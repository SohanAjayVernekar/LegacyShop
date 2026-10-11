#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"
[ -f "$WEB_PROJ" ] || { echo "ERROR: $WEB_PROJ not found"; exit 1; }

python3 - <<'PY'
from pathlib import Path
import re

proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = proj.read_text(encoding="utf-8")

for asset in [r'Content\product-moving-3d.css', r'Scripts\product-moving-3d.js']:
    if asset in s or asset.replace("\\","/") in s:
        continue

    groups = list(re.finditer(r'</ItemGroup>', s, re.I))
    if not groups:
        raise SystemExit("ERROR: No ItemGroup in Web csproj")

    pos = groups[-1].start()
    s = s[:pos] + '    <Content Include="' + asset + '" />\n' + s[pos:]

proj.write_text(s, encoding="utf-8")

views = [
    Path("src/Ecommerce.Web/Views/Product/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Product/Detail.cshtml"),
    Path("src/Ecommerce.Web/Views/Cart/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Customer/Wishlist.cshtml"),
]

css = '<link rel="stylesheet" href="/Content/product-moving-3d.css" />'
js  = '<script src="/Scripts/product-moving-3d.js"></script>'

for p in views:
    if not p.exists():
        continue

    v = p.read_text(encoding="utf-8")

    if "product-moving-3d.css" not in v:
        v += "\n" + css + "\n"

    if "product-moving-3d.js" not in v:
        v += "\n" + js + "\n"

    p.write_text(v, encoding="utf-8")
    print("Updated:", p)

print("Moving 3D layer installed.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then DOCKER="sudo docker"; fi

echo
echo "== Rebuilding LegacyShop moving 3D visuals =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh: Ctrl+Shift+R"
