# OP88-S6 owned-launch V10.1 consumer adaptation — findings map, consumer applicability, boundary map

Builder: sole T4 Fable builder S5/S6 (requested model Claude Fable 5 / High — a policy request, not an observable). Packet: `/home/user/workspace/execution/e8d546f9/s6-owned-launch-v101/` (sole writer). Source/syntax/hash/diff only: NOTHING in this packet has been executed (no consumer run, no control run, no probe, no lock, no network, no install, no worktree edit, no commit). Two child consumers, each requiring its own independent T4 review: **S6-C6-RUNNER-ADAPT** (`run-c6-hazard-v5-conly.v101.sh`) and **S6-SETUP-ADAPT** (`run-c5-setup-npm-ci.v101.sh`).

## 1. Exact inputs (read-only; copies under `inputs/`, hashes in `INPUTS.json`)
| Input | SHA256 | Role |
|---|---|---|
| `remediation/s6-diagnostic/execution-successor-3/v3/run-c5-setup-npm-ci.v3.sh` | `91fe0f1b1db951a3d41b34afba528bb2e3815ba89f0154b917aeb01d9b197bd1` | original S6 setup (adapted) |
| `op88/remediation/s6-c6-prep/c6/run-c6-hazard-v5-conly.sh` | `746e244d2eadde25142d13b88380c90079a552961a898bb31bb90b80e1f1c11b` | original C6 runner (adapted) |
| `s5-v101/own-block-v101.sh` | `4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5` | primitive, embedded UNCHANGED |
| `s5-v101/controls-v101-t0/run-s5-setup-npm-ci.v101.sh` | `5f94783b44850cce3a16fc9ba68b75b572aa4b8125bc6a2e63fd650b8af98087` | reviewed S5 setup consumer (semantics reference) |
| `s5-v101/controls-v101-t0/ctl-t0-only.v101.sh` | `51fb43b724ce1571a94c75f232651dc473804af85d75f4cfd9b5ef7e1406d62c` | reviewed S5 T0 consumer (`run_gate` reference for multi-step `run_owned`) |
| `s6-c6-prep/C6_SETUP_CORRECTION_REQUEST.md` / `C6_EXECUTION_REQUEST.md` | `149cb1c7…4090` / `6a9a16ad…fefc` | findings R1/R2/R3 and §4 shape; exact C6 invocation and cleanup-truth lines |
| `audits/s6-c6-b/S6_C6_REVIEW_B.md` | `5196e231cce48fb2c0d6dcd796cdea0eb532ed658ef116a1346164a76c590699` | Part B (a)–(d) + "stamp required" |
| `s6-c6-prep/c6/MANIFEST.c6.sha256`, `c6/launch-c6-observer.sh` | `34d3c358…976d`, `f140787a…8fe1` | frozen, NOT edited; referenced by the runner / launches the ORIGINAL runner |
| `s6-c6-prep/MANIFEST.sha256` (19 files) | `04d761f0421cfbdc99058bbbcf9c5ad4d420a76ae45b258c33c0ed0e925709a6` | verified 19/19 before adaptation |

Untouched by construction (hashes unchanged, not copied, not referenced by new bytes other than through the existing paths): hazard v5 `a91bb732…`, adapter `3796be8f…`, instrument `s6diag.main.js cf470101…`, `c6classify.js 2715cf11…`, Jest selection/argv, budgets, assertions, product head `d51a1910…`, base `a5933fd6…`.

## 2. Outputs and what changed
| Output | SHA256 | Diff |
|---|---|---|
| `run-c5-setup-npm-ci.v101.sh` (264 lines) | `8b1ae8c06a7484ca92d0b1ff93c22c933c824e372c308bbc58fea4764ef3dcf3` | `diffs/DIFF_setup_v3_91fe0f1b_to_v101.patch`; also `diffs/DIFF_s5setup_v101_REF_to_s6setup_v101.patch` (vs the reviewed S5 consumer: only S6 paths, S6 gates, S6 npm argv, S6 after-checks, header/comment wording, and the two `EXCLUSION_UNPRESERVED` stderr/label lines differ — mechanics identical) |
| `run-c6-hazard-v5-conly.v101.sh` (412 lines) | `2c9748a468cef65779365b153e7d691120e1472d3e390b8a55f30e71103628c9` | `diffs/DIFF_c6_runner_746e244d_to_v101.patch` |
| `verify-embedded-block.sh` | see MANIFEST | static block-identity check (run once here: OK for both; see `SYNTAX_CHECKS.txt`) |

### 2.1 Setup consumer hunks (new line numbers)
- L1–29 new header (lineage, closure map, boundary statement, invoke line with the new script path); L30–47 original v3 header retained; L48–56 vars **unchanged** (WT/EX/LOGS/LOCK, budgets, env, CPU).
- L58–166 OWN-BLOCK v10.1 embedded byte-identical (`verify-embedded-block.sh`).
- L168–171 `ts/rec/alive/ancestor_inventory` unchanged; legacy `reap_group` (v3 L36–43) **removed** (unused, replaced by primitive calls).
- L172–180 `final_accounting`: ancestor gate unchanged; the `for pg in $OWNED_PGIDS; pgrep -g` loop (v3 L49) replaced by `historical owned_pgids=[…] (evidence only)` + `own_collect` + `own_census` (CURRENT registry; any live/unknown ⇒ CLEANUP_FAILURES).
- L181–187 `HOLD_BOUND`/`quarantine()` added (S5 V10 bytes with S6 label `s6-setup-v101` and two extra lines: `echo EXCLUSION_UNPRESERVED >&2`, "known residual" label). See §5.
- L188–190 `finish`: FINAL write checked (rc 74 on failure) — S5 V9 semantics.
- L191–194 `on_signal`: `[ -n "$CUR_PGID" ] && reap_group` (v3 L57) replaced by `own_reap_all 20` + `own_collect` + `own_census` ⇒ quarantine on unresolved. FIRST_EXIT/finish 143 unchanged.
- L196–197 `die`: reap/collect/census/quarantine prefix when any ownership or a spawning phase exists; then the v3 bytes.
- L200–201 START record adds `runner_sha256=$(sha256sum "$0")`; `OWN_STAMP` written AFTER the START record creation; `own_precondition || die precondition-job-control-or-tools 2` BEFORE the lock.
- L202–221 lock, cwd, provenance block and the four gates: **unchanged v3 bytes** (HEAD `d51a1910…`, clean tree, node_modules absent, ancestor package.json absent).
- L223–248 install: v3 L85–98 replaced by the S5 V10.1 consumer sequence: `OWN_ROOT=$LOGS/attempts` → `own_attempt` → `own_spawn_begin` → `setsid bash -c "$OWN_GATE" own-gate "$ATT" $$ $CPU npm ci --no-audit --no-fund --loglevel=error --logs-dir=… --logs-max=10 … 9>&- &` (argv identical to v3 L86; the S5 `--ignore-scripts` is NOT carried over) → `own_register` → `own_confirm 2` → IDENTITY `own_record` → `own_adopt` → IDENTITY line (failure ⇒ released-then-cancelled ⇒ `die 74`) → refused ⇒ pid TERM/KILL, `own_finish`, `die startup-adoption-refused 2` (NO install ran) → budget poll via `own_alive` (2 s cadence unchanged) → budget TERM/KILL via `own_signal`/`own_wait_gone` → `own_finish` in THIS shell (unobserved ⇒ RC 137 + quarantine; subshell ⇒ RC 70) → EXIT `own_record` → group TERM/KILL via `own_group_signal`/`own_group_wait_empty` → typed `own_group_current` (live ⇒ CE=1 + quarantine; empty ⇒ CE=0; foreign ⇒ CE=0 recorded; unknown ⇒ CE=1 + quarantine) → `own_retire` only when CE=0 AND observed.
- L250–264 after-checks, strict 20-module `node -e` (byte-identical body), FIRST_EXIT/primary rc line, `finish 0`: **unchanged v3 bytes**.

### 2.2 C6 runner hunks (new line numbers)
- L1–35 new header; L36–111 original C6/V3.1/V3/V2 headers + vars **unchanged** (WT, C6, DIAG, IN, LOGS, LOCK, BUDGET=180, env incl. `EXPO_PUBLIC_FF_*`, `S6DIAG_WT`, CPU, TESTDIR, COPIES, `HAZARD_V5_SHA`, `ADAPTER_SHA`).
- L112 `EX=/home/user/workspace/execution/op88/s6-c6-prep` added (quarantine primary root only; no other use).
- L114–222 OWN-BLOCK v10.1 embedded byte-identical.
- L224–232 `ts/ancestor_inventory/alive/rec/elapsed/sha` unchanged; `reap_group` (orig L89–106) **removed**.
- L233–243 `copy_source`/`cleanup_copies` **unchanged** (hash-guarded `rm -f` of the two declared copies only; porcelain gate).
- L245–253 `final_accounting`: ancestor gate + `cleanup_copies` unchanged; `final owned pgid=… members=[…]` loop (orig L124–126) replaced by historical line + `own_collect` + `own_census`.
- L254–260 `HOLD_BOUND`/`quarantine()` added (label `s6-c6-runner-v101`); L261–265 `finish` FINAL write checked.
- L266–275 `on_signal`: `reap_group "$CUR_PGID" 10` (orig L137) replaced by `own_reap_all 10` + collect + census ⇒ quarantine; FIRST_EXIT/finish 143 unchanged (grace 10 as in the original).
- L279–280 `die`: reap/collect/census/quarantine prefix (grace 10), then the original bytes.
- L286–326 `run_owned`: budget-refusal check (orig L153–154) **unchanged**; orig L156–161 (`setsid "$@" &; sleep 0.2; ps -o pgid; fallback CUR_PGID=CUR_PID; OWNED_PGIDS+=`) replaced by attempt → `own_spawn_begin` → `setsid bash -c "$OWN_GATE" own-gate "$att" $$ "$@" > "$log" 2>&1 < /dev/null 9>&- &` → `own_register` → `own_confirm 2` → IDENTITY record → `own_adopt` → IDENTITY line → refused ⇒ `die "$step-startup-adoption-refused" 2` (NO workload ran); `CUR_PGID=$CUR_PID` only after release. Poll (1 s cadence, `own_alive`), budget TERM/KILL via `own_signal`/`own_wait_gone` (grace unchanged), `own_finish` in THIS shell (unobserved ⇒ RUN_RC 137 + quarantine), `first_exit` line (adds `raw=`), session TERM/KILL via `own_group_signal`/`own_group_wait_empty` (10 s + 3 s as the original 10 s + 1 s), typed census ⇒ `cleanup_exit=<ce> session=<empty|live|foreign|unknown> group_signal=…`, per-step `EXIT` record, `own_retire` only when ce=0 AND observed AND session=empty, M-1 `die "$step-cleanup-survivors" 90` **unchanged**.
- L327–335 `JEST_ARGS`/`jest_step` **unchanged** (Jest argv, setup/global files, summarizer).
- L338–340 START adds `runner_sha256`; `OWN_STAMP` + `own_precondition` (die rc 2) before the lock; L342–344 lock unchanged; L345 `OWN_ROOT=$LOGS/attempts` after the lock.
- L346–412 provenance, MANIFEST.c6 check (frozen packet, unchanged), strict module list, copies + fingerprint gates, selftest 15/5, C 90/20, checks, classifier, FIRST_EXIT, `finish "$RUN_RC"`: **unchanged original bytes**.

## 3. Finding closure map (source-level; unverified at runtime)
| Finding | Where it was | How the adapted consumer addresses it (both scripts unless noted) | Status |
|---|---|---|---|
| **R1** child lost on TERM in `& → sleep 0.2 → ps` window; `on_signal` guarded by `[ -n "$CUR_PGID" ]` | setup v3 L86–87/L57; runner L156–161/L137 | pid registered synchronously after `&` (`own_register`, setup L227 / runner L295); `on_signal` and `die` call `own_reap_all` (registered pids + phase-bound pending `$!` + every confirmed session), never `CUR_PGID`-dependent; there is no `sleep` before registration | implemented, unrun |
| **R2** sampled PGID may equal the caller's group ⇒ `kill -- -<runner pgid>` self-termination | setup L87 fallback; runner L159–160 | no ps-sampled number is ever used as a signal target: `own_confirm` requires pgid==sid==pid, direct child, `!= OWN_SELF_PGID` (decoy recorded); `CUR_PGID` is set to the CONFIRMED pid only after release; `own_group_signal` refuses self pgid/sid and foreign numbers; unconfirmed ⇒ never released ⇒ `die 2` | implemented, unrun |
| **R3** shell-mode (`set -m`) assumption; stamp required (C6B) | both, implicit | `OWN_STAMP` line (monitor mode, bash, setsid/timeout/ps versions) written to the EXIT_RECORD right after START; `own_precondition` refuses monitor mode or missing setsid/pgrep/ps ⇒ `die precondition-job-control-or-tools 2` before the lock (setup L201 / runner L340). The observer's LAUNCH_START stamp suggested by C6B is NOT added (observer not edited) — the runner-side stamp covers R3 evidence for the inner session | implemented, unrun |
| **Part B (a)** register-by-confirmation | — | `own_confirm` (pgid==pid, never == runner pgid) before any authority is used | implemented via primitive |
| **Part B (b)** single-pid TERM/KILL when only the pid is known | — | `own_signal` prints `pid` path when identity is not (re)confirmed; `own_reap_all` pid phase; refused-adoption branch signals the pid only | implemented via primitive |
| **Part B (c)** `${CUR_PID:-$!}` fallback for the `&`→`$!` gap | — | `own_pending` (phase-bound, direct-child-verified `$!` while `OWN_PHASE=spawning`) consumed by `own_reap_all` in `on_signal`/`die` | implemented via primitive |
| **Part B (d)** `wait` after reap to avoid zombie false-SURVIVOR | — | `own_finish` waits in THIS shell only after verified absence; `own_group_current`/`own_census` exclude `Z` members; `own_collect` collects exited leaders in the trap paths | implemented via primitive |
| C6B optional A-1 (classifier `destroyed` filter), A-2 (observer lock probe) | classifier / observer | **NOT mine; NOT touched** | out of scope |
| "Actual inner npm/Jest session must remain covered, not just the outer runner session" (mail 2) | — | the workload is the confirmed session leader (pgid==sid==pid) behind the gate; session census covers ALL process groups of that session (`own_session_members` by sid), so `npm ci` / Jest descendants that re-group are still covered; foreign numbers are never signalled | implemented, unrun |

## 4. S5 semantics applicability — explicit, NOT inherited clearance
- The parent accepted the V10.1 PRIVATE diagnostic (RESULT manifest `8e16701b…`, 25/25 PASS, `S5_V101_CONTROL_DISPOSITION.md`) for the PRIMITIVE and the S5 consumers under the S5 fixture. That acceptance is **not** transferred to these two S6 consumers: they have no control run, no diagnostic, no runtime evidence of any kind. Every row in §3 is "implemented in source, unrun".
- Applicability argument (for reviewers, per item): (i) the primitive is byte-identical (verifier); (ii) the setup consumer is line-for-line the reviewed S5 setup consumer with only S6 pins/paths/argv/gates/after-checks substituted (`diffs/DIFF_s5setup_v101_REF_to_s6setup_v101.patch` shows exactly those lines); (iii) the runner's `run_owned` follows the reviewed S5 T0 `run_gate` sequence (attempt → spawn_begin → gate spawn → register → confirm → IDENTITY → adopt → START-line latch → refused branch → poll → budget TERM/KILL → own_finish → typed session census → EXIT record → conditional retire) with the C6 additions that were already in the original runner (budget refusal, M-1 die on survivors, `RUN_RC`/`RUN_HOW` outputs) — but it is a NEW function body and is the item most in need of independent reading.
- Consumer-specific facts that differ from S5 and must be reviewed on their own: multi-step (selftest, C) attempts under one `OWN_ROOT`; `jest_step`'s env-prefix call of `run_owned` (unchanged from the original) passes `S6DIAG_*` through the gate child to the exec'd Jest; the gate adds `bash -c … exec taskset -c 0,1 node …` in front of the workload (same pid: `exec`); C6's inner `BUDGET=180` admission check is unchanged and does not account for confirm (≤2 s) + gate (≤5 s) + session escalation (≤13 s + 3 s) per step — nominal worst-case arithmetic: preflight ≈5 s + selftest ≤(5+15+5+3+13+3)=44 s ⇒ remaining ≥131 s ≥ needed 115 s for C; C worst ≤(5+90+20+3+13+3)=134 s ⇒ ≈183 s + accounting < external 240 s. Not a completion attestation.
- The setup-exclusion v2 packet (`s5-setup-exclusion-v2/`, frozen; A review `fa876aa6` with two canonical residuals; S5 V3 repairs assigned to a different builder in `s5-setup-exclusion-v3/`) is **not** used, referenced or inherited here. No launcher/observer/wrapper is built.

## 5. Consumer-specific LAST-EXCLUSION boundary — explicitly mapped, NOT claimed safe
Both consumers copy the reviewed S5 V10 `quarantine()`: marker publication is checked (`own_record`, primary `$EX/QUARANTINE`, fallback `$LOGS/QUARANTINE`); on `failed` with unresolved ownership the runner holds fd 9 polling the census for `HOLD_BOUND` (60 s), then exits FINAL 90 with `EXCLUSION_UNPRESERVED` in the record and on stderr.
- **What this branch does NOT do:** it releases the lease (`flock` fd 9 closes at exit) while owned work may still be alive/unknown. This is the known-unsafe residual of the S5 setup consumer class that the parent forbade me to "copy and claim safe". I copied it (accepted, reviewed bytes; no new architecture) and I **do not claim it safe**: it is reported as the open boundary of both S6 consumers.
- **Why not changed here:** any consumer-internal alternative (unbounded hold, hold until census resolves) is bounded anyway by the frozen external `timeout -k 30 240` (runner) / `timeout -k 30 1290` (setup), which KILLs the holder and releases the lease identically; a real fix needs an outer holder that survives the runner (the setup-exclusion launcher class), which is (a) under separate review with canonical residuals, (b) assigned to a different builder, and (c) beyond "two consumer scripts". Per mail 4 / boundary notice I return a scope map instead of building a wrapper:
  - **Scope map for a wrapper reuse (NOT built):** S6-C6 would need a launcher that (1) takes and holds the canonical lock itself, (2) spawns the runner as an owned confirmed session WITHOUT the runner taking fd 9 (runner change: lock inherited or skipped — a consumer edit beyond this packet), (3) after the runner's FINAL/outer.exit, censuses the runner's session and retains the lock until positively empty, writing its own marker; the frozen observer `launch-c6-observer.sh` (f140787a) is the natural insertion point but is not mine to edit and has its own review items (A-2). For S6-SETUP the same launcher shape applies (no observer exists today). Deciding this is the parent's; if approved it is a NEW sole-writer scope.
- **Marker consumers:** no S6 precondition today checks `$EX/QUARANTINE` (neither the observer nor either consumer). The marker is evidence for the parent's manual grant gate only. Adding a refusal gate is a one-line consumer change I did NOT make (not in the accepted patterns; parent may direct it).
- **Two quarantine roots:** setup writes `execution/s6-diagnostic/QUARANTINE`; runner writes `execution/op88/s6-c6-prep/QUARANTINE` (fallbacks under each LOGS). Same worktree/lock; the parent must read both before any grant.

## 6. Evidence/record and path consequences (for the parent, not changes to frozen files)
1. `C6_EXECUTION_REQUEST.md` §5 cleanup-truth lines change for the adapted runner: `final owned pgid=… members=[]` is replaced by `historical owned_pgids=[…]`, `final COLLECTED/SESSION_RETIRED…` and `final census EMPTY_SESSION sid=… / RETIRED id=…` lines; per step the line is `cleanup_exit=<n> session=<typed> group_signal=…`; new lines `OWN_STAMP …`, `step=<s> IDENTITY …`, `first_exit … raw=…`. `FINAL rc=` semantics unchanged. Attempt evidence: `logs/c6/attempts/attempt-*/{IDENTITY,ADOPT,EXIT}`; setup: `logs/setup-v3/attempts/…`.
2. The frozen observer launches the ORIGINAL runner path; launching the adapted runner requires the parent (or the observer's owner) to re-point ONE path (`RUNNER=`) — not done here. The observer's refusal on existing `c6.EXIT_RECORD`/`outer.exit` still applies (same LOGS dir kept on purpose).
3. `MANIFEST.c6.sha256` (frozen) still verifies the frozen c6 packet including the ORIGINAL runner; the adapted runner is pinned by this packet's `MANIFEST.s6-owned-launch-v101` and by its own `runner_sha256=` START line. No frozen manifest was edited or regenerated.
4. LOGS paths kept identical to the originals (`execution/s6-diagnostic/logs/setup-v3`, `execution/op88/s6-c6-prep/logs/c6`) for minimal diff and observer compatibility; `execution/s6-diagnostic/logs` does not exist today (checked with `ls`), so no record would be overwritten by a first setup run; the START line still truncates `setup.EXIT_RECORD` (`>`), as in v3.
5. Both adapted scripts are executable-bit set in this packet; `bash -n` passes for both and for the verifier; `node --check` not applicable (no JS file touched; the `node -e` bodies are byte-identical to the originals — checked by extraction).

## 7. Truth table
| Item | State |
|---|---|
| Source adaptation of two consumers | implemented |
| Block identity (`verify-embedded-block.sh`) | run once here, OK (static) |
| `bash -n` both consumers + verifier | run once here, OK |
| Any execution of either consumer, any control, any probe | **not done; not permitted by this mail** |
| R1/R2/R3/Part B closure | source-level only; **unverified at runtime** |
| Exclusion boundary (§5) | **open; mapped; not solved** |
| Frozen artifacts (V10.1, setup-exclusion v2, s6-c6-prep, S6 setup v3, V3.1 runner, product) | untouched (hashes re-verified in `SYNTAX_CHECKS.txt`) |
| Requested model | Claude Fable 5 / High requested by policy; actual runtime model/settings not observable, not asserted |
