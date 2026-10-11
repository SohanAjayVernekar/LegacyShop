#!/usr/bin/env bash
set -euo pipefail

cd "$(dirname "$0")/.."

ACCOUNT="src/Ecommerce.Web/Controllers/AccountController.cs"
ACCOUNT_BAK="${ACCOUNT}.before-register-page.bak"
LOGIN="src/Ecommerce.Web/Views/Account/CustomerLogin.cshtml"
LOGIN_BAK="${LOGIN}.before-register-link.bak"
CORE_PROJ="src/Ecommerce.Core/Ecommerce.Core.csproj"
WEB_PROJ="src/Ecommerce.Web/Ecommerce.Web.csproj"

for f in "$ACCOUNT" "$LOGIN" "$CORE_PROJ" "$WEB_PROJ"; do
    if [ ! -f "$f" ]; then
        echo "ERROR: Missing $f"
        exit 1
    fi
done

echo "== Repairing registration compile error =="

if [ -f "$ACCOUNT_BAK" ]; then
    cp "$ACCOUNT_BAK" "$ACCOUNT"
    echo "Restored clean AccountController backup."
fi

if [ -f "$LOGIN_BAK" ]; then
    cp "$LOGIN_BAK" "$LOGIN"
    echo "Restored clean CustomerLogin backup."
fi

python3 - <<'PY'
from pathlib import Path
import re

account = Path("src/Ecommerce.Web/Controllers/AccountController.cs")
login = Path("src/Ecommerce.Web/Views/Account/CustomerLogin.cshtml")
core_proj = Path("src/Ecommerce.Core/Ecommerce.Core.csproj")
web_proj = Path("src/Ecommerce.Web/Ecommerce.Web.csproj")

c = account.read_text(encoding="utf-8")

# If a backup was unavailable, remove the broken literal-\n blocks from the bad patch.
if "\\n" in c:
    start = c.find('[HttpGet]\\n        public ActionResult Register()')
    if start >= 0:
        line_start = c.rfind("\n", 0, start) + 1
        admin_pos = c.find("[HttpGet]", start + 1)
        if admin_pos >= 0:
            c = c[:line_start] + c[admin_pos:]

    start = c.find('private static string HashRegistrationPassword(string password)\\n')
    if start >= 0:
        line_start = c.rfind("\n", 0, start) + 1
        close = c.find("\n    }", start)
        if close >= 0:
            c = c[:line_start] + c[close:]

# Required namespaces.
required = [
    "using System;",
    "using System.Linq;",
    "using System.Security.Cryptography;",
    "using System.Text;",
    "using Ecommerce.Core.Entities;",
    "using Ecommerce.Data;",
]
for u in reversed(required):
    if not re.search(r'^\s*' + re.escape(u) + r'\s*$', c, re.M):
        c = u + "\n" + c

# Preserve/fix the "logged in customer -> dashboard" behavior.
if 'Session["CustomerId"] != null' not in c:
    pattern = re.compile(
        r'\[HttpGet\]\s*public\s+ActionResult\s+CustomerLogin\s*\(\s*\)\s*'
        r'\{\s*return\s+View\s*\(\s*new\s+LoginViewModel\s*\(\s*\)\s*\)\s*;\s*\}',
        re.S
    )
    replacement = '''[HttpGet]
        public ActionResult CustomerLogin()
        {
            if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")
            {
                return RedirectToAction("Dashboard", "Customer");
            }

            return View(new LoginViewModel());
        }'''
    c, _ = pattern.subn(replacement, c, count=1)

# Remove any valid registration methods/helper before adding a clean copy.
def remove_method(source, signature_regex):
    m = re.search(signature_regex, source, re.S)
    if not m:
        return source
    brace = source.find("{", m.start())
    if brace < 0:
        return source

    depth = 0
    in_string = False
    escaped = False
    i = brace

    while i < len(source):
        ch = source[i]
        if in_string:
            if escaped:
                escaped = False
            elif ch == "\\":
                escaped = True
            elif ch == '"':
                in_string = False
        else:
            if ch == '"':
                in_string = True
            elif ch == "{":
                depth += 1
            elif ch == "}":
                depth -= 1
                if depth == 0:
                    start = source.rfind("\n", 0, m.start()) + 1
                    end = i + 1
                    while end < len(source) and source[end] in " \t\r\n":
                        end += 1
                    return source[:start] + source[end:]
        i += 1

    return source

c = remove_method(
    c,
    r'\[HttpGet\]\s*public\s+ActionResult\s+Register\s*\(\s*\)'
)
c = remove_method(
    c,
    r'\[HttpPost\s*,\s*ValidateAntiForgeryToken\]\s*'
    r'public\s+ActionResult\s+Register\s*\(\s*RegisterViewModel\s+model\s*\)'
)
c = remove_method(
    c,
    r'private\s+static\s+string\s+HashRegistrationPassword\s*'
    r'\(\s*string\s+password\s*\)'
)

admin = re.search(
    r'\s*\[HttpGet\]\s*public\s+ActionResult\s+AdminLogin\s*\(\s*\)',
    c,
    re.S
)
if not admin:
    raise SystemExit("ERROR: Could not find AdminLogin action.")

register_methods = '''
        [HttpGet]
        public ActionResult Register()
        {
            if (Session["CustomerId"] != null && Convert.ToString(Session["Role"]) == "Customer")
            {
                return RedirectToAction("Dashboard", "Customer");
            }

            return View(new RegisterViewModel());
        }

        [HttpPost, ValidateAntiForgeryToken]
        public ActionResult Register(RegisterViewModel model)
        {
            if (!ModelState.IsValid)
            {
                return View(model);
            }

            var email = (model.Email ?? "").Trim().ToLowerInvariant();
            var fullName = (model.FullName ?? "").Trim();
            var phone = string.IsNullOrWhiteSpace(model.Phone) ? null : model.Phone.Trim();

            using (var db = new LegacyEcommerceContext())
            {
                if (db.AppUsers.Any(x => x.Email == email) ||
                    db.Customers.Any(x => x.Email == email))
                {
                    ModelState.AddModelError("Email", "An account with this email already exists.");
                    return View(model);
                }

                using (var transaction = db.Database.BeginTransaction())
                {
                    try
                    {
                        var customer = new Customer
                        {
                            Email = email,
                            FullName = fullName,
                            Phone = phone,
                            CreatedAt = DateTime.UtcNow,
                            IsActive = true
                        };

                        db.Customers.Add(customer);
                        db.SaveChanges();

                        var user = new AppUser
                        {
                            Email = email,
                            PasswordHash = HashRegistrationPassword(model.Password),
                            Role = "Customer",
                            DisplayName = fullName,
                            CustomerId = customer.Id,
                            IsActive = true,
                            CreatedAt = DateTime.UtcNow
                        };

                        db.AppUsers.Add(user);
                        db.SaveChanges();
                        transaction.Commit();

                        Session["UserId"] = user.Id;
                        Session["CustomerId"] = customer.Id;
                        Session["Role"] = "Customer";
                        Session["DisplayName"] = fullName;

                        return RedirectToAction("Dashboard", "Customer");
                    }
                    catch
                    {
                        transaction.Rollback();
                        ModelState.AddModelError("", "We could not create the account. Please try again.");
                        return View(model);
                    }
                }
            }
        }

'''

c = c[:admin.start()] + "\n" + register_methods + c[admin.start():]

controller_close = c.rfind("\n    }")
if controller_close < 0:
    raise SystemExit("ERROR: Could not locate controller closing brace.")

helper = '''
        private static string HashRegistrationPassword(string password)
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

c = c[:controller_close] + "\n" + helper + c[controller_close:]

# The broken script's exact symptom was literal backslash-n text.
bad = [(i + 1, line) for i, line in enumerate(c.splitlines()) if "\\n" in line]
if bad:
    raise SystemExit("ERROR: Literal \\\\n text is still present in AccountController.")

account.write_text(c, encoding="utf-8")
print("AccountController repaired with real line breaks.")

# Restore/add the Create Account link with real newlines.
s = login.read_text(encoding="utf-8")

broken_cta = (
    '                <div class="fl-switch-login">\\n'
    '                    New to LegacyShop? <a href="/Account/Register">Create account &rarr;</a>\\n'
    '                </div>\\n\\n'
)
s = s.replace(broken_cta, "")

if '/Account/Register' not in s:
    cta = '''                <div class="fl-switch-login">
                    New to LegacyShop? <a href="/Account/Register">Create account &rarr;</a>
                </div>

'''
    marker = re.search(
        r'\s*<div\s+class=["\']fl-switch-login["\']>\s*Store\s+administrator\?',
        s,
        re.I
    )
    if marker:
        s = s[:marker.start()] + "\n" + cta + s[marker.start():]
    else:
        # Add just before </body> if the exact footer class differs.
        pos = s.rfind("</body>")
        if pos < 0:
            raise SystemExit("ERROR: Could not find </body> in CustomerLogin.")
        s = s[:pos] + "\n" + cta + s[pos:]

login.write_text(s, encoding="utf-8")
print("CustomerLogin registration link repaired.")

# Core csproj: ensure RegisterViewModel is included once.
s = core_proj.read_text(encoding="utf-8")
if 'ViewModels\\RegisterViewModel.cs' not in s and 'ViewModels/RegisterViewModel.cs' not in s:
    group = None
    for m in re.finditer(r'<ItemGroup>(.*?)</ItemGroup>', s, re.I | re.S):
        if '<Compile Include=' in m.group(1):
            group = m
            break
    if not group:
        raise SystemExit("ERROR: Core Compile ItemGroup not found.")
    pos = group.end() - len("</ItemGroup>")
    s = s[:pos] + '    <Compile Include="ViewModels\\RegisterViewModel.cs" />\n' + s[pos:]
core_proj.write_text(s, encoding="utf-8")

# Web csproj: ensure Register view is included once.
s = web_proj.read_text(encoding="utf-8")
if 'Views\\Account\\Register.cshtml' not in s and 'Views/Account/Register.cshtml' not in s:
    group = None
    for m in re.finditer(r'<ItemGroup>(.*?)</ItemGroup>', s, re.I | re.S):
        if 'Views\\Account\\CustomerLogin.cshtml' in m.group(1) or 'Views/Account/CustomerLogin.cshtml' in m.group(1):
            group = m
            break
    if not group:
        raise SystemExit("ERROR: Web Content ItemGroup not found.")
    pos = group.end() - len("</ItemGroup>")
    s = s[:pos] + '    <Content Include="Views\\Account\\Register.cshtml" />\n' + s[pos:]
web_proj.write_text(s, encoding="utf-8")

print("Project entries verified.")
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
echo "Repair complete."
echo "Login:    http://localhost:${WEB_PORT:-8040}/Account/CustomerLogin"
echo "Register: http://localhost:${WEB_PORT:-8040}/Account/Register"
