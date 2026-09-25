# S7-L v3 runtime failure disposition — independent reviewer B (non-builder)

Written 2026-09-25 ~05:50Z on the parent's runtime-only assignment. Read-only: no tests, probes, Git writes, PG, locks, gates
or peer reads. All earlier reviews immutable; this is the only file created. **No acceptance is claimed for this run**; the
23 passes are recorded as observations on head a68cdac7 only, not as an accepted proof. No fix or retry is granted by me.

## 0. Run identity (as observed in `s7l/binding/v3/run/`)

| Item | Observed |
|---|---|
| Driver / head | `binding/v3/s7l-pg-proof.sh` (`0c33b222…`, BINDING.sha256 `82f501a3…`), `JEST_START 05:39:56Z head=a68cdac70d81aea384fdc99c01c9c983a08e80eb`; supervisor `timeout -k 30 3900`, stdin /dev/null (`LAUNCHER.txt`) |
| Lane | fresh `recovery-reset/proof-v3/clusters/s7l/pg-data` (IDENTITY_OK 05:39:56Z, 170006, cluster `s7l-disposable-pg17`, `applied_migrations=171`, `s7l_columns_before=0`); `PREFLIGHT_OK` with both other lanes (`clusters/s7l` retained v2, `clusters/s8-c`) hashed and `postmaster.pid` absent; port free; postgres procs 0 |
| Jest | natural exit `JEST_END rc=1 05:41:41Z`; `Tests: 1 failed, 23 passed, 24 total`, `Time: 104.302 s`; no open-handle warning; every stanza reached (no ETIMEDOUT, no lock cascade) — P1/P2 from the runtime correction behaved as designed (stage-1 lock-timeout stanza ✓ 5907 ms, lock released) |
| Post | `POST_JEST applied_migrations=172` (final state = re-applied S7-L after L03/L04, as the spec ends); `STOP_FIRST_FAILURE stage=jest rc=1`; `S7L_FIXTURE_STOP_OK`; `CLEANUP_STOP rc=0 postgres_procs=0 port55641_listeners=0 survivor_pid=none`; `END rc=1 05:41:42Z`; `LAUNCHER_EXIT rc=1` |
| Sentinel | `RC=1 STAGE=jest END=2026-09-25T05:41:42Z HEAD=a68cdac7… LOCK_INODE=691716` |
| Receipts | `RECEIPTS.sha256`: jest.log `2d41a121…` (matches file); s7l-pg-proof.log `67eff11d…` = file without its final `END` line (recomputed; same C-R4 ordering as v2, record-only) |

## 1. The single failure — exact assertion reached

**Stanza:** `stage 4 › L05/L12: the OLD image legacy writers on the S7-L schema — byte-identical legacy rows; a server row is
protected by the legacy marker` (`test/rls-g2-s7l.spec.ts` L951-1004, blob 94e7fac4).

**Failing assertion:** L986 `expect(replay.result).toEqual(ack(oldIntent))` — expected `{acknowledged:true,
intent_id:"intent_old_ext_2026"}`, received `undefined` (jest.log L773-786).

**What the OLD-image process actually returned** (jest.log L715, `PG17_PROCESS g2l_49`, `old:true`, action `complete`,
`terminal_status:"success"` on the already-completed legacy intent):
`"failure":{"status":500,"message":"Internal server error","code":"P2002"}, "queries":3`. The worker sets `failure` and leaves
`result` undefined when the service throws (`test/utils/g2-s7l-worker.cjs` L155-165), hence `undefined`.

**Database side** (`proof-v3/clusters/s7l/pg.log` L429, 05:41:35): `ERROR: duplicate key value violates unique constraint
"ScoutImportCompletion_coach_id_intent_id_key"` — the accepted completion-ledger unique, not any S7-L object. (The only other
23505 in the log, L416, is `ScoutImport_import_intent_id_key` from the L07 duplicate-Start race, which passed as expected.)

### Assertions reached vs not reached in this stanza
- Reached and passed (L954-979): OLD-image first `/complete(partial)` on `intent_old_ext_2026` acknowledged (g2l_47, 4
  queries, jest.log L687); candidate `/complete(partial)` on `intent_new_ext_2026` acknowledged; both rows equal after
  stripping id/intent/timestamps (byte-identical legacy rows — the L05 claim); OLD-written row is `mode:'legacy'`,
  `import_intent_id:null`, `phase:null`, `execution_epoch:1`, `terminal_status:'partial'` (S7-L defaults applied by the DB for
  an OLD writer that knows none of those columns).
- Failed (L986): OLD-image replay idempotent ack.
- **Not reached** (L987-1003): row unchanged after replay; OLD-image `status` read of the legacy row; OLD-image `/complete`
  aimed at a SERVER (UUID) run → expected 500, server row unchanged, no completion row (the L12 "protected by the legacy
  marker" claim). These remain unverified.

## 2. Cause

The OLD image's accepted `complete()` (`git show 93389265:src/scout/scout.service.ts` L263-301) is designed to treat a
replay as a no-op ack: the ledger `create` is first in the `$transaction`, the duplicate raises P2002, and the catch
`if (err instanceof PrismaClientKnownRequestError && err.code === 'P2002') firstTime = false; else throw err;` (L296-300)
turns it into `{acknowledged:true, …}` (L311). The DB did raise exactly that P2002 and the worker's `failure.code` is
`P2002` — so the `instanceof` test was false and the error was rethrown.

Why `instanceof` is false in the OLD image only:
- `scout.service.ts` imports the class from `'@prisma/client/runtime/library'` (L4 in both OLD and head). In the OLD root,
  `node_modules` is a symlink to the candidate's tree (`proof-v3/s7l/old-root/node_modules → worktrees/64e33dc7-s7l/node_modules`,
  by design of `g2-s7l-old-root.sh` L95-99), so this resolves to the pinned
  `node_modules/@prisma/client/runtime/library.js` (sha `abdeb84c…`).
- The worker's module hook (`g2-s7l-worker.cjs` L18-23) redirects **only** the bare request `'@prisma/client'` to the
  private OLD client `input.client/index.js`. That generated custom-output client requires **its own copy**
  `./runtime/library.js` (`.g2-s7l-old-client/index.js` L30 and L3430; sha `5a72b6f6…`, the pinned bytes preceded by a
  130-byte generator header, as `g2-s7l-bootstrap.sh` L199-201 and L220-228 verify and the v3 log L541 records).
- Node therefore loads two distinct module instances of the runtime; the error thrown by the OLD client is an instance of
  the copy's `PrismaClientKnownRequestError`, while the service compares against the pinned package's class. Cross-instance
  `instanceof` is false → rethrow → worker maps it to `{status:500, message:'Internal server error', code:'P2002'}`.
- The candidate image is unaffected: its client is the default-output `node_modules/.prisma/client`, which requires
  `@prisma/client/runtime/library` from the same pinned package the service imports (single instance; bootstrap L250,
  v3 log L542). That is why the candidate's own P2002 no-op paths (`scout.service.ts` head L340, L401; L09 duplicate
  `/complete` no-op ack) passed.
- Within this run, g2l_49 is the first and only OLD-image call that reaches the P2002 branch (g2l_1, g2l_47, g2l_50 are all
  first-time completes, jest.log L15/L687/L729), so the defect was latent in every earlier stanza that passed.

### Classification: **B — proof/tool defect (worker module isolation), not a product defect.**
- Product: the OLD image's replay behaviour on the S7-L schema is exactly the accepted design up to the `instanceof` line;
  the S7-L migration added no object involved (the violated unique is the accepted ledger key); the candidate's P2002
  idempotency is verified in this same run. In a real deployment there is one `@prisma/client` runtime instance, so this
  failure mode cannot occur; nothing here falsifies L05 or L12 as product claims — L12's server-row protection is simply
  unverified.
- Concrete harm: the PG proof cannot pass while any OLD-image replay assertion exists; L12's three trailing assertions are
  never exercised; one PG grant consumed.
- Exact decision blocked: acceptance of S7-L on head a68cdac7 via the v3 binding.
- Minimum closure (proof tooling, one committed helper): in `test/utils/g2-s7l-worker.cjs` L18-23 extend the resolve hook so
  that, when `input.client/runtime/library.js` exists (i.e. the custom-output OLD client), requests for
  `'@prisma/client/runtime/library'` (and the `.js`-suffixed form) resolve to that file, so the OLD root's services and the
  OLD client share one runtime instance. The candidate path is unchanged because `node_modules/.prisma/client` has no
  `runtime/` directory. No `src/**`, `prisma/**`, spec, bootstrap, old-root or fixture change is required; the bootstrap's
  header-tolerant byte check (L227) already guarantees the redirected copy is the pinned runtime. This changes the worker
  blob pin (`a8fed545…`) and therefore needs a new ordinary head, scoped gates and a v4 binding with fresh lane paths — the
  parent's decision, not mine. An alternative closure that avoids touching the worker (making the OLD client resolve the
  package runtime instead of its private copy) would require bootstrap changes and is larger.
- Execution unlocked by closure: one fresh PG run of the whole spec on the new head; the 23 observations below would then be
  re-established on that head, not inherited.

## 3. Observations preserved from this run (not acceptance)

All 23 other stanzas passed with natural timing (jest.log L744-771): stage 1 baseline + 2 decoys + lock-timeout (P1/P2 now
effective: 5907 ms, release confirmed) + OLD-shape down refusal; stage 2 L01 (172 applied, catalog/RLS/legacy assertions),
L02, §3.1 gate serialization, fence-waits-for-writer; stage 3 constraint matrix, **L06 anon/authenticated policy refusal via
owner-session SET ROLE (F2 closure verified at runtime)**; stage 4 L07 guards and duplicate-Start race (one row; pg.log L416
is the expected loser), L08 ×2, L09 ×2, **L10 lazy deadline incl. read-path fence (F1 closure verified at runtime)**, CAS
terminal-once, L11 projections; stage 5 L03, L04 (OLD writer g2l_50 continues after down), re-apply. These are evidence about
head a68cdac7 for the parent's record only; the proof as a whole is a single Jest invocation and it failed.

## 4. Record-only (C)

- C-V1: the v3 driver's post-run other-lane hash comparison and worktree/OLD-root drift checks run only on the success path;
  on `STOP_FIRST_FAILURE` they are skipped by design (driver L209-219 not reached). Preflight hashes for `clusters/s7l` and
  `clusters/s8-c` are in the log (L3-4) for the parent to compare manually if desired.
- C-V2: `RECEIPTS.sha256` again covers the driver log minus its final `END` line (same as C-R4).
- C-V3: bootstrap L220-228 deliberately tolerates the header-prefixed runtime copy for byte provenance, but nothing in the
  harness asserted single-instance identity of runtime classes for the OLD image; the L05 baseline stanzas exercised only
  first-time completes, so the split was invisible until L986. Recorded for the proof's design history; no action requested.
- C-V4: worker `failure` mapping intentionally hides the Prisma message (Nest boundary emulation), so the log carries only
  `code:'P2002'`; the DB log supplied the constraint name. Adequate; no change requested.

Verdict on this run: **FAILED — not accepted. Single causal failure at spec L986; class B, proof-tool defect (two Prisma
runtime instances in the OLD-image worker make the accepted `instanceof PrismaClientKnownRequestError` P2002 no-op path
throw). No product defect identified; F1/F2 closures and 21 further claims observed passing on a68cdac7 but not accepted.**
