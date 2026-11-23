"""Round v3: final Home flow J and log sheet K. Reuses v1/v2 helpers by exec; writes only v3 files, boards LogSheetV3*.dc.html and canvas rows.
Run: python3 gen4.py. PNGs: headless Edge as in gen.py."""
import json, pathlib
HERE3 = pathlib.Path(__file__).resolve().parent
V2 = HERE3.parent / "log-sheet-v2"
g3 = (V2 / "gen3.py").read_text()
head = g3.split("# new icons")[0].replace("HERE2 = pathlib.Path(__file__).resolve().parent", "HERE2 = pathlib.Path(" + repr(str(V2)) + ")").replace("(V1 / \"gen2.py\").read_text()", "(V1 / \"gen2.py\").read_text()")
exec(head)
exec("CAL = lambda" + g3.split("CAL = lambda")[1].split("f1 = homecard")[0])
HERE = HERE3
TAG = "v3"
CSS += """
.wc{display:flex;gap:6px}.wc .chip{flex:1;justify-content:center;padding:0 4px;gap:5px;height:42px;border-radius:14px}
.fl{font:600 12px Outfit;color:var(--mut);margin:0 0 6px 4px}
"""
def chips(on):
    out = ""
    for i, n in enumerate(["Done", "Soon", "Later", "Date", "When…"]):
        ic = f'<span style="display:flex">{CAL(16)}</span>' if n == "Date" else ""
        out += f'<span class="chip{" on" if i == on else ""}">{ic}{n}</span>'
    return f'<div class="wc">{out}</div>'
def card(names, extra, btn="Save", fld="saw a bouldering video…"):
    c = (f'<div class="sunc"><h2 class="o" style="margin:0;font-size:22px">Who\'s on your mind?</h2><div class="fld">{fld}</div>'
         f'{who(names)}{extra}<div class="btn">{btn}</div></div>')
    return (f'<div class="pg" style="padding-top:18px;gap:14px"><h1>Kept.</h1>{c}</div>'
            f'<div class="nav"><span>Home</span><span>People</span><span>Meetups</span><span>More</span></div>')
f1 = card([], "", "Save")
f1 = f1.replace('<div class="btn">Save</div>', '<div class="btn" style="opacity:.45">Save</div>')
pk = pick2({"Franz", "Lucy"}, 300, 8).replace('<div class="scrim" style="background:rgba(31,19,38,.45)"></div>', '', 1).replace("Who else was there?", "Who's on your mind?")
f2 = f1 + '<div class="scrim"></div>' + pk
f3 = card(["Franz", "Lucy"], kinds() + chips(1), "Save for Franz and Lucy")
f4 = card(["Franz", "Lucy"], kinds() + chips(0) + days3("a"), "Save")
J = ('<div class="pair" style="gap:40px">' + fr(f1, "1 · Empty card: pick people") + fr(f2, "2 · The picker slides up") + fr(f3, "3 · A plan: saved as one thought each") + fr(f4, "4 · Done: pick the day") + '</div>')

def sec(l, h): return f'<div class="sec"><p class="l">{l}</p>{h}</div>'
sh = (f'<div class="sheet" style="gap:16px;background:#fff"><div class="grab"></div><h1>We were in touch</h1>'
      f'{sec("What", kinds())}{sec("When", days3("a"))}{sec("With", who(["Tom","Franz","Lucy"]))}{sec("Activity", activity())}<div class="btn" style="margin-top:2px">Save</div></div>')
K = '<div class="pair">' + fr(person_page() + '<div class="scrim"></div>' + sh, "“We were in touch” over Tom's page") + '</div>'

exec('def plain' + _g.split('def plain')[1].split('canvas_path =')[0])
NEW = {"J-home-flow": ("J Home flow", J, 4 * 390 + 3 * 40), "K-log-sheet": ("K Log sheet", K, 390)}
canvas_path = CONCEPTS / "canvas.json"
canvas = json.loads(canvas_path.read_text())
x = 0; Y = 21400
for key, (title, body, w) in NEW.items():
    W, Hh = w + 32, 844 + 32 + 60
    (HERE / f"{key}.html").write_text(plain(title, body))
    fname = f"LogSheetV3{key[0]}.dc.html"
    (CONCEPTS / fname).write_text(dc(title, W, Hh, body))
    canvas["boards"][fname] = {"x": x, "y": Y, "w": W, "h": Hh, "title": f"Log sheet {TAG} · {title}"}
    if fname not in canvas["order"]: canvas["order"].append(fname)
    x += W + 80
canvas["notes"]["tLogSheetV3"] = {"x": 0, "y": Y - 300, "w": 240, "kind": "title1", "maxW": 2740, "text": "Log sheet v3: final Home flow and log sheet"}
canvas_path.write_text(json.dumps(canvas, indent=2, ensure_ascii=False) + "\n")
