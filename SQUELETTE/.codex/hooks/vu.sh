#!/bin/sh
# Hook UserPromptSubmit de Codex : note sa présence à chaque message, pour que le suivant
# sache si le chantier est libre (voir qui.sh dans SHAREDDIR). Ne doit rien afficher.
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" 2>/dev/null || exit 0
[ -x lib/SHAREDDIR/SCRIPTS/qui.sh ] && lib/SHAREDDIR/SCRIPTS/qui.sh --vu Codex >/dev/null 2>&1
exit 0
