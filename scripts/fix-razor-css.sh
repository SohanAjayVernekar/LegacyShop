#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Views/Home/Index.cshtml")
s = p.read_text()

s = s.replace("@keyframes", "@@keyframes")
s = s.replace("@media", "@@media")

s = s.replace("@@@keyframes", "@@keyframes")
s = s.replace("@@@media", "@@media")

p.write_text(s)
print("Escaped Razor CSS @-rules in Home/Index.cshtml")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "Rebuilding..."
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Open: http://localhost:${WEB_PORT:-8040}"
echo "Hard refresh: Ctrl+Shift+R"
