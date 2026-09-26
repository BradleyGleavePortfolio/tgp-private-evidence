# S10-C gate + binding v1: review as a delta from S10-B (reviewer B)

Scope:
- `private-evidence/execution/d3a9f701/s10c/gate/`: `s10c-gate-d3a9.sh` 80a75682, PINS.env, FROZEN.sha256.
- `s10c/binding/v1/`: `s10c-pg-proof.sh.template` 91ea28d0, `s10c-fixture.sh` c1b57239.
- Summary: `s10c_gate_binding_builder_summary.md`.

This review was read-only: I ran nothing and used read-only git with `GIT_OPTIONAL_LOCKS=0`. The BASE cases checked are the ones the parent named: c8ee9005 (S11-A1 lands) or 711c1f8f.

## Verdict: **NO-GO**

The verdict rests on B1 and B2. Both fixes are small, and after them the binding is GO. The gate is GO once B3 is fixed; B3 is one line.

## What holds

**B4 (my item): closed.**
- New lane `clusters/s10-c` and `run/s10-c`, port 55649, with the path check at template L123.
- 55646 and 55647 are refused as lane ports (L125, fixture L34) and must have zero listeners before and after (L264, L328).
- 55649 must not be in the guard's REFUSED_PORTS, while 55646 must be (L183-184). `g2-s10b-db.ts:69-74` lists 55641-55646 only.
- The retained s10-b lane:
  - must exist, not be a symlink and have no `postmaster.pid` (L127-128);
  - must be in the fingerprint set (preflight);
  - must have an unchanged fingerprint at the end (L327).
- The fixture reuses the S10-B marker, so the same marker is also on the s10-b lane. That risk is closed by `lane_conf_ok`, which requires `port = 55649` in this lane's own conf before start or destroy (fixture L36, L79, L90). The s10-b conf carries 55647.
- The jest run is only `rls-g2-s10b.spec.ts` + `rls-g2-s10c.spec.ts` with `jest.rls.config.js --runInBand` (L307). It requires 32/32 tests and 2/2 suites. The it() counts 24/8 are pinned on the committed bytes (L185-186), and the worktree currently has 24 and 8. It rejects skip/only/todo.

**Frozen paths: hold.**
- The 29 FROZEN entries are pinned by blob at HEAD (binding L158-160) and by bytes pre-lock and under lock (gate L221).
- They are forbidden in the delta (gate PINS FORBIDDEN_DELTA_PATHS and the post-commit FORB check).
- None of the 29 changes between a2c74e90 and c8ee9005 (checked path by path).

**11 owned paths: hold.**
- The gate's REQUIRED_OWNED plus the OWNED_PINS fill (sha, mode, M/N; checked pre-lock and under lock) cover them, including `test/rls-g2-s9c.spec.ts`.
- The staged set must equal the owned set, with index modes checked.
- In the binding, `EXPECT_DELTA` must equal the 11 paths plus the contract only when it changed (L133-135). BASE..HEAD must equal the receipt (L155-156).

**Ancestor rule: holds.**
- Both scripts require `merge-base --is-ancestor` for a2c74e90 and a4af8e33 on BASE (gate L141-142, binding L152-153), and HEAD^ = BASE (binding L151).
- Read-only check: both commits are ancestors of 711c1f8f, and c8ee9005's parent is 711c1f8f.
- The gate's S10B_HEAD..BASE checks (no prisma change, no owned/contract overlap) pass for the S11-A1 delta, which touches no owned path and no prisma.

**Run-once: holds in both scripts.**
- Gate: STARTED/TERMINAL refused before the lock; the lock inode must match both the record and PINS; nonblocking flock; STARTED created with O_EXCL (gate L203-212).
- Binding: sentinel and STARTED are symlink-aware (L109-110, L237); the lock inode must be 692282; STARTED is created with O_EXCL straight after the flock (L240-242).
- All pins are checked before the lock.

**No `| grep -q`:** confirmed. Every `grep -q` reads a file or a here-string.

## Findings

### B1: the binding refuses its primary BASE case (c8ee9005)
- **Where:** template L162: `git diff --name-only "$S10B_HEAD" HEAD -- prisma package.json package-lock.json test/utils` must be empty.
- **Concrete harm:** at BASE = c8ee9005, S11-A1 adds six paths under `test/utils/` (`g2-s11-bootstrap.sh`, `-db-guard.spec.ts`, `-db.ts`, `-harness.ts`, `-pg-harness.ts`, `-worker.cjs`; checked with a read-only `git diff a2c74e90 c8ee9005`). The binding would stop pre-lock with "prisma / manifests / test/utils differ from the S10-B landing".
  - The refusal happens before the lock, so the run is not consumed.
  - At 711c1f8f the diff is empty and the binding passes.
- **Exact thing blocked:** the 32-test S10-C live proof on the base the parent said it will most likely use.
- **Minimum fix:** narrow the pathspec to `'test/utils/g2-s10b-*'`. Those files are already blob-pinned at L189-192. Alternatively, drop `test/utils` from this line: the gate already forbids `test/utils` in BASE..HEAD, and L164 and L167 carry the prisma and manifest parts.
- **Unblocks:** the binding at BASE = c8ee9005.

### B2: the binding lacks the S11 hook-identity and core.hooksPath equivalents
- **Where:**
  - L197-202 check only that `$(git rev-parse --git-path hooks)/{pre-commit,commit-msg}` are regular files that contain "lefthook".
  - There is no `core.hooksPath` refusal.
  - There is no check that the hooks dir is the plain `.git/hooks` directory. If core.hooksPath is set, `--git-path hooks` follows it, and any lefthook-containing files there pass.
  - There is no identity pin against the gate's receipt (`hooks raw pre-commit=… commit-msg=…`, gate L418).
  - The under-lock recheck (L245-247) covers fixture, HEAD, status and client only, not hooks.
- **Concrete harm:** the "committed through the gate's genuine hooks" attestation can be satisfied by other hook files. This is the same defect the parent just fixed in the S11 runner (s11-pg-proof.sh L131-136 and L221-224).
- **Exact thing blocked:** the binding's hooked-commit evidence line, and parity with S11-A1 as the parent requested.
- **Minimum fix:**
  1. Pre-lock:
     - refuse a non-empty `git -C "$W" config --get core.hooksPath`;
     - require `--git-path hooks` = `.git/hooks`, a real directory and not a symlink;
     - add fill pins `EXPECT_HOOK_PRECOMMIT_SHA` and `EXPECT_HOOK_COMMITMSG_SHA`, taken from the receipt `hooks raw` line, and compare both.
  2. Under the lock, repeat all three checks in the L245 recheck.
- **Unblocks:** the binding hook evidence, with parity to S11.

### B3 (low): the gate does not re-assert hook identity immediately before the commit
- **Where:** hooks are installed and verified under the lock (gate L273-291), and `core.hooksPath` is last checked at L291. Then the targeted and full jest runs follow (up to 4200 s) before `git commit` at L385. Nothing re-checks `sha .git/hooks/{pre-commit,commit-msg}` = `$HP/$HC`, the plain hooks dir or an empty `core.hooksPath` just before L385.
- **Concrete harm:** if a hook or hooksPath changes during that window of more than 70 minutes, the receipt still records the L277 shas as the hooks that "made" the commit. The one hooked commit is then unproven.
- **Exact thing blocked:** the gate receipt's `hooks raw` line as evidence of the commit.
- **Minimum fix:** one guard line before L385, e.g. `[ "$(sha .git/hooks/pre-commit)" = "$HP" ] && [ "$(sha .git/hooks/commit-msg)" = "$HC" ] && [ -z "$(git config --get core.hooksPath)" ] && [ "$(git rev-parse --git-path hooks)" = .git/hooks ] && [ ! -L .git/hooks ] || { log "HOOK_FAIL hooks moved before commit"; finish 71; }`.
- **Unblocks:** the gate's hooked-commit receipt.

### Hygiene (C)
- **C1:** the binding runs in the gate worktree `worktrees/d3a9-s10c`, not a fresh clone. That is the same as the accepted S10-B design and the worktree is kept clean (checked pre-lock and under lock), so there is no finding. Once B2's hook pin is in, the worktree's hooks are the gate's own.
- **C2:** the summary says "`test/rls-g2-s9c.spec.ts` is not run". The template header (L19-20) says the same, and it matches the parent decision. Its live proof rests on S10-C R33/R35 (Delta review 1, C6).
- **C3:** the `clusters/s11` lane from the running S11-A1 proof will be in the fingerprint set. Before-and-after equality still holds as long as S11's teardown has finished before the S10-C binding takes the lock. The shared lock and the `pgrep -cx postgres = 0` preflight enforce this.
- **C4:** DELTA files not re-diffed byte-for-byte; I reviewed the scripts directly.

## Delta 1: review fixes (gate `daf179fd…`, template `bf73d258…`)

**Verdict: GO** for both the gate and the binding. B1, B2 and B3 are closed.

What I did:
- Read both `DELTA-review-fix.diff` files.
- Ran `sha256sum -c` on GATE.sha256 and BINDING.sha256; every entry is OK. Both lists record the new shas (daf179fd / bf73d258).
- Ran `bash -n` on the gate and the template; both are OK.
- Ran nothing else.

| Finding | Status | Evidence |
|---|---|---|
| B1: `test/utils` refusal at c8ee9005 | **Closed** | The pathspec is now `'test/utils/g2-s10b-*'`. Git pathspec globbing is on by default, so the S11-A1 `g2-s11-*` additions no longer match. The g2-s10b-* files are still blob-pinned (template L189-192), and the prisma and manifest parts of the line are unchanged. |
| B2: binding hook identity | **Closed** | Pre-lock: <br>• `core.hooksPath` is refused if set;<br>• `--git-path hooks` must be the plain `$W/.git/hooks` directory, not a symlink;<br>• both hooks must be regular files and equal the two new fill pins from the receipt's `hooks raw` line.<br>The pins are also in the placeholder refusal and must be 64-hex. Under the lock, the recheck repeats hooksPath, the plain dir, regular files and both shas. `H` is assigned only once (L201), so the recheck compares against the pre-lock path. The README fill table lists both pins. |
| B3: gate recheck before commit | **Closed** | A guard line sits immediately before `git commit`. It checks: both hook shas = `$HP/$HC`, `core.hooksPath` empty, `--git-path hooks` = `.git/hooks`, the dir is real and not a symlink, and both hooks are regular files. On failure it stops with `HOOK_FAIL`, rc 71. |

Nothing new introduced:
- No `| grep -q`.
- No other logic changed. The diffs contain only these hunks, and the `.pre-review-fix` copies are retained and hash-listed.

## Gate run-1 delta — landed S8-G settle-hook spec

**Verdict: GO on this test-only repair; the full gate still requires a fresh passing run.** The diff adds only two transaction-double delegates for the S10-C post-CAS observation read/basis insert and a fourth-argument matcher for the run binding (`private-evidence/execution/d3a9f701/s10c/gate-fix/settle-hook.diff`; `test/scout/orchestration/settle-hook.spec.ts:113-122,164-175`). It deletes or weakens **no** S8-G assertion: G01 still verifies pass→lock→facts→terminal order, one facts call, truthful partial verdict, settled event and no false `complete`; the gate, CAS-miss, fence, failed-claim and unexpected-pass-failure cases remain (`test/scout/orchestration/settle-hook.spec.ts:154-188,190-295`). The stubs are narrow and do not mock away `onTransferSettled` or the terminal write; the formerly failing suite now reports 10 passed/10 total (`gate-fix/jest-settle-hook-2.log`). The generic basis-create stub is appropriate to this preexisting S8-G orchestration spec; S10-C-specific tests, not this spec, must prove basis contents/order. No new A/B issue in this delta.

## Proof run-1 delta (`PROOF_RUN1_FINDING.md`, `proof-fix/rls-g2-s10c.diff`)

**Verdict: NO-GO, on one item (R36).** Items 1-3 are GO as written. R36 needs a fix of about five lines, and proof v2 is a new run anyway, so tightening it now costs nothing extra.

This was read-only. I read `src/scout/scout.service.ts` (landed, not S10-C-owned), `test/utils/g2-s10b-worker.cjs`, and the D-S10-6 text and R38 in `docs/decisions/2026-09-26-s10-induction.md`. I ran nothing.

**The classifications are right (class B: the spec's premises were wrong, the product was not).**
- **200 ack for a duplicate or fenced settle is the landed contract.**
  - The doc at `scout.service.ts:365-366` says "a fenced or terminal run (late or duplicate settle) → 200 ack no-op, unchanged".
  - The code agrees: `completeServerRun` catches `RunGateClosed` and throws 409 only for `not_started`; otherwise it `return ack` (L392-397). P2002 on a second open claim also returns ack (L401).
- **The claim commits before the settle.** The `$transaction` (L375-390) commits the ledger row and phase before `notifyComplete` → `onTransferSettled` (L405-410).
- **pushes=1 is not a customer side effect.**
  - `notifyComplete` calls `notifications.pushToUser(coachId, …, {kind:'import.complete'})` (L553-570). That is the importing coach, the user themselves, and it is pre-existing S7-L behaviour.
  - D-S10-6 invariant 5 (doc L338-340) is about *customer-facing* effects and the *induction module's* imports.
  - R38 (doc L442-443) lists "import, replay, declaration and observations", not the /complete settle.
  - `sideEffectLoads` stays asserted all-zero.
- **The R36 re-drive is out of S10-C scope** (S11-B), so the "retry settles" premise was wrong.

**Fixes 1-3: minimal, non-vacuous, no invariant dropped.**
- **R33 complete:**
  - `pushes 1` is exact, not `>= 1`, and module loads are 0.
  - `noSideEffects` is kept on the status reads (spec L271, L286).
  - Residual C: the frozen worker counts pushes without recording the recipient (worker L77-81). Coach-only is carried by the source: the only `pushToUser` on this path is `notifyComplete(coachId)`.
- **Second claim:** ack, `pushes 0`, still exactly one SETTLED row, and no basis INSERT in the second call. Insert-only is preserved.
- **Fenced late claim:** ack, `pushes 0`, no basis INSERT, zero SETTLED, and `reason_code` stays `revoked`. That covers "the fence writes no basis" and "the late claim writes none".

**B (NO-GO): R36 retry. The new assertion is conditional where the outcome is deterministic.**
- **What the diff asserts:** `expect(count(SETTLED)).toBe(terminal_status === null ? 0 : 1)`.
- **What the code does, deterministically:**
  1. After the injected failure, the tail rolls back: terminal NULL, 0 basis rows. This is already asserted above the retry.
  2. The ledger row and `phase='reconciling'` are committed.
  3. On the retry, either `assertRunOpen` passes and `scoutImportCompletion.create` hits P2002 → ack (L401), or the gate reads as closed → `classifyClosed` gives something other than `not_started` → ack.
  4. On both paths `onTransferSettled` is never reached: no push, no CAS, no INSERT.
- **Concrete harm:** the conditional accepts both "retry did nothing" and "retry settled with one basis row". The spec therefore no longer proves what the retry actually does. It would silently pass if the retry started settling on a path other than S11-B's re-drive, e.g. a regression that settles from a retried claim without the S11-B re-arm. It would also give S11-B no failing assertion to supersede.
- **Exact thing blocked:** the R36 half "retry after a failed settle is a no-op and leaves the run open until the S11-B re-drive", as a live proof.
- **Minimum fix:** replace the conditional with exact assertions:
  - `expect(retry.failure).toBeUndefined(); expect(retry.pushes).toBe(0);`
  - `expect(retry.queries.filter(isTerminalCas)).toHaveLength(0); expect(retry.queries.filter(isBasisInsert)).toHaveLength(0);`
  - `expect(runRow(COACH, intentId).terminal_status).toBeNull(); expect(count(SETTLED)).toBe(0);`
  - plus the comment "superseded by S11-B re-drive".
  - The pairing invariant is implied (null ↔ 0).
- **Unblocks:** GO on the proof-fix, and candidate v2 / proof v2 with this spec.

**C (optional):** in the second-claim case, also assert `runRow(...).terminal_status` and `reason_code` unchanged from the first settle, and `again.queries.filter(isTerminalCas)` empty. Not blocking, since SETTLED=1 and no INSERT already carry insert-only.

## Proof run-1 delta 2 (`proof-fix/rls-g2-s10c-v2-to-v3.diff`)

**Verdict: GO.** The R36 B finding is closed and the optional C extra is applied.

**R36 retry**
- The conditional is replaced by exact assertions: ack, `pushes 0`, no `isTerminalCas`, no `isBasisInsert`, `terminal_status` null, `count(SETTLED)` 0.
- The comment names S11-B's re-drive as the explicit superseder.
- This matches the deterministic path in `scout.service.ts` (L392-401 ack; `onTransferSettled` never reached).
- The query-absence checks are non-vacuous: the same `isTerminalCas` and `isBasisInsert` matchers must hit exactly once in R33 (`toHaveLength(1)`) on the same run shape.

**Second claim**
- Adds: no terminal CAS, and `terminal_status`/`reason_code` equal to the row captured right after the first settle.
- It keeps: `pushes 0`, SETTLED 1, and no basis INSERT.

The diff has only these two hunks. The `it()` count is unchanged at 8, and no invariant is dropped.
