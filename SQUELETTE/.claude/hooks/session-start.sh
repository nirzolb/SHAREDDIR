#!/bin/sh
# Hook SessionStart (voir .claude/settings.json) : ce qui sort ici est ajouté au contexte
# de Claude Code au démarrage de chaque session, y compris après /resume ou /compact.
# Équivalent automatique du début de /reprise : état du dépôt et fin du cahier.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
echo "=== Reprise automatique du chantier (hook SessionStart) ==="
if [ -d lib/SHAREDDIR ]; then make --no-print-directory sha 2>/dev/null; else echo "lib/ absent : lancer make deps"; fi
echo
echo "--- Dernières entrées de NOTES.md ---"
# les deux dernières entrées (titres '## '), sinon les 30 dernières lignes
awk '/^## /{c++} {l[NR]=$0} END{s=1; n=0; for(i=NR;i>=1;i--){ if(l[i]~/^## /){n++; if(n==2){s=i; break}} } if(n<2)s=(NR>30?NR-29:1); for(i=s;i<=NR;i++)print l[i]}' NOTES.md 2>/dev/null
echo
echo "Consigne : lire CLAUDE.md, ne rien modifier avant d'avoir compris où en est le chantier ; /reprise donne un résumé et une proposition, /passation clôt la session."
exit 0
