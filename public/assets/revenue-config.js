window.BIBLE_COPILOT_REVENUE = {
  // AdSense publisher account verified in the authenticated Google account.
  // Product, Pro, tool, legal, and homepage routes are always excluded in revenue.js.
  adsenseClient: "ca-pub-4276853338128888",
  adsenseMode: "auto",
  adSlots: {
    articleAfterAnswer: "",
    articleMidpoint: "",
    articleSidebar: ""
  },
  appStoreUrl: "https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373",
  // Fill these with approved App Store custom product page URLs after they are created.
  // Empty values intentionally fall back to appStoreUrl in revenue.js.
  appStoreCustomProductPages: {
    default: "",
    verseExplanation: "",
    originalLanguages: "",
    apologetics: "",
    smallGroups: "",
    studyQuestions: "",
    newChristians: ""
  },
  // Explicit, measured article-to-app pilot contracts. Do not add a page here
  // until its reader journey and baseline are approved for rollout.
  articleHandoffs: {
    "/blog/isaiah-432-meaning-when-you-pass-through-the-waters-explained/": {
      attributionKey: "article-isaiah-43-2-meaning-when-you-pass-through-the-waters-explained",
      attributionVersion: "article_journey_v1",
      contentCluster: "isaiah_43_2",
      ctaLocation: "article_inline_app",
      ctaLocations: [
        "article_inline_app",
        "article_context_isaiah_432_context_v1"
      ]
    }
  },
  proUrl: "/pro/",
  freeToolUrl: "/tools/verse-study/"
};
