#!/bin/bash
# Déplace un chantier dans un autre répertoire, et remet d'aplomb ce qui le connaissait par
# son chemin.
#
#   deplacer-chantier.sh [-n] [--force] [--sans-lien] CHANTIER DESTINATION
#   deplacer-chantier.sh [-n] [--sans-lien] --apres CHANTIER
#
#   CHANTIER     son répertoire, ou son nom, cherché dans l'annuaire jusqu'à trois niveaux
#   DESTINATION  le répertoire où le ranger, créé au besoin : le chantier devient
#                DESTINATION/<son nom>
#   -n           dit ce qui serait fait, sans rien faire
#   --force      déplace même si une session Claude Code ou Codex y est ouverte, ou vers un
#                répertoire que Claude Code n'a pas le droit de lire
#   --sans-lien  ne pose pas de lien dans l'annuaire
#   --apres      le chantier a déjà été déplacé à la main (mv, Finder) : CHANTIER est son
#                répertoire d'aujourd'hui, et le script rattrape les points 3 à 5
#
# L'annuaire est $CHANTIERS_DIR, à défaut /Users/bournez/00-CHANTIERS-CARE : c'est là que le
# registre (etat-chantiers.sh) cherche les chantiers. Un chantier rangé ailleurs y a un lien
# symbolique, que le registre suit.
#
# Ce que fait le script :
#   1. refuse si CHANTIER n'est pas un dépôt git, s'il a des postes (un worktree note le
#      chemin de son dépôt), si DESTINATION/<nom> existe, si une session y est ouverte, ou
#      si ~/.claude/settings.json interdit à Claude Code de lire sous DESTINATION : il ne
#      pourrait plus y travailler, ni le registre l'y voir quand c'est lui qui le dresse ;
#   2. déplace le répertoire ;
#   3. tient l'annuaire : le chantier qui en sort y laisse un lien à sa place, un lien qui
#      pointait sur l'ancien emplacement est refait, ou retiré si le chantier y revient ;
#   4. renomme le répertoire où Claude Code range la mémoire et les conversations du
#      chantier, ~/.claude/projects/<chemin, tout caractère non alphanumérique devenu ->,
#      pour qu'une session ouverte au nouvel endroit les retrouve ; si elle en a déjà
#      ouvert un, l'ancien y est versé sans rien écraser ;
#   5. dit ce qui reste à faire à la main.
#
# Sous --apres, l'ancien emplacement n'est plus connu. Le script le retrouve dans
# ~/.claude/projects : tout répertoire dont le nom finit par celui du chantier, sauf s'il est
# à un autre répertoire de ce nom qui existe toujours (ses conversations disent où elles ont
# eu lieu). Dans l'annuaire, il retire un lien à ce nom qui ne mène plus nulle part, et en
# pose un si le registre ne peut plus atteindre le chantier.
#
# Rien dans le chantier n'est modifié : ni fichier suivi, ni git. À lancer par Olivier depuis
# son terminal, sessions fermées : un assistant n'a pas le droit d'écrire dans ~/.claude.
set -euo pipefail

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 1; }
SEC=0; FORCE=0; LIEN=1; APRES=0; ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -n)          SEC=1 ;;
    --force)     FORCE=1 ;;
    --sans-lien) LIEN=0 ;;
    --apres)     APRES=1 ;;
    -h|--help)   usage ;;
    -*)          echo "option inconnue : $1"; usage ;;
    *)           ARGS+=("$1") ;;
  esac
  shift
done
[ "${#ARGS[@]}" = $((2 - APRES)) ] || usage
ANNUAIRE="${CHANTIERS_DIR:-/Users/bournez/00-CHANTIERS-CARE}"
A=""; if [ -d "$ANNUAIRE" ]; then A=$(cd "$ANNUAIRE" && pwd -P); fi

refus() { echo "Refus : $*" >&2; exit 1; }
tilde() { case "$1" in "$HOME"/*) printf '~%s' "${1#"$HOME"}" ;; *) printf '%s' "$1" ;; esac; }
# fais COMMANDE... : l'exécute, ou la montre seulement sous -n.
fais() {
  if [ "$SEC" = 1 ]; then printf '  (à faire)'; printf ' %s' "$@"; printf '\n'; else "$@"; fi
}
# Le nom du répertoire de Claude Code pour un chemin.
code() { printf '%s' "$1" | sed 's/[^A-Za-z0-9]/-/g'; }

vrai() { (cd "$1" 2>/dev/null && pwd -P) || true; }
# interdit CHEMIN : le répertoire que les réglages de Claude Code lui interdisent de lire,
# Read(~/X/**), et sous lequel CHEMIN se trouve.
interdit() {
  [ -f "$HOME/.claude/settings.json" ] || return 0
  sed -n 's|.*"Read(~/\(.*\)/\*\*)".*|\1|p' "$HOME/.claude/settings.json" | while IFS= read -r r; do
    case "$1/" in ("$HOME/$r"/*) printf '~/%s\n' "$r" ;; esac   # ( ouvrante : bash 3.2, dans $(...)
  done
}
# depots_nommes NOM : les dépôts de ce nom que le registre atteint dans l'annuaire, liens
# suivis, par leur vrai chemin. Une vieille copie sans .git n'en est pas un.
depots_nommes() {
  [ -n "$A" ] || return 0
  find -L "$A" -maxdepth 3 -type d -name "$1" 2>/dev/null | while IFS= read -r c; do
    if [ -e "$c/.git" ]; then vrai "$c"; fi
  done | sort -u
}
# verse O N : le répertoire O de ~/.claude/projects devient N ; si N existe, le contenu de O
# y passe sans rien écraser, et ce qui existe des deux côtés reste dans O.
verse() {
  local o=$1 n=$2 e f b
  if [ ! -e "$n" ]; then fais mv "$o" "$n"; return; fi
  for e in "$o"/* "$o"/.[!.]*; do
    [ -e "$e" ] || continue
    b=$(basename "$e")
    if [ ! -e "$n/$b" ]; then fais mv "$e" "$n/$b"
    elif [ "$b" = memory ] && [ -d "$e" ]; then
      for f in "$e"/*; do
        [ -e "$f" ] || continue
        if [ ! -e "$n/memory/$(basename "$f")" ]; then
          fais mv "$f" "$n/memory/"
          echo "  Souvenir versé, $(basename "$f") : sa ligne manque au MEMORY.md du nouvel emplacement."
        fi
      done
    fi
  done
  [ "$SEC" = 0 ] || return 0
  rmdir "$o/memory" 2>/dev/null || true
  rmdir "$o" 2>/dev/null || echo "  Reste dans $(tilde "$o") ce qui existait des deux côtés : à voir à la main."
}

# Le chantier, par son vrai chemin : désigné par un lien de l'annuaire, on prend ce qu'il vise.
SRC=${ARGS[0]}
if [ ! -d "$SRC" ] && [ -n "$A" ]; then
  case "$SRC" in */*) ;; *)
    TROUVES=$(depots_nommes "$SRC" || true)
    case "$(printf '%s' "$TROUVES" | grep -c . || true)" in
      0) ;;
      1) SRC=$TROUVES ;;
      *) echo "$TROUVES"; refus "plusieurs $SRC dans l'annuaire : donner le chemin" ;;
    esac ;;
  esac
fi
[ -d "$SRC" ] || refus "$SRC : répertoire introuvable, ici comme dans $ANNUAIRE"
SRC=$(cd "$SRC" && pwd -P)
NOM=$(basename "$SRC")
[ -e "$SRC/.git" ] || refus "$(tilde "$SRC") n'est pas un dépôt git"
[ -d "$SRC/.git" ] || refus "$(tilde "$SRC") est un poste, pas un chantier : il se retire par nouveau-poste.sh --retirer"
P="$HOME/.claude/projects"

# ---------------------------------------------------------------------------------------
# --apres : le déplacement est fait, on rattrape l'annuaire et Claude Code.
if [ "$APRES" = 1 ]; then
  NEW=$SRC; N="$P/$(code "$NEW")"
  echo "Chantier : $NOM"
  echo "  aujourd'hui dans $(tilde "$NEW"), déplacé à la main : rattrapage."
  INTERDIT=$(interdit "$NEW")
  if [ -n "$INTERDIT" ]; then
    echo "ATTENTION : Claude Code n'a pas le droit de lire sous $INTERDIT (~/.claude/settings.json) :"
    echo "  le chantier lui est fermé, et le registre qu'il dresse ne le voit plus."
  fi

  # L'annuaire.
  DEHORS=1
  if [ -z "$A" ]; then
    echo "Annuaire $ANNUAIRE absent : pas de lien."
  else
    case "$NEW/" in "$A"/*) DEHORS=0 ;; esac
    OU="$A/$NOM"
    while IFS= read -r l; do
      [ -n "$l" ] || continue
      if [ ! -e "$l" ]; then echo "Lien qui ne mène plus nulle part : $(tilde "$l")"; fais rm "$l"; OU=$l; fi
    done < <(find "$A" -maxdepth 3 -type l -name "$NOM" 2>/dev/null)
    if [ -n "$(depots_nommes "$NOM" | grep -xF "$NEW" || true)" ]; then
      echo "Annuaire : le registre atteint le chantier, rien à poser."
    elif [ "$LIEN" = 0 ]; then
      echo "Pas de lien dans l'annuaire (--sans-lien) : le registre ne voit pas ce chantier."
    elif [ "$SEC" = 0 ] && { [ -e "$OU" ] || [ -L "$OU" ]; }; then
      echo "ATTENTION : $(tilde "$OU") existe, lien non posé."
    else
      echo "Lien dans l'annuaire : $(tilde "$OU")"; fais ln -s "$NEW" "$OU"
    fi
  fi

  # La mémoire et les conversations de Claude Code, restées sous un ancien nom.
  FAIT=0
  for O in "$P"/*-"$(code "$NOM")"; do
    if [ ! -d "$O" ] || [ "$O" = "$N" ]; then continue; fi
    # Est-il à un autre répertoire de ce nom, qui existe toujours ? Ses conversations disent
    # où elles ont eu lieu ; à défaut, son nom est celui d'un dépôt de l'annuaire.
    VIVANT=""
    while IFS= read -r V; do
      case "$V" in */"$NOM") if [ -d "$V" ] && [ "$(vrai "$V")" != "$NEW" ]; then VIVANT=$V; fi ;; esac
    done < <(grep -h -o '"cwd":"[^"]*"' "$O"/*.jsonl 2>/dev/null | sed 's/^"cwd":"//; s/"$//' | sort -u || true)
    while IFS= read -r V; do
      if [ -n "$V" ] && [ "$V" != "$NEW" ] && [ "$(code "$V")" = "$(basename "$O")" ]; then VIVANT=$V; fi
    done < <(depots_nommes "$NOM" || true)
    if [ -n "$VIVANT" ]; then
      echo "Claude Code : $(tilde "$O") appartient à $(tilde "$VIVANT"), qui existe toujours : laissé tel quel."
    else
      echo "Claude Code : mémoire et conversations restées sous un ancien nom,"
      echo "  $(tilde "$O")"
      if verse "$O" "$N"; then FAIT=1
      else echo "ATTENTION : renommage refusé. À la main, application fermée :"; echo "  mv '$O' '$N'"; fi
    fi
  done
  [ "$FAIT" = 1 ] || echo "Claude Code : rien à rattraper sous un ancien nom."

  if [ -L "$NEW/lib/SHAREDDIR" ] && [ ! -d "$NEW/lib/SHAREDDIR/" ]; then
    echo "ATTENTION : lib/SHAREDDIR ne mène plus nulle part : make deps dans le chantier."
  fi
  if [ -f "$NEW/.codex/hooks.json" ] && ! grep -q 'rev-parse' "$NEW/.codex/hooks.json" \
     && ! grep -qF "'$NEW/.codex/" "$NEW/.codex/hooks.json"; then
    echo "ATTENTION : .codex/hooks.json porte un ancien chemin, les hooks de Codex ne tournent"
    echo "  plus : y porter le hooks.json du squelette."
  fi
  echo
  echo "Reste à la main :"
  echo "  - fermer une session ouverte avant le déplacement : elle écrit encore sous l'ancien"
  echo "    nom ; relancer ensuite cette commande, puis rouvrir sur $(tilde "$NEW") ;"
  if [ "$DEHORS" = 1 ]; then
    echo "  - pour qu'une session ouverte dans SHAREDDIR puisse y porter une correction :"
    echo "    ajouter $(tilde "$(dirname "$NEW")") à additionalDirectories et à allowWrite, dans"
    echo "    SHAREDDIR/.claude/settings.local.json ;"
  fi
  echo "  - le finalisé, GitHub et lib/ ne dépendent pas de l'emplacement : rien à y faire."
  [ "$SEC" = 0 ] || echo "(-n : rien n'a été fait.)"
  exit 0
fi
# ---------------------------------------------------------------------------------------
NP=$(git -C "$SRC" worktree list --porcelain 2>/dev/null | grep -c '^worktree ' || true)
[ "$NP" -le 1 ] || refus "ce chantier a des postes (git worktree list) : les retirer d'abord, ils notent son chemin"

# La destination, en chemin absolu ; sous -n elle peut ne pas exister encore.
DEST=${ARGS[1]}
case "$DEST" in /*) ;; *) DEST="$PWD/$DEST" ;; esac
if [ -d "$DEST" ]; then DEST=$(cd "$DEST" && pwd -P)
elif [ -e "$DEST" ]; then refus "$DEST existe et n'est pas un répertoire"; fi
DEST=${DEST%/}
NEW="$DEST/$NOM"
[ "$NEW" != "$SRC" ] || refus "le chantier est déjà dans $(tilde "$DEST")"
case "$DEST/" in "$SRC"/*) refus "la destination est dans le chantier lui-même" ;; esac

# Une destination que les réglages de Claude Code lui interdisent de lire.
INTERDIT=$(interdit "$NEW")
if [ -n "$INTERDIT" ]; then
  echo "Claude Code n'a pas le droit de lire sous $INTERDIT (~/.claude/settings.json) :"
  echo "  rangé là, le chantier lui est fermé, et le registre qu'il dresse ne le voit plus."
  [ "$FORCE" = 1 ] || refus "choisir un autre répertoire, ou --force pour l'y archiver"
fi

# Les liens de l'annuaire qui visent le chantier, jusqu'à trois niveaux comme le registre.
LIENS=()
if [ -n "$A" ]; then
  while IFS= read -r l; do
    if [ "$(cd "$l" 2>/dev/null && pwd -P)" = "$SRC" ]; then LIENS+=("$l"); fi
  done < <(find "$A" -maxdepth 3 -type l 2>/dev/null)
fi
# Le chantier revient là où un de ses liens tenait la place : le lien s'efface devant lui.
PRIS=1
for l in ${LIENS[@]+"${LIENS[@]}"}; do if [ "$l" = "$NEW" ]; then PRIS=0; fi; done
if [ "$PRIS" = 1 ] && { [ -e "$NEW" ] || [ -L "$NEW" ]; }; then refus "$(tilde "$NEW") existe déjà"; fi

# Une session ouverte dans le chantier garderait l'ancien chemin en tête.
if command -v lsof >/dev/null 2>&1; then
  OUVERTES=$(lsof -a -d cwd -c claude -c codex -Fpcn 2>/dev/null | awk -v src="$SRC" '
    /^p/ { pid = substr($0, 2) } /^c/ { cmd = substr($0, 2) }
    /^n/ { d = substr($0, 2); if (d == src || index(d, src "/") == 1) printf "  %s (processus %s)\n", cmd, pid }' || true)
  if [ -n "$OUVERTES" ]; then
    echo "Une session est ouverte dans ce chantier :"; echo "$OUVERTES"
    [ "$FORCE" = 1 ] || refus "la fermer d'abord, ou --force"
  fi
fi
SALE=$(git -C "$SRC" status --porcelain 2>/dev/null | grep -c . || true)

echo "Chantier : $NOM"
echo "  de   $(tilde "$SRC")"
echo "  vers $(tilde "$NEW")"
[ "$SALE" = 0 ] || echo "  fichiers non commités : $SALE, qui suivent le déplacement."

# 2. Le déplacement.
for l in ${LIENS[@]+"${LIENS[@]}"}; do fais rm "$l"; done
fais mkdir -p "$DEST"
fais mv "$SRC" "$NEW"

# 3. L'annuaire. Hors de lui, le chantier y garde un lien : là où il était, là où était son
# lien, à défaut sous son nom à la racine de l'annuaire.
DEHORS=1; ETAIT=0
if [ -n "$A" ]; then
  case "$NEW/" in "$A"/*) DEHORS=0 ;; esac
  case "$SRC/" in "$A"/*) ETAIT=1 ;; esac
fi
if [ -z "$A" ]; then
  echo "Annuaire $ANNUAIRE absent : pas de lien."
elif [ "$DEHORS" = 0 ]; then
  echo "Le chantier est dans l'annuaire : pas de lien."
elif [ "$LIEN" = 0 ]; then
  echo "Pas de lien dans l'annuaire (--sans-lien) : le registre ne verra plus ce chantier."
else
  OU=()
  if [ "$ETAIT" = 1 ]; then OU=("$SRC")
  elif [ "${#LIENS[@]}" -gt 0 ]; then OU=("${LIENS[@]}")
  else OU=("$A/$NOM"); fi
  for l in "${OU[@]}"; do
    if [ "$SEC" = 0 ] && { [ -e "$l" ] || [ -L "$l" ]; }; then
      echo "ATTENTION : $(tilde "$l") existe, lien non posé."
    else
      echo "Lien dans l'annuaire : $(tilde "$l")"; fais ln -s "$NEW" "$l"
    fi
  done
fi

# 4. La mémoire et les conversations de Claude Code.
O="$P/$(code "$SRC")"; N="$P/$(code "$NEW")"
if [ ! -d "$O" ]; then
  echo "Claude Code : rien de rangé sous l'ancien chemin."
else
  echo "Claude Code : mémoire et conversations, le répertoire change de nom."
  if verse "$O" "$N"; then :
  else echo "ATTENTION : renommage refusé. À la main, application fermée :"; echo "  mv '$O' '$N'"; fi
fi

# 5. Ce qui reste.
[ "$SEC" = 1 ] && BUT="$SRC" || BUT="$NEW"
if [ -L "$BUT/lib/SHAREDDIR" ] && [ ! -d "$BUT/lib/SHAREDDIR/" ]; then
  echo "ATTENTION : lib/SHAREDDIR ne mène plus nulle part : make deps dans le chantier."
fi
if grep -qF "$SRC/" "$BUT/.codex/hooks.json" 2>/dev/null; then
  echo "ATTENTION : .codex/hooks.json porte l'ancien chemin. Les hooks de Codex ne tournent"
  echo "  plus que si un lien tient l'ancienne place : y porter le hooks.json du squelette."
fi
echo
echo "Reste à la main :"
echo "  - rouvrir les sessions sur $(tilde "$NEW"), par ce chemin et non par le lien ;"
echo "    Claude Code et Codex redemandent la confiance du répertoire, et les conversations"
echo "    déjà listées dans l'application gardent l'ancien chemin ;"
if [ "$DEHORS" = 1 ]; then
  echo "  - pour qu'une session ouverte dans SHAREDDIR puisse y porter une correction :"
  echo "    ajouter $(tilde "$DEST") à additionalDirectories et à allowWrite, dans"
  echo "    SHAREDDIR/.claude/settings.local.json ;"
fi
echo "  - le finalisé, GitHub et lib/ ne dépendent pas de l'emplacement : rien à y faire."
[ "$SEC" = 0 ] || echo "(-n : rien n'a été fait.)"
