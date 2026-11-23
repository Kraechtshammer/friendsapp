"""Flow pictures F and G for the log sheet (round v1, chosen look A2 + D2 + E1 + faces).
Reuses gen.py's styles and helpers (everything above its picture list). Run: python3 gen2.py
Writes F-flow.html, G-home-card.html, boards LogSheetV1F/G.dc.html and canvas rows. PNGs: headless Edge as in gen.py."""
import json, pathlib
src = (pathlib.Path(__file__).parent / "gen.py").read_text().split("# Each picture")[0]
src = src.replace("__file__", repr(str(pathlib.Path(__file__).resolve().parent / "gen.py")))
exec(src)
FONTS = '<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">'

CSS += """
.gb{height:48px;border-radius:24px;background:var(--s2);box-shadow:0 4px 0 var(--s2d);display:flex;align-items:center;justify-content:center;font:600 16px Outfit;color:var(--on)}
.gb.tap{background:var(--sun);box-shadow:0 1px 0 var(--sund);transform:translateY(3px);outline:3px solid rgba(255,207,92,.45);outline-offset:3px}
.tapdot{position:absolute;width:46px;height:46px;border-radius:50%;background:rgba(42,27,61,.22);border:2px solid rgba(42,27,61,.5)}
.pg{position:absolute;inset:0;padding:20px 16px;display:flex;flex-direction:column;gap:14px}
.pg .card{padding:14px 16px}
.hd{display:flex;gap:16px;align-items:center}
.tag{display:inline-block;background:var(--lilacc);border-radius:10px;padding:2px 10px;font:600 12px Outfit;transform:rotate(2deg)}
.cap{font:600 15px Outfit;text-align:center;color:#2A1B3D;margin-top:10px;width:390px}
.arrow{align-self:center;margin-top:-30px}
.sunc{background:var(--sunc);border-radius:28px;padding:16px;box-shadow:0 5px 0 rgba(196,150,42,.5);display:flex;flex-direction:column;gap:14px}
.tiles.sm{gap:8px}.tiles.sm .tb{border-radius:18px}
.fld{background:var(--bg);border-radius:16px;height:44px;display:flex;align-items:center;padding:0 14px;color:var(--mut);font-size:15px}
.nav{position:absolute;left:0;right:0;bottom:0;height:72px;background:var(--s1);display:flex;justify-content:space-around;align-items:center;font:600 12px Outfit;color:var(--mut)}
"""

def days2():
    days = [("Today", "23", 1, -2), ("Yday", "22", 0, 2), ("Sat", "21", 0, -2), ("Fri", "20", 0, 3), ("Thu", "19", 0, -2)]
    c = "".join(f'<span class="db{" on" if o else ""}" style="transform:rotate({t}deg)"><small>{w}</small><b>{d}</b></span>' for w, d, o, t in days)
    return f'<div class="strip" style="gap:9px;padding:4px 0 6px">{c}</div>'

def secs2(): return [("What", what_tiles("sel")), ("When", days2()), ("With", with_faces()), ("Activity", activity())]

def person_page(tap=False):
    tapdot = '<span class="tapdot" style="left:290px;top:188px"></span>' if tap else ''
    return (f'<div class="pg"><div class="hd">{av("Tom", 84)}<div><h1>Tom</h1><span class="tag">Reconnecting</span></div></div>'
            f'<div class="btn" style="background:var(--s2);box-shadow:0 4px 0 var(--s2d)">Open WhatsApp</div>'
            f'<div class="gb{" tap" if tap else ""}">We were in touch</div>'
            f'<div class="row"><div class="gb" style="flex:1">They wrote</div><div class="gb" style="flex:1">They called</div></div>'
            f'<div class="card"><p class="l">On your mind</p><div style="font-size:16px">Ask about the bouldering trip</div></div>'
            f'<div class="card"><p class="l">Notes</p><div style="font-size:16px;color:var(--mut)">Likes climbing, dislikes phone calls</div></div>{tapdot}</div>')

def sheet1(): return sheet(secs2(), "plain")

def pick2(sel, top, n=8):
    names = ["Franz", "Lucy", "Anna", "Mark", "Sofia", "Jonas", "Maya", "Ben"][:n]
    cells = "".join(f'<div class="g"><div class="pw{" sel" if x in sel else ""}">{av(x,60)}' + (f'<span class="ck">{CHECK.format(15)}</span>' if x in sel else "") + f'</div><span>{x}</span></div>' for x in names)
    return (f'<div class="scrim" style="background:rgba(31,19,38,.45)"></div><div class="sheet" style="top:{top}px;background:#fff;gap:12px;box-shadow:0 -4px 0 rgba(0,0,0,.12),0 -10px 30px rgba(0,0,0,.25)"><div class="grab"></div>'
            f'<div style="display:flex;align-items:baseline;justify-content:space-between"><h1 style="font-size:22px">Who else was there?</h1><span class="sub">{len(sel)} chosen</span></div>'
            f'<div class="search">{SEARCH}<span>Search people</span></div><div class="grid">{cells}</div><div style="flex:1"></div><div class="btn">Done</div></div>')

def fr(inner, cap):
    return f'<div><div class="s">{inner}</div><p class="cap">{cap}</p></div>'

ARR = '<svg class="arrow" width="40" height="30" viewBox="0 0 40 30"><path d="M4 15h28M24 7l8 8-8 8" fill="none" stroke="#2A1B3D" stroke-width="3.4" stroke-linecap="round" stroke-linejoin="round"/></svg>'

# F: flow. Frame 3: first sheet visible behind the second one, dimmed
f3 = person_page() + '<div class="scrim"></div>' + sheet1() + '<div class="scrim" style="background:rgba(31,19,38,.35)"></div>' + pick2({"Franz", "Lucy"}, 330, 8).replace('<div class="scrim" style="background:rgba(31,19,38,.45)"></div>', '', 1)
F = ('<div class="pair" style="gap:16px">' + fr(person_page(True), "1 · Tap “We were in touch”") + ARR
     + fr(person_page() + '<div class="scrim"></div>' + sheet1(), "2 · The log sheet slides up") + ARR
     + fr(f3, "3 · “+” opens the people picker on top") + '</div>')

# G: Home with the capture card, state "Already happened"
def home(inner_after=""):
    people = "".join(f'<div class="face" style="width:52px">{av(n,44)}<span>{n}</span></div>' for n in ["Tom", "Franz", "Lucy", "Anna"])
    ring = f'<style>.sel44{{box-shadow:0 0 0 3px #fff,0 0 0 5px var(--coral);border-radius:50%}}</style>'
    people = people.replace(av("Tom", 44), f'<span class="sel44">{av("Tom",44)}</span>', 1)
    tiles = what_tiles("sel").replace('class="tiles"', 'class="tiles sm"')
    card = (f'<div class="sunc"><h2 class="o" style="margin:0;font-size:22px">Who\'s on your mind?</h2>'
            f'<div class="fld">saw a bouldering video…</div><div class="faces" style="gap:10px">{people}</div>{tiles}'
            f'<div><span class="chip on" style="height:38px">Already happened</span></div>{days2()}'
            f'<div class="faces" style="gap:12px">{"".join(f"<div class=face style=width:50px>{av(n,44)}<span>{n}</span></div>" for n in ["Tom","Franz","Lucy"])}<div class="face" style="width:50px"><div class="add" style="width:44px;height:44px">{PLUS.format(22)}</div></div></div>'
            f'<div class="btn">Save</div></div>')
    page = (f'<div class="pg" style="padding-top:18px;gap:14px"><h1>Kept.</h1>{card}</div>'
            f'<div class="nav"><span>Home</span><span>People</span><span>Meetups</span><span>More</span></div>')
    return ring + page + inner_after
G = ('<div class="pair" style="gap:40px">' + fr(home(), "Capture card, “Already happened”") + fr(home('<div class="scrim"></div>').replace('</div></div><div class="nav">', '</div></div><div class="nav">') + pick2({"Franz", "Lucy"}, 300, 8).replace('<div class="scrim" style="background:rgba(31,19,38,.45)"></div>', '', 1), "After tapping “+”: the picker slides up") + '</div>')

_g = (pathlib.Path(__file__).parent / 'gen.py').read_text()
exec('def plain' + _g.split('def plain')[1].split('canvas_path =')[0])
NEW = {"F-flow": ("F Flow from the person page", F, 1280 + 0), "G-home-card": ("G Home capture card", G, 860)}
canvas_path = CONCEPTS / "canvas.json"
canvas = json.loads(canvas_path.read_text())
x = 3028 + 892 + 80
for key, (title, body, w) in NEW.items():
    W, H = w + 32, 844 + 32 + 60
    if key.startswith("F"): W = 3 * 390 + 2 * 72 + 32
    (HERE / f"{key}.html").write_text(plain(title, body))
    fname = f"LogSheetV1{key[0]}.dc.html"
    (CONCEPTS / fname).write_text(dc(title, W, H, body))
    canvas["boards"][fname] = {"x": x, "y": TOP + 300, "w": W, "h": H, "title": f"Log sheet {TAG} · {title}"}
    if fname not in canvas["order"]: canvas["order"].append(fname)
    x += W + 80
canvas_path.write_text(json.dumps(canvas, indent=2, ensure_ascii=False) + "\n")
