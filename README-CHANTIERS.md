# Chantiers : aide-mémoire

Deux modes. **Brouillon** : document jetable, produit dans le chat, avec les modèles de
SHAREDDIR. **Chantier** : document qui vit dans un dépôt git privé sous
`/Users/bournez/00-CHANTIERS-CARE/NOM`, travaillé à deux (Olivier et Claude) dans Claude
Code, parfois depuis le chat, et publié de temps en temps vers un répertoire *finalisé*
que des tiers peuvent voir. Le dépôt est la seule source de vérité.

## Ouvrir un chantier

Depuis rien :

```
/Users/bournez/public_raw/SHAREDDIR/SCRIPTS/nouveau-chantier.sh cours|expose|doc NOM --github
cd /Users/bournez/00-CHANTIERS-CARE/NOM && claude
```

Option `--dest /chemin/finalise` si le répertoire finalisé est déjà connu. `--github` suppose
`gh` connecté (`gh auth status`) ; sinon le chantier est créé, mais sans dépôt distant.

Depuis un brouillon du chat : dire « on ouvre un chantier ». Claude demande le nom, le type
si besoin et l'éventuel répertoire finalisé, livre `NOM.tar.gz` et rappelle les commandes :

```
cd /Users/bournez/00-CHANTIERS-CARE && tar xzf ~/Downloads/NOM.tar.gz && cd NOM
gh repo create NOM --private --source=. --remote=origin --push
make && claude
```

## Dans Claude Code (le mode normal)

| Quoi | Comment |
|---|---|
| Début de session | automatique : un hook fournit `make sha` et la fin de NOTES.md à Claude Code. `/reprise` en plus pour un résumé et une proposition |
| Fin de session | `/passation` (ou `/passation remarque libre`) : entrée dans NOTES.md, commit, push. Quand tu arrêtes, ou avant de passer au chat ; pas après chaque petite tâche (Claude Code commite au fil de l'eau) |
| Compiler | `make` (pdflatex, bibtex, makeindex si besoin, pdflatex x2 ; erreurs du .log affichées) |
| Où en est-on | `make sha` : le sha est l'identifiant du commit courant (`a351890`), plus branche, non commité, non poussé. À citer dans tout échange pour être sûrs de parler de la même version |
| Depuis le téléphone | `claude remote-control --name NOM` dans le répertoire, puis app Claude, onglet Code, session au point vert |

- Les commits de Claude Code sont signés Claude-Code ; les tiens, depuis ton terminal,
  restent à ton nom. Si tu demandes à Claude Code de committer tes propres retouches,
  elles seront signées Claude-Code : commite-les toi-même si la distinction compte.
  Relecture : `git log --author=Claude-Code`.
- Un seul chantier par surface à la fois. Deux sessions Claude Code sur le même chantier :
  `git worktree`, ou `claude remote-control --spawn worktree`.

## Depuis le chat

Le chat ne voit qu'une photo (connaissances du Projet claude.ai synchronisées par le
connecteur GitHub, ou fichiers collés). Il annonce son commit de base ; tu lui donnes le
tien (`make sha`). S'ils diffèrent, Sync now ou colle le fichier à jour avant de discuter.

Ce qu'il écrit revient en patch `chantier-AAAAMMJJ-HHMM.patch` (auteur Claude-Code,
entrée de passation incluse). Dans le chantier : `make am` (dernier patch de ~/Downloads,
ou `make am PATCH=fichier`), ou dire à Claude Code « applique le dernier patch de
~/Downloads ». En cas de conflit, git le dit et Claude Code le résout.

Pour un chantier actif dans Claude Code, préférer Remote Control au chat : même session,
même état, rien à synchroniser.

## Répertoire finalisé (tiers)

1. `Makefile.local` du chantier : `DEST = /chemin/du/finalise`.
2. Une fois par finalisé : `hooks/install.sh /chemin/du/finalise` (hook pre-push qui
   refuse toute trace de Claude ; contournement volontaire : `git push --no-verify`).
3. `make publier` : compile, copie le chantier dans DEST (exclusions dans
   `.publier-exclude`), puis un commit unique **à ton nom** dans DEST, sans historique.
   `make publier MIRROR=1` supprime aussi dans DEST ce qui a disparu du chantier.
4. `make importer` : modifications des tiers vers le chantier, puis commit. Refuse si
   l'arbre du chantier n'est pas propre.
5. Jamais de `pull`, `merge`, `push` entre chantier et finalisé, ni de git tapé dans DEST.

## À retenir

- `lib/` (SHAREDDIR, logos) est en lecture seule et non versionné. Une correction de
  style se fait dans `/Users/bournez/public_raw/SHAREDDIR`, puis
  `do-public_raw-update.command` (qui devrait faire `git add -A`).
- Non versionnés, propres à la machine : `Makefile.local`, `figcommons-local.tex`,
  `main.pdf`, `.claude/settings.local.json`.
- `NOTES.md` : ajout seulement, une entrée par session. `passations/` pour les échanges
  gardés tels quels.
- Ce que Claude doit savoir sur ce chantier précisément : rubrique « rappels propres à ce
  chantier » de CLAUDE.md. Ce qui vaut pour tous les chantiers : CONVENTIONS-LATEX.md
  dans SHAREDDIR (importé automatiquement). Ce qui vaut pour toi partout :
  `~/.claude/CLAUDE.md` (lien vers CLAUDE-PERSO.md dans SHAREDDIR).

## Dépannage

| Symptôme | Remède |
|---|---|
| `lib/` absent, styles introuvables | `make deps` |
| Compilation étrange après un changement de style | `make distclean && make` |
| Le hook refuse un push du finalisé | auteur ou message avec « Claude » : `git commit --amend --reset-author` ; si c'est voulu, `--no-verify` |
| `make am` échoue (conflit) | `git am --abort`, puis demander à Claude Code d'appliquer le patch et de résoudre |
| `gh` refuse | `gh auth login` (une fois ; code affiché dans le terminal, à saisir sur github.com) |
| `git push` : aucun dépôt distant | `gh repo create NOM --private --source=. --remote=origin --push` |
| `claude` demande un code par mail | connecter d'abord le navigateur à claude.ai, puis `claude auth login` |
| Claude Code laisse un fichier « A » non commité | c'est le tien (ajouté par toi) : `git commit` depuis ton terminal, à ton nom |
| Le chat parle d'une vieille version | comparer les commits (`make sha`), Sync now, ou passer par Remote Control |
