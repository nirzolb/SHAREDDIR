#!/bin/sh
# Hook SessionStart : ce qui sort ici est ajouté au contexte de Claude Code au démarrage.
# L'état du dépôt, la fin du cahier et « le dépôt est-il libre ? » sont dits par
# debut-session.sh, le même pour tous les assistants et pour tous les chantiers.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
SCRIPTS/debut-session.sh "Claude (CARE)"
echo "Ici en plus : ce dépôt est PUBLIC et il sert de source aux chantiers. Une correction du"
echo "SQUELETTE ne se propage pas toute seule, les chantiers ouverts en ont une copie."
echo "/reprise donne un résumé, /passation clôt la session, /registre refait le registre."
exit 0
