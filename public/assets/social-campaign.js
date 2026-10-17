/* Social-to-Study campaign measurement. Deliberately excludes visitor-entered text and PII. */
(function () {
  "use strict";
  var root = document.querySelector("[data-social-campaign]");
  if (!root) return;
  var campaign = root.dataset.socialCampaign || "unclassified";
  var creative = root.dataset.socialCreative || "unclassified";
  var topic = root.dataset.socialTopic || "unclassified";
  var params = new URLSearchParams(location.search);
  var source = params.get("utm_source") || "organic_or_direct";
  var medium = params.get("utm_medium") || "social";
  var eventData = { campaign_id: campaign, creative_id: creative, topic_id: topic, source_platform: source, source_medium: medium, page_path: location.pathname };

  function measure(name, detail) {
    var data = Object.assign({}, eventData, detail || {});
    window.dataLayer = window.dataLayer || [];
    window.dataLayer.push({ event: name, social_campaign: data });
    if (window.gtag) window.gtag("event", name, data);
    if (window.plausible) window.plausible(name, { props: data });
  }

  measure("social_landing_viewed");
  document.addEventListener("click", function (event) {
    var cta = event.target.closest("a[data-social-cta]");
    if (!cta) return;
    measure(cta.dataset.socialCta, { cta_location: cta.dataset.ctaLocation || "unclassified" });
  });
}());
