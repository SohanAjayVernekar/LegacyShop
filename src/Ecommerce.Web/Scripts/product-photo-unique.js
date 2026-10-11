(function () {
    "use strict";

    var STOP_WORDS = {
        "the": true,
        "and": true,
        "with": true,
        "for": true,
        "set": true,
        "kit": true,
        "premium": true,
        "classic": true,
        "modern": true,
        "digital": true,
        "portable": true,
        "universal": true,
        "adjustable": true,
        "minimal": true,
        "organic": true,
        "luxury": true,
        "celebration": true,
        "personalized": true,
        "smart": false
    };

    function trim(value) {
        return (value || "").replace(/^\s+|\s+$/g, "");
    }

    function parseIdFromHref(href) {
        if (!href) return null;

        var match = href.match(/\/Product\/Detail\/(\d+)/i);
        return match ? parseInt(match[1], 10) : null;
    }

    function parseIdFromPath() {
        var match = window.location.pathname.match(/\/Product\/Detail\/(\d+)/i);
        return match ? parseInt(match[1], 10) : null;
    }

    function cleanProductName(name) {
        var value = trim(name)
            .toLowerCase()
            .replace(/['’]/g, "")
            .replace(/\b(?:variant|edition|series|model)\s*[-#]?\s*\d+\b/g, " ")
            .replace(/\b[a-z]{0,3}\d{2,}\b/g, " ")
            .replace(/\b\d+\b/g, " ")
            .replace(/[^a-z0-9]+/g, " ");

        var words = value.split(/\s+/);
        var useful = [];

        for (var i = 0; i < words.length; i++) {
            var word = words[i];

            if (!word) continue;
            if (STOP_WORDS[word] === true) continue;

            useful.push(word);

            if (useful.length === 4) break;
        }

        return useful.join(",");
    }

    function categoryFallback(category) {
        var value = trim(category).toLowerCase();

        var map = [
            [/mobile|tablet/, "smartphone,tablet"],
            [/computer/, "laptop,computer"],
            [/tv|audio/, "television,audio"],
            [/camera/, "camera,photography"],
            [/gaming/, "gaming,console"],
            [/home|kitchen/, "kitchen,home"],
            [/furniture/, "furniture,chair"],
            [/lighting/, "lamp,lighting"],
            [/decor/, "home,decor"],
            [/appliance/, "home,appliance"],
            [/men.*fashion/, "mens,fashion"],
            [/women.*fashion/, "womens,fashion"],
            [/shoe/, "shoes,sneakers"],
            [/bag|luggage/, "bag,luggage"],
            [/jewel/, "jewelry"],
            [/watch/, "watch"],
            [/beauty|personal/, "beauty,skincare"],
            [/health|wellness/, "fitness,wellness"],
            [/grocery/, "food,grocery"],
            [/book/, "book"],
            [/sport|fitness/, "sport,fitness"],
            [/toy|game/, "toy,game"],
            [/baby/, "baby,product"],
            [/automotive/, "car,accessory"],
            [/pet/, "pet,product"],
            [/office|stationery/, "office,stationery"],
            [/garden|outdoor/, "garden,outdoor"],
            [/tool|improvement/, "tools,hardware"],
            [/musical|instrument/, "musical,instrument"],
            [/gift/, "gift"],
            [/travel/, "travel,accessory"],
            [/electronic/, "electronics,gadget"]
        ];

        for (var i = 0; i < map.length; i++) {
            if (map[i][0].test(value)) return map[i][1];
        }

        return "product,shopping";
    }

    function productQuery(name, category) {
        var byName = cleanProductName(name);

        if (byName) {
            return byName;
        }

        return categoryFallback(category);
    }

    function safeQuery(query) {
        return encodeURIComponent(query)
            .replace(/%2C/gi, ",");
    }

    function primaryPhotoUrl(productId, name, category, variation) {
        var query = productQuery(name, category);
        var lock = (productId * 17) + (variation || 0) + 101;

        return "https://loremflickr.com/900/900/" +
            safeQuery(query) +
            "?lock=" + lock;
    }

    function fallbackPhotoUrl(productId, variation) {
        var seed = "legacyshop-" + productId + "-" + (variation || 0);
        return "https://picsum.photos/seed/" +
            encodeURIComponent(seed) +
            "/900/900";
    }

    function createPhoto(productId, name, category, variation) {
        var img = document.createElement("img");

        img.className = "ls-product-photo";
        img.alt = name || "LegacyShop product";
        img.loading = "lazy";
        img.decoding = "async";
        img.referrerPolicy = "no-referrer";

        var usingFallback = false;

        img.addEventListener("load", function () {
            img.classList.add("is-loaded");
        });

        img.addEventListener("error", function () {
            if (!usingFallback) {
                usingFallback = true;
                img.src = fallbackPhotoUrl(productId, variation);
                return;
            }

            img.style.display = "none";
        });

        img.src = primaryPhotoUrl(
            productId,
            name,
            category,
            variation
        );

        return img;
    }

    function addLoader(art) {
        if (!art || art.querySelector(".ls-photo-loader")) return;

        var loader = document.createElement("span");
        loader.className = "ls-photo-loader";
        art.insertBefore(loader, art.firstChild);
    }

    function upgradeCatalogCards() {
        var cards = document.querySelectorAll(".product-card");

        for (var i = 0; i < cards.length; i++) {
            var card = cards[i];

            if (card.getAttribute("data-ls-photo-upgraded") === "1") {
                continue;
            }

            var link = card.querySelector('a[href*="/Product/Detail/"]');
            var art = card.querySelector(".product-art");

            if (!link || !art) continue;

            var productId = parseIdFromHref(link.getAttribute("href"));
            if (!productId) continue;

            var nameNode = card.querySelector(".product-body h3");
            var categoryNode =
                card.querySelector(".product-category") ||
                card.querySelector(".product-tag");

            var name = nameNode ? trim(nameNode.textContent) : "Product";
            var category = categoryNode ? trim(categoryNode.textContent) : "Product";

            addLoader(art);

            var photo = createPhoto(productId, name, category, 0);
            art.insertBefore(photo, art.firstChild);
            art.classList.add("ls-photo-ready");

            card.setAttribute("data-ls-photo-upgraded", "1");
        }
    }

    function setMainDetailImage(mainPhoto, productId, name, category, variation) {
        if (!mainPhoto) return;

        mainPhoto.classList.remove("is-loaded");
        mainPhoto.src = primaryPhotoUrl(productId, name, category, variation);

        var fallbackUsed = false;

        mainPhoto.onerror = function () {
            if (!fallbackUsed) {
                fallbackUsed = true;
                mainPhoto.src = fallbackPhotoUrl(productId, variation);
            }
        };
    }

    function upgradeDetailPage() {
        var art = document.querySelector(".detail-art");
        if (!art || art.getAttribute("data-ls-photo-upgraded") === "1") {
            return;
        }

        var productId = parseIdFromPath();
        if (!productId) return;

        var nameNode = document.querySelector(".product-detail-copy h1");
        var categoryNode =
            document.querySelector(".product-detail-copy .section-kicker") ||
            art.querySelector(".product-tag");

        var name = nameNode ? trim(nameNode.textContent) : "Product";
        var category = categoryNode ? trim(categoryNode.textContent) : "Product";

        addLoader(art);

        var mainPhoto = createPhoto(productId, name, category, 0);
        art.insertBefore(mainPhoto, art.firstChild);
        art.classList.add("ls-photo-ready");
        art.setAttribute("data-ls-photo-upgraded", "1");

        var oldThumbs = document.querySelector(".detail-thumbs");
        if (oldThumbs) {
            oldThumbs.classList.add("ls-old-thumbs-hidden");
        }

        var gallery = document.createElement("div");
        gallery.className = "ls-detail-thumbs";

        for (var i = 0; i < 3; i++) {
            (function (variation) {
                var button = document.createElement("button");
                button.type = "button";
                button.className =
                    "ls-detail-thumb" + (variation === 0 ? " active" : "");

                var thumb = document.createElement("img");
                thumb.alt = name + " view " + (variation + 1);
                thumb.loading = "lazy";
                thumb.referrerPolicy = "no-referrer";

                var fallbackUsed = false;

                thumb.onerror = function () {
                    if (!fallbackUsed) {
                        fallbackUsed = true;
                        thumb.src = fallbackPhotoUrl(productId, variation);
                    }
                };

                thumb.src = primaryPhotoUrl(
                    productId,
                    name,
                    category,
                    variation
                );

                button.appendChild(thumb);

                button.addEventListener("click", function () {
                    var all = gallery.querySelectorAll(".ls-detail-thumb");

                    for (var j = 0; j < all.length; j++) {
                        all[j].classList.remove("active");
                    }

                    button.classList.add("active");

                    setMainDetailImage(
                        mainPhoto,
                        productId,
                        name,
                        category,
                        variation
                    );
                });

                gallery.appendChild(button);
            })(i);
        }

        var visual = art.parentNode;

        if (visual) {
            visual.appendChild(gallery);
        }
    }

    function init() {
        upgradeCatalogCards();
        upgradeDetailPage();
    }

    if (document.readyState === "loading") {
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
