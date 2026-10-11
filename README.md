# LegacyShop — Moving 3D Blank Product Fix

The blank product cards were caused by a CSS conflict, not by your generated
product files.

`generated-product-assets.css` hides every direct child of the product-art
container except `.generated-product-image`.

The moving 3D script wraps that image inside:

`.ls-moving3d-stage`

so the older CSS immediately hid the entire 3D stage. That is why the beige
product boxes became empty after enabling moving 3D.

This patch adds a final compatibility stylesheet that keeps the 3D stage,
product image, moving light and depth layers visible.

## Apply

```bash
cd "$HOME/Documents/Intership Projects/Assignment 3/LegacyShop_ZeroToMVP"

unzip -o ~/Downloads/LegacyShop_Moving_3D_Blank_Fix.zip -d .

chmod +x scripts/fix-moving-3d-blank-products.sh

./scripts/fix-moving-3d-blank-products.sh
```

Then open:

`http://localhost:8040/Product`

and press:

`Ctrl + Shift + R`
