#!/bin/sh
# Hook SessionStart : ce qui sort ici est ajouté au contexte de Claude Code au démarrage.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
echo "=== Reprise automatique de SHAREDDIR (hook SessionStart) ==="
make --no-print-directory sha 2>/dev/null
echo
echo "--- Dernières entrées de NOTES.md ---"
awk '/^## /{c++} {l[NR]=$0} END{s=1; n=0; for(i=NR;i>=1;i--){ if(l[i]~/^## /){n++; if(n==2){s=i; break}} } if(n<2)s=(NR>30?NR-29:1); for(i=s;i<=NR;i++)print l[i]}' NOTES.md 2>/dev/null
echo
echo "Consigne : ce dépôt est PUBLIC et il sert de source aux chantiers. Une correction du"
echo "SQUELETTE ne se propage pas toute seule, les chantiers ouverts en ont une copie."
echo "/reprise donne un résumé, /passation clôt la session."
exit 0
