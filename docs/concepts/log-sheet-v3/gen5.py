"""Round v3, picture L: Home card with suggested faces. Reuses gen4.py helpers (without its output step). Run: python3 gen5.py"""
import json, pathlib
_here = pathlib.Path(__file__).resolve().parent
_src = (_here / "gen4.py").read_text()
exec(compile(_src.replace('__file__', repr(str(_here / "gen4.py"))).split("\ncanvas_path = CONCEPTS")[0], "gen4", "exec"))
CSS += """
.sg{display:flex;gap:6px;align-items:flex-start}
.sg .fc{display:flex;flex-direction:column;align-items:center;gap:6px;width:46px;font:500 12px Roboto}
.sg .pw{width:42px;height:42px}.sg .pw .av{width:40px;height:40px;font-size:16px}
.sg .pw.sel{box-shadow:0 0 0 2px #fff,0 0 0 4px var(--coral)}
.sg .pw.sel .av{width:40px;height:40px}
.sg .ck{width:18px;height:18px;right:-5px;bottom:-5px;box-shadow:0 1px 0 rgba(0,0,0,.3),0 0 0 2px var(--bg)}
.sg .fd .av{opacity:.45}.sg .fd span{color:var(--mut)}
.sg .add{width:42px;height:42px}
.oft{font:600 11px Outfit;color:var(--mut);margin:0 0 -6px 2px;letter-spacing:.04em}
"""
def sug(chosen, rest):
    o = ""
    for n in chosen:
        o += f'<div class="fc"><div class="pw sel">{av(n,40)}<span class="ck">{CHECK.format(11)}</span></div><span>{n}</span></div>'
    for n in rest:
        o += f'<div class="fc fd"><div class="pw">{av(n,40)}</div><span>{n}</span></div>'
    o += f'<div class="fc"><div class="add">{PLUS.format(20)}</div><span>More</span></div>'
    return f'<p class="oft">Often</p><div class="sg">{o}</div>'
def card2(row, extra, btn):
    c = (f'<div class="sunc"><h2 class="o" style="margin:0;font-size:22px">Who\'s on your mind?</h2><div class="fld">saw a bouldering video…</div>'
         f'{row}{extra}<div class="btn"{" style=opacity:.45" if btn=="Save" else ""}>{btn}</div></div>')
    return (f'<div class="pg" style="padding-top:18px;gap:14px"><h1>Kept.</h1>{c}</div>'
            f'<div class="nav"><span>Home</span><span>People</span><span>Meetups</span><span>More</span></div>')
s = ["Tom", "Anna", "Franz", "Maya"]
a = card2(sug([], s), "", "Save")
b = card2(sug(["Tom", "Franz"], ["Anna", "Maya"]), kinds() + chips(1), "Save for Tom and Franz")
c = card2(sug(["Tom", "Franz", "Lucy"], ["Anna", "Maya"]), kinds() + chips(1), "Save for Tom, Franz and Lucy")
L = '<div class="pair" style="gap:40px">' + fr(a, "1 · Empty card: often-used people") + fr(b, "2 · Tom and Franz tapped") + fr(c, "3 · Lucy added via “More”") + '</div>'
key, title, w = "L-home-suggested", "L Home suggested", 3 * 390 + 2 * 40
W, Hh = w + 32, 844 + 32 + 60
(HERE / f"{key}.html").write_text(plain(title, L))
fname = "LogSheetV3L.dc.html"
(CONCEPTS / fname).write_text(dc(title, W, Hh, L))
cp = CONCEPTS / "canvas.json"; cv = json.loads(cp.read_text())
prev = [v for k, v in cv["boards"].items() if k == "LogSheetV3K.dc.html"][0]
cv["boards"][fname] = {"x": prev["x"] + prev["w"] + 80, "y": prev["y"], "w": W, "h": Hh, "title": f"Log sheet v3 · {title}"}
if fname not in cv["order"]: cv["order"].append(fname)
cp.write_text(json.dumps(cv, indent=2, ensure_ascii=False) + "\n")
