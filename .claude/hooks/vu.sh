#!/bin/sh
# Hook UserPromptSubmit : note la présence de Claude Code à chaque message, pour que le
# suivant sache si le dépôt est libre (voir SCRIPTS/qui.sh). Ne doit rien afficher.
cd "${CLAUDE_PROJECT_DIR:-.}" 2>/dev/null || exit 0
SCRIPTS/qui.sh --vu "Claude (CARE)" >/dev/null 2>&1
exit 0
