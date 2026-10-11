#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

if [[ ! -f .env ]]; then
  echo "Missing .env"
  exit 1
fi

set -a
source .env
set +a

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = p.read_text()

if 'stage4b.css' not in s:
    if '<Content Include="Content/site.css" />' in s:
        s = s.replace(
            '<Content Include="Content/site.css" />',
            '<Content Include="Content/site.css" />\n    <Content Include="Content/stage4b.css" />'
        )
    elif '<Content Include="Content\\site.css" />' in s:
        s = s.replace(
            '<Content Include="Content\\site.css" />',
            '<Content Include="Content\\site.css" />\n    <Content Include="Content\\stage4b.css" />'
        )
    else:
        raise SystemExit("Could not find site.css Content line in Ecommerce.Web.csproj")
    p.write_text(s)
    print("Added stage4b.css to Ecommerce.Web.csproj")
else:
    print("stage4b.css already listed.")
PY

echo
echo "== Applying broad marketplace catalog =="
$DOCKER exec -i legacyshop-sql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U sa \
  -P "$MSSQL_SA_PASSWORD" \
  -C -b < sql/005_all_product_types.sql

echo
echo "== Rebuilding web =="
$DOCKER compose build web

echo
echo "== Starting web =="
$DOCKER compose up -d web

echo
$DOCKER compose ps

echo
echo "Open: http://localhost:${WEB_PORT:-8040}"
echo "Then press Ctrl+Shift+R."
