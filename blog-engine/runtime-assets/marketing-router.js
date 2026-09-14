/* AI-operated intent, attribution, and consent router. No PII is sent here. */
(function () {
  "use strict";
  var endpoint = "https://fseqgcebvxiqmzngxhre.supabase.co/functions/v1/marketing-attribution";
  var anonKey = "eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImZzZXFnY2VidnhpcW16bmd4aHJlIiwicm9sZSI6ImFub24iLCJpYXQiOjE3NzQyODQ2MDMsImV4cCI6MjA4OTg2MDYwM30.J_rkoAP-qFfaankfjSyWInk5pSQtrymfhvNhvzh7joA";
  var key = "bc_marketing_first_touch_v2";
  var params = new URLSearchParams(location.search);
  var path = location.pathname.toLowerCase();
  var intent = /anxiety|fear|grief|loss|worry/.test(path) ? "comfort" : /apolog|doubt|why/.test(path) ? "apologetics" : /prayer|pray/.test(path) ? "prayer" : /beginner|how-to|study/.test(path) ? "study_start" : "verse_explanation";

  function referringHost() {
    try {
      return new URL(document.referrer).hostname.toLowerCase().replace(/^www\./, "");
    } catch (_) {
      return "none";
    }
  }

  function hostMatches(host, candidate) {
    return host === candidate || host.endsWith("." + candidate);
  }

  function sourceFromReferrer(host) {
    var aiSources = [
      ["chatgpt.com", "ai_chatgpt"],
      ["perplexity.ai", "ai_perplexity"],
      ["copilot.microsoft.com", "ai_copilot"],
      ["gemini.google.com", "ai_gemini"],
      ["claude.ai", "ai_claude"],
      ["you.com", "ai_you"],
      ["meta.ai", "ai_meta"],
      ["chat.deepseek.com", "ai_deepseek"],
      ["chat.mistral.ai", "ai_mistral"]
    ];
    for (var i = 0; i < aiSources.length; i += 1) {
      if (hostMatches(host, aiSources[i][0])) return aiSources[i][1];
    }
    if (host === "none" || hostMatches(host, "mybiblecopilot.com")) return "organic_or_direct";
    return "external_referral";
  }

  var referrerHost = referringHost();
  var inferredSource = sourceFromReferrer(referrerHost);
  var explicitSource = params.get("utm_source");
  var source = explicitSource || inferredSource;
  var inferredCampaign = source.indexOf("ai_") === 0 ? "ai_referral_unpaid" : "unclassified";
  var touch = {
    source: source,
    campaign: params.get("utm_campaign") || inferredCampaign,
    intent: intent,
    referrer_host: referrerHost
  };
  try { if (!localStorage.getItem(key)) localStorage.setItem(key, JSON.stringify(touch)); else touch = JSON.parse(localStorage.getItem(key)); } catch (_) {}
  function sid() { try { var s = sessionStorage.getItem("bc_marketing_sid"); if (s) return s; s = crypto.randomUUID().replace(/-/g, "_"); sessionStorage.setItem("bc_marketing_sid", s); return s; } catch (_) { return "bc_" + Date.now().toString(36); } }
  function send(event, detail) { fetch(endpoint, { method: "POST", mode: "cors", credentials: "omit", keepalive: true, headers: { "Content-Type": "application/json", "apikey": anonKey, "Authorization": "Bearer " + anonKey }, body: JSON.stringify(Object.assign({ event: event, session_id: sid(), intent: intent, first_source: touch.source, first_campaign: touch.campaign, referrer_host: touch.referrer_host || "none", path: location.pathname }, detail || {})) }).catch(function () {}); }
  send("intent_landing_view");
  document.querySelectorAll("form").forEach(function (form) { ["intent", "first_source", "first_campaign"].forEach(function (name) { var input = document.createElement("input"); input.type = "hidden"; input.name = name; input.value = name === "intent" ? intent : name === "first_source" ? touch.source : touch.campaign; form.appendChild(input); }); form.addEventListener("submit", function () { send("lead_capture_submit", { form: form.getAttribute("name") || form.id || "unclassified" }); }); });
  document.addEventListener("click", function (e) { var a = e.target.closest("a"); if (!a) return; var isStore = /apps\.apple\.com/.test(a.href); if (isStore) send("app_store_intent_tap", { location: a.dataset.ctaLocation || "unclassified" }); else if (a.dataset.studyLink !== undefined || /\/tools\/verse-study/.test(a.getAttribute("href") || "")) send("study_start_tap", { location: a.dataset.ctaLocation || "unclassified" }); }, true);
}());
