(function () {
  "use strict";

  var endpoint = "https://fseqgcebvxiqmzngxhre.supabase.co/functions/v1/marketing-attribution";
  // This is the public anonymous key used by the iOS analytics client. It only
  // satisfies the Supabase gateway; the Edge Function still validates origin,
  // event name, and anonymous session format before using its service role.
  var anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzZXFnY2VidnhpcW16bmd4aHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODQ2MDMsImV4cCI6MjA4OTg2MDYwM30.J_rkoAP-qFfaankfjSyWInk5pSQtrymfhvNhvzh7joA";
  var sessionKey = "youtube_campaign_session";

  function sessionId() {
    try {
      var existing = window.sessionStorage.getItem(sessionKey);
      if (existing) return existing;
      var created = window.crypto && window.crypto.randomUUID
        ? window.crypto.randomUUID().replace(/-/g, "_")
        : "youtube_" + Date.now().toString(36) + "_" + Math.random().toString(36).slice(2, 12);
      window.sessionStorage.setItem(sessionKey, created);
      return created;
    } catch (ignore) {
      return "youtube_" + Date.now().toString(36) + "_" + Math.random().toString(36).slice(2, 12);
    }
  }

  function campaign() {
    var params = new URLSearchParams(window.location.search);
    return {
      source: params.get("utm_source") || "youtube",
      campaign: params.get("utm_campaign") || "shorts_2026_08",
      content: params.get("utm_content") || "unclassified"
    };
  }

  function send(event, location) {
    var source = campaign();
    var payload = {
      event: event,
      session_id: sessionId(),
      intent: "bible_copilot_youtube",
      first_source: source.source,
      first_campaign: source.campaign,
      path: window.location.pathname,
      location: location || source.content
    };
    window.fetch(endpoint, {
      method: "POST",
      mode: "cors",
      credentials: "omit",
      keepalive: true,
      headers: {
        "Content-Type": "application/json",
        "apikey": anonKey,
        "Authorization": "Bearer " + anonKey
      },
      body: JSON.stringify(payload)
    }).catch(function () {});
  }

  send("intent_landing_view");
  document.addEventListener("click", function (event) {
    var cta = event.target.closest("a[data-youtube-app-store-cta]");
    if (!cta || cta.dataset.youtubeTapped === "true") return;
    cta.dataset.youtubeTapped = "true";
    send("app_store_intent_tap", "youtube_app_store_cta");
  }, true);
}());
