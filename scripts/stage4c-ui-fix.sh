#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = p.read_text()

if "stage4c.css" not in s:
    if '<Content Include="Content/stage4b.css" />' in s:
        s = s.replace(
            '<Content Include="Content/stage4b.css" />',
            '<Content Include="Content/stage4b.css" />\n    <Content Include="Content/stage4c.css" />'
        )
    elif '<Content Include="Content/site.css" />' in s:
        s = s.replace(
            '<Content Include="Content/site.css" />',
            '<Content Include="Content/site.css" />\n    <Content Include="Content/stage4c.css" />'
        )
    elif '<Content Include="Content\\site.css" />' in s:
        s = s.replace(
            '<Content Include="Content\\site.css" />',
            '<Content Include="Content\\site.css" />\n    <Content Include="Content\\stage4c.css" />'
        )
    else:
        raise SystemExit("Could not find CSS Content entry in Ecommerce.Web.csproj")

    p.write_text(s)
    print("Added stage4c.css to project.")
else:
    print("stage4c.css already present.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "== Rebuilding polished marketplace UI =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Open http://localhost:${WEB_PORT:-8040}"
echo "Hard refresh with Ctrl+Shift+R"
