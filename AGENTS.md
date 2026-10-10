# SHAREDDIR

Le fonds commun d'Olivier Bournez : styles LaTeX, bibliographie, modèles, conventions,
et le squelette dont sortent les chantiers. Olivier y travaille avec ses assistants, Claude
Code et Codex. Ce fichier porte les règles du dépôt, les mêmes pour tous, et prime sur leurs
instructions générales. `CLAUDE.md` l'importe et n'ajoute que ce qui est propre à Claude
Code : une règle nouvelle s'écrit ici, sinon les autres assistants l'ignorent.

## Deux choses à savoir avant de toucher à quoi que ce soit

- **Ce dépôt est public**, https://github.com/nirzolb/SHAREDDIR. Rien de personnel n'y
  entre au-delà de chemins et de conventions, et un diff se relit avant d'être poussé.
- **Il est la source des chantiers.** Ce qui change ici change la façon dont les chantiers
  futurs seront faits, et parfois le comportement de Claude et de Codex partout, puisque
  `~/.claude/CLAUDE.md` et `~/.codex/AGENTS.md` sont des liens vers `CLAUDE-PERSO.md`.

## Qui travaille ici

- **Ton nom d'intervenant** signe tes commits et note ta présence : `Claude (CARE)` pour
  Claude Code (`.claude/settings.json`), `Codex` pour Codex (`.codex/config.toml`). Les
  commits d'Olivier restent à son nom.
- **Un seul répertoire, à tour de rôle**, sur `main`. Le hook de démarrage dit si le dépôt
  est libre (`SCRIPTS/qui.sh`). S'il avertit qu'un autre assistant a été vu depuis moins
  d'une heure, que des fichiers suivis sont modifiés sans être commités, ou qu'un autre
  vient de commiter, tu ne modifies rien avant d'en avoir parlé à Olivier.

## Ce que contient le dépôt

| | |
|---|---|
| `STYLEDIR/` | les styles et macros. `~/lib/LaTeX/Perso` y renvoie par des liens : une correction arrive dans le CV et les exposés sans recopie |
| `SQUELETTE/` | le modèle de chantier : AGENTS.md (les règles, communes aux assistants), CLAUDE.md qui l'importe, NOTES.md, Makefile, hooks, `.claude/`, `.codex/` |
| `SCRIPTS/nouveau-chantier.sh` | ouvre un chantier à partir du squelette ; `--dir` pour le ranger ailleurs que dans l'annuaire, où il reçoit alors un lien |
| `SCRIPTS/deplacer-chantier.sh` | déplace un chantier dans un autre répertoire : lien dans l'annuaire `~/00-CHANTIERS-CARE`, où le registre cherche, et renommage du répertoire où Claude Code range sa mémoire. Lancé par Olivier, sessions fermées |
| `SCRIPTS/etat-chantiers.sh` | dresse le registre de tous les chantiers à partir de git et de leur fiche `CHANTIER.md` ; il l'écrit hors de ce dépôt |
| `SCRIPTS/qui.sh`, `debut-session.sh` | qui travaille dans un chantier, où est la version la plus avancée ; appelés par `make qui` et par les hooks de démarrage. Les chantiers les atteignent par `lib/SHAREDDIR` : une correction y arrive sans portage |
| `SCRIPTS/tex-root.py` | pose `% !TEX root` en tête des fichiers inclus d'un chantier ; appelé par `make` (vérification) et `make texroot` (correction), et par `nouveau-chantier.sh` |
| `SCRIPTS/nouveau-poste.sh` | ouvre et retire un poste temporaire, pour le cas rare où deux assistants travaillent en même temps au même chantier |
| `LATEX-EXEMPLES/` | les modèles de document que le script recopie |
| `BIBDESKDIR/` | la bibliographie de référence, dont `@@reference-biblio.bib` |
| `CONVENTIONS-LATEX.md`, `CONVENTIONS-ARTICLES.md` | importées automatiquement dans les chantiers par `lib/SHAREDDIR` |
| `CLAUDE-PERSO.md` | les instructions personnelles d'Olivier pour ses assistants, lues partout par les liens `~/.claude/CLAUDE.md` (Claude Code) et `~/.codex/AGENTS.md` (Codex) |
| `README-CHANTIERS.md` | l'aide-mémoire d'ensemble |
| `AGENTS.md`, `CLAUDE.md`, `.claude/`, `.codex/` | les règles de ce dépôt et les réglages des deux assistants, suivis par git |

## Le squelette ne se propage pas tout seul

`lib/SHAREDDIR` d'un chantier est un lien : une correction de **style** ou de
**conventions** y arrive aussitôt. Mais le **squelette** est recopié à l'ouverture du
chantier, pas lié : corriger `SQUELETTE/Makefile` ou `SQUELETTE/.claude/` ne change rien
aux chantiers déjà ouverts. Il faut leur porter la correction, chantier par chantier, et
dire lesquels dans l'entrée de passation. Les scripts de `SCRIPTS/`, eux, sont atteints par
le lien : ce qui peut vivre là plutôt que dans le squelette n'a pas à être porté.

La liste des chantiers ouverts n'est plus tenue ici, elle vieillissait : c'est le registre
qui la donne (`SCRIPTS/etat-chantiers.sh`, ou `/registre`), hors de ce dépôt public. Quatre
dépôts ne se portent pas mécaniquement, leurs règles étant trop particulières : INF412,
PAGE-WEB, WORKFLOW-OMNIFOCUS-MAIL-DT-DIR, et le dépôt du CV, `/Users/bournez/CURRICULUM-VITAE=`,
qui suit les usages sans venir du squelette.

Un portage se fait sur l'ordre d'Olivier, chantier au repos, répété d'abord sur une copie
jetable quand il touche aux règles. Il laisse dans le cahier du chantier une entrée
`(code, depuis SHAREDDIR)` : le registre la reconnaît et ne compte pas ce commit comme une
activité du chantier. [5 octobre 2026]

Un portage en profite pour retirer du `=LISEZ-MOI-SUR-CE-CHANTIER.md` du chantier son chemin
absolu, que le squelette n'écrit plus : la ligne devient celle du squelette. Un chemin écrit
dans le dépôt est faux au premier déplacement. [10 octobre 2026]

## Publier

`./do-public_raw-update.command` : `git add -A`, commit, push. Le dépôt étant public, on
relit le diff avant. Ce script faisait `git add * */*`, qui laissait de côté les fichiers
cachés, donc `.claude/` et `.gitignore` ; corrigé le 25 septembre 2026. Comme il prend tout,
un fichier non suivi qui traîne part avec : regarder `git status` avant de le lancer.

## Git

- Tes commits sont signés de ton nom d'intervenant, ceux d'Olivier restent à son nom. Quand il te
  demande de commiter une modification à lui, garde-le comme auteur (`--author`) et ne
  prends que la place de celui qui a passé la commande.
- Ne commite que ce que tu as modifié. Petits commits, messages en français.
- Jamais de force-push, de rebase, de `reset --hard`, ni de réécriture d'historique.

## Début et fin de session

Au démarrage, un hook donne `make sha`, la fin de `NOTES.md`, et dit si le dépôt est libre.
Claude Code a `/reprise` pour un résumé, `/passation` pour clore, `/registre` pour régénérer
le registre des chantiers et le recopier dans Notion ; une tâche planifiée de l'application le
fait aussi chaque matin, sur ce Mac. Un autre assistant fait les mêmes
gestes à la main : résumer et attendre l'accord d'Olivier au début ; à la fin, une entrée
dans `NOTES.md` (Fait, Décidé, À faire, Questions pour Olivier, puis `Base : <sha court>`),
commit des seuls fichiers qu'il a modifiés, relecture du diff, push. `make sha` et `make am`
sont les seules cibles : ce dépôt ne se construit pas.
