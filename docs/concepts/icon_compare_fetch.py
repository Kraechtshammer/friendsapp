import json, urllib.request, urllib.parse, sys, pathlib
out = pathlib.Path(sys.argv[1])
CONCEPTS = ["home","calendar","people","cake","mountain","phone","chat","dice","settings","star","leaf","popcorn","check","gift"]
QUERY = {"people":["users","people","group","team"],"chat":["chat","message","speech","bubble"],"settings":["gear","settings","cog"],"check":["check","badge","verified"],
         "leaf":["leaf","plant"],"dice":["dice","die"],"phone":["phone","telephone","call"],"cake":["cake","birthday"],"mountain":["mountain","hiking","climb"],"home":["home","house"],
         "popcorn":["popcorn","cinema","movie"],"gift":["gift","present"],"star":["star"],"calendar":["calendar"]}
FIXED = {"fluent-emoji-flat":{"home":"house","calendar":"calendar","people":"busts-in-silhouette","cake":"birthday-cake","mountain":"mountain","phone":"telephone-receiver","chat":"speech-balloon",
         "dice":"game-die","settings":"gear","star":"star","leaf":"herb","popcorn":"popcorn","check":"check-mark-button","gift":"wrapped-gift"}}
SETS = ["fluent-emoji-flat","streamline-plump-color","streamline-kameleon-color","streamline-stickies-color","streamline-flex-color","flat-color-icons","fluent-color"]
def get(url):
    req = urllib.request.Request(url, headers={"User-Agent":"icon-compare/1.0"})
    with urllib.request.urlopen(req, timeout=20) as r: return r.read().decode()
res = {}
for s in SETS:
    res[s] = {}
    for c in CONCEPTS:
        name = FIXED.get(s,{}).get(c)
        if not name:
            for q in QUERY[c]:
                try:
                    d = json.loads(get("https://api.iconify.design/search?query=%s&prefix=%s&limit=8" % (urllib.parse.quote(q), s)))
                except Exception as e:
                    d = {"icons":[]}
                ic = [i.split(":")[1] for i in d.get("icons",[])]
                ic = [i for i in ic if not i.endswith("-flat")] or ic
                if ic: name = ic[0]; break
        if not name: continue
        try:
            svg = get("https://api.iconify.design/%s/%s.svg?height=48" % (s, name))
            if svg.startswith("<svg"): res[s][c] = {"name":name,"svg":svg}
        except Exception as e: pass
    print(s, len(res[s]), [res[s].get(c,{}).get("name","-") for c in CONCEPTS])
(out/"candidates.json").write_text(json.dumps(res))
