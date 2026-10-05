#!/bin/sh
# Hook UserPromptSubmit : note la présence de Claude Code à chaque message, pour que le
# suivant sache si le chantier est libre (voir qui.sh dans SHAREDDIR). Ne doit rien
# afficher : ce qui sortirait ici entrerait dans le contexte.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
[ -x lib/SHAREDDIR/SCRIPTS/qui.sh ] && lib/SHAREDDIR/SCRIPTS/qui.sh --vu Claude-Code >/dev/null 2>&1
exit 0
