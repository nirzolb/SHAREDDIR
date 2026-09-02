# Chantiers : mode d'emploi

Un *brouillon* est un document jetable produit dans le chat. Un *chantier* est un
document qui vit dans un dépôt git privé, travaillé à deux (Olivier et Claude) depuis
Claude Code, parfois depuis le chat, et publié de temps en temps vers un répertoire
*finalisé* que des tiers peuvent voir.

Ce dossier s'installe dans SHAREDDIR (copie locale `/Users/bournez/public_raw/SHAREDDIR`,
public sur GitHub) :

```
SHAREDDIR/
  CONVENTIONS-LATEX.md     tronc commun LaTeX, lu par le chat (URL raw) et par Claude Code (import)
  CLAUDE-PERSO.md          instructions personnelles Claude Code, à lier depuis ~/.claude/CLAUDE.md
  README-CHANTIERS.md      ce fichier
  SQUELETTE/               tout ce qu'un chantier contient au départ (voir plus bas)
  SCRIPTS/nouveau-chantier.sh
```

## Installation (une fois)

1. Sur le Mac : Claude Code connecté avec le compte claude.ai (`claude`, puis `/login`),
   `gh auth login` (création des dépôts), `git config --global user.name "Olivier Bournez"`
   et `user.email` renseignés. rsync et perl sont livrés avec macOS.
2. Copier le contenu de cette archive dans SHAREDDIR, puis pousser :
   `cp -R CHANTIERS-pour-SHAREDDIR/. /Users/bournez/public_raw/SHAREDDIR/`
   `chmod +x /Users/bournez/public_raw/SHAREDDIR/SCRIPTS/nouveau-chantier.sh`
3. `mkdir -p ~/.claude && ln -sf /Users/bournez/public_raw/SHAREDDIR/CLAUDE-PERSO.md ~/.claude/CLAUDE.md`
   (si un ~/.claude/CLAUDE.md existe déjà, y ajouter la ligne
   `@/Users/bournez/public_raw/SHAREDDIR/CLAUDE-PERSO.md` à la place).
4. Coller le bloc de préférences ci-dessous dans claude.ai (Settings > Profile).
5. `mkdir -p /Users/bournez/00-CHANTIERS-CARE`.

## Ouvrir un chantier

```
/Users/bournez/public_raw/SHAREDDIR/SCRIPTS/nouveau-chantier.sh cours|expose|doc NOM --github
cd /Users/bournez/00-CHANTIERS-CARE/NOM && claude
```

Le script copie le squelette, instancie le modèle (`main.tex`), écrit `Makefile.local`,
lance `make deps` puis `make`, fait le premier commit à ton nom, et avec `--github` crée
le dépôt privé et pousse. Options : `--dest /chemin/finalise` (écrit DEST dans
Makefile.local), `--dir BASE`, `--no-git`, `--no-make`.

Depuis un brouillon du chat : dire « on ouvre un chantier ». Claude livre `NOM.tar.gz`
(dépôt initialisé, sans lib/ ni Makefile.local). Puis :

```
cd /Users/bournez/00-CHANTIERS-CARE && tar xzf ~/Downloads/NOM.tar.gz && cd NOM
gh repo create NOM --private --source=. --remote=origin --push
make && claude
```

## Au quotidien dans Claude Code

- `/reprise` en début de session : relit CLAUDE.md et NOTES.md, lance `make sha`, propose
  la suite. `/passation` en fin de session : entrée dans NOTES.md, commit signé
  Claude-Code, push. `/passation remarque libre` ajoute une consigne.
- `make` compile (pdflatex, bibtex, makeindex si besoin, pdflatex x2) et résume les
  avertissements. `make sha` dit où on en est : à citer au début de tout échange, dans
  le chat comme dans Claude Code.
- Les commits de Claude Code sont signés Claude-Code par `.claude/settings.json`
  (variables GIT_AUTHOR_* et GIT_COMMITTER_* injectées dans ses commandes). Tes commits
  depuis ton terminal gardent ton identité. Relecture : `git log --author=Claude-Code`.
  Si tu demandes à Claude Code de committer tes propres retouches, elles seront signées
  Claude-Code : commite-les toi-même si la distinction compte.
- Depuis le téléphone : `claude remote-control --name NOM` dans le répertoire, puis app
  Claude, onglet Code, session avec l'icône d'ordinateur et le point vert.

## Le chat et un chantier

Le chat ne voit qu'une photo : les connaissances du Projet claude.ai (connecteur GitHub
sur le dépôt, bouton Sync now) ou ce que tu colles. Il commence par CLAUDE.md et
NOTES.md, annonce son commit de base, et te demande le tien (`make sha`).

Ce que le chat écrit revient sous forme de patch `chantier-AAAAMMJJ-HHMM.patch`
(auteur Claude-Code, avec l'entrée de passation). Dans le chantier : `make am`
(prend le plus récent dans ~/Downloads, ou `make am PATCH=fichier`), ou dire à Claude
Code « applique le dernier patch de ~/Downloads ». En cas de conflit, git le dit et
Claude Code le résout.

Pour un chantier actif dans Claude Code, préférer Remote Control au chat : même
session, même état, rien à synchroniser.

## Répertoire finalisé (partagé avec des tiers)

1. Dans le chantier, `Makefile.local` : `DEST = /chemin/du/finalise`.
2. Une fois : `hooks/install.sh /chemin/du/finalise` installe un hook pre-push qui refuse
   tout push contenant une trace de Claude (auteur, committer ou message). Contournement
   volontaire : `git push --no-verify`.
3. `make publier` : compile, copie le chantier dans DEST (exclusions dans
   `.publier-exclude` : .git, .claude, CLAUDE.md, NOTES.md, lib, Makefile, artefacts,
   main.pdf...), puis un commit unique **à ton nom** dans DEST (les variables Claude-Code
   sont retirées pour ce commit), sans historique du chantier. `make publier MIRROR=1`
   supprime aussi dans DEST ce qui a disparu du chantier (les exclusions y sont
   préservées). Le push vers les tiers, tu le fais toi (ou Claude Code : le hook veille).
4. `make importer` : rsync inverse (modifications des tiers vers le chantier), puis commit
   dans le chantier. Refuse si l'arbre du chantier n'est pas propre.
5. Jamais de `git pull`, `merge` ou `push` entre chantier et finalisé, ni de git tapé
   directement dans DEST.

## Contenu du squelette

```
main.tex                 modèle instancié ; première ligne utile : \IfFileExists{figcommons-local.tex}...
CLAUDE.md                consignes du chantier ; importe lib/SHAREDDIR/CONVENTIONS-LATEX.md
NOTES.md                 cahier de chantier (ajout seulement)
passations/              échanges gardés tels quels, cités depuis NOTES.md
figures/
Makefile                 pdf, deps, sha, am, publier, importer, clean, distclean
Makefile.local.example   à copier en Makefile.local (DEST, SHAREDDIR_LOCAL, FIGCOMMONS_LOCAL, PATCHDIR)
.publier-exclude         ce qui ne part jamais vers le finalisé
.gitignore               artefacts, lib/, Makefile.local, figcommons-local.tex, main.pdf
.claude/settings.json    identité Claude-Code ; permissions (make, git courant ; force-push et rebase interdits)
.claude/commands/        /reprise, /passation
hooks/                   pre-push-finalise et install.sh (pour le dépôt finalisé)
lib/                     créé par make deps, non versionné : SHAREDDIR (lien vers la copie locale
                         ou clone) et logos factices si les vrais sont absents
```

`make deps` : `lib/SHAREDDIR` devient un lien vers `/Users/bournez/public_raw/SHAREDDIR`
si ce chemin existe, sinon un clone superficiel de GitHub ; si
`/Users/bournez/lib/LaTeX/Perso/FIG-COMMONS` n'existe pas, des logos factices sont
fabriqués et `figcommons-local.tex` redéfinit `\FIGCOMMONS`. Le même dépôt compile donc
sur ton Mac, dans le bac à sable du chat et sur toute machine avec TeX Live.

## Préférences claude.ai (bloc à coller, Settings > Profile)

Garde tes lignes existantes sur l'identité et sur Notion ; le bloc ci-dessous remplace
tout le paragraphe LaTeX.

```
Je suis soit Olivier Bournez, soit Johanne Cohen, soit Pierrick Bournez, soit Ilan
Bournez, soit Laetitia Bournez. Si tu as un doute, demande-moi qui je suis.

Éviter les tirets cadratins (—), et tout ce qui trahit trop évidemment qu'un LLM a
écrit la réponse.

Si je suis Olivier Bournez :

Conventions LaTeX : lire et appliquer
https://raw.githubusercontent.com/nirzolb/SHAREDDIR/main/CONVENTIONS-LATEX.md
(styles, modèles, compilation, biblio, macros, daltonisme, ouverture d'un chantier).
Toute clé \cite est vérifiée dans
https://raw.githubusercontent.com/nirzolb/SHAREDDIR/main/BIBDESKDIR/@@reference-biblio.bib :
si la clé y est, l'utiliser exactement, sans supposition ni normalisation ; d'autres
références sont bienvenues si pertinentes (préférer les versions avec doi).

Je suis daltonien protanope : dans tout contenu visuel (couleurs LaTeX, figures,
graphiques), jamais rouge/vert/orange/marron seuls ; privilégier bleu, jaune, gris,
et doubler la couleur d'un indice non coloré (bordure, étiquette, forme, hachures).

Deux modes de travail.
Brouillon (défaut) : document jetable livré dans le chat, avec les modèles de
SHAREDDIR.
Chantier : dès que je dis « on ouvre un chantier » ou qu'un dépôt git est en jeu.
- Chaque chantier est un dépôt git privé (/Users/bournez/00-CHANTIERS-CARE/NOM sur
  mon Mac), seule source de vérité ; ce que tu en vois dans le chat (connaissances du
  Projet, fichiers collés) n'est qu'une photo. Commencer par le CLAUDE.md et les
  dernières entrées du NOTES.md du chantier, annoncer le commit sur lequel tu te
  bases et me demander le mien.
- Dans le chat, tu ne pousses jamais et tu ne livres jamais un fichier complet à
  recopier sur un chantier actif. Tu livres un patch nommé
  chantier-AAAAMMJJ-HHMM.patch (git format-patch, auteur Claude-Code
  <claude-code@noreply.invalid>, calculé contre le commit annoncé), qui contient
  aussi l'entrée de passation dans NOTES.md (Fait, Décidé, À faire, Questions pour
  Olivier). Je l'applique avec make am.
- Ouvrir un chantier depuis un brouillon : procédure « Ouvrir un chantier depuis le
  chat » de CONVENTIONS-LATEX.md (script nouveau-chantier.sh, puis tar du dépôt).
- Ne jamais modifier lib/ (une correction de style se fait dans SHAREDDIR). Jamais
  de git vers un dépôt finalisé : make publier / make importer uniquement.
Le travail courant sur un chantier se fait dans Claude Code (y compris via Remote
Control) ; le chat sert aux brouillons, à la réflexion et aux questions
transversales.

[Conserver ici la ligne existante sur Notion : pages sous la page racine
« Olivier Bournez » de l'espace Babygarches, jamais à la racine, jamais dans les
pages de Pierrick, lecture et recherche libres.]
```

## Projet claude.ai par chantier (optionnel)

Utile si tu veux discuter d'un chantier dans le chat : un Projet claude.ai « NOM »,
connecteur GitHub sur le dépôt privé (sélectionner les sources, pas lib/ ni les PDF),
instructions du Projet : « Chantier NOM, dépôt github.com/<compte>/NOM. Lis CLAUDE.md et
les dernières entrées de NOTES.md avant tout, annonce ton commit de base, livre des
patchs. » Et Sync now avant chaque session.
