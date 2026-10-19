#!/bin/bash
# relecture.sh : la version de relecture d'un document de chantier, pour lire sur tablette.
# Les mêmes pages, au trait près ; sous chaque page, une bande avec les références citées sur la
# page et les tournures à revoir, surlignées et numérotées dans la page (STYLEDIR/relecture/).
#
# Usage, depuis le répertoire du chantier (make relecture le lance sur le document principal) :
#   lib/SHAREDDIR/SCRIPTS/relecture.sh [options] SOURCE
#     SOURCE             le document, avec ou sans .tex
#     --job NOM          le PDF produit, sans .pdf (défaut : SOURCE-relecture)
#     --defs 'TEX'       définitions faites avant \input{SOURCE}, par exemple '\def\versionlongue{1}'
#     --sans-tournures   les références seules
#     --mots LISTE       une liste personnelle de tournures, comme pour make style
#
# Passages : pdflatex, bibtex, bibtex des entrées courtes (relecture.bst sur les clés citées),
# pdflatex deux fois (les bandes au deuxième, les numéros des références au troisième), un de
# plus si LaTeX le demande. Puis les tournures : pdftotext -bbox donne la place de chaque mot,
# relecture-tournures.py y cherche celles que connaît style-anglais.py, et un dernier passage les
# dessine. La bande s'ajoute sous la page : le texte ne bouge pas, et les places restent justes.
# La première fois, le .aux, le .toc et le .bbl de la version normale servent d'amorce.
# Fichiers produits : <job>.pdf, et les intermédiaires <job>.*, <job>-refs.*, <job>-tournures.aux,
# que le .gitignore et le .publier-exclude du squelette écartent (*.pdf, *.aux, *.bbl...).

set -u
ICI=$(cd "$(dirname "$0")" && pwd)
RL=$(cd "$ICI/../STYLEDIR/relecture" 2>/dev/null && pwd) || { echo "relecture : STYLEDIR/relecture introuvable à côté de $ICI"; exit 1; }

JOB= DEFS= TOURNURES=1 MOTS= SOURCE=
while [ $# -gt 0 ]; do
  case "$1" in
    --job) JOB=${2:-}; shift 2 ;;
    --defs) DEFS=${2:-}; shift 2 ;;
    --sans-tournures) TOURNURES=; shift ;;
    --mots) MOTS=${2:-}; shift 2 ;;
    -h|--help) sed -n '2,20p' "$0" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*) echo "relecture : option inconnue $1 (--help)"; exit 1 ;;
    *) [ -z "$SOURCE" ] || { echo "relecture : un seul document"; exit 1; }; SOURCE=${1%.tex}; shift ;;
  esac
done
[ -n "$SOURCE" ] || { echo "relecture : quel document ? (--help)"; exit 1; }
[ -f "$SOURCE.tex" ] || { echo "relecture : $SOURCE.tex introuvable"; exit 1; }
[ -n "$JOB" ] || JOB=$SOURCE-relecture
[ -z "$MOTS" ] || [ -f "$MOTS" ] || { echo "relecture : liste $MOTS introuvable"; exit 1; }

# relecture.tex et relecture.bst d'abord : un fichier du même nom dans le chantier ne les cache pas.
export TEXINPUTS="$RL:${TEXINPUTS:-.:}"
export BSTINPUTS="$RL:${BSTINPUTS:-.:}"
PDFLATEX=${PDFLATEX:-pdflatex -interaction=nonstopmode -file-line-error -recorder}
CHARGE='\AddToHook{begindocument/before}{\input{relecture}}'
CHARGE_T='\AddToHook{begindocument/before}{\def\rlavectournures{}\input{relecture}}'

passe() { $PDFLATEX -jobname="$JOB" "$1$DEFS\\input{$SOURCE}" >/dev/null 2>&1; }
erreur() { echo "ERREUR pdflatex ($JOB, $1) :"; grep -n -A3 -E '^!|^[^ ]+:[0-9]+: ' "$JOB.log" | head -40; exit 1; }

rm -f "$JOB-tournures.aux"
[ -f "$JOB.aux" ] || for e in aux toc bbl; do [ ! -f "$SOURCE.$e" ] || cp "$SOURCE.$e" "$JOB.$e"; done
passe "$CHARGE" || erreur "premier passage"
if grep -q '^\\bibdata' "$JOB.aux"; then
  bibtex "$JOB" >/dev/null 2>&1 || true
  # Les clés citées, y compris dans les .aux des \include.
  aux=$(sed -n 's/^\\@input{\(.*\)}$/\1/p' "$JOB.aux")
  { grep -h -E '^\\(citation|bibdata)\{' "$JOB.aux" $aux 2>/dev/null; printf '%s\n' '\bibstyle{relecture}'; } > "$JOB-refs.aux"
  bibtex "$JOB-refs" >/dev/null 2>&1 || true
fi
passe "$CHARGE" || true
passe "$CHARGE" || erreur "troisième passage"
! grep -q 'Rerun to get' "$JOB.log" || passe "$CHARGE" || erreur "passage de plus"

t=
if [ -n "$TOURNURES" ]; then
  if ! command -v pdftotext >/dev/null 2>&1; then
    t="pas de tournures : pdftotext (poppler) manque sur cette machine"
  elif pdftotext -bbox "$JOB.pdf" - 2>/dev/null \
       | python3 "$ICI/relecture-tournures.py" --aux "$JOB.aux" ${MOTS:+--mots "$MOTS"} > "$JOB-tournures.aux"; then
    t=$(sed -n 's/^%% bilan : //p' "$JOB-tournures.aux")
    passe "$CHARGE_T" || erreur "passage des tournures"
  else
    rm -f "$JOB-tournures.aux"; t="pas de tournures : relecture-tournures.py a échoué"
  fi
fi

p=$(pdfinfo "$JOB.pdf" 2>/dev/null | awk '/^Pages/{print $2}')
echo "OK : $JOB.pdf${p:+ ($p pages)}"
r=$(grep -c '^\\rlentry' "$JOB-refs.bbl" 2>/dev/null); c=$(grep -c "Citation .* undefined" "$JOB.log")
echo "Références : ${r:-0} citée(s), $c citation(s) indéfinie(s)"
[ -z "$t" ] || echo "Tournures : $t"
