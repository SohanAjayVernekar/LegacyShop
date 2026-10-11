#!/usr/bin/env bash
set -euo pipefail
cd "$(dirname "$0")/.."

CORE_PROJ="src/Ecommerce.Core/Ecommerce.Core.csproj"
WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"
ACCOUNT="src/Ecommerce.Web/Controllers/AccountController.cs"
ADMIN_LOGIN="src/Ecommerce.Web/Views/Account/AdminLogin.cshtml"

for f in "$CORE_PROJ" "$WEB_PROJ" "$ACCOUNT" "$ADMIN_LOGIN"; do
  [ -f "$f" ] || { echo "ERROR: Missing $f"; exit 1; }
done

cp "$ACCOUNT" "$ACCOUNT.before-admin-register.bak"
cp "$ADMIN_LOGIN" "$ADMIN_LOGIN.before-admin-register-link.bak"

python3 - <<'PY'
from pathlib import Path
import re

core=Path("src/Ecommerce.Core/Ecommerce.Core.csproj")
web=Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
account=Path("src/Ecommerce.Web/Controllers/AccountController.cs")
login=Path("src/Ecommerce.Web/Views/Account/AdminLogin.cshtml")

s=core.read_text()
if "AdminRegisterViewModel.cs" not in s:
    g=next((m for m in re.finditer(r"<ItemGroup>(.*?)</ItemGroup>",s,re.S|re.I) if "<Compile Include=" in m.group(1)),None)
    if not g: raise SystemExit("ERROR: Core Compile ItemGroup not found")
    pos=g.end()-len("</ItemGroup>")
    s=s[:pos]+'    <Compile Include="ViewModels\\AdminRegisterViewModel.cs" />\n'+s[pos:]
    core.write_text(s)
    print("Added AdminRegisterViewModel.")

s=web.read_text()
if "AdminRegister.cshtml" not in s:
    g=next((m for m in re.finditer(r"<ItemGroup>(.*?)</ItemGroup>",s,re.S|re.I) if "AdminLogin.cshtml" in m.group(1)),None)
    if not g: raise SystemExit("ERROR: Web view ItemGroup not found")
    pos=g.end()-len("</ItemGroup>")
    s=s[:pos]+'    <Content Include="Views\\Account\\AdminRegister.cshtml" />\n'+s[pos:]
    web.write_text(s)
    print("Added AdminRegister view.")

c=account.read_text()

if any("\\n" in line for line in c.splitlines()):
    raise SystemExit("ERROR: AccountController contains literal \\n text. Run the customer registration compile repair first.")

for u in reversed([
    "using System;",
    "using System.Linq;",
    "using System.Security.Cryptography;",
    "using System.Text;",
    "using Ecommerce.Core.Entities;",
    "using Ecommerce.Data;",
]):
    if not re.search(r"^\s*"+re.escape(u)+r"\s*$",c,re.M):
        c=u+"\n"+c

if "ActionResult AdminRegister(" not in c:
    methods = '''
        [HttpGet]
        public ActionResult AdminRegister()
        {
            if (Session["UserId"] != null && Convert.ToString(Session["Role"]) == "Admin")
            {
                return RedirectToAction("Dashboard", "Admin");
            }

            return View(new AdminRegisterViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult AdminRegister(AdminRegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var email = (model.Email ?? "").Trim().ToLowerInvariant();
            var fullName = (model.FullName ?? "").Trim();

            using (var db = new LegacyEcommerceContext())
            {
                if (db.AppUsers.Any(x => x.Email == email))
                {
                    ModelState.AddModelError("Email", "An account with this email already exists.");
                    return View(model);
                }

                var user = new AppUser
                {
                    Email = email,
                    PasswordHash = HashAdminRegistrationPassword(model.Password),
                    Role = "Admin",
                    DisplayName = fullName,
                    CustomerId = null,
                    IsActive = true,
                    CreatedAt = DateTime.UtcNow
                };

                db.AppUsers.Add(user);
                db.SaveChanges();

                Session["UserId"] = user.Id;
                Session["CustomerId"] = null;
                Session["Role"] = "Admin";
                Session["DisplayName"] = fullName;

                return RedirectToAction("Dashboard", "Admin");
            }
        }

'''
    marker=re.search(r"\s*(?:\[HttpGet\]\s*)?public\s+ActionResult\s+Logout\s*\(",c,re.S)
    if marker:
        c=c[:marker.start()]+"\n"+methods+c[marker.start():]
    else:
        pos=c.rfind("\n    }")
        if pos<0: raise SystemExit("ERROR: Controller closing brace not found")
        c=c[:pos]+"\n"+methods+c[pos:]
    print("Added AdminRegister actions.")

if "private static string HashAdminRegistrationPassword" not in c:
    helper = '''
        private static string HashAdminRegistrationPassword(string password)
        {
            using (var sha = SHA256.Create())
            {
                var bytes = Encoding.Unicode.GetBytes("LegacyShop|" + password);
                var hash = sha.ComputeHash(bytes);
                var sb = new StringBuilder(hash.Length * 2);

                foreach (var b in hash)
                {
                    sb.Append(b.ToString("X2"));
                }

                return sb.ToString();
            }
        }

'''
    pos=c.rfind("\n    }")
    if pos<0: raise SystemExit("ERROR: Controller closing brace not found")
    c=c[:pos]+"\n"+helper+c[pos:]
    print("Added admin password helper.")

account.write_text(c)

s=login.read_text()
if "/Account/AdminRegister" not in s:
    cta='''<div class="fl-switch-login" style="margin-top:12px;text-align:center">
    Need another administrator? <a href="/Account/AdminRegister">Create admin account &rarr;</a>
</div>
'''
    pos=s.rfind("</body>")
    if pos<0: raise SystemExit("ERROR: </body> not found in AdminLogin")
    s=s[:pos]+cta+s[pos:]
    login.write_text(s)
    print("Added Create Admin Account link.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then DOCKER="sudo docker"; fi

echo "== Rebuilding LegacyShop =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo "Done."
echo "Admin login:    http://localhost:${WEB_PORT:-8040}/Account/AdminLogin"
echo "Admin register: http://localhost:${WEB_PORT:-8040}/Account/AdminRegister"
