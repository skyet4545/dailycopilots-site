#!/usr/bin/env node

const fs = require('fs');
const path = require('path');

const root = process.env.SITE_ROOT
  ? path.join(process.env.SITE_ROOT, 'blog')
  : path.join(__dirname, '..', 'site-deploy', 'blog');
const write = process.argv.includes('--write');

function plain(value) {
  return value
    .replace(/<[^>]+>/g, ' ')
    .replace(/&(?:nbsp|amp|quot|#39);/g, ' ')
    .replace(/\s+/g, ' ')
    .trim();
}

function descriptionFor(html) {
  const paragraphs = [...html.matchAll(/<p(?:\s[^>]*)?>([\s\S]*?)<\/p>/gi)]
    .map((match) => plain(match[1]))
    .filter((value) => value.length >= 80);
  const title = plain((html.match(/<title>([\s\S]*?)<\/title>/i) || [])[1] || '')
    .replace(/\s*\|\s*Bible Copilot\s*$/i, '');
  const source = paragraphs[0] || `Explore the meaning, context, original language, and practical application of ${title} with Bible Copilot.`;
  return (source.length > 158 ? `${source.slice(0, 155).replace(/\s+\S*$/, '')}...` : source)
    .replaceAll('"', '&quot;');
}

let scanned = 0;
let changed = 0;
for (const entry of fs.readdirSync(root, { withFileTypes: true })) {
  if (!entry.isDirectory()) continue;
  const file = path.join(root, entry.name, 'index.html');
  if (!fs.existsSync(file)) continue;
  const before = fs.readFileSync(file, 'utf8');
  scanned++;
  const current = before.match(/<meta name="description" content="([^"]*)"/i)?.[1];
  if (current == null || current.trim()) continue;
  const description = descriptionFor(before);
  const after = before
    .replace(/(<meta name="description" content=")[^"]*(")/i, `$1${description}$2`)
    .replace(/(<meta property="og:description" content=")[^"]*(")/i, `$1${description}$2`)
    .replace(/(<meta name="twitter:description" content=")[^"]*(")/i, `$1${description}$2`)
    .replace(/("description"\s*:\s*")[^"]*(")/i, `$1${description.replaceAll('&quot;', '\\"')}$2`);
  if (after === before) continue;
  changed++;
  if (write) fs.writeFileSync(file, after);
}

console.log(JSON.stringify({ scanned, changed, mode: write ? 'write' : 'check' }, null, 2));
