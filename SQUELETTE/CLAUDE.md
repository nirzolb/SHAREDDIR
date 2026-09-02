# Chantier __NOM__ (__TYPE__, modèle __MODELE__)

Document LaTeX en mode chantier : travail à deux, Olivier Bournez et Claude, dans un
dépôt privé. Le dépôt est la seule source de vérité. Ce fichier prime sur les
instructions générales (~/.claude/CLAUDE.md, préférences du chat).

@lib/SHAREDDIR/CONVENTIONS-LATEX.md

## Début et fin de session
- Début : `/reprise` (ou à la main : les deux dernières entrées de NOTES.md, puis `make sha`).
  Si `lib/` manque : `make deps`.
- Fin : `/passation` (entrée dans NOTES.md, commit, push).
- Dans tout échange sur ce chantier, citer le commit courant (`make sha`).

## Commandes
- `make` (= `make pdf`) : pdflatex, bibtex, makeindex si .idx, pdflatex deux fois. Doit
  passer avant tout commit. En cas d'erreur, les lignes fautives du .log sont affichées.
- `make sha` : commit courant, branche, modifications non commitées, commits non poussés.
- `make am` : applique le dernier `chantier-*.patch` venu du chat (auteur conservé).
- `make publier` / `make importer` : échanges avec le répertoire finalisé (`DEST` dans
  `Makefile.local`). Jamais de commande git directement dans DEST.
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
  \SURSURLIGNE. Pour mettre en évidence : \IMPORTANTCARE[titre]{texte}.
- __NOTES_SPECIFIQUES__
