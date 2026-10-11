#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"
INDEX="src/Ecommerce.Web/Views/Product/Index.cshtml"
DETAIL="src/Ecommerce.Web/Views/Product/Detail.cshtml"

[ -f "$WEB_PROJ" ] || { echo "ERROR: Missing $WEB_PROJ"; exit 1; }
[ -f "$INDEX" ] || { echo "ERROR: Missing $INDEX"; exit 1; }

python3 - <<'PY'
from pathlib import Path
import re

proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = proj.read_text(encoding="utf-8")

asset = r'Content\product-moving-3d-compat-fix.css'
if asset not in s and asset.replace("\\", "/") not in s:
    groups = list(re.finditer(r'</ItemGroup>', s, re.I))
    if not groups:
        raise SystemExit("ERROR: Could not find ItemGroup in Web csproj.")
    pos = groups[-1].start()
    s = s[:pos] + '    <Content Include="' + asset + '" />\n' + s[pos:]
    proj.write_text(s, encoding="utf-8")
    print("Added compatibility CSS to Web project.")

css = '<link rel="stylesheet" href="/Content/product-moving-3d-compat-fix.css" />'

views = [
    Path("src/Ecommerce.Web/Views/Product/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Product/Detail.cshtml"),
    Path("src/Ecommerce.Web/Views/Cart/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Customer/Wishlist.cshtml"),
]

for p in views:
    if not p.exists():
        continue

    v = p.read_text(encoding="utf-8")

    # Ensure the compatibility fix is the final stylesheet so it wins over
    # generated-product-assets.css and product-moving-3d.css.
    v = "\n".join(
        line for line in v.splitlines()
        if "product-moving-3d-compat-fix.css" not in line
    )
    v = v.rstrip() + "\n" + css + "\n"
    p.write_text(v, encoding="utf-8")
    print("Updated:", p)

print("3D blank-image compatibility fix installed.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "FIX COMPLETE."
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh: Ctrl+Shift+R"
