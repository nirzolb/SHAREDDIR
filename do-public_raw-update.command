
cd /Users/bournez/public_raw/SHAREDDIR
# D'abord la copie publique de la bibliographie, depuis BibDesk : le chat ne voit que celle de
# GitHub. Seuls les .bib déjà publiés sont recopiés. [17 octobre 2026]
./SCRIPTS/copie-bib.sh
# -A et non * */* : l'ancienne forme laissait de cote les fichiers caches,
# donc .claude/ et .gitignore, qui ne partaient jamais. [25 septembre 2026]
git add -A
git commit -m "Update "
git push
