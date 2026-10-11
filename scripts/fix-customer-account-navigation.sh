#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

PRODUCT_VIEW="src/Ecommerce.Web/Views/Product/Index.cshtml"
ACCOUNT_CONTROLLER="src/Ecommerce.Web/Controllers/AccountController.cs"

if [ ! -f "$PRODUCT_VIEW" ]; then
    echo "ERROR: $PRODUCT_VIEW not found."
    exit 1
fi

if [ ! -f "$ACCOUNT_CONTROLLER" ]; then
    echo "ERROR: $ACCOUNT_CONTROLLER not found."
    exit 1
fi

cp "$PRODUCT_VIEW" "$PRODUCT_VIEW.before-account-nav-fix.bak"
cp "$ACCOUNT_CONTROLLER" "$ACCOUNT_CONTROLLER.before-account-nav-fix.bak"

python3 - <<'PY'
from pathlib import Path
import re

view = Path("src/Ecommerce.Web/Views/Product/Index.cshtml")
s = view.read_text(encoding="utf-8")

conditional = '''@if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")
            {
                <a href="/Customer/Dashboard">Account</a>
            }
            else if (Session["UserId"] != null && Convert.ToString(Session["Role"]) == "Admin")
            {
                <a href="/Admin/Dashboard">Admin</a>
            }
            else
            {
                <a href="/Account/CustomerLogin">Account</a>
            }'''

pattern = r'<a\b[^>]*href=["\']/Account/CustomerLogin["\'][^>]*>\s*(?:My\s+)?Account\s*</a>'

if re.search(pattern, s, flags=re.I):
    s = re.sub(pattern, conditional, s, count=1, flags=re.I)
    print("Updated Product/Index.cshtml Account navigation.")
elif 'href="/Customer/Dashboard">Account</a>' in s:
    print("Product/Index.cshtml already appears patched.")
else:
    raise SystemExit(
        "ERROR: Could not find the Account login link in Product/Index.cshtml. "
        "No view changes were made."
    )

view.write_text(s, encoding="utf-8")

controller = Path("src/Ecommerce.Web/Controllers/AccountController.cs")
c = controller.read_text(encoding="utf-8")

old_customer = '''[HttpGet]
        public ActionResult CustomerLogin() { return View(new LoginViewModel()); }'''

new_customer = '''[HttpGet]
        public ActionResult CustomerLogin()
        {
            if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")
            {
                return RedirectToAction("Dashboard", "Customer");
            }

            return View(new LoginViewModel());
        }'''

if old_customer in c:
    c = c.replace(old_customer, new_customer, 1)
    print("Added logged-in customer redirect to AccountController.")
elif 'Session["CustomerId"] != null' in c and 'RedirectToAction("Dashboard", "Customer")' in c:
    print("CustomerLogin redirect already appears patched.")
else:
    customer_pattern = (
        r'\[HttpGet\]\s*'
        r'public\s+ActionResult\s+CustomerLogin\s*\(\s*\)\s*'
        r'\{\s*return\s+View\s*\(\s*new\s+LoginViewModel\s*\(\s*\)\s*\)\s*;\s*\}'
    )

    if re.search(customer_pattern, c, flags=re.S):
        c = re.sub(customer_pattern, new_customer, c, count=1, flags=re.S)
        print("Added logged-in customer redirect to AccountController.")
    else:
        raise SystemExit(
            "ERROR: Could not safely patch CustomerLogin GET action. "
            "Controller was left unchanged."
        )

if not re.search(r'^\s*using\s+System\s*;', c, flags=re.M):
    c = 'using System;\n' + c
    print("Added using System;")

controller.write_text(c, encoding="utf-8")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop web =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Fix applied."
echo
echo "Test 1:"
echo "  Login as customer -> Customer Dashboard -> Shop -> Account"
echo "  Expected: /Customer/Dashboard"
echo
echo "Test 2:"
echo "  Logout -> Home/Landing -> Shop -> Account"
echo "  Expected: /Account/CustomerLogin"
