#!/usr/bin/env node

/**
 * Creates one Klaviyo campaign from an approved daily-study manifest.
 *
 * This is deliberately manifest-driven. It never invents content, sends to a
 * default list, or falls back to a public site key. `--schedule` is the only
 * mode that changes Klaviyo; without it, the command performs the full local
 * validation and prints a dry-run summary.
 */

import { createHash } from 'node:crypto';
import { execFileSync } from 'node:child_process';
import { existsSync, mkdirSync, readFileSync, writeFileSync } from 'node:fs';
import path from 'node:path';
import process from 'node:process';
import { fileURLToPath } from 'node:url';

const root = path.resolve(path.dirname(fileURLToPath(import.meta.url)), '..');
const manifestsDir = path.join(root, 'daily-study-manifests');
const receiptsDir = path.join(root, 'evidence', 'daily-study-email');
const revision = '2026-07-15.pre';
const apiBase = 'https://a.klaviyo.com/api';
const keychainService = 'biblecopilot-klaviyo-daily-study';
const requiredCtaPrefix = 'https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373';
const allowedSender = 'republicpublishing@proton.me';

function usage(message) {
  if (message) console.error(`Error: ${message}\n`);
  console.error('Usage: node scripts/bible-daily-study-scheduler.mjs --date YYYY-MM-DD --audience-id ID [--schedule]');
  process.exit(2);
}

function parseArgs(argv) {
  const options = { schedule: false };
  for (let index = 0; index < argv.length; index += 1) {
    const value = argv[index];
    if (value === '--schedule') options.schedule = true;
    else if (value === '--date') options.date = argv[++index];
    else if (value === '--audience-id') options.audienceId = argv[++index];
    else usage(`Unknown argument: ${value}`);
  }
  if (!/^\d{4}-\d{2}-\d{2}$/.test(options.date ?? '')) usage('A valid --date is required.');
  if (!/^[A-Za-z0-9]+$/.test(options.audienceId ?? '')) usage('A valid --audience-id is required.');
  return options;
}

function digest(value) {
  return createHash('sha256').update(JSON.stringify(value)).digest('hex');
}

function readManifest(date) {
  const manifestPath = path.join(manifestsDir, `${date}.json`);
  if (!existsSync(manifestPath)) throw new Error(`Missing approved manifest: ${manifestPath}`);
  const manifest = JSON.parse(readFileSync(manifestPath, 'utf8'));
  const required = ['id', 'passage', 'context_note', 'reflection_question', 'cta_label', 'cta_url', 'editorial_status', 'approved_by', 'source_references'];
  for (const field of required) if (!manifest[field]) throw new Error(`Manifest ${date} is missing ${field}.`);
  if (manifest.id !== date) throw new Error(`Manifest id must equal ${date}.`);
  if (manifest.editorial_status !== 'approved' || manifest.approved_by !== 'Carlos Reyes') {
    throw new Error('Manifest must be explicitly approved by Carlos Reyes.');
  }
  if (!Array.isArray(manifest.source_references) || manifest.source_references.length === 0) {
    throw new Error('Manifest must include at least one source reference.');
  }
  if (!manifest.cta_url.startsWith(requiredCtaPrefix)) throw new Error('Manifest CTA must use the approved Bible Copilot App Store URL.');
  return manifest;
}

function scheduleTime(date) {
  // 08:00 Eastern in August (EDT, UTC-4). A human must update manifest policy
  // before DST changes; this avoids silently sending at the wrong local time.
  const month = Number(date.slice(5, 7));
  if (month < 3 || month > 10) throw new Error('DST-safe send time requires explicit review outside Mar-Oct.');
  return `${date}T12:00:00.000Z`;
}

function keychainKey() {
  try {
    return execFileSync('security', ['find-generic-password', '-s', keychainService, '-a', 'Bible Copilot Daily Study Scheduler', '-w'], { encoding: 'utf8' }).trim();
  } catch {
    throw new Error('Required Klaviyo scheduler credential is unavailable in macOS Keychain.');
  }
}

async function request(endpoint, method, apiKey, body) {
  const response = await fetch(`${apiBase}${endpoint}`, {
    method,
    headers: {
      Accept: 'application/vnd.api+json',
      'Content-Type': 'application/vnd.api+json',
      Authorization: `Klaviyo-API-Key ${apiKey}`,
      revision,
    },
    body: body ? JSON.stringify(body) : undefined,
  });
  const json = await response.json().catch(() => ({}));
  if (!response.ok) throw new Error(`Klaviyo ${method} ${endpoint} failed (${response.status}): ${JSON.stringify(json.errors ?? json)}`);
  return json;
}

function messageHtml(manifest) {
  const esc = (input) => String(input).replace(/[&<>"']/g, (char) => ({ '&': '&amp;', '<': '&lt;', '>': '&gt;', '"': '&quot;', "'": '&#39;' })[char]);
  return `<!doctype html><html><body style="margin:0;background:#f8f5ee;color:#141414;font-family:Georgia,serif"><main style="max-width:640px;margin:0 auto;padding:36px 28px"><p style="letter-spacing:1.5px;font:600 12px Arial,sans-serif;color:#8a6714">BIBLE COPILOT · DAILY STUDY</p><h1 style="font-size:30px;line-height:1.18">${esc(manifest.passage)}</h1><p style="font:18px/1.65 Arial,sans-serif">Read the passage in its immediate context before moving on.</p><h2 style="font-size:21px">A little context</h2><p style="font:17px/1.65 Arial,sans-serif">${esc(manifest.context_note)}</p><h2 style="font-size:21px">Carry this question with you</h2><p style="font:17px/1.65 Arial,sans-serif">${esc(manifest.reflection_question)}</p><p style="margin-top:30px"><a href="${esc(manifest.cta_url)}" style="display:inline-block;background:#d7ae54;color:#101010;padding:14px 20px;border-radius:5px;text-decoration:none;font:600 15px Arial,sans-serif">${esc(manifest.cta_label)}</a></p><p style="font:14px/1.5 Arial,sans-serif;color:#666">Bible Copilot is a study aid, not a replacement for reading Scripture, prayer, church, or pastoral care.</p></main></body></html>`;
}

function messageText(manifest) {
  return `${manifest.passage}\n\nRead the passage in its immediate context before moving on.\n\nA little context\n${manifest.context_note}\n\nCarry this question with you\n${manifest.reflection_question}\n\n${manifest.cta_label}: ${manifest.cta_url}\n\nBible Copilot is a study aid, not a replacement for reading Scripture, prayer, church, or pastoral care.`;
}

function templatePayload(manifest) {
  return {
    data: {
      type: 'template',
      attributes: {
        name: `Bible Copilot Daily Study — ${manifest.id}`,
        editor_type: 'CODE',
        html: messageHtml(manifest),
        text: messageText(manifest),
      },
    },
  };
}

function campaignPayload(manifest, audienceId, templateId) {
  const temporaryAudienceId = `bc_daily_${manifest.id.replaceAll('-', '_')}`;
  return {
    data: {
      type: 'campaign',
      attributes: {
        definition: {
          name: `Bible Copilot Daily Study — ${manifest.id}`,
          builder: 'wizard',
          send_settings: { send_timezone: 'America/New_York', send_strategy: 'STATIC', send_passed_rltz_immediately: false, exit_condition_enabled: false, exit_condition_conversion_metric_id: null },
        },
        audiences: [{ temporary_id: temporaryAudienceId, included: [audienceId], excluded: [] }],
        messages: [{
          audience_temporary_id: temporaryAudienceId,
          name: `Bible Copilot Daily Study ${manifest.id}`,
          variations: [{ definition: { name: 'Email', details: { channel: 'email', template_id: templateId, subject: manifest.passage, preview_text: 'One verse. A clearer understanding. Every day.', from_email: allowedSender, from_label: 'Bible Copilot', reply_to_email: allowedSender } } }],
        }],
      },
    },
  };
}

async function main() {
  const options = parseArgs(process.argv.slice(2));
  const manifest = readManifest(options.date);
  const intendedTime = scheduleTime(options.date);
  if (new Date(intendedTime) <= new Date()) throw new Error(`Intended send time ${intendedTime} is not in the future.`);
  const receiptPath = path.join(receiptsDir, `${options.date}.json`);
  if (existsSync(receiptPath)) throw new Error(`A receipt already exists for ${options.date}; refusing duplicate schedule.`);
  const plan = { manifest_id: manifest.id, manifest_sha256: digest(manifest), audience_id: options.audienceId, intended_send_time: intendedTime, sender: allowedSender, status: options.schedule ? 'ready_to_schedule' : 'dry_run' };
  if (!options.schedule) return console.log(JSON.stringify(plan, null, 2));

  const apiKey = keychainKey();
  const template = await request('/templates', 'POST', apiKey, templatePayload(manifest));
  const campaign = await request('/campaigns', 'POST', apiKey, campaignPayload(manifest, options.audienceId, template.data.id));
  const messageId = campaign.data.relationships['campaign-messages'].data[0].id;
  const scheduled = await request('/campaign-message-schedule', 'POST', apiKey, { data: { type: 'campaign-message-schedule', attributes: { send_time: intendedTime, strategy: 'static' }, relationships: { 'campaign-message': { data: { type: 'campaign-message', id: messageId } } } } });
  mkdirSync(receiptsDir, { recursive: true });
  const receipt = { ...plan, status: 'scheduled', scheduled_at: new Date().toISOString(), template_id: template.data.id, campaign_id: campaign.data.id, campaign_message_id: messageId, campaign_schedule_id: scheduled.data.id, api_revision: revision };
  writeFileSync(receiptPath, `${JSON.stringify(receipt, null, 2)}\n`, { flag: 'wx' });
  console.log(JSON.stringify(receipt, null, 2));
}

main().catch((error) => { console.error(`Scheduler failed closed: ${error.message}`); process.exit(1); });
