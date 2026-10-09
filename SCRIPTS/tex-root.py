#!/usr/bin/env python3
"""Pose « % !TEX root = <document principal> » en tête des fichiers inclus.

Usage, depuis le répertoire du document principal (le Makefile d'un chantier le fait) :
  tex-root.py DOC.tex              ajoute la ligne là où elle manque, corrige un root faux
  tex-root.py --verifier DOC.tex   liste ce qui manque sans rien toucher (code 1 s'il y a lieu)

Avec cette ligne, TeXShop (et la plupart des éditeurs) compile le document principal depuis
n'importe quel fichier inclus. Le script suit les \\input et \\include du document principal,
puis ceux des fichiers inclus, vers les .tex du répertoire, même quand l'un d'eux porte le
\\documentclass (entete-cours.tex). Il laisse de côté lib/, ce qui sort du répertoire, les
liens symboliques, figcommons-local.tex, et les \\subfile, faits pour se compiler seuls.
Les chemins sont relatifs au document principal, comme pour LaTeX ; la ligne posée est
relative au fichier inclus (../DOC.tex dans un sous-dossier).
Le fichier est lu et réécrit octet pour octet (utf-8 comme latin-1), fins de ligne comprises.
"""
import os
import re
import sys

EXCLUS = {"figcommons-local.tex"}
INCLUSION = re.compile(rb"\\(?:input|include)\s*\{([^}]+)\}|\\input\s+([\w./-]+)")
RACINE = re.compile(rb"^\s*%\s*!\s*TEX\s+root\s*=\s*(.*?)\s*$", re.IGNORECASE)
COMMENTAIRE = re.compile(rb"(?<!\\)%.*")


def sans_commentaires(contenu):
    return b"\n".join(COMMENTAIRE.sub(b"", l) for l in contenu.split(b"\n"))


def inclus(chemin, base):
    """Les .tex inclus par chemin, relatifs à base (le répertoire du document principal)."""
    with open(os.path.join(base, chemin), "rb") as f:
        texte = sans_commentaires(f.read())
    for m in INCLUSION.finditer(texte):
        nom = (m.group(1) or m.group(2)).strip().decode("utf-8", "replace")
        for c in (nom, nom + ".tex"):
            if c.endswith(".tex") and os.path.isfile(os.path.join(base, c)):
                yield os.path.normpath(c)
                break


def retenu(rel, base):
    absolu = os.path.join(base, rel)
    if rel in EXCLUS or rel.split(os.sep)[0] == "lib" or rel.startswith(".."):
        return False
    return not os.path.islink(absolu)


def a_traiter(principal, base):
    vus, pile, retenus = {principal}, [principal], []
    while pile:
        for rel in inclus(pile.pop(), base):
            if rel not in vus:
                vus.add(rel)
                if retenu(rel, base):
                    retenus.append(rel)
                    pile.append(rel)
    return sorted(retenus)


def etat(rel, principal, base):
    """('ok'|'manque'|'faux', numéro de la ligne root ou None, ligne attendue)."""
    attendu = os.path.relpath(os.path.join(base, principal), os.path.dirname(os.path.join(base, rel)))
    with open(os.path.join(base, rel), "rb") as f:
        lignes = f.read().split(b"\n")
    for i, l in enumerate(lignes[:20]):
        m = RACINE.match(l.rstrip(b"\r"))
        if m:
            vise = os.path.normpath(os.path.join(os.path.dirname(rel), m.group(1).decode("utf-8", "replace")))
            return ("ok" if vise == os.path.normpath(principal) else "faux"), i, attendu
    return "manque", None, attendu


def corrige(rel, statut, i, attendu, base):
    chemin = os.path.join(base, rel)
    with open(chemin, "rb") as f:
        contenu = f.read()
    fin = b"\r\n" if contenu.split(b"\n", 1)[0].endswith(b"\r") else b"\n"
    ligne = ("% !TEX root = " + attendu).encode("utf-8")
    lignes = contenu.split(b"\n")
    if statut == "faux":
        lignes[i] = ligne + (b"\r" if lignes[i].endswith(b"\r") else b"")
        contenu = b"\n".join(lignes)
    else:
        contenu = ligne + fin + contenu
    with open(chemin, "wb") as f:
        f.write(contenu)


def main(args):
    verifier = "--verifier" in args
    args = [a for a in args if a != "--verifier"]
    if len(args) != 1:
        sys.exit(__doc__)
    base, principal = os.path.split(os.path.abspath(args[0]))
    if not principal.endswith(".tex"):
        principal += ".tex"
    if not os.path.isfile(os.path.join(base, principal)):
        sys.exit("tex-root : %s introuvable" % args[0])
    manque, faux = [], []
    for rel in a_traiter(principal, base):
        statut, i, attendu = etat(rel, principal, base)
        if statut == "ok":
            continue
        (manque if statut == "manque" else faux).append(rel)
        if not verifier:
            corrige(rel, statut, i, attendu, base)
    if verifier:
        if manque:
            print("  % !TEX root absent : " + ", ".join(manque) + " (make texroot)")
        if faux:
            print("  % !TEX root faux : " + ", ".join(faux) + " (make texroot)")
        return 1 if manque or faux else 0
    for liste, quoi in ((manque, "ajouté"), (faux, "corrigé")):
        if liste:
            print("% !TEX root " + quoi + " : " + ", ".join(liste))
    if not manque and not faux:
        print("% !TEX root : rien à faire")
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
