# Classes de documents absentes de TeX Live

- `lipics/` : classe LIPIcs (lipics-v2021.cls, logos cc-by.pdf, lipics-logo-bw.pdf, orcid.pdf),
  licence LPPL, copiée depuis https://github.com/dagstuhl-publishing/styles (LIPIcs/authors,
  commit 2c1cab7, classe : 2023/05/12 v3.1.3 LIPIcs articles). Mettre à jour en recopiant les mêmes fichiers.
- llncs (Springer LNCS, avec splncs04.bst) et acmart (ACM) sont dans TeX Live
  (Ubuntu : texlive-publishers ; MacTeX : inclus). Si un appel impose une version précise,
  la déposer dans le répertoire de l'article, elle prime sur celle de TeX Live.

Le Makefile des chantiers cherche récursivement dans lib/SHAREDDIR/STYLEDIR, donc ces
classes sont trouvées sans rien configurer. Hors chantier (brouillon dans le chat) :
https://raw.githubusercontent.com/nirzolb/SHAREDDIR/main/STYLEDIR/CLASSES/lipics/<fichier>.
