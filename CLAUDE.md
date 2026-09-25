# SHAREDDIR

Le fonds commun d'Olivier Bournez : styles LaTeX, bibliographie, modèles, conventions,
et le squelette dont sortent les chantiers. Travail à deux, Olivier et Claude. Ce fichier
prime sur les instructions générales.

## Deux choses à savoir avant de toucher à quoi que ce soit

- **Ce dépôt est public**, https://github.com/nirzolb/SHAREDDIR. Rien de personnel n'y
  entre au-delà de chemins et de conventions, et un diff se relit avant d'être poussé.
- **Il est la source des chantiers.** Ce qui change ici change la façon dont les chantiers
  futurs seront faits, et parfois le comportement de Claude partout, puisque
  `~/.claude/CLAUDE.md` est un lien vers `CLAUDE-PERSO.md`.

## Ce que contient le dépôt

| | |
|---|---|
| `STYLEDIR/` | les styles et macros. `~/lib/LaTeX/Perso` y renvoie par des liens : une correction arrive dans le CV et les exposés sans recopie |
| `SQUELETTE/` | le modèle de chantier : CLAUDE.md, NOTES.md, Makefile, hooks, `.claude/` |
| `SCRIPTS/nouveau-chantier.sh` | ouvre un chantier à partir du squelette |
| `LATEX-EXEMPLES/` | les modèles de document que le script recopie |
| `BIBDESKDIR/` | la bibliographie de référence, dont `@@reference-biblio.bib` |
| `CONVENTIONS-LATEX.md`, `CONVENTIONS-ARTICLES.md` | importées automatiquement dans les chantiers par `lib/SHAREDDIR` |
| `CLAUDE-PERSO.md` | les instructions personnelles d'Olivier, lues partout par le lien `~/.claude/CLAUDE.md` |
| `README-CHANTIERS.md` | l'aide-mémoire d'ensemble |

## Le squelette ne se propage pas tout seul

`lib/SHAREDDIR` d'un chantier est un lien : une correction de **style** ou de
**conventions** y arrive aussitôt. Mais le **squelette** est recopié à l'ouverture du
chantier, pas lié : corriger `SQUELETTE/Makefile` ou `SQUELETTE/.claude/` ne change rien
aux chantiers déjà ouverts. Il faut leur porter la correction, chantier par chantier, et
dire lesquels dans l'entrée de passation.

Les chantiers ouverts à ce jour : `00-CHANTIERS-CARE/CARE-CHANTIER-INF412`,
`CARE-CHANTIER-STACS2027-PRECISION`, `CARE-CHANTIER-PAGE-WEB`,
`CARE-ET-PROGRAMMATION/CARE-WORKFLOW-OMNIFOCUS-MAIL-DT-DIR`,
`SOUS-CHANTIERS-COMPREHENSION/CARE-CHANTIER-COURS-POUR-MOI-...`, et le dépôt du CV,
`/Users/bournez/CURRICULUM-VITAE=`, qui suit les usages sans venir du squelette.

## Publier

`./do-public_raw-update.command` : `git add -A`, commit, push. Le dépôt étant public, on
relit le diff avant. Ce script faisait `git add * */*`, qui laissait de côté les fichiers
cachés, donc `.claude/` et `.gitignore` ; corrigé le 25 septembre 2026.

## Git

- Tes commits sont signés `Claude (CARE)`, ceux d'Olivier restent à son nom. Quand il te
  demande de commiter une modification à lui, garde-le comme auteur (`--author`) et ne
  prends que la place de celui qui a passé la commande.
- Ne commite que ce que tu as modifié. Petits commits, messages en français.
- Jamais de force-push, de rebase, de `reset --hard`, ni de réécriture d'historique.

## Début et fin de session

Un hook donne `make sha` et la fin de `NOTES.md` au démarrage. `/reprise` pour un résumé,
`/passation` pour clore. `make sha` et `make am` sont les seules cibles : ce dépôt ne se
construit pas.
