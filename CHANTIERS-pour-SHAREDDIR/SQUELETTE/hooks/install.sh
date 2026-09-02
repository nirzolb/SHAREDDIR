#!/bin/sh
# Installe le hook de protection dans un dépôt finalisé : hooks/install.sh /chemin/du/depot
set -e
d="${1:?usage: hooks/install.sh /chemin/du/depot}"
[ -d "$d/.git" ] || { echo "$d n'est pas un dépôt git" >&2; exit 1; }
here=$(cd "$(dirname "$0")" && pwd -P)
dst="$d/.git/hooks/pre-push"
if [ -e "$dst" ] && ! cmp -s "$here/pre-push-finalise" "$dst"; then
  cp "$dst" "$dst.avant-chantier"
  echo "Hook pre-push existant sauvegardé en $dst.avant-chantier"
fi
cp "$here/pre-push-finalise" "$dst"
chmod +x "$dst"
echo "Hook installé : $dst"
