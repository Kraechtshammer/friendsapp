"""Builds board.html: all activity icon drafts on dark and light ground.

Run: python3 board.py   (from this folder). Rerun after every change.
"""
import pathlib
import re

HERE = pathlib.Path(__file__).parent
ICONS = HERE.parent.parent.parent / "assets" / "icons"

# Existing icons shown for comparison (assets/icons).
REUSED = [("runner", "runner"), ("climber", "climber"), ("dumbbell", "dumbbell"),
          ("guitar", "guitar")]
SET = ["runner", "climber", "dumbbell", "guitar", "people", "bench"]

GROUNDS = {"dark": ("#17121C", "#231C2A", "#BBADC2"),
           "light": ("#F4F1F7", "#FFFFFF", "#5A4E63")}


def body(path):
    svg = path.read_text()
    return re.sub(r"^<svg[^>]*>|</svg>\s*$", "", svg.strip())


def icon(inner, size):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 48 48" '
            f'style="filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))">{inner}</svg>')


def card(name, inner):
    sizes = "".join(icon(inner, s) for s in (22, 36, 72))
    return f'<div class="card"><div class="ic">{sizes}</div><span>{name}</span></div>'


drafts = sorted(p for p in HERE.glob("*.svg"))
existing = [(f"{a} ({f})", body(ICONS / f"{f}.svg")) for a, f in REUSED]
new = [(p.stem, body(p)) for p in drafts]
strip = "".join(icon(body(ICONS / f"{f}.svg"), 26) for f in SET)
strip += '<i></i>' + "".join(icon(b, 26) for _, b in new)

parts = []
for g, (bg, cardbg, fg) in GROUNDS.items():
    parts.append(f'<section style="background:{bg};color:{fg}">'
                 f'<style>.{g} .card{{background:{cardbg}}}</style><div class="{g}">'
                 f'<h2>Weight check at 26 px: existing | drafts</h2><div class="strip">{strip}</div>'
                 f'<h2>New drafts</h2><div class="grid">{"".join(card(n, b) for n, b in new)}</div>'
                 f'<h2>Existing</h2><div class="grid">{"".join(card(n, b) for n, b in existing)}</div>'
                 f'</div></section>')

html = ('<!doctype html><meta charset="utf-8"><title>Activity icons v2</title><style>'
        'body{margin:0;font:13px sans-serif;display:flex}section{flex:1;padding:16px}'
        'h2{font-size:13px;font-weight:600;margin:14px 0 8px}'
        '.strip{display:flex;flex-wrap:wrap;gap:10px;align-items:center}'
        '.strip i{width:1px;height:26px;background:currentColor;opacity:.4}'
        '.grid{display:grid;grid-template-columns:repeat(auto-fill,minmax(170px,1fr));gap:8px}'
        '.card{border-radius:12px;padding:10px;display:flex;flex-direction:column;gap:6px}'
        '.ic{display:flex;align-items:flex-end;gap:12px}</style>' + "".join(parts))
(HERE / "board.html").write_text(html)
print(f"{len(new)} drafts, {len(existing)} existing -> board.html")
