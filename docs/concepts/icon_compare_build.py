import json, base64, sys, pathlib, shutil
S = pathlib.Path(sys.argv[1]); OUT = S/"design/project"; DOCS = pathlib.Path("docs/concepts")
src = open(DOCS/"gen_v6.py").read()
ns = {}; sys.argv = ["x", str(OUT), str(DOCS)]
exec(src[:src.index("def ci(")], ns)
ICONS = ns["ICONS"]
cand = json.load(open(S/"icons/candidates.json"))
CONCEPTS = ["home","calendar","people","cake","mountain","phone","chat","dice","settings","star","leaf","popcorn","check","gift"]
OURS = {"home":"home","calendar":"calendar","people":"people","cake":"cake","mountain":"mountain","phone":"phone","chat":"chat","dice":"dice","settings":"gear","star":"star","leaf":"leaf","popcorn":"popcorn","check":"stamp"}
ROWS = [("Ours (drawn for the concept)", "no licence question", None),
        ("Fluent Emoji Flat · Microsoft", "MIT · 3,145 icons", "fluent-emoji-flat"),
        ("Streamline Plump Color", "CC BY 4.0, credit needed · 1,000", "streamline-plump-color"),
        ("Streamline Flex Color", "CC BY 4.0, credit needed · 1,000", "streamline-flex-color"),
        ("Streamline Kameleon Color", "CC BY 4.0, credit needed · 400+", "streamline-kameleon-color"),
        ("Streamline Stickies Color", "CC BY 4.0, credit needed · 200", "streamline-stickies-color"),
        ("Icons8 Flat Color Icons", "MIT · about 320, repo archived", "flat-color-icons")]
def cell(setid, c):
    if setid is None:
        if c not in OURS: return '<span class="no">not drawn</span>'
        return '<svg width="40" height="40" viewBox="0 0 48 48">%s</svg>' % ICONS[OURS[c]]
    e = cand.get(setid, {}).get(c)
    if not e: return '<span class="no">none found</span>'
    return '<img width="40" height="40" alt="%s" src="data:image/svg+xml;base64,%s">' % (e["name"], base64.b64encode(e["svg"].encode()).decode())
def panel(theme):
    h = '<div class="p %s"><div class="r h"><div class="n"></div>%s</div>' % (theme, "".join('<div class="k">%s</div>' % c for c in CONCEPTS))
    for name, lic, sid in ROWS:
        h += '<div class="r"><div class="n"><b>%s</b><span>%s</span></div>%s</div>' % (name, lic, "".join('<div class="k">%s</div>' % cell(sid, c) for c in CONCEPTS))
    return h + '</div>'
CSS = """body{margin:0}
.w{width:1180px;height:1080px;box-sizing:border-box;font-family:'Roboto',system-ui,sans-serif;font-size:13px;display:flex;flex-direction:column}
.p{flex:1;padding:14px 20px;display:flex;flex-direction:column;justify-content:space-between}
.dark{background:#17121C;color:#EFE3F2}.light{background:#FFF6EA;color:#2A1B3D}
.r{display:flex;align-items:center;height:58px;border-radius:16px;padding:0 10px}
.dark .r:not(.h){background:#231C2A}.light .r:not(.h){background:#fff}
.r.h{height:24px;font:600 11px 'Outfit','Roboto',sans-serif;letter-spacing:.08em;text-transform:uppercase;opacity:.7}
.n{width:250px;flex:none;display:flex;flex-direction:column}.n b{font:600 15px 'Outfit','Roboto',sans-serif}.n span{opacity:.7;font-size:12px}
.k{flex:1;display:flex;align-items:center;justify-content:center;text-align:center}
.no{opacity:.45;font-size:10px;line-height:1.1}"""
FONTS = '<link href="https://fonts.googleapis.com/css2?family=Outfit:wght@500;600;700&family=Roboto:wght@400;500;700&display=swap" rel="stylesheet">'
body = '<div class="w">' + panel("dark") + panel("light") + '</div>'
html = """<!doctype html>
<html lang="en">
<head>
<meta charset="utf-8">
<title>Icon set comparison</title>
<script src="./support.js"></script>
</head>
<body>
<x-dc>
<helmet>
%s
<style>%s</style>
</helmet>
%s
</x-dc>
<script type="text/x-dc" data-dc-script data-props='{"$preview":{"width":1180,"height":1080}}'>
class Component extends DCLogic {
renderVals() { return {}; }
}
</script>
</body>
</html>
""" % (FONTS, CSS, body)
f = "IconCompare.dc.html"
(OUT/f).write_text(html); shutil.copy(OUT/f, DOCS/f)
canvas = json.loads((OUT/"canvas.json").read_text())
canvas["boards"].setdefault(f, {"x": 0, "y": 12640, "w": 1180, "h": 1080, "title": "Icon sets compared: ours and six candidates, dark and light"})
if f not in canvas["order"]: canvas["order"].append(f)
canvas["notes"].setdefault("t11", {"x": 0, "y": 12340, "w": 240, "text": "Icon sets: ours against candidates (samples picked by search, so some matches are off)", "kind": "title1", "maxW": 2740})
(OUT/"canvas.json").write_text(json.dumps(canvas, ensure_ascii=False, indent=2)); shutil.copy(OUT/"canvas.json", DOCS/"canvas.json")
(S/"prev/compare.html").write_text('<!doctype html><meta charset="utf-8">%s<style>%s</style><body>%s</body>' % (FONTS, CSS, body))
print("ok", len(html))
