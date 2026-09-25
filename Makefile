# SHAREDDIR : styles, bibliographie, modèles, squelette et scripts de chantier.
# Ce Makefile ne construit rien : il n'apporte que les cibles de chantier.
# La mise en ligne passe par do-public_raw-update.command, pas par make.

NOM      := SHAREDDIR
PATCHDIR ?= $(HOME)/Downloads

.PHONY: help sha am

help:
	@echo "make sha : commit courant, branche, modifications non commitées, commits non poussés"
	@echo "make am  : applique le dernier chantier-*.patch de $(PATCHDIR)"
	@echo
	@echo "Publier : ./do-public_raw-update.command (git add -A, commit, push)."
	@echo "Ce dépôt est public : relire le diff avant."

sha:
	@printf 'Dépôt   : %s (public)\n' "$(NOM)"
	@printf 'Commit  : %s\n' "$$(git log -1 --format='%h  %ad  %an  %s' --date=short 2>/dev/null || echo 'aucun commit')"
	@printf 'Branche : %s\n' "$$(git rev-parse --abbrev-ref HEAD 2>/dev/null || echo '?')"
	@if [ -n "$$(git status --porcelain 2>/dev/null)" ]; then echo "Modifications non commitées :"; git status --short; else echo "Arbre propre."; fi
	@n=$$(git rev-list --count @{u}..HEAD 2>/dev/null) && echo "Commits non poussés : $$n" || echo "Commits non poussés : ? (pas de branche distante)"

am:
	@p="$(PATCH)"; [ -n "$$p" ] || p=$$(ls -t $(PATCHDIR)/chantier-*.patch 2>/dev/null | head -1); \
	  [ -n "$$p" ] || { echo "Aucun patch : make am PATCH=fichier, ou chantier-*.patch dans $(PATCHDIR)"; exit 1; }; \
	  echo "Application de $$p"; git am --abort 2>/dev/null; \
	  if git apply --index "$$p" 2>/dev/null; then echo "Appliqué directement ; le commit reste à faire."; \
	  elif git am --3way "$$p"; then echo "Appliqué par git am --3way."; \
	  else echo "Échec : demander à Claude Code d'appliquer le patch et de résoudre."; exit 1; fi; \
	  $(MAKE) --no-print-directory sha
