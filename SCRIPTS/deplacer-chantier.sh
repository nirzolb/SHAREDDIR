#!/bin/bash
# Déplace un chantier dans un autre répertoire, et remet d'aplomb ce qui le connaissait par
# son chemin.
#
#   deplacer-chantier.sh [-n] [--force] [--sans-lien] CHANTIER DESTINATION
#
#   CHANTIER     son répertoire, ou son nom, cherché dans l'annuaire jusqu'à trois niveaux
#   DESTINATION  le répertoire où le ranger, créé au besoin : le chantier devient
#                DESTINATION/<son nom>
#   -n           dit ce qui serait fait, sans rien faire
#   --force      déplace même si une session Claude Code ou Codex y est ouverte
#   --sans-lien  ne pose pas de lien dans l'annuaire
#
# L'annuaire est $CHANTIERS_DIR, à défaut /Users/bournez/00-CHANTIERS-CARE : c'est là que le
# registre (etat-chantiers.sh) cherche les chantiers. Un chantier rangé ailleurs y a un lien
# symbolique, que le registre suit.
#
# Ce que fait le script :
#   1. refuse si CHANTIER n'est pas un dépôt git, s'il a des postes (un worktree note le
#      chemin de son dépôt), si DESTINATION/<nom> existe, ou si une session y est ouverte ;
#   2. déplace le répertoire ;
#   3. tient l'annuaire : le chantier qui en sort y laisse un lien à sa place, un lien qui
#      pointait sur l'ancien emplacement est refait, ou retiré si le chantier y revient ;
#   4. renomme le répertoire où Claude Code range la mémoire et les conversations du
#      chantier, ~/.claude/projects/<chemin, tout caractère non alphanumérique devenu ->,
#      pour qu'une session ouverte au nouvel endroit les retrouve ;
#   5. dit ce qui reste à faire à la main.
#
# Rien dans le chantier n'est modifié : ni fichier suivi, ni git. À lancer par Olivier depuis
# son terminal, sessions fermées : un assistant n'a pas le droit d'écrire dans ~/.claude.
set -euo pipefail

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 1; }
SEC=0; FORCE=0; LIEN=1; ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    -n)          SEC=1 ;;
    --force)     FORCE=1 ;;
    --sans-lien) LIEN=0 ;;
    -h|--help)   usage ;;
    -*)          echo "option inconnue : $1"; usage ;;
    *)           ARGS+=("$1") ;;
  esac
  shift
done
[ "${#ARGS[@]}" = 2 ] || usage
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

# Le chantier, par son vrai chemin : désigné par un lien de l'annuaire, on prend ce qu'il vise.
SRC=${ARGS[0]}
if [ ! -d "$SRC" ] && [ -n "$A" ]; then
  case "$SRC" in */*) ;; *)
    TROUVES=$(find "$A" -maxdepth 3 -name "$SRC" \( -type d -o -type l \) 2>/dev/null || true)
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
P="$HOME/.claude/projects"; O="$P/$(code "$SRC")"; N="$P/$(code "$NEW")"
if [ ! -d "$O" ]; then
  echo "Claude Code : rien de rangé sous l'ancien chemin."
elif [ -e "$N" ]; then
  echo "ATTENTION : Claude Code a déjà un répertoire pour le nouveau chemin, je ne fusionne pas."
  echo "  ancien : $(tilde "$O")"
  echo "  nouveau : $(tilde "$N")"
else
  echo "Claude Code : mémoire et conversations, le répertoire change de nom."
  if fais mv "$O" "$N"; then :
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
