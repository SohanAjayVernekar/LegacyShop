#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

views = [
    Path("src/Ecommerce.Web/Views/Product/Index.cshtml"),
    Path("src/Ecommerce.Web/Views/Product/Detail.cshtml"),
]

css_tag = '<link rel="stylesheet" href="/Content/product-photo-unique.css" />'
js_tag = '<script src="/Scripts/product-photo-unique.js"></script>'

for p in views:
    if not p.exists():
        print("Skipping missing:", p)
        continue

    s = p.read_text(encoding="utf-8")

    if "product-photo-unique.css" not in s:
        # Place the photo override after other page-specific CSS.
        if "</style>" in s:
            pos = s.rfind("</style>") + len("</style>")
            s = s[:pos] + "\n" + css_tag + "\n" + s[pos:]
        else:
            links = []
            start = 0
            while True:
                idx = s.find("<link ", start)
                if idx < 0:
                    break
                links.append(idx)
                start = idx + 1

            if links:
                idx = links[-1]
                end = s.find(">", idx)
                if end >= 0:
                    end += 1
                    s = s[:end] + "\n" + css_tag + "\n" + s[end:]
                else:
                    s = css_tag + "\n" + s
            else:
                candidates = [
                    x for x in (
                        s.find("<div"),
                        s.find("<header"),
                        s.find("<main")
                    )
                    if x >= 0
                ]

                if candidates:
                    pos = min(candidates)
                    s = s[:pos] + css_tag + "\n" + s[pos:]
                else:
                    s += "\n" + css_tag + "\n"

    if "product-photo-unique.js" not in s:
        s += "\n" + js_tag + "\n"

    p.write_text(s, encoding="utf-8")
    print("Patched:", p)

proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
if not proj.exists():
    raise SystemExit("Could not find src/Ecommerce.Web/Ecommerce.Web.csproj")

s = proj.read_text(encoding="utf-8")

items = [
    ("Content/product-photo-unique.css", "Content\\product-photo-unique.css"),
    ("Scripts/product-photo-unique.js", "Scripts\\product-photo-unique.js"),
]

for slash, back in items:
    if slash in s or back in s:
        continue

    marker_forward = '<Content Include="Content/site.css" />'
    marker_back = '<Content Include="Content\\site.css" />'

    if marker_forward in s:
        s = s.replace(
            marker_forward,
            '<Content Include="' + slash + '" />\n    ' + marker_forward,
            1
        )
    elif marker_back in s:
        s = s.replace(
            marker_back,
            '<Content Include="' + back + '" />\n    ' + marker_back,
            1
        )
    else:
        # Last-resort old-style csproj insertion.
        close = s.rfind("</ItemGroup>")
        if close < 0:
            raise SystemExit("Could not add product image assets to csproj.")

        s = (
            s[:close]
            + '    <Content Include="' + slash + '" />\n'
            + s[close:]
        )

proj.write_text(s, encoding="utf-8")
print("Project asset entries updated.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop with unique product photos =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Open: http://localhost:${WEB_PORT:-8040}/Product"
echo "Hard refresh with Ctrl+Shift+R."
