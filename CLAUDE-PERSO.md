# Instructions personnelles pour Claude Code (Olivier Bournez)

Ce fichier est lié depuis ~/.claude/CLAUDE.md sur mes machines. Il est public dans
SHAREDDIR : rien de personnel au-delà de chemins et de conventions.

## Qui et comment
- Je suis Olivier Bournez (LIX, CNRS, École polytechnique). Me répondre en français, sauf
  si le document est en anglais.
- Pas de tirets cadratins ; éviter les tics d'écriture de LLM.
- Daltonien protanope : dans tout contenu visuel, jamais rouge/vert/orange/marron seuls ;
  bleu, jaune, gris, et doubler la couleur d'un indice non coloré.

## Mes dépôts
- SHAREDDIR, public : /Users/bournez/public_raw/SHAREDDIR, miroir de
  https://github.com/nirzolb/SHAREDDIR. Styles LaTeX, biblio, modèles, squelette de
  chantier. Depuis un chantier, il est en lecture seule (lib/SHAREDDIR) ; une correction de
  style se fait ici, puis se pousse.
- Chantiers : /Users/bournez/00-CHANTIERS-CARE/<nom>, un dépôt privé chacun, avec son
  CLAUDE.md qui prime sur ce fichier.

## En chantier (détails dans le CLAUDE.md du chantier)
- Mes commits restent à mon nom ; les tiens sont signés Claude-Code, ne commite que ce que
  tu as modifié.
- Début de session : /reprise. Fin : /passation. Citer le commit courant (make sha) dans
  tout échange.
- Jamais de git dans un répertoire finalisé : make publier et make importer seulement.

## LaTeX
- Conventions : /Users/bournez/public_raw/SHAREDDIR/CONVENTIONS-LATEX.md (importées
  automatiquement dans un chantier via lib/SHAREDDIR).
- Styles personnels installés dans TEXMFHOME, soit ~/Library/texmf/tex/latex/ : le lien
  perso pointe sur ~/lib/LaTeX/Perso, et perso-extra/ contient des liens nommés, fichier
  par fichier. kpsewhich les trouve donc sans TEXINPUTS, y compris hors shell interactif
  et depuis une application ouverte par le Finder, qui hérite de launchd et non du shell.
  TEXINPUTS reste dans le .zshrc, il ne sert plus de béquille. [2 septembre 2026]
- Ne jamais lier tout ~/lib/LaTeX dans cet arbre : TEXMFHOME est fouillé récursivement et
  prime sur la distribution, ce qui mettrait de vieilles copies (hyperref, pgf, prosper,
  listings, ucs, microtype) devant TeX Live pour toute la machine. Un style manquant
  s'ajoute par un lien nommé dans perso-extra.
- Dans ~/lib/LaTeX/Perso, olivier.sty, expose.sty et expose-new.sty sont des liens vers
  SHAREDDIR/STYLEDIR, et beamerthemeVillers.sty est lié depuis perso-extra. Une
  correction faite dans SHAREDDIR se propage donc sans recopie. Ne pas rétablir de copie,
  les deux versions divergeraient en silence.
