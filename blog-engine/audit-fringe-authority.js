#!/usr/bin/env node
/*
 * Read-only GSC opportunity audit for Bible Copilot.
 *
 * It deliberately does not write drafts, modify a backlog, or publish. A
 * query family is only a research lead until a human-reviewed authority
 * manifest supplies source provenance, distinct value, corpus similarity,
 * and live canonical verification.
 *
 * Usage:
 *   node audit-fringe-authority.js <gsc-query-page-baseline.json> [site-deploy]
 */
const fs = require('fs');
const path = require('path');

const baselinePath = process.argv[2];
const sitePath = process.argv[3] || path.join(__dirname, '..', 'site-deploy');
if (!baselinePath || !fs.existsSync(baselinePath)) {
  throw new Error('Pass an existing GSC query/page baseline JSON file.');
}

const BASE = 'https://mybiblecopilot.com';
const PUBLISHED = path.join(__dirname, 'inbox', 'published');
const STOP = new Set('a an and are as at be bible does for from god gods how in is it meaning of on or scripture that the this to verse verses what with your'.split(' '));
const normalize = value => String(value || '').toLowerCase()
  .replace(/['’]/g, '').replace(/[^a-z0-9]+/g, ' ').trim();
const slugify = value => normalize(value).replace(/\s+/g, '-');
const tokens = value => normalize(value).split(' ').filter(token => token.length > 2 && !STOP.has(token));
const frontmatter = raw => {
  const match = raw.match(/^---\n([\s\S]*?)\n---/);
  const meta = {};
  if (!match) return meta;
  for (const line of match[1].split('\n')) {
    const pair = line.match(/^(\w[\w_]*):\s*(.*)$/);
    if (pair) meta[pair[1]] = pair[2].replace(/^['"]|['"]$/g, '').trim();
  }
  return meta;
};
const sourceCorpus = fs.readdirSync(PUBLISHED).filter(file => file.endsWith('.md')).map(file => {
  const meta = frontmatter(fs.readFileSync(path.join(PUBLISHED, file), 'utf8'));
  return { file, slug: meta.slug || path.basename(file, '.md'), title: meta.title || '', keywords: meta.keywords || '' };
});

function staticCorpus(site) {
  const blog = path.join(site, 'blog');
  if (!fs.existsSync(blog)) return [];
  return fs.readdirSync(blog, { withFileTypes: true }).filter(entry => entry.isDirectory()).flatMap(entry => {
    const file = path.join(blog, entry.name, 'index.html');
    if (!fs.existsSync(file)) return [];
    const html = fs.readFileSync(file, 'utf8');
    const title = (html.match(/<title>([\s\S]*?)<\/title>/i) || [])[1] || '';
    const description = (html.match(/<meta\s+name=["']description["']\s+content=["']([^"']*)/i) || [])[1] || '';
    return [{ file, slug: entry.name, title, keywords: description }];
  });
}
const corpusBySlug = new Map();
for (const page of [...sourceCorpus, ...staticCorpus(sitePath)]) {
  const current = corpusBySlug.get(page.slug);
  corpusBySlug.set(page.slug, current
    ? { ...current, title: current.title || page.title, keywords: `${current.keywords} ${page.keywords}`.trim() }
    : page);
}
const corpus = [...corpusBySlug.values()];

const redirects = new Map();
const redirectsPath = path.join(sitePath, '_redirects');
if (fs.existsSync(redirectsPath)) {
  for (const line of fs.readFileSync(redirectsPath, 'utf8').split('\n')) {
    const match = line.trim().match(/^(\/\S+)\s+(\/\S+)\s+(?:301|308)(?:\s|$)/);
    if (match) redirects.set(match[1].replace(/\/$/, '') + '/', match[2].replace(/\/$/, '') + '/');
  }
}
function resolveLocalRedirect(url) {
  let pathname;
  try { pathname = new URL(url).pathname.replace(/\/$/, '') + '/'; } catch { return null; }
  const seen = new Set();
  while (redirects.has(pathname) && !seen.has(pathname)) {
    seen.add(pathname); pathname = redirects.get(pathname);
  }
  return seen.size ? `${BASE}${pathname}` : null;
}
function sourceOwner(query) {
  const queryTokens = new Set(tokens(query));
  if (!queryTokens.size) return null;
  const scored = corpus.map(page => {
    const haystack = new Set(tokens(`${page.slug} ${page.title} ${page.keywords}`));
    const overlap = [...queryTokens].filter(token => haystack.has(token)).length;
    return { page, overlap, score: overlap / queryTokens.size };
  }).sort((a, b) => b.score - a.score || b.overlap - a.overlap);
  const winner = scored[0];
  return winner && winner.overlap >= 2 && winner.score >= 0.5 ? winner : null;
}
function landingAppearsToOwnQuery(query, landingUrl) {
  if (!landingUrl) return false;
  const queryTerms = tokens(query);
  let pathname = '';
  try { pathname = new URL(landingUrl).pathname; } catch { return false; }
  const normalizedPath = normalize(pathname);
  const compactQuery = normalize(query).replace(/\s+/g, '');
  const compactPath = normalizedPath.replace(/\s+/g, '');
  // Captures reference variants such as "Isaiah 43 2" -> "isaiah-432-..."
  // and transliterated phrases already named by the landing-page slug.
  if (compactQuery.length >= 7 && compactPath.includes(compactQuery)) return true;
  return queryTerms.length >= 2
    && queryTerms.filter(term => normalizedPath.includes(term)).length / queryTerms.length >= 0.7;
}
function isExistingBlogLanding(url) {
  try { return new URL(url).origin === BASE && /^\/blog\/[^/]+\/$/.test(new URL(url).pathname); } catch { return false; }
}

const baseline = JSON.parse(fs.readFileSync(baselinePath, 'utf8'));
if (!Array.isArray(baseline.rows) || !baseline.rows.every(row => row.query && row.page)) {
  throw new Error('Baseline must contain query/page rows from Search Console.');
}
const families = new Map();
for (const row of baseline.rows) {
  const query = normalize(row.query);
  if (!query) continue;
  const family = families.get(query) || { query, impressions: 0, clicks: 0, weightedPosition: 0, pages: new Map() };
  const impressions = Number(row.impressions || 0);
  family.impressions += impressions;
  family.clicks += Number(row.clicks || 0);
  family.weightedPosition += Number(row.position || 0) * impressions;
  const landing = family.pages.get(row.page) || { url: row.page, impressions: 0, clicks: 0 };
  landing.impressions += impressions; landing.clicks += Number(row.clicks || 0);
  family.pages.set(row.page, landing); families.set(query, family);
}
const qualified = [...families.values()].map(family => {
  const position = family.impressions ? family.weightedPosition / family.impressions : 0;
  const landings = [...family.pages.values()].sort((a, b) => b.impressions - a.impressions);
  const primary = landings[0];
  const redirectedTo = primary ? resolveLocalRedirect(primary.url) : null;
  const owner = sourceOwner(family.query);
  let action = 'hold_for_manual_intent_review';
  if (redirectedTo) action = 'canonical_consolidation_required';
  else if (owner || landingAppearsToOwnQuery(family.query, primary?.url) || isExistingBlogLanding(primary?.url)) action = 'existing_page_uplift';
  const researchLead = action === 'hold_for_manual_intent_review' && family.impressions >= 20;
  return {
    query: family.query, impressions: family.impressions, clicks: family.clicks,
    position: Number(position.toFixed(2)), primaryLandingPage: primary?.url || null,
    localRedirectTarget: redirectedTo, sourceOwner: owner ? { slug: owner.page.slug, title: owner.page.title, lexicalMatch: Number(owner.score.toFixed(2)) } : null,
    action, researchLead,
    releaseGate: researchLead
      ? 'Not a draft authorization: verify live canonical/status, source plan, distinct value, corpus similarity, doctrine/editorial review, and manifest approval.'
      : 'Do not create a new URL from this row; resolve the assigned action first.'
  };
}).filter(item => item.impressions >= 3 && item.position >= 8 && item.position <= 20)
  .sort((a, b) => b.impressions - a.impressions || a.position - b.position);

const count = action => qualified.filter(item => item.action === action).length;
const report = {
  schemaVersion: 1,
  purpose: 'Read-only fringe-authority audit; not a publishing manifest.',
  evidence: { baselinePath: path.resolve(baselinePath), collectedAt: baseline.collected_at, range: baseline.range, rows: baseline.rows.length },
  corpus: { publishedSourceFiles: sourceCorpus.length, publishedCorpusRecords: corpus.length, localRedirectRules: redirects.size, localSitePath: path.resolve(sitePath), localDataWarning: 'Redirect results are local evidence and must be verified live before release.' },
  thresholds: { minImpressions: 3, positionRange: '8-20', netNewResearchLeadMinImpressions: 20 },
  summary: {
    qualifiedQueryFamilies: qualified.length,
    canonicalConsolidationRequired: count('canonical_consolidation_required'),
    existingPageUplift: count('existing_page_uplift'),
    manualIntentReview: count('hold_for_manual_intent_review'),
    netNewResearchLeads: qualified.filter(item => item.researchLead).length,
    authorizedNewPages: 0
  },
  opportunities: qualified
};
process.stdout.write(JSON.stringify(report, null, 2) + '\n');
