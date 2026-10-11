# Stage 4D — Self-contained home page fix

The screenshot showed that the page-specific stylesheet was not being applied.
This patch puts the complete home-page styling directly inside `Views/Home/Index.cshtml`.

That means:
- no second CSS file can 404
- the 3D phone is guaranteed to be styled
- the department cards are guaranteed to be styled
- the marquee is guaranteed to be styled
- the rest of the site is left alone

Apply:

```bash
cd ~/Downloads/LegacyShop_ZeroToMVP
unzip -o ~/Downloads/LegacyShop_Stage4D_Home_SelfContained_Fix.zip -d .
chmod +x scripts/stage4d-home-fix.sh
./scripts/stage4d-home-fix.sh
```

Then hard refresh with `Ctrl+Shift+R`.
