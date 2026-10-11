#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "Missing .env. Create it first: cp .env.example .env"
  exit 1
fi

echo "Building legacy MVC web container..."
docker compose build web

echo "Starting database + web..."
docker compose up -d db web

echo
docker compose ps
echo
echo "LegacyShop should be available at:"
echo "  http://localhost:${WEB_PORT:-8080}"
echo
echo "If it does not open, run:"
echo "  docker compose logs --tail=120 web"
