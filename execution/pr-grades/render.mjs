import fs from 'node:fs';
import path from 'node:path';

// Administrative snapshot rendering only; never product source or a PR gate.
const dir = path.dirname(new URL(import.meta.url).pathname);
const decisions = JSON.parse(fs.readFileSync(path.join(dir, 'decisions.json'), 'utf8'));
const names = {
  backend: 'growth-project-backend',
  mobile: 'growth-project-mobile',
  extension: 'tgp-importer-extension',
  context: 'tgp-agent-context',
};
const routing = {
  T0: 'GPT-5.6 Luna / Low; deterministic checks, no mandatory AI audit',
  T1: 'GPT-5.6 Terra / Medium; targeted AI code review',
  T2: 'Claude Sonnet 5 / High; one independent adversarial audit',
  T3: 'Claude Opus 5 / XHigh; architecture + independent audit, second lens for G06 triggers',
  T4: 'Claude Fable 5 / High; two independent final-head adversarial attestations',
};
const generated = new Date().toISOString();
const rows = [];
let md = `# TGP public PR consequence grades\n\nObserved ${generated}. This covers every open PR in the four preserved TGP repositories, not only the active cumulative S-lanes. Per-PR head and GitHub-reported base are recorded separately from current repository main; a historical reported base is not asserted to be today's main.\n\n`;
md += `## Interpretation\n\n- **Scoped:** consequence assessed from current change surfaces and retained applicable authority/evidence. This is a grade, not an audit clearance.\n- **Provisional:** explicit conservative grade under G06, using the higher plausible consequence while retained work remains inactive. No implied review, new dispatch, downgrade or permission to land; the scope must be confirmed before activation. This avoids reopening broad historical reconnaissance.\n- **Roman #293:** retains its previously established T1 private leaf-view scope; not a downgrade of the T4 operational mobile foundation. #294 is separately T2 for terminal/result semantics. Integration into real lifecycle/identity authority must be regraded independently.\n- **Other retained work:** preserve unchanged; do not start unrelated scope while importer blockers remain. A title or small diff never determines grade by itself.\n\n`;
md += `## Builder and review routing\n\n| Tier | Required route |\n|---|---|\n`;
for (const [tier, route] of Object.entries(routing)) md += `| ${tier} | ${route} |\n`;
for (const [key, repo] of Object.entries(names)) {
  const prs = JSON.parse(fs.readFileSync(path.join(dir, `${key}.json`), 'utf8'));
  const map = decisions[key];
  const observed = new Set(prs.map(p => String(p.number)));
  for (const number of Object.keys(map)) if (!observed.has(number)) throw new Error(`Stale decision ${key}#${number}`);
  md += `\n## ${repo}\n\n| PR | Exact current head | Grade | Basis | Consequence rationale |\n|---|---|---|---|---|\n`;
  for (const pr of prs) {
    const decision = map[String(pr.number)];
    if (!decision || !routing[decision[0]]) throw new Error(`Ungraded ${repo}#${pr.number}`);
    const [tier, rationale, basis] = decision;
    const row = { repository: `BradleyGleavePortfolio/${repo}`, ...pr, tier, rationale, basis, canonicalRoute: routing[tier], observedAt: generated };
    rows.push(row);
    md += `| [#${pr.number}](${pr.url}) | \`${pr.headRefOid}\` | **${tier}** | ${basis} | ${rationale} |\n`;
  }
}
md += `\n## Coverage and authority\n\n${rows.length} distinct open PRs have explicit grades and full head identities. Exact reported bases, titles, routing and observation timestamps are retained in \`PUBLIC_PR_GRADES.json\`. No remote PR descriptions, source, protection settings or merge state were changed by this register. Authoritative active writer/slot state is \`execution/DISPATCHES.md\`; slice contracts remain separate from this preserved-PR inventory.\n`;
fs.writeFileSync(path.join(dir, 'PUBLIC_PR_GRADES.md'), md);
fs.writeFileSync(path.join(dir, 'PUBLIC_PR_GRADES.json'), JSON.stringify(rows, null, 2) + '\n');
console.log(JSON.stringify({ count: rows.length, ungraded: 0, tiers: rows.reduce((a, r) => (a[r.tier] = (a[r.tier] || 0) + 1, a), {}), observedAt: generated }));
