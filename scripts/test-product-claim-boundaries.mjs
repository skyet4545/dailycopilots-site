import fs from "node:fs";
import path from "node:path";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const targets = [
  "BibleCopilot/Models/OnboardingSlide.swift",
  "BibleCopilot/Views/Onboarding/OnboardingView.swift",
  "BibleCopilot/Views/Paywall/PaywallView.swift"
];
const corpus = targets.map(file => fs.readFileSync(path.join(root, file), "utf8")).join("\n");
const forbidden = [
  /every\s+answer\s+cites\s+scripture/i,
  /every\s+answer\s+is\s+rooted\s+in\s+the\s+bible/i,
  /unlimited\s+scripture[- ]cited\s+answers/i,
  /seminary[- ]grade\s+method/i,
  /same\s+inductive\s+framework\s+taught\s+in\s+seminaries/i,
  /major\s+views\s+fairly\s+presented/i,
  /five\s+study\s+modes/i
];

const findings = forbidden.filter(pattern => pattern.test(corpus)).map(pattern => pattern.source);
if (findings.length) throw new Error(`Unsupported or stale product claims remain: ${findings.join(", ")}`);

const required = [
  "References you can check",
  "compare the response with Scripture in context",
  "Theology mode aims to identify major Christian views",
  "Unlimited AI study questions",
  "Six Study\\nModes",
  "Summary, observation, interpretation, theology, application, and apologetics"
];
const missing = required.filter(text => !corpus.includes(text));
if (missing.length) throw new Error(`Required bounded product copy missing: ${missing.join(", ")}`);

console.log(JSON.stringify({ passed: true, filesChecked: targets.length, forbiddenPatterns: forbidden.length, requiredClaims: required.length, externalEffects: [] }));
