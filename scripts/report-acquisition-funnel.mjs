#!/usr/bin/env node

/**
 * Read-only acquisition report for Bible Copilot.
 *
 * Usage:
 *   node scripts/report-acquisition-funnel.mjs 2026-08-01 2026-08-31
 *
 * Requires the Supabase CLI to be linked to the shared analytics project.
 * It reports self-reported acquisition source, not verified App Store
 * campaign-install attribution. App Store click, install, and paid outcomes
 * must remain distinct until Apple supplies a cohort-safe join.
 */

import { execFileSync } from "node:child_process";
import { existsSync } from "node:fs";

const [start, end] = process.argv.slice(2);
const analyticsProjectDirectory = process.env.BIBLE_COPILOT_ANALYTICS_PROJECT_DIR;

if (!/^\d{4}-\d{2}-\d{2}$/.test(start || "") || !/^\d{4}-\d{2}-\d{2}$/.test(end || "")) {
  throw new Error("Usage: node scripts/report-acquisition-funnel.mjs YYYY-MM-DD YYYY-MM-DD");
}

if (!analyticsProjectDirectory || !existsSync(analyticsProjectDirectory)) {
  throw new Error(
    "Set BIBLE_COPILOT_ANALYTICS_PROJECT_DIR to the locally linked Supabase project directory before running this report."
  );
}

const endExclusive = new Date(`${end}T00:00:00Z`);
endExclusive.setUTCDate(endExclusive.getUTCDate() + 1);
const endExclusiveDate = endExclusive.toISOString().slice(0, 10);

const sql = `
  with events as (
    select event, properties, device_id
    from analytics_events
    where app_identifier = 'bible_copilot'
      and created_at >= '${start}T00:00:00Z'
      and created_at < '${endExclusiveDate}T00:00:00Z'
  ), source_by_device as (
    select
      device_id,
      max(coalesce(
        properties->>'acquisition_source',
        case
          when event = 'quiz_answer' and properties->>'question' = 'heard_about'
          then properties->>'answer'
        end
      )) as acquisition_source
    from events
    group by device_id
  ), device_funnel as (
    select
      source_by_device.acquisition_source,
      events.device_id,
      bool_or(events.event = 'onboarding_complete') as onboarding_complete,
      bool_or(events.event = 'question_asked') as question_asked,
      bool_or(events.event = 'paywall_view') as paywall_view,
      bool_or(events.event = 'trial_start_tap') as trial_start_tap,
      bool_or(events.event = 'purchase_success') as purchase_success,
      bool_or(events.event = 'limit_hit') as limit_hit
    from events
    join source_by_device using (device_id)
    group by source_by_device.acquisition_source, events.device_id
  )
  select json_build_object(
    'all_tracked_devices', (select count(distinct device_id) from events),
    'known_source_devices', (select count(*) from device_funnel where acquisition_source is not null),
    'by_source', (
      select coalesce(json_agg(source_row order by acquisition_source), '[]'::json)
      from (
        select
          acquisition_source,
          count(*) as source_devices,
          count(*) filter (where onboarding_complete) as onboarding_complete_devices,
          count(*) filter (where question_asked) as question_devices,
          count(*) filter (where paywall_view) as paywall_devices,
          count(*) filter (where trial_start_tap) as trial_tap_devices,
          count(*) filter (where purchase_success) as purchase_devices,
          count(*) filter (where limit_hit) as limit_hit_devices
        from device_funnel
        where acquisition_source is not null
        group by acquisition_source
      ) source_row
    )
  ) as report;
`;

const raw = execFileSync("supabase", ["db", "query", "--linked", sql.replace(/\s+/g, " ").trim()], {
  cwd: analyticsProjectDirectory,
  encoding: "utf8",
  stdio: ["ignore", "pipe", "pipe"],
});
const parsed = JSON.parse(raw.slice(raw.indexOf("{")));
const report = parsed.rows?.[0]?.report;

if (!report) throw new Error("The linked database returned no acquisition report.");

console.log(JSON.stringify({
  start,
  end,
  evidence: "aggregate first-party events; acquisition_source is self-reported and not a verified App Store install attribution key",
  report,
}, null, 2));
