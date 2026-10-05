# Ce chantier, en une page

Pour Olivier, quand il arrive ici et ne se souvient plus. Les règles de travail détaillées
sont dans `AGENTS.md`, communes à tous mes assistants, le récit des sessions dans `NOTES.md`.

Ce fichier est posé à l'ouverture du chantier, avec des trous. **L'assistant de la
première session le remplit**, et chacun le tient à jour ensuite : dès qu'une sortie, une commande ou un
piège change, il change ici aussi.

## Où je suis

`__CHEMIN__`, dépôt privé `__NOM__`.

On y travaille __A_REMPLIR : de quoi il s'agit, en une phrase__. Le dépôt est la source de
vérité : tout part d'ici.

Chantier de type `__TYPE__`, ouvert le __DATE__ à partir du squelette de SHAREDDIR.

## La chose à ne pas oublier

__A_REMPLIR : ce qui n'est vrai que de ce chantier et qu'on oublie toujours. Pour un
document LaTeX ordinaire, il n'y a peut-être rien : écrire alors « Rien de particulier,
c'est un chantier ordinaire. »__

## Ce qui se passe si je publie

`make publier` copie le chantier dans le **répertoire finalisé**, celui que des tiers
voient, puis y fait un commit unique à mon nom, sans l'historique du chantier.

- répertoire finalisé : __A_REMPLIR : le chemin, ou « aucun pour l'instant »__
- qui le voit : __A_REMPLIR : qui, et par quel chemin__
- ce qui n'y va pas : ce que `.publier-exclude` écarte, dont `AGENTS.md`, `CLAUDE.md` et `NOTES.md`

`make publier MIRROR=1` supprime en plus là-bas ce qui a disparu ici. `make importer`
rapatrie les modifications des tiers. **Jamais de commande git dans le finalisé** : ces
deux cibles sont les seuls passages.

__A_REMPLIR : s'il existe une autre sortie, un serveur, un site, une liste de diffusion,
la décrire ici et dire qui a le droit de la déclencher.__

## Le cycle normal

```
make            compile, et doit passer avant tout commit
make sha        où j'en suis : commit, branche, non commité, non poussé
make publier    vers le répertoire finalisé
```

## Les commandes

| | |
|---|---|
| `make` | compile `__DOC__.tex` en `__DOC__.pdf` : pdflatex, bibtex, makeindex si besoin, pdflatex deux fois |
| `make sha` | commit courant, branche, modifications non commitées, commits non poussés |
| `make qui` | qui travaille ici (Claude Code, Codex), les branches, qui a touché quoi en dernier |
| `make deps` | refait `lib/`, à lancer si les styles manquent |
| `make am` | applique le dernier patch venu du chat |
| `make publier` / `make importer` | échanges avec le finalisé |
| `make clean` / `make distclean` | ménage |

## Ses particularités

__A_REMPLIR : les pièges qui ont coûté du temps, pas une liste théorique. Les ajouter au
fil des sessions, quand on les rencontre. S'il n'y en a pas encore, écrire « Rien de
signalé pour l'instant. »__

## Si quelque chose tourne mal

- Styles introuvables, `lib/` absent : `make deps`.
- Compilation étrange après un changement de style : `make distclean && make`.
- Ce qui a été décidé et pourquoi : `NOTES.md`, du plus ancien au plus récent, et
  `passations/`.
- Ce qui est parti de travers ici : `git log`, `git diff`, le dépôt distant.
