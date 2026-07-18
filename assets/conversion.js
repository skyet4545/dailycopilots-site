(function () {
  "use strict";

  function measure(name, parameters) {
    parameters = Object.assign({ page_path: window.location.pathname }, parameters || {});
    if (window.gtag) window.gtag("event", name, parameters);
  }

  document.addEventListener("click", function (event) {
    var appLink = event.target.closest("a[href*='apps.apple.com']");
    if (appLink) {
      if (appLink.dataset.convTracked === "true") return;
      appLink.dataset.convTracked = "true";
      var url;
      try { url = new URL(appLink.href, window.location.href); } catch (e) { url = null; }
      var ct = url ? (url.searchParams.get("ct") || "unclassified") : "unclassified";
      var src = url ? (url.searchParams.get("src") || "unclassified") : "unclassified";
      measure("appstore_click", { cta_type: ct, cta_src: src, destination: "app_store" });
      return;
    }

    var proLink = event.target.closest("a[href*='/pro/']");
    if (proLink && !/apps\.apple\.com/.test(proLink.href)) {
      if (proLink.dataset.convTracked === "true") return;
      proLink.dataset.convTracked = "true";
      measure("pro_cta_click", { destination: proLink.getAttribute("href") });
    }
  }, true);

  if (/\/pro\/?$/.test(window.location.pathname)) {
    measure("pricing_viewed", { annual_price: 49.99, monthly_price: 9.99, currency: "USD" });
  }

  measure("page_view_conversion_ready");
})();
