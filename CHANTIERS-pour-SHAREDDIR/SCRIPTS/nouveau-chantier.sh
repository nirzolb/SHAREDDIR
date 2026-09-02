#!/bin/bash
# Ouvre un chantier LaTeX (Olivier Bournez / Claude) à partir de SHAREDDIR/SQUELETTE.
#
#   nouveau-chantier.sh cours|expose|doc NOM [--github] [--dir BASE] [--dest FINALISE] [--no-git] [--no-make]
#
#   cours   : modèle cours-minimal.tex (+ entete-cours.tex, fin-cours.tex)
#   expose  : modèle expose-minimal.tex
#   doc     : modèle tex-minimal.tex
#   --github        crée le dépôt privé GitHub NOM avec gh et pousse le premier commit
#   --dir BASE      répertoire des chantiers (défaut : $CHANTIERS_DIR ou /Users/bournez/00-CHANTIERS-CARE)
#   --dest FINALISE chemin du répertoire finalisé, écrit dans Makefile.local
#   --no-git        ne pas initialiser git (pour un essai)
#   --no-make       ne pas lancer make deps / make à la fin
#
# Le script doit rester dans SHAREDDIR/SCRIPTS : il en déduit l'emplacement de SQUELETTE,
# LATEX-EXEMPLES, et écrit SHAREDDIR_LOCAL dans le Makefile.local du chantier.
set -euo pipefail

usage() { sed -n '2,17p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
[ $# -ge 2 ] || usage
TYPE=$1; NOM=$2; shift 2
BASE="${CHANTIERS_DIR:-/Users/bournez/00-CHANTIERS-CARE}"
GITHUB=0; DOGIT=1; DOMAKE=1; DEST=""
while [ $# -gt 0 ]; do
  case "$1" in
    --github)  GITHUB=1 ;;
    --dir)     BASE="$2"; shift ;;
    --dest)    DEST="$2"; shift ;;
    --no-git)  DOGIT=0 ;;
    --no-make) DOMAKE=0 ;;
    *) echo "option inconnue : $1"; usage ;;
  esac
  shift
done
case "$TYPE" in
  cours)  MODELE=cours-minimal ;;
  expose) MODELE=expose-minimal ;;
  doc)    MODELE=tex-minimal ;;
  *) echo "type inconnu : $TYPE (cours, expose ou doc)"; usage ;;
esac
case "$NOM" in *[!A-Za-z0-9._-]*|"") echo "NOM : lettres, chiffres, . _ - seulement"; exit 1 ;; esac

SD=$(cd "$(dirname "$0")/.." && pwd -P)
SQ="$SD/SQUELETTE"; EX="$SD/LATEX-EXEMPLES"
[ -d "$SQ" ] && [ -d "$EX" ] || { echo "SQUELETTE ou LATEX-EXEMPLES introuvable à côté de $0"; exit 1; }
[ -f "$EX/$MODELE.tex" ] || { echo "modèle $EX/$MODELE.tex introuvable"; exit 1; }
CH="$BASE/$NOM"
[ -e "$CH" ] && { echo "$CH existe déjà"; exit 1; }
DATE=$(date +%Y-%m-%d)

mkdir -p "$CH"
cp -R "$SQ/." "$CH/"
cp "$EX/$MODELE.tex" "$CH/main.tex"
if [ "$TYPE" = cours ]; then cp "$EX/entete-cours.tex" "$EX/fin-cours.tex" "$CH/"; fi

# \FIGCOMMONS redéfinissable avant \input{macros} : ligne insérée avant la première commande TeX
perl -0pi -e 's/^(\\)/\\IfFileExists{figcommons-local.tex}{\\input{figcommons-local}}{}\n$1/m' "$CH/main.tex"

# Trous du squelette
NOM="$NOM" TYPE="$TYPE" MODELE="$MODELE" DATE="$DATE" \
  perl -pi -e 's/__NOM__/$ENV{NOM}/g; s/__TYPE__/$ENV{TYPE}/g; s/__MODELE__/$ENV{MODELE}/g; s/__DATE__/$ENV{DATE}/g; s/__NOTES_SPECIFIQUES__/(à compléter)/g' \
  "$CH/CLAUDE.md" "$CH/NOTES.md"

# Réglages propres à cette machine
{
  echo "# Généré par nouveau-chantier.sh le $DATE (non versionné)."
  echo "SHAREDDIR_LOCAL = $SD"
  if [ -n "$DEST" ]; then echo "DEST = $DEST"; else echo "# DEST = /chemin/vers/le/repertoire/finalise"; fi
} > "$CH/Makefile.local"

cd "$CH"
if [ "$DOMAKE" = 1 ]; then
  make --no-print-directory deps
  if make --no-print-directory pdf; then :; else echo "ATTENTION : la compilation initiale échoue (voir main.log) ; le chantier est créé quand même."; fi
fi

if [ "$DOGIT" = 1 ]; then
  git init -q -b main 2>/dev/null || { git init -q && git checkout -q -b main; }
  IDENT=()
  if [ -z "$(git config user.name || true)" ]; then IDENT=(-c user.name=Claude-Code -c user.email=claude-code@noreply.invalid); fi
  git add -A
  git "${IDENT[@]}" commit -q -m "Ouverture du chantier $NOM ($TYPE, modèle $MODELE)"
  if [ "$GITHUB" = 1 ]; then
    if command -v gh >/dev/null 2>&1; then
      gh repo create "$NOM" --private --source=. --remote=origin --push
    else
      echo "gh absent : créer le dépôt privé à la main puis : git remote add origin <url> && git push -u origin main"
    fi
  fi
fi

echo
echo "Chantier ouvert : $CH"
echo "  main.tex (modèle $MODELE)  CLAUDE.md  NOTES.md  Makefile  .claude/"
echo "Suite : cd \"$CH\" && claude        (première fois : accepter la confiance du répertoire)"
[ "$GITHUB" = 1 ] || echo "        dépôt distant : gh repo create $NOM --private --source=. --remote=origin --push"
echo "        finalisé : DEST dans Makefile.local, puis hooks/install.sh /chemin/finalise"
