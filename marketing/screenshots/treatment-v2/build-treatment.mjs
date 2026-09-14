import fs from "node:fs";
import path from "node:path";
import crypto from "node:crypto";
import { createRequire } from "node:module";
import { fileURLToPath, pathToFileURL } from "node:url";

const require = createRequire(import.meta.url);
const puppeteer = require("puppeteer");
const here = path.dirname(fileURLToPath(import.meta.url));
const manifestPath = path.join(here, "manifest.json");
const manifest = JSON.parse(fs.readFileSync(manifestPath, "utf8"));
const sha256 = bytes => crypto.createHash("sha256").update(bytes).digest("hex");
const browserCandidates = [
  process.env.BIBLE_SCREENSHOT_BROWSER,
  "/Applications/Google Chrome.app/Contents/MacOS/Google Chrome",
  "/Applications/Chromium.app/Contents/MacOS/Chromium",
  "/Applications/Microsoft Edge.app/Contents/MacOS/Microsoft Edge"
].filter(Boolean);
const executablePath = browserCandidates.find(candidate => fs.existsSync(candidate));
if (!executablePath) throw new Error("No supported local browser found. Set BIBLE_SCREENSHOT_BROWSER to an executable path.");

function html(frame, sourcePath) {
  const deviceHeight = frame.deviceViewportHeight ? `height:${frame.deviceViewportHeight}px` : "";
  return `<!doctype html><html><head><meta charset="utf-8"><style>
*{margin:0;padding:0;box-sizing:border-box}html,body{width:1290px;height:2796px;overflow:hidden}
.canvas{width:1290px;height:2796px;background:radial-gradient(120% 75% at 50% 0%,#0F2138 0%,#0A1628 42%,#060F1E 100%);font-family:-apple-system,"SF Pro Display","Helvetica Neue",sans-serif;-webkit-font-smoothing:antialiased;display:flex;flex-direction:column;align-items:center;padding:118px 0 0}
.headline{font-size:104px;line-height:1.05;font-weight:650;color:#fff;text-align:center;letter-spacing:-2.5px;max-width:1120px}
.rule{width:88px;height:8px;background:#FBBF24;border-radius:4px;margin:42px 0 32px}
.caption{font-size:38px;line-height:1.2;color:#B8C7DC;text-align:center;font-weight:450;margin:0 58px 60px;letter-spacing:-.4px;max-width:1120px}
.device{width:1006px;${deviceHeight};border-radius:62px;overflow:hidden;border:3px solid #22344F;box-shadow:0 50px 130px rgba(0,0,0,.6);background:#0A1628}.device img{width:100%;display:block}
</style></head><body><div class="canvas"><div class="headline">${frame.headline}</div><div class="rule"></div><div class="caption">${frame.supportingLine}</div><div class="device"><img src="${pathToFileURL(sourcePath).href}" alt=""></div></div></body></html>`;
}

fs.mkdirSync(path.join(here, "output"), { recursive: true });
const browser = await puppeteer.launch({ headless: true, executablePath });
const page = await browser.newPage();
await page.setViewport({ width: manifest.canvas.width, height: manifest.canvas.height, deviceScaleFactor: 1 });
const assets = [];

for (const frame of manifest.frames) {
  if (frame.status !== "ready_for_composite") continue;
  const sourcePath = path.resolve(here, frame.source);
  const sourceBytes = fs.readFileSync(sourcePath);
  if (sha256(sourceBytes) !== frame.sourceSha256) throw new Error(`Source hash mismatch for frame ${frame.position}`);
  const htmlPath = path.join(here, "output", `${String(frame.position).padStart(2, "0")}-${frame.id}.html`);
  const pngPath = htmlPath.replace(/\.html$/, ".png");
  fs.writeFileSync(htmlPath, html(frame, sourcePath));
  await page.goto(pathToFileURL(htmlPath).href, { waitUntil: "networkidle0" });
  await page.screenshot({ path: pngPath, type: "png", fullPage: false });
  const outputBytes = fs.readFileSync(pngPath);
  assets.push({
    position: frame.position,
    id: frame.id,
    status: "composited_from_verified_real_capture",
    source: path.relative(here, sourcePath),
    sourceSha256: frame.sourceSha256,
    output: path.relative(here, pngPath),
    outputSha256: sha256(outputBytes)
  });
}

await browser.close();
const readiness = {
  schemaVersion: 1,
  treatmentId: manifest.treatmentId,
  generatedAt: new Date().toISOString(),
  readyFrames: assets.length,
  requiredFrames: manifest.frames.length,
  complete: assets.length === manifest.frames.length,
  assets,
  blockers: manifest.frames.filter(frame => frame.status !== "ready_for_composite").map(frame => ({ position: frame.position, id: frame.id, reason: frame.blockedReason }))
};
fs.writeFileSync(path.join(here, "output", "asset-manifest.json"), `${JSON.stringify(readiness, null, 2)}\n`);
console.log(JSON.stringify(readiness, null, 2));
