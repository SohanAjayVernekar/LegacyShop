(function(){
    "use strict";

    function findVisual(host){
        if(!host) return null;

        // Prefer the current generated-product SVG/image.
        var img = host.querySelector('img[src*="generated-product-art"], img.product-photo, img');
        if(img) return img;

        var svg = host.querySelector(".lsv4-svg, svg");
        if(svg) return svg;

        return null;
    }

    function wrap(host){
        if(!host || host.classList.contains("ls-moving3d")) return;

        var visual = findVisual(host);
        if(!visual) return;

        var stage = document.createElement("div");
        stage.className = "ls-moving3d-stage";

        var plane = document.createElement("div");
        plane.className = "ls-moving3d-plane";

        var edgeA = document.createElement("span");
        edgeA.className = "ls-moving3d-edge edge-a";

        var edgeB = document.createElement("span");
        edgeB.className = "ls-moving3d-edge edge-b";

        var glint = document.createElement("span");
        glint.className = "ls-moving3d-glint";

        visual.parentNode.insertBefore(stage, visual);
        plane.appendChild(visual);
        stage.appendChild(edgeA);
        stage.appendChild(edgeB);
        stage.appendChild(plane);
        stage.appendChild(glint);

        host.classList.add("ls-moving3d");

        // Stable starting angle differs per product, preserving uniqueness.
        var seed = 0;
        var text = (host.closest(".product-card,.cart-item,.cp-product") || host).textContent || "";
        for(var i=0;i<text.length;i++){
            seed = ((seed << 5) - seed + text.charCodeAt(i)) | 0;
        }
        seed = Math.abs(seed);

        host.style.setProperty("--rx", (-7 + (seed % 7)) + "deg");
        host.style.setProperty("--ry", (-12 + ((seed >> 3) % 25)) + "deg");

        bindTilt(host, stage);
    }

    function bindTilt(host, stage){
        var reduce = window.matchMedia &&
            window.matchMedia("(prefers-reduced-motion: reduce)").matches;
        if(reduce) return;

        host.addEventListener("mousemove", function(e){
            var r = host.getBoundingClientRect();
            var x = (e.clientX - r.left) / Math.max(r.width,1);
            var y = (e.clientY - r.top) / Math.max(r.height,1);

            var ry = (x - .5) * 22;
            var rx = (.5 - y) * 16;

            host.style.setProperty("--rx", rx.toFixed(2) + "deg");
            host.style.setProperty("--ry", ry.toFixed(2) + "deg");
            host.style.setProperty("--gx", ((x * 90) - 45).toFixed(1) + "%");
            host.style.setProperty("--gy", ((y * 50) - 25).toFixed(1) + "%");
        });

        host.addEventListener("mouseleave", function(){
            host.style.setProperty("--rx","-4deg");
            host.style.setProperty("--ry","8deg");
            host.style.setProperty("--gx","-42%");
            host.style.setProperty("--gy","-15%");
        });

        // Touch/mobile: gentle automatic perspective drift.
        var phase = Math.random() * Math.PI * 2;
        var start = performance.now();

        function drift(now){
            if(!document.body.contains(host)) return;
            if(window.matchMedia("(hover: hover)").matches) return;

            var t = (now - start) / 1600 + phase;
            var rx = -2 + Math.sin(t) * 2.5;
            var ry = 4 + Math.cos(t * .82) * 5;

            host.style.setProperty("--rx", rx.toFixed(2) + "deg");
            host.style.setProperty("--ry", ry.toFixed(2) + "deg");

            requestAnimationFrame(drift);
        }

        requestAnimationFrame(drift);
    }

    function init(){
        var selectors = [
            ".product-card .product-art",
            ".detail-art",
            ".cart-item .cart-thumb",
            ".cp-product .cp-product-art",
            ".cp-product .product-thumb",
            ".cp-product .wishlist-thumb",
            ".cp-product .thumb",
            ".ls3d-mini-host"
        ];

        for(var s=0;s<selectors.length;s++){
            var nodes = document.querySelectorAll(selectors[s]);
            for(var i=0;i<nodes.length;i++) wrap(nodes[i]);
        }
    }

    if(document.readyState === "loading"){
        document.addEventListener("DOMContentLoaded", init);
    } else {
        init();
    }
})();
