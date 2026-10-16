# Fiche de style pour l'anglais (Olivier Bournez)

À lire avant d'écrire, de corriger ou de reprendre un texte anglais d'Olivier : article,
résumé, rapport, lettre, page web. Complète CONVENTIONS-ARTICLES.md, qui fixe le plan d'un
article. Tirée d'une analyse de ses articles depuis 1996 (environ 560 000 mots de prose
anglaise, dont 235 000 lus et annotés) et validée par Olivier sur des tests de réécriture.
[16 octobre 2026]

## 1. La cible

- La voix d'Olivier telle qu'on l'entend dans ses articles, qu'il les ait écrits seul ou
  avec d'autres, avec ses fautes corrigées et ses phrases trop longues coupées.
- Ce qu'un assistant ajoute quand on lui demande de « polir » (verbes savants, connecteurs
  de transition, formules toutes faites, points-virgules, métaphores) efface cette voix.

## 2. Trois façons de travailler

1. **Correction minimale**, par défaut quand Olivier donne son texte : corriger les fautes
   (§5), rien d'autre. Ne toucher ni à l'ordre des idées, ni aux mots, ni aux connecteurs,
   ni à la ponctuation qui n'est pas fautive. Ne pas couper les phrases longues : signaler
   à la fin celles de plus de 40 mots, avec une coupe proposée.
2. **Reprise**, quand il le demande : couper les phrases de plus de 40 mots et réordonner
   dans la phrase ou le paragraphe, en gardant ses mots et ses tournures, comme le ferait
   un relecteur attentif (exemple au §7). Une phrase de discussion qui avance par ajouts
   (« and hence », « and since ») peut rester longue. Dire ensuite, en quelques lignes, ce
   qui a changé au-delà des fautes.
3. **Rédaction**, quand l'assistant écrit à partir de notes ou d'un plan : écrire selon le
   §3, partir des gabarits du §6, sans les fautes du §5 et sans phrase de plus de 40 mots,
   puis vérifier avec le §4.

Dans les trois cas, jamais « polir », « fluidifier », « rendre plus académique ». Dans un
source LaTeX, ne toucher ni aux formules, ni aux `\cite`, `\ref` et `\label`, ni au
découpage des lignes. Si Olivier indique qu'un passage est d'un coauteur, le corriger au
minimum, sans le ramener à cette voix.

## 3. Ce qui fait sa voix

À garder en correction, à produire en rédaction. Sauf mention contraire, les plages vont
du 10e au 90e centile de ses textes de 2012 à 2022, mesurées sur la prose discursive
(résumé, introduction, travaux liés, conclusion). Une tournure vue une ou deux fois dans
ses textes illustre un geste : ne pas la recopier, ou une fois par article au plus.

**Personne et posture**
- « we » est le sujet des résultats, des choix et du plan : we prove, we show, we consider,
  we need, we get, we use. De 11 à 24 pour 1000 mots (médiane 17).
- Ses propres résultats à la première personne : « We proved in 2007 [6] that ... »,
  « We gave in [7,8] a characterization of ... ». Jamais « Bournez et al. [6] showed ».
- Les résultats s'énoncent sans atténuation, comme des caractérisations exactes :
  « precisely the languages of ... », « a full characterization », « if and only if ».
  L'atténuation va au commentaire : « in some sense », « roughly », « quite »,
  « basically ». Une affirmation large se nuance simplement : « a kind of universal
  language ».
- Une réserve se dit à la première personne ou en note : « We believe that ... », « we do
  not claim that the models we consider have any physical reality ». Pas par une tournure
  impersonnelle (« it appears that », « it is worth »).
- Des aveux francs : « This classification is not perfect, and it is debatable. », « but
  this says nothing! », « We do not intend here to be exhaustive ».
- Le passif qui énonce un fait ou un résultat est à lui (« It is shown in [2] that ... »,
  « can be recognized by ... ») : environ une phrase sur trois. Ne pas le tourner à
  l'actif par principe.
- « one can » pour les généralités (près de 1 pour 1000 mots). « some » comme indéfini
  devant un pluriel ou un indénombrable (« some PCD systems »), autour de 5 pour 1000
  mots ; ne pas le changer en « certain ».
- Un peu d'humour dans les apartés et les notes (« a zoology of possible behaviors »,
  « a chicken-and-egg problem ») : garder celui qui est là, ne pas en fabriquer.

**Phrases et ponctuation**
- Phrases courtes et moyennes : 17 à 24 mots en moyenne, et une sur six fait moins de
  10 mots. Les phrases de plus de 40 mots sont rares dans ses textes de 2012 à 2022 (4,6 %
  en médiane), plus fréquentes dans ceux qu'il a écrits seul (7 %) : ce sont elles que la
  cible coupe (§2).
- Le deux-points est la charnière : une affirmation, puis son contenu, sa raison, une liste
  ou un renvoi, en minuscule après. De 3 à 11 pour 1000 mots, deux fois plus quand il écrit
  seul. « The bound is sharp: Figure 3 gives an example of ... » ; « five dimensions are
  used in [2] to climb each level of the arithmetical hierarchy: one for a timer, one used
  for the divisions by 2, ... ». Ne pas remplacer un deux-points par un point-virgule, par
  « namely » ou par un point.
- Les parenthèses pour les précisions courtes, de 6 à 20 pour 1000 mots : « a different
  (and somewhat easier for our purposes) problem ».
- Pas de tiret cadratin (presque aucun dans ses textes). Presque pas de point-virgule en
  prose (médiane 0,5 pour 1000 mots) ; il reste possible dans une énumération de
  définitions.
- « i.e. » et « e.g. » sans virgule après (quatre fois sur cinq chez lui) ; « see e.g.
  [8, 22] ». Pas de virgule de série : « Asarin, Maler and Pnueli ».
- Orthographe américaine (characterization, analog, modeling, program), sauf dans un
  article coécrit déjà en orthographe britannique : une seule orthographe par document.
  Pas de contractions.

**Guider le lecteur**
- Reformuler juste après un énoncé : « In other words, ... » (dans deux de ses textes sur
  trois), « that is to say », « This means that », « If one prefers, ».
- L'idée avant les détails : « the idea is to build more and more powerful machines that
  ... », « The proof is rather technical: ... », « Intuitively, ».
- Annonces plates, presque orales : « We are ready to define ... », « Let us consider ... »,
  « We now come back to PCD systems. », « It remains to show that ... ».
- Remarques techniques en « Note that », « Observe that », « Notice that », souvent entre
  parenthèses : autour de 1 pour 1000 mots.
- Connecteurs courts en tête de phrase. Pour 100 phrases : However environ 2, In
  particular 1,8, puis Notice, Indeed, Then et Furthermore autour de 1, et Thus, Note, But,
  Finally, In other words, Moreover, Of course, Hence, Actually (au sens d'« en fait », pour
  corriger ou préciser la phrase d'avant) entre 0,2 et 0,7. Moreover et Furthermore sont à
  lui : les garder en correction, n'en ajouter aucun dans un texte d'Olivier, et pas plus
  d'un par paragraphe en rédaction.

**Organiser**
- Motiver par l'histoire du problème, avec des noms et des dates : qui a introduit quel
  modèle, ce qui restait ouvert, ce qu'on améliore. « In 1941, Claude Shannon introduced the
  General Purpose Analog Computer (GPAC) as a model for the Differential Analyzer [N], on
  which he worked as an operator. » Pas de motivation par une tendance générale.
- Ouvrir un résumé ou une introduction sur l'objet ou sur un fait, pas sur une thèse
  générale : « We study the computational power of ... », « Reachability for piecewise
  affine systems is known to be undecidable, starting from dimension 2. », « It has been
  understood quite recently that it is possible to program with Ordinary Differential
  Equations (ODEs). ».
- Le résumé suit le plan en quatre phrases de CONVENTIONS-ARTICLES.md. Les siens faisaient
  80 à 105 mots jusqu'en 2016, autour de 200 ensuite.
- Situer par des renvois : « see e.g. [8, 22] » (dans près d'un texte sur deux), « we
  refer to [6] for a survey ». Ne discuter que les travaux qui servent : ce qu'ils font, ce
  qu'on améliore. Rapporter les travaux des autres au présent : « In [14], Moore proposes
  ... ».
- Décrire la contribution par ce qu'elle prouve et ce qu'elle permet, et dire ses limites.
- Plan de l'article en une phrase par section, avec « we » pour sujet : « In Section 5, we
  prove that ... ». Pas de section sujet d'un verbe imagé (« Section 3 explores ... »).
- Finir un paragraphe sur le résultat, une conséquence ou un renvoi.
- Conclure sur ce qui est prouvé (« We proved that ... »), puis donner les questions
  ouvertes sous forme déclarative : « The question whether ... remains open. », « It would
  be interesting to know whether ... ».
- Quelques notes de bas de page courtes, parfois sans verbe, comme une seconde voix.
  Beaucoup de ses textes n'en ont pas : ne pas en ajouter pour en avoir.
- Un angle qui revient d'article en article : le calcul comme programmation d'un système
  dynamique (« ODE programming »). Quand un article a un slogan, c'est celui d'Olivier : le
  reprendre tel quel du titre à la conclusion. Ne pas en inventer.

**Mots**
- Verbes simples : show, get, use, give, go on, talk about. Ne pas les remplacer par
  establish, yield ou leverage.
- Répéter le terme technique plutôt que varier par un synonyme ou un pronom : la
  répétition est voulue.
- Garder les termes du domaine tels quels, sans paraphrase.
- Évaluations simples : nice, natural, very interesting, instructive ; « very » autour de
  1 pour 1000 mots. Pas d'intensifs comme striking, compelling, profound, remarkable.

## 4. Ce qu'il ne faut pas écrire

Étranger à sa voix et typique d'un assistant.

- Une question rhétorique pour ouvrir ou motiver un texte. Une question ouverte s'énonce
  sous forme déclarative (§3).
- Un contraste fabriqué pour donner du relief : « not merely X but Y », « X rather than a
  mere Y », « It is not X: it is Y. ». Un contraste qui énonce un fait est à lui : « Here
  automata are not considered as language recognizers, but as computing operators on
  signals. »
- Un point-virgule qui balance deux propositions ; un triplet bien rythmé (« X is fast, Y is
  robust, and Z is both ») ; une liste de noms abstraits en sujet de phrase.
- Une métaphore filée d'un paragraphe à l'autre, par exemple le domaine décrit comme un
  paysage ou une carte. Les mots map, slice, picture ont chez lui un sens technique ou
  littéral (« piecewise affine maps », « We then get the following picture: » devant un
  tableau) : seul l'usage figuré est exclu.
- Les mots d'assistant, absents ou presque de ses textes : delve, tapestry, « a testament
  to », harness, multifaceted, holistic, nuanced, showcase, underscore, pivotal, seamless,
  genuinely, « through the lens of », « sheds light on », « paves the way », « still in its
  infancy », « it is worth noting », « in the realm of ».
- Les paragraphes-catalogues, une phrase par groupe d'auteurs ; ses propres travaux à la
  troisième personne.
- Une ouverture sur une thèse générale (« Computation is everywhere in nature. »), une fin de
  paragraphe sur une maxime (« Precision, in the end, is the true currency of
  computation. »), une portée gonflée (« groundbreaking », « a paradigm shift »), une
  conclusion qui récapitule toute la structure de l'article.
- Specifically, Additionally, Notably en tête de phrase pour lier des phrases qui se
  suivent déjà.
- Le tiret cadratin, la virgule de série, l'orthographe britannique hors du cas du §3.

## 5. Corriger : ses fautes récurrentes

Les fautes les plus fréquentes portent sur les articles, les prépositions, les accords et
la place de l'adverbe. Elles viennent du français et ne bloquent presque jamais le sens. Un
paragraphe sans faute se rend tel quel.

| Il écrit | Corriger en |
|---|---|
| allows to compute, permits to know | allows one to compute, makes it possible to know |
| requires to encode, suggests to introduce | requires encoding, suggests introducing |
| it exists a ... | there exists a ... |
| closed by composition, stable by, invariant by | closed under composition, stable under, invariant under |
| is said computable | is said to be computable, is called computable |
| this is clear that, this is possible to | it is clear that, it is possible to |
| X has shown to be | X has been shown to be, X has proved to be |
| in literature, in next section, Church thesis | in the literature, in the next section, the Church-Turing thesis |
| a same segment | the same segment |
| we define inductively the set, compute directly the limit | we inductively define the set, directly compute the limit |
| There has been recently an increasing interest in | Recently, there has been increasing interest in |
| since 30 years, since the last thirty years | for 30 years, over the last thirty years |
| are concerning | concern |
| in term of, in function of | in terms of, depending on (as a function of) |
| the considered models | the models considered, the models under consideration |
| is considered as possible | is considered possible |
| some digression | a digression |
| somehow (pour « en quelque sorte ») | in some sense, somewhat, to some extent |
| up to our knowledge | to our knowledge, to the best of our knowledge |
| by other words | in other words |
| see for e.g. | see e.g. |
| by lack of space | for lack of space |
| we remind that | we recall that |
| did not succeed to do | did not succeed in doing |
| devoted to prove | devoted to proving |
| either ..., either ... | either ... or ... |
| unicity, derivable function, a compact | uniqueness, differentiable function, a compact set |
| the dynamic (d'un système) | the dynamics |
| asymptotic development | asymptotic expansion |
| informations, softwares | information, software |
| tentatives, physic, leaded, argumented | attempts, physics, led, argued |
| independant, developped, refering, explicitely | independent, developed, referring, explicitly |
| etc... | etc. |

À lire en contexte, sans corriger d'office :
- « as soon as » au sens logique de « dès que » : souvent « whenever », « once » ou
  « provided that ».
- « Indeed » pour « en effet » qui annonce une justification : le supprimer, ou dire le lien
  (« This is because ... », « since ... »). Quand il confirme ce qui précède, le garder.
- « even if » pour « même si » quand le fait est acquis : « even though ».
- « eventually » : juste au sens de « au bout du compte » ; faux pour « éventuellement »
  (« possibly ») et pour « enfin » dans un plan (« Finally, in Section 5, we show »).
- « actually » : juste au sens d'« en fait » ; faux pour « actuellement » (« currently »).
- « considered as » : juste au sens de « vu comme » (« PCD systems considered as
  machines ») ; « considered » seul au sens de « jugé ».
- Le « do » d'insistance (« do correspond to ») : le garder s'il répond à un doute, sinon
  l'enlever.
- « If it is so » : « If so, » est plus courant.

À ne pas corriger, c'est du bon anglais et c'est sa voix : « Actually, » qui corrige ou
précise la phrase d'avant, « In other words », « that is to say », « the idea is »,
« Of course », « Basically, », « As one can see », « Let us », « Unfortunately, »,
« Hence », « some » devant un pluriel.

## 6. Gabarits

Tirés de ses textes, fautes corrigées. Les lettres et [N] sont à remplir.

- Ouvrir : « We study the computational power of X. » ; « In this paper, we characterize
  X. » ; « In [year], A introduced X as a model for Y. » ; « According to the Church-Turing
  thesis, all reasonable models of X are equivalent to Y. No similar result is known for
  Z. » ; « This paper studies problems such as the following: given X, decide whether Y. »
- Annoncer : « We prove that X are precisely the Y. Hence we provide a precise
  characterization of Z, and we solve a problem left open by [N]. » ; « The purpose of this
  paper is to provide a positive answer to X. » ; « Quite surprisingly, although X is a
  well-known open problem, we prove that all variants are actually equivalent. »
- Se situer : « In [N], A proposes X. Recently, B and C [N] showed, using Y, that Z. » ;
  « This extends to X a result of [N] proved for Y. » ; « Other authors have also obtained
  very interesting results on this topic but, for reasons of space, we cannot give a
  thorough survey: see e.g. [N]. »
- Expliquer : « The idea is to X. » ; « In other words, X is equivalent to Y. » ; « The
  proof is rather technical: X. » ; « We have two things to prove. First we need to show
  that X. Second we need to show that Y. » ; « While this result looks very surprising at
  first sight, the proof turns out to use basic arguments and can be explained as
  follows. »
- Prendre position : « We believe that this limitation is due to the notion of X rather
  than to the model itself. » ; « We do not claim that X. » ; « This classification is not
  perfect, and it is debatable. »
- Conclure : « We proved that X, extending several results of [N]. » ; « The question
  whether X remains open. » ; « It would be interesting to know what happens at a more
  refined level, i.e. from a complexity point of view. » ; « It is a first step towards
  X. »

## 7. Deux exemples

**Correction minimale contre polissage** (1998, écrit seul).

Original. The study of machines working on a continuous space with a continuous time is
only beginning. In [14], Moore proposes a recursion theory for computations on the reals in
continuous time. When PCD systems are considered as machines working on continuous space
with a continuous time no precise characterization of their computational power was known:
recently, Asarin and Maler [3] showed using Zeno's paradox, that every set of the
arithmetical hierarchy can be recognized by a PCD system of finite dimension. We gave in
[7,8] a characterization of the computational power of a restricted class of PCD systems:
the purely rational PCD systems. But no characterization was given for the general class of
PCD systems.

Correction minimale, la cible. The study of machines working on a continuous space with
continuous time is only beginning. In [14], Moore proposes a recursion theory for
computations on the reals in continuous time. When PCD systems are considered as machines
working on continuous space with continuous time, no precise characterization of their
computational power was known: recently, Asarin and Maler [3] showed, using Zeno's paradox,
that every set of the arithmetical hierarchy can be recognized by a PCD system of finite
dimension. We gave in [7,8] a characterization of the computational power of a restricted
class of PCD systems: the purely rational PCD systems. But no characterization was given for
the general class of PCD systems.

Polissage, à ne pas faire. The study of machines operating on a continuous space in
continuous time is still in its infancy. In [14], Moore proposed a recursion theory for
computations over the reals in continuous time. When PCD systems are viewed as machines
operating on a continuous space in continuous time, no precise characterization of their
computational power was previously known. Asarin and Maler [3] recently showed, using Zeno's
paradox, that every set of the arithmetical hierarchy can be recognized by a
finite-dimensional PCD system. In [7,8], we characterized the computational power of a
restricted class of PCD systems, namely purely rational PCD systems. However, no
characterization has been given for the general class of PCD systems.

La correction minimale supprime deux fois l'article de « with a continuous time » et ajoute
deux virgules. Le polissage remplace « working » par « operating », « is only beginning »
par « is still in its infancy », « considered as » par « viewed as », « But » par
« However » ; il met « Moore proposes » au passé, défait les deux deux-points et change
« We gave in [7,8] a characterization » en « In [7,8], we characterized ». Aucun de ces
changements ne corrige une faute.

**Couper une phrase trop longue en gardant la voix** (2020, écrit seul, 108 mots).

Original. We proved in 2007 [6] that this statement about the limitation of the
computational power of the GPAC model comes mainly from a misconception of what was called
computable at the time of Shannon with respect to what would be called such today: If the
input is given as some initial data, and if we allow the machine not to produce its output
in real-time, but after some delay (i.e. after some computation time (encoded by the delay
required for $y_{j}$ to be less than required precision in Theorem 9 which follows)), as in
all modern models of computations, then the model can compute any function that is
classically (Turing) computable.

Reprise. We proved in 2007 [6] that this statement about the limitation of the GPAC comes
mainly from a misconception: what was called computable at the time of Shannon is not what
would be called computable today. Assume that the input is given as some initial data, and
that the machine may produce its output not in real time but after some delay, as in all
modern models of computation. This delay is the computation time (i.e. the time needed for
$y_{j}$ to reach the required precision, see Theorem 9 below). Then the GPAC can compute any
function that is classically (Turing) computable.

La phrase devient quatre phrases. Les idées restent, et presque tous les mots : « Assume
that » et « This delay is » ouvrent les nouvelles phrases. Le deux-points, « we » et
« i.e. » restent. Aucun connecteur ni mot savant n'est ajouté.

## 8. Vérifier avant de rendre

1. Le mode est-il le bon (§2) ?
2. Corriger les articles, les prépositions, les accords et la place de l'adverbe, puis les
   fautes du §5.
3. Traiter les phrases de plus de 40 mots selon le mode : signalées en correction minimale,
   coupées en reprise et en rédaction.
4. Chercher les points-virgules, les points d'interrogation, les tirets cadratins,
   « rather than », « not just », « not merely », et les mots du §4 pris au figuré.
5. Sur quelques centaines de mots au moins, regarder les repères : moins de 10 « we » pour
   1000 mots, plus de 1,2 point-virgule pour 1000 mots, aucune phrase de moins de 10 mots,
   presque aucun deux-points ni aucune parenthèse, aucun « In other words » ni « Note
   that ». Ce sont des signes qu'un texte a glissé vers la voix d'un assistant.
6. En chantier, `python3 lib/SHAREDDIR/SCRIPTS/style-anglais.py DOC.tex` (ou un .md, un
   .txt) fait les étapes 3 à 5 : mesures contre la plage habituelle de ses textes,
   tournures d'assistant, fautes et calques connus, phrases de plus de 40 mots.
   `--profil solo` compare aux textes qu'il a écrits seul. Les mesures signalent des
   passages à relire ; un très bon texte d'Olivier peut sortir de la plage.

## 9. D'où viennent ces règles

- 109 textes depuis 1996, convertis depuis les PDF publiés. Une phrase reprise d'une version
  à l'autre n'est comptée qu'une fois.
- Environ 235 000 mots lus et annotés (fautes, tournures) ; 28 paragraphes repris en
  correction minimale et en polissage ; des tests de réécriture jugés par Olivier.
- Les données, les extraits et les scripts d'analyse sont gardés à part, hors de ce dépôt
  public.
