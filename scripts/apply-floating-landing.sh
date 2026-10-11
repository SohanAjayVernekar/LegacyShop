#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = p.read_text()

item = "Content/landing-floating.css"
item_back = item.replace("/", "\\")

if item not in s and item_back not in s:
    marker = '<Content Include="Content/site.css" />'

    if marker in s:
        s = s.replace(
            marker,
            '<Content Include="Content/landing-floating.css" />\n    ' + marker,
            1
        )
    else:
        marker = '<Content Include="Content\\site.css" />'
        if marker in s:
            s = s.replace(
                marker,
                '<Content Include="Content\\landing-floating.css" />\n    ' + marker,
                1
            )
        else:
            raise SystemExit("Could not find site.css entry in Ecommerce.Web.csproj")

    p.write_text(s)
    print("Added landing-floating.css to Ecommerce.Web.csproj")
else:
    print("landing-floating.css already present.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo
echo "== Building Floating Marketplace landing page =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Open: http://localhost:${WEB_PORT:-8040}"
echo "Hard refresh: Ctrl+Shift+R"
