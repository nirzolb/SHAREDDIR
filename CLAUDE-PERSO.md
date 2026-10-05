# Instructions personnelles pour mes assistants, Claude Code et Codex (Olivier Bournez)

Ce fichier est lié depuis ~/.claude/CLAUDE.md pour Claude Code et depuis ~/.codex/AGENTS.md
pour Codex, sur mes machines : un seul texte pour les deux, plus de copie qui diverge.
Il est public dans SHAREDDIR : rien de personnel au-delà de chemins et de conventions.
[5 octobre 2026]

## Qui et comment
- Je suis Olivier Bournez (LIX, CNRS, École polytechnique). Me répondre en français, sauf
  si le document est en anglais.
- Pas de tirets cadratins ; éviter les tics d'écriture de LLM.
- Daltonien protanope : dans tout contenu visuel, jamais rouge/vert/orange/marron seuls ;
  bleu, jaune, gris, et doubler la couleur d'un indice non coloré.
- Jamais d'ultracode (orchestration multi-agents, outil Workflow) sans mon autorisation
  explicite : c'est moi qui mets le mot sur la requête ; sa simple mention dans un message
  n'autorise rien. [3 octobre 2026]

## Mes dépôts
- SHAREDDIR, public : /Users/bournez/public_raw/SHAREDDIR, miroir de
  https://github.com/nirzolb/SHAREDDIR. Styles LaTeX, biblio, modèles, squelette de
  chantier. Depuis un chantier, il est en lecture seule (lib/SHAREDDIR) ; une correction de
  style se fait ici, puis se pousse.
- Chantiers : /Users/bournez/00-CHANTIERS-CARE/<nom>, un dépôt privé chacun, avec ses
  règles, AGENTS.md ou CLAUDE.md, qui priment sur ce fichier.

## En chantier (détails dans les règles du chantier)
- Mes commits restent à mon nom ; les tiens sont signés de ton nom d'intervenant,
  Claude-Code pour Claude Code, Codex pour Codex. Ne commite que ce que tu as modifié.
- Début et fin de session : /reprise et /passation dans Claude Code, les mêmes gestes à la
  main ailleurs, tels que les règles du chantier les décrivent. Citer le commit courant
  (make sha) dans tout échange.
- Tu n'es pas seul dans un chantier : Claude Code et Codex y travaillent tous les deux. Un chantier, un dépôt, un
  seul répertoire, à tour de rôle. Si le hook de démarrage ou `make qui` dit qu'un autre
  est là, ou que la version la plus avancée d'un fichier est ailleurs que dans l'arbre de
  travail, me le dire avant de modifier quoi que ce soit. Travail simultané seulement sur
  mon ordre, dans un poste temporaire (nouveau-poste.sh). Les règles d'un chantier sont
  dans son AGENTS.md quand son CLAUDE.md l'importe : une règle nouvelle s'y écrit alors,
  pas dans CLAUDE.md. Dans un chantier pas encore converti, où CLAUDE.md n'importe pas
  AGENTS.md, c'est CLAUDE.md qui fait foi pour tous les assistants, et l'AGENTS.md qui s'y
  trouve est une vieille copie à ne pas suivre. [5 octobre 2026]
- Jamais de git dans un répertoire finalisé : make publier et make importer seulement.
- Rien de ce qui part vers un finalisé ne parle du chantier, de Claude, de Codex ni de
  CARE : make publier refuse (macros CARE, les quatre mots), le hook pre-push refuse les
  commits qui en parlent, le message de commit est neutre. [27 septembre 2026 ; Codex
  ajouté le 5 octobre]
- Le document principal d'un chantier porte le nom du chantier sans le préfixe
  CARE-CHANTIER- (CARE-CHANTIER-Raisonner-Sur-ODEs donne Raisonner-Sur-ODEs.tex et .pdf),
  jamais main : des PDF tous appelés main.pdf ne se distinguent pas. nouveau-chantier.sh
  le fait par défaut (--doc pour un autre nom). [2 octobre 2026]

## LaTeX
- L'environnement recherche est à moi : ne jamais l'utiliser (mais préserver ses
  occurrences). Ton équivalent est rechercheCARE, défini dans macros-care.tex.
  Vaut aussi pour les brouillons. Tous mes assistants s'en servent : signer ce que tu y
  écris de ton nom, \signeCARE{Claude} ou \signeCARE{Codex}, et répondre sous le texte
  d'un autre sans le réécrire. [5 octobre 2026]
- Conventions : /Users/bournez/public_raw/SHAREDDIR/CONVENTIONS-LATEX.md (importées
  automatiquement dans un chantier via lib/SHAREDDIR).
- Styles personnels installés dans TEXMFHOME, soit ~/Library/texmf/tex/latex/ : le lien
  perso pointe sur ~/lib/LaTeX/Perso, et perso-extra/ contient des liens nommés, fichier
  par fichier. kpsewhich les trouve donc sans TEXINPUTS, y compris hors shell interactif
  et depuis une application ouverte par le Finder, qui hérite de launchd et non du shell.
  TEXINPUTS reste dans le .zshrc, il ne sert plus de béquille. [2 septembre 2026]
- Même principe pour bibtex : ~/Library/texmf/bibtex/bib/perso-extra contient des liens
  nommés vers les .bib principaux de ~/bibliographie/BIBDESK-DIR= (@@reference-biblio,
  bournez, perso, CARE, mecite...), et bibtex/bst/perso-extra un lien vers myfplain.bst.
  BIBINPUTS et BSTINPUTS du .zshrc ne parviennent pas à TeXShop. Un .bib de plus s'ajoute
  par un lien nommé, pas en liant tout le répertoire (ARCHIVES, OLD2, COPIE portent des
  homonymes). [21 septembre 2026]
- Ne jamais lier tout ~/lib/LaTeX dans cet arbre : TEXMFHOME est fouillé récursivement et
  prime sur la distribution, ce qui mettrait de vieilles copies (hyperref, pgf, prosper,
  listings, ucs, microtype) devant TeX Live pour toute la machine. Un style manquant
  s'ajoute par un lien nommé dans perso-extra.
- Dans ~/lib/LaTeX/Perso, olivier.sty, expose.sty, expose-new.sty, macros.tex,
  macros-moins-propres.tex, macros-care.tex, macros-accents.tex, macros-intitules.tex et
  macros-markdown.tex sont des liens vers SHAREDDIR/STYLEDIR, et beamerthemeVillers.sty est lié depuis
  perso-extra. Une correction faite dans SHAREDDIR se propage donc sans recopie. Ne pas
  rétablir de copie, les deux versions divergeraient en silence (c'est arrivé :
  rechercheCARE absent de la copie de macros-moins-propres.tex ; anciennes copies dans
  ~/lib/LaTeX/Perso-copies-avant-liens-20260921). [21 septembre 2026]
