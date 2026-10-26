#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const site = process.argv[2];
const source = process.argv[3];
if (!site || !source) throw new Error('Usage: node apply-original-language-tool.js <site-deploy> <tool-html>');

const destination = path.join(site, 'tools', 'greek-hebrew-bible-study', 'index.html');
fs.mkdirSync(path.dirname(destination), { recursive: true });
fs.copyFileSync(source, destination);

const hubFile = path.join(site, 'tools', 'index.html');
let hub = fs.readFileSync(hubFile, 'utf8');
const card = '<a class="card primary" data-study-link href="/tools/greek-hebrew-bible-study/"><span class="tag">Search-data winner</span><div class="icon">Α א</div><h2>Greek &amp; Hebrew Bible Explorer</h2><p>Explore key original-language words behind popular verses with transliteration, definitions, and context.</p></a>';
if (!hub.includes('/tools/greek-hebrew-bible-study/')) {
  hub = hub.replace('<main class="wrap"><div class="grid">', '<main class="wrap"><div class="grid">\n' + card);
  fs.writeFileSync(hubFile, hub);
}

const sitemapFile = path.join(site, 'sitemap.xml');
let sitemap = fs.readFileSync(sitemapFile, 'utf8');
if (!sitemap.includes('/tools/greek-hebrew-bible-study/')) {
  const entry = '  <url><loc>https://mybiblecopilot.com/tools/greek-hebrew-bible-study/</loc><lastmod>2026-07-15</lastmod><changefreq>weekly</changefreq><priority>0.9</priority></url>\n';
  sitemap = sitemap.replace('</urlset>', entry + '</urlset>');
  fs.writeFileSync(sitemapFile, sitemap);
}

console.log(JSON.stringify({ destination, hubLinked: hub.includes('/tools/greek-hebrew-bible-study/'), sitemapAdded: sitemap.includes('/tools/greek-hebrew-bible-study/') }, null, 2));
