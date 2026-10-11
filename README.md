# LegacyShop Admin Register Link Fix

The previous script successfully added the admin registration backend and view.
It failed only because `AdminLogin.cshtml` has no `</body>` tag.

Apply:

```bash
cd "$HOME/Documents/Intership Projects/Assignment 3/LegacyShop_ZeroToMVP"
unzip -o ~/Downloads/LegacyShop_Admin_Register_Link_Fix.zip -d .
chmod +x scripts/fix-admin-register-link.sh
./scripts/fix-admin-register-link.sh
```
