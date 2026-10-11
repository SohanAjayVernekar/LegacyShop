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

echo "== Expanding catalog to 2000 products =="
$DOCKER exec -i legacyshop-sql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost \
  -U sa \
  -P "$MSSQL_SA_PASSWORD" \
  -C \
  -b < sql/004_bulk_catalog_2000.sql

echo
echo "== Rebuilding animated LegacyShop web app =="
$DOCKER compose build web

echo
echo "== Restarting web =="
$DOCKER compose up -d web

echo
$DOCKER compose ps

echo
echo "LegacyShop:"
echo "  http://localhost:${WEB_PORT:-8040}"
echo
echo "Hard refresh browser with Ctrl+Shift+R."
