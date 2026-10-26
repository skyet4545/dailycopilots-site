#!/usr/bin/env node
// Retrofit the 2,648 legacy blog-NNNNN pages for AI-search citability.
// Adds, idempotently, to each page:
//   1. A front-loaded "Quick Answer" box at the top of the article body
//      (front-loaded answers = ~44% of ChatGPT citations; the #1 on-page lever).
//   2. A visible byline linking to the editorial-standards page + a genuine
//      "Updated <today>" date (each page is really modified today) + a
//      Scripture-cited trust line — honest E-E-A-T, no fabricated authors.
//   3. Bumps dateModified in the Article JSON-LD to today (legitimate: changed today).
//
// Quick-answer text = the page's own "direct answer" sentence if present,
// else the meta description. No new AI generation.
//
// Usage: node retrofit-blog-citability.js [--limit N]

const fs = require('fs');
const path = require('path');
const BLOG = path.join(__dirname, '..', 'site-deploy', 'blog');
const TODAY = new Date().toISOString().slice(0, 10);
const TODAY_HUMAN = new Date(TODAY + 'T12:00:00Z').toLocaleDateString('en-US', { year: 'numeric', month: 'long', day: 'numeric', timeZone: 'UTC' });
const MARKER = 'qa-box-v1';
const ABOUT = 'https://mybiblecopilot.com/about/';

const argLimit = process.argv.indexOf('--limit');
const LIMIT = argLimit > -1 ? parseInt(process.argv[argLimit + 1], 10) : Infinity;

function stripTags(s) { return s.replace(/<[^>]+>/g, ' ').replace(/\s+/g, ' ').trim(); }
function esc(s) { return s.replace(/&(?!(amp|lt|gt|quot|#\d+);)/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;'); }

function extractQuickAnswer(html) {
  // 1) the article's own "direct answer" sentence (many pages have one)
  const body = html.match(/<div class="post-body">([\s\S]*?)<div class="cta-box"/);
  if (body) {
    const text = stripTags(body[1]);
    const m = text.match(/(?:the\s+)?(?:short|direct|quick)\s+answer[:—-]?\s*(.{40,340}?[.!?])(?:\s|$)/i);
    if (m) return m[1].trim();
    // else first substantive sentence-pair after any intro heading
  }
  // 2) fallback: meta description (already a concise summary)
  const md = html.match(/<meta name="description" content="([^"]+)"/);
  if (md && md[1].trim().length > 20) return md[1].replace(/&quot;/g, '"').trim();
  // 3) fallback: first substantive sentence of the article body
  if (body) {
    const paras = [...body[1].matchAll(/<p[^>]*>([\s\S]*?)<\/p>/g)].map(m => stripTags(m[1]));
    for (const p of paras) {
      if (p.length < 60) continue;
      const s = p.match(/^(.{50,320}?[.!?])(?:\s|$)/);
      if (s) return s[1].trim();
    }
  }
  return null;
}

function retrofit(file) {
  let html = fs.readFileSync(file, 'utf8');
  if (html.includes(MARKER)) return 'skip';

  const answer = extractQuickAnswer(html);
  if (!answer) return 'noanswer';

  // Quick Answer box — inserted right after the opening of .post-body.
  const qaBox =
    `<div class="${MARKER}" style="background:#141c34;border-left:4px solid #d4af5f;border-radius:8px;padding:18px 22px;margin:0 0 26px;">` +
    `<div style="font-size:13px;font-weight:700;letter-spacing:.06em;text-transform:uppercase;color:#d4af5f;margin-bottom:6px;">Quick answer</div>` +
    `<p style="margin:0;color:#e8e8f0;font-size:17px;line-height:1.6;">${esc(answer)}</p></div>\n`;
  const before = html;
  html = html.replace(/(<div class="post-body">\s*)/, `$1\n${qaBox}`);
  if (html === before) return 'nobody';

  // Byline + updated date + trust line, replacing the plain post-meta.
  html = html.replace(
    /<div class="post-meta">[\s\S]*?<\/div>/,
    `<div class="post-meta">\n` +
    `          <span>By <a href="${ABOUT}" style="color:#d4af5f;text-decoration:none;">Bible Copilot</a></span>\n` +
    `          <span>Updated ${TODAY_HUMAN}</span>\n` +
    `          <span>Scripture-cited · <a href="${ABOUT}" style="color:#9090b8;text-decoration:none;">editorial standards</a></span>\n` +
    `        </div>`
  );

  // Freshen dateModified (genuinely changed today).
  html = html.replace(/("dateModified":\s*")[^"]*(")/, `$1${TODAY}$2`);

  fs.writeFileSync(file, html);
  return 'done';
}

const dirs = fs.readdirSync(BLOG).filter(d => /^blog-\d+$/.test(d)).sort();
const counts = { done: 0, skip: 0, noanswer: 0, nobody: 0 };
let n = 0;
for (const d of dirs) {
  if (n >= LIMIT) break;
  const f = path.join(BLOG, d, 'index.html');
  if (!fs.existsSync(f)) continue;
  counts[retrofit(f)]++;
  n++;
}
console.log(`processed ${n} pages (of ${dirs.length}) @ ${TODAY}:`, JSON.stringify(counts));
