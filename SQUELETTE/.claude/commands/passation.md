---
description: Fin de session - entrée de passation dans NOTES.md, commit signé Claude-Code, push
---
Fin de session sur ce chantier. Remarques d'Olivier pour cette passation : $ARGUMENTS

Fais, dans l'ordre :
1. `make` doit passer. Sinon corrige, ou note l'échec dans l'entrée.
2. Note le commit courant avec `make sha`.
3. Ajoute à la fin de NOTES.md une entrée `## AAAA-MM-JJ HHhMM (code)` avec quatre
   rubriques : Fait, Décidé, À faire, Questions pour Olivier. Court et factuel, pas de
   résumé de conversation. Si un raisonnement ou un échange mérite d'être gardé tel quel,
   mets-le dans `passations/AAAA-MM-JJ-sujet.md` et cite ce fichier dans l'entrée.
   Termine l'entrée par `Base : <sha court du commit noté à l'étape 2>`.
4. Si une sortie, une commande ou un piège a changé pendant la session, mets à jour
   `=LISEZ-MOI-SUR-CE-CHANTIER.md`. S'il lui reste des trous `__A_REMPLIR__`, dis-le dans
   l'entrée plutôt que de les laisser en silence.
5. Commite uniquement les fichiers que tu as modifiés dans cette session (git add
   explicite). Si des modifications non commitées d'Olivier traînent, laisse-les et
   dis-le dans l'entrée. Message en français, première ligne courte.
6. `git push`.
7. Termine par la sortie de `make sha`.
