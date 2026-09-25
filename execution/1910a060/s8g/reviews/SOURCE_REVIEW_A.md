# S8-G SOURCE REVIEW A (T4 independent non-builder, read-only)

Reviewer: source review A. Read-only. Did not touch `worktrees/1910a060-s8g`, did not run tests, installs, or take the lock. Did not read reviewer B's output. Sole write: this file.

Review date: 2026-09-25. Evidence repo HEAD at review: `06da57d` (with uncommitted builder modifications under `s8g/` — rebase to 62471b11 in progress; see B2).

## Verdict

**SOURCE GO — bound to the product blobs below; conditional on closure of B1 and B2 (identity/attestation only) before the gate runs.**

The product bytes are correct against the durable S8-G design (lifecycle state machine, fencing, lock ordering, idempotency, tenant scoping, bounded work, no terminal writes by the pass, reason codes). The harness/worker/db-guard/bootstrap carry the accepted S7-L/S8-C safety guards forward. The live-proof and unit specs cover acceptance cases G01–G14. No A-class finding. Two B-class findings are evidence-identity defects, not product defects; their minimum closures are republication/attestation steps that must precede the gate. C findings are recorded and non-blocking.

## What was reviewed (identity)

Method: `git archive` of base `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9` (from the `worktrees/1910a060-land-s8f` object store, read-only) into a scratch tree `/tmp/s8g-review-a/base`; `git apply --check` then `git apply` of the committed patch. Every resulting blob hash matched `build/blob-hashes.txt` (committed) and the patch `index` lines.

| Artifact | Value verified by me |
|---|---|
| Base | `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, tree `82b56ad373c9cb4888b7c9b79544fbbb6f55c0d6` |
| Patch `build/s8g-candidate-1c5fbb04.patch` | sha256 `36c4402fe61e18e55650daf0321a184ee803a281e73ba205f47056141524f55c`, 3741 lines (committed at evidence `06da57d`) |
| Rebased patch `build/s8g-candidate-62471b11.patch` (untracked) | sha256 `9119d6d3e70a15af5cce6894a1e839266a3122357cd53a9ffd27fb194ad6181e`, 3741 lines |
| `src/scout/lifecycle/lifecycle.service.ts` | `5949a293` → **`1a6db74e`** (identical in both patches) |
| `src/scout/scout-reconstruct.service.ts` | `711bfb09` → **`fb728502`** (identical in both patches) |
| `src/scout/reconstruct/orchestration/family-plan.ts` | new **`0a75e656`** (identical in both patches) |
| `src/scout/reconstruct/orchestration/run-context.ts` | new **`b07ebb85`** (identical in both patches) |
| `test/rls-g2-s8g.spec.ts` | `7e3e4273` (1c5fbb04 patch) / `3c8491bd` (62471b11 patch) |
| `test/scout/g2-s8g-db-guard.spec.ts` | `f702cc1b` / `10781eca` |
| `test/scout/orchestration/{family-plan,reconstruct-run,settle-hook}.spec.ts` | `46a36eac`, `bdb01c0a`, `d0334d6c` (identical in both patches) |
| `test/utils/g2-s8g-bootstrap.sh` | `02e9986f` / `2ab85a13` |
| `test/utils/g2-s8g-db.ts` | `2fdbedd2` / `da34f70d` |
| `test/utils/g2-s8g-harness.ts` | `ee2a41a2` (identical) |
| `test/utils/g2-s8g-pg-harness.ts` | `ffd7c476` / `a0261246` |
| `test/utils/g2-s8g-worker.cjs` | `65ee972d` (identical) |

Rebase delta (1c5fbb04 patch vs 62471b11 patch, `diff` of the two patch files): only base-head literals and comments change (`BASE_HEAD`, `G2_S8G_BASE_HEAD`, the db-guard spec's `BASE_HEAD`/`base` constants, header comments). No product line differs. `git diff --stat 1c5fbb04 62471b11` over `src/scout/lifecycle`, `src/scout/scout-reconstruct.service.ts`, `src/scout/reconstruct`, `test/scout/orchestration`, `prisma`, `package-lock.json`, `jest*.config.js` is empty, and `62471b11:prisma/schema.prisma` is blob `2e328bbc` (same as base). The GO therefore carries to the rebased candidate for the product blobs; the five pin-changed harness files need only the pin re-verification in B2.

## Findings

### A — product/customer/data risk: none.

### B1 — SOURCE_READY.md identity table does not match the committed artifact (proof-invalidating for the identity claim only)

- Evidence: task text and `build/SOURCE_READY.md` state patch sha256 `0fe0d149…`, 3729 lines, and test blobs `53235675` (rls spec), `cefb394f` (reconstruct-run.spec), `5533f3cf` (settle-hook.spec). The only patch committed in evidence history (HEAD `06da57d`) is sha256 `36c4402f…`, 3741 lines, with test blobs `7e3e4273`, `bdb01c0a`, `d0334d6c`. No object with `0fe0d149` is recoverable from the evidence repo. Product blob hashes (`1a6db74e`, `fb728502`, `0a75e656`, `b07ebb85`) are identical in SOURCE_READY, committed `blob-hashes.txt`, and my applied scratch tree.
- Harm: a reviewer or gate that binds to SOURCE_READY's identity binds to bytes that do not exist; the attestation chain (SOURCE_READY → patch → head) has a broken link. No product harm: the product bytes reviewed are the ones in the patch and are unchanged.
- Decision: block the identity attestation only; product review proceeds on the actual patch bytes.
- Minimum closure: builder republishes SOURCE_READY.md's identity table from the artifact that will be gated (the rebased `s8g-candidate-62471b11.patch`, sha256 `9119d6d3…`, and its blob `index` lines), and records the supersession of `0fe0d149`. Reviewers bind GO to the product blobs `1a6db74e / fb728502 / 0a75e656 / b07ebb85`, which are stable across both patches.

### B2 — Rebase onto 62471b11 in progress; pin-changed harness bytes and binding pins must be re-attested before the gate

- Evidence: evidence working tree shows uncommitted modifications to `build/blob-hashes.txt`, `gate/PREFORMAT.sha256`, `gate/freeze/*` (5 files), `gate/s8g-gate-1910.sh`, plus untracked `build/REBASED.md` and `build/s8g-candidate-62471b11.patch`. Binding v1 `PINS.txt.unfilled` still pins `BASE_HEAD=1c5fbb04…`, `BASE_TREE=82b56ad3…` and "accepted-file blob pins at base 1c5fbb04"; the bootstrap/db.ts/db-guard spec in the rebased patch pin `62471b11`.
- Harm: if the gate or binding runs with the base pin split across 1c5fbb04 (binding) and 62471b11 (harness), the runner's own consistency check (`g2-s8g-db-guard.spec.ts` "pins the base head … identically across bootstrap, harness and repository") or the runner's `BASE_HEAD` refusal can fail spuriously, or worse, a mixed pin set is accepted without anyone having attested it.
- Decision: block only the binding/gate attestation; product GO unaffected (product blobs identical in both patches, verified above).
- Minimum closure: (1) builder commits the rebased candidate and evidence (REBASED.md, rebased patch, refreshed blob-hashes/PREFORMAT/freeze); (2) binding v1 `PINS.txt.unfilled`/runner get `BASE_HEAD=62471b116267fdec6746073c4b4c80a154d09834`, `BASE_TREE=23614f0b7dc33dc37b90cf4f27fcb8331912e60f`, and the accepted-file blob pins re-derived at 62471b11 (I verified `prisma/schema.prisma`, `g2-s8c-db.ts`, `rls-g2-s7l.spec.ts`, `jest.rls.config.js` blobs are unchanged from 1c5fbb04; `EXPECT_SCHEMA_SHA` `0eb41f9a…` and `EXPECT_PKG_LOCK_SHA` `b7fed5ed…` match base objects); (3) a non-builder confirms the five pin-changed harness blobs (`3c8491bd`, `10781eca`, `2ab85a13`, `da34f70d`, `a0261246`) differ from the reviewed ones only by the pin lines shown above (a `diff` of the two patch files suffices).

### C — recorded, continue

- C1 `runUnmappedSource` has no `RECONSTRUCT_MAX_ROWS` ceiling. Planned families call `assertWithinBound` before reading; unmapped tokens on a canonical platform write one `skipped` ledger row per staged row with no count check, bounded only by ingest's per-batch cap and the run deadline (gate fails → `timed_out` fence stops the loop). Design §1.2 step 5 did not require a ceiling here. Recommend applying `assertWithinBound` to unmapped groups in a follow-up; not blocking (work is O(rows) trivial writes, gate-first per row, tenant-scoped).
- C2 Ingest remains admitted during `reconciling` (S7-L gate has no phase predicate). Rows staged after `planRun` are not seen by the pass; the arbiter still yields `partial`/`reconciliation_not_performed` so nothing is claimed complete. S7-L behaviour; S9 concern.
- C3 The pass runs inline in `/complete` (design C2 accepted). An unexpected pass exception propagates, leaving the run open until the lazy deadline poll fences `timed_out` (design E2; covered by settle-hook spec "unexpected pass failure propagates" and P13).
- C4 `gateRun` requires `seen === ctx.epoch`; with the gate's `WHERE fenced_at IS NULL AND terminal_status IS NULL` this equality is redundant but harmless (a raised epoch always co-occurs with a fence). Unit-tested ("per-row CAS").
- C5 Analytics/log payloads carry free-form staged token strings (pre-existing S8-A pattern, low cardinality in practice).
- C6 Bootstrap replaces S8-C's exact-SHA pin of the generated client schema copy with a structural check (S7-L fields, provenance model, ledger `source_platform`, staged `entity_type`). Semantic change (T3 under the GRADE rule) — justified because the S8-C SHA belongs to the 93389265 schema and no `prisma generate` was permitted. Mitigated: the binding runner pins `node_modules/.prisma/client/index.d.ts` (`EXPECT_NM_CLIENT_SHA`) pre- and post-run and `prisma/schema.prisma` by sha256, and the bootstrap verifies the prisma tree is git-identical to base. Acceptable.
- C7 Runner template `s8g-pg-proof.sh.unfilled` line 120 failure message says `!= 77f33bcd` (stale S8-C text) while the pin is `EXPECT_SCHEMA_SHA` `0eb41f9a…`; cosmetic, fix when filling pins.
- C8 `RunPassResult.families` is `[]` when the pass stops on `gate_closed` (families that never completed emit no completion event and are omitted); result is informational only (verdict comes from durable facts under the tail lock). Consistent with the settle-hook spec "the pass result is informational".

## Focus-area assessment (product bytes `1a6db74e`, `fb728502`, `0a75e656`, `b07ebb85`)

**Lifecycle state machine / fencing.** `onTransferSettled(coach, intent, epoch)` = `reconstructRun({mode:'server', epoch, gate: tx => assertRunOpen(tx, coach, intent)})` → if `stopped==='gate_closed'` then `classifyClosed(coach, intent)` once → S7-L tail verbatim (`lockRun` FOR NO KEY UPDATE → CAS on `execution_epoch === epoch && terminal_status IS NULL` → `collectFacts` → `arbitrate` → `writeTerminal`). Verified against base `5949a293`: the tail hunk is byte-identical, `complete` never appears as a terminal value, the pass writes no `terminal_status`/`fenced_at`/`phase`/`execution_epoch`. `assertRunOpen` (base L442–451) only advances `discovering → transferring` and otherwise keeps the phase, so the run stays `reconciling` throughout the pass. Gate predicate `mode='server' AND terminal_status IS NULL AND fenced_at IS NULL AND deadline_at > now()` closes the pass on cancel, revoke, deadline, and any terminal — per row, before any write.

**Transaction / lock ordering.** Each per-row transaction: gate UPDATE on `ScoutImport` (row lock) → provenance/native target writes → ledger upsert/updateMany. Fence and tail lock only `ScoutImport`. Legacy `reconstruct()` never locks `ScoutImport` (LEGACY_RUN ctx, gate is a no-op). Order ScoutImport → provenance → ledger is consistent across all writers; no cycle. Paging is deterministic (`orderBy source_id, source_platform` under unique `(coach,intent,entity_type,platform,source_id)`).

**Idempotency.** Duplicate `/complete` → completion INSERT P2002 → ack, hook not invoked (P07). Replayed pass over a terminal run: every gate closes, zero writes, zero pushes, zero side-effect module loads (P12). Second run over the same source identifiers: native writer verifies existing targets via provenance, no duplicates (P13). Legacy route replay equal result and unchanged target snapshot (P09).

**Tenant scoping.** `groupBy`, `findMany`, `count`, ledger writes all carry `coach_id` + `intent_id`; gate carries both as parameters (settle-hook spec asserts this). P11: coach A's pass reads/writes none of B's rows; `anon`/`authenticated` refused by RLS on ledger and provenance; rolled-back `service_role` write persists nothing. Unit G11 "enumerates only the calling coach and intent".

**Bounded work.** Planned families: `assertWithinBound` (RECONSTRUCT_MAX_ROWS 10_000) before any read; over-ceiling isolates that source (`stopped:'over_ceiling'`, no read, no write, later families continue, pass not stopped — unit + P10). Paged `findMany` (RECONSTRUCT_PAGE_SIZE). Unmapped groups: see C1. Wall-clock bound by run `deadline_at` via the per-row gate.

**No writes beyond design.** Product diff touches only the four listed files; no prisma/migration/package change (bootstrap refuses otherwise, exit 4). Pass writes: native targets + provenance (accepted S8-C writer), ledger rows, analytics captures. Terminal/fence fields written only by S7-L tail/fence/classifyClosed. Unit "does not write terminal fields: only ledger and target calls appear in any transaction".

**Error / terminal reason codes.** `unresolved_family:<token>`, `unsupported_platform:<platform>` (S8-A reasons, exact strings unit-tested), `over_ceiling`, `provenance_conflict`, `gate_closed`; terminal outcomes `partial/reconciliation_not_performed`, `failed/transfer_failed` (zero staged + failed claim), fence `timed_out/deadline_exceeded`, `cancelled/cancelled_by_coach`. `summarizeError` still strips payloads from `failed` reasons (unit asserts no private payload leakage). `RunPassStopped` is rethrown before the `failed` fallback, so a closed gate never fabricates a `failed` ledger row (unit + P03/P05).

**Worker / harness safety guards.** `g2-s8g-db.ts`: faithful substitution of accepted `g2-s8c-db.ts` plus refused ports 55641/55642, distinct DB marker `s8g-g2-run-orchestration-synthetic-disposable-fixture-safe-to-drop`, cluster marker `s8g-disposable-pg17`, loopback-only confirmed target, candidate head must ≠ base and tree clean. Bootstrap refuses foreign `cluster_name` before any write (exit 3), refuses a DB without the exact comment marker (never repairs/drops), verifies prisma tree identical to base and 172 migrations incl. S7-L, verifies S7-L columns present, and structurally verifies the generated client (C6). Worker attests head before constructing any client; barriers pause only; `mapper:'throw'` fault injection identical to the accepted S8-C worker; real service chain `ScoutService → ScoutLifecycleService → ScoutReconstructService`, no production writer emulated. Default `jest.config.js` ignores `test/rls-*.spec.ts`, so the live spec cannot run without `jest.rls.config.js`; unit specs under `test/scout/**` are in the default suite.

**Binding runner refusals** (`binding/v1/s8g-pg-proof.sh.unfilled`, not run): refuses when any of nine pins is unfilled (exit 70), when `EXPECT_HEAD == BASE_HEAD`, when the once-only sentinel exists (76), when the canonical lock file is absent or busy (`flock -n` fd 9, inode 667698, exit 75), on any tool/binary/lock/schema/client sha mismatch, on head/tree/blob mismatch; runs jest exactly once with `--runInBand --ci` under `timeout`; stop bounded; data dir retained (destroy is a separate marker-gated grant); post-checks that the worktree porcelain and generated client are unchanged. `s8g-fixture.sh` refuses standalone use unless `S8G_RUNNER_PID` is live. Verified pins against base objects: `EXPECT_SCHEMA_SHA`, `EXPECT_PKG_LOCK_SHA`, `BASE_TREE`, and the sampled accepted-file blob pins match. Needs the B2 pin update for 62471b11.

**Test adequacy vs acceptance cases.** Live proof P01–P14 map to G01–G14 (gate-first per segment and 8 segments for 8 rows; cancel between rows → 3 gates then rollback; lock-wait; fence-after-rollback ordering; zero staged → `failed/transfer_failed` with one gate; duplicate claim ack; legacy route 409 during pass and distinct afterwards; unmapped token + over-ceiling isolation with one terminal write; tenant/RLS/rollback; zero side effects; interrupted pass → lazy `timed_out` → clean replay; CAS miss on the tail with `completed_at` set once and stale-epoch settle no-op). Unit specs cover planner purity/order/fail-closed routing, gate-first for success/skip/failed/unmapped, per-row CAS, closed-gate stop without fabricated `failed`, over-ceiling and provenance-conflict isolation, terminal-field absence, tenancy, legacy statement-sequence identity (G08), hook ordering `pass → lock → terminal`, gate closure bound to (coach,intent), classifyClosed once, CAS miss, unexpected failure propagation, self-constructed engine fallback, and the G12 static import scan. No acceptance case lacks a test.

## Non-regression on accepted context (not re-audited)

Existing `test/scout/lifecycle/lifecycle.service.spec.ts` and `src/scout/scout.service.spec.ts` do not exercise `onTransferSettled`; the new `@Optional()` constructor parameter defaults to `new ScoutReconstructService(prisma, analytics)`, and both services are already providers in `scout.module.ts`. Fallback constructions in `scout-ingest.service.ts` / `scout.service.ts` therefore obtain a working engine. Legacy `reconstruct()` keeps its select and statement sequence (G08 unit).

## Bindings for the parent

- GO is bound to product blobs `1a6db74e`, `fb728502`, `0a75e656`, `b07ebb85` on base `1c5fbb04` or `62471b11` (identical prisma tree, no path overlap with S8-F).
- Gate may proceed once B1 (identity republish) and B2 (rebased head + binding pins attested) are closed. No product change required.
