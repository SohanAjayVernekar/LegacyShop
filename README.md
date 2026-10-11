# LegacyShop — Floating Add Product UI

This patch redesigns the Admin `Add Product` page and the existing `Edit Product`
page because both routes use the same `ProductEdit.cshtml` view.

It keeps the existing backend fields and save logic:
- Name
- Slug
- Category
- Price
- StockQuantity
- Description
- IsFeatured
- IsActive (edit only)
- Anti-forgery token

UI additions:
- same floating/curved LegacyShop admin style
- admin sidebar + topbar
- rounded glass form panel
- live product preview
- automatic slug helper while typing a new name
- animated floating preview card
- click burst on save/back buttons
- responsive layout

Apply:

```bash
cd ~/Downloads/LegacyShop_ZeroToMVP
unzip -o ~/Downloads/LegacyShop_Add_Product_Floating_UI.zip -d .
chmod +x scripts/apply-add-product-floating-ui.sh
./scripts/apply-add-product-floating-ui.sh
```

Open:

`http://localhost:8040/Admin/ProductCreate`
