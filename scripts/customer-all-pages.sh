#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

# Keep the working customer dashboard UI and only repair its destinations.
dash = Path("src/Ecommerce.Web/Views/Customer/Dashboard.cshtml")
if dash.exists():
    s = dash.read_text()

    replacements = {
        'href="/Customer/Dashboard"><span class="ls-nav-icon">□</span>Orders':
            'href="/Customer/Orders"><span class="ls-nav-icon">□</span>Orders',
        'href="#"><span class="ls-nav-icon">♡</span>Wishlist':
            'href="/Customer/Wishlist"><span class="ls-nav-icon">♡</span>Wishlist',
        'href="#"><span class="ls-nav-icon">⌖</span>Addresses':
            'href="/Customer/Addresses"><span class="ls-nav-icon">⌖</span>Addresses',
        '<a href="#"><div class="ls-qicon">⌖</div><div><strong>Addresses</strong>':
            '<a href="/Customer/Addresses"><div class="ls-qicon">⌖</div><div><strong>Addresses</strong>',
        '<a href="#">View all →</a>':
            '<a href="/Customer/Orders">View all →</a>'
    }

    for old, new in replacements.items():
        s = s.replace(old, new)

    dash.write_text(s)
    print("Customer dashboard links updated.")

# Add the new Razor/CSS files to the old-style project as Content.
p = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = p.read_text()

items = [
    "Views/Customer/Orders.cshtml",
    "Views/Customer/Wishlist.cshtml",
    "Views/Customer/Addresses.cshtml",
    "Views/Customer/_CustomerSidebar.cshtml",
    "Views/Customer/_CustomerTopbar.cshtml",
    "Content/customer-pages.css"
]

for item in items:
    slash = item
    back = item.replace("/", "\\")
    if slash in s or back in s:
        continue

    marker = '<Content Include="Content/site.css" />'
    if marker in s:
        s = s.replace(
            marker,
            '<Content Include="' + item + '" />' + "\n    " + marker,
            1
        )
    else:
        marker = '<Content Include="Content\\site.css" />'
        if marker in s:
            s = s.replace(
                marker,
                '<Content Include="' + back + '" />' + "\n    " + marker,
                1
            )
        else:
            raise SystemExit("Could not find Content/site.css entry in Ecommerce.Web.csproj")

p.write_text(s)
print("Customer page content entries updated.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo
echo "== Building customer workspace =="
$DOCKER compose build web

echo
echo "== Starting web =="
$DOCKER compose up -d web

echo
$DOCKER compose ps

echo
echo "Customer pages:"
echo "  Dashboard  http://localhost:${WEB_PORT:-8040}/Customer/Dashboard"
echo "  Shop       http://localhost:${WEB_PORT:-8040}/Product"
echo "  Orders     http://localhost:${WEB_PORT:-8040}/Customer/Orders"
echo "  Cart       http://localhost:${WEB_PORT:-8040}/Cart"
echo "  Wishlist   http://localhost:${WEB_PORT:-8040}/Customer/Wishlist"
echo "  Addresses  http://localhost:${WEB_PORT:-8040}/Customer/Addresses"
echo
echo "Hard refresh with Ctrl+Shift+R."
