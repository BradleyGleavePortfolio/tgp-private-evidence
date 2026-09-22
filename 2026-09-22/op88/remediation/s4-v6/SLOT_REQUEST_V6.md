# S4 R6 V6 — slot request (Stage 1 private controls incl. fault controls, Stage 2 native validation)

Builder: OP88-S4-V6 canonical fixer (sole writer `execution/op88/s4-v6`). Basis: frozen V5 packet (manifest `73c2dbbe…`) + BOTH frozen
V5 reviews: A (`audits/s4-v5-a/AUDIT.json` `0adc4d6b…`) and B (`audits/s4-v5-b/FINDINGS.json` `430ae71d…`, `REPORT.md` `2bcf6cf5…`,
manifest `1bf4653c…`). Consolidated closure map: `FINDINGS_MAP.json`. Frozen after both reviews were incorporated (`SHA256SUMS`).

Truth: **implemented (manual edits) · hashed · diffed · syntax-checked. NOTHING EXECUTED.** No control, probe, lock, install, network,
DB or browser action. Stage 1/2 success later does not prove runtime, native gates, artifact/browser correctness, revocation or release.

## 1. Exact delta (V5 → V6) — `V5_TO_V6.diff`

| file | vs V5 | class |
|---|---|---|
| `runner/chrome-pipe-discriminator-v6.mjs` | byte-identical `c261ffb4…` | rename |
| `runner/s4-r6-lib-v6.sh` | +4 −3 | names/paths + 1 header line; latch/lock-attribution/seam bytes unchanged (checked: identical modulo v5→v6) |
| `runner/s4-r6-validate-v6.sh` | +13 −12 | names/paths + header; no step/pin/criterion/join change (downstream key `pipe_v5_sha256`→`pipe_v6_sha256`, B-10) |
| `controls/s4-r6-control-stub-v6.sh` | +25 −7 | names/paths + header; 4 fault-control scenario cases (B-06) |
| `launcher/s4-r6-launch-v6.sh` | +159 −67 | **A-03** standby holder, receipt-failure keeps holder (11), self-hold fallback (12); **A-05 lineage** census state; bounded re-parse; record fields; **B-06** CONTROL-only fault seams (`S4R6_FAULT`) |
| `controls/run-controls-v6.sh` | +202 −77 | **A-01/B-01** current-run binding; **A-02/B-03/B-04** once-budgeted cancel (+5 s slack, uncertain identity ⇒ UNRESOLVED); **A-04/B-02** success via `finish 0` + terminal receipt; **A-05** census UNKNOWN → 99; **B-06** fault controls + identity-checked `recover_holder`; live-holder judgement |
| `controls/control-predicates-v6.py` | +70 −10 | V6 formula; standby verified/released, census EMPTY mandatory; fault-control branches (exit 5/11/8 facts) |

Untouched: product `91990ae9…`/tree `840fb285…`; V4/V5 packets; all audit dirs.

## 2. Finding → change → exact discriminator (machine-readable: `FINDINGS_MAP.json`)

| ID | V6 change | Discriminator |
|---|---|---|
| **S4-V5-A-01** current-run identity | driver `resolve_active_run` binds `ACTIVE_RUN_DIR` by glob `CONTROL-V6-*-<launcher pid>-*` every poll second and inside `cancel_active`/`finish`; `RUN_IDENTITY` ∈ NONE/UNKNOWN_NO_SPAWN/BOUND; census targets the bound run's `OWNED_SID`; `LAST_RUN_DIR` is set only from the bound run | **current-first**: a TERM during control *n* yields `EXIT … run=<dir whose name contains the active launcher pid> identity=BOUND`; **next-run**: during control *n+1* the receipt names *n+1*'s dir, never *n*'s; **no-spawn**: `identity=UNKNOWN_NO_SPAWN` → code 99, never "empty" |
| **S4-V5-A-02** once-budgeted cancel | `CANCEL_SENT`/`CANCEL_DEADLINE` absolute; second `cancel_active` logs "re-entered … waiting only the remaining Ns" and never re-sends TERM; `run_bounded` resets per launcher; reserve 110 itemised (grace 6 + 77 + 10 + 8 + 5 + 3 = 109) | exactly one `CANCEL active launcher …` line per launcher; source has one `kill -TERM "$ACTIVE_PID"` and zero `kill -KILL "$ACTIVE_PID"`; unresolved receipt total wait = one allowance |
| **S4-V5-A-03** never release last verified exclusion | **standby holder** spawned+verified right after `flock` and before the runner (`spawn_holder`; failure → `STANDBY_HOLDER_FAILED 8`, nothing owned); on every non-quarantine exit released identity-checked (`release_standby_holder`) *after* the verified-EMPTY census; quarantine: re-verify holder → if lost ONE respawn → receipt tmp+mv; **receipt failure keeps the holder** (`QUARANTINED_RECEIPT_FAILED 11`); no verified holder at all → **SELF-HOLD** (launcher `exec -a <token>-SELF`, TERM/INT/HUP ignored, would-be 12, does not exit) | **creation failure**: exit 8, record `lease.standby_holder_verified=false`, no `OWNED_SID`, `runner.spawned_pid=null`, lease free afterwards; **publication failure**: exit 11, `QUARANTINE_LEASE_HOLDER` absent, record `lease.quarantine_ok=true, quarantine_receipt_ok=false, released_at_launcher_exit=false`, holder alive with cmdline token `s4r6-quarantine-holder-<RUN_ID>` and `readlink fd/9 == lease`; console line `UNSAFE HANDOFF … receipt_ok=false`; **self-hold**: launcher pid alive with cmdline starting `s4r6-quarantine-holder-<RUN_ID>-SELF`, driver 97 with `fd9=<lease> lease_held_by_it=true` |
| **S4-V5-A-04** terminal receipt | success path ends `finish 0 "all controls passed"`; `finish` re-runs census/lease/holder on the last bound run and downgrades 0 → 94/98/99/97 on contradiction; writes `control-runs/DRIVER-TERMINAL-<utc>-<pid>.txt` (write checked; failure on a 0 path → 90) then logs the identical `EXIT code=…` line | pass = raw outer exit 0 **and** `DRIVER-TERMINAL-*.txt` containing `EXIT code=0 … identity=BOUND leftovers_first='' (state=EMPTY) … private_lease_free=true quarantine_holder=''` |
| **S4-V5-A-05** census unknown ≠ empty | driver `census <sid>` keeps `PIPESTATUS[0]`: 0 MEMBERS / 1 EMPTY / else `UNKNOWN:<rc>`; `LEFT_FIRST*` set once per run (never overwritten by finalisation), `LEFT_FINAL*` separate; UNKNOWN → no reap, exit **99**; launcher `census` same states, `wait_session_empty` returns 0 only on EMPTY, `SURVIVORS_STATE != EMPTY` → quarantine; recorded `owned_session.census_state`; predicate requires `"EMPTY"` | driver log `census=UNKNOWN:124` + `EXIT code=99`; launcher record `census_state:"UNKNOWN:124"` with `overall` 5/11 (never TIMEOUT/SUCCESS) |
| **S4-V5-B-06** private fault injection before canonical first use | 4 CONTROL-only seams in the launcher (`has_fault`, gated `KIND==CONTROL` **and** `S4R6_FAULT`; inert in VALIDATION): `holder-unverifiable` (standby verification token never matches → 8), `census-members-persist` (after the runner has really exited, census keeps reporting deadline members → real quarantine code → 5), `receipt-unwritable` (receipt under a non-existent dir → 11, holder retained), `census-unknown` (census UNKNOWN:124 after runner exit → 5 with `census_state UNKNOWN:124`). Driver classes `quarantine`/`refusal`: verifies a LIVE identity-checked holder + lease held + real session EMPTY, then `recover_holder` (§6 rule, KILL only after pid+starttime+token+fd9 match) and verifies release | Stage 1 receipts of `fault-*` runs: launcher exits 8/5/11/5, `SUPERVISOR_RECORD.control_fault` = injected list, holder pid ≠ launcher pid, `quarantine_holder_token == s4r6-quarantine-holder-<RUN_ID>`; driver log `recover_holder: identity verified … KILL` then `private_lease_free=true`. Not exercised: SELF-HOLD (12) and standby-loss/respawn (stated) |
| **S4-V5-B-05 / V4-B-06** | FINDINGS_MAP row corrected: B-06 (control 5 cannot distinguish the launcher's hold from the stub's inherited fd 9) is the PRIOR NONBLOCKING discrimination qualification, not closed and not a budget item; stub unchanged (no `exec 9>&-`), no new consequence identified | — |
| A/B decision points | 91/70/95 labelled pre-spawn (no finish; nothing owned); 97 receipt records `readlink /proc/<pid>/fd/9` result; 98 uses `LEFT_FINAL` while the judged snapshot `LEFT_FIRST` is preserved; publication re-parse bounded by `READ_S`; `bounds.bound_qualification` string states what is/isn't enclosed; B-06 is NOT claimed closed | — |

Preserved (unchanged bytes or semantics): A-01 latch + seam (lib identical modulo names), mandatory parsed-record/step predicates, guarded
raw callers, launcher-owned lease attribution (`EXIT_RECORD.lock`), artifact joins/pins (runner identical modulo names/header), uutils
exit set, survivors-before-TIMEOUT precedence, setsid ownership, quoted-heredoc JSON writers (55/55 and 27/27 argv checked).

## 3. Fresh path mapping (all ABSENT now; restoration is a copy)

Restore `execution/op88/s4-v6/` → `/home/user/workspace/execution/s4-r6-validation/v6/` (driver `cd`s there and runs `sha256sum -c --quiet SHA256SUMS`;
mismatch → 91). Stage 1 writes only `…/v6/control-runs/` (private lease `…/v6/control-runs/.private-control-lease.lock`). Stage 2 additionally needs
`…/s4-r6-validation/runs/`, `worktrees/s4-r6` at `91990ae9…`, `execution/s4-r6/{predecessor-88287cff,probes}`, `execution/s4-r6-validation/tooling`,
canonical lock `execution/test-validation.lock`. Environment assumed, not probed: bash 5.3.9; rust-coreutils 0.8.0 (`timeout`, `sleep`, `sha256sum`,
`readlink`, …); util-linux 2.41.3 (`flock`, `setsid`); procps 4.0.4 (`pgrep` rc 1 = no match); python 3.14.3.

## 4. Stage 1 — private controls (after dual exact-V6 review and a separate grant)

```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash controls/run-controls-v6.sh; then rc=0; else rc=$?; fi; printf "driver exit=%s\n" "$rc"; exit "$rc"'
```
Non-job-control parent; no `--kill-after`. Hard budget **1500 s** (worst: seven behaviour controls 130+112+112+115×4 = 814, four fault controls 115+122+122+125 = 484, direct refusal 7,
startup 25, reserve 115 → 1445 ≤ 1500; admission stops with 92 rather than overrun); typical ≈ 2–3 min. **Qualification**: the bound sums
declared allowances of bounded phases; `mv`/log lines are not enclosed by a timeout. Controls (name|outer|grace|worst|seam|class|fault):
`nested-orphan-after-exit|25|3|130||normal|` · `live-step-interrupt|4|6|112||normal|` · `live-step-double-term|4|6|112|step-after-reap|normal|` ·
`predicate-rc0|10|3|115||normal|` · `record-without-sentinel|10|3|115||normal|` · `lease-held-by-supervisor|10|3|115||normal|` · `refuse|10|3|115||normal|` ·
`fault-holder-unverifiable|10|3|115||refusal|holder-unverifiable` · `fault-survivors-quarantine|4|6|122||quarantine|census-members-persist` ·
`fault-receipt-unwritable|4|6|122||quarantine|census-members-persist,receipt-unwritable` · `fault-census-unknown|10|3|125||quarantine|census-unknown` ·
direct-refusal (real runner without launcher → 71, no run dir). Quarantine-class controls leave a holder on the PRIVATE lease for a few seconds
until the driver's identity-checked recovery; nothing outside `…/v6/control-runs` is touched.

Driver exits (actual branches): pre-spawn, no finish/census: **70** mkdir · **91** manifest mismatch · **95** private lease pre-held. Via `finish`
(census + lease + LIVE holder re-checked, one `DRIVER-TERMINAL-*.txt` + `EXIT code=` line): **0** all passed and re-confirmed · **90** terminal receipt
unwritable on a success path · **92** budget admission · **93** run-dir/identity anomaly · **94** first unexpected result (predicate MISS, leftovers as
left by launcher, lease not free, live holder where none expected, fault control without live holder / recovery failed, or success contradicted) · **96** cancelled, launcher exited, bound run clean · **97**
cancelled-unresolved (launcher alive at its one cancel deadline; pid+starttime+fd9 in `DRIVER-UNRESOLVED-*.txt`; not killed) · **98** unsafe release
observed (unreaped leftovers, lease free) · **99** census UNKNOWN, no bound run, or no owned session for a non-refusal run (nothing declared empty, nothing reaped) · **143/130** signalled.
Code 70 is shared by the caller (`cd` failure), the driver (`mkdir`) and the launcher (dir/console/lease-open) — disambiguate by the printed line (B-10).
Pass = raw exit 0 AND every `PREDICATES.txt` free of `MISS` AND terminal receipt as in §2/A-04. Anything else: STOP, preserve `control-runs`, no re-run
without a new grant.

## 5. Stage 2 — native validation (NOT executable until: Stage 1 passed on these bytes under its own grant; both V6 reviews; §3 paths; canonical-lock grant)

```
bash -c 'cd /home/user/workspace/execution/s4-r6-validation/v6 || exit 70; if bash launcher/s4-r6-launch-v6.sh; then rc=0; else rc=$?; fi; printf "launcher exit=%s\n" "$rc"; exit "$rc"'
```
Bound: 3300+45+10+8+5 + 2×5 read + 2×5 verify + 16×2 census + 2 = **3422 s** = `bounds.worst_case_s`, with the same qualification (allowances of
bounded phases; `mv`/log not enclosed). Launcher exits (actual branches): **73** caller is a group leader (stderr only, no record) · **70** runs dir /
console / lease-open failure · **71** run dir already exists · **72** runner file missing · **75** LEASE_BUSY (canonical lock held) · **8**
STANDBY_HOLDER_FAILED (nothing spawned) · **124** TIMEOUT (session verified EMPTY) · **143** INTERRUPTED (verified EMPTY) · **6**
FAILED_RUNNER_LEFT_ORPHANS · **71/73/75** RUNNER_REFUSED (runner's own refusals) · other nonzero = runner's exit (RUNNER_NONZERO) · **9**
FAILED_OWNERSHIP_HANDSHAKE · **7** FAILED_PUBLICATION (record/sentinel mismatch, supervisor record unwritable on a SUCCESS path, or standby holder
not releasable on a SUCCESS path) · **5** QUARANTINED_SURVIVORS (holder verified + receipt) · **11** QUARANTINED_RECEIPT_FAILED (holder retained, no
receipt) · **12** QUARANTINED_SELF_HOLD (recorded would-be code; the process does not exit) · **0** SUCCESS. There is no runner-hash comparison exit.

## 6. Recovery (identity-checked; never executed here; only after the listed survivors are verified gone)

Sources of identity, in order: `<run>/QUARANTINE_LEASE_HOLDER` → `<run>/SUPERVISOR_RECORD.json` `lease.quarantine_holder_*` → `<run>/console.log`
`UNSAFE HANDOFF`/`SELF-HOLD` line → `pgrep -af s4r6-quarantine-holder-<RUN_ID>`. Kill only when `/proc/<pid>/stat` starttime, cmdline token and
`readlink /proc/<pid>/fd/9` all match the recorded values (rule text in V5 request §6 unchanged).

## 7. Decision points / rescope boundary

1. **SELF-HOLD (A-03 terminal fallback)** — reached only if the standby holder was lost *and* one respawn fails while survivors are unresolved. It is
   the only in-contract move that neither releases exclusion nor leaves an unrecorded holder, but the caller's bounded termination becomes a
   recorded live launcher (driver 97). Alternatives if the parent prefers a rescope: (a) external pre-existing holder service owned by the parent
   lane; (b) accept SELF-HOLD as the contract; (c) forbid the path by making holder loss itself a quarantine trigger earlier (does not remove the
   respawn-failure case). Other corrections do not depend on this choice.
2. Standby holder doubles fd-9 holders during a run (launcher + holder); the stub's outside-`flock` probe and B-06 limit are unchanged.
3. Budget 600 → 1500 s (eleven launcher controls); new codes 8/11/12 (launcher), 90/99 (driver); 10 removed.
4. `CENSUS_CALLS_MAX=16` is a source count of census calls outside wall-clock loops on the longest path; reviewers may recount.
5. Fault seams live in the launcher (data-level census/token/receipt-path substitution, `KIND==CONTROL` gated) — the same shape as the accepted
   lib seam; they exercise the real holder/receipt/recovery code, not a replacement. SELF-HOLD and standby-loss/respawn remain unexercised by
   Stage 1 (stated; a further data-level seam could kill the standby holder pre-quarantine if the parent wants that path covered too).
6. Bash/uutils behaviours still unmeasured by anyone (B not_proven): `timeout` raw 15, `setsid` in-place exec, pending-trap timing, `exec -a`,
   `sleep 60 9>&-`. Stage 1 is the first measurement.

## 8. Smallest next action
Dispatch two independent risk-scoped exact-V6 reviews against this packet's `SHA256SUMS`; on both clean, grant Stage 1 (§4) separately.
