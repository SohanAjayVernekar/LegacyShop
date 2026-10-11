# Stage 4C UI correction

This patch fixes the screenshot problems:
- hero content is properly centered and not clipped
- the 3D product is clearly visible
- the marquee has its own styled band instead of raw text
- multiple floating product objects surround the 3D phone
- department section is more visual and compact
- 24 broad marketplace departments are shown immediately
- burst/glitter effects remain enabled

Apply:

```bash
cd ~/Downloads/LegacyShop_ZeroToMVP
unzip -o ~/Downloads/LegacyShop_Stage4C_UI_Fix.zip -d .
chmod +x scripts/stage4c-ui-fix.sh
./scripts/stage4c-ui-fix.sh
```

Then hard refresh:

```text
Ctrl + Shift + R
```
