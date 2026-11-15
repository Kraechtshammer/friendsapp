"""Generates the V5 artboards: V4 with colourful icons everywhere, straight large cards,
stamps that land slightly off their slots, and the messenger's app icon on "Open chat".
V4 was made by an earlier state of this script; its screens are kept as V4*.dc.html.
Usage: python3 gen_v5.py <design/project folder> <docs/concepts folder> [preview folder]"""
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
    items = [("Home", "home", "V5Home"), ("Upcoming", "calendar", "V5Upcoming"), ("People", "people", "V5Person"), ("Progress", "stamp", "V5Progress")]
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
<div class="row" style="justify-content:space-between"><h1>Good evening</h1><button class="b b2 ib" aria-label="Settings">""" + ci("gear", 28) + """</button></div>
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
<div class="row" style="justify-content:space-between"><p class="l" style="color:var(--mut)">Coming up</p><a class="f row" style="font-weight:600;font-size:14px;gap:2px;text-decoration:none;min-height:24px" href="V5Upcoming.dc.html">See all""" + ic("arrow_forward", 18) + """</a></div>
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
    return ('<span class="slot"><span class="ds" style="transform:translate(%dpx,%dpx) rotate(%ddeg)"><span class="st a-coral sh1">' % (dx, dy, rot)) + ic("check", 26) + '</span></span></span>'
SLOT = '<span class="slot"></span>'

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
<a class="b" style="margin-bottom:10px" href="V5Home.dc.html">Back home</a>
</div>
"""

PERSON = """
<div class="t-mint" style="border-radius:0 0 32px 32px;box-shadow:0 5px 0 var(--shd);padding:16px 16px 18px;display:flex;flex-direction:column;align-items:center;gap:8px;position:relative">
<a class="b b2 ib" style="position:absolute;left:16px;top:16px;width:44px;height:44px;border-radius:16px" href="V5Home.dc.html" aria-label="Back">""" + ic("arrow_back") + """</a>
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

SCREENS = [
    ("V5Home", "V5 · Home", home(False)),
    ("V5Upcoming", "V5 · Upcoming", UPCOMING),
    ("V5Done", "V5 · After 'Yes, I wrote'", DONE),
    ("V5Person", "V5 · One person", PERSON),
    ("V5Progress", "V5 · Progress and stamp card", PROGRESS),
]

canvas = json.loads((OUT / "canvas.json").read_text())
Y0 = 6320
for i, (name, title, body) in enumerate(SCREENS):
    f = name + ".dc.html"
    html = TEMPLATE.replace("__TITLE__", title).replace("__FONTS__", FONTS).replace("__CSS__", CSS).replace("__BODY__", body.strip())
    (OUT / f).write_text(html)
    if f not in canvas["boards"]:   # keep positions the developer may have changed
        canvas["boards"][f] = {"x": i * 470, "y": Y0, "w": 390, "h": 844, "title": title}
    if f not in canvas["order"]:
        canvas["order"].append(f)
canvas["notes"].setdefault("t6", {"x": 0, "y": Y0 - 300, "w": 240, "text": "V5: colourful icons everywhere, large cards straight, imperfect stamps, messenger icon on Open chat", "kind": "title1", "maxW": 2740})
(OUT / "canvas.json").write_text(json.dumps(canvas, ensure_ascii=False, indent=2))
for p in list(OUT.glob("V5*.dc.html")) + [OUT / "canvas.json"]:
    shutil.copy(p, DOCS / p.name)

if PREVIEW:
    for n, part in enumerate([SCREENS[:3], SCREENS[3:]], 1):
        boards = "".join('<div class="s dark" style="flex:none">%s</div>' % b for _, _, b in part)
        (PREVIEW / ("preview%d.html" % n)).write_text(
            '<!doctype html><meta charset="utf-8">%s<style>%s</style><body style="display:flex;gap:20px;background:#000">%s</body>' % (FONTS, CSS, boards))
print("ok", [s[0] for s in SCREENS])
