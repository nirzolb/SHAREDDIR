#!/usr/bin/env python3
"""Repère, page par page, les tournures à revoir d'une version de relecture (make relecture).

Usage (SCRIPTS/relecture.sh le lance entre ses passages) :
  pdftotext -bbox JOB.pdf - | python3 relecture-tournures.py --aux JOB.aux [--mots LISTE] > JOB-tournures.aux

Entrée : la place de chaque mot du PDF, en points PostScript depuis le coin haut gauche de la page.
Le texte de chaque page est recomposé (mots coupés en fin de ligne recollés), découpé en phrases
comme dans style-anglais.py, et on y cherche ce que ce script connaît déjà (§4 de STYLE-ANGLAIS.md) :
  f  les tournures d'assistant et les mots de la liste forte, et ceux de LISTE ;
  v  les indices faibles, marqués « (à vérifier) » dans la fiche ;
  c  les fautes et calques venus du français, avec la correction suggérée.
Sortie : les commandes que lit STYLEDIR/relecture/relecture.tex au dernier passage (fonds, traits,
numéros dans la marge, lignes de la bande), et une ligne « %% bilan : ... ».
On ne cherche ni dans la bande (sous \\rlhauteur, lu dans JOB.aux), ni dans la bibliographie (pages
données par \\rlbiblio, à partir de son titre), ni dans une page surtout en français : la fiche
ne vaut que pour l'anglais. Le texte des formules passe tel que pdftotext le rend ; un motif n'y
prend presque jamais. Python 3.8 ou plus, bibliothèque standard seule.
"""
import html
import importlib.util
import os
import re
import sys
import unicodedata

ICI = os.path.dirname(os.path.abspath(__file__))
_spec = importlib.util.spec_from_file_location("style_anglais", os.path.join(ICI, "style-anglais.py"))
SA = importlib.util.module_from_spec(_spec)
_spec.loader.exec_module(SA)

PAGE = re.compile(r'<page width="([\d.]+)" height="([\d.]+)">')
MOT = re.compile(r'<word xMin="([\d.]+)" yMin="([\d.]+)" xMax="([\d.]+)" yMax="([\d.]+)">(.*?)</word>')
TITRE_NUMERO = re.compile(r"^(S?\d+(\.\d+)*\.?\s+)+[A-Z]")   # titre de section : ni question ni point-virgule
TITRE_BIBLIO = re.compile(r"^(\d+\.?\s+)?(references|bibliography|références|bibliographie)$", re.I)
FR = re.compile(r"\b(le|la|les|des|du|une|est|sont|dans|pour|avec|sur|que|qui|pas|cette|nous)\b", re.I)
EN = re.compile(r"\b(the|of|and|is|are|in|for|with|on|that|which|not|this|we|to)\b", re.I)
PT_BP = 72 / 72.27
COULEURS = {"f": "rlfort", "c": "rlfaute"}
RANG = {"f": 0, "c": 1, "v": 2}
TYPO = {"\u2019": "'", "\u2018": "'", "\u201c": '"', "\u201d": '"', "\u00a0": " ", "\u2212": "-"}


def lire_aux(chemin):
    """Hauteur de la page sans bande (bp) et pages de début et de fin de la bibliographie."""
    hauteur, debut, fin = None, [], []
    try:
        with open(chemin, encoding="latin-1") as f:
            for ligne in f:
                m = re.match(r"\\rlhauteur\{([\d.]+)pt\}", ligne)
                if m:
                    hauteur = float(m.group(1)) * PT_BP
                m = re.match(r"\\rlbiblio\{(debut|fin)\}\{(\d+)\}", ligne)
                if m:
                    (debut if m.group(1) == "debut" else fin).append(int(m.group(2)))
    except OSError:
        pass
    return hauteur, list(zip(debut, fin + [10 ** 6] * (len(debut) - len(fin))))


def pages(flux):
    """Les pages de pdftotext -bbox : [(largeur, hauteur, [(x0, y0, x1, y1, mot)])]."""
    out = []
    for ligne in flux:
        m = PAGE.search(ligne)
        if m:
            out.append((float(m.group(1)), float(m.group(2)), []))
            continue
        m = MOT.search(ligne)
        if m and out:
            mot = unicodedata.normalize("NFKC", html.unescape(m.group(5)))
            mot = "".join(TYPO.get(ch, ch) for ch in mot)
            out[-1][2].append(tuple(float(m.group(i)) for i in range(1, 5)) + (mot,))
    return out


def lignes(mots):
    """Numéro de ligne de chaque mot : on change de ligne quand y saute ou que x revient en arrière."""
    num, n, prec = [], 0, None
    for x0, y0, x1, y1, _ in mots:
        if prec and (abs(y0 - prec[1]) > 0.5 * min(y1 - y0, prec[3] - prec[1]) or x0 < prec[0] - 1):
            n += 1
        num.append(n)
        prec = (x0, y0, x1, y1)
    return num


def texte(mots, num):
    """Texte de la page et place de chaque mot dans ce texte ; un mot coupé en fin de ligne est recollé."""
    t, places = "", []
    for i, m in enumerate(mots):
        mot = m[4]
        coupe = (mot.endswith("-") and len(mot) > 2 and mot[-2].isalpha() and i + 1 < len(mots)
                 and num[i + 1] != num[i] and mots[i + 1][4][:1].islower())
        if t and not (i and places[-1][2]):
            t += " "
        debut = len(t)
        t += mot[:-1] if coupe else mot
        places.append((debut, len(t), coupe))
    return t, [(a, b) for a, b, _ in places]


def phrases(t):
    """Les phrases de la page (découpage de style-anglais.py), avec leur place dans le texte."""
    out, pos = [], 0
    for s in SA.decoupe(t):
        i = t.find(s, pos)
        if i < 0:
            continue
        out.append((i, s))
        pos = i + len(s)
    return out


def raison(categorie, etiquette, prise):
    """La raison affichée : la catégorie, et l'étiquette de la fiche si elle dit plus que la prise."""
    nu = re.sub(r"\(.*?\)", "", etiquette).strip().lower()
    return categorie if not nu or nu in prise.lower() else "%s (%s)" % (categorie, etiquette)


def prises(t, perso):
    """Les tournures de la page : [(début, fin, genre, raison)], les prises qui se chevauchent fusionnées."""
    brut = []
    for o, s in phrases(t):
        for m in SA.SIGNALES.finditer(s):
            brut.append((o + m.start(), o + m.end(), "f", "mot de LLM (liste forte)"))
        titre = TITRE_NUMERO.match(s)
        for e, rx in SA.TOURNURES + perso:
            if titre and e in SA.PROSE_SEULE:
                continue
            for m in rx.finditer(s):
                if m.end() > m.start():
                    faible = "(à vérifier)" in e
                    brut.append((o + m.start(), o + m.end(), "v" if faible else "f",
                                 raison("à vérifier" if faible else "tournure d'assistant",
                                        e.replace(" (à vérifier)", ""), m.group(0))))
        for _, g, rx, note, neg in SA.FAUTES:
            for m in rx.finditer(s):
                if neg is None or not neg.search(s[max(0, m.start() - 25):m.start()]):
                    note = re.sub(r"^→\s*", "écrire ", note)
                    brut.append((o + m.start(), o + m.end(), "c",
                                 ("faute" if g == "e" else "calque") + (" : " + note if note else "")))
    out = []
    for a, b, g, r in sorted(brut):
        if out and a < out[-1][1]:
            a0, b0, g0, r0 = out[-1]
            out[-1] = (a0, max(b, b0), min(g, g0, key=RANG.get), r0 if r in r0.split(" ; ") else r0 + " ; " + r)
        else:
            out.append((a, b, g, r))
    return out


def tex(s, n=90):
    """Texte sûr pour LaTeX : caractères spéciaux protégés, ce qui n'est pas du latin retiré."""
    s = s if len(s) <= n else s[:n - 1].rstrip() + "…"
    spec = {"\\": r"\textbackslash{}", "#": r"\#", "$": r"\$", "%": r"\%", "&": r"\&", "_": r"\_",
            "{": r"\{", "}": r"\}", "^": r"\^{}", "~": r"\~{}", "<": r"\textless{}", ">": r"\textgreater{}",
            "|": r"\textbar{}", '"': "''", "\u2014": "---", "\u2013": "--", "…": r"\ldots{}",
            "→": r"\ensuremath{\to}", "«": "``", "»": "''"}
    out = []
    for ch in s:
        if ch in spec:
            out.append(spec[ch])
        elif ord(ch) < 128 or ("À" <= ch <= "ÿ" and ch not in "×÷"):
            out.append(ch)
        else:
            out.append("".join(c for c in unicodedata.normalize("NFKD", ch) if ord(c) < 128))
    return "".join(out)


def dessin(p, t, mots, num, places, liste, gauche):
    """Les commandes d'une page : fonds, traits, numéros dans la marge, lignes de la bande."""
    out, marge = [], {}
    for k, (a, b, g, r) in enumerate(liste, 1):
        touches = [i for i, (x, y) in enumerate(places) if x < b and y > a]
        if not touches:
            continue
        groupes = []
        for i in touches:
            if groupes and num[groupes[-1][-1]] == num[i]:
                groupes[-1].append(i)
            else:
                groupes.append([i])
        for gr in groupes:
            x0, x1 = mots[gr[0]][0] - 0.6, mots[gr[-1]][2] + 0.6
            y0, y1 = min(mots[i][1] for i in gr) - 0.4, max(mots[i][3] for i in gr) + 0.4
            if g in COULEURS:
                out.append(r"\rlfond{%d}{%s}{%.2f}{%.2f}{%.2f}{%.2f}" % (p, COULEURS[g], x0, -y1, x1 - x0, y1 - y0))
                out.append(r"\rltrait{%d}{%.2f}{%.2f}{%.2f}" % (p, x0, -y1 - 1.0, x1 - x0))
            else:
                out.append(r"\rlpointille{%d}{%.2f}{%.2f}{%d}" % (p, x0, -y1 - 1.0, max(1, int((x1 - x0) / 3))))
        y0, y1 = mots[groupes[0][0]][1], mots[groupes[0][0]][3]
        ligne = num[groupes[0][0]]
        marge.setdefault(ligne, [(y0 + y1) / 2, []])[1].append((k, g))
        phrase = t[places[touches[0]][0]:places[touches[-1]][1]]
        out.append(r"\rltournure{%d}{%d}{%s}{%s}{%s}" % (p, k, g, tex(phrase), tex(r, 160)))
    for y, ks in marge.values():
        couleur = "rlgris" if all(g == "v" for _, g in ks) else "rltrait"
        out.append(r"\rlnum{%d}{%s}{%.2f}{%.2f}{%s}" % (p, couleur, max(8.0, gauche - 4), -y,
                                                       ",".join(str(k) for k, _ in ks)))
    return out


def main(args):
    if "-h" in args or "--help" in args or "--aux" not in args:
        print(__doc__)
        return 0 if "--aux" not in args and ("-h" in args or "--help" in args) else 1
    aux = args[args.index("--aux") + 1]
    perso = SA.mots_perso(args[args.index("--mots") + 1]) if "--mots" in args else []
    hauteur, biblio = lire_aux(aux)
    out, bilan, sautees = [], {"f": 0, "v": 0, "c": 0}, 0
    for p, (_, h, tous) in enumerate(pages(sys.stdin), 1):
        bas = (hauteur or h) - 0.5
        mots = [m for m in tous if m[1] < bas]
        if not mots:
            continue
        num = lignes(mots)
        for d, f in biblio:
            if p == d:
                # La bibliographie commence à son titre ; sans titre reconnu, toute la page est écartée.
                txt = {}
                for m, n in zip(mots, num):
                    txt.setdefault(n, []).append(m[4])
                titres = [n for n, ms in txt.items() if TITRE_BIBLIO.match(" ".join(ms))]
                garde = [i for i, n in enumerate(num) if titres and n < titres[-1]]
                mots, num = [mots[i] for i in garde], [num[i] for i in garde]
            elif d < p <= f:
                mots, num = [], []
        if not mots:
            continue
        t, places = texte(mots, num)
        if len(FR.findall(t)) > len(EN.findall(t)):
            sautees += 1
            continue
        liste = prises(t, perso)
        for _, _, g, _ in liste:
            bilan[g] += 1
        gauche = min(m[0] for m in mots)
        out += dessin(p, t, mots, num, places, liste, gauche)
    n = sum(bilan.values())
    resume = ("%d repérée%s (%d d'assistant, %d fautes ou calques, %d à vérifier)" % (
        n, "s" if n > 1 else "", bilan["f"], bilan["c"], bilan["v"]) if n else "aucune repérée")
    if sautees:
        resume += " ; %d page%s en français laissée%s de côté" % (sautees, "s" if sautees > 1 else "",
                                                                  "s" if sautees > 1 else "")
    print("%% relecture-tournures.py : les tournures, pour relecture.tex (dernier passage)")
    print("%% bilan : " + resume)
    print("\n".join(out))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))
