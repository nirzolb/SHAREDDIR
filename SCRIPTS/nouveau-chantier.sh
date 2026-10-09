#!/bin/bash
# Ouvre un chantier LaTeX (Olivier Bournez et ses assistants) à partir de SHAREDDIR/SQUELETTE.
#
#   nouveau-chantier.sh cours|expose|doc|article NOM [--classe lipics|lncs|acm|generic] [--github] [--dir BASE] [--dest FINALISE] [--doc DOC] [--parent NOM|--sans-parent] [--no-git] [--no-make]
#
#   cours   : modèle cours-minimal.tex (+ entete-cours.tex, fin-cours.tex)
#   expose  : modèle expose-minimal.tex
#   doc     : modèle tex-minimal.tex
#   article : modèle article-<classe>-minimal.tex (défaut lipics), importe CONVENTIONS-ARTICLES.md
#   --classe C      pour un article : lipics (défaut), lncs, acm ou generic
#   --github        crée le dépôt privé GitHub NOM avec gh et pousse le premier commit
#   --dir BASE      répertoire des chantiers (défaut : $CHANTIERS_DIR ou /Users/bournez/00-CHANTIERS-CARE)
#   --dest FINALISE chemin du répertoire finalisé, écrit dans Makefile.local
#   --doc DOC       nom du document principal, DOC.tex et DOC.pdf ; défaut : NOM sans le
#                   préfixe CARE-CHANTIER-, pour que les PDF des chantiers se distinguent
#   --parent NOM    chantier dont celui-ci est né, écrit dans sa fiche CHANTIER.md ; défaut :
#                   le chantier où se trouve le répertoire courant, s'il y en a un
#   --sans-parent   ne pas déduire de parent : le chantier est une racine
#   --no-git        ne pas initialiser git (pour un essai)
#   --no-make       ne pas lancer make deps / make à la fin
#
# Le script doit rester dans SHAREDDIR/SCRIPTS : il en déduit l'emplacement de SQUELETTE,
# LATEX-EXEMPLES, et écrit SHAREDDIR_LOCAL dans le Makefile.local du chantier.
set -euo pipefail

usage() { sed -n '2,23p' "$0" | sed 's/^# \{0,1\}//'; exit 1; }
[ $# -ge 2 ] || usage
TYPE=$1; NOM=$2; shift 2
BASE="${CHANTIERS_DIR:-/Users/bournez/00-CHANTIERS-CARE}"
GITHUB=0; DOGIT=1; DOMAKE=1; DEST=""; CLASSE=lipics; DOC=""; PARENT=""; SANSPARENT=0
while [ $# -gt 0 ]; do
  case "$1" in
    --github)  GITHUB=1 ;;
    --dir)     BASE="$2"; shift ;;
    --dest)    DEST="$2"; shift ;;
    --doc)     DOC="$2"; shift ;;
    --classe)  CLASSE="$2"; shift ;;
    --parent)  PARENT="$2"; shift ;;
    --sans-parent) SANSPARENT=1 ;;
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
  article)
    case "$CLASSE" in lipics|lncs|acm|generic) MODELE=article-$CLASSE-minimal ;; *) echo "classe inconnue : $CLASSE (lipics, lncs, acm, generic)"; exit 1 ;; esac ;;
  *) echo "type inconnu : $TYPE (cours, expose, doc ou article)"; usage ;;
esac
case "$NOM" in *[!A-Za-z0-9._-]*|"") echo "NOM : lettres, chiffres, . _ - seulement"; exit 1 ;; esac
# Le document principal porte le nom du chantier sans le préfixe CARE-CHANTIER- (et non main) :
# des PDF tous appelés main.pdf ne se distinguent pas. [2 octobre 2026]
[ -n "$DOC" ] || DOC="${NOM#CARE-CHANTIER-}"
case "$DOC" in *[!A-Za-z0-9._-]*|"") echo "DOC : lettres, chiffres, . _ - seulement"; exit 1 ;; esac

SD=$(cd "$(dirname "$0")/.." && pwd -P)
SQ="$SD/SQUELETTE"; EX="$SD/LATEX-EXEMPLES"
[ -d "$SQ" ] && [ -d "$EX" ] || { echo "SQUELETTE ou LATEX-EXEMPLES introuvable à côté de $0"; exit 1; }
[ -f "$EX/$MODELE.tex" ] || { echo "modèle $EX/$MODELE.tex introuvable"; exit 1; }
CH="$BASE/$NOM"
[ -e "$CH" ] && { echo "$CH existe déjà"; exit 1; }

# Le parent : le chantier dont celui-ci est né. Par défaut, celui où se trouve le répertoire
# courant, reconnu à sa fiche ou à son mode d'emploi ; depuis un poste (worktree), on remonte
# au dépôt. SHAREDDIR, d'où l'on lance souvent ce script, n'est le parent de personne.
if [ -n "$PARENT" ] && [ "$SANSPARENT" = 1 ]; then echo "--parent et --sans-parent s'excluent"; exit 1; fi
DEDUIT=""
if [ -z "$PARENT" ] && [ "$SANSPARENT" = 0 ]; then
  T=$(git worktree list --porcelain 2>/dev/null | sed -n '1s/^worktree //p' || true)
  if [ -n "$T" ] && [ "$(cd "$T" && pwd -P)" != "$SD" ] \
     && { [ -f "$T/CHANTIER.md" ] || [ -f "$T/=LISEZ-MOI-SUR-CE-CHANTIER.md" ]; }; then
    PARENT=$(basename "$T"); DEDUIT=" (déduit du répertoire courant ; --sans-parent pour une racine)"
  fi
fi
case "$PARENT" in *[!A-Za-z0-9._=-]*) echo "--parent : un nom de chantier"; exit 1 ;; esac
[ -n "$PARENT" ] || PARENT=aucun
DATE=$(date +%Y-%m-%d)

mkdir -p "$CH"
cp -R "$SQ/." "$CH/"
cp "$EX/$MODELE.tex" "$CH/$DOC.tex"
if [ "$TYPE" = cours ]; then cp "$EX/entete-cours.tex" "$EX/fin-cours.tex" "$CH/"; fi
# Les conventions à lire : importées par CLAUDE.md pour Claude Code, nommées dans AGENTS.md
# pour les assistants qui ne suivent pas les imports.
CONVENTIONS='`lib/SHAREDDIR/CONVENTIONS-LATEX.md`'
if [ "$TYPE" = article ]; then
  perl -0pi -e 's/(\@lib\/SHAREDDIR\/CONVENTIONS-LATEX\.md\n)/$1\@lib\/SHAREDDIR\/CONVENTIONS-ARTICLES.md\n/' "$CH/CLAUDE.md"
  CONVENTIONS="$CONVENTIONS et "'`lib/SHAREDDIR/CONVENTIONS-ARTICLES.md`'
fi

# \FIGCOMMONS redéfinissable avant \input{macros} : ligne insérée avant la première commande TeX
perl -0pi -e 's/^(\\)/\\IfFileExists{figcommons-local.tex}{\\input{figcommons-local}}{}\n$1/m' "$CH/$DOC.tex"

# Trous du squelette
NOM="$NOM" TYPE="$TYPE" MODELE="$MODELE" DATE="$DATE" DOC="$DOC" CHEMIN="$CH" PARENT="$PARENT" CONVENTIONS="$CONVENTIONS" \
  perl -pi -e 's/__NOM__/$ENV{NOM}/g; s/__TYPE__/$ENV{TYPE}/g; s/__MODELE__/$ENV{MODELE}/g; s/__DATE__/$ENV{DATE}/g; s/__DOC__/$ENV{DOC}/g; s/__CHEMIN__/$ENV{CHEMIN}/g; s/__PARENT__/$ENV{PARENT}/g; s/__CONVENTIONS__/$ENV{CONVENTIONS}/g; s/__NOTES_SPECIFIQUES__/(à compléter)/g' \
  "$CH/AGENTS.md" "$CH/CLAUDE.md" "$CH/NOTES.md" "$CH/=LISEZ-MOI-SUR-CE-CHANTIER.md" "$CH/CHANTIER.md" "$CH/.publier-exclude" \
  "$CH/.codex/hooks.json"
DOC="$DOC" perl -pi -e 's/^MAIN \?= main$/MAIN ?= $ENV{DOC}/' "$CH/Makefile"

# % !TEX root en tête des fichiers inclus (entete-cours.tex, fin-cours.tex d'un cours)
( cd "$CH" && python3 "$SD/SCRIPTS/tex-root.py" "$DOC.tex" >/dev/null ) || echo "ATTENTION : tex-root.py a échoué ; make texroot plus tard."

# Réglages propres à cette machine
{
  echo "# Généré par nouveau-chantier.sh le $DATE (non versionné)."
  echo "SHAREDDIR_LOCAL = $SD"
  if [ -n "$DEST" ]; then echo "DEST = $DEST"; else echo "# DEST = /chemin/vers/le/repertoire/finalise"; fi
} > "$CH/Makefile.local"

cd "$CH"
if [ "$DOMAKE" = 1 ]; then
  make --no-print-directory deps
  if make --no-print-directory pdf; then :; else echo "ATTENTION : la compilation initiale échoue (voir $DOC.log) ; le chantier est créé quand même."; fi
fi

if [ "$DOGIT" = 1 ]; then
  git init -q -b main 2>/dev/null || { git init -q && git checkout -q -b main; }
  IDENT=()
  if [ -z "$(git config user.name || true)" ]; then IDENT=(-c user.name=Claude-Code -c user.email=claude-code@noreply.invalid); fi
  git add -A
  # ${IDENT[@]+"${IDENT[@]}"} : un tableau vide sous set -u est une erreur en bash 3.2 (macOS)
  git ${IDENT[@]+"${IDENT[@]}"} commit -q -m "Ouverture du chantier $NOM ($TYPE, modèle $MODELE)"
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
echo "  $DOC.tex (modèle $MODELE)  AGENTS.md  CLAUDE.md  NOTES.md  Makefile  .claude/  .codex/"
echo "  =LISEZ-MOI-SUR-CE-CHANTIER.md : mode d'emploi à trous, que l'assistant de la"
echo "        première session remplit."
echo "  CHANTIER.md : la fiche du registre des chantiers ; parent : $PARENT$DEDUIT"
echo "Suite : cd \"$CH\" && claude        (première fois : accepter la confiance du répertoire)"
echo "        ou ouvrir ce répertoire dans Codex : les règles sont les mêmes, dans AGENTS.md"
[ "$GITHUB" = 1 ] || echo "        dépôt distant : gh repo create $NOM --private --source=. --remote=origin --push"
echo "        finalisé : DEST dans Makefile.local, puis hooks/install.sh /chemin/finalise"
echo "        registre de tous les chantiers : $SD/SCRIPTS/etat-chantiers.sh"
