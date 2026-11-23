"""Round v2 of the log sheet: Home card H, when tiles I, past-day row D3.
Reuses v1 (gen.py styles/helpers, gen2.py pick2/fr/home pieces) by exec of their headers. Run: python3 gen3.py
Writes H-home-card.html, I-when-tiles.html, D3-days.html, boards LogSheetV2*.dc.html and canvas rows.
PNGs: headless Edge as in gen.py. v1 files are never written."""
import json, pathlib
HERE2 = pathlib.Path(__file__).resolve().parent
V1 = HERE2.parent / "log-sheet-v1"
g2 = (V1 / "gen2.py").read_text().split("# F: flow")[0].replace("__file__", repr(str(V1 / "gen2.py")))
exec(g2)
HERE = HERE2
TAG = "v2"
_g = (V1 / "gen.py").read_text()
exec('def plain' + _g.split('def plain')[1].split('canvas_path =')[0])

CSS += """
.tiles.w5{gap:8px}.tiles.w5 .tb{border-radius:18px}
.d3{display:flex;gap:8px}
.d3 .db{flex:1;width:auto;height:auto;aspect-ratio:1;border-radius:18px;position:relative}
.d3 .db small{font-size:10.5px}
.d3 .db b{font-size:24px}
.cond{background:#fff;border-radius:16px;height:44px;display:flex;align-items:center;padding:0 14px;gap:10px;color:var(--mut);font-size:15px;box-shadow:inset 0 0 0 1.5px var(--line)}
.pn{--sunc:#FFE08A;--bg:#FFF6EA;--s2:#F3E6D6;--s2d:#D9C7B2;--on:#2A1B3D;--mut:#6B5A7A;--line:#CDBBA8;--sun:#FFCF5C;--sund:#C4962A;--onacc:#1F1326;color:var(--on);font-family:Roboto,sans-serif;width:390px;display:flex;flex-direction:column;gap:12px}
.note{font:600 12px Outfit;color:var(--mut);margin:0 0 6px 4px;letter-spacing:.05em;text-transform:uppercase}
"""

# new icons (icon-style.md: flat, no outline, split shading, 48 grid, palette)
DONE = ('<svg width="{0}" height="{0}" viewBox="0 0 48 48" style="flex:none;filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))">'
        '<path d="M15 7h18a10 10 0 0 1 10 10v8a10 10 0 0 1-10 10H23l-9 8v-8.2A10 10 0 0 1 5 25v-8A10 10 0 0 1 15 7z" fill="#1FD67A"/>'
        '<path d="M24 7h9a10 10 0 0 1 10 10v8a10 10 0 0 1-10 10h-9z" fill="#0FA85C"/>'
        '<path d="M14.5 21.5l6 6 12-12" fill="none" stroke="#fff" stroke-width="7" stroke-linecap="round" stroke-linejoin="round"/></svg>')
SUNCLOUD = ('<svg width="{0}" height="{0}" viewBox="0 0 48 48" style="flex:none;filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))">'
        '<g stroke="#FFC61A" stroke-width="4" stroke-linecap="round"><path d="M17 3v4M5.5 8l3 3M28.5 8l-3 3M2 19h4M32 19h-4"/></g>'
        '<circle cx="17" cy="18" r="9" fill="#FFC61A"/><path d="M17 9a9 9 0 0 1 0 18z" fill="#F59A0B"/>'
        '<path d="M16 28a8 8 0 0 1 14-3 8 8 0 0 1 12 8 7 7 0 0 1-3 13H16a9 9 0 0 1 0-18z" fill="#F1F3FF" stroke="#F1F3FF" stroke-width="3" stroke-linejoin="round"/>'
        '<path d="M30 25a8 8 0 0 1 12 8 7 7 0 0 1-3 13H30z" fill="#D5DAF0" stroke="#D5DAF0" stroke-width="3" stroke-linejoin="round"/></svg>')
(HERE / "icons").mkdir(exist_ok=True)
(HERE / "icons" / "done.svg").write_text(DONE.format(48).replace(' style="flex:none;filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))"', '').replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" '))
(HERE / "icons" / "sun-cloud.svg").write_text(SUNCLOUD.format(48).replace(' style="flex:none;filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))"', '').replace('<svg ', '<svg xmlns="http://www.w3.org/2000/svg" '))

WHEN = [(DONE.format(40), "Done"), (ico("sprout", 40), "Soon"), (ico("moon", 40), "Later"), (ico("calendar", 40), "Date"), (SUNCLOUD.format(40), "When…")]
def when_tiles(on, labels):  # labels "all" | "sel"
    out = ""
    for i, (ic, n) in enumerate(WHEN):
        o = i == on
        lab = f"<span>{n}</span>" if labels == "all" or o else "<span>&nbsp;</span>"
        out += f'<div class="tile{" on" if o else ""}"><div class="tb">{ic}</div>{lab}</div>'
    return f'<div class="tiles w5">{out}</div>'

CAL = lambda s: ico("calendar", s)
def days3(order, picked=None, on=0):
    d = [("Today", "23"), ("Yday", "22"), ("Sat", "21"), ("Fri", "20")]
    if order == "b": d = d[::-1]
    cells = [f'<span class="db{" on" if i == on else ""}"><small>{w}</small><b>{n}</b></span>' for i, (w, n) in enumerate(d)]
    if picked:
        cal = f'<span class="db on"><small>{picked[0]}</small><b>{picked[1]}</b><i style="position:absolute;right:3px;top:3px;display:flex">{CAL(16)}</i></span>'
    else:
        cal = f'<span class="db">{CAL(30)}<small style="margin-top:1px">Pick</small></span>'
    cells = cells + [cal] if order == "a" else [cal] + cells
    return f'<div class="d3">{"".join(cells)}</div>'

def who(names):
    f = "".join(f'<div class="face" style="width:56px">{av(n,50)}<span>{n}</span></div>' for n in names)
    lab = "<span>Pick people</span>" if not names else "<span>&nbsp;</span>"
    return f'<div class="faces" style="gap:12px">{f}<div class="face" style="width:{56 if names else 90}px"><div class="add" style="width:50px;height:50px">{PLUS.format(24)}</div>{lab}</div></div>'

def kinds(): return what_tiles("sel").replace('class="tiles"', 'class="tiles sm"')
def homecard(names, whenrow, extra=""):
    card = (f'<div class="sunc"><h2 class="o" style="margin:0;font-size:22px">Who\'s on your mind?</h2><div class="fld">saw a bouldering video…</div>'
            f'{who(names)}{kinds()}{whenrow}{extra}<div class="btn">Save</div></div>')
    return (f'<div class="pg" style="padding-top:18px;gap:14px"><h1>Kept.</h1>{card}</div>'
            f'<div class="nav"><span>Home</span><span>People</span><span>Meetups</span><span>More</span></div>')

f1 = homecard([], when_tiles(1, "sel"))
f2 = homecard([], when_tiles(1, "sel")) + '<div class="scrim"></div>' + pick2({"Franz", "Lucy"}, 300, 8).replace('<div class="scrim" style="background:rgba(31,19,38,.45)"></div>', '', 1).replace("Who else was there?", "Who's on your mind?")
f3 = homecard(["Franz", "Lucy"], when_tiles(0, "sel"), days3("a"))
H = ('<div class="pair" style="gap:40px">' + fr(f1, "1 · No person yet: one dashed plus") + fr(f2, "2 · The picker slides up") + fr(f3, "3 · After Done: faces, when tiles, days") + '</div>')

def panel(on, labels):
    def blk(o, below, cap):
        return f'<div><p class="note">{cap}</p><div class="sunc" style="padding:14px;gap:10px">{when_tiles(o, labels)}{below}</div></div>'
    date = f'<div class="cond"><span style="display:flex">{CAL(22)}</span><span style="color:var(--on)">Sat 28 Nov 2026</span></div>'
    cond = '<div class="cond">when it is warm again</div>'
    return (f'<div class="pn">{blk(0, "", "Done already")}{blk(3, date, "Date chosen: date field")}{blk(4, cond, "When… chosen: condition field")}</div>')
I = ('<div class="pair" style="gap:40px"><div><p class="lab">I1 · label only on the chosen tile</p>' + panel(0, "sel") + '</div>'
     '<div><p class="lab">I2 · all tiles labelled</p>' + panel(0, "all") + '</div></div>')

def dpanel(order, cap):
    def blk(h, c): return f'<div><p class="note">{c}</p><div class="sunc" style="padding:14px">{h}</div></div>'
    return (f'<div class="pn"><p class="lab" style="margin:0">{cap}</p>' + blk(days3(order, on=0 if order == "a" else 3), "Today chosen")
            + blk(days3(order, on=2 if order == "a" else 1), "Another day chosen") + blk(days3(order, ("Mon", "17"), on=-1), "Picked date shown on the calendar badge") + '</div>')
D = '<div class="pair" style="gap:40px">' + dpanel("a", "D3a · newest first, calendar at the right") + dpanel("b", "D3b · oldest first, calendar at the left") + '</div>'

NEW = {"H-home-card": ("H Home card", H, 3 * 390 + 2 * 40, 844 + 60), "I-when-tiles": ("I When tiles", I, 2 * 390 + 40, 760), "D3-days": ("D3 Past-day row", D, 2 * 390 + 40, 480)}
canvas_path = CONCEPTS / "canvas.json"
canvas = json.loads(canvas_path.read_text())
x = 0; Y = 20400
for key, (title, body, w, h) in NEW.items():
    W, Hh = w + 32, h + 32
    (HERE / f"{key}.html").write_text(plain(title, body))
    fname = f"LogSheetV2{key.split('-')[0]}.dc.html"
    (CONCEPTS / fname).write_text(dc(title, W, Hh, body))
    canvas["boards"][fname] = {"x": x, "y": Y, "w": W, "h": Hh, "title": f"Log sheet {TAG} · {title}"}
    if fname not in canvas["order"]: canvas["order"].append(fname)
    x += W + 80
canvas["notes"]["tLogSheetV2"] = {"x": 0, "y": Y - 300, "w": 240, "kind": "title1", "maxW": 2740, "text": "Log sheet v2: Home card with one dashed plus, when as five tiles, past days as five badges"}
canvas_path.write_text(json.dumps(canvas, indent=2, ensure_ascii=False) + "\n")
