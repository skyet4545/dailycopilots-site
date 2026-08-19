import fs from "node:fs";
import path from "node:path";

const root = process.cwd();
const truthPath = path.join(root, "product-truth.json");
const baselinePath = path.join(root, "ci", "product-claim-baseline.json");
const errors = [];

if (!fs.existsSync(truthPath)) {
  console.error("product-truth.json is required");
  process.exit(1);
}

const truth = JSON.parse(fs.readFileSync(truthPath, "utf8"));
const expected = {
  name: "Bible Copilot",
  appStoreId: "6758913373",
  freeQuestions: 3,
  monthlyUsd: 9.99,
  annualUsd: 49.99,
  monthlyTrialDays: 7,
  annualTrialDays: 7,
  studyModes: ["Summary", "Observe", "Interpret", "Theology", "Apply", "Apologetics"]
};

function check(condition, message) {
  if (!condition) errors.push(message);
}

check(truth.product?.name === expected.name, "Unexpected product name");
check(truth.product?.app_store_id === expected.appStoreId, "Unexpected App Store ID");
check(truth.free_tier?.questions_per_day === expected.freeQuestions, "Free question limit drifted");
check(truth.pro?.monthly_usd === expected.monthlyUsd, "Monthly price drifted");
check(truth.pro?.annual_usd === expected.annualUsd, "Annual price drifted");
check(truth.pro?.monthly_trial_days === expected.monthlyTrialDays, "Monthly trial length drifted");
check(truth.pro?.annual_trial_days === expected.annualTrialDays, "Annual trial length drifted");
check(
  JSON.stringify(truth.study_modes) === JSON.stringify(expected.studyModes),
  "Study modes drifted"
);

const publicRoots = ["site-deploy", "marketing-site-v2", "metadata", "marketing"];
const textExtensions = new Set([".html", ".md", ".txt", ".json", ".xml", ".py", ".js", ".ts"]);
const prohibited = truth.prohibited_claims_without_current_evidence || [];
const findings = [];
const stalePriceFindings = [];

const claimMatchers = new Map([
  ["#1 AI Bible study app", /#1\s+ai\s+bible\s+study\s+app/i],
  ["Scholarly-level", /\bscholarly-level\b/i],
  ["Seminary-grade", /\bseminary-grade\b/i],
  ["Limited-time offer", /\blimited-time offer\b/i],
  ["Founding week offer", /\bfounding week offer\b/i],
  [
    "The first",
    /\b(?:the\s+first\s+(?:ai\s+)?bible(?:\s+study)?\s+app|first\s+(?:ai\s+)?bible(?:\s+study)?\s+app)\b/i,
  ],
]);

function visit(directory) {
  if (!fs.existsSync(directory)) return;
  for (const entry of fs.readdirSync(directory, { withFileTypes: true })) {
    if (entry.name.startsWith(".") || entry.name === "node_modules") continue;
    const fullPath = path.join(directory, entry.name);
    if (entry.isDirectory()) {
      visit(fullPath);
      continue;
    }
    if (!textExtensions.has(path.extname(entry.name).toLowerCase())) continue;
    const content = fs.readFileSync(fullPath, "utf8").toLowerCase();
    const stalePricePatterns = [
      /\$4\.99\/(?:mo(?:nth)?|month)(?=[\s\S]{0,50}(?:\$49\.99|49\.99\/yr))/i,
      /bible copilot is \$4\.99/i,
      /bible copilot's pro is \$4\.99/i,
      /pro at \$4\.99\/month/i,
      /monthly is available for \$4\.99/i,
    ];
    const relativePath = path.relative(root, fullPath);
    const isHistoricalWatch = /^marketing\/geo\/watch-\d{4}-\d{2}-\d{2}\.md$/.test(relativePath);
    if (!isHistoricalWatch && stalePricePatterns.some((matcher) => matcher.test(content))) {
      stalePriceFindings.push(`${relativePath} contains stale Bible Copilot monthly pricing`);
    }
    for (const claim of prohibited) {
      const matcher = claimMatchers.get(claim);
      const matches = matcher ? matcher.test(content) : content.includes(claim.toLowerCase());
      if (matches) {
        findings.push(`${path.relative(root, fullPath)} contains prohibited claim: ${claim}`);
      }
    }
  }
}

for (const publicRoot of publicRoots) visit(path.join(root, publicRoot));
errors.push(...stalePriceFindings);

if (process.argv.includes("--write-baseline")) {
  fs.writeFileSync(
    baselinePath,
    `${JSON.stringify(
      {
        version: 1,
        generatedAt: new Date().toISOString(),
        findings
      },
      null,
      2
    )}\n`
  );
  console.log(`Wrote ${findings.length} existing findings to ${baselinePath}`);
  process.exit(0);
}

const baseline = fs.existsSync(baselinePath)
  ? JSON.parse(fs.readFileSync(baselinePath, "utf8")).findings || []
  : [];
const baselineSet = new Set(baseline);
const newFindings = findings.filter((finding) => !baselineSet.has(finding));
const resolvedFindings = baseline.filter((finding) => !findings.includes(finding));

if (newFindings.length) {
  errors.push(...newFindings);
}

if (errors.length) {
  console.error(`Product contract validation failed with ${errors.length} finding(s):`);
  for (const error of errors) console.error(`- ${error}`);
  process.exit(1);
}

console.log("Product contract validation passed.");
console.log(
  `${findings.length} legacy claim findings remain baselined; ${resolvedFindings.length} baseline findings have been resolved.`
);
