#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"
GEN_DIR="src/Ecommerce.Web/Content/generated-product-art"
PRODUCT_LIST="/tmp/legacyshop-products.psv"

[ -f "$WEB_PROJ" ] || { echo "ERROR: $WEB_PROJ not found"; exit 1; }
[ -f ".env" ] || { echo "ERROR: .env not found in project root"; exit 1; }

set -a
source .env
set +a

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then DOCKER="sudo docker"; fi

SQL_CONTAINER="$($DOCKER compose ps -q sql 2>/dev/null || true)"
if [ -z "$SQL_CONTAINER" ]; then
    SQL_CONTAINER="$($DOCKER ps --filter name=legacyshop-sql --format '{{.ID}}' | head -n1)"
fi

if [ -z "$SQL_CONTAINER" ]; then
    echo "ERROR: SQL Server container is not running."
    echo "Run: docker compose up -d"
    exit 1
fi

echo "== Reading actual product rows from SQL Server =="

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
[ "$COUNT" -gt 0 ] || { echo "ERROR: No products returned."; exit 1; }

echo "== Generating a separate local SVG for every product =="
rm -rf "$GEN_DIR"
mkdir -p "$GEN_DIR"
python3 tools/generate_product_assets.py "$PRODUCT_LIST" "$GEN_DIR"

python3 - <<'PY'
from pathlib import Path
import re

proj=Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s=proj.read_text(encoding="utf-8")

s=re.sub(
    r'^\s*<Content Include="Content[\\/]+generated-product-art[\\/]+product-\d+\.svg"\s*/>\s*\n?',
    '',
    s,
    flags=re.M
)

for asset in [r'Content\generated-product-assets.css',r'Scripts\generated-product-assets.js']:
    if asset not in s and asset.replace("\\","/") not in s:
        groups=list(re.finditer(r'</ItemGroup>',s,re.I))
        if not groups: raise SystemExit("ERROR: No ItemGroup in Web csproj")
        pos=groups[-1].start()
        s=s[:pos]+'    <Content Include="'+asset+'" />\n'+s[pos:]

svgs=sorted(
    Path("src/Ecommerce.Web/Content/generated-product-art").glob("product-*.svg"),
    key=lambda p:int(p.stem.split("-")[1])
)
groups=list(re.finditer(r'</ItemGroup>',s,re.I))
pos=groups[-1].start()
lines=['    <Content Include="'+str(p.relative_to("src/Ecommerce.Web")).replace("/","\\")+'" />' for p in svgs]
s=s[:pos]+"\n".join(lines)+"\n"+s[pos:]
proj.write_text(s,encoding="utf-8")
print("Added",len(svgs),"generated product files to Ecommerce.Web.csproj")

views=[
    Path("src/Ecommerce.Web/Views/Product/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Product/Detail.cshtml"),
    Path("src/Ecommerce.Web/Views/Cart/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Customer/Wishlist.cshtml"),
]
old_tokens=[
    "product-photo-unique.css","product-photo-unique.js",
    "product-3d-visuals.css","product-3d-visuals.js",
    "product-3d-unique-v3.css","product-3d-unique-v3.js",
    "product-art-v4.css","product-art-v4.js",
    "generated-product-assets.css","generated-product-assets.js",
]
css='<link rel="stylesheet" href="/Content/generated-product-assets.css" />'
js='<script src="/Scripts/generated-product-assets.js"></script>'

for p in views:
    if not p.exists(): continue
    v=p.read_text(encoding="utf-8")
    v="\n".join(line for line in v.splitlines() if not any(tok in line for tok in old_tokens))
    v=v.rstrip()+"\n\n"+css+"\n"+js+"\n"
    p.write_text(v,encoding="utf-8")
    print("Updated:",p)
PY

echo "== Rebuilding LegacyShop web =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "COMPLETE."
echo "Unique local product assets generated: $COUNT"
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh: Ctrl+Shift+R"
