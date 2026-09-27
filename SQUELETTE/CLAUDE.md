# Chantier __NOM__ (__TYPE__, modèle __MODELE__)

Document LaTeX en mode chantier : travail à deux, Olivier Bournez et Claude, dans un
dépôt privé. Le dépôt est la seule source de vérité. Ce fichier prime sur les
instructions générales (~/.claude/CLAUDE.md, préférences du chat).

@lib/SHAREDDIR/CONVENTIONS-LATEX.md

## Le mode d'emploi du chantier

`=LISEZ-MOI-SUR-CE-CHANTIER.md` s'adresse à Olivier, non à toi : où il est, ce qui se passe
s'il publie, les particularités du lieu. Il est posé à l'ouverture avec des trous marqués
`__A_REMPLIR__`.

- **À la première session, tu le remplis**, en demandant à Olivier ce que tu ne peux pas
  déduire, notamment le répertoire finalisé et qui le voit. N'invente pas une sortie.
- **Ensuite tu le tiens à jour** : dès qu'une sortie, une commande ou un piège change, il
  change aussi. Un piège qui t'a coûté du temps y a sa place, en une ligne.
- Il reste court, une page. Les règles de travail vont dans ce fichier-ci, le récit dans
  `NOTES.md`.

## Début et fin de session
- Au démarrage, un hook (.claude/hooks/session-start.sh) t'a fourni `make sha` et la fin de
  NOTES.md : pars de là. `/reprise` en plus si Olivier veut un résumé et une proposition.
  Si `lib/` manque : `make deps`.
- Fin de session, ou avant qu'Olivier change de surface : `/passation` (entrée dans
  NOTES.md, commit, push).
- Dans tout échange sur ce chantier, citer le commit courant (`make sha`).

## Commandes
- `make` (= `make pdf`) : pdflatex, bibtex, makeindex si .idx, pdflatex deux fois. Doit
  passer avant tout commit. En cas d'erreur, les lignes fautives du .log sont affichées.
- `make sha` : commit courant, branche, modifications non commitées, commits non poussés.
- `make am` : applique le dernier `chantier-*.patch` venu du chat (auteur conservé).
- `make publier` / `make importer` : échanges avec le répertoire finalisé (`DEST` dans
  `Makefile.local`). Jamais de commande git directement dans DEST. Règle d'Olivier
  (27 septembre 2026) : rien de ce qui part vers un finalisé ne parle du chantier, de
  Claude ni de CARE. `make publier` refuse sans rien copier s'il trouve une macro ou un
  environnement CARE (\IMPORTANTCARE, rechercheCARE) ou l'un des trois mots dans ce qui
  partirait ; le hook pre-push du finalisé refuse un commit qui en parle ; retirer donc
  les \IMPORTANTCARE des sources avant de publier. Le push reste le geste d'Olivier.
- `make clean` / `make distclean`.

## Structure
- `main.tex` : document principal. Fichiers inclus à la racine ou dans un sous-dossier ;
  figures dans `figures/`.
- `lib/` : SHAREDDIR (styles, biblio, modèles) et logos, non versionné, en lecture seule.
  Une correction de style se fait dans SHAREDDIR (/Users/bournez/public_raw/SHAREDDIR sur
  le Mac d'Olivier), pas ici.
- `NOTES.md` : cahier de chantier, ajout seulement. `passations/` : échanges conservés
  tels quels, référencés depuis NOTES.md.
- `Makefile.local`, `figcommons-local.tex`, `.claude/settings.local.json` : propres à la
  machine, non versionnés.

## Git
- Tes commits sont signés Claude-Code (réglé dans .claude/settings.json) ; ceux d'Olivier
  restent à son nom. Ne commite que les fichiers que tu as modifiés dans la session
  (`git add` explicite) ; si des modifications non commitées d'Olivier traînent, signale-les
  et n'y touche pas.
- Petits commits, messages en français, première ligne courte. `make` doit passer avant.
- Jamais de force-push, de rebase, de reset --hard ni de réécriture d'historique.
- Retouches directement sur main. Gros morceau : branche `claude/sujet`, Olivier merge.
- Pas d'artefacts de compilation dans le dépôt (le .gitignore s'en charge).

## LaTeX, rappels propres à ce chantier
- Macros réservées à Olivier, à préserver telles quelles : \IMPORTANT, \SURLIGNE,
  \SURSURLIGNE. Pour mettre en évidence : \IMPORTANTCARE[titre]{texte} (macros-care.tex,
  jamais publié : aucune occurrence ne doit rester dans ce qui part vers un finalisé).
- __NOTES_SPECIFIQUES__
