#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

views = [
    "src/Ecommerce.Web/Views/Customer/Dashboard.cshtml",
    "src/Ecommerce.Web/Views/Customer/Orders.cshtml",
    "src/Ecommerce.Web/Views/Customer/Wishlist.cshtml",
    "src/Ecommerce.Web/Views/Customer/Addresses.cshtml",

    "src/Ecommerce.Web/Views/Admin/Dashboard.cshtml",
    "src/Ecommerce.Web/Views/Admin/Products.cshtml",
    "src/Ecommerce.Web/Views/Admin/Categories.cshtml",
    "src/Ecommerce.Web/Views/Admin/Orders.cshtml",
    "src/Ecommerce.Web/Views/Admin/Customers.cshtml",
    "src/Ecommerce.Web/Views/Admin/Inventory.cshtml",
    "src/Ecommerce.Web/Views/Admin/Reports.cshtml",
    "src/Ecommerce.Web/Views/Admin/Settings.cshtml",

    "src/Ecommerce.Web/Views/Cart/Index.cshtml",
    "src/Ecommerce.Web/Views/Checkout/Index.cshtml",
    "src/Ecommerce.Web/Views/Checkout/Success.cshtml",

    "src/Ecommerce.Web/Views/Product/Index.cshtml",
    "src/Ecommerce.Web/Views/Product/Detail.cshtml",
]

css_tag = '<link rel="stylesheet" href="/Content/floating-app-theme.css" />'
js_tag = '<script src="/Scripts/floating-app-theme.js"></script>'

for filename in views:
    p = Path(filename)

    if not p.exists():
        print("Skipping missing:", filename)
        continue

    s = p.read_text()

    if "floating-app-theme.css" in s:
        print("Already themed:", filename)
        continue

    # Put the override after the page's own style source whenever possible.
    if "</style>" in s:
        pos = s.rfind("</style>") + len("</style>")
        s = s[:pos] + "\n" + css_tag + "\n" + s[pos:]
    else:
        links = [i for i in range(len(s)) if s.startswith("<link ", i)]
        if links:
            start = links[-1]
            end = s.find(">", start)
            if end != -1:
                end += 1
                s = s[:end] + "\n" + css_tag + "\n" + s[end:]
            else:
                s = css_tag + "\n" + s
        else:
            # Safe fallback: insert before first rendered HTML tag.
            candidates = [x for x in [s.find("<div"), s.find("<header"), s.find("<main")] if x >= 0]
            if candidates:
                pos = min(candidates)
                s = s[:pos] + css_tag + "\n" + s[pos:]
            else:
                s = css_tag + "\n" + s

    s += "\n" + js_tag + "\n"
    p.write_text(s)
    print("Themed:", filename)

# Ensure old-style project includes both new assets.
proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = proj.read_text()

items = [
    ("Content/floating-app-theme.css", "Content\\floating-app-theme.css"),
    ("Scripts/floating-app-theme.js", "Scripts\\floating-app-theme.js"),
]

for slash, back in items:
    if slash in s or back in s:
        continue

    marker = '<Content Include="Content/site.css" />'
    if marker in s:
        s = s.replace(
            marker,
            '<Content Include="' + slash + '" />\n    ' + marker,
            1
        )
        continue

    marker = '<Content Include="Content\\site.css" />'
    if marker in s:
        s = s.replace(
            marker,
            '<Content Include="' + back + '" />\n    ' + marker,
            1
        )
        continue

    raise SystemExit("Could not find site.css Content entry in Ecommerce.Web.csproj")

proj.write_text(s)
print("Project asset entries updated.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Building floating UI for remaining pages =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Theme applied to:"
echo "  Product catalog + details"
echo "  Customer dashboard + Orders/Wishlist/Addresses"
echo "  Admin dashboard + all admin pages"
echo "  Cart"
echo "  Checkout + success"
echo
echo "Landing and login pages remain as your current floating versions."
echo "Hard refresh with Ctrl+Shift+R."
