# S9-B fresh harness/recovery — findings report (T2 narrow engineering; no safety-boundary change)

Scope worked: `/home/user/workspace/tgp/backend-s9b-recovery` only. Read-only:
`/home/user/workspace/private-evidence`, `/home/user/workspace/agent-context/AGENT_RULES.md`.
Governance G01 (current constitution) confirmed in effect; no G01-superseding action taken; no
governance/trust/review-identity change made — none was in scope. Base confirmed exact:
`9497ca5275938c9228c6ec6fa0dfa8c34f39f724` (worktree HEAD == evidence M2, tree `737c34a3…8b9`).

## A. cmp defect (gate false-failure) — findings

- Evidence (`gate/attempt-1/GATE-1-STOP.md`, `gate.log`, `TERMINAL`) shows the *only* prior gate
  attempt stopped at STAGE=node_modules, RC=71, on the line
  `cmp -s node_modules/.prisma/client/schema.prisma prisma/schema.prisma`.
- Root cause confirmed independently: `prisma generate` always writes a Prettier-formatted copy of
  the schema into the client; comparing that byte-for-byte against the source-committed
  `prisma/schema.prisma` is unsatisfiable by construction (`diff -B -w` between the two = a single
  reordered attribute line, no semantic difference). The sha256 pin check one line above
  (`CLIENT_SCHEMA` vs. donor/runtime-receipt value) is the correct, already-passing criterion.
- `closures-3-driver.diff` proposes deleting exactly that `cmp -s` line, nothing else materially
  changed on that path (a timeout bump is a separate, unrelated line).
- Verified in this session: current evidence driver `gate/s9b-gate-1910.sh` (sha256
  `71c05654add8754bbeb155852a27ee86dca473e93cbd6b400821bcaef86f51a9`) does **not** contain the
  `cmp -s` line — **the fix is already applied** there. This matches the parent's mail
  ("parent confirms current driver already removes cmp"). `bash -n` on that file: clean, run
  read-only, no stage executed, no lock touched.
- Harm/blocked assessment: the defect was blocking gate progress entirely (any run would refuse at
  the same precondition regardless of candidate correctness) but is now closed at the driver level.
  It was never a defect in the S9-B candidate, the S9-A dependency, or the base.
- Minimum fix: delete the one `cmp -s` line (done, in evidence). No further action needed on this
  item; not reapplied redundantly per the parent's explicit instruction.

## B. Missing owned files — findings (parent's suspicion CONFIRMED)

Checked all 10 S9-B-owned pathlist files plus the modified doc against the worktree at base
`9497ca52`: **all 10 owned product/test/harness files are absent from the worktree.** Only the 4
read-only S9-A dependency copies and the unmodified landed doc are present — exactly matching the
evidence's own description of the pre-gate state (`git status`: 10 untracked owned + 4 untracked
dependency copies + 1 modified doc), except that here even the 10 owned files never existed on
disk at all (this is a fresh worktree, not the original failed-gate clone).

Recovery pass against `private-evidence/execution/1910a060/s9b/**` (read-only):

- **5 of 11 pathlist entries recovered byte-exact**, each independently hash-verified against the
  authoritative pin in `gate/PINS.env` / `SOURCE_READY.md` / `CLOSURES-1.md` / `CLOSURES-2.md`:
  - `src/scout/reconciliation/facts.service.ts` — pre-file + diff (CLOSURES-1) → `e2f40a79…8357` MATCH
  - `test/scout/reconciliation/facts.service.spec.ts` — pre-file + diff (CLOSURES-1) → `9dcfbd96…14f3c` MATCH
  - `test/utils/g2-s9-db.ts` — pre-file + diff (CLOSURES-2) → `39ba033b…a2ae9` MATCH
  - `test/scout/g2-s9-db-guard.spec.ts` — pre-file + diff (CLOSURES-2) → `a99cf9c9…4fbf` MATCH
  - `docs/decisions/2026-09-25-s9-reconciliation.md` — landed text (already correct in worktree,
    533 lines) + `S9_0_ADDENDUM_DRAFT.md` (99 lines) appended verbatim → `be591e97…6515` MATCH
- **6 of 11 pathlist entries CANNOT be exactly recovered** — no full bytes for these exist anywhere
  in `private-evidence/`, only a sha256 in `SOURCE_READY.md §2a` (they were never modified after
  SOURCE_READY, so no `closures-*/pre-*` copy or diff was ever produced, and the gate died at the
  `node_modules` precondition stage — before it reached the freeze/snapshot step that S8-G/S8-F/S8-C
  gates have). Confirmed no `.bundle`, `.tar.gz`, or other archive containing S9-B source exists
  anywhere under `private-evidence/` (S9-B has no `checkpoints/` or `gate/*/freeze/` directory,
  unlike sibling lanes). Confirmed via evidence-repo git log that these paths never appear as
  full blobs in any commit (`git log --all --name-only -- execution/1910a060/s9b` shows only the
  same file list already inspected). These are:
  1. `src/scout/reconciliation/reconciliation.module.ts` (pin `f2c1e4476f21830fcc51921ac2b612235b650f1cf74e39bb38a62d80decd84e1`)
  2. `test/utils/g2-s9-pg-harness.ts` (pin `8274a85b011f00e60fc9247b550373f9391d27b40c375f55e98f7accb70e2def`)
  3. `test/utils/g2-s9-harness.ts` (pin `16a5aeac75f189de09bba7b55b8a829ff96120e42b7e4a619d99b60d17e387ff`)
  4. `test/utils/g2-s9-worker.cjs` (pin `5e52b9188cc6a46232723dba7ee0db1cfb9241934644bc3992f656b8bfe622db`)
  5. `test/utils/g2-s9-bootstrap.sh` (pin `8452feba381d790f703c956403a0798d56f498def3663df0b6c32155d63ea682`)
  6. `test/rls-g2-s9.spec.ts` (pin `b854fd59ab1cb174ce55afff3da62974e8373e9d2f672140b34a9a793d485fb6`)

  These are exactly the module/harness/worker/bootstrap/rls files the parent named as suspected
  missing — confirmed missing, and confirmed **not reimplementable within this mandate** (no
  reimplementation attempted, per explicit instruction).

## C. Harm / blocked / minimum fix / unblocks — summary

- **Harm if unaddressed:** none yet realized (no gate has run to completion; no product/customer
  impact). The risk is a wasted future gate attempt repeating the same false RC=71 refusal, and/or
  an agent being tempted to reimplement the 6 missing files from scratch, which would be
  undisclosed reconstruction, not recovery, and is explicitly disallowed here.
- **Blocked:** the S9-B gate cannot run to completion — 6 of 10 owned files have no recoverable
  exact bytes anywhere in this workspace. This is a hard blocker at the source level, independent
  of the (already-fixed) driver defect.
- **Minimum fix:** (1) driver — already applied (verified, not reapplied). (2) source — needs the
  parent (or the original S9-B builder session, out of this lane's mandate to dig for) to supply
  the exact bytes or explicit sha256-verifiable source for the 6 missing files; absent that, a
  fresh, disclosed, reviewed B-NEW candidate for just those 6 files is the only path, and that is a
  scope/authority decision for the parent, not this T2 lane.
- **What unblocks once resolved:** once all 10 owned files are present and pin-matched (or the
  parent accepts revised pins for a fresh candidate), the gate can be re-relayed under a fresh
  sentinel (the prior `gate/STARTED` sentinel makes the driver one-shot-refuse until the parent
  disposes of it) with a heavy-slot grant, donor `node_modules`, and PG proof grant — none of which
  this lane requests or performs.

## D. Recovered vs missing — hash manifest

See `recovery/MANIFEST.md` for the full table. Recovered-file hashes also in
`recovery/candidate/SHA256SUMS`. Path-preserving archive (5 recovered files, real repo-relative
paths) at `recovery/s9b-recovered-candidate.tar.gz` (sha256
`2ddc5c245c9152f712f250ed2e803ac1e814d60aa93db9f17f03e4448d1d9fe4`) for parent preservation as a
private checkpoint. A narrow corrected gate copy (already-fixed driver, `bash -n` clean, not run)
is at `recovery/gate/` for inspection; it does not replace or modify the historical evidence repo.

## E. Immediate alert to parent

**Recovery gap:** 6 of 10 S9-B owned files (`reconciliation.module.ts`, `g2-s9-pg-harness.ts`,
`g2-s9-harness.ts`, `g2-s9-worker.cjs`, `g2-s9-bootstrap.sh`, `rls-g2-s9.spec.ts`) have no exact
bytes recoverable from this workspace (worktree, private-evidence, or any archive/bundle). Only
their sha256 pins exist. Per mandate, these were NOT reimplemented. Parent action needed: locate an
external/session source for these 6 files, or explicitly authorize a fresh disclosed candidate for
them (a scope/authority decision beyond this T2 narrow lane). Gate remains blocked until resolved
plus a runtime/heavy-slot grant.
