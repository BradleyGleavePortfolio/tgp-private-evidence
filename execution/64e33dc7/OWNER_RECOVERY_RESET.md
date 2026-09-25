# Owner-directed recovery reset

Owner: Bradley. Received 2026-09-24 20:16 America/Los_Angeles (2026-09-25 03:16Z), in parent session `64e33dc7-18e7-42d0-add5-7db69dc37a24`. Effective immediately on receipt. This supersedes the exact-export and predecessor-release prerequisites in the earlier scope, not accepted product evidence or reserved production authority.

## Exact owner instruction

> OWNER DECISION — RECOVERY / OWNERSHIP TRANSFER
> Do not wait for a predecessor session or exact exports that are not currently recoverable.
> Effective now:
> 1. PREDECESSOR OWNERSHIP IS REVOKED.
> Any prior S7-L / S8-C worker or predecessor runtime is no longer authorized to write product code, hold the canonical heavy slot, publish evidence, or land work.
> If an old predecessor session later becomes reachable, treat any work produced after this revocation as unauthorized until explicitly reconciled.
> 2. HEAVY-SLOT OWNERSHIP MAY TRANSFER.
> The current parent may assign a new heavy-slot owner after verifying the current execution environment has no live canonical lock/process.
> Do not delete or steal an existing live lock.
> Use the current execution namespace, fresh unique runtime paths/ports/data directories, and fresh ownership records.
> 3. DO NOT APPROXIMATE THE LOST CANDIDATES.
> a585bf76 and the unrecoverable S8-C work are historical unaccepted candidates.
> Do not:
> claim their exact bytes were recovered,
> reuse their candidate-specific proof as acceptance evidence,
> reconstruct them approximately and call it continuity,
> or rewrite their receipts.
> Preserve all existing records about them as historical evidence.
> 4. CREATE NEW CANDIDATES FROM THE LAST ACCEPTED LANDED BASES.
> For S7-L:
> start a NEW candidate from the current accepted backend integration/importer head,
> reuse the durable S7-L contract/decision material and any still-applicable accepted requirements,
> implement the required S7-L behavior cleanly,
> assign a new candidate identity,
> run only the proof/review required for the NEW bytes,
> do not reuse a585bf76-specific proof as if it bound the new candidate.
> For S8-C:
> start a NEW candidate from the current accepted S8-B / integration/importer state,
> reuse the durable S8-C grant, requirements, and architectural decisions where still applicable,
> treat the missing uncommitted predecessor work as lost draft work, not accepted product state,
> implement a new candidate under a new writer,
> prove/review that new candidate normally.
> 5. MAXIMUM SAFE PARALLELISM
> S7-L and S8-C may proceed in parallel if their writable surfaces remain disjoint and their contracts are sufficiently frozen.
> Do not serialize them merely because the predecessor session is gone.
> S8-D/E remain separately blocked on the existing principal/roster owner decision; do not let that block S7-L or coach-owned S8-C.
> 6. LANDING
> Once a replacement candidate is accepted and dependency-valid, land it automatically to the authorized non-production branch under the standing autonomous-landing amendment.
> Backend production main remains owner-reserved.
> 7. EVIDENCE
> Record this as an owner-directed recovery reset:
> predecessor ownership revoked,
> exact old candidates unrecovered,
> old receipts preserved,
> new candidate lineage begins from the current accepted landed base.
> No fresh broad audit.
> No accepted-proof reruns.
> No attempt to recreate lost unaccepted bytes for provenance purity.
> BRADLEY DECISION REQUIRED: NO
> Resume S7-L and S8-C with newly assigned writers now.
> EXECUTE.

## Parent application

At 03:16:47Z remote backend integration is still `93389265a846095b846fa8f1fb0dad782fb6ee9f`; production main remains `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. Both replacement lineages begin at accepted integration `93389265`, not an unrecovered predecessor SHA. No old source-specific proof is transferred.

Environment inspection found `/home/user/workspace/execution/test-validation.lock`, `/home/user/workspace/execution`, `/home/user/pg17`, backend node_modules and the new runtime namespace absent. No postgres/postmaster/pg_ctl/Jest/tsc/npm worker process was present; only SSH listened. Historical stub locks inside archived evidence are not live canonical locks and were not touched.

Parent may grant the free canonical lock using nonblocking flock. Fresh runtime root: `/home/user/workspace/execution/64e33dc7/recovery-reset`; proposed proof ports S7-L `55641`, S8-C `55642`, each with distinct socket/data/receipt paths. Every actual acquisition still checks the lock and current processes. No live lock is removed or stolen.

New grants: `S7L_REPLACEMENT_BUILD_GRANT.md`, `S8C_REPLACEMENT_BUILD_GRANT.md`, `RUNTIME_SETUP_GRANT.md`. Old candidates, old bindings and all previous receipts are historical and unchanged. S8-D/E, production, G3-AUTH, store publication and branch-protection boundaries remain separately reserved.
