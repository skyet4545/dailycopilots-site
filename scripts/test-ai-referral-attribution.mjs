import assert from "node:assert/strict";
import fs from "node:fs";
import os from "node:os";
import path from "node:path";
import vm from "node:vm";
import { createRequire } from "node:module";

const require = createRequire(import.meta.url);
const syncRuntimeAssets = require("../blog-engine/sync-runtime-assets.js");
const router = fs.readFileSync(new URL("../blog-engine/runtime-assets/marketing-router.js", import.meta.url), "utf8");
const revenue = fs.readFileSync(new URL("../blog-engine/runtime-assets/revenue.js", import.meta.url), "utf8");

function storage() {
  const values = new Map();
  return {
    getItem: (key) => values.has(key) ? values.get(key) : null,
    setItem: (key, value) => values.set(key, value),
  };
}

async function capture({ referrer = "", search = "" }) {
  const posts = [];
  let click;
  const context = {
    URL,
    URLSearchParams,
    document: {
      referrer,
      querySelectorAll: () => [],
      addEventListener: (name, handler) => { if (name === "click") click = handler; },
    },
    location: { search, pathname: "/blog/test/" },
    localStorage: storage(),
    sessionStorage: storage(),
    crypto: { randomUUID: () => "01234567-89ab-cdef-0123-456789abcdef" },
    fetch: async (_url, options) => { posts.push(JSON.parse(options.body)); return { ok: true }; },
  };
  vm.runInNewContext(router, context);
  await new Promise((resolve) => setImmediate(resolve));
  click({ target: { closest: () => ({ href: "https://apps.apple.com/us/app/id6758913373", dataset: { ctaLocation: "article_final_app" } }) } });
  await new Promise((resolve) => setImmediate(resolve));
  return posts;
}

for (const [referrer, expected] of [
  ["https://chatgpt.com/", "ai_chatgpt"],
  ["https://www.perplexity.ai/", "ai_perplexity"],
  ["https://copilot.microsoft.com/", "ai_copilot"],
  ["https://gemini.google.com/", "ai_gemini"],
  ["https://claude.ai/", "ai_claude"],
]) {
  const posts = await capture({ referrer });
  assert.equal(posts.length, 2);
  assert.equal(posts[0].event, "intent_landing_view");
  assert.equal(posts[0].first_source, expected);
  assert.equal(posts[0].first_campaign, "ai_referral_unpaid");
  assert.equal(posts[0].referrer_host, new URL(referrer).hostname.replace(/^www\./, ""));
  assert.equal(posts[1].event, "app_store_intent_tap");
  assert.equal(posts[1].first_source, expected);
}

const tagged = await capture({ referrer: "https://chatgpt.com/", search: "?utm_source=partner&utm_campaign=launch" });
assert.equal(tagged[0].first_source, "partner");
assert.equal(tagged[0].first_campaign, "launch");
assert.equal(tagged[0].referrer_host, "chatgpt.com");

const ordinary = await capture({ referrer: "https://example.org/article?id=private" });
assert.equal(ordinary[0].first_source, "external_referral");
assert.equal(ordinary[0].referrer_host, "example.org");
assert.ok(!JSON.stringify(ordinary).includes("private"));

assert.match(revenue, /marketing-router\.js\?v=20260914-1/);
assert.match(revenue, /script\[src\^='\/assets\/marketing-router\.js'\]/);

const temp = fs.mkdtempSync(path.join(os.tmpdir(), "bible-ai-attribution-"));
const synced = syncRuntimeAssets(temp);
assert.equal(synced.filter((item) => item.state === "synced").length, 2);
assert.equal(syncRuntimeAssets(temp).filter((item) => item.state === "unchanged").length, 2);
for (const name of ["marketing-router.js", "revenue.js"]) {
  assert.equal(
    fs.readFileSync(path.join(temp, "assets", name), "utf8"),
    fs.readFileSync(new URL(`../blog-engine/runtime-assets/${name}`, import.meta.url), "utf8")
  );
}

console.log("PASS: AI referrers classified, UTM precedence preserved, host-only privacy enforced, router loaded once, and runtime sync is idempotent.");
