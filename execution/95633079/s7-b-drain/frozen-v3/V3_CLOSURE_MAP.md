# v3 candidate — narrow per-finding closure map (source composition + formatter only)

Grant: parent "CONSOLIDATED MINIMUM SOURCE CLOSURE" (2026-09-24 ~07:40Z). Executed: source edits in the isolated worktree, the four reviewed adapter files copied in, Prettier 3.9.6 `--check`/`--write` (CLI sha256 `6e922134…7906e` verified; repo config; each invocation under `flock -n execution/test-validation.lock`), temp-index `write-tree`. NOT executed: install, node_modules copy, tsc, eslint, jest, hooks, commit, PG, probe. v1, v2 and `fixture-proposal/` unchanged.

## Identity
| | value |
|---|---|
| Base | HEAD `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree `87798e742c7b48f56b05e9b5c30efa877180a9b3` (unchanged; real index clean; tracked files unmodified) |
| v2 tree | `3739193a5badb104a0aa880a5242ff21e2a98fb0` (frozen reference, untouched) |
| **v3 tree** | **`00b105ffe362c27808a38c44c6db1f733134f074`** (temp index, no commit) |
| v3 vs base | 11 `A`, +2320 (`b-drain.v3.diff`, `NAME_STATUS.vs-base.txt`) |
| v3 vs v2 | 5 `M` + 4 `A`, +896/−37 (`v2-to-v3.diff`, `NAME_STATUS.vs-v2.txt`); `migration.sql` and `scout-ledger-backfill.cli.ts` byte-identical to v2 |
| Working tree | 11 untracked paths (7 v2 + 4 adapters), index clean, no hooks, no node_modules |
| Accepted S5 donors | byte-identical at HEAD (`S5_DONORS_UNCHANGED.git-sha1`): db `0e73d76d`, harness `ab9aaab4`, bootstrap `85a636ba`, guard spec `4fed8bcd`, old-root `b9080538` |

## v3 blobs (`BLOBS.git-sha1`)
| Path | v2 | v3 | Changed by |
|---|---|---|---|
| prisma/…/migration.sql | 55c85906 | 55c85906 | — |
| prisma/…/down.sql | 8c6710e7 | 91e646dd | F1 |
| src/scout/scout-ledger-backfill.ts | 8493f278 | 957fb8c6 | F1, B-1 |
| src/scout/scout-ledger-backfill.cli.ts | bcc06577 | bcc06577 | — |
| src/scout/scout-ledger-backfill.spec.ts | e64d8263 | 3a97093a | B-1 |
| test/rls-g2-b-drain.spec.ts | c970ab29 | 9b31fd18 | F1, F2, B-2, identity; Prettier reflow of 1 array literal |
| test/utils/g2-b-drain-harness.ts | 09c677fa | 469cbd2a | F1 (fence()), B-2 helpers, identity |
| test/utils/g2-b-drain-db.ts | — | cb60f3f4 | adapter (Prettier collapsed one 5-line Set literal) |
| test/utils/g2-b-drain-pg-harness.ts | — | c22a72c4 | adapter |
| test/utils/g2-b-drain-bootstrap.sh (100755) | — | b4503eef | adapter |
| test/scout/g2-b-drain-db-guard.spec.ts | — | 4e1ed6ff | adapter |

Pre-format blobs: `preformat/BLOBS.preformat.git-sha1` (spec `87f193ee`, db `9f1d1dfc`); format-only deltas `preformat/format-only.*.diff`; whitespace/trailing-comma-normalised token streams identical (sha256 equal per file). `prettier --check` on all 8 TS files: pass. TS files new/changed in v3: 7 (cli.ts unchanged); `.sh`/`.sql` not formatted.

## Closure mapping (exact lines are in `v2-to-v3.diff`)

### 1. A-BD-FENCE (reviewer A F1) — search_path-independent effective-fence detection
- `src/scout/scout-ledger-backfill.ts`: `readDrainState` no longer compares `pg_get_triggerdef` text. Structural predicate: joins `pg_trigger` → `pg_class`/`pg_namespace` (`public`.`ScoutReconstructionLedger`) and `pg_proc`/`pg_namespace` (`public`.`scout_ledger_platform_fence`, `pronargs = 0`); `tgname` exact; `NOT tgisinternal`; `tgenabled <> 'D'` (enabled-state intent kept); `tgtype = 7` (ROW|BEFORE|INSERT, exported `FENCE_TRIGGER_TYPE`); `tgqual IS NULL`; `tgattr::int2[] = '{}'`; `tgnargs = 0`; `tgconstraint = 0`. Plain joins → genuinely absent fence yields `fences = 0` → `fenced:false` → `complete_unfenced` (no regprocedure cast that throws). `FENCE_TRIGGER_DEFINITION` kept as documented canonical rendering under `search_path = ''` (test oracle only).
- `down.sql`: identity `IF NOT EXISTS` uses the same structural predicate (keeps `to_regprocedure` NULL-safe lookup and `NOT prosecdef`; adds `pronargs = 0`, `tgtype = 7`, `tgqual IS NULL`, `tgattr = '{}'`, `tgnargs = 0`, `tgconstraint = 0`; drops the `pg_get_triggerdef` text compare). Refusal text `G2-B fence absent` unchanged; drops trigger then function only. `migration.sql`, trigger and function: no change.
- Spec/helper alignment: `fence()` now runs `SET search_path = ''` in the same psql session before rendering and adds `tgtype` to each trigger tuple; stage 3 asserts `['…_platform_fence','O',FENCE_TRIGGER_TYPE,FENCE_TRIGGER_DEFINITION]`; stage 7 before/after equality unchanged in meaning.
- DB-free spec fake unaffected (still dispatches on `pg_trigger`).

### 2. B-BD-ACL (reviewer A F2) — erroneous live ACL proof only
- `test/rls-g2-b-drain.spec.ts` stage 3: the three `has_function_privilege(...) = 'f'` expectations are replaced by (a) `proacl IS NOT NULL` (explicit ACL, not the PUBLIC-default NULL), (b) `aclexplode(proacl)` has no `grantee = 0` EXECUTE entry, (c) direct call `SELECT public.scout_ledger_platform_fence()` refused with `trigger functions can only be called as triggers` as `postgres`, `anon`, `authenticated`, `service_role`. No product REVOKE widened.

### 3. B-BD-RETRY (reviewer B B-1) — zero lock retries
- `scout-ledger-backfill.ts`: `bounded(value, fallback, max, min = 1)`; only `lockRetries` passes `min 0`; batch/passes minimum unchanged; message `(${min}..${max})`.
- `scout-ledger-backfill.spec.ts`: one added DB-free assertion — `{ lockRetries: 0 }` with one lock fault → `lockFailures: 1`, `stalledByLocks: true`, `outcome 'stalled'`, `db.transactions === 1` (exactly one attempt). `{ lockRetries: -1 }` still rejected.

### 4. B-BD-HISTORY (reviewer B B-2) — honest fixture history, relative counts, exact new-migration set
- Helper: `S1_MIGRATION`, `C1_MIGRATION`, `acceptedUpFile(name)`, `appliedSince(serverTimestamp)` (sorted `migration_name` with `finished_at >= ts`).
- Spec `beforeAll`: `base = Number(appliedMigrations())`, `expect(base).toBe(164)` (O-root fixture identity, as bootstrap pins); none of S1/C1/E/B recorded.
- Stage 1: after O rows on the narrow shape, S1 then C1 are applied from their shipped `migration.sql` via `sqlFile` and recorded with `prisma migrate resolve --applied` (identical path to E), `base+2`, column still absent; then E as before, `base+3`. No S1/C1 assertion beyond count; nothing marked applied without its SQL.
- Stage 3: `start = SELECT now()`; after `prisma migrate deploy`: `appliedSince(start) === [B_MIGRATION]` (exactly B), `base+4`; rerun/stage 7 use `base+4`. Output still asserted to contain B and not E.

### 5. Identity adapter (reviewed proposal, applied as-is; 4 new files + 2-file delta)
- New: `test/utils/g2-b-drain-db.ts`, `test/utils/g2-b-drain-pg-harness.ts`, `test/utils/g2-b-drain-bootstrap.sh` (mode 100755 like its donor), `test/scout/g2-b-drain-db-guard.spec.ts`. Bytes equal the reviewed proposal files except Prettier's collapse of one `Set([...])` literal in `g2-b-drain-db.ts`. Diffs vs donors: `adapter-diffs-vs-donor/` (67/52/128/74 changed lines; only substantive change = bootstrap step 7 verification instead of candidate `prisma generate`; no byte `cmp` of schema — known whitespace normalisation).
- Delta in spec/helper: imports → `./utils/g2-b-drain-pg-harness` / `./utils/g2-b-drain-db`; `G2_B_CLUSTER_MARKER`/`G2_B_DATABASE_MARKER`; `database: 'g2_b_drain_disposable'`; directory `/\/pg17\/clusters\/b-drain\/pg-data$/`; `G2_B_RUNTIME_ROLE`, `process.env.G2_B_PASSWORD`. Combined with 1–4 in the same files (not the stale `spec-v3-candidate/` overwrite).

### 6. Execution proposal corrections (additive; `fixture-proposal-v3/`)
- `binding/b-pg-proof.sh` (diff vs proposal-v1 binding: 28 changed lines): outer `timeout -k 30 3600` (inner soft sum 2835 s stated); header no longer claims guaranteed cleanup — observed terminal/stop/survivor evidence governs; inner bounds and first-failure stop unchanged; no trap/supervisor added; new read-only preconditions: `.git/hooks/pre-commit` and `commit-msg` present and lefthook-based (hookless commit refused), five accepted S5 donor blobs pinned at HEAD, `PROVENANCE.txt` lines echoed into the receipt; pre-step order in header: isolated C1 copy+verify → `lefthook install` → affected gates (incl. `test/scout/g2-b-drain-db-guard.spec.ts`) → ordinary hooked commit → fill pins → separate PG grant. Pins remain `__PLACEHOLDER__`; script refuses to run.
- `binding/b-fixture.sh`: byte-identical copy of the reviewed fixture.
- Reviewer C notes (CB-1..7, C1..C10, C-1..C-7, BIND-4/5) recorded only; no optional hardening added.

## Commit message (unchanged text from `B_DRAIN_SOURCE_HANDOFF.md` §7, still accurate: fence, backfill, CLI, DB-free spec, live proof on the PG17 lane; no trailers). Author/committer Bradley Gleave.

## Not done / pending grants
Isolated C1 `node_modules` copy; `lefthook install`; tsc/eslint/check-r75/jest gates; commit; pin fill; PG run. `tsc` points the phase-A gate should confirm: `installed.function.proacl` access on the `any` returned by `json()`; `appliedSince` typing; `${FENCE_TRIGGER_TYPE}::int2` parameter in the raw query.
