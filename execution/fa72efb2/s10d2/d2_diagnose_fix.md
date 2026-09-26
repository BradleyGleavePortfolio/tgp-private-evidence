# S10-D D2 proof-v1 failure — diagnosis and minimum fix (EXEC-FA72EFB2, T4)

Grant: s10d2/D2_DIAGNOSE_FIX_GRANT.md. Rules: execution/fa72efb2/WORKER_RULES.md. Clone:
/home/user/workspace/worktrees/fa72-d2, branch fa72/d2-r1, base 7fdcbc04, candidate-v1 144269d1.
Preserved evidence read, never edited: s10d2/PROOF_V1_FINDING.md, s10d2/binding/v1/run/{jest.log,d2-pg-proof.log}.
No PostgreSQL was run. No `.ts` under `src/` was edited (CORE DIFF = 0 kept; gate result below).

## Verdict (one line)

The core behaved exactly as designed; the D2 candidate's `complete` cases were wrong because they staged
`clients` rows, and a staged `clients` row cannot be in a `complete` run at this head — the `clients`
writer is still the LEGACY handoff (ledger `target_kind` NULL, no provenance), which S9-A classifies bucket f
`unresolved:evidence_only` → C-ID `unresolved_identities`. Classification: (ii)+(iii) fixture-shape /
spec-expectation error on top of a real, documented, owner-reserved core gap (iv-adjacent: S8-D typed
`person` handoff, blocked on D-S8-2). Minimum fix made in ONE D2-owned file (the pg spec); product finding
recorded below (B) for the parent.

## 1. Root cause with file:line evidence

Live chain for SET.base (2 × `u10-members` → clients, `u10-routines` + `u10-sessions` → workouts):

1. The S8-G pass reconstructed every row (jest.log: `clients staged 2 reconstructed 2`, `workouts 1/1, 1/1`,
   `unmapped_families []`) — the pass is not at fault.
2. `clients` persist is the legacy writer: `src/scout/reconstruct/families.ts` L75-103 (`clientsFamily.persist`
   returns `person.id`, a plain string), documented at L157-158 "`clients` targets `Person` (legacy result,
   ledger kind NULL)". No `ImportNativeProvenance` row is written for clients (only `native-writers.ts`
   `persistProgram` / `persistWorkoutTemplate` / `persistEvidence` write provenance).
3. The engine writes such a result with `target_kind` NULL: `src/scout/scout-reconstruct.service.ts` L510-520
   ("Legacy `string | null` result: ledger target_kind stays NULL (never reinterpreted)").
4. S9-B reads it back as `{status:'reconstructed', target_kind: null, provenance: null}`:
   `src/scout/reconciliation/facts.service.ts` L699-704 (`isLedgerTargetKind(null)` → null; no provenance
   row matches `(platform, 'clients', source_id)` L757-778).
5. S9-A bucket f: `src/scout/reconciliation/reconcile.ts` L136-146 — `!isNativeKind(row.target_kind)` →
   `unresolved` / `unresolved:evidence_only` (clients is neither client-owned nor client-linked: facts.service.ts
   L143 `CLIENT_OWNED_FAMILIES = {client_history}`, L671-672 `clientSourceId` is null for the clients family).
   Designed so: S9-DOC `docs/decisions/2026-09-25-s9-reconciliation.md` L110 (bucket f: "`target_kind` NULL or
   `scout_entity` … `unresolved`"); pinned by `test/scout/reconciliation/reconcile.spec.ts` L417 "(f) target_kind
   NULL, coach-owned family → evidence_only".
6. C-ID: `reconcile.ts` L338-348 (`f.unresolved + f.rejected + f.failed > 0` in a mapped family) →
   `unresolved_identities`, which precedes C-COV in D-S9-2 order (L355, `S9_REASON_CODES`). Hence:
   - (a) and R41: `partial/unresolved_identities` instead of `complete` (jest.log L294/L316);
   - (e) and (f): `unresolved_identities` instead of `coverage_basis_unknown` — coverage WAS unknown as
     intended, but C-ID held first and masked it (jest.log L341/L348);
   - (b), (c), (d), R27 "passed" for the wrong reason ((b)/(c) trivially, via the clients rows).

No-DB reproduction (`s10d2/repro/d2_reconcile_repro.ts`, run with the clone's ts-node under the flock, RC=0):
feeding `reconcile()` the facts S9-B would collect for SET.base gives, per clients-row handoff —
`legacy` → `partial/unresolved_identities`, clients `{staged 2, native_present_verified 0, unresolved 2,
reasons [{unresolved:evidence_only, 2}], qualifiers [roster_bridge_pending], completeness_basis
source_signed_enumeration, observed_unique 2}` (exactly the live shape); `typed person` → `complete`;
`no clients rows` → `complete` with clients `{staged 0, completeness_basis source_signed_enumeration,
observed_unique 0}`.

Why the e2e half said "known + covering" for the same set: `test/scout/s10/s10-unseen.e2e.spec.ts` L298-340
runs ONLY the S10-C evaluator (`evaluateCoverage` over declaration + statements + staged digests = C-COV). It never
builds ledger/provenance facts and never calls `reconcile()`, so C-ID (buckets a-k) is not exercised there. Its
(a) assertion (every family known and covering) is TRUE and stays true; it simply is not the `complete` predicate.

Comparison with the accepted live proofs: `test/rls-g2-s10c.spec.ts` L14-22 and L119-122 state that S10-C is NOT
the live `complete → complete` proof (worker registry has no manifests; every terminal there is
`partial/coverage_basis_unknown`, `expect(row.terminal_status).not.toBe('complete')`). The S9 / S11 PG specs never
assert `complete` either (`rg "toBe\('complete'\)" test/` → only D2). So D2 was the FIRST live attempt at
`complete`; the only accepted `complete` fixture in the repository is the unit-tier R33 shape
`test/scout/reconciliation/facts.service.coverage.spec.ts` L221-250 `cleanRun` + L401-425: ONE `programs` row
(typed `workout_program` + provenance `created`), `clients` and `workouts` declared and source-signed as EMPTY
sets (`observe(db,'clients',[])`) → `complete/null`. It stages no `clients` row — the design's reachable shape.

Decision: (i) assets are correct (mapping, identity keys, native rules and manifest all resolved and verified
live; coverage was known for all three families). (ii)/(iii) the fixture SHAPE used for the `complete` cases and
the spec's expectation (`persons: 2` together with `complete`, L304 of v1) contradict S8-DOC §4.1 qualifier
"until S8-D" (`docs/decisions/2026-09-24-s8-native-contract.md` L372-374), families.ts L157-158, S9-DOC bucket f,
and S10-DOC Q5 (L482-483). (iv) holds for the narrower property "a run that stages `clients` rows can be
`complete`": that needs the typed `person` handoff (S8-D), a core change reserved to the owner (D-S8-2). Per the
grant ("never weaken (a)'s `complete` unless the design says complete is impossible — then say so"): the design
says it is impossible WITH staged clients rows and possible WITHOUT them, so (a) keeps `complete` on the
native-clean shape and a new case pins the clients truth live.

## 2. Minimum fix (D2-owned path only: `test/scout/s10/s10-unseen.pg.spec.ts`; fixtures, assets, e2e unchanged)

Diff: s10d2/d2_fix_worktree.diff (114 insertions, 21 deletions, 1 file). Summary:

- Header: a "SHAPES" paragraph stating the clients limitation with the file:line chain above.
- `ROSTER` / `NATIVE_CLEAN` derived IN the spec from the unchanged fixture `SET.base` (members rows vs the two
  workouts rows) — no fixture bytes change; `SET.base` keeps its meaning for the e2e.
- `basisOf(token)` → `familyOf(family)` (declared-only entries have no tokens) + `evidenceRows(coach)` helper.
- (a) `complete` on `NATIVE_CLEAN`: `required_families` = [clients, programs, workouts]; all three
  `source_signed_enumeration`; clients/programs `observed_unique` 0 (proven empty, never absent); workouts
  `{staged 2, native_present_verified 2, unresolved 0, observed 2}`; native counts `{persons 0, plans 2,
  programs 0}`; 0 evidence rows.
- R41 replay on `NATIVE_CLEAN` (plans 2 before, unchanged after, second run `complete`).
- (b) on `NATIVE_CLEAN` — now discriminating: the ONLY delta from (a) is the withheld rule set; asserts workouts
  `unresolved 2`, reasons exactly `[{unresolved:evidence_only, 2}]`, plans 0, evidence rows 2.
- (c) on `NATIVE_CLEAN + client_linked` — asserts `reason_code unresolved_identities`, workouts `{staged 3, j 2,
  unresolved 1}`, reasons exactly `[{unresolved:no_native_client_principal, 1}]` (D-S8-2 truth), plans 2, 1
  evidence row.
- (d) on `NATIVE_CLEAN + undeclared_family` (assertions unchanged).
- (e)/(f) on `NATIVE_CLEAN`: `conditions` exactly `['coverage_basis_unknown']` (C-ID no longer masks C-COV);
  (e) programs `{completeness_basis 'none', observed_unique null}`.
- R27 (g) on `NATIVE_CLEAN + canonical_token`: adds `reason_code unresolved_identities` and programs
  `{staged 1, j 0, source_signed_enumeration, observed 1}` (covered but unmapped by the pass).
- NEW (h) `ROSTER + NATIVE_CLEAN` (= v1's SET.base): `partial/unresolved_identities`, `conditions` exactly
  `['unresolved_identities']`, clients `{staged 2, j 0, unresolved 2, reasons [{unresolved:evidence_only,2}],
  qualifiers [roster_bridge_pending], source_signed_enumeration, observed 2}`, workouts `{j 2, unresolved 0}`,
  native `{persons 2, plans 2, programs 0}`, 0 evidence rows. This is the failed v1 case asserted truthfully.

Honesty check on every changed assertion (derivations, all from code read above):
(b) `persistEvidence` with `recordNoNativePrincipal:false` writes no provenance (native-writers.ts L371-380,
L404-410) → ledger `scout_entity` → bucket f `evidence_only`. (c) client-linked → `mode:'evidence'`
(native-families.ts L152-160) → evidence row + unresolved provenance `no_native_client_principal`
(native-writers.ts L404-410) → reconcile.ts L139-146 `client_linked` true → `no_native_client_principal`; the E-R3
edge is from a non-bucket-j identity so C-REL stays clear (reconcile.ts L303). (g) planner leaves canonical token
`programs` unmapped (`family-plan.ts` L96-100) → ledger `skipped unresolved_family:programs`; S9-B groups it as
the MAPPED `programs` family (`resolveFamily`, facts.service.ts L231-242) → bucket e unresolved → C-ID, not
C-FAM. (a)/(e)/(f) declared-only entries come from `reconcile.ts` L358-374 (`declaredOnly`), coverage of an
empty staged set is `known` when the source signs the empty enumeration (e2e (a) already proves it for
`programs`, observed 0). Case counts are 9 (was 8).

## 3. Commands run (all from /home/user/workspace/worktrees/fa72-d2 unless noted) and RC

| # | Command | RC |
| - | ------- | -- |
| 1 | `flock -w 3600 …/test-validation.lock bash -c 'NODE_OPTIONS=--max-old-space-size=3072 ./node_modules/.bin/ts-node --transpile-only -P tsconfig.json …/s10d2/repro/d2_reconcile_repro.ts'` (0.6 s; slot marker present) | 0 |
| 2 | `prettier --check test/scout/s10/s10-unseen.pg.spec.ts` (prettier 3.9.9 from runtime/tools, read-only PATH) — before formatting | 1 (3 wraps) |
| 3 | `prettier --write …pg.spec.ts` then `prettier --check …pg.spec.ts` | 0 |
| 4 | `flock … bash -c 'NODE_OPTIONS=… ./node_modules/.bin/eslint test/scout/s10/s10-unseen.pg.spec.ts test/scout/s10/s10-unseen.e2e.spec.ts'` (slot marker present) | 0 |
| 5 | `flock … bash -c 'NODE_OPTIONS=… ./node_modules/.bin/tsc -p tsconfig.json --noEmit'` (started while the slot marker was present; log /tmp/d2_tsc.log) | 0 |
| 6 | `flock … bash -c 'env -u G2_S10B_DATABASE_URL NODE_OPTIONS=… ./node_modules/.bin/jest -c jest.config.js --runInBand --ci --runTestsByPath test/scout/s10/s10-unseen.e2e.spec.ts test/scout/s10/s10-unseen.pg.spec.ts'` (slot marker present, 16:47Z) → e2e 16/16 PASS, pg suite `describe.skip` 9 skipped, 10.3 s (s10d2/d2_fix_jest_nodb.log) | 0 |
| 7 | `git add test/scout/s10/s10-unseen.pg.spec.ts` + `flock … git commit -F /tmp/d2_commit_msg.txt` with `GIT_AUTHOR_*`/`GIT_COMMITTER_*` = Bradley Gleave <bradley@bradleytgpcoaching.com>, hooks ran (lefthook pre-commit: banned-cast-tokens, eslint, prettier, tsc 49 s, prod-readiness-quick; commit-msg: no-ai-tokens — all ✔; s10d2/d2_fix_commit.log) | 0 |
| 8 | `bash scripts/s10-core-diff-gate.sh 7fdcbc04dc…` — MY typo while pasting the 40-hex B (`dc` for `4d`); the gate refused it at the args check as designed ("B is not a commit") | 1 (operator error, not a gate finding) |
| 9 | `bash scripts/s10-core-diff-gate.sh 7fdcbc044dba1747d0db2f2750ced951f3b6b752` → checks 1-7 ok, `PASS B=7fdcbc04… HEAD=275e458c…` | 0 |
| 10 | `git status --porcelain --untracked-files=all | wc -l` → 0 (clean) | 0 |

Note: 16:29Z-16:47Z the parent had removed `PROOF_SLOT_FREE` (S11-B PG proofs); the jest e2e, the hook-run
commit and the gate were held until the marker returned and then run with it present. An earlier background
`tsc` launch (step 5) was killed with the tool shell before it produced output; it was relaunched under
`setsid` while the marker was present and completed RC=0 — only that completed run is counted.

## 4. New head

`275e458ca5a6b3684bb6ec83edb2a854056a6fd0` on fa72/d2-r1 (parent 144269d1, base 7fdcbc04), ONE new commit,
author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no trailers, subject
`test(scout): settle the unseen source complete on the native-clean shape (S10-D D2)`.
`git diff --name-only 7fdcbc04 HEAD` = the 8 allowed D2 paths exactly; `git diff 144269d1 HEAD` touches only
`test/scout/s10/s10-unseen.pg.spec.ts` (+114/−21; file now 454 LOC, sha256
`a3dfcd93a648851ffd2f8cb7a6221c3ea1fffc91f7ad77cbb5d9f94ae1d38403`).

Evidence files written (sha256):
- s10d2/d2_fix_commit.diff `407e3f9a1823805e5f33eb34d8b8e7c999ed5bf09c364c3897f3f9fae2588b09` (identical bytes to d2_fix_worktree.diff)
- s10d2/d2_fix_jest_nodb.log `83e0e302a8acd5ad3e8f2657e4d8f71be634d6b9e0c6336639d155bfd8db7e71`
- s10d2/d2_fix_tsc.log `08a37328d6e51ce41316a57df98b53c3d70700cc4e9d146b0bae3e91a763b930` (contains only `TSC_RC=0`)
- s10d2/d2_fix_commit.log `db8f85e243ca713ffed0360d8ab97113fef3948d4ad85dbdfc5929226af8419b` (ANSI stripped)
- s10d2/d2_fix_commit_head.txt `47773cc4b0a01203b0bc39e190156467357c55e9d05c64ecf1bc2e886003d6db`
- s10d2/repro/d2_reconcile_repro.ts `52452e18c6dcfc306589649296311c71fcbfada1fd97184588f13566395bd9f6`
- test/scout/s10/s10-unseen.pg.spec.ts @275e458c `a3dfcd93a648851ffd2f8cb7a6221c3ea1fffc91f7ad77cbb5d9f94ae1d38403`

## 5. Product finding (B) — for the parent (north-star)

- CLASS: B (candidate/proof-shape, on top of a known, documented, owner-reserved core gap).
- FINDING: at head 7fdcbc04 NO source — existing (TrueCoach, conformance) or new — can settle `complete` if the
  run stages a single `clients` row: `clientsFamily.persist` (families.ts L83-101) is the legacy handoff
  (ledger kind NULL, no provenance) so S9 bucket f applies to every roster identity. The mission sentence "new
  source → core diff 0 → complete" therefore holds today only for runs whose staged set is native-clean
  (workouts/programs) with `clients` (and any other declared family) proven EMPTY by the source. Real imports
  stage rosters; they will settle `partial/unresolved_identities` with `unresolved:evidence_only ×N` and
  `roster_bridge_pending` until S8-D lands the typed `person` outcome + provenance for clients.
- CONCRETE HARM if ignored: a landed D2 would have been read as proof of the north-star for realistic sources;
  it proves the mechanism for a roster-free run and truthfully proves the roster block ((h)).
- EXACT DECISION BLOCKED: whether D2's `complete` proof on the native-clean shape (+ the live (h) pin) is
  accepted as the D-S10-5 evidence, and whether/when S8-D (typed `person` handoff: `LEDGER_TARGET_KIND.person`
  already exists, persist-outcome.ts L16; S8-DOC §4.1 already says `native_kind` is `person`) is scheduled —
  D-S8-2 is owner-reserved (S8-DOC L84-89; S9-DOC L508-510; S10-DOC Q5).
- MINIMUM CLOSURE: (1) accept the reshaped D2 proof (this commit) and re-run one real-PG proof; (2) record S8-D
  as the blocker of realistic `complete` in the mission roadmap; (3) optionally, a unit-tier note in
  reconcile.spec that `clients` legacy rows are bucket f (already pinned at L417 — no new test needed).
- EXECUTION UNLOCKED: D2 landing (#561) on truthful assertions; S8-D scoping.

## 6. Residual risks

- (C) Each new live assertion was derived from code, not from a run; the parent's one real-PG run is the check.
  Highest-uncertainty items, in order: (g)'s exact ledger reason string is irrelevant to the bucket but the
  `observed_unique 1` for programs relies on the evaluator half already proven in the e2e R27 case; (h)'s
  `qualifiers: ['roster_bridge_pending']` relies on facts.service.ts L145-148 for a staged mapped clients entry
  (the repro confirms it in-process).
- (C) `toMatchObject` with array values requires exact arrays (`reasons`); every family in these cases has
  exactly one reason code by construction, so no order ambiguity.
- (C) The spec's `it` title for (h) is long (one string; prettier/eslint accept it).
- (C) Case count rises 8 → 9; the runner's `expect_tests=8` in the v1 binding (d2-pg-proof.log L545) must be
  9 in the next binding version — a binding change the parent/binding builder owns, not this fix.
- (C) Receipt-order note from PROOF_V1_FINDING.md unchanged (RECEIPTS.sha256 written before `END`).
- (B, recorded above) realistic-roster `complete` needs S8-D; nothing in D2 can or should work around it.
