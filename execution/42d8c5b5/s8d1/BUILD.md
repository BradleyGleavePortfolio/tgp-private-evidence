# S8-D1 — typed person handoff — BUILD (rebuild, 42d8c5b5)

Builder: T4 (worker rules `execution/42d8c5b5/WORKER_RULES.md`; grant `s8d1/GRANT.md`).
Predecessor candidate (fa72efb2: 42c8ed30 / 03b574e4) was LOST from the repo; rebuilt from
`execution/fa72efb2/s8d1/s8d1_build.md` + `s8d1_review.md` against the same contract.

## Heads

| what | value |
|---|---|
| base (origin/main) | `aed23289024898cceca7385d3778cd7373b7424d` |
| candidate HEAD | `68cfe342248dc61de660a570eb4e565f8bdc0128` |
| candidate tree | `3bd29f97419b0eff3e4b43228d5384101e0fdd0d` |
| pushed | `refs/heads/cand/x42/s8d1` → `68cfe342` (verified with `git ls-remote preserve`) |
| author / committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (both; lefthook pre-commit + commit-msg ran, no `--no-verify`) |
| clone | `/home/user/workspace/worktrees/x42-s8d1`, branch `x42/s8d1`, working tree clean after commit |
| commits | 1 (`feat(scout): S8-D1 typed person handoff — create-only, provenance-verified clients writer`) |

## Design (contract `docs/decisions/2026-09-26-s8d-person-link.md` §5.1 steps 1–4; owner D-S8-2 (a))

`clientsFamily.persist` → `persistPerson(tx, coachId, {source_platform, source_id}, 'clients', client)`
in `src/scout/reconstruct/native/person-writer.ts`:

1. `findProvenance(coach, platform, 'clients', source_id)`. Resolved row → `verifyProvenanceTarget`:
   wrong kind / null id → `unresolved:identity_conflict`; `person.findUnique({id})` missing or
   `state = Deleted` → `unresolved:native_target_removed`; other coach → `identity_conflict`; else
   `ok` (byte-identical provenance, no write). Unresolved row is kept and promoted in step 3.
2. No resolved provenance → `person.findUnique` on `(coach_id, source_platform, source_person_id)`
   (the ext-ref unique). Live row of this coach → `recordAlreadyPresent` (pre-D1 Persons adopt);
   Deleted → `native_target_removed`; other coach cannot match (the key includes coach).
3. Otherwise `person.create` (`display_name`, ext ref, coach; Prisma default `state = InvitePending`)
   and `recordCreated` / `promoteToCreated` (tags `[]`). Returns
   `{ok:true, targetId, targetKind:'person', unresolvedChildren:0}`.
4. Never updates an existing Person (coach edits survive replay); never mints a User; email is
   never read as an identity key. Concurrency: the ext-ref unique raises P2002 on a same-identity
   race; the engine's existing `retryContention` re-runs the transaction once and step 2 adopts the
   winner (`already_present`).

Engine (`scout-reconstruct.service.ts`) untouched: it already stamps `target_kind` when the family
returns a typed outcome. S9 `readPersons` now selects `state, updated_at` and maps
`archived_at = Deleted ? updated_at : null`, so a Deleted Person is bucket (i) `removed`.

## Files

Production (`git diff --numstat aed23289 HEAD -- src` = **+202 / −31**; 5 files; grant ceiling 1,000):

| file | Δ | change |
|---|---|---|
| `src/scout/reconstruct/native/person-writer.ts` (new) | +137 | `persistPerson` (above) |
| `src/scout/reconstruct/native/native-provenance.ts` | +27 | `recordAlreadyPresent(tx, key, existing, kind, id)` — create, or promote an unresolved row in place |
| `src/scout/reconstruct/native/native-contract.ts` | +6/−1 | `NATIVE_KIND.person` |
| `src/scout/reconstruct/families.ts` | +21/−26 | `clientsFamily.persist` → `persistPerson`; legacy string-id handoff removed; doc comments |
| `src/scout/reconciliation/facts.service.ts` | +11/−4 | `readPersons` selects `state`/`updated_at`; Deleted → `archived_at` |

No migration (S11 lane keeps 173). No platform slug literal in `src` (`rg` for `s10_unseen` /
second-source slug in `src`: 0 hits). Unknown never silently zero (every non-ok path returns a
typed `unresolved:*` reason). `test/scout/s11/journey-full.pg.spec.ts` NOT touched.

Tests (`git diff --numstat aed23289 HEAD -- test` = **+1003 / −130**; 9 files):

| file | change |
|---|---|
| `test/scout/reconstruct/native/person-writer.spec.ts` (new, 12 `it`) | create order/shape (raw vs trimmed id), null name, edited display_name survives replay (calls = [provenance.findUnique, person.findUnique]), Deleted/vanished → `native_target_removed` with byte-identical provenance, foreign coach / wrong kind → `identity_conflict`, two coaches isolated, pre-D1 adoption → `already_present` then verify path, Deleted pre-D1 not adopted, unresolved+legacy promoted in place, 5 runs → 1 Person / 1 provenance / name v0, rollback via `failAt` |
| `test/scout/reconstruct/native/fake-native-tx.ts` | `persons` map, `person.findUnique` (id or ext ref) / `person.create` (P2002 on dup), `seedPerson`, snapshot incl. persons |
| `test/scout/reconstruct/scout-reconstruct.service.spec.ts` | fake `person` → findUnique/create (+ P2002-once + poison), `importNativeProvenance` primitives, ledger shape asserts `target_kind:'person'`, display-name replay is create-only, +2 cases (Deleted → skipped `native_target_removed`; pre-D1 adoption → ledger `legacy-person`/person, one `already_present` over two runs), P2002 race asserts 1 provenance row |
| `test/scout/reconstruct/conformance-alpha.e2e.spec.ts`, `mapping-spec.third-source.spec.ts` | same fake swap; replay asserts N `clients/person/created` provenance rows |
| `test/scout/reconciliation/facts.service.spec.ts` | +4 (`S8-D1 typed person kind`): present_owned for created & already_present (only `coverage_basis_unknown`); Deleted → removed / other coach → foreign_owner → `identity_conflict` + `native_target_removed`; NULL-kind ledger + later person provenance → still bucket f `unresolved:evidence_only`; single bounded `person.findMany({id:{in}})` read |
| `test/scout/reconciliation/reconcile.spec.ts` | +2 verdict cases: C6 negative (verified clients + client-owned evidence family → `partial / unresolved_identities`, qualifier carried) and positive (→ `complete / null`, `roster_bridge_pending` carried) |
| `test/scout/s10/s10-unseen.pg.spec.ts` | case (h) flipped to `complete` / null / `[]`; clients `{2,2,0,[],['roster_bridge_pending'],source_signed_enumeration,2}`; native 2/2/0, evidence 0; **new counts**: `ImportNativeProvenance entity_type='clients' AND native_kind='person' AND outcome='created'` = 2, `Person state='InvitePending'` = 2, ledger `u10-members` reconstructed `target_kind='person'` with matching provenance target = 2; header rewritten; cases (a)–(g) untouched |
| `test/scout/s11/journey-induction.pg.spec.ts` | header comment only (native-clean shape is now a proof-shape choice, not a constraint) |

`rg 'person\.upsert' src test` → 0 hits.

## Gates (all in the clone; heavy ones under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`, inode 657581)

| gate | command | RC |
|---|---|---|
| prettier 3.9.9 (runtime tools) | `prettier --write` then `--check` on the 14 touched files | 0 |
| eslint | `npx eslint --no-warn-ignored --max-warnings 0 <14 files>` | 0 |
| tsc | `npx tsc --noEmit -p tsconfig.json` | 0 |
| jest | `NODE_OPTIONS=--max-old-space-size=3072 npx jest --runInBand test/scout/reconstruct test/scout/reconciliation src/scout test/scout/roster test/scout/s10/s10-unseen.pg.spec.ts test/scout/s11/journey-induction.pg.spec.ts` | 0 — **30 suites passed, 702 tests passed, 13 skipped** (2 suites = the two PG specs `describe.skip` without a lane) |
| lefthook pre-commit | prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc | all ✔ (51.8 s) |
| lefthook commit-msg | no-ai-tokens | ✔ |
| push | `git push preserve HEAD:refs/heads/cand/x42/s8d1` | 0 (new branch, `68cfe342`) |

Not run (parent-only per rules): any `*.pg.spec.ts` live lane, `rls-g2-*`, PostgreSQL.

## PG lanes the parent must run (expected)

| lane | expectation |
|---|---|
| S10-B lane, `test/scout/s10/s10-unseen.pg.spec.ts` | 9 `it` pass; (h) settles `complete`, provenance count 2, InvitePending 2, typed-ledger count 2 |
| `rls-g2-s10b` / `rls-g2-s10c` | 32 unchanged (no schema, no policy change) |
| S11 lane (`journey-core` 8, `readiness` 6, `settle-redrive` 8, `journey-induction` 4, `rls-g2-s11` 6, `g2-s11-db-guard` 95) | 127 unchanged (migration count stays 173) |
| S11 `journey-full.pg.spec.ts` | 6 pass ONLY after the parent applies `execution/fa72efb2/s8d1/journey-full_leg-b_j20_required-changes.r3.patch` (review B1: J20 range walk `..HEAD` and leg B asserting `partial` are pinned to the pre-D1 truth). Without the patch expect 2 failures there — that is the design's expected outcome, not a regression |
| S8 / S9 G2 lanes | unchanged |

## Findings

- **A** — none.
- **B1 (carried from fa72efb2 review, parent-owned)** — HARM: `journey-full.pg.spec.ts` leg B still asserts the pre-D1 `partial` and the J20 range walk. EXACT THING BLOCKED: a green S11 lane on this candidate. MINIMUM CLOSURE: parent applies the r3 patch on top of `68cfe342`. STATE UNLOCKED: S11 lane 133/133.
- **B2 (risk, low)** — `recordAlreadyPresent` for a pre-D1 Person uses the `updated_at`-free ext-ref lookup; a Person the coach hand-deleted (`Deleted`) is NOT adopted and the row settles `native_target_removed`. This is the contract's step 4 semantics, but a roster replay after a coach deletion will keep the run `partial` until D2 defines resurrection. Not blocking.
- **C** — the two PG specs were verified by `describe.skip` only in this build (tsc + eslint cover them; live truth is the parent's lane run). `roster_bridge_pending` is still emitted (retiring it is S8-D2).

## Round 2 — review A1 closure (one Person per accepted source identity)

**Identity hold status.** The round-2 commit was made locally at 11:44 PDT, through lefthook, BEFORE the
hold mail arrived (11:51). It is `57d160b060083d2af18af1982e389499e49ac699`, tree
`cfec4d824f298339e64746ddff4c96a4119f3568`, author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`,
parent `68cfe342`. Per the hold ("if you already committed, report it and change nothing") it was NOT amended,
rewritten or re-authored as scratch, and it has NOT been pushed: `git ls-remote preserve refs/heads/cand/x42/s8d1`
still reads `68cfe342`. Working tree clean. The parent re-creates the commit at landing; the tree to reproduce is
`cfec4d82`.

| what | value |
|---|---|
| local HEAD | `57d160b060083d2af18af1982e389499e49ac699` (tree `cfec4d824f298339e64746ddff4c96a4119f3568`) |
| pushed cand ref | `57d160b0` — hold lifted 12:35 PDT; fast-forward `68cfe342..57d160b0`, confirmed by `git ls-remote preserve` |
| patch | `execution/42d8c5b5/s8d1/round2.patch` = `git diff 68cfe342` (597 lines); sha256 `82b8a70b8e25b3629c589b4d945339f0e97f79f7cbe0859d32395fc04c125535` |
| delta LOC (68cfe342 → HEAD) | prod **+62 / −9** (person-writer +36/−9, native-provenance +26); test **+363 / −4** |
| cumulative prod LOC (aed23289 → HEAD) | +255 / −31 (ceiling 1,000) |

### Change

1. **Claim check (A1 minimum closure 1)** — `native-provenance.ts` `findOtherClaim(tx, key, kind, id)`:
   `importNativeProvenance.findFirst` on (coach, namespace, family, native_kind=person, native_id=id,
   outcome ≠ unresolved, source_id ≠ this raw id). In `persistPerson` step 2 the located Person is adopted only
   when this returns null; otherwise `unresolved:identity_conflict` (ledger `skipped`, S9 bucket d → honest
   `partial / unresolved_identities`). Unclaimed pre-D1 adoption unchanged. Unresolved rows do not claim.
2. **Row lock (closure 2)** — `lockPerson`: `SELECT "id","coach_id","state" FROM "Person" WHERE "id" = $1 FOR
   UPDATE` via `tx.$queryRaw` (parameterised; the sanctioned pattern from `regimes.service.ts`), taken after the
   ext-ref locate and BEFORE verify + claim check; the locked row is the authoritative one verified. Second of two
   concurrent adopters blocks until the first commits and then sees its claim; an adopter racing the creator blocks
   on the uncommitted insert's row lock until commit. No migration.
3. **C1** — `verifyPerson` checks ownership before `Deleted` (one-line precedence swap): a foreign Deleted target is
   `identity_conflict`. `facts.service.ts` `checkNative` precedence (all kinds, pre-existing S9) untouched.

### Specs (closure 3)

| file | added |
|---|---|
| `fake-native-tx.ts` | `importNativeProvenance.findFirst` (exact filter shape); `$queryRaw` accepting only the `FOR UPDATE` Person statement; inside `$transaction` a per-transaction view whose `$queryRaw` holds a per-Person lock released at transaction end (waiters loop until the holder commits/rolls back) |
| `person-writer.spec.ts` (+6, now 18 `it`) | sequential `c-1` then ` c-1 ` → second `identity_conflict`, calls `[prov.findUnique, person.findUnique, $queryRaw, prov.findFirst]`, one Person, provenance byte-identical, both replays stable; refusal when the claim is an `already_present`; an unresolved row for the other raw id is not a claim; claims under another family/namespace/coach don't block; **concurrent pair** via two `$transaction`s → exactly `[ok, identity_conflict]`, one provenance row, loser's claim check ordered after the holder's write; C1 foreign-Deleted → `identity_conflict` (provenance path) while same-coach Deleted stays `native_target_removed`. Existing adoption cases updated for the two new calls in the order |
| `scout-reconstruct.service.spec.ts` (+1) | engine pass over `'1'` and `'1 '` → `{staged 2, reconstructed 1, skipped 1}`, ledger `['1','reconstructed','person'] / ['1 ','skipped',null,'unresolved:identity_conflict']`, one provenance row, replay converges; fake gains `$queryRaw` (plain read) and `findFirst` |
| `s10-unseen.pg.spec.ts` case (i) (new, cheap: same `chain` helper) | stage `ROSTER + {u10-m-1 + ' '} + NATIVE_CLEAN` → `partial / unresolved_identities`, conditions `['unresolved_identities']`, clients `{staged_unique 3, native_present_verified 2, unresolved 1, reasons [identity_conflict×1], observed_unique 3}`, persons 2, `clients/person` provenance rows 2, alias ledger row `skipped:unresolved:identity_conflict`. Ingest DTO accepts a padded id (`IsString/MinLength(1)`, no trim), so the shape is live-realistic |

### Gates (round 2, all in the clone; heavy ones under the flock, inode 657581)

| gate | RC |
|---|---|
| prettier 3.9.9 `--write` + `--check` on the 6 touched files | 0 |
| `npx eslint --no-warn-ignored --max-warnings 0 <6 files>` | 0 |
| `npx tsc --noEmit -p tsconfig.json` | 0 |
| focused `npx jest --runInBand person-writer.spec scout-reconstruct.service.spec` | 0 — 2 suites, 76 passed |
| broad `npx jest --runInBand test/scout/reconstruct test/scout/reconciliation src/scout test/scout/roster test/scout/s10/s10-unseen.pg.spec.ts test/scout/s11/journey-induction.pg.spec.ts` | 0 — **30 suites passed, 709 passed, 14 skipped** (2 PG suites `describe.skip`) |
| lefthook pre-commit (prod-readiness-quick, prettier, banned-cast-tokens, eslint, tsc) + commit-msg (no-ai-tokens) | all ✔ |

### PG lane deltas for the parent

- S10-B lane `s10-unseen.pg.spec.ts`: now **10** `it` (was 9); (i) is the A1 rail, expectations above. (h) unchanged from round 1.
- All other lanes unchanged from round 1 (no schema, no policy, no migration; 173 stays).

### Findings

- **A** — none open (A1 closed as above).
- **B** — B1 (journey-full patch, parent-owned) unchanged.
- **C** — The concurrent proof on the fake pins the lock PROTOCOL (lock before claim check; loser observes the winner's committed claim), not PostgreSQL semantics; the creator-vs-adopter race relies on PG's insert row lock blocking `FOR UPDATE` until commit (static reasoning, standard READ COMMITTED). A live two-transaction PG race is not in any lane. C1 swap done in the writer only.

## Round 3 — rebase onto S11-DE + journey-full leg-B flip

Pushed to a NEW ref `refs/heads/cand/x42/s8d1-r3` (confirmed by `git ls-remote preserve`); `cand/x42/s8d1`
stays at `57d160b0`. Branch `x42/s8d1-r3` in the same clone; working tree clean.

| commit | SHA | tree | note |
|---|---|---|---|
| base (S11-DE r2, `cand/x42/s11de`) | `1ee239c09a19af8da1eb99677f320ec7576a6a5e` | — | on `ce37c6ee` on `aed23289` |
| 1 D1 (rebased 68cfe342) | `77445a0d8685989fee6e723c88955cf377972986` | `dcd252405f311e600f6c74f3ba1d193ad2525f9e` | content identical to 68cfe342 |
| 2 D1 r2 (rebased 57d160b0) | `f8464c2d3f07181debff2e4c81d492002ddeff0f` | `ae7e69614862ec5d9b4f5b6e0ae6c78f915dcb21` | content identical to 57d160b0 |
| 3 test-only leg-B flip (new) | **`245940c0ece836bfab65061b56b137a37d82cc5d`** | `a3a025e5667513f5e97476b5f39be47e0e2f03e8` | `test/scout/s11/journey-full.pg.spec.ts` only, +52/−31 |

All three: author+committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; commit 3 went through lefthook
(pre-commit 5/5 ✔, commit-msg ✔). Patch-ids are identical before/after the rebase (`git patch-id --stable`):
D1 `aed23289..68cfe342` = `1ee239c0..77445a0d` = `a6a13e57…`; D1 r2 `68cfe342..57d160b0` = `77445a0d..f8464c2d` =
`ca29cd5b…` — the D1 diffs are byte-identical after the rebase. LOC over the S11-DE base: prod +255/−31, test +1416/−163.

**Conflicts resolved:** none. S11-DE touches 17 files (roster/entities readers, cursor, family-scope, dto,
openapi contract, journey-full, worker, their specs); the D1 commits touch 14 files; the intersection is
empty, so `git rebase preserve/cand/x42/s11de` applied both commits cleanly. Semantic check: S11-DE's
roster reader classifies staged tokens through the same registry the engine plans with and reads Person rows
only (no persist path), so it neither calls nor bypasses `persistPerson`.

**J20 hard rule:** untouched. S11-DE already closed the walk at `S11_RANGE_END = ce37c6ee` (S11-E) — the
J20 half of `fa72efb2/s8d1/journey-full_leg-b_j20_required-changes.r3.patch` (which had pinned `aed23289`)
is superseded and NOT applied. The two D1 src commits sit after the closed range, so SLICE_COMMITS gained no
entry; the ancestor check (`SLICE_COMMITS ∪ S11_RANGE_END` ancestors of HEAD) holds on this branch.

**Leg-B flip (adapted from the r3 patch's leg-B half):** header MANDATORY HONESTY paragraph and leg-B summary
rewritten as past tense + D1 truth; `it` title → "settles `complete` … qualifier roster_bridge_pending still
carried"; in-test comment names the D1 code path; assertions: `terminal_status 'complete'`, `reason_code`
null, `conditions []`, clients cell `{staged_unique: rosterIds.size, native_present_verified: rosterIds.size,
unresolved: 0, reasons: [], completeness_basis: 'source_signed_enumeration', observed_unique: rosterIds.size,
qualifiers: ['roster_bridge_pending']}`; J17 readiness `not.toContain('partial'|'unresolved_identities')` kept
(still meaningful); step-11 roster comment updated; roster reads stay `rosterVia` → `h.onInduction` (S11-DE
seam) — unchanged, `accounting.staged === rosterIds.size`, `unclassified 0`, every person `InvitePending`.

**Static trace of leg B → `complete`:**
1. Staged: first source `[...ROSTER_ROWS(2× u10-members), ...first.nativeClean]` via P1, second source
   `second.nativeClean` via P2 (`s11-sources.ts:158,172,177`); `firstRowsWithRoster` is exactly D2's case (h)
   shape `[...ROSTER, ...NATIVE_CLEAN]`.
2. Pass: worker builds the engine with `buildFamilyRegistry({sourceMappers, nativeRules})`
   (`g2-s11-worker.cjs:318`) → repository `clientsFamily` → `persistPerson` step 3 for both roster ids
   (fresh coach `COACH_B`, no provenance, no ext-ref match → create Person + `clients/person/created`
   provenance; typed outcome → ledger `reconstructed`, `target_kind person`). Two raw ids are distinct after
   trim (`u10-m-1`, `u10-m-2`) so the A1 claim check is never reached. Native-clean rows verify exactly as on
   leg A (which S11-DE already settles `complete`).
3. S9 facts: `readPersons` selects `state`/`updated_at`; both InvitePending → `archived_at null` →
   `present_owned`; reconcile bucket j for both → clients `native_present_verified 2, unresolved 0`.
4. Coverage: `observeRows(first, firstRowsWithRoster)` signs the roster ids under `clients` for the first
   source (families from the spec incl. clients); second source declares no clients → clients basis is the
   first source's signed enumeration, `observed_unique 2`, covers staged; claim `success` → every family
   basis known (as leg A) → no `coverage_basis_unknown`; no orphan ledger rows; relationship edges as leg A
   → conditions `[]`, verdict `complete / null`. Qualifier `roster_bridge_pending` is descriptive (S8-DOC §4.1),
   not a verdict input. Live pin of the same shape: `s10-unseen.pg.spec.ts` case (h), S10-B lane 42/42 on
   `57d160b0`.

**Gates (round 3, clone at 245940c0's tree; heavy ones under the flock):**

| gate | RC |
|---|---|
| prettier 3.9.9 `--write`/`--check` journey-full.pg.spec.ts | 0 |
| `npx eslint --no-warn-ignored --max-warnings 0` journey-full + 4 D1 src files | 0 |
| `npx tsc --noEmit -p tsconfig.json` | 0 |
| `npx jest --runInBand test/scout/reconstruct test/scout/reconciliation src/scout test/scout/roster test/scout/entities test/scout/s10/s10-unseen.pg.spec.ts test/scout/s11` | 0 — **35 suites passed, 827 passed, 47 skipped** (6 PG suites `describe.skip`) |
| `npx jest --runInBand test/utils/g2-s11-db-guard.spec.ts` | 0 — **95 passed** (incl. "names no real platform slug", "journey specs inert without the lane") |
| lefthook pre-commit + commit-msg on commit 3 | ✔ |

**PG lanes for the parent (on 245940c0):** S11 lane `journey-full` 6 pass WITHOUT any patch (leg B flipped
here); S10-B lane 42 (unchanged from 57d160b0); everything else as round 2. Migration count 173.

**Findings:** A none. B none (B1 closed by commit 3). C: leg-B `complete` is statically traced here and
live-pinned only by the D2 case (h) analogue; the parent's S11 lane run is the live proof.
