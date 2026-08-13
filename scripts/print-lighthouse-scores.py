#!/usr/bin/env python3
"""
print-lighthouse-scores.py — affiche les scores Lighthouse par page.

Sans cela, un run réussi ne laisse aucune trace des scores obtenus : les
assertions passent en silence, et l'AC1 demande de consigner les quatre scores.
Lit les rapports JSON produits par `lhci autorun` et affiche la **médiane** par
page et par catégorie (numberOfRuns > 1 dans lighthouserc.json).

Ne fait jamais échouer le job : c'est un rapporteur, la porte reste `lhci assert`.
"""
import json
import statistics
import sys
from collections import defaultdict
from pathlib import Path

CATEGORIES = ["performance", "accessibility", "best-practices", "seo"]
LABELS = {
    "performance": "Performance",
    "accessibility": "Accessibilité",
    "best-practices": "Bonnes pratiques",
    "seo": "SEO",
}


def main() -> int:
    root = Path(__file__).resolve().parent.parent / ".lighthouseci"
    reports = sorted(root.rglob("*.json"))
    scores = defaultdict(lambda: defaultdict(list))

    for path in reports:
        try:
            data = json.loads(path.read_text(encoding="utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError):
            continue
        url = data.get("finalDisplayedUrl") or data.get("finalUrl") or data.get("requestedUrl")
        cats = data.get("categories")
        if not url or not isinstance(cats, dict):
            continue  # fichiers de manifeste et autres sous-produits de lhci
        for key in CATEGORIES:
            value = (cats.get(key) or {}).get("score")
            if isinstance(value, (int, float)):
                scores[url][key].append(value * 100)

    if not scores:
        print("Aucun rapport Lighthouse exploitable trouvé dans .lighthouseci/")
        return 0

    print("\nScores Lighthouse (mobile, médiane des runs)")
    print("=" * 74)
    for url in sorted(scores):
        print(f"\n{url}")
        for key in CATEGORIES:
            values = scores[url][key]
            if not values:
                continue
            median = statistics.median(values)
            flag = "OK " if median >= 95 else "SOUS LE SEUIL"
            detail = f"  (runs: {', '.join(f'{v:.0f}' for v in values)})"
            print(f"   {LABELS[key]:<18} {median:5.0f}   {flag}{detail}")
    print()
    return 0


if __name__ == "__main__":
    sys.exit(main())
