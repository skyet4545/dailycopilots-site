// Generates 4 App Store screenshot HTML files at 1290x2796.
// Brand-exact: AppTheme #0A1628 navy, #FBBF24 gold, #60A5FA accent + per-mode colors.
const fs = require('fs');
const path = require('path');
const OUT = __dirname;

// --- inline Feather-style stroke icons (MIT) ---
const ico = (d, color, sw = 2) =>
  `<svg viewBox="0 0 24 24" fill="none" stroke="${color}" stroke-width="${sw}" stroke-linecap="round" stroke-linejoin="round">${d}</svg>`;
const I = {
  search: '<circle cx="11" cy="11" r="8"/><line x1="21" y1="21" x2="16.65" y2="16.65"/>',
  eye: '<path d="M1 12s4-8 11-8 11 8 11 8-4 8-11 8-11-8-11-8z"/><circle cx="12" cy="12" r="3"/>',
  bulb: '<polygon points="13 2 3 14 12 14 11 22 21 10 12 10 13 2"/>',
  book: '<path d="M2 3h6a4 4 0 0 1 4 4v14a3 3 0 0 0-3-3H2z"/><path d="M22 3h-6a4 4 0 0 0-4 4v14a3 3 0 0 1 3-3h7z"/>',
  heart: '<path d="M20.84 4.61a5.5 5.5 0 0 0-7.78 0L12 5.67l-1.06-1.06a5.5 5.5 0 1 0-7.78 7.78l1.06 1.06L12 21.23l7.78-7.78 1.06-1.06a5.5 5.5 0 0 0 0-7.78z"/>',
  shield: '<path d="M12 22s8-4 8-10V5l-8-3-8 3v7c0 6 8 10 8 10z"/><path d="M9 12l2 2 4-4"/>',
  file: '<path d="M14 2H6a2 2 0 0 0-2 2v16a2 2 0 0 0 2 2h12a2 2 0 0 0 2-2V8z"/><polyline points="14 2 14 8 20 8"/><line x1="8" y1="13" x2="16" y2="13"/><line x1="8" y1="17" x2="13" y2="17"/>',
  bookmark: '<path d="M19 21l-7-5-7 5V5a2 2 0 0 1 2-2h10a2 2 0 0 1 2 2z"/>',
  calendar: '<rect x="3" y="4" width="18" height="18" rx="2" ry="2"/><line x1="16" y1="2" x2="16" y2="6"/><line x1="8" y1="2" x2="8" y2="6"/><line x1="3" y1="10" x2="21" y2="10"/>',
  infinity: '<path d="M18.178 8c-1.86 0-3.366 1.79-4.178 4-0.812-2.21-2.318-4-4.178-4a4 4 0 0 0 0 8c1.86 0 3.366-1.79 4.178-4 0.812 2.21 2.318 4 4.178 4a4 4 0 0 0 0-8z"/>',
  check: '<polyline points="20 6 9 17 4 12"/>',
};

const MODES = [
  { label: 'Summary',     icon: I.file,  c: '#2DD4BF' },
  { label: 'Observe',     icon: I.eye,   c: '#60A5FA' },
  { label: 'Interpret',   icon: I.bulb,  c: '#A78BFA' },
  { label: 'Theology',    icon: I.book,  c: '#34D399' },
  { label: 'Apply',       icon: I.heart, c: '#F87171' },
  { label: 'Apologetics', icon: I.shield,c: '#FBBF24' },
];

const hexA = (hex, a) => {
  const n = parseInt(hex.slice(1), 16);
  return `rgba(${(n >> 16) & 255},${(n >> 8) & 255},${n & 255},${a})`;
};

const shell = (headline, caption, panel) => `<!doctype html><html><head><meta charset="utf-8"><style>
*{margin:0;padding:0;box-sizing:border-box}
html,body{width:1290px;height:2796px;overflow:hidden}
.canvas{width:1290px;height:2796px;background:radial-gradient(120% 80% at 50% 0%, #0F2138 0%, #0A1628 45%, #060F1E 100%);
  font-family:-apple-system,"SF Pro Display","Helvetica Neue",sans-serif;-webkit-font-smoothing:antialiased;
  display:flex;flex-direction:column;align-items:center;padding:170px 100px 120px}
.headline{font-size:122px;line-height:1.04;font-weight:600;color:#fff;text-align:center;letter-spacing:-3px}
.rule{width:96px;height:8px;background:#FBBF24;border-radius:4px;margin:54px 0 40px}
.caption{font-size:40px;color:#9DB2CE;text-align:center;font-weight:400;margin-bottom:96px;letter-spacing:-0.5px}
.panel{width:1090px;flex:1;background:linear-gradient(180deg,#0E1B30 0%,#0B1526 100%);
  border:2px solid #1B2B45;border-radius:76px;padding:80px 70px;
  box-shadow:0 40px 120px rgba(0,0,0,.5);display:flex;flex-direction:column}
svg{display:block}
</style></head><body><div class="canvas">
<div class="headline">${headline}</div><div class="rule"></div><div class="caption">${caption}</div>
<div class="panel">${panel}</div></div></body></html>`;

// ---- Screen 1: hero — verse field + 6 mode pills ----
// pills mirror the real Study screen: tinted bg, colored border, colored icon + colored label
const pills = MODES.map(m => `
  <div style="display:flex;align-items:center;gap:26px;background:${hexA(m.c,0.12)};
    border:2px solid ${hexA(m.c,0.32)};border-radius:30px;padding:38px 34px">
    <div style="width:54px;height:54px;flex:none">${ico(m.icon, m.c, 2)}</div>
    <span style="font-size:46px;color:${m.c};font-weight:600">${m.label}</span>
  </div>`).join('');
// hero mirrors the real Study screen: gold verse reference card above the 6 mode pills
const s1 = shell('Study any verse,<br>six ways', 'Bible study app · verse meaning', `
  <div style="margin:auto 0;width:100%">
  <div style="background:rgba(255,255,255,0.05);border:2px solid rgba(255,255,255,0.08);
    border-radius:34px;padding:46px 48px;margin-bottom:56px">
    <div style="display:flex;align-items:center;justify-content:space-between;margin-bottom:24px">
      <span style="font-size:56px;color:#FBBF24;font-weight:700">Romans 8:28</span>
      <span style="font-size:32px;color:#8E8E93;font-weight:600;border:2px solid #2A3B55;border-radius:16px;padding:8px 20px">ASV</span>
    </div>
    <p style="font-size:44px;line-height:1.4;color:#E8E8E8;font-style:italic">And we know that all things work together for good to them that love God…</p>
  </div>
  <div style="display:grid;grid-template-columns:1fr 1fr;gap:34px">${pills}</div>
  </div>`);

// ---- Screen 2: the payoff — verse card + Interpret answer + blue cross-ref chips ----
// crossref chips match CrossReferencesView: accent text, accent@12% bg, accent@30% border, capsule
const xref = (t) => `<span style="color:#60A5FA;background:${hexA('#60A5FA',0.12)};
  border:2px solid ${hexA('#60A5FA',0.30)};font-size:40px;font-weight:500;
  padding:18px 36px;border-radius:999px;display:inline-block">${t}</span>`;
const s2 = shell('A real answer,<br>every time', 'Scripture explained with cross references', `
  <div style="background:rgba(255,255,255,0.05);border:2px solid rgba(255,255,255,0.08);
    border-radius:30px;padding:38px 40px;margin-bottom:36px;display:flex;align-items:center;justify-content:space-between">
    <span style="font-size:54px;color:#FBBF24;font-weight:700">Romans 8:28</span>
    <span style="background:#A78BFA;color:#0A1628;font-size:38px;font-weight:600;padding:16px 36px;border-radius:999px">Interpret</span>
  </div>
  <div style="background:rgba(255,255,255,0.05);border:2px solid rgba(255,255,255,0.08);
    border-radius:46px;padding:56px 56px;flex:1;display:flex;flex-direction:column">
    <div style="display:flex;align-items:center;gap:24px;margin-bottom:38px">
      <div style="width:52px;height:52px">${ico('<path d="M21 15a2 2 0 0 1-2 2H7l-4 4V5a2 2 0 0 1 2-2h14a2 2 0 0 1 2 2z"/>','#60A5FA',2)}</div>
      <span style="font-size:40px;color:#E8E8E8;font-weight:600">AI Study Response</span>
    </div>
    <p style="font-size:48px;line-height:1.5;color:#fff;font-weight:400">
      <b style="font-weight:600">"All things work together for good"</b> isn't a promise that everything
      <i>is</i> good — it's that God weaves all of it toward His purpose for those who love Him.</p>
    <div style="margin-top:auto;padding-top:52px">
      <p style="font-size:32px;color:#8E8E93;font-weight:700;letter-spacing:3px;margin-bottom:26px">CROSS REFERENCES</p>
      <div style="display:flex;gap:24px;flex-wrap:wrap">
        ${xref('Genesis 50:20')}${xref('Jeremiah 29:11')}${xref('Philippians 1:6')}
      </div>
    </div>
  </div>`);

// ---- Screen 3: the habit layer — journal + reading plan ----
const seg = (filled) => `<div style="flex:1;height:22px;border-radius:11px;background:${filled?'#34D399':'#1B2B45'}"></div>`;
const s3 = shell('Keep what<br>you learn', 'Study journal &amp; reading plans', `
  <div style="margin:auto 0;width:100%">
  <div style="background:#0A1628;border:2px solid #1B2B45;border-radius:42px;padding:56px;margin-bottom:50px">
    <div style="display:flex;align-items:center;gap:24px;margin-bottom:30px">
      <div style="width:52px;height:52px">${ico(I.bookmark,'#FBBF24',2)}</div>
      <span style="font-size:36px;color:#8E8E93;font-weight:600;letter-spacing:3px">SAVED TO JOURNAL</span>
    </div>
    <p style="font-size:48px;line-height:1.45;color:#E8E8E8">Romans 8:28 — God weaves all things toward His purpose for those who love Him.</p>
  </div>
  <div style="background:#0A1628;border:2px solid #1B2B45;border-radius:42px;padding:56px">
    <div style="display:flex;align-items:center;gap:24px;margin-bottom:40px">
      <div style="width:52px;height:52px">${ico(I.calendar,'#34D399',2)}</div>
      <span style="font-size:36px;color:#8E8E93;font-weight:600;letter-spacing:3px">READING PLAN · DAY 4 OF 7</span>
    </div>
    <div style="display:flex;gap:18px">${[1,1,1,1,0,0,0].map(f=>seg(f)).join('')}</div>
  </div>
  </div>`);

// ---- Screen 4: the offer ----
const feat = (icon, t) => `<div style="display:flex;align-items:center;gap:34px">
  <div style="width:58px;height:58px;flex:none">${ico(icon,'#FBBF24',2)}</div>
  <span style="font-size:52px;color:#E8E8E8;font-weight:500">${t}</span></div>`;
const s4 = shell('Try Pro free<br>for 7 days', 'Free trial · unlimited studies', `
  <div style="display:flex;flex-direction:column;gap:56px;margin-top:20px">
    ${feat(I.infinity,'Unlimited verse studies')}
    ${feat(I.book,'All 6 study modes')}
    ${feat(I.bookmark,'Study journal + reading plans')}
    ${feat(I.check,'No ads, ever')}
  </div>
  <div style="margin-top:auto">
    <div style="background:linear-gradient(90deg,#FBBF24 0%,#3B82F6 100%);border-radius:42px;padding:52px;text-align:center;box-shadow:0 20px 60px ${hexA('#FBBF24',0.3)}">
      <span style="font-size:56px;font-weight:600;color:#fff">Start 7-day free trial</span></div>
    <p style="font-size:38px;color:#8E8E93;text-align:center;margin-top:36px">Then $49.99/yr · cancel anytime</p>
  </div>`);

const files = { '01-hero.html': s1, '02-answer.html': s2, '03-journal.html': s3, '04-offer.html': s4 };
for (const [name, html] of Object.entries(files)) {
  fs.writeFileSync(path.join(OUT, name), html);
  console.log('wrote', name);
}
