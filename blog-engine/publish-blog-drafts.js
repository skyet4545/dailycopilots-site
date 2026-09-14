#!/usr/bin/env node
// Bible Copilot blog publisher.
// Reads markdown drafts from blog-engine/inbox/, renders them into the live
// site's blog template, writes site-deploy/blog/<slug>/index.html, updates
// sitemap.xml and blog/index.html, then moves each draft to inbox/published/.
// Drafts that fail validation move to inbox/needs-review/ with a .reason.txt.
//
// Draft format: YAML-ish frontmatter (title, meta_description, slug, date,
// category, keywords) followed by markdown. This is what the Cowork task
// `bible-copilot-seo-engine` writes.
//
// Usage: node publish-blog-drafts.js          (build only)
// Deploy after: cd ../site-deploy && netlify deploy --prod --dir .

const fs = require('fs');
const path = require('path');
const syncRuntimeAssets = require('./sync-runtime-assets.js');

const ENGINE = __dirname;
const INBOX = path.join(ENGINE, 'inbox');
const PUBLISHED = path.join(INBOX, 'published');
const NEEDS_REVIEW = path.join(INBOX, 'needs-review');
const SITE = path.join(ENGINE, '..', 'site-deploy');
syncRuntimeAssets(SITE);
const BLOG = path.join(SITE, 'blog');
const SITEMAP = path.join(SITE, 'sitemap.xml');
const BLOG_INDEX = path.join(BLOG, 'index.html');
const TEMPLATE = fs.readFileSync(path.join(ENGINE, 'blog-template.html'), 'utf8');
const DONE_LOG = path.join(ENGINE, 'done_topics.txt');
const BASE = 'https://mybiblecopilot.com';
const AUTHORITY_ROOT = '/Users/carlosreyes/Documents/Codex/2026-07-27/i-ve-logged/outputs/bible-copilot-authority-system';
const PUBLICATION_POLICY_VERSION = '2026-07-30-v1';

function isoWeek(date = new Date()) {
  const value = new Date(Date.UTC(date.getUTCFullYear(), date.getUTCMonth(), date.getUTCDate()));
  value.setUTCDate(value.getUTCDate() + 4 - (value.getUTCDay() || 7));
  const yearStart = new Date(Date.UTC(value.getUTCFullYear(), 0, 1));
  const week = Math.ceil((((value - yearStart) / 86400000) + 1) / 7);
  return `${value.getUTCFullYear()}-W${String(week).padStart(2, '0')}`;
}

const CURRENT_WEEK = isoWeek();
const CURRENT_MANIFEST_PATH = path.join(AUTHORITY_ROOT, 'weeks', CURRENT_WEEK, 'cluster-manifest.json');
const CURRENT_MANIFEST = fs.existsSync(CURRENT_MANIFEST_PATH)
  ? JSON.parse(fs.readFileSync(CURRENT_MANIFEST_PATH, 'utf8'))
  : null;

function publishedThisWeek() {
  if (!fs.existsSync(DONE_LOG)) return 0;
  return fs.readFileSync(DONE_LOG, 'utf8')
    .split('\n')
    .filter(Boolean)
    .filter(line => {
      const date = new Date(`${line.split('\t')[0]}T12:00:00Z`);
      return !Number.isNaN(date.valueOf()) && isoWeek(date) === CURRENT_WEEK;
    }).length;
}

// Volume cap. This throttles throughput; it does NOT decide quality - every page
// still has to clear the corpus-similarity, 20-impression evidence, 700-word,
// named-reviewer and slop gates below. Capping volume instead of uniqueness held
// net new pages at zero for six consecutive weeks (W31-W36).
const WEEKLY_NEW_PAGE_CAP = Number(process.env.WEEKLY_NEW_PAGE_CAP || 25);
let weeklyPublishedCount = publishedThisWeek();

function parseFrontmatter(raw) {
  const m = raw.match(/^---\n([\s\S]*?)\n---\n?([\s\S]*)$/);
  if (!m) return null;
  const meta = {};
  for (const line of m[1].split('\n')) {
    const kv = line.match(/^(\w[\w_]*):\s*(.*)$/);
    if (kv) {
      const value = kv[2].trim();
      const quote = value[0];
      meta[kv[1]] = value.length >= 2 && (quote === '"' || quote === "'") && value.at(-1) === quote
        ? value.slice(1, -1)
        : value;
    }
  }
  if (!meta.title && meta.seo_title) meta.title = meta.seo_title; // both frontmatter styles occur
  return { meta, body: m[2].trim() };
}

function esc(s) {
  return s.replace(/&/g, '&amp;').replace(/</g, '&lt;').replace(/>/g, '&gt;')
          .replace(/"/g, '&quot;');
}

function inline(s) {
  return esc(s)
    .replace(/\*\*([^*]+)\*\*/g, '<strong>$1</strong>')
    .replace(/\*([^*]+)\*/g, '<em>$1</em>')
    .replace(/\[([^\]]+)\]\(([^)]+)\)/g, '<a href="$2">$1</a>');
}

function slugify(s) {
  return s.toLowerCase().replace(/[^a-z0-9]+/g, '-').replace(/^-+|-+$/g, '');
}

const QUALITY_STOP_WORDS = new Set([
  'and', 'are', 'for', 'from', 'have', 'into', 'that', 'the', 'their', 'this',
  'through', 'with', 'your', 'what', 'does', 'mean', 'bible', 'verse'
]);

function qualityTokens(value) {
  return String(value || '').toLowerCase()
    .replace(/<script\b[\s\S]*?<\/script>/gi, ' ')
    .replace(/<style\b[\s\S]*?<\/style>/gi, ' ')
    .replace(/<[^>]+>/g, ' ')
    .replace(/[^a-z0-9 ]/g, ' ')
    .split(/\s+/)
    .filter(token => token.length > 2 && !QUALITY_STOP_WORDS.has(token));
}

function bigrams(value) {
  const tokens = qualityTokens(value);
  if (tokens.length < 2) return new Set(tokens);
  return new Set(tokens.slice(0, -1).map((token, index) => `${token} ${tokens[index + 1]}`));
}

function jaccard(left, right) {
  const a = bigrams(left);
  const b = bigrams(right);
  const overlap = [...a].filter(item => b.has(item)).length;
  const union = new Set([...a, ...b]).size;
  return union ? overlap / union : 0;
}

function nearestPublishedPage(body) {
  const candidates = fs.readdirSync(BLOG, { withFileTypes: true })
    .filter(entry => entry.isDirectory())
    .map(entry => {
      const file = path.join(BLOG, entry.name, 'index.html');
      if (!fs.existsSync(file)) return null;
      const html = fs.readFileSync(file, 'utf8');
      return { slug: entry.name, similarity: jaccard(body, html) };
    })
    .filter(Boolean)
    .sort((a, b) => b.similarity - a.similarity);
  return candidates[0] || null;
}

function approvedNewPage(meta) {
  // The manifest may authorize a single page (approvedNewPage) or a batch
  // (approvedNewPages: []). Both go through identical evidence and uniqueness
  // gates below - the array form only changes HOW MANY may be authorized per
  // week, never the bar each one has to clear.
  const single = CURRENT_MANIFEST?.approvedNewPage;
  const many = CURRENT_MANIFEST?.approvedNewPages;
  const pool = Array.isArray(many) ? many : (single ? [single] : []);
  if (!pool.length) return { error: `current ${CURRENT_WEEK} authority manifest has no approvedNewPage` };
  const slug = meta.slug || slugify(meta.title || '');
  const approval = pool.find((a) => a && a.slug === slug);
  if (!approval) return { error: `slug is not authorized by ${CURRENT_WEEK} manifest` };
  if (approval.canonical !== `${BASE}/blog/${slug}/`) return { error: 'manifest canonical does not match target URL' };
  const evidence = approval.exactQueryEvidence || [];
  const impressions = evidence.reduce((sum, row) => sum + Number(row.impressions || 0), 0);
  if (!evidence.length || impressions < 20) return { error: 'manifest lacks 20 exact-query impressions' };
  if (!approval.distinctValue || !approval.sourcePlan) return { error: 'manifest lacks distinct value or source plan' };
  if (!approval.corpusSimilarity || typeof approval.corpusSimilarity.score !== 'number') {
    return { error: 'manifest lacks corpus-similarity evidence' };
  }
  const threshold = Number(approval.corpusSimilarity.threshold ?? 0.58);
  if (approval.corpusSimilarity.score >= threshold) return { error: 'manifest corpus-similarity gate failed' };
  return { approval, threshold };
}

// Minimal markdown -> HTML for the article body. Supports #/##/### headings,
// blockquotes, unordered lists, hr, bold/italic/links, paragraphs.
function mdToHtml(md) {
  const lines = md.split('\n').filter(line => !/^\s*(?:\*\*)?(?:meta description|keywords?|word count)(?:\*\*)?\s*:/i.test(line));
  const out = [];
  let list = false, quote = false, table = false, para = [];
  const flushPara = () => {
    if (para.length) { out.push('<p>' + inline(para.join(' ')) + '</p>'); para = []; }
  };
  const closeBlocks = () => {
    flushPara();
    if (list) { out.push('</ul>'); list = false; }
    if (quote) { out.push('</blockquote>'); quote = false; }
    if (table) { out.push('</tbody></table>'); table = false; }
  };
  for (const rawLine of lines) {
    const line = rawLine.trimEnd();
    if (/^\|.*\|$/.test(line)) {
      const cells = line.slice(1, -1).split('|').map(c => c.trim());
      if (cells.every(c => /^:?-{3,}:?$/.test(c))) continue; // separator row
      if (!table) {
        flushPara();
        if (list) { out.push('</ul>'); list = false; }
        if (quote) { out.push('</blockquote>'); quote = false; }
        out.push('<table><thead><tr>' + cells.map(c => `<th>${inline(c)}</th>`).join('') + '</tr></thead><tbody>');
        table = true;
      } else {
        out.push('<tr>' + cells.map(c => `<td>${inline(c)}</td>`).join('') + '</tr>');
      }
      continue;
    }
    if (table) { out.push('</tbody></table>'); table = false; }
    const h = line.match(/^(#{1,3})\s+(.*)$/);
    if (h) {
      closeBlocks();
      const level = h[1].length;
      if (level === 1) continue; // page h1 comes from the template header
      out.push(`<h${level} id="${slugify(h[2])}">${inline(h[2])}</h${level}>`);
    } else if (/^>\s?/.test(line)) {
      flushPara();
      if (list) { out.push('</ul>'); list = false; }
      if (!quote) { out.push('<blockquote>'); quote = true; }
      out.push('<p>' + inline(line.replace(/^>\s?/, '')) + '</p>');
    } else if (/^[-*]\s+/.test(line)) {
      flushPara();
      if (quote) { out.push('</blockquote>'); quote = false; }
      if (!list) { out.push('<ul>'); list = true; }
      out.push('<li>' + inline(line.replace(/^[-*]\s+/, '')) + '</li>');
    } else if (/^(---|\*\*\*)$/.test(line)) {
      closeBlocks();
      out.push('<hr>');
    } else if (line === '') {
      closeBlocks();
    } else {
      if (quote) { out.push('</blockquote>'); quote = false; }
      if (list) { out.push('</ul>'); list = false; }
      para.push(line.trim());
    }
  }
  closeBlocks();
  return out.join('\n');
}

// Pull **Q** / answer pairs out of the FAQ section for FAQPage JSON-LD.
function extractFaq(md) {
  const sec = md.split(/^##\s+Frequently Asked Questions\s*$/m)[1];
  if (!sec) return [];
  const body = sec.split(/^##\s+/m)[0];
  const faqs = [];
  const re = /\*\*(.+?)\*\*\s*\n([\s\S]+?)(?=\n\*\*|\n##|\n---|$)/g;
  let m;
  while ((m = re.exec(body))) {
    const q = m[1].trim(), a = m[2].trim().replace(/\s+/g, ' ');
    if (q.length > 5 && a.length > 20) faqs.push({ q, a });
  }
  return faqs;
}

function jsonLd(meta, url, faqs) {
  const article = {
    '@context': 'https://schema.org', '@type': 'Article',
    headline: meta.title, description: meta.meta_description,
    author: { '@type': 'Organization', name: meta.author },
    reviewedBy: { '@type': 'Person', name: meta.reviewer },
    publisher: { '@type': 'Organization', name: 'Bible Copilot',
      logo: { '@type': 'ImageObject', url: `${BASE}/og-image.png` } },
    url, datePublished: meta.date || new Date().toISOString().slice(0, 10),
    dateModified: meta.date || new Date().toISOString().slice(0, 10),
    mainEntityOfPage: url,
    isAccessibleForFree: true,
  };
  const breadcrumb = {
    '@context': 'https://schema.org', '@type': 'BreadcrumbList',
    itemListElement: [
      { '@type': 'ListItem', position: 1, name: 'Home', item: `${BASE}/` },
      { '@type': 'ListItem', position: 2, name: 'Blog', item: `${BASE}/blog/` },
      { '@type': 'ListItem', position: 3, name: meta.title, item: url },
    ],
  };
  let s = `<script type="application/ld+json">${JSON.stringify(article)}</script>`;
  s += `\n  <script type="application/ld+json">${JSON.stringify(breadcrumb)}</script>`;
  if (faqs.length >= 3) {
    const faq = {
      '@context': 'https://schema.org', '@type': 'FAQPage',
      mainEntity: faqs.map(f => ({
        '@type': 'Question', name: f.q,
        acceptedAnswer: { '@type': 'Answer', text: f.a },
      })),
    };
    s += `\n  <script type="application/ld+json">${JSON.stringify(faq)}</script>`;
  }
  return s;
}

function validate(meta, body) {
  if (!meta.title) return 'missing title';
  if (!meta.meta_description) return 'missing meta_description';
  const slug = meta.slug || slugify(meta.title);
  if (!/^[a-z0-9-]{5,80}$/.test(slug)) return `bad slug: ${slug}`;
  if (fs.existsSync(path.join(BLOG, slug))) return `slug already published: ${slug}`;
  if (weeklyPublishedCount >= WEEKLY_NEW_PAGE_CAP) return `weekly new-page cap reached for ${CURRENT_WEEK}`;
  const authorization = approvedNewPage(meta);
  if (authorization.error) return authorization.error;
  if (meta.manifest_week !== CURRENT_WEEK) return `manifest_week must equal ${CURRENT_WEEK}`;
  if (meta.review_status !== 'approved') return 'review_status must be approved';
  if (!meta.reviewer || /pending|tbd|unknown/i.test(meta.reviewer)) return 'named reviewer identity missing';
  if (!meta.author || meta.author.length < 4) return 'author identity missing';
  if (!meta.creation_method || meta.creation_method.length < 30) return 'creation_method disclosure missing';
  if (!meta.distinct_value || meta.distinct_value.length < 40) return 'distinct_value evidence is too weak';
  if (!meta.source_references || meta.source_references.length < 20) return 'source_references missing';
  if (meta.distinct_value !== authorization.approval.distinctValue) return 'distinct_value does not match manifest';
  if (meta.title.length > 65) return `title too long: ${meta.title.length} characters`;
  if (meta.meta_description.length < 80 || meta.meta_description.length > 155) {
    return `meta_description must be 80-155 characters: ${meta.meta_description.length}`;
  }
  const words = body.split(/\s+/).length;
  if (words < 700) return `too short for governed review: ${words} words`;
  if (words > 1400) return `too long without a manifest exception: ${words} words`;
  if (/\[insert|TODO|\{\{/i.test(body)) return 'leftover template scaffolding';
  if (/^\s*(?:\*\*)?(?:meta description|keywords?|word count)(?:\*\*)?\s*:/im.test(body)) return 'authoring metadata is visible in body';
  const firstWords = body.split(/\s+/).slice(0, 120).join(' ');
  if (!/\*\*Short answer:\*\*/i.test(firstWords)) return 'direct Short answer is missing from the first 120 words';
  for (const section of ['context', 'cross-reference', 'apply']) {
    if (!new RegExp(`^#{2,3}.*${section}`, 'im').test(body)) return `required ${section} section missing`;
  }
  if (extractFaq(body).length < 3) return 'at least three substantive FAQs are required';
  if (!/\((?:WEB|KJV)\)/.test(body)) return 'quoted Scripture translation must be identified as WEB or KJV';
  if (/in today'?s (?:fast-paced|digital)|delve into|ever-evolving landscape|in conclusion|it is worth noting|at its core/i.test(body)) {
    return 'generic AI-pattern language detected';
  }
  const paragraphs = body.split(/\n\s*\n/).map(value => value.trim()).filter(value => value.length > 80);
  const normalizedParagraphs = paragraphs.map(value => qualityTokens(value).join(' '));
  if (new Set(normalizedParagraphs).size !== normalizedParagraphs.length) return 'repeated paragraph detected';
  const nearest = nearestPublishedPage(body);
  if (nearest && nearest.similarity >= authorization.threshold) {
    return `corpus similarity ${nearest.similarity.toFixed(3)} exceeds ${authorization.threshold} against ${nearest.slug}`;
  }
  return null;
}


// ---- verse-page enrichment: related links + YouTube Short embed (added 2026-07-05) ----
const BOT_LOGS = '/Users/carlosreyes/Desktop/Projects/Apps/BibleCopilot-tiktok-bot/logs';
function refSlugFromLabel(label) {
  const m = /((?:[1-3]\s)?[A-Za-z]+)\s(\d+):(\d+)/.exec(label || '');
  if (!m) return null;
  return `${m[1].toLowerCase().replace(/\s+/g, '-')}-${m[2]}-${m[3]}`;
}
function videoForSlug(slug) {
  // slug: what-does-<book>-<c>-<v>-mean -> match runs.jsonl label joined to youtube.jsonl by (date,type)
  const m = /^what-does-(.+)-mean$/.exec(slug);
  if (!m) return null;
  try {
    const runs = fs.readFileSync(path.join(BOT_LOGS, 'runs.jsonl'), 'utf8').trim().split('\n').map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean);
    const vids = fs.readFileSync(path.join(BOT_LOGS, 'youtube.jsonl'), 'utf8').trim().split('\n').map(l => { try { return JSON.parse(l); } catch { return null; } }).filter(Boolean).filter(v => v.posted);
    for (const r of runs) {
      if (refSlugFromLabel(r.label) === m[1]) {
        const v = vids.find(v => v.file === `${r.date}_${r.type}.mp4`);
        if (v) return { id: v.id, title: v.title || r.label, date: r.date };
      }
    }
  } catch { /* bot repo not present */ }
  return null;
}
function relatedVerseLinks(slug) {
  const all = fs.readdirSync(BLOG).filter(d => /^what-does-.+-mean$/.test(d) && d !== slug);
  if (!all.length) return '';
  const book = (/^what-does-([1-3]?-?[a-z]+)/.exec(slug) || [])[1];
  const sameBook = all.filter(d => book && d.startsWith(`what-does-${book}-`));
  const pick = [...new Set([...sameBook, ...all])].slice(0, 4);
  const nice = d => {
    const m = /^what-does-(.+)-(\d+)-(\d+)-mean$/.exec(d);
    if (!m) return d;
    const b = m[1].split('-').map(w => w[0].toUpperCase() + w.slice(1)).join(' ');
    return `What does ${b} ${m[2]}:${m[3]} mean?`;
  };
  return `\n<h2>Related verses</h2>\n<ul>\n` +
    pick.map(d => `  <li><a href="/blog/${d}/">${nice(d)}</a></li>`).join('\n') +
    `\n</ul>\n`;
}
function videoEmbed(v) {
  if (!v) return { html: '', ld: '' };
  const html = `\n<h2>Watch: this verse in 30 seconds</h2>\n` +
    `<div style="position:relative;padding-bottom:177%;max-width:340px;margin:0 auto">` +
    `<iframe src="https://www.youtube.com/embed/${v.id}" title="${v.title.replace(/"/g, '&quot;')}" ` +
    `style="position:absolute;top:0;left:0;width:100%;height:100%;border:0;border-radius:14px" ` +
    `allowfullscreen loading="lazy"></iframe></div>\n`;
  const ld = `\n  <script type="application/ld+json">` + JSON.stringify({
    '@context': 'https://schema.org', '@type': 'VideoObject',
    name: v.title, uploadDate: v.date,
    thumbnailUrl: `https://i.ytimg.com/vi/${v.id}/hqdefault.jpg`,
    embedUrl: `https://www.youtube.com/embed/${v.id}`,
    contentUrl: `https://youtube.com/shorts/${v.id}`,
    publisher: { '@type': 'Organization', name: 'Bible Copilot' },
  }) + `</script>`;
  return { html, ld };
}

function publishOne(file) {
  const raw = fs.readFileSync(path.join(INBOX, file), 'utf8');
  const parsed = parseFrontmatter(raw);
  if (!parsed) return { file, error: 'no frontmatter' };
  const { meta, body } = parsed;
  const error = validate(meta, body);
  if (error) return { file, error };

  const slug = meta.slug || slugify(meta.title);
  const url = `${BASE}/blog/${slug}/`;
  const minutes = Math.max(2, Math.round(body.split(/\s+/).length / 220));
  const faqs = extractFaq(body);
  const editorialNote = `<aside class="editorial-note"><strong>Editorial note:</strong> ` +
    `${esc(meta.author)}; reviewed by ${esc(meta.reviewer)}. ` +
    `${esc(meta.creation_method)}. <a href="/editorial-standards/">Editorial standards</a>.` +
    `<br><strong>Sources:</strong> ${esc(meta.source_references)}</aside>\n`;

  const isVerse = /^what-does-.+-mean$/.test(slug);
  const vid = isVerse ? videoForSlug(slug) : null;
  const embed = videoEmbed(vid);
  const related = isVerse ? relatedVerseLinks(slug) : '';
  const html = TEMPLATE
    .replaceAll('{{TITLE}}', esc(meta.title))
    .replaceAll('{{DESC}}', esc(meta.meta_description))
    .replaceAll('{{URL}}', url)
    .replaceAll('{{CATEGORY}}', esc(meta.category || 'Bible Study'))
    .replaceAll('{{MINUTES}}', String(minutes))
    .replaceAll('{{JSONLD}}', jsonLd(meta, url, faqs) + embed.ld)
    .replaceAll('{{BODY}}', editorialNote + mdToHtml(body) + embed.html + related);

  fs.mkdirSync(path.join(BLOG, slug), { recursive: true });
  fs.writeFileSync(path.join(BLOG, slug, 'index.html'), html);

  // sitemap: insert before </urlset>
  const entry = `<url><loc>${url}</loc><changefreq>weekly</changefreq><priority>0.8</priority></url>`;
  const sm = fs.readFileSync(SITEMAP, 'utf8');
  if (!sm.includes(`<loc>${url}</loc>`)) {
    fs.writeFileSync(SITEMAP, sm.replace('</urlset>', entry + '</urlset>'));
  }

  // blog index: insert a card before the first existing card
  const card = `  <a href="/blog/${slug}/" class="card" data-title="${esc(meta.title.toLowerCase())}">\n` +
               `    <h2>${esc(meta.title)}</h2>\n    <p>${esc(meta.meta_description)}</p>\n  </a>\n`;
  const idx = fs.readFileSync(BLOG_INDEX, 'utf8');
  const anchor = idx.indexOf('  <a href="/blog/');
  if (anchor !== -1 && !idx.includes(`href="/blog/${slug}/"`)) {
    fs.writeFileSync(BLOG_INDEX, idx.slice(0, anchor) + card + idx.slice(anchor));
  }

  fs.appendFileSync(DONE_LOG, `${meta.date || new Date().toISOString().slice(0, 10)}\t${slug}\t${meta.title}\n`);
  fs.renameSync(path.join(INBOX, file), path.join(PUBLISHED, file));
  weeklyPublishedCount++;
  return { file, slug, url };
}

const drafts = fs.readdirSync(INBOX).filter(f => f.endsWith('.md'));
const published = [], failed = [];
for (const f of drafts) {
  const r = publishOne(f);
  if (r.error) {
    failed.push(r);
    fs.renameSync(path.join(INBOX, f), path.join(NEEDS_REVIEW, f));
    fs.writeFileSync(path.join(NEEDS_REVIEW, f + '.reason.txt'), r.error);
  } else {
    published.push(r);
  }
}
console.log(`published: ${published.length}`);
published.forEach(p => console.log('  ' + p.url));
console.log(`needs-review: ${failed.length}`);
failed.forEach(p => console.log(`  ${p.file}: ${p.error}`));

// IndexNow: instant Bing indexing (Bing powers ChatGPT search). Fire-and-forget.
if (published.length) {
  const key = fs.readFileSync(path.join(ENGINE, 'indexnow-key.txt'), 'utf8').trim();
  fetch('https://api.indexnow.org/indexnow', {
    method: 'POST',
    headers: { 'Content-Type': 'application/json; charset=utf-8' },
    body: JSON.stringify({
      host: 'mybiblecopilot.com',
      key,
      keyLocation: `https://mybiblecopilot.com/${key}.txt`,
      urlList: published.map(p => p.url),
    }),
  }).then(r => console.log('indexnow:', r.status)).catch(e => console.log('indexnow failed:', e.message));
}
