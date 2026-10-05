#!/bin/bash
# Ouvre, ou retire, un poste temporaire : un second répertoire de travail (git worktree) sur
# un chantier, pour le cas rare où deux intervenants doivent y travailler en même temps.
#
#   nouveau-poste.sh INTERVENANT SUJET [--depuis REF] [--dir POSTES] [--no-make]
#   nouveau-poste.sh --retirer POSTE
#   nouveau-poste.sh --liste
#
# À lancer depuis le chantier. La règle reste un seul répertoire par chantier, à tour de
# rôle : un poste ne s'ouvre que sur l'ordre d'Olivier, et se retire dès que sa branche est
# intégrée. Le chantier reste un seul dépôt : le poste en partage l'historique.
#
#   INTERVENANT   celui qui travaillera dans le poste : Claude-Code, Codex...
#   SUJET         ce qu'il y fait. La branche s'appelle claude/SUJET pour Claude-Code,
#                 INTERVENANT/SUJET pour les autres (Codex/SUJET)
#   --depuis REF  d'où part la branche (défaut : là où en est le répertoire courant)
#   --dir POSTES  où ranger les postes (défaut : $CHANTIERS_DIR/POSTES-TEMPORAIRES, soit
#                 /Users/bournez/00-CHANTIERS-CARE/POSTES-TEMPORAIRES), à l'écart des chantiers
#   --no-make     ne pas lancer make deps dans le poste
#   --retirer POSTE  retire le poste (chemin, ou nom sous POSTES). Refuse s'il y reste un
#                 fichier non commité, ou si sa branche n'est ni poussée ni reprise ailleurs.
#                 La branche, elle, reste.
#   --liste       les postes du chantier courant
set -euo pipefail

usage() { sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 1; }
POSTES="${CHANTIERS_DIR:-/Users/bournez/00-CHANTIERS-CARE}/POSTES-TEMPORAIRES"
ACTION=ouvrir; DEPUIS=""; DOMAKE=1; ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --retirer) ACTION=retirer ;;
    --liste)   ACTION=liste ;;
    --depuis)  DEPUIS="$2"; shift ;;
    --dir)     POSTES="$2"; shift ;;
    --no-make) DOMAKE=0 ;;
    -h|--help) usage ;;
    -*)        echo "option inconnue : $1"; usage ;;
    *)         ARGS+=("$1") ;;
  esac
  shift
done

# Le chantier : le dépôt dont le répertoire courant fait partie, poste compris.
chantier() {
  TOP=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p' || true)
  [ -n "$TOP" ] || { echo "À lancer depuis un chantier : $(pwd) n'est pas dans un dépôt git"; exit 1; }
  NOM=$(basename "$TOP")
}

if [ "$ACTION" = liste ]; then
  chantier
  git -C "$TOP" worktree list --porcelain | awk 'BEGIN { RS = ""; FS = "\n" }
    NR > 1 { p = ""; b = "tête détachée"
      for (i = 1; i <= NF; i++) {
        if ($i ~ /^worktree /) p = substr($i, 10)
        if ($i ~ /^branch /) { b = substr($i, 8); sub(/^refs\/heads\//, "", b) }
      }
      printf "%s (%s)\n", p, b; n++ }
    END { if (!n) print "aucun poste : le chantier n\047a que son répertoire" }'
  exit 0
fi

if [ "$ACTION" = retirer ]; then
  [ ${#ARGS[@]} -eq 1 ] || usage
  P=${ARGS[0]}; [ -d "$P" ] || P="$POSTES/$P"
  [ -f "$P/.git" ] || { echo "$P n'est pas un poste (un poste a un fichier .git, pas un répertoire)"; exit 1; }
  P=$(cd "$P" && pwd -P)
  TOP=$(git -C "$P" worktree list --porcelain | sed -n '1s/^worktree //p')
  B=$(git -C "$P" rev-parse --abbrev-ref HEAD)
  if [ -n "$(git -C "$P" status --porcelain)" ]; then
    echo "Refusé : il reste dans $P des fichiers modifiés ou non suivis :"
    git -C "$P" status --short | sed -n '1,10p' | sed 's/^/   /'
    exit 1
  fi
  # Le travail du poste doit exister ailleurs que dans sa seule branche locale.
  ailleurs=""
  if git -C "$TOP" show-ref --verify --quiet "refs/remotes/origin/$B" \
     && [ "$(git -C "$TOP" rev-list --count "origin/$B..$B")" = 0 ]; then ailleurs="poussée sur origin"; fi
  if [ -z "$ailleurs" ]; then
    c=$(git -C "$TOP" branch --contains "$B" --format='%(refname:short)' | grep -vx "$B" | sed -n 1p || true)
    if [ -n "$c" ]; then ailleurs="reprise dans $c"; fi
  fi
  if [ -z "$ailleurs" ]; then
    echo "Refusé : la branche $B n'est ni poussée ni reprise dans une autre branche."
    echo "La pousser (git -C \"$P\" push -u origin $B) ou l'intégrer, puis recommencer."
    exit 1
  fi
  git -C "$TOP" worktree remove "$P"
  echo "Poste retiré : $P"
  echo "La branche $B reste dans le chantier ($ailleurs)."
  exit 0
fi

[ ${#ARGS[@]} -eq 2 ] || usage
QUI=${ARGS[0]}; SUJET=${ARGS[1]}
case "$QUI" in *[!A-Za-z0-9._-]*|"") echo "INTERVENANT : lettres, chiffres, . _ - seulement"; exit 1 ;; esac
case "$SUJET" in *[!A-Za-z0-9._-]*|"") echo "SUJET : lettres, chiffres, . _ - seulement"; exit 1 ;; esac
chantier
case "$QUI" in Claude-Code|Claude) PREFIXE=claude ;; *) PREFIXE=$QUI ;; esac
B="$PREFIXE/$SUJET"
if git -C "$TOP" show-ref --verify --quiet "refs/heads/$B"; then echo "La branche $B existe déjà"; exit 1; fi
[ -n "$DEPUIS" ] || DEPUIS=$(git rev-parse --abbrev-ref HEAD)
git rev-parse --verify --quiet "$DEPUIS^{commit}" >/dev/null || { echo "--depuis : $DEPUIS n'existe pas"; exit 1; }
P="$POSTES/$NOM-$QUI"
if [ -e "$P" ]; then P="$P-$SUJET"; fi
[ -e "$P" ] && { echo "$P existe déjà"; exit 1; }

mkdir -p "$POSTES"
git -C "$TOP" worktree add -q -b "$B" "$P" "$DEPUIS"
# Ce qui n'est pas versionné et sans quoi rien ne compile dans un répertoire neuf.
for f in Makefile.local config.local.mk; do
  if [ -f "$TOP/$f" ]; then cp -p "$TOP/$f" "$P/$f"; fi
done
if [ "$DOMAKE" = 1 ] && [ -f "$P/Makefile" ] && make -C "$P" -n deps >/dev/null 2>&1; then
  make -C "$P" --no-print-directory deps || echo "ATTENTION : make deps échoue dans le poste, à relancer à la main"
fi

echo
echo "Poste ouvert : $P"
echo "  chantier $NOM, branche $B, partie de $DEPUIS ($(git -C "$P" rev-parse --short HEAD))"
echo "  pour $QUI : ouvrir sa session dans ce répertoire, pas dans le chantier"
echo "À la fin : pousser la branche, la faire intégrer par Olivier, puis"
echo "  $0 --retirer \"$P\""
