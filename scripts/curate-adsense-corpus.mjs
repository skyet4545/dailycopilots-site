#!/usr/bin/env node

// A human-reviewed public corpus for AdSense. This intentionally withholds
// keyword-variant and generated long-tail pages from search until individually
// reviewed for distinct, original, reader-first value.
import fs from "node:fs";
import path from "node:path";

const root = path.resolve(process.argv[2] || "site-deploy");
const origin = "https://mybiblecopilot.com";
const keep = new Set([
  "/", "/privacy/", "/terms/", "/trust/", "/reviewers/", "/editorial-standards/",
  "/authors/bible-copilot-editorial-team/", "/research/ai-bible-study-accuracy-benchmark/",
  "/bible-study-app/", "/bible-study-app-for-beginners/", "/bible-study-app-for-pastors/",
  "/bible-study-tools/", "/ai-bible-study-app/", "/free-bible-study-app/", "/bible-verse-explanation/",
  "/bible-study-questions/", "/topical-bible-study/", "/small-group-bible-study/", "/greek-hebrew-bible-study/", "/bible-cross-references/", "/bible-verse-finder/",
  "/tools/", "/tools/verse-study/", "/tools/greek-hebrew-bible-study/", "/tools/cross-reference-explorer/", "/tools/topical-bible-study-planner/", "/tools/small-group-bible-study-builder/", "/tools/bible-study-questions-generator/",
  "/bible/", "/bible/psalm/", "/bible/matthew/", "/bible/proverbs/", "/bible/john/", "/bible/romans/", "/bible/isaiah/", "/bible/hebrews/", "/bible/ephesians/", "/bible/philippians/", "/bible/james/",
  "/compare/bible-copilot-vs-youversion/", "/compare/bible-copilot-vs-logos/", "/compare/bible-copilot-vs-blue-letter-bible/",
  "/blog/", "/blog/isaiah-432-meaning-when-you-pass-through-the-waters-explained/", "/blog/what-does-joel-2-25-mean/", "/blog/what-does-isaiah-43-1-mean/", "/blog/what-does-psalm-126-5-mean/", "/blog/story-of-david-and-goliath-explained/", "/blog/bible-copilot-vs-logos/", "/blog/best-bible-app-for-small-groups/", "/blog/bible-verses-about-spiritual-warfare/"
]);
function walk(dir) { return fs.readdirSync(dir, { withFileTypes: true }).flatMap(e => { const p = path.join(dir, e.name); return e.isDirectory() ? walk(p) : [p]; }); }
function urlFor(file) { const d = path.relative(root, path.dirname(file)).replaceAll(path.sep, "/"); return d ? `/${d}/` : "/"; }
function robots(html, value) { const tag = `<meta name="robots" content="${value}">`; return /<meta\s+name=["']robots["'][^>]*>/i.test(html) ? html.replace(/<meta\s+name=["']robots["'][^>]*>/i, tag) : html.replace(/<head([^>]*)>/i, `<head$1>${tag}`); }
const report = { indexable: [], noindex: [] };
for (const file of walk(root).filter(f => path.basename(f) === "index.html")) {
  const url = urlFor(file); const ok = keep.has(url); const html = robots(fs.readFileSync(file, "utf8"), ok ? "index, follow" : "noindex, follow");
  fs.writeFileSync(file, html); report[ok ? "indexable" : "noindex"].push(url);
}
fs.writeFileSync(path.join(root, "sitemap.xml"), `<?xml version="1.0" encoding="UTF-8"?>\n<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n${[...keep].sort().map(u => `  <url><loc>${origin}${u}</loc><lastmod>2026-08-15</lastmod></url>`).join("\n")}\n</urlset>\n`);
fs.writeFileSync(path.join(root, "adsense-curation-report.json"), `${JSON.stringify({ generatedAt: new Date().toISOString(), ...report }, null, 2)}\n`);
console.log(JSON.stringify({ indexable: report.indexable.length, noindex: report.noindex.length }, null, 2));
