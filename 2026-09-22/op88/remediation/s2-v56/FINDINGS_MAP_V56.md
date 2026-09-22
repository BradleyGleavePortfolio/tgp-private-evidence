# FINDINGS MAP — S2 runner v5.6 / controls driver v56 (OP88-S2-V56)

Inputs (frozen, read-only): A REPORT fb91a51d…, B REPORT 8d35b223…, runner v5.5 c3a4d2a9…, driver v55 a5a2d73f… (full hashes in inputs/INPUT_HASHES.txt).
Truth status of every row: **IMPLEMENTED** (static edit present) / **TESTED: none** (nothing executed except `bash -n`) / **UNRUN** control that would discriminate. Line numbers refer to the frozen v5.6 files in this lane.

## A. Material findings → smallest change → discriminating (unrun) control

| Finding | v5.5 defect (as reviewed) | v5.6 change (file:line) | Control (unrun) |
|---|---|---|---|
| A-01 / B-01 IDDIR/root-path guard | trailing `IDDIR=` reset on the register line; `rm -f "$IDDIR/…"` could resolve at root | runner L110 single assignment `IDDIR="$OUT/.pgid"`; L120–L123 `iddir_guard()` requires IDDIR == "$OUT/.pgid", OUT under `$R56/*/*`, directory; run_step/owned_cleanup_cmd call it before any `rm -f` (refuse 70, nothing removed) | k/K2 (guard passes on the normal path); grep `IDDIR=` count = 1 (static, done) |
| A-02 startup identity publication/adoption (pre-publication window) | leader could exec before the runner adopted its identity; interruption in the window left an unowned live group | runner L128 LEADER: publish → wait `<idf>.ack` (≤3 s) → exec, else exit 70 (workload never starts); L130–L139 adopt_published registers group BEFORE ack; L159–L166 halt_owned_work resolves a published-but-unadopted identity before pid-only fallback; L132/L162 accept only a regular non-empty id file | neg2/N5a (STUB_PUBLISH_FAIL: leader exits 70, guard log has no stub output, final=70), neg2/N5b (STUB_HOLD_ACK + driver-owned TERM: `HALT … PUBLISHED but unadopted identity → adopted now`, final=143, harness never ran); driver mirror: probe/P1 |
| A-03 / B-03 current-only signal authority, owned watchdogs, total cancellation | driver watchdog read `ls -t *.pgid` (history), unowned `sleep` sleeper, no escalation to the driver itself | driver L54 `$ENCL/CURRENT` written on adoption (L81), truncated at empty census (L90) / prune (L75); watchdog L156–L162 reads only CURRENT, owns sleeper pid file, TERM@BUDGET−RESERVE → KILL@BUDGET−RESERVE/2 → TERM driver; L123–L124 `on_cancel` → finish 3; L93–L98 stop_watchdog census feeds gate L118 | wdtest/W1 (fires at schedule, authority cleared), neg2/N7 (nested: census empty), neg2/N4 active-vs-retired (`^g` records 0, CURRENT empty) |
| A-04 / B-02 K2 / predecessor receipt predicates | K2 regex expected `recorded groups [...]` (not produced by v5.5); RECEIPT.txt required from v5.3.1 which never writes it | driver L183 regex `owned groups \[none\] retired \[[0-9 ]+\], anchored scan` ← runner L183; L184 end line ← runner L308; L139–L146 successor-only RECEIPT/PUBLICATION/outer-manifest predicates, predecessor: `^final=… first_exit=` + SHA256SUMS present (NOT re-verified: known v5.3.1 post-hash mutation) | k/K2, new2/K7pre (predecessor path) |
| A-05 / B-05 checked immutable publication, publication deadline | hash step under `--foreground` inherited group semantics; receipt write unchecked; 0 returned after failed publication | runner L314–L329: `timeout -k 1 $hb bash -c 'find…sha256sum'` (no --foreground), deadline exhausted → hash skipped, receipt write verified by grep, `SHA256SUMS.outer` written + `sha256sum -c`, PUBLICATION.txt (unhashed) records status, FINAL 0→71 on failure/deadline; stdout `RECEIPT: … PUBLICATION: …` | k/K2 (`publication_status=ok deadline_exceeded_at_publication=no`, outer+inner re-verify), neg2/N5a & N5b (publication ok on refusal/signal paths) |
| A-06 / B-04 dead cleanup branch / unconfirmed cleanup client | unreachable branch; unconfirmed client treated as empty | runner owned_cleanup_cmd: dead branch removed; unconfirmed/unacked client → bounded halt, `CLEANUP_LEAK=yes`, return 70 → 71 | k/K10 (`cleanup_client_leak=yes`, final=71) |
| B-06 pin installed CLI before execution | `--version` executed before hash pin | runner F06 block: existence + `EXPECT_PRISMA_CLI_SHA` pin, then `--version` | real-proof only (stub mode skips toolchain) — PROOF_REQUEST_11 |
| CHECKPOINT_DISABLE=1 / env -i | unchanged from v5.5 (both reviews: kept) | no change; K2 L190–L192 still assert `CHECKPOINT_DISABLE=1` in 40/45/50 logs | k/K2 |

Driver mirror (E8, A-02): `enclose()` L76–L92 same leader contract; unconfirmed → STRIKE, bounded pid-only TERM/KILL, plain pid recorded; ack-write failure → group TERM + STRIKE. Never silent rc 0.
Driver publication (E10, A-05 mirror): L99–L106 bounded `timeout -k 1`, status-checked, `CONTROLS_RECEIPT.txt` (excluded from SHA256SUMS), classify after publication (0→4 on failure).

## B. N-discriminators

| Id | Question | Mechanism (deterministic, no probabilistic sleep as proof) | Expected producer lines |
|---|---|---|---|
| N4 | does any owned-work signal reach a caller-group process? | `exec -a s2r56-caller-decoy sleep 60` in the driver's own group, unrecorded, outside PAT; normal K2-like run, exceptional K3-like TERM run, driver owned_cleanup; then `grep -c '^g' owned-pids.txt`=0 and CURRENT empty; decoy ended by owner | runner signals only `$OWNED_PGIDS` (never MY/PARENT_PGID); driver kills only records |
| N5a | leader cannot publish | seam `STUB_PUBLISH_FAIL=10-guard-spec` → directory at id path (runner L206); leader `echo $$ > dir` fails → exit 70 | L206 `SEAM: … publish target made unwritable`; L222 `… exited rc=70 WITHOUT an adoptable published identity`; L309 `final=70 first_exit=70 …fixture_stop=notrun survivors=none`; no `stub guard spec` in 10-guard-spec.log |
| N5b | interruption after publication, before adoption | seam `STUB_HOLD_ACK=40-composition` (L136) holds the runner before adoption; driver seam-controller waits for the SEAM stamp, reads `lock acquired pid=` (L338), sends TERM | L136 `SEAM: 40-composition identity N read; HOLDING…`; L191 `SIGNAL SIGTERM … during step '40-composition'`; L164 `HALT: in-flight step '40-composition' … PUBLISHED but unadopted identity N → adopted now and signalled as a group`; L309 `final=143 … composition=interrupted(TERM) … fixture_stop=0 survivors=none`; no `stub harness` in 40-composition.log |
| N6 | handoff refusal when the lane lock is held | separately owned `setsid flock <lane lock> sleep 40`; nested driver `CTL_SET=probe` passes its control but gate returns 4 | driver L118 `HANDOFF FAILURE: … lane lock HELD …`; `CONTROLS_RECEIPT: publication_status=ok aggregate_exit=4` |
| N7 | watchdog fires on schedule, no sleeper residue | nested `CTL_SET=wdtest CTL_BUDGET=20`: unclipped enclosure `sleep 20`, watchdog TERM at t=12 | L158 `WATCHDOG fired … current_authority=N → TERM group`; L98 `watchdog stopped: … census_after=[empty]`; exit 0 |

Pre-publication window: closed by construction (no exec before ack); N5a/N5b cover both failure and interruption sides. Timing assertions (W1 window, K10 20–30 s) are ranges around scheduled bounds, not race proofs.

## C. Producer ↔ predicate cross-check (every `expect` on runner output, driver line → runner line)

| driver | predicate | runner producer | ok |
|---|---|---|---|
| L140 | `^receipt_status=ok$` | L318/L321 `receipt=ok` unless hash/deadline failure | ✓ |
| L141 | `^publication_status=ok deadline_exceeded_at_publication=no$` | L324–L327 (`pub`, `dl_pub`) | ✓ |
| L144 | `^final=[0-9]+ first_exit=` (predecessor) | v5.3.1 L153–L158 exit-codes.txt | ✓ |
| L179/198/209/218/223/231/240/253/260/269/328/332/345/359 | `^final=… first_exit=… cleanup_exit=… signal=… reap=…` | L309 | ✓ |
| L180/199/210/219/224/232/241/254/270/346/360 | step fields `guard_spec= refusal_hosted= … fixture_stop= survivors=` | L309 (RC_* defaults notrun; `interrupted($sig)` L192–L193; RC_STOP REFUSED L284 / SKIPPED L289 / rc L291) | ✓ |
| L181 | `STUB MODE — NOT EVIDENCE` | L114 | ✓ |
| L182 | `head=d5cd… tree=c0ab… dirty_lines=0` | L342 | ✓ |
| L183 | `REAP ok: … (owned groups \[none\] retired \[[0-9 ]+\], anchored scan)` | L183 | ✓ (v55 regex `recorded groups` had no producer → A-04) |
| L184 | `owned_groups=\[none\] retired_groups=\[…\]` | L308 | ✓ |
| L185 | 10 ack files in `$O/.pgid` | LEADER/adopt_published per label 10,20,21,30,31,32,40,45,50,51 | ✓ (51 runs only when remaining ≥ status allowance — normal path yes) |
| L186–L187 | `S1-GUARD REFUSED URL_HOST` / `CONFIRM` | product test/db/_support/s1-target-guard.sh (exit 64), verified in clone | ✓ |
| L188–L192 | `fd9=…` / `CHECKPOINT_DISABLE=1` | stubs echo fd9; runner env per step | ✓ (unchanged v55) |
| L193 | `^50-fixture-stop: group N census empty after exit` | L270 | ✓ |
| L203/L212 | `LOCK: held by runner through cleanup (HELD)` [+ `; NOT safely handed off`] | L305–L306 | ✓ |
| L211 | `s2r53-stub-escapee` in QUARANTINE.txt | L182 + stub harness escape mode | ✓ |
| L238/L252 | `^40-composition: leader pid=N exited rc=0|124 but group N still has members` | L234 | ✓ |
| L239 | `^HALT: live owned groups \[` | L169 | ✓ |
| L242 | `^DEADLINE: cleanup deadline started \(50 s\) reason=quiescence-40-composition` | L141 (CLEANUP_BUDGET=50, reason string from run_step) | ✓ |
| L271 | `^50-fixture-stop: client exited rc=124 but its group N still has members` | L266 | ✓ |
| L272 | `cleanup_client_leak=yes` | L302 | ✓ |
| L273 | `^50 fixture-stop exit=124 \(124=stop bound 20s exceeded` | L292 (`sb`=20 nominal) | ✓ |
| L343 | `^SEAM: 10-guard-spec publish target made unwritable` | L206 | ✓ |
| L344 | `^10-guard-spec: leader pid=N exited rc=70 WITHOUT an adoptable published identity` | L222 (`rc0`=70 from LEADER `exit 70`) | ✓ |
| L356 | `^SEAM: 40-composition identity N read; HOLDING before adoption/ack` | L136 | ✓ |
| L357 | `^SIGNAL SIGTERM .* during step '40-composition'` | L191 | ✓ |
| L358 | `^HALT: in-flight step '40-composition' pid=N had a PUBLISHED but unadopted identity N → adopted now and signalled as a group` | L164 | ✓ |

Driver-internal predicates (N1–N3, N6, N7, W1) reference driver-produced lines: `ABORT`, `ONE-STRIKE STOP before K2`, `BUDGET EXHAUSTED before K1`, `controls_run=R/P` (L120/L122), `HANDOFF FAILURE: … lane lock HELD` (L118), `CONTROLS_RECEIPT: publication_status=ok aggregate_exit=4` (L106), `WATCHDOG fired … current_authority=N → TERM group` (L158, tee'd to stdout and $R), `watchdog stopped: shell=N sleeper=N census_after=[empty]` (L98), `PASS: probe enclosure rc=0` (L305), `PASS: watchdog targeted the CURRENT validated authority` / `PASS: authority cleared` (L316/L318). All checked against the producing lines above.

## D. Residual observations (no change made; for the two reviewers)
- OBS-1 (pre-existing v5.5): runner `on_signal` sets `trap '' TERM INT HUP`; children spawned afterwards inherit SIG_IGN for TERM, so post-signal bounds (`timeout -k`) effectively act at the kill-after edge (+1 s hash, +STOP_KILL fixture stop). Bounds still hold; stamps are correct. The driver uses a no-op handler (`trap ':' TERM`) instead so its children keep default TERM.
- OBS-2: K3 (bound 3 s) and N4b (bound 4 s) rely on the runner reaching step 40 before the outer TERM; each step now adds one ack round-trip (≤~70 ms). Not a race proof; a miss shows as a different `signal … during step` label, which STRIKEs visibly.
- OBS-3: uutils timeout 0.8.0 (parent environment) may report 15 instead of 143 on group TERM; no v56 predicate asserts GNU-specific codes for enclosure exits except the runner's own `final=143` (set by the runner's trap, implementation-independent) and outer 124 (both implementations).
- OBS-4: lane discrepancy — S2-RUNNER-V5.6-PREP names `execution/s2-runner56`; OP88 brief governs → `execution/op88/s2-v56`.
