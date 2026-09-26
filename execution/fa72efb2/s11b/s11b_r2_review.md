# S11-B r2 independent T4 delta review — second lens

**Verdict: GO for the two-file r2 delta, 9149f82381c38cdee8caf9b2b7ff47b2d358ac21 over 4d31616f9288402c0cdd6a74fb30b4b15d0658d3.** This is a code-review verdict, **not** a replacement for the parent's new-version real-PG binding/proof or its landing decision. The preserved v1 J13 failure is not a pass for r2. No PostgreSQL, Jest, lock, or writes to the product worktree were performed.

## Scope and integrity

HEAD tree `6a0bc5aa082484805f86457ca2619ef5e4769182`; clean worktree at review. `git diff 4d31616f HEAD --name-only` names only:

| Path relative to `/home/user/workspace/worktrees/fa72-s11b` | SHA-256 of working file | LOC |
|---|---|---:|
| `src/scout/lifecycle/lifecycle.service.ts` | `8e7db85ccc09f9a8d8ebcb18fe3ce97c0cbcc4b3e936024a08bb2c3fcd931eaf` | 1071 |
| `test/scout/lifecycle/lifecycle.service.spec.ts` | `cbb0d0b2dd0007f290423ce6709fc85de879ea1423155a6a4c87ae026733ffc8` | 1711 |

The change to the product is the error predicate and its explanatory comments; the test adds a raw-error factory and three cases. No caller or transaction body changed. `git diff --check` passed.

## Decision on the grant questions

1. **Raw shape.** Installed `node_modules/@prisma/client/package.json` says 6.19.3; `runtime/library.d.ts` declares `PrismaClientKnownRequestError.code: string` and `meta?: Record<string, unknown>`. Installed `runtime/library.js` constructs the known error from engine `user_facing_error.error_code`, passing `user_facing_error.meta` unchanged; its request-handler wrapping preserves raw `meta` (without a model name). Installed native engine strings contain `RawQueryFailed`, `RawDatabaseError`, `TransactionWriteConflict`, the P2010 message template, and engine hash `c2990dca591cba766e3b7ef5d9e8a84796e47ab7`. The preserved v1 live PG log shows SQLSTATE-40001-style “could not serialize access due to concurrent update” at the raw lock, while the J13 failure was surfaced as P2010/HTTP 500. Together these support the fixer’s `P2010` plus `meta.code` SQLSTATE shape; the exact Rust mapping is described in the fixer report but **was not independently executed against the engine here**. The local JS is not itself the Rust mapping; new live proof is still the definitive end-to-end check.
2. **Safety.** `settleWithSnapshot` is called here only by `onTransferSettled`. Every retry opens a new `S9_SNAPSHOT_TX_OPTIONS` Repeatable Read transaction, invokes the same body, locks `ScoutImport`, then checks null/terminal/epoch before fact reads or writes. `SETTLE_ATTEMPTS = 3`; the last recognized failure and every other failure propagate. The new predicate accepts only an actual `PrismaClientKnownRequestError` P2010 with *string* `meta.code` exactly `40001` or `40P01`, in addition to existing P2034. It does not turn other P2010 errors into retries. `writeTerminal` is epoch-and-null CAS; `writeSettledBasis` follows successful CAS in the same transaction; `SCOUT_RUN_SETTLED` capture is after successful commit and only for a non-null verdict. An aborted attempt cannot persist its terminal/basis; after a concurrent winner, the retry sees terminal and returns null without another basis/event. Reconstruction occurs before this retry loop, so this change does not replay the ledger pass. A different writer's terminal is not overwritten.
3. **J13 and adjacent lanes.** On the observed J13 lock failure, the second transaction's fresh lock sees the winner's terminal, returns null, and `onTransferSettled` resolves. `completeServerRun`'s P2002 re-drive branch then returns ack. `expectRedriveTrace` requires at least one tail lock, the prior pending read, and prior gate; it does not require a terminal write on the loser, so the first failed lock plus retry satisfy it. J13's combined one-CAS, one-basis, one-event assertions remain coherent. J12/J14's single replay settling path, J15 closed-gate path, J16 seam tests, and R36 injected non-serialization insert error do not acquire a changed outcome from this predicate. R36's two-claim contention may now return success instead of an otherwise possible raw 500, consistent with its no-deadlock and one-basis assertions. This is static reasoning; r2 J13 and other live lanes still await the parent's new binding.
4. **Test discrimination.** The added classification test covers both raw SQLSTATEs, nonretryable raw states, missing/non-string meta, and P2002 with misleading meta. The integration-shaped unit test makes first lock throw raw P2010/40001 and checks a second snapshot transaction, one eventual CAS/basis/event. Another checks one-attempt propagation for P2010/23505. The preserved builder mutation log records 2 expected failures (the positive cases) and 1 negative-case pass when product reverted to the parent behavior; the builder's ordinary Jest log records 88/88 passing. These are reviewed receipts, **not tests run by this reviewer**.

## Findings

**A: none. B: none.** No newly found A/B blocker. The previously recorded **B** (v1 live J13 P2010/500) is addressed by these candidate bytes, subject to new live proof; it is not silently closed as a production outcome.

**C1 — stale unit comment.** `test/scout/lifecycle/lifecycle.service.spec.ts:1416` says “only P2034 is retried,” whereas exact P2010/40001 and /40P01 are now retried. The associated R36 assertion still tests an ordinary injected `Error`, correctly asserting one attempt. Correct the comment opportunistically; no decision blocked.

**C2 — unit coverage limit.** The new retry test uses an open row on attempt two, not the J13 already-terminal row; the existing terminal/epoch guard tests cover the latter decision shape, and the proposed live binding must demonstrate the concurrent path. The raw 40P01 acceptance is predicate-tested but not transaction-retry-tested. No blocker on the delta; preserve explicit live validation as the parent prerequisite.

**C3 — bounded retries and timeout.** Three consecutive raw 40001s would propagate the last P2010, and each new transaction carries the 20-second timeout. This is the pre-existing bounded-retry policy extended to the correctly classified shape, not a new silent success. No fabricated terminal.

## Commands run (all read-only; RC unless otherwise stated)

1. `sed -n '1,240p' .../WORKER_RULES.md` — 0; simultaneous `sed -n '1,280p' .../S11B_R2_REVIEW_GRANT.md` — **2** because the grant had not yet appeared at that instant. Subsequently read the grant successfully (0).
2. `rg --files .../execution/fa72efb2 | rg 'S11B|s11b|REVIEW_GRANT'`; `ls -la .../s11b/; ls -la .../node_modules/@prisma | head`; `git -C .../fa72-s11b status --short && git -C .../fa72-s11b log -5 --oneline --decorate` — 0.
3. `sed` of grant, prior `PROOF_A_V1_FINDING.md`, fixer report/grant, source ranges `lifecycle.service.ts`, `scout.service.ts`, unit specs, J13 live spec, R36 spec, builder Jest/mutant logs and preserved v1 J13/PG logs — 0.
4. `git -C .../fa72-s11b show --stat --oneline HEAD`; `git -C .../fa72-s11b show --format=fuller --no-ext-diff HEAD --`; `git -C .../fa72-s11b diff 4d31616f HEAD --check`; `git -C .../fa72-s11b diff --name-only 4d31616f HEAD`; `git -C .../fa72-s11b rev-parse HEAD HEAD^{tree} 4d31616f`; `git -C .../fa72-s11b status --short` — 0.
5. `rg -n` for the retry/lock/CAS/test/SQLSTATE symbols in changed code, adjacent Scout code and specs, installed `@prisma/client` files, and builder receipts; `rg -o` snippets from `node_modules/@prisma/client/runtime/library.js`; `strings -n 5 node_modules/.prisma/client/libquery_engine-debian-openssl-3.0.x.so.node | rg -o ... | head`; `sha256sum` and `wc -l` on both changed files — 0.

No new live observations were produced. Open prerequisite: parent-owned fresh binding and real-PG J13/S11 and S10-B lane proof on 9149f823, then parent acceptance/landing.

**Concurrent-worktree note (post-review):** After this report was first written, a final read-only status check found this shared worktree had moved to HEAD `275e458ca5a6b3684bb6ec83edb2a854056a6fd0` with five staged paths, and its working-file SHA-256 values had changed. This reviewer made no worktree edits or checkout. The findings and two-file hashes above describe the earlier clean 9149f823 snapshot, **not** the later checkout. Final additional commands: `wc -l` and `sha256sum` on this report; `git status --short`; `git rev-parse HEAD`; `sha256sum` on the two previously reviewed worktree files; `git diff --cached --stat` — all RC 0.
