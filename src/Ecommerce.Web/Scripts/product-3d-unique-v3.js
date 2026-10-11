(function () {
    "use strict";

    function text(node) {
        return node ? (node.textContent || "").replace(/\s+/g, " ").trim() : "";
    }

    function hash(value) {
        var s = value || "LegacyShop";
        var h = 2166136261;
        for (var i = 0; i < s.length; i++) {
            h ^= s.charCodeAt(i);
            h += (h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24);
        }
        return Math.abs(h >>> 0);
    }

    function parseId(href) {
        var m = (href || "").match(/\/Product\/Detail\/(\d+)/i);
        return m ? parseInt(m[1], 10) : 0;
    }

    function productKey(card, name) {
        var link = card.querySelector('a[href*="/Product/Detail/"]');
        var id = link ? parseId(link.getAttribute("href")) : 0;
        return String(id || hash(name));
    }

    function clamp(v, min, max) {
        return Math.max(min, Math.min(max, v));
    }

    function applyFingerprint(host, card, name, category) {
        if (!host) return;

        var model = host.querySelector(".ls3d-model");
        var scene = host.querySelector(".ls3d-scene");
        if (!model || !scene) return;

        var key = productKey(card, name);
        var id = parseInt(key, 10) || hash(name);
        var h = hash(key + "|" + name + "|" + category);

        var variant = h % 12;
        var hueShift = ((h >> 3) % 80) - 40;
        var rotY = -32 + ((h >> 6) % 65);
        var rotX = -12 + ((h >> 11) % 21);
        var rotZ = -7 + ((h >> 15) % 15);
        var scale = 0.88 + (((h >> 19) % 25) / 100);
        var offX = -10 + ((h >> 22) % 21);
        var offY = -10 + ((h >> 25) % 21);

        host.setAttribute("data-ls3d-variant", String(variant));
        host.setAttribute("data-ls3d-fingerprint", String(h));

        model.style.setProperty("--v-hue-shift", hueShift + "deg");
        model.style.setProperty("--ry", rotY + "deg");
        model.style.setProperty("--rx", rotX + "deg");
        model.style.setProperty("--rz", rotZ + "deg");
        model.style.setProperty("--v-scale", String(scale));
        model.style.setProperty("--v-x", offX + "px");
        model.style.setProperty("--v-y", offY + "px");

        scene.style.setProperty("--pattern-rot", ((h % 50) - 25) + "deg");
        scene.style.setProperty("--pattern-x", ((h >> 4) % 70) + "%");
        scene.style.setProperty("--pattern-y", ((h >> 8) % 70) + "%");

        addUniqueDetails(scene, variant, h, name);
    }

    function addUniqueDetails(scene, variant, h, name) {
        var old = scene.querySelectorAll(".ls3d-unique-detail");
        for (var i = 0; i < old.length; i++) {
            if (old[i].parentNode) old[i].parentNode.removeChild(old[i]);
        }

        var count = 1 + (h % 3);

        for (var j = 0; j < count; j++) {
            var dot = document.createElement("span");
            dot.className = "ls3d-unique-detail detail-" + ((variant + j) % 6);
            dot.style.left = (9 + ((h >> (j + 2)) % 76)) + "%";
            dot.style.top = (8 + ((h >> (j + 6)) % 72)) + "%";
            dot.style.transform = "rotate(" + (((h >> (j + 10)) % 80) - 40) + "deg)";
            scene.appendChild(dot);
        }

        var stamp = document.createElement("span");
        stamp.className = "ls3d-unique-detail ls3d-edition";
        stamp.textContent = shortCode(name, h);
        scene.appendChild(stamp);
    }

    function shortCode(name, h) {
        var words = (name || "LS").replace(/[^a-zA-Z0-9 ]/g, " ").split(/\s+/);
        var letters = "";
        for (var i = 0; i < words.length && letters.length < 3; i++) {
            if (words[i]) letters += words[i].charAt(0).toUpperCase();
        }
        if (!letters) letters = "LS";
        return letters + "-" + String((h % 89) + 10);
    }

    function upgradeCatalog() {
        var cards = document.querySelectorAll(".product-card");

        for (var i = 0; i < cards.length; i++) {
            var card = cards[i];
            var host = card.querySelector(".product-art");
            if (!host) continue;

            var name = text(card.querySelector(".product-body h3,h3,.product-name"));
            var category = text(card.querySelector(".product-category,.product-tag,.category"));

            applyFingerprint(host, card, name, category);
        }
    }

    function upgradeDetail() {
        var host = document.querySelector(".detail-art");
        if (!host) return;

        var fakeCard = document.createElement("div");
        var link = document.createElement("a");
        link.setAttribute("href", location.pathname);
        fakeCard.appendChild(link);

        var name = text(document.querySelector(".product-detail-copy h1,.product-detail-page h1"));
        var category = text(document.querySelector(".product-detail-copy .section-kicker,.product-detail-copy .product-tag,.product-detail-page .product-tag"));

        applyFingerprint(host, fakeCard, name, category);

        var thumbs = document.querySelectorAll(".ls3d-view-btn");
        for (var i = 0; i < thumbs.length; i++) {
            applyFingerprint(thumbs[i], fakeCard, name + " view " + (i + 1), category);
        }
    }

    function upgradeMiniCards() {
        var selectors = [".cart-item", ".cp-product"];

        for (var s = 0; s < selectors.length; s++) {
            var items = document.querySelectorAll(selectors[s]);

            for (var i = 0; i < items.length; i++) {
                var item = items[i];
                var host = item.querySelector(".cart-thumb,.ls3d-mini-host,.cp-product-art,.product-thumb,.wishlist-thumb,.thumb");
                if (!host) continue;

                var name = text(item.querySelector(".cart-item-name,.cart-product-name,h3,h4,.name"));
                var category = text(item.querySelector(".category,.product-category,.product-tag,.meta"));

                applyFingerprint(host, item, name, category);
            }
        }
    }

    function init() {
        upgradeCatalog();
        upgradeDetail();
        upgradeMiniCards();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
