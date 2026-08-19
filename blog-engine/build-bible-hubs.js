const fs = require('fs');
const path = require('path');

const root = process.argv[2];
if (!root) throw new Error('Usage: node build-bible-hubs.js <repo-root>');
const site = path.join(root, 'site-deploy');
const blog = path.join(site, 'blog');
const books = [
  ['1 Thessalonians','1-thessalonians'],['2 Thessalonians','2-thessalonians'],['1 Corinthians','1-corinthians'],['2 Corinthians','2-corinthians'],['1 Chronicles','1-chronicles'],['2 Chronicles','2-chronicles'],['Song of Solomon','song-of-solomon'],['1 Timothy','1-timothy'],['2 Timothy','2-timothy'],['1 Peter','1-peter'],['2 Peter','2-peter'],['1 John','1-john'],['2 John','2-john'],['3 John','3-john'],['1 Samuel','1-samuel'],['2 Samuel','2-samuel'],['1 Kings','1-kings'],['2 Kings','2-kings'],
  ...['Genesis','Exodus','Leviticus','Numbers','Deuteronomy','Joshua','Judges','Ruth','Ezra','Nehemiah','Esther','Job','Psalms','Psalm','Proverbs','Ecclesiastes','Isaiah','Jeremiah','Lamentations','Ezekiel','Daniel','Hosea','Joel','Amos','Obadiah','Jonah','Micah','Nahum','Habakkuk','Zephaniah','Haggai','Zechariah','Malachi','Matthew','Mark','Luke','John','Acts','Romans','Galatians','Ephesians','Philippians','Colossians','Titus','Philemon','Hebrews','James','Jude','Revelation'].map(name=>[name,name.toLowerCase()])
];
const descriptions = {
  psalm: 'Explore prayers, songs, lament, praise, wisdom, and hope from the Psalms.',
  proverbs: 'Study biblical wisdom about speech, work, relationships, character, and the fear of the Lord.',
  isaiah: 'Explore Isaiah’s promises, warnings, servant passages, and vision of God’s redemption.',
  romans: 'Study Paul’s explanation of sin, grace, justification, life in the Spirit, and Christian obedience.',
  john: 'Explore John’s signs, “I am” sayings, and testimony about the identity and mission of Jesus.',
  matthew: 'Study Jesus’ teaching, the kingdom of heaven, the Sermon on the Mount, and the Great Commission.',
  genesis: 'Study creation, the fall, covenant, Abraham, Jacob, Joseph, and the beginnings of the biblical story.',
  philippians: 'Explore joy, humility, perseverance, contentment, and life centered on Christ.',
  corinthians: 'Study grace in weakness, Christian community, spiritual gifts, love, resurrection, and ministry.',
  ephesians: 'Explore identity in Christ, grace, unity, spiritual maturity, relationships, and the armor of God.'
};
function escape(value){return value.replace(/[&<>"']/g,c=>({'&':'&amp;','<':'&lt;','>':'&gt;','"':'&quot;',"'":'&#39;'}[c]));}
function identify(title){
  for (const [name,slug] of books) {
    const pattern = new RegExp(`(^|[^A-Za-z])${name.replace(/ /g,'\\s+')}\\s+\\d`, 'i');
    if (pattern.test(title)) return {name: name === 'Psalms' ? 'Psalms' : name, slug: slug === 'psalms' ? 'psalm' : slug};
  }
  return null;
}
const entries=[];
for(const dir of fs.readdirSync(blog,{withFileTypes:true})){
  if(!dir.isDirectory()||!/^blog-\d+$/.test(dir.name))continue;
  const file=path.join(blog,dir.name,'index.html');
  const html=fs.readFileSync(file,'utf8');
  const raw=(html.match(/<title>([\s\S]*?)<\/title>/i)||[])[1]||'';
  const title=raw.replace(/\s*\|\s*Bible Copilot\s*$/,'').replace(/<[^>]+>/g,'').trim();
  const book=identify(title);
  if(book)entries.push({file,url:`/blog/${dir.name}/`,title,book});
}
const grouped=new Map();
for(const entry of entries){if(!grouped.has(entry.book.slug))grouped.set(entry.book.slug,{...entry.book,entries:[]});grouped.get(entry.book.slug).entries.push(entry)}
const priorities=[...grouped.values()].sort((a,b)=>b.entries.length-a.entries.length).slice(0,10);

const style=`:root{--bg:#090e1b;--panel:#111a2e;--line:#293957;--text:#f7f3e8;--muted:#aeb8ca;--gold:#d4af5f}*{box-sizing:border-box}body{margin:0;background:var(--bg);color:var(--text);font:16px/1.65 system-ui,-apple-system,sans-serif}.wrap{max-width:1080px;margin:auto;padding:0 22px}a{color:inherit}nav{border-bottom:1px solid var(--line);padding:18px 0}nav .wrap{display:flex;justify-content:space-between}.brand{font-weight:800;text-decoration:none}.crumbs{color:var(--muted);font-size:.9rem;padding-top:20px}.crumbs a{color:var(--gold)}header{padding:55px 0 34px}h1{font:700 clamp(2.3rem,6vw,4rem)/1.08 Georgia,serif;margin:0 0 14px}header p{color:var(--muted);max-width:760px;font-size:1.08rem}.grid{display:grid;grid-template-columns:repeat(auto-fit,minmax(270px,1fr));gap:15px;padding:15px 0 70px}.card{display:block;background:var(--panel);border:1px solid var(--line);border-radius:15px;padding:20px;text-decoration:none}.card:hover{border-color:var(--gold)}.card h2{font-size:1.05rem;margin:0 0 8px}.card p{margin:0;color:var(--muted);font-size:.9rem}.cta{border:2px solid var(--gold);border-radius:20px;text-align:center;padding:30px;margin:10px 0 65px}.cta a{display:inline-block;background:var(--gold);color:#111827;padding:12px 20px;border-radius:999px;text-decoration:none;font-weight:800}footer{border-top:1px solid var(--line);padding:30px 0;text-align:center;color:var(--muted)}`;
function shell({title,description,canonical,breadcrumb,content}){return `<!doctype html><html lang="en"><head><meta charset="utf-8"><meta name="viewport" content="width=device-width,initial-scale=1"><title>${escape(title)} | Bible Copilot</title><meta name="description" content="${escape(description)}"><link rel="canonical" href="${canonical}"><script async src="https://www.googletagmanager.com/gtag/js?id=G-TL50DGZ82K"></script><script>window.dataLayer=window.dataLayer||[];function gtag(){dataLayer.push(arguments)}gtag('js',new Date());gtag('config','G-TL50DGZ82K');</script><style>${style}</style></head><body><nav><div class="wrap"><a class="brand" href="/">✝ Bible Copilot</a><a href="/tools/verse-study/">Free Verse Study Tool</a></div></nav><div class="wrap"><div class="crumbs">${breadcrumb}</div>${content}</div><footer><div class="wrap">© 2026 Bible Copilot</div></footer><script src="/assets/revenue-config.js"></script><script defer src="/assets/revenue.js"></script></body></html>`}

const hubRoot=path.join(site,'bible');fs.mkdirSync(hubRoot,{recursive:true});
const mainCards=priorities.map(group=>`<a class="card" href="/bible/${group.slug}/"><h2>${escape(group.name)}</h2><p>${group.entries.length} verse studies</p></a>`).join('');
fs.writeFileSync(path.join(hubRoot,'index.html'),shell({title:'Bible Study by Book',description:'Explore Bible verse explanations, original-language studies, cross-references, and applications organized by book.',canonical:'https://mybiblecopilot.com/bible/',breadcrumb:'<a href="/">Home</a> › Bible',content:`<header><h1>Study the Bible by book</h1><p>Move from a passage to its context. These hubs organize Bible Copilot’s most useful verse explanations, original-language studies, cross-references, and applications.</p></header><main><div class="grid">${mainCards}</div><section class="cta"><h2>Study any passage in six guided modes</h2><p>Use Bible Copilot for Summary, Observe, Interpret, Theology, Apply, and Apologetics.</p><a data-cta-location="bible_hub" href="https://apps.apple.com/us/app/bible-copilot-ai-bible-study/id6758913373">Try Bible Copilot free</a></section></main>`}));

for(const group of priorities){
  const dir=path.join(hubRoot,group.slug);fs.mkdirSync(dir,{recursive:true});
  const cards=group.entries.slice(0,60).map(entry=>`<a class="card" href="${entry.url}" data-study-link><h2>${escape(entry.title)}</h2><p>Read the complete Bible study</p></a>`).join('');
  const desc=descriptions[group.slug]||`Explore verse explanations, original-language studies, cross-references, and applications from ${group.name}.`;
  fs.writeFileSync(path.join(dir,'index.html'),shell({title:`${group.name} Bible Study Guide`,description:desc,canonical:`https://mybiblecopilot.com/bible/${group.slug}/`,breadcrumb:`<a href="/">Home</a> › <a href="/bible/">Bible</a> › ${escape(group.name)}`,content:`<header><h1>${escape(group.name)} Bible study guide</h1><p>${escape(desc)} Start with the studies below, then use the free worksheet to examine any passage yourself.</p></header><main><div class="grid">${cards}</div><section class="cta"><h2>Build your own ${escape(group.name)} study</h2><p>Enter any reference and get a structured inductive study worksheet.</p><a href="/tools/verse-study/?reference=${encodeURIComponent(group.name+' 1:1')}" data-study-link>Open the free study tool</a></section></main>`}));
  for(const entry of group.entries){
    let html=fs.readFileSync(entry.file,'utf8');
    if(html.includes(`href="/bible/${group.slug}/"`))continue;
    const box=`<aside style="margin:28px 0;padding:16px 18px;border:1px solid #2a3858;border-radius:12px;background:#10182a;"><strong>Continue studying ${escape(group.name)}</strong><br><a href="/bible/${group.slug}/" data-study-link style="color:#d4af5f;">Browse the ${escape(group.name)} study guide</a> · <a href="/tools/verse-study/" data-study-link style="color:#d4af5f;">Build a verse worksheet</a></aside>\n`;
    html=html.replace('<div class="cta-box">',box+'<div class="cta-box">');
    fs.writeFileSync(entry.file,html);
  }
}

const sitemap=path.join(site,'sitemap.xml');let xml=fs.readFileSync(sitemap,'utf8');const urls=['https://mybiblecopilot.com/bible/',...priorities.map(g=>`https://mybiblecopilot.com/bible/${g.slug}/`)];let added=0;for(const url of urls){if(xml.includes(`<loc>${url}</loc>`))continue;xml=xml.replace('</urlset>',`<url><loc>${url}</loc><changefreq>weekly</changefreq><priority>0.9</priority></url></urlset>`);added++}fs.writeFileSync(sitemap,xml);
console.log(JSON.stringify({hubs:priorities.map(g=>({book:g.name,pages:g.entries.length})),articleLinksAdded:priorities.reduce((n,g)=>n+g.entries.length,0),sitemapAdded:added},null,2));
