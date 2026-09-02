# Conventions LaTeX (Olivier Bournez)

Tronc commun lu par le chat (via son URL raw) et par Claude Code (importé par le
CLAUDE.md de chaque chantier). Source de vérité : ce fichier, dans SHAREDDIR
(https://github.com/nirzolb/SHAREDDIR, public ; copie locale /Users/bournez/public_raw/SHAREDDIR).

## Fichiers de style et modèles
- Styles dans `STYLEDIR/` : macros.tex, macros-moins-propres.tex, macros-accents.tex,
  macros-markdown.tex, macros-intitules.tex, olivier.sty, expose.sty, expose-new.sty,
  beamerthemeVillers.sty. macros.tex inpute macros-accents.tex, et macros-markdown.tex
  s'il existe (son absence est tolérée). olivier.sty en option [expose] requiert expose.sty
  ET expose-new.sty.
- Modèles dans `LATEX-EXEMPLES/` : tex-minimal.tex (document simple), expose-minimal.tex
  (exposé beamer, thème Villers), cours-minimal.tex (cours, avec entete-cours.tex et
  fin-cours.tex à côté).
- Tout fichier .tex généré commence par `\input{macros}` puis `\input{macros-moins-propres}`.
- En chantier, tout est accessible par `lib/SHAREDDIR/` (TEXINPUTS et BIBINPUTS réglés par
  le Makefile). Hors chantier (brouillon dans le chat), récupérer les fichiers par
  https://raw.githubusercontent.com/nirzolb/SHAREDDIR/main/STYLEDIR/<fichier> et
  .../LATEX-EXEMPLES/<modèle>.
- Si un fichier de style requis manque au dépôt : créer un stub vide clairement commenté
  et le signaler.

## Compilation
- pdflatex, bibtex, makeindex (pour un cours, si un .idx existe), puis pdflatex deux fois.
  En chantier : `make`.
- Paquets Ubuntu : texlive-fonts-extra, texlive-lang-french, texlive-plain-generic,
  texlive-bibtex-extra, lmodern (plus texlive-latex-extra, texlive-science,
  texlive-pictures pour les exposés).
- Cours : mode travail par défaut (ne définir ni \SAFEMODE ni \DIFFUSIONFINALE) ; version
  de diffusion uniquement sur demande explicite.

## Bibliographie et clés de citation
- Les modèles font `\bibliography{\BIBFILES}`, avec \BIBFILES = @@reference-biblio par
  défaut. Rendre `BIBDESKDIR/@@reference-biblio.bib` accessible (copie locale ou BIBINPUTS ;
  en chantier le Makefile s'en charge), ou faire `\renewcommand\BIBFILES`.
- Toute clé `\cite{xxx}` est vérifiée dans @@reference-biblio.bib
  (https://raw.githubusercontent.com/nirzolb/SHAREDDIR/main/BIBDESKDIR/@@reference-biblio.bib) :
  si la clé y est, l'utiliser exactement, sans supposition ni normalisation. D'autres
  références sont bienvenues si pertinentes ; entre plusieurs versions, préférer celle
  avec doi.

## Logos
- `\FIGCOMMONS` pointe par défaut sur /Users/bournez/lib/LaTeX/Perso/FIG-COMMONS
  (logo_CNRS, logo_LIX, logo_IPP, logo_X_new). Sur une autre machine : logos factices et
  `\providecommand\FIGCOMMONS{...}` avant `\input{macros}` (en chantier, `make deps` le fait
  via figcommons-local.tex), ou `\renewcommand\FIGCOMMONS` après.

## Macros et mise en évidence
- Ne jamais utiliser \IMPORTANT, \SURLIGNE et \SURSURLIGNE (annotations personnelles
  d'Olivier), mais les préserver là où elles sont.
- Points importants et « à retenir » : `\IMPORTANTCARE[titre optionnel]{texte}` (bandeau
  bleu, défini dans macros.tex), titres du type « Important (CARE) », « À retenir (CARE) »,
  « Point clé (CARE) ». En ligne : \emph ou \textbf ; \SOUSLIGNE pour le secondaire.

## Couleurs (daltonisme protanope)
- Jamais rouge/vert/orange/marron seuls, dans les couleurs LaTeX comme dans les figures et
  graphiques. Privilégier bleu contre jaune contre gris, et doubler la couleur d'un indice
  non coloré (bordure, étiquette, forme, hachures).

## Écriture
- Pas de tirets cadratins ; éviter ce qui trahit un texte de LLM (formules creuses,
  listes à puces systématiques, résumés finaux inutiles). Français par défaut.

## Ouvrir un chantier depuis le chat
Quand Olivier dit « on ouvre un chantier » à partir d'un brouillon :
1. `git clone --depth 1 https://github.com/nirzolb/SHAREDDIR` dans le bac à sable, puis
   `SHAREDDIR/SCRIPTS/nouveau-chantier.sh <cours|expose|doc> <nom> --dir <répertoire>`.
2. Remplacer main.tex (et fichiers annexes) par le brouillon ; compléter CLAUDE.md
   (rubrique « rappels propres à ce chantier ») et la première entrée de NOTES.md.
3. Vérifier que `make` passe, `make distclean`, supprimer Makefile.local, commit (auteur
   Claude-Code), puis livrer `<nom>.tar.gz` du répertoire. Olivier fait ensuite, dans
   /Users/bournez/00-CHANTIERS-CARE/<nom> : `gh repo create <nom> --private --source=.
   --remote=origin --push`.
