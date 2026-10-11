# LegacyShop Stage 3 — Functional MVP

This patch upgrades Stage 2 from static/demo redirects into a functional database-backed MVP.

## Implemented now

- EF6 runtime access to the existing SQL Server database
- repository + service layers
- SQL-backed product catalog and product details
- real credential validation against `AppUsers`
- separate Customer and Admin roles
- role-protected dashboards
- session cart
- checkout creates `Orders` + `OrderLines`
- customer dashboard reads real orders
- admin dashboard reads real totals
- admin product list/add/edit
- admin order list
- anti-forgery on POST forms

### Demo credentials

Customer:
- `customer@legacyshop.local`
- `Customer@123`

Admin:
- `admin@legacyshop.local`
- `Admin@123`

## Important scope note

For tonight's Ubuntu-only MVP, authentication is a database-backed session-role implementation,
not ASP.NET Identity/OWIN yet. Password hashing is a simple salted SHA-256 demo mechanism.
Do not use this auth mechanism in production.

EF6 is connected to the database with a hand-authored DbContext mapped to the existing
database schema. The database remains the source of truth, but this patch does not yet include
a designer-generated EDMX.

## Install

Copy/extract this ZIP over the current project:

```bash
cd ~/Downloads/LegacyShop_ZeroToMVP
unzip -o ~/Downloads/LegacyShop_Stage3_Functional_MVP.zip -d .
chmod +x scripts/stage3-run.sh
./scripts/stage3-run.sh
```

Then open:

```text
http://localhost:8040
```

Test in this order:

1. `/Product`
2. customer login
3. add product to cart
4. checkout
5. customer dashboard
6. logout
7. admin login
8. admin products
9. add/edit product
10. admin orders

If build fails, paste:

```bash
docker compose build web
```

output.

If the container runs but the browser shows HTTP 500, paste:

```bash
docker exec legacyshop-web tail -n 120 /var/log/apache2/legacyshop-error.log
```
