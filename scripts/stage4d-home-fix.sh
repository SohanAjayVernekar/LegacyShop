#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "Rebuilding self-contained home page..."
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps
echo
echo "Open: http://localhost:${WEB_PORT:-8040}"
echo "Hard refresh: Ctrl+Shift+R"
