#!/bin/sh
# Ce qu'un assistant doit savoir en ouvrant une session dans un chantier : où en est le
# dépôt, la fin du cahier, et si le chantier est libre. Appelé par le hook de démarrage de
# chaque assistant ; ce qui sort ici entre dans son contexte.
#
#   debut-session.sh NOM
#
# NOM est le nom d'intervenant : Claude-Code, Codex... À lancer depuis la racine du chantier.
# La logique vit ici, dans SHAREDDIR, et non dans les hooks du chantier, qui ne sont que des
# relais : une correction arrive ainsi dans tous les chantiers par le lien lib/SHAREDDIR.
NOM=${1:-}
ICI=$(dirname "$0")
echo "=== Reprise automatique du chantier (hook de démarrage) ==="
make --no-print-directory sha 2>/dev/null || git log -1 --format='Commit : %h  %ad  %an  %s' --date=short 2>/dev/null
echo
echo "--- Dernières entrées de NOTES.md ---"
# les deux dernières entrées (titres '## '), sinon les 30 dernières lignes
awk '/^## /{c++} {l[NR]=$0} END{s=1; n=0; for(i=NR;i>=1;i--){ if(l[i]~/^## /){n++; if(n==2){s=i; break}} } if(n<2)s=(NR>30?NR-29:1); for(i=s;i<=NR;i++)print l[i]}' NOTES.md 2>/dev/null
echo
if [ -n "$NOM" ] && [ -x "$ICI/qui.sh" ]; then "$ICI/qui.sh" --arrivee "$NOM"; echo; fi
echo "Consigne : lire AGENTS.md, ne rien modifier avant d'avoir compris où en est le chantier"
echo "et, si le chantier n'est pas libre, avant d'en avoir parlé à Olivier."
exit 0
