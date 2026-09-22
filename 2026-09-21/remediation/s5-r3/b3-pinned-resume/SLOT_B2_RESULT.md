# SLOT B2-S5-FULL — result (honest, not an audit)

Launch 00:10:45Z: launcher pid 15820, timeout 15823, runner 15824 (`run-proof.sh full`, rev 4 sha 462a4d99…); source cf3e72f9 / tree 85d57e9d clean; A1 deps. Sentinel logs/full-20260922T001045Z.sentinel: `FULL_EXIT=1 CLEANUP_STOP_RC=na END=00:12:01Z`.

Stages (one lock holder pid 15824, LOCK_HELD→RELEASE; lock log paired):
guard 27/27 → G2_PG17_OLD_ROOT_OK → S5_FIXTURE_INIT_OK (fresh /home/user/pg17/clusters/s5, cluster_name s5-disposable-pg17, PG 17.6) → S5_FIXTURE_START_OK pid 16219 → LOCK_EXCLUSIVE_OK → PREFLIGHT_OK (170006, loopback 54325, s5_super super, hosted_roles=0, dbs=[postgres template0 template1], target_exists=0) → G2_PG17_BOOTSTRAP_OK → **live: Test suite failed to run, 0 tests** → S5_FIXTURE_STOP_OK → `PROOF_EXIT=1 STOP_RC=0 DAEMON=none`. Cluster left stopped (no postmaster.pid) for inspection; not destroyed.

## First failure — explained, source defect in frozen S5 spec
ts-jest: `test/rls-g2-pg17-etq0.spec.ts:841,926 TS2304 Cannot find name 'Result'` — the two claim-race tests introduced in 9f38ab03 declare `let outcome!: Result` but the type (exported by test/utils/g2-pg17-harness.ts) was never imported. Never compiled before because no run had dependencies until A1. Not a DB/infra/runner failure; no test executed, so the database is in pristine bootstrap state (164 migrations, no E, both markers).

## Fix (validation-only, type-only) — commit b94c24889c8f5bf40a2749ad57c26173ab5ad64a
Tree 134efc9759c04127433ec3e2aa0e7b8bcce82da3, parent cf3e72f9, author=committer Bradley Gleave, 1 file +1 line: `import type { Result } from './utils/g2-pg17-harness';`. No assertion/fixture/schema/application change. Evidence logs/typecheck-fix-*.log: `tsc --noEmit` on spec+guard rc 0 after; same command on cf3e72f9 reproduces exactly the two TS2304 errors. Type-check ran under the canonical lock (HOLDER/RELEASE typecheck).

## Runner delta rev 4 → 5 (checkpoint-3/, SHA256SUMS)
New stage `resume` = guard → oldroot → start (refuses unless postgresql.conf carries the S5 marker and no postmaster.pid) → LOCK_EXCLUSIVE → 13-fact preflight (requires the marked target to exist) → live → stop, one lock holder, no init/bootstrap/destroy; `full` still refuses the existing directory (rc 3, verified). launch-full.sh accepts `STAGE=resume`.

## Proposed rerun (awaiting explicit grant; source fingerprint changed)
`G2_PG17_PASSWORD=s5_local_synthetic STAGE=resume bash execution/s5-r3/launch-full.sh` at b94c2488 / tree 134efc97, ≤30 min + 60 s cleanup, reuses the stopped inspected cluster; expected live 51/51, STOP_RC=0, DAEMON=none, PROOF_EXIT=0.
