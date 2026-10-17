#!/bin/sh
# Hook pre-push de SHAREDDIR. Il est posé une fois par machine, par un lien :
#   ln -s ../../SCRIPTS/hook-pre-push.sh .git/hooks/pre-push
# Il refuse de pousser tant que la copie publique de la bibliographie (BIBDESKDIR) est en
# retard sur BibDesk : que le push vienne d'Olivier ou d'un assistant, ce que voit le chat sur
# GitHub reste à jour. Contournement volontaire : git push --no-verify.
D=$(git rev-parse --show-toplevel 2>/dev/null) || exit 0
[ -x "$D/SCRIPTS/copie-bib.sh" ] || exit 0
if ! "$D/SCRIPTS/copie-bib.sh" --verifier; then
  echo "Push refusé : la copie de la bibliographie est en retard sur BibDesk. Au choix :"
  echo "  - do-public_raw-update.command, qui recopie, commite et pousse ;"
  echo "  - SCRIPTS/copie-bib.sh, commit de BIBDESKDIR au nom d'Olivier, puis git push."
  exit 1
fi
exit 0
