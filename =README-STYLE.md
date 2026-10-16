# Faire corriger son anglais dans un chantier

L'aide-mémoire pour demander à Claude Code ou à Codex de mettre un texte anglais à ton style.
Les règles elles-mêmes sont dans `STYLE-ANGLAIS.md`, la fiche ; ce fichier dit seulement quoi
demander et comment vérifier. Depuis un chantier, il est à `lib/SHAREDDIR/=README-STYLE.md`.

## Ce qu'il faut dire

Nommer le mode de la fiche : c'est lui qui fixe jusqu'où l'assistant a le droit d'aller.

| Tu veux | Tu écris | Tu obtiens |
|---|---|---|
| tes fautes corrigées, rien d'autre | « Correction minimale de la section 2 de intro.tex, selon la fiche de style. » | les fautes corrigées ; les phrases de plus de 40 mots signalées à la fin avec une coupe proposée, pas coupées |
| le texte remis d'aplomb, avec tes mots | « Reprise de l'introduction selon la fiche de style. » | les phrases longues coupées, l'ordre revu dans la phrase ou le paragraphe, puis quelques lignes sur ce qui a changé au-delà des fautes |
| un passage écrit à partir de notes | « Rédige la section 4 à partir de ces notes, selon la fiche de style. » | un texte dans ta voix, sans phrase de plus de 40 mots, vérifié contre ce qu'il ne faut pas écrire |

Si tu donnes un texte sans rien préciser, c'est la correction minimale.

À ajouter selon le cas :

- « puis lance `make style` et dis-moi ce qui sort de la plage » : l'assistant vérifie son
  propre travail avec le script ;
- « ce paragraphe est d'un coauteur » : il est corrigé au minimum, sans être ramené à ta
  voix.

À ne pas écrire : « polis », « fluidifie », « rends plus académique », « améliore le style ».
La fiche interdit justement ce que ces mots demandent, et l'assistant hésitera entre les deux.

## Vérifier soi-même

Dans le terminal, depuis le chantier :

```
make style                         le document principal
make style FICHIER=sections/intro.tex
make style PROFIL=solo             comparé à tes textes écrits seul
make style MOTS=~/ma-liste.txt     cherche aussi tes tournures à toi (une par ligne)
```

Le rapport ne modifie rien. Il donne, dans l'ordre :

1. les mesures du texte face à ta plage habituelle (« we », points-virgules, longueur des
   phrases...), avec un statut pour chacune ;
2. les tournures d'assistant repérées ;
3. les fautes et calques venus du français, avec la correction suggérée ;
4. les phrases de plus de 40 mots.

Il faut quelques centaines de mots pour que les mesures veuillent dire quelque chose : en
dessous de 300, le script ne les donne pas et ne dresse que les listes. Une mesure hors de la
plage signale un passage à relire, pas une faute ; un très bon texte de toi peut en sortir.

## Selon le chantier

- **Article ouvert depuis le 16 octobre 2026** : la fiche est chargée d'office, `make style`
  existe. Rien à faire de plus.
- **Chantier plus ancien, ou qui n'est pas un article** (ANR, cours en anglais...) :
  commencer par « Lis `lib/SHAREDDIR/STYLE-ANGLAIS.md` », puis la même demande. Si `make style`
  répond « No rule to make target », la commande directe fait la même chose :

  ```
  python3 lib/SHAREDDIR/SCRIPTS/style-anglais.py DOC.tex
  ```

  Pour l'avoir pour de bon, demander le portage depuis SHAREDDIR.
- **Codex** : les mêmes phrases. Dans un article récent, son `AGENTS.md` lui nomme la fiche ;
  ailleurs, lui dire aussi « Lis `lib/SHAREDDIR/STYLE-ANGLAIS.md` ».
- **Depuis le chat** : coller le lien de la fiche,
  https://raw.githubusercontent.com/nirzolb/SHAREDDIR/main/STYLE-ANGLAIS.md, avec la demande.
