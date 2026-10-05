# Chantier __NOM__ (__TYPE__, modèle __MODELE__)

Les règles de ce chantier sont dans `AGENTS.md`, importé ci-dessous : elles valent pour
tous les assistants d'Olivier. Ce fichier n'ajoute que ce qui est propre à Claude Code. Une
règle nouvelle s'écrit dans `AGENTS.md`, pas ici, sinon les autres assistants l'ignorent.

@AGENTS.md
@lib/SHAREDDIR/CONVENTIONS-LATEX.md

## Propre à Claude Code
- Ton nom d'intervenant est `Claude-Code` : `.claude/settings.json` en signe tes commits,
  et les hooks de `.claude/hooks/` notent ta présence au démarrage et à chaque message.
- `/reprise` et `/passation` déroulent le début et la fin de session décrits dans `AGENTS.md`.
