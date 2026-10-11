#!/usr/bin/env python3
import sys, re, html, hashlib, random
from pathlib import Path

if len(sys.argv) != 3:
    print("Usage: generate_product_assets.py products.psv output_dir")
    sys.exit(2)

src = Path(sys.argv[1])
out = Path(sys.argv[2])
out.mkdir(parents=True, exist_ok=True)

def esc(s):
    return html.escape(s or "", quote=True)

def clean_name(name):
    return re.sub(r"\s+\d{4}$", "", (name or "").strip())

def seed_int(pid, name, category):
    raw = f"{pid}|{name}|{category}".encode("utf-8")
    return int(hashlib.sha256(raw).hexdigest()[:16], 16)

def family_for(name, category):
    base = clean_name(name).lower()
    exact = {
        "wireless earbuds":"earbuds","bluetooth speaker":"speaker","power bank":"powerbank",
        "5g smartphone":"phone","android tablet":"tablet","fast charger":"charger",
        "ultrabook laptop":"laptop","mechanical keyboard":"computer_keyboard","27-inch monitor":"monitor",
        "4k smart tv":"tv","soundbar":"soundbar","over-ear headphones":"headphones",
        "mirrorless camera":"camera","action camera":"actioncam","camera tripod":"tripod",
        "gaming console":"console","gaming mouse":"mouse","gaming headset":"headset",
        "cookware set":"cookware","chef knife set":"knives","coffee maker":"coffeemaker",
        "nordic lounge chair":"chair","oak coffee table":"table","study desk":"desk",
        "ceramic table lamp":"tablelamp","arc floor lamp":"floorlamp","pendant light":"pendantlight",
        "stoneware vase":"vase","round wall mirror":"mirror","abstract wall art":"wallart",
        "air fryer":"airfryer","microwave oven":"microwave","vacuum cleaner":"vacuum",
        "oxford shirt":"shirt","slim fit jeans":"jeans","casual jacket":"jacket",
        "printed kurta":"kurta","midi dress":"dress","denim jacket":"jacket",
        "running shoes":"shoe","leather sneakers":"shoe","formal loafers":"loafer",
        "travel backpack":"backpack","cabin trolley":"trolley","crossbody bag":"bag",
        "minimal pendant":"jewelry_pendant","stud earring set":"earrings","pearl necklace":"necklace",
        "classic analog watch":"analogwatch","smart fitness watch":"smartwatch","sports chronograph":"chronograph",
        "hydrating face serum":"serum","hair dryer":"hairdryer","skincare gift kit":"skincarekit",
        "yoga mat":"yogamat","massage gun":"massagegun","digital weighing scale":"scale",
        "premium coffee beans":"coffeebag","dry fruit mix":"dryfruit","organic honey":"honey",
        "modern fiction book":"book","business essentials book":"book","design coffee table book":"book",
        "adjustable dumbbell set":"dumbbell","football":"football","badminton racket":"racket",
        "building blocks set":"blocks","strategy board game":"boardgame","remote control toy car":"toycar",
        "baby stroller":"stroller","baby blanket":"blanket","soft activity toy":"softtoy",
        "car vacuum cleaner":"carvacuum","phone car mount":"carmount","dash camera":"dashcam",
        "pet bed":"petbed","pet grooming kit":"grooming","interactive pet toy":"pettoy",
        "premium notebook set":"notebook","desk organizer":"organizer","planner journal":"journal",
        "garden tool set":"gardentools","solar garden light":"solarlight","outdoor planter":"planter",
        "cordless drill":"drill","tool kit":"toolkit","screwdriver set":"screwdrivers",
        "acoustic guitar":"guitar","portable keyboard":"music_keyboard","studio microphone":"microphone",
        "luxury gift hamper":"hamper","personalized mug":"mug","celebration gift box":"giftbox",
        "travel neck pillow":"neckpillow","universal travel adapter":"traveladapter","packing cube set":"packingcubes",
    }
    if base in exact:
        return exact[base]

    s = (base + " " + (category or "").lower())
    rules = [
        (r"keyboard","computer_keyboard"),(r"earbud","earbuds"),(r"headphone|headset","headphones"),
        (r"smartphone|phone","phone"),(r"tablet","tablet"),(r"laptop","laptop"),
        (r"monitor","monitor"),(r"camera","camera"),(r"speaker","speaker"),(r"watch","analogwatch"),
        (r"serum","serum"),(r"shoe|sneaker|loafer","shoe"),(r"bag|backpack","bag"),
        (r"chair","chair"),(r"lamp|light","tablelamp"),(r"wall art|painting","wallart"),
        (r"book","book"),(r"mug|cup","mug"),(r"toy","softtoy"),(r"gift","giftbox"),
        (r"guitar","guitar"),(r"drill|tool","toolkit"),(r"garden|planter","planter"),
    ]
    for pat, fam in rules:
        if re.search(pat, s):
            return fam
    return "generic"

def colors(rng):
    h1 = rng.randrange(0, 360)
    h2 = (h1 + rng.randrange(35, 115)) % 360
    h3 = (h1 + 180 + rng.randrange(-30, 31)) % 360
    return (
        f"hsl({h1},42%,58%)",
        f"hsl({h2},38%,38%)",
        f"hsl({h3},42%,72%)",
        f"hsl({h1},35%,91%)",
        f"hsl({h2},30%,76%)",
    )

def rect(x,y,w,h,rx,fill, extra=""):
    return f'<rect x="{x}" y="{y}" width="{w}" height="{h}" rx="{rx}" fill="{fill}" {extra}/>'

def circle(cx,cy,r,fill,extra=""):
    return f'<circle cx="{cx}" cy="{cy}" r="{r}" fill="{fill}" {extra}/>'

def line(x1,y1,x2,y2,stroke,width,extra=""):
    return f'<line x1="{x1}" y1="{y1}" x2="{x2}" y2="{y2}" stroke="{stroke}" stroke-width="{width}" {extra}/>'

def family_art(fam, rng, c1, c2, c3, variant):
    dark = "#2d2925"
    light = "#fffaf4"
    mid = "#8b8178"
    v = variant % 7

    if fam == "earbuds":
        case_w = 220 + v*8
        x = 320-case_w/2
        return (
            rect(x,220,case_w,125,48,"url(#obj)") +
            f'<path d="M210 105c35-20 75 8 75 43v102h-48v-80c0-10-7-18-18-18s-18 8-18 18v42h-42v-66c0-18 18-32 51-41z" fill="{light}"/>' +
            f'<path d="M430 105c-35-20-75 8-75 43v102h48v-80c0-10 7-18 18-18s18 8 18 18v42h42v-66c0-18-18-32-51-41z" fill="{light}"/>'
        )
    if fam in ("speaker","soundbar"):
        if fam == "soundbar":
            return rect(100,210,440,105,38,dark) + circle(175,262,28,c1) + circle(465,262,28,c1) + rect(255,248,130,26,13,c3)
        return rect(230,70,180,310,30,dark) + circle(320,270,66,"#5f5650") + circle(320,270,38,c1) + circle(320,145,26,c3)
    if fam == "powerbank":
        return rect(205,110,230,260,34,"url(#obj)") + rect(250,145,140,22,11,light,'opacity=".35"') + circle(320,300,34,light,'opacity=".22"')
    if fam == "phone":
        cams = 2 + (v % 3)
        cam_markup = "".join(circle(245+(i%2)*48,115+(i//2)*48,17,"#141414") for i in range(cams))
        return rect(210,55,220,360,36,dark) + rect(224,69,192,332,28,"url(#screen)") + cam_markup
    if fam == "tablet":
        return rect(160,65,320,330,38,dark) + rect(175,80,290,300,28,"url(#screen)") + circle(320,90,6,"#111")
    if fam == "charger":
        return rect(235,135,170,190,28,light,'stroke="#cabdb1" stroke-width="5"') + rect(275,315,18,70,7,mid) + rect(345,315,18,70,7,mid) + circle(320,230,30,c1)
    if fam == "laptop":
        return rect(155,70,330,220,24,dark) + rect(174,89,292,182,14,"url(#screen)") + '<path d="M105 300h430l-48 72H153z" fill="#cbc2ba"/>' + rect(270,322,100,20,8,"#a99f96")
    if fam == "computer_keyboard":
        cols = 14 + (v%3)*2
        rows = 5 if v%2==0 else 6
        parts = [f'<g transform="translate(105 150) rotate({-8+v*2} 215 75)">', rect(0,0,430,150,24,dark)]
        kw = 19 if cols>=16 else 23
        gap = 6
        for r in range(rows):
            for c in range(cols):
                x=16+c*(kw+gap)
                if x+kw>414: break
                parts.append(rect(x,15+r*21,kw,14,3, light if (c+r+v)%7 else c1, 'opacity=".92"'))
        parts.append("</g>")
        return "".join(parts)
    if fam == "monitor":
        return rect(115,65,410,255,24,dark) + rect(135,85,370,215,14,"url(#screen)") + rect(300,320,40,72,10,mid) + rect(225,382,190,18,9,mid)
    if fam == "tv":
        return rect(85,70,470,270,18,dark) + rect(104,89,432,232,9,"url(#screen)") + line(250,350,390,350,mid,18,'stroke-linecap="round"')
    if fam in ("headphones","headset"):
        mic = line(430,260,500,300,dark,10,'stroke-linecap="round"') if fam=="headset" else ""
        return f'<path d="M205 260v-70c0-135 230-135 230 0v70" fill="none" stroke="{dark}" stroke-width="36" stroke-linecap="round"/>' + rect(150,225,95,135,38,dark) + rect(395,225,95,135,38,dark) + mic
    if fam in ("camera","actioncam","dashcam"):
        if fam=="actioncam":
            return rect(190,110,260,230,35,dark) + circle(320,225,78,"#68615c") + circle(320,225,45,"url(#screen)") + rect(220,130,70,28,10,c1)
        if fam=="dashcam":
            return rect(180,120,280,185,26,dark) + circle(320,212,65,"#5d5550") + circle(320,212,38,"url(#screen)") + rect(285,305,70,80,14,mid)
        return rect(145,145,350,205,34,dark) + rect(205,95,120,65,14,dark) + circle(320,248,92,"#6a625c") + circle(320,248,56,"url(#screen)")
    if fam == "tripod":
        return circle(320,120,28,dark) + line(320,145,230,390,dark,15,'stroke-linecap="round"') + line(320,145,410,390,dark,15,'stroke-linecap="round"') + line(320,145,320,395,dark,15,'stroke-linecap="round"') + rect(270,78,100,45,14,c1)
    if fam == "console":
        return rect(170,105,300,195,38,"url(#obj)") + rect(265,295,110,68,28,dark) + circle(300,330,10,light)+circle(340,330,10,light)
    if fam == "mouse":
        return rect(250,85,140,285,70,dark) + line(320,85,320,210,light,4,'opacity=".35"') + rect(305,135,30,55,15,c1)
    if fam == "cookware":
        return circle(300,245,95,"url(#obj)") + rect(365,225,165,30,15,dark) + circle(225,145,62,c3) + rect(175,132,85,20,10,dark)
    if fam == "knives":
        return ''.join(f'<g transform="translate({180+i*70} {100+i*8}) rotate({-10+i*6})"><path d="M0 0h32v210H0z" fill="#c9c5c2"/><rect x="-4" y="205" width="40" height="115" rx="15" fill="{dark}"/></g>' for i in range(4))
    if fam == "coffeemaker":
        return rect(215,90,210,285,28,dark) + rect(245,120,150,95,16,c1) + '<path d="M255 230h130l-15 105H270z" fill="url(#glass)"/>' + rect(315,335,25,35,8,dark)
    if fam == "chair":
        return rect(220,70,200,205,55,"url(#obj)") + rect(190,250,260,82,28,"url(#obj)") + line(235,320,215,410,dark,18,'stroke-linecap="round"') + line(405,320,425,410,dark,18,'stroke-linecap="round"')
    if fam in ("table","desk"):
        top_y=205 if fam=="table" else 165
        return rect(135,top_y,370,70,22,"url(#obj)") + line(175,top_y+60,155,405,dark,18,'stroke-linecap="round"') + line(465,top_y+60,485,405,dark,18,'stroke-linecap="round"') + (rect(180,250,120,65,12,c3) if fam=="desk" else "")
    if fam == "tablelamp":
        return '<path d="M230 85h180l50 145H180z" fill="url(#obj)"/>' + rect(307,230,26,115,13,dark)+f'<ellipse cx="320" cy="365" rx="105" ry="28" fill="{dark}"/>'
    if fam == "floorlamp":
        return '<path d="M360 65h135l38 105H322z" fill="url(#obj)"/>' + f'<path d="M385 175c-130 35-155 115-155 185" fill="none" stroke="{dark}" stroke-width="20" stroke-linecap="round"/>' + f'<ellipse cx="230" cy="385" rx="85" ry="24" fill="{dark}"/>'
    if fam == "pendantlight":
        return line(320,35,320,145,dark,10) + '<path d="M210 150h220l-45 125H255z" fill="url(#obj)"/>' + circle(320,260,25,"#ffe59a")
    if fam == "vase":
        return '<path d="M270 85h100l18 70 62 220H190l62-220z" fill="url(#obj)"/>' + rect(285,72,70,20,10,c3)
    if fam == "mirror":
        return '<ellipse cx="320" cy="225" rx="145" ry="170" fill="#8b6d55"/><ellipse cx="320" cy="225" rx="125" ry="150" fill="url(#glass)"/>'
    if fam == "wallart":
        return rect(130,65,380,315,18,"#7c6049") + rect(150,85,340,275,10,"#f3e8dc") + circle(250,185,68,c1) + rect(335,125,85,160,18,c3,f'transform="rotate({12+v*5} 377 205)"') + line(205,310,440,120,dark,12,'opacity=".25"')
    if fam == "airfryer":
        return rect(225,80,190,305,38,dark) + rect(250,110,140,70,18,c1) + rect(265,240,110,95,25,"#49423d") + rect(292,325,56,38,12,c3)
    if fam == "microwave":
        return rect(115,120,410,245,28,dark) + rect(145,150,260,185,18,"#25282a") + rect(425,150,70,185,18,"#4e4741") + circle(460,195,18,c1)+circle(460,245,18,c3)
    if fam in ("vacuum","carvacuum"):
        return circle(250,285,85,"url(#obj)") + f'<path d="M305 240c100-105 150-100 175-35" fill="none" stroke="{dark}" stroke-width="24" stroke-linecap="round"/>' + rect(450,185,65,95,24,dark)
    if fam in ("shirt","kurta","dress","jacket"):
        if fam=="dress":
            return '<path d="M285 75h70l35 80-65 55 115 185H200l115-185-65-55z" fill="url(#obj)"/>'
        if fam=="jacket":
            return '<path d="M250 80h140l60 70-45 65-40-38v220H275V177l-40 38-45-65z" fill="url(#obj)"/>' + line(320,95,320,385,light,6,'opacity=".55"')
        return '<path d="M250 80h140l65 70-45 70-45-38v210H275V182l-45 38-45-70z" fill="url(#obj)"/>'
    if fam == "jeans":
        return '<path d="M245 75h150l20 110-45 220h-70l20-185-20 185h-70l-5-220z" fill="url(#obj)"/>'
    if fam in ("shoe","loafer"):
        upper = '<path d="M135 290c65-35 105-110 170-155 50-34 95 40 140 83 35 33 70 42 105 50l-20 75H155z" fill="url(#obj)"/>'
        sole = line(150,345,525,345,"#f2ebe4",28,'stroke-linecap="round"')
        if fam=="loafer":
            upper = '<path d="M140 285c80-30 135-105 210-125 40-10 55 55 105 80 42 22 72 25 95 30l-15 72H155z" fill="url(#obj)"/>' + rect(275,205,120,20,10,c3)
        return upper + sole
    if fam == "backpack":
        return rect(205,80,230,305,70,"url(#obj)") + rect(245,250,150,95,25,"rgba(255,255,255,.18)") + f'<path d="M255 110c10-80 120-80 130 0" fill="none" stroke="{dark}" stroke-width="20"/>'
    if fam == "trolley":
        return rect(220,85,200,300,38,"url(#obj)") + f'<path d="M275 85V45h90v40" fill="none" stroke="{dark}" stroke-width="14"/>' + circle(260,400,14,dark)+circle(380,400,14,dark)
    if fam == "bag":
        return rect(180,155,280,215,42,"url(#obj)") + f'<path d="M245 165v-45c0-90 150-90 150 0v45" fill="none" stroke="{dark}" stroke-width="22"/>'
    if fam in ("jewelry_pendant","earrings","necklace"):
        if fam=="earrings":
            return circle(245,215,42,"none",'stroke="url(#obj)" stroke-width="22"') + circle(395,215,42,"none",'stroke="url(#obj)" stroke-width="22"') + circle(245,315,28,c3)+circle(395,315,28,c3)
        if fam=="necklace":
            return '<path d="M175 120c35 240 255 240 290 0" fill="none" stroke="url(#obj)" stroke-width="18"/>' + circle(320,330,42,c3)
        return '<path d="M195 100c25 225 225 225 250 0" fill="none" stroke="url(#obj)" stroke-width="16"/>' + f'<path d="M320 270l38 58-38 58-38-58z" fill="{c3}"/>'
    if fam in ("analogwatch","smartwatch","chronograph"):
        face = "50%" if fam!="smartwatch" else "28%"
        extra = circle(320,235,18,c1) if fam=="chronograph" else ""
        return rect(282,30,76,390,35,"url(#obj)") + rect(225,145,190,180,face,dark,'stroke="#c9b39e" stroke-width="10"') + line(320,235,320,185,light,6,'stroke-linecap="round"') + line(320,235,362,260,light,6,'stroke-linecap="round"') + extra
    if fam == "serum":
        bottle_w=155+(v%3)*12
        x=320-bottle_w/2
        return rect(285,55,70,58,10,dark) + rect(x,108,bottle_w,270,34,"url(#glass)",'stroke="rgba(255,255,255,.65)" stroke-width="5"') + rect(x+25,215,bottle_w-50,70,14,light,'opacity=".76"')
    if fam == "hairdryer":
        return circle(270,190,100,"url(#obj)") + rect(330,160,170,70,34,dark) + f'<path d="M280 245l75 150h-62l-70-125z" fill="{dark}"/>'
    if fam == "skincarekit":
        return rect(165,125,120,250,30,"url(#glass)") + rect(305,165,105,210,24,"url(#obj)") + rect(430,215,75,160,22,c3) + rect(190,230,70,65,14,light,'opacity=".7"')
    if fam == "yogamat":
        return '<ellipse cx="250" cy="285" rx="120" ry="55" fill="url(#obj)"/><rect x="250" y="230" width="250" height="110" rx="55" fill="url(#obj)"/>' + line(370,235,370,335,light,8,'opacity=".35"')
    if fam == "massagegun":
        return circle(205,185,45,c3) + rect(245,145,230,90,35,"url(#obj)") + rect(350,225,75,170,30,dark)
    if fam == "scale":
        return rect(170,115,300,280,45,"url(#glass)",'stroke="rgba(255,255,255,.7)" stroke-width="5"') + rect(265,145,110,55,18,dark) + f'<text x="320" y="181" text-anchor="middle" font-size="28" fill="{light}">{55+v*3}.2</text>'
    if fam in ("coffeebag","dryfruit"):
        label="COFFEE" if fam=="coffeebag" else "MIX"
        return '<path d="M205 70h230l25 320H180z" fill="url(#obj)"/>' + rect(230,190,180,90,20,light,'opacity=".78"') + f'<text x="320" y="245" text-anchor="middle" font-size="28" font-weight="800" fill="{dark}">{label}</text>'
    if fam == "honey":
        return rect(235,105,170,275,45,"url(#obj)") + rect(265,65,110,55,16,dark) + rect(260,205,120,70,18,light,'opacity=".78"')
    if fam == "book":
        return rect(205,65,230,335,20,"url(#obj)",f'transform="rotate({-6+v*2} 320 230)"') + rect(230,135,180,110,16,"rgba(255,255,255,.18)")
    if fam == "dumbbell":
        return rect(185,220,270,35,17,dark) + rect(125,155,95,165,24,"url(#obj)") + rect(420,155,95,165,24,"url(#obj)")
    if fam == "football":
        return circle(320,225,135,"#f0ede8") + f'<path d="M320 90l55 42-20 65h-70l-20-65z" fill="{dark}"/>' + circle(225,210,32,dark)+circle(420,210,32,dark)+circle(320,330,32,dark)
    if fam == "racket":
        return f'<ellipse cx="290" cy="180" rx="110" ry="140" fill="none" stroke="{dark}" stroke-width="20"/>' + line(360,285,455,400,dark,24,'stroke-linecap="round"') + ''.join(line(210+i*20,80,210+i*20,280,"rgba(255,255,255,.35)",3) for i in range(9))
    if fam == "blocks":
        cols=[c1,c2,c3,"#d55d58","#e4b54d","#69a36d"]
        parts=[]
        pos=[(160,245),(285,245),(410,245),(220,120),(345,120)]
        for i,(x,y) in enumerate(pos):
            parts.append(rect(x,y,105,105,16,cols[(i+v)%len(cols)]))
            parts.append(circle(x+28,y-4,12,cols[(i+v)%len(cols)]))
            parts.append(circle(x+77,y-4,12,cols[(i+v)%len(cols)]))
        return "".join(parts)
    if fam == "boardgame":
        return rect(140,85,360,300,28,"url(#obj)") + rect(185,130,270,210,18,light,'opacity=".82"') + circle(250,210,32,c1)+circle(390,255,28,c3)+rect(285,275,70,45,12,c2)
    if fam == "toycar":
        return rect(160,205,320,115,42,"url(#obj)") + '<path d="M235 205l65-75h110l55 75z" fill="url(#obj2)"/>' + circle(230,330,40,dark)+circle(410,330,40,dark)
    if fam == "stroller":
        return '<path d="M210 120h200l-35 170H245z" fill="url(#obj)"/>' + line(405,130,485,70,dark,16,'stroke-linecap="round"') + line(250,285,205,390,dark,14) + line(365,285,425,390,dark,14) + circle(205,395,30,dark)+circle(425,395,30,dark)
    if fam == "blanket":
        return rect(145,105,350,280,42,"url(#obj)") + f'<path d="M175 150c95 80 195-60 285 35M175 245c95 80 195-60 285 35" fill="none" stroke="{light}" stroke-width="14" opacity=".35"/>'
    if fam == "softtoy":
        return circle(320,170,90,"url(#obj)") + circle(250,110,38,"url(#obj)") + circle(390,110,38,"url(#obj)") + circle(320,300,105,"url(#obj)") + circle(285,155,10,dark)+circle(355,155,10,dark)+circle(320,195,14,c3)
    if fam == "carmount":
        return circle(320,205,72,dark) + rect(292,250,56,110,20,dark) + rect(230,90,180,215,28,"none",'stroke="url(#obj)" stroke-width="20"')
    if fam == "petbed":
        return '<ellipse cx="320" cy="280" rx="190" ry="100" fill="url(#obj)"/>' + f'<ellipse cx="320" cy="260" rx="135" ry="55" fill="{c3}"/>'
    if fam == "grooming":
        return rect(165,205,310,145,35,"url(#obj)") + rect(210,115,35,110,17,dark) + rect(300,95,35,130,17,dark) + rect(390,130,35,95,17,dark)
    if fam == "pettoy":
        return circle(260,220,85,c1) + circle(380,220,85,c3) + rect(275,195,90,50,25,dark)
    if fam in ("notebook","journal"):
        return rect(190,70,270,335,22,"url(#obj)") + rect(220,120,210,55,14,light,'opacity=".22"') + ''.join(circle(188,110+i*45,8,mid) for i in range(6))
    if fam == "organizer":
        return rect(160,190,320,180,28,"url(#obj)") + rect(200,115,40,100,18,dark)+rect(285,90,40,125,18,c1)+rect(370,130,40,85,18,c3)
    if fam == "gardentools":
        return rect(245,175,150,210,30,"#a66f4d") + line(230,90,300,260,dark,18) + line(325,70,325,270,dark,18) + line(420,105,350,270,dark,18)
    if fam == "solarlight":
        return rect(245,70,150,120,18,dark) + rect(260,85,120,90,12,"url(#screen)") + rect(307,190,26,175,12,mid) + f'<path d="M270 365h100l-50 55z" fill="{dark}"/>'
    if fam == "planter":
        return '<path d="M220 245h200l-35 145H255z" fill="#a96847"/>' + '<ellipse cx="320" cy="150" rx="60" ry="120" fill="#63845b" transform="rotate(-18 320 150)"/>' + '<ellipse cx="250" cy="175" rx="50" ry="95" fill="#75956b" transform="rotate(-42 250 175)"/>' + '<ellipse cx="390" cy="175" rx="50" ry="95" fill="#75956b" transform="rotate(42 390 175)"/>'
    if fam == "drill":
        return rect(175,140,310,100,32,"url(#obj)") + rect(355,220,85,170,32,dark) + rect(485,168,80,28,14,mid)
    if fam == "toolkit":
        return rect(150,165,340,210,35,"url(#obj)") + f'<path d="M245 165v-55h150v55" fill="none" stroke="{dark}" stroke-width="20"/>' + rect(195,230,250,45,14,"rgba(255,255,255,.16)")
    if fam == "screwdrivers":
        colors4=[c1,c2,c3,dark]
        return ''.join(f'<g transform="translate({180+i*75} {95+i%2*30}) rotate({-8+i*5})"><rect x="0" y="0" width="18" height="190" rx="9" fill="#aaa"/><rect x="-15" y="175" width="48" height="135" rx="22" fill="{colors4[i%4]}"/></g>' for i in range(4))
    if fam == "guitar":
        return rect(307,40,28,230,12,"#5c3e2c") + circle(320,300,95,"url(#obj)") + circle(320,220,62,"url(#obj)") + circle(320,255,24,dark)
    if fam == "music_keyboard":
        parts=[rect(105,155,430,165,28,dark)]
        for i in range(14):
            parts.append(rect(125+i*28,175,24,115,3,light))
            if i not in (2,6,9,13):
                parts.append(rect(143+i*28,175,14,70,3,dark))
        return "".join(parts)
    if fam == "microphone":
        return circle(320,145,70,"#5c5752") + rect(290,190,60,155,28,dark) + rect(270,335,100,24,12,mid) + line(320,345,320,400,mid,18)
    if fam == "hamper":
        return '<path d="M160 190h320l-45 195H205z" fill="url(#obj)"/>' + f'<path d="M220 195c10-125 190-125 200 0" fill="none" stroke="{dark}" stroke-width="20"/>' + circle(250,210,35,c3)+circle(320,190,42,c1)+circle(390,215,32,light)
    if fam == "mug":
        return rect(195,135,230,240,35,"url(#obj)") + '<path d="M420 190c120 0 120 125 0 125" fill="none" stroke="url(#obj)" stroke-width="35"/>' + rect(235,220,150,55,14,light,'opacity=".72"')
    if fam == "giftbox":
        return rect(165,155,310,220,28,"url(#obj)") + rect(300,155,40,220,0,"#f0dbc5") + rect(165,235,310,35,0,"#f0dbc5") + '<path d="M320 160c-75-105-145 0-65 52M320 160c75-105 145 0 65 52" fill="none" stroke="#f0dbc5" stroke-width="22" stroke-linecap="round"/>'
    if fam == "neckpillow":
        return '<path d="M195 220c0-110 250-110 250 0v110h-80v-78c0-55-90-55-90 0v78h-80z" fill="url(#obj)"/>'
    if fam == "traveladapter":
        return rect(215,120,210,235,32,light,'stroke="#c9bdb0" stroke-width="5"') + rect(250,165,55,55,12,dark)+rect(335,165,55,55,12,dark)+rect(292,245,56,45,12,c1)
    if fam == "packingcubes":
        return rect(110,125,190,160,30,c1) + rect(330,95,200,185,30,c3) + rect(215,280,215,115,28,c2) + rect(145,155,120,26,10,light,'opacity=".35"') + rect(370,130,120,26,10,light,'opacity=".35"')
    return rect(185,80,270,300,36,"url(#obj)") + rect(225,175,190,85,18,light,'opacity=".75"')

def make_svg(pid, name, category):
    seed = seed_int(pid, name, category)
    rng = random.Random(seed)
    fam = family_for(name, category)
    c1,c2,c3,bg1,bg2 = colors(rng)
    variant = seed % 7
    angle = rng.randint(-7, 7)
    dx = rng.randint(-18, 18)
    dy = rng.randint(-12, 12)
    scale = 0.93 + rng.random()*0.12
    art = family_art(fam, rng, c1, c2, c3, variant)
    display_name = esc(name)
    display_cat = esc(category)
    display_cat_upper = esc((category or "").upper())
    code = hashlib.md5(f"{pid}-{name}".encode("utf-8")).hexdigest()[:6].upper()

    deco = []
    for i in range(4):
        cx = rng.randint(45,595); cy = rng.randint(45,400); rr = rng.randint(10,42)
        deco.append(circle(cx,cy,rr,["rgba(255,255,255,.18)","rgba(255,246,225,.22)","rgba(70,50,38,.07)"][i%3]))

    return f'''<?xml version="1.0" encoding="UTF-8"?>
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 640 520" role="img" aria-label="{display_name}">
<defs>
  <linearGradient id="bg" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{bg1}"/><stop offset="1" stop-color="{bg2}"/></linearGradient>
  <linearGradient id="obj" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{c1}"/><stop offset="1" stop-color="{c2}"/></linearGradient>
  <linearGradient id="obj2" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{c3}"/><stop offset="1" stop-color="{c1}"/></linearGradient>
  <linearGradient id="screen" x1="0" y1="0" x2="1" y2="1"><stop stop-color="{c3}"/><stop offset="1" stop-color="{c2}"/></linearGradient>
  <linearGradient id="glass" x1="0" y1="0" x2="1" y2="1"><stop stop-color="#fff" stop-opacity=".9"/><stop offset="1" stop-color="{c3}" stop-opacity=".82"/></linearGradient>
  <filter id="shadow" x="-40%" y="-40%" width="180%" height="180%"><feDropShadow dx="0" dy="22" stdDeviation="18" flood-color="#35271e" flood-opacity=".22"/></filter>
</defs>
<rect width="640" height="520" rx="42" fill="url(#bg)"/>
{''.join(deco)}
<path d="M0 430 C160 {370+rng.randint(-30,30)} 410 {455+rng.randint(-30,30)} 640 382 V520 H0Z" fill="rgba(255,255,255,.16)"/>
<g filter="url(#shadow)" transform="translate({dx} {dy}) rotate({angle} 320 245) scale({scale:.3f})">
{art}
</g>
<g>
  <rect x="28" y="422" width="505" height="72" rx="22" fill="rgba(255,253,249,.84)"/>
  <text x="48" y="448" font-family="Arial,Helvetica,sans-serif" font-size="12" font-weight="700" fill="#806b5d" letter-spacing="1">{display_cat_upper}</text>
  <text x="48" y="478" font-family="Arial,Helvetica,sans-serif" font-size="21" font-weight="800" fill="#332c27">{display_name}</text>
</g>
<g transform="translate(555 28)">
  <circle cx="28" cy="28" r="28" fill="rgba(255,253,249,.7)"/>
  <text x="28" y="35" text-anchor="middle" font-family="Georgia,serif" font-size="20" fill="#7a5c49">&#10022;</text>
</g>
<text x="604" y="493" text-anchor="end" font-family="Arial,Helvetica,sans-serif" font-size="10" font-weight="800" fill="rgba(62,48,39,.55)">LS-{pid}-{code}</text>
</svg>'''

count = 0
with src.open("r", encoding="utf-8", errors="replace") as f:
    for raw in f:
        row = raw.strip("\r\n ")
        if not row or "|" not in row:
            continue
        parts = row.split("|", 2)
        if len(parts) != 3:
            continue
        try:
            pid = int(parts[0].strip())
        except ValueError:
            continue
        name = parts[1].strip()
        category = parts[2].strip()
        if not name:
            continue
        (out / f"product-{pid}.svg").write_text(make_svg(pid, name, category), encoding="utf-8")
        count += 1

if not count:
    print("ERROR: no products were read from", src)
    sys.exit(3)

print(f"Generated {count} unique local product SVG files in {out}")
