# S8-G real-PG proof receipt: MISSING — diagnosis note (bounded, T2)

Owner: fresh S8-G diagnosis owner (bounded T2 diagnosis only, no product edits).
Scope: locate the actual real-PG proof failure output for the exact candidate
`820ce85be2ebf994112afbb90739eb9469ad628e`. **Not** a re-audit, not a rerun,
not an inferred root cause.

## Status: NOT FOUND. This is a report of an absence, not a diagnosis of a cause.

## What was confirmed present

- Candidate `820ce85be2ebf994112afbb90739eb9469ad628e` is recovered unchanged
  as HEAD of `/home/user/workspace/tgp/backend-s8g-recovery`
  (branch `execute/d3a9/s8g`, worktree clean, matches tree
  `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`, sole parent `62471b11…`).
- `private-evidence` repo (`main`, single branch, single remote ref, fresh
  shallow clone — reflog shows only the clone event, no other local refs,
  `git fsck --unreachable` empty, no stash) has tip `8912286` at inspection
  time; the commit the task described as "latest" is `3d6ceb4` ("Grant single
  S8-G real-PG proof after dual binding GO"), which `8912286` sits directly on
  top of. **Parent has independently confirmed the remote is the same: main
  originally `3d6ceb4` pre-proof-grant, no other heads/tags.**
- `execution/1910a060/s8g/S8G_PG_PROOF_GRANT.md` — the grant authorizing
  **exactly one** run of the binding-v1 runner, single attempt, no retry
  without a separate parent disposition.
- `execution/1910a060/s8g/binding/v1/s8g-pg-proof.sh` — the frozen, filled
  runner script, pins verified against the committed candidate head.
- `execution/1910a060/s8g/gate/attempt-4/*` — the **source gate** (prettier,
  eslint, tsc, targeted jest, full jest 577/589 passed) that produced the
  commit. This is pre-commit CI-style gating, not the real-PG proof; it never
  starts a PostgreSQL server and is a different step in the runner's own
  documented pre-steps list.
- `execution/1910a060/runtime/RUNTIME_SETUP_RECEIPT.md` — environment
  preparation only (node_modules donor copy, PG 17.6 binaries fetched/hashed,
  prettier tool prefix). Explicitly states "NOT run here: compiler, tests,
  initdb, any PostgreSQL server, bootstrap, proof". This receipt is for the
  **S8-F** binding v2 runtime, reused as the donor for S8-G; it is not an
  S8-G proof execution record.
- `execution/1910a060/SCOPE.md` — written by the parent that took ownership
  immediately before the grant, states verbatim: *"no final S8-G export or
  S9-B source checkpoint found in current private GitHub evidence"* at that
  time, and that the runtime host at 21:09:01Z had **no postgres/pg_ctl/psql
  executable and no `execution/` directory at all**. The grant and gate then
  proceeded from that point forward.

## What is missing (exact expected paths, per the runner script itself)

The runner `execution/1910a060/s8g/binding/v1/s8g-pg-proof.sh` defines its own
output location as `$D/run` where `D=execution/1910a060/s8g/binding/v1`. On
any completed or failed run (the script's `fail()`/`finish()` traps run on
**every** exit path, success or first-failure) it must have produced:

- `execution/1910a060/s8g/binding/v1/run/s8g-pg-proof.sentinel` — terminal
  sentinel line: `RC=<n> STAGE=<stage> END=<ts> HEAD=<head> LOCK_INODE=<inode>`
- `execution/1910a060/s8g/binding/v1/run/s8g-pg-proof.log` — the full stage
  log (START, PRECONDITIONS_OK, PREFLIGHT_OK, FIXTURE_INIT, FIXTURE_START,
  BOOTSTRAP, IDENTITY_OK, JEST_START/END, JEST_COUNT_OK/FAIL, FIXTURE_STOP,
  STOP_STATE_OK, POST_OK, END)
- `execution/1910a060/s8g/binding/v1/run/jest.log` — raw Jest output for
  `test/rls-g2-s8g.spec.ts` under `jest.rls.config.js` (expected `Tests: 19
  passed, 19 total`, `Test Suites: 1 passed, 1 total` on success; any other
  count or a nonzero Jest exit is the failure signature)
  and, if a mismatch produced the failure per the script's own explicit check:
  the line `JEST_COUNT_FAIL expected 'Tests: 19 passed, 19 total' (got: ...)`.
- `execution/1910a060/s8g/binding/v1/run/RECEIPTS.sha256` — sha256 of the log
  and jest.log, written by `finish()` on every exit.

**None of these four files, nor the `run/` directory itself, exist** in the
private-evidence working tree, in any commit reachable from any local or
remote ref, in the reflog, or as a dangling/unreachable git object. A
repository-wide filename search (`s8g-pg-proof.sentinel`, `s8g-pg-proof.log`,
`jest.log`, `RECEIPTS.sha256`, and the containing `run/` directory) under
`execution/1910a060/s8g/binding/` returns nothing beyond the frozen,
never-executed script and its `.unfilled` template/history copies.

Also absent from this sandbox entirely: the runner's own working paths
`/home/user/workspace/execution/1910a060/runtime` (RUNTIME_ROOT) and
`/home/user/workspace/worktrees/1910a060-s8g` (W, the standalone clone the
script operates against) — i.e., not just the receipt files but the runtime
and worktree the runner would have needed to write them into are not present
anywhere reachable from durable repo history or archives.

## What this means, precisely (no cause inferred)

- The one-time grant (`S8G_PG_PROOF_GRANT.md`) plus the frozen runner together
  establish that a real-PG run was **authorized and prepared for**, up to and
  including environment setup receipts.
- No durable artifact anywhere in `private-evidence` history/archives
  demonstrates that the runner script was actually invoked: no sentinel, no
  log, no Jest output, no receipts hash, at any commit, on any branch, in any
  bundle under `execution/1910a060/`, or as an unreachable object.
- The task's premise — "real PG failed 5/19 after dual final GO" — states a
  specific failure shape (5 of 19 tests failing). That figure does not appear
  anywhere in the evidence I can reach: no `jest.log`, no `Tests: ... passed,
  19 total` line with a nonzero failed count, no `JEST_COUNT_FAIL` line, and
  no sentinel with `RC != 0` tied to this candidate's PG proof. I am not able
  to confirm, deny, or explain that reported number from durable evidence.
- Per instructions, I have **not** inferred an actual cause and have **not**
  rerun or attempted to reconstruct the missing receipt.

## Bounded diagnosis hypotheses (candidate code only — clearly separated from actual findings above)

These are **hypotheses about what a run against this exact candidate could
plausibly fail on**, derived only from reading the candidate's own proof-path
source under `test/rls-g2-s8g.spec.ts`, `test/utils/g2-s8g-*`, and the
runner's own precondition/identity/count assertions. They are NOT claims about
what did happen, since no receipt exists to confirm any of them.

| ID | Hypothesis (candidate-code-only) | Where it would surface |
|---|---|---|
| H1 | `EXPECT_TESTS=19` is a static `it()` count pinned at binding time; if the committed `test/rls-g2-s8g.spec.ts` blob at candidate head differs in test count from what was pinned when binding v1 was frozen, the runner's own `JEST_COUNT_FAIL` check would stop the run even if all executed tests passed. | Runner's step 6 count assertion vs. actual spec content |
| H2 | The spec drives real Postgres RLS/session-variable behavior (`g2-s8g-db.ts`, `g2-s8g-pg-harness.ts`); any of the 19 cases asserting per-row CAS-on-epoch or gate-first-statement ordering (called out in the commit message) is exactly the kind of concurrency/ordering assertion that is easy to write correctly in isolation but fails under a real transaction/lock scheduler, unlike the mocked orchestration specs that already passed in the source gate. | `test/rls-g2-s8g.spec.ts`, real-PG only, never exercised by the gate's mocked Jest run |
| H3 | The candidate's own bootstrap (`test/utils/g2-s8g-bootstrap.sh`) applies all 172 migrations and asserts S7-L/S8-C objects; any drift between the base `62471b11` schema actually materialized in a fresh PG17.6 instance and what the candidate's guard/harness expect would fail at the `IDENTITY_OK`/bootstrap stage, before Jest even runs — which would explain a failure that is not "N of 19 failed" but a pre-Jest stop. | Runner steps 4–5 (bootstrap, identity) vs. `test/utils/g2-s8g-db-guard.spec.ts` guard logic |

These three are offered only as bounded, code-derived possibilities to guide
a future owner who does obtain the missing receipt — not as findings.

## Actual A/B classification (harm / blocked / min fix / unblocks)

Because no actual failure receipt exists, I can classify only the **actual**
condition observed (absence), not a hypothesized cause:

- **A — Missing receipt (confirmed actual state)**
  - Harm: None yet realized — no product code has shipped on the strength of
    a false "proof passed" claim. The risk is a false GO/NO-GO decision being
    made without ground truth.
  - Blocked: Any acceptance, landing, or "S8-G real-PG proof: PASS/FAIL"
    claim for candidate `820ce85be2eb` is unsupported. G09 ("bind every claim
    to its real evidence") and the grant's own step 5 reporting requirement
    are both unmet.
  - Min fix: None available to a diagnosis-only owner — the fix is
    re-establishing the runtime/worktree and executing exactly one granted
    run of the frozen `s8g-pg-proof.sh`, which is explicitly outside this
    owner's mandate (no install/test/DB/rerun).
  - Unblocks: A single fresh, separately granted, single-attempt execution of
    the unmodified `binding/v1/s8g-pg-proof.sh` against the unmodified
    candidate would produce the missing sentinel/log/jest.log/receipts and
    resolve this classification either way.

- **B — Reported 5/19 failure (unconfirmed, not evidenced)**
  - Harm: Unknown — cannot be classified without the receipt that would show
    which 5 of 19 cases failed and at what stage.
  - Blocked: Any root-cause work, fix authorship, or hypothesis-to-finding
    promotion is blocked on the same missing artifact.
  - Min fix: N/A until the receipt exists.
  - Unblocks: Same as A — the single granted run.

## Exact recovery route (safe, not executed by this owner)

1. Confirm with the operator/parent whether a prior execution attempt actually
   ran outside this sandbox's visibility (e.g., a different host or session
   than `1910a060`) and, if so, recover its `run/` directory intact into
   `private-evidence` under `execution/1910a060/s8g/binding/v1/run/` before
   anything else.
2. If no such attempt exists anywhere, per `SCOPE.md`'s own heavy-sequence
   ordering and the grant's single-run rule: a new parent disposition must
   authorize exactly one fresh run of `s8g-pg-proof.sh`, unmodified, with a
   fresh `RUNTIME_ROOT` and standalone clone `W` re-established per
   `RUNTIME_SETUP_RECEIPT.md`'s donor-copy instructions (§5), under the
   canonical lock, before the run.
3. Whatever the outcome (pass or first-failure), the script's own
   `finish()`/`fail()` traps write the four artifacts listed above
   unconditionally — preserve them immediately and commit them to
   `private-evidence` under `execution/1910a060/s8g/binding/v1/run/` verbatim,
   with no edits, before any disposition or classification is written.
4. Only after that receipt exists should any owner attempt actual A/B
   causal classification of a real failure — not the hypotheses in this note.

## Explicit non-actions taken by this owner (per mandate)

- No install, test execution, DB access, or heavy-slot lock acquisition.
- No automatic rerun of `s8g-pg-proof.sh` or any part of it.
- No inference of an actual root cause for the reported 5/19 figure.
- No product/candidate edits (worktree is clean, unchanged from
  `820ce85be2ebf994112afbb90739eb9469ad628e`).
- No re-audit of already-accepted slices (S7-L, S8-C, S8-F, S9-A source gates
  were read only to distinguish them from the missing S8-G PG proof, not
  re-graded).

Evidence inspected, read-only: `private-evidence` at commit `891228616a15a26efa703eb3ccda4079df2efb50`
(tip at inspection time; sits directly on `3d6ceb4a8bf9a8cec98837d2b06c21efa22690fb`,
the commit named in the task as the pre-proof-grant latest — parent confirmed
this matches the remote). All paths cited above are under
`execution/1910a060/` in that repository.
