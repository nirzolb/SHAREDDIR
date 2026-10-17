#!/bin/sh
# Ancien raccourci, gardé pour qui l'ouvre depuis BIBDESKDIR : il lance celui de SHAREDDIR,
# qui recopie la bibliographie depuis BibDesk avant de commiter et de pousser tout le dépôt.
# Il faisait autrefois git add *, qui oubliait les fichiers cachés. [17 octobre 2026]
exec /bin/sh /Users/bournez/public_raw/SHAREDDIR/do-public_raw-update.command
