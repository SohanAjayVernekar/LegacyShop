#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path
import re

views = [
    Path("src/Ecommerce.Web/Views/Product/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Product/Detail.cshtml"),
    Path("src/Ecommerce.Web/Views/Cart/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Customer/Wishlist.cshtml"),
]

css_tag = '<link rel="stylesheet" href="/Content/product-3d-visuals.css" />'
js_tag  = '<script src="/Scripts/product-3d-visuals.js"></script>'

def remove_old_photo_tags(s):
    lines = []
    for line in s.splitlines():
        if "product-photo-unique.css" in line:
            continue
        if "product-photo-unique.js" in line:
            continue
        lines.append(line)
    return "\n".join(lines) + ("\n" if s.endswith("\n") else "")

for p in views:
    if not p.exists():
        print("Skipping missing:", p)
        continue

    s = p.read_text(encoding="utf-8")
    s = remove_old_photo_tags(s)

    if "product-3d-visuals.css" not in s:
        if "</style>" in s:
            pos = s.rfind("</style>") + len("</style>")
            s = s[:pos] + "\n" + css_tag + "\n" + s[pos:]
        else:
            links = list(re.finditer(r'<link\b[^>]*>', s, re.I))
            if links:
                pos = links[-1].end()
                s = s[:pos] + "\n" + css_tag + "\n" + s[pos:]
            else:
                starts = [x for x in (s.find("<div"), s.find("<main"), s.find("<header")) if x >= 0]
                if starts:
                    pos = min(starts)
                    s = s[:pos] + css_tag + "\n" + s[pos:]
                else:
                    s = css_tag + "\n" + s

    if "product-3d-visuals.js" not in s:
        s += "\n" + js_tag + "\n"

    p.write_text(s, encoding="utf-8")
    print("Patched:", p)

proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
if not proj.exists():
    raise SystemExit("ERROR: Ecommerce.Web.csproj not found.")

s = proj.read_text(encoding="utf-8")

new_assets = [
    r'Content\product-3d-visuals.css',
    r'Scripts\product-3d-visuals.js',
]

for asset in new_assets:
    slash = asset.replace("\\", "/")
    if asset in s or slash in s:
        continue

    close = s.rfind("</ItemGroup>")
    if close < 0:
        raise SystemExit("ERROR: Could not locate an ItemGroup in csproj.")

    s = s[:close] + '    <Content Include="' + asset + '" />\n' + s[close:]

proj.write_text(s, encoding="utf-8")
print("Added 3D CSS/JS assets to Ecommerce.Web.csproj.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Building LegacyShop Option B 3D product visuals =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Open:"
echo "  http://localhost:${WEB_PORT:-8040}/Product"
echo
echo "Hard refresh with Ctrl+Shift+R."
