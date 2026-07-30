import fs from "node:fs";
import path from "node:path";

const website = path.resolve(import.meta.dirname, "..");
const providerToken = "128532000";

const apps = {
  constitution: {
    label: "Constitution Copilot",
    appId: "6761391729",
    accent: "#a01d2e",
    tint: "#f7e9eb",
    hubTitle: "U.S. Constitution answers",
    hubDescription: "Source-backed answers about constitutional clauses, amendments, federal powers, landmark cases, and the Federalist Papers.",
    bridge: "Compare the constitutional text, historical context, and leading cases for your exact question.",
    prompts: ["Which enumerated power supports this law?", "How did the Supreme Court interpret this issue?", "What arguments exist on both sides?"],
    bridgeEs: "Compara el texto constitucional, el contexto histórico y los casos principales relacionados con tu pregunta.",
    promptsEs: ["¿Qué poder enumerado respalda esta ley?", "¿Cómo interpretó la Corte Suprema este asunto?", "¿Qué argumentos existen en ambos lados?"],
    disclaimer: "General educational information, not legal advice.",
    disclaimerEs: "Información educativa general; no es asesoría legal."
  },
  gita: {
    label: "Gita Copilot",
    appId: "6761395731",
    accent: "#c85f1c",
    tint: "#fbe9dc",
    hubTitle: "Bhagavad Gita answers",
    hubDescription: "Source-backed answers about Bhagavad Gita verses, Sanskrit terms, yoga, dharma, karma, devotion, and interpretation.",
    bridge: "Ask about a verse, a Sanskrit term, its place in the dialogue, or how major interpretations differ.",
    prompts: ["What does the Sanskrit word mean here?", "How does this connect to another chapter?", "How can I apply this teaching without oversimplifying it?"],
    bridgeEs: "Pregunta por un verso, un término sánscrito, su lugar en el diálogo o las diferencias entre interpretaciones principales.",
    promptsEs: ["¿Qué significa aquí esta palabra sánscrita?", "¿Cómo se relaciona con otro capítulo?", "¿Cómo puedo aplicar esta enseñanza sin simplificarla demasiado?"]
  },
  stoic: {
    label: "Stoic Copilot",
    appId: "6761389396",
    accent: "#a06b2c",
    tint: "#f6ece0",
    hubTitle: "Stoic philosophy answers",
    hubDescription: "Source-backed answers about Marcus Aurelius, Epictetus, Seneca, Stoic practice, virtue, judgment, desire, and action.",
    bridge: "Ask how Marcus Aurelius, Epictetus, and Seneca explain the idea—and how it applies to your situation.",
    prompts: ["Which primary text is this idea from?", "How would another Stoic frame it?", "What would practicing this look like today?"],
    bridgeEs: "Pregunta cómo explican esta idea Marco Aurelio, Epicteto y Séneca, y cómo se aplica a tu situación.",
    promptsEs: ["¿De qué texto primario proviene esta idea?", "¿Cómo la plantearía otro estoico?", "¿Cómo sería practicarla hoy?"]
  },
  torah: {
    label: "Torah Copilot",
    appId: "6761395920",
    accent: "#a8850f",
    tint: "#f9f3d9",
    hubTitle: "Torah study answers",
    hubDescription: "Source-backed answers about Torah text, Hebrew, pshat, classical commentators, mitzvot, parsha, and Jewish tradition.",
    bridge: "Ask about the Hebrew, the plain meaning, and how classical commentators understand the passage.",
    prompts: ["What does the Hebrew phrase mean?", "How do Rashi and other commentators differ?", "Where else does the Torah address this idea?"]
  },
  wisdom: {
    label: "Wisdom Copilot",
    appId: "6761395984",
    accent: "#2f8560",
    tint: "#e4f3ec",
    hubTitle: "Timeless wisdom answers",
    hubDescription: "Source-backed comparisons across Stoicism, Scripture, Buddhist thought, classical philosophy, and other wisdom traditions.",
    bridge: "Compare traditions carefully and bring their ideas into a real decision, emotion, relationship, or season of life.",
    prompts: ["Where do these traditions genuinely agree?", "Where do their assumptions differ?", "How can I apply this without flattening the traditions?"]
  }
};

function walk(directory) {
  if (!fs.existsSync(directory)) return [];
  return fs.readdirSync(directory, { withFileTypes: true }).flatMap((entry) => {
    const target = path.join(directory, entry.name);
    return entry.isDirectory() ? walk(target) : [target];
  });
}

function htmlEscape(value) {
  return value.replaceAll("&", "&amp;").replaceAll("<", "&lt;").replaceAll(">", "&gt;").replaceAll('"', "&quot;");
}

function updateAppStoreHref(rawHref, app, placement) {
  const decoded = rawHref.replaceAll("&amp;", "&");
  const url = new URL(decoded);
  url.search = "";
  url.searchParams.set("pt", providerToken);
  url.searchParams.set("ct", `dc_${app}_${placement}`);
  url.searchParams.set("mt", "8");
  return url.toString().replaceAll("&", "&amp;");
}

function addTrackingAttributes(anchor, app, location, contentId = "") {
  let updated = anchor.replace(/\sdata-(?:app|cta-location|content-id)="[^"]*"/g, "");
  const attributes = ` data-app="${app}" data-cta-location="${location}"${contentId ? ` data-content-id="${contentId}"` : ""}`;
  return updated.replace("<a ", `<a${attributes} `);
}

function bridgeMarkup(appKey, config, contentId, language) {
  const isSpanish = language === "es";
  const prompts = isSpanish && config.promptsEs ? config.promptsEs : config.prompts;
  const bridge = isSpanish && config.bridgeEs ? config.bridgeEs : config.bridge;
  const disclaimer = isSpanish && config.disclaimerEs ? config.disclaimerEs : config.disclaimer;
  const list = prompts.map((prompt) => `<li>${htmlEscape(prompt)}</li>`).join("");
  const href = `https://apps.apple.com/us/app/${appKey}-copilot/id${config.appId}?pt=${providerToken}&amp;ct=dc_${appKey}_answer&amp;mt=8`;
  return `<section class="app-bridge" data-app-bridge="${appKey}" data-content-id="${contentId}">
  <div class="eyebrow">${isSpanish ? `Continúa esta pregunta en ${config.label}` : `Continue this question in ${config.label}`}</div>
  <h2>${isSpanish ? "¿Tienes otra pregunta sobre este tema?" : "Have a follow-up about this?"}</h2>
  <p>${bridge}</p>
  <ul>${list}</ul>
  <a class="app-bridge-cta" data-app="${appKey}" data-cta-location="answer_bridge" data-content-id="${contentId}" href="${href}">${isSpanish ? `Pregúntale a ${config.label} — empieza gratis →` : `Ask ${config.label} — free to start →`}</a>
  <p class="micro">${isSpanish ? "Sin cuenta · iPhone y iPad" : "No account required · iPhone &amp; iPad"}</p>${disclaimer ? `\n  <p class="disclaimer">${disclaimer}</p>` : ""}
 </section>`;
}

function updateAnswerPage(file, appKey, config, language) {
  const contentId = path.basename(path.dirname(file));
  let html = fs.readFileSync(file, "utf8");
  html = html.replace(/\n?<section class="app-bridge"[\s\S]*?<\/section>\n?/g, "\n");
  if (!html.includes("/assets/answer-journey.css")) {
    html = html.replace("</head>", '<link rel="stylesheet" href="/assets/answer-journey.css?v=20260730-1">\n</head>');
  }
  const breadcrumb = `<nav class="answer-breadcrumb" aria-label="Breadcrumb"><a href="/">Daily Copilots</a><span>›</span><a href="/${appKey}/">${config.label}</a><span>›</span><a href="/${appKey}/answers/">Answers</a></nav>`;
  html = html.replace(/<div class="top"><a[^>]*>[\s\S]*?<\/a><\/div>/, breadcrumb);
  html = html.replace(/(<div class="cite">[\s\S]*?<\/div>)/, `$1\n ${bridgeMarkup(appKey, config, contentId, language)}`);
  html = html.replace(/<a class="cta"[^>]*href="([^"]*apps\.apple\.com[^"]*)"[^>]*>/g, (anchor) => {
    const hrefMatch = anchor.match(/href="([^"]*)"/);
    if (!hrefMatch) return anchor;
    let updated = anchor.replace(hrefMatch[1], updateAppStoreHref(hrefMatch[1], appKey, "answer"));
    return addTrackingAttributes(updated, appKey, "answer_badge", contentId);
  });
  html = html.replace(/<html lang="[^"]*">/, `<html lang="${language}">`);
  html = html.replace(/^[ \t]+$/gm, "");
  fs.writeFileSync(file, html);
}

function answerRecords(appKey, config) {
  const directory = path.join(website, appKey, "answers");
  const hub = path.join(directory, "index.html");
  return walk(directory).filter((file) => file.endsWith("index.html") && file !== hub).map((file) => {
    const html = fs.readFileSync(file, "utf8");
    const title = html.match(/<h1>([\s\S]*?)<\/h1>/)?.[1]?.replace(/<[^>]+>/g, "").trim() || path.basename(path.dirname(file));
    return { title, slug: path.basename(path.dirname(file)) };
  }).sort((a, b) => a.title.localeCompare(b.title));
}

function hubMarkup(appKey, config, records) {
  const items = records.map((record) => `<a class="question" href="/${appKey}/answers/${record.slug}/">${htmlEscape(record.title)}<span>Read answer →</span></a>`).join("\n   ");
  const itemList = JSON.stringify({
    "@context": "https://schema.org",
    "@type": "CollectionPage",
    name: `${config.label} Answers`,
    url: `https://dailycopilots.com/${appKey}/answers/`,
    description: config.hubDescription,
    mainEntity: {
      "@type": "ItemList",
      itemListElement: records.map((record, index) => ({
        "@type": "ListItem",
        position: index + 1,
        name: record.title,
        url: `https://dailycopilots.com/${appKey}/answers/${record.slug}/`
      }))
    }
  });
  const appHref = `https://apps.apple.com/us/app/${appKey}-copilot/id${config.appId}?pt=${providerToken}&amp;ct=dc_${appKey}_landing&amp;mt=8`;
  return `<!doctype html><html lang="en"><head>
<meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1">
<title>${config.hubTitle} | ${config.label}</title>
<meta name="description" content="${config.hubDescription}">
<link rel="canonical" href="https://dailycopilots.com/${appKey}/answers/">
<meta property="og:title" content="${config.hubTitle} | ${config.label}"><meta property="og:description" content="${config.hubDescription}"><meta property="og:type" content="website"><meta property="og:url" content="https://dailycopilots.com/${appKey}/answers/">
<script type="application/ld+json">${itemList}</script>
<link rel="preconnect" href="https://fonts.googleapis.com"><link rel="preconnect" href="https://fonts.gstatic.com" crossorigin>
<link href="https://fonts.googleapis.com/css2?family=Sora:wght@600;700;800&family=Plus+Jakarta+Sans:wght@400;500;600;700&display=swap" rel="stylesheet">
<style>
:root{--bg:#faf8f3;--surface:#fff;--ink:#181510;--ink-soft:#5b574d;--muted:#918c7d;--border:#eae6da;--acc:${config.accent};--acc-tint:${config.tint}}*{box-sizing:border-box;margin:0;padding:0}body{font-family:'Plus Jakarta Sans',sans-serif;background:var(--bg);color:var(--ink);line-height:1.55}.wrap{max-width:900px;margin:0 auto;padding:0 24px}.crumb{padding:24px 0;font-size:13px}.crumb a{color:var(--muted);text-decoration:none;font-weight:700}.hero{padding:34px 0 28px}.eyebrow{color:var(--acc);font-weight:800;text-transform:uppercase;letter-spacing:.1em;font-size:11px;margin-bottom:12px}h1{font-family:'Sora',sans-serif;font-size:42px;line-height:1.12;letter-spacing:-.025em;margin-bottom:15px}.intro{font-size:18px;color:var(--ink-soft);max-width:690px}.actions{display:flex;gap:12px;flex-wrap:wrap;margin-top:24px}.primary,.secondary{display:inline-flex;padding:12px 18px;border-radius:12px;text-decoration:none;font-weight:800;font-size:14px}.primary{background:var(--acc);color:white}.secondary{background:var(--acc-tint);color:var(--acc)}.questions{display:grid;grid-template-columns:1fr 1fr;gap:12px;padding:24px 0 60px}.question{display:flex;flex-direction:column;justify-content:space-between;min-height:126px;padding:19px;background:var(--surface);border:1px solid var(--border);border-radius:16px;color:var(--ink);text-decoration:none;font-weight:700}.question:hover{border-color:var(--acc);transform:translateY(-2px)}.question span{margin-top:14px;color:var(--acc);font-size:12px}footer{padding:0 0 50px;text-align:center;color:var(--muted);font-size:12px}@media(max-width:650px){h1{font-size:32px}.questions{grid-template-columns:1fr}}
</style><script async src="https://www.googletagmanager.com/gtag/js?id=G-77KV1K7WK6"></script>
<script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments);}gtag('js',new Date());gtag('config','G-77KV1K7WK6');</script>
<script defer src="/assets/conversion.js"></script></head><body><div class="wrap">
 <div class="crumb"><a href="/">Daily Copilots</a> · <a href="/${appKey}/">${config.label}</a></div>
 <main><section class="hero"><div class="eyebrow">${config.label} answer library</div><h1>${config.hubTitle}</h1><p class="intro">${config.hubDescription} Start with a question below, then continue with your own follow-up in the app.</p><div class="actions"><a class="primary" data-app="${appKey}" data-cta-location="answer_hub_hero" href="${appHref}">Ask ${config.label} — free to start →</a><a class="secondary" href="/${appKey}/">See how ${config.label} works</a></div></section>
  <section class="questions" aria-label="${config.label} questions">${items}</section></main>
 <footer>Part of <a href="/" style="color:var(--acc)">Daily Copilots</a> · Republic Publishing.${config.disclaimer ? ` ${config.disclaimer}` : ""}</footer>
</div></body></html>`;
}

function updateProductPage(appKey, config, placement) {
  const file = path.join(website, appKey, placement === "pro" ? "pro/index.html" : "index.html");
  let html = fs.readFileSync(file, "utf8");
  html = html.replace(/<a class="cta"[^>]*href="([^"]*apps\.apple\.com[^"]*)"[^>]*>/g, (anchor) => {
    const hrefMatch = anchor.match(/href="([^"]*)"/);
    if (!hrefMatch) return anchor;
    let updated = anchor.replace(hrefMatch[1], updateAppStoreHref(hrefMatch[1], appKey, placement === "pro" ? "pro" : "landing"));
    return addTrackingAttributes(updated, appKey, placement === "pro" ? "pro_badge" : "product_badge");
  });
  if (placement === "landing" && !html.includes(`href="/${appKey}/answers/"`)) {
    if (!html.includes("/assets/answer-journey.css")) {
      html = html.replace("</head>", '<link rel="stylesheet" href="/assets/answer-journey.css?v=20260730-1">\n</head>');
    }
    html = html.replace(/(<div class="offerteaser">[\s\S]*?<\/div>)/, `$1\n  <div class="answer-hub-link"><a href="/${appKey}/answers/">Explore ${config.label} answers →</a></div>`);
  }
  fs.writeFileSync(file, html);
}

function updateHomepage() {
  const file = path.join(website, "index.html");
  let html = fs.readFileSync(file, "utf8");
  html = html.replace(/<a class="app"([^>]*href="([^"]+)"[^>]*)>/g, (anchor, rest, href) => {
    let appKey = Object.keys(apps).find((key) => href.includes(`/${key}/`));
    if (href.includes("mybiblecopilot.com")) appKey = "bible";
    if (href.includes("prayercopilot.com")) appKey = "prayer";
    if (!appKey) return anchor;
    const destination = href.includes("dailycopilots.com") ? "product_page" : "external_product_site";
    let updated = anchor.replace(/\sdata-(?:track|app|cta-location|destination-type)="[^"]*"/g, "");
    return updated.replace("<a ", `<a data-track="copilot_catalog_click" data-app="${appKey}" data-cta-location="homepage_catalog" data-destination-type="${destination}" `);
  });
  fs.writeFileSync(file, html);
}

function updateSitemap() {
  const file = path.join(website, "sitemap.xml");
  let xml = fs.readFileSync(file, "utf8");
  for (const appKey of Object.keys(apps)) {
    const entry = `<url><loc>https://dailycopilots.com/${appKey}/answers/</loc><changefreq>weekly</changefreq></url>`;
    if (!xml.includes(`/${appKey}/answers/</loc>`)) xml = xml.replace("</urlset>", `${entry}\n</urlset>`);
  }
  fs.writeFileSync(file, xml);
}

for (const [appKey, config] of Object.entries(apps)) {
  const answerHub = path.join(website, appKey, "answers", "index.html");
  const englishFiles = walk(path.join(website, appKey, "answers")).filter((file) => file.endsWith("index.html") && file !== answerHub);
  const spanishFiles = walk(path.join(website, "es", appKey, "answers")).filter((file) => file.endsWith("index.html"));
  for (const file of englishFiles) updateAnswerPage(file, appKey, config, "en");
  for (const file of spanishFiles) updateAnswerPage(file, appKey, config, "es");
  const records = answerRecords(appKey, config);
  const hubDirectory = path.join(website, appKey, "answers");
  fs.mkdirSync(hubDirectory, { recursive: true });
  fs.writeFileSync(path.join(hubDirectory, "index.html"), hubMarkup(appKey, config, records));
  updateProductPage(appKey, config, "landing");
  updateProductPage(appKey, config, "pro");
}

updateHomepage();
updateSitemap();
console.log("Built Daily Copilots search-to-app journey.");
