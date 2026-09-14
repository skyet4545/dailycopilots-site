import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { fileURLToPath } from "node:url";

const here = path.dirname(fileURLToPath(import.meta.url));
const manifest = JSON.parse(fs.readFileSync(path.join(here, "manifest.json"), "utf8"));
const outputs = JSON.parse(fs.readFileSync(path.join(here, "output", "asset-manifest.json"), "utf8"));
const requireComplete = process.argv.includes("--require-complete");
const errors = [];
const sha256 = bytes => crypto.createHash("sha256").update(bytes).digest("hex");
const expected = ["verse-entry", "six-study-modes", "scripture-cited-answer", "follow-up-study", "reading-plan", "pro-offer"];
const forbiddenAbsoluteClaims = [
  /every\s+answer\s+cites\s+scripture/i,
  /cites\s+scripture\s+for\s+every\s+answer/i,
  /every\s+answer\s+(?:is\s+)?backed\s+by\s+(?:actual\s+)?scripture/i,
  /answers?\s+anchored\s+in\s+scripture/i
];

if (manifest.canvas.width !== 1290 || manifest.canvas.height !== 2796) errors.push("invalid_canvas_contract");
if (manifest.frames.length !== 6) errors.push("expected_six_frames");
if (manifest.frames.map(frame => frame.id).join("|") !== expected.join("|")) errors.push("invalid_frame_order");

const customerFacingCopy = manifest.frames
  .map(frame => `${frame.headline ?? ""}\n${frame.supportingLine ?? ""}`)
  .join("\n");
for (const pattern of forbiddenAbsoluteClaims) {
  if (pattern.test(customerFacingCopy)) errors.push(`forbidden_absolute_claim:${pattern.source}`);
}
const proFrame = manifest.frames.find(frame => frame.id === "pro-offer");
const proCopy = `${proFrame?.headline ?? ""} ${proFrame?.supportingLine ?? ""}`;
if (/free|trial/i.test(proCopy) && !/eligible/i.test(proCopy)) errors.push("trial_claim_missing_eligibility_boundary");
if (outputs.complete && !String(proFrame?.sourceCopyBoundaryStatus ?? "").startsWith("passed_")) errors.push("complete_treatment_uses_unreviewed_pro_source_copy");

for (const frame of manifest.frames) {
  if (frame.position < 1 || frame.position > 6) errors.push(`invalid_position:${frame.id}`);
  if (!Array.isArray(frame.truthChecks) || frame.truthChecks.length === 0) errors.push(`missing_truth_checks:${frame.id}`);
  if (frame.status === "ready_for_composite") {
    if (!String(frame.sourceCopyBoundaryStatus ?? "").startsWith("passed_")) errors.push(`source_copy_boundary_not_passed:${frame.id}`);
    const sourcePath = path.resolve(here, frame.source ?? "");
    if (!fs.existsSync(sourcePath)) errors.push(`missing_source:${frame.id}`);
    else if (sha256(fs.readFileSync(sourcePath)) !== frame.sourceSha256) errors.push(`source_hash_mismatch:${frame.id}`);
  } else if (!frame.blockedReason) errors.push(`missing_blocked_reason:${frame.id}`);
}

for (const asset of outputs.assets) {
  const outputPath = path.resolve(here, asset.output);
  if (!fs.existsSync(outputPath)) { errors.push(`missing_output:${asset.id}`); continue; }
  const bytes = fs.readFileSync(outputPath);
  if (bytes.toString("ascii", 1, 4) !== "PNG") errors.push(`not_png:${asset.id}`);
  const width = bytes.readUInt32BE(16);
  const height = bytes.readUInt32BE(20);
  if (width !== 1290 || height !== 2796) errors.push(`wrong_dimensions:${asset.id}:${width}x${height}`);
  if (sha256(bytes) !== asset.outputSha256) errors.push(`output_hash_mismatch:${asset.id}`);
}

if (requireComplete && !outputs.complete) errors.push(`treatment_incomplete:${outputs.readyFrames}_of_${outputs.requiredFrames}`);
const result = { status: errors.length ? "failed" : "passed", complete: outputs.complete, readyFrames: outputs.readyFrames, requiredFrames: outputs.requiredFrames, blockers: outputs.blockers, errors };
console.log(JSON.stringify(result, null, 2));
if (errors.length) process.exitCode = 1;
