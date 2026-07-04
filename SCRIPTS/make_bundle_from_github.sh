#!/bin/bash

set -e

REPO_URL="https://github.com/nirzolb/SHAREDDIR.git"
WORKDIR="tmp_repo"
OUTDIR="READY-TO-COMPILE"

echo "⬇️ Cloning repository..."
rm -rf $WORKDIR
git clone $REPO_URL $WORKDIR

echo "📦 Preparing bundle..."
rm -rf $OUTDIR
mkdir -p $OUTDIR/STYLEDIR
mkdir -p $OUTDIR/LATEX-EXEMPLES

# Copy styles
cp $WORKDIR/STYLEDIR/macros.tex $OUTDIR/STYLEDIR/
cp $WORKDIR/STYLEDIR/macros-moins-propres.tex $OUTDIR/STYLEDIR/
cp $WORKDIR/STYLEDIR/olivier.sty $OUTDIR/STYLEDIR/
cp $WORKDIR/STYLEDIR/expose-new.sty $OUTDIR/STYLEDIR/
cp $WORKDIR/STYLEDIR/beamerthemeVillers.sty $OUTDIR/STYLEDIR/

# Copy example
cp $WORKDIR/LATEX-EXEMPLES/expose-minimal.tex $OUTDIR/

# Create a minimal main file
cat <<EOF > $OUTDIR/exemple.tex
\documentclass[compress,dvipsnames]{beamer}

\input{STYLEDIR/macros}
\input{STYLEDIR/macros-moins-propres}

\usepackage[beamer,expose,french]{olivier}
\usetheme{Villers}

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

# Zip it
zip -r latex_bundle.zip $OUTDIR > /dev/null

echo "✅ Bundle ready: latex_bundle.zip"
open .

