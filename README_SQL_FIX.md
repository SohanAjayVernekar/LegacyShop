# Stage 4B SQL scope fix

The previous script used a SQL Server table variable (`@Templates`) across `GO`
batch separators. Table variables only exist inside the batch where they are
declared, so SQL Server reported:

`Must declare the table variable "@Templates".`

This version uses a temporary table named `#Templates`, which remains available
across the `GO` batches for the same sqlcmd connection.

Apply it:

```bash
cd ~/Downloads/LegacyShop_ZeroToMVP
unzip -o ~/Downloads/LegacyShop_Stage4B_SQL_Fix.zip -d .

set -a
source .env
set +a

docker exec -i legacyshop-sql /opt/mssql-tools18/bin/sqlcmd \
  -S localhost -U sa -P "$MSSQL_SA_PASSWORD" -C -b \
  < sql/005_all_product_types.sql
```

Then rebuild/restart the web app:

```bash
docker compose build web
docker compose up -d web
```
