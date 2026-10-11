#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Views/Home/Index.cshtml")
s = p.read_text()

css_marker = "/* === HOME HEADER FOOTER RESTORE === */"
header_marker = '<header class="ls-home-header">'
footer_marker = '<footer class="ls-home-footer">'

css = r"""
/* === HOME HEADER FOOTER RESTORE === */
.ls-home-header{
    height:76px;
    padding:0 6vw;
    display:flex;
    align-items:center;
    justify-content:space-between;
    gap:24px;
    background:rgba(255,253,249,.96);
    border-bottom:1px solid #e5dbcf;
    position:sticky;
    top:0;
    z-index:100;
    backdrop-filter:blur(14px);
}
.ls-home-brand{
    display:flex;
    align-items:center;
    gap:10px;
    font-size:22px;
    font-weight:800;
    letter-spacing:-.6px;
    white-space:nowrap;
}
.ls-home-brand-mark{
    width:35px;
    height:35px;
    border-radius:50%;
    display:inline-flex;
    align-items:center;
    justify-content:center;
    background:#27231f;
    color:#fff;
    font-family:Georgia,serif;
    font-weight:500;
}
.ls-home-brand-accent{color:#a86943}
.ls-home-nav{
    display:flex;
    align-items:center;
    justify-content:flex-end;
    gap:22px;
    font-size:12px;
    font-weight:700;
}
.ls-home-nav>a{
    color:#5f574f;
    transition:.2s;
}
.ls-home-nav>a:hover{color:#a86943}
.ls-home-login{
    display:inline-flex!important;
    align-items:center;
    justify-content:center;
    min-width:116px;
    padding:11px 18px;
    border-radius:999px;
    background:#27231f;
    color:#fff!important;
    box-shadow:0 8px 22px rgba(39,35,31,.13);
}
.ls-home-admin{
    display:inline-flex!important;
    align-items:center;
    justify-content:center;
    padding:10px 15px;
    border-radius:999px;
    border:1px solid #d7cabd;
    background:#fffaf4;
}
.ls-home-footer{
    padding:46px 7vw 34px;
    background:#211e1a;
    color:#eee6dc;
    display:grid;
    grid-template-columns:1.3fr .8fr auto;
    gap:40px;
    align-items:end;
}
.ls-home-footer .ls-home-brand{color:#fff}
.ls-home-footer .ls-home-brand-mark{
    background:#efe3d6;
    color:#27231f;
}
.ls-home-footer-copy p{
    max-width:430px;
    margin:14px 0 0;
    color:#aaa096;
    font-size:11px;
    line-height:1.7;
}
.ls-home-footer-links{
    display:grid;
    gap:8px;
    font-size:11px;
}
.ls-home-footer-links a{color:#d7cdc4}
.ls-home-footer-meta{
    font-size:10px;
    color:#8e857d;
    white-space:nowrap;
}
@media(max-width:850px){
    .ls-home-nav>a:not(.ls-home-login):not(.ls-home-admin){display:none}
    .ls-home-footer{grid-template-columns:1fr}
}
@media(max-width:520px){
    .ls-home-header{padding:0 4vw}
    .ls-home-brand{font-size:18px}
    .ls-home-login{min-width:auto;padding:10px 13px}
    .ls-home-admin{display:none!important}
}
"""

header = r"""
<header class="ls-home-header">
    <a class="ls-home-brand" href="/">
        <span class="ls-home-brand-mark">L</span>
        <span>Legacy<span class="ls-home-brand-accent">Shop</span></span>
    </a>

    <nav class="ls-home-nav">
        <a href="/Product">Shop</a>
        <a href="#departments">Departments</a>
        <a href="/Customer/Dashboard">My Account</a>
        <a class="ls-home-login burst-trigger" href="/Account/CustomerLogin">Customer Login</a>
        <a class="ls-home-admin" href="/Account/AdminLogin">Admin</a>
    </nav>
</header>
"""

footer = r"""
<footer class="ls-home-footer">
    <div class="ls-home-footer-copy">
        <a class="ls-home-brand" href="/">
            <span class="ls-home-brand-mark">L</span>
            <span>Legacy<span class="ls-home-brand-accent">Shop</span></span>
        </a>
        <p>
            A full marketplace experience with 2000 products, customer checkout,
            order tracking and administrator tools.
        </p>
    </div>

    <div class="ls-home-footer-links">
        <a href="/Product">Shop products</a>
        <a href="/Account/CustomerLogin">Customer Login</a>
        <a href="/Account/AdminLogin">Admin Login</a>
    </div>

    <div class="ls-home-footer-meta">© 2026 LegacyShop</div>
</footer>
"""

if css_marker not in s:
    if "</style>" not in s:
        raise SystemExit("Could not find </style> in Home/Index.cshtml")
    s = s.replace("</style>", css + "\n</style>", 1)
    print("Added header/footer CSS.")
else:
    print("Header/footer CSS already present.")

if header_marker not in s:
    target = '<div class="ls-home">'
    if target not in s:
        raise SystemExit('Could not find <div class="ls-home">')
    s = s.replace(target, target + "\n" + header, 1)
    print("Added home header.")
else:
    print("Home header already present.")

if footer_marker not in s:
    pos = s.rfind("</div>")
    if pos == -1:
        raise SystemExit("Could not find final closing div.")
    s = s[:pos] + footer + "\n" + s[pos:]
    print("Added home footer.")
else:
    print("Home footer already present.")

# Razor escape CSS @media if needed
s = s.replace("@media", "@@media")
s = s.replace("@@@media", "@@media")

p.write_text(s)
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo
echo "Rebuilding LegacyShop..."
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Open: http://localhost:${WEB_PORT:-8040}"
echo "Hard refresh: Ctrl+Shift+R"
