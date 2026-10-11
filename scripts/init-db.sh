#!/usr/bin/env bash
set -euo pipefail

if [[ ! -f .env ]]; then
  echo "Missing .env. Run: cp .env.example .env and edit the password."
  exit 1
fi

set -a
source .env
set +a

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "Waiting for SQL Server..."
for i in $(seq 1 60); do
  if $DOCKER exec legacyshop-sql /opt/mssql-tools18/bin/sqlcmd       -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -Q "SELECT 1" >/dev/null 2>&1; then
    break
  fi
  sleep 2
done

echo "Applying schema..."
$DOCKER exec -i legacyshop-sql /opt/mssql-tools18/bin/sqlcmd   -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b < sql/001_schema.sql

echo "Applying seed data..."
$DOCKER exec -i legacyshop-sql /opt/mssql-tools18/bin/sqlcmd   -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b < sql/002_seed.sql

echo "Database initialized."
