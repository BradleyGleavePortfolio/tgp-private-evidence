# S5 setup-exclusion V32 private controls — request (T4 static candidate; NOT EXECUTED by the builder)

Builder: `repair_s5_binding_mue9vjso`. Successor of frozen `s5-setup-v31-controls-v2` (manifest `7d4a150d…`, driver `ctl-v31.v2.sh` `f34769c3…`, fake `4e7858a2…`). Requires a separate single private grant after two independent reviews of these exact bytes and of the v32 source packet.

## Candidate files

| file | sha256 | delta |
|---|---|---|
| `ctl-v32.sh` | see `SHA256SUMS.s5-setup-v32-controls` | `diffs/ctl-v31v2-to-v32.diff` (+34/-7) |
| `fake-runner.v32.sh` | see manifest | `diffs/fake-v31-to-v32.diff` (+4/-2): `start_line` publishes `token=${S5_LEASE_INHERITED:-none}` after `ppid=` (mirrors runner v101y L210) |

Pins inside the driver: `PIN_L=55acc00fe9b04d0e015f37bbdac90e582925c4b4564f7aaaa55c21a13304cf0a` (launcher v3.2), default launcher path `../s5-setup-exclusion-v32/launch-s5-setup-exclusion.v32.sh`.

## Exactly three additive driver changes (10 predecessor `check` statements byte-identical; P2's token-bound wait L~106 retained)

1. **V31-B-01** (`audits/s5-v31-b`): before `check P1.inner_live_hold`, `wait_text launcher.EXIT_RECORD "HEARTBEAT state=SELF-HOLD census=live detail=\[$P:empty $SP:live\]" 5` — acknowledges the line the unchanged conjunction reads (the launcher appends it only after a full `session_state`; `wait_state SELF-HOLD` + `reason=` do not imply it exists yet). On timeout a note is logged and the unchanged predicate is evaluated and fails on its own terms (no weakening, no reordering).
2. **O-B-01** (`audits/s5-v2-result-b`): `check()` calls `diag "$1"` on FAIL only, before `STOP_ON_FIRST_FAILURE`. `diag` writes `$OUT/FAIL.<check>.diag`: stamp, `EXD`, `LPID`, launcher liveness (`kill -0`), private-lock state, driver scalars (`RC SH SP P TOK RR STALE SEED3c HELD ST3`, `/proc/$SP` presence), and `ls -ld` + sha256 + `cat` (regular files only — never a FIFO) of `LEASE_HOLDER LEASE_RELEASE SELF_HOLD SUB_READY LEASE_HOLDER.at-running LEASE_RELEASE.first-receipt P2.holder-update-attempt.txt P3c.seed.sha256 logs/setup-exclusion/launcher.EXIT_RECORD logs/setup-exclusion/SELF_HOLD logs/setup-v1/setup.EXIT_RECORD`, every `prior/*` file, and `ls -la attempts/`. Observation only, tools already used by the driver (`date ls cat sha256sum kill -0 grep flock`), no signals, writes only under `$OUT`. Limitation (nonclaim): snapshot is taken **after** the conjunction evaluated (milliseconds; records may have advanced by up to one heartbeat, their stamps show it); it is not an inline per-operand evaluation.
3. **S5-V31-A-01 negative, case P3c** (between P3a and P3b; P3b stays LAST): PATH shim `setsid` that, like P3a, creates no session (decoy -> adoption refused, runner never runs) and, being the process whose pid becomes the launcher's `SESSION`, seeds a STALE-shaped `setup.EXIT_RECORD` with `pgid=$$` (exactly this attempt's session number), the current UTC second as stamp (not before this holder's spawn) and token `STALE-TOKEN-P3c`, plus `IDENTITY … state=released`, `EXCLUSION_UNPRESERVED`, `CLEANUP_FAILURES=1`, `FINAL rc=90`; records its sha256 in `$EXD/P3c.seed.sha256`; `exec "$@"`. Check `P3c.same_number_not_before_spawn_stale_not_bound`: rc 90, `runner-not-released(never-released)-then-empty`, `runner=[exit_record=not-this-attempt]`, `raw=observed 143`, `inner=[none]`, record START has `pid=$P pgid=$P ppid=1 token=STALE-TOKEN-P3c` with `$P` from `RUNNER_LAUNCH`, START stamp not lexically before the holder's `LEASE_HELD` stamp, `confirm_rc=[23] adoption=not-attempted`, `setsid=[setsid SHIM-P3c`, no `released-but-no-IDENTITY`, no `SELF_HOLD`, record sha256 == seed, lock free. Counterfactual: v3.1's fallback (`pgid=$SESSION` and stamp ≥ `SPAWN_TS`) would have bound this record and imported `released=1` -> `released-but-no-IDENTITY` -> unknown SELF-HOLD; so the check discriminates v3.1 from v3.2.

Static expectation: 11 checks PASS, `ALL_CASES_DONE pass=11 fail=0`, ~76 s passing path (P3c adds ~6 s). Not evidence until executed under grant.

## Exact command (single private run, after grant)
```
cd <controls dir> && S5X_OUT=<fresh absolute noncanonical dir> S5_CTL_GRANT=granted-by-parent timeout --foreground -k 10 180 bash ctl-v32.sh
```
`<controls dir>` = the reviewed copy of this packet placed beside `s5-setup-exclusion-v32/` (default launcher path is relative; or set `S5X_LAUNCHER` to the reviewed v3.2 path — the pin refuses any other bytes). `S5X_OUT` must be absolute, fresh, outside both packets, resolved (no symlink into canonical trees); the driver refuses `execution/test-validation.lock` / `execution/s5-r4` substrings.

## Prerequisites (unchanged from v31 unless noted)
Non-root (P1 relies on `chmod a-rwx` being effective), interactive job control off, util-linux `setsid` (`--version`, real session creation for the driver's own launches), procps `ps`/`pgrep` (`ps -o pgid= / sid=`, `pgrep -g`), `flock`, `sha256sum`, bash ≥ 4 (candidate parsed with 5.3.9).

**`timeout` semantics genuinely relied on** (parent mail 3: the image's observed `timeout` is uutils 0.8.0 with `-k/--foreground`, NOT GNU; nothing here asserts GNU and no tool change is requested):
* Outer request bound: accepts `--foreground -k <dur> <dur> <cmd…>`; sends TERM at 180 s then KILL 10 s later; `--foreground` leaves the driver in the caller's foreground process group (the driver itself creates the launcher sessions with real `setsid`, so it does not depend on `timeout` signalling children).
* Inner bound on the spawn line (`timeout -k "$INNER_KILL" "$INNER_BOUND" bash "$RUNNER"`, within the gate's new session): must run the command as its child **without moving it to a different process group/session** (the fake's `pgid` must equal the outer `SESSION` — P3b's `pgid=$P` operand exposes any deviation as an unresolved holder that is reported, never killed: safe unknown hold) and must **propagate the child's exit status** (P3b `raw=observed 75`, `final_rc=75`). No reliance on `timeout` exit-code conventions 124/137 in any check.
* Bounded FIFO reads (unchanged from v31): P2 `timeout 10 cat "$FIFO" > P2.holder-update-attempt.txt` (L104) and `finish` `timeout 3 cat "$FIFO"` (L76) rely on `timeout <secs> <cmd>` terminating `cat` if the FIFO writer never arrives so the driver cannot block; the P2 predicate reads the file content and the release record, not `timeout`'s exit code. All other waits are `sleep 0.1` polls. No other `timeout` behaviour is assumed.
If any of these semantics does not hold for uutils 0.8.0 the failure mode is a FAIL with a `FAIL.<check>.diag` snapshot or a reported (never killed) holder — not a canonical-path effect.

## Ownership / non-effects
Writes only under `$S5X_OUT`. No network, installs, canonical lock, product edits, Git. Driver signal set: none beyond `kill -0` reads (the launcher signals only its own unadopted gate in P3a/P3c). STOP on first failure; an unresolved P3b holder is reported and left to the parent.
