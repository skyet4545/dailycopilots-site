/* v4 video attribution: only opaque, pipeline-issued IDs; no prayer text or topic paths. */
(function () {
  "use strict";
  if (window.CopilotSocialAttribution) return;
  var brands = {
    "mybiblecopilot.com": { prefix: "bc", app: "6758913373", campaign: "bible_context_to_study_v1" },
    "prayercopilot.com": { prefix: "pc", app: "6761485209", campaign: "prayer_honest_start_v1" }
  };
  var brand = brands[location.hostname];
  if (!brand) return;
  var params = new URLSearchParams(location.search);
  var creative = params.get("utm_content") || "";
  var platform = params.get("utm_source") || "";
  if (params.getAll("utm_content").length !== 1 || params.getAll("utm_source").length !== 1 ||
      !new RegExp("^" + brand.prefix + "_v4_[0-9]{12}_[a-f0-9]{8}$").test(creative) ||
      ["instagram", "youtube", "tiktok"].indexOf(platform) < 0 ||
      params.get("utm_medium") !== "organic_social" || params.get("utm_campaign") !== brand.campaign) return;
  var token = creative + "_" + platform;
  function attributed(raw) {
    try {
      var url = new URL(raw, location.href);
      if (url.protocol !== "https:" || url.hostname !== "apps.apple.com" || url.username || url.password ||
          !url.pathname.endsWith("/id" + brand.app)) return null;
      url.searchParams.set("ct", token);
      url.searchParams.set("mt", "8");
      return { url: url.toString(), campaign: token };
    } catch (ignore) { return null; }
  }
  function measure(name) {
    var data = { creative_id: creative, source_platform: platform, campaign_id: brand.campaign,
      apple_campaign_token: token, page_location: location.origin + "/social/video/",
      page_title: "Social video continuation", page_referrer: "" };
    if (window.gtag) window.gtag("event", name, data);
  }
  window.CopilotSocialAttribution = { version: 4, attributedAppStoreURL: attributed, creativeId: creative };
  document.querySelectorAll("a[href]").forEach(function (link) {
    var target = attributed(link.href); if (target) link.href = target.url;
  });
  measure("social_video_landing_viewed");
  var seen = new WeakSet();
  document.addEventListener("click", function (event) {
    var link = event.target.closest && event.target.closest("a[href]");
    if (!link) return;
    var target = attributed(link.href); if (!target) return;
    link.href = target.url;
    if (!seen.has(link)) { seen.add(link); measure("social_video_app_store_handoff"); }
  }, true);
}());
