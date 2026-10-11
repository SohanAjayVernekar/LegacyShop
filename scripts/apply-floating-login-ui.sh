#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "== Rebuilding floating login pages =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Customer: http://localhost:${WEB_PORT:-8040}/Account/CustomerLogin"
echo "Admin:    http://localhost:${WEB_PORT:-8040}/Account/AdminLogin"
echo
echo "Hard refresh both pages with Ctrl+Shift+R."
