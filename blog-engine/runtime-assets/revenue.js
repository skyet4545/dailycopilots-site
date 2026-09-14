(function () {
  "use strict";

  var socialVideoTracking = document.createElement("script");
  socialVideoTracking.src = "/assets/social-video-attribution.js?v=20260911-1";
  socialVideoTracking.defer = true;
  document.head.appendChild(socialVideoTracking);

  // Load the first-party acquisition router on every revenue-enabled page.
  // The router records the handoff into the App Store; it never claims that
  // the click became an install or paid subscription.
  if (!document.querySelector("script[src^='/assets/marketing-router.js']")) {
    var marketingAttribution = document.createElement("script");
    marketingAttribution.src = "/assets/marketing-router.js?v=20260914-1";
    marketingAttribution.defer = true;
    document.head.appendChild(marketingAttribution);
  }

  var config = window.BIBLE_COPILOT_REVENUE || {};
  var path = window.location.pathname.replace(/\/+/g, "/");
  var appUrl = config.appStoreUrl || "https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373";
  var customProductPages = config.appStoreCustomProductPages || {};
  var articleHandoffs = config.articleHandoffs || {};
  var premiumSiteSystemEnabled = false;

  function articleHandoffFor(ctaLocation) {
    var handoff = articleHandoffs[path];
    if (!handoff || handoff.ctaLocation !== ctaLocation) return null;
    return handoff;
  }

  function customProductPageKeyFor(ctaLocation) {
    var key = "default";
    if (/verse|explanation|article_inline|verse_study/i.test(ctaLocation || "") || /\/blog\/bible-verse-explanation-app\/|\/tools\/verse-study\//.test(path)) key = "verseExplanation";
    if (/greek|hebrew|language/i.test(ctaLocation || "") || /\/tools\/greek-hebrew-bible-study\//.test(path)) key = "originalLanguages";
    if (/apologetics|apologetic/i.test(ctaLocation || "") || /\/blog\/best-ai-bible-app-for-apologetics\//.test(path)) key = "apologetics";
    if (/small_group|small-group|group/i.test(ctaLocation || "") || /\/tools\/small-group-bible-study-builder\//.test(path)) key = "smallGroups";
    if (/question|discussion/i.test(ctaLocation || "") || /\/tools\/bible-study-questions-generator\//.test(path)) key = "studyQuestions";
    if (/beginner|new_christian|new-christian/i.test(ctaLocation || "") || /\/blog\/best-bible-app-for-new-christians\//.test(path)) key = "newChristians";
    return key;
  }

  function appStoreUrlFor(ctaLocation) {
    var key = customProductPageKeyFor(ctaLocation);
    return campaignUrl(customProductPages[key] || customProductPages.default || appUrl, ctaLocation, key);
  }

  function campaignUrl(url, ctaLocation, appstorePage) {
    try {
      var parsed = new URL(url, window.location.href);
      if (parsed.hostname.indexOf("apps.apple.com") === -1) return url;
      var campaign = ("bc_" + (ctaLocation || "unclassified"))
        .toLowerCase()
        .replace(/[^a-z0-9]+/g, "_")
        .replace(/^_+|_+$/g, "")
        .slice(0, 40);
      if (!parsed.searchParams.get("ct")) parsed.searchParams.set("ct", campaign);
      if (!parsed.searchParams.get("src")) parsed.searchParams.set("src", "mybiblecopilot");
      if (!parsed.searchParams.get("appstore_page")) parsed.searchParams.set("appstore_page", appstorePage || "default");
      return parsed.toString();
    } catch (ignore) {
      return url;
    }
  }

  function routeAppStoreLinks() {
    Array.prototype.slice.call(document.querySelectorAll("a[href*='id6758913373'][data-cta-location]")).forEach(function (link) {
      var ctaLocation = link.dataset.ctaLocation || "unclassified";
      link.dataset.appstorePage = customProductPageKeyFor(ctaLocation);
      link.href = appStoreUrlFor(ctaLocation);
    });
  }

  // Keep high-intent public surfaces visually aligned with the product site without
  // changing their URL, content model, or the article-specific reader experience.
  function enablePremiumSiteSystem() {
    var premiumPaths = new Set([
      "/blog/", "/bible/", "/tools/", "/about/", "/trust/",
      "/ai-bible-study-app/", "/bible-study-app/", "/free-bible-study-app/",
      "/bible-study-tools/", "/bible-verse-explanation/", "/bible-verse-finder/",
      "/bible-study-questions/", "/greek-hebrew-bible-study/",
      "/small-group-bible-study/", "/topical-bible-study/",
      "/bible-cross-references/", "/bible-study-app-for-beginners/",
      "/bible-study-app-for-pastors/", "/compare/bible-copilot-vs-youversion/",
      "/compare/bible-copilot-vs-logos/", "/compare/bible-copilot-vs-blue-letter-bible/",
      "/authors/bible-copilot-editorial-team/", "/editorial-standards/",
      "/reviewers/", "/research/", "/gospel/"
    ]);
    var isBookHub = /^\/bible\/[^/]+\/$/.test(path);
    if (!premiumPaths.has(path) && !isBookHub) return;

    document.body.classList.add("bc-premium-page");
    premiumSiteSystemEnabled = true;
    if (document.querySelector('link[href="/assets/site-system.css"]')) return;
    var stylesheet = document.createElement("link");
    stylesheet.rel = "stylesheet";
    stylesheet.href = "/assets/site-system.css";
    document.head.appendChild(stylesheet);
  }

  function enhancePremiumNavigation() {
    if (!premiumSiteSystemEnabled) return;
    var nav = document.querySelector("body > nav") || document.querySelector("nav");
    if (!nav) return;
    var navContent = nav.querySelector(":scope > .wrap") || nav;
    nav.classList.add("bc-shared-nav");
    if (!navContent.querySelector(".brand, .logo")) {
      var brand = element("a", "brand", "Bible Copilot");
      brand.href = "/";
      brand.setAttribute("aria-label", "Bible Copilot home");
      navContent.insertBefore(brand, navContent.firstChild);
    }
    if (navContent.querySelector('a[href*="apps.apple.com"]')) return;
    var appLink = element("a", "app", "Open free in app");
    appLink.href = appStoreUrlFor("site_nav_app");
    appLink.dataset.ctaLocation = "site_nav_app";
    navContent.appendChild(appLink);
  }

  function repairLegacyBlogIndexStructure() {
    if (path !== "/blog/") return;
    var malformedNav = document.querySelector("body > nav");
    if (!malformedNav || !malformedNav.querySelector(".card")) return;

    // The generated source duplicates the real hero/grid/footer inside its
    // nav element. The canonical siblings remain in place, so clear only the
    // duplicate navigation payload and let the shared shell rebuild the bar.
    malformedNav.replaceChildren();
  }

  function classifyPage() {
    if (path === "/") return { intent: "product", type: "homepage", ads: false };
    if (path.indexOf("/pro/") === 0) return { intent: "product", type: "pro", ads: false };
    if (path.indexOf("/tools/") === 0) return { intent: "product", type: "tool", ads: false };
    if (/^\/(privacy|terms|thanks|about)\/?/.test(path)) return { intent: "utility", type: "utility", ads: false };
    if (/^\/blog\/(best-|[^/]+-vs-|[^/]+-alternatives|bible-app-for-|best-bible-app)/.test(path)) return { intent: "commercial", type: "article", ads: false };
    if (path.indexOf("/blog/") === 0 && path !== "/blog/") return { intent: "informational", type: "article", ads: true };
    if (path.indexOf("/bible/") === 0) return { intent: "informational", type: "hub", ads: true };
    return { intent: "informational", type: "content", ads: true };
  }

  var page = classifyPage();
  var toolName = page.type === "tool" ? (path.split("/").filter(Boolean)[1] || "tools_hub") : "not_applicable";

  function contentGroup() {
    if (page.type === "article") return "bible_study_articles";
    if (page.type === "hub") return "bible_book_hubs";
    if (page.type === "tool") return "free_bible_tools";
    if (page.type === "pro") return "pro_subscription";
    if (page.type === "homepage") return "product_marketing";
    return page.type;
  }
  document.documentElement.dataset.monetizationIntent = page.intent;
  document.documentElement.dataset.pageType = page.type;

  function measure(name, parameters) {
    parameters = Object.assign({
      monetization_intent: page.intent,
      page_type: page.type,
      content_group: contentGroup(),
      page_path: path
    }, parameters || {});
    if (window.gtag) window.gtag("event", name, parameters);
    if (window.plausible) window.plausible(name, { props: parameters });
  }

  function element(tag, className, html) {
    var node = document.createElement(tag);
    if (className) node.className = className;
    if (html) node.innerHTML = html;
    return node;
  }

  function markLegacyPromotions(article) {
    var promotions = Array.prototype.slice.call(article.querySelectorAll(".cta-box"));
    var fixedBars = Array.prototype.slice.call(document.querySelectorAll("body > div[style*='position:fixed'][style*='bottom:0']"));
    promotions.concat(fixedBars).forEach(function (node) { node.classList.add("bc-legacy-promo-hidden"); });
    fixedBars.forEach(function (node) {
      var spacer = node.nextElementSibling;
      if (spacer && spacer.tagName === "DIV" && /height\s*:\s*72px/i.test(spacer.getAttribute("style") || "")) spacer.classList.add("bc-legacy-promo-hidden");
    });

    Array.prototype.slice.call(article.children).forEach(function (node) {
      var style = node.getAttribute && (node.getAttribute("style") || "");
      if (/border\s*:\s*2px solid #d4af5f/i.test(style) && node.querySelector("a[href*='id6758913373']")) node.classList.add("bc-legacy-promo-hidden");
    });
  }

  function buildInlineStudy(article) {
    var body = article.querySelector(".post-body") || article;
    var headings = body.querySelectorAll("h2");
    var anchor = headings.length ? headings[0] : body.querySelector("p:nth-of-type(3)");
    if (!anchor || article.querySelector(".bc-inline-study")) return;
    var inlineAppLocation = "article_inline_app";
    var box = element("aside", "bc-inline-study", '<p class="bc-kicker">Bible verse explanation</p><h2>Ask the next question about this passage</h2><p>Use the free verse worksheet now, read the verification method, or continue in Bible Copilot for Scripture-cited follow-up questions.</p><div class="bc-button-row"><a class="bc-button" data-study-link data-cta-location="article_inline_tool" href="' + (config.freeToolUrl || "/tools/verse-study/") + '">Study a verse free</a><a class="bc-text-link" data-cta-location="article_inline_verse_hub" href="/bible-verse-explanation/">How to verify an explanation →</a><a class="bc-text-link" data-cta-location="' + inlineAppLocation + '" href="' + appStoreUrlFor(inlineAppLocation) + '">Continue in the iPhone app →</a></div>');
    anchor.parentNode.insertBefore(box, anchor);
  }

  function buildFinalPro(article) {
    if (article.querySelector(".bc-final-pro")) return;
    var finalAppLocation = "article_final_app";
    var box = element("aside", "bc-final-pro", '<p class="bc-kicker">Bible Copilot Pro</p><h2>Continue the study with your next question</h2><p>Ask follow-up questions and compare six guided study modes. Start free, then choose Pro for $9.99 monthly or $49.99 annually.</p><div class="bc-button-row" style="justify-content:center"><a class="bc-button" data-cta-location="' + finalAppLocation + '" href="' + appStoreUrlFor(finalAppLocation) + '">Try Bible Copilot free</a><a class="bc-text-link" data-study-link href="' + (config.proUrl || "/pro/") + '">See what Pro includes →</a></div><span class="bc-price-note">Both Pro plans include a 7-day trial.</span>');
    article.appendChild(box);
  }

  function buildSidebar(shell, article) {
    if (!shell || shell.querySelector(".bc-study-sidebar")) return;
    var headings = Array.prototype.slice.call(article.querySelectorAll(".post-body h2[id], .post-body h3[id]")).slice(0, 8);
    var toc = headings.length ? '<div class="bc-sidebar-card"><p class="bc-sidebar-label">On this page</p><ul class="bc-toc">' + headings.map(function (heading) { return '<li><a href="#' + heading.id + '">' + heading.textContent.trim() + '</a></li>'; }).join("") + '</ul></div>' : "";
    var guides = '<div class="bc-sidebar-card"><p class="bc-sidebar-label">Bible verse explanation</p><ul class="bc-toc"><li><a href="/bible-verse-explanation/">How to explain a Bible verse</a></li><li><a href="/tools/verse-study/">Free verse study worksheet</a></li><li><a href="/tools/cross-reference-explorer/">Cross-reference explorer</a></li><li><a href="/tools/greek-hebrew-bible-study/">Greek and Hebrew word study</a></li><li><a href="/blog/bible-verse-explanation-app/">Verse explanation apps</a></li></ul></div>';
    var sidebarAppLocation = "article_sidebar_app";
    var study = '<div class="bc-sidebar-card"><p class="bc-sidebar-label">Continue the study</p><h2>Ask the next question</h2><p>Get verse-anchored explanations across Summary, Observe, Interpret, Theology, Apply, and Apologetics.</p><a class="bc-button" data-cta-location="' + sidebarAppLocation + '" href="' + appStoreUrlFor(sidebarAppLocation) + '">Open Bible Copilot</a><span class="bc-price-note">3 free questions daily · Pro $9.99/mo or $49.99/yr</span></div>';
    var sidebar = element("aside", "bc-study-sidebar", toc + guides + study);
    sidebar.setAttribute("aria-label", "Article study tools");
    shell.appendChild(sidebar);
  }

  function enhanceArticle() {
    if (page.type !== "article") return;
    var article = document.querySelector("article");
    if (!article) return;
    var shell = article.closest(".container") || article.parentElement;
    if (shell) shell.classList.add("bc-editorial-shell");
    markLegacyPromotions(article);
    buildInlineStudy(article);
    buildFinalPro(article);
    buildSidebar(shell, article);
  }

  function observeCtas() {
    if (!("IntersectionObserver" in window)) return;
    var seen = new WeakSet();
    var observer = new IntersectionObserver(function (entries) {
      entries.forEach(function (entry) {
        if (!entry.isIntersecting || seen.has(entry.target)) return;
        seen.add(entry.target);
        measure("cta_impression", { cta_location: entry.target.dataset.ctaLocation || "unclassified" });
      });
    }, { threshold: 0.6 });
    document.querySelectorAll("a[data-cta-location]").forEach(function (cta) { observer.observe(cta); });
  }

  function loadAdsense() {
    if (!config.adsenseClient || !page.ads) return;
    var ads = document.createElement("script");
    ads.async = true;
    ads.crossOrigin = "anonymous";
    ads.src = "https://pagead2.googlesyndication.com/pagead/js/adsbygoogle.js?client=" + encodeURIComponent(config.adsenseClient);
    ads.addEventListener("load", function () { measure("adsense_loaded", { ad_treatment: config.adsenseMode || "auto" }); });
    document.head.appendChild(ads);
  }

  document.addEventListener("click", function (event) {
    var link = event.target.closest("a[href*='id6758913373']");
    var prayerLink = event.target.closest("a[href*='id6761485209'][data-prayer-handoff-context]");
    if (link) {
      if (link.dataset.revenueTracked === "true") return;
      link.dataset.revenueTracked = "true";
      var ctaLocation = link.dataset.ctaLocation || "unclassified";
      measure("appstore_click", { cta_location: ctaLocation, appstore_page: link.dataset.appstorePage || customProductPageKeyFor(ctaLocation), destination: "app_store" });
      var articleHandoff = articleHandoffFor(ctaLocation);
      if (articleHandoff) {
        measure("article_app_store_handoff", {
          attribution_key: articleHandoff.attributionKey,
          attribution_version: articleHandoff.attributionVersion,
          content_cluster: articleHandoff.contentCluster,
          cta_location: ctaLocation,
          destination: "app_store"
        });
      }
    }
    if (prayerLink) {
      measure("prayer_copilot_handoff_click", {
        cta_location: prayerLink.dataset.ctaLocation || "contextual_result",
        handoff_context: prayerLink.dataset.prayerHandoffContext,
        campaign: "contextual_prayer_handoff",
        destination: "app_store"
      });
    }
    var pro = event.target.closest("a[href='/pro/'], a[href='https://mybiblecopilot.com/pro/']");
    if (pro) measure("pro_cta_click", { cta_location: pro.dataset.ctaLocation || "internal_link" });
    var study = event.target.closest("a[data-study-link]");
    if (study) measure("study_tool_click", { destination: study.getAttribute("href") });

    var internal = event.target.closest("a[href]");
    if (internal && !link && !prayerLink && !pro && !study) {
      try {
        var destination = new URL(internal.href, window.location.href);
        if (destination.origin === window.location.origin) {
          measure("internal_navigation", {
            link_path: destination.pathname,
            link_location: internal.dataset.ctaLocation || "content_link"
          });
        } else {
          measure("outbound_destination_click", {
            destination_host: destination.hostname,
            link_location: internal.dataset.ctaLocation || "content_link"
          });
        }
      } catch (ignore) {}
    }

    if (page.type === "tool") {
      var control = event.target.closest("button, [role='button']");
      if (control && !control.matches("[data-share-action]")) startTool("button");
    }
  }, true);

  var scrollMeasured = false;
  function measureScroll() {
    if (scrollMeasured) return;
    var max = document.documentElement.scrollHeight - window.innerHeight;
    if (max > 0 && window.scrollY / max >= 0.75) {
      scrollMeasured = true;
      measure("content_75_percent");
      window.removeEventListener("scroll", measureScroll);
    }
  }
  window.addEventListener("scroll", measureScroll, { passive: true });

  var toolStarted = false;
  var toolCompleted = false;
  function startTool(method) {
    if (page.type !== "tool" || toolStarted) return;
    toolStarted = true;
    measure("tool_started", { tool_name: toolName, interaction_method: method });
  }

  function watchTool() {
    if (page.type !== "tool") return;
    document.addEventListener("submit", function () { startTool("form_submit"); }, true);
    document.addEventListener("change", function (event) {
      if (event.target.matches("select, input[type='radio'], input[type='range']")) startTool("control_change");
    }, true);
    document.addEventListener("input", function (event) {
      if (event.target.matches("input, textarea")) startTool("text_input");
    }, true);

    var results = Array.prototype.slice.call(document.querySelectorAll("#result, .result, [data-tool-result]"));
    if (!results.length || !("MutationObserver" in window)) return;
    var observer = new MutationObserver(function () {
      if (toolCompleted || !toolStarted) return;
      var visible = results.some(function (node) {
        return !node.hidden && node.getAttribute("aria-hidden") !== "true" && node.textContent.trim().length > 20;
      });
      if (!visible) return;
      toolCompleted = true;
      measure("tool_completed", { tool_name: toolName });
      observer.disconnect();
    });
    results.forEach(function (node) { observer.observe(node, { attributes: true, childList: true, subtree: true }); });
  }

  function trackEngagement() {
    var fired = false;
    window.setTimeout(function () {
      if (fired || document.visibilityState !== "visible") return;
      fired = true;
      measure("content_engaged", { engagement_threshold: "30_seconds" });
    }, 30000);

    var search = document.querySelector("#search, [data-site-search]");
    if (search) search.addEventListener("input", function () {
      if (search.dataset.analyticsUsed === "true") return;
      search.dataset.analyticsUsed = "true";
      measure("site_search_used", { search_surface: page.type });
    });
  }

  function init() {
    document.body.classList.add("bc-revenue-ready");
    enablePremiumSiteSystem();
    repairLegacyBlogIndexStructure();
    enhancePremiumNavigation();
    routeAppStoreLinks();
    enhanceArticle();
    observeCtas();
    watchTool();
    trackEngagement();
    loadAdsense();
    measure("monetization_page_view", { ads_eligible: page.ads ? "yes" : "no" });
    if (page.type === "pro") measure("pricing_viewed", { annual_price: 49.99, monthly_price: 9.99, currency: "USD" });
  }

  if (document.readyState === "loading") document.addEventListener("DOMContentLoaded", init);
  else init();
})();
