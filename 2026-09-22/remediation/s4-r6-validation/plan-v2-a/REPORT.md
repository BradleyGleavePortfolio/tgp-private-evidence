# S4-V2-INDEPENDENT-PLAN-A — frozen static disposition

**HOLD V2 allocation, including the proposed controls as currently specified.** Product `91990ae9aec72f47a67591892ac09fa1f59d2f16` / tree `840fb2855953d5363fbd144e11b3f81763d9cef7` remains clean; original source and V1 audit packets remain unchanged. This review ran no launcher, runner, control, timeout target, syntax check, test, install, browser, network or DB operation; local binary disassembly was read-only inspection, not a process-topology experiment. No current V2 peer conclusions were accessed. ([Attribution](INPUTS.json))

Exact reviewed launcher `13fed63063ec5511c50255263e69b410df35fad625e48efb0613355ab2d53c8f`, runner `fa5dbaef8834a5766536e63c1f8772eaa3eb0e6f7173cdbbba14b99bcf09b2ff`, pipe `c261ffb408dc5a724a17c5ad0889b500918fde5d1aa29420b39ced4c4d04531b`; all eight packet manifest entries match. Requested identity is inherited parent; actual model/version/reasoning settings are not exposed. ([Attribution](INPUTS.json))

## Five prior closures

| Prior ID | V2 static disposition |
|---|---|
| VPA-01 ownership | **OPEN:** transient command-substitution census is removed and immediate pipe-child exit is now required, but the nested timeout creates a different process group from the group being supervised; A-01 below controls applicability. ([Runner, 80–95,114](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [pipe, 105–167](../../../../s4-r6-validation/v2/runner/chrome-pipe-discriminator-v2.mjs)) |
| VPA-02 truth | **PARTIAL:** runner cleanup/source checks and parsed temporary-record publication are improvements; supervisor publication is deterministically broken, and primary failure attribution still has defects (A-02/A-04). ([Runner, 271–321](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [launcher, 120–132](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh)) |
| VPA-03 bounded launch | **PARTIAL:** output is created before redirection and a mandatory supervisor deadline exists, but startup identification, final wait and proposed control bounds remain unsafe/unproved (A-03/A-05), compounded by A-01. ([Launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh), [request](../../../../s4-r6-validation/v2/SLOT_REQUEST_V2.md)) |
| VPA-04 attribution | **NARROW SOURCE CLOSURE:** exclusive fresh output, sole named inventory/ZIP, actual ZIP hash/size, HEAD-file comparisons, browser receipt joins, reused-probe pins and predecessor comparisons now address the identified stale-output/input counterexample; actual artifact proof remains NOTRUN. ([Runner, 133–154,216–268](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [packager round-trip and inventory](../../../../../worktrees/s4-r6/scripts/package-extension.mjs)) |
| VPA-05 prerequisite latch | **NARROW SOURCE CLOSURE:** dedicated required evidence steps and `FIRST_FAIL` prevent dependent execution; the incorrect exit attribution in A-04 does not undo that latch but still requires repair. ([Runner, 69–74,104–130,163–214](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh)) |

## Material successor findings

### S4-V2-A-01 — HIGH — nested timeout leaves the supervised group

**Locations:** runner `56,83,114,117,273–277`; launcher `81–104`. Actual `step()` executes `timeout --kill-after=30 …` without foreground mode, while every census and supervisor group signal selects only runner PGID `R`; a session and a process group are not interchangeable. ([Runner](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh))

This was independently checked against the installed tool, not assumed to be GNU: `/usr/bin/timeout` resolves to the **uutils 0.8.0** binary, SHA256 `48893b0fb21436b54619db80486e83ef39dfccaf1aefe83dfa00c02d6146e8c0`; its static timeout code contains the foreground option and default `setpgid(0,0)` branch at `0x4f30f4` through relocation `0xaca1f8`. No timeout process was launched to obtain this evidence. ([Static binary evidence](TIMEOUT_STATIC.json))

**Counterexample:** runner `R` launches timeout `T`, which creates PGID `T` in session `R`; the command and its ordinary descendants inherit `T`, so `pgrep -g R` omits them. If the command exits leaving an orphan, the post-step “verified empty” check can miss it; if the outer deadline kills only `-R`, the step group can continue beyond that grace, while the killed runner releases the lock because its step child deliberately closed fd 9. Profile-name scanning does not cover npm/Vitest children and treats escaped Chrome as unowned instead of cleaning it. ([Runner, 64–67,83,114,275–277](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [supervisor signal route](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh), [static timeout evidence](TIMEOUT_STATIC.json))

**Minimal closure:** align the timeout launch with the chosen stable ownership boundary, or explicitly supervise all owned step groups/session members; keep the lock held through verified termination. A narrow control must exercise the **actual nested step wrapper**, including an orphan after a nominal command exit and interruption during a live step; C1/C2 currently bypass `step()` and therefore cannot prove this closure. ([Controls](../../../../s4-r6-validation/v2/controls/C1-timeout-orphan-stub.sh), [C2](../../../../s4-r6-validation/v2/controls/C2-runner-leaves-orphan-stub.sh))

### S4-V2-A-02 — HIGH — supervisor JSON publication always evaluates an undefined Python boolean

**Location:** launcher `75,120–130`. The unquoted heredoc substitutes shell `TIMED_OUT=false` or `true` directly into Python as `"timed_out":false` or `"timed_out":true`; neither identifier is defined, so dictionary evaluation raises `NameError` before `json.dump` can write the record. Syntax-only parsing would not detect this name-resolution failure. ([Launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh))

**Consequence/closure:** any path reaching this writer loses the promised supervisor receipt and is ultimately relabelled FAILED_PUBLICATION/exit 7, including an intended TIMEOUT/124 control; pass/parse a real Boolean through a quoted/data-safe interface, preserving timeout/interruption and publication failure as distinct facts. This is a static deterministic defect, not an executed failure. ([Launcher, 129–132](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh))

### S4-V2-A-03 — HIGH — delayed ownership discovery loses fast exits; final wait is unbounded

**Locations:** launcher `58–71,92`. Ownership is discovered only after `sleep 0.2`; C2 and C3 can exit before that observation, leaving no `RPID` for `ps`, and a C2 orphan has already reparented so `pgrep -P RPID` cannot recover it. The exit-73 refusal then precedes the supervisor-record writer and does not reap the missing group. The comment describing recovery of a re-forked session leader does not implement a durable handshake. ([Launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh), [C2](../../../../s4-r6-validation/v2/controls/C2-runner-leaves-orphan-stub.sh), [C3](../../../../s4-r6-validation/v2/controls/C3-publication-failure-stub.sh))

**Additional bound:** `wait "$RPID"` has no bound and runs before the final survivor classification; if termination is not confirmed after KILL, the supervisor can block rather than write QUARANTINED_SURVIVORS. S00 and final bookkeeping also remain outside `step()` despite the request's broader wording, so the outer supervisor must really cover them. ([Launcher, 89–105](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh), [runner, 133–161,279–309](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh))

**Minimal closure:** establish acknowledged ownership before allowing the child workload to exit or orphan work, preserve that identity after exit, and classify startup/refusal through the supervisor; bound confirmation/reaping instead of unconditionally waiting on a possibly surviving process. Do not “repair” C2/C3 by adding a sleep that merely hides the lifecycle race.

### S4-V2-A-04 — MEDIUM / MATERIAL — first failure and runner exit can misstate the observed failure

**Locations:** runner `127–129,213–214,300,321`. Cleanup/source errors are latched before the already-observed command exit, so a command failure followed by cleanup failure reports 96 rather than that first command exit; an unexpected S45 exit **0** is also passed to `block`, then `RESULT=FAILED` falls through to `exit 0`. Dependent steps do stop, and the supervisor's result check would reject FAILED, but the runner's exit and promised primary-failure attribution are not truthful. ([Runner](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh))

**Minimal closure:** preserve the primary command exit before later cleanup errors; keep raw expected-negative observation 0 separate from the nonzero validation-failure exit used for a violated sign predicate. Retain cleanup/source results independently rather than replacing the first failure.

### S4-V2-A-05 — MEDIUM / MATERIAL — proposed control grant does not enforce its ≤60-second allowance

**Locations:** request control table; launcher `35–36,78–101`. C2/C3 specify outer 30 seconds but inherit grace **45 seconds**, so an unexpected hang can consume 75 seconds before additional kill/reap/publication time—already beyond the entire requested aggregate allowance. C4 has an expected duration but no aggregate supervisor, and the unconditional wait in A-03 further invalidates a finite worst-case claim. ([Request](../../../../s4-r6-validation/v2/SLOT_REQUEST_V2.md), [launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh))

**Minimal closure:** freeze explicit per-control deadline/grace values and a total sequential-control bound that includes failure cleanup; stop on the first unexpected result and preserve receipts. Lowering names or optimistic typical durations is not a bound.

## Proposed controls and real-proof applicability

| Control | Static assessment; no execution |
|---|---|
| C1 | Exercises same-group TERM immunity/reparenting, not nested timeout; even if termination matches the request, A-02 prevents the requested TIMEOUT receipt/exit. ([C1](../../../../s4-r6-validation/v2/controls/C1-timeout-orphan-stub.sh), [launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh)) |
| C2 | Correctly intends to detect exit-0 orphan leakage, but the fast-exit ownership race can leave its `sleep 300` outside cleanup and return 73 instead of the required 6; do not allocate unchanged. ([C2](../../../../s4-r6-validation/v2/controls/C2-runner-leaves-orphan-stub.sh), [launcher, 62–71](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh)) |
| C3 | A zero exit with SUCCESS JSON/no sentinel is a useful publication negative, but fast exit can hit 73; after that repair, A-02 can produce exit 7 for the **wrong cause**, so exit 7 alone is not a discriminating control—require the intended parsed runner record/no-sentinel facts. ([C3](../../../../s4-r6-validation/v2/controls/C3-publication-failure-stub.sh), [launcher](../../../../s4-r6-validation/v2/launcher/s4-r6-launch-v2.sh)) |
| C4 | With launch variables absent, the real runner refuses at its token check before lock/worktree use; the control wrapper itself returns **0** when it observes runner 71. Preserve that distinction in any later receipt. ([C4](../../../../s4-r6-validation/v2/controls/C4-direct-runner-refusal.sh), [runner, 50–67](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh)) |

Native packager/browser CLI and JSON fields remain compatible with the reviewed consumers; the original-ZIP joins and stricter syntax/no-receiver negative are retained, and genuine prerequisite failures now stop later steps. None of that proves real Vitest, gates, package/browser success, or a Chrome reproduction of R6's concurrency schedules. ([Runner, 182–268](../../../../s4-r6-validation/v2/runner/s4-r6-validate-v2.sh), [packager](../../../../../worktrees/s4-r6/scripts/package-extension.mjs), [browser](../../../../../worktrees/s4-r6/scripts/browser-load-proof.mjs))

**Next:** canonical builder supplies a minimal additive successor for these five findings; independently assess it before separately authorizing bounded controls, then native validation. No product repair, original report rewrite, test/artifact acceptance or release authorization is implied; historical hooks remain **0/6** and artifact/release attestations stay **WITHHELD**. ([Review contract](../../../../S4_V2_REVIEW_BRIEF.md))
