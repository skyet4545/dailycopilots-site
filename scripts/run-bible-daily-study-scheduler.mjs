#!/usr/bin/env node
// Launchd entrypoint. It deliberately schedules only the controlled audience
// until a separately approved production-audience record is present.
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const receipts = path.join(root, 'evidence', 'daily-study-email', 'runs');
const audienceId = 'RuR9mx'; // Klaviyo: Bible Copilot Daily Study — Controlled Verification
const date = new Intl.DateTimeFormat('en-CA', { timeZone: 'America/New_York' }).format(new Date());
const manifest = path.join(root, 'daily-study-manifests', `${date}.json`);
mkdirSync(receipts, { recursive: true });
const receiptPath = path.join(receipts, `${date}.json`);

if (!existsSync(manifest)) {
  writeFileSync(receiptPath, `${JSON.stringify({ status: 'verified_skip', date, reason: 'missing_approved_manifest', audience: 'controlled_only', recorded_at: new Date().toISOString() }, null, 2)}\n`);
  process.exit(0);
}
try {
  const output = execFileSync(process.execPath, ['scripts/bible-daily-study-scheduler.mjs', '--date', date, '--audience-id', audienceId, '--schedule'], { cwd: root, encoding: 'utf8' });
  writeFileSync(receiptPath, `${JSON.stringify({ status: 'scheduled', date, audience: 'controlled_only', scheduler_output: JSON.parse(output), recorded_at: new Date().toISOString() }, null, 2)}\n`);
} catch (error) {
  writeFileSync(receiptPath, `${JSON.stringify({ status: 'failed_closed', date, audience: 'controlled_only', error: String(error.stderr || error.message), recorded_at: new Date().toISOString() }, null, 2)}\n`);
  process.exit(1);
}
