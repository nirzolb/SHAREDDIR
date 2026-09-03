# Conventions pour les articles (Olivier Bournez)

Complète CONVENTIONS-LATEX.md pour les articles de recherche. Lu par le chat quand Olivier
demande un article, et importé par le CLAUDE.md des chantiers de type article.

## 1. Avant d'écrire : la cible
- Première chose à demander, si ce n'est pas dit : la cible (conférence ou revue, ou lien
  vers l'appel), les coauteurs, la limite de pages (avec ou sans annexe, avec ou sans
  biblio), soumission anonyme ou non. Si un lien vers l'appel est donné, le lire et en
  extraire ces contraintes, la date limite et le style de biblio imposé.
- Modèle selon la cible (LATEX-EXEMPLES/) :

  | Cible | Modèle | Classe | Biblio |
  |---|---|---|---|
  | LIPIcs (MFCS, ICALP, STACS, CSL, FSTTCS, ...) | article-lipics-minimal.tex | lipics-v2021 (STYLEDIR/CLASSES/lipics) | plainurl |
  | Springer LNCS (CiE, ...) | article-lncs-minimal.tex | llncs (TeX Live) | splncs04 |
  | ACM (ISSAC, LICS, ...) | article-acm-minimal.tex | acmart (TeX Live) | ACM-Reference-Format |
  | Revue ou appel avec sa propre classe, arXiv | article-generic-minimal.tex | article, ou la classe de l'appel déposée à côté | plainurl |

  Le modèle est copié tel quel, métadonnées comprises ; on remplace les trous, on ne
  réinvente pas le préambule.

## 2. Preuves et apxproof (LIPIcs et générique par défaut, LNCS et ACM sur demande)
- Un résultat dont la preuve dépasse une dizaine de lignes s'écrit
  `theoremrep` (ou `lemmarep`, `propositionrep`, `corollaryrep`, `claimrep`), suivi de
  `proofsketch` puis de `proof`, dans cet ordre. Le sketch reste dans le corps, la preuve
  part en annexe. Une preuve courte reste inline dans un environnement ordinaire.
- Le sketch, 3 à 8 lignes, dit l'idée, l'ingrédient clé et où est la difficulté ; il doit
  se suffire à lui-même, parce qu'en version strip c'est tout ce qui reste.
- Tout résultat principal de l'introduction a un sketch ; jamais un sketch et une preuve
  complète tous deux dans le corps.
- Trois versions du même source, choisies par `\apxparameter` sans toucher au texte :
  `make` (appendix=append, soumission avec annexe), `make full` (appendix=inline, version
  longue arXiv ou revue), `make strip` (appendix=strip, camera-ready quand l'annexe n'est
  pas admise ; ajouter alors `\relatedversion` vers la version longue).
- apxproof se charge avant `\input{macros.tex}` (qui le configure) : c'est ce que font
  les modèles, ne pas déplacer cette ligne. L'annexe est engendrée automatiquement,
  groupée par section d'origine ; ne pas écrire `\appendix` soi-même.
- `\SHORTER{...}` (texte retiré pour la limite de pages) est réservé à Olivier : Claude n'en
  ajoute pas, n'en retire pas, et ne modifie pas ce qu'il y a dedans. Contenus
  conditionnels : environnements SIDE, PASFINALISE, LONGUER, AVOIR (paquet version),
  exclus par défaut.

## 3. Plan et écriture
- Abstract en quatre phrases : la question, pourquoi elle compte, le résultat, la
  technique. Introduction : contexte, question, résultat principal en une phrase avec
  renvoi au théorème, paragraphe « Contributions » (liste), technique, travaux liés,
  plan. Puis Preliminaries, résultats, sections de preuve, Conclusion and perspectives.
- Anglais, « we ». Paragraphes titrés avec `\myparagraph{...}`. Renvois `Theorem~\ref{}`,
  `Section~\ref{}` (LIPIcs, LNCS, générique) ; `\cref` seulement avec acmart. Labels
  `thm:`, `lem:`, `prop:`, `cor:`, `def:`, `sec:`, `eq:`, `fig:`.
- Pas de tics de LLM : pas de phrases creuses, pas de listes à puces hors contributions,
  pas de résumé de section en fin de section, pas de tirets cadratins.
- Clés `\cite` : règle de CONVENTIONS-LATEX.md (exactement celles de
  @@reference-biblio.bib quand elles y sont). `\bibliography{\BIBFILES}` ; la biblio
  personnelle d'Olivier (`bournez,perso`) se substitue chez lui.
- Métadonnées : bloc auteur d'Olivier tel quel dans le modèle (ORCID
  0000-0002-9218-1130, affiliation, financement) ; `\ccsdesc` et `\keywords`
  obligatoires pour LIPIcs et ACM ; `\EventEditors` et compagnie restent vides jusqu'à
  la camera-ready.
- Limite de pages : `make` affiche le nombre de pages. En cas de dépassement, Claude
  propose des coupes (preuves à passer en annexe, paragraphes à resserrer) et Olivier
  tranche ; jamais de bidouille de marges ou de police.
- Coauteurs : la syntaxe de chaque classe est dans le modèle, en commentaire sous le bloc
  auteur d'Olivier ; la décommenter et remplir, y compris \authorrunning et \Copyright
  (LIPIcs) ou \shortauthors (ACM).

## 4. En chantier
- `nouveau-chantier.sh article NOM --classe lipics|lncs|acm|generic --github` ; le CLAUDE.md
  du chantier importe ce fichier. Classe imposée par un appel : la déposer à la racine du
  chantier, elle prime sur celle de lib/SHAREDDIR ou de TeX Live.
- Hors chantier (brouillon dans le chat) : classe LIPIcs à récupérer dans
  STYLEDIR/CLASSES/lipics via les URL raw ; llncs et acmart sont dans TeX Live.
