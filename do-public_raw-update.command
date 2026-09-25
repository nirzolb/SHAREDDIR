
cd /Users/bournez/public_raw/SHAREDDIR
# -A et non * */* : l'ancienne forme laissait de cote les fichiers caches,
# donc .claude/ et .gitignore, qui ne partaient jamais. [25 septembre 2026]
git add -A
git commit -m "Update "
git push
