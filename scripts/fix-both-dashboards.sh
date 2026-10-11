#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "Rebuilding customer + admin dashboards..."
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Customer dashboard: http://localhost:${WEB_PORT:-8040}/Customer/Dashboard"
echo "Admin dashboard:    http://localhost:${WEB_PORT:-8040}/Admin/Dashboard"
echo "Hard refresh both pages with Ctrl+Shift+R"
