#!/usr/bin/env node

const fs = require("fs");
const path = require("path");

const ASSETS = ["marketing-router.js", "revenue.js"];

function syncRuntimeAssets(siteRoot = path.join(__dirname, "..", "site-deploy")) {
  const sourceRoot = path.join(__dirname, "runtime-assets");
  const destinationRoot = path.join(siteRoot, "assets");
  fs.mkdirSync(destinationRoot, { recursive: true });
  return ASSETS.map((name) => {
    const source = path.join(sourceRoot, name);
    const destination = path.join(destinationRoot, name);
    const next = fs.readFileSync(source);
    const state = fs.existsSync(destination) && fs.readFileSync(destination).equals(next) ? "unchanged" : "synced";
    if (state === "synced") fs.writeFileSync(destination, next);
    return { name, state, source, destination };
  });
}

if (require.main === module) {
  const siteRoot = process.argv[2] ? path.resolve(process.argv[2]) : undefined;
  console.log(JSON.stringify({ status: "local_assets_synced", assets: syncRuntimeAssets(siteRoot) }, null, 2));
}

module.exports = syncRuntimeAssets;
