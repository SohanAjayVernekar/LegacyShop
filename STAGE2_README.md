# Stage 2 — MVC 5 UI shell

This stage gives you:
- the 4-project solution,
- MVC 5.2.9 + Razor,
- a real coded landing page,
- customer login,
- admin login,
- customer dashboard,
- admin dashboard,
- a Linux web container running Mono + XSP4.

Login POSTs are deliberately temporary demo redirects in this stage.
Real authentication, EF6 repositories, products, cart and orders come next.

## Merge into your existing folder

Copy/overwrite these Stage 2 files into your existing `LegacyShop_ZeroToMVP` folder.

Then:

```bash
chmod +x scripts/*.sh
```

Keep your existing `.env` with the working SQL password and port 14330.
Add this line if it is missing:

```text
WEB_PORT=8080
```

Then:

```bash
./scripts/stage2-run.sh
```

Open:

```text
http://localhost:8080
```

Useful routes:
- `/`
- `/Account/CustomerLogin`
- `/Account/AdminLogin`
- `/Customer/Dashboard`
- `/Admin/Dashboard`

If build/start fails:

```bash
docker compose logs --tail=150 web
```

and paste the output into ChatGPT.
