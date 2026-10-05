---
description: Régénère le registre des chantiers et le recopie dans la base Notion « Chantiers »
---
Mise à jour du registre des chantiers et de sa vitrine Notion. Consigne éventuelle : $ARGUMENTS

1. Lance `SCRIPTS/etat-chantiers.sh --fetch` ; sans `--fetch` si le réseau manque, et dis-le.
   Il écrit `CHANTIERS.md` et `CHANTIERS.json` sous `~/00-CHANTIERS-CARE`, hors de ce dépôt.
2. Lis `CHANTIERS.json`. C'est la seule source de la recopie : ne rien déduire d'ailleurs.
3. Dans Notion, la base « Chantiers » est sous « Suivi de projets ». Lis ses lignes puis,
   pour chaque chantier du JSON, mets à jour la ligne dont le titre est son `nom`, ou
   crée-la. La correspondance :

   | JSON | Notion |
   |---|---|
   | `nom` | Chantier (le titre) |
   | `profondeur` | Niveau : une flèche ↳ par génération, séparées par une espace ; vide pour une racine |
   | `parent` | Né de : la ligne de ce chantier ; vide pour une racine |
   | `etat` | État |
   | `derniere_activite`, `par` | Dernière activité, Par |
   | `a_voir`, `en_bref` | À voir, En bref |
   | `ouvert`, `intervenants` | Ouvert, Intervenants |
   | `finalise`, `branche`, `chemin`, `journal` | Finalisé, Branche, Chemin, Journal |
   | `depot_distant` | Dépôt, précédé de `https://github.com/` s'il n'a pas de schéma |
   | `ordre` | Ordre |

   Un champ vide dans le JSON vide la colonne.
4. Une ligne de la base dont le chantier n'est plus dans le JSON n'est pas supprimée :
   signale-la à Olivier.
5. Réécris la description de la base en entier, en un seul appel, avec le texte ci-dessous
   (une seule ligne), où `engendre` et `machine` du JSON prennent la place de `<engendre>`
   et de `<machine>`. Le connecteur ne permet pas de relire la description : ne cherche
   l'ancien texte nulle part, ni dans Notion ni dans d'anciennes conversations.

   ```text
   Vitrine du registre des chantiers. Ne rien corriger ici : la base est recopiée depuis ~/00-CHANTIERS-CARE/CHANTIERS.json, qu'engendre SHAREDDIR/SCRIPTS/etat-chantiers.sh à partir de git et des fiches CHANTIER.md. Ce qui est faux se corrige dans la fiche du chantier. Dernière recopie : relevé du <engendre> sur <machine>.
   ```
6. Termine par ce qui a changé depuis la recopie précédente, en trois lignes au plus :
   chantiers nouveaux, états changés, ce qui est « à voir ».

Rappels. La base est une vitrine : on n'y corrige rien à la main ; ce qui est faux se
corrige dans la fiche `CHANTIER.md` du chantier, puis on relance. Une valeur nouvelle de
« Par » ou d'« État » reçoit une couleur parmi bleu, jaune et gris, jamais une autre. Le
registre nomme des chantiers privés : rien de lui n'entre dans ce dépôt.
