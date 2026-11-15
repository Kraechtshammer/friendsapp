"""Generates the V3 tryout artboards: V2 ideas remixed with Material 3 Expressive.
Dark and light theme, Material Symbols instead of emoji.
Usage: python3 gen_v3.py <design/project folder> <docs/concepts folder>"""
import json, math, pathlib, shutil, sys

OUT = pathlib.Path(sys.argv[1])
DOCS = pathlib.Path(sys.argv[2])

def cookie(n=8, depth=0.07, steps=96):
    pts = []
    for i in range(steps):
        t = 2 * math.pi * i / steps
        r = 0.5 - depth + depth * math.cos(n * t)
        pts.append("%.1f%% %.1f%%" % (50 + 100 * r * math.cos(t), 50 + 100 * r * math.sin(t)))
    return "polygon(" + ",".join(pts) + ")"

CSS = """
body{margin:0}
.s{width:390px;height:844px;box-sizing:border-box;background:var(--bg);color:var(--on);font-family:'Roboto',system-ui,sans-serif;display:flex;flex-direction:column;font-size:16px;line-height:1.35;position:relative;overflow:hidden;
--coral:#FF8A7A;--sun:#FFCF5C;--mint:#7EDDBE;--lilac:#C3B4FF;--sky:#8CCBFF;--pink:#FF9EC6;--onacc:#1F1326}
.dark{--bg:#17121C;--s1:#231C2A;--s2:#30273A;--on:#EFE3F2;--mut:#BBADC2;--line:#54475E;
--sunc:#46380F;--onsunc:#FFE29A;--mintc:#12433A;--onmintc:#A6F0D8;--lilacc:#352B63;--onlilacc:#DCD3FF;--pinkc:#54213A;--onpinkc:#FFC4DC;--skyc:#173F5E;--onskyc:#BFE2FF;--coralc:#5A231C;--oncoralc:#FFC2B8}
.light{--bg:#FFF6EA;--s1:#FFFFFF;--s2:#F6E9DA;--on:#2A1B3D;--mut:#6B5A7A;--line:#CDBBA8;
--sunc:#FFE08A;--onsunc:#2A1B3D;--mintc:#BDEFDD;--onmintc:#2A1B3D;--lilacc:#DDD4FF;--onlilacc:#2A1B3D;--pinkc:#FFD0E2;--onpinkc:#2A1B3D;--skyc:#C6E5FF;--onskyc:#2A1B3D;--coralc:#FFC9C0;--oncoralc:#2A1B3D}
.c{flex:1;padding:22px 16px 12px;display:flex;flex-direction:column;gap:14px;overflow:hidden}
h1,h2,.f{font-family:'Outfit','Roboto',sans-serif}
h1{margin:0;font-size:30px;font-weight:700;line-height:1.15}
h2{margin:0;font-size:21px;font-weight:600;line-height:1.2}
p{margin:0}
a{color:inherit}
.ic{font-family:'Material Symbols Rounded';font-weight:normal;font-style:normal;font-size:24px;line-height:1;letter-spacing:normal;text-transform:none;display:inline-block;white-space:nowrap;direction:ltr;font-feature-settings:'liga';-webkit-font-smoothing:antialiased;font-variation-settings:'FILL' 1,'wght' 500,'GRAD' 0,'opsz' 24;flex:none}
.card{background:var(--s1);border-radius:28px;padding:16px;display:flex;flex-direction:column;gap:12px}
.t-sun{background:var(--sunc);color:var(--onsunc)}.t-mint{background:var(--mintc);color:var(--onmintc)}.t-lilac{background:var(--lilacc);color:var(--onlilacc)}.t-pink{background:var(--pinkc);color:var(--onpinkc)}.t-sky{background:var(--skyc);color:var(--onskyc)}.t-coral{background:var(--coralc);color:var(--oncoralc)}
.a-sun{background:var(--sun);color:var(--onacc)}.a-mint{background:var(--mint);color:var(--onacc)}.a-lilac{background:var(--lilac);color:var(--onacc)}.a-pink{background:var(--pink);color:var(--onacc)}.a-sky{background:var(--sky);color:var(--onacc)}.a-coral{background:var(--coral);color:var(--onacc)}
.b{height:52px;box-sizing:border-box;border:0;border-radius:26px;font:600 17px 'Outfit','Roboto',sans-serif;padding:0 20px;background:var(--coral);color:var(--onacc);display:inline-flex;align-items:center;justify-content:center;gap:8px;text-decoration:none}
.b2{background:var(--s2);color:var(--on)}
.ib{width:52px;height:52px;padding:0;border-radius:18px;flex:none}
.chip{height:44px;box-sizing:border-box;border-radius:14px;border:1.5px solid var(--line);background:transparent;color:inherit;font:500 14px 'Roboto',sans-serif;padding:0 14px}
.tag{align-self:flex-start;font:600 13px 'Outfit','Roboto',sans-serif;padding:4px 12px;border-radius:14px}
.m{color:var(--mut);font-size:14px}
[class*="t-"] .m{color:inherit;opacity:.82}
.l{font:600 13px 'Outfit','Roboto',sans-serif;letter-spacing:.08em;text-transform:uppercase}
.av{width:48px;height:48px;box-sizing:border-box;display:flex;align-items:center;justify-content:center;font:700 20px 'Outfit','Roboto',sans-serif;flex:none;text-decoration:none;border-radius:50%}
.sh1{clip-path:__COOKIE__;border-radius:0}
.sh2{border-radius:34%}
.sh3{border-radius:50% 50% 50% 22%}
.sh4{border-radius:50% 50% 24% 24%}
.sh5{clip-path:__COOKIE6__;border-radius:0}
.who{display:flex;flex-direction:column;align-items:center;gap:4px;font-weight:500;font-size:13px;background:none;border:0;padding:0;color:inherit;font-family:inherit;min-width:54px}
.in{box-sizing:border-box;width:100%;height:52px;border:0;border-radius:26px;padding:0 18px;font:400 16px 'Roboto',sans-serif;color:var(--on);background:var(--bg)}
.in::placeholder{color:var(--mut)}
.row{display:flex;gap:10px;align-items:center}
.nav{display:flex;background:var(--s1);padding:0 4px}
.nav a{flex:1;height:76px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:4px;font:500 12px 'Roboto',sans-serif;color:var(--mut);text-decoration:none}
.nav a .ic{width:60px;height:32px;border-radius:16px;display:flex;align-items:center;justify-content:center}
.nav a.cur{color:var(--on);font-weight:700}
.nav a.cur .ic{background:var(--sun);color:var(--onacc)}
.tl{position:relative;display:flex;flex-direction:column;gap:8px}
.tl::before{content:"";position:absolute;left:27px;top:8px;bottom:8px;width:2px;background:var(--line)}
.tl .l{position:relative;align-self:flex-start;background:var(--bg);padding:3px 8px 3px 0;color:var(--mut)}
.ev{position:relative;display:flex;gap:10px;align-items:center}
.dt{width:56px;height:58px;box-sizing:border-box;flex:none;border-radius:18px;display:flex;flex-direction:column;align-items:center;justify-content:center;font:600 11px 'Outfit','Roboto',sans-serif;letter-spacing:.08em;line-height:1.1}
.dt b{font-size:23px;letter-spacing:0}
.evc{flex:1;background:var(--s1);border-radius:20px;padding:9px 14px;font-weight:500;display:flex;align-items:center;gap:10px;min-height:58px;box-sizing:border-box}
.evc div{flex:1}
.evc .m{font-size:13px}
.st{width:56px;height:56px;display:flex;align-items:center;justify-content:center;flex:none}
.st.e{box-sizing:border-box;border:2px dashed currentColor;border-radius:50%;opacity:.6;width:50px;height:50px;margin:3px}
.dy{flex:1;display:flex;flex-direction:column;align-items:center;gap:5px;font-size:12px;font-weight:500;color:var(--mut)}
.dy i{width:36px;height:36px;box-sizing:border-box;border-radius:50%;display:flex;align-items:center;justify-content:center;font-style:normal;background:var(--s2)}
.dy i.y{background:var(--mint);color:var(--onacc);border-radius:0;clip-path:__COOKIE__}
.dy i.f{background:transparent;border:2px dashed var(--line)}
""".replace("__COOKIE6__", cookie(6, 0.06)).replace("__COOKIE__", cookie(8, 0.05))

def ic(name, size=24, style=""):
    return '<span class="ic" aria-hidden="true" style="font-size:%dpx;%s">%s</span>' % (size, style, name)

def nav(cur):
    items = [("Home", "home", "Home"), ("Upcoming", "event_upcoming", "Upcoming"), ("People", "group", "People"), ("Progress", "local_activity", "Progress")]
    out = ['<nav class="nav">']
    for name, icon, f in items:
        c = ' class="cur" aria-current="page"' if name == cur else ''
        href = "#" if f == "People" else "V3%s__T__.dc.html" % f   # no V3 People screen yet
        out.append('<a%s href="%s">%s%s</a>' % (c, href, ic(icon), name))
    out.append('</nav>')
    return "\n".join(out)

def who(letter, name, col, shape, size=48):
    return '<button class="who"><span class="av a-%s %s" style="width:%dpx;height:%dpx" aria-hidden="true">%s</span>%s</button>' % (col, shape, size, size, letter, name)

def ev(dow, day, col, title, sub, icon):
    return ('<div class="ev"><div class="dt a-%s">%s<b>%s</b></div><div class="evc"><div>%s<p class="m">%s</p></div>%s</div></div>'
            % (col, dow, day, title, sub, ic(icon, 24, "color:var(--%s)" % col)))

HOME = """
<div class="c">
<div class="row" style="justify-content:space-between"><h1>Good evening</h1><button class="b b2 ib" aria-label="Settings">""" + ic("settings") + """</button></div>
<div class="card t-sun">
<h2>Who's on your mind?</h2>
<div class="row"><input class="in" aria-label="What came to mind" placeholder="saw a bouldering video…"><button class="b ib a-sun" aria-label="Save">""" + ic("add", 28) + """</button></div>
<div class="row" style="justify-content:space-between">
""" + who("T", "Tom", "mint", "sh1") + who("A", "Anna", "pink", "sh2") + who("J", "Jonas", "lilac", "sh3") + who("M", "Maria", "sky", "sh4") + """
<button class="who"><span class="av" style="background:var(--bg);color:var(--on)">""" + ic("search") + """</span>More</button>
</div>
</div>
<div class="card">
<span class="tag a-coral" style="transform:rotate(-3deg);margin:-28px 0 0 -4px">Tonight's pick</span>
<div class="row" style="gap:14px"><span class="av a-mint sh1" style="width:60px;height:60px;font-size:26px" aria-hidden="true">T</span><div><h2>Tom</h2><p class="m">Close friend · WhatsApp</p></div></div>
<p style="background:var(--s2);border-radius:6px 20px 20px 20px;padding:11px 14px">“Saw a bouldering video. Ask if he's up for Saturday.”</p>
<div class="row"><button class="b" style="flex:1">""" + ic("chat") + """Open chat</button><button class="b b2 ib" aria-label="Another one">""" + ic("shuffle") + """</button><button class="b b2 ib" aria-label="Done">""" + ic("check") + """</button></div>
</div>
<div class="row" style="justify-content:space-between"><p class="l" style="color:var(--mut)">Coming up</p><a class="f row" style="font-weight:600;font-size:14px;gap:2px;text-decoration:none;min-height:24px" href="V3Upcoming__T__.dc.html">See all""" + ic("arrow_forward", 18) + """</a></div>
<div class="row" style="align-items:stretch">
<div class="card t-pink" style="flex:1;padding:12px 14px;gap:4px;border-radius:22px"><div class="row" style="justify-content:space-between"><p class="l">Thu 19</p>""" + ic("cake", 20) + """</div><p style="font-weight:500">Anna's birthday</p></div>
<div class="card t-mint" style="flex:1;padding:12px 14px;gap:4px;border-radius:22px"><div class="row" style="justify-content:space-between"><p class="l">Sat 21</p>""" + ic("hiking", 20) + """</div><p style="font-weight:500">Bouldering, Tom</p></div>
</div>
</div>
""" + nav("Home")

UPCOMING = """
<div class="c" style="gap:12px">
<div><h1>Coming up</h1><p class="m">Birthdays and dates you have set. Nothing here is ever late.</p></div>
<div class="tl">
<p class="l">This week</p>
""" + ev("THU", "19", "pink", "Anna's birthday", "The app asks you that evening.", "cake") \
    + ev("SAT", "21", "mint", "Bouldering with Tom", "Meet-up · 11:00", "hiking") + """
<p class="l">Next week</p>
""" + ev("WED", "25", "sky", "Call Grandpa", "You picked this day.", "call") + """
<p class="l">December</p>
""" + ev("SUN", "6", "sun", "Aunt Maria visits the new flat", "Meet-up · afternoon", "cottage") \
    + ev("MON", "14", "pink", "Sophie's birthday", "Now and then", "cake") + """
</div>
<div class="card" style="background:transparent;border:2px dashed var(--line);gap:6px;padding:12px 14px">
<p class="l" style="color:var(--mut)">No date yet</p>
<div class="row" style="justify-content:space-between"><p style="font-weight:500">Board game night with the old gang</p><button class="b b2" style="height:44px;font-size:15px;padding:0 16px;flex:none">Pick a date</button></div>
</div>
</div>
""" + nav("Upcoming")

def day(lbl, cls, mark):
    return '<div class="dy"><i class="%s" aria-hidden="true">%s</i>%s</div>' % (cls, mark, lbl)

def pile(items):
    out = []
    for i, (e, c) in enumerate(items):
        out.append('<span class="av a-%s" style="width:38px;height:38px;font-size:16px;margin-left:%dpx;box-shadow:0 0 0 2.5px var(--mintc)" aria-hidden="true">%s</span>' % (c, 0 if i == 0 else -9, e))
    return "".join(out)

STAMP = '<span class="st a-coral sh1" style="transform:rotate(%ddeg)">' + ic("check", 28) + '</span>'

PROGRESS = """
<div class="c">
<h1>Your year so far</h1>
<div class="card t-mint">
<div class="row" style="gap:14px"><p class="f" style="font-size:68px;font-weight:700;line-height:.9">14</p><p style="font-weight:500">people reached this year. This number only ever grows.</p></div>
<div class="row" style="gap:0">""" + pile([("T", "sun"), ("A", "pink"), ("J", "lilac"), ("M", "sky"), ("S", "coral"), ("M", "sky"), ("G", "coral"), ("B", "lilac")]) + """<span class="av" style="width:38px;height:38px;margin-left:-9px;background:var(--bg);color:var(--on);font-size:13px;box-shadow:0 0 0 2.5px var(--mintc)">+6</span></div>
</div>
<div class="card t-sun">
<div class="row" style="justify-content:space-between"><p class="l">Treat stamp card</p><a class="f row" style="font-weight:600;font-size:14px;gap:2px;text-decoration:none;min-height:24px" href="#">My treats""" + ic("arrow_forward", 18) + """</a></div>
<div class="row">""" + ic("theaters", 26) + """<h2>Cinema evening</h2></div>
<div class="row" role="img" aria-label="2 of 3 stamps">""" + (STAMP % -8) + (STAMP % 6) + """<span class="st e"></span><p style="font-weight:500;margin-left:4px">One more person and it is yours.</p></div>
</div>
<div class="card">
<p class="l" style="color:var(--mut)">This week</p>
<div style="display:flex">""" + day("Mon", "y", ic("star", 18)) + day("Tue", "", "") + day("Wed", "", "") + day("Thu", "y", ic("star", 18)) + day("Fri", "", "") + day("Sat", "f", "") + day("Sun", "f", "") + """</div>
<p class="m">Star: you reached someone. Blank: not today, also a fine answer.</p>
<div class="row" style="border-top:1.5px solid var(--line);padding-top:10px">""" + ic("eco", 24, "color:var(--mint)") + """<p style="font-weight:500">3 weeks in a row. A quiet week pauses it, it never resets.</p></div>
</div>
<div class="card t-pink" style="padding:12px 16px;border-radius:22px"><p><b>This month:</b> 9 thoughts noted, 6 followed up.</p></div>
</div>
""" + nav("Progress")

TEMPLATE = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>__TITLE__</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">
<style>__CSS__</style>
</helmet>
<div class="s __THEME__">
__BODY__
</div>
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{"$preview":{"width":390,"height":844}}'>
class Component extends DCLogic {
renderVals() { return {}; }
}
</script>
</body>
</html>
"""

SCREENS = [
    ("V3HomeDark", "V3 · Home, dark", HOME, "dark"),
    ("V3UpcomingDark", "V3 · Upcoming, dark", UPCOMING, "dark"),
    ("V3ProgressDark", "V3 · Progress and stamp card, dark", PROGRESS, "dark"),
    ("V3HomeLight", "V3 · Home, light", HOME, "light"),
    ("V3UpcomingLight", "V3 · Upcoming, light", UPCOMING, "light"),
    ("V3ProgressLight", "V3 · Progress and stamp card, light", PROGRESS, "light"),
]

canvas = json.loads((OUT / "canvas.json").read_text())
Y = 3792
for i, (name, title, body, theme) in enumerate(SCREENS):
    f = name + ".dc.html"
    html = (TEMPLATE.replace("__TITLE__", title).replace("__CSS__", CSS).replace("__THEME__", theme)
            .replace("__BODY__", body.strip()).replace("__T__", theme.capitalize()))
    (OUT / f).write_text(html)
    canvas["boards"][f] = {"x": i * 470, "y": Y, "w": 390, "h": 844, "title": title}
    if f not in canvas["order"]:
        canvas["order"].append(f)
canvas["notes"]["t4"] = {"x": 0, "y": Y - 300, "text": "V3 tryout: V2 ideas in Material 3 Expressive, dark and light, no emoji", "kind": "title1", "maxW": 2740}
(OUT / "canvas.json").write_text(json.dumps(canvas, ensure_ascii=False, separators=(",", ":")))
for p in list(OUT.glob("V3*.dc.html")) + [OUT / "canvas.json"]:
    shutil.copy(p, DOCS / p.name)
print("ok", [s[0] for s in SCREENS])
