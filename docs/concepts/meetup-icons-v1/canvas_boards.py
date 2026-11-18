"""Writes one canvas board per meetup activity into docs/concepts/ and adds
them to docs/concepts/canvas.json as a new row.

Run: python3 canvas_boards.py   (from anywhere). Rerun after every change.
Fetch the live canvas.json first: the developer moves boards on the canvas.
"""
import json
import pathlib
import re

HERE = pathlib.Path(__file__).parent
CONCEPTS = HERE.parent
ICONS = CONCEPTS.parent.parent / "assets" / "icons"

# Activity -> variants. A name without a path is a draft here, "@x" is assets/icons/x.svg.
ACTIVITIES = [
    ("Bar", ["bar"]), ("Board games", ["boardgames", "boardgames-b"]),
    ("Bouldering", ["bouldering", "bouldering-b"]), ("Cinema", ["cinema", "cinema-b"]),
    ("Concert", ["concert", "concert-b"]), ("Cooking together", ["cooking"]),
    ("DIY", ["diy", "diy-b"]), ("Gym", ["gym"]), ("Karaoke", ["karaoke"]),
    ("Restaurant", ["restaurant"]), ("Shopping", ["shopping"]),
    ("Sports", ["sports", "sports-b"]), ("Walk", ["walk", "walk-b", "@bench"]),
    ("Reused as they are", ["@cups", "@party", "@popcorn", "@chat", "@controller"]),
]
SET = ["home", "cake", "dice", "chat", "popcorn", "cups", "gift", "mountain"]
ROW_Y, ROW_H, PER_ROW = 14020, 420, 7


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


canvas_path = CONCEPTS / "canvas.json"
canvas = json.loads(canvas_path.read_text())
for k in [k for k in canvas["boards"] if k.startswith("Meetup")]:
    del canvas["boards"][k]
canvas["order"] = [k for k in canvas["order"] if not k.startswith("Meetup")]


def add(fname, title, x, y, w, h, html):
    (CONCEPTS / fname).write_text(html)
    canvas["boards"][fname] = {"x": x, "y": y, "w": w, "h": h, "title": title}
    canvas["order"].append(fname)


drafts = [n for _, vs in ACTIVITIES for n in vs if not n.startswith("@")]
strip = ("".join(icon(body("@" + s), 26) for s in SET) + "<i></i>"
         + "".join(icon(body(n), 26) for n in drafts))
pane = lambda g, c: f'<div class="p {g}">{c}</div>'
add("MeetupWeight.dc.html", "Meetup icons v1 · weight check at 26 px: existing set | drafts",
    0, ROW_Y + 300, 1180, 200,
    board("Weight check", 1180, 200, pane("dark", f'<div class="row">{strip}</div>')
          + pane("light", f'<div class="row">{strip}</div>')))

for i, (title, names) in enumerate(ACTIVITIES):
    w = 360 if len(names) <= 2 else 560
    sizes = (22, 36, 72) if len(names) <= 3 else (22, 36)
    if len(names) > 3:
        w = 560
    content = variants(names, sizes)
    fname = "Meetup" + re.sub(r"\W", "", title.title()) + ".dc.html"
    col, row = i % PER_ROW, i // PER_ROW
    x = sum((560 if len(ACTIVITIES[row * PER_ROW + c][1]) > 2 else 360) + 80
            for c in range(col))
    add(fname, f"Meetup icons v1 · {title}", x, ROW_Y + 620 + row * ROW_H, w, 300,
        board(title, w, 300, pane("dark", content) + pane("light", content)))

canvas["notes"]["t12"] = {"x": 0, "y": ROW_Y, "w": 240, "kind": "title1", "maxW": 2740,
                          "text": "Meetup icons v1: one board per activity, dark and light, at 22, 36 and 72 px"}
canvas_path.write_text(json.dumps(canvas, indent=2, ensure_ascii=False) + "\n")
print("boards:", [k for k in canvas["order"] if k.startswith("Meetup")])
