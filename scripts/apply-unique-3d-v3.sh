#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"

if [ ! -f "$WEB_PROJ" ]; then
    echo "ERROR: $WEB_PROJ not found."
    exit 1
fi

python3 - <<'PY'
from pathlib import Path
import re

proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = proj.read_text(encoding="utf-8")

assets = [
    r'Content\product-3d-unique-v3.css',
    r'Scripts\product-3d-unique-v3.js',
]

for asset in assets:
    if asset in s or asset.replace("\\", "/") in s:
        continue

    groups = list(re.finditer(r'</ItemGroup>', s, re.I))
    if not groups:
        raise SystemExit("ERROR: Could not find ItemGroup in Web csproj.")

    pos = groups[-1].start()
    s = s[:pos] + '    <Content Include="' + asset + '" />\n' + s[pos:]

proj.write_text(s, encoding="utf-8")

views = [
    Path("src/Ecommerce.Web/Views/Product/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Product/Detail.cshtml"),
    Path("src/Ecommerce.Web/Views/Cart/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Customer/Wishlist.cshtml"),
]

css = '<link rel="stylesheet" href="/Content/product-3d-unique-v3.css" />'
js  = '<script src="/Scripts/product-3d-unique-v3.js"></script>'

for p in views:
    if not p.exists():
        continue

    v = p.read_text(encoding="utf-8")

    if "product-3d-unique-v3.css" not in v:
        # Append is deliberate: V3 must load after V2.
        v += "\n" + css + "\n"

    if "product-3d-unique-v3.js" not in v:
        # Also load after V2's semantic model creation.
        v += "\n" + js + "\n"

    p.write_text(v, encoding="utf-8")
    print("Updated:", p)

print("V3 unique visual assets installed.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop unique 3D V3 =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh with Ctrl+Shift+R."
