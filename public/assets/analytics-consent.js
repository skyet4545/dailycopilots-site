(function () {
  "use strict";

  var CONSENT_KEY = "bc_analytics_consent_v1";
  var GA_ID = "G-TL50DGZ82K";
  var GA_SRC = "https://www.googletagmanager.com/gtag/js?id=" + GA_ID;
  var PLAUSIBLE_SRC = "https://plausible.io/js/pa--jK5TL04op6ly-9pXDPhz.js";
  var consent = readConsent();

  function readConsent() {
    try {
      return window.localStorage.getItem(CONSENT_KEY);
    } catch (_) {
      return null;
    }
  }

  function writeConsent(value) {
    try {
      window.localStorage.setItem(CONSENT_KEY, value);
    } catch (_) {
      // Analytics remains session-only if persistent preferences are unavailable.
    }
    consent = value;
  }

  function setKlaviyoTrackingAllowed(allowed) {
    try {
      document.cookie = allowed
        ? "__kla_off=; Max-Age=0; path=/; SameSite=Lax"
        : "__kla_off=true; path=/; SameSite=Lax";
    } catch (_) {
      // The edge bootstrap also defaults Klaviyo tracking to off.
    }
  }

  function appendScript(src, name) {
    var existing = document.querySelector('script[data-bc-analytics="' + name + '"]');
    if (existing) return;
    var script = document.createElement("script");
    script.async = true;
    script.src = src;
    script.setAttribute("data-bc-analytics", name);
    document.head.appendChild(script);
  }

  function startAnalytics() {
    if (consent !== "granted" || window.__bcAnalyticsStarted) return;

    setKlaviyoTrackingAllowed(true);

    // Discard events accumulated by other page scripts before consent.
    window.dataLayer = [];
    window.gtag = function () { window.dataLayer.push(arguments); };
    window.gtag("consent", "default", {
      analytics_storage: "granted",
      ad_storage: "denied",
      ad_user_data: "denied",
      ad_personalization: "denied",
    });
    window.gtag("js", new Date());
    window.gtag("config", GA_ID);

    appendScript(GA_SRC, "ga4");
    appendScript(PLAUSIBLE_SRC, "plausible");
    appendScript("/assets/daily-study-capture.js", "daily-study-capture");
    appendScript("/assets/marketing-router.js", "marketing-router");
    window.__bcAnalyticsStarted = true;
    window.dispatchEvent(new CustomEvent("bc:analytics-consent", { detail: { granted: true } }));
  }

  function clearAnalyticsCookies() {
    var names = document.cookie.split(";").map(function (entry) {
      return entry.split("=")[0].trim();
    }).filter(function (name) {
      return /^_ga(?:_|$)|^_gid$|^_gat(?:_|$)|^__kla_id$/.test(name);
    });
    names.forEach(function (name) {
      document.cookie = name + "=; Max-Age=0; path=/; SameSite=Lax";
    });
  }

  function stopAnalytics() {
    setKlaviyoTrackingAllowed(false);
    if (typeof window.gtag === "function") {
      window.gtag("consent", "update", {
        analytics_storage: "denied",
        ad_storage: "denied",
        ad_user_data: "denied",
        ad_personalization: "denied",
      });
    }
    window.dataLayer = [];
    window.gtag = function () {};
    window.plausible = function () {};
    window.__bcAnalyticsStarted = false;
    document.querySelectorAll('script[data-bc-analytics="ga4"], script[data-bc-analytics="plausible"]').forEach(function (script) {
      script.remove();
    });
    clearAnalyticsCookies();
    try {
      window.localStorage.removeItem("bc_marketing_first_touch_v1");
      window.sessionStorage.removeItem("bc_marketing_sid");
    } catch (_) {}
    window.dispatchEvent(new CustomEvent("bc:analytics-consent", { detail: { granted: false } }));
  }

  function makeButton(label, className, handler) {
    var button = document.createElement("button");
    button.type = "button";
    button.className = className;
    button.textContent = label;
    button.addEventListener("click", handler);
    return button;
  }

  function createChoices() {
    var panel = document.querySelector("#bc-analytics-consent");
    if (panel) return panel;

    panel = document.createElement("section");
    panel.id = "bc-analytics-consent";
    panel.className = "bc-analytics-consent";
    panel.setAttribute("role", "dialog");
    panel.setAttribute("aria-label", "Optional analytics choices");
    panel.setAttribute("aria-live", "polite");

    var copy = document.createElement("p");
    copy.className = "bc-analytics-consent__copy";
    copy.textContent = "Help improve Bible Copilot by allowing optional analytics. If you decline, analytics stay off. You can change this choice at any time.";

    var privacy = document.createElement("a");
    privacy.href = "/privacy/";
    privacy.textContent = "Privacy policy";

    var actions = document.createElement("div");
    actions.className = "bc-analytics-consent__actions";
    actions.appendChild(makeButton("Allow analytics", "bc-analytics-consent__allow", function () {
      writeConsent("granted");
      panel.hidden = true;
      startAnalytics();
    }));
    actions.appendChild(makeButton("Continue without analytics", "bc-analytics-consent__deny", function () {
      writeConsent("denied");
      panel.hidden = true;
      stopAnalytics();
    }));

    panel.appendChild(copy);
    panel.appendChild(privacy);
    panel.appendChild(actions);
    document.body.appendChild(panel);
    return panel;
  }

  function addSettingsControl() {
    if (document.querySelector("#bc-analytics-settings")) return;
    var button = makeButton("Privacy choices", "bc-analytics-settings", function () {
      var panel = createChoices();
      panel.hidden = false;
      var allow = panel.querySelector(".bc-analytics-consent__allow");
      if (allow) allow.focus();
    });
    var footer = document.querySelector("footer") || document.body;
    footer.appendChild(button);
  }

  var choices = createChoices();
  addSettingsControl();

  setKlaviyoTrackingAllowed(consent === "granted");

  if (consent === "granted") {
    choices.hidden = true;
    startAnalytics();
  } else if (consent === "denied") {
    choices.hidden = true;
  }
})();
