#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

GEN_DIR="src/Ecommerce.Web/Content/generated-product-art"
PRODUCT_LIST="/tmp/legacyshop-products.psv"

[ -f ".env" ] || { echo "ERROR: .env not found"; exit 1; }
[ -f "tools/generate_product_assets.py" ] || { echo "ERROR: generator missing"; exit 1; }

set -a
source .env
set +a

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then DOCKER="sudo docker"; fi

SQL_CONTAINER="$($DOCKER compose ps -q sql 2>/dev/null || true)"
if [ -z "$SQL_CONTAINER" ]; then
    SQL_CONTAINER="$($DOCKER ps --filter name=legacyshop-sql --format '{{.ID}}' | head -n1)"
fi

[ -n "$SQL_CONTAINER" ] || { echo "ERROR: SQL container not running"; exit 1; }

echo "== Reading products =="
$DOCKER exec "$SQL_CONTAINER" /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -W -h -1 -s "|" \
  -Q "SET NOCOUNT ON; USE LegacyEcommerceDb;
      SELECT p.Id,
        REPLACE(REPLACE(REPLACE(p.Name, '|', ' '), CHAR(13), ' '), CHAR(10), ' '),
        REPLACE(REPLACE(REPLACE(ISNULL(c.Name,''), '|', ' '), CHAR(13), ' '), CHAR(10), ' ')
      FROM dbo.Products p
      LEFT JOIN dbo.Categories c ON c.Id=p.CategoryId
      WHERE p.IsActive=1
      ORDER BY p.Id;" > "$PRODUCT_LIST"

COUNT="$(grep -c '|' "$PRODUCT_LIST" || true)"
echo "Products found: $COUNT"
[ "$COUNT" -gt 0 ] || { echo "ERROR: no products found"; exit 1; }

echo "== Regenerating all product assets with valid XML =="
rm -rf "$GEN_DIR"
mkdir -p "$GEN_DIR"
python3 tools/generate_product_assets.py "$PRODUCT_LIST" "$GEN_DIR"

echo "== Validating every generated SVG =="
python3 - <<'PY'
from pathlib import Path
import xml.etree.ElementTree as ET
import sys

files = sorted(Path("src/Ecommerce.Web/Content/generated-product-art").glob("product-*.svg"))
bad = []

for p in files:
    try:
        ET.parse(str(p))
    except Exception as e:
        bad.append((p.name, str(e)))

if bad:
    print("INVALID SVG FILES:")
    for name, err in bad[:30]:
        print(" ", name, "->", err)
    sys.exit(1)

print("Validated", len(files), "SVG files successfully.")
PY

echo "== Rebuilding web =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "FIX COMPLETE."
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh: Ctrl+Shift+R"
