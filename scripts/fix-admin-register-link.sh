#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

LOGIN="src/Ecommerce.Web/Views/Account/AdminLogin.cshtml"

if [ ! -f "$LOGIN" ]; then
    echo "ERROR: Missing $LOGIN"
    exit 1
fi

cp "$LOGIN" "$LOGIN.before-admin-register-link-fix.bak"

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Views/Account/AdminLogin.cshtml")
s = p.read_text(encoding="utf-8")

if "/Account/AdminRegister" in s:
    print("Admin register link already exists.")
else:
    block = """
<style>
    .admin-register-cta{
        margin:14px auto 0;
        max-width:440px;
        padding:12px 14px;
        text-align:center;
        border:1px solid #dfd1c4;
        border-radius:14px;
        background:rgba(255,253,249,.88);
        color:#80756b;
        font-size:9px;
    }
    .admin-register-cta a{
        color:#8b593b;
        font-weight:900;
        text-decoration:none;
    }
</style>

<div class="admin-register-cta">
    Need another administrator?
    <a href="/Account/AdminRegister">Create admin account &rarr;</a>
</div>
"""
    s = s.rstrip() + "\n\n" + block.strip() + "\n"
    p.write_text(s, encoding="utf-8")
    print("Added Create Admin Account link to Admin Login.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Admin login:    http://localhost:${WEB_PORT:-8040}/Account/AdminLogin"
echo "Admin register: http://localhost:${WEB_PORT:-8040}/Account/AdminRegister"
