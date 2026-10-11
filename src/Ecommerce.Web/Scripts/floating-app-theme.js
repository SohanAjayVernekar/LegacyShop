(function () {
    function reducedMotion() {
        return window.matchMedia &&
               window.matchMedia("(prefers-reduced-motion: reduce)").matches;
    }

    function ensureLayer() {
        var layer = document.getElementById("floating-theme-burst-layer");
        if (!layer) {
            layer = document.createElement("div");
            layer.id = "floating-theme-burst-layer";
            document.body.appendChild(layer);
        }
        return layer;
    }

    function burst(x, y) {
        if (reducedMotion()) return;

        var layer = ensureLayer();
        var burst = document.createElement("div");
        burst.className = "fu-burst";
        burst.style.left = x + "px";
        burst.style.top = y + "px";

        for (var i = 0; i < 12; i++) {
            var dot = document.createElement("i");
            var angle = Math.PI * 2 * i / 12;
            var distance = 28 + Math.random() * 40;

            dot.style.setProperty("--bx", (Math.cos(angle) * distance) + "px");
            dot.style.setProperty("--by", (Math.sin(angle) * distance) + "px");

            burst.appendChild(dot);
        }

        layer.appendChild(burst);

        setTimeout(function () {
            if (burst.parentNode) burst.parentNode.removeChild(burst);
        }, 850);
    }

    function bindBursts() {
        var selector = [
            ".ls-btn",
            ".ap-btn",
            ".cp-btn",
            ".checkout-btn",
            ".place-order-btn",
            ".cart-primary",
            ".btn.btn-dark",
            ".nav-pill",
            ".page-arrow",
            ".product-card a",
            ".ls-nav a",
            ".ap-nav a",
            ".cp-nav a"
        ].join(",");

        var targets = document.querySelectorAll(selector);

        for (var i = 0; i < targets.length; i++) {
            targets[i].addEventListener("click", function (e) {
                burst(e.clientX, e.clientY);
            });
        }
    }

    function cardTilt() {
        if (reducedMotion()) return;

        var selector = [
            ".product-card",
            ".ls-mini-card",
            ".ap-category-card",
            ".cp-product"
        ].join(",");

        var cards = document.querySelectorAll(selector);

        for (var i = 0; i < cards.length; i++) {
            cards[i].addEventListener("mousemove", function (e) {
                var r = this.getBoundingClientRect();
                var x = (e.clientX - r.left) / r.width - .5;
                var y = (e.clientY - r.top) / r.height - .5;

                this.style.transform =
                    "translateY(-6px) rotateX(" + (-y * 2.5) + "deg) rotateY(" + (x * 3) + "deg)";
            });

            cards[i].addEventListener("mouseleave", function () {
                this.style.transform = "";
            });
        }
    }

    document.addEventListener("DOMContentLoaded", function () {
        bindBursts();
        cardTilt();
    });
})();
