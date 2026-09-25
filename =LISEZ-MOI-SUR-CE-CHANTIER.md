# Ce dépôt, en une page

Pour Olivier, quand il arrive ici et ne se souvient plus. Les règles de travail détaillées
sont dans `CLAUDE.md`, le récit des sessions dans `NOTES.md`, la logique d'ensemble des
chantiers dans `README-CHANTIERS.md`.

## Où je suis

`/Users/bournez/public_raw/SHAREDDIR`, dépôt **public**
[nirzolb/SHAREDDIR](https://github.com/nirzolb/SHAREDDIR).

C'est le fonds commun : styles LaTeX, bibliographie de référence, modèles, conventions, et
le squelette dont sortent les chantiers. Le lien
`CARE-ET-SHAREDIR-En-Fait-Un-Lien-Symbolique-Vers-Mon-Repertoire`, dans
`00-CHANTIERS-CARE`, pointe ici.

## Les deux choses à ne pas oublier

**Ce dépôt est public.** Tout ce qui y entre est lisible par n'importe qui, commits
compris. Rien de personnel au-delà de chemins et de conventions, et un diff se relit avant
d'être poussé.

**Ce que je change ici change la façon dont les chantiers seront faits.** Et parfois plus :
`~/.claude/CLAUDE.md` est un lien vers `CLAUDE-PERSO.md`, donc le modifier change le
comportement de Claude sur toutes mes machines et tous mes projets.

## Ce qui se passe si je publie

```bash
./do-public_raw-update.command
```

`git add -A`, un commit intitulé « Update », et un `push` vers GitHub. **C'est public et
immédiat.** Relire le diff avant.

## Ce qui se propage, et ce qui ne se propage pas

| ce que je corrige | ce qui arrive |
|---|---|
| `STYLEDIR/` (styles, macros) | **aussitôt partout** : `~/lib/LaTeX/Perso` y renvoie par des liens, donc le CV et les exposés le voient sans recopie |
| `CONVENTIONS-*.md` | **aussitôt** dans les chantiers : leur `lib/SHAREDDIR` est un lien |
| `SQUELETTE/`, `SCRIPTS/` | **rien du tout** pour les chantiers déjà ouverts : ils en ont une **copie**, faite à leur ouverture |

C'est le piège du lieu. Corriger `SQUELETTE/Makefile` ne répare aucun chantier existant ;
il faut leur porter la correction, un par un, et dire lesquels dans la passation.

Chantiers ouverts à ce jour : `CARE-CHANTIER-INF412`, `CARE-CHANTIER-STACS2027-PRECISION`,
`CARE-CHANTIER-PAGE-WEB`, `CARE-ET-PROGRAMMATION/CARE-WORKFLOW-OMNIFOCUS-MAIL-DT-DIR`,
`SOUS-CHANTIERS-COMPREHENSION/CARE-CHANTIER-COURS-POUR-MOI-...`, `essai`, plus le CV,
`/Users/bournez/CURRICULUM-VITAE=`, qui suit les usages sans venir du squelette.

## Ce que contient le dépôt

| | |
|---|---|
| `STYLEDIR/` | les styles et macros, liés depuis `~/lib/LaTeX/Perso` |
| `SQUELETTE/` | le modèle de chantier, recopié à l'ouverture |
| `SCRIPTS/nouveau-chantier.sh` | ouvre un chantier |
| `LATEX-EXEMPLES/` | les modèles de document |
| `BIBDESKDIR/` | la bibliographie de référence |
| `CONVENTIONS-LATEX.md`, `CONVENTIONS-ARTICLES.md` | importées dans les chantiers |
| `CLAUDE-PERSO.md` | mes instructions, lues partout par `~/.claude/CLAUDE.md` |
| `README-CHANTIERS.md` | l'aide-mémoire d'ensemble |

## Ouvrir un chantier

```bash
/Users/bournez/public_raw/SHAREDDIR/SCRIPTS/nouveau-chantier.sh cours|expose|doc|article NOM --github
cd /Users/bournez/00-CHANTIERS-CARE/NOM && claude
```

## Les commandes

| | |
|---|---|
| `make sha` | où j'en suis : commit, branche, non commité, non poussé |
| `make am` | applique un patch venu du chat |
| `./do-public_raw-update.command` | publie, sur un dépôt public |

Ce dépôt ne se construit pas : il n'y a rien à compiler.

## Si quelque chose tourne mal

- Un style corrigé ici et sans effet ailleurs : vérifier que le lien de `~/lib/LaTeX/Perso`
  est vivant, et qu'une copie n'a pas été rétablie à côté.
- Un chantier qui n'a pas la dernière version du squelette : c'est normal, il faut la lui
  porter.
- Ce qui a été décidé et pourquoi : `NOTES.md`.
