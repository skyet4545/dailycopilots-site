(function () {
  "use strict";

  var BIBLE_COPILOT_FORM_ID = "W2ZpsL";
  var FORM_NAME = "bible_copilot_verse_of_the_day";

  function track(name, parameters) {
    var payload = Object.assign({
      form_name: FORM_NAME,
      form_id: BIBLE_COPILOT_FORM_ID,
      page_path: window.location.pathname
    }, parameters || {});
    if (window.gtag) window.gtag("event", name, payload);
    if (window.plausible) window.plausible(name, { props: payload });
  }

  // Klaviyo's onsite SDK emits this event for a displayed, submitted, or
  // dismissed form. Restrict measurement to the Bible Copilot form so the
  // shared Republic Publishing account cannot contaminate this funnel.
  window.addEventListener("klaviyoForms", function (event) {
    var detail = event && event.detail ? event.detail : {};
    if (detail.formId !== BIBLE_COPILOT_FORM_ID) return;

    if (detail.type === "open" || detail.type === "embedOpen") {
      track("daily_study_popup_viewed", { form_event: detail.type });
    } else if (detail.type === "submit") {
      track("daily_study_signup_completed", { form_event: detail.type, signup_method: "klaviyo_popup" });
    } else if (detail.type === "close") {
      track("daily_study_popup_dismissed", { form_event: detail.type });
    }
  });

  // Any intentional page-level invitation can open the approved Klaviyo form
  // without duplicating subscription logic in the website.
  document.addEventListener("click", function (event) {
    var trigger = event.target.closest("[data-daily-study-trigger]");
    if (!trigger) return;
    event.preventDefault();
    track("daily_study_popup_requested", { cta_location: trigger.dataset.ctaLocation || "unclassified" });
    window._klOnsite = window._klOnsite || [];
    window._klOnsite.push(["openForm", BIBLE_COPILOT_FORM_ID]);
  });
})();
