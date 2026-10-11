# XSP crash fix

The old `xsp4` executable is incompatible with the Mono runtime shipped in the
Ubuntu 22.04 container. This patch replaces XSP with Apache + mod_mono while
keeping the same ASP.NET MVC 5 / System.Web application.

From your `LegacyShop_ZeroToMVP` directory:

```bash
unzip -o LegacyShop_XSP_Fix.zip -d .
docker compose rm -sf web
docker compose build --no-cache web
docker compose up -d web
docker compose ps
docker compose logs --tail=100 web
```

Keep your existing `.env`:

```text
MSSQL_PORT=14330
WEB_PORT=8040
```

Then open:

```text
http://localhost:8040
```

If Apache starts but the site gives HTTP 500:

```bash
docker exec legacyshop-web cat /var/log/apache2/legacyshop-error.log
```

Paste that output into ChatGPT.
