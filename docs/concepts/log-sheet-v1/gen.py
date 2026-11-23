"""Concept screens for the redesigned "We were in touch" sheet (round v1).

Run: python3 gen.py [preview-only]   (from this folder; rerun after every change.)
Writes the plain HTML pictures here (<name>.html), the canvas boards
docs/concepts/LogSheetV1*.dc.html and a row in docs/concepts/canvas.json.
PNGs: headless Edge, see docs/history-research-and-design.md (line about gen_v6 previews).
A round the developer has seen is not changed again; add a new round (v2) instead.
"""
import json, math, pathlib, re, sys

HERE = pathlib.Path(__file__).parent
CONCEPTS = HERE.parent
ICONS = CONCEPTS.parent.parent / "assets" / "icons"
TAG, TOP = "v1", 19000

def cookie():
    pts = []
    for i in range(96):
        t = 2 * math.pi * i / 96
        r = 0.45 + 0.05 * math.cos(8 * t)
        pts.append("%.1f%% %.1f%%" % (100 * (0.5 + r * math.cos(t)), 100 * (0.5 + r * math.sin(t))))
    return "polygon(" + ",".join(pts) + ")"

def ico(name, size):
    s = (ICONS / f"{name}.svg").read_text().strip()
    inner = re.sub(r"^<svg[^>]*>|</svg>\s*$", "", s)
    return (f'<svg width="{size}" height="{size}" viewBox="0 0 48 48" style="flex:none;filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))">{inner}</svg>')

CHECK = '<svg width="{0}" height="{0}" viewBox="0 0 24 24"><path d="M5 12.5l4.5 4.5L19 7.5" fill="none" stroke="#1F1326" stroke-width="3.2" stroke-linecap="round" stroke-linejoin="round"/></svg>'
PLUS = '<svg width="{0}" height="{0}" viewBox="0 0 24 24"><path d="M12 5v14M5 12h14" fill="none" stroke="currentColor" stroke-width="2.6" stroke-linecap="round"/></svg>'
SEARCH = '<svg width="22" height="22" viewBox="0 0 24 24"><circle cx="10.5" cy="10.5" r="6" fill="none" stroke="currentColor" stroke-width="2.4"/><path d="M15.5 15.5 20 20" stroke="currentColor" stroke-width="2.4" stroke-linecap="round"/></svg>'

CSS = """
body{margin:0}
.s{width:390px;height:844px;box-sizing:border-box;background:var(--bg);color:var(--on);font-family:'Roboto',system-ui,sans-serif;font-size:16px;line-height:1.35;position:relative;overflow:hidden;flex:none;
--coral:#FF8A7A;--corald:#C4564A;--sun:#FFCF5C;--sund:#C4962A;--mint:#7EDDBE;--lilac:#C3B4FF;--sky:#8CCBFF;--pink:#FF9EC6;--onacc:#1F1326;
--bg:#FFF6EA;--s1:#FFFFFF;--s2:#F3E6D6;--s2d:#D9C7B2;--shd:rgba(42,27,61,.2);--on:#2A1B3D;--mut:#6B5A7A;--line:#CDBBA8;
--sunc:#FFE08A;--mintc:#BDEFDD;--lilacc:#DDD4FF;--pinkc:#FFD0E2;--skyc:#C6E5FF;--coralc:#FFC9C0}
.s *{box-sizing:border-box}
.pair{display:flex;gap:40px;align-items:flex-start}
.lab{font:600 13px Outfit,sans-serif;color:#6B5A7A;margin:0 0 8px 4px;letter-spacing:.04em}
h1,.o{font-family:Outfit,sans-serif}
.back{position:absolute;inset:0;padding:22px 16px}
.back .blk{background:var(--s1);border-radius:28px;box-shadow:0 5px 0 var(--shd);height:110px;margin-bottom:14px}
.scrim{position:absolute;inset:0;background:rgba(31,19,38,.55)}
.sheet{position:absolute;left:0;right:0;bottom:0;background:var(--bg);border-radius:28px 28px 0 0;padding:10px 16px 18px;display:flex;flex-direction:column;gap:14px;box-shadow:0 -4px 0 rgba(0,0,0,.12)}
.grab{width:40px;height:5px;border-radius:3px;background:var(--line);margin:0 auto 2px}
h1{font-size:24px;font-weight:700;margin:0}
.sub{font-size:14px;color:var(--mut)}
.l{font:600 13px Outfit,sans-serif;letter-spacing:.08em;text-transform:uppercase;color:var(--mut);margin:0 0 10px}
.sec{display:block}
.card{background:var(--s1);border-radius:22px;padding:12px 14px 14px;box-shadow:0 4px 0 var(--shd)}
.t1{background:var(--lilacc)}.t2{background:var(--skyc)}.t3{background:var(--mintc)}.t4{background:var(--pinkc)}
.row{display:flex;gap:8px;align-items:center}
.chip{height:44px;border-radius:14px;border:1.5px solid var(--on);display:inline-flex;align-items:center;gap:6px;padding:0 14px;font:500 15px Roboto;color:var(--on);background:transparent;white-space:nowrap}
.chip.on{background:var(--sun);border-color:var(--sun);color:var(--onacc)}
.tiles{display:flex;gap:10px}
.tile{flex:1;display:flex;flex-direction:column;align-items:center;gap:6px}
.tb{width:100%;aspect-ratio:1;border-radius:22px;background:var(--s2);box-shadow:0 4px 0 var(--s2d);display:flex;align-items:center;justify-content:center}
.tile.on .tb{background:var(--sun);box-shadow:0 4px 0 var(--sund)}
.tile.on .tb svg{transform:scale(1.08)}
.tile span{font:600 14px Outfit;color:var(--mut)}.tile.on span{color:var(--on);font-weight:700}
.tile.hid .tb{aspect-ratio:1}
.av{display:flex;align-items:center;justify-content:center;font:700 22px Outfit;color:var(--onacc);filter:drop-shadow(0 2px 0 rgba(0,0,0,.3));flex:none}
.sc{clip-path:%CK%}.rs{border-radius:34%}.lf{border-radius:50% 50% 50% 16%}.ar{border-radius:50% 50% 16% 16%}
.a-coral{background:var(--coral)}.a-sun{background:var(--sun)}.a-mint{background:var(--mint)}.a-lilac{background:var(--lilac)}.a-sky{background:var(--sky)}.a-pink{background:var(--pink)}
.faces{display:flex;gap:14px;align-items:flex-start}
.face{display:flex;flex-direction:column;align-items:center;gap:5px;font:500 13px Roboto;width:58px}
.face .av{width:54px;height:54px}
.add{width:54px;height:54px;border-radius:50%;border:2px dashed var(--line);display:flex;align-items:center;justify-content:center;color:var(--mut)}
.strip{display:flex;gap:8px;align-items:center;overflow:hidden}
.cal{width:44px;height:44px;border-radius:14px;background:var(--s2);box-shadow:0 3px 0 var(--s2d);display:flex;align-items:center;justify-content:center;flex:none}
.db{width:62px;height:62px;border-radius:18px;background:var(--s2);box-shadow:0 4px 0 var(--s2d);display:flex;flex-direction:column;align-items:center;justify-content:center;flex:none;color:var(--on)}
.db small{font:600 9.5px Outfit;letter-spacing:.02em;text-transform:uppercase;color:var(--mut)}
.db b{font:700 24px Outfit;line-height:1.05}
.db.on{background:var(--sun);box-shadow:0 4px 0 var(--sund);color:var(--onacc)}.db.on small{color:var(--onacc)}
.btn{height:52px;border-radius:26px;background:var(--coral);box-shadow:0 4px 0 var(--corald);color:var(--onacc);font:600 17px Outfit;display:flex;align-items:center;justify-content:center;gap:8px}
.search{height:48px;border-radius:26px;background:#F6EEE4;display:flex;align-items:center;gap:10px;padding:0 16px;color:var(--mut);font-size:16px}
.grid{display:grid;grid-template-columns:repeat(4,1fr);gap:16px 6px;padding:4px 0}
.g{display:flex;flex-direction:column;align-items:center;gap:10px;font:500 14px Roboto}
.pw{position:relative;width:68px;height:68px;display:flex;align-items:center;justify-content:center}
.pw .av{width:60px;height:60px;font-size:24px}
.pw.sel{box-shadow:0 0 0 4px #fff,0 0 0 7px var(--coral);border-radius:50%}
.pw.sel .av{width:62px;height:62px}
.ck{position:absolute;right:-4px;bottom:-4px;width:26px;height:26px;border-radius:50%;background:var(--mint);box-shadow:0 2px 0 rgba(0,0,0,.3),0 0 0 3px var(--bg);display:flex;align-items:center;justify-content:center}
"""
CSS = CSS.replace("%CK%", cookie())

SH = ["sc", "rs", "lf", "ar"]
PEOPLE = {"Tom": ("T", "sky", "rs"), "Franz": ("F", "mint", "sc"), "Lucy": ("L", "pink", "lf"),
          "Anna": ("A", "lilac", "ar"), "Mark": ("M", "sun", "sc"), "Sofia": ("S", "coral", "rs"),
          "Jonas": ("J", "sky", "ar"), "Maya": ("M", "mint", "lf"), "Ben": ("B", "pink", "sc"),
          "Eva": ("E", "sun", "ar"), "Paul": ("P", "lilac", "rs"), "Nora": ("N", "coral", "lf")}

def av(name, size=54):
    l, c, s = PEOPLE[name]
    return f'<span class="av a-{c} {s}" style="width:{size}px;height:{size}px;font-size:{size*0.4:.0f}px">{l}</span>'

KINDS = [("chat", "Wrote"), ("phone", "Called"), ("people", "Met"), ("controller", "Played")]

# ---- sections: (label, html) in three styles ----
def what_old():
    return '<div class="row">' + "".join(f'<span class="chip{" on" if i == 0 else ""}">{n}</span>' for i, (_, n) in enumerate(KINDS)) + '</div>'

def what_tiles(labels):  # labels: "all" or "sel"
    out = ""
    for i, (ic, n) in enumerate(KINDS):
        on = i == 2
        show = labels == "all" or on
        cls = "tile" + (" on" if on else "")
        out += f'<div class="{cls}"><div class="tb">{ico(ic, 44)}</div>' + (f'<span>{n}</span>' if show else '<span>&nbsp;</span>') + '</div>'
    return f'<div class="tiles">{out}</div>'

def when_old():
    return '<div class="row">' + "".join(f'<span class="chip{" on" if i == 0 else ""}">{n}</span>' for i, n in enumerate(["Today", "Yesterday", "Pick a day"])) + '</div>'

def when_d1():
    ch = [("Today", 1), ("Yesterday", 0), ("SAT 21", 0)]
    return ('<div class="strip">' + "".join(f'<span class="chip{" on" if o else ""}">{t}</span>' for t, o in ch)
            + f'<span class="cal">{ico("calendar", 26)}</span></div>')

def when_d2():
    days = [("Today", "23", 1, -2), ("Yesterday", "22", 0, 2), ("Sat", "21", 0, -2), ("Fri", "20", 0, 3), ("Thu", "19", 0, -2)]
    cells = "".join(f'<span class="db{" on" if o else ""}" style="transform:rotate({t}deg)"><small>{w}</small><b>{d}</b></span>' for w, d, o, t in days)
    return f'<div class="strip" style="gap:9px;padding:4px 0 6px">{cells}</div>'

def with_old():
    c = "".join(f'<span class="chip" style="gap:8px;padding:0 10px 0 8px">{av(n,24)}{n}</span>' for n in ["Tom", "Franz", "Lucy"])
    return f'<div class="row" style="flex-wrap:wrap">{c}<span class="chip">+ Add person</span></div>'

def with_faces():
    f = "".join(f'<div class="face">{av(n)}<span>{n}</span></div>' for n in ["Tom", "Franz", "Lucy"])
    return f'<div class="faces">{f}<div class="face"><div class="add">{PLUS.format(24)}</div><span>&nbsp;</span></div></div>'

def activity():
    return f'<div class="row"><span class="chip" style="gap:8px;padding:0 14px 0 10px">{ico("dice", 24)}Add an activity</span></div>'

def sheet(secs, style, extra_cls=""):
    """secs: list of (label, html). style: plain | cards."""
    out = ""
    for i, (lab, h) in enumerate(secs):
        if style == "cards":
            out += f'<div class="card t{i+1}"><p class="l" style="color:#2A1B3D;opacity:.7">{lab}</p>{h}</div>'
        else:
            out += f'<div class="sec"><p class="l">{lab}</p>{h}</div>'
    gap = "10px" if style == "cards" else "16px"
    bg = "#FFFFFF" if style == "plain" else "var(--bg)"
    return (f'<div class="sheet" style="gap:{gap};background:{bg}"><div class="grab"></div><h1>We were in touch</h1>{out}'
            f'<div class="btn" style="margin-top:2px">Save</div></div>')

BACK = '<div class="back"><h1 style="margin-bottom:14px">Tom</h1><div class="blk"></div><div class="blk"></div><div class="blk"></div></div><div class="scrim"></div>'

def phone(inner):
    return f'<div class="s">{BACK}{inner}</div>'

def secs(what, when, with_):
    return [("What", what), ("When", when), ("With", with_), ("Activity", activity())]

def picker(selected):
    names = ["Franz", "Lucy", "Anna", "Mark", "Sofia", "Jonas", "Maya", "Ben", "Eva", "Paul", "Nora", "Anna"][:11]
    cells = ""
    for n in names:
        sel = n in selected
        cells += (f'<div class="g"><div class="pw{" sel" if sel else ""}">{av(n,60)}'
                  + (f'<span class="ck">{CHECK.format(15)}</span>' if sel else "") + f'</div><span>{n}</span></div>')
    return (f'<div class="scrim" style="background:rgba(31,19,38,.45)"></div>'
            f'<div class="sheet" style="top:150px;gap:14px;background:#FFFFFF"><div class="grab"></div>'
            f'<div style="display:flex;align-items:baseline;justify-content:space-between"><h1 style="font-size:22px">Who else was there?</h1><span class="sub">{len(selected)} chosen</span></div>'
            f'<div class="search">{SEARCH}<span>Search people</span></div><div class="grid">{cells}</div>'
            f'<div style="flex:1"></div><div class="btn">Done</div></div>')

def labelled(items):
    return '<div class="pair">' + "".join(f'<div><p class="lab">{l}</p>{p}</div>' for l, p in items) + '</div>'

# Each picture: file name -> (title, content html, width)
old = (what_old(), when_old(), with_old())
P = {}
P["A-what-tiles"] = ("A What as tiles", labelled([
    ("A1 · every tile has a label", phone(sheet(secs(what_tiles("all"), old[1], old[2]), "plain"))),
    ("A2 · label only on the chosen tile", phone(sheet(secs(what_tiles("sel"), old[1], old[2]), "plain")))]), 860)
P["B-with-faces"] = ("B With as faces", labelled([
    ("B · faces and a dashed plus", phone(sheet(secs(old[0], old[1], with_faces()), "plain")))]), 430)
P["C-people-picker"] = ("C People picker", labelled([
    ("C · picker slides up, two chosen", '<div class="s">' + BACK + picker({"Franz", "Lucy"}) + '</div>')]), 430)
P["D-when-strip"] = ("D When as a strip of days", labelled([
    ("D1 · labels and weekday chips", phone(sheet(secs(old[0], when_d1(), old[2]), "plain"))),
    ("D2 · date badges", phone(sheet(secs(old[0], when_d2(), old[2]), "plain")))]), 860)
P["E-full-sheet"] = ("E Full sheet", labelled([
    ("E1 · plain white sections", phone(sheet(secs(what_tiles("sel"), when_d2(), with_faces()), "plain"))),
    ("E2 · soft tinted cards", phone(sheet(secs(what_tiles("sel"), when_d2(), with_faces()), "cards")))]), 860)

FONTS = ('<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">')

def plain(title, body):
    return (f'<!doctype html><html lang="en"><head><meta charset="utf-8"><title>{title}</title>{FONTS}'
            f'<style>{CSS}body{{background:#EDE3D6;padding:0}}</style></head><body><div style="padding:16px;width:fit-content">{body}</div></body></html>')

def dc(title, w, h, body):
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
{FONTS}
<style>{CSS}
.w{{padding:16px;background:#EDE3D6;width:{w}px;height:{h}px}}</style>
</helmet>
<div class="w">{body}</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{props}'>
class Component extends DCLogic {{
renderVals() {{ return {{}}; }}
}}
</script>
</body>
</html>
"""

canvas_path = CONCEPTS / "canvas.json"
canvas = json.loads(canvas_path.read_text())
pref = "LogSheet" + TAG.upper()
mine = lambda k: k.startswith(pref)
for k in [k for k in canvas["boards"] if mine(k)]:
    del canvas["boards"][k]
canvas["order"] = [k for k in canvas["order"] if not mine(k)]
x = 0
for key, (title, body, w) in P.items():
    W, H = w + 32 - 40 + 40, 844 + 32 + 30
    W = w + 32
    (HERE / f"{key}.html").write_text(plain(title, body))
    fname = f"{pref}{key.split('-')[0]}.dc.html"
    (CONCEPTS / fname).write_text(dc(title, W, H, body))
    canvas["boards"][fname] = {"x": x, "y": TOP + 300, "w": W, "h": H, "title": f"Log sheet {TAG} · {title}"}
    canvas["order"].append(fname)
    x += W + 80
canvas["notes"]["t" + pref] = {"x": 0, "y": TOP, "w": 240, "kind": "title1", "maxW": 2740,
    "text": "Log sheet v1: redesign of \"We were in touch\" (tiles for What, faces for With, picker, strip of days), light"}
canvas_path.write_text(json.dumps(canvas, indent=2, ensure_ascii=False) + "\n")
print(list(P))
