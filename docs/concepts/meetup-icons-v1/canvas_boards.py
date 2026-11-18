"""Writes one canvas board per meetup activity into docs/concepts/ and adds
them to docs/concepts/canvas.json as a row per round.

Run: python3 canvas_boards.py <round>   e.g. v2. Rerun after every change.
Fetch the live canvas.json first: the developer moves boards on the canvas.
A round the developer has seen is not changed again; add a new round instead.
"""
import json
import pathlib
import re
import sys

HERE = pathlib.Path(__file__).parent
CONCEPTS = HERE.parent
ICONS = CONCEPTS.parent.parent / "assets" / "icons"

# Activity -> variants. A plain name is a draft here, "@x" is assets/icons/x.svg.
REUSED = ("Reused as they are", ["@cups", "@party", "@popcorn", "@chat", "@controller"])
ROUNDS = {
    "v1": dict(prefix="Meetup", y=14020, note_id="t12",
               note="Meetup icons v1: one board per activity, dark and light, at 22, 36 and 72 px",
               activities=[
                   ("Bar", ["bar"]), ("Board games", ["boardgames", "boardgames-b"]),
                   ("Bouldering", ["bouldering", "bouldering-b"]), ("Cinema", ["cinema", "cinema-b"]),
                   ("Concert", ["concert", "concert-b"]), ("Cooking together", ["cooking"]),
                   ("DIY", ["diy", "diy-b"]), ("Gym", ["gym"]), ("Karaoke", ["karaoke"]),
                   ("Restaurant", ["restaurant"]), ("Shopping", ["shopping"]),
                   ("Sports", ["sports", "sports-b"]), ("Walk", ["walk", "walk-b", "@bench"]),
                   REUSED]),
    "v2": dict(prefix="MeetupV2", y=15660,
               note="Meetup icons v2: picks from v1, new climber, runner and restaurant",
               activities=[
                   ("Bouldering (new)", ["bouldering-c", "bouldering-d"]),
                   ("Sports (new)", ["sports-c", "sports-d"]),
                   ("Restaurant (new)", ["restaurant-b", "restaurant-c"]),
                   ("Bar", ["bar"]), ("Board games", ["boardgames"]),
                   ("Cinema", ["cinema", "cinema-b"]), ("Concert", ["concert"]),
                   ("Making music", ["concert-b"]), ("Cooking together", ["cooking"]),
                   ("DIY", ["diy"]), ("Gym", ["gym"]), ("Karaoke", ["karaoke"]),
                   ("Shopping", ["shopping"]), ("Walk", ["@bench"]), REUSED]),
}
SET = ["home", "cake", "dice", "chat", "popcorn", "cups", "gift", "mountain"]
PER_ROW = 7


def body(name):
    p = ICONS / f"{name[1:]}.svg" if name.startswith("@") else HERE / f"{name}.svg"
    return re.sub(r"^<svg[^>]*>|</svg>\s*$", "", p.read_text().strip())


def icon(inner, size):
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 48 48" '
            f'style="filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))">{inner}</svg>')


def board(title, w, h, content):
    props = json.dumps({"$preview": {"width": w, "height": h}})
    return f"""<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>{title}</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<style>body{{margin:0}}
.w{{width:{w}px;height:{h}px;box-sizing:border-box;font:13px Roboto,system-ui,sans-serif;display:flex;flex-direction:column}}
.p{{flex:1;padding:12px 14px;display:flex;flex-direction:column;justify-content:center;gap:10px}}
.dark{{background:#17121C;color:#BBADC2}}.light{{background:#F4F1F7;color:#5A4E63}}
.row{{display:flex;gap:14px;flex-wrap:wrap;align-items:center}}
.v{{display:flex;flex-direction:column;gap:4px}}.ic{{display:flex;align-items:flex-end;gap:10px}}
i{{width:1px;height:26px;background:currentColor;opacity:.4}}</style>
</helmet>
<div class="w">{content}</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{props}'>
class Component extends DCLogic {{
renderVals() {{ return {{}}; }}
}}
</script>
</body>
</html>
"""


def variants(names, sizes):
    out = []
    for n in names:
        ics = "".join(icon(body(n), s) for s in sizes)
        label = n[1:] + " (exists)" if n.startswith("@") else n
        out.append(f'<div class="v"><div class="ic">{ics}</div><span>{label}</span></div>')
    return '<div class="row">' + "".join(out) + "</div>"


rnd = ROUNDS[sys.argv[1]]
prefix, top, acts = rnd["prefix"], rnd["y"], rnd["activities"]
canvas_path = CONCEPTS / "canvas.json"
canvas = json.loads(canvas_path.read_text())
mine = lambda k: re.fullmatch(prefix + r"[A-Z][a-z]\w*\.dc\.html", k)
for k in [k for k in canvas["boards"] if mine(k)]:
    del canvas["boards"][k]
canvas["order"] = [k for k in canvas["order"] if not mine(k)]


def add(fname, title, x, y, w, h, html):
    (CONCEPTS / fname).write_text(html)
    canvas["boards"][fname] = {"x": x, "y": y, "w": w, "h": h, "title": title}
    canvas["order"].append(fname)


tag = sys.argv[1]
drafts = [n for _, vs in acts for n in vs if not n.startswith("@")]
strip = ("".join(icon(body("@" + s), 26) for s in SET) + "<i></i>"
         + "".join(icon(body(n), 26) for n in drafts))
pane = lambda g, c: f'<div class="p {g}">{c}</div>'
add(f"{prefix}Weight.dc.html", f"Meetup icons {tag} · weight check at 26 px: existing set | drafts",
    0, top + 300, 1180, 200,
    board("Weight check", 1180, 200, pane("dark", f'<div class="row">{strip}</div>')
          + pane("light", f'<div class="row">{strip}</div>')))

width = lambda names: 560 if len(names) > 2 else 360
for i, (title, names) in enumerate(acts):
    w = width(names)
    sizes = (22, 36, 72) if len(names) <= 3 else (22, 36)
    fname = prefix + re.sub(r"\W", "", title.title()) + ".dc.html"
    col, row = i % PER_ROW, i // PER_ROW
    x = sum(width(acts[row * PER_ROW + c][1]) + 80 for c in range(col))
    content = variants(names, sizes)
    add(fname, f"Meetup icons {tag} · {title}", x, top + 620 + row * 420, w, 300,
        board(title, w, 300, pane("dark", content) + pane("light", content)))

canvas["notes"][rnd.get("note_id", "t" + prefix)] = {"x": 0, "y": top, "w": 240, "kind": "title1",
                                 "maxW": 2740, "text": rnd["note"]}
canvas_path.write_text(json.dumps(canvas, indent=2, ensure_ascii=False) + "\n")
print("boards:", [k for k in canvas["order"] if mine(k)])
