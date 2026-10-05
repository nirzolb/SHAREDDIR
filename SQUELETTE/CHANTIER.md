# Fiche du chantier __NOM__

Ce que git ne sait pas de ce chantier. `SCRIPTS/etat-chantiers.sh` de SHAREDDIR la lit pour
dresser le registre de tous les chantiers : les lignes « Parent » et « En bref » et celles
du journal gardent leur forme, chacune sur une seule ligne.

- Parent : __PARENT__
- En bref : __A_REMPLIR : de quoi il s'agit, en une ou deux phrases__

## Journal

Une ligne datée par événement : `ouvert`, `clos (raison)`, `rouvert (raison)`. La dernière
donne l'état du chantier. Clore ou rouvrir est une décision d'Olivier.

- __DATE__ ouvert
