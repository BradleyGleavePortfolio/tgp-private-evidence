# S4-V2-INDEPENDENT-PLAN B — V2 allocation-plan review, frozen

## Verdict

**HOLD V2 allocation (controls and validation run). V3 required.** Static, read-only review of the frozen V2 packet only; product head `91990ae9aec72f47a67591892ac09fa1f59d2f16` / tree `840fb2855953d5363fbd144e11b3f81763d9cef7` unchanged and not re-audited. All eight packet hashes verify; launcher `13fed630…`, runner `fa5dbaef…`, pipe helper `c261ffb4…` match the brief. No runner, control, test, install, browser, network, DB, probe or syntax execution was performed; no source, packet or V1 file was written; the current V2 reviewer-A directory exists and was not read. ([Identity/inputs](FINDINGS.json))

Three material findings block allocation: the owned-boundary census is vacuous for every real step (F-01), the supervisor record can never be written so every launcher run ends `FAILED_PUBLICATION`/exit 7 (F-02), and two of the four proposed controls race the launcher and none can observe F-01 (F-03). None of these opens a false `SUCCESS` from the runner's own record; F-01 does (leaked non-Chrome owned process → `SUCCESS` with "group verified empty"). The five V1 closures are otherwise structurally present (see "Checked, not assumed").

## Material findings (exact line-bound; minimal closure only, no new framework)

### F-01 — `timeout` puts every step into a *different* process group, so the PGID census/reap/signal boundary never sees step children (VPA-01 and VPA-03 not closed)

**Locations:** runner `114` (`exec timeout --kill-after=30 …` without `--foreground`), `83` (`pgrep -g "$PGID"`), `86–96` (`reap_owned`), `117–118,127` (post-step verify), `273–274` (final census); launcher `81` (`group_members`), `84–89` (deadline TERM/KILL to `-$PGID`), `96–104` (post-exit census), `115–116,123,125` (classification/record); request `26,28,48`. ([Runner](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh), [request](../../../../s4-r6-validation/v2/SLOT_REQUEST_V2.md))

**Basis:** both GNU and uutils `timeout` call `setpgid(0,0)` when not run with `--foreground` (documented: `--foreground` "don't create a separate background program group … children of COMMAND will not be timed out"); the installed `/usr/bin/timeout` here is `coreutils-from-uutils` 0.8.0 and carries that help text, and the runner hard-codes this host (`ROOT=/home/user/workspace`, runner `23`). Consequently `timeout`, npm, Vitest workers, node probes, the packager, the browser harness and every Chrome process live in a per-step group `PGID = timeout pid`, same session, never in the runner's group `$$`. No `spawn` in the native consumers or probes uses `detached`/`setsid`, so they stay in the session. ([Browser harness spawn 311–331](../../../../../worktrees/s4-r6/scripts/browser-load-proof.mjs))

**Consequences (static failure paths, not observed leaks):**
1. `census`/`reap_owned` after every step and at `final` always find nothing; `orphans_reaped_verified=true` and `cleanup.exit=0` are unconditional. A leaked npm/Vitest/node/Chrome-helper process without a `tgp-*` profile string yields **`SUCCESS`, exit 0** with "group verified empty" (runner `273–288`). The `pgrep -f` profile scan at `275` is again the only real catch — the V1 objection re-enters.
2. On outer deadline/interrupt the launcher signals `-$PGID` = the runner bash only (launcher `85,89`); bash defers `on_signal` while a step is in the foreground, so after `GRACE_S` the runner is KILLed while the step's `timeout` group keeps running for up to `tmo+30 s` (S31: 930 s). `group_members` is empty, `survivors_after_kill=""`, `OVERALL=TIMEOUT` is reported as clean. The advertised worst case (request `48`: 3300+45+15 s) is understated by up to ~930 s.
3. Lock-through-cleanup fails: killing the runner closes fd 9 and releases `test-validation.lock` (runner `65–67`) while step children still write `node_modules`, `dist`, `runs/…` in the worktree.
4. The browser harness's fire-and-forget `child.kill("SIGKILL")` (native `673`) is *not* "covered by the post-step group reap" as request `26` claims.

**Minimal closure:** own the *session*, not the group: runner `census` uses `pgrep -s "$$"` and the launcher uses `pgrep -s "$SID"`; signal each listed PID (or each distinct PGID within the session via `kill -- -pgid`) in the existing TERM→wait→KILL→verify loops. Keep `timeout` group semantics. Add one bounded control whose stub runs a `timeout`-wrapped TERM-immune sleep so this path is exercised before any validation slot. No framework.

### F-02 — the supervisor record is unwritable: unquoted shell `true`/`false` inside Python (VPA-02/VPA-03 truth path)

**Location:** launcher `126` (`"timed_out":$TIMED_OUT` in the unquoted `<<PY` heredoc, `120–128`), `129–132`. ([Launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh))

**Consequence:** `TIMED_OUT` is the shell string `true` or `false` (launcher `75,78`); in Python these are undefined names, so the dict literal raises `NameError` before `open("$SUP","w")` is evaluated — `SUPERVISOR_RECORD.json` is never created. Line `130` then forces `OVERALL=FAILED_PUBLICATION`; line `132` exits **7 on every path**, including genuine `SUCCESS`, `TIMEOUT`, `QUARANTINED_SURVIVORS` and `FAILED_RUNNER_LEFT_ORPHANS`. Fail-closed (never a false 0), but the launcher's entire classification and the request's exit table (`45–47`) are unattainable, and the request's promise that the supervisor record survives when the runner cannot write its own (`28`) is false. `ast.parse` cannot catch this (`true` is a valid Name); the builder's stated checks were therefore insufficient here.

**Minimal closure:** pass the shell values as argv and coerce in Python (as the runner already does at `289–291`), or emit `True`/`False` literals. Then require each control's acceptance to read specific `SUPERVISOR_RECORD.json` fields (`overall`, `signalled`, `reaped_by_supervisor`, `survivors_after_kill`), not the exit code alone.

### F-03 — the proposed controls are not executable as specified and cannot observe F-01

**Locations:** launcher `62–71` (fixed `sleep 0.2`, PGID via `ps`, refusal `73` without census); controls C2 `6–9`, C3 `5–6`, C1 `9–11`; request `60–65`. ([Launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh), [C2](../../../../s4-r6-validation/v2/controls/C2-runner-leaves-orphan-stub.sh), [C3](../../../../s4-r6-validation/v2/controls/C3-publication-failure-stub.sh), [C1](../../../../s4-r6-validation/v2/controls/C1-timeout-orphan-stub.sh))

**Consequences:**
1. **Race:** C2 and C3 exit in milliseconds; when bash has already reaped `RPID` before the launcher's `sleep 0.2` ends, `ps -p "$RPID"` is empty, the `pgrep -P` fallback finds nothing, and line `71` refuses with exit **73**, not the expected 6/7. On that refusal path there is no census or reap, so C2's `nohup sleep 300` is left running for 300 s — the control designed to prove orphan reaping can itself leak an orphan. The same race misreports a fast real-runner refusal (lock busy `75`) as `73`.
2. **Non-representative:** C1–C3 spawn plain `sleep` inside the runner's own group; none wraps a child in `timeout` as `step` does (runner `114`), so all three would show `survivors_after_kill=""` while a real step child would survive invisibly (F-01). Their expected "pass" would be evidence of the wrong topology.
3. **Non-discriminating:** C3's expected outcome (exit 7, `FAILED_PUBLICATION`) is identical to the universal F-02 outcome, so C3 cannot distinguish a correct publication gate from a broken supervisor.
4. C4 is sound: runner `52–53` refuse (exit 71) before the lock at `65` and before `mkdir` at `57`; nothing is created.

**Minimal closure:** derive the owned PGID by construction (`PGID=$RPID`, since a non-leader child of the non-interactive launcher makes `setsid` exec without forking; keep the `ps`/runner self-assert at runner `54` as verification) and run the census/reap on every exit path including refusals; add the `timeout`-wrapped stub from F-01; state per-control acceptance as record fields. Aggregate budget stays ≤ 60 s.

## Non-material observations (record, no allocation impact on their own)

- N-01 S00 (runner `134–159`: git, `node --version`, `npm --version`, per-file `hash-object` loop) is not a bounded `step`; request `28` ("every pre/post command … bounded") overstates. Bounded only by the launcher deadline.
- N-02 Launcher refusal exits 70–73 (`43–71`) write no `SUPERVISOR_RECORD.json` and lose the runner's exit code; the runner message survives only in `console.log`.
- N-03 The launcher records but does not pin the runner hash (`51–52`); in `VALIDATION` mode it should compare to `fa5dbaef…`.
- N-04 `owned_orphans_after` (runner `118`) counts survivors *after* reaping, not orphans found; `reaps.log` holds the true list.
- N-05 Return code `99` is used as the NOTRUN sentinel for `required=0` steps (runner `109,214,259`); native probes/harness document exits 0/1/2 so no current collision.
- N-06 The runner has no deadline of its own; if the launcher dies, the run is bounded only by the sum of step budgets (~1 h + kill-afters).
- N-07 `pgrep -f "tgp-…"` (runner `156,275`) can match unrelated command lines that merely contain the string; fail-closed (`CLEAN_RC=2`), acceptable.

## Checked, not assumed

- Hash/identity: `sha256sum -c v2/SHA256SUMS` OK for all 8 files; manifest is non-self-including.
- Topology: launcher `58` starts `setsid bash runner &` from a non-interactive script, so the child is not a group leader and `setsid` execs in place; runner `54` asserts `sid==pgid==$$` and refuses otherwise (fail-closed). Lock fd is closed for step children (`114`, `9>&-`).
- Fresh output: launcher `43–47` atomic `mkdir`; runner `55,57` refuse pre-existing `steps/`, `dist/`, record, sentinel.
- Exit truth order: runner `284–288` latched failure → cleanup → source → warnings → success; record `.tmp` → parse → `mv` → sentinel (`308–312`); launcher `113–119` requires runner 0 ∧ `result==SUCCESS` ∧ sentinel ∧ no supervisor reaping (would be correct once F-02 is fixed).
- Latch: `block` (`71–74`), NOTRUN short-circuit (`107–110`), blocking codes 90–98; S45/S63 expected-negative handled without treating the intended exit as a prerequisite failure (`213–214,257–269`).
- Joins vs real native consumers: S50b field names match the packager (`package-extension.mjs` `70–92`: `zip.file/bytes/sha256`, `source.head/clean`, `files[].path/sha256`, `<name>.inventory.json`); S62b/S63b match the harness (`browser-load-proof.mjs` `639–668`: `kind`, `package.path/sha256/inventory.zipSha256/inventory.source`, `mutation.file/appended/sha256AfterMutation`, `checks[].name/pass`; `700–745`: `negativeControl.detected/syntaxExceptionSeen/unrelatedFailures`, exit `detected?0:1`). `secrets-scan.sh pr <40hex> <40hex>`/`history` and `install-gitleaks.sh <abs dir>` match the repo scripts; `.git` is a directory clone so `.git/hooks/pre-commit` (S10b) is the right path; `node_modules/` and `dist/` are gitignored so head-cleanliness checks are not self-defeating. ([Packager](../../../../../worktrees/s4-r6/scripts/package-extension.mjs), [harness](../../../../../worktrees/s4-r6/scripts/browser-load-proof.mjs))
- Pipe helper v2: verdict requires the `exit` event; unconfirmed → `CLEANUP_UNVERIFIED`, exit 3, scratch retained (`107–135,141–148,166–168`). Correct in itself; its Chrome is still subject to F-01 at the runner level.

## What this review does not prove

No real gates, Vitest, gitleaks, package, browser or pipe results; no artifact/release or native-import attestation; historical hooks remain **0/6**; the earlier narrow source acceptance is neither widened nor withdrawn. Two independent final evidence attestations remain required after any future real run.

**Next action:** canonical builder freezes V3 with the three minimal closures above (session census + per-PID/PGID signalling; JSON-safe supervisor record; race-free PGID derivation, census on refusal paths, one `timeout`-wrapped control, field-level control acceptance) under new hashes and a new request; then dual independent review, then controls, then one validation slot.
