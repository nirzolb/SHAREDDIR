#!/bin/bash
# Builds latex_bundle.zip in the current directory: the styles and the model documents as
# they are on GitHub, for a machine that has nothing else (ChatGPT, a colleague).
# The zip holds one folder, READY-TO-COMPILE, whose README.txt says how to compile.

set -e

REPO_URL="https://github.com/nirzolb/SHAREDDIR.git"
OUTDIR="READY-TO-COMPILE"
ZIP="latex_bundle.zip"

# A file missing from GitHub stops the script: no incomplete zip
STYLES="macros.tex macros-moins-propres.tex macros-care.tex macros-accents.tex
        macros-markdown.tex macros-intitules.tex
        olivier.sty expose.sty expose-new.sty beamerthemeVillers.sty"
EXAMPLES="tex-minimal.tex expose-minimal.tex cours-minimal.tex entete-cours.tex fin-cours.tex"

# Work in a temporary directory: only the zip is left behind
HERE=$(pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
WORKDIR="$TMP/repo"

echo "⬇️ Cloning repository..."
git clone --quiet "$REPO_URL" "$WORKDIR"

echo "📦 Preparing bundle..."
mkdir -p "$TMP/$OUTDIR/STYLEDIR" "$TMP/$OUTDIR/LATEX-EXEMPLES"

# Copy styles
for f in $STYLES; do
  cp "$WORKDIR/STYLEDIR/$f" "$TMP/$OUTDIR/STYLEDIR/"
done

# Copy examples
for f in $EXAMPLES; do
  cp "$WORKDIR/LATEX-EXEMPLES/$f" "$TMP/$OUTDIR/LATEX-EXEMPLES/"
done

# Create a minimal main file
cat <<'EOF' > "$TMP/$OUTDIR/exemple.tex"
%% Test of this bundle: run "pdflatex exemple.tex" in this directory.
%% The next line is only needed here, because the styles sit in STYLEDIR/.
\makeatletter\def\input@path{{STYLEDIR/}}\makeatother

%% The two precautions below are explained in LATEX-EXEMPLES/expose-minimal.tex.
\providecommand\ifnotSLIDE[1]{}
\documentclass[compress,dvipsnames]{beamer}

\input{macros}
\input{macros-moins-propres}

\makeatletter
\@for\@tempa:={soustitre,defin,motnouv,motnouvi,motnouvm}\do{%
  \expandafter\let\csname\@tempa\endcsname\relax}
\makeatother

\usepackage[beamer,expose,french]{olivier}

\title{Test Villers}
\author{Test}
\date{\today}

\begin{document}

\begin{frame}
\titlepage
\end{frame}

\begin{myslide}{Test}

Hello world

\end{myslide}

\end{document}
EOF

# Say what this is and which version: the last commit that touched what is copied
VERSION=$(git -C "$WORKDIR" log -1 --format='%h, %cd' --date=short -- STYLEDIR LATEX-EXEMPLES)
{
  echo "LaTeX styles and model documents of Olivier Bournez."
  echo "From $REPO_URL (commit $VERSION)."
  cat <<'EOF'

STYLEDIR/        the styles: macros*.tex, olivier.sty, expose*.sty, beamerthemeVillers.sty
LATEX-EXEMPLES/  the models: tex-minimal.tex (article), expose-minimal.tex (slides),
                 cours-minimal.tex with entete-cours.tex and fin-cours.tex (lecture notes)
exemple.tex      a two-slide test of the styles

To test the bundle, in this directory:
    pdflatex exemple.tex

A document starts with \input{macros} and \input{macros-moins-propres}, without a path:
TeX has to be told where the styles are. From any directory:
    TEXINPUTS=/path/to/READY-TO-COMPILE/STYLEDIR: pdflatex document.tex

Not in this bundle: the bibliography (BIBDESKDIR/@@reference-biblio.bib in the repository)
and the logos that expose-minimal.tex puts on its title page (\FIGCOMMONS).
EOF
} > "$TMP/$OUTDIR/README.txt"

# Zip it. Same styles, same zip: files take the date of that commit, entries are sorted
STAMP=$(git -C "$WORKDIR" log -1 --format=%cd --date=format-local:%Y%m%d%H%M.%S -- STYLEDIR LATEX-EXEMPLES)
find "$TMP/$OUTDIR" -exec touch -t "$STAMP" {} +
rm -f "$ZIP"
(cd "$TMP" && find "$OUTDIR" -type f | LC_ALL=C sort | zip -q -X "$HERE/$ZIP" -@)

echo "✅ Bundle ready: $ZIP (styles of commit $VERSION)"
if [ -t 1 ] && command -v open > /dev/null; then open .; fi
