# Makefile de chantier (Olivier Bournez / Claude). GNU make 3.81+.
# Cibles : pdf (défaut), deps, sha, am, publier, importer, clean, distclean.

MAIN ?= main
NOM  := $(notdir $(CURDIR))

# Réglages propres à la machine (non versionnés) : DEST, SHAREDDIR_LOCAL, FIGCOMMONS_LOCAL...
-include Makefile.local

SHAREDDIR_URL    ?= https://github.com/nirzolb/SHAREDDIR
SHAREDDIR_LOCAL  ?= /Users/bournez/public_raw/SHAREDDIR
FIGCOMMONS_LOCAL ?= /Users/bournez/lib/LaTeX/Perso/FIG-COMMONS
PATCHDIR         ?= $(HOME)/Downloads

LIB := lib
SD  := $(LIB)/SHAREDDIR

export TEXINPUTS := .:$(SD)/STYLEDIR//:
export BIBINPUTS := .:$(SD)/BIBDESKDIR//:
export BSTINPUTS := .:$(SD)/STYLEDIR//:

PDFLATEX := pdflatex -interaction=nonstopmode -file-line-error -recorder

.PHONY: all pdf deps full strip apxversion sha am publier importer clean distclean

all: pdf

# ---------- dépendances : styles, biblio, logos ----------
deps: $(SD) figcommons-local.tex

$(SD):
	@mkdir -p $(LIB)
	@if [ -d "$(SHAREDDIR_LOCAL)" ]; then \
	  ln -s "$(SHAREDDIR_LOCAL)" "$(SD)" && echo "lib/SHAREDDIR -> $(SHAREDDIR_LOCAL)"; \
	else \
	  git clone --depth 1 -q $(SHAREDDIR_URL) "$(SD)" && echo "lib/SHAREDDIR : clone de $(SHAREDDIR_URL)"; \
	fi

# Sur une machine sans les vrais logos, logos factices + redéfinition de \FIGCOMMONS
# (lue par $(MAIN).tex avant \input{macros}, qui fait un \providecommand).
figcommons-local.tex:
	@if [ -d "$(FIGCOMMONS_LOCAL)" ]; then \
	  printf '%%%% généré par make deps : les logos sont dans %s\n' "$(FIGCOMMONS_LOCAL)" > $@; \
	else \
	  $(MAKE) --no-print-directory $(LIB)/FIG-COMMONS; \
	  printf '%%%% généré par make deps : logos factices\n\\providecommand\\FIGCOMMONS{%s}\n' "$(LIB)/FIG-COMMONS" > $@; \
	fi

$(LIB)/FIG-COMMONS:
	@mkdir -p $@
	@for l in CNRS LIX IPP X_new; do \
	  t=$$(echo $$l | tr _ ' '); \
	  printf '\\documentclass{article}\\usepackage[paperwidth=4cm,paperheight=2cm,margin=1mm]{geometry}\\pagestyle{empty}\\begin{document}\\centering\\fbox{\\parbox{3.4cm}{\\centering logo %s (factice)}}\\end{document}\n' "$$t" > $@/logo_$$l.tex; \
	  (cd $@ && pdflatex -interaction=batchmode logo_$$l.tex >/dev/null 2>&1; rm -f logo_$$l.aux logo_$$l.log logo_$$l.tex); \
	done
	@echo "lib/FIG-COMMONS : logos factices (les vrais sont absents de cette machine)"

# ---------- compilation : pdflatex, bibtex, makeindex, pdflatex x2 ----------
pdf: deps
	@$(PDFLATEX) $(MAIN) >/dev/null 2>&1 || { echo "ERREUR pdflatex (1er passage) :"; grep -n -A3 '^!\|^\./$(MAIN).tex:[0-9]*:' $(MAIN).log | head -40; exit 1; }
	@bibtex $(MAIN) >/dev/null 2>&1 || true
	@if [ -f $(MAIN).idx ]; then makeindex -q $(MAIN).idx >/dev/null 2>&1 || true; fi
	@$(PDFLATEX) $(MAIN) >/dev/null 2>&1 || true
	@$(PDFLATEX) $(MAIN) >/dev/null 2>&1 || { echo "ERREUR pdflatex (dernier passage) :"; grep -n -A3 '^!\|^\./$(MAIN).tex:[0-9]*:' $(MAIN).log | head -40; exit 1; }
	@p=$$(pdfinfo $(MAIN).pdf 2>/dev/null | awk '/^Pages/{print $$2}'); echo "OK : $(MAIN).pdf$${p:+ ($$p pages)}"
	@c=$$(grep -c "Citation .* undefined" $(MAIN).log); r=$$(grep -c "Reference .* undefined" $(MAIN).log); o=$$(grep -c "^Overfull" $(MAIN).log); \
	  echo "Avertissements : $$c citation(s) indéfinie(s), $$r référence(s) indéfinie(s), $$o overfull"; \
	  if [ "$$c" != 0 ]; then grep "Citation .* undefined" $(MAIN).log | sed 's/.*Citation .\(.*\). on page.*/  citation manquante : \1/' | sort -u | head -20; fi

# ---------- versions apxproof d'un article ----------
# make full  : preuves à leur place (appendix=inline)   -> $(MAIN)-full.pdf
# make strip : annexe supprimée     (appendix=strip)    -> $(MAIN)-strip.pdf
full: deps
	@$(MAKE) --no-print-directory apxversion APXOPT=inline APXNAME=$(MAIN)-full
strip: deps
	@$(MAKE) --no-print-directory apxversion APXOPT=strip APXNAME=$(MAIN)-strip
APXTEX = "\newcommand\apxparameter{appendix=$(APXOPT)}\input{$(MAIN)}"
apxversion:
	@$(PDFLATEX) -jobname=$(APXNAME) $(APXTEX) >/dev/null 2>&1 || { echo "ERREUR pdflatex ($(APXNAME)) :"; grep -n -A3 '^!' $(APXNAME).log | head -40; exit 1; }
	@bibtex $(APXNAME) >/dev/null 2>&1 || true
	@if [ -f $(APXNAME).idx ]; then makeindex -q $(APXNAME).idx >/dev/null 2>&1 || true; fi
	@$(PDFLATEX) -jobname=$(APXNAME) $(APXTEX) >/dev/null 2>&1 || true
	@$(PDFLATEX) -jobname=$(APXNAME) $(APXTEX) >/dev/null 2>&1 || { echo "ERREUR pdflatex ($(APXNAME)) :"; grep -n -A3 '^!' $(APXNAME).log | head -40; exit 1; }
	@p=$$(pdfinfo $(APXNAME).pdf 2>/dev/null | awk '/^Pages/{print $$2}'); echo "OK : $(APXNAME).pdf$${p:+ ($$p pages)} (appendix=$(APXOPT))"

# ---------- où en est-on ? (à citer au début de tout échange) ----------
sha:
	@printf 'Chantier : %s\n' "$(NOM)"
	@printf 'Commit   : %s\n' "$$(git log -1 --format='%h  %ad  %an  %s' --date=short 2>/dev/null || echo 'aucun commit')"
	@printf 'Branche  : %s\n' "$$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
	@if [ -n "$$(git status --porcelain 2>/dev/null)" ]; then echo "Modifications non commitées :"; git status --short; else echo "Arbre propre."; fi
	@n=$$(git rev-list --count @{u}..HEAD 2>/dev/null) && echo "Commits non poussés : $$n" || echo "Commits non poussés : ? (pas de branche distante)"

# ---------- appliquer un patch venu du chat (auteur Claude-Code conservé) ----------
# Un patch venu du chat n'a pas les lignes « index <sha>..<sha> » exploitables : les blobs
# d'origine n'existent que sur la machine, et --3way seul échoue alors sur « sha1 information
# is lacking or useless » en laissant un .git/rebase-apply qui bloque la tentative suivante.
# On tente donc git am nu d'abord, --3way seulement en second recours, avec un abort entre
# les deux et un autre en cas d'échec complet : l'arbre est toujours propre à la sortie.
am:
	@p="$(PATCH)"; [ -n "$$p" ] || p=$$(ls -t $(PATCHDIR)/chantier-*.patch 2>/dev/null | head -1); \
	  [ -n "$$p" ] || { echo "Aucun patch : make am PATCH=fichier, ou chantier-*.patch dans $(PATCHDIR)"; exit 1; }; \
	  echo "Application de $$p"; \
	  if git am "$$p"; then \
	    echo "Patch appliqué par git am (application directe)."; \
	  else \
	    git am --abort >/dev/null 2>&1 || true; \
	    echo "Application directe impossible, seconde tentative avec --3way."; \
	    if git am --3way "$$p"; then \
	      echo "Patch appliqué par git am --3way (fusion à trois points)."; \
	    else \
	      git am --abort >/dev/null 2>&1 || true; \
	      echo "Échec des deux voies (git am, puis git am --3way) ; arbre laissé propre."; \
	      echo "Demander à Claude Code d'appliquer $$p et de résoudre."; \
	      exit 1; \
	    fi; \
	  fi; \
	  $(MAKE) --no-print-directory sha

# ---------- échanges avec le répertoire finalisé (jamais de git direct là-bas) ----------
# make publier            : copie (ajouts et mises à jour) puis commit à mon nom dans DEST
# make publier MIRROR=1   : idem avec suppression dans DEST de ce qui n'est plus dans le chantier
# make publier CONTROLE=0 : passe outre le contrôle des traces (un « Claude Shannon » dans le
#                           texte, par exemple), en connaissance de cause ; le hook reste.
# Si DEST est un sous-répertoire d'un dépôt (un dossier par papier dans un dépôt partagé),
# le commit se fait dans le dépôt englobant et ne porte que sur DEST.
# Le finalisé doit se compiler seul, sans lib/ ni Makefile : ce que la dernière compilation
# a lu sous lib/ (classe, logos, macros, biblio, style bibtex), d'après $(MAIN).fls
# (pdflatex -recorder) et $(MAIN).blg, y est recopié à plat, réécrasé à chaque publication,
# et jamais réimporté (make importer l'exclut d'après la même liste).
# Règle (Olivier, 27 septembre 2026) : rien de ce qui part ne parle du chantier, de Claude
# ni de CARE. L'arbre à publier est d'abord assemblé dans un répertoire temporaire : les
# sources, puis les copies de lib/ sans les fichiers dont le nom contient « care »
# (macros-care.tex porte \IMPORTANTCARE) et sans leurs lignes de commentaire fautives.
# Une macro ou un environnement CARE, ou l'un des trois mots, dans cet arbre, et make
# publier REFUSE sans rien toucher, en listant les lignes. Le message de commit est neutre,
# et le hook pre-push (hooks/) refuse les commits dont l'auteur ou le message en parle.
# Seuls les fichiers copiés sont indexés dans DEST (plus les suppressions du miroir) : ce qui
# y a été produit par une compilation sur place, $(MAIN).axp ou $(MAIN).idx par exemple, que le
# .gitignore du dépôt partagé n'écarte pas forcément, n'entre jamais dans le commit.
DEPS_LIB = { awk '/^INPUT /{print $$2}' $(MAIN).fls 2>/dev/null; \
             sed -n 's/^Database file \#[0-9]*: //p; s/^The style file: //p' $(MAIN).blg 2>/dev/null \
               | while read -r b; do kpsewhich "$$b"; done; } | sed 's,^\./,,' | grep '^$(LIB)/' | sort -u
publier: pdf
	@[ -n "$(DEST)" ] || { echo "DEST manquant : make publier DEST=/chemin, ou DEST dans Makefile.local"; exit 1; }
	@[ -d "$(DEST)" ] || { echo "$(DEST) n'existe pas"; exit 1; }
	@[ "$(abspath $(DEST))" != "$(CURDIR)" ] || { echo "DEST est le chantier lui-même"; exit 1; }
	@st=$$(mktemp -d "$${TMPDIR:-/tmp}/publier.XXXXXX") || exit 1; trap 'rm -rf "$$st"' EXIT; \
	rsync -a --exclude-from=.publier-exclude ./ "$$st/" || exit 1; \
	copies=""; for f in $$($(DEPS_LIB)); do b=$$(basename "$$f"); \
	  case "$$(printf '%s' "$$b" | tr '[:upper:]' '[:lower:]')" in *care*) continue;; esac; copies="$$copies $$b"; \
	  case "$$b" in *.tex|*.sty|*.cls|*.clo|*.def|*.bst) \
	    awk '!((/^[[:space:]]*%/ && tolower($$0) ~ /claude|chantier|(^|[^a-z])care([^a-z]|$$)/) || tolower($$0) ~ /\\(input|inputiffileexists)\{[^}]*care/)' "$$f" > "$$st/$$b";; \
	  *) cp -p "$$f" "$$st/$$b";; esac; done; \
	t=$$(cd "$$st" && { grep -rIn -i --exclude-dir=.git --exclude='*.bib' 'claude' .; grep -rIn -i --exclude-dir=.git 'chantier' .; grep -rIn -w --exclude-dir=.git 'CARE' .; \
	  grep -rIn -E '\\[A-Za-z@]*CARE|\\(begin|end)\{[A-Za-z*]*CARE' .; } 2>/dev/null | sort -u); \
	if [ -n "$$t" ] && [ "$(CONTROLE)" != 0 ]; then echo "publier REFUSÉ, rien n'a été copié : traces de Claude, du chantier ou de CARE dans ce qui partirait :"; \
	  printf '%s\n' "$$t" | head -30 | sed 's/^/   /'; echo "(une source se corrige ici, une copie de lib/ dans SHAREDDIR/STYLEDIR ; CONTROLE=0 passe outre, en connaissance de cause)"; exit 1; \
	elif [ -n "$$t" ]; then echo "AVERTISSEMENT : contrôle des traces passé outre (CONTROLE=0) ; traces :"; printf '%s\n' "$$t" | head -30 | sed 's/^/   /'; fi; \
	rsync -a $(if $(MIRROR),--delete,) --exclude-from=.publier-exclude "$$st/" "$(DEST)/" || exit 1; \
	echo "Vérifié et copié dans $(DEST) ; copies à plat :$$copies"; \
	d=$$(cd "$(DEST)" && pwd -P); top=$$(git -C "$$d" rev-parse --show-toplevel 2>/dev/null); \
	if [ -z "$$top" ]; then echo "$(DEST) n'est pas un dépôt git : fichiers copiés, rien à committer"; exit 0; fi; \
	git -C "$$top" add -u -- "$$d" || exit 1; \
	(cd "$$st" && find . -type f | sed 's,^\./,,') | while IFS= read -r f; do git -C "$$top" add -f -- "$$d/$$f" || exit 1; done || exit 1; \
	if git -C "$$top" diff --cached --quiet -- "$$d"; then echo "Rien de nouveau à committer dans $(DEST)"; \
	else \
	  env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL \
	    git -C "$$top" commit -q -m "Mise à jour de $$(basename "$$d")" -- "$$d" || exit 1; \
	  echo "Commit dans $$top : $$(git -C "$$top" log -1 --format='%h  %an <%ae>  %s')"; \
	  echo "  (publié depuis le commit $$(git -C $(CURDIR) rev-parse --short HEAD 2>/dev/null) du chantier : à noter dans NOTES.md)"; \
	  [ "$$top" = "$$d" ] || echo "  (dépôt englobant : seul $$d a été commité)"; \
	fi; \
	if git -C "$$top" log -1 --format='%an %cn %B' | grep -q -i -E 'claude|chantier' || git -C "$$top" log -1 --format='%B' | grep -q -w 'CARE'; then \
	  echo "ATTENTION : trace de Claude, du chantier ou de CARE dans le dernier commit du finalisé, corriger avec git commit --amend"; exit 1; fi

# make importer : rapporte dans le chantier ce que les tiers ont modifié dans DEST, sauf les
# copies faites par make publier (liste DEPS_LIB, d'où la recompilation préalable).
importer: pdf
	@[ -n "$(DEST)" ] || { echo "DEST manquant : make importer DEST=/chemin, ou DEST dans Makefile.local"; exit 1; }
	@[ -d "$(DEST)" ] || { echo "$(DEST) n'existe pas"; exit 1; }
	@[ -z "$$(git status --porcelain)" ] || { echo "Arbre non propre : commiter ou remiser avant d'importer"; exit 1; }
	@x=$$($(DEPS_LIB) | while read -r f; do printf -- '--exclude=/%s ' "$$(basename "$$f")"; done); \
	  [ -z "$$x" ] || echo "Copies de lib/ laissées dans $(DEST) : $$(echo $$x | sed 's,--exclude=/,,g')"; \
	  rsync -a --exclude-from=.publier-exclude $$x "$(DEST)/" ./
	@git add -A && git commit -q -m "Import depuis le répertoire finalisé ($$(git -C "$(DEST)" rev-parse --short HEAD 2>/dev/null || echo 'sans git'))" && echo "Import commité" || echo "Rien à importer"

# ---------- ménage ----------
clean:
	@rm -f $(MAIN)-full.* $(MAIN)-strip.* $(MAIN).aux $(MAIN).log $(MAIN).bbl $(MAIN).blg $(MAIN).out $(MAIN).toc $(MAIN).lof $(MAIN).lot \
	  $(MAIN).idx $(MAIN).ind $(MAIN).ilg $(MAIN).nav $(MAIN).snm $(MAIN).vrb $(MAIN).synctex.gz $(MAIN).fls $(MAIN).fdb_latexmk

distclean: clean
	@rm -rf $(LIB) figcommons-local.tex $(MAIN).pdf
