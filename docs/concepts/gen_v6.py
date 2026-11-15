"""Generates the V6 full set: the V5 look for all screens, stamps only tilted.
Built from gen_v5.py (first part) plus the remaining screens (second part).
Usage: python3 gen_v6.py <design/project folder> <docs/concepts folder> [preview folder]"""
import json, math, pathlib, shutil, sys

OUT = pathlib.Path(sys.argv[1])
DOCS = pathlib.Path(sys.argv[2])
PREVIEW = pathlib.Path(sys.argv[3]) if len(sys.argv) > 3 else None

def cookie_pts(n=8, depth=0.05, steps=96):
    for i in range(steps):
        t = 2 * math.pi * i / steps
        r = 0.5 - depth + depth * math.cos(n * t)
        yield 0.5 + r * math.cos(t), 0.5 + r * math.sin(t)

def cookie_css(n=8, depth=0.05):
    return "polygon(" + ",".join("%.1f%% %.1f%%" % (100 * x, 100 * y) for x, y in cookie_pts(n, depth)) + ")"

def cookie_svg(n=8, depth=0.05):
    return " ".join("%.1f,%.1f" % (48 * x, 48 * y) for x, y in cookie_pts(n, depth))

def star_pts(R=21, r=9.5):
    out = []
    for i in range(10):
        t = -math.pi / 2 + i * math.pi / 5
        rad = R if i % 2 == 0 else r
        out.append("%.1f,%.1f" % (24 + rad * math.cos(t), 25 + rad * math.sin(t)))
    return " ".join(out)

# ---- colourful icons (48 x 48), flat, two or three tones ----
B, BD, BL = "#2F7BFF", "#1B55D9", "#8CC4FF"
G, GD = "#1FD67A", "#0FA85C"
Y, YD, YL = "#FFC61A", "#F59A0B", "#FFE08A"
R, RD = "#FF3D5A", "#D4213F"
P, PD = "#8A3FFC", "#6325C9"
K, KD = "#FF4FA3", "#E0308A"
T = "#14C8C8"
SL, SD = "#A9B6E8", "#4A5578"
RJ = ' stroke-linejoin="round" stroke-linecap="round"'

def house(roof, body, shade, door):
    return ('<path d="M10 22h28v16a4 4 0 0 1-4 4H14a4 4 0 0 1-4-4z" fill="%s"/><path d="M24 22h14v16a4 4 0 0 1-4 4H24z" fill="%s"/>'
            '<path d="M24 7 43 23H5z" fill="%s" stroke="%s" stroke-width="4"%s/><rect x="19" y="30" width="10" height="12" rx="3" fill="%s"/>'
            % (body, shade, roof, roof, RJ, door))

ICONS = {
    "home": house(R, Y, YD, SD),
    "cottage": house(B, "#F1F3FF", "#D5DAF0", Y),
    "calendar": ('<rect x="6" y="9" width="36" height="33" rx="8" fill="#F1F3FF"/><path d="M24 20h18v14a8 8 0 0 1-8 8H24z" fill="#D5DAF0"/>'
                 '<path d="M14 9h20a8 8 0 0 1 8 8v5H6v-5a8 8 0 0 1 8-8z" fill="%s"/><rect x="13" y="4" width="5" height="10" rx="2.5" fill="%s"/><rect x="30" y="4" width="5" height="10" rx="2.5" fill="%s"/>'
                 '<circle cx="15" cy="30" r="3" fill="%s"/><circle cx="24" cy="30" r="3" fill="%s"/><circle cx="33" cy="30" r="3" fill="%s"/><circle cx="15" cy="37" r="3" fill="%s"/>'
                 % (R, SD, SD, B, B, Y, B)),
    "people": ('<circle cx="31" cy="16" r="7" fill="%s"/><path d="M20 40a11 11 0 0 1 22 0v1a2 2 0 0 1-2 2H22a2 2 0 0 1-2-2z" fill="%s"/>'
               '<circle cx="18" cy="18" r="8" fill="%s"/><path d="M5 40a13 13 0 0 1 26 0v1a2 2 0 0 1-2 2H7a2 2 0 0 1-2-2z" fill="%s"/>' % (P, PD, Y, "#FF8A1F")),
    "stamp": ('<polygon points="%s" fill="%s"/><circle cx="24" cy="24" r="13" fill="%s"/><path d="M16.5 24.5l5.5 5.5 10-11" fill="none" stroke="#fff" stroke-width="4.5"%s/>'
              % (cookie_svg(), G, GD, RJ)),
    "cake": ('<rect x="4" y="38" width="40" height="6" rx="3" fill="%s"/><rect x="8" y="22" width="32" height="19" rx="5" fill="%s"/>'
             '<path d="M24 22h11a5 5 0 0 1 5 5v9a5 5 0 0 1-5 5H24z" fill="%s"/>'
             '<path d="M8 27a5 5 0 0 1 5-5h22a5 5 0 0 1 5 5v2a4 4 0 0 1-8 0 4 4 0 0 1-8 0 4 4 0 0 1-8 0 4 4 0 0 1-8 0z" fill="#FFE1EE"/>'
             '<rect x="22" y="11" width="4" height="12" rx="2" fill="%s"/><path d="M24 2c3.5 3.5 3.5 7 0 9-3.5-2-3.5-5.5 0-9z" fill="%s"/>' % (SL, K, KD, B, Y)),
    "mountain": ('<path d="M33 17 45 40H21z" fill="%s" stroke="%s" stroke-width="3"%s/><path d="M17 10 32 40H3z" fill="%s" stroke="%s" stroke-width="3"%s/>'
                 '<path d="M17 10 32 40H17z" fill="%s" stroke="%s" stroke-width="3"%s/><path d="M17 10l4.5 9-4.5 3-4.5-3z" fill="#fff" stroke="#fff" stroke-width="3"%s/>'
                 % (T, T, RJ, G, G, RJ, GD, GD, RJ, RJ)),
    "phone": ('<path d="M13 11c0 14 10 24 24 24" fill="none" stroke="%s" stroke-width="9"%s/><circle cx="13" cy="11" r="6.5" fill="%s"/><circle cx="37" cy="35" r="6.5" fill="%s"/>' % (B, RJ, BL, BL)),
    "dice": ('<rect x="7" y="7" width="34" height="34" rx="9" fill="%s"/><path d="M41 16v16a9 9 0 0 1-9 9H16z" fill="%s"/>'
             '<circle cx="17" cy="17" r="3.5" fill="#fff"/><circle cx="24" cy="24" r="3.5" fill="#fff"/><circle cx="31" cy="31" r="3.5" fill="#fff"/>' % (P, PD)),
    "chat": ('<path d="M15 7h18a10 10 0 0 1 10 10v8a10 10 0 0 1-10 10H23l-9 8v-8.2A10 10 0 0 1 5 25v-8A10 10 0 0 1 15 7z" fill="%s"/>'
             '<path d="M24 7h9a10 10 0 0 1 10 10v8a10 10 0 0 1-10 10h-9z" fill="%s"/>'
             '<circle cx="15.5" cy="21" r="3" fill="#fff"/><circle cx="24" cy="21" r="3" fill="#fff"/><circle cx="32.5" cy="21" r="3" fill="#fff"/>' % (G, GD)),
    "whatsapp": ('<rect x="2" y="2" width="44" height="44" rx="14" fill="#25D366"/><circle cx="24.5" cy="22.5" r="12" fill="none" stroke="#fff" stroke-width="3.5"/>'
                 '<path d="M15 30l-3.5 8.5 9-3z" fill="#fff"/><path d="M20 18.5c0 5.5 3.5 9 9 9" fill="none" stroke="#fff" stroke-width="4"%s/>' % RJ),
    "check": '<path d="M9 25l10 10 20-22" fill="none" stroke="%s" stroke-width="7"%s/>' % (G, RJ),
    "gear": '<polygon points="%s" fill="%s"/><circle cx="24" cy="24" r="8" fill="%s"/>' % (cookie_svg(8, 0.09), SL, SD),
    "search": '<path d="M32 32l9 9" stroke="%s" stroke-width="7"%s/><circle cx="21" cy="21" r="12" fill="%s" stroke="%s" stroke-width="6"/>' % (Y, RJ, BL, B),
    "popcorn": ('<circle cx="14" cy="17" r="6.5" fill="%s"/><circle cx="34" cy="17" r="6.5" fill="%s"/><circle cx="24" cy="13" r="8" fill="%s"/><circle cx="19" cy="19" r="5" fill="%s"/><circle cx="29" cy="19" r="5" fill="%s"/>'
                '<path d="M10 20h28l-4 21a3 3 0 0 1-3 2H17a3 3 0 0 1-3-2z" fill="%s"/><path d="M17 20h5l1 23h-4z" fill="#fff"/><path d="M26 20h5l-2 23h-4z" fill="#fff"/>' % (Y, Y, YL, YL, Y, R)),
    "star": '<polygon points="%s" fill="%s" stroke="%s" stroke-width="4"%s/>' % (star_pts(), Y, Y, RJ),
    "leaf": ('<path d="M8 40C8 20 20 8 40 8c0 20-12 32-32 32z" fill="%s" stroke="%s" stroke-width="3"%s/><path d="M8 40 40 8c0 20-12 32-32 32z" fill="%s" stroke="%s" stroke-width="3"%s/>' % (G, G, RJ, GD, GD, RJ)),
}

def ci(name, size=24, style=""):
    return '<svg class="ci" width="%d" height="%d" viewBox="0 0 48 48" aria-hidden="true" style="%s">%s</svg>' % (size, size, style, ICONS[name])

def ic(name, size=24, style=""):
    return '<span class="ic" aria-hidden="true" style="font-size:%dpx;%s">%s</span>' % (size, style, name)

CSS = """
body{margin:0}
.s{width:390px;height:844px;box-sizing:border-box;background:var(--bg);color:var(--on);font-family:'Roboto',system-ui,sans-serif;display:flex;flex-direction:column;font-size:16px;line-height:1.35;position:relative;overflow:hidden;
--coral:#FF8A7A;--corald:#C4564A;--sun:#FFCF5C;--sund:#C4962A;--mint:#7EDDBE;--lilac:#C3B4FF;--sky:#8CCBFF;--pink:#FF9EC6;--onacc:#1F1326}
.light{--bg:#FFF6EA;--s1:#FFFFFF;--s2:#F3E6D6;--s2d:#D9C7B2;--shd:rgba(42,27,61,.2);--on:#2A1B3D;--mut:#6B5A7A;--line:#CDBBA8;
--sunc:#FFE08A;--onsunc:#2A1B3D;--mintc:#BDEFDD;--onmintc:#2A1B3D;--lilacc:#DDD4FF;--onlilacc:#2A1B3D;--pinkc:#FFD0E2;--onpinkc:#2A1B3D;--skyc:#C6E5FF;--onskyc:#2A1B3D;--coralc:#FFC9C0;--oncoralc:#2A1B3D}
.dark{--bg:#17121C;--s1:#231C2A;--s2:#30273A;--s2d:#1A141F;--shd:rgba(0,0,0,.5);--on:#EFE3F2;--mut:#BBADC2;--line:#54475E;
--sunc:#46380F;--onsunc:#FFE29A;--mintc:#12433A;--onmintc:#A6F0D8;--lilacc:#352B63;--onlilacc:#DCD3FF;--pinkc:#54213A;--onpinkc:#FFC4DC;--skyc:#173F5E;--onskyc:#BFE2FF;--coralc:#5A231C;--oncoralc:#FFC2B8}
.c{flex:1;padding:22px 16px 12px;display:flex;flex-direction:column;gap:14px;overflow:hidden}
h1,h2,.f{font-family:'Outfit','Roboto',sans-serif}
h1{margin:0;font-size:30px;font-weight:700;line-height:1.15}
h2{margin:0;font-size:21px;font-weight:600;line-height:1.2}
p{margin:0}
a{color:inherit}
.ic{font-family:'Material Symbols Rounded';font-weight:normal;font-style:normal;font-size:24px;line-height:1;letter-spacing:normal;text-transform:none;display:inline-block;white-space:nowrap;direction:ltr;font-feature-settings:'liga';-webkit-font-smoothing:antialiased;font-variation-settings:'FILL' 1,'wght' 500,'GRAD' 0,'opsz' 24;flex:none}
.ci{flex:none;display:block;filter:drop-shadow(0 2px 0 rgba(0,0,0,.3))}
.card{background:var(--s1);border-radius:28px;padding:16px;display:flex;flex-direction:column;gap:12px;box-shadow:0 5px 0 var(--shd)}
.t-sun{background:var(--sunc);color:var(--onsunc)}.t-mint{background:var(--mintc);color:var(--onmintc)}.t-lilac{background:var(--lilacc);color:var(--onlilacc)}.t-pink{background:var(--pinkc);color:var(--onpinkc)}.t-sky{background:var(--skyc);color:var(--onskyc)}.t-coral{background:var(--coralc);color:var(--oncoralc)}
.a-sun{background:var(--sun);color:var(--onacc)}.a-mint{background:var(--mint);color:var(--onacc)}.a-lilac{background:var(--lilac);color:var(--onacc)}.a-pink{background:var(--pink);color:var(--onacc)}.a-sky{background:var(--sky);color:var(--onacc)}.a-coral{background:var(--coral);color:var(--onacc)}
.b{height:52px;box-sizing:border-box;border:0;border-radius:26px;font:600 17px 'Outfit','Roboto',sans-serif;padding:0 20px;background:var(--coral);color:var(--onacc);display:inline-flex;align-items:center;justify-content:center;gap:8px;text-decoration:none;box-shadow:0 4px 0 var(--corald)}
.b2{background:var(--s2);color:var(--on);box-shadow:0 4px 0 var(--s2d)}
.b.a-sun{box-shadow:0 4px 0 var(--sund)}
.ib{width:52px;height:52px;padding:0;border-radius:18px;flex:none}
.chip{height:44px;box-sizing:border-box;border-radius:14px;border:1.5px solid currentColor;background:transparent;color:inherit;font:500 14px 'Roboto',sans-serif;padding:0 12px;display:inline-flex;align-items:center;gap:6px}
.tag{align-self:flex-start;font:600 13px 'Outfit','Roboto',sans-serif;padding:4px 12px;border-radius:14px;box-shadow:0 3px 0 var(--shd);display:inline-flex;align-items:center;gap:4px}
.m{color:var(--mut);font-size:14px}
[class*="t-"] .m{color:inherit;opacity:.82}
.l{font:600 13px 'Outfit','Roboto',sans-serif;letter-spacing:.08em;text-transform:uppercase}
.av{width:48px;height:48px;box-sizing:border-box;display:flex;align-items:center;justify-content:center;font:700 20px 'Outfit','Roboto',sans-serif;flex:none;text-decoration:none;border-radius:50%}
.sh1{clip-path:__COOKIE__;border-radius:0}
.sh2{border-radius:34%}
.sh3{border-radius:50% 50% 50% 22%}
.sh4{border-radius:50% 50% 24% 24%}
.ds{display:inline-flex;filter:drop-shadow(0 3px 0 rgba(0,0,0,.4))}
.who{display:flex;flex-direction:column;align-items:center;gap:4px;font-weight:500;font-size:13px;background:none;border:0;padding:0;color:inherit;font-family:inherit;min-width:54px}
.in{box-sizing:border-box;width:100%;height:52px;border:0;border-radius:26px;padding:0 18px;font:400 16px 'Roboto',sans-serif;color:var(--on);background:var(--bg)}
.in::placeholder{color:var(--mut)}
.row{display:flex;gap:10px;align-items:center}
.nav{display:flex;background:var(--s1);padding:0 4px}
.nav a{flex:1;height:76px;display:flex;flex-direction:column;align-items:center;justify-content:center;gap:3px;font:500 12px 'Roboto',sans-serif;color:var(--mut);text-decoration:none}
.nav a i{width:64px;height:36px;border-radius:18px;display:flex;align-items:center;justify-content:center}
.nav a.cur{color:var(--on);font-weight:700}
.nav a.cur i{background:var(--s2);box-shadow:0 3px 0 var(--s2d)}
.tl{position:relative;display:flex;flex-direction:column;gap:12px}
.tl::before{content:"";position:absolute;left:27px;top:8px;bottom:8px;width:2px;background:var(--line)}
.tl .l{position:relative;align-self:flex-start;background:var(--bg);padding:3px 8px 3px 0;color:var(--mut)}
.ev{position:relative;display:flex;gap:10px;align-items:center}
.dt{width:56px;height:58px;box-sizing:border-box;flex:none;border-radius:18px;display:flex;flex-direction:column;align-items:center;justify-content:center;font:600 11px 'Outfit','Roboto',sans-serif;letter-spacing:.08em;line-height:1.1;box-shadow:0 4px 0 var(--shd)}
.dt b{font-size:23px;letter-spacing:0}
.evc{flex:1;background:var(--s1);border-radius:20px;padding:9px 14px;font-weight:500;display:flex;align-items:center;gap:10px;min-height:58px;box-sizing:border-box;box-shadow:0 4px 0 var(--shd)}
.evc div{flex:1}
.evc .m{font-size:13px}
.slot{width:58px;height:58px;box-sizing:border-box;flex:none;border-radius:50%;border:2px dashed color-mix(in srgb,currentColor 50%,transparent);display:flex;align-items:center;justify-content:center}
.st{width:52px;height:52px;display:flex;align-items:center;justify-content:center;flex:none}
.ste{box-sizing:border-box;border:2px dashed currentColor;border-radius:50%;opacity:.6;width:50px;height:50px;margin:3px;flex:none}
.note{width:106px;height:88px;box-sizing:border-box;border:0;border-radius:6px 6px 22px 6px;padding:10px;font:500 14px 'Roboto',sans-serif;line-height:1.25;text-align:left;box-shadow:0 5px 0 var(--shd);display:flex;align-items:flex-start}
.dy{flex:1;display:flex;flex-direction:column;align-items:center;gap:5px;font-size:12px;font-weight:500;color:var(--mut)}
.dy i{width:36px;height:36px;box-sizing:border-box;border-radius:50%;display:flex;align-items:center;justify-content:center;font-style:normal;background:var(--s2)}
.dy i.y{background:var(--mintc)}
.dy i.f{background:transparent;border:2px dashed var(--line)}
""".replace("__COOKIE__", cookie_css())

def nav(cur):
    items = [("Home", "home", "V6Home"), ("Upcoming", "calendar", "V6Upcoming"), ("People", "people", "V6People"), ("Progress", "stamp", "V6Progress")]
    out = ['<nav class="nav">']
    for name, icon, f in items:
        c = ' class="cur" aria-current="page"' if name == cur else ''
        out.append('<a%s href="%s.dc.html"><i>%s</i>%s</a>' % (c, f, ci(icon, 26), name))
    out.append('</nav>')
    return "\n".join(out)

def who(letter, name, col, shape, size=48):
    return '<button class="who"><span class="av a-%s %s" style="width:%dpx;height:%dpx" aria-hidden="true">%s</span>%s</button>' % (col, shape, size, size, letter, name)

def ev(dow, day, col, title, sub, icon, tilt):
    return ('<div class="ev"><div class="dt a-%s" style="transform:rotate(%ddeg)">%s<b>%s</b></div><div class="evc"><div>%s<p class="m">%s</p></div>%s</div></div>'
            % (col, tilt, dow, day, title, sub, ci(icon, 30)))

def home(plain):
    """plain=True: Material line icons on coloured areas, colourful icons only on neutral ones."""
    chat = ic("chat") if plain else ci("whatsapp", 28)
    cake = ic("cake", 26, "color:var(--pink)") if plain else ci("cake", 30)
    hike = ic("hiking", 26, "color:var(--mint)") if plain else ci("mountain", 30)
    return """
<div class="c">
<div class="row" style="justify-content:space-between"><h1>Good evening</h1><a class="b b2 ib" href="V6Settings.dc.html" aria-label="Settings">""" + ci("gear", 28) + """</a></div>
<div class="card t-sun">
<h2>Who's on your mind?</h2>
<div class="row"><input class="in" aria-label="What came to mind" placeholder="saw a bouldering video…"><button class="b ib" aria-label="Save">""" + ic("add", 28) + """</button></div>
<div class="row" style="justify-content:space-between">
""" + who("T", "Tom", "mint", "sh1") + who("A", "Anna", "pink", "sh2") + who("J", "Jonas", "lilac", "sh3") + who("M", "Maria", "sky", "sh4") + """
<button class="who"><span class="av" style="background:var(--bg)">""" + ci("search", 26) + """</span>More</button>
</div>
</div>
<div class="card">
<span class="tag a-coral" style="transform:rotate(-3deg);margin:-28px 0 0 -4px">Tonight's pick</span>
<div class="row" style="gap:14px"><span class="ds"><span class="av a-mint sh1" style="width:60px;height:60px;font-size:26px" aria-hidden="true">T</span></span><div><h2>Tom</h2><p class="m">Close friend · WhatsApp</p></div></div>
<p style="background:var(--s2);border-radius:6px 20px 20px 20px;padding:11px 14px">“Saw a bouldering video. Ask if he's up for Saturday.”</p>
<div class="row" style="padding-bottom:4px"><button class="b" style="flex:1">""" + chat + """Open chat</button><button class="b b2 ib" aria-label="Another one">""" + ci("dice", 28) + """</button><button class="b b2 ib" aria-label="Done">""" + ci("check", 28) + """</button></div>
</div>
<div class="row" style="justify-content:space-between"><p class="l" style="color:var(--mut)">Coming up</p><a class="f row" style="font-weight:600;font-size:14px;gap:2px;text-decoration:none;min-height:24px" href="V6Upcoming.dc.html">See all""" + ic("arrow_forward", 18) + """</a></div>
<div class="row" style="align-items:stretch;gap:12px">
<div class="card" style="flex:1;padding:12px 14px;gap:8px;border-radius:22px"><div class="row" style="justify-content:space-between"><div class="dt a-pink" style="transform:rotate(-3deg);width:46px;height:48px;border-radius:15px">THU<b style="font-size:19px">19</b></div>""" + cake + """</div><p style="font-weight:500">Anna's birthday</p></div>
<div class="card" style="flex:1;padding:12px 14px;gap:8px;border-radius:22px"><div class="row" style="justify-content:space-between"><div class="dt a-mint" style="transform:rotate(2deg);width:46px;height:48px;border-radius:15px">SAT<b style="font-size:19px">21</b></div>""" + hike + """</div><p style="font-weight:500">Bouldering, Tom</p></div>
</div>
</div>
""" + nav("Home")

UPCOMING = """
<div class="c" style="gap:12px">
<div><h1>Coming up</h1><p class="m">Birthdays and dates you have set. Nothing here is ever late.</p></div>
<div class="tl">
<p class="l">This week</p>
""" + ev("THU", "19", "pink", "Anna's birthday", "The app asks you that evening.", "cake", -3) \
    + ev("SAT", "21", "mint", "Bouldering with Tom", "Meet-up · 11:00", "mountain", 2) + """
<p class="l">Next week</p>
""" + ev("WED", "25", "sky", "Call Grandpa", "You picked this day.", "phone", -2) + """
<p class="l">December</p>
""" + ev("SUN", "6", "sun", "Aunt Maria visits the new flat", "Meet-up · afternoon", "cottage", 3) \
    + ev("MON", "14", "pink", "Sophie's birthday", "Now and then", "cake", -2) + """
</div>
<div class="card" style="background:transparent;border:2px dashed var(--line);box-shadow:none;gap:6px;padding:12px 14px">
<p class="l" style="color:var(--mut)">No date yet</p>
<div class="row" style="justify-content:space-between">""" + ci("dice", 28) + """<p style="font-weight:500;flex:1">Board game night with the old gang</p><button class="b b2" style="height:44px;font-size:15px;padding:0 16px;flex:none">Pick a date</button></div>
</div>
</div>
""" + nav("Upcoming")

CONFETTI = "".join(
    '<i aria-hidden="true" style="position:absolute;left:%dpx;top:%dpx;width:%dpx;height:%dpx;background:%s;border-radius:%s;transform:rotate(%ddeg)"></i>'
    % t for t in [
        (24, 46, 14, 14, "#FF8A7A", "50%", 0), (62, 104, 20, 9, "#7EDDBE", "4px", 24), (112, 34, 9, 20, "#FFCF5C", "4px", -18),
        (300, 50, 16, 16, "#C3B4FF", "50%", 0), (342, 112, 20, 9, "#FF9EC6", "4px", -30), (262, 22, 9, 20, "#8CCBFF", "4px", 30),
        (40, 168, 11, 11, "#FFCF5C", "50%", 0), (330, 176, 11, 11, "#7EDDBE", "50%", 0), (86, 60, 9, 9, "#8CCBFF", "50%", 0),
        (286, 96, 9, 9, "#FFCF5C", "50%", 0), (150, 16, 18, 8, "#FF9EC6", "4px", 40), (252, 122, 8, 18, "#FF8A7A", "4px", 16),
        (16, 118, 8, 18, "#C3B4FF", "4px", -24), (358, 40, 8, 18, "#FFCF5C", "4px", 12), (92, 150, 18, 8, "#FF8A7A", "4px", -12),
        (282, 158, 18, 8, "#8CCBFF", "4px", 20),
    ])

def stamp(dx, dy, rot):
    # V6: stamps are only tilted, they sit where they belong (dx, dy unused)
    return ('<span class="ds" style="transform:rotate(%ddeg)"><span class="st a-coral sh1" style="width:56px;height:56px">' % rot) + ic("check", 28) + '</span></span>'
SLOT = '<span class="ste"></span>'

DONE = CONFETTI + """
<div class="c" style="padding-top:44px">
<div style="display:flex;flex-direction:column;align-items:center;gap:6px;text-align:center">
<div style="position:relative"><span class="ds"><span class="av a-mint sh1" style="width:96px;height:96px;font-size:42px" aria-hidden="true">T</span></span><span class="tag a-sun" style="position:absolute;right:-78px;top:-2px;transform:rotate(8deg);white-space:nowrap">High five!</span></div>
<h1>Nice one!</h1>
<p>You wrote to Tom. That's what counts.</p>
</div>
<div class="card" style="gap:10px">
<label class="l" for="n" style="color:var(--mut)">One line for next time?</label>
<input id="n" class="in" placeholder="new job since March…">
</div>
<div class="card t-sky" style="gap:10px">
<p style="font-weight:500">Planning to meet up?</p>
<div class="row" style="gap:8px"><button class="chip">""" + ci("calendar", 22) + """Set a date</button><button class="chip">Keep it open</button><button class="chip">No</button></div>
</div>
<div class="card t-sun" style="gap:10px">
<p class="l">Treat stamp card</p>
<div class="row">""" + stamp(-3, 2, -9) + stamp(4, -3, 7) + stamp(-1, 4, -3) + """<h2 style="margin-left:6px">Full!</h2></div>
<div class="row">""" + ci("popcorn", 30) + """<p style="font-weight:500">Cinema evening is yours. You set this treat yourself, so go enjoy it.</p></div>
</div>
<div style="flex:1"></div>
<a class="b" style="margin-bottom:10px" href="V6Home.dc.html">Back home</a>
</div>
"""

PERSON = """
<div class="t-mint" style="border-radius:0 0 32px 32px;box-shadow:0 5px 0 var(--shd);padding:16px 16px 18px;display:flex;flex-direction:column;align-items:center;gap:8px;position:relative">
<a class="b b2 ib" style="position:absolute;left:16px;top:16px;width:44px;height:44px;border-radius:16px" href="V6People.dc.html" aria-label="Back">""" + ic("arrow_back") + """</a>
<span class="ds"><span class="av a-mint sh1" style="width:84px;height:84px;font-size:38px" aria-hidden="true">T</span></span>
<h1>Tom Berger</h1>
<div class="row" style="gap:8px"><span class="tag a-sun" style="transform:rotate(-2deg)">Close friend</span><span class="tag" style="background:var(--s2);color:var(--on)">WhatsApp</span><span class="tag a-pink" style="transform:rotate(2deg)">3 March</span></div>
</div>
<div class="c" style="padding-top:18px;gap:12px">
<button class="b">""" + ci("whatsapp", 28) + """Open WhatsApp</button>
<div class="card t-sky" style="padding:10px 14px;border-radius:20px;flex-direction:row;align-items:center;box-shadow:0 4px 0 var(--shd)">""" + ci("calendar", 26) + """<p style="font-weight:500">Sat 21 Nov · Bouldering together</p></div>
<p class="l" style="color:var(--mut)">Ideas for next time</p>
<div class="row" style="justify-content:space-between;padding:0 2px 6px">
<div class="note a-sun" style="transform:rotate(-3deg)">New bouldering hall</div>
<div class="note a-pink" style="transform:rotate(2deg)">Ramen place he mentioned</div>
<button class="note" style="transform:rotate(-1deg);background:transparent;border:2px dashed var(--line);box-shadow:none;color:var(--mut)">+ Add an idea</button>
</div>
<div class="card" style="gap:4px;padding:12px 14px;border-radius:20px;box-shadow:0 4px 0 var(--shd)"><p class="l" style="color:var(--mut)">Notes</p><p>New job since March. Training for a half marathon.</p></div>
<p class="l" style="color:var(--mut)">Lately</p>
<div style="display:flex;flex-direction:column;gap:8px">
<div class="row">""" + ci("chat", 22) + """<p><b>You wrote</b> <span class="m">· 2 Nov</span></p></div>
<div class="row">""" + ci("mountain", 22) + """<p><b>Met up</b> <span class="m">· 12 Oct · bouldering</span></p></div>
<div class="row">""" + ci("phone", 22) + """<p><b>Called</b> <span class="m">· 20 Sep</span></p></div>
</div>
</div>
""" + nav("People")

def day(lbl, cls, mark):
    return '<div class="dy"><i class="%s" aria-hidden="true">%s</i>%s</div>' % (cls, mark, lbl)

def pile(items):
    out = []
    for i, (e, c) in enumerate(items):
        out.append('<span class="av a-%s" style="width:38px;height:38px;font-size:16px;margin-left:%dpx;box-shadow:0 0 0 2.5px var(--mintc)" aria-hidden="true">%s</span>' % (c, 0 if i == 0 else -9, e))
    return "".join(out)

PROGRESS = """
<div class="c">
<h1>Your year so far</h1>
<div class="card t-mint">
<div class="row" style="gap:14px"><p class="f" style="font-size:68px;font-weight:700;line-height:.9">14</p><p style="font-weight:500">people reached this year. This number only ever grows.</p></div>
<div class="row" style="gap:0">""" + pile([("T", "sun"), ("A", "pink"), ("J", "lilac"), ("M", "sky"), ("S", "coral"), ("M", "sky"), ("G", "coral"), ("B", "lilac")]) + """<span class="av" style="width:38px;height:38px;margin-left:-9px;background:var(--bg);color:var(--on);font-size:13px;box-shadow:0 0 0 2.5px var(--mintc)">+6</span></div>
</div>
<div class="card t-sun">
<div class="row" style="justify-content:space-between"><p class="l">Treat stamp card</p><a class="f row" style="font-weight:600;font-size:14px;gap:2px;text-decoration:none;min-height:24px" href="#">My treats""" + ic("arrow_forward", 18) + """</a></div>
<div class="row">""" + ci("popcorn", 30) + """<h2>Cinema evening</h2></div>
<div class="row" role="img" aria-label="2 of 3 stamps">""" + stamp(-3, 2, -9) + stamp(4, -3, 7) + SLOT + """<p style="font-weight:500;margin-left:4px">One more person and it is yours.</p></div>
</div>
<div class="card">
<p class="l" style="color:var(--mut)">This week</p>
<div style="display:flex">""" + day("Mon", "y", ci("star", 22)) + day("Tue", "", "") + day("Wed", "", "") + day("Thu", "y", ci("star", 22)) + day("Fri", "", "") + day("Sat", "f", "") + day("Sun", "f", "") + """</div>
<p class="m">Star: you reached someone. Blank: not today, also a fine answer.</p>
<div class="row" style="border-top:1.5px solid var(--line);padding-top:10px">""" + ci("leaf", 26) + """<p style="font-weight:500">3 weeks in a row. A quiet week pauses it, it never resets.</p></div>
</div>
<div class="card t-pink" style="padding:12px 16px;border-radius:22px;box-shadow:0 4px 0 var(--shd)"><p><b>This month:</b> 9 thoughts noted, 6 followed up.</p></div>
</div>
""" + nav("Progress")

FONTS = """<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">
<link href="https://fonts.googleapis.com/css2?family=Material+Symbols+Rounded:opsz,wght,FILL,GRAD@20..48,100..700,0..1,-50..200" rel="stylesheet">"""

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
__FONTS__
<style>__CSS__</style>
</helmet>
<div class="s dark">
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


# ---------------------------------------------------------------------------
# V6 additions: remaining screens in the same look
# ---------------------------------------------------------------------------

ICONS["telegram"] = ('<rect x="2" y="2" width="44" height="44" rx="14" fill="#2AABEE"/>'
                     '<polygon points="9,23 38,11 33,37 24,30 20,35 19,27" fill="#fff" stroke="#fff" stroke-width="2"%s/>'
                     '<path d="M19 27 32 17" stroke="#2AABEE" stroke-width="2.5"%s/>' % (RJ, RJ))

CSS += """
.r{display:flex;align-items:center;justify-content:space-between;gap:10px;min-height:40px;font-weight:500}
.sw{width:52px;height:32px;border:0;padding:0;border-radius:16px;background:var(--mint);position:relative;flex:none}
.sw::after{content:"";position:absolute;top:4px;left:24px;width:24px;height:24px;border-radius:50%;background:var(--onacc)}
.sw.off{background:var(--s2)}
.sw.off::after{left:4px;background:var(--mut)}
.seg{display:flex;background:var(--bg);border-radius:14px;padding:3px;flex:none}
.seg button{height:38px;padding:0 12px;border:0;border-radius:11px;background:transparent;color:var(--mut);font:500 14px 'Roboto',sans-serif}
.seg button.on{background:var(--sun);color:var(--onacc);font-weight:700}
.dc{width:40px;height:40px;border:0;padding:0;border-radius:50%;background:var(--s2);color:var(--mut);font:500 13px 'Roboto',sans-serif;flex:none}
.dc.on{background:var(--sun);color:var(--onacc);font-weight:700}
.cb{width:26px;height:26px;border-radius:9px;border:2px solid var(--line);box-sizing:border-box;display:flex;align-items:center;justify-content:center;flex:none}
.cb.on{background:var(--mint);border-color:var(--mint);color:var(--onacc)}
.li{background:var(--s1);border-radius:20px;padding:8px 12px;display:flex;align-items:center;gap:12px;box-shadow:0 4px 0 var(--shd);min-height:52px;box-sizing:border-box}
.nt{background:var(--s1);border-radius:26px;padding:14px 16px;display:flex;flex-direction:column;gap:6px;box-shadow:0 5px 0 var(--shd)}
.ct{position:relative;display:flex;flex-direction:column;gap:12px}
.ct::before{content:"";position:absolute;left:87px;top:6px;bottom:6px;width:2px;background:var(--line)}
.cr{display:flex;gap:8px;align-items:flex-start;position:relative}
.cr .d{width:66px;white-space:nowrap;flex:none;text-align:right;font:600 12px 'Outfit','Roboto',sans-serif;letter-spacing:.06em;text-transform:uppercase;color:var(--mut);padding-top:7px;box-sizing:border-box}
.cr .d span{display:inline-block;padding:2px 7px;border-radius:9px;box-shadow:0 2px 0 var(--shd)}
.cr .n{width:28px;height:30px;flex:none;background:var(--bg);display:flex;align-items:center;justify-content:center;position:relative}
.cr .x{flex:1;padding-top:4px;font-weight:500}
.cr .x .m{font-weight:400;font-size:13px}
.ct .l{position:relative;background:var(--bg);align-self:flex-start;margin-left:70px;padding:2px 8px;color:var(--mut)}
.nt .ac{display:flex;gap:22px;padding-top:6px;font:600 14px 'Outfit','Roboto',sans-serif;color:var(--sun)}
"""

HEADER = """<div class="row" style="justify-content:space-between"><h1>Good evening</h1><a class="b b2 ib" href="V6Settings.dc.html" aria-label="Settings">""" + ci("gear", 28) + """</a></div>"""

def open_item(letter, col, shape, name, reason, app):
    return ('<div class="li"><span class="av a-%s %s" style="width:44px;height:44px;font-size:18px" aria-hidden="true">%s</span>'
            '<div style="flex:1;min-width:0"><p style="font-weight:700">%s</p><p class="m">%s</p></div>'
            '<button class="b ib" style="width:46px;height:46px;border-radius:16px" aria-label="Open chat with %s">%s</button></div>'
            % (col, shape, letter, name, reason, name, ci(app, 28)))

DIM = ' style="opacity:.45"'
CAPTURE = """
<div class="c">
""" + HEADER + """
<div class="card t-sun">
<h2>Who's on your mind?</h2>
<div class="row"><input class="in" aria-label="What came to mind" value="saw a bouldering video"><button class="b ib" aria-label="Save">""" + ic("add", 28) + """</button></div>
<div class="row" style="justify-content:space-between">
<button class="who" aria-pressed="true" style="background:var(--bg);border-radius:20px;padding:6px 4px;margin:-6px -4px;font-weight:700"><span class="av a-mint sh1" aria-hidden="true">T</span>Tom</button>
""" + who("A", "Anna", "pink", "sh2").replace('class="who"', 'class="who"' + DIM) + who("J", "Jonas", "lilac", "sh3").replace('class="who"', 'class="who"' + DIM) + who("M", "Maria", "sky", "sh4").replace('class="who"', 'class="who"' + DIM) + """
<button class="who"%s><span class="av" style="background:var(--bg)">""" % DIM + ci("search", 26) + """</span>More</button>
</div>
<div class="row" style="gap:8px"><button class="chip" aria-pressed="true" style="background:var(--sun);color:var(--onacc);border-color:transparent;font-weight:700">""" + ci("chat", 22) + """Write</button><button class="chip">""" + ci("phone", 22) + """Call</button><button class="chip">""" + ci("people", 22) + """Meet</button></div>
<button class="b">Save for Tom</button>
</div>
<div class="row" style="justify-content:space-between"><p class="l" style="color:var(--mut)">For tonight</p><p class="m" style="font-size:13px">Showing three · change in settings</p></div>
""" + open_item("T", "mint", "sh1", "Tom", "Saw a bouldering video", "whatsapp") \
    + open_item("A", "pink", "sh2", "Anna", "Ask about the new flat", "whatsapp") \
    + open_item("J", "lilac", "sh3", "Jonas", "Getting back in touch", "telegram") + """
</div>
""" + nav("Home")

ASK = """
<div class="c" style="justify-content:center;align-items:stretch;gap:18px;padding:22px 24px">
<div style="display:flex;flex-direction:column;align-items:center;gap:10px;text-align:center">
<span class="ds"><span class="av a-mint sh1" style="width:96px;height:96px;font-size:42px" aria-hidden="true">T</span></span>
<h1>Did you write to Tom?</h1>
<p class="m">You opened WhatsApp a moment ago.</p>
</div>
<button class="b" style="margin-top:8px">Yes, I did</button>
<button class="b b2">Not yet</button>
<p class="m" style="text-align:center">“Not yet” keeps Tom for another evening. Nothing becomes overdue.</p>
</div>
"""

def notif(icon, when, title, text, actions):
    acts = "".join("<span>%s</span>" % a for a in actions)
    return ('<div class="nt"><div class="row" style="gap:6px">%s<p class="m" style="font-size:12px;flex:1">Friends · %s</p></div>'
            '<div class="row" style="align-items:flex-start;gap:12px"><div style="flex:1"><p style="font-weight:700">%s</p><p class="m">%s</p></div>%s</div>'
            '<div class="ac">%s</div></div>' % (ci("stamp", 18), when, title, text, ci(icon, 36), acts))

NOTIFS = """
<div class="c" style="background:#0E0B12;gap:16px">
<div><h1 style="font-size:24px">What the app sends</h1><p class="m">At most one of these on a day, at the time you set.</p></div>
""" + notif("star", "19:30", "Got ten minutes for someone today?", "Tom, Anna and one more are on your mind.", ["Yes", "Not today"]) \
    + notif("cake", "19:30", "Congratulated Anna yet?", "Her birthday is today.", ["Yes", "Open chat", "Later"]) \
    + notif("chat", "19:30", "Still owe Jonas a reply?", "He wrote two days ago.", ["Open chat", "Already answered"]) \
    + notif("people", "Mon 19:30", "This week: Jonas", "Old friends pick up where they left off.", ["Say hi", "Someone else"]) + """
</div>
"""

def group(label, people, grow="none"):
    return ('<div style="display:flex;flex-direction:column;gap:10px;flex:' + grow + '"><p class="l" style="color:var(--mut)">%s</p><div class="row" style="gap:16px">%s</div></div>'
            % (label, "".join(who(l, n, c, s, 54) for l, n, c, s in people)))

PEOPLE = """
<div class="c">
<div class="row" style="justify-content:space-between"><h1>Your people</h1><button class="b ib" aria-label="Add a person">""" + ic("add", 28) + """</button></div>
<div class="card t-lilac">
<span class="tag a-lilac" style="transform:rotate(-2deg)">Getting back in touch · this week</span>
<div class="row" style="gap:14px"><span class="ds"><span class="av a-lilac sh3" style="width:56px;height:56px;font-size:24px" aria-hidden="true">J</span></span><div><h2>Jonas</h2><p style="font-size:14px">School friend. Old friends pick up where they left off.</p></div></div>
<div class="row" style="padding-bottom:4px"><button class="b" style="flex:1">""" + ci("telegram", 28) + """Say hi</button><button class="b b2">Someone else</button></div>
</div>
""" + group("Close friends", [("T", "Tom", "mint", "sh1"), ("A", "Anna", "pink", "sh2"), ("M", "Marek", "sky", "sh4"), ("L", "Lena", "sun", "sh3")]) \
    + group("Now and then", [("S", "Sophie", "coral", "sh2"), ("B", "Ben", "lilac", "sh1"), ("I", "Ida", "mint", "sh4"), ("K", "Kai", "sky", "sh3")]) + """
<div class="row" style="align-items:flex-start;gap:20px">
""" + group("A few times a year", [("N", "Nora", "pink", "sh3"), ("E", "Emil", "sun", "sh2")], "1") \
    + group("Family", [("M", "Maria", "sky", "sh4"), ("G", "Grandpa", "coral", "sh1")], "1") + """
</div>
</div>
""" + nav("People")

def cr(date, icon, title, note="", col=None, tilt=0):
    d = '<span class="a-%s" style="transform:rotate(%ddeg);color:var(--onacc)">%s</span>' % (col, tilt, date) if col else date
    n = '<p class="m">%s</p>' % note if note else ''
    return '<div class="cr"><div class="d"%s>%s</div><div class="n">%s</div><div class="x">%s%s</div></div>' % (
        ' style="padding-top:4px"' if col else '', d, ci(icon, 22), title, n)

PERSON_MORE = """
<div class="t-mint" style="border-radius:0 0 26px 26px;box-shadow:0 5px 0 var(--shd);padding:12px 16px;display:flex;align-items:center;gap:12px">
<a class="b b2 ib" style="width:44px;height:44px;border-radius:16px" href="V6Person.dc.html" aria-label="Back">""" + ic("arrow_back") + """</a>
<span class="av a-mint sh1" style="width:44px;height:44px;font-size:18px" aria-hidden="true">T</span>
<h2 style="flex:1">Tom Berger</h2>
<button class="b ib" style="width:46px;height:46px;border-radius:16px" aria-label="Open WhatsApp">""" + ci("whatsapp", 28) + """</button>
</div>
<div class="c" style="padding-top:18px">
<div class="ct">
<p class="l">Coming up</p>
""" + cr("3 Mar", "cake", "Birthday", "", "pink", 3) \
    + cr("21 Nov", "mountain", "Bouldering together", "Meet-up · 11:00", "mint", -3) + """
<p class="l" style="color:var(--on)">Today</p>
""" + cr("2 Nov", "chat", "You wrote", "New job is going well.") \
    + cr("12 Oct", "mountain", "Met up", "Bouldering, then ramen.") \
    + cr("20 Sep", "phone", "Called") \
    + cr("3 Aug", "chat", "He wrote, you answered") \
    + cr("14 Jul", "people", "Met up", "Barbecue at Anna's.") \
    + cr("3 Mar", "cake", "Birthday", "Congratulated.") \
    + cr("Feb", "stamp", "Added to your people") + """
</div>
</div>
""" + nav("People")

def pick(name, cls=None, col=None):
    if cls:
        return ('<label class="li"><span class="cb on">%s</span><span style="flex:1;font-weight:500">%s</span>'
                '<span class="tag a-%s" style="align-self:center;padding-right:6px">%s%s</span></label>' % (ic("check", 18), name, col, cls, ic("expand_more", 18)))
    return '<label class="li"><span class="cb"></span><span style="flex:1;font-weight:500">%s</span></label>' % name

SETUP = """
<div class="c" style="gap:10px">
<h1>Pick a few people to start</h1>
<p class="m">Five is plenty. You can add more any time. Numbers and birthdays come from your contacts.</p>
<div class="row" style="background:var(--s1);border-radius:26px;height:52px;padding:0 16px;flex:none">""" + ci("search", 22) + """<span class="m" style="font-size:16px">Search contacts</span></div>
""" + pick("Tom Berger", "Close friend", "sun") + pick("Anna Keller", "Close friend", "sun") + pick("Jonas Wirth", "Getting back in touch", "lilac") \
    + pick("Aunt Maria", "Family", "sky") + pick("Sophie Brandt") + pick("Marek Nowak") + pick("Grandpa") + """
<div style="flex:1"></div>
<button class="b" style="margin-bottom:10px">Start with 4 people</button>
</div>
"""

def days(on):
    return "".join('<button class="dc%s" aria-pressed="%s">%s</button>' % (" on" if d in on else "", "true" if d in on else "false", d)
                   for d in ["Mo", "Tu", "We", "Th", "Fr", "Sa", "Su"])

def seg(opts, cur):
    return '<div class="seg">' + "".join('<button%s>%s</button>' % (' class="on" aria-pressed="true"' if o == cur else '', o) for o in opts) + '</div>'

def sw(label, on=True):
    return '<div class="r">%s<button class="sw%s" role="switch" aria-checked="%s" aria-label="%s"></button></div>' % (label, "" if on else " off", "true" if on else "false", label)

SETTINGS = """
<div class="c" style="gap:12px">
<div class="row" style="gap:12px"><a class="b b2 ib" style="width:44px;height:44px;border-radius:16px" href="V6Home.dc.html" aria-label="Back">""" + ic("arrow_back") + """</a><h1>Settings</h1></div>
<div class="card" style="gap:8px;padding:14px 16px">
<p class="l" style="color:var(--mut)">Evening question</p>
<div class="r">Ask me at<button class="b b2" style="height:40px;padding:0 16px;font-size:16px">19:30</button></div>
<p style="font-weight:500">Days I can be asked</p>
<div class="row" style="justify-content:space-between;gap:4px">""" + days(["Mo", "We", "Th", "Sa", "Su"]) + """</div>
</div>
<div class="card" style="gap:8px;padding:14px 16px">
<p class="l" style="color:var(--mut)">Optional parts</p>
""" + sw("Progress and treats") + sw("Birthday follow-up") + sw("Notice when I owe a reply") + """
<p class="m" style="font-size:13px">Reads who wrote to you from message notifications. Stays on this phone. Needs notification access.</p>
</div>
<div class="card" style="gap:8px;padding:14px 16px">
<p class="l" style="color:var(--mut)">Look and more</p>
<div class="r">Open items on Home""" + seg(["One", "Three"], "One") + """</div>
<div class="r">Theme""" + seg(["System", "Dark", "Light"], "Dark") + """</div>
<div class="r">Language""" + seg(["Deutsch", "English"], "English") + """</div>
<div class="r">Friend classes and rhythms""" + ic("arrow_forward", 22) + """</div>
</div>
</div>
"""

def dirn(icon, text):
    return ic(icon, 16, "vertical-align:-2px;margin-right:4px;color:var(--mut)") + text

# Friend timeline that also shows who reached out, and birthdays in both directions
PERSON_MORE2 = PERSON_MORE[:PERSON_MORE.index('<p class="l" style="color:var(--on)">Today</p>')] + """<p class="l" style="color:var(--on)">Today</p>
""" + cr("2 Nov", "chat", dirn("north_east", "You wrote"), "New job is going well.") \
    + cr("28 Oct", "chat", dirn("south_west", "Tom wrote"), "Sent a climbing video.") \
    + cr("12 Oct", "mountain", "Met up", "Bouldering, then ramen.") \
    + cr("20 Sep", "phone", dirn("north_east", "You called")) \
    + cr("9 Jun", "cake", "Your birthday", "Tom congratulated you.") \
    + cr("3 Mar", "cake", "Tom's birthday", "You congratulated.") \
    + cr("Feb", "stamp", "Added to your people") + """
</div>
</div>
""" + nav("People")

import re
def tweak(body):
    """V6b: shadows under the people blobs, and a plain 'more' blob instead of the magnifier."""
    body = re.sub(r'(<button class="who"[^>]*>)(<span class="av a-[^>]*>[^<]*</span>)', r'\1<span class="ds">\2</span>', body)
    body = re.sub(r'<span class="av" style="background:var\(--bg\)"><svg.*?</svg></span>More',
                  '<span class="ds"><span class="av" style="background:var(--s2);color:var(--on)">' + ic("more_horiz", 26) + '</span></span>More', body, flags=re.S)
    return body

ROWS = [
    (7584, "V6 full set, every day", [
        ("V6Home", "V6 · Home", home(False)),
        ("V6Capture", "V6 · Capturing, and the list of three", CAPTURE),
        ("V6Notifications", "V6 · Notifications", NOTIFS),
        ("V6Ask", "V6 · Back from the chat", ASK),
        ("V6Done", "V6 · After 'Yes, I wrote'", DONE),
        ("V6Upcoming", "V6 · Upcoming", UPCOMING),
    ]),
    (8848, "V6 full set, people, setup and settings (stamps only tilted)", [
        ("V6People", "V6 · People", PEOPLE),
        ("V6Person", "V6 · One person", PERSON),
        ("V6PersonMore", "V6 · One person, scrolled down: upcoming and history", PERSON_MORE),
        ("V6Setup", "V6 · First start", SETUP),
        ("V6Progress", "V6 · Progress and stamp card", PROGRESS),
        ("V6Settings", "V6 · Settings", SETTINGS),
    ]),
    (10112, "V6 in light mode (the friend timeline here also shows who reached out)", [
        ("V6LightHome", "V6 light · Home", home(False)),
        ("V6LightUpcoming", "V6 light · Upcoming", UPCOMING),
        ("V6LightPersonMore", "V6 light · Friend timeline, with who reached out", PERSON_MORE2),
        ("V6LightProgress", "V6 light · Progress and stamp card", PROGRESS),
    ]),
    (11376, "V6b tweaks: shadows under people blobs and grey buttons, 'More' blob instead of the magnifier", [
        ("V6bHome", "V6b · Home", tweak(home(False))),
        ("V6bCapture", "V6b · Capturing", tweak(CAPTURE)),
        ("V6bPeople", "V6b · People", tweak(PEOPLE)),
    ]),
]

canvas = json.loads((OUT / "canvas.json").read_text())
ALL = []
for n, (y0, note, screens) in enumerate(ROWS):
    for i, (name, title, body) in enumerate(screens):
        f = name + ".dc.html"
        html = TEMPLATE.replace("__TITLE__", title).replace("__FONTS__", FONTS).replace("__CSS__", CSS).replace("__BODY__", body.strip())
        if name.startswith("V6b"):   # grey buttons get a shadow that shows on the dark ground
            html = html.replace('<div class="s dark">', '<div class="s dark" style="--s2d:#08060B">')
        if "Light" in name:
            html = html.replace('<div class="s dark">', '<div class="s light">')
        (OUT / f).write_text(html)
        if f not in canvas["boards"]:   # keep positions the developer may have changed
            canvas["boards"][f] = {"x": i * 470, "y": y0, "w": 390, "h": 844, "title": title}
        if f not in canvas["order"]:
            canvas["order"].append(f)
        ALL.append((name, body))
    canvas["notes"].setdefault("t%d" % (7 + n), {"x": 0, "y": y0 - 300, "w": 240, "text": note, "kind": "title1", "maxW": 2740})
(OUT / "canvas.json").write_text(json.dumps(canvas, ensure_ascii=False, indent=2))
for p in list(OUT.glob("V6*.dc.html")) + [OUT / "canvas.json"]:
    shutil.copy(p, DOCS / p.name)

if PREVIEW:
    for n in range(0, len(ALL), 3):
        boards = "".join('<div class="s %s" style="flex:none%s">%s</div>' % ("light" if "Light" in nm else "dark", ";--s2d:#08060B" if nm.startswith("V6b") else "", b) for nm, b in ALL[n:n + 3])
        (PREVIEW / ("v6-%d.html" % (n // 3 + 1))).write_text(
            '<!doctype html><meta charset="utf-8">%s<style>%s</style><body style="display:flex;gap:20px;background:#000">%s</body>' % (FONTS, CSS, boards))
print("ok", [a[0] for a in ALL])
