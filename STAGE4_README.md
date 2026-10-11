# LegacyShop Stage 4 — Animated 3D + 2000 Products

Adds:

- total catalog size of 2000 SQL Server products
- 24-product pagination so the storefront remains usable
- interactive CSS 3D chair model on the landing page
- mouse-parallax floating cards
- floating orbit animation
- burst particles when clicking product cards/buttons
- glitter/twinkle particles
- animated hero gradient
- scrolling collection ticker
- animated product cards
- animated product detail presentation
- reduced-motion accessibility fallback

No external 3D library is required. The 3D showcase is built with CSS 3D transforms,
so it works inside the existing ASP.NET MVC 5 / Razor application.

## Apply

```bash
cd ~/Downloads/LegacyShop_ZeroToMVP
unzip -o ~/Downloads/LegacyShop_Stage4_Animated_3D_2000.zip -d .
chmod +x scripts/stage4-animated-3d-2000.sh
./scripts/stage4-animated-3d-2000.sh
```

Then open:

```text
http://localhost:8040
```

Hard refresh:

```text
Ctrl + Shift + R
```

The SQL script is repeat-safe: it only adds enough products to bring the catalog
up to 2000 total products.
