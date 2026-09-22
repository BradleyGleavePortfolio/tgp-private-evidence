# OP88-S5-V8 — narrow T0 startup-identity/caller-group/deadline/cleanup successor (S5-V7-A-02/A-03) + additive setup successor (P88-S5-SETUP-01); PREPARATION ONLY

Worker `s5_selective_v7_fixer_mud58q6n`. Sole writes: `/home/user/workspace/execution/op88/s5-v8-t0`. V7 packet (`dd7f2eab…`), R1 results, restore packet, archives, worktree source: untouched. Static work only: reads, `sha256sum`, `diff`, `bash -n`, one `sed`-range block-identity check. **Nothing executed** (no controls, Jest, install, network, lock). All "expected" outcomes below are static readings.

## 0. Inputs
| Input | SHA256 |
|---|---|
| V7 T0-only driver (derivation base) `inputs/ctl-t0-only.v7.sh` | `a13d44a5ba5b1ec9097b7e5782bb057b4b9b46f96086a40ebdbb6db1e769da6a` |
| frozen setup-v1 (derivation base, preserved unchanged) `inputs/run-s5-setup-npm-ci.v1.sh` | `74736a5878fe4620adfb8dfe8f0a1c88e12b4f08a5313d3a52017e1deb8ebeaa` |
| `execution/op88/audits/s5-v7-a/AUDIT.json` (A-01 closed by the R1 grant; A-02 HIGH, A-03 MEDIUM for R2) | read in full |
| parent mail P88-S5-SETUP-01 (setup v1 L90–92 spawn→sleep 0.2→CUR_PGID; L57 on_signal skips reap when CUR_PGID empty) | **confirmed on the bytes**: L90 `setsid … &`, L91 `CUR_PID=$!; sleep 0.2; CUR_PGID=$(ps -o pgid= …)`, L57 `[ -n "$CUR_PGID" ] && reap_group …`; a pre-`setsid` sample returns the runner's own pgid (the runner is itself launched under `setsid nohup`, so that group contains the runner), and `reap_group`'s ownership check passes because the decoy was written into `OWNED_PGIDS`. Same root class as A-02. |

## 1. One minimal shared correction — `own-block-v8.sh` (`cc8346cd…ba9c`, 30 lines), embedded byte-identically in both successors (`verify-embedded-block.sh` → IDENTICAL ×2)
| Function | Closes | Behaviour |
|---|---|---|
| `own_register <pid>` | A-02 startup publication | called as the very next command after `&`; `OWN_PIDS` is the recovery list the EXIT/TERM path always reaps — no sleep precedes registration |
| `own_confirm <pid> [2 s]` | A-02 identity / caller-group decoy | 50 ms polls until `pgid==sid==pid` **and** `pgid != OWN_SELF_PGID`; only then the group joins `OWN_PGIDS`. rc 1 = gone before confirm, rc 2 = unconfirmed (never a group target); a self-group observation is recorded in `OWN_LAST_DECOY` |
| `own_signal <pid> <SIG>` | A-02 signal authority | re-confirms identity *at signal time*; group signal only to a confirmed own-session leader, else pid-only; prints `group|pid|gone` |
| `own_alive`, `own_wait_gone <pid> <s>` | A-03 | zombie-aware liveness; bounded 0.1 s polls — no blocking `wait` |
| `own_reap_all <grace>` | A-02/A-03 cleanup | TERM → bounded grace → KILL → 3 s bounded; `REAPED`/`SURVIVOR`/`GROUP_SURVIVORS` lines; rc 1 on any survivor |
| `own_budget <remaining> <want> <grace> <reserve>` | A-03 admission | `min(want, remaining − grace − reserve)`, floor 0 |
No new supervisor, daemon, lock, file protocol or framework: 9 shell functions, procps/coreutils only.

## 2. `controls-v8-t0/ctl-t0-only.v8.sh` (`c226266e…8e2b`) — delta vs V7 `controls-v7-to-v8-t0-only.diff` (`83d272df…`, 107 lines, +61/−15)
Added: 16 header lines; `RUN_RESERVE=10` on the bounds line; the OWN block (replacing `OWNED_PGIDS=""`); `on_exit` now calls `own_reap_all "$RUN_GRACE"` (old `reap_owned` removed); `run_gate` rewritten (16 lines): admission via `own_budget` (refuses with `AGGREGATE_BOUND_HIT` when admissible < 5 s), spawn line **unchanged**, `own_register` immediately after `&`, `own_confirm 2` → `identity=confirmed|exited-before-confirm|unconfirmed`, an unconfirmed child is TERM/KILLed pid-only and fails the new check **`T0.identity`** (stop), budget loop with `own_alive`, TERM→grace→KILL with bounded waits, `how=budget-KILL-unconfirmed` ⇒ synthetic `GATE_RC=137` **instead of an unconditional `wait`**, group census only for a confirmed group, `T0.owned` unchanged in meaning. Unchanged: all rc-2 gates (HEAD `143d451e`, fingerprint `6850b32e`, jest, identities, harness `2de5fe24`, config `a6eeb1cd`), control root, I0, predecessor spec via `git show`, `mut()`, `T0.defect`, `T0.refusal_reason`, lib `check`/`summary`. Header also corrects the "12 PASS = T1/T2" shorthand (nonblocking note 3).
Bounds: `RUN_BUDGET 90 + RUN_GRACE 10 + RUN_RESERVE 10 ≤ AGG_BOUND 120`; EXIT-trap reap ≤ 13 s ⇒ driver end-to-end ≤ ~135 s; outer `timeout --foreground -k 20 140` = nominal 160 s allowance (not a completion attestation). Expected positive: `I0.inputs`, `T0.identity`, `T0.owned`, `T0.defect`, `T0.refusal_reason`, `SUMMARY pass=5 fail=0`, rc 0, Jest rc ≠ 0 by design. Layout: needs `../controls-v3/{lib.sh,teardown-gate/*}` beside `controls-v8-t0/` at execution time (copy the byte-identical V7 `controls-v3/` — not duplicated here to keep V7 immutable and this packet small).

## 3. `controls-v8-t0/run-s5-setup-npm-ci.v8.sh` (`bca83158…4a91`) — additive successor of frozen 74736a58; delta `setup-v1-to-v8.diff` (`c18bbc31…`, 90 lines, +48/−7)
Added: 9 header lines; OWN block after L29; `final_accounting` gains a registered-pid census (alive ⇒ `CLEANUP_FAILURES++`); `on_signal` L57 → `own_reap_all 20` recorded into `EXIT_RECORD` (reaps even when `CUR_PGID` is empty); L91 → `own_register` + `own_confirm 2` + `IDENTITY` record, unconfirmed ⇒ pid-only TERM/KILL then `die startup-identity-unconfirmed 2` (FINAL 2, no install continues unowned); confirmed ⇒ `CUR_PGID=$CUR_PID; OWNED_PGIDS="$CUR_PGID"` (so the unchanged `reap_group` ownership check still applies); L93–98 → `own_alive` loop, `own_signal` TERM (group only if re-confirmed), bounded grace, KILL, 3 s bounded, `budget-KILL-unconfirmed` ⇒ `RC=137` + `CLEANUP_FAILURES++` instead of unconditional `wait`. Unchanged: every pin/gate (HEAD, lock blob, exact porcelain, fingerprint before/after), lock fd 9 held by runner and closed in the child (`9>&-`), `npm ci --ignore-scripts` line, ancestor gate, FIRST_EXIT/FINAL semantics, after-checks/identities, external `timeout -k 30 1290` (1200 budget + 30 grace + 2 confirm + ≤ 13 reap + checks + accounting fits the 90 s margin; allowance, not attestation). Original 74736a58 preserved in `inputs/` and in `s5-restore/setup-v1-frozen-copy/`.

## 4. Deterministic no-network child controls — `controls-v8-t0/ctl-own-startup.sh` (`b34db0d8…`) with fixture `sup-under-test.sh` (`9dc308ab…`); NOT executed
Fixture = a 40-line supervisor that sources the OWN block (mode `v8`) or reproduces the v1/v6 pattern (mode `pred`: `sleep 0.2` then `ps` pgid sample) around a FAKE `sleep` child; interruption is delivered deterministically by `kill -TERM $$` placed between spawn/registration and confirmation (bash runs the trap after the current command — no probabilistic sleeps). The `pred` fixture never fires a group signal (it only reports the target it *would* select).
| Case | Expected |
|---|---|
| C0.budget | `own_budget` 6→0, 30→10, 200→90, 25→5 |
| C1pred (pred, interrupt) | sup rc 143, trap saw `owned=[]`, fake child **survives** (A-02/SETUP-01 hole reproduced), then control cleans it by recorded pid |
| C1v8 (v8, interrupt) | sup rc 143, `REAPED pid=<child>` in trap record, child gone ≤ 3 s |
| C2pred (pred, decoy-delayed: child stays in caller group ~1 s then `setsid`) | `would_target_self=YES` — the 0.2 s sample selected the supervisor's own pgid |
| C2v8 (same child) | `confirm_rc=0`, decoy observed and refused, `REAPED … how=group`, sup rc 0 (not self-killed) |
| C2bv8 (child never leaves caller group) | `confirm_rc=2`, `identity-refused signal=pid`, sup rc 2, child gone |
| C3v8 (TERM-ignoring confirmed child) | `how=group+KILL:group`, gone within bound, sup rc 0 |
| C4v8 (plain) | `confirm_rc=0`, `REAPED … how=group` |
Bounds: each case `timeout -k 3 15`, aggregate 90 s admission, first failure stops with owned fixture cleanup by recorded pid (never by name); outer `timeout --foreground -k 10 120`. Requires `S5_CTL_GRANT=granted-by-parent`; pins own-block and fixture hashes (rc 2 otherwise); canonical lock path only `stat`ed. Expected `pass=16 fail=0`. C1pred/C2pred are intentionally failing-behaviour reproductions of the predecessor pattern, not repairs.

## 5. Truth, closure map, requests
- Implemented + `bash -n`: 5 scripts; block identity verified statically. Tested: nothing. Unrun: all controls, T0, setup.
- A-02 → source-closed by §1/§2 (identity publication, confirmation, caller-group exclusion, startup-window reap) — proven only when §4 controls run. A-03 → source-closed by admission budgeting + bounded waits/no unconditional `wait` + stated allowances. P88-S5-SETUP-01 → source-closed by §3 using the same block. A-01 → closed by the parent's R1 grant caller (R1 executed, `RAW_OUTER_EXIT=0`, 11/0).
- No architecture change was needed; no rescope requested. Residual (disclosed, not fixed): `pgrep -g` census for a confirmed group cannot see descendants that themselves called `setsid` (none expected under `--runInBand`/`npm ci`); Node's own child processes under `npm ci` are in the confirmed group and receive the group signal as before.
- Requests (none granted here): **R3** independent narrow review of `own-block-v8.sh`, both diffs, and the controls; **R4** deterministic controls slot (`cd /home/user/workspace/execution/op88/s5-v8-t0 && S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 120 bash controls-v8-t0/ctl-own-startup.sh` with guarded raw-status capture as in the R1 grant; no Jest/install/network/lock); **R2'** (still HELD) fresh setup via `run-s5-setup-npm-ci.v8.sh` from the restored worktree (fingerprint now `6850b32e` after receipt-1), then `ctl-t0-only.v8.sh`; both only after R3/R4 and the parent's setup review.
- Success does not prove: a green V6 wave, DB behaviour, live 51-case run, hooks/commit, final attestations.
- Smallest next action: parent assigns R3; on closure grants R4 alone (fake-child controls, no dependencies) before any setup.
