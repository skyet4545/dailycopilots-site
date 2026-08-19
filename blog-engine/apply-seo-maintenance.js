#!/usr/bin/env node
// Idempotent maintenance pass for generated Bible Copilot article pages.
// Usage: node apply-seo-maintenance.js [--write]

const fs = require('fs');
const path = require('path');

const SITE = process.env.BIBLE_COPILOT_SITE || path.join(__dirname, '..', 'site-deploy');
const BLOG = path.join(SITE, 'blog');
const WRITE = process.argv.includes('--write');
const MARKER = 'seo-maintenance-v1';

const tracking = `<script data-maintenance="${MARKER}">
document.addEventListener('click', function (event) {
  const link = event.target.closest('a[href*="apps.apple.com/app/id6758913373"]');
  if (!link) return;
  const parameters = {
    cta_location: link.dataset.ctaLocation || 'article_body',
    page_type: 'article',
    page_path: window.location.pathname
  };
  if (window.gtag) window.gtag('event', 'appstore_click', parameters);
  if (window.plausible) window.plausible('AppStore Tap', {props: parameters});
});
</script>`;

function clean(html) {
  let next = html;

  // Remove authoring metadata that should never appear to readers.
  next = next.replace(/<p[^>]*>\s*(?:<(?:strong|em)[^>]*>\s*)*(?:Meta description|(?:Related\s+)?Keywords?|Word Count)\s*:\s*[\s\S]*?<\/p>/gi, '');
  next = next.replace(/<(?:div|span)[^>]*>\s*(?:<(?:strong|em)[^>]*>\s*)*(?:Meta description|(?:Related\s+)?Keywords?|Word Count)\s*:\s*[\s\S]*?<\/(?:div|span)>/gi, '');

  // Keep the template's first H1 and demote accidental duplicate article H1s.
  let h1Seen = false;
  next = next.replace(/<h1(\s[^>]*)?>([\s\S]*?)<\/h1>/gi, (match, attrs = '', body) => {
    if (!h1Seen) { h1Seen = true; return match; }
    return `<h2${attrs}>${body}</h2>`;
  });

  // Remove the legacy body heading when it exactly repeats the page title.
  const pageTitle = (next.match(/<h1(?:\s[^>]*)?>([\s\S]*?)<\/h1>/i) || [])[1];
  if (pageTitle) {
    const normalize = value => value.replace(/<[^>]+>/g, '').replace(/&[^;]+;/g, ' ').replace(/\s+/g, ' ').trim().toLowerCase();
    const normalizedTitle = normalize(pageTitle);
    let removedDuplicateTitle = false;
    next = next.replace(/<h2(\s[^>]*)?>([\s\S]*?)<\/h2>/gi, (match, attrs = '', body) => {
      if (!removedDuplicateTitle && normalize(body) === normalizedTitle) {
        removedDuplicateTitle = true;
        return '';
      }
      return match;
    });
  }

  // The generated schema referenced a nonexistent logo asset.
  next = next.replaceAll('https://mybiblecopilot.com/logo.png', 'https://mybiblecopilot.com/og-image.png');

  // Label App Store CTAs and install one delegated listener per page.
  next = next.replace(/<a\b(?![^>]*\bdata-cta-location=)([^>]*href=["']https:\/\/apps\.apple\.com\/app\/id6758913373["'][^>]*)>/gi,
    '<a data-cta-location="article_body"$1>');
  if (!next.includes(`data-maintenance="${MARKER}"`)) {
    next = next.replace(/<\/body>/i, `${tracking}\n</body>`);
  }

  return next;
}

const counts = {scanned: 0, changed: 0, duplicateH1Before: 0, scaffoldingBefore: 0};
for (const entry of fs.readdirSync(BLOG, {withFileTypes: true})) {
  if (!entry.isDirectory()) continue;
  const file = path.join(BLOG, entry.name, 'index.html');
  if (!fs.existsSync(file)) continue;
  const before = fs.readFileSync(file, 'utf8');
  counts.scanned++;
  if ((before.match(/<h1\b/gi) || []).length > 1) counts.duplicateH1Before++;
  if (/(?:Meta description|Keywords?|Word Count)\s*:/i.test(before)) counts.scaffoldingBefore++;
  const after = clean(before);
  if (after === before) continue;
  counts.changed++;
  if (WRITE) fs.writeFileSync(file, after);
}

console.log(JSON.stringify({...counts, mode: WRITE ? 'write' : 'check'}, null, 2));
