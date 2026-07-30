import fs from "node:fs";
import path from "node:path";

const website = path.resolve(import.meta.dirname, "..");
const apps = {
  constitution: "6761391729",
  gita: "6761395731",
  stoic: "6761389396",
  torah: "6761395920",
  wisdom: "6761395984"
};
const failures = [];
let answerCount = 0;
let appStoreCount = 0;

function walk(directory) {
  if (!fs.existsSync(directory)) return [];
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const target = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(target) : [target];
  });
}

const homepage = fs.readFileSync(path.join(website, "index.html"), "utf8");
const sitemap = fs.readFileSync(path.join(website, "sitemap.xml"), "utf8");
for (const app of [...Object.keys(apps), "bible", "prayer"]) {
  if (!homepage.includes(`data-track="copilot_catalog_click" data-app="${app}"`)) failures.push(`Homepage catalog tracking missing for ${app}`);
}

for (const [app, appId] of Object.entries(apps)) {
  const hub = path.join(website, app, "answers", "index.html");
  if (!fs.existsSync(hub)) failures.push(`Answer hub missing for ${app}`);
  const hubHtml = fs.existsSync(hub) ? fs.readFileSync(hub, "utf8") : "";
  if (!hubHtml.includes(`<link rel="canonical" href="https://dailycopilots.com/${app}/answers/">`)) failures.push(`Answer hub canonical missing for ${app}`);
  if (!hubHtml.includes(`ct=dc_${app}_landing`)) failures.push(`Answer hub campaign missing for ${app}`);
  if (!sitemap.includes(`https://dailycopilots.com/${app}/answers/`)) failures.push(`Answer hub sitemap entry missing for ${app}`);
  for (const match of hubHtml.matchAll(/<script type="application\/ld\+json">([\s\S]*?)<\/script>/g)) {
    try { JSON.parse(match[1]); } catch { failures.push(`Answer hub JSON-LD invalid for ${app}`); }
  }
  const product = fs.readFileSync(path.join(website, app, "index.html"), "utf8");
  if (!product.includes(`href="/${app}/answers/"`)) failures.push(`Product-to-answer-hub link missing for ${app}`);
  const files = [
    ...walk(path.join(website, app, "answers")),
    ...walk(path.join(website, "es", app, "answers"))
  ].filter((file) => file.endsWith("index.html") && file !== hub);
  for (const file of files) {
    answerCount += 1;
    const html = fs.readFileSync(file, "utf8");
    const rel = path.relative(website, file);
    if ((html.match(new RegExp(`data-app-bridge="${app}"`, "g")) || []).length !== 1) failures.push(`${rel}: app bridge missing, duplicated, or wrong`);
    if (!html.includes(`href="/${app}/answers/"`)) failures.push(`${rel}: answer hub breadcrumb missing`);
    if (!html.includes('data-cta-location="answer_bridge"')) failures.push(`${rel}: bridge CTA tracking missing`);
    if (app === "constitution" && !html.includes("General educational information")) failures.push(`${rel}: Constitution disclaimer missing`);
  }
  const appHtmlFiles = [
    ...walk(path.join(website, app)),
    ...walk(path.join(website, "es", app))
  ].filter((item) => item.endsWith(".html"));
  for (const file of appHtmlFiles) {
    const html = fs.readFileSync(file, "utf8");
    for (const match of html.matchAll(/href="(https:\/\/apps\.apple\.com[^"]+)"/g)) {
      appStoreCount += 1;
      const href = match[1].replaceAll("&amp;", "&");
      const url = new URL(href);
      if (!url.pathname.includes(appId)) failures.push(`${path.relative(website, file)}: wrong App Store ID for ${app}`);
      if (url.searchParams.get("pt") !== "128532000") failures.push(`${path.relative(website, file)}: provider token missing or wrong`);
      if (!url.searchParams.get("ct")?.startsWith(`dc_${app}_`)) failures.push(`${path.relative(website, file)}: campaign token missing or wrong`);
      if (url.searchParams.get("mt") !== "8") failures.push(`${path.relative(website, file)}: media token missing or wrong`);
    }
  }
}

const conversion = fs.readFileSync(path.join(website, "assets", "conversion.js"), "utf8");
for (const event of ["copilot_catalog_click", "answer_landing_viewed", "app_bridge_viewed", "appstore_click", "pro_cta_click", "pricing_viewed"]) {
  if (!conversion.includes(event)) failures.push(`conversion.js missing ${event}`);
}

if (failures.length) {
  console.error(failures.join("\n"));
  process.exit(1);
}
console.log(JSON.stringify({ status: "passed", answerPages: answerCount, appStoreLinks: appStoreCount, apps: Object.keys(apps).length }, null, 2));
