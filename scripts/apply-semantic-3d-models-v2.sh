#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

CSS="src/Ecommerce.Web/Content/product-3d-visuals.css"
JS="src/Ecommerce.Web/Scripts/product-3d-visuals.js"

if [ ! -f "$CSS" ] || [ ! -f "$JS" ]; then
  echo "ERROR: V2 3D model files were not extracted correctly."
  exit 1
fi

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "== Rebuilding semantic 3D model V2 =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh with Ctrl+Shift+R."
