// Composites REAL device captures into 1290x2796 App Store frames.
// Each frame: navy gradient bg + marketing headline + gold rule + caption + the real screenshot.
const fs = require('fs');
const path = require('path');
const OUT = __dirname;

// Headlines: benefit-led + OCR-indexed keywords (Apple indexes screenshot text since 2025).
// Keyword coverage across the 4: bible verse, AI bible study, devotional, scripture,
// meaning, theology, bible questions, cross references.
const SHOTS = [
  { src: 'real-src-01-home.png',    out: 'store-01-home.html',    png: 'store-01-home.png',
    headline: 'Understand any<br>Bible verse', caption: 'AI Bible study · daily devotional · KJV' },
  { src: 'real-src-02-study.png',   out: 'store-02-study.html',   png: 'store-02-study.png',
    headline: 'Study Scripture<br>six ways', caption: 'Commentary · meaning · theology · application' },
  { src: 'real-src-03-answer.png',  out: 'store-03-answer.html',  png: 'store-03-answer.png',
    headline: 'Every answer<br>cites Scripture', caption: 'Bible questions answered with cross-references' },
  { src: 'real-src-04-paywall.png', out: 'store-04-paywall.html', png: 'store-04-paywall.png',
    headline: 'Try Pro free<br>for 7 days', caption: 'Unlimited studies · reading plans · cancel anytime' },
];

const frame = (headline, caption, src) => `<!doctype html><html><head><meta charset="utf-8"><style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:1290px;height:2796px;overflow:hidden}
.canvas{width:1290px;height:2796px;
  background:radial-gradient(120% 75% at 50% 0%, #0F2138 0%, #0A1628 42%, #060F1E 100%);
  font-family:-apple-system,"SF Pro Display","Helvetica Neue",sans-serif;-webkit-font-smoothing:antialiased;
  display:flex;flex-direction:column;align-items:center;padding:118px 0 0}
.headline{font-size:104px;line-height:1.05;font-weight:600;color:#fff;text-align:center;letter-spacing:-2.5px}
.rule{width:88px;height:8px;background:#FBBF24;border-radius:4px;margin:42px 0 32px}
.caption{font-size:38px;color:#9DB2CE;text-align:center;font-weight:400;margin-bottom:60px;letter-spacing:-0.4px}
.device{width:1006px;border-radius:62px;overflow:hidden;
  border:3px solid #22344F;box-shadow:0 50px 130px rgba(0,0,0,.6);background:#0A1628}
.device img{width:100%;display:block}
</style></head><body><div class="canvas">
<div class="headline">${headline}</div><div class="rule"></div><div class="caption">${caption}</div>
<div class="device"><img src="${src}" alt=""></div>
</div></body></html>`;

for (const s of SHOTS) {
  fs.writeFileSync(path.join(OUT, s.out), frame(s.headline, s.caption, s.src));
  console.log('wrote', s.out);
}
