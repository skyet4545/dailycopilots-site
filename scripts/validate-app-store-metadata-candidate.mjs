#!/usr/bin/env node
import assert from "node:assert/strict";
import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const candidate = JSON.parse(fs.readFileSync(path.join(root, "metadata", "app_store_metadata_candidate.json"), "utf8"));
const truth = JSON.parse(fs.readFileSync(path.join(root, "product-truth.json"), "utf8"));
const live = candidate.liveBaseline;
const treatment = candidate.candidate;
const normalizedWords = (value) => new Set(value.toLowerCase().replace(/[^a-z0-9]+/g, " ").trim().split(/\s+/));
const indexed = normalizedWords(`${treatment.name} ${treatment.subtitle}`);
const keywordTokens = treatment.keywords.split(",");
const forbidden = truth.prohibited_claims_without_current_evidence.map((value) => value.toLowerCase());
const allCopy = JSON.stringify(candidate).toLowerCase();

assert.equal(candidate.appStoreId, truth.product.app_store_id);
assert.equal(treatment.name, live.name);
assert.equal(treatment.subtitle, live.subtitle);
assert.ok(Buffer.byteLength(treatment.name) <= 30);
assert.ok(Buffer.byteLength(treatment.subtitle) <= 30);
assert.ok(Buffer.byteLength(live.description) <= 4000);
assert.ok(Buffer.byteLength(treatment.keywords) <= 100);
assert.equal(Buffer.byteLength(treatment.keywords), 99);
assert.equal(/,\s/.test(treatment.keywords), false);
assert.equal(new Set(keywordTokens).size, keywordTokens.length);
assert.deepEqual(keywordTokens.filter((token) => indexed.has(token)), []);
assert.ok(live.description.includes("Ask up to 3 AI-powered questions each day at no charge."));
assert.ok(live.description.includes("Monthly: $9.99"));
assert.ok(live.description.includes("Annual: $49.99 with a 7-day free trial"));
assert.equal(live.description.includes("No data collected"), false);
assert.deepEqual(forbidden.filter((claim) => allCopy.includes(claim)), []);
assert.match(treatment.status, /^held_/);
assert.deepEqual(candidate.externalEffects, []);
assert.ok(candidate.ownerGates.includes("App Store metadata change"));
assert.match(candidate.decisionPolicy.boundary, /Do not attribute installs, paid subscriptions, or revenue/i);

console.log(JSON.stringify({ passed: true, assertions: 20, keywordBytes: Buffer.byteLength(treatment.keywords), externalEffects: [] }));
