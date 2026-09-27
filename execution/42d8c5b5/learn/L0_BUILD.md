# L0 BUILD — learn-and-remember decision record (T4, builder claude_fable_5)

Grant: `execution/42d8c5b5/learn/L0_GRANT.md` + parent addenda (vendor lock, oracle parity + deletion, Roman
journey mapping; X1/R1 as fixed inputs). North star: `execution/42d8c5b5/northstar/NORTH_STAR.md`.

## Deliverable

- Repo: growth-project-backend. Branch `cand/x42/learn-doc`, off `integration/importer` 9668af6c.
- File: `docs/decisions/2026-09-27-learn-and-remember.md` — HEAD_SHA_PLACEHOLDER, LINE_COUNT_PLACEHOLDER lines (≤ 600 target met).
- Author/committer Bradley Gleave <bradley@bradleytgpcoaching.com>, no AI trailer; committed through lefthook (no `--no-verify`).
- Pushed once, non-force, to `preserve` refs/heads/cand/x42/learn-doc. No PR opened.
- Clone: `/home/user/workspace/worktrees/x42-learn-doc` (standalone `git clone --no-hardlinks`, push URL of `origin` disabled).
- No code changed, no PG test run, no other worktree touched.

## What the record decides (D-L0-1 … D-L0-9)

1. One process, 11 steps, each mapped to owner (phone / computer / backend), Roman screen and the status field the phone
   reads. `E#19` chain: C2a, C2b-1, normalizer, engine, redaction survive; C2c/C3a/A1-A4/C3b merge into a backend decode call
   + a ≤150-LOC compiler + one URL-navigation action; C2b-2/3, confidence scoring, Learn UI, coach confirm, D1, F1 deleted.
2. AI runs on the backend only, on a `StructureDigestV1` (keys, kinds, value classes, templates with ids collapsed, query key
   names, constant headers). No value, id, name, email, header value or DOM ever leaves the device.
3. Grammar `LearnedProposalV1` = blueprint hints + `SourceMappingSpec` + `NativeRuleSet`; manifest is server-derived, never
   model output. Validators V-L0…V-L9 (backend parsers + cross-checks) before any source request; `normalizeBlueprint` gate in
   the extension; conformance C1-C4 on the actual staged rows before any native write.
4. Memory: `ScoutLearnedPlatform` (global, structure only), `ScoutRunLearnedPackage` (run pin), `ScoutLearnedPlatformEvent`
   (coach-scoped audit). Key = slug (authorized hostname) + structure fingerprint; versions; promotion only in the settle
   transaction after a verified import; drift = fingerprint change; structural failure invalidates. One
   `SourceRegistryProvider.forRun` replaces the seven per-site registry constructions → new site = rows, zero deploy, core diff 0.
5. AI never decides identity, writes or `complete`. Learned sources settle `partial/coverage_basis_unknown` until owner Q2;
   if Q2 yes, L6 appends `replay_terminal_enumeration` with a fail-closed evaluator rule.
6. Bounds: ≤3 model calls/run, 24k in / 4k out, 45 s per call, learn ≤ 2:00 of 5:00, per-coach and global daily caps, existing
   Perplexity channel; fallback = memory or zero source requests + truthful `failed` (no guess path).
7. Slice plan (below) after X1, R1, C2b-1 rescue. V1 proof + oracle parity on TrueCoach + deletion slice.
8. Eight owner questions (§6), none assumed.

## Slice table

| Id  | Repo      | Grade | Prod LOC | Depends on           | Parallel now |
| --- | --------- | ----- | -------- | -------------------- | ------------ |
| L1  | backend   | T1    | ~340     | none                 | yes          |
| X2  | extension | T2    | ~320     | C2b-1 landed         | yes          |
| X3  | extension | T2    | ~140     | X1                   | yes          |
| L2  | backend   | T4    | ~360     | L1                   | after L1     |
| L3  | backend   | T4    | ~300     | L2                   | after L2     |
| L4  | backend   | T3    | ~380     | L1, L2               | after L2     |
| X4  | extension | T3    | ~200     | X1                   | after X1     |
| X5  | extension | T4    | ~380     | X2, X3, X4, L4       | after L4     |
| L5  | backend   | T4    | ~280     | L3, L4               | after L3     |
| L6  | backend   | T4    | ~250     | L5, owner Q2         | blocked      |
| V1  | all       | T4    | 0        | L5, X5 (L6 if Q2)    | blocked      |
| DEL | ext+back  | T3    | negative | V1 parity            | blocked      |

## Open owner questions (recorded in §6 of the record)

Q-L0-1 extension-observed basis for `complete` (= S10 Q2); Q-L0-2 V1 live source account + consent; Q-L0-3 provider/model/spend
caps; Q-L0-4 production flags; Q-L0-5 Chrome Web Store review of `optional_host_permissions ["https://*/*"]`; Q-L0-6 NS resolves
S11 Q-S11-2 (extension automates declaration/claim/evidence); Q-L0-7 cross-tenant reuse of learned structure and whether a review
step precedes promotion; Q-L0-8 retention of learn tables.

## Commands (RC)

- `git clone --no-hardlinks` + `checkout -b cand/x42/learn-doc 9668af6c` — RC 0.
- `cp -al donor/node_modules` (rule 6) — slow on this box (> 30 min for the hardlink tree); completed before commit.
- prettier 3.9.9 `--check` on the doc — RC 0 (after one `--write`).
- `git commit` through lefthook (banned-cast, tsc, eslint, prettier, prod-readiness-quick) under `flock` on the canonical lock — see below.
- `git push preserve HEAD:refs/heads/cand/x42/learn-doc` — see below.

COMMIT_LOG_PLACEHOLDER

## Risks / notes

- C: the doc cites `E#20` (C2b-1) line numbers at 93a678a4; the rescue PR may move them. Citation only, no behaviour depends on it.
- C: prettier reflowed the step table and one bullet; content unchanged.
- A-class dependency named, not closed: without owner Q2, V1 cannot show `complete`; the record makes this the honest `partial`.
