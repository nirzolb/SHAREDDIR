# Chantier __NOM__ (__TYPE__, modèle __MODELE__)

Document LaTeX en mode chantier : Olivier Bournez y travaille avec ses assistants, Claude
Code, Codex, et le chat par patchs, dans un dépôt privé. Le dépôt est la seule source de
vérité. Ce fichier porte les règles du chantier, les mêmes pour tous les assistants, et
prime sur leurs instructions générales (~/.claude/CLAUDE.md, ~/.codex/AGENTS.md,
préférences du chat). `CLAUDE.md` l'importe et n'ajoute que ce qui est propre à Claude
Code : une règle nouvelle s'écrit ici, sinon les autres assistants l'ignorent.

Les conventions LaTeX communes à tous les chantiers sont dans __CONVENTIONS__ : les lire
avant de toucher au LaTeX. Claude Code les importe de lui-même, les autres les ouvrent.

## Qui travaille ici

- **Ton nom d'intervenant** signe tes commits et note ta présence : `Claude-Code` pour
  Claude Code (`.claude/settings.json`), `Codex` pour Codex (`.codex/config.toml`). Les
  commits d'Olivier restent à son nom. Un patch venu du chat garde le nom de celui qui l'a
  produit.
- **Un chantier, un dépôt, un répertoire, à tour de rôle.** Jamais de copie du chantier
  pour un autre assistant : deux copies divergent en silence.
- **Au début d'une session**, le hook de démarrage dit si le chantier est libre. S'il
  avertit qu'un autre intervenant a été vu depuis moins d'une heure, que des fichiers
  suivis sont modifiés sans être commités, ou qu'un autre vient de commiter, tu ne
  modifies rien : tu le dis à Olivier, qui attend la passation de l'autre ou te demande
  d'ouvrir un poste.
- **Repartir du plus avancé.** `make qui` dit qui est là, quelles branches vivent, et pour
  chaque fichier qui y a travaillé en dernier, qui y a surtout travaillé, et si sa version
  la plus récente est ailleurs que dans l'arbre de travail. Dans ce dernier cas, le dire à
  Olivier avant d'écrire : on ne refait pas ce qu'un autre a déjà fait.
- **Branches.** Retouches sur la branche de l'arbre de travail. Gros morceau : une branche
  à ton nom, `claude/sujet` pour Claude Code, `Codex/sujet` pour Codex, partie de la plus
  avancée. Tu ne commites pas sur la branche d'un autre assistant, tu en repars.
  L'intégration dans `main` est le geste d'Olivier, ou le tien sur son ordre explicite.
- **Travail simultané** : seulement sur l'ordre d'Olivier, et dans un poste temporaire
  (`lib/SHAREDDIR/SCRIPTS/nouveau-poste.sh`), jamais à deux dans le même répertoire. Le
  poste se retire dès que sa branche est intégrée.
- **Ce qu'un autre a écrit.** Dans un bloc `rechercheCARE`, tu signes ce que tu écris par
  `\signeCARE{Claude}` ou `\signeCARE{Codex}`, et tu réponds sous le texte d'un autre sans
  le réécrire. Un désaccord entre assistants se dit à Olivier ; il ne se tranche pas par
  une réécriture.

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

Claude Code a `/reprise` et `/passation` ; les autres assistants font les mêmes gestes à la
main.

- **Début.** Le hook de démarrage donne `make sha`, la fin de `NOTES.md` et dit si le
  chantier est libre. Puis `git fetch`, pour voir ce qui a été poussé d'une autre machine,
  `make qui` si plusieurs branches vivent, `make deps` si `lib/` manque. Résumer à Olivier
  où en est le chantier, proposer la suite, attendre son accord. Rien ne se modifie avant.
- **Fin**, ou avant qu'Olivier change de surface ou d'assistant. `make` doit passer. Une
  entrée à la fin de `NOTES.md`, `## AAAA-MM-JJ HHhMM (surface)`, avec quatre rubriques,
  Fait, Décidé, À faire, Questions pour Olivier, terminée par `Base : <sha court>`. Commit
  des seuls fichiers que tu as modifiés, puis `git push` de ta branche. L'arbre reste sans
  rien en attente : c'est ce qui permet au suivant de s'y installer.
- Dans tout échange sur ce chantier, citer le commit courant (`make sha`).

## Commandes
- `make` (= `make pdf`) : pdflatex, bibtex, makeindex si .idx, pdflatex deux fois. Doit
  passer avant tout commit. En cas d'erreur, les lignes fautives du .log sont affichées.
- `make texroot` : pose `% !TEX root = <document principal>` en tête des fichiers inclus,
  pour compiler depuis TeXShop ; `make` signale ceux qui n'ont pas la ligne.
- `make sha` : commit courant, branche, modifications non commitées, commits non poussés.
- `make qui` : qui travaille ici, les branches, qui a touché quoi.
- `make am` : applique le dernier `chantier-*.patch` venu du chat (auteur conservé).
- `make publier MSG="..."` / `make importer` : échanges avec le répertoire finalisé (`DEST`
  dans `Makefile.local`). Le message du commit du finalisé est court, dit ce qui a changé
  depuis la dernière publication, et imite ceux du `git log` du finalisé ; sans `MSG`, un
  assistant voit la commande refuser. Si tu ne vois pas quoi écrire, demande à Olivier.
  Jamais de commande git directement dans DEST. Règle d'Olivier (27 septembre 2026) : rien de ce qui part vers un finalisé ne parle du chantier, d'un
  assistant ni de CARE. `make publier` refuse sans rien copier s'il trouve une macro ou un
  environnement CARE (\IMPORTANTCARE, rechercheCARE, \signeCARE) ou l'un des mots Claude,
  Codex, chantier, CARE dans ce qui partirait ; le hook pre-push du finalisé refuse un commit qui
  en parle ; retirer donc ces macros des sources avant de publier. Le push reste le geste
  d'Olivier.
- `make clean` / `make distclean`.

## Structure
- `__DOC__.tex` : document principal, nommé d'après le chantier sans le préfixe CARE-CHANTIER-,
  pour que les PDF des chantiers se distinguent ; jamais `main.tex`. Fichiers inclus à la
  racine ou dans un sous-dossier ; figures dans `figures/`.
- `lib/` : SHAREDDIR (styles, biblio, modèles, scripts) et logos, non versionné, en lecture
  seule. Une correction de style se fait dans SHAREDDIR (/Users/bournez/public_raw/SHAREDDIR
  sur le Mac d'Olivier), pas ici.
- `NOTES.md` : cahier de chantier, ajout seulement. `passations/` : échanges conservés
  tels quels, référencés depuis NOTES.md.
- `CHANTIER.md` : la fiche que lit le registre de tous les chantiers (`SCRIPTS/etat-chantiers.sh`
  de SHAREDDIR) : le parent, un résumé en une ligne, un journal ouvert, clos, rouvert. Tu
  remplis « En bref » à la première session et tu le tiens juste. Une ligne au journal
  quand Olivier clôt ou rouvre le chantier, jamais de ta propre initiative. Elle ne part
  jamais vers un finalisé (`.publier-exclude`).
- `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.codex/` : les règles et les réglages des
  assistants, suivis par git, jamais publiés.
- `Makefile.local`, `figcommons-local.tex`, `.claude/settings.local.json` : propres à la
  machine, non versionnés.

## Git
- Tes commits sont signés de ton nom d'intervenant ; ceux d'Olivier restent à son nom. Ne
  commite que les fichiers que tu as modifiés dans la session (`git add` explicite, commit
  par chemins) ; si des modifications non commitées traînent, d'Olivier ou d'un autre
  assistant, signale-les et n'y touche pas.
- Petits commits, messages en français, première ligne courte. `make` doit passer avant.
- Jamais de force-push, de rebase, de reset --hard ni de réécriture d'historique.
- Les branches et l'intégration dans `main` : voir « Qui travaille ici ».
- Pas d'artefacts de compilation dans le dépôt (le .gitignore s'en charge).

## LaTeX, rappels propres à ce chantier
- Macros réservées à Olivier, à préserver telles quelles : \IMPORTANT, \SURLIGNE,
  \SURSURLIGNE, et l'environnement recherche. Pour mettre en évidence :
  \IMPORTANTCARE[titre]{texte} ; pour une piste ou une question ouverte : l'environnement
  rechercheCARE, signé par \signeCARE. Aucune occurrence ne doit rester dans ce qui part
  vers un finalisé.
- __NOTES_SPECIFIQUES__
