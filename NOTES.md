# Cahier de SHAREDDIR

Une entrée par session, ajout seulement, la plus récente en bas. Le hook de démarrage en
montre les deux dernières ; `/passation` en écrit une nouvelle.

Répartition avec CLAUDE.md : **ici le récit**, ce qui a été fait tel jour et pourquoi ;
**là-bas les règles**. Ce dépôt étant public, les deux le sont.

## 2026-09-25 23h30

**Fait.** SHAREDDIR devient un chantier à son tour, après le CV et la page web. Ajoutés :
`.claude/` avec le hook de démarrage, `/reprise` et `/passation`, un `NOTES.md`, un
`Makefile` à deux cibles, `sha` et `am`, un `CLAUDE.md` propre au dépôt, un `.gitignore`
qu'il n'avait pas, et `passations/`.

Le dépôt avait 48 commits mais aucune de ces pièces, alors qu'il porte le squelette dont
sortent les autres chantiers.

**Décidé.** La signature est `Claude (CARE)`, comme dans les deux autres dépôts ; l'ancien
`Claude-Code` de deux commits n'est pas repris. Le `CLAUDE.md` insiste sur les deux
particularités du lieu : il est public, et le squelette qu'il contient est recopié dans les
chantiers, non lié, donc une correction ne s'y propage pas d'elle-même.

Commitée aussi, à la demande d'Olivier et sous son nom, sa modification de
`CLAUDE-PERSO.md` du 21 septembre, restée en attente : la liste des macros liées vers
STYLEDIR.

Base : greffe en cours, voir le commit qui suit

## 2026-09-25 23h55 (passation)

**Fait.** Le mode d'emploi de chantier devient une pièce du squelette.
`SQUELETTE/=LISEZ-MOI-SUR-CE-CHANTIER.md` est un gabarit à six trous,
`SCRIPTS/nouveau-chantier.sh` y substitue le nom, le type et la date comme il le fait déjà
pour `CLAUDE.md` et `NOTES.md`, le `CLAUDE.md` du squelette charge Claude de le remplir à
la première session puis de le tenir à jour, et sa `passation.md` vérifie qu'il ne reste
pas de trou en silence.

Éprouvé sur un chantier jetable créé dans un répertoire temporaire : le fichier arrive avec
ses trois substitutions faites et ses six questions en attente.

Les huit dépôts existants ont reçu le leur, écrit un par un : celui d'INF412 a été relu et
validé par Olivier avant les autres.

**Décidé.** Ce fichier s'adresse à Olivier, non à Claude. `CLAUDE.md` garde les règles de
travail, `NOTES.md` le récit ; celui-ci répond à « qu'est-ce que je tape, et qu'est-ce que
je risque ». Ses particularités sont celles qui ont coûté du temps, pas une liste
théorique.

**À faire.** Rien d'ouvert ici. La règle du squelette recopié et non lié vaut toujours :
cette pièce-ci n'arrivera pas d'elle-même dans un chantier ouvert avant aujourd'hui, mais
tous l'ont déjà reçue à la main.

Base : 3fe0df0

## 2026-09-27 19h08 (code, depuis CARE-CHANTIER-STACS2027-PRECISION)

**Fait.** Le finalisé se compile seul et ne parle plus du chantier. `SQUELETTE/Makefile` :
`pdflatex -recorder` ; `make publier` recopie à plat dans DEST ce que la compilation a lu
sous `lib/` (classe, logos, macros, biblio, style bibtex, d'après `.fls` et `.blg`), en
retirant des copies les lignes de commentaire qui parlent de Claude, du chantier ou de
CARE, signale ce qui subsiste dans DEST, et commite sous un message neutre (« Mise à jour
de <dossier> ») ; `make importer` recompile d'abord et laisse ces copies dans DEST.
`SQUELETTE/.publier-exclude` : le `=LISEZ-MOI` (page pour Olivier, qui partait chez les
tiers) et `main-*.pdf`. `SQUELETTE/hooks/pre-push-finalise` refuse aussi « chantier » et
« CARE » (mot entier). Éprouvé dans un répertoire jetable : le finalisé de STACS 2027 se
compile sans `lib/` ni TEXMFHOME, en trois versions.

**Décidé.** Olivier, 27 septembre : rien de ce qui part vers un dépôt partagé avec un
tiers ne doit parler du chantier, de Claude ni de CARE. Le mécanisme est générique (liste
déduite du recorder), pas une liste à tenir par chantier.

**À faire.** Porter ces trois fichiers aux autres chantiers ouverts (INF412, PAGE-WEB,
WORKFLOW-OMNIFOCUS-MAIL-DT-DIR, COURS-POUR-MOI, CV) : seul STACS2027-PRECISION les a reçus.
`\IMPORTANTCARE` dans `STYLEDIR/macros.tex` reste la seule trace de CARE qui parte (nom de
macro et titre par défaut « Important (CARE) ») : à renommer si Olivier le veut.

Base : f237bb4

## 2026-09-27 19h30 (code, depuis CARE-CHANTIER-STACS2027-PRECISION, suite)

**Fait.** `\IMPORTANTCARE` et sa boîte quittent `STYLEDIR/macros.tex` pour
`STYLEDIR/macros-care.tex`, que macros.tex charge s'il est là (lien ajouté dans
~/lib/LaTeX/Perso pour les documents hors chantier). `make publier` assemble l'arbre à
publier dans un répertoire temporaire, sans les fichiers de lib/ dont le nom contient
« care » ni la ligne qui les charge, puis REFUSE sans rien copier s'il y trouve une macro ou
un environnement CARE ou l'un des trois mots, en listant les lignes ; `CONTROLE=0` passe
outre en connaissance de cause. Règle écrite dans SQUELETTE/CLAUDE.md, README-CHANTIERS.md,
CONVENTIONS-LATEX.md et CLAUDE-PERSO.md. Portée à STACS2027-PRECISION et au cours « pour
moi » (Makefile, .publier-exclude, hook, CLAUDE.md) et, sur mesure, à INF412 (crible avant
copie, message « Cours N : mise à jour », hook réinstallé dans kelen).

**Décidé.** Olivier, 27 septembre : la règle vaut pour tout projet dont le publié est un
git. Pas de réécriture des sources à la publication ni d'import en fusion : les sources
publiées ne contiennent simplement pas de macro CARE, et publier refuse sinon.

**À faire.** INF412 : les sources déjà dans kelen portent \IMPORTANTCARE (avec un
\providecommand de repli) et le sigle dans deux .sty ; tant qu'elles ne sont pas nettoyées,
`make publier COURS=N` refuse et il faut CONTROLE=0. Renommer la macro côté INF412 est une
session à part. rechercheCARE reste dans macros-moins-propres.tex, à déplacer dans
macros-care.tex si un document qui le charge doit un jour être publié. PAGE-WEB
(`make pousser` vers le site, pas un git) et le CV n'ont pas de publier : la règle n'y est
pas outillée.

Base : 2451801
