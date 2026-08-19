#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const site = process.argv[2];
if (!site) throw new Error('Usage: node apply-monetization-redesign.js <site-deploy>');

const stylesheet = '<link rel="stylesheet" href="/assets/monetization.css">';
const stats = { scanned: 0, stylesheetAdded: 0, duplicateTrackingRemoved: 0, homepageUpdated: false, proUpdated: false };

function updateHtml(file) {
  let html = fs.readFileSync(file, 'utf8');
  const before = html;
  stats.scanned++;

  if (!html.includes('/assets/monetization.css')) {
    html = html.replace(/<\/head>/i, `${stylesheet}\n</head>`);
    stats.stylesheetAdded++;
  }

  const maintenance = /\s*<script data-maintenance="seo-maintenance-v1">[\s\S]*?<\/script>/gi;
  if (maintenance.test(html)) {
    html = html.replace(maintenance, '');
    stats.duplicateTrackingRemoved++;
  }

  if (file === path.join(site, 'index.html')) {
    html = html.replace(/<div>\s*<a href='\/pro\/'>Pro<\/a>[\s\S]*?<\/div>\s*<\/nav>/, `<div>
    <a href='/tools/verse-study/'>Study a Verse</a>
    <a href='/bible/'>Bible Studies</a>
    <a href='/blog/'>Answers</a>
    <a href='/pro/'>Pro</a>
    <a href='/about/'>About</a>
  </div>
</nav>`);
    html = html.replace(/<section class="hero">[\s\S]*?<\/section>\s*\n\s*<section class="features">/, `<section class="hero">
  <div class="badge">Verse-anchored Bible study</div>
  <h1>Understand any Bible verse.<br><span>Then go deeper.</span></h1>
  <p class="sub">Start with a free structured study, then use Bible Copilot on iPhone or iPad for Scripture-cited explanations across six guided modes.</p>
  <div class="hero-actions">
    <a href="/tools/verse-study/" class="cta" data-study-link data-cta-location="homepage_hero_tool">Study a verse free</a>
    <a href="https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373" class="cta-secondary" data-cta-location="homepage_hero_app">Get the iPhone app</a>
  </div>
  <div class="hero-proof"><span>No account required</span><span>5.0★ App Store rating</span><span>15 free questions daily</span></div>
</section>

<section class="features">`);
    stats.homepageUpdated = html !== before;
  }

  if (file === path.join(site, 'pro', 'index.html')) {
    html = html.replace('<div class="proof">Free tier · No account required · 1-week annual trial</div>', '<div class="proof">15 free questions daily · 1-week annual trial · Cancel through Apple</div>');
    html = html.replace('<section class="features">', '<section class="features" aria-label="Everything included with Bible Copilot Pro">');
    stats.proUpdated = html !== before;
  }

  if (html !== before) fs.writeFileSync(file, html);
}

function walk(dir) {
  for (const entry of fs.readdirSync(dir, { withFileTypes: true })) {
    const file = path.join(dir, entry.name);
    if (entry.isDirectory()) walk(file);
    else if (entry.isFile() && entry.name === 'index.html') updateHtml(file);
  }
}

walk(site);
console.log(JSON.stringify(stats, null, 2));
