# S9-B exact-byte recovery manifest (fresh S9-B harness/recovery owner, T2 narrow)

Base: `9497ca5275938c9228c6ec6fa0dfa8c34f39f724` (== worktree HEAD; == M2 in evidence). Governance: G01
(current constitution supersedes old numbered rules). No installs/tests/PG/lock run. No product rewrite.

Source evidence: `/home/user/workspace/private-evidence/execution/1910a060/s9b/**` (read-only).
Recovery output: this directory (`recovery/`), untracked, not committed, not touching repo history.

## A. Pathlist contract — 11 entries (10 owned + 1 modified-doc; SOURCE_READY §2a)

| # | Path | Pin (sha256) | Worktree state (before recovery) | Recovered? | Recovered sha256 matches pin |
|---|---|---|---|---|---|
| 1 | `src/scout/reconciliation/facts.service.ts` | `e2f40a79…8357` (CLOSURES-1) | **MISSING** | YES — pre-file + `closures-1/facts.service.ts.diff` | MATCH |
| 2 | `src/scout/reconciliation/reconciliation.module.ts` | `f2c1e447…4e1` (SOURCE_READY, unchanged) | **MISSING** | **NO** — no full bytes anywhere in evidence, only sha256 | N/A |
| 3 | `test/scout/reconciliation/facts.service.spec.ts` | `9dcfbd96…14f3c` (CLOSURES-1) | **MISSING** | YES — pre-file + `closures-1/facts.service.spec.ts.diff` | MATCH |
| 4 | `test/utils/g2-s9-db.ts` | `39ba033b…a2ae9` (CLOSURES-2) | **MISSING** | YES — pre-file + `closures-2/g2-s9-db.ts.diff` | MATCH |
| 5 | `test/utils/g2-s9-pg-harness.ts` | `8274a85b…f0def` (SOURCE_READY, unchanged) | **MISSING** | **NO** — no full bytes anywhere, only sha256 | N/A |
| 6 | `test/utils/g2-s9-harness.ts` | `16a5aeac…387ff` (SOURCE_READY, unchanged) | **MISSING** | **NO** — no full bytes anywhere, only sha256 | N/A |
| 7 | `test/utils/g2-s9-worker.cjs` | `5e52b918…622db` (SOURCE_READY, unchanged) | **MISSING** | **NO** — no full bytes anywhere, only sha256 | N/A |
| 8 | `test/utils/g2-s9-bootstrap.sh` | `8452feba…63ea682` (SOURCE_READY, unchanged) | **MISSING** | **NO** — no full bytes anywhere, only sha256 | N/A |
| 9 | `test/scout/g2-s9-db-guard.spec.ts` | `a99cf9c9…4fbf` (CLOSURES-2) | **MISSING** | YES — pre-file + `closures-2/g2-s9-db-guard.spec.ts.diff` | MATCH |
| 10 | `test/rls-g2-s9.spec.ts` | `b854fd59…85fb6` (SOURCE_READY, unchanged) | **MISSING** | **NO** — no full bytes anywhere, only sha256 | N/A |
| 11 | `docs/decisions/2026-09-25-s9-reconciliation.md` | `be591e97…6515` (CLOSURES-1, +99/-0 addendum) | present, landed-only (533 lines, `cda68d82…07bab1`), no addendum | YES — landed text (already correct in worktree) + `S9_0_ADDENDUM_DRAFT.md` appended verbatim | MATCH |

**Result: 5 of 11 pathlist entries recovered byte-exact and pin-verified. 6 of 11 (all 6 in rows 2, 5–8, 10) are genuinely unrecoverable from any evidence in this workspace — their content was never captured as full bytes anywhere, only as a sha256 in `SOURCE_READY.md`.**

Files in rows 2, 5, 6, 7, 8, 10 are exactly the module/harness/worker/bootstrap/rls files the parent
flagged as suspected missing. That suspicion is confirmed: they are missing from the worktree AND
missing from evidence (no `pre-*` copy, no diff, no freeze/postformat bundle, no `.bundle`/`.tar.gz`
archive anywhere under `private-evidence/` for S9-B — S9-B's gate died at the `node_modules` stage,
before any freeze snapshot was ever taken, unlike S8-G/S8-F/S8-C which have `gate/*/freeze/` bundles).

## B. Read-only S9-A dependency copies (SOURCE_READY §2b) — present and correct in the base worktree

These are NOT S9-B-owned; they are the accepted S9-A post-format bytes already committed at base
`9497ca52` (composed via `be88909f`/`62471b11`). No recovery action needed; verified present and
matching CLOSURES-1/PINS.env pins:

| Path | sha256 (worktree, unchanged) | Pin |
|---|---|---|
| `src/scout/reconciliation/types.ts` | `211b474a…c77114` | MATCH (`SHA_S9A_TYPES`) |
| `src/scout/reconciliation/coverage.ts` | `eca66f33…6eaa8e7` | MATCH (`SHA_S9A_COVERAGE`) |
| `src/scout/reconciliation/reconcile.ts` | `d16158ad…d30ab` | MATCH (`SHA_S9A_RECONCILE`) |
| `test/scout/reconciliation/reconcile.spec.ts` | `dc084dce…408ee` | MATCH (`SHA_S9A_SPEC`) |

## C. Gate driver — cmp defect status (parent-confirmed already fixed; verified independently here)

`closures-3-driver.diff` proposes deleting the invalid line
`cmp -s node_modules/.prisma/client/schema.prisma prisma/schema.prisma` from
`gate/s9b-gate-1910.sh`. That comparison is invalid by construction: `prisma generate` always
emits a Prettier/Prisma-formatted copy of the schema (whitespace/ordering only — `diff -B -w`
showed a single reordered line, no model/field/attribute difference), so it can never byte-equal
the source-committed `prisma/schema.prisma`. The correct criterion is the sha256 pin check one
line above it (`CLIENT_SCHEMA` == donor/receipt value), which already passed in attempt-1.

Verified independently (read-only) in this session:
- Current evidence gate driver `gate/s9b-gate-1910.sh` (sha256 `71c05654add8…1a9`) does **not**
  contain any `cmp -s` line — the fix is already applied there, consistent with the parent's mail.
- `bash -n` on that file: **clean** (no syntax errors), run in this session without executing any
  stage.
- A byte-identical copy is placed at `recovery/gate/s9b-gate-1910.sh` (+ `PINS.env`, `README.md`,
  both commit-message files) for narrow inspection in this worktree. This is a copy for review
  only; it was not run, and the historical evidence repo was not modified.

## D. What is still blocked

1. **6 owned files cannot be exactly recovered** from anything available in this workspace:
   `reconciliation.module.ts`, `g2-s9-pg-harness.ts`, `g2-s9-harness.ts`, `g2-s9-worker.cjs`,
   `g2-s9-bootstrap.sh`, `test/rls-g2-s9.spec.ts`. Per instructions, they are **not reimplemented**.
2. Gate cannot run (by design of this task and of the driver itself — it needs the full candidate,
   a heavy slot, a donor `node_modules`, and a parent grant) until either (a) the 6 files above are
   supplied by the parent/original session from some source not present here, or (b) the parent
   authorizes a bounded, disclosed reimplementation with its own review — which is out of this T2
   lane's mandate and would need explicit parent routing per G06/G20.
3. No product, install, test, PG, or lock action was taken. `recovery/` is untracked in the
   worktree; no historical file was altered.

## E. Archive

Path-preserving tri from `recovery/candidate/**` (the 5 exactly-recovered files, with their real
repo-relative paths) packaged at `recovery/s9b-recovered-candidate.tar.gz` for parent preservation
as a private checkpoint. SHA256SUMS included inside and alongside.
