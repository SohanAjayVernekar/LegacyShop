#!/usr/bin/env bash
set -euo pipefail

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

echo "== Applying Stage 3 database patch =="
$DOCKER exec -i legacyshop-sql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b < sql/003_auth_and_demo.sql

echo
echo "== Rebuilding web app =="
$DOCKER compose rm -sf web || true
$DOCKER compose build --no-cache web
$DOCKER compose up -d web

echo
$DOCKER compose ps
echo
echo "Open: http://localhost:${WEB_PORT:-8040}"
echo "Customer: customer@legacyshop.local / Customer@123"
echo "Admin:    admin@legacyshop.local / Admin@123"
