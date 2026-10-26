#!/usr/bin/env node
const fs = require('fs');
const path = require('path');

const site = process.argv[2];
if (!site) throw new Error('Usage: node apply-ctr-optimizations.js <site-deploy>');

const changes = [
  {
    id: 'blog-01116',
    title: 'Philippians 1:6 Greek Meaning: “He Will Complete It” | Bible Copilot',
    h1: 'Philippians 1:6 Greek Meaning: “He Will Complete It”',
    description: 'Explore Philippians 1:6 in Greek: what “began,” “good work,” and “complete” mean, the verse’s context, and the confidence Paul expresses in God.',
    answer: '<strong>Philippians 1:6 expresses Paul’s confidence that God will finish the saving and transforming work he began in believers.</strong> The Greek verbs emphasize God as the one who initiates the work and carries it toward completion, while the surrounding context connects that confidence to the Philippians’ continuing partnership in the gospel.'
  },
  {
    id: 'blog-00336',
    title: 'Colossians 3:23 Greek: Work “For the Lord” | Bible Copilot',
    h1: 'Colossians 3:23 Greek Meaning: Work “For the Lord” Explained',
    description: 'Study Colossians 3:23 in Greek: the meaning of wholehearted work, “as for the Lord,” its household context, and how Christians should apply it.',
    answer: '<strong>Colossians 3:23 calls Christians to work wholeheartedly because their ultimate service is offered to the Lord, not merely to a human supervisor.</strong> The Greek phrase translated “from the heart” points to sincere, whole-person effort. In context, Paul addresses people with little social power and grounds their dignity and motivation in Christ.'
  },
  {
    id: 'blog-01472',
    title: 'Revelation 21:4 Meaning: “He Will Wipe Every Tear” | Bible Copilot',
    h1: 'Revelation 21:4 Meaning: “He Will Wipe Every Tear” Explained',
    description: 'Understand Revelation 21:4 in context: God wiping every tear, the end of death and mourning, and the promise of life in the new creation.',
    answer: '<strong>Revelation 21:4 promises that in God’s new creation, death, mourning, crying, and pain will finally end.</strong> The verse is not a guarantee that Christians avoid present suffering. It is a picture of God dwelling with his people and permanently removing the effects of sin and death.'
  },
  {
    id: 'blog-00416',
    title: 'Matthew 7:7 in Greek: Ask, Seek, Knock Explained | Bible Copilot',
    h1: 'Matthew 7:7 in Greek: Ask, Seek, Knock Explained',
    description: 'Explore Matthew 7:7 in Greek: what the commands ask, seek, and knock communicate, how persistence fits the context, and what Jesus promises.',
    answer: '<strong>In Matthew 7:7, “ask,” “seek,” and “knock” are present-tense Greek commands that portray active, continuing dependence on God.</strong> Jesus is not promising that every desire will be granted exactly as requested. The following verses compare God to a good Father who gives what is genuinely good to his children.'
  },
  {
    id: 'blog-01012',
    title: 'Genesis 1:1 in Hebrew: Bereshit, Bara and Elohim Explained | Bible Copilot',
    h1: 'Genesis 1:1 in Hebrew: Bereshit, Bara and Elohim Explained',
    description: 'Read Genesis 1:1 in Hebrew and explore bereshit, bara, Elohim, the grammar of the opening sentence, and what it says about God and creation.',
    answer: '<strong>Genesis 1:1 introduces God as the source of the heavens and the earth.</strong> The Hebrew opening, <em>bereshit bara Elohim</em>, places creation within God’s purposeful action. The verse’s main claim is theological rather than scientific: everything that follows owes its existence and order to God.'
  },
  {
    id: 'blog-00346',
    title: '2 Corinthians 5:17 in Greek: “New Creation” Explained | Bible Copilot',
    h1: '2 Corinthians 5:17 in Greek: “New Creation” Explained',
    description: 'Explore 2 Corinthians 5:17 in Greek: the meaning of “in Christ,” kainē ktisis or new creation, and what “the old has passed away” means.',
    answer: '<strong>2 Corinthians 5:17 means that anyone united to Christ participates in God’s new creation.</strong> The compact Greek phrase <em>kainē ktisis</em> means “new creation,” not merely an improved version of the old self. Paul places personal transformation inside the larger work of reconciliation God accomplishes through Christ.'
  },
  {
    id: 'blog-01741',
    title: 'Hebrews 12:11 Meaning: Discipline Explained | Bible Copilot',
    h1: 'Hebrews 12:11 Meaning: Discipline and Righteousness Explained',
    description: 'Understand Hebrews 12:11 in context: why discipline feels painful, what the peaceful fruit of righteousness means, and who is trained by it.',
    answer: '<strong>Hebrews 12:11 teaches that loving discipline is painful in the moment but can produce mature, righteous character in people who are trained by it.</strong> The verse belongs to an extended comparison between God’s formation of believers and a parent’s purposeful correction of children—not punishment intended to destroy them.'
  },
  {
    id: 'blog-01356',
    title: '1 Peter 2:9 in Greek: Chosen People and Royal Priesthood | Bible Copilot',
    h1: '1 Peter 2:9 in Greek: Chosen People and Royal Priesthood',
    description: 'Study 1 Peter 2:9 in Greek: chosen people, royal priesthood, holy nation, God’s possession, and the calling to proclaim his excellencies.',
    answer: '<strong>1 Peter 2:9 describes believers collectively as God’s chosen people, royal priesthood, holy nation, and treasured possession.</strong> Peter applies covenant language from the Old Testament to a community formed around Christ, then explains its purpose: to proclaim the excellencies of the God who called them out of darkness.'
  },
  {
    id: 'blog-00128',
    title: 'Romans 8:38–39 Explained: Nothing Can Separate Us | Bible Copilot',
    h1: 'Romans 8:38–39 Explained: Nothing Can Separate Us from God’s Love',
    description: 'Understand Romans 8:38–39 in context and explore the related passages behind Paul’s claim that nothing can separate believers from God’s love.',
    answer: '<strong>Romans 8:38–39 declares that no power in creation can separate believers from God’s love revealed in Christ Jesus.</strong> Paul’s sweeping list includes death, life, spiritual powers, present and future threats, and every created thing. The assurance rests on God’s action in Christ, not the believer’s ability to avoid hardship.'
  },
  {
    id: 'blog-00626',
    title: 'Lamentations 3:22–23 Hebrew: Mercies Every Morning | Bible Copilot',
    h1: 'Lamentations 3:22–23 Hebrew Meaning: Mercies New Every Morning',
    description: 'Explore Lamentations 3:22–23 in Hebrew: hesed, compassion, faithfulness, and why “mercies new every morning” appears in a book of grief.',
    answer: '<strong>Lamentations 3:22–23 finds hope in God’s covenant love while Jerusalem is devastated.</strong> The Hebrew language emphasizes steadfast loyalty, deep compassion, continual renewal, and reliability. “New every morning” does not deny grief; it confesses that judgment and suffering have not exhausted God’s mercy.'
  },
  {
    id: 'blog-01021',
    title: 'What Does Deuteronomy 31:6 Mean? “Be Strong and Courageous” | Bible Copilot',
    h1: 'What Does Deuteronomy 31:6 Mean? “Be Strong and Courageous”',
    description: 'Understand Deuteronomy 31:6 in context: Moses’ command to be strong and courageous, God’s presence with Israel, and how Christians can apply it.',
    answer: '<strong>Deuteronomy 31:6 tells Israel to face the transition into the promised land with courage because God would go with them and would not abandon them.</strong> The command was first given in a specific covenant and military setting. Its enduring principle is confidence rooted in God’s faithful presence, not confidence in human strength.'
  },
  {
    id: 'blog-00188',
    title: 'Matthew 6:33 Cross-References: Seek First God’s Kingdom | Bible Copilot',
    h1: 'Matthew 6:33 Cross-References: Seek First God’s Kingdom',
    description: 'Explore Bible passages connected to Matthew 6:33 about seeking God’s kingdom, trusting the Father for daily needs, righteousness, and reordered priorities.',
    answer: '<strong>Matthew 6:33 calls Jesus’ followers to make God’s kingdom and righteousness their governing priority instead of being ruled by anxiety about daily needs.</strong> Its strongest cross-references connect seeking God, trusting his provision, and living under his reign throughout both Testaments.'
  }
];

function replaceMeta(html, attribute, key, value) {
  const safe = value.replace(/&/g, '&amp;').replace(/"/g, '&quot;');
  const tag = new RegExp(`<meta[^>]+${attribute}=["']${key}["'][^>]*>`, 'i');
  const reverse = new RegExp(`<meta[^>]+content=["'][^>]*${attribute}=["']${key}["'][^>]*>`, 'i');
  if (tag.test(html)) return html.replace(tag, `<meta ${attribute}="${key}" content="${safe}">`);
  if (reverse.test(html)) return html.replace(reverse, `<meta ${attribute}="${key}" content="${safe}">`);
  return html;
}

const results = [];
for (const change of changes) {
  const file = path.join(site, 'blog', change.id, 'index.html');
  let html = fs.readFileSync(file, 'utf8');
  const before = html;
  const titleEscaped = change.title.replace(/&/g, '&amp;');
  const h1Escaped = change.h1.replace(/&/g, '&amp;');

  html = html.replace(/<title>[\s\S]*?<\/title>/i, `<title>${titleEscaped}</title>`);
  html = html.replace(/<h1[^>]*>[\s\S]*?<\/h1>/i, `<h1>${h1Escaped}</h1>`);
  html = replaceMeta(html, 'name', 'description', change.description);
  html = replaceMeta(html, 'property', 'og:title', change.h1);
  html = replaceMeta(html, 'property', 'og:description', change.description);
  html = replaceMeta(html, 'name', 'twitter:title', change.h1);
  html = replaceMeta(html, 'name', 'twitter:description', change.description);

  html = html.replace(/("headline"\s*:\s*")[^"]*(")/i, `$1${change.h1.replace(/"/g, '\\"')}$2`);
  html = html.replace(/"description"\s*:\s*[\s\S]*?,\s*"author"/i, `"description":"${change.description.replace(/"/g, '\\"')}","author"`);

  if (!html.includes('data-ctr-optimization="2026-07-15"')) {
    html = html.replace(/(<div class="post-body">\s*)/i, `$1<p class="bc-direct-answer" data-ctr-optimization="2026-07-15">${change.answer}</p>\n`);
  }

  fs.writeFileSync(file, html);
  results.push({ id: change.id, changed: html !== before, title: change.title });
}

console.log(JSON.stringify({ updated: results.filter(r => r.changed).length, pages: results }, null, 2));
