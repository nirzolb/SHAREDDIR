#!/bin/sh
# Installe le hook de protection dans le dépôt du finalisé : hooks/install.sh /chemin/du/finalise
set -e
d="${1:?usage: hooks/install.sh /chemin/du/finalise}"
[ -d "$d" ] || { echo "$d n'existe pas" >&2; exit 1; }
# DEST peut être un sous-répertoire d'un dépôt partagé (un dossier par papier) : le hook
# se pose sur le dépôt qui le contient.
top=$(git -C "$d" rev-parse --show-toplevel 2>/dev/null) || true
[ -n "$top" ] || { echo "$d n'est dans aucun dépôt git" >&2; exit 1; }
[ "$top" = "$(cd "$d" && pwd -P)" ] || echo "Dépôt englobant : $top"
here=$(cd "$(dirname "$0")" && pwd -P)
hd=$(cd "$top" && git rev-parse --git-path hooks)   # gère aussi .git fichier (worktree)
case "$hd" in /*) ;; *) hd="$top/$hd";; esac
mkdir -p "$hd"
dst="$hd/pre-push"
if [ -e "$dst" ] && ! cmp -s "$here/pre-push-finalise" "$dst"; then
  cp "$dst" "$dst.avant-chantier"
  echo "Hook pre-push existant sauvegardé en $dst.avant-chantier"
fi
cp "$here/pre-push-finalise" "$dst"
chmod +x "$dst"
echo "Hook installé : $dst"
