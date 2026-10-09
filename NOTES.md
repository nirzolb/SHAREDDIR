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

## 2026-09-27, plus tard le même soir (code, depuis CARE-CHANTIER-STACS2027-PRECISION)

**Fait.** `STYLEDIR/macros-care.tex` définit aussi `\ARETENIR`, la même boîte sous un nom
neutre, titre par défaut « À retenir » : c'est le nom que prend `\IMPORTANTCARE` dans INF412
(décision d'Olivier), dont les fragments portent un `\providecommand` de repli pour kelen.
Le renommage lui-même est dans le chantier INF412.

Base : 84f1afe

## 2026-09-27, encore plus tard (code, depuis CARE-CHANTIER-STACS2027-PRECISION)

**Fait.** `make publier` n'indexe plus dans DEST que les fichiers qu'il a copiés, plus les
suppressions du miroir : ce qu'une compilation sur place y produit (main.axp, main.idx, que
le .gitignore du dépôt partagé n'écarte pas) n'entre plus dans le commit. Constaté ce soir
après une compilation d'Olivier dans le répertoire publié ; éprouvé sur un dépôt jetable
(artefacts présents, reliquat suivi supprimé par MIRROR=1, republication sans changement).
Reporté à STACS2027-PRECISION et au cours « pour moi ».

Base : 16e7f0c

## 2026-10-05 13h20 (code, SHAREDDIR)

**Fait.** Session étalée sur plusieurs jours, tout est déjà poussé.
`rechercheCARE` dans `STYLEDIR/macros-moins-propres.tex` (bandeau « RECHERCHE (CARE) »,
bleu et jaune, retiré en diffusion finale) : l'équivalent de `recherche`, qui reste à
Olivier ; règle écrite dans `CONVENTIONS-LATEX.md` et `CLAUDE-PERSO.md` (6d7531c).
Page de garde : l'heure n'apparaît qu'en brouillon, pas sous `SAFEMODE` ; `\unskip` des
deux côtés, sinon le corps de `\ifnotmodeDIFFUSIONFINALE` laisse une espace devant la
virgule (dcdbe14). Hors dépôt, sur le Mac : les `.bib` principaux et `myfplain.bst` liés
dans `~/Library/texmf/bibtex`, pour que TeXShop les trouve sans `BIBINPUTS` ; et les cinq
`macros*.tex` de `~/lib/LaTeX/Perso`, qui étaient des copies, remplacés par des liens vers
`STYLEDIR` (anciennes copies dans `~/lib/LaTeX/Perso-copies-avant-liens-20260921`).

**Décidé.** `recherche`, `\IMPORTANT`, `\SURLIGNE`, `\SURSURLIGNE` sont à Olivier ; mes
équivalents sont `rechercheCARE` et `\IMPORTANTCARE`, y compris dans les brouillons du
chat. L'heure de compilation sert à distinguer deux tirages du même jour, elle n'a rien à
faire sur un document publié.

**À faire.** `SQUELETTE/Makefile` a changé le 21 septembre (`make am` tente l'application
directe, puis `--3way`, et laisse l'arbre propre en cas d'échec) : les chantiers ouverts en
ont une copie, la correction ne leur est pas parvenue. À leur porter : INF412,
STACS2027-PRECISION, PAGE-WEB, WORKFLOW-OMNIFOCUS-MAIL-DT-DIR, le cours « pour moi ».
Rien d'autre que je sache : ni `SCRIPTS/`, ni le reste du squelette.

**Questions pour Olivier.** Aucune. `.codex/` et `AGENTS.md`, apparus à la racine, sont à
Codex : Olivier les laisse non suivis, ne pas les committer ni les ignorer.

Base : c887fcc

## 2026-10-05 15h42 (code, SHAREDDIR)

**Fait.** Deux chantiers d'outillage, menés avec Olivier, tout est poussé.
Le registre des chantiers : `SCRIPTS/etat-chantiers.sh` écrit `CHANTIERS.md` et
`CHANTIERS.json` hors de ce dépôt, à partir de git (ouverture, dernière activité et son
auteur, ce qui n'est ni commité ni poussé, branches, postes, finalisé) et de la fiche
`CHANTIER.md` de chaque chantier (parent, résumé, journal ouvert, clos, rouvert). La fiche
est dans le squelette, `nouveau-chantier.sh` y écrit le parent (`--parent`,
`--sans-parent`), et les treize dépôts en ont une. Ne comptent comme activité ni les
commits de fiche, ni ceux portés d'une autre session. La base Notion « Chantiers » en est
la vitrine, recopiée par `/registre`.
Le travail à plusieurs assistants : `qui.sh` (qui a été vu, branches, qui a touché quoi,
avertissement au démarrage), `debut-session.sh`, `nouveau-poste.sh` ; dans le squelette,
les règles passent dans `AGENTS.md`, que `CLAUDE.md` importe, `.codex/` est suivi et Codex
y signe Codex, les hooks des deux assistants sont des relais, `make qui` s'ajoute.
`\signeCARE` signe un bloc `rechercheCARE`. `CLAUDE-PERSO.md` s'adresse aux deux
assistants, et `~/.codex/AGENTS.md` est devenu un lien vers lui.
Deux corrections : `rechercheCARE` est défini dans `macros-care.tex` (dans
`macros-moins-propres.tex`, son bandeau faisait refuser `make publier` à tout document qui
le charge, modèle nu compris) ; `make publier` et le hook pre-push refusent aussi le mot
Codex.
Portages, sur l'ordre d'Olivier, chantiers au repos, une entrée « depuis SHAREDDIR » dans
chaque cahier : la fiche dans les treize dépôts ; le Makefile (`make qui`, mot Codex,
`make am` là où il manquait, soit `essai` et WORKFLOW-OMNIFOCUS-MAIL-DT-DIR) dans neuf ; les
règles communes dans les huit chantiers issus du squelette, `make` vérifié dans chacun, ce
qu'ils avaient de propre repris mot pour mot. Essai d'Olivier avec Codex dans le chantier
pilote : message de démarrage reçu, avertissement vu, commits signés Codex. Le second
répertoire que Codex y occupait est retiré.
Hors dépôt : la signature de Codex corrigée dans ses réglages non suivis, ici compris ; les
fichiers remplacés sont copiés dans `~/00-CHANTIERS-CARE/COPIES-AVANT-AGENTS-COMMUN-20261005`.
`CLAUDE.md` : la liste des chantiers, qui n'en nommait que cinq, renvoie au registre.

**Décidé (Olivier).** Un chantier, un dépôt, un seul répertoire, à tour de rôle ; le
simultané seulement sur son ordre, dans un poste temporaire. `main` s'intègre par lui, ou
sur son ordre. Une seule source de règles par chantier, `AGENTS.md`. `recherche` reste à
lui, `rechercheCARE` est à tous les assistants. Le registre est engendré, Notion n'en est
que la vitrine. SHAREDDIR, le CV et `essai` y figurent. Un seul fichier personnel pour les
deux assistants.

**À faire.** Règles communes non portées : INF412, PAGE-WEB, WORKFLOW-OMNIFOCUS-MAIL-DT-DIR
et le CV, chacun dans une session à lui, et SHAREDDIR lui-même. Pour que les hooks déjà
installés dans les finalisés refusent Codex : relancer `hooks/install.sh` ; un chantier a
gardé un hook plus ancien, non touché. Les sessions ouvertes avant le portage ont encore
l'ancien `CLAUDE.md` en mémoire. Trois chantiers ont leur version à jour hors de `main`.

**Questions pour Olivier.** Le crochet que Codex écrit après `\begin{rechercheCARE}`
s'imprime tel quel : en faire un vrai titre ? À quel rythme recopier le registre dans
Notion : à la demande, à chaque passation, ou chaque matin ? `.codex/` et `AGENTS.md`, à la
racine d'ici, sont encore la copie de Codex, non suivie : convertir SHAREDDIR comme les
chantiers ?

Base : 27fc83d

## 2026-10-05 17h08 (code, SHAREDDIR)

**Fait.** Suite de la session close à 15h42, tout est poussé.
Les portages qui restaient : SHAREDDIR passe aux règles communes (`AGENTS.md` que
`CLAUDE.md` importe, `.codex/` suivi, hooks relais) ; INF412, PAGE-WEB,
WORKFLOW-OMNIFOCUS-MAIL-DT-DIR et le CV aussi, à leur façon, leur texte gardé mot pour mot
sous le nom d'`AGENTS.md`, un bloc « Qui travaille ici » ajouté, leur hook de démarrage
conservé ; `hooks/install.sh` relancé pour les trois répertoires finalisés, dont le hook
installé est maintenant celui du chantier et refuse le mot Codex.
Le crochet de `rechercheCARE` devient un titre, en gras au début du bloc. Le registre se
recopie chaque matin dans Notion, par une tâche planifiée de l'application Claude.
`/registre` donne le texte entier de la description de la base : le connecteur ne permet
pas de la relire, et les premières recopies avaient retrouvé le début du texte en fouillant
d'anciennes conversations.
`SCRIPTS/make_bundle_from_github.sh` est refait. `latex_bundle.zip` emporte les dix styles
(cinq manquaient, dont `macros-accents.tex`, que `macros.tex` exige, et `macros-care.tex`),
les cinq modèles, un README et un exemple ; il se compile à l'essai sans les styles
personnels. Le script travaille dans un répertoire temporaire et redonne le même zip tant
que `STYLEDIR` et `LATEX-EXEMPLES` n'ont pas changé. Ses restes de juillet sont retirés :
`SCRIPTS/READY-TO-COMPILE/`, `SCRIPTS/tmp_repo` (un clone du dépôt, entré dans git comme
dépôt imbriqué) et une copie de `macros-markdown.tex`.
Tour des treize dépôts à 16h40 : rien de modifié sans être commité, tout poussé, règles,
réglages et hooks des deux assistants en place, les dix styles trouvés par TeX dans
`STYLEDIR`.
Hors dépôt : textes donnés à Olivier pour ses préférences de Claude chat et pour les
instructions personnalisées de ChatGPT (adresse de la bibliographie avec `@@`,
`macros-care.tex`, `rechercheCARE` signé `\signeCARE{ChatGPT}`).

**Décidé (Olivier).** Le crochet de `rechercheCARE` est un titre. Le registre se recopie
chaque matin. SHAREDDIR suit les mêmes règles que les chantiers. Les restes du script du zip
sortent du dépôt.

**À faire.** Rien à porter aux chantiers : le squelette n'a pas changé depuis 15h42, et le
script du zip n'est appelé par aucun d'eux. La tâche du matin n'a pas encore tourné avec la
consigne corrigée, et n'a jamais eu à écrire une ligne : l'application demandera sans doute
une autorisation ce jour-là. Les conversations ouvertes dans un chantier avant sa conversion
gardent les anciennes règles : en ouvrir de nouvelles. Codex ne fait encore confiance qu'à
deux chantiers ; ailleurs il le demandera à la première ouverture, et rien ne dit que les
réglages du chantier s'appliquent avant. L'application ChatGPT liste encore le second
répertoire, retiré, d'un chantier. Dans les quatre dépôts particuliers, le texte repris mot
pour mot parle encore à Claude seul : à récrire un jour pour les deux assistants. Trois
chantiers ont toujours leur version à jour hors de `main`.

**Questions pour Olivier.** Écrire dans `AGENTS.md` qu'un changement de style oblige à
refaire le zip ? Le zip doit-il emporter aussi la bibliographie et les logos, que
`expose-minimal.tex` va chercher sur le Mac ?

Base : df532dd

## 2026-10-09 19h40 (code)
**Fait.** Règle nouvelle d'Olivier : tout fichier inclus commence par
`% !TEX root = <document principal>.tex`, pour compiler depuis TeXShop. Écrite dans
CONVENTIONS-LATEX.md. `SCRIPTS/tex-root.py` suit les `\input` et `\include` et pose la
ligne (`--verifier` pour seulement lister). Le Makefile du squelette vérifie à chaque `make`
et offre `make texroot` ; `nouveau-chantier.sh` pose les lignes à l'ouverture (essayé sur un
cours jetable : entete-cours.tex et fin-cours.tex les reçoivent). Portage, Makefile et
lignes, commité et poussé dans Raisonner-Sur-ODEs, COURS-POUR-MOI-PETITES-CLASSES et
STACS2027-PRECISION ; fait dans Odes-et-statistiques, à commiter à sa passation.
Hors dépôt : TeXShop réglé chez Olivier par `defaults write TeXShop BringPdfFrontOnTypeset NO`
(noté au dépannage de README-CHANTIERS.md), sans quoi le PDF passe devant le fichier inclus.

**Décidé (Olivier).** La règle, le script, la cible, et le portage aux chantiers libres.

**À faire.** Porter quand ils seront au repos : Information-Et-Precision (branche
claude/entropie-trajet, deux fichiers non commités), Abstraire-Une-Dynamique (sur la branche
Codex/representations-et-limites), ANR-2026 (un fichier non commité, aucun fichier inclus
à compléter), STOC2027 (branche Codex). Les quatre dépôts particuliers ne sont pas touchés.

**Questions pour Olivier.** Aucune.

Base : 325219a
