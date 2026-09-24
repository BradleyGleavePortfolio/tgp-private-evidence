# S7-3′ B/drain — minimal B-only fixture / identity adapter / execution binding proposal (SOURCE ONLY)

Status: proposal for the two T4 reviewers' bounded binding/delta phase. Nothing here was executed: no PG process, cluster, database, install, node_modules copy, test, probe, hook or commit. Frozen v2 (`frozen-v2/`, tree `3739193a5badb104a0aa880a5242ff21e2a98fb0`, seven product files) and the worktree `/home/user/workspace/worktrees/s7-b-drain` are unchanged; every byte below lives under `execution/95633079/s7-b-drain/fixture-proposal/`. Manifest: `PROPOSAL.sha256`.

## 1. Where the frozen v2 proof still binds S5 identity (the obstacle)

The new spec `test/rls-g2-b-drain.spec.ts` (v2 blob `c970ab29`) and helper `test/utils/g2-b-drain-harness.ts` (v2 blob `09c677fa`) import the accepted S5 harness/guard. That is deliberate reuse of accepted machinery, but the S5 guard pins S5 *identity* as literals, so as frozen the proof can only run against a cluster that impersonates S5 — exactly what the parent forbids (S5 stays ABSENT; no reconstruction).

| Binding | Where | Literal |
|---|---|---|
| Database name in URL path | `test/utils/g2-pg17-db.ts` `g2Pg17TestTarget` | `/g2_s5_etq0_disposable` |
| Admin login in URL | same | `s5_super` |
| Confirmation token | same | `g2_s5_etq0_disposable:<port>` |
| Cluster marker (`cluster_name`) | same, `G2_PG17_CLUSTER_MARKER` | `s5-disposable-pg17` |
| Database marker (DB comment) | same, `G2_PG17_DATABASE_MARKER` | `s5-g2-etq0-synthetic-disposable-fixture-safe-to-drop` |
| Refused ports | same | {5432, 5433, 6543, 54321, 54322, 55439} |
| Env names | `g2-pg17-harness.ts`, `g2-pg17-bootstrap.sh` | `G2_PG17_DATABASE_URL/CONFIRM/PASSWORD/PSQL/OLD_ROOT/OLD_CLIENT/DATA_DIRECTORY/SERVER_VERSION` |
| Bootstrap DB/markers | `g2-pg17-bootstrap.sh` lines 29–30 + `CREATE DATABASE` | same S5 literals; `test/scout/g2-pg17-db-guard.spec.ts` asserts they stay identical |
| Spec identity gate | `rls-g2-b-drain.spec.ts` beforeAll | `database: 'g2_s5_etq0_disposable'`, `directory` regex `/\/pg17\/clusters\/s5$/`, both `G2_PG17_*` markers |
| Helper | `g2-b-drain-harness.ts` | `G2_PG17_RUNTIME_ROLE`, `process.env.G2_PG17_PASSWORD` |

No S5 file has an injection point (markers are literals "so no operator variable can re-point a destructive step"). Therefore the honest minimum is **additive derivation, not parameterisation**: leave all four accepted S5 files byte-identical (they keep governing the accepted S5 proof) and add B-named siblings produced by literal substitution, the same recipe C1 used for its fixture (`c1-pg/derive-c1-fixture.sh`). Old-guard semantics are unchanged: the B guard is the same function body with B literals; the S5 guard still refuses everything it refused.

## 2. B-only identity (exact values; all unique, none shared with S1/S5/C1)

| Item | Value |
|---|---|
| Cluster data dir | `/home/user/pg17/clusters/b-drain/pg-data` (fresh init only; refuses if present) |
| Cluster marker | `cluster_name = 'b-disposable-pg17'` |
| Port | **55461** (loopback only; not 5432/5433/6543/54321/54322/55439(C1)/54325(S5)) |
| Superuser / fixture password | `b_super` / `b_local_synthetic` (scram, S5 shape; never in a URL — harness uses PGPASSWORD / in-memory Prisma URL) |
| Database | `g2_b_drain_disposable`, owner `postgres`, comment `b-g2-drain-synthetic-disposable-fixture-safe-to-drop` |
| Confirmation | `g2_b_drain_disposable:55461` |
| Role matrix | unchanged S5 shape: `postgres` (migration, bypassrls, not super), `service_role` (runtime), `anon`, `authenticated` |
| Env prefix | `G2_B_*` (`DATABASE_URL, CONFIRM, PASSWORD, PSQL, DATA_DIRECTORY, SERVER_VERSION, OLD_ROOT, OLD_CLIENT`) |
| Unix socket dir | `/home/user/pg17/run/b-drain` |
| Old-root checkout | `/home/user/workspace/execution/95633079/s7-b-drain/runtime/old-root` (outside the candidate; detached at O `925780e0`, verified ancestor of HEAD) |
| O client | `…/runtime/old-root/.g2-b-old-client` (inside the old root as bootstrap step 6 requires) |
| Raw receipts | `/home/user/workspace/execution/95633079/s7-b-drain/runtime/run/{b-pg-proof.log,jest.log,b-pg-proof.sentinel,RECEIPTS.sha256}` |

## 3. Proposed bytes

### 3a. Product-side adapter (would become part of a **v3** commit; NOT applied to the worktree)

| Proposed path in repo | Proposal file | Donor (unchanged) | Delta |
|---|---|---|---|
| `test/utils/g2-b-drain-db.ts` | `adapter/g2-b-drain-db.ts` | `test/utils/g2-pg17-db.ts` (blob `0e73d76d`) | 69 changed lines: header, DB/role/marker/env/function-name literals, `REFUSED_PORTS` + `54325`. Function body identical. Diff: `adapter/g2-b-drain-db.ts.diff-vs-donor` |
| `test/utils/g2-b-drain-pg-harness.ts` | `adapter/g2-b-drain-pg-harness.ts` | `test/utils/g2-pg17-harness.ts` (blob `ab9aaab4`) | 52 changed lines: header, import → `./g2-b-drain-db`, `G2_PG17_*`→`G2_B_*`, one error string, worker name prefix `g2p17_`→`g2b_`. Logic identical. Diff: `…pg-harness.ts.diff-vs-donor` |
| `test/utils/g2-b-drain-bootstrap.sh` | `adapter/g2-b-drain-bootstrap.sh` | `test/utils/g2-pg17-bootstrap.sh` (blob `85a636ba`) | 128 changed lines, all literal substitutions **except step 7**: candidate `prisma generate` replaced by verification of the already-generated client in the isolated C1 tree (presence, `ScoutReconstructionLedger`, engine sha, runtime realpath, `source_platform`). Step 6 (O client `prisma generate` inside the old root) is kept: it is the only generate of the lane and is a genuine fixture dependency (the O client does not exist anywhere else). Diff: `…bootstrap.sh.diff-vs-donor` |
| `test/scout/g2-b-drain-db-guard.spec.ts` | `adapter/g2-b-drain-db-guard.spec.ts` | `test/scout/g2-pg17-db-guard.spec.ts` (blob `4fed8bcd`) | DB-free unit spec pinning B literals and bootstrap-literal identity (mirrors the S5 rule); adds refusal of the S5 name and S5 port. Diff: `…guard.spec.ts.diff-vs-donor` |
| `test/utils/g2-pg17-old-root.sh` | — (reused unchanged) | — | identity-free; only input is `G2_PG17_OLD_ROOT`, which the binding sets for that call alone |

Repo-gate expectation for v3: the four adapter files are gated exactly like v2 (Prettier check on the `.ts`, eslint `--max-warnings 0`, tsc strict, r75 scan). `.ts` files were derived without re-wrapping donor lines; a format-only Prettier pass under the same format grant as v2 may still be required before commit and is expected to be a no-op or comment-only.

### 3b. Product spec delta v2→v3 (`spec-v3-candidate/`, NOT applied)

`spec-v3-candidate/v2-to-v3.identity-only.diff` (21 changed lines, 2 files): import paths → `./utils/g2-b-drain-pg-harness` / `./utils/g2-b-drain-db`; `G2_PG17_*_MARKER`→`G2_B_*_MARKER`; identity gate `database: 'g2_b_drain_disposable'`, `directory` regex `/\/pg17\/clusters\/b-drain\/pg-data$/`; helper `G2_B_RUNTIME_ROLE`, `process.env.G2_B_PASSWORD`. No stage, assertion, fixture size, timeout or SQL changes; the five other product files (migration up/down, backfill core, CLI, unit spec) are untouched.

### 3c. Execution binding (execution area only; never committed)

| File | Derived from | Notes |
|---|---|---|
| `binding/b-fixture.sh` | `c1-pg/donor/s5-fixture.sh` (sha `3a7d57bf`) | 56 changed lines: lane constants (port/superuser/password/marker/data/log/socket), `S5_`→`B_` env/marker prefixes, runner guard → `b-pg-proof.sh`. Keeps scram+pwfile (S5 shape) and revision-2 destroy/stop semantics. Diff: `binding/b-fixture.sh.diff-vs-s5-donor` |
| `binding/b-pg-proof.sh` | `c1-pg/c1-pg-proof.sh` (sha `50506175`) | structure kept; adds steps 4 (old-root), 5 (B bootstrap), extended identity (cluster_name + DB comment), pins for the isolated C1 dependency tree, S5-ABSENT requirement, retained-C1-cluster hash guard. Pins are `__PLACEHOLDER__`s and the script refuses to run until the binding phase fills them from the committed v3 |

## 4. Fixture setup vs predecessor assertions vs novel proof

- **Fixture setup (not assertions, reused bytes):** cluster init/start (S5 fixture shape), role matrix, marked database, `scripts/ci/supabase-shim.sql`, default privileges, extensions, old-root detached checkout, 164 O migrations via `prisma migrate deploy` in the old root, O client generate — all S5 bootstrap steps unchanged in substance. The spec's stage 1 (O rows on the narrow shape, E applied via `sqlFile(upFile)` + `migrate resolve`, more O rows, T pass) is *setup data* for B and is asserted only to the extent needed to know the fixture is in the intended pre-B state.
- **Predecessor assertions (NOT repeated):** the 51 fresh/E-T-Q0 assertions, the S5 sequencing proof, the C1 22-case suite, the 190/22 targeted lane. `b-pg-proof.sh` names one spec only; jest cannot pick up `rls-g2-pg17-etq0.spec.ts` or `rls-c1-setup.spec.ts`.
- **Novel proof (the only thing the run establishes):** 26 `it` blocks / 131 `expect`s in `rls-g2-b-drain.spec.ts` across stages 2–7: backfill completion ≠ drain, B deploy adds fence with both narrow indexes intact, fence vs real O writer/T/RLS, unresolvable classes + cursor + idempotence + untouched columns → `drained`, concurrency (row locks, T barrier, staging writer, `blocked()`), down/up. Any "drained" verdict is a property of this disposable fixture only (mail 1 boundary preserved in the spec header).

## 5. Bounded first-failure execution (later, under a separate runtime grant — not now)

Pre-steps the binding **requires but does not perform** (each its own grant, receipts in `runtime/`):
1. v3 commit in the worktree (adapter + 3b delta, genuine lefthook hooks, ordinary Bradley-authored message) → fill `EXPECT_HEAD/TREE/SPEC_BLOB/BOOTSTRAP_BLOB`, `EXPECT_FIXTURE_SHA`.
2. Isolated dependency tree: `cp -a /home/user/workspace/worktrees/s7-c1/node_modules /home/user/workspace/worktrees/s7-b-drain/node_modules` (717 MB, plain copy, not hardlink/symlink); verified by the binding against C1 records `.package-lock.json 05bc530a…` and `.prisma/client/index.d.ts bf679a16…`. No `npm ci`, no candidate `prisma generate`.

Run: `timeout -k 30 2400 bash binding/b-pg-proof.sh` — single `flock -n` on the canonical lock; sentinel refuses a second run. Stage order and bounds: preconditions (read-only) → preflight (B dir absent, port 55461 free, 0 postgres, **S5 ABSENT required**, C1 cluster hashed and never started) → init 60 s → start 60 s → old-root 180 s (git only) → bootstrap 900 s → identity 4×15 s → jest exactly once 1500 s (`jest.setTimeout(240000)` already in the spec; no CLI timeout flags) → fixture stop 75 s → post (S5 still absent, C1 conf/pg_control unchanged, worktree porcelain/HEAD unchanged) → `RECEIPTS.sha256`. First nonzero exit stops; the only cleanup is a bounded `b-fixture.sh stop` if the postmaster was started by this run; the exit code is the first failure's, not the cleanup's. Data dir retained (marker-guarded `b-fixture.sh destroy` is a separate grant). Wall estimate ≈ bootstrap 2–4 min + jest 3–8 min.

## 6. What this asks of the reviewers

1. Confirm additive derivation (§1) is the accepted minimum versus parameterising S5 files.
2. Review the five diffs-vs-donor for literal-only changes plus the one substantive bootstrap step-7 change.
3. Confirm the v2→v3 identity-only delta (21 lines) is the entire product change needed for binding.
4. Approve the identity table (§2) and the binding order/bounds (§5), including the S5-ABSENT hard requirement and the retained-C1 hash guard.
