#!/usr/bin/env python3
"""Hakt die Abnahmekriterien im README anhand der Check-Ergebnisse ab.

Liest die von grade.sh geschriebene TSV-Datei ($CLASSROOM_RESULTS, Format
"PASS|FAIL<TAB>Beschreibung") und setzt in README.md jede Checkbox, deren Text
exakt einer Beschreibung entspricht, auf [x] bzw. zurueck auf [ ].

Damit wird ein Kriterium automatisch abgehakt, sobald es erfuellt ist — und
wieder geleert, sobald eine Aenderung es erneut brechen laesst.

Checkboxen ohne passendes Ergebnis (z. B. manuell abgenommene Kriterien)
bleiben unveraendert.

Exit-Code 0 = README ist aktuell, 10 = README wurde geaendert.
"""

import os
import re
import sys
from datetime import datetime, timezone

README = "README.md"
# Optionaler Status-Marker (✅/⬜) direkt nach der Checkbox: er wird beim
# Schreiben immer neu gesetzt und beim Lesen uebersprungen, damit der
# Beschreibungstext der Schluessel bleibt.
CHECKBOX = re.compile(r"^(\s*[-*]\s+\[)([ xX])(\]\s+)(?:[✅⬜]\s+)?(\S.*?)(\s*)$")
MARK_DONE = "✅"
MARK_OPEN = "⬜"
PROGRESS_START = "<!-- c50:progress -->"
PROGRESS_END = "<!-- /c50:progress -->"

CHANGED_EXIT = 10


def load_results(path):
    """Beschreibung -> bestanden (bool)."""
    results = {}
    with open(path, encoding="utf-8") as fh:
        for line in fh:
            line = line.rstrip("\n")
            if not line:
                continue
            status, _, description = line.partition("\t")
            description = description.strip()
            if description:
                results[description] = status.strip().upper() == "PASS"
    return results


def render_bar(done, total, width=10):
    """Balken aus gruenen/leeren Quadraten — auf einen Blick lesbar."""
    if total <= 0:
        return ""
    filled = round(width * done / total)
    # Solange noch etwas offen ist, nie den vollen Balken zeigen.
    if filled == width and done < total:
        filled = width - 1
    return "🟩" * filled + "⬜" * (width - filled)


def render_progress(done, total):
    stamp = datetime.now(timezone.utc).strftime("%Y-%m-%d %H:%M UTC")
    bar = render_bar(done, total)
    if total and done == total:
        head = f"✅ **Alle {total} Kriterien erfüllt**"
    else:
        head = f"**Fortschritt: {done} / {total} Kriterien erfüllt**"
    return [PROGRESS_START, f"{head} {bar} — Stand: {stamp}.", PROGRESS_END]


def main():
    results_path = os.environ.get("CLASSROOM_RESULTS")
    if not results_path or not os.path.isfile(results_path):
        print("update_readme: keine Ergebnisdatei ($CLASSROOM_RESULTS) — uebersprungen")
        return 0
    if not os.path.isfile(README):
        print(f"update_readme: {README} nicht gefunden — uebersprungen")
        return 0

    results = load_results(results_path)
    if not results:
        print("update_readme: Ergebnisdatei leer — uebersprungen")
        return 0

    with open(README, encoding="utf-8") as fh:
        original = fh.readlines()

    out = []
    done = total = flipped = 0

    for line in original:
        match = CHECKBOX.match(line.rstrip("\n"))
        if match:
            description = match.group(4).strip()
            if description in results:
                total += 1
                passed = results[description]
                done += passed
                mark = "x" if passed else " "
                marker = MARK_DONE if passed else MARK_OPEN
                if match.group(2) != mark:
                    flipped += 1
                line = (
                    f"{match.group(1)}{mark}{match.group(3)}"
                    f"{marker} {match.group(4)}\n"
                )
        out.append(line)

    # Fortschrittsblock zwischen den Markern ersetzen, falls vorhanden.
    try:
        start = next(i for i, l in enumerate(out) if l.strip() == PROGRESS_START)
        end = next(i for i, l in enumerate(out) if l.strip() == PROGRESS_END)
    except StopIteration:
        pass
    else:
        if start < end:
            out[start:end + 1] = [l + "\n" for l in render_progress(done, total)]

    if out == original:
        print(f"update_readme: {done}/{total} erfuellt — README unveraendert")
        return 0

    with open(README, "w", encoding="utf-8") as fh:
        fh.writelines(out)

    print(f"update_readme: {done}/{total} erfuellt — {flipped} Checkbox(en) geaendert")
    return CHANGED_EXIT


if __name__ == "__main__":
    sys.exit(main())
