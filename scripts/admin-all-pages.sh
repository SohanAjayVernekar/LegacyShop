#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

# Update Dashboard sidebar links without replacing the working dashboard UI.
dash = Path("src/Ecommerce.Web/Views/Admin/Dashboard.cshtml")
if dash.exists():
    s = dash.read_text()
    replacements = {
        'href="/Admin/Products"><span class="ls-nav-icon">◫</span>Categories':
            'href="/Admin/Categories"><span class="ls-nav-icon">◫</span>Categories',
        'href="#"><span class="ls-nav-icon">◎</span>Customers':
            'href="/Admin/Customers"><span class="ls-nav-icon">◎</span>Customers',
        'href="/Admin/Products"><span class="ls-nav-icon">≡</span>Inventory':
            'href="/Admin/Inventory"><span class="ls-nav-icon">≡</span>Inventory',
        'href="#"><span class="ls-nav-icon">↗</span>Reports':
            'href="/Admin/Reports"><span class="ls-nav-icon">↗</span>Reports',
        'href="#"><span class="ls-nav-icon">⚙</span>Settings':
            'href="/Admin/Settings"><span class="ls-nav-icon">⚙</span>Settings'
    }
    for old, new in replacements.items():
        s = s.replace(old, new)
    dash.write_text(s)
    print("Dashboard sidebar links updated.")

# Add new Content items to the old-style csproj for completeness.
p = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = p.read_text()

items = [
    "Views/Admin/Categories.cshtml",
    "Views/Admin/Customers.cshtml",
    "Views/Admin/Inventory.cshtml",
    "Views/Admin/Reports.cshtml",
    "Views/Admin/Settings.cshtml",
    "Views/Admin/_AdminSidebar.cshtml",
    "Views/Admin/_AdminTopbar.cshtml",
    "Content/admin-pages.css"
]

for item in items:
    slash = item
    back = item.replace("/", "\\")
    if slash in s or back in s:
        continue

    marker = '<Content Include="Content/site.css" />'
    if marker in s:
        s = s.replace(marker, '<Content Include="' + item + '" />' + "\n    " + marker, 1)
    else:
        marker = '<Content Include="Content\\site.css" />'
        if marker in s:
            s = s.replace(marker, '<Content Include="' + back + '" />' + "\n    " + marker, 1)
        else:
            raise SystemExit("Could not find site.css Content entry in Ecommerce.Web.csproj")

p.write_text(s)
print("Project content entries updated.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo
echo "== Building admin workspace =="
$DOCKER compose build web

echo
echo "== Starting web =="
$DOCKER compose up -d web

echo
$DOCKER compose ps

echo
echo "Admin pages:"
echo "  Dashboard  http://localhost:${WEB_PORT:-8040}/Admin/Dashboard"
echo "  Products   http://localhost:${WEB_PORT:-8040}/Admin/Products"
echo "  Categories http://localhost:${WEB_PORT:-8040}/Admin/Categories"
echo "  Orders     http://localhost:${WEB_PORT:-8040}/Admin/Orders"
echo "  Customers  http://localhost:${WEB_PORT:-8040}/Admin/Customers"
echo "  Inventory  http://localhost:${WEB_PORT:-8040}/Admin/Inventory"
echo "  Reports    http://localhost:${WEB_PORT:-8040}/Admin/Reports"
echo "  Settings   http://localhost:${WEB_PORT:-8040}/Admin/Settings"
echo
echo "Hard refresh with Ctrl+Shift+R."
