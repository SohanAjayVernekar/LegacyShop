# LegacyShop — Zero to MVP starter

Target host: Ubuntu 26.04 LTS
No Windows, no VM.

Tonight's goal:
1. Confirm Mono works on Ubuntu 26.04.
2. Run SQL Server 2022 Express in Docker.
3. Create `LegacyEcommerceDb`.
4. Keep the 4-project architecture from the specification.
5. Add MVC 5 / Razor / EF6 incrementally after the environment is proven.

Important compatibility rule:
- Keep MVC actions synchronous.
- Do not use ASP.NET Core or EF Core.
- We will use EF6.
- EDMX/Database First tooling is the hardest Linux-only part and will be handled after the environment test.

## Step 1 — make scripts executable

```bash
cd LegacyShop_ZeroToMVP
chmod +x scripts/*.sh
```

## Step 2 — install/check host tools

```bash
./scripts/setup-host.sh
./scripts/check-env.sh
```

If the script adds your user to the docker group, either log out/in or use `sudo docker`
for the current session.

## Step 3 — start SQL Server Express

Copy the environment file:

```bash
cp .env.example .env
```

Edit `.env` and set a strong password.

Then:

```bash
docker compose up -d db
docker compose ps
docker compose logs --tail=50 db
```

Wait until SQL Server reports that it is ready for client connections.

## Step 4 — create the database

```bash
./scripts/init-db.sh
```

Expected database: `LegacyEcommerceDb`.

## Step 5 — verify the four-project layout

```text
src/
  Ecommerce.Core/
  Ecommerce.Data/
  Ecommerce.Services/
  Ecommerce.Web/
```

Do not start ASP.NET Core. We will create the legacy MVC 5 project files next after
the environment checks pass.
