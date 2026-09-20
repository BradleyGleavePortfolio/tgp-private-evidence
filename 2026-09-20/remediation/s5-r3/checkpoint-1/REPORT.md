# S5 R3 validation-only fixer — builder report (NOT an audit)

Written 2026-09-20 ~23:00 UTC. Requested routing: Claude Fable 5 / High per the parent's catalog request; actual runtime identity is not independently verifiable from inside this session and is not claimed. This document is builder evidence for independent R3 audit; it contains no self-clearance.

## 1. Exact identities (probed; commands in RECREATE.md §1)

- **New head** `9f38ab033b08ae30ce2fc62d0150520239d6a5c8`, tree `49d2e03cbb60d81d010bfc524ae2e1a4cd1f425a`, branch `execute/20260920-s5-r3`, worktree `/home/user/workspace/worktrees/s5-r3`, clean (`git status --short` empty after commit).
- **Parent** `485c67973b56758fb9b8404579f5ddaec87136bd` (frozen S5 R2 head; `worktrees/s5` still detached there, untouched; `git worktree list` in `logs/oldroot-preflight-*.log`).
- **Delta 485c6797→9f38ab03**: 5 files, +212/−14 — `test/rls-g2-pg17-etq0.spec.ts` (+127/−12 lines changed), `test/utils/g2-pg17-old-root.sh` (new, 82), `test/utils/g2-tq0-worker.cjs` (+8/−2), `test/utils/g2-pg17-harness.ts` (+5/−1 comment), `test/utils/g2-pg17-bootstrap.sh` (+4/−1 comment). No `src/`, `prisma/`, `.github/`, `package*.json` change. Patch: `s5-r3-delta-vs-485c6797.patch`.
- **Commit identity**: author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` (repo-local `.git/config`; `git var` probed before commit; `git log -1` fields probed after). No AI/co-author trailers. No push, no force, no product merge.
- **Bundle** `s5-r3-candidate.bundle` (178,000 bytes) requires public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; `git bundle verify` okay from `repos/backend`; a fresh public-base clone + fetch yields `9f38ab03` and contains `925780e0`. SHA-256 in `SHA256SUMS`.

## 2. Finding dispositions (stable IDs)

| ID | Disposition | Where |
|---|---|---|
| S5-R2-A-01 / S5-R2B-02 (E recovery wording mismatch) | **Mapped to S1**, not fixed by S5 (S1 sole owner of E recovery text/SQL). Measured facts supplied. S5's own fixture comments corrected to stop asserting recovery semantics. | `S1_HANDOFF_E_RECOVERY.md`; harness line ~41; spec forward-repair comment |
| S5-R2-A-02 / S5-R2B-03 (terminal worker/target state logged not asserted; refused branch unexercised) | **Fixed in source (unverified live)**: claim-race test awaits the worker and asserts branch-specific terminal contract (result/failure/events/ledger/targets/column/history) before and after forward repair, with convergence replay; new deterministic refused-branch test via fixture-only `txTimeout`. 500/P2022 labelled characterization of a state a rollout must never enter, not acceptable behaviour. | spec lines ~823–950; worker.cjs lines 36–44 |
| S5-R2-A-03 / S5-R2B-01 (O recreation recipe = `git archive`, cannot pass identity gate) | **Fixed**: `test/utils/g2-pg17-old-root.sh` creates a detached Git checkout and preflights bootstrap's step-4 gate offline; recipe exercised from a bundle restore on the public base (self-contained, `alternates=none`) and negatives refused. Frozen R2 packet manifest NOT edited; correction lives in this bundle. | script; `RECREATE.md` §2; `logs/oldroot-*.log` |
| S5-R2B-07 (hard-coded port in `beforeAll`) | Fixed: reads `target.port` from the guarded target. | spec `beforeAll` |
| S5-R2B-04/05/06, A-04.. (hosted applicability, serving role, drain/fencing, ledger-tally wording, PG-version CI truth) | **Out of S5 R3 scope**, unchanged; remain with their owners per parent disposition. | — |

## 3. What is proven vs. not

**Proven in this slice (offline, logs preserved):**
- `bash -n` on all three shell files; `node --check` on `g2-tq0-worker.cjs`; `git diff --check` clean.
- O recipe: create/preflight OK at `925780e0`, detached, 164 migrations, both shared and self-contained variants; negatives (archive extraction, branch HEAD, dirty path) refused rc 4; recipe works from public base + bundle (`logs/oldroot-bundle-restore-recipe-*.log`).
- Syntax-only parse of the two edited TS files with a FOREIGN `tsc` (worktrees/s6 mobile tree, TS 6.0.3; backend pins 5.9.3), `--noResolve`: zero grammar (TS1xxx) diagnostics; the 377 unresolved-symbol diagnostics are expected and meaningless. **This is not a backend type proof** (`logs/tsc-syntax-only-*.log`).

**Not proven (needs the requested slot):**
- Type-check under backend's own `typescript@5.9.3`/ts-jest (strict). Known risk points I checked by reading: `let outcome!: Result` definite assignment; `target` export exists in harness; `Result.events: any[]`; `records()`/`targets()` return `any`.
- Live behaviour of the new assertions. Unobserved sub-branch: down-refused (b) `failed`/`error:Prisma.P2028` outcome is asserted from service reading (`reconstructRow` catch → `writeOutcome`; `summarizeError` → `error:Prisma.<code>`), not from a log. If the live run shows a different legal shape, that is a fixture correction, not a product finding.
- New refused-branch test timing on a 2-CPU box: asserts `5000 ≤ elapsed < 30000` ms for E's lock-timeout refusal; worker ceiling 30 s (fixture-only) vs 90 s harness kill timer.
- Historical 50/50 + 26/26 at `485c6797` (run `20260920T185210Z`) is preserved and NOT claimed for `9f38ab03`.

## 4. Requested execution (single serialized replay; awaiting parent slot + S1 guard review)

1. `bash execution/s5-r3/npm-ci.sh` — heavy slot; S5's own lock (`354de3da`), no substitution.
2. S1 lane s5 up; S1 guard review complete.
3. `G2_PG17_PASSWORD=… bash execution/s5-r3/run-proof.sh reset && … run-proof.sh all` — expected guard 26/26, `G2_PG17_OLD_ROOT_OK`, `G2_PG17_BOOTSTRAP_OK`, live **51/51**, `PROOF_EXIT=0`. Nonblocking lock (exit 75 if busy). One infra-class rerun max; all runs preserved.

## 5. Bundle contents

`INITIAL_PLAN.md` (approved by parent), `REPORT.md`, `RECREATE.md`, `S1_HANDOFF_E_RECOVERY.md`, `run-proof.sh`, `npm-ci.sh`, `g2-pg17-old-root.sh.copy` (copy of the committed script), `s5-r3-candidate.bundle`, `s5-r3-delta-vs-485c6797.patch`, `SHA256SUMS`, `logs/` (oldroot create/preflight/negatives/bundle-restore/self-contained recreate; tsc syntax-only), `old-root-925780e0/` (the created fixture, disposable, no node_modules).

## 6. Boundaries respected

No product push, no live/hosted DB, no activation, no schema/migration/generator/service writes, no dependency install, no PostgreSQL start, no edit of frozen packets or worktrees, no blocking lock waits. Web interactions: none.
