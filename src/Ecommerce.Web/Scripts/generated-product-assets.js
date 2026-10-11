(function(){
    "use strict";
    function text(n){return n?(n.textContent||"").replace(/\s+/g," ").trim():"";}
    function idFromHref(href){var m=(href||"").match(/\/Product\/Detail\/(\d+)/i);return m?parseInt(m[1],10):0;}
    function makeImg(id,name){
        var img=document.createElement("img");
        img.className="generated-product-image";
        img.src="/Content/generated-product-art/product-"+id+".svg";
        img.alt=name||"LegacyShop product";
        img.loading="lazy";
        img.decoding="async";
        return img;
    }
    function replace(host,id,name){
        if(!host||!id)return;
        host.innerHTML="";
        host.classList.add("generated-product-host");
        host.appendChild(makeImg(id,name));
    }
    function catalog(){
        var cards=document.querySelectorAll(".product-card");
        for(var i=0;i<cards.length;i++){
            var c=cards[i],a=c.querySelector('a[href*="/Product/Detail/"]'),host=c.querySelector(".product-art");
            if(!a||!host)continue;
            replace(host,idFromHref(a.getAttribute("href")),text(c.querySelector(".product-body h3,h3,.product-name")));
        }
    }
    function detail(){
        var host=document.querySelector(".detail-art"),m=location.pathname.match(/\/Product\/Detail\/(\d+)/i);
        if(!host||!m)return;
        replace(host,parseInt(m[1],10),text(document.querySelector(".product-detail-copy h1,.product-detail-page h1")));
        var olds=document.querySelectorAll(".ls3d-detail-views,.detail-thumbs,.ls-detail-thumbs");
        for(var i=0;i<olds.length;i++)olds[i].style.display="none";
    }
    function minis(){
        var items=document.querySelectorAll(".cart-item,.cp-product");
        for(var i=0;i<items.length;i++){
            var item=items[i],a=item.querySelector('a[href*="/Product/Detail/"]');
            var host=item.querySelector(".cart-thumb,.cp-product-art,.product-thumb,.wishlist-thumb,.thumb,.ls3d-mini-host");
            if(!a||!host)continue;
            replace(host,idFromHref(a.getAttribute("href")),text(item.querySelector(".cart-item-name,.cart-product-name,h3,h4,.name")));
        }
    }
    function init(){catalog();detail();minis();}
    if(document.readyState==="loading")document.addEventListener("DOMContentLoaded",init);else init();
})();
