(function () {
  "use strict";

  var endpoint = "https://fseqgcebvxiqmzngxhre.supabase.co/functions/v1/gospel-funnel-event";
  var sessionKey = "gospel_funnel_session";

  function sessionId() {
    try {
      var existing = window.sessionStorage.getItem(sessionKey);
      if (existing) return existing;
      var created = window.crypto && window.crypto.randomUUID
        ? window.crypto.randomUUID().replace(/-/g, "_")
        : "gospel_" + Date.now().toString(36) + "_" + Math.random().toString(36).slice(2, 12);
      window.sessionStorage.setItem(sessionKey, created);
      return created;
    } catch (ignore) {
      return "gospel_" + Date.now().toString(36) + "_" + Math.random().toString(36).slice(2, 12);
    }
  }

  function referrerHost() {
    if (!document.referrer) return "direct_or_unavailable";
    try { return new URL(document.referrer).hostname.toLowerCase(); }
    catch (ignore) { return "direct_or_unavailable"; }
  }

  function send(event, detail) {
    var payload = Object.assign({
      event: event,
      session_id: sessionId(),
      referrer_host: referrerHost()
    }, detail || {});

    window.fetch(endpoint, {
      method: "POST",
      mode: "cors",
      credentials: "omit",
      keepalive: true,
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify(payload)
    }).catch(function () {});
  }

  try {
    if (!window.sessionStorage.getItem("gospel_funnel_viewed")) {
      window.sessionStorage.setItem("gospel_funnel_viewed", "1");
      send("gospel_landing_view");
    }
  } catch (ignore) {
    send("gospel_landing_view");
  }

  document.addEventListener("click", function (event) {
    var cta = event.target.closest("a[data-gospel-funnel-cta]");
    if (!cta || cta.dataset.gospelFunnelTapped === "true") return;
    cta.dataset.gospelFunnelTapped = "true";
    send("gospel_app_store_tap", { cta_location: cta.dataset.ctaLocation || "unclassified" });
  }, true);
}());
