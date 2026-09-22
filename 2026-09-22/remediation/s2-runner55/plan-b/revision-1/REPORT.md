# S2-V5.5-INDEPENDENT-CLOSURE — Reviewer B report (revision-1, frozen)

Role: independent reviewer B (`s1_r4_independent_audit_b_muc6muwk`), read-only. Scope: narrow actual-delta closure review of `execution/s2-runner55` (runner v5.5 + driver v55 + stubs + CONTROL_REQUEST_08 + PROOF_REQUEST_09), not a product re-audit. Nothing was executed: no scripts, no `bash -n`, no probes, no install, no DB, no network, no source/fixture/runner change. Peer A's *current* r55 output was not read; both frozen r54 reports were used as prior input.

Model: requested Claude Fable 5 only; runtime identity is not exposed and is not asserted.

## 0. Bottom line

| Item | Verdict on the actual bytes | Evidence state |
|---|---|---|
| **BLOCKER S2-R55B-01** | Runner L103 ends with `IDDIR=`, erasing the id directory set at L94. Every step's identity file path becomes `/<label>.pgid`; as uid 2000 the publish fails, so **every run (stub or real) is refused at step 10 with `final=70`** — fail-closed, no unsafe action, but request 08's K2 and every runner control cannot pass and request 09 would burn a slot on a certain refusal. Smallest closure: delete the trailing `IDDIR=` token on L103 (or move L94 below L103). | source-certain (path arithmetic + `/` owned by root 0755, runner uid 2000) |
| **S2-R55B-02** | Driver L119 K2 expectation still matches the v5.4 text `(recorded groups [digits]`; v5.5 L141 now prints `(owned groups [none] retired [...]`. K2 strikes even after -01 is fixed. Closure: update the regex on L119. | source-certain |
| P1 checkpoint pin / client bytes | Closed at source: L75 export, L315/L318 explicit under `env -i`, L298 refuses unless installed CLI == `c2a77456…`, L299 stamp; consumers (release.sh, harness, discriminator, guard spec) contain no `env -i`/`unset`/`env -u` (grep). Historical egress remains inferred from bytes, not observed; the pin is prospective. | source; K2 E6 echo NOTRUN |
| P2 self-published exclusive identity / retirement | Closed at source: L161–L181 (publish after `setsid`, adopt only `published == $!` and ≠ own/parent), L108/L109/L194 retire on confirmed-empty, L122 pid-only fallback, L167 own/parent rejection. Closes R54B-02/-05 and the anomaly own-group case — **but inoperative until -01 is fixed**. | source |
| P3 owned stop/status | Closed at source: L200–L219, L237/L239; census bounded by QUIESCE_WAIT and the deadline; leftovers TERM/KILL by group, `cleanup_client_leak=yes` → 71 (L248). Real-mode: `pg_ctl stop` leaves the postmaster in its own session, so the census is expected empty. | source; K10 NOTRUN |
| P4 deadline before first exceptional reap | Closed at source: `deadline_start <reason>` L104 called at L121 (halt), L147 (signal), L171 (anomaly), L189 (quiescence), L224 (cleanup); first caller wins. Closes R54B-04. | source; K7 reason expectation NOTRUN |
| P5 immutable receipts | Closed at source: L255 exit-codes, L258 bounded inner manifest (excludes SHA256SUMS/RECEIPT.txt/SHA256SUMS.outer), L263 RECEIPT.txt, L264 outer manifest, L265 stdout only; no hashed file is touched after L258; failed/over-deadline receipt → 71 (L261); process exit = RECEIPT final (L262/L266). Closes R54B-03. Launcher `8d0e2c7c…` writes runner stdout to `runs/<name>.log`, outside `$OUT`. | source |
| Driver E1–E5 (exclusive enclosure, prune, clip with grace, handoff → 4, receipt required) | Closed at source: L52–L59, L50–L51, L80, L67–L74, L89; own/parent groups never recorded or expanded (L56/L61). | source; N1–N3 NOTRUN |
| N4/N5/N6 proposed-only | N4 and N5: **no necessary gap** (safe by construction / sub-100 ms window, fail-closed). N6: the only untested guarantee path (`finish` → 4); recommended in the same request cycle, not a grant blocker. | — |
| Control request 08 | **Not grantable as issued**: outcome predetermined (K1 pass, K2 strike → set `k` exit 1; `new1`/`new2` strike at their first runner control). Grantable after -01/-02 → new bytes → request 08a. | — |
| Proof request 09 | **HOLD**: -01 makes a real run refuse at step 10; also requires 08a to pass. | — |

DYNAMIC ATTESTATION PENDING: v5.5/v55 have never run; nothing from v5.3/v5.4 controls transfers.

## 1. Identity and inputs (verified with `sha256sum` / `sha256sum -c` / `cmp`)

- `execution/s2-runner55/SHA256SUMS.outer` — 16 files, all OK; manifest sha256 `0d7332992da568bb8855a9d19a540e2389cd9bd345ec914639cf295a072788a4`.
- Runner `run-composition-r55-v5.5-when-granted.sh` `c3a4d2a9a234dda141122a44d46a3902a8575001a26ffcadc2029080a768de49` (357 lines; 134 changed lines vs v5.4 `3f404479…4327`).
- Driver `controls-proposed/run-controls-v55.sh` `a5a2d73f8b0138362ef391c4cbd58ea846673be1846bfaf92561bde2a538312c` (236 lines; 102 changed lines vs v54 `6638ec06…c6a4`).
- Stubs: `harness.sh` `d519f41b9c718ae0fd14f07f62262b215c73b18722c0a255b1063e91059a5b95`, `fixture.sh` `e415003c87fb118e809b9d8f732acdb76920993e4d5eda1556d4ef83e0cbcc61`, `discriminator.sh` `535dc494cb47b09d284adcbe990c64837648d3ab4a53ac033577b0f9dce3a8f1`; `guard-spec.sh` and `k1-predecessor-mechanism.sh` byte-identical to r54 (`cmp`); `SHA256SUMS.stubs` OK. Stub diffs are additive echoes (`CHECKPOINT_DISABLE=…`, `pid=… pgid=…`) plus the hanging-stop child publishing `spawned pid=`.
- `FINDINGS_MAP.md` `67d334d12befbcb7c2a0211d67249ac183360aa74c3b694afc4c5eb236283676`; `CONTROL_REQUEST_08.md` `83100d303c0305e1698a036e7463917135bce27c46b3b1f900f61213deb5750a`; `PROOF_REQUEST_09.md` `25f6d6a82f0753db235e2d6a79d1da6aa96a79273b674e77cfc922d3b9a5addf`.
- Prior frozen: A r54 `REPORT.md` `f5000761fef24541679f07aa42d455ee5455a3de679c51cb203c11761a45f241`; B r54 `REPORT.md` `3b807e6ebf58032b513cd7f4cf7d82f825e9f1cabf1f95d48e0bc0bb2e42b428`.
- Unchanged pins: fixture `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881`; launcher `launch-detached.sh` `8d0e2c7ce4721afaa7ff5bdfdfb2cb525790b424b8a163319c9de2e2eb4d7181`; v5.3.1 lane manifest verifies clean (0 failures).
- Contract: `EXECUTION_REPAIR_WAVE_2.md` `cafda5fb0622f2afea568b6908f72a3c471c509b7289b3f081fc3ca4756342f5` §S2-V5.5-INDEPENDENT-CLOSURE A/B; `DISPATCHES.md` `e5cdb56dd93ae54b3cf6957f77a422abfac1d5f3578aba9c85b9abb7483ff4fb`.
- Host facts used: runner would execute as uid 2000 (`id -u`), `/` is `root:root 0755`.

## 2. Findings (stable ids S2-R55B-NN)

### S2-R55B-01 — DEFECT, BLOCKER — `IDDIR` is reset to empty after being set
- L94: `mkdir -p "$OUT"; IDDIR="$OUT/.pgid"; mkdir -p "$IDDIR"`.
- L103 (register initialisation, one physical line) ends with `… PARENT_PGID=$(ps -o pgid= -p $PPID 2>/dev/null | tr -d ' '); IDDIR=` — the last token assigns the empty string. `IDDIR` is referenced only at L94, L103, L162, L202 (grep), never re-set.
- Effect at L162/L202: `idf="/10-guard-spec.pgid"` etc. The leader's `echo $$ > "$1"` (L163/L164/L203) fails with EACCES (uid 2000 cannot write to `/`); `bash -c` has no `set -e`, so the step still runs, but no identity is ever published. Trace for step 10: stub `guard-spec.sh` exits within milliseconds → L166 loop sees the child dead → L168 `"" != $STEP_PID` → L169 false → L177 wait → L178 "exited rc=0 WITHOUT publishing its identity → stage NOT accepted" → L179 `finish 70`. Real guard spec (runs seconds) → L171 IDENTITY ANOMALY → TERM by pid → `finish 70`. Every run ends `final=70 first_exit=70 guard_spec=notrun` before any fixture/DB action; the fixture stop client (L237) would likewise fall to pid-only handling.
- Safety: fail-closed; the only signal is a TERM to the runner's own `timeout` leader by pid. If the sandbox ever ran as root the files would be created at filesystem root — a write outside the lane; not the case here (uid 2000) but a second reason to fix.
- Not catchable by `bash -n`; would be caught by K2 (`final=0` miss). Smallest closure: remove the 6-character token `IDDIR=` at the end of L103 (or move L94 after L103). New runner bytes → new request.

### S2-R55B-02 — DEFECT (control), HIGH for request 08 — stale K2 expectation
- Driver L119: `expect "$O/stamp.txt" 'REAP ok: no owned-work process survives \(recorded groups \[[0-9 ]+\]' …`.
- Runner L141 now stamps `REAP ok: no owned-work process survives (owned groups [none] retired [<ids>], anchored scan)`; on K2's normal path all step groups are retired at L194, so the text is `(owned groups [none] retired [...]`. The regex cannot match → STRIKE → `k` set exits 1 at K2 even with -01 fixed. FINDINGS_MAP and request 08 themselves state the new text (`owned groups [none]`).
- Every other driver expectation was cross-checked against the v5.5 stamp/exit-codes/receipt formats (L89, L115–L127, L132–L137, L143–L147, L152–L153, L157–L158, L172–L176, L186–L188, L203–L207): all consistent. Smallest closure: L119 regex → `'REAP ok: no owned-work process survives \(owned groups \[none\] retired \[[0-9 ]+\]'` (description text likewise). Driver byte change → request 08a.

### S2-R55B-03 — INFO — watchdog sleeper residue and stale-id watchdog target
- Driver L98 starts `( sleep $((BUDGET-RESERVE/2)); … ) &`; `finish`/`abort` (L68/L75) kill the subshell, orphaning its `sleep` (unnamed, in the driver's own group) for up to ≈86 s after a `k` set. Harmless to handoff (`newpat` is pattern-based; the sleeper is not recorded). The watchdog reads the newest `.encl/*.pgid` (L98); between controls that id is a dead group and only a recycled id could be signalled — same low-probability class as R54B-02, mitigated by `pgrep -g` liveness and the own-group exclusion. Optional: `kill -- -"$WATCHDOG"` is not applicable (same group as the driver); simplest is to have the watchdog `exec sleep` inside a `setsid` of its own or accept the residue.

### S2-R55B-04 — INFO — unidentified cleanup-client leak branch is unreachable
- L217 `elif kill -0 "$pid"` follows `wait "$pid"` (L207); after `wait` the pid is reaped, so the branch never fires. An unidentified stop/status client's leaked children are therefore caught only by the pattern scan (L243). Moot once -01 is fixed (identity publication will succeed); if kept, make the branch depend on `pgrep -P`/pattern instead of `kill -0`.

### S2-R55B-05 — INFO — deadline/receipt notes (verification)
- Single anchor confirmed (L104; first caller wins); clipped consumers L117, L209, L213, L234–L235, L239, L257–L258; final registers computed before hashing (L243–L255), receipt after (L259–L263); `deadline_exceeded_after_hash` recorded (L260). Unclipped remainder: `lock_probe`, `pgrep`/`ss`, RECEIPT/outer-manifest writes (sub-second). Header L50 "48 s" is historical text (declared so at L16).
- Stub-mode K10 path traced: stop TERM at 20 s kills the stub's `bash` in `wait`, the published `sleep 60` stays in the stop group → L212 census line → TERM group → `cleanup_client_leak=yes` → 71; expected total ≈23 s, inside the driver's 20–30 s window. This is the R54B-06 residue fix (owned stop group), consistent.

### S2-R55B-06 — INFO — real-mode assumptions (unchanged from r54, not stub-covered)
`pg_ctl start` detaches the postmaster (P2 quiescence at step 31 passes only because of this; otherwise a fail-closed 70 and a TERM/KILL of the disposable postmaster as owned group); `pg_ctl stop` census empty for the same reason; Prisma engine children non-detached; harness C7 blocker terminated (harness L224–L225). First observation only in a real run stamp. Historical Prisma checkpoint egress is inferred from the bundled CLI bytes, not observed; `CHECKPOINT_DISABLE=1` is a prospective boundary and its inheritance into `npx`/`node` is first observed in a real run (request 09 says so).

## 3. N4 / N5 / N6 — is there a necessary control gap?

- **N4 caller-group decoy**: not necessary. The driver's kill list is record-based only (`owned_live` L60–L62 expands records; `record_from_run` L43–L49 no longer adopts any pgid from a child log; `enclose` L56 records only `published == $!` and ≠ `MY_PGID`/`PARENT_PGID`; L61 excludes own/parent groups and `$$`/`$PPID`). A process in the caller's group can only be signalled if its pid appears in a `spawned/escapee pid=` or QUARANTINE record written by a run this driver launched — that is the generic pid-reuse class, not a caller-group class. Nice-to-have, not blocking.
- **N5 startup interruption**: not necessary. The unconfirmed window is from `setsid bash -c` start to the `echo $$ > idf` (milliseconds, before `timeout` even execs); a signal there yields L122 TERM-by-pid and pattern-based survivor detection (72 if anything named survives). The residual is an unnamed grandchild spawned inside that window — practically empty for the real step commands.
- **N6 intentional handoff failure**: the only guarantee path with no exercise (`finish` L70–L71 → 4). Its absence is partially corroborated by every control's "recorded-owned alive after cleanup: [...]; pattern-detected: [...]" line (L66), but a regression that made `owned_live`/`detect` return empty would pass silently. Cheap to construct (an unrecorded `exec -a s2r53-stub-escapee sleep 20` injected after the first control, expected aggregate 4). Recommendation: add N6 to the same request cycle as the -01/-02 fixes; not a blocker for granting no-DB controls, because a false "0" here would still be caught by the request's post-set `pgrep`/lock probes if the grantor performs them.

## 4. Grantability (kept separate)

**Request 08 (controls, no DB):** safe as to side effects (signals only to identity-confirmed enclosure groups and recorded pids; refusal signal-free; lane-private lock; pre-runs additive with the frozen 37-file re-verify), but **not grantable as issued** because its result is predetermined by -01 and -02: `k` = K1 pass then K2 strike → 1; `new1` = K7pre passes (it runs the v5.3.1 bytes, which have no id file) then K7 strikes on L172 → 1; `new2` K10 strike → 1; `neg` would pass (N1–N3 test the driver, not the runner). Running it would only confirm the blocker. Path: fix L103 (runner) and L119 (driver) → re-hash → request 08a (optionally with N6) → run once.

**Request 09 (real proof):** HOLD. -01 guarantees refusal at step 10 (`final=70`, nothing created beyond `$OUT` and the lock hold), so a slot would be consumed for no evidence; also gated on 08a passing. No other real-proof blocker found in the delta; all r54 closures (checkpoint pin + bytes binding, retirement, owned stop, deadline-before-reap, receipt freeze) are correct at source once -01 is fixed. Settled pins (head/lock/closure/fixture/NS/DB/PORT) unchanged; destroy never invoked (L16 comment only).

## 5. Non-goals honoured
No execution, syntax check, probe, install, DB, network, source/fixture/runner/driver edit; no reads of `execution/audits/s2-r55/a`; all prior frozen outputs unchanged; output limited to `execution/audits/s2-r55/b/revision-1/`.
