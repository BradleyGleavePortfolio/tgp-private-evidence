# OP88-OWNED-LAUNCH-V8-B — independent T4 non-builder review of the frozen S5 V8 T0/setup packet

- Reviewer: independent auditor B (Claude "Fable 5" by policy label; actual model setting unexposed). Non-builder. Read-only.
- Parent thread: e9bd7cce-d7f3-4f33-b3c3-e2b7adbe9038 (mail priority high).
- Peer isolation: `execution/op88/audits/owned-launch-v8-a` and `execution/op88/audits/s4-v4-a` were NOT read. No current peer conclusions were consulted. A directory search for base-file provenance surfaced file names under `execution/op88/s5-v9-t0/`; its contents were NOT read and play no part in this verdict.
- Operations performed: `cat`/`sed`/`rg`/`sha256sum`/`cmp`/`diff -u`/`ls`, plus one read of `/proc/sys/kernel/pid_max`. No packet script was executed, no `bash -n`, no probe of live processes, no lock operation, no install, no network.
- Frozen at (actual clock, `date -u`): see `frozen_at` in `FINDINGS.json`; the value was taken immediately before hashing.

## 1. Exact inputs (all hashes verified by me)

Packet `/home/user/workspace/execution/op88/s5-v8-t0/` — manifest `SHA256SUMS.s5-v8-t0` = `ed03323afc1b6a779961a214a87b2b97b363ebe09fe8a20fbeab392d802ed6f5`, `sha256sum -c` 12/12 OK.

| file | sha256 |
|---|---|
| own-block-v8.sh (29 lines) | cc8346cdf298922dedc5ea3f7dfed538d3aec16be87e2c085ae8b7a89eaeba9c |
| controls-v8-t0/ctl-t0-only.v8.sh | c226266e23e3c5e953085ef92afcf3f8eeb1e64e60d823208b6144edd6e88e2b |
| controls-v8-t0/run-s5-setup-npm-ci.v8.sh | bca8315844e5c9dd965f905745bcf405d9a760d3bcc170399e91d2b093884a91 |
| controls-v8-t0/ctl-own-startup.sh | b34db0d88620fed015fd07a8b89da54f490de3fb201b4c1a6546a20646289bf0 |
| controls-v8-t0/sup-under-test.sh | 9dc308ab1439479030ee219ce29fe9596612b0adcc8d19dd19613525ef6f50b4 |
| controls-v7-to-v8-t0-only.diff | 83d272df7db5a60ae95c996c662f08a0872fa35df204b4e92a069381d52e4ef5 |
| setup-v1-to-v8.diff | c18bbc31a57484d1b5d2b60403068bcba65b45cf80c7c1bad5eb330f927bbc20 |
| inputs/ctl-t0-only.v7.sh (base) | a13d44a5ba5b1ec9097b7e5782bb057b4b9b46f96086a40ebdbb6db1e769da6a |
| inputs/run-s5-setup-npm-ci.v1.sh (base) | 74736a5878fe4620adfb8dfe8f0a1c88e12b4f08a5313d3a52017e1deb8ebeaa |
| SUMMARY.json | 7cf7dafeab3099e4944a86474f8495d952fc54cbf2d35f4d6ee2e2d29286aa93 |
| V8_T0_AND_SETUP_SUCCESSOR_REQUEST.md | e602802bffa4eecc0d93c2b9d800658b490f9a068dc05e1cd38b9a583aea6f23 |
| verify-embedded-block.sh | dfeccbc20b07b457eb1423f8a9141b599bb0861db54caa641547818f787f1c34 |

Context inputs: `execution/op88/OWNED_LAUNCH_SCOPE.md` 811ca939…, `S5_V8_MILESTONE_1.md` 642800b0…, `S5_R1_GRANT.md` 0cd35c36…, frozen prior review `audits/s5-v7-a/AUDIT.json` 1f6f651c… (permitted frozen dependency, defines A-02/A-03), `execution/OP88_WAVE1.md` f0d348dd…. Full list in `INPUTS.json`.

Provenance checks I reproduced myself:
- Embedded OWN-BLOCK: `sed -n '/^# >>> OWN-BLOCK v8/,/^# <<< OWN-BLOCK v8/p'` of both consumers `cmp`-identical to `own-block-v8.sh` (T0 driver L47–75; setup L39–67). Builder claim "IDENTICAL x2" confirmed independently (the packet's `verify-embedded-block.sh` was not run).
- Both packet diffs reproduced byte-for-byte from `inputs/` bases with `diff -u` (header timestamps excepted).
- V7 base a13d44a5 equals the frozen `s5-v7/controls-v7-selective/ctl-t0-only.sh`; setup base 74736a58 equals `s5-restore/setup-v1-frozen-copy/run-s5-setup-npm-ci.v1.sh`.
- `control-results/` exists and is writable (drwxr-xr-x) inside the otherwise r-x packet, as the controls require (ctl-own-startup L15).
- Host fact read from `/proc/sys/kernel/pid_max`: **32768** (relevant to V8B-01).

Implemented / tested / unrun truth: everything in the packet is implemented and hash-bound; NOTHING has been executed by builder or by me; the controls (8 cases / 16 checks) are unrun; the consumers' adapted lines (T0 L110–121, setup L129–141) are exercised by no control at all (the fixture exercises only the primitive).

## 2. What the primitive does (line-bound, own-block-v8.sh)

- L4 samples `OWN_SELF_PGID`/`OWN_SELF_SID` once at source time. L5 `OWN_PIDS` (every spawned pid) / `OWN_PGIDS` (confirmed leaders only). L6 `own_register` appends; nothing ever removes a pid.
- L7 `own_identity`: `ps -o pgid= -o sid= -p pid | tr -s ' ' | sed` → "pgid sid" (parse verified correct for padded output).
- L8 `own_alive`: `kill -0` then `ps -o stat=` first char ≠ Z.
- L9–14 `own_confirm`: up to 40×50 ms polls; confirmed iff pgid==sid==pid and pgid ≠ self pgid; records a caller-group decoy; rc1 gone, rc2 unconfirmed.
- L15–17 `own_signal`: re-runs the same shape test at signal time; group signal (`kill -SIG -- -pg`) only if it passes, else pid-only; "gone" if no identity.
- L18–19 `own_wait_gone`: bounded 0.1 s polls, never `wait`.
- L20–26 `own_reap_all`: per registered pid: TERM → bounded grace → KILL → bounded 3 s → SURVIVOR; then `pgrep -g` census of confirmed groups (census only — no signal).
- L27–28 `own_budget`: min(want, remaining−grace−reserve), floor 0 (arithmetic checked: 6→0, 30→10, 200→90, 25→5 as C0 expects).

Consumers: T0 driver spawns `( cd … && exec setsid env -i … jest … ) &` (L110–111), registers (L112), confirms (L113), refuses/pid-only cleans (L115), polls budget (L116), TERM/KILL with bounded waits (L117), `wait` unless `budget-KILL-unconfirmed` (L118), group census (L119), checks `.identity`/`.owned` (L122–123); EXIT trap `on_exit` (L91) reaps via `own_reap_all`. Setup spawns `setsid taskset npm ci … 9>&- &` (L129), registers/confirms (L130–131), refuses with `die startup-identity-unconfirmed 2` (L132), keeps unchanged `reap_group` ownership list (L133, L141), `on_signal` → `own_reap_all 20` (L96), `final_accounting` censuses `OWNED_PGIDS` and `OWN_PIDS` (L87, L90).

In all three launch sites the spawned process is a forked non-leader, so util-linux `setsid` calls `setsid()` and execs in place: `$!` IS the eventual session leader (pgid==sid==pid) and its PPID stays `$$`. The confirmation predicate is therefore satisfiable and correct for the real children.

## 3. Closure of the inherited findings

- **S5-V7-A-02 (HIGH, V7 registers after `sleep 0.2`; caller-group pgid could be adopted as signal authority):** substantially source-closed. Registration is the command right after `&` (T0 L112, setup L130); the sampled caller pgid is refused as a decoy (block L12–13); group signals need pgid==sid==pid ≠ self at signal time (L17); unconfirmed identity fails `T0.identity` (T0 L122) or `die … 2` (setup L132). Residuals: V8B-05 (one command-boundary window remains, LOW) and V8B-01 (retired-pid re-targeting, new, HIGH).
- **S5-V7-A-03 (MEDIUM, bounds omit kill/cleanup grace; unconditional `wait`):** partially closed. Admission budgeting (L27–28, T0 L107–108) and bounded waits on the budget path (T0 L117–118, setup L137–139) are correct. NOT closed on the identity-refused path (V8B-02), where the unconditional `wait` survives in both consumers. Worst-case T0 timing (≈2.4 s confirm + ≈92 s budget loop + ≈11 s grace + ≈3.3 s KILL wait + 3 s census, +≈15 s if `on_exit` must reap) ≈ 112–127 s plus gate overhead against the recommended outer 140 s: plausible, thin, and correctly labelled "not a completion attestation".
- **P88-S5-SETUP-01 (setup v1 L90–91 same class):** same status as A-02 for the setup consumer.

## 4. New findings (material unless stated)

### V8B-01 — Retired registered pids stay signal targets; identity is a shape test, not an ownership test (HIGH, material)
- Where: block L5–6 (no retire operation), L8 (`kill -0` accepts any same-user pid), L9–17 (predicate pgid==sid==pid ≠ self only — no `PPID==$$`, no start-time binding), L20–26 (iterates every ever-registered pid). T0: L118 `wait` reaps but does not retire; L91 `on_exit` → `own_reap_all` re-examines the retired number. Setup: L139/L141 clear `CUR_PID` but `OWN_PIDS` keeps it; L90 `final_accounting` increments `CLEANUP_FAILURES` if `own_alive` on that number succeeds; L96 `on_signal` would signal it.
- Counterexample: after the child is reaped, its pid number is free. On this host `pid_max` is 32768 (read from `/proc`), and the setup consumer runs up to ~1265 s while every `own_alive`/`own_identity` poll and every other lane fork processes; the number can be reused within the window. If reused by any same-user process that is its own session leader (every other lane's `setsid`-launched runner — including `timeout` under `setsid nohup timeout …` as the setup's own invocation line shows — satisfies pgid==sid==pid ≠ self), then (a) setup L90 reports a false `alive=YES` → `CLEANUP_FAILURES++` → FINAL 90 on a successful install, and (b) `on_signal`/`on_exit` send **group TERM then KILL to a foreign lane**. This is exactly "treating a retired numeric ID as signal authority", which OWNED_LAUNCH_SCOPE forbids.
- Not covered by controls (no pid-wrap fixture; a PPID-mismatch fixture is constructible: register a pre-existing own-session `sleep` that is not our child and require refusal).
- Smallest closure: (1) `own_retire <pid>` (remove from `OWN_PIDS`, and from `OWN_PGIDS` once the group census is empty) called right after every successful `wait`; (2) add `ppid==$$` to `own_identity`/`own_confirm`/`own_signal` (`ps -o ppid=`), which is exact for all three direct-child launch sites; optionally bind the confirmed start time (`/proc/<pid>/stat` field 22) and require it at signal time.

### V8B-02 — Unconditional `wait` retained on the identity-refused KILL-survivor path (MEDIUM, material)
- T0 L115 sets `m="pid:$pid"` when the unconfirmed child survives KILL for 3 s but leaves `how=identity-refused`; L118 then executes `wait "$pid"` unconditionally (only `budget-KILL-unconfirmed` skips it). Setup L132 increments `CLEANUP_FAILURES` for the same survivor and then `wait "$CUR_PID"` unconditionally. (Fixture L37 has the same shape; bounded by `timeout -k 3 15`, non-material.)
- Header claims (T0 L11–13, block L20 "without unconditional wait") are false on this path. A KILL-surviving child (uninterruptible sleep) is rare but is the same class A-03 named; under the outer `timeout` the driver would be KILLed without running `on_exit`, losing the cleanup record.
- Closure: condition the `wait` on the child being gone (`[ -n "$m" ]` → synthetic rc 137 in T0; `CLEANUP_FAILURES` branch → skip `wait` in setup).

### V8B-03 — Leaderless confirmed-group survivors are censused but never signalled (MEDIUM, material; regression in reach vs V7/v1)
- Block L25 only lists `pgrep -g` members; `own_signal` (L16) prints `gone` and sends nothing once the leader has been reaped. T0 L119 therefore does `own_signal … TERM`/`KILL` → "gone" → no signal, so surviving group members after Jest exits are only reported. V7 L93 and the deleted `reap_owned` (diff L67) sent `kill -TERM/-KILL -- -$pg` to the group. Setup keeps the real group kill on the normal path (`reap_group` L141) but `on_signal` L96 now uses `own_reap_all` only, so after a runner signal leaderless npm descendants are counted (L87 → `CLEANUP_FAILURES`) and left running.
- Safety of the fix: a pgid cannot be recycled while any member remains in the group, and members of a confirmed own-session group have sid==pg; signalling `-pg` after verifying `ps -o sid=` of the listed members equals `pg` never reaches the caller group or a foreign lane.
- Closure: in the group loop of `own_reap_all` (and T0 L119): for members whose sid==pg, TERM → bounded wait → KILL → bounded wait, then report survivors. Add a control case: leader exits leaving a member (`( exec setsid bash -c 'sleep 20 & exec sleep 0.3' ) &`).

### V8B-04 — Group census counts the caller's own unreaped zombies as survivors (MEDIUM, material for evidence truth)
- Block L25 (`pgrep -g`, no `-r` run-state filter, no `own_alive` filter) and setup L87. Whenever `own_reap_all` runs before the caller has `wait`ed — T0 `on_exit` entered from the TERM/INT/HUP trap during `run_gate` (L91–92); setup `on_signal` L96 followed by `final_accounting` L87; fixture L38 before its `wait` at L39 — the killed leader is a zombie child of the caller and remains a member of its group. procps 4.0.4 `pgrep` matches every run state unless `-r` is given (the host is minimized and has no man page; this is stated as a behaviour dependency, deterministically checkable by the control below). Effect: `GROUP_SURVIVORS` → rc 1 → T0 `surv=1`, root retained, "survivors" logged; setup `CLEANUP_FAILURES++`. Not a safety hazard, but it breaks "truthful primary/cleanup exits".
- The current controls would pass silently: C2v8/C3v8/C4v8 assert `REAPED … how=group` but never the fixture's recorded `reap_rc`. Adding `grep -q 'reap_rc=0'` to those checks confirms or refutes this finding at zero cost.
- Closure: filter census members through `own_alive` (or reap known-dead pids with `wait -n`/`wait pid` before the census).

### V8B-05 — One command-boundary interruption window remains between `&` and `own_register` (LOW likelihood; material by the scope's absolute wording; trivial closure)
- T0 L111→L112, setup L129→L130, fixture L33: bash runs a pending trap between commands, so a TERM that arrives after the background spawn completes but before `pid=$!` runs the TERM trap with the child unregistered; `own_reap_all` then iterates an `OWN_PIDS` that lacks it. C1v8 (fixture L33–34) fires `kill -TERM $$` after `own_register`, so it exercises the registered window, not this boundary; the C1v8 "deterministic" wording should say so.
- Closure: iterate `$OWN_PIDS ${!:-}` in `own_reap_all` (bash sets `$!` at spawn, before any trap can run), de-duplicated.

### Optional / non-material observations
- O-01 T0 `mktemp -d` at L90 precedes the TERM trap at L92 (a signal in between leaves the empty root); inherited from V7.
- O-02 OWNED_LAUNCH_SCOPE requires a publication-failure control; the milestone discloses none exists. For this primitive, publication is an in-memory append (L6), so the practical analogue is V8B-05 (registration not yet performed) — still no control.
- O-03 Controls exercise the primitive through a fixture only; the consumers' adapted lines (T0 L110–123, setup L129–141) have no control, which is why V8B-02 is invisible to them.
- O-04 Timing margin of the T0 slot is thin (§3); the "allowance, not attestation" wording is correct and should stay.

## 5. Controls (ctl-own-startup.sh b34db0d8 + sup-under-test.sh 9dc308ab) — discriminator safety

Checked line by line: grant gate (L10), pins for the block and fixture (L11–14), own hash logged (L30), canonical lock only `stat`ed (L31), fake `sleep` children only, per-case `timeout -k 3 15` (L25), admission `left > 18` under AGG 90 (L23), first-failure stop (L21), fixture cleanup by recorded pid only (L19, L39, L48), predecessor pattern reports and never fires a group signal (fixture L28–29). Expected checks: C0 1 + C1pred 4 + C1v8 3 + C2pred 1 + C2v8 3 + C2bv8 2 + C3v8 1 + C4v8 1 = 16, consistent with the builder's pass=16. Expected wall time ≈ 10–15 s. The `kill -TERM $$` interruption is deterministic for the window it targets (trap runs after the `kill` builtin returns). C2v8's decoy assertion depends on the first poll preceding the fixture's 1 s delayed `setsid`, which holds (first poll is immediate). Non-`--foreground` `timeout` places the fixture in `timeout`'s group; the decoy logic is self-relative and unaffected.

Verdict on the control set: discriminator-safe and grantable on the exact bytes as evidence for A-02 decoy/interruption closure; it does not discriminate V8B-01, -02, -03, -05 and would silently pass V8B-04. Recommended before or alongside the grant: assert `reap_rc=0` (exposes V8B-04) and add the leaderless-group case (exposes V8B-03).

## 6. Separated verdicts

- **R4 controls slot (Stage 1 control grantability):** GRANTABLE on b34db0d8 / 9dc308ab / cc8346cd — safe, bounded, no network/lock/install. Its PASS would evidence A-02's decoy and post-registration interruption closure only; it is not a clearance of T0 or setup.
- **R2' setup install (bca83158):** NOT GRANTABLE on V8 bytes. V8B-01 is most exposed here (≈20-minute run, pid_max 32768, false FINAL 90 or wrong-target group signal), plus V8B-02 and V8B-05.
- **T0 applicability (c226266e):** NOT GRANTABLE on V8 bytes. A-02 substantially closed; A-03 partially closed (V8B-02 open); V8B-01/-03/-04/-05 apply. Corrections are small and line-bound.
- **S6 consumers:** absent from this packet; NOT cleared; nothing here transfers to S6 adaptations.
- No product-clearance claim. Builder claims verified: manifest, embedded-block identity, diff reproduction, base provenance, 16-check count, bounds arithmetic. Builder claims not verified because unrun: any PASS.

## 7. One smallest next action

Builder freezes an own-block v9 (still byte-identical in both consumers) with: `ppid==$$` in the identity predicates plus `own_retire` after each successful `wait` (V8B-01); `wait` skipped when the identity-refused child survived KILL (V8B-02); own-session group TERM/KILL for leaderless members and `own_alive`-filtered census (V8B-03/-04); `${!:-}` included in `own_reap_all` (V8B-05); and two control additions (`reap_rc=0` assertion; leaderless-group case). Meanwhile the parent may grant the V8 R4 control run as safe evidence, explicitly not as T0/R2' clearance.
