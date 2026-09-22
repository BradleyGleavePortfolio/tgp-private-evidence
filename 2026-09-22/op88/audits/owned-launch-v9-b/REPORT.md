# OP88-OWNED-LAUNCH-V9-B — independent T4 non-builder review of the FINAL V9 candidate (s5-v9-t0 + closure-1 addendum)

- Reviewer: independent auditor B (canonical "Claude Fable 5" reviewer label; actual model setting unexposed, not asserted). Non-builder. Read/hash/diff only.
- Parent thread: e9bd7cce-d7f3-4f33-b3c3-e2b7adbe9038 (mail priority high).
- Peer isolation: `execution/op88/audits/owned-launch-v9-a` NOT read. Both frozen V8 audits were read as instructed (A: `owned-launch-v8-a/AUDIT.json` 1fe174c9…, manifest 9f54e9d7…; B: my own frozen `owned-launch-v8-b`, manifest b22a6140…). S6 narrow review `audits/s6-c6-b/S6_C6_REVIEW_B.md` 5196e231… read for Part B only.
- Operations: `cat`/`sed`/`rg`/`grep`/`sha256sum`/`cmp`/`diff -u`/`ls`, plus one read of `/proc/sys/kernel/pid_max` (32768). No packet script executed, no `bash -n`, no live-process probe, no lock/install/network, no source edit. Former outputs untouched.
- Frozen at (actual UTC clock): value in `FINDINGS.json.frozen_at`, taken immediately before hashing.

## 1. Exact inputs (all verified by me)

`execution/op88/s5-v9-t0/SHA256SUMS.s5-v9-t0` = `36f04f84a08192f7d9e7ad4358dcb453a0243b4ee8f8ae0aab989e94f3e188c3`, 18 entries, `sha256sum -c` 18/18 OK, non-self-including. Addendum manifest `s5-v9-t0-closure-1/SHA256SUMS.closure-1` = `345c1b7f…` → `FINAL_CLOSURE_ADDENDUM.md` d66b23c1… OK.

| file | sha256 |
|---|---|
| own-block-v9.sh (66 lines) | 9d713d2cc50dcb33500bc13df5d737c1b9a0c6e2b7845113e244c50ab89ae82d |
| controls-v9-t0/ctl-t0-only.v9.sh | 38f8ec0169f223f5bce3cb8b61d57ab9c2dc92bf04b09870ffed937451d3e973 |
| controls-v9-t0/run-s5-setup-npm-ci.v9.sh | da5228c20347b164e90a3adbd5bf69afe52190d9363d0119168c01f5e243b41c |
| controls-v9-t0/ctl-own-launch.v9.sh | f1f8182cd37f7985412bdb255155febc3b146b29ad9b4504e7597d08905ac1eb |
| controls-v9-t0/sup-under-test.v9.sh | b9d3383367d2f4325566bd1374fe5038f8cc00a87d0a53a4bc3d60d6844d98e4 |
| own-block-v8-to-v9.diff / controls-v8-to-v9-t0-only.diff / controls-v7-to-v9-t0-only.diff | 3c3774f6… / 30be702f… / f05091f9… |
| setup-v8-to-v9.diff / setup-v1-to-v9.diff | 8552ac13… / dc304682… |
| inputs/ (v7 T0 a13d44a5, v8 T0 c226266e, v8 block cc8346cd, setup v1 74736a58, setup v8 bca83158) | as manifest |
| SUMMARY.json / V9_OWNED_LAUNCH_REQUEST.md / verify-embedded-block.sh | 519b0484… / 547655a7… / c2bff689… |
| OWNED_LAUNCH_SCOPE.md (current, with V9 ruling) | 3c7d8181aab62575f63e6f77d7dc1f13eb6f2011f0c295cc285c868a1809db26 |
| s5-v7/controls-v3/lib.sh (T0 `check`/`log`/`summary` dependency) | a08b762b89f50ef0d272da817b08290e07df326a85ea6759afda7baa0394bed2 |

Reproduced independently: embedded OWN-BLOCK v9 `cmp`-identical in T0 (L60–125) and setup (L46–111) to `own-block-v9.sh`; all five packet diffs regenerate byte-for-byte from `inputs/` bases with `diff -u` (header timestamps excepted); inputs bases equal the frozen V7/V8 hashes. `control-results/` exists and is writable.

Implemented / tested / unrun truth: everything is implemented and hash-bound; NOTHING has been executed by anyone; 15 control checks unrun; both consumers unrun. `bash -n` (builder-claimed) cannot detect any finding below.

## 2. What V9 changes (line-bound, own-block-v9.sh)

L15 `OWN_GATE`: child-side gate `bash -c "$OWN_GATE" own-gate <attempt> <parent> <workload…>` polls ≤ 100×50 ms for `<attempt>/ADOPT` == "`$$` `<attempt basename>`", exits 76 if parent gone, 75 if never adopted, then `exec "$@"`. L16–17 stamp/precondition (`set -m` refused). L18 fresh `mktemp -d` attempt path. L19–20 phase markers. L21 `own_is_child` (ppid==$$) guards L23 `own_alive`, L29 `own_confirm`, L39 `own_signal`. L24–26 `own_pending` (`$!` only in phase `spawning`, not registered/retired, live direct child). L33–37 `own_adopt` tmp→`mv`→readback with named failures. L41–51 session-based descendant authority (`ps -eo pid=,sid=,stat=` members, zombies excluded; pgid-foreign refusal; per-pgid verified group signal). L52–53 `own_finish`: `wait` only when not alive, prints `observed <rc>`/`unobserved`. L55–57 `own_retire`. L58–64 `own_reap_all` = registered+pending pids, then confirmed groups independent of leader liveness.

Launch shape (all sites): a forked non-leader `exec setsid bash -c "$OWN_GATE" …`, so `$!` is the session leader, the gate's `$$`, the eventual workload pid, and a direct child (ppid==$$) — the identity/adoption predicates are satisfiable and correct; jest/npm argv and env are preserved (T0 L162–163, setup L178).

## 3. Material findings on the frozen V9 bytes

### V9B-01 — T0 driver installs NO trap: `on_exit` is dead code; interruption closure, EXIT reap and FINAL-90 propagation do not exist (HIGH, material)
- V8 L92 `trap on_exit EXIT; trap 'log SIGNAL; exit 143' TERM INT HUP` was deleted (controls-v8-to-v9-t0-only.diff L117, hunk `@@ -88,8 +135,12 @@`) and never re-added; `grep -n 'trap '` on ctl-t0-only.v9.sh matches only header comments; `controls-v3/lib.sh` installs none (its `check` comment relies on "the EXIT trap"). `on_exit` (L139–143) is defined and unreachable.
- Counterexamples on supported paths: (a) outer `timeout --foreground -k 20 140` fires → default TERM kills the driver instantly; the adopted Jest session (its gate checks parent liveness only before `exec`, L15) keeps running, unowned — the exact class A-01/V8B-05 addressed, now spanning the whole run. (b) `check` first-failure `exit 1` (lib.sh L24–31) with `.owned` survivors → no reap, no `FINAL rc=90`, no control-root decision. (c) Normal completion → `summary` return code is the process exit; `cleanup_rc`, `CONTROL_ROOT_RETAINED`/`rm -rf "$CR"` and `AGGREGATE_ELAPSED` never happen.
- The addendum's row "T0: reap rc/survivors force FINAL rc 90" and the header L5–7 are false as frozen. Controls cannot see it (they exercise the primitive through the fixture, not this consumer).
- Closure: reinstate `trap on_exit EXIT; trap 'log SIGNAL; exit 143' TERM INT HUP` immediately after L143 (before L144, still before any child).

### V9B-02 — `own_finish` runs `wait` inside `$(…)` at every call site: it can never observe the child's exit; the "observed <rc>" value is fabricated and the parent never reaps (HIGH, material)
- Block L53 `wait "$1"` is the only `wait` in each consumer (addendum confirms). Every caller uses command substitution: T0 L172 `fin=$(own_finish "$pid")`; setup L184 and L192 `FIN=$(own_finish "$CUR_PID")`; fixture L40/L48/L50; control driver L34. A `$(…)` runs in a forked subshell that is not the child's parent; `waitpid(2)` from a non-parent fails with ECHILD, so bash's `wait` returns immediately with a status that is not the child's (127 "not a child of this shell" when the job record is absent, or bash's placeholder when waitpid reports ECHILD) and the real parent never reaps the zombie.
- Consequences: setup L192 `RC=${FIN#* }` is never npm's status → L199 `die npm-ci "$RC"` (rc 127) or a false rc 0 — either a guaranteed false FINAL on a successful install or a fail-open acceptance of a failed one; T0 L172 `GATE_RC`/`raw=` is not Jest's status while `.adoption`/`.owned` still PASS (`observed` prefix present) — untruthful raw exit under a passing check; fixture "finish raw=observed N" lines never carry the real N. The controls WOULD stop deterministically at C1 (`SUP_RC` must be 0 and comes from the same construct) or, if bash yields 0, at C3 (`raw=observed 75`) — so the builder's "expected pass=15" is statically false.
- This is A-04's "report raw observed exit separately" and the scope's "truthful primary … exits" unmet, replacing an unconditional wait by an impossible one. Closure: make `own_finish` return through a variable in the calling shell (`OWN_FIN="observed $rc"`; callers `own_finish "$pid"; fin=$OWN_FIN`), never through `$(…)`; keep `own_reap_all` (no `wait` inside) as is.

### V9B-03 — setup stamp is written and then truncated away (MEDIUM, material for evidence)
- L148 appends `OWN_STAMP` to `$EXIT_RECORD` with `>>`; L149 then creates the record with `>` (`echo "$(ts) START …" > "$EXIT_RECORD"`), discarding the stamp. S6-B Part B requires the mode/tool stamp as recorded evidence; `own_precondition` still refuses `set -m`, so safety holds, but the addendum's "stamp recorded first" is false for the setup. Closure: write L148 after L149, or make L149 `>>`.

### V9B-04 — setup's checked publication-failure branch abandons an already-released install (MEDIUM, material)
- L180 publishes ADOPT (workload release) before L181–182 record the identity; if the L182 `echo … >> "$EXIT_RECORD"` fails the script does `exit 74` directly: no `own_signal`/`own_reap_all`, no `quarantine`, EXIT trap `final_accounting` only censuses. The gate may already have exec'd `npm ci` (fd 9 closed), the runner exits and releases the lease, and the install continues unowned — the A-03/A-05 consequence on an explicitly coded branch. Closure: route L182 failure through reap + `quarantine` + `finish 74` (same as L184–185).

### V9B-05 — a member that exits between the `pgrep` and `ps` samples is classified "foreign" (rc 2) and the group is skipped with rc 0 (LOW–MEDIUM, material direction)
- L43: `ps -o stat=` empty (gone) is not `Z`, then `ps -o sid=` empty ≠ `$1` → `return 2`. In `own_reap_all` L62 rc 2 prints `GROUP_FOREIGN` and `continue`s without setting `rc=1`; in setup L196 rc 2 → `CE=0`, no quarantine, then L197 retires authority. A live TERM-ignoring descendant coexisting with one naturally exiting sibling at that instant is left unreaped with a clean status (fail-open). The mirrored race in `own_group_signal` L49 (`ok=0`) only under-signals one round (fail-closed). Closure: treat empty `ps` output as "gone/continue", and reserve rc 2 for a member whose sid is present and ≠ `$1`.

## 4. Closure map (A-01..06, V8B-01..05, S6-B Part B) on V9 bytes

| item | primitive | T0 consumer | setup consumer | controls |
|---|---|---|---|---|
| A-01 workload after checked adoption; pre-register window | CLOSED (L15 gate, L24–26 pending) | NOT CLOSED — no trap (V9B-01) | CLOSED except V9B-04 branch | C3/C4/C5/C8/C9 discriminate |
| A-02 / V8B-01 recycled/retired ids | CLOSED (L21 ppid, L55–57 retire, retired skipped) | CLOSED (L175) | CLOSED (L184, L197) | C10/C13 |
| A-03 / V8B-03 leader-exit descendants; setup lease | CLOSED in design (L41–51), qualified by V9B-05 | EXIT path void (V9B-01); in-line L173 OK | CLOSED (L195–197, quarantine) | C11 |
| A-04 / V8B-02 unconditional wait | no blocking wait remains — but the wait is impossible (V9B-02) | raw exit fabricated | RC fabricated → wrong FINAL | fails at C1/C3 |
| A-05 publication/cleanup govern exit | named outcomes L33–37 | FINAL 90 never emitted (V9B-01) | quarantine ✓; L182 exception (V9B-04) | C5 |
| A-06 controls cancellation-safe/discriminators | — | — | — | enclosure via primitive ✓; expected pass=15 false (V9B-02) |
| V8B-04 zombie census | CLOSED (L41, L43) | — | — | reap_rc=0 asserted ×8 |
| V8B-05 `&`→register | CLOSED (phase-bound `$!`) | ✓ | ✓ | C8 |
| S6-B Part B R3 stamp/refuse, (c), (d) | CLOSED | stamp logged L126 ✓ | stamp lost (V9B-03) | — |

Prior V7 items: S5-V7-A-02/P88-S5-SETUP-01 closed at source in the primitive; S5-V7-A-03 bounds remain an allowance (see O-02).

## 5. Controls (ctl-own-launch.v9.sh f1f8182c + sup-under-test.v9.sh b9d33833) — determinism and safety

Safe: grant gate L10, hash pins L11–14, fake `sleep` workloads only, per-fixture `timeout -k 3 20` inside an enclosure launched through the primitive (L29–36), EXIT/TERM traps L24, fixture grandchildren never signalled by bare number (L20, fail-closed rc 90), lock path only `stat`ed (L43), admission L27 (needs ≥ 33 s left of 170), expected wall ≈ 55–70 s ≪ 200 s outer. Seams are deterministic: `kill -TERM $$` after `&` inside `spawn` (C8 hits the `&`→`$!` boundary), after register (C9), pre-spawn with stale `$!` (C10); stale/write-fail configured before spawn (C4/C5); gate expiry 5 s vs fixture wait 7 s (C3/C4/C5); delayed setsid 1 s vs ≥ 2 s confirm window (C7). C11's regex matches `own_reap_all` L63–64 output exactly; C6's decoy value is the fixture's own pgid from `sup.pid_pgid`.

Not discriminating / qualified: every case's `SUP_RC` and every `raw=observed` assertion depends on the broken `own_finish` (V9B-02) → the run stops at C1 (or C3); consumer-only defects V9B-01/03/04 are invisible by construction; C5's `! ran` cannot fail because the attempt dir is `a-w` (assert `raw=observed 75` instead); `finish_ctl` L20 checks `GRAND`, which lacks the in-flight case's child on mid-case cancellation (O-03).

## 6. Optional / non-material
- O-01 `ps -eo pid=,sid=,stat=` (L41): procps documents that `-o a=X,b=Y` header parsing varies with personality; under the default Linux personality it yields three columns, but `-o pid= -o sid= -o stat=` removes the dependency.
- O-02 Bounds: setup `on_signal` worst case = 20+3 (pids) + 20+3 (groups) = 46 s > the 30 s kill margin of `timeout -k 30 1290` (header says "≤ 13 reap"); T0 EXIT reap worst case (once the trap exists) = 10+3+10+3 = 26 s, so ≈ 118 + 26 s can exceed the 140 s nominal — correctly labelled allowance, not attestation, but the "≤ 13" figures should be corrected.
- O-03 Control driver: add the current `$REC/child.pid` to the survivor check on cancellation.
- O-04 T0 `mktemp` before the (missing) trap; inherited.
- O-05 `own_alive`/`own_is_child` treat a failed/empty `ps` as "not our child": under fork failure the reaper silently skips a live child; reading `/proc/<pid>/stat` (fields 3–4) needs no fork. Hardening, not a supported-path counterexample.

## 7. Separated verdicts
- **R6 fake-child control slot (f1f8182c / b9d33833 / 9d713d2c):** discriminator-SAFE to run (no lock/network/install; enclosure cancellation-safe), but NOT worth spending on these bytes: static analysis says it stops at C1 or C3 because of V9B-02, proving only that defect. Grant only if the parent wants that empirical confirmation; otherwise after the V10 fix.
- **T0 applicability (38f8ec01):** NOT GRANTABLE — V9B-01 (no trap at all) and V9B-02 (fabricated raw exit under passing checks).
- **Fresh setup / R2' (da5228c2):** NOT GRANTABLE — V9B-02 (FINAL always wrong), V9B-03, V9B-04.
- **S6 consumers:** absent from the packet; NOT cleared; nothing transfers.
- No product, install, DB, T0-outcome or release claim. Builder claims verified: manifests, embedded identity ×2, all five diffs, base provenance, 15-check count, bounds arithmetic. Claims refuted: "expected pass=15", "T0 FINAL rc 90 fail-closed", "stamp recorded first (setup)", "no `wait` on unconfirmed termination → truthful raw exit".

## 8. One smallest next action
Builder issues V10 (byte-identical block ×2) with: `own_finish` returning via `OWN_FIN` and all seven call sites changed to top-level calls (V9B-02); the T0 trap line restored after L143 (V9B-01); setup stamp after record creation (V9B-03); L182 failure → reap + quarantine + finish 74 (V9B-04); `own_group_current`/`own_group_signal` treating empty `ps` as gone (V9B-05); C5 asserting `raw=observed 75`; corrected bound figures. Then two exact re-reviews, then R6.
