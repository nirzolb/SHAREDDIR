#!/bin/sh
# Hook SessionStart de Codex (voir .codex/hooks.json), le pendant de celui de Claude Code :
# ce qui sort ici est ajouté au contexte de Codex au démarrage d'une session. Simple relais
# vers debut-session.sh, dans SHAREDDIR, le même pour tous les assistants. On se place à la
# racine du dépôt où Codex travaille, qui peut être un poste et non le chantier lui-même.
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 0
if [ -x lib/SHAREDDIR/SCRIPTS/debut-session.sh ]; then exec lib/SHAREDDIR/SCRIPTS/debut-session.sh Codex; fi
echo "=== Reprise automatique du chantier (hook SessionStart) ==="
echo "lib/ absent : lancer make deps, puis reprendre le début de session décrit dans AGENTS.md."
exit 0
