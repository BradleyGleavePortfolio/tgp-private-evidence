# B/drain v5 phase A — actual result (RC=0) and additive PG binding arrangement (not run)

Grant `execution/cf8ff737/B_V5_MINIMUM_CORRECTION_AND_PHASE_A_GRANT.md`; slot relayed free by parent after J3 (15:25:34Z). Builder `b_drain_exact_recovery_and_remainder_mufn6ybc`. Driver `v5/phase-a-v5.sh` (sha `7e937ab3…`, `prep/DRIVERS.sha256`) run once 15:27:22→15:29:09Z under `flock -n` fd 9; slot released on exit, verified free; 0 jest/tsc/lefthook survivors. Not self-accepted.

## 1. Source correction (exact two product lines)

| File | Old blob | New blob | Line |
|---|---|---|---|
| `src/scout/scout-ledger-backfill.ts` | `957fb8c6…` | `11d0a3fe…` | 257: `t.tgattr::int2[] = '{}'::int2[]` → `cardinality(t.tgattr::int2[]) = 0` |
| `prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql` | `91e646dd…` | `7deaf700…` | 64: identical replacement |

Delta = 4 changed lines (2 −/2 +), `git diff --check` clean, no formatting churn; frozen `prep/v5.delta.patch` sha `a1da778e…`; the driver refused to proceed unless the live diff was byte-identical to it and the old/new line texts matched exactly. No spec/harness/forward-migration/fixture/schema/dependency/gate/runtime-contract change.

## 2. Phase A (reuse-only environment; no install/copy/generate)

- Preflight: HEAD `75a2863b` (parent `a0ea1bea`), index clean, no untracked, modified set == the two files, 10 accepted-file pins ✔, identity ✔, no bypass env, `hooksPath` unset, message sha ✔; env pins `.package-lock.json` `05bc530a…` ✔, client `bf679a16…` ✔, Prettier target `6e922134…` + 3.9.6 ✔, Lefthook 2.1.9 ✔; existing hooks verified by hash (pre-commit `e5723334…`, commit-msg `29f83d8e…`) — **not reinstalled**.
- Staged 2 paths → write-tree **`d02f9b124bee52107f8ad2f286f8af611b859fe6`** ✔.
- Gates (first-nonzero stop, none): tsc rc 0 (45 s) · eslint `scout-ledger-backfill.ts` rc 0 · prettier --check rc 0 · check-r75 --mode=staged rc 0 · jest `scout-ledger-backfill.spec.ts` + `g2-b-drain-db-guard.spec.ts` **42/42** rc 0 (`gates/04-*.log`).
- Hooked ordinary commit: Lefthook pre-commit tsc ✔ eslint ✔ prettier ✔ banned-cast-tokens ✔ prod-readiness-quick ✔ (43.7 s); commit-msg no-ai-tokens ✔ (`gates/05-commit.stderr`).
- **New head `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`**, tree `d02f9b12…`, parent `75a2863b…`, author = committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` 15:28:23Z, message exactly `fix(importer): recognize empty trigger column vectors`, no trailers, no amend/rebase. Worktree clean.
- History preserved: refs `refs/s7/b-drain-v4-failed` = `75a2863b`, `refs/s7/b-drain-v5` = `0d69c7ba`; C1 refs intact. Bundles (all verify ok, `bundle/BUNDLE.sha256`): `s7-b-drain-v5-0d69c7ba….bundle` (requires 75a2863b), `s7-b-drain-v4v5-from-a0ea1bea-….bundle` (both commits, requires a0ea1bea), `s7-b-drain-full-history-….bundle` (6 refs down to the shallow graft `c23b9d9f`), `s7-b-drain-v5-….patch`.
- Original failed v4 evidence untouched: `runtime/run/RECEIPTS.sha256` re-verified; `runtime/old-root`, `runtime/binding` (a64d24de…) and `/home/user/pg17/clusters/b-drain` (stopped datadir) byte-unchanged.

## 3. v5 binding — filled, NOT run (`execution/95633079/s7-b-drain/runtime-v5/binding/`)

Template `fixture-proposal-v3/binding/b-pg-proof.sh` sha `25eb6837…` (byte-identical, still). Two-step fill, each step's diff preserved:

1. **Substitution-only** (`b-pg-proof.sh.substitution-only`, sha `8bcdc114…`; diff exactly 10 changed lines = 5 placeholders): EXPECT_HEAD `0d69c7ba…`, EXPECT_TREE `d02f9b12…`, EXPECT_SPEC_BLOB `9b31fd18…` (unchanged), EXPECT_BOOTSTRAP_BLOB `b4503eef…` (unchanged), EXPECT_FIXTURE_SHA `4525f01d…` (unchanged).
2. **One disclosed mechanical line beyond the five pins** (`b-pg-proof.sh.mechanical-RT-only.diff`, exactly 1 −/1 +), for independent binding disposition:
   ```
   -RT=/home/user/workspace/execution/95633079/s7-b-drain/runtime          # ALL runtime artefacts of the B lane live here
   +RT=/home/user/workspace/execution/95633079/s7-b-drain/runtime-v5       # v5 proof: separate receipt/old-root root (first proof runtime/ preserved)
   ```
   Why necessary (template's own refusals): with the original `RT`, the runner exits 76 (`$SENT exists; this proof runs once`) and PREFLIGHT_FAIL 71 (`$RT/old-root exists (once-only fixture; no reuse)`), and would otherwise overwrite `run/b-pg-proof.log`/`jest.log`. `RT` drives only `R=$RT/run` (receipts) and `G2_B_OLD_ROOT/G2_B_OLD_CLIENT=$RT/old-root…`. `D=`, `BDIR`, `PORT`, `DBNAME`, bounds, stage order, Jest arguments unchanged. Final filled runner sha `e895b16e…`; `bash -n` ok; `PINS.txt` lists all EXPECT_*/D/RT/BDIR/PORT lines.

   Consequence: the old-root checkout + O-client generation is **re-created** under `runtime-v5/old-root` by the sealed steps (the template forbids reuse of an existing old-root; identity does not permit reuse, so the grant's "reuse where identity permits" resolves to no reuse). Same 3 registry-free steps as the first run (old-root is a local `git` checkout; O-client `prisma generate` uses the already-fetched engines; `npm_config_offline=true`).

3. **Datadir precondition outside the script (proposal, not executed):** `b-fixture.sh` (pinned sha `4525f01d…`, cannot change) hardcodes `DATA=/home/user/pg17/clusters/b-drain/pg-data` and refuses if it exists; the runner's PREFLIGHT also requires `$BDIR` absent. Minimum preserving arrangement before a v5 run: a single rename of the stopped first-proof cluster directory
   `mv /home/user/pg17/clusters/b-drain /home/user/pg17/clusters/b-drain.v4-failed-75a2863b-20260924T151250Z`
   (no deletion; contents byte-identical; `postmaster.pid` absent; 0 postgres procs confirmed). Recording the pre/post `sha256sum` of `pg-data/global/pg_control` and `postgresql.conf` in the receipt. Requires the PG proof grant to include this one filesystem action (the datadir is outside my owned areas).

## 4. Qualifications (C, recorded)

- Known failure cascade in the live spec: when a stage-6 assertion fails mid-test, paused workers/handles leak, Jest reports "did not exit one second after the test run" and exits ~2 min later; failure 5 (`nullify` 20→0) was such a cascade. Per grant: **no try/finally, no new control, no cleanup harness** in v5; the full existing live test remains mandatory.
- Prettier gate covers the TS file only (SQL is not a Prettier target in this repo's config); the migration file's change is covered by check-r75, the hook chain and the live proof.

## 5. Next (parent-owned)

Dual actual-head/binding attestation of `0d69c7ba` + the RT-line disposition + datadir rename → separate single PG proof grant → run `timeout -k 30 3600 bash execution/95633079/s7-b-drain/runtime-v5/binding/b-pg-proof.sh` once. Expected to resolve failures 1–4, 6, 7 directly and 5, 8 as cascades; any remaining failure stops again as a new defect. No PG execution by this worker until granted.
