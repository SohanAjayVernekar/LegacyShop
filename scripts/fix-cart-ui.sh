#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = p.read_text()

item = "Content/cart-page.css"

if item not in s and item.replace("/", "\\") not in s:
    marker = '<Content Include="Content/site.css" />'

    if marker in s:
        s = s.replace(
            marker,
            '<Content Include="Content/cart-page.css" />\n    ' + marker,
            1
        )
    else:
        marker = '<Content Include="Content\\site.css" />'

        if marker in s:
            s = s.replace(
                marker,
                '<Content Include="Content\\cart-page.css" />\n    ' + marker,
                1
            )
        else:
            raise SystemExit("Could not find site.css entry in Ecommerce.Web.csproj")

    p.write_text(s)
    print("Added cart-page.css to web project.")
else:
    print("cart-page.css already listed.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo
echo "== Rebuilding cart page =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Cart: http://localhost:${WEB_PORT:-8040}/Cart"
echo "Hard refresh with Ctrl+Shift+R"
