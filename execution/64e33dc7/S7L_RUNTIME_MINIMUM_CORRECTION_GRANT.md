# S7-L runtime minimum correction grant

Parent disposition, 2026-09-25 05:22Z. Sole writer remains `s7_l_replacement_builder_muge72rg`, cumulative T4. This is an ordinary follow-up to `54970cd937afc8dea689b33243961abfef8b9dd6`, tree `513c71d7c1390787e1521ccbfa46b30bb52b5462`. That failed candidate, its ancestors, v1/v2 bindings, all reviews, logs, sentinel, failed cluster and old-root remain unchanged historical evidence. No acceptance, landing, rerun or deletion is authorized here.

## Failure disposition and exact product-file surface

The first proof failed21/24 and required a narrowly verified parent TERM of the completed Jest stage. The unchanged driver stopped its cluster and released the lock at05:14:22Z. Both independent runtime dispositions identify the SQLSTATE assertion mismatch and the leaked held transaction; neither evidences a product defect, and the S7-L schema was never applied.

Parent adopts two proof-only B closures in exactly one file, `test/rls-g2-s7l.spec.ts`, limited to the stage-1 held-transaction test:

- P1: replace `refusedFile(upFile, '55P03')` with the observed message `refusedFile(upFile, 'canceling statement due to lock timeout')`. Do not change psql verbosity or any migration behavior.
- P2: put that test's assertions while the transaction is held inside `try`, and its existing `holder.release()` inside `finally`, following the accepted S8-B pattern. Preserve the held barrier, timing, unchanged-schema/shape assertions and subsequent released-lock assertion. No assertion removal, skip, new global holder registry, afterAll sweep, kill fallback, harness change, timeout change or other holder hardening.

This updates the parent's earlier one-line-only message to reviewer B. The cleanup correction is not speculative C work: the actual run skipped release after the first failed assertion, held locks through subsequent tests and left Jest open until parent intervention. Reviewer A classifies that exact observed failure path B, and the parent agrees for this stanza only. Other C findings remain record-only, including general holder hardening, harness session timeouts and log-hash ordering. No broad source audit or accepted-proof rerun.

Nothing in `src/**`, `prisma/**`, generated contracts, other tests, helpers, dependencies, hooks or workflows may change. Exact follow-up parent must be54970cd9; preserve839b54c5 and accepted93389265 ancestry.

## Source preparation and queued gates

Source preparation and a fresh immutable checkpoint may begin now, parallel to S8-C's disjoint gates. S8-C retains the sole heavy source-gate grant. S7-L must not acquire the lock, format, lint, compile, test, install, generate or commit until the parent explicitly relays the slot after actual S8-C release.

After that relay, hold the existing canonical nonblocking lock in the working gate process. Run scoped pinned prettier and eslint for this one file, then one ordinary genuine-hook commit with heap4096, using the isolated pinned formatter and offline npm configuration. R75 is supplied by the genuine hook; no separate repeat is required. No default-Jest unit suite is affected by this PG-only spec correction; do not run one, and do not execute the PG spec. Preserve each raw failure and stop for disposition rather than replaying automatically.

Author and committer must be Bradley Gleave <bradley@bradleytgpcoaching.com>, no trailers, bypass, amend or push. Export the new head in a fresh versioned bundle/checkpoint and write `s7l/runtime-correction/CORRECTION_RECEIPT.md`. Release promptly.

## Versioned binding and fresh runtime paths

Prepare `s7l/binding/v3/` only. Preserve all v1/v2 files, including v2 run receipts; do not move, destroy, repair, restart or reuse the failed lane or its old-root.

Use these fresh paths beneath the existing runtime root `/home/user/workspace/execution/64e33dc7/recovery-reset`:

- Data lane: `proof-v3/clusters/s7l`, data directory `proof-v3/clusters/s7l/pg-data`.
- Socket: `proof-v3/run/s7l`.
- Detached old-root: `proof-v3/s7l/old-root`, with its usual private generated old client beneath it.

Keep PG binaries, tool paths/hashes, canonical lock/inode, port55641, synthetic identities, cluster/database markers, bounds, one Jest invocation, cleanup behavior and sentinel semantics unchanged. The existing data-directory guard accepts this fresh path ending `/s7l/pg-data`; no committed helper change is granted.

The private fixture delta is only the fresh lane/socket paths and directly corresponding comments. The driver delta is limited to v3 receipt paths/comments, new HEAD/TREE/SPEC_BLOB/EXPECT_PARENT and derived fixture hash, correct preserved-parent tree/lineage and exact one-path delta checks, and the fresh lane/socket/old-root paths. Keep `CLUSTERS=$RUNTIME_ROOT/clusters` for existing other-lane pre/post checks. In both existing loops, replace the old basename-only exclusion of `s7l` with exclusion of the actual `$LANE/` path: the retained v2 `clusters/s7l` is now another stopped lane and must be included in those unchanged conf/control hash checks. This is the necessary mechanical own-lane identity adjustment, not a new audit or control system.

Every other committed proof-object pin, schema/migration/base-file pin and tool pin stays unchanged. Freeze from the committed clean head, never edit a pin to conceal a mismatch. Record exact v2-to-v3 driver and fixture diffs, complete PINS/README, a freshly computed manifest and the full lineage. Source-only binding preparation may use shell syntax checks, Git reads and hashes, never bootstrap, database or test execution.

## Review and separate execution boundary

On final pins, the same independent reviewers re-attest only these closures, lineage, scoped gate receipts and exact versioned binding/fresh paths. They write new `s7l/reviews/RUNTIME_CORRECTION_REVIEW_A.md` and `RUNTIME_CORRECTION_REVIEW_B.md`; original reports remain immutable and peer reports unread.

There is no new PG execution grant until both changed-question attestations are GO and the parent separately binds one run to the new candidate and v3 driver. A subsequent successful proof and review would support this new candidate only, never retroactively accept the failed54970cd9 run.

## Source-gate relay, 2026-09-25 05:22Z

Parent read S8-C's completed gate log: scoped gates, four suites44/44, genuine hooks and ordinary commit87018a42 completedrc0, lock released05:20:40Z. At05:22:14Z parent independently observed no lock holder, unchanged lock inode691716, no postgres/test/compiler/npm/Prisma/formatter/hook/Git process, and no listener on55641/55642; the only Node processes were platform daemons415/454.

S7-L is now the sole heavy source-gate grantee for the one-spec correction above. Complete/checkpoint the exact source, then run only its scoped formatter/lint and genuine hooked ordinary commit with heap4096 under the in-process nonblocking canonical lock. Release, export and freeze v3 as specified. S8-C has no further gate authority and is completing its source-only review packet. This relay authorizes no PG, bootstrap, install, generate or accepted test replay.
