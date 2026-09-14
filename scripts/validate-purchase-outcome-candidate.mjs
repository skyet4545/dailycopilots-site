#!/usr/bin/env node

import fs from "node:fs";
import path from "node:path";
import { execFileSync } from "node:child_process";
import { fileURLToPath } from "node:url";

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), "..");
const read = (relative) => fs.readFileSync(path.join(root, relative), "utf8");
const assertions = [];
const check = (condition, message) => {
  assertions.push({ message, passed: Boolean(condition) });
  if (!condition) throw new Error(message);
};

const service = read("BibleCopilot/Services/SubscriptionService.swift");
const analytics = read("BibleCopilot/Services/AnalyticsService.swift");
const paywall = read("BibleCopilot/Views/Paywall/PaywallView.swift");
const onboarding = read("BibleCopilot/Views/Onboarding/OnboardingView.swift");
const settings = read("BibleCopilot/Views/Tabs/SettingsView.swift");
const project = read("BibleCopilot.xcodeproj/project.pbxproj");
const review = read("PURCHASE-OUTCOME-CANDIDATE.md");

check((project.match(/CURRENT_PROJECT_VERSION = 134;/g) || []).length === 2, "build 134 is set for both configurations");
check((project.match(/MARKETING_VERSION = 2\.4\.8;/g) || []).length === 2, "version 2.4.8 is set for both configurations");
check(service.includes("func purchase(_ product: Product) async throws -> PurchaseOutcome"), "purchase returns an explicit outcome");
for (const value of ["purchased", "cancelled", "pending", "unknown"]) {
  check(service.includes(`case ${value}`), `purchase outcome ${value} exists`);
}
check(service.includes("func restore() async throws -> Bool"), "restore propagates App Store errors and reports entitlement state");
for (const event of ["purchase_cancelled", "purchase_pending", "purchase_unknown", "paywall_dismissed", "paywall_plans_load_failed", "restore_started", "restore_succeeded", "restore_no_entitlement", "restore_failed"]) {
  check(analytics.includes(`= \"${event}\"`), `analytics event ${event} exists`);
}
check(paywall.includes("case .pending:") && paywall.includes("pending Apple approval"), "paywall explains pending Apple approval");
check(paywall.includes("recordDismissal(reason: \"sheet_closed\")"), "sheet dismissal is measured");
check(paywall.includes("recordedPlanLoadFailure"), "plan-load failure is deduplicated");
check(onboarding.includes("PaywallView.visibleTrialLength"), "onboarding reuses the tested eligibility boundary");
check(onboarding.includes("Unlock Bible Copilot Pro") && onboarding.includes("Subscribe Annually"), "ineligible onboarding avoids a free-trial promise");
check(settings.includes("No active Bible Copilot Pro purchase was found"), "settings reports no restored entitlement");
check((paywall.match(/purchase_attempt_id/g) || []).length >= 1 && onboarding.includes("purchase_attempt_id"), "purchase tap and outcomes carry an anonymous attempt join key");
check(paywall.includes("restore_attempt_id") && settings.includes("restore_attempt_id"), "restore outcomes carry an anonymous attempt join key");
check(paywall.includes("AnalyticsEvent.restoreStarted") && settings.includes("AnalyticsEvent.restoreStarted"), "restore attempts record a joinable start denominator");
check(review.includes("do not establish an active paid subscription"), "review preserves the commercial evidence boundary");

const parent = "9bf3b9acf492175d65e4045fd94d0bed1ea63a63";
execFileSync("git", ["merge-base", "--is-ancestor", parent, "HEAD"], { cwd: root });
check(true, "candidate descends from exact 2.4.7/133 parent");
check(execFileSync("git", ["status", "--porcelain"], { cwd: root, encoding: "utf8" }).trim() === "", "candidate worktree is clean");

console.log(JSON.stringify({ passed: true, assertions: assertions.length, head: execFileSync("git", ["rev-parse", "HEAD"], { cwd: root, encoding: "utf8" }).trim(), externalEffects: [] }));
