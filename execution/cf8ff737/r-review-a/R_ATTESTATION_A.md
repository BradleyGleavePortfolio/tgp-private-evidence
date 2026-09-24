# R_ATTESTATION_A — independent T4 reviewer A, Phase 1 (actual-head + binding attestation)

Scope: read-only review of candidate head `df36e3310d4088501c93bcac3ce07617d02c749d` in `/home/user/workspace/worktrees/s7-r-ready` and the proposed binding `execution/cf8ff737/r-ready/binding/`. Nothing was executed against PostgreSQL; no tsc/Jest/install; no worktree edits; lock not taken. Reviewer B's directory was never read. Accepted B/E/T/C1 bytes were not re-audited (only their blob identity at the R head was machine-checked).

Written 2026-09-24 ~16:35Z. Requested route: Claude Fable 5 / High — no telemetry available, not claimed as proven.

## 0. Verdict for the parent's grant decision

**DO NOT grant `R_SINGLE_PG_PROOF_GRANT.md` on head df36e331 with binding r-pg-proof.sh sha `ac437b90…`.**
As pinned, the single run is predicted to terminate `PRECONDITION_FAIL … hookless commit` rc 70 at line 74 before touching any cluster (B-3); if that line were bypassed it would fail `IDENTITY_FAIL data_directory` rc 73 after fixture start (B-2); and if both were bypassed Jest would fail 3 rerun assertions (B-1). Each is fail-closed and harmless to product/data/retained B clusters, but each burns the once-only run. Minimum closure = one hooked Bradley commit (B-1) + one binding edit (B-2, B-3), re-pin, fresh dual attestation. Everything else in the head verifies.

## 1. What verifies (facts, recomputed by me)

### 1.1 Head, identity, tree, lineage
- HEAD `df36e3310d4088501c93bcac3ce07617d02c749d`, tree `74ddf4dd57657300d96b9a7b0cdd6e6237a52abd`, single parent `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c` (accepted B v5 head per `B_DRAIN_LOCAL_ACCEPTANCE.md`), branch `s7-r-ready`. Worktree clean (`status --porcelain --untracked-files=all` empty); no MERGE_HEAD.
- Author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`, ts 1790266641 +0000 (2026-09-24T16:17:21Z). Raw commit object: tree/parent/author/committer only — no trailers, no `Co-authored-by`, no AI tokens.
- Receipt `12-commit.log`: genuine Lefthook v2.1.9 pre-commit (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc — all ✔, 46.77 s) and commit-msg `no-ai-tokens` ✔. Hooks physically present and lefthook-managed at the common git dir `worktrees/s7-b-drain/.git/hooks/{pre-commit,commit-msg}` (see B-3 for why the binding cannot find them).
- Gates 07–11 rc=0 (tsc, eslint, prettier --check, check-r75, DB-free jest 3 suites / 90 tests); lock receipt 06 held 16:14:36Z–16:18:37Z and released. `sha256sum -c receipts/RECEIPTS.sha256`: 12/12 OK.

### 1.2 Diff confinement (HEAD^..HEAD)
Exactly 11 paths, all inside grant §2 paths: `prisma/migrations/20270120000000_scout_identity_ready/{migration.sql,down.sql}`, `prisma/schema.prisma`, `src/scout/scout-ingest.dto.ts`, `test/rls-g2-r-ready.spec.ts`, `test/scout/g2-r-ready-db-guard.spec.ts`, `test/scout/scout-ingest.validation.integration.spec.ts`, `test/utils/g2-r-ready-{db.ts,harness.ts,pg-harness.ts,bootstrap.sh}` (+1961/−1). Committed blobs: migration.sql 64d8daeb, down.sql 0bd52ec7, schema.prisma bd3e0078, dto fbb4ff0e, spec a6f3f166, guard spec d827099e, validation spec 35425068, bootstrap 67b77f7a (mode 100755), db.ts 6af4892a, harness.ts 78cdc57d, pg-harness.ts 4922b641 — equal to receipt 05 and `binding/PINS.txt`.
- Blob-identical to 0d69c7ba: all six B donor files, five S5 files, `scout-platform.ts`, `scout-reconstruct.service.ts`, `scripts/export-importer-contract.ts` (77ac9f97), `docs/contracts/importer-openapi.json` (55c864ea). Contract export/C1 pair surface: zero bytes changed (D2 correctly not regenerated — generator has no CLI plugin, so the DTO rule is not encodable).

### 1.3 Migration ordering
`20270120000000_scout_identity_ready` is the maximum of 169 timestamped migration dirs, its timestamp is unique, and it is absent on the base. No collision. (Older duplicate timestamps exist among pre-existing migrations; not R's.)

### 1.4 migration.sql / down.sql content
- Envelope copied from B: `BEGIN`, `lock_timeout 5s`, `statement_timeout 30s`, `LOCK … ACCESS EXCLUSIVE` both tables, single `DO` block, DDL, `COMMIT`.
- Guards (in file order): narrow indexes exact → column prerequisites (ledger nullable TEXT, no constraint touching the column; staging NOT NULL TEXT, no constraint) → fence exact using **`cardinality(t.tgattr::int2[]) = 0`** (`'{}'::int2[]` occurs nowhere in the R diff) → wide identity already present (`to_regclass` both index names + `pg_constraint.conname` both CHECK names) → NULL provenance → noncanonical ledger → noncanonical staging. Each raises and the transaction aborts; nothing partial.
- DDL: `SET NOT NULL` ledger; `ADD CONSTRAINT … CHECK (source_platform COLLATE "C" ~ '^[a-z0-9][a-z0-9._:-]{0,255}$')` on both tables; `CREATE UNIQUE INDEX` both wide keys, schema-qualified. Regex textually equal to `isCanonicalPlatform`'s (appears 4×; spec line 200 asserts 4).
- down.sql: requires narrow exact, wide indexes exact definition, both CHECKs validated with `conkey=[attnum]`, ledger `attnotnull`; then `DROP CONSTRAINT` ×2, `DROP INDEX` ×2, `DROP NOT NULL`. Refuses `G2-R wide identity absent` on rerun. B.down refuses while R is present (checks `NOT attnotnull`) → R.down-before-B.down ordering is enforced. Reversible; rows/fence/narrow untouched.

### 1.5 D1–D4
- D1: `ScoutReconstructionLedger.source_platform String?` retained in schema.prisma; both `@@unique(..., map: "..._identity_key")` added; narrow uniques retained.
- D2: `IsCanonicalPlatformToken` = `ValidateBy` delegating directly to `isCanonicalPlatform` (parity by construction, no restated regex); field-level message; existing `@IsString/@MinLength/@MaxLength` kept; `@ApiProperty` untouched. Validation spec: HTTP 400 through the production pipe for trailing `\n`, leading space / `-`; 202 for canonical; 33-entry parity table (7 accepts) covering empty, 256/257 length, `\r\n`, NUL, non-ASCII, non-strings.
- D3: B fence retained and required exactly by the R guard; down leaves it.
- D4: base = 0d69c7ba only (ancestor check confirmed).

### 1.6 Spec R01–R12 and harness
- `test/rls-g2-r-ready.spec.ts` (666 lines): 5 stages; every R01–R12 mapped; no `.skip`/`.only`; assertions concrete (OIDs, byte-identical row snapshots, SQLSTATEs 23505/23514/23502/42501/55P03, `wide()`/`narrow()`/`fence()` catalog shapes, `appliedMigrations()` counts, `prisma migrate deploy` "No pending migrations"). `catalog().tables` compares only oid/relname/RLS flags, so NOT NULL/CHECK additions do not falsely perturb equality.
- Harness/db/pg-harness/bootstrap/guard-spec are literal substitutions of the B donors (identity `r_super`, `g2_r_ready_disposable`, port 55471, markers `r-disposable-pg17` / `r-g2-ready-synthetic-disposable-fixture-safe-to-drop`); db.ts adds 55461 (B lane port) to refused ports; guard spec has 28 refusal cases incl. `b_super`/55461/B db; bootstrap additionally verifies both `_identity_key` maps in the generated client.

### 1.7 Binding pins (recomputed)
| Pin | Expected in r-pg-proof.sh | Recomputed | |
|---|---|---|---|
| r-pg-proof.sh sha256 | ac437b90… (PINS/BINDING.sha256) | ac437b90… | ✔ |
| r-fixture.sh sha256 | 6e71d754… | 6e71d754… | ✔ |
| derive-r-pg-proof.py | 0d9d9185… | 0d9d9185… | ✔ (`sha256sum -c BINDING.sha256` all OK) |
| EXPECT_HEAD / TREE | df36e331… / 74ddf4dd… | same | ✔ |
| EXPECT_SPEC_BLOB | a6f3f166… | `git rev-parse HEAD:test/rls-g2-r-ready.spec.ts` | ✔ |
| EXPECT_BOOTSTRAP_BLOB | 67b77f7a… | `HEAD:test/utils/g2-r-ready-bootstrap.sh` | ✔ |
| EXPECT_NM_LOCK_SHA | 05bc530a… | `node_modules/.package-lock.json` | ✔ (isolated real dir, not symlink; receipt 02 hardlinks 0) |
| EXPECT_NM_CLIENT_SHA | 7c367454… | `node_modules/.prisma/client/index.d.ts` | ✔ (receipt 03 pre bf679a16 → post 7c367454, rc 0) |
| EXPECT_POSTGRES_SHA / INITDB_SHA | 23cd1748… / b7db9bc2… | `/home/user/pg17/dist/bin/*` | ✔; `postgres --version` = 17.6 |
| Ancestors | 0d69c7ba, 925780e0 | both ancestors of HEAD | ✔ |
| Tools | jest / ts-node / prisma / jest.rls.config.js / /usr/bin/psql | present | ✔ |

### 1.8 Binding behaviour (read)
- Refuses unfilled `__` placeholders (rc 70); once-only sentinel `runtime/run/r-pg-proof.sentinel` (rc 76); non-blocking `flock -n` on the canonical `test-validation.lock` (rc 75); first nonzero stops; bounded stop of the fixture only if this run started it.
- Fresh isolation: `RDIR=/home/user/pg17/clusters/r-ready` must not exist (rc 71); fixture `init` refuses an existing data dir; port 55471 must have no listener; `pgrep -cx postgres` must be 0; socket dir `run/r-ready`; runtime/old-root must not pre-exist. Fixture is lock-free and refuses standalone invocation unless `R_RUNNER_PID` is a live r-pg-proof.sh.
- Retained B clusters: `clusters/b-drain/pg-data` — `postmaster.pid` absent required, `postgresql.conf` + `global/pg_control` sha'd pre and post, never started. `b-drain.v4-failed-*` is not referenced at all (never opened). S5 and C1 cluster dirs are absent on this host (recorded as-is).
- Jest invoked exactly once: `jest --config jest.rls.config.js test/rls-g2-r-ready.spec.ts --runInBand --ci` → `runtime/run/jest.log`; post-checks worktree porcelain unchanged and HEAD unchanged; writes `runtime/run/RECEIPTS.sha256`. Data dir retained; no push anywhere.
- Lane state now: `/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-75a2863b-20260924T151250Z` only; no postgres processes; no `r-ready`; no `runtime/`. Disk 4.6 GiB free.

## 2. Findings

### B-1 — migration guard order contradicts the spec's post-apply rerun message (proof-invalidating; needs a hooked commit)
- Fact: in `migration.sql` the column-prerequisite gate (ledger `NOT attnotnull` and no `pg_constraint` whose `conkey` includes the column; lines 52–72) executes before the "wide identity already present" gate (lines 96–103). After R is applied the ledger column is `attnotnull` and the new CHECK's `conkey` includes it, so a raw rerun raises **`G2-R unexpected platform column prerequisite`** and never reaches `G2-R wide identity already present`. The builder's own receipt 04 documents this order.
- The spec asserts `/G2-R wide identity already present/` on post-apply reruns at lines **452 (R05), 462 (R11 shadow search_path), 660 (stage-5 re-up)**. Lines 325/330 (R11 decoy, pre-apply) are unaffected. → 3 tests fail → Jest rc ≠ 0.
- Concrete harm: the once-only granted run ends NOT-ACCEPT with a false negative; product behaviour itself still fails closed atomically (message text only).
- Exact decision blocked: issuing `R_SINGLE_PG_PROOF_GRANT.md` for head df36e331.
- Minimum closure (either, one hooked Bradley commit on top of df36e331): (a) preferred — move the "wide identity already present" block to immediately after the narrow-index loop (before the column gate), keeping brief §7 R05/R11 wording and the spec unchanged; or (b) change the three spec assertions to `/G2-R unexpected platform column prerequisite/`. Then re-run the DB-free gates, re-fill `EXPECT_HEAD/TREE/SPEC_BLOB` (and BOOTSTRAP if touched), re-pin sha, re-attest.
- Execution unlocked: the single real-PG run.
- Note: brief §3 gate order vs §7 R05 message was already internally inconsistent; the builder followed §3.

### B-2 — binding exports the B cluster path as the R data directory (proof-invalidating; binding-only fix)
- Fact: `r-pg-proof.sh` line 45: `G2_R_DATA_DIRECTORY=$BDIR/pg-data` where `BDIR=/home/user/pg17/clusters/b-drain` (line 36). The fixture initialises and starts `/home/user/pg17/clusters/r-ready/pg-data`. Step 6 (`DD=$(psqlq 'SHOW data_directory'); [ "$DD" = "$G2_R_DATA_DIRECTORY" ]`) therefore fails → `IDENTITY_FAIL` rc 73 after init/start/old-root/bootstrap (~minutes), fixture stopped. Even if it passed, the spec's `beforeAll` requires `directory` to match `/pg17/clusters/r-ready/pg-data$` and the harness `identity.directory` equality — both would fail before any mutation. Root cause: the B v5 line `G2_B_DATA_DIRECTORY=$BDIR/pg-data` was carried by `derive-r-pg-proof.py` with `BDIR` re-purposed to mean the retained B cluster and `RDIR` added, but this one token was not substituted (diff-vs-b-v5 line 85).
- Harm: burned run; no data/cluster harm (the value is only string-compared; the B cluster is never opened; bootstrap does not read it).
- Blocked decision: same grant.
- Minimum closure: `G2_R_DATA_DIRECTORY=$RDIR/pg-data` (one token) in r-pg-proof.sh, mirrored in `derive-r-pg-proof.py` so the derivation stays reproducible; recompute sha in PINS.txt/BINDING.sha256.

### B-3 — binding hook check cannot succeed in a linked worktree (proof-invalidating; binding-only fix)
- Fact: lines 74–75 `grep -q lefthook "$W/.git/hooks/pre-commit" && … commit-msg`. `worktrees/s7-r-ready/.git` is a **file** (`gitdir: …/s7-b-drain/.git/worktrees/s7-r-ready`), because receipt 01 created R as a linked worktree of s7-b-drain. Hooks live in the common dir `s7-b-drain/.git/hooks/` (lefthook-managed, 2233 bytes each, present). I evaluated the exact expression read-only: **FAIL**. The run would stop at `PRECONDITION_FAIL … hookless commit` rc 70 as the first stage, before any fixture action. (B v5's worktree was a standalone repo, so the same line passed there.)
- Harm: burned run and a false "hookless" claim against a commit that receipt 12 shows was hooked.
- Blocked decision: same grant.
- Minimum closure: `H=$(git -C "$W" rev-parse --git-path hooks)` and grep `$H/pre-commit`, `$H/commit-msg` (respects both linked worktrees and `core.hooksPath`); mirror in the derive script; re-pin sha.

### C (record only; no new work)
- C-R1: down.sql does not verify fence presence (brief §4 "fence present"); B.down refuses while R present, so only reachable via a manual DROP TRIGGER.
- C-R2: down.sql lacks the brief §4 production-ordering comment (R.down safe only while no N writer is deployed).
- C-R3: commit subject/body says NOT NULL is added on both tables; staging was already NOT NULL — wording only.
- C-R4: eslint JSON confirm in receipt 08 lists 4 of 7 changed files; the hook eslint covered all staged files (receipt 12).
- C-R5: builder's `prisma migrate diff` informational drift claim ("one DROP NOT NULL") may also include the two CHECKs; informational (BL-MIGRATION-REBASELINE).
- C-R6: `pg_get_constraintdef` rendering compared via `stripParens` — plausible, unverifiable without PG; hedged.
- C-R7: line 72 `[ ! -e "$W/.git/MERGE_HEAD" ]` is vacuous in a linked worktree (MERGE_HEAD would live in the per-worktree gitdir); the porcelain-clean check at line 71 substantially covers it. Use `git rev-parse --git-path MERGE_HEAD` when B-3 is edited, or leave.
- C-R8: binding header comments still say "pins filled AFTER v3 is committed" (B wording); cosmetic.
- C-R9: `/usr/bin/psql` is 18.6 client against a 17.6 server — same as accepted B v5; recorded as-is.

## 3. Preconditions for the single run (PRE-R, analogue of B's PRE-1)
- PRE-R1: new hooked Bradley commit closing B-1 on top of df36e331 (diff confined to `migration.sql` and/or the three spec lines); DB-free gates rc 0; receipts appended (not rewritten).
- PRE-R2: binding edited for B-2 and B-3 (and derive script mirrored); `EXPECT_HEAD/TREE/SPEC_BLOB[/BOOTSTRAP_BLOB]` refilled from the new head; new `r-pg-proof.sh` sha recorded in PINS.txt and BINDING.sha256; fixture sha unchanged (6e71d754…) unless the fixture is touched.
- PRE-R3: lane state at launch unchanged from now: no `clusters/r-ready`, no `r-ready/runtime`, port 55471 free, 0 postgres processes, B clusters stopped (`postmaster.pid` absent), `test-validation.lock` free, ≥4 GiB free disk.
- PRE-R4: fresh attestation by both independent reviewers on the new head/binding before the grant file is written.
- Runtime env note: `/home/user/pg17/clusters/s5` and `c1-builder` are absent here; the binding records them as ABSENT and continues (not a blocker).

## 4. Scope statement
Local, disposable PG17 synthetic lane only. No PG15 CI, no push, no deploy, no real drain, no customer data. This attestation is a source/binding review; it is not a run result.

## 5. Files read (evidence locations)
`execution/cf8ff737/R_IDENTITY_READY_BUILD_GRANT.md`, `R_IMPLEMENTATION_DECISIONS_PENDING_B_ACCEPTANCE.md`, `r-prep/R_SLICE_BRIEF.md`, `B_DRAIN_LOCAL_ACCEPTANCE.md`, `/tmp/tgp-agent-context/AGENT_RULES.md`; `r-ready/R_COMMIT_REPORT_AND_PG_GRANT_REQUEST.md`, `SOURCE_READY_REPORT.md`, `receipts/01–12 + RECEIPTS.sha256`, `binding/{r-pg-proof.sh,r-fixture.sh,derive-r-pg-proof.py,PINS.txt,README.md,BINDING.sha256,r-pg-proof.sh.diff-vs-b-v5}`; worktree `s7-r-ready` at df36e331 (git objects only); B v5 binding `execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh` for envelope/derivation comparison.
