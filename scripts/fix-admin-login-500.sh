#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

WEB_CONFIG="src/Ecommerce.Web/Web.config"

if [ ! -f "$WEB_CONFIG" ]; then
  echo "ERROR: $WEB_CONFIG not found."
  exit 1
fi

cp "$WEB_CONFIG" "$WEB_CONFIG.before-machinekey-fix.bak"

python3 - <<'PY'
from pathlib import Path
import re
import secrets

p = Path("src/Ecommerce.Web/Web.config")
s = p.read_text(encoding="utf-8")

# The POST /Account/AdminLogin failures are consistent with anti-forgery /
# machine-key decryption becoming unstable under Mono when AutoGenerate keys
# cannot be persisted to /var/www/.mono/registry/CurrentUser.
#
# Keep an already-explicit machineKey unchanged.
if re.search(r"<machineKey\b", s, re.I):
    print("Web.config already has an explicit <machineKey>; leaving it unchanged.")
else:
    validation_key = secrets.token_hex(64).upper()   # 128 hex chars
    decryption_key = secrets.token_hex(32).upper()   # 64 hex chars

    machine_key = (
        '    <machineKey '
        'validationKey="' + validation_key + '" '
        'decryptionKey="' + decryption_key + '" '
        'validation="SHA1" '
        'decryption="AES" />\n'
    )

    m = re.search(r"<system\.web(?:\s[^>]*)?>", s, re.I)
    if not m:
        raise SystemExit("ERROR: Could not find <system.web> in Web.config.")

    insert_at = m.end()
    s = s[:insert_at] + "\n" + machine_key + s[insert_at:]
    p.write_text(s, encoding="utf-8")
    print("Added a stable explicit <machineKey> to Web.config.")

print("Backup:", str(p) + ".before-machinekey-fix.bak")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop web container =="
$DOCKER compose build web
$DOCKER compose up -d web

echo
echo "== Web status =="
$DOCKER compose ps web

echo
echo "== Checking machine-key warning after restart =="
sleep 2
$DOCKER exec legacyshop-web sh -lc \
  "tail -n 80 /var/log/apache2/error.log 2>/dev/null | grep -E 'MachineKey|machineKey|encryption keys|SecurityException|UnauthorizedAccessException' || true"

echo
echo "Fix applied."
echo "Open a NEW tab for:"
echo "  http://localhost:${WEB_PORT:-8040}/Account/AdminLogin"
echo
echo "Do not reuse the old login tab/token. Hard refresh with Ctrl+Shift+R."
