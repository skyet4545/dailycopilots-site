(function () {
  "use strict";

  var appIds = {
    "6761391729": "constitution",
    "6761395731": "gita",
    "6761389396": "stoic",
    "6761395920": "torah",
    "6761395984": "wisdom",
    "6761485209": "prayer"
  };

  function measure(name, parameters) {
    parameters = Object.assign({
      page_path: window.location.pathname,
      page_type: pageType(),
      transport_type: "beacon"
    }, parameters || {});
    if (window.gtag) window.gtag("event", name, parameters);
  }

  function pageType() {
    if (/\/answers\/[^/]+\/?$/.test(window.location.pathname)) return "answer";
    if (/\/answers\/?$/.test(window.location.pathname)) return "answer_hub";
    if (/\/pro\/?$/.test(window.location.pathname)) return "pro";
    if (window.location.pathname === "/") return "catalog";
    return "product";
  }

  function contentId() {
    var parts = window.location.pathname.split("/").filter(Boolean);
    var answerIndex = parts.indexOf("answers");
    return answerIndex >= 0 && parts[answerIndex + 1] ? parts[answerIndex + 1] : "";
  }

  function appFromPath() {
    var parts = window.location.pathname.split("/").filter(Boolean);
    if (parts[0] === "es") parts.shift();
    return ["constitution", "gita", "stoic", "torah", "wisdom"].indexOf(parts[0]) >= 0 ? parts[0] : "portfolio";
  }

  function appFromLink(link, url) {
    if (link.dataset.app) return link.dataset.app;
    var id = Object.keys(appIds).find(function (candidate) {
      return url && url.pathname.indexOf(candidate) >= 0;
    });
    return id ? appIds[id] : appFromPath();
  }

  function destinationType(link) {
    if (link.dataset.destinationType) return link.dataset.destinationType;
    try {
      var url = new URL(link.href, window.location.href);
      if (/apps\.apple\.com$/.test(url.hostname)) return "app_store";
      if (url.hostname === window.location.hostname) return "internal";
      return "external_product_site";
    } catch (e) {
      return "unknown";
    }
  }

  document.addEventListener("click", function (event) {
    var catalogLink = event.target.closest("[data-track='copilot_catalog_click']");
    if (catalogLink) {
      measure("copilot_catalog_click", {
        app_id: catalogLink.dataset.app || "unclassified",
        cta_location: catalogLink.dataset.ctaLocation || "unclassified",
        destination_type: destinationType(catalogLink),
        link_url: catalogLink.href
      });
    }

    var appLink = event.target.closest("a[href*='apps.apple.com']");
    if (appLink) {
      if (appLink.dataset.convTracked === "true") return;
      appLink.dataset.convTracked = "true";
      var url;
      try { url = new URL(appLink.href, window.location.href); } catch (e) { url = null; }
      var ct = url ? (url.searchParams.get("ct") || "unclassified") : "unclassified";
      var src = url ? (url.searchParams.get("src") || "unclassified") : "unclassified";
      var pt = url ? (url.searchParams.get("pt") || "unclassified") : "unclassified";
      measure("appstore_click", {
        app_id: appFromLink(appLink, url),
        content_id: appLink.dataset.contentId || contentId(),
        cta_location: appLink.dataset.ctaLocation || "unclassified",
        cta_type: ct,
        cta_src: src,
        campaign_token: ct,
        provider_token: pt,
        destination: "app_store",
        link_url: appLink.href
      });
      return;
    }

    var proLink = event.target.closest("a[href*='/pro/']");
    if (proLink && !/apps\.apple\.com/.test(proLink.href)) {
      if (proLink.dataset.convTracked === "true") return;
      proLink.dataset.convTracked = "true";
      measure("pro_cta_click", {
        app_id: proLink.dataset.app || appFromPath(),
        cta_location: proLink.dataset.ctaLocation || "unclassified",
        destination: proLink.getAttribute("href"),
        link_url: proLink.href
      });
    }
  }, true);

  if (/\/pro\/?$/.test(window.location.pathname)) {
    measure("pricing_viewed", {
      app_id: appFromPath(),
      annual_price: 49.99,
      monthly_price: 9.99,
      currency: "USD"
    });
  }

  if (/\/answers\/[^/]+\/?$/.test(window.location.pathname)) {
    measure("answer_landing_viewed", {
      app_id: appFromPath(),
      content_id: contentId(),
      language: document.documentElement.lang || "en"
    });
    var bridge = document.querySelector("[data-app-bridge]");
    if (bridge && "IntersectionObserver" in window) {
      var observer = new IntersectionObserver(function (entries) {
        if (!entries.some(function (entry) { return entry.isIntersecting; })) return;
        measure("app_bridge_viewed", {
          app_id: bridge.dataset.appBridge || appFromPath(),
          content_id: bridge.dataset.contentId || contentId(),
          cta_location: "answer_bridge"
        });
        observer.disconnect();
      }, { threshold: 0.35 });
      observer.observe(bridge);
    }
  }

  measure("page_view_conversion_ready");
})();
