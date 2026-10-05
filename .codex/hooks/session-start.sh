#!/bin/sh
# Hook SessionStart de Codex (voir .codex/hooks.json), le pendant de celui de Claude Code :
# ce qui sort ici est ajouté au contexte de Codex au démarrage d'une session.
cd "$(git rev-parse --show-toplevel 2>/dev/null || pwd)" || exit 0
SCRIPTS/debut-session.sh Codex
echo "Ici en plus : ce dépôt est PUBLIC et il sert de source aux chantiers. Une correction du"
echo "SQUELETTE ne se propage pas toute seule, les chantiers ouverts en ont une copie."
echo "Début et fin de session : voir AGENTS.md."
exit 0
