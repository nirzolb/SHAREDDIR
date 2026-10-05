#!/bin/sh
# Hook UserPromptSubmit de Codex : note sa présence à chaque message (voir SCRIPTS/qui.sh).
# Ne doit rien afficher.
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" 2>/dev/null || exit 0
SCRIPTS/qui.sh --vu Codex >/dev/null 2>&1
exit 0
