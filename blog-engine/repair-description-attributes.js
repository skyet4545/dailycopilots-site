#!/usr/bin/env node
// Repair legacy, quoted HTML description attributes without changing article copy.
// Usage: node repair-description-attributes.js --site /path/to/site [--write]

const fs = require('node:fs');
const path = require('node:path');

const siteFlag = process.argv.indexOf('--site');
const site = siteFlag >= 0 ? process.argv[siteFlag + 1] : path.join(__dirname, '..', 'site-deploy');
if (!site || !fs.existsSync(path.join(site, 'blog'))) {
  throw new Error('Expected --site to identify a Bible Copilot static site checkout');
}
const write = process.argv.includes('--write');
const blog = path.join(site, 'blog');
const attributeLine = /^(\s*<meta (?:name="description"|property="og:description"|name="twitter:description") content=")(.*)(">\s*)$/gm;
const results = { site: path.resolve(site), mode: write ? 'write' : 'check', scanned: 0, affectedFiles: [], repairedAttributes: 0 };

for (const entry of fs.readdirSync(blog, { withFileTypes: true })) {
  if (!entry.isDirectory()) continue;
  const file = path.join(blog, entry.name, 'index.html');
  if (!fs.existsSync(file)) continue;
  results.scanned++;
  const before = fs.readFileSync(file, 'utf8');
  const after = before.replace(attributeLine, (line, prefix, value, suffix) => {
    if (!value.includes('"')) return line;
    results.repairedAttributes++;
    return prefix + value.replaceAll('"', '&quot;') + suffix;
  });
  if (after === before) continue;
  results.affectedFiles.push(path.relative(site, file));
  if (write) fs.writeFileSync(file, after);
}

console.log(JSON.stringify(results, null, 2));
if (!write && results.affectedFiles.length) process.exitCode = 1;
