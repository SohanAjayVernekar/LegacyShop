#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

CORE_PROJ="src/Ecommerce.Core/Ecommerce.Core.csproj"
WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"
ACCOUNT="src/Ecommerce.Web/Controllers/AccountController.cs"
LOGIN="src/Ecommerce.Web/Views/Account/CustomerLogin.cshtml"

for f in "$CORE_PROJ" "$WEB_PROJ" "$ACCOUNT" "$LOGIN"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing $f"
        exit 1
    fi
done

cp "$ACCOUNT" "$ACCOUNT.before-register-page.bak"
cp "$LOGIN" "$LOGIN.before-register-link.bak"

python3 - <<'PY'
from pathlib import Path
import re

core = Path("src/Ecommerce.Core/Ecommerce.Core.csproj")
s = core.read_text(encoding="utf-8")
entry = r'ViewModels\RegisterViewModel.cs'
if entry not in s and entry.replace("\\", "/") not in s:
    groups = list(re.finditer(r'</ItemGroup>', s, re.I))
    if not groups:
        raise SystemExit("ERROR: No ItemGroup found in Core csproj.")
    pos = groups[0].start()
    s = s[:pos] + '    <Compile Include="' + entry + '" />\n' + s[pos:]
    core.write_text(s, encoding="utf-8")
    print("Added RegisterViewModel to Core project.")

web = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")
s = web.read_text(encoding="utf-8")
entry = r'Views\Account\Register.cshtml'
if entry not in s and entry.replace("\\", "/") not in s:
    insert_at = None
    for m in re.finditer(r'<ItemGroup>(.*?)</ItemGroup>', s, re.I | re.S):
        block = m.group(1)
        if 'Views\\Account\\CustomerLogin.cshtml' in block or 'Views/Account/CustomerLogin.cshtml' in block:
            insert_at = m.end() - len('</ItemGroup>')
            break
    if insert_at is None:
        groups = list(re.finditer(r'</ItemGroup>', s, re.I))
        if not groups:
            raise SystemExit("ERROR: No ItemGroup found in Web csproj.")
        insert_at = groups[-1].start()
    s = s[:insert_at] + '    <Content Include="' + entry + '" />\n' + s[insert_at:]
    web.write_text(s, encoding="utf-8")
    print("Added Register.cshtml to Web project.")

p = Path("src/Ecommerce.Web/Controllers/AccountController.cs")
c = p.read_text(encoding="utf-8")

for u in [
    "using System;",
    "using System.Linq;",
    "using System.Security.Cryptography;",
    "using System.Text;",
    "using Ecommerce.Core.Entities;",
    "using Ecommerce.Data;",
]:
    if not re.search(r'^\s*' + re.escape(u) + r'\s*$', c, re.M):
        c = u + "\n" + c

if "ActionResult Register(" not in c:
    marker = re.search(r'\s*\[HttpGet\]\s*public\s+ActionResult\s+AdminLogin\s*\(\s*\)', c, re.S)
    if not marker:
        raise SystemExit("ERROR: Could not find AdminLogin GET action.")

    methods = (
        '        [HttpGet]\\n'
        '        public ActionResult Register()\\n'
        '        {\\n'
        '            if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")\\n'
        '            {\\n'
        '                return RedirectToAction("Dashboard", "Customer");\\n'
        '            }\\n\\n'
        '            return View(new RegisterViewModel());\\n'
        '        }\\n\\n'
        '        [HttpPost, ValidateAntiForgeryToken]\\n'
        '        public ActionResult Register(RegisterViewModel model)\\n'
        '        {\\n'
        '            if (!ModelState.IsValid) return View(model);\\n\\n'
        '            var email = (model.Email ?? "").Trim().ToLowerInvariant();\\n'
        '            var fullName = (model.FullName ?? "").Trim();\\n'
        '            var phone = string.IsNullOrWhiteSpace(model.Phone) ? null : model.Phone.Trim();\\n\\n'
        '            using (var db = new LegacyEcommerceContext())\\n'
        '            {\\n'
        '                if (db.AppUsers.Any(x => x.Email == email) || db.Customers.Any(x => x.Email == email))\\n'
        '                {\\n'
        '                    ModelState.AddModelError("Email", "An account with this email already exists.");\\n'
        '                    return View(model);\\n'
        '                }\\n\\n'
        '                using (var transaction = db.Database.BeginTransaction())\\n'
        '                {\\n'
        '                    try\\n'
        '                    {\\n'
        '                        var customer = new Customer\\n'
        '                        {\\n'
        '                            Email = email, FullName = fullName, Phone = phone,\\n'
        '                            CreatedAt = DateTime.UtcNow, IsActive = true\\n'
        '                        };\\n'
        '                        db.Customers.Add(customer);\\n'
        '                        db.SaveChanges();\\n\\n'
        '                        var user = new AppUser\\n'
        '                        {\\n'
        '                            Email = email,\\n'
        '                            PasswordHash = HashRegistrationPassword(model.Password),\\n'
        '                            Role = "Customer", DisplayName = fullName,\\n'
        '                            CustomerId = customer.Id, IsActive = true, CreatedAt = DateTime.UtcNow\\n'
        '                        };\\n'
        '                        db.AppUsers.Add(user);\\n'
        '                        db.SaveChanges();\\n'
        '                        transaction.Commit();\\n\\n'
        '                        Session["UserId"] = user.Id;\\n'
        '                        Session["CustomerId"] = customer.Id;\\n'
        '                        Session["Role"] = "Customer";\\n'
        '                        Session["DisplayName"] = fullName;\\n\\n'
        '                        return RedirectToAction("Dashboard", "Customer");\\n'
        '                    }\\n'
        '                    catch\\n'
        '                    {\\n'
        '                        transaction.Rollback();\\n'
        '                        ModelState.AddModelError("", "We could not create the account. Please try again.");\\n'
        '                        return View(model);\\n'
        '                    }\\n'
        '                }\\n'
        '            }\\n'
        '        }\\n\\n'
    )
    c = c[:marker.start()] + "\n" + methods + c[marker.start():]
    print("Added Register GET/POST actions.")

if "private static string HashRegistrationPassword" not in c:
    idx = c.rfind("\n    }")
    if idx < 0:
        raise SystemExit("ERROR: Could not locate controller closing brace.")
    helper = (
        '        private static string HashRegistrationPassword(string password)\\n'
        '        {\\n'
        '            using (var sha = SHA256.Create())\\n'
        '            {\\n'
        '                var bytes = Encoding.Unicode.GetBytes("LegacyShop|" + password);\\n'
        '                var hash = sha.ComputeHash(bytes);\\n'
        '                var sb = new StringBuilder(hash.Length * 2);\\n'
        '                foreach (var b in hash) sb.Append(b.ToString("X2"));\\n'
        '                return sb.ToString();\\n'
        '            }\\n'
        '        }\\n\\n'
    )
    c = c[:idx] + "\n" + helper + c[idx:]
    print("Added registration password hash helper.")

p.write_text(c, encoding="utf-8")

login = Path("src/Ecommerce.Web/Views/Account/CustomerLogin.cshtml")
s = login.read_text(encoding="utf-8")

if '/Account/Register' not in s:
    cta = (
        '                <div class="fl-switch-login">\\n'
        '                    New to LegacyShop? <a href="/Account/Register">Create account &rarr;</a>\\n'
        '                </div>\\n\\n'
    )
    m = re.search(r'\s*<div\s+class=["\']fl-switch-login["\']>\s*Store\s+administrator\?', s, re.I)
    if m:
        s = s[:m.start()] + "\n" + cta + s[m.start():]
    else:
        marker = s.rfind('</div>\\n            </div>\\n        </section>')
        if marker < 0:
            raise SystemExit("ERROR: Could not safely insert Create Account link into CustomerLogin.")
        s = s[:marker] + cta + s[marker:]
    login.write_text(s, encoding="utf-8")
    print("Added Create Account link to Customer Login.")
PY

DOCKER="docker"
if ! docker info >/dev/null 2>&1; then
    DOCKER="sudo docker"
fi

echo
echo "== Rebuilding LegacyShop with customer registration =="
$DOCKER compose build web
$DOCKER compose up -d web
$DOCKER compose ps web

echo
echo "Done."
echo "Login:    http://localhost:${WEB_PORT:-8040}/Account/CustomerLogin"
echo "Register: http://localhost:${WEB_PORT:-8040}/Account/Register"
