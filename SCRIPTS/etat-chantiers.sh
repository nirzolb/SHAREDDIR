#!/bin/bash
# Dresse le registre des chantiers : CHANTIERS.md, engendré, jamais tenu à la main.
#
#   etat-chantiers.sh [--racine DIR] [--sortie FICHIER] [--fetch] [--sommeil JOURS]
#
#   --racine DIR     répertoire des chantiers (défaut : $CHANTIERS_DIR ou /Users/bournez/00-CHANTIERS-CARE)
#   --sortie FICHIER où écrire le registre (défaut : DIR/CHANTIERS.md ; - pour la sortie standard)
#   --fetch          git fetch dans chaque dépôt avant de lire, pour voir ce qui a été poussé
#                    depuis une autre machine ; sans cette option le script ne modifie aucun dépôt
#   --sommeil JOURS  sans commit depuis JOURS jours, un chantier est dit en sommeil (défaut : 21)
#
# Est un chantier tout dépôt git trouvé sous DIR, jusqu'à trois niveaux, liens symboliques
# compris ; on ne descend pas dans un dépôt. Un worktree est rattaché à son dépôt, comme poste.
#
# Vient de git : l'ouverture (premier commit), la dernière activité et son auteur, les
# intervenants, la branche courante, ce qui n'est ni commité ni poussé, les branches non
# fusionnées, les postes et les worktrees d'agents. Le finalisé vient de DEST dans Makefile.local.
# Vient de la fiche CHANTIER.md du chantier, quand elle existe, ce que git ne sait pas :
#
#   - Parent : CARE-CHANTIER-Exemple
#   - En bref : de quoi il s'agit, en une ou deux phrases, sur une seule ligne.
#
#   ## Journal
#   - 2026-09-03 ouvert
#   - 2026-09-28 clos (soumis)
#   - 2026-10-12 rouvert (révision demandée)
#
# « Parent : aucun » pour une racine. L'état est le premier mot de la dernière ligne du
# journal (ouvert, clos, rouvert) ; sans fiche, le chantier est tenu pour ouvert. La fiche
# est lue dans l'arbre de travail, à défaut dans la branche la plus récente qui en porte une.
#
# Le registre nomme des chantiers privés : il sort sous DIR, jamais dans SHAREDDIR, qui est public.
set -euo pipefail

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 1; }
RACINE="${CHANTIERS_DIR:-/Users/bournez/00-CHANTIERS-CARE}"
SORTIE=""; FETCH=0; SOMMEIL=21
while [ $# -gt 0 ]; do
  case "$1" in
    --racine)  RACINE="$2"; shift ;;
    --sortie)  SORTIE="$2"; shift ;;
    --fetch)   FETCH=1 ;;
    --sommeil) SOMMEIL="$2"; shift ;;
    *) echo "option inconnue : $1"; usage ;;
  esac
  shift
done
[ -d "$RACINE" ] || { echo "$RACINE n'existe pas"; exit 1; }
RACINE=$(cd "$RACINE" && pwd)
[ -n "$SORTIE" ] || SORTIE="$RACINE/CHANTIERS.md"
case "$SOMMEIL" in *[!0-9]*|"") echo "--sommeil : un nombre de jours"; exit 1 ;; esac

TMP=$(mktemp -d "${TMPDIR:-/tmp}/etat-chantiers.XXXXXX")
trap 'rm -rf "$TMP"' EXIT

# Les dépôts sous $1 : on s'arrête au premier .git rencontré, et au troisième niveau.
depots() {
  local d=$1 p=$2 e
  if [ -e "$d/.git" ]; then printf '%s\n' "$d"; return 0; fi
  if [ "$p" -ge 3 ]; then return 0; fi
  for e in "$d"/*/; do
    if [ -d "$e" ]; then depots "${e%/}" $((p + 1)); fi
  done
  return 0
}
tilde() { case "$1" in "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;; *) printf '%s' "$1" ;; esac; }
# git dans le dépôt courant, sans verrou ni écriture d'index ; un échec donne une sortie vide.
# Pas de head derrière : sous pipefail, un tube refermé trop tôt arrêterait le script.
g() { git --no-optional-locks -C "$TOP" "$@" 2>/dev/null || true; }

: > "$TMP/vus"; : > "$TMP/lignes"
depots "$RACINE" 0 | while IFS= read -r D; do
  [ -d "$D/.git" ] || continue      # .git fichier : un poste, rattaché plus bas à son dépôt
  TOP=$(cd "$D" && pwd -P)
  if grep -qxF "$TOP" "$TMP/vus"; then continue; fi
  printf '%s\n' "$TOP" >> "$TMP/vus"
  if [ "$FETCH" = 1 ]; then
    git -C "$TOP" fetch --all --quiet 2>/dev/null || echo "fetch impossible : $TOP" >&2
  fi

  NOM=$(basename "$TOP")
  BRANCHE=$(g rev-parse --abbrev-ref HEAD)
  DERNIER=$(g log -1 --date=short --format='%ct%x09%cd%x09%an' HEAD --branches --remotes)
  EPOQUE=$(printf '%s' "$DERNIER" | cut -f1)
  DATE=$(printf '%s' "$DERNIER" | cut -f2)
  PAR=$(printf '%s' "$DERNIER" | cut -f3)
  OUVERT=$(g log --date=short --format='%at %ad' HEAD --branches --remotes | sort -n | sed -n 1p | cut -d' ' -f2)
  INTERV=$(g log --date=short --format='%an%x09%cd' HEAD --branches --remotes \
    | awk -F'\t' '!v[$1]++ { printf "%s%s (%s)", (n++ ? ", " : ""), $1, $2 }')
  g status --porcelain > "$TMP/st"
  NMOD=$(awk '!/^\?\?/ { n++ } END { print n + 0 }' "$TMP/st")
  NNS=$(awk '/^\?\?/ { n++ } END { print n + 0 }' "$TMP/st")

  DISTANT=$(g remote | awk '$0 == "origin" { o = 1 } NR == 1 { p = $0 } END { print (o ? "origin" : p) }'); URL=""; NONP=""
  if [ -n "$DISTANT" ]; then
    URL=$(g remote get-url "$DISTANT"); URL=${URL%.git}; URL=${URL#https://github.com/}; URL=${URL#git@github.com:}
    NONP=$(g rev-list --count HEAD --branches --not --remotes)
  fi

  # Branches non fusionnées dans la branche principale ; les worktree-* sont comptées à part,
  # ce sont les restes d'agents lancés en isolation.
  if git -C "$TOP" show-ref --verify --quiet refs/heads/main 2>/dev/null; then DEF=main
  elif git -C "$TOP" show-ref --verify --quiet refs/heads/master 2>/dev/null; then DEF=master
  else DEF=$BRANCHE; fi
  g for-each-ref refs/heads --no-merged "$DEF" --format='%(refname:short)' > "$TMP/nf"
  NORCH=$(awk '/^worktree-/ { n++ } END { print n + 0 }' "$TMP/nf")
  NNF=$(awk '!/^worktree-/ { n++ } END { print n + 0 }' "$TMP/nf")
  NOMSNF=$(awk '!/^worktree-/ { if (++n <= 4) printf "%s%s", (n > 1 ? ", " : ""), $0 } END { if (n > 4) printf ", ..." }' "$TMP/nf")

  # Worktrees au-delà du premier, qui est le dépôt lui-même : ceux qui sont rangés dans le
  # dépôt (.claude/worktrees) sont des restes d'agents, les autres sont des postes.
  g worktree list --porcelain | awk -v top="$TOP" -v home="$HOME" 'BEGIN { RS = ""; FS = "\n" }
    NR > 1 { p = ""; b = "tête détachée"
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^worktree /) p = substr($i, 10)
        if ($i ~ /^branch /) { b = substr($i, 8); sub(/^refs\/heads\//, "", b) }
      }
      if (index(p, top "/") == 1) { print "agent"; next }
      if (index(p, home "/") == 1) p = "~" substr(p, length(home) + 1)
      printf "poste\t`%s` (%s)\n", p, b }' > "$TMP/wt"
  NAGENTS=$(awk '$1 == "agent" { n++ } END { print n + 0 }' "$TMP/wt")
  NPOSTES=$(awk -F'\t' '$1 == "poste" { n++ } END { print n + 0 }' "$TMP/wt")
  POSTES=$(awk -F'\t' '$1 == "poste" { printf "%s%s", (n++ ? ", " : ""), $2 }' "$TMP/wt")

  FINAL=""; FINALOK=1
  for f in "$TOP/Makefile.local" "$TOP/Makefile"; do
    if [ -z "$FINAL" ] && [ -f "$f" ]; then
      FINAL=$(sed -n 's/^DEST[[:space:]]*[:?]\{0,1\}=[[:space:]]*//p' "$f" | sed -n 1p | sed 's/[[:space:]]*$//')
    fi
  done
  if [ -n "$FINAL" ]; then
    if [ ! -d "$FINAL" ]; then FINALOK=0; fi
    FINAL=$(tilde "$FINAL")
  fi

  # La fiche : celle de l'arbre de travail, sinon celle de la branche la plus récente qui en
  # porte une, pour qu'un changement de branche ne fasse pas perdre son parent au chantier.
  FICHE=0; PARENT=""; BREF=""; JOURNAL=""; EFICHE=""; F=$TOP/CHANTIER.md
  if [ ! -f "$F" ]; then
    F=""
    for ref in $(g for-each-ref --sort=-committerdate --format='%(refname)' refs/heads refs/remotes); do
      if git -C "$TOP" cat-file -e "$ref:CHANTIER.md" 2>/dev/null; then
        g show "$ref:CHANTIER.md" > "$TMP/fiche"; F=$TMP/fiche; break
      fi
    done
  fi
  if [ -n "$F" ]; then
    FICHE=1
    PARENT=$(sed -n 's/^- Parent[[:space:]]*:[[:space:]]*//p' "$F" | sed -n 1p | tr -d '`' | sed 's/[[:space:]]*$//')
    case "$PARENT" in aucun|Aucun|aucun.) PARENT="" ;; esac
    BREF=$(sed -n 's/^- En bref[[:space:]]*:[[:space:]]*//p' "$F" | sed -n 1p)
    case "$BREF" in __A_REMPLIR*) BREF="" ;; esac      # le trou du squelette, pas encore rempli
    JOURNAL=$(awk '/^## Journal/ { j = 1; next } /^## / { j = 0 }
      j && /^- [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] / { sub(/^- /, ""); printf "%s%s", (n++ ? " ; " : ""), $0 }' "$F")
    EFICHE=$(awk '/^## Journal/ { j = 1; next } /^## / { j = 0 }
      j && /^- [0-9][0-9][0-9][0-9]-[0-9][0-9]-[0-9][0-9] / { e = $3 } END { print e }' "$F")
  fi

  # Une ligne par chantier, champs séparés par des tabulations ; l'époque en dernier, pour le tri.
  for v in "$NOM" "$(tilde "$TOP")" "$PARENT" "$EFICHE" "$BREF" "$OUVERT" "$DATE" "$PAR" "$INTERV" \
           "$BRANCHE" "$NMOD" "$NONP" "$NNF" "$NOMSNF" "$NORCH" "$POSTES" "$NPOSTES" "$FINAL" "$FINALOK" \
           "$URL" "$FICHE" "$JOURNAL" "$NNS" "$NAGENTS"; do
    printf '%s\t' "$(printf '%s' "$v" | tr '\t\n' '  ')"
  done >> "$TMP/lignes"
  printf '%s\n' "${EPOQUE:-0}" >> "$TMP/lignes"
done

cat > "$TMP/rendu.awk" <<'AWK'
BEGIN { FS = "\t" }
function court(n) { sub(/^CARE-CHANTIER-/, "", n); return n }
function pl(k) { return (k > 1 ? "s" : "") }
function ajoute(s, t) { return (s == "" ? t : s " ; " t) }
function etat(i) {
  if (efiche[i] ~ /^clos/) return "clos"
  if (epoque[i] == 0) return "sans commit"
  return ((maintenant - epoque[i]) / 86400 > sommeil) ? "en sommeil" : "actif"
}
function avoir(i,   s) {
  s = ""
  if (nmod[i] > 0) s = ajoute(s, nmod[i] " fichier" pl(nmod[i]) " modifié" pl(nmod[i]))
  if (nns[i] > 0) s = ajoute(s, nns[i] " non suivi" pl(nns[i]))
  if (url[i] == "") s = ajoute(s, "pas de dépôt distant")
  else if (nonp[i] > 0) s = ajoute(s, nonp[i] " commit" pl(nonp[i]) " non poussé" pl(nonp[i]))
  if (nnf[i] > 0) s = ajoute(s, nnf[i] " branche" pl(nnf[i]) " non fusionnée" pl(nnf[i]))
  if (norch[i] > 0) s = ajoute(s, norch[i] " branche" pl(norch[i]) " worktree-*")
  if (npostes[i] > 0) s = ajoute(s, npostes[i] " poste" pl(npostes[i]) " en plus")
  if (nagents[i] > 0) s = ajoute(s, nagents[i] " worktree" pl(nagents[i]) " d'agent" pl(nagents[i]))
  return s
}
# Dernière activité d'un chantier ou de sa descendance : une famille se range d'après son
# membre le plus récemment actif, pas d'après sa racine.
function recent(i,   e, k, j, r, x) {
  if (i in rec) return rec[i]
  if (encours[i]) return epoque[i]
  encours[i] = 1; r = epoque[i]
  k = split(enfants[i], e, " ")
  for (j = 1; j <= k; j++) { x = recent(e[j] + 0); if (x > r) r = x }
  encours[i] = 0; rec[i] = r
  return r
}
function trie(liste,   a, k, j, l, t, s) {
  k = split(liste, a, " ")
  for (j = 2; j <= k; j++) {
    t = a[j]
    for (l = j - 1; l >= 1 && recent(a[l] + 0) < recent(t + 0); l--) a[l + 1] = a[l]
    a[l + 1] = t
  }
  s = ""
  for (j = 1; j <= k; j++) s = s " " a[j]
  return s
}
# Parcours en profondeur : un parent, puis ses enfants.
function parcours(i, d,   e, k, j) {
  if (vu[i]) return
  vu[i] = 1; ordre[++m] = i; prof[m] = d
  k = split(trie(enfants[i]), e, " ")
  for (j = 1; j <= k; j++) parcours(e[j] + 0, d + 1)
}
{
  n++
  nom[n] = court($1); chemin[n] = $2; parent[n] = court($3); efiche[n] = $4; bref[n] = $5
  ouvert[n] = $6; date[n] = $7; par[n] = $8; interv[n] = $9; branche[n] = $10
  nmod[n] = $11 + 0; nonp[n] = $12 + 0; nnf[n] = $13 + 0; nomsnf[n] = $14; norch[n] = $15 + 0
  postes[n] = $16; npostes[n] = $17 + 0; final[n] = $18; finalok[n] = $19 + 0; url[n] = $20
  fiche[n] = $21 + 0; journal[n] = $22; nns[n] = $23 + 0; nagents[n] = $24 + 0; epoque[n] = $25 + 0
  rang[nom[n]] = n
}
END {
  for (i = 1; i <= n; i++) {
    p = parent[i]
    if (p != "" && (p in rang) && rang[p] != i) enfants[rang[p]] = enfants[rang[p]] " " i
    else racines = racines " " i
  }
  c = split(trie(racines), f, " ")
  for (j = 1; j <= c; j++) parcours(f[j] + 0, 0)
  for (i = 1; i <= n; i++) if (!vu[i]) parcours(i, 0)     # parents en boucle : montrés quand même
  for (k = 1; k <= m; k++) compte[etat(ordre[k])]++

  printf "# Chantiers\n\n"
  printf "Registre engendré le %s sur %s par `SHAREDDIR/SCRIPTS/etat-chantiers.sh`.\n", quand, machine
  printf "Ne pas le modifier : il est réécrit à chaque passage. Ce que git ne sait pas (parent, résumé,\n"
  printf "clôture) se corrige dans la fiche `CHANTIER.md` du chantier.\n\n"
  printf "%d chantier%s : %d actif%s, %d en sommeil (sans commit depuis plus de %d jours), %d clos.\n\n", \
    m, pl(m), compte["actif"], pl(compte["actif"]), compte["en sommeil"], sommeil, compte["clos"]

  print "| Chantier | État | Ouvert | Dernière activité | Par | À voir |"
  print "|---|---|---|---|---|---|"
  for (k = 1; k <= m; k++) {
    i = ordre[k]; pre = ""
    for (j = 0; j < prof[k]; j++) pre = pre "↳ "
    printf "| %s%s | %s | %s | %s | %s | %s |\n", pre, nom[i], etat(i), ouvert[i], date[i], par[i], avoir(i)
    if (!fiche[i]) sansfiche = sansfiche (sansfiche == "" ? "" : ", ") nom[i]
  }
  print ""
  print "Un chantier né d'un autre est rangé sous lui, marqué ↳."
  if (sansfiche != "") printf "Sans fiche `CHANTIER.md`, donc sans parent ni résumé : %s.\n", sansfiche

  printf "\n## Détail\n"
  for (k = 1; k <= m; k++) {
    i = ordre[k]
    printf "\n### %s\n\n", nom[i]
    if (bref[i] != "") printf "- En bref : %s\n", bref[i]
    printf "- État : %s%s\n", etat(i), (journal[i] != "" ? " ; journal : " journal[i] : "")
    if (!fiche[i]) print "- Parent : non renseigné"
    else if (parent[i] == "") print "- Parent : aucun"
    else printf "- Parent : %s%s\n", parent[i], ((parent[i] in rang) ? "" : " (absent de cette machine)")
    c = split(enfants[i], f, " ")
    if (c > 0) {
      printf "- Enfants : "
      for (j = 1; j <= c; j++) printf "%s%s", (j > 1 ? ", " : ""), nom[f[j] + 0]
      print ""
    }
    printf "- Chemin : `%s`\n", chemin[i]
    printf "- Dépôt distant : %s\n", (url[i] != "" ? "`" url[i] "`" : "aucun")
    if (final[i] == "") print "- Finalisé : non déclaré"
    else printf "- Finalisé : `%s`%s\n", final[i], (finalok[i] ? "" : " (absent de cette machine)")
    if (epoque[i] > 0) {
      printf "- Ouvert le %s ; dernière activité le %s, par %s\n", ouvert[i], date[i], par[i]
      printf "- Intervenants : %s\n", interv[i]
    }
    t = ""
    if (nmod[i] > 0) t = ajoute(t, nmod[i] " fichier" pl(nmod[i]) " modifié" pl(nmod[i]) " non commité" pl(nmod[i]))
    if (nns[i] > 0) t = ajoute(t, nns[i] " non suivi" pl(nns[i]))
    printf "- Branche courante : `%s`, %s\n", branche[i], (t == "" ? "arbre propre" : t)
    if (url[i] != "") printf "- Non poussé : %s\n", (nonp[i] > 0 ? nonp[i] " commit" pl(nonp[i]) : "rien")
    if (nnf[i] > 0) printf "- Branches non fusionnées dans la branche principale : %d (%s)\n", nnf[i], nomsnf[i]
    if (norch[i] > 0) printf "- Branches `worktree-*` laissées par des agents : %d\n", norch[i]
    if (npostes[i] > 0) printf "- Postes en plus : %s\n", postes[i]
    if (nagents[i] > 0) printf "- Worktrees d'agents restés dans le dépôt : %d\n", nagents[i]
  }
}
AWK

N=$(awk 'END { print NR }' "$TMP/lignes")
if [ "$N" = 0 ]; then echo "Aucun dépôt git sous $RACINE"; exit 1; fi
sort -t "$(printf '\t')" -k25,25nr "$TMP/lignes" \
  | awk -v maintenant="$(date +%s)" -v sommeil="$SOMMEIL" -v quand="$(date '+%Y-%m-%d à %Hh%M')" \
        -v machine="$(hostname -s)" -f "$TMP/rendu.awk" > "$TMP/registre"

if [ "$SORTIE" = - ]; then
  cat "$TMP/registre"
else
  mv "$TMP/registre" "$SORTIE"
  echo "Registre écrit : $SORTIE ($N chantiers)"
fi
