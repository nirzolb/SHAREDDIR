# Relire un document sur la tablette

L'aide-mémoire de `make relecture`. Depuis un chantier, ce fichier est à
`lib/SHAREDDIR/=README-RELECTURE.md`.

## Ce que ça donne

Un PDF à côté du document, `<document>-relecture.pdf`. Il a les mêmes pages, au trait près :
même pagination, rien ne bouge dans le texte. Sous chaque page qui en a besoin, la page est
allongée d'une bande grise qui donne :

- **les références citées sur cette page** : numéro, auteurs, titre, lieu, année. Le numéro
  est un lien vers la bibliographie ;
- **les tournures à revoir** sur cette page, numérotées, avec leur raison.

Dans le texte, chaque tournure repérée est marquée à sa place, et son numéro est dans la
marge de gauche :

| Marque | Ce que c'est | Exemples |
|---|---|---|
| fond jaune, trait plein bleu foncé | tournure d'assistant, mot typique des LLM | delve, pivotal, seamlessly, it is worth noting, not merely, tiret cadratin |
| fond bleu clair, trait plein bleu foncé | faute ou calque venu du français ; la bande donne la correction | allows to compute, it exists a, depends of, in a first time |
| pointillé gris, sans fond | indice faible, souvent légitime : à vérifier | rather than, une question dans la prose, un point-virgule entre deux propositions |

La bande dit toujours en toutes lettres de quoi il s'agit : la couleur n'est jamais le seul
indice. Les listes sont celles de `STYLE-ANGLAIS.md` (§4) et de `make style` ; les mesures
et les phrases de plus de 40 mots n'y sont pas, elles restent dans `make style`.

Le PDF de relecture n'est pas suivi par git et ne part jamais vers le finalisé.

## Dans un chantier ouvert depuis le 19 octobre 2026

Dans le terminal, depuis le répertoire du chantier :

```
make relecture                            le document principal
make relecture TOURNURES=non              les références seules
make relecture FICHIER=autre.tex          un autre document du chantier
make relecture MOTS=~/ma-liste.txt        cherche aussi tes tournures à toi (une par ligne)
```

Ou, à Claude Code ou à Codex : « fais-moi la version de relecture ».

## Dans un chantier plus ancien

**Tout de suite, sans rien changer au chantier.** Depuis son répertoire, en remplaçant
`DOC` par le nom du document principal (celui du chantier, sans le préfixe CARE-CHANTIER-) :

```
lib/SHAREDDIR/SCRIPTS/relecture.sh DOC.tex
lib/SHAREDDIR/SCRIPTS/relecture.sh --sans-tournures DOC.tex
```

Si la réponse est « No such file or directory », `lib/` manque : `make deps`, puis la même
commande.

**Pour avoir `make relecture` pour de bon**, il faut un portage. Dans une session Claude
Code ouverte sur ce chantier, après `/reprise`, écrire :

« Porte make relecture depuis SHAREDDIR dans ce chantier. »

L'assistant vérifie que le chantier est libre, ajoute la commande au Makefile et au mode
d'emploi du chantier, compile pour vérifier, commite à son nom et le note dans NOTES.md.

CARE-CHANTIER-SURVEY-2026 est à part : il a sa propre commande `make relecture`, plus
ancienne, qui donne les références sans les tournures. Jusqu'à son portage, la commande
directe ci-dessus donne la nouvelle version.

## Ce qu'il ne faut pas en attendre

- C'est une recherche de motifs, pas un jugement : une marque désigne un passage à relire,
  pas une faute certaine. Sur un texte déjà repris au style, il ne reste presque que du gris.
- Les tournures ne valent que pour l'anglais : une page surtout en français est laissée de
  côté. Rien n'est cherché dans la bibliographie.
- La bibliographie doit passer par bibtex (le cas de tous les modèles) ; avec biblatex, la
  bande des références ne vient pas.
- Ce qui dépasse le bas d'une page dans le PDF normal (un flottant trop grand, signalé par
  « Float too large » dans le .log) devient visible et chevauche la bande : c'est le
  document qu'il faut corriger.

## Si ça coince

| Symptôme | Remède |
|---|---|
| `make: *** No rule to make target 'relecture'` | chantier pas encore porté : la commande directe ci-dessus |
| « ERREUR pdflatex » | le document lui-même ne compile pas : `make` d'abord, et corriger |
| « pas de tournures : pdftotext manque » | sur une machine sans poppler ; les références viennent quand même |
| une tournure marquée à tort | rien à faire, c'est un indice ; si elle revient souvent, le dire à Claude dans SHAREDDIR |
