#!/usr/bin/env python3
"""Compare un brouillon en anglais au style mesuré d'Olivier Bournez (fiche STYLE-ANGLAIS.md).

Usage, depuis le répertoire du chantier :
  python3 lib/SHAREDDIR/SCRIPTS/style-anglais.py DOC.tex                  face à ses textes de 2012 à 2022
  python3 lib/SHAREDDIR/SCRIPTS/style-anglais.py --profil solo DOC.tex     face à ses textes écrits seul
  python3 lib/SHAREDDIR/SCRIPTS/style-anglais.py --mots LISTE.txt DOC.tex  cherche aussi les tournures de LISTE
  python3 lib/SHAREDDIR/SCRIPTS/style-anglais.py --phrases DOC.tex         phrases extraites, pour contrôle

DOC est un .tex (les \\input et \\include sont suivis), un .md ou un .txt (paragraphes séparés par
une ligne vide, titres en #). LISTE : une expression régulière par ligne, sans casse ; lignes vides
et lignes en # ignorées ; \\b est ajouté devant une entrée qui commence par une lettre et derrière
une entrée qui finit par une lettre. Le rapport, en Markdown sur la sortie standard, donne :
  1. les mesures du brouillon face à la plage habituelle (10e à 90e centile, par texte, de la
     prose discursive d'Olivier), avec la médiane et un statut ;
  2. les tournures d'assistant du §4 de la fiche, et celles de LISTE, marquées (liste perso) ;
  3. les fautes et calques venus du français, avec la correction suggérée ;
  4. les phrases de plus de 40 mots, à couper.
Énoncés, preuves et légendes sont techniques, comme les phrases chargées en maths (15 % des
jetons dans l'abstract, l'introduction, les travaux liés et la conclusion, 5 % ailleurs). Les
mesures portent sur les phrases discursives s'il y en a au moins 20, sinon sur toutes ; il faut
quelques centaines de mots pour qu'elles veuillent dire quelque chose. Définitions de l'outil
d'analyse du corpus (check_style.py, hors de ce dépôt), sans ses mesures syntaxiques.
Python 3.8 ou plus, bibliothèque standard seule. Code de sortie 0, ou 1 si l'appel est mal formé.
"""
import os
import re
import statistics
import sys
import unicodedata

# ------------------------------------------------------------------ mesures et plages de référence
# Plages par texte (10e, 50e, 90e centile de la prose discursive) tirées de l'analyse du corpus
# (octobre 2026) : 31 textes de 2012 à 2022 (défaut), 8 textes écrits seul (--profil solo).
# Colonnes : nom affiché | nom d'origine (style_metrics.py) | calcul et motif | 2012-2022 | seul.
# La liste forte est llm_strong de patterns.py moins un mot (voir LLM_FORT) ; sa plage
# 2012-2022 a été recalculée avec cette définition. Corpus nettoyé corrigé le 16 octobre 2026.
MESURES = [ligne.split(" | ") for ligne in """\
longueur moyenne des phrases (mots) | sentence length (mean words) | moy \
| 17.429 18.982 24.444 | 17.729 18.702 23.85
longueur médiane des phrases (mots) | sentence length (median) | med | 15 18 22 | 14.7 16.5 22
phrases de plus de 40 mots (%) | sentences > 40 words (%) | >40 | 2.381 4.598 11.236 | 4.199 7.397 12.179
phrases de moins de 10 mots (%) | sentences < 10 words (%) | <10 | 10.857 16.418 26.23 | 13.476 23.228 26.046
virgules par phrase | commas per sentence | /phrase virgule | 0.736 0.936 1.366 | 0.515 0.976 1.378
points-virgules /1000 mots | semicolons /1000w | /1000 semicolon | 0 0.524 1.19 | 0 0 0.967
deux-points /1000 mots | colons /1000w | /1000 colon | 3.39 6.592 11.123 | 10.132 15.245 23.856
parenthèses /1000 mots | parentheses /1000w | /1000 paren_open | 5.616 11.446 19.661 | 5.508 9.741 14.671
tirets cadratins /1000 mots | em dashes /1000w | /1000 em_dash | 0 0 0 | 0 0 0
we /1000 mots | we /1000w | /1000 we | 10.612 16.727 23.635 | 9.68 14.384 30.196
our, us /1000 mots | our/us /1000w | /1000 our | 1.19 2.62 6.283 | 0 1.617 3.274
one can, one may /1000 mots | one can/may /1000w | /1000 one_can | 0 0.794 1.561 | 1.006 1.522 3.596
Indeed en tête /100 phrases | Indeed (initial) /100 sent | /100ph init_indeed | 0 0.917 2.752 | 0 0 1.202
Actually en tête /100 phrases | Actually (initial) /100 sent | /100ph init_actually | 0 0 0.694 | 0 0.797 3.702
Moreover, Furthermore en tête /100 phrases | Moreover+Furthermore (initial) /100 sent | /100ph init_moreover  \
| 0 0.893 3.371 | 0 0 1.202
Hence, Thus, Therefore en tête /100 phrases | Hence+Thus+Therefore (initial) /100 sent | /100ph init_hence  \
| 0 0.571 2.74 | 0 0.829 5.034
However en tête /100 phrases | However (initial) /100 sent | /100ph init_however | 0 1.852 4.545 | 0.53 2.553 3.702
Note, Notice, Observe, Remark that /1000 mots | Note/Notice/Observe/Remark that /1000w | /1000 note_that  \
| 0 0.984 2.096 | 0 0.444 2.492
in order to /1000 mots | in order to /1000w | /1000 in_order_to | 0 0.305 1.45 | 0 0 0.626
we will, we shall /1000 mots | we will/shall /1000w | /1000 we_will | 0.295 1.112 3.457 | 0.276 0.881 2.357
atténuateurs (hedges) /1000 mots | hedges /1000w | /1000 hedge | 1.72 4.449 7.069 | 1.157 4.592 6.981
intensifs (boosters) /1000 mots | boosters /1000w | /1000 booster | 1.455 3.121 6.15 | 0.797 3.253 4.581
very /1000 mots | very /1000w | /1000 very | 0 1.112 2.442 | 0.622 1.045 2.022
fautes de type français /1000 mots | French-type errors /1000w | /1000 fr_err | 0 0.536 1.933 | 0 0.87 2.6
calques du français /1000 mots | French-type calques /1000w | /1000 fr_calque | 0 0 1.041 | 0 0.481 1.838
mots de LLM, liste forte /1000 mots | LLM style words (strong list) /1000w | /1000 llm_strong  \
| 0 0.483 1.356 | 0 0 0.114
orthographe britannique (% des variantes) | UK spelling share (%) | uk | 0 0 14.286 | 0 0 0""".splitlines()]
PROFILS = {"2012-2022": (3, "les 31 textes d'Olivier de 2012 à 2022"),
           "solo": (4, "les 8 textes qu'Olivier a écrits seul, de 1997 à 2022")}

# Motifs des mesures, repris de patterns.py (les init_* sont sensibles à la casse).
STEMS = ("character|real|general|formal|normal|organ|recogn|emphas|minim|maxim|optim|discret|parameter|"
         "parametr|summar|util|special|initial|stabil|local|linear|symbol|visual|hypothes|synthes|standard|"
         "central|regular|categor|author|prior|rational|modular|vector|digit|serial|random|polar|familiar|"
         "capital|global|memor|apolog|critic|axiomat|arithmet|algebra|polynomial|real|modern|minimal|maximal|"
         "homogen|synchron|monet|theor")
LLM_FORT = ["delv(e|es|ed|ing)", "intricate", "intricacies", "pivotal", "showcas(e|es|ed|ing)",
            "underscor(e|es|ed|ing)", "notably", "noteworthy", "meticulous(ly)?", "commendable", "invaluable",
            "paramount", "groundbreaking", "unprecedented", "unveil(s|ed|ing)?", "embark(s|ed|ing)?",
            "endeavou?rs?", "navigat(e|es|ed|ing)", "interplay", "testament", "realms?", "tapestry",
            "foster(s|ed|ing)?", "harness(es|ed|ing)?", "nuanced", "multifaceted", "seamless(ly)?",
            "streamlin(e|es|ed|ing)", "bolster(s|ed|ing)?", "garner(s|ed|ing)?", "underpin(s|ned|ning)?",
            "elucidat(e|es|ed|ing)", "resonat(e|es|ed|ing)", "leverag(e|es|ed|ing)", "vibrant", "holistic",
            "cutting-edge", "unlock(s|ed|ing)?", "elevat(e|es|ed|ing)", "crucial(ly)?", "comprehensive(ly)?",
            "insights?", "insightful", "shed(s|ding)? light", "pav(e|es|ed|ing) the way", "key role",
            "crucial role", "pivotal role", "vital role", "in essence"]
MOTIFS = {k: re.compile(v, re.I) for k, v in [
    ("virgule", r","), ("semicolon", r";"), ("colon", r":"), ("paren_open", r"\("), ("em_dash", r"\u2014"),
    ("we", r"\bwe\b"), ("our", r"\b(our|ours|us)\b"), ("very", r"\bvery\b"), ("in_order_to", r"\bin order to\b"),
    ("one_can", r"\bone (can|may|could|should|has to|needs to|must|gets|obtains|sees)\b"),
    ("we_will", r"\bwe (will|shall)\b"), ("init_indeed", r"(?-i:^Indeed\b)"),
    ("init_actually", r"(?-i:^Actually\b)"), ("init_however", r"(?-i:^However\b)"),
    ("init_moreover", r"(?-i:^(Moreover|Furthermore)\b)"), ("init_hence", r"(?-i:^(Hence|Thus|Therefore)\b)"),
    ("note_that", r"\bnote that\b|\bnotice that\b|\bobserve that\b|\b(remark|remarks|remarked) that\b"),
    ("hedge", r"\b(seems?|seemed|appears? to|might|may|could|possibly|probably|likely|somehow|rather|quite|"
              r"in some sense|to some extent|roughly|kind of|sort of|arguably|presumably|in some way|a priori|"
              r"we believe|we think|perhaps|maybe)\b"),
    ("booster", r"\b(clearly|obviously|of course|certainly|definitely|surely|very|really|strongly|totally|"
                r"completely|fully|deeply|highly|extremely|easily|trivially|immediately|straightforward(ly)?|"
                r"indeed)\b"),
    ("llm_strong", r"\b(%s)\b" % "|".join(LLM_FORT)),
    ("uk", r"\b(%s)is(e|es|ed|ing|ation|ations|er|ers|able)\b|\banalys(e|es|ed|ing|er)\b|\b(behaviour|colour|"
           r"neighbour|favour|honour|labour|flavour|vapour)(s|hood|hoods|al|ed|ing|able)?\b|\b(centre|centres|"
           r"fibre|fibres|metre|metres)\b|\b(modell(ed|ing|er|ers)|labell(ed|ing)|travell(ed|ing)|"
           r"cancell(ed|ing)|signall(ed|ing)|levell(ed|ing)|tunnell(ed|ing)|channell(ed|ing))\b|\banalogue\b"
           % STEMS),
    ("us", r"\b(%s)iz(e|es|ed|ing|ation|ations|er|ers|able)\b|\banalyz(e|es|ed|ing|er)\b|\b(behavior|color|"
           r"neighbor|favor|honor|labor|flavor|vapor)(s|hood|hoods|al|ed|ing|able)?\b|\b(center|centers|fiber|"
           r"fibers|meter|meters)\b|\b(model(ed|ing|er|ers)|label(ed|ing)|travel(ed|ing)|cancel(ed|ing)|"
           r"signal(ed|ing)|level(ed|ing)|tunnel(ed|ing)|channel(ed|ing))\b|\banalog\b" % STEMS)]}

# ------------------------------------------------------------------ fautes et calques
# Repris de patterns.py (fr_calque, fr_spelling, typography ; gravité e = error, c = calque) :
# (identifiant, gravité, motif, correction suggérée). NEG : contexte qui annule la prise quand il
# termine les 25 caractères précédents.
NEG = {"allow_to_inf": r"\b(is|are|was|were|be|been|being|not|only|is only|are only|is not|are not|also|still|"
                       r"then|now)", "require_to_inf": r"\b(is|are|was|were|be|been|being|not)"}
FAUTES = [
    ("allow_to_inf", "e", r"\b(allow|allows|allowed|allowing|permit|permits|permitted|permitting|enable|enables|"
                          r"enabled|enabling)\s+to\s+[a-z]+",
     "verbe sans complément → allows one to compute, makes it possible to"),
    ("it_exists", "e", r"\bit exists?\s+(a|an|some|two|one|no|⟨m⟩|several|infinitely|at least|such|a unique|"
                       r"unique|finitely|only)\b", "il existe → there exists"),
    ("it_does_not_exist", "e", r"\bit does not exist\s+(a|an|any|some|⟨m⟩)\b", "il n'existe pas → there is no"),
    ("remind_that", "e", r"\bremind that\b|\b(let us|we) remind\b(?!\s+(the|our|you|him|her|them)\b)",
     "rappelons → recall"),
    ("precise_verb", "e", r"\b(let us precise|we precise|to precise|precised|precising|precise (that|how|what|"
                          r"which|it))\b", "préciser → specify, make precise"),
    ("is_said_adj", "c", r"\b(is|are|be) said (?!to\b|that\b|before\b|above\b|earlier\b)([a-z]+(able|al|ic|ive|"
                         r"ent|ant|ed|ous|ar|ary)\b|of (class|type|degree|order|rank|dimension)\b)",
     "est dit X → is said to be X, is called X"),
    ("important_quantity", "c", r"\b(an? )?important (number|amount|quantity|proportion|size|growth|part)\b",
     "important → large, significant"),
    ("in_function_of", "e", r"\bin function of\b", "en fonction de → as a function of, depending on"),
    ("tentative_noun", "e", r"\b(a|the|several|some|many|first|these|those|our|any|previous)\s+tentatives?\b|"
                            r"\btentatives?\s+(of|to)\b", "tentative → attempt"),
    ("derivable", "c", r"\bderivab(le|ility)\b(?!\s+(from|in (the|a|this|that) (system|theory|calculus|logic)))",
     "dérivable → differentiable"),
    ("punctual", "e", r"\bpunctual(ly)?\b", "ponctuel → pointwise"),
    ("majorate", "e", r"\b(majorat\w*|minorat\w*|majored|minored|majorize\w*|minorize\w*)\b",
     "majorer → bound from above"),
    ("a_same", "e", r"\ba same\b", "un même → the same"),
    ("same_than", "e", r"\bsame (\w+ ){0,2}than\b", "→ the same as"),
    ("different_of", "e", r"\bdifferent of\b", "→ different from"),
    ("depend_of", "e", r"\bdepend(s|ing|ed)? of\b", "→ depend on"),
    ("participate_to", "e", r"\bparticipat(e|es|ed|ing) to\b", "→ participate in"),
    ("interested_by", "e", r"\binterested by\b", "→ interested in"),
    ("contrarily_to", "e", r"\bcontrarily to\b|\bat the contrary\b", "→ unlike, contrary to ; on the contrary"),
    ("in_a_first_time", "e", r"\bin a (first|second|third) (time|step|phase|stage)\b",
     "dans un premier temps → first"),
    ("up_to_our_knowledge", "e", r"\bup to (our|my) knowledge\b", "→ to our knowledge"),
    ("in_literature", "e", r"\b(in|from|of|by) literature\b", "article manquant : in the literature"),
    ("see_for_eg", "e", r"\bsee for e\.?g\b|\bfor e\.g\b", "see for e.g. → see e.g."),
    ("uncountable_plural", "e", r"\b(informations|softwares|knowledges|evidences|advices|feedbacks|equipments)\b",
     "nom indénombrable : information, software"),
    ("a_research", "e", r"\ba research\b(?! (group|team|project|program|programme|direction|area|topic|question|"
                        r"line|field|agenda|interest|institute|center|centre|paper|article|effort|community|"
                        r"domain|axis|theme|grant|unit))", "une recherche → a study, research"),
    ("leaded", "e", r"\bleaded\b", "→ led"),
    ("argumented", "e", r"\bargumented\b", "→ argued"),
    ("physic_noun", "e", r"\b(the|of|in) physic\b(?!s)", "→ physics"),
    ("since_duration", "e", r"\bsince (several|many|a few|some|\d+|two|three|ten|twenty|thirty|forty|fifty) "
                            r"(years|decades|months)\b", "depuis plusieurs années → for several years"),
    ("during_years", "c", r"\bduring (several|many|\d+|two|three|ten|twenty) (years|decades)\b", "pendant → for"),
    ("the_X_theory", "c", r"\bthe (complexity|computability|recursion|graph|automata|game|probability|category|"
                          r"measure|number|proof|set|control|information|computation|recursive function) theory\b",
     "sans article : complexity theory"),
    ("modelization", "e", r"\bmodeli[sz]ations?\b", "→ modelling"),
    ("apparition", "e", r"\bapparitions?\b", "→ appearance, emergence"),
    ("of_do", "e", r"\b(able|capable) (of|to) (do|doing) (hyper|super)\b", ""),
    ("to_resume", "e", r"\b(to|let us|we) resume\b(?! (the|our|this|from|work|where))", "résumer → summarize"),
    ("closed_by", "e", r"\b(closed|stable|invariant)\s+by\b", "clos par → closed under, invariant under"),
    ("this_is_adj_that", "e", r"\b[Tt]his is (not )?(possible|clear|easy|natural|important|necessary|interesting|"
                              r"difficult|hard|obvious|immediate|true|known|well known) that\b",
     "c'est clair que → it is clear that"),
    ("unicity", "e", r"\bunicity\b", "→ uniqueness"),
    ("by_other_words", "e", r"\bby other words\b", "→ in other words"),
    ("in_term_of", "e", r"\bin term of\b", "→ in terms of"),
    ("devoted_to_inf", "e", r"\b(devoted|dedicated|consecrated) to (prove|show|study|establish|discuss|present|"
                            r"define|describe|give|introduce)\b", "→ devoted to proving"),
    ("a_compact", "c", r"\ba compact\b(?! (set|subset|interval|domain|space|manifold|support|form|way|"
                       r"description|representation|and))", "un compact → a compact set"),
    ("let_be", "e", r"(?-i:\bLet be\b)", "Soit → Let X be"),
    ("either_either", "e", r"\beither\b[^.]{1,80}\beither\b", "soit ... soit → either ... or"),
    ("derivated", "e", r"\bderivat(ed|es|ing)\b", "dériver → differentiate"),
    ("asymptotic_development", "e", r"\basymptotic developments?\b", "→ asymptotic expansion"),
    ("initial_data_count", "c", r"\ban? (given )?initial data\b", "→ initial data, an initial condition"),
    ("the_dynamic", "c", r"\bthe dynamic\b(?! (programming|range|system|systems|equation|equations|model|models|"
                         r"setting|version|case|approach|point))", "la dynamique → the dynamics"),
    ("worth_to", "e", r"\bworth to\b", "worth + -ing"),
    ("out_of_the_scope", "c", r"\bout of the (scope|ambition) of\b", "→ beyond the scope of"),
    ("in_many_aspects", "c", r"\bin (many|several|some) aspects\b", "→ in many respects"),
    ("obey_to", "e", r"\bobey(s|ed|ing)? to\b", "→ obey"),
    ("substituted_to", "e", r"\bsubstitut(e|es|ed|ing) to\b", "→ substitute for, replace by"),
    ("discuss_about", "e", r"\bdiscuss(es|ed|ing)? (about|on)\b", "→ discuss"),
    ("equals_to", "e", r"\bequals to\b", "→ equals, is equal to"),
    ("followings", "e", r"\bfollowings\b", "→ the following"),
    ("require_to_inf", "e", r"\b(requires?|requiring|suggests?|forces?|forbids?|imposes?)\s+to\s+(?!the\b|a\b|"
                            r"an\b|be\b|this\b|that\b|these\b|those\b|its\b|their\b|our\b|all\b|any\b|some\b|"
                            r"each\b)[a-z]+\b", "→ require one to"),
    ("amounts_to_bare", "e", r"\bamounts? to (have|say|do|prove|show|check|visit|consider|compute|find|take|add|"
                             r"use)\b", "→ amounts to saying"),
    ("fr_spelling", "e", r"\b(litterature|developp\w*|adress(e|es|ed|ing)?|independant\w*|existance|occurence\w*|"
                         r"refered|refering|modelisation\w*|comportment\w*|mecanism\w*|exemples?|caracteri[sz]\w*|"
                         r"dimention\w*|ressources?|personnal\w*|professionnal\w*|traditionnal\w*|additionnal\w*|"
                         r"fonctions?|proprety|proprieties|explicitely|implicitely|analogic\w*|litteral\w*|"
                         r"paralell\w*|recurrsively|comparaisons?|correspondance|dependance|negligeable|bloc|blocs|"
                         r"hierarchie|algorithmes?|syntaxic\w*|langages?|caracteristic\w*|conexion|connexion|"
                         r"complexe|parametr(e|es)|theorem e|systeme|methode|modele|probabilit(e|y)s|categorie\b|"
                         r"polynomes?|coefficents?|aproximat\w*|aproach\w*)\b", "orthographe calquée sur le français"),
    ("etc_dots", "e", r"\betc\s*\.\s*\.\s*\.", "→ etc."),
    ("ie_no_dot", "e", r"\bi\.e\b(?!\.)", "→ i.e."),
    ("eg_no_dot", "e", r"\be\.g\b(?!\.)", "→ e.g."),
]
FAUTES = [(i, g, re.compile(r, re.I), n, re.compile(NEG[i] + r"\s*$", re.I) if i in NEG else None)
          for i, g, r, n in FAUTES]

# ------------------------------------------------------------------ tournures d'assistant
# §4 de STYLE-ANGLAIS.md ; « (à vérifier) » marque un indice faible, souvent légitime. Les mots
# de LLM_FORT s'y ajoutent, sauf ceux qu'Olivier emploie (crucial, insight, interplay,
# comprehensive, in essence, « plays a key role ») et notably, signalé seulement en tête de
# phrase. Une liste personnelle s'ajoute avec --mots.
SIGNALES = re.compile(r"\b(%s)\b" % "|".join(x for x in LLM_FORT if x not in (
    "notably", "crucial(ly)?", "key role", "crucial role", "pivotal role", "vital role", "interplay",
    "comprehensive(ly)?", "insights?", "in essence")), re.I)
TOURNURES = [(e, re.compile(r, re.I)) for e, r in [
    ("genuine(ly)", r"\bgenuine(ly)?\b"), ("lens", r"\blens(es)?\b"), ("not just (à vérifier)", r"\bnot just\b"),
    ("in its infancy", r"\bin (its|their) infancy\b"),
    ("it is worth noting", r"\bworth (noting|mentioning|emphasi[sz]ing|stressing|pointing out)\b"),
    ("striking(ly)", r"\bstriking(ly)?\b"), ("compelling", r"\bcompelling(ly)?\b"),
    ("profound(ly)", r"\bprofound(ly)?\b"), ("remarkable", r"\bremarkabl(e|y)\b"),
    ("paradigm shift", r"\bparadigm shifts?\b"), ("not merely", r"\bnot merely\b"),
    ("it is not X: it is Y", r"\b(it|this) is not (just |merely |simply |only )?[^.,;:]{1,40}[,;:] (it|this) is\b"),
    ("tiret cadratin", r"\u2014"), ("rather than (à vérifier)", r"\brather than\b"),
    ("Specifically, Additionally, Notably en tête (à vérifier)", r"(?-i:^(Specifically|Additionally|Notably),)"),
    ("série X, Y, and Z (à vérifier)", r"\b\w+, \w+(?: \w+)?, and \w+\b"),
    ("question en prose courante (à vérifier)", r"\?\s*$"),
    ("point-virgule entre deux propositions (à vérifier)",
     r";\s+((however|hence|thus|indeed|moreover|therefore|then|so|but|and),?\s+)?(we|it|this|these|they|there|"
     r"one|such|our|its|their|the \w+( \w+)? (is|are|was|were|has|have|can|will|may|does|do))\b")]]
PROSE_SEULE = ("question en prose courante (à vérifier)", "point-virgule entre deux propositions (à vérifier)")

# ------------------------------------------------------------------ structure du texte (comme 02_clean.py)
ENONCES = ("Theorem|Lemma|Proposition|Corollary|Definition|Remark|Example|Claim|Fact|Conjecture|Problem|"
           "Observation|Notation|Assumption|Hypothesis|Question|Open problem|Property|Exercise|Construction|"
           "Algorithm|Note|Convention|Théorème|Lemme|Définition|Remarque|Exemple|Corollaire|Propriété")
ENONCE_PAR, ENONCE_TITRE = re.compile(r"^(%s)\b" % ENONCES), re.compile(r"^(%s)s?\b" % ENONCES)
PREUVE = re.compile(r"^(Proof|Preuve|Démonstration|Sketch of proof|Proof sketch|Proof idea|Idea of the proof)\b")
FIN_PREUVE = re.compile(r"(□|∎|◻|\\square|\\blacksquare|\\qed|QED|⟦QED⟧)\s*\$?\s*$")
META = re.compile(r"\s*(\d{4} ACM Subject Classification|Keywords|Key words|Digital Object|Funding|Related "
                  r"Version|Supplementary|Category|Mots-clés|Acknowledg|Editor:|Received|Accepted|Published)")
SECTIONS = [("abstract", r"\b(abstract|résumé)\b"),
            ("references", r"\b(references|bibliography|références|bibliographie)\b"),
            ("acknowledgements", r"acknowledg|remerciement|funding"),
            ("introduction", r"\bintroduction\b|\bmotivation|^(overview|context|contexte)$"),
            ("related_work", r"related work|state of the art|previous work|literature|état de l'art|"
                             r"related results|bibliographical notes|historical"),
            ("conclusion", r"conclusion|perspective|future work|open problem|open question|discussion|"
                           r"concluding|final remark|further work"),
            ("appendix", r"appendix|annex|annexe|omitted proof|missing proof|technical lemma"),
            ("preliminaries", r"prelimin|definition|notation|background|the model|basic|framework|setting|"
                              r"préliminaires|mathematical tools"),
            ("proofs", r"\bproofs?\b|preuve"), ("results", r"\b(our results?|main results?|contributions?|results)\b")]
NIVEAUX = {"part": 1, "chapter": 1, "section": 1, "subsection": 2, "subsubsection": 3, "paragraph": 4,
           "subparagraph": 5, "myparagraph": 4}
THM = (r"theorem|lemma|proposition|corollary|definition|remark|example|claim|conjecture|fact|problem|"
       r"observation|notation|assumption|hypothesis|question|property|exercise|thm|lem|prop|cor|defn|defi|rem|"
       r"rmk|conj|obs")
PRV = r"proof|proofsketch|proofidea|sketch|proofof|preuve|demonstration"
EXCLUS = ["SIDE", "PASFINALISE", "PASANNEXE", "LONGUER", "AVOIR", "recherche", "rechercheCARE", "comment",
          "verbatim", "thebibliography", "lstlisting", "minted", "tikzpicture", "picture", "tabular", "tabular*",
          "tabularx", "acks", "algorithmic", "CCSXML"]
OTER = ("label|includegraphics|vspace|hspace|bibliography|bibliographystyle|title|author|date|thanks|address|"
        "affil|affiliation|institute|email|keywords|todo|marginpar|DANSLAMARGE|COMMENTAIREPERSO|SHORTER|"
        "signeCARE|newcommand|providecommand|setcounter|addtocounter|pagestyle|thispagestyle|captionsetup|index|"
        "ccsdesc|titlerunning|authorrunning|Copyright|newtheorem|declaretheorem|excludeversion|includeversion|"
        "color|definecolor|hypersetup")
GARDER = ("emph|textbf|textit|textsl|textsc|texttt|textrm|textsf|textmd|textup|textnormal|text|underline|uline|"
          "mbox|hbox|fbox|enquote|hyperref|IMPORTANT|IMPORTANTCARE|ARETENIR|SURLIGNE|SURSURLIGNE|SOUSLIGNE|"
          "QUESTION|RESUME")
CITES = "cite|citep|citet|citealp|citealt|citeauthor|citeyear|parencite|textcite|autocite|Cite|Citep|Citet|nocite"
ACCENTS = {"'": "\u0301", "`": "\u0300", "^": "\u0302", '"': "\u0308", "~": "\u0303", "=": "\u0304", ".": "\u0307"}
MOT, BLANCS = re.compile(r"[A-Za-zÀ-ÿ]+(?:[-'’][A-Za-zÀ-ÿ]+)*"), re.compile(r"[ \t]*")
ABREV = set("""e.g i.e etc resp cf vs al fig figs sect sec secs thm thms prop props def defs lem lemm cor eq
eqs ref refs ch chap vol no nos pp p ed eds dr prof mr ms st jr approx w.r.t wrt a.k.a aka w.l.o.g wlog s.t
i.i.d univ dept inc ltd corp jan feb mar apr jun jul aug sep sept oct nov dec ca c.f e.t.c viz ibid op cit
resp. eq. ex obs rem conj""".split())


def accolade(s, i):
    """Indice juste après l'accolade fermante qui répond à s[i] == '{' (-1 si elle manque)."""
    prof = 0
    while i < len(s):
        if s[i] == "\\":
            i += 1
        elif s[i] in "{}":
            prof += 1 if s[i] == "{" else -1
            if prof == 0:
                return i + 1
        i += 1
    return -1


def commande(s, noms, n, f):
    """Remplace \\nom*[...]{a}{b}... par f(nom, arguments) ; n arguments au plus (None : tous)."""
    rx, out, i = re.compile(r"\\(%s)\*?(?![a-zA-Z@])" % noms), [], 0
    while True:
        m = rx.search(s, i)
        if not m:
            return "".join(out) + s[i:]
        j, args = m.end(), []
        while n is None or len(args) < n:
            k = BLANCS.match(s, j).end()
            e = accolade(s, k) if s.startswith("{", k) else -1
            if s.startswith("[", k) and not args and s.find("]", k) > 0:
                j = s.find("]", k) + 1
            elif e > 0:
                args, j = args + [s[k + 1:e - 1]], e
            else:
                break
        out += [s[i:m.start()], f(m.group(1), args)]
        i = j


def sans_env(s, noms, f):
    """Remplace les environnements noms par f(m), du plus intérieur au plus extérieur (tableaux imbriqués)."""
    rx = re.compile(r"\\begin\{(%s)\}((?:(?!\\begin\{\1\}).)*?)\\end\{\1\}" % noms, re.S)
    while rx.search(s):
        s = rx.sub(f, s)
    return s


def maths(s):
    """Formules centrées → ⟨D⟩ (ponctuation finale gardée), maths en ligne → ⟨M⟩, fin de preuve marquée."""
    def centree(x):
        x = re.sub(r"(\\quad|\\qquad|\\,|\\;|\\!|\\ |\s|\\tag\{[^}]*\}|\\label\{[^}]*\}|\\end\{[a-z*]+\}|⟦BR⟧)+$",
                   "", x)
        m = re.search(r"([.,;:])\s*(\\text\{\s*\}|\})*\s*$", x)
        return " ⟨D⟩%s " % (m.group(1) if m else "")
    s = re.sub(r"(\\(?:square|blacksquare|qed|Box)\b\s*(?:\$\$|\$|\\\]|\\\))?)[ \t]*$", r"\1 ⟦QED⟧", s, flags=re.M)
    s = sans_env(s, r"(?:equation|align|alignat|gather|multline|eqnarray|flalign|displaymath|dmath)\*?",
                 lambda m: centree(m.group(2)))
    s = re.sub(r"\\\[(.*?)\\\]|\$\$(.*?)\$\$", lambda m: centree(m.group(1) or m.group(2) or ""), s, flags=re.S)
    s = re.sub(r"\\\((.*?)\\\)", " ⟨M⟩ ", s, flags=re.S)
    return re.sub(r"(?<!\\)\$((?:\\.|(?!\n[ \t]*\n)[^$\\])+?)\$", " ⟨M⟩ ", s)


def cite(nom, args):
    """Citation → ⟨C⟩ ; \\citet{clé} → « Auteur et al. ⟨C⟩ », l'auteur étant tiré de la clé."""
    m = re.match(r"\s*([A-Za-z][a-z]+)", "".join(args))
    auteur = m.group(1).capitalize() + " et al. " if m and nom in ("citet", "Citet", "textcite", "citeauthor") else ""
    return "" if nom == "nocite" else auteur + ("" if nom == "citeauthor" else "⟨C⟩")


def lire(chemin, base, prof=0):
    """Contenu du fichier ; pour un .tex, sans commentaires et avec les \\input et \\include développés."""
    with open(chemin, encoding="utf-8", errors="replace") as f:
        src = unicodedata.normalize("NFC", f.read())
    if not chemin.endswith(".tex"):
        return src
    src = "\n".join(re.sub(r"(?<!\\)%.*", "", ligne) for ligne in src.split("\n"))

    def inclure(m):
        for c in (m.group(1).strip(), m.group(1).strip() + ".tex"):
            if c.endswith(".tex") and not c.startswith("lib/") and os.path.isfile(os.path.join(base, c)) and prof < 9:
                return "\n" + lire(os.path.join(base, c), base, prof + 1) + "\n"
        return " "
    return re.sub(r"\\(?:input|include)\s*\{([^}]*)\}", inclure, src)


def blocs_tex(src, annexes):
    """Corps du document LaTeX en blocs séparés par des lignes vides, avec des marqueurs ⟦..⟧."""
    noms = re.findall(r"\\(?:newtheorem\*?|declaretheorem)(?:\[[^\]]*\])?\{([^}]+)\}", src)
    thm = THM + "".join("|" + re.escape(x) for x in noms)
    exclus = EXCLUS + re.findall(r"\\excludeversion\{([^}]+)\}", src)
    s = src.split("\\begin{document}", 1)[-1].split("\\end{document}", 1)[0]
    s = re.sub(r"\$\s*\{\s*\}\s*\^\{[^$]{0,40}\}\s*\$|\^\{\s*\*\s*\}", "", s)          # appels de note (Mathpix)
    s = re.sub(r"\\\\\*?(\[[^\]\n]*\])?", "⟦BR⟧", s)                                   # \\ et \\[2pt]
    s = maths(sans_env(s, "|".join(map(re.escape, exclus)), lambda m: "\n\n"))
    s = re.sub(r"\\(renewcommand|newcommand|providecommand)\*?\s*\\[a-zA-Z@]+", r"\\newcommand", s)
    s = commande(s, CITES, 1, cite)
    s = commande(s, "ref|eqref|cref|Cref|autoref|pageref|vref|nameref", 1,
                 lambda n, a: "(1)" if n == "eqref" else "1")
    s = commande(s, "url", 1, lambda n, a: " ⟨URL⟩ ")
    s = commande(s, "href|textcolor|colorbox", 2, lambda n, a: a[-1] if a else "")
    s = commande(commande(s, OTER, None, lambda n, a: " "), GARDER, 1, lambda n, a: a[-1] if a else "")
    s = re.sub(r"\\begin\{abstract\}(.*?)\\end\{abstract\}", lambda m: "\n\n⟦A⟧\n\n%s\n\n⟦/A⟧\n\n"
               % re.sub(r"⟦BR⟧[ \t]*\n", "\n\n", m.group(1)), s, flags=re.S)

    def annexe(kind):
        return lambda n, a: annexes.append((kind, a[0] if a else "")) or " "
    s = sans_env(s, r"(?:figure|table|wrapfigure|algorithm)\*?",
                 lambda m: commande(m.group(2), "caption", 1, annexe("caption"))[:0] + "\n\n")
    s = commande(commande(s, "caption", 1, annexe("caption")), "footnote|footnotetext", 1, annexe("footnote"))
    for debut, fin, noms in (("⟦T⟧", "⟦/T⟧", thm), ("⟦P⟧", "⟦/P⟧", PRV)):
        s = re.sub(r"\\begin\{(%s)(rep)?\*?\}(\[[^\]]*\])?" % noms, "\n\n" + debut, s)
        s = re.sub(r"\\end\{(%s)(rep)?\*?\}" % noms, fin + "\n\n", s)
    s = re.sub(r"\\item\b\s*(\[[^\]]*\])?", "\n\n⟦LI⟧ ", s)
    s = commande(s, "|".join(NIVEAUX), 1,
                 lambda n, a: "\n\n⟦H%d⟧%s⟦/H⟧\n\n" % (NIVEAUX[n], " ".join(a).replace("\n", " ")))
    s = re.sub(r"\\appendix\b", "\n\n⟦APP⟧\n\n", s)
    return re.sub(r"\\(begin|end)\{[^}]*\}(\[[^\]]*\])?", "\n\n", s)


def blocs_md(src):
    """Markdown ou texte brut : titres en #, listes, liens et maths ramenés au même format."""
    src = re.sub(r"```.*?```", "\n\n", src, flags=re.S)
    lv = [len(h) for h in re.findall(r"(?m)^(#+)\s", src)]
    haut = min(lv[1:]) if len(lv) > 1 and lv[0] < min(lv[1:]) else min(lv or [1])    # « # Titre » seul en tête
    src = re.sub(r"(?m)^(#+)\s+(.*)$",
                 lambda m: "\n\n⟦H%d⟧%s⟦/H⟧\n\n" % (max(0, len(m.group(1)) - haut + 1), m.group(2)), src)
    src = re.sub(r"(?m)^[ \t]*(?:[-*+]|\d+[.)])[ \t]+", "\n\n⟦LI⟧ ", src)
    src = re.sub(r"\[([^\]]*)\]\([^)]*\)", r"\1", re.sub(r"!\[[^\]]*\]\([^)]*\)", " ", src))
    return maths(re.sub(r"\*\*|__|`", "", src))


def nettoie(t):
    """Nettoyage fin d'un bloc (inline_clean de 02_clean.py, version masquée)."""
    t = t.replace("⟦BR⟧", " ").replace("⟦QED⟧", " ").replace("---", "\u2014").replace("--", "\u2013")
    for a, b in (("``", "“"), ("''", "”"), ("\\%", "%"), ("\\&", "&"), ("\\_", "_"), ("\\#", "#"),
                 ("\\$", "$"), ("\\{", "{"), ("\\}", "}")):
        t = t.replace(a, b)
    t = re.sub(r"\\(ldots|dots|textellipsis)\b", "…", re.sub(r"(?<!\\)~", " ", t).replace("\\~{}", "~"))
    t = re.sub(r"\\([`'^\"~=.])\s*\{?\\?([A-Za-z])\}?",
               lambda m: unicodedata.normalize("NFC", m.group(2) + ACCENTS[m.group(1)]), t)
    t = re.sub(r"\\c\s*\{?([cC])\}?", lambda m: "ç" if m.group(1) == "c" else "Ç", t)
    t = re.sub(r"\\(begin|end)\{[^}]*\}|\\[,;:! ]|\\[a-zA-Z@]+\*?(\[[^\]]*\])?", " ", t)
    t = re.sub(r"\[(?:\s*(?:\d+|\?)\s*(?:[,;\u2013-]\s*(?:\d+|\?)\s*)*)\]", "⟨C⟩",
               t.replace("{", "").replace("}", ""))                                     # [12], [3-5] (Mathpix)
    t = re.sub(r"\[(?:[A-Z][A-Za-z+'\-]*\s*\+?\d{2,4}[a-z]?(?:\s*[,;]\s*[A-Z][A-Za-z+'\-]*\s*\+?\d{2,4}[a-z]?)*)"
               r"(?:,\s*[^\]]{0,30})?\]", "⟨C⟩", t)                                     # [Bou97]
    t = re.sub(r"(⟨[MDCR]⟩|⟨URL⟩)(\s*\1)+", r"\1", t.replace("\\", " "))
    t = re.sub(r"\s+", " ", re.sub(r"(⟨[MDCR]⟩|⟨URL⟩)", r" \1 ", t)).strip()
    return re.sub(r"\s+([,.;)])", r"\1", t)


def classe(titre):
    """Type de section d'après son titre (classify_section de 02_clean.py)."""
    t = titre.strip()
    t = (re.sub(r"^[\dA-Z]+(\.\d+)*\.?\s+", "", t) if re.match(r"^[\dA-Z]+(\.\d+)*\.?\s+\S", t)
         and not re.match(r"^[A-Z][a-z]", t) else t).lower().strip(" .:")
    return next((typ for typ, rx in SECTIONS if re.search(rx, t)), "body")


def unites(s, sec, annexes):
    """Unités de prose (type, section, texte masqué), à la manière de 02_clean.py."""
    us, sid, refs, app, env, avant = [], 0, False, False, set(), sec
    for b in (b.strip() for b in re.split(r"\n[ \t]*\n", s)):
        m = re.match(r"⟦H(\d)⟧(.*?)⟦/H⟧$", b, re.S)
        if m or b in ("⟦A⟧", "⟦/A⟧", "⟦APP⟧"):            # titre, début ou fin d'abstract, \appendix
            sid += 1
            us.append(["heading", sec, sid, "", "", True])
            if b == "⟦A⟧":
                avant, sec = sec, "abstract"
            sec, app = avant if b == "⟦/A⟧" else sec, app or b == "⟦APP⟧"
        if m:
            titre, niv = nettoie(m.group(2)), int(m.group(1))
            st = classe(titre)
            st = "appendix" if app and niv == 1 and st not in ("references", "acknowledgements") else st
            if niv and not ENONCE_TITRE.match(titre) and (
                    niv == 1 or st in ("references", "acknowledgements", "appendix", "conclusion", "introduction")):
                refs, sec = (True, st) if st == "references" else (False, "appendix") if refs and st in (
                    "appendix", "body", "proofs", "results", "preliminaries") else (refs, st)
        if m or b in ("⟦A⟧", "⟦/A⟧", "⟦APP⟧"):
            continue
        env.update(re.findall(r"⟦([TP])⟧", b))
        kind = "statement" if "T" in env else "proof" if "P" in env else "list_item" if "⟦LI⟧" in b else "paragraph"
        fixe = bool(env)
        env.difference_update(re.findall(r"⟦/([TP])⟧", b))
        brut = re.sub(r"⟦/?[TP]⟧|⟦LI⟧", " ", b).strip()
        t, p = nettoie(brut), us[-1] if us else None
        if not t or refs:
            continue
        fin = re.sub(r"(⟨D⟩\s*[.,;:]?|⟨[MCR]⟩|⟨URL⟩|[\])\s])+$", "", p[4]) if p else "."
        ouvert = not re.search(r"[.!?:]\s*[\"”)]*$", fin)                      # pas de point final
        if (kind == "paragraph" and not fixe and ouvert and p[0] in ("paragraph", "list_item") and not p[5]
                and p[2] == sid and re.match(r"[a-z(]|⟨[MC]⟩", t)):                 # paragraphe coupé par une formule
            p[3], p[4] = p[3] + " " + brut, re.sub(r"\s+([,.;)])", r"\1", p[4] + " " + t)
            continue
        us.append([kind, sec, sid, brut, t, fixe])
    preuve = 0
    for u in us:                                       # « Theorem 2. » et « Proof. » en tête de paragraphe
        if u[0] not in ("paragraph", "list_item") or u[5]:
            preuve = 0
        elif PREUVE.match(u[4]):
            u[0], preuve = "proof", 0 if FIN_PREUVE.search(u[3]) else 1
        elif ENONCE_PAR.match(u[4]):
            u[0], preuve = "statement", 0
        elif preuve and preuve < 15 and u[0] == "paragraph":
            u[0], preuve = "proof", 0 if FIN_PREUVE.search(u[3]) else preuve + 1
    out = [(u[0], u[1], u[4]) for u in us if u[0] != "heading" and re.search(r"[A-Za-zÀ-ÿ]{2}", u[4])
           and u[1] not in ("references", "acknowledgements")
           and not (u[0] in ("paragraph", "list_item") and META.match(u[4]))]
    for kind, x in annexes:                            # notes et légendes, en fin de liste comme dans 02_clean.py
        for par in re.split(r"\n[ \t]*\n" + (r"|⟦BR⟧[ \t]*\n" if kind == "footnote" else ""), x):
            if re.search(r"[A-Za-zÀ-ÿ]{2}", nettoie(par)):
                out.append((kind, kind, nettoie(par)))
    return out


def decoupe(texte):
    """Découpage en phrases, repris de split_sentences (03_sentences.py)."""
    phrases, debut = [], 0
    for m in re.finditer(r"([.?!])([\"”’)\]]*)\s+(?=[A-Z⟨(\"“0-9À-Ý])", texte):
        avant = texte[debut:m.start(1)]
        der = (re.findall(r"([A-Za-z.]+)$", avant) or [""])[0].lower()
        suite = re.match(r"(We|The|This|In|It|They|These|Our|A|An|However|Moreover|Thus|Hence)\b",
                         texte[m.end():m.end() + 12])
        initiale = re.search(r"(^|[\s(])[A-Z]$", avant)                           # « J. Smith »
        if m.group(1) == "." and (der.rstrip(".") in ABREV or der.split(".")[-1] in ABREV or initiale
                                  or re.search(r"\bet al$", avant) and not suite):
            continue
        phrases.append(texte[debut:m.end(2)].strip())
        debut = m.end()
    return [p for p in phrases + [texte[debut:].strip()] if p]


def registre(kind, sec, n_mots, n_maths):
    """Registre d'une phrase (register_of de check_style.py) ; les légendes sont techniques."""
    if kind in ("proof", "statement", "caption"):
        return "technique"
    seuil = 0.15 if sec in ("abstract", "introduction", "related_work", "conclusion") else 0.05
    return "discursive" if n_maths / max(1, n_mots + n_maths) < seuil else "technique"


def analyse(chemin):
    """Phrases du brouillon avec leur registre, leurs comptes et leurs fautes."""
    annexes, src = [], lire(chemin, os.path.dirname(os.path.abspath(chemin)))
    if chemin.endswith(".tex"):
        us = unites(blocs_tex(src, annexes), "front", annexes)
    else:
        us = unites(blocs_md(src), "introduction", [])
    out = []
    for kind, sec, texte in us:
        for s in decoupe(texte):
            n = len(MOT.findall(re.sub(r"⟨[MDCR]⟩|⟨URL⟩", " ", s)))
            if n:
                c = {k: len(rx.findall(s)) for k, rx in MOTIFS.items()}
                f = [(i, g, m.group(0), note) for i, g, rx, note, neg in FAUTES for m in rx.finditer(s)
                     if neg is None or not neg.search(s[max(0, m.start() - 25):m.start()])]
                c["fr_err"], c["fr_calque"] = sum(x[1] == "e" for x in f), sum(x[1] == "c" for x in f)
                out.append(dict(t=s, n=n, kind=kind, sec=sec, c=c, fautes=f,
                                reg=registre(kind, sec, n, len(re.findall(r"⟨[MD]⟩", s)))))
    return out


def valeur(calc, base):
    """Valeur d'une mesure sur les phrases retenues (compute de style_metrics.py) ; None si indéfinie."""
    longueurs, mots = [p["n"] for p in base], sum(p["n"] for p in base)
    calc, motif = (calc.split() + [""])[:2]
    if calc in ("moy", "med"):
        return (statistics.mean if calc == "moy" else statistics.median)(longueurs)
    if calc in (">40", "<10"):
        return 100 * sum(x > 40 if calc == ">40" else x < 10 for x in longueurs) / len(base)
    if calc == "uk":
        uk, us = sum(p["c"]["uk"] for p in base), sum(p["c"]["us"] for p in base)
        return 100 * uk / (uk + us) if uk + us else None
    tot = sum(p["c"][motif] for p in base)
    return {"/phrase": tot / len(base), "/100ph": 100 * tot / len(base)}.get(calc, 1000 * tot / max(1, mots))


def affiche(s, n=250):
    """Phrase citée dans le rapport, tronquée ; les tirets y sont écrits comme dans le source (--- et --)."""
    s = s.replace("\u2014", "---").replace("\u2013", "--")
    return s if len(s) <= n else s[:n - 1].rstrip() + "…"


def mots_perso(chemin):
    """Tournures de la liste personnelle (--mots) : une expression régulière par ligne, sans casse."""
    out = []
    with open(chemin, encoding="utf-8") as f:
        for e in (ligne.strip() for ligne in f):
            if not e or e.startswith("#"):
                continue
            try:
                debut, fin = ("\\b" if e[0].isalpha() else ""), ("\\b" if e[-1].isalpha() else "")
                out.append((e + " (liste perso)", re.compile(debut + "(?:" + e + ")" + fin, re.I)))
            except re.error as err:
                print("style-anglais : entrée ignorée dans %s : %s (%s)" % (chemin, e, err), file=sys.stderr)
    return out


def rapport(nom, ph, profil, perso):
    """Rapport Markdown en français sur la sortie standard."""
    disc = [p for p in ph if p["reg"] == "discursive"]
    base, mots = disc if len(disc) >= 20 else ph, sum(p["n"] for p in ph)
    out = ["# Style anglais : %s\n" % nom, "%d phrases, %d mots, dont %d phrases discursives (%d mots)."
           % (len(ph), mots, len(disc), sum(p["n"] for p in disc))]
    if mots < 300:
        out.append("\n**Trop peu de mots (%d, moins de 300) : les mesures ne veulent rien dire et ne sont pas "
                   "données. Les listes suivent quand même.**" % mots)
    else:
        out += ["Mesures calculées sur %s. Référence : %s ; plage habituelle : du 10e au 90e centile, texte par "
                "texte." % ("les phrases discursives" if base is disc else
                            "toutes les phrases (moins de 20 phrases discursives)", PROFILS[profil][1]),
                "\n## Mesures\n\n| mesure | brouillon | plage habituelle | médiane | statut |\n|---|---|---|---|---|"]
        for m in MESURES:
            v, (p10, p50, p90) = valeur(m[2], base), map(float, m[PROFILS[profil][0]].split())
            st = "sans objet" if v is None else "au-dessus" if v > p90 else "au-dessous" if v < p10 else "ok"
            out.append("| %s | %s | %.2f à %.2f | %.2f | %s |"
                       % (m[0], "n.d." if v is None else "%.2f" % v, p10, p90, p50, st))
    out += ["\nPhrases citées : ⟨M⟩ maths en ligne, ⟨D⟩ formule centrée, ⟨C⟩ citation, ⟨URL⟩ adresse.",
            "\n## Tournures d'assistant\n\n(à vérifier) : indice faible, souvent légitime ; relire la phrase.\n"]
    liste = []
    for p in ph:
        tags = [m.group(0).lower() for m in SIGNALES.finditer(p["t"])]
        tags += [e for e, rx in TOURNURES + perso
                 if rx.search(p["t"]) and (e not in PROSE_SEULE or p["reg"] == "discursive")]
        liste += ["- [%s] %s" % (", ".join(dict.fromkeys(tags)), affiche(p["t"]))] if tags else []
    out += (liste or ["Aucune."]) + ["\n## Fautes et calques\n"]
    out += ["- [%s] %s" % (" ; ".join("%s « %s »%s" % (i, x, " : " + n if n else "") for i, _, x, n in p["fautes"]),
                           affiche(p["t"])) for p in ph if p["fautes"]] or ["Aucune."]
    out += ["\n## Phrases de plus de 40 mots\n"]
    out += ["- (%d mots%s) %s" % (p["n"], "" if p["reg"] == "discursive" else ", technique", affiche(p["t"]))
            for p in ph if p["n"] > 40] or ["Aucune."]
    print("\n".join(out))


def main(args):
    """Lecture des options, analyse et rapport."""
    if not args or "-h" in args or "--help" in args:
        print(__doc__)
        return 0
    opts = {}
    for o in ("--profil", "--mots"):
        if o in args:
            i = args.index(o)
            opts[o] = args[i + 1] if i + 1 < len(args) else ""
            del args[i:i + 2]
    if opts.get("--profil", "solo") != "solo":
        sys.exit("style-anglais : seule l'option --profil solo existe (sans elle : textes de 2012 à 2022)")
    fichiers = [a for a in args if a != "--phrases"]
    if len(fichiers) != 1 or not os.path.isfile(fichiers[0]) or not os.path.isfile(opts.get("--mots", __file__)):
        sys.exit("style-anglais : donner un seul fichier .tex, .md ou .txt, et une liste --mots qui existe")
    ph = analyse(fichiers[0])
    if "--phrases" in args:
        for p in ph:
            print("%s | %-12s | %-9s | %3d | %s" % (p["reg"][0].upper(), p["sec"], p["kind"], p["n"],
                                                     affiche(p["t"], 10 ** 6)))
        return 0
    perso = mots_perso(opts["--mots"]) if "--mots" in opts else []
    rapport(os.path.basename(fichiers[0]), ph, "solo" if "--profil" in opts else "2012-2022", perso)
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
