# Portfolio Analytics — Plausible Deploy Doc (2026-04-30)

---

## Why Plausible

Plausible Analytics is a privacy-respecting, cookie-free alternative to Google Analytics. It is fully GDPR and CCPA compliant out of the box — no consent banner required — because it stores no personal data and sets no cookies. The tracking script is approximately 1 KB, adds negligible load time, and delivers a real-time dashboard with the metrics that matter for a small portfolio: pageviews, unique visitors, referrer sources, and top pages. For this portfolio — four distinct properties across different stacks, with no PII collection requirements and a need for low operational overhead — Plausible is a clean fit. One account, one dashboard per property, no third-party ad-tech baggage.

---

## One-Time Account Setup

1. Go to [https://plausible.io](https://plausible.io) and sign up. The **Growth** tier ($9/month, billed monthly, or $90/year) covers up to 10,000 pageviews/month across multiple sites. If any single property exceeds that, upgrade to Business ($19/month).
2. Alternatively, self-host using the official Docker image: [https://plausible.io/docs/self-hosting](https://plausible.io/docs/self-hosting). Self-hosting requires a VPS (minimum 1 GB RAM) and eliminates the monthly fee. The tradeoff is infrastructure maintenance. For this portfolio, hosted Plausible is recommended unless you already run a VPS.
3. Once logged in, click **"+ Add a website"** in the Plausible dashboard. Enter the domain exactly as it appears in the snippet instructions below (e.g., `mybiblecopilot.com`). Repeat for each property.
4. Plausible will show you a snippet after each site is added. The snippet for hosted Plausible always follows this pattern:
   ```html
   <script defer data-domain="YOUR-DOMAIN" src="https://plausible.io/js/script.js"></script>
   ```
   The `data-domain` value must match exactly what you entered in step 3.
5. After pasting the snippet and deploying, click **"Start collecting data"** in the Plausible dashboard. Plausible verifies the snippet is live by detecting an incoming event.

---

## Per-Property Deploy

---

### 1. Bible Copilot Marketing Site v2

- **Domain:** `mybiblecopilot.com`
  *(Confirmed via App Store metadata at `/Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/metadata/app_store_metadata.md`, which lists `https://mybiblecopilot.com` as the marketing URL, privacy URL, and support URL. The footer contact email `hello@scripturecopilot.app` is a secondary alias.)*

- **File to edit:** `marketing-site-v2/index.html`
  Full path: `/Users/carlosreyes/Desktop/Projects/Apps/biblecopilot/marketing-site-v2/index.html`

- **Snippet to paste:**
  ```html
  <script defer data-domain="mybiblecopilot.com" src="https://plausible.io/js/script.js"></script>
  ```

- **Where in the file:** Inside `<head>`, immediately before the closing `</head>` tag (currently at line 336). The `<head>` block ends with the closing `</style>` tag for the embedded CSS, so paste immediately after that `</style>` and before `</head>`. Example final lines of `<head>`:
  ```html
    }
  </style>
  <script defer data-domain="mybiblecopilot.com" src="https://plausible.io/js/script.js"></script>
  </head>
  ```

- **CSP notes:** The current `index.html` has no Content-Security-Policy meta tag or HTTP header. There is no `netlify.toml` or `_headers` file in `marketing-site-v2/`. No CSP action required unless you add one in the future. If you later add a `_headers` file for Netlify, include:
  ```
  /*
    Content-Security-Policy: script-src 'self' https://plausible.io https://esm.sh https://fonts.googleapis.com; connect-src 'self' https://plausible.io
  ```
  Note: the existing page loads scripts from `esm.sh` and fonts from `fonts.googleapis.com`, so those origins must be included in any future CSP.

---

### 2. Peptide Radar

- **Domain:** `peptideradar.net`
  *(Confirmed via `og:url` and `link rel="canonical"` in both `/peptideradar-site/index.html` and `/peptideradar-site/blog/index.html`, which both reference `https://peptideradar.net/`.)*

- **Files to edit:**
  - Root: `peptideradar-site/index.html`
    Full path: `/Users/carlosreyes/Desktop/Projects/Affiliate marketing/Peptide Affiliate Marketing/Pep Affiliate/peptideradar-site/index.html`
  - Blog index: `peptideradar-site/blog/index.html`
    Full path: `/Users/carlosreyes/Desktop/Projects/Affiliate marketing/Peptide Affiliate Marketing/Pep Affiliate/peptideradar-site/blog/index.html`
  - All blog article pages: `peptideradar-site/blog/*.html` (100+ files)

  **Practical approach for the article pages:** Rather than editing 100+ files individually, find the common `</head>` closing in each file and use a bulk find-and-replace. All article HTML files follow the same generator template. A single-pass sed command will handle this:
  ```bash
  cd "/Users/carlosreyes/Desktop/Projects/Affiliate marketing/Peptide Affiliate Marketing/Pep Affiliate/peptideradar-site/blog"
  find . -name "*.html" -exec sed -i '' 's|</head>|<script defer data-domain="peptideradar.net" src="https://plausible.io/js/script.js"></script>\n</head>|' {} +
  ```
  Run this only after confirming it works on one file manually.

- **Snippet to paste (per file):**
  ```html
  <script defer data-domain="peptideradar.net" src="https://plausible.io/js/script.js"></script>
  ```

- **Where in the file:** Inside `<head>`, immediately before `</head>`. The root `index.html` has an embedded `<style>` block that closes before `</head>` — paste between `</style>` and `</head>`. The blog `index.html` has a similar pattern with an inline `<style>` block followed by a `<meta name="twitter:card">` tag — paste after the final meta tag and before `</head>`.

- **CSP notes:** No CSP meta tags or HTTP headers are present in the inspected files. No Netlify `_headers` file exists in this directory. No CSP action required currently. If you add Netlify deployment configuration later, follow the same `_headers` pattern described in Property 1.

---

### 3. Republic Publishing — Men of the Republic Site

- **Domain:** `menoftherepublic.org`
  *(Confirmed via repeated internal links (`https://menoftherepublic.org/...`) throughout the site's HTML files, and confirmed as the active Netlify deployment. Note: the root `index.html` at `/menoftherepublic/index.html` uses `https://therepublicseries.com` as its canonical URL and og:url — see Open Questions below.)*

- **Primary file to edit:** `menoftherepublic/index.html`
  Full path: `/Users/carlosreyes/Desktop/Projects/Publishing/Republic Publishing LLC/menoftherepublic/index.html`

- **All pages:** The `menoftherepublic/` directory contains dozens of individual `.html` pages (book pages, guides, compare pages, etc.). Each one needs the snippet. Same bulk-sed approach applies:
  ```bash
  cd "/Users/carlosreyes/Desktop/Projects/Publishing/Republic Publishing LLC/menoftherepublic"
  find . -name "*.html" -not -path "./.netlify/*" -exec sed -i '' 's|</head>|<script defer data-domain="menoftherepublic.org" src="https://plausible.io/js/script.js"></script>\n</head>|' {} +
  ```

- **Snippet to paste (per file):**
  ```html
  <script defer data-domain="menoftherepublic.org" src="https://plausible.io/js/script.js"></script>
  ```

- **Where in the file:** Inside `<head>`, immediately before `</head>`. In `index.html`, the head ends with a closing `</script>` tag for the JSON-LD structured data block, followed immediately by `</head>` — paste the Plausible snippet between that `</script>` and `</head>`.

- **CSP notes:** No CSP meta tags or HTTP headers present. The `.netlify/netlify.toml` file in this directory is auto-generated and contains no `[[headers]]` blocks. No CSP action required currently. If you add a hand-authored `netlify.toml` or `_headers` file later, include `https://plausible.io` in `script-src` and `connect-src`.

- **Domain ambiguity note:** The root `index.html` canonical points to `therepublicseries.com`. If that domain is the live canonical domain for this Netlify site (rather than `menoftherepublic.org`), you should register `therepublicseries.com` as the site in the Plausible dashboard instead, and update `data-domain="therepublicseries.com"` in the snippet. See Open Questions.

---

### 4. Florida FrontDesk (AI FrontDesk)

- **Domain:** `aifrontdesk.org`
  *(Confirmed via `NEXT_PUBLIC_APP_URL=https://aifrontdesk.org` in `/app/.env.local`, and `metadataBase: new URL("https://aifrontdesk.org")` plus `og:url` in `/app/src/app/layout.tsx`.)*

- **File to edit:** `app/src/app/layout.tsx`
  Full path: `/Users/carlosreyes/Desktop/Projects/Florida FrontDesk/app/src/app/layout.tsx`

- **Snippet to paste (Next.js App Router pattern):**

  Next.js App Router requires using the `next/script` component (not a raw `<script>` tag) for third-party scripts inside the root layout. Update `layout.tsx` as follows:

  ```tsx
  import type { Metadata } from "next";
  import Script from "next/script";
  import "./globals.css";

  export const metadata: Metadata = {
    // ... existing metadata unchanged ...
  };

  export default function RootLayout({ children }: { children: React.ReactNode }) {
    return (
      <html lang="en">
        <head>
          <Script
            defer
            data-domain="aifrontdesk.org"
            src="https://plausible.io/js/script.js"
            strategy="afterInteractive"
          />
        </head>
        <body>{children}</body>
      </html>
    );
  }
  ```

  The `strategy="afterInteractive"` prop tells Next.js to load the script after the page becomes interactive, which matches Plausible's recommended `defer` behavior.

  Alternatively, if you prefer to keep the `<head>` minimal and let Next.js manage the document head entirely, you can use `strategy="lazyOnload"` — Plausible works with either.

- **Where in the file:** Add the `import Script from "next/script"` at the top of the file (after the existing `import type { Metadata }` line). Then add the `<Script>` component inside `<head>` within `RootLayout`, as shown above. The current `RootLayout` renders `<html><body>{children}</body></html>` with no explicit `<head>` element — add the `<head>` block to contain the Script component.

- **CSP notes:** The current `next.config.mjs` has no `headers()` function and sets no CSP. The `netlify.toml` has no `[[headers]]` blocks with CSP. No CSP action required currently. If you add a CSP later via the `headers()` function in `next.config.mjs`, add `https://plausible.io` to both `script-src` and `connect-src`:
  ```js
  // next.config.mjs (example CSP addition)
  const nextConfig = {
    reactStrictMode: true,
    experimental: { serverActions: { allowedOrigins: ["localhost:3000"] } },
    async headers() {
      return [
        {
          source: "/(.*)",
          headers: [
            {
              key: "Content-Security-Policy",
              value: [
                "default-src 'self'",
                "script-src 'self' 'unsafe-inline' https://plausible.io",
                "connect-src 'self' https://plausible.io",
              ].join("; "),
            },
          ],
        },
      ];
    },
  };
  export default nextConfig;
  ```
  Note: Next.js with `'unsafe-inline'` in `script-src` is typical for App Router because of inline script chunks. Adjust to your security posture.

---

## Validation

After deploying each property: open the site in a browser, open DevTools Network tab, and filter by `plausible.io`. You should see a POST request to `https://plausible.io/api/event` with a 202 response within a second of page load. Then open the Plausible dashboard for that domain — the "Current visitors" count should show at least 1. If the request is blocked, check for a CSP violation in the browser console (logged as a Content-Security-Policy error).

---

## Open Questions

1. **Hosted plausible.io vs. self-hosted?** Hosted ($9/month) is recommended for this portfolio. Self-hosting requires a VPS and ongoing maintenance. Decide before setup — the snippet `src` URL changes from `https://plausible.io/js/script.js` to `https://your-plausible-instance.com/js/script.js` if self-hosted.

2. **Custom proxy subdomain for adblocker resilience?** Plausible supports proxying the script through your own domain (e.g., `analytics.mybiblecopilot.com`) to avoid common adblocker blocklists. This is optional. For a content/marketing portfolio with non-adversarial audiences, standard Plausible blocking rates are low. Recommend: skip for now, revisit if dashboard numbers seem unexpectedly low. If you do proxy, each property needs its own subdomain and Netlify/Next.js rewrites configured separately.

3. **Goals and funnels per property:**
   - **Bible Copilot:** Track "App Store click" as a goal (clicks on `https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373`). Set up as an outbound link click goal in Plausible.
   - **Peptide Radar:** Track outbound affiliate link clicks as goals. Plausible's outbound link tracking (`script.outbound-links.js` variant) is useful here.
   - **Men of the Republic:** Track Amazon book link clicks and email list sign-up form submissions as goals.
   - **AI FrontDesk:** Track "Demo request" form submissions and "Contact" CTA clicks as goals.

4. **Domain ambiguity — Republic Publishing:** The `menoftherepublic/index.html` uses `therepublicseries.com` as its canonical URL and og:url, but internal links throughout the site point to `menoftherepublic.org`. The Netlify state.json (`siteId: 9b634ab8-7438-4886-9940-2ce923a36bcf`) is the source of truth for which domain Netlify is serving this site under. Confirm the live domain in the Netlify dashboard before registering the site with Plausible. If the live domain is `therepublicseries.com`, use that as the `data-domain` value instead.

5. **Peptide Radar blog articles (100+ files):** The bulk-sed approach described above will work but should be tested on one file first. After running, spot-check three or four output files to confirm the snippet was inserted correctly and did not duplicate or corrupt any `</head>` tags.
