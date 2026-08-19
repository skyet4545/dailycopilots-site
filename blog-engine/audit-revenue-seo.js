const fs = require('fs');
const path = require('path');

const site = process.argv[2];
const output = process.argv[3];
if (!site || !output) throw new Error('Usage: node audit-revenue-seo.js <site-deploy> <output.csv>');

const pages = [];
function text(value = '') { return value.replace(/<[^>]+>/g, ' ').replace(/&[^;]+;/g, ' ').replace(/\s+/g, ' ').trim(); }
function match(html, pattern) { return (html.match(pattern) || [])[1] || ''; }
function intent(url) {
  if (url === '/' || url.startsWith('/tools/verse-study')) return 'product';
  if (/\/(best-|[^/]+-vs-|[^/]+-alternatives|bible-app-for-|best-bible-app)/.test(url)) return 'product';
  if (url.startsWith('/tools/') || /(greek|hebrew|original-language)/.test(url)) return 'mixed';
  return 'informational';
}
function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    if (entry.name.startsWith('deploy-') || entry.name === 'node_modules') continue;
    const filename = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(filename);
    if (!entry.isFile() || entry.name !== 'index.html') continue;
    const html = fs.readFileSync(filename, 'utf8');
    const relative = path.relative(site, path.dirname(filename));
    const url = relative ? '/' + relative.split(path.sep).join('/') + '/' : '/';
    const title = text(match(html, /<title>([\s\S]*?)<\/title>/i));
    const h1 = text(match(html, /<h1[^>]*>([\s\S]*?)<\/h1>/i));
    const canonical = match(html, /<link[^>]+rel=["']canonical["'][^>]+href=["']([^"']+)/i) || match(html, /<link[^>]+href=["']([^"']+)["'][^>]+rel=["']canonical["']/i);
    const body = text(match(html, /<body[^>]*>([\s\S]*?)<\/body>/i));
    pages.push({ filename, url, title, h1, canonical, words: body ? body.split(' ').length : 0, internalLinks: (html.match(/href=["'](?:\/|https:\/\/mybiblecopilot\.com)/g) || []).length, appStoreLinks: (html.match(/id6758913373/g) || []).length, noindex: /noindex/i.test(match(html, /<meta[^>]+name=["']robots["'][^>]+content=["']([^"']+)/i)), intent: intent(url) });
  }
}
walk(site);

const titleCounts = new Map();
for (const page of pages) titleCounts.set(page.title, (titleCounts.get(page.title) || 0) + 1);
function recommendation(page) {
  if (page.noindex) return 'review_noindex';
  if (!page.canonical) return 'add_canonical';
  if (!page.h1 || !page.title) return 'repair_metadata';
  if (titleCounts.get(page.title) > 1) return 'consolidate_duplicate_title';
  if (page.words < 450) return 'review_thin_content';
  if (page.internalLinks < 3) return 'add_internal_links';
  return page.intent === 'product' ? 'improve_pro_conversion' : 'keep_and_optimize';
}
function csv(value) { return '"' + String(value).replace(/"/g, '""') + '"'; }
const headers = ['url','title','h1','monetization_intent','word_count','internal_links','app_store_links','canonical','noindex','duplicate_title_count','recommended_action'];
const rows = pages.sort((a,b)=>a.url.localeCompare(b.url)).map(page => [page.url,page.title,page.h1,page.intent,page.words,page.internalLinks,page.appStoreLinks,page.canonical,page.noindex,titleCounts.get(page.title),recommendation(page)]);
fs.mkdirSync(path.dirname(output), { recursive: true });
fs.writeFileSync(output, [headers, ...rows].map(row => row.map(csv).join(',')).join('\n') + '\n');
const summary = rows.reduce((acc,row)=>{acc[row[10]]=(acc[row[10]]||0)+1;return acc},{});
console.log(JSON.stringify({ pages: pages.length, summary }, null, 2));
