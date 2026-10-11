(function () {
    "use strict";

    function txt(node) {
        return node ? (node.textContent || "").replace(/\s+/g, " ").trim() : "";
    }
    function low(v) { return (v || "").toLowerCase(); }

    function idFromHref(href) {
        var m = (href || "").match(/\/Product\/Detail\/(\d+)/i);
        return m ? parseInt(m[1], 10) : 0;
    }
    function idFromPath() {
        var m = location.pathname.match(/\/Product\/Detail\/(\d+)/i);
        return m ? parseInt(m[1], 10) : 0;
    }
    function hash(s) {
        var h = 2166136261;
        s = s || "LegacyShop";
        for (var i = 0; i < s.length; i++) {
            h ^= s.charCodeAt(i);
            h += (h << 1) + (h << 4) + (h << 7) + (h << 8) + (h << 24);
        }
        return Math.abs(h >>> 0);
    }
    function stableId(id, name) {
        return id || ((hash(name) % 100000) + 1);
    }

    // Product name gets priority over category.
    function detectType(name, category) {
        var n = low(name);
        var c = low(category);

        // Beauty / personal care
        if (/serum|essence|facial oil|face oil|dropper/.test(n)) return "serum";
        if (/perfume|fragrance|eau de|cologne/.test(n)) return "perfume";
        if (/lipstick|lip balm|lip color/.test(n)) return "lipstick";
        if (/mascara|eyeliner/.test(n)) return "mascara";
        if (/cream|moistur|lotion|cleanser|face wash|sunscreen|shampoo|conditioner|body wash/.test(n)) return "cream";
        if (/toothbrush/.test(n)) return "toothbrush";
        if (/hair dryer|hairdryer|blow dryer/.test(n)) return "dryer";
        if (/razor|shaver|trimmer/.test(n)) return "trimmer";

        // Electronics / computers
        if (/mechanical keyboard|gaming keyboard|wireless keyboard|portable keyboard|keyboard/.test(n)) return "keyboard";
        if (/mouse\b|gaming mouse|wireless mouse/.test(n)) return "mouse";
        if (/monitor|display screen/.test(n)) return "monitor";
        if (/webcam/.test(n)) return "webcam";
        if (/router|wi[- ]?fi/.test(n)) return "router";
        if (/power bank|portable charger/.test(n)) return "powerbank";
        if (/charger|charging adapter|wall adapter/.test(n)) return "charger";
        if (/usb|flash drive|pendrive|thumb drive/.test(n)) return "usb";
        if (/hard drive|ssd|storage drive/.test(n)) return "drive";
        if (/earbud|airpod|true wireless|tws/.test(n)) return "earbuds";
        if (/headphone|headset/.test(n)) return "audio";
        if (/smartphone|mobile phone|iphone|android phone|\bphone\b/.test(n)) return "phone";
        if (/tablet|ipad/.test(n)) return "tablet";
        if (/laptop|notebook|macbook|chromebook/.test(n)) return "laptop";
        if (/camera|mirrorless|dslr/.test(n)) return "camera";
        if (/speaker|bluetooth speaker|soundbar|woofer/.test(n)) return "speaker";
        if (/controller|gamepad|joystick/.test(n)) return "game";
        if (/console|playstation|xbox|switch/.test(n)) return "console";
        if (/smart watch|smartwatch|fitness watch/.test(n)) return "smartwatch";
        if (/watch|timepiece/.test(n)) return "watch";

        // Home / decor / appliances
        if (/wall art|wall frame|art print|poster|canvas art|painting/.test(n)) return "wallart";
        if (/photo frame|picture frame/.test(n)) return "frame";
        if (/mirror/.test(n)) return "mirror";
        if (/vase/.test(n)) return "vase";
        if (/clock/.test(n)) return "clock";
        if (/candle/.test(n)) return "candle";
        if (/lamp|table light|desk light/.test(n)) return "lamp";
        if (/chair|office chair|dining chair|stool/.test(n)) return "chair";
        if (/sofa|couch/.test(n)) return "sofa";
        if (/table|desk/.test(n)) return "table";
        if (/mug|coffee cup|cup/.test(n)) return "mug";
        if (/coffee maker|coffee machine/.test(n)) return "coffee";
        if (/toaster/.test(n)) return "toaster";
        if (/blender|mixer|juicer/.test(n)) return "blender";
        if (/kettle/.test(n)) return "kettle";
        if (/microwave/.test(n)) return "microwave";
        if (/vacuum/.test(n)) return "vacuum";
        if (/fan/.test(n)) return "fan";
        if (/iron\b|steam iron/.test(n)) return "iron";

        // Fashion
        if (/sneaker|running shoe|sports shoe|shoe/.test(n)) return "shoe";
        if (/boot/.test(n)) return "boot";
        if (/crossbody bag|handbag|shoulder bag|tote bag|purse/.test(n)) return "bag";
        if (/backpack/.test(n)) return "backpack";
        if (/luggage|suitcase|trolley/.test(n)) return "travel";
        if (/sunglass|eyewear/.test(n)) return "glasses";
        if (/ring\b/.test(n)) return "ring";
        if (/necklace/.test(n)) return "necklace";
        if (/bracelet/.test(n)) return "bracelet";
        if (/wallet/.test(n)) return "wallet";
        if (/shirt|t[- ]?shirt|top\b/.test(n)) return "shirt";
        if (/jacket|coat/.test(n)) return "jacket";

        // Toys / baby
        if (/building block|blocks set|block set|lego/.test(n)) return "blocks";
        if (/teddy|plush|soft toy/.test(n)) return "teddy";
        if (/toy car|race car/.test(n)) return "toycar";
        if (/doll/.test(n)) return "doll";
        if (/baby bottle/.test(n)) return "babybottle";
        if (/stroller|pram/.test(n)) return "stroller";

        // Grocery
        if (/coffee beans|coffee pack|ground coffee/.test(n)) return "coffeebag";
        if (/tea\b|tea pack/.test(n)) return "teabox";
        if (/cereal/.test(n)) return "cereal";
        if (/chocolate/.test(n)) return "chocolate";
        if (/cookie|biscuit/.test(n)) return "cookies";
        if (/juice/.test(n)) return "juice";
        if (/water bottle|mineral water/.test(n)) return "bottle";
        if (/snack|chips/.test(n)) return "snack";

        // Books / stationery / office
        if (/book|novel|paperback|hardcover/.test(n)) return "book";
        if (/notebook|journal/.test(n)) return "notebook";
        if (/pen set|pencil set|stationery/.test(n)) return "office";
        if (/calculator/.test(n)) return "calculator";

        // Sports
        if (/dumbbell/.test(n)) return "dumbbell";
        if (/yoga mat/.test(n)) return "yogamat";
        if (/football|soccer ball/.test(n)) return "football";
        if (/basketball/.test(n)) return "basketball";
        if (/tennis racket|tennis racquet/.test(n)) return "racket";
        if (/cricket bat/.test(n)) return "bat";
        if (/helmet/.test(n)) return "helmet";

        // Automotive
        if (/car charger/.test(n)) return "carcharger";
        if (/car vacuum/.test(n)) return "vacuum";
        if (/car mat/.test(n)) return "carmat";
        if (/phone holder|car mount/.test(n)) return "phonemount";
        if (/tire inflator|air pump/.test(n)) return "pump";

        // Garden / tools / music / pets / gifts
        if (/plant pot|planter/.test(n)) return "garden";
        if (/watering can/.test(n)) return "wateringcan";
        if (/hammer/.test(n)) return "hammer";
        if (/screwdriver/.test(n)) return "screwdriver";
        if (/drill/.test(n)) return "drill";
        if (/guitar/.test(n)) return "guitar";
        if (/violin/.test(n)) return "violin";
        if (/piano|musical keyboard|electronic keyboard/.test(n)) return "piano";
        if (/pet bowl/.test(n)) return "pet";
        if (/pet bed|dog bed|cat bed/.test(n)) return "petbed";
        if (/gift box|gift set/.test(n)) return "gift";

        // Category fallback only after name rules.
        if (/beauty|personal care/.test(c)) return "cream";
        if (/mobiles|tablet/.test(c)) return "phone";
        if (/computer|accessories/.test(c)) return "keyboard";
        if (/tv|audio|electronics/.test(c)) return "speaker";
        if (/camera/.test(c)) return "camera";
        if (/gaming/.test(c)) return "game";
        if (/furniture/.test(c)) return "chair";
        if (/lighting/.test(c)) return "lamp";
        if (/decor/.test(c)) return "wallart";
        if (/appliance/.test(c)) return "microwave";
        if (/fashion/.test(c)) return "shirt";
        if (/shoe/.test(c)) return "shoe";
        if (/bag|luggage/.test(c)) return "bag";
        if (/jewel/.test(c)) return "ring";
        if (/watch/.test(c)) return "watch";
        if (/grocery/.test(c)) return "snack";
        if (/book/.test(c)) return "book";
        if (/sport|fitness/.test(c)) return "dumbbell";
        if (/toy|game/.test(c)) return "blocks";
        if (/baby/.test(c)) return "babybottle";
        if (/automotive/.test(c)) return "phonemount";
        if (/pet/.test(c)) return "pet";
        if (/office|stationery/.test(c)) return "office";
        if (/garden|outdoor/.test(c)) return "garden";
        if (/tool|home improvement/.test(c)) return "hammer";
        if (/musical instrument/.test(c)) return "guitar";
        if (/gift/.test(c)) return "gift";
        if (/travel/.test(c)) return "travel";

        return "box";
    }

    function palette(id, type) {
        var base = {
            serum:20, perfume:338, lipstick:348, mascara:320, cream:18,
            toothbrush:188, dryer:220, trimmer:205,
            keyboard:212, mouse:218, monitor:210, webcam:205, router:215,
            powerbank:218, charger:210, usb:205, drive:215,
            earbuds:204, audio:214, phone:228, tablet:222, laptop:203,
            camera:30, speaker:215, game:261, console:248, smartwatch:205, watch:31,
            wallart:34, frame:28, mirror:210, vase:42, clock:35, candle:30,
            lamp:36, chair:27, sofa:25, table:27, mug:15, coffee:22,
            toaster:28, blender:185, kettle:205, microwave:210, vacuum:210,
            fan:205, iron:210,
            shoe:8, boot:22, bag:350, backpack:210, travel:205, glasses:25,
            ring:42, necklace:38, bracelet:35, wallet:24, shirt:198, jacket:215,
            blocks:330, teddy:24, toycar:5, doll:340, babybottle:190, stroller:208,
            coffeebag:26, teabox:105, cereal:35, chocolate:18, cookies:32, juice:28,
            bottle:185, snack:45, book:14, notebook:22, office:205, calculator:215,
            dumbbell:160, yogamat:285, football:155, basketball:20, racket:185,
            bat:28, helmet:205, carcharger:210, carmat:28, phonemount:215, pump:210,
            garden:114, wateringcan:175, hammer:28, screwdriver:15, drill:210,
            guitar:26, violin:22, piano:210, pet:19, petbed:24, gift:337, box:32
        };
        var b = base[type] || 28;
        return (b + ((id * 29) % 46) - 23 + 360) % 360;
    }

    function bg(id, type) {
        var h = palette(id, type);
        var h2 = (h + 26 + ((id * 7) % 24)) % 360;
        return {
            h:h,
            bg1:"hsl(" + h + " 38% 91%)",
            bg2:"hsl(" + h2 + " 30% 74%)",
            ry:(-20 + (id % 11)) + "deg",
            rx:(-8 + (id % 5)) + "deg",
            rz:(-3 + (id % 7)) + "deg"
        };
    }

    function markup(type) {
        var M = {
            keyboard:'<div class="kb-board"></div><div class="kb-keys"></div>',
            mouse:'<div class="mouse-shell"></div><div class="mouse-wheel"></div>',
            monitor:'<div class="monitor-screen"></div><div class="monitor-neck"></div><div class="monitor-base"></div>',
            wallart:'<div class="art-frame"><div class="art-shape a"></div><div class="art-shape b"></div><div class="art-line"></div></div>',
            frame:'<div class="photo-frame"><div class="photo-inner"></div></div>',
            blocks:'<div class="block b1"></div><div class="block b2"></div><div class="block b3"></div><div class="block b4"></div>',
            serum:'<div class="pump"></div><div class="cap"></div><div class="bottle"></div><div class="label">SERUM</div>',
            perfume:'<div class="perf-cap"></div><div class="perf-bottle"></div><div class="perf-label">EAU</div>',
            lipstick:'<div class="lip-base"></div><div class="lip-stick"></div>',
            cream:'<div class="tube"></div><div class="cap"></div>',
            phone:'<div class="device"></div>',
            tablet:'<div class="tablet-device"></div>',
            laptop:'<div class="screen"></div><div class="base"></div>',
            earbuds:'<div class="case"></div><div class="bud b1"></div><div class="bud b2"></div>',
            audio:'<div class="band"></div><div class="cup c1"></div><div class="cup c2"></div>',
            camera:'<div class="cam-body"></div><div class="lens"></div>',
            speaker:'<div class="speaker-box"></div><div class="woofer"></div><div class="tweeter"></div>',
            shoe:'<div class="sole"></div><div class="upper"></div>',
            bag:'<div class="bag-body"></div><div class="bag-strap"></div>',
            backpack:'<div class="pack-body"></div><div class="pack-pocket"></div>',
            watch:'<div class="strap"></div><div class="face"></div>',
            smartwatch:'<div class="strap"></div><div class="smart-face"></div>',
            chair:'<div class="back"></div><div class="seat"></div><div class="leg l1"></div><div class="leg l2"></div>',
            lamp:'<div class="shade"></div><div class="stem"></div><div class="lamp-base"></div>',
            mug:'<div class="mug-body"></div><div class="mug-handle"></div>',
            coffee:'<div class="coffee-body"></div><div class="coffee-pot"></div>',
            book:'<div class="cover"></div>',
            notebook:'<div class="notebook-body"></div><div class="notebook-ring"></div>',
            dumbbell:'<div class="db-bar"></div><div class="db-weight left"></div><div class="db-weight right"></div>',
            football:'<div class="ball football-ball"></div>',
            basketball:'<div class="ball basket-ball"></div>',
            toycar:'<div class="toycar-body"></div><div class="wheel w1"></div><div class="wheel w2"></div>',
            teddy:'<div class="teddy-head"></div><div class="teddy-body"></div><div class="teddy-ear e1"></div><div class="teddy-ear e2"></div>',
            gift:'<div class="gift-box"></div><div class="gift-ribbon"></div><div class="gift-bow"></div>',
            guitar:'<div class="g-neck"></div><div class="g-body1"></div><div class="g-body2"></div><div class="g-hole"></div>',
            piano:'<div class="piano-body"></div><div class="piano-keys"></div>',
            vase:'<div class="vase-body"></div>',
            mirror:'<div class="mirror-body"></div>',
            clock:'<div class="clock-body"></div><div class="clock-hand h1"></div><div class="clock-hand h2"></div>',
            candle:'<div class="candle-body"></div><div class="flame"></div>',
            travel:'<div class="travel-case"></div>',
            garden:'<div class="pot"></div><div class="leaf g1"></div><div class="leaf g2"></div><div class="leaf g3"></div>',
            hammer:'<div class="handle"></div><div class="head"></div>',
            drill:'<div class="drill-body"></div><div class="drill-bit"></div>',
            pet:'<div class="bowl"></div>',
            babybottle:'<div class="baby-bottle"></div><div class="baby-nipple"></div>',
            office:'<div class="holder"></div><div class="pen p1"></div><div class="pen p2"></div><div class="pen p3"></div>',
            snack:'<div class="snack-pack"></div>',
            bottle:'<div class="generic-bottle"></div>',
            box:'<div class="pack"></div>'
        };
        return M[type] || M.box;
    }

    function shortName(name) {
        var s = (name || "LegacyShop product").replace(/\b\d{3,}\b/g, "").trim();
        if (s.length > 26) s = s.substring(0, 26).trim() + "…";
        return s;
    }

    function makeScene(id, name, category, compact) {
        id = stableId(id, name);
        var type = detectType(name, category);
        var p = bg(id, type);
        var scene = document.createElement("div");
        scene.className = "ls3d-scene";
        scene.setAttribute("data-ls3d-type", type);
        scene.style.setProperty("--ls3d-bg1", p.bg1);
        scene.style.setProperty("--ls3d-bg2", p.bg2);

        var model = document.createElement("div");
        model.className = "ls3d-model ls3d-" + type;
        model.style.setProperty("--h", p.h);
        model.style.setProperty("--ry", p.ry);
        model.style.setProperty("--rx", p.rx);
        model.style.setProperty("--rz", p.rz);
        model.innerHTML = markup(type);
        scene.appendChild(model);

        if (!compact) {
            var label = document.createElement("div");
            label.className = "ls3d-brand";
            label.textContent = shortName(name);
            scene.appendChild(label);

            var s1 = document.createElement("span");
            s1.className = "ls3d-spark s1";
            s1.textContent = "✦";
            var s2 = document.createElement("span");
            s2.className = "ls3d-spark s2";
            s2.textContent = "✧";
            scene.appendChild(s1); scene.appendChild(s2);
        }

        return scene;
    }

    function clear(host) {
        if (!host) return;
        var q = host.querySelectorAll(".ls-product-photo,.ls-photo-loader,.ls3d-scene");
        for (var i = 0; i < q.length; i++) {
            if (q[i].parentNode) q[i].parentNode.removeChild(q[i]);
        }
    }

    function upgradeCatalog() {
        var cards = document.querySelectorAll(".product-card");
        for (var i = 0; i < cards.length; i++) {
            var card = cards[i];
            var art = card.querySelector(".product-art");
            var link = card.querySelector('a[href*="/Product/Detail/"]');
            if (!art || !link) continue;

            var name = txt(card.querySelector(".product-body h3,h3,.product-name"));
            var cat = txt(card.querySelector(".product-category,.product-tag,.category"));
            var id = idFromHref(link.getAttribute("href"));

            clear(art);
            art.classList.add("ls3d-ready");
            art.appendChild(makeScene(id, name, cat, false));
        }
    }

    function upgradeDetail() {
        var art = document.querySelector(".detail-art");
        if (!art) return;

        var id = idFromPath();
        var name = txt(document.querySelector(".product-detail-copy h1,.product-detail-page h1"));
        var cat = txt(document.querySelector(".product-detail-copy .section-kicker,.product-detail-copy .product-tag,.product-detail-page .product-tag"));

        clear(art);
        art.classList.add("ls3d-ready");
        art.setAttribute("data-ls3d-view", "1");
        art.appendChild(makeScene(id, name, cat, false));

        var old = document.querySelectorAll(".detail-thumbs,.ls-detail-thumbs");
        for (var i = 0; i < old.length; i++) old[i].classList.add("ls3d-hide-old");

        var host = art.parentNode;
        if (!host) return;

        var existing = host.querySelector(".ls3d-detail-views");
        if (existing && existing.parentNode) existing.parentNode.removeChild(existing);

        var views = document.createElement("div");
        views.className = "ls3d-detail-views";

        for (var v = 1; v <= 3; v++) {
            (function(viewNo){
                var btn = document.createElement("button");
                btn.type = "button";
                btn.className = "ls3d-view-btn" + (viewNo === 1 ? " active" : "");
                btn.setAttribute("aria-label", "3D product view " + viewNo);

                var scene = makeScene(id, name, cat, true);
                var model = scene.querySelector(".ls3d-model");
                if (model) {
                    model.style.animation = "none";
                    if (viewNo === 1) { model.style.setProperty("--ry","18deg"); model.style.setProperty("--rx","-4deg"); }
                    if (viewNo === 2) { model.style.setProperty("--ry","-34deg"); model.style.setProperty("--rx","-10deg"); }
                    if (viewNo === 3) { model.style.setProperty("--ry","3deg"); model.style.setProperty("--rx","12deg"); }
                }

                btn.appendChild(scene);
                btn.addEventListener("click", function(){
                    var all = views.querySelectorAll(".ls3d-view-btn");
                    for (var j = 0; j < all.length; j++) all[j].classList.remove("active");
                    btn.classList.add("active");
                    art.setAttribute("data-ls3d-view", String(viewNo));
                });
                views.appendChild(btn);
            })(v);
        }

        host.appendChild(views);
    }

    function itemName(item) {
        return txt(item.querySelector(".cart-item-name,.cart-product-name,.cp-product h3,.cp-product h4,h3,h4,.name"));
    }
    function itemCat(item) {
        return txt(item.querySelector(".category,.product-category,.product-tag,.meta"));
    }
    function itemId(item) {
        var link = item.querySelector('a[href*="/Product/Detail/"]');
        if (link) return idFromHref(link.getAttribute("href"));
        var d = item.getAttribute("data-product-id");
        return d ? parseInt(d,10) || 0 : 0;
    }

    function upgradeCart() {
        var items = document.querySelectorAll(".cart-item");
        for (var i = 0; i < items.length; i++) {
            var host = items[i].querySelector(".cart-thumb");
            if (!host) continue;
            host.innerHTML = "";
            host.classList.add("ls3d-ready");
            host.appendChild(makeScene(itemId(items[i]), itemName(items[i]), itemCat(items[i]), true));
        }
    }

    function upgradeWishlist() {
        var items = document.querySelectorAll(".cp-product");
        for (var i = 0; i < items.length; i++) {
            var item = items[i];
            var host = item.querySelector(".cp-product-art,.product-thumb,.wishlist-thumb,.thumb");
            if (!host) {
                host = document.createElement("div");
                host.className = "ls3d-mini-host";
                host.style.width = "76px";
                host.style.height = "76px";
                host.style.borderRadius = "18px";
                item.insertBefore(host, item.firstChild);
            } else {
                host.classList.add("ls3d-mini-host");
                host.innerHTML = "";
            }
            host.appendChild(makeScene(itemId(item), itemName(item), itemCat(item), true));
        }
    }

    function init() {
        upgradeCatalog();
        upgradeDetail();
        upgradeCart();
        upgradeWishlist();
    }

    if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
    else init();
})();
