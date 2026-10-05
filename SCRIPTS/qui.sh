#!/bin/bash
# Qui travaille dans ce chantier, et où en est chacun.
#
#   qui.sh [REPERTOIRE]              le relevé : qui est là, les branches, qui a touché quoi
#   qui.sh --arrivee NOM [REPERTOIRE]  au début d'une session : avertit si le chantier n'est
#                                    peut-être pas libre, dit où est la version la plus
#                                    avancée, puis note la présence de NOM
#   qui.sh --vu NOM [REPERTOIRE]     note la présence de NOM sans rien afficher (à chaque message)
#   --jours N                        le relevé regarde les N derniers jours (défaut : 30)
#
# NOM est le nom d'intervenant, celui qui signe les commits : Claude-Code, Codex...
# Un chantier se travaille dans un seul répertoire, à tour de rôle. Ce script ne verrouille
# rien : il dit ce qu'il voit, et c'est Olivier qui décide d'attendre ou d'ouvrir un poste
# (nouveau-poste.sh).
#
# La présence d'un intervenant est un fichier vide, <répertoire git>/intervenants/NOM, dont
# la date dit quand il a été vu pour la dernière fois. Il vit dans .git : ni suivi, ni vu par
# git status. Un poste (worktree) a son répertoire git à lui, donc ses propres présences.
# Appelé par des hooks : ne sort jamais en erreur, et --vu ne dit jamais rien.
set -u

usage() { sed -n '2,/^set -u/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 0; }
MODE=releve; MOI=""; JOURS=30
while [ $# -gt 0 ]; do
  case "$1" in
    --arrivee|--vu) [ $# -ge 2 ] || exit 0; MODE=${1#--}; MOI=$2; shift ;;
    --jours)        [ $# -ge 2 ] || exit 0; JOURS=$2; shift ;;
    -h|--help)      usage ;;
    -*)             echo "option inconnue : $1"; exit 0 ;;
    *)              cd "$1" 2>/dev/null || { echo "$1 : répertoire introuvable"; exit 0; } ;;
  esac
  shift
done
case "$JOURS" in *[!0-9]*|"") JOURS=30 ;; esac
case "$MOI" in */*) exit 0 ;; esac

g() { git --no-optional-locks "$@" 2>/dev/null; }
GD=$(g rev-parse --absolute-git-dir) || { [ "$MODE" = vu ] || echo "Pas un dépôt git : $(pwd)"; exit 0; }
TOP=$(g rev-parse --show-toplevel) && cd "$TOP" || exit 0
PRES=$GD/intervenants
MAINTENANT=$(date +%s)
TAB=$(printf '\t')

mtime() { stat -f %m "$1" 2>/dev/null || stat -c %Y "$1" 2>/dev/null || echo 0; }
ilya() {
  if [ "$1" -lt 120 ]; then echo "à l'instant"
  elif [ "$1" -lt 7200 ]; then echo "il y a $(($1 / 60)) minutes"
  elif [ "$1" -lt 172800 ]; then echo "il y a $(($1 / 3600)) heures"
  else echo "il y a $(($1 / 86400)) jours"; fi
}
note_presence() { [ -n "$MOI" ] && mkdir -p "$PRES" 2>/dev/null && : > "$PRES/$MOI"; }
# Les présences, la plus récente d'abord : secondes écoulées, tabulation, nom.
presences() {
  [ -d "$PRES" ] || return 0
  for f in "$PRES"/*; do
    [ -f "$f" ] || continue
    printf '%s\t%s\n' "$((MAINTENANT - $(mtime "$f")))" "$(basename "$f")"
  done | sort -n
}
# La branche, locale ou distante, qui a le plus de commits que l'arbre de travail n'a pas.
plus_avancee() {
  g for-each-ref refs/heads refs/remotes --format='%(refname:short)' | grep -v -e '^worktree-' -e '/HEAD$' \
    | while IFS= read -r b; do
        n=$(g rev-list --count "HEAD..$b")
        [ "${n:-0}" -gt 0 ] && printf '%s\t%s\n' "$n" "$b"
      done | sort -t "$TAB" -k1,1nr | sed -n 1p
}

# Les sessions Claude Code dont le répertoire courant est ce dépôt. Une session ouverte
# n'est pas forcément active, et les sessions de Codex ne se voient pas ainsi.
sessions_claude() {
  command -v lsof >/dev/null 2>&1 || { echo 0; return; }
  n=0
  for pid in $(ps -Ao pid=,comm= | awk '{ k = split($NF, a, "/"); if (a[k] == "claude") print $1 }'); do
    [ "$(lsof -a -p "$pid" -d cwd -Fn 2>/dev/null | sed -n 's/^n//p')" = "$TOP" ] && n=$((n + 1))
  done
  echo "$n"
}

if [ "$MODE" = vu ]; then note_presence; exit 0; fi

MODIFS=$(g status --porcelain | grep -v '^??' | cut -c4-)
NMODIFS=$(printf '%s' "$MODIFS" | awk 'NF { n++ } END { print n + 0 }')
BRANCHE=$(g rev-parse --abbrev-ref HEAD)

if [ "$MODE" = arrivee ]; then
  [ -n "$MOI" ] || exit 0
  # Ma propre présence est fraîche : c'est la même session qui reprend (après /compact ou
  # /resume), et les fichiers en attente sont alors les miens.
  reprise=0
  if [ -f "$PRES/$MOI" ] && [ $((MAINTENANT - $(mtime "$PRES/$MOI"))) -lt 3600 ]; then reprise=1; fi
  alertes=""
  while IFS=$TAB read -r age nom; do
    [ -n "$nom" ] && [ "$nom" != "$MOI" ] && [ "$age" -lt 3600 ] && alertes="$alertes  - $nom a été vu ici $(ilya "$age")
"
  done <<EOF
$(presences)
EOF
  if [ "$NMODIFS" -gt 0 ] && [ "$reprise" = 0 ]; then
    alertes="$alertes  - $NMODIFS fichier(s) suivi(s) modifié(s) sans être commité(s) : $(printf '%s' "$MODIFS" | awk 'NR <= 4 { printf "%s%s", (NR > 1 ? ", " : ""), $0 } END { if (NR > 4) printf ", ..." }')
"
  fi
  dernier=$(g log -1 --format="%ct$TAB%an")
  if [ -n "$dernier" ]; then
    age=$((MAINTENANT - ${dernier%%$TAB*})); par=${dernier#*$TAB}
    # un commit d'Olivier lui-même n'est pas le signe qu'un autre assistant travaille
    [ "$par" != "$MOI" ] && [ "$par" != "$(g config user.name)" ] && [ "$age" -lt 1800 ] \
      && alertes="$alertes  - dernier commit $(ilya "$age"), par $par
"
  fi
  echo "--- Qui travaille ici (qui.sh) ---"
  if [ -n "$alertes" ]; then
    echo "ATTENTION, ce chantier n'est peut-être pas libre :"
    printf '%s' "$alertes"
    echo "Un chantier se travaille à tour de rôle : avant de modifier quoi que ce soit, dis-le à"
    echo "Olivier. Il peut attendre la passation de l'autre, ou demander un poste temporaire."
  else
    echo "Chantier libre : aucun autre intervenant vu depuis une heure, rien en attente de commit."
  fi
  n=$(sessions_claude)
  [ "$n" -gt 1 ] && echo "$n sessions Claude Code sont ouvertes sur ce répertoire : une seule doit y travailler."
  av=$(plus_avancee)
  if [ -n "$av" ]; then
    b=${av#*$TAB}
    echo "L'arbre est sur $BRANCHE, mais $b a ${av%%$TAB*} commit(s) qu'il n'a pas"
    echo "($(g log -1 --date=short --format='%an, %cd' "$b")) : la version la plus avancée est peut-être là. Détail : make qui."
  fi
  note_presence
  exit 0
fi

# ---------- le relevé ----------
if g show-ref --verify --quiet refs/heads/main; then DEF=main
elif g show-ref --verify --quiet refs/heads/master; then DEF=master
else DEF=$BRANCHE; fi

echo "$(basename "$TOP"), arbre sur $BRANCHE ($(g rev-parse --short HEAD))"
echo
echo "Qui est là"
p=$(presences)
if [ -n "$p" ]; then
  printf '%s\n' "$p" | while IFS=$TAB read -r age nom; do printf '  %-16s vu %s\n' "$nom" "$(ilya "$age")"; done
else
  echo "  personne n'a encore été vu ici (les présences se notent au début de chaque session)"
fi
n=$(sessions_claude)
[ "$n" -gt 0 ] && echo "  $n session(s) Claude Code ouverte(s) sur ce répertoire (ouverte ne veut pas dire active)"
if [ "$NMODIFS" -gt 0 ]; then
  echo "  $NMODIFS fichier(s) suivi(s) modifié(s) sans être commité(s) :"
  printf '%s\n' "$MODIFS" | sed -n '1,8p' | sed 's/^/    /'
fi
g worktree list --porcelain | awk -v home="$HOME" 'BEGIN { RS = ""; FS = "\n" }
  NR > 1 { p = ""; b = "tête détachée"
    for (i = 1; i <= NF; i++) {
      if ($i ~ /^worktree /) p = substr($i, 10)
      if ($i ~ /^branch /) { b = substr($i, 8); sub(/^refs\/heads\//, "", b) }
    }
    if (index(p, home "/") == 1) p = "~" substr(p, length(home) + 1)
    if (p ~ /\/\.claude\/worktrees\//) agents++
    else printf "  poste : %s (%s)\n", p, b }
  END { if (agents) printf "  %d worktree(s) d\047agent(s) resté(s) dans le dépôt\n", agents }'

echo
echo "Branches, par rapport à $DEF"
T=$(mktemp -d "${TMPDIR:-/tmp}/qui.XXXXXX") || exit 0
trap 'rm -rf "$T"' EXIT
g for-each-ref --sort=-committerdate refs/heads \
    --format="%(refname:short)$TAB%(committerdate:short)$TAB%(authorname)" > "$T/tmp"
: > "$T/nf"; : > "$T/pointes"; fusionnees=0; restes=0; reprises=0
while IFS=$TAB read -r b date par; do
  case "$b" in worktree-*) restes=$((restes + 1)); continue ;; esac
  devant=$(g rev-list --count "$DEF..$b"); derriere=$(g rev-list --count "$b..$DEF")
  if [ "$b" = "$DEF" ]; then printf '%s\t%s\t%s\n' "$b" "$date" "$par" > "$T/def"; continue; fi
  if [ "${devant:-0}" -eq 0 ] && [ "$b" != "$BRANCHE" ]; then fusionnees=$((fusionnees + 1)); continue; fi
  printf '%s\t%s\t%s\t%s\t%s\n' "$b" "$date" "$par" "${devant:-0}" "${derriere:-0}" >> "$T/nf"
done < "$T/tmp"
# Une pointe est une branche qu'aucune autre ne contient : son travail n'est repris nulle part
# ailleurs. Les autres sont déjà contenues dans une pointe, on ne fait que les compter.
while IFS=$TAB read -r b date par devant derriere; do
  sha=$(g rev-parse "$b")
  dans=$(g branch --contains "$b" --format='%(refname:short)' | grep -v -e '^worktree-' -e '^(' \
    | while IFS= read -r c; do
        [ "$c" = "$b" ] || [ "$c" = "$DEF" ] || [ "$(g rev-parse "$c")" = "$sha" ] || { echo "$c"; break; }
      done)
  if [ -n "$dans" ] && [ "$b" != "$BRANCHE" ]; then reprises=$((reprises + 1))
  else printf '%s\t%s\t%s\t%s\t%s\n' "$b" "$date" "$par" "$devant" "$derriere" >> "$T/pointes"; fi
done < "$T/nf"
cut -f1 "$T/nf" > "$T/noms"
sed -n '1,12p' "$T/pointes" | while IFS=$TAB read -r b date par devant derriere; do
  note=""
  [ "$b" = "$BRANCHE" ] && note="  <- arbre de travail"
  repris=$(g branch --merged "$b" --format='%(refname:short)' | grep -vx "$b" | grep -xF -f "$T/noms")
  n=$(printf '%s' "$repris" | awk 'NF { n++ } END { print n + 0 }')
  if [ "$n" -gt 3 ]; then note="$note  reprend $n autres branches"
  elif [ "$n" -gt 0 ]; then note="$note  reprend $(printf '%s' "$repris" | awk '{ printf "%s%s", (NR > 1 ? ", " : ""), $0 }')"; fi
  printf '  %-34s %s  %-15s %3s devant, %3s derrière%s\n' "$b" "$date" "$par" "$devant" "$derriere" "$note"
done
np=$(awk 'END { print NR }' "$T/pointes")
[ "$np" -gt 12 ] && echo "  ... et $((np - 12)) autres pointes, plus anciennes"
if [ -s "$T/def" ]; then
  IFS=$TAB read -r b date par < "$T/def"
  if [ "$DEF" = "$BRANCHE" ]; then note="<- arbre de travail"; else note="la référence"; fi
  printf '  %-34s %s  %-15s %s\n' "$b" "$date" "$par" "$note"
fi
[ "$reprises" -gt 0 ] && echo "  $reprises branche(s) déjà contenue(s) dans une autre : leur travail est repris plus haut"
[ "$fusionnees" -gt 0 ] && echo "  $fusionnees branche(s) déjà fusionnée(s) dans $DEF"
[ "$restes" -gt 0 ] && echo "  $restes branche(s) worktree-*, restes d'agents"
av=$(plus_avancee)
if [ -n "$av" ]; then
  echo "  La plus avancée par rapport à l'arbre : ${av#*$TAB}, ${av%%$TAB*} commit(s) que l'arbre n'a pas."
else
  echo "  Rien n'est en avance sur l'arbre de travail."
fi

# Qui a touché quoi : une seule lecture de l'historique, toutes branches, le plus récent d'abord.
if [ -n "$(g ls-files '*.tex' | sed -n 1p)" ]; then quoi="les fichiers .tex"; set -- '*.tex'
else quoi="les fichiers"; set -- . ':!NOTES.md' ':!CHANTIER.md' ':!passations'; fi
echo
echo "Qui a touché quoi, sur $JOURS jours ($quoi, toutes branches)"
g log --since="$JOURS days ago" --name-only --date=short --format="@%H$TAB%an$TAB%cd" \
    HEAD --branches --remotes -- "$@" \
  | awk -F'\t' '
      /^@/ { h = substr($1, 2); qui = $2; quand = $3; next }
      NF == 0 { next }
      { if (!($0 in dernier)) { dernier[$0] = h; par[$0] = qui; date[$0] = quand; ordre[++n] = $0 }
        c[$0 SUBSEP qui]++; if (c[$0 SUBSEP qui] > m[$0]) { m[$0] = c[$0 SUBSEP qui]; surtout[$0] = qui } }
      END { for (i = 1; i <= n; i++) { f = ordre[i]; printf "%s\t%s\t%s\t%s\t%d\t%s\n", f, par[f], date[f], surtout[f], m[f], dernier[f] } }' \
  > "$T/tmp"
nf=$(awk 'END { print NR }' "$T/tmp")
if [ "$nf" -eq 0 ]; then
  echo "  rien depuis $JOURS jours"
else
  ailleurs=0
  # rangés par chemin, comme une table des matières ; au-delà de 40, les plus récents seulement
  if sort -V /dev/null 2>/dev/null; then tri="-k1,1V"; else tri="-k1,1"; fi
  sed -n '1,40p' "$T/tmp" | sort -t "$TAB" $tri > "$T/nf"
  while IFS=$TAB read -r f par date surtout combien h; do
    ou=""
    if ! g merge-base --is-ancestor "$h" HEAD; then
      b=$(g branch --contains "$h" --format='%(refname:short)' | grep -v '^worktree-' | sed -n 1p)
      [ -n "$b" ] || b=$(g branch -r --contains "$h" --format='%(refname:short)' | sed -n 1p)
      ou="  PAS DANS L'ARBRE : sur ${b:-une autre branche}"; ailleurs=$((ailleurs + 1))
    fi
    case "${#f}" in ?|[1-3]?|4[0-4]) court=$f ;; *) court="...${f: -41}" ;; esac
    printf '  %-44s %-14s %s  surtout %s (%s)%s\n' "$court" "$par" "$date" "$surtout" "$combien" "$ou"
  done < "$T/nf"
  [ "$nf" -gt 40 ] && echo "  ... et $((nf - 40)) autres fichiers, touchés moins récemment"
  [ "$ailleurs" -gt 0 ] && echo "  $ailleurs fichier(s) ont leur version la plus récente ailleurs que dans l'arbre de travail."
fi
exit 0
