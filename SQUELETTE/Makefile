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

PDFLATEX := pdflatex -interaction=nonstopmode -file-line-error

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
# (lue par main.tex avant \input{macros}, qui fait un \providecommand).
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
am:
	@p="$(PATCH)"; [ -n "$$p" ] || p=$$(ls -t $(PATCHDIR)/chantier-*.patch 2>/dev/null | head -1); \
	  [ -n "$$p" ] || { echo "Aucun patch : make am PATCH=fichier, ou chantier-*.patch dans $(PATCHDIR)"; exit 1; }; \
	  echo "Application de $$p"; git am --3way "$$p" && $(MAKE) --no-print-directory sha

# ---------- échanges avec le répertoire finalisé (jamais de git direct là-bas) ----------
# make publier            : copie (ajouts et mises à jour) puis commit à mon nom dans DEST
# make publier MIRROR=1   : idem avec suppression dans DEST de ce qui n'est plus dans le chantier
# Si DEST est un sous-répertoire d'un dépôt (un dossier par papier dans un dépôt partagé),
# le commit se fait dans le dépôt englobant et ne porte que sur DEST.
publier: pdf
	@[ -n "$(DEST)" ] || { echo "DEST manquant : make publier DEST=/chemin, ou DEST dans Makefile.local"; exit 1; }
	@[ -d "$(DEST)" ] || { echo "$(DEST) n'existe pas"; exit 1; }
	@[ "$(abspath $(DEST))" != "$(CURDIR)" ] || { echo "DEST est le chantier lui-même"; exit 1; }
	rsync -a $(if $(MIRROR),--delete,) --exclude-from=.publier-exclude ./ "$(DEST)/"
	@d=$$(cd "$(DEST)" && pwd -P); top=$$(git -C "$$d" rev-parse --show-toplevel 2>/dev/null); \
	if [ -n "$$top" ]; then \
	  git -C "$$top" add -A -- "$$d"; \
	  if git -C "$$top" diff --cached --quiet -- "$$d"; then \
	    echo "Rien de nouveau à committer dans $(DEST)"; \
	  else \
	    env -u GIT_AUTHOR_NAME -u GIT_AUTHOR_EMAIL -u GIT_COMMITTER_NAME -u GIT_COMMITTER_EMAIL \
	      git -C "$$top" commit -q -m "Mise à jour depuis le chantier $(NOM) ($$(git -C $(CURDIR) rev-parse --short HEAD 2>/dev/null))" -- "$$d" || exit 1; \
	    echo "Commit dans $$top : $$(git -C "$$top" log -1 --format='%h  %an <%ae>  %s')"; \
	    [ "$$top" = "$$d" ] || echo "  (dépôt englobant : seul $$d a été commité)"; \
	  fi; \
	  case "$$(git -C "$$top" log -1 --format='%an %cn')" in *[Cc]laude*) echo "ATTENTION : identité Claude dans le dépôt finalisé, corriger avec git commit --amend --reset-author"; exit 1;; esac; \
	else echo "$(DEST) n'est pas un dépôt git : fichiers copiés, rien à committer"; fi

importer:
	@[ -n "$(DEST)" ] || { echo "DEST manquant : make importer DEST=/chemin, ou DEST dans Makefile.local"; exit 1; }
	@[ -d "$(DEST)" ] || { echo "$(DEST) n'existe pas"; exit 1; }
	@[ -z "$$(git status --porcelain)" ] || { echo "Arbre non propre : commiter ou remiser avant d'importer"; exit 1; }
	rsync -a --exclude-from=.publier-exclude "$(DEST)/" ./
	@git add -A && git commit -q -m "Import depuis le répertoire finalisé ($$(git -C "$(DEST)" rev-parse --short HEAD 2>/dev/null || echo 'sans git'))" && echo "Import commité" || echo "Rien à importer"

# ---------- ménage ----------
clean:
	@rm -f $(MAIN)-full.* $(MAIN)-strip.* $(MAIN).aux $(MAIN).log $(MAIN).bbl $(MAIN).blg $(MAIN).out $(MAIN).toc $(MAIN).lof $(MAIN).lot \
	  $(MAIN).idx $(MAIN).ind $(MAIN).ilg $(MAIN).nav $(MAIN).snm $(MAIN).vrb $(MAIN).synctex.gz $(MAIN).fls $(MAIN).fdb_latexmk

distclean: clean
	@rm -rf $(LIB) figcommons-local.tex $(MAIN).pdf
