#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

cat > /tmp/legacyshop-auth.css <<'CSS'

/* === AUTH PAGE RESTORE FIX === */
.auth-page{
    min-height:100vh;
    background:#fbf8f2;
}
.auth-header{
    min-height:78px;
    padding:0 6vw;
    display:flex;
    align-items:center;
    justify-content:space-between;
    background:#fffdf9;
    border-bottom:1px solid #e5dbcf;
}
.auth-header .brand{
    display:flex;
    align-items:center;
    gap:10px;
    font-weight:800;
    font-size:22px;
    letter-spacing:-.6px;
}
.auth-header .brand-mark{
    width:34px;
    height:34px;
    border-radius:50%;
    display:inline-flex;
    align-items:center;
    justify-content:center;
    background:#26231f;
    color:#fff;
    font-family:Georgia,serif;
    font-weight:500;
}
.auth-header .brand-accent{color:#a86943}
.auth-header .back-link{
    font-size:13px;
    color:#7d746a;
}
.auth-layout{
    min-height:calc(100vh - 78px);
    display:grid;
    grid-template-columns:1.04fr .96fr;
}
.auth-visual{
    position:relative;
    overflow:hidden;
    padding:7vh 6vw;
    color:#fff;
    background:
        radial-gradient(circle at 82% 68%,rgba(255,255,255,.12),transparent 25%),
        linear-gradient(135deg,#705747 0%,#302924 100%);
}
.admin-auth{
    background:
        radial-gradient(circle at 76% 72%,rgba(255,255,255,.09),transparent 27%),
        linear-gradient(135deg,#5c4b3e 0%,#28231f 100%);
}
.auth-copy{
    position:relative;
    z-index:4;
    max-width:590px;
}
.auth-copy .soft-badge{
    display:inline-flex;
    padding:8px 11px;
    border-radius:999px;
    border:1px solid rgba(255,255,255,.24);
    background:rgba(255,255,255,.12);
    color:#fff;
    font-size:9px;
    letter-spacing:1.8px;
    font-weight:800;
}
.auth-copy h1{
    font-family:Georgia,"Times New Roman",serif;
    font-size:58px;
    line-height:1.03;
    font-weight:400;
    letter-spacing:-2px;
    margin:18px 0;
}
.auth-copy>p{
    max-width:520px;
    color:#e6ddd5;
    font-size:16px;
    line-height:1.7;
}
.auth-benefits{
    display:grid;
    gap:17px;
    margin-top:34px;
}
.auth-benefits>div{
    display:flex;
    gap:13px;
    align-items:flex-start;
}
.auth-benefits>div>span{
    flex:0 0 30px;
    width:30px;
    height:30px;
    border:1px solid rgba(255,255,255,.32);
    border-radius:50%;
    display:flex;
    align-items:center;
    justify-content:center;
    font-size:11px;
}
.auth-benefits strong,
.auth-benefits small{
    display:block;
}
.auth-benefits strong{
    font-size:13px;
    margin-bottom:2px;
}
.auth-benefits small{
    font-size:11px;
    color:#cfc5bc;
}
.auth-room{
    position:absolute;
    left:8%;
    right:6%;
    bottom:-28px;
    height:39%;
    border-radius:120px 120px 0 0;
    background:#d8c4b0;
    opacity:.96;
}
.room-arch{
    position:absolute;
    right:70px;
    top:28px;
    width:170px;
    height:225px;
    border-radius:90px 90px 0 0;
    background:#f0e4d7;
}
.room-shelf{
    position:absolute;
    right:52px;
    top:160px;
    width:210px;
    height:7px;
    background:#705545;
}
.room-chair{
    position:absolute;
    left:90px;
    bottom:60px;
    width:180px;
    height:180px;
}
.room-chair-back{
    position:absolute;
    left:28px;
    top:10px;
    width:120px;
    height:115px;
    background:#9c7156;
    border-radius:60px 60px 16px 16px;
}
.room-chair-seat{
    position:absolute;
    left:15px;
    top:110px;
    width:148px;
    height:50px;
    background:#b18365;
    border-radius:18px;
}
.room-chair-leg{
    position:absolute;
    bottom:0;
    width:8px;
    height:44px;
    background:#5c4437;
}
.room-chair-leg.leg-a{left:35px}
.room-chair-leg.leg-b{right:30px}
.room-table{
    position:absolute;
    left:290px;
    bottom:55px;
    width:145px;
    height:44px;
    background:#6f5141;
    border-radius:50%;
}
.room-vase{
    position:absolute;
    left:342px;
    bottom:91px;
    width:42px;
    height:66px;
    border-radius:44% 44% 30% 30%;
    background:#e8dfd4;
}
.admin-visual-card{
    position:absolute;
    left:8%;
    right:8%;
    bottom:-30px;
    height:35%;
    border-radius:28px 28px 0 0;
    background:#eee3d6;
    color:#26231f;
    padding:22px;
    box-shadow:0 -12px 50px rgba(0,0,0,.12);
}
.admin-mini-header{
    display:flex;
    justify-content:space-between;
    font-size:10px;
    letter-spacing:1.5px;
}
.admin-mini-grid{
    display:grid;
    grid-template-columns:repeat(4,1fr);
    gap:10px;
    margin:22px 0;
}
.admin-mini-grid i{
    height:48px;
    background:#dac9b8;
    border-radius:10px;
}
.admin-mini-chart{
    height:95px;
    display:flex;
    align-items:end;
    gap:12px;
    padding:0 20px;
    border-bottom:1px solid #cbb7a3;
}
.admin-mini-chart b{
    flex:1;
    background:#8c674f;
    border-radius:7px 7px 0 0;
}
.auth-form-side{
    display:flex;
    align-items:center;
    justify-content:center;
    padding:48px;
    background:#fbf8f2;
}
.auth-card{
    width:min(470px,90%);
    padding:44px;
    background:#fff;
    border:1px solid #e5dbcf;
    border-radius:24px;
    box-shadow:0 18px 55px rgba(58,44,30,.10);
}
.auth-card .section-kicker{
    display:inline-block;
    font-size:9px;
    letter-spacing:1.8px;
    font-weight:800;
    color:#a86943;
}
.auth-card h2{
    font-family:Georgia,"Times New Roman",serif;
    font-size:38px;
    font-weight:400;
    margin:7px 0 6px;
}
.auth-card .muted{
    color:#7d746a;
    font-size:13px;
    margin-bottom:22px;
}
.auth-card .field{
    margin-bottom:17px;
}
.auth-card .field label{
    display:block;
    margin-bottom:7px;
    font-size:11px;
    font-weight:800;
    color:#49423b;
}
.auth-card .field input{
    width:100%;
    padding:13px 14px;
    border:1px solid #dcd0c3;
    border-radius:10px;
    background:#fff;
    outline:none;
}
.auth-card .field input:focus{
    border-color:#a77a5c;
    box-shadow:0 0 0 3px rgba(167,122,92,.08);
}
.field-error{
    display:block;
    margin-top:5px;
    font-size:11px;
    color:#a3473b;
}
.validation-box{
    border:1px solid #e5b7ae;
    background:#fff0ec;
    color:#964a3d;
    border-radius:10px;
    padding:10px 12px;
    font-size:12px;
    margin:13px 0;
}
.form-meta{
    display:flex;
    justify-content:space-between;
    align-items:center;
    gap:15px;
    margin:4px 0 22px;
    font-size:11px;
}
.form-meta .remember{
    display:flex;
    align-items:center;
    gap:7px;
    color:#7d746a;
}
.form-meta .remember input{width:auto}
.form-meta a{
    color:#7f4f33;
    font-weight:700;
}
.auth-card .btn{
    display:inline-flex;
    align-items:center;
    justify-content:center;
    gap:10px;
    border:0;
    border-radius:10px;
    padding:14px 20px;
    font-weight:800;
    font-size:13px;
}
.auth-card .btn-dark{
    background:#26231f;
    color:#fff;
}
.auth-card .btn-block{width:100%}
.demo-credentials{
    margin-top:20px;
    padding-top:16px;
    border-top:1px solid #e5dbcf;
    display:grid;
    gap:4px;
}
.demo-credentials>span{
    font-size:9px;
    letter-spacing:1.4px;
    color:#7d746a;
}
.demo-credentials code{
    font-family:inherit;
    font-size:11px;
    color:#5e564e;
}
@media(max-width:900px){
    .auth-layout{grid-template-columns:1fr}
    .auth-visual{min-height:540px}
    .auth-form-side{padding:40px 20px}
}
@media(max-width:620px){
    .auth-copy h1{font-size:44px}
    .auth-card{padding:28px;width:100%}
    .auth-room{display:none}
    .admin-visual-card{display:none}
}

CSS

python3 - <<'PY'
from pathlib import Path

p = Path("src/Ecommerce.Web/Content/site.css")
s = p.read_text()
patch = Path("/tmp/legacyshop-auth.css").read_text()
marker = "/* === AUTH PAGE RESTORE FIX === */"

if marker not in s:
    if not s.endswith("\n"):
        s += "\n"
    s += "\n" + patch + "\n"
    p.write_text(s)
    print("Auth styles appended to site.css")
else:
    print("Auth styles already present; no duplicate added.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
  DOCKER="sudo docker"
fi

echo "Rebuilding web..."
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps

echo
echo "Open customer login: http://localhost:${WEB_PORT:-8040}/Account/CustomerLogin"
echo "Open admin login:    http://localhost:${WEB_PORT:-8040}/Account/AdminLogin"
echo "Hard refresh with Ctrl+Shift+R"
