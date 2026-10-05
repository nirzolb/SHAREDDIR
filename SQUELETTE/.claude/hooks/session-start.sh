#!/bin/sh
# Hook SessionStart (voir .claude/settings.json) : ce qui sort ici est ajouté au contexte
# de Claude Code au démarrage de chaque session, y compris après /resume ou /compact.
# Simple relais : l'état du dépôt, la fin du cahier et « le chantier est-il libre ? » sont
# dits par debut-session.sh, dans SHAREDDIR, le même pour tous les assistants.
cd "${CLAUDE_PROJECT_DIR:-.}" || exit 0
if [ -x lib/SHAREDDIR/SCRIPTS/debut-session.sh ]; then exec lib/SHAREDDIR/SCRIPTS/debut-session.sh Claude-Code; fi
echo "=== Reprise automatique du chantier (hook SessionStart) ==="
echo "lib/ absent : lancer make deps, puis /reprise."
exit 0
