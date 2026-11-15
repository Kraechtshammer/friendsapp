"""Generates the V2 concept artboards (shared look, one body per screen)."""
import json, pathlib, shutil, sys

OUT = pathlib.Path(sys.argv[1])          # design/project
DOCS = pathlib.Path(sys.argv[2])         # docs/concepts

CSS = """
body{margin:0}
.s{width:390px;height:844px;box-sizing:border-box;background:#FFF4E4;color:#2A1B3D;font-family:'Nunito',system-ui,sans-serif;display:flex;flex-direction:column;font-size:16px;line-height:1.35;position:relative;overflow:hidden}
.c{flex:1;padding:22px 18px 12px;display:flex;flex-direction:column;gap:14px;overflow:hidden}
h1,h2,.f{font-family:'Fredoka','Nunito',sans-serif}
h1{margin:0;font-size:28px;font-weight:700;line-height:1.15}
h2{margin:0;font-size:20px;font-weight:600;line-height:1.2}
p{margin:0}
a{color:inherit}
.card{background:#fff;border:2.5px solid #2A1B3D;border-radius:24px;box-shadow:0 5px 0 #2A1B3D;padding:14px 16px;display:flex;flex-direction:column;gap:10px}
.sun{background:#FFD45C}.coral{background:#FF7A6B}.mint{background:#8FE3C8}.lilac{background:#CFC2FF}.sky{background:#A9D8FF}.pink{background:#FFB8D4}.cream{background:#FFF4E4}.white{background:#fff}
.b{height:48px;box-sizing:border-box;border:2.5px solid #2A1B3D;border-radius:16px;box-shadow:0 4px 0 #2A1B3D;font:600 17px 'Fredoka','Nunito',sans-serif;padding:0 14px;background:#FF7A6B;color:#2A1B3D}
.b2{background:#fff}
.chip{height:44px;box-sizing:border-box;border-radius:22px;border:2px solid #2A1B3D;background:#fff;color:#2A1B3D;font:700 14px 'Nunito',sans-serif;padding:0 14px}
.tag{align-self:flex-start;font:600 13px 'Fredoka','Nunito',sans-serif;padding:3px 10px;border-radius:12px;border:2px solid #2A1B3D}
.m{color:#6B5A7A;font-size:14px}
.l{font:600 13px 'Fredoka','Nunito',sans-serif;letter-spacing:.06em;text-transform:uppercase}
.av{width:48px;height:48px;box-sizing:border-box;border-radius:50%;border:2.5px solid #2A1B3D;display:flex;align-items:center;justify-content:center;font-size:24px;line-height:1;flex:none;text-decoration:none}
.who{display:flex;flex-direction:column;align-items:center;gap:3px;font-weight:700;font-size:13px;background:none;border:0;padding:0;color:#2A1B3D;font-family:inherit;min-width:56px}
.in{box-sizing:border-box;width:100%;height:48px;border:2.5px solid #2A1B3D;border-radius:16px;padding:0 14px;font:600 16px 'Nunito',sans-serif;color:#2A1B3D;background:#fff}
.in::placeholder{color:#6B5A7A}
.row{display:flex;gap:10px;align-items:center}
.nav{display:flex;background:#fff;border-top:2.5px solid #2A1B3D}
.nav a{flex:1;height:68px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:2px;font:600 13px 'Fredoka','Nunito',sans-serif;color:#6B5A7A;text-decoration:none}
.nav a span{font-size:22px;line-height:1}
.nav a.cur{color:#2A1B3D;background:#FFD45C}
.tl{position:relative;display:flex;flex-direction:column;gap:9px}
.tl::before{content:"";position:absolute;left:25px;top:8px;bottom:8px;border-left:3px dashed #2A1B3D;opacity:.35}
.tl .l{position:relative;align-self:flex-start;background:#FFF4E4;padding:2px 8px 2px 0}
.ev{position:relative;display:flex;gap:12px;align-items:center}
.dt{width:54px;height:56px;box-sizing:border-box;flex:none;border:2.5px solid #2A1B3D;border-radius:16px;display:flex;flex-direction:column;align-items:center;justify-content:center;font:600 11px 'Fredoka','Nunito',sans-serif;letter-spacing:.06em;line-height:1.1}
.dt b{font-size:22px;letter-spacing:0}
.evc{flex:1;background:#fff;border:2.5px solid #2A1B3D;border-radius:18px;padding:7px 12px;font-weight:700}
.evc .m{font-weight:400;font-size:13px}
.note{width:100px;height:84px;box-sizing:border-box;border:2.5px solid #2A1B3D;border-radius:6px 6px 18px 6px;padding:8px;font-weight:700;font-size:14px;line-height:1.2;box-shadow:0 4px 0 #2A1B3D}
.st{width:52px;height:52px;box-sizing:border-box;border-radius:50%;border:2.5px solid #2A1B3D;display:flex;align-items:center;justify-content:center;font:700 22px 'Fredoka',sans-serif}
.st.e{border-style:dashed;background:rgba(255,255,255,.6)}
.dy{flex:1;display:flex;flex-direction:column;align-items:center;gap:4px;font-size:12px;font-weight:700;color:#6B5A7A}
.dy i{width:34px;height:34px;box-sizing:border-box;border-radius:50%;border:2.5px solid #2A1B3D;display:flex;align-items:center;justify-content:center;font-style:normal;font-size:16px;background:#FFF4E4}
.dy i.y{background:#8FE3C8}
.dy i.f{border-style:dashed;background:#fff}
"""

def nav(cur):
    items = [("Home", "🏠", "V2Home"), ("Upcoming", "📅", "V2Upcoming"), ("People", "🫶", "V2People"), ("Progress", "🌱", "V2Progress")]
    out = ['<nav class="nav">']
    for name, ico, f in items:
        c = ' class="cur" aria-current="page"' if name == cur else ''
        out.append('<a%s href="%s.dc.html"><span aria-hidden="true">%s</span>%s</a>' % (c, f, ico, name))
    out.append('</nav>')
    return "\n".join(out)

def who(emoji, name, col, size=48):
    return '<button class="who"><span class="av %s" style="width:%dpx;height:%dpx" aria-hidden="true">%s</span>%s</button>' % (col, size, size, emoji, name)

def ev(dow, day, col, title, sub):
    return ('<div class="ev"><div class="dt %s">%s<b>%s</b></div><div class="evc">%s<p class="m">%s</p></div></div>'
            % (col, dow, day, title, sub))

HOME = """
<div class="c">
<div class="row" style="justify-content:space-between"><h1>Hey you 👋</h1><a class="av" style="width:44px;height:44px;background:#fff;font-size:20px" href="Settings.dc.html" aria-label="Settings">⚙️</a></div>
<div class="card sun">
<h2>Who's on your mind?</h2>
<div class="row"><input class="in" aria-label="What came to mind" placeholder="saw a bouldering video…"><button class="b" style="background:#2A1B3D;color:#fff;box-shadow:none;flex:none" aria-label="Save">＋</button></div>
<div class="row" style="justify-content:space-between">
""" + who("🧗", "Tom", "mint") + who("🎨", "Anna", "pink") + who("🛹", "Jonas", "lilac") + who("🏡", "Maria", "sky") + who("🔍", "More", "white") + """
</div>
</div>
<div class="card">
<span class="tag coral" style="transform:rotate(-3deg);margin:-26px 0 0 -6px">Tonight's pick</span>
<div class="row"><span class="av mint" style="width:56px;height:56px;font-size:28px" aria-hidden="true">🧗</span><div><h2>Tom</h2><p class="m">Close friend · WhatsApp</p></div></div>
<p class="cream" style="border-radius:4px 18px 18px 18px;padding:10px 12px;font-weight:700">“Saw a bouldering video. Ask if he's up for Saturday.”</p>
<div class="row"><button class="b" style="flex:1">Open chat 💬</button><button class="b b2" aria-label="Another one">🎲</button><button class="b b2">Done ✓</button></div>
</div>
<div class="row" style="justify-content:space-between"><p class="l">Coming up</p><a class="f" style="font-weight:600;font-size:14px" href="V2Upcoming.dc.html">See all →</a></div>
<div class="row" style="align-items:stretch">
<div class="card pink" style="flex:1;padding:10px 12px;gap:2px;border-radius:18px;box-shadow:0 4px 0 #2A1B3D"><p class="l">Thu 19</p><p style="font-weight:700">Anna's birthday 🎂</p></div>
<div class="card mint" style="flex:1;padding:10px 12px;gap:2px;border-radius:18px;box-shadow:0 4px 0 #2A1B3D"><p class="l">Sat 21</p><p style="font-weight:700">Bouldering with Tom</p></div>
</div>
</div>
""" + nav("Home")

UPCOMING = """
<div class="c" style="gap:12px">
<div><h1>Coming up</h1><p class="m">Birthdays and dates you have set. Nothing here is ever late.</p></div>
<div class="tl">
<p class="l">This week</p>
""" + ev("THU", "19", "pink", "Anna's birthday 🎂", "The app asks you that evening.") \
    + ev("SAT", "21", "mint", "Bouldering with Tom 🧗", "Meet-up · 11:00") + """
<p class="l">Next week</p>
""" + ev("WED", "25", "sky", "Call Grandpa ☎️", "You picked this day.") + """
<p class="l">December</p>
""" + ev("SUN", "6", "sun", "Aunt Maria visits the new flat 🏡", "Meet-up · afternoon") \
    + ev("MON", "14", "pink", "Sophie's birthday 🎂", "Now and then") + """
</div>
<div class="card lilac" style="border-style:dashed;box-shadow:none;gap:6px">
<p class="l">No date yet</p>
<div class="row" style="justify-content:space-between"><p style="font-weight:700">Board game night with the old gang 🎲</p><button class="chip" style="flex:none">Pick a date</button></div>
</div>
</div>
""" + nav("Upcoming")

CONFETTI = "".join(
    '<i aria-hidden="true" style="position:absolute;left:%dpx;top:%dpx;width:%dpx;height:%dpx;background:%s;border:2px solid #2A1B3D;border-radius:%s;transform:rotate(%ddeg)"></i>'
    % t for t in [
        (28, 40, 14, 14, "#FF7A6B", "50%", 0), (70, 96, 18, 10, "#8FE3C8", "3px", 24), (120, 30, 10, 18, "#FFD45C", "3px", -18),
        (300, 44, 16, 16, "#CFC2FF", "50%", 0), (338, 104, 18, 10, "#FFB8D4", "3px", -30), (262, 20, 10, 18, "#A9D8FF", "3px", 30),
        (44, 150, 12, 12, "#FFD45C", "50%", 0), (322, 160, 12, 12, "#8FE3C8", "50%", 0),
    ])

DONE = CONFETTI + """
<div class="c" style="padding-top:40px">
<div style="display:flex;flex-direction:column;align-items:center;gap:6px;text-align:center">
<div style="position:relative"><span class="av mint" style="width:96px;height:96px;font-size:48px" aria-hidden="true">🧗</span><span class="tag sun" style="position:absolute;right:-64px;top:-4px;transform:rotate(8deg);white-space:nowrap">✋ High five!</span></div>
<h1>Nice one!</h1>
<p>You wrote to Tom. That's what counts.</p>
</div>
<div class="card" style="gap:8px">
<label class="l" for="n">One line for next time?</label>
<input id="n" class="in" placeholder="new job since March…">
</div>
<div class="card sky" style="gap:8px">
<p style="font-weight:700">Planning to meet up?</p>
<div class="row"><button class="chip">Set a date 📅</button><button class="chip">Keep it open</button><button class="chip">No</button></div>
</div>
<div class="card sun" style="gap:8px">
<p class="l">Treat stamp card</p>
<div class="row"><span class="st coral" style="transform:rotate(-8deg)">✓</span><span class="st coral" style="transform:rotate(5deg)">✓</span><span class="st coral" style="transform:rotate(-4deg)">✓</span><h2 style="margin-left:6px">Full!</h2></div>
<p style="font-weight:700">Cinema evening 🍿 is yours. You set this treat yourself, so go enjoy it.</p>
</div>
<div style="flex:1"></div>
<a class="b" style="display:flex;align-items:center;justify-content:center;text-decoration:none;margin-bottom:8px" href="V2Home.dc.html">Back home</a>
</div>
"""

PEOPLE = """
<div class="c">
<div class="row" style="justify-content:space-between"><h1>Your people</h1><button class="av sun" style="width:44px;height:44px;font:700 24px 'Fredoka',sans-serif;color:#2A1B3D" aria-label="Add a person">+</button></div>
<div class="card lilac">
<span class="tag" style="background:#fff;transform:rotate(-2deg)">Getting back in touch · this week</span>
<div class="row"><span class="av" style="width:56px;height:56px;font-size:28px;background:#fff" aria-hidden="true">🛹</span><div><h2>Jonas</h2><p style="font-size:14px">School friend. Old friends pick up where they left off.</p></div></div>
<div class="row"><a class="b" style="flex:1;display:flex;align-items:center;justify-content:center;text-decoration:none" href="V2Person.dc.html">Say hi 👋</a><button class="b b2">Someone else</button></div>
</div>
<p class="l">Close friends</p>
<div class="row" style="justify-content:space-between">""" + who("🧗", "Tom", "mint", 54) + who("🎨", "Anna", "pink", 54) + who("🎮", "Marek", "sky", 54) + who("🚴", "Lena", "sun", 54) + """</div>
<p class="l">Now and then</p>
<div class="row" style="justify-content:space-between">""" + who("📚", "Sophie", "coral", 54) + who("🎸", "Ben", "lilac", 54) + who("🌱", "Ida", "mint", 54) + who("⛵", "Kai", "sky", 54) + """</div>
<div class="row" style="align-items:flex-start;gap:20px">
<div style="flex:1;display:flex;flex-direction:column;gap:14px"><p class="l">A few times a year</p><div class="row" style="gap:16px">""" + who("🏔️", "Nora", "pink", 54) + who("🎬", "Emil", "sun", 54) + """</div></div>
<div style="flex:1;display:flex;flex-direction:column;gap:14px"><p class="l">Family</p><div class="row" style="gap:16px">""" + who("🏡", "Maria", "sky", 54) + who("♟️", "Grandpa", "coral", 54) + """</div></div>
</div>
</div>
""" + nav("People")

PERSON = """
<div class="mint" style="border-bottom:2.5px solid #2A1B3D;padding:16px 18px 14px;display:flex;flex-direction:column;align-items:center;gap:6px;position:relative">
<a class="av" style="position:absolute;left:18px;top:16px;width:44px;height:44px;background:#fff;font-size:20px" href="V2People.dc.html" aria-label="Back to people">←</a>
<span class="av" style="width:84px;height:84px;font-size:42px;background:#fff;box-shadow:0 4px 0 #2A1B3D" aria-hidden="true">🧗</span>
<h1>Tom Berger</h1>
<div class="row" style="gap:6px"><span class="tag sun">Close friend</span><span class="tag" style="background:#fff">WhatsApp</span><span class="tag pink">🎂 3 March</span></div>
</div>
<div class="c" style="padding-top:16px;gap:12px">
<button class="b">Open WhatsApp 💬</button>
<div class="card sky" style="padding:8px 14px;border-radius:18px;box-shadow:none;flex-direction:row;align-items:center"><span aria-hidden="true">📅</span><p style="font-weight:700">Sat 21 Nov · Bouldering together</p></div>
<p class="l">Ideas for next time</p>
<div class="row" style="justify-content:space-between;padding-bottom:4px">
<div class="note sun" style="transform:rotate(-3deg)">New bouldering hall</div>
<div class="note pink" style="transform:rotate(2deg)">Ramen place he mentioned</div>
<button class="note" style="transform:rotate(-1deg);background:#fff;border-style:dashed;box-shadow:none;font-family:inherit;color:#2A1B3D">+ Add an idea</button>
</div>
<div class="card" style="gap:4px;padding:10px 14px;border-radius:18px;box-shadow:0 4px 0 #2A1B3D"><p class="l">Notes</p><p>New job since March. Training for a half marathon.</p></div>
<p class="l">Lately</p>
<div style="display:flex;flex-direction:column;gap:6px">
<p><span aria-hidden="true">💬</span> <b>You wrote</b> <span class="m">· 2 Nov</span></p>
<p><span aria-hidden="true">🧗</span> <b>Met up</b> <span class="m">· 12 Oct · bouldering</span></p>
<p><span aria-hidden="true">📞</span> <b>Called</b> <span class="m">· 20 Sep</span></p>
</div>
</div>
""" + nav("People")

def day(lbl, cls, mark):
    return '<div class="dy"><i class="%s" aria-hidden="true">%s</i>%s</div>' % (cls, mark, lbl)

def pile(items):
    out = []
    for i, (e, c) in enumerate(items):
        out.append('<span class="av %s" style="width:38px;height:38px;font-size:18px;margin-left:%dpx" aria-hidden="true">%s</span>' % (c, 0 if i == 0 else -10, e))
    return "".join(out)

PROGRESS = """
<div class="c">
<h1>Your year so far</h1>
<div class="card mint">
<div class="row" style="gap:14px"><p class="f" style="font-size:64px;font-weight:700;line-height:.9">14</p><p style="font-weight:700">people reached this year. This number only ever grows.</p></div>
<div class="row" style="gap:0">""" + pile([("🧗", "sun"), ("🎨", "pink"), ("🛹", "lilac"), ("🏡", "sky"), ("📚", "coral"), ("🎮", "sky"), ("♟️", "coral"), ("🎸", "lilac")]) + """<span class="av" style="width:38px;height:38px;margin-left:-10px;background:#fff;font:700 13px 'Nunito',sans-serif">+6</span></div>
</div>
<div class="card sun">
<div class="row" style="justify-content:space-between"><p class="l">Treat stamp card</p><a class="f" style="font-weight:600;font-size:14px" href="#">My treats →</a></div>
<h2>Cinema evening 🍿</h2>
<div class="row" role="img" aria-label="2 of 3 stamps"><span class="st coral" style="transform:rotate(-8deg)">✓</span><span class="st coral" style="transform:rotate(5deg)">✓</span><span class="st e"></span><p style="font-weight:700;margin-left:4px">One more person and it is yours.</p></div>
</div>
<div class="card">
<p class="l">This week</p>
<div style="display:flex">""" + day("Mon", "y", "⭐") + day("Tue", "", "") + day("Wed", "", "") + day("Thu", "y", "⭐") + day("Fri", "", "") + day("Sat", "f", "") + day("Sun", "f", "") + """</div>
<p class="m">Star: you reached someone. Blank: not today, also a fine answer.</p>
<p style="font-weight:700;border-top:2px dashed #2A1B3D;padding-top:8px">🌱 3 weeks in a row. A quiet week pauses it, it never resets.</p>
</div>
<div class="card pink" style="padding:10px 14px;border-radius:18px;box-shadow:0 4px 0 #2A1B3D"><p><b>This month:</b> 9 thoughts noted, 6 followed up.</p></div>
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
<link href="https://fonts.googleapis.com/css2?family=Fredoka:wght@500;600;700&family=Nunito:wght@400;700;800&display=swap" rel="stylesheet">
<style>__CSS__</style>
</helmet>
<div class="s">
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
    ("V2Home", "V2 · 1 Home: capture, tonight's pick, coming up", HOME),
    ("V2Upcoming", "V2 · 2 Upcoming timeline (new)", UPCOMING),
    ("V2Done", "V2 · 3 After \"Yes, I wrote\"", DONE),
    ("V2People", "V2 · 4 People", PEOPLE),
    ("V2Person", "V2 · 5 One person", PERSON),
    ("V2Progress", "V2 · 6 Progress and treats", PROGRESS),
]

canvas = json.loads((OUT / "canvas.json").read_text())
Y = 2528
for i, (name, title, body) in enumerate(SCREENS):
    f = name + ".dc.html"
    html = TEMPLATE.replace("__TITLE__", title.replace('"', "'")).replace("__CSS__", CSS).replace("__BODY__", body.strip())
    (OUT / f).write_text(html)
    canvas["boards"][f] = {"x": i * 470, "y": Y, "w": 390, "h": 844, "title": title}
    if f not in canvas["order"]:
        canvas["order"].append(f)
canvas["notes"]["t3"] = {"x": 0, "y": Y - 300, "text": "V2: warmer and more playful, with an upcoming timeline", "kind": "title1", "maxW": 2740}
(OUT / "canvas.json").write_text(json.dumps(canvas, ensure_ascii=False, separators=(",", ":")))
for p in list(OUT.glob("V2*.dc.html")) + [OUT / "canvas.json"]:
    shutil.copy(p, DOCS / p.name)
print("ok", [s[0] for s in SCREENS])
