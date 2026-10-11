#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo "== Rebuilding Add/Edit Product UI =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Open:"
echo "  http://localhost:${WEB_PORT:-8040}/Admin/ProductCreate"
echo
echo "Hard refresh with Ctrl+Shift+R."
