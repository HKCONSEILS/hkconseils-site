#!/usr/bin/env python3
"""
check-jsonld.py — porte AC3.

Vérifie que le bloc JSON-LD de public/index.html :
  1. est du JSON valide, structuré en @graph ;
  2. contient les nœuds exigés par la directive : ProfessionalService, Person,
     cinq Service, un FAQPage ;

     SITE-01d — la reprise en pleine propriété d'applications devient un service
     nommé : nœud `#reprise-actifs`, vérifié par son @id comme `#editos`. Le socle
     FAQ passe à 7 questions.

     D-site-08 v2 — Editos est décrit en Service et non plus en Product. Product
     est un type à résultat enrichi : Search Console y réclame offers, review et
     aggregateRating, qu'une application interne sans prix public ni avis ne peut
     fournir sans les inventer. Service n'appelle pas ces propriétés, et l'entité
     reste comprise du graphe. Le script refuse donc désormais tout nœud Product.
  3. porte les propriétés minimales attendues sur chaque nœud ;
  4. — le point qui casse le plus souvent en silence — expose des questions et
     réponses FAQ **strictement identiques** au texte rendu dans le DOM.
     Google déclasse un FAQPage dont le balisage ne correspond pas au visible.

Aucune dépendance externe : bibliothèque standard uniquement.
Sortie 0 si tout passe, 1 sinon.
"""
import json
import re
import sys
import unicodedata
from html.parser import HTMLParser
from pathlib import Path

INDEX = Path(__file__).resolve().parent.parent / "public" / "index.html"
FAQ_MINIMUM = 7


class Extractor(HTMLParser):
    """Récupère le JSON-LD, et le texte des <summary>/<p> de la section FAQ."""

    def __init__(self):
        super().__init__(convert_charrefs=True)
        self.jsonld = []
        self.faq = []            # [(question, réponse), ...]
        self._in_script = False
        self._in_faq = 0         # profondeur dans <div class="faq">
        self._depth = 0
        self._capture = None
        self._buf = []
        self._pending_q = None

    def handle_starttag(self, tag, attrs):
        a = dict(attrs)
        if tag == "script" and a.get("type") == "application/ld+json":
            self._in_script = True
            self._buf = []
        if tag == "div":
            self._depth += 1
            if "faq" in (a.get("class") or "").split():
                self._in_faq = self._depth
        if self._in_faq and tag in ("summary", "p"):
            self._capture = tag
            self._buf = []

    def handle_endtag(self, tag):
        if tag == "script" and self._in_script:
            self.jsonld.append("".join(self._buf))
            self._in_script = False
            self._buf = []
        if self._in_faq and tag == self._capture:
            text = norm("".join(self._buf))
            if self._capture == "summary":
                self._pending_q = text
            elif self._pending_q is not None:
                self.faq.append((self._pending_q, text))
                self._pending_q = None
            self._capture = None
            self._buf = []
        if tag == "div":
            if self._in_faq == self._depth:
                self._in_faq = 0
            self._depth -= 1

    def handle_data(self, data):
        if self._in_script or self._capture:
            self._buf.append(data)


def norm(s: str) -> str:
    """Normalise pour la comparaison : NFC, espaces insécables ramenées à des
    espaces ordinaires, espaces multiples réduites. Le contenu doit être
    identique ; sa mise en forme typographique n'a pas à l'être."""
    s = unicodedata.normalize("NFC", s)
    s = s.replace(" ", " ").replace(" ", " ")
    return re.sub(r"\s+", " ", s).strip()


def main() -> int:
    errors = []
    html = INDEX.read_text(encoding="utf-8")

    p = Extractor()
    p.feed(html)

    if len(p.jsonld) != 1:
        print(f"ABORT: {len(p.jsonld)} bloc(s) JSON-LD trouvé(s), 1 attendu.")
        return 1

    try:
        data = json.loads(p.jsonld[0])
    except json.JSONDecodeError as e:
        print(f"ABORT: JSON-LD invalide — {e}")
        return 1

    graph = data.get("@graph")
    if not isinstance(graph, list):
        print("ABORT: le JSON-LD ne contient pas de tableau @graph.")
        return 1

    by_type = {}
    for node in graph:
        by_type.setdefault(node.get("@type"), []).append(node)

    expected = {
        "ProfessionalService": 1,
        "Person": 1,
        "Service": 5,
        "FAQPage": 1,
    }
    for t, n in expected.items():
        got = len(by_type.get(t, []))
        if got != n:
            errors.append(f"nœud {t} : {got} trouvé(s), {n} attendu(s)")

    # D-site-08 v2 : plus aucun nœud Product, quelle qu'en soit la raison. C'est le
    # motif même de l'amendement ; le rendre explicite évite qu'il revienne par
    # inadvertance et rouvre l'erreur Search Console qu'on vient de fermer.
    if "Product" in by_type:
        errors.append(
            f"nœud Product : {len(by_type['Product'])} trouvé(s), 0 attendu "
            "(D-site-08 v2 — type à résultat enrichi, réclame offers/review/aggregateRating)"
        )

    # -- propriétés minimales --------------------------------------------------
    for node in by_type.get("ProfessionalService", []):
        for key in ("name", "url", "address", "founder", "areaServed", "email"):
            if key not in node:
                errors.append(f"ProfessionalService : propriété '{key}' manquante")
    for node in by_type.get("Person", []):
        for key in ("name", "jobTitle", "worksFor"):
            if key not in node:
                errors.append(f"Person : propriété '{key}' manquante")
    for node in by_type.get("Service", []):
        if "provider" not in node:
            errors.append(f"Service '{node.get('name')}' : 'provider' manquant")

    # Le compte de Service ne suffit pas à défendre les nœuds qui portent une
    # décision : cinq Service quelconques passeraient. Ceux-là sont donc vérifiés
    # nommément, par leur @id, avec les propriétés que leur directive exige.
    nommes = (
        # (fragment d'@id, libellé, propriétés requises)
        ("#editos", "Editos", ("name", "description", "image", "provider")),
        ("#reprise-actifs", "Reprise d'actifs", ("name", "description", "provider")),
    )
    for fragment, libelle, requises in nommes:
        node = next(
            (n for n in graph if n.get("@id") == f"https://hkconseils.fr/{fragment}"), None
        )
        if node is None:
            errors.append(f"nœud {libelle} ({fragment}) absent du @graph")
            continue
        if node.get("@type") != "Service":
            errors.append(f"{libelle} : @type '{node.get('@type')}', 'Service' attendu")
        for key in requises:
            if key not in node:
                errors.append(f"{libelle} : propriété '{key}' manquante")
        if "brand" in node:
            errors.append(f"{libelle} : 'brand' présent, 'provider' attendu (D-site-08 v2)")

    # -- FAQ : le balisage doit refléter le DOM --------------------------------
    faq_nodes = by_type.get("FAQPage", [])
    if faq_nodes:
        entities = faq_nodes[0].get("mainEntity", [])
        markup = [
            (norm(q.get("name", "")), norm(q.get("acceptedAnswer", {}).get("text", "")))
            for q in entities
        ]
        dom = [(q, a) for q, a in p.faq]

        # La directive SITE-01 en imposait 5, SITE-01b en ajoute une 6e. Le nombre
        # exact n'est pas la propriété à défendre : ce qui compte est qu'il ne
        # descende pas sous le socle, et surtout que balisage et DOM concordent.
        if len(markup) < FAQ_MINIMUM:
            errors.append(
                f"FAQPage : {len(markup)} question(s) balisée(s), au moins {FAQ_MINIMUM} attendues"
            )
        if len(dom) != len(markup):
            errors.append(
                f"FAQ : {len(dom)} paire(s) dans le DOM contre {len(markup)} dans le balisage"
            )
        for i, (m, d) in enumerate(zip(markup, dom), start=1):
            if m[0] != d[0]:
                errors.append(
                    f"FAQ #{i} : question divergente\n"
                    f"      DOM      : {d[0]!r}\n"
                    f"      JSON-LD  : {m[0]!r}"
                )
            if m[1] != d[1]:
                errors.append(
                    f"FAQ #{i} : réponse divergente\n"
                    f"      DOM      : {d[1][:90]!r}…\n"
                    f"      JSON-LD  : {m[1][:90]!r}…"
                )

    if errors:
        print("ABORT: JSON-LD non conforme")
        for e in errors:
            print(f"    - {e}")
        return 1

    print(
        f"check-jsonld: OK — @graph valide, "
        f"{len(graph)} nœuds, {len(p.faq)} Q/R FAQ identiques entre le DOM et le balisage."
    )
    return 0


if __name__ == "__main__":
    sys.exit(main())
