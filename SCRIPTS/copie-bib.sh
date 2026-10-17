#!/bin/bash
# Met la copie publique de la bibliographie, SHAREDDIR/BIBDESKDIR, au niveau de la
# référence : la bibliographie BibDesk d'Olivier, ~/bibliographie/BIBDESK-DIR=.
#
#   copie-bib.sh              recopie les .bib en retard sur la référence, et dit lesquels
#   copie-bib.sh --verifier   dit seulement lesquels sont en retard ; sort en 1 s'il y en a
#
# Ne sont recopiés que les .bib déjà présents dans BIBDESKDIR et qui ont, dans la référence,
# un fichier du même nom (les liens de la référence sont suivis). Un fichier de la référence
# n'entre jamais ici de lui-même : le dépôt est public, et CARE.bib, mecite.bib et les autres
# restent chez Olivier. Pour en publier un de plus, le recopier une fois à la main.
# Sans la référence (une autre machine), le script ne fait rien et le dit.
# Appelé par do-public_raw-update.command avant son commit, et par le hook pre-push du dépôt
# (SCRIPTS/hook-pre-push.sh), qui refuse un push tant que la copie est en retard.
set -euo pipefail

REF="${BIB_REFERENCE:-$HOME/bibliographie/BIBDESK-DIR=}"
D=$(cd "$(dirname "$0")/../BIBDESKDIR" && pwd)
VERIF=0
case "${1:-}" in
  --verifier) VERIF=1 ;;
  "") ;;
  *) sed -n '2,/^set -euo/p' "$0" | sed '$d' | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
if [ ! -d "$REF" ]; then echo "copie-bib.sh : référence $REF absente, rien à comparer."; exit 0; fi

RETARD=0
for f in "$D"/*.bib; do
  n=$(basename "$f"); r="$REF/$n"
  [ -f "$r" ] || continue
  cmp -s "$f" "$r" && continue
  RETARD=$((RETARD + 1))
  if [ "$VERIF" = 1 ]; then echo "  en retard sur BibDesk : BIBDESKDIR/$n"
  else cp "$r" "$f"; echo "  recopié depuis BibDesk : BIBDESKDIR/$n"; fi
done
if [ "$VERIF" = 1 ] && [ "$RETARD" -gt 0 ]; then exit 1; fi
exit 0
