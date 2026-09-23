# S2-V59 — independent exact-delta review B (T4), FROZEN 2026-09-23T01:24:43Z

Auditor: review lane B (non-builder). Requested identity: Claude Fable 5 / High per scope — **requested policy, not an observable runtime claim**. Method: read / hash / diff only; **nothing executed** (no `bash -n`, control, probe, process signal, lock, install, network, git); text-only regex scan. Sole writes: `execution/e8d546f9/audits/s2-v59-b/`. Not read: `audits/s2-v59-a/` (current peer), any state/takeover file. Read after my V58 freeze, as permitted: frozen V58-A `audits/s2-v58-a/AUDIT.json` (6ffd1b73…, manifest db115961…). My frozen V58 report (`audits/s2-v58-b`, MANIFEST b2a3f895…) is unchanged; its findings are re-applied below without assuming closure.

## 0. Exact inputs (full list: `INPUTS.sha256`)
| Input | sha256 | Note |
|---|---|---|
| V59 `execution/e8d546f9/s2-v59/SHA256SUMS.outer` | 4341ce30553bf950c32b40ef0f6466502bd2f189c99643733fa141dc5bd08bb5 | 16/16 OK from packet dir (17 files incl. manifest) |
| V59 driver `controls-proposed/run-controls-v59.sh` | 924768a25c644da980f320d331d1d767fc202343f03260177c62fddb4b839706 | 520 lines |
| Runner `run-composition-r57-v5.7-when-granted.sh` | efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c | `cmp` identical to V58 (= V57) |
| stubs fixture / harness / guard-spec / discriminator / SHA256SUMS.stubs; K1 | 5560c9f7… / bc9704e6… / 6dc98ce0… / 535dc494… / 19683d2f…; 3359b84a… | all `cmp` identical to V58; stubs manifest 4/4 OK |
| CONTROL_REQUEST_16.md / PROOF_REQUEST_17.md / REPORT.md / FINDINGS_MAP_V59.md / inputs/INPUT_HASHES.txt | 28a7c46b… / 262d5884… / 91a4a93d… / d97b48a3… / f92027ff… | |
| diffs controls-driver-v58-to-v59 / control-request-14-to-16 / proof-request-15-to-17 | 3c59bd80… / 24ab1a2a… / 83c1143b… | bodies reproduced |
| Base V58 `s2-v58/SHA256SUMS.outer`; driver v58; CONTROL_REQUEST_14; PROOF_REQUEST_15 | efde06b5…; 1e2e32eb…; f5cc7c0d…; 74f46142… | base of every diff |
| Frozen V58-A `AUDIT.json` / `MANIFEST.sha256` | 6ffd1b736d90c38d160a2bbe231703a5c7eacece67cb6e0cce5e48d4f37bc76a / db1159619dec76beb86927bcc89e037c583593e376f0d5db0f6be578ef43e3fa | permitted after my V58 freeze |
| My frozen V58-B `S2_V58_REVIEW_B.md` / `MANIFEST.sha256` | 5f2729ba… / b2a3f895… | unchanged |
| V58 B disposition `B_DISPOSITION_V58.md` / `MANIFEST.sha256` | 8fd39eb9… / 1c265fcd… | context |
| Setup receipt `s2-setup-result/SETUP_RESULT.md` | 0f51a22e… | context only; claims not re-verified by me; no reinstall requested |
| `recon/EXECUTION_SCOPE.md` / `tgp-agent-context/AGENT_RULES.md` | f06655da… / edd63115… | scope |

## 1. Integrity of the exact successor — PASS
- `sha256sum -c --quiet SHA256SUMS.outer` in `s2-v59`: 16/16 OK; manifest hash equals the parent's 4341ce30…. Stubs manifest 4/4 OK.
- Three packet diffs independently recomputed (`diff -u` V58 file → V59 file); bodies (from line 3) **byte-identical** to `diffs/controls-driver-v58-to-v59.diff`, `control-request-14-to-16.diff`, `proof-request-15-to-17.diff`. Driver: 41 changed lines in 5 hunks (header, lane paths `R58→R59`, helpers D157–169, K1 path D274, banner D251) — matches REPORT.md L10.
- Runner, four stubs, stubs manifest and K1 `cmp`-identical to V58 → **runner/stubs/K1 unchanged; runner pins (R97 `execution/op88/s2-v57`, R115 stub lock/out, R120 real out, canonical lock) unchanged; product unchanged**. Dual-lane `RLANE` arrangement carried (D80, parent-accepted).
- Text scan for unassigned `$VAR`: only `R57`/`R58`, both solely in retained header comments (D27, D32, D47) — no code use.

## 2. Closure ledger
| Prior finding | Change verified in V59 (exact lines) | Independent challenge | Verdict |
|---|---|---|---|
| **S2-V58-A01** HIGH — g-kind N6 holder known only as `g<pid>`; cancellation before the child's `setsid` → `resolve_pending_controller`'s g branch finds no session → child discarded, may later take the lane lock | D159–160 `ctrl_recs <pid>`: `prec=$(pid_rec "$1")`; empty → nothing; else `p<pid>:<start>` and, for kind g, also `g<pid>`. D161–164 `ctrl_book` books **every** record (OWNED when armed `owned`, CTRL always, each read back; `ok=1` on any miss → STRIKE). D165–169 `resolve_pending_controller` lists every record of the unbooked child and names them in the stamp. D158 `ctrl_arm` comment updated. Call site D491–492 unchanged (`ctrl_arm n6-holder g owned; setsid flock … & HOLDER=$!; ctrl_book "$HOLDER"`); `controller_cleanup` D170–176, `rec_alive` D104–108, `pid_rec` D103, `finish` order D210, N6 explicit `kill -TERM -- "-$HOLDER"; wait` D501 unchanged | The direct child X (`$!`) is bash→`setsid`→`flock` by exec, so its `/proc` starttime is fork-time and exec-invariant: `p<X>:<start>` is valid authority from the fork on, before any session exists. In the counterexample schedule (TERM between D492 `&` and `ctrl_book`, child pre-`setsid`): resolver → `ctrl_recs X` → `pX:start` + `gX` in CTRL; `controller_cleanup`: `rec_alive pX` → X (live), `rec_alive gX` → empty pre-session (`pgrep -g X` finds no member) → TERM X → X dies at default disposition; census empty. If X had already become session leader and `flock` had forked its `bash -c … exec sleep 40` child Y: TERM X (flock) may leave Y holding the inherited fd, but at the 0.5 s re-evaluation `gX` yields Y (sid == X) → KILL Y → lock released → census empty. Caller's group never targeted: p = exactly X; g excludes `MY_PGID`/`PARENT_PGID` (D106) and X ≠ driver pgid. Duplicate pid in the TERM list (X from both records) is harmless. Normal path: no `owned_cleanup` runs between D492 and D501; D501 ends the group and `wait`s X before the lock re-observation; the later `owned_cleanup` finds both records dead. | **CLOSED** |
| V58 closures (V57-A01..A05, B57-01/02) | helpers changed only by enumerating records; N1/C1/N4/N5b are kind p → `ctrl_recs` yields exactly the v58 record; D190–191/D260–266 (A01 fix), D386 (N1), D434 (C1), D443 (N4), D473/D478 (N5b), D100–111 (A04 parser), D77/D90/D214–216/D246 (A03) unchanged in content (only line shift +13) | grep-confirmed predicates and producers unchanged; stubs byte-identical | **PRESERVED** |
| Behaviour change (builder-disclosed, FINDINGS_MAP L13) | dead g-kind child at booking: v58 booked `g<pid>` and returned 0; v59 books nothing → STRIKE `FAIL: holder session N could not be booked` | fail-closed; consistent with p-kind; not a weakening | acceptable |

## 3. My frozen V58 findings — applicability to V59 (no closure assumed; all outside V59's declared scope)
| ID | V59 state | Applicability |
|---|---|---|
| **B58-01** LOW — finish alarm calls `wd_parent_ok` (now D204) before its definition (now D260), traps armed at D224 | unchanged | **OPEN-LOW, carried.** Window is D225–D259 (pre-control preamble) on external TERM/abnormal exit only; `abort()` (D221) does not use `finish`; all `finish` after D260 correct. Not a grant blocker; one relocated line for a future delta if one is needed for another reason. |
| B58-02 INFO — `new1` predecessor lock lands inside the frozen packet's `stubs/` dir | path now `execution/e8d546f9/s2-v59/controls-proposed/stubs/test-validation.lock` (D90; CONTROL_REQUEST_16 §Limits) | policy point, enumerated; unchanged class |
| B58-03 INFO — `ctrl_book` clears the latch on registry-write failure with a live child | unchanged (D164) | now also covers g-kind; still I/O-failure class with STRIKE; not material |
| B58-04 cosmetic — stale `TERM(driver)@+1 s` comment | now D258 | unchanged |
| Carried V57 residuals B57-03/05/07 | unchanged | as documented in the V58 B disposition; visible-only or doc-only |

## 4. New findings introduced by the V59 delta
| ID | Sev | Location | Finding |
|---|---|---|---|
| B59-01 | INFO | PROOF_REQUEST_17 L5 | Retained sentence "Supersedes PROOF_REQUEST_13 only by path" is stale (the request supersedes 15); L3 states it correctly. Doc nit; no effect on any control. |

No consequential delta defect found. Producer↔predicate cross-check: every string grepped by the driver/runner (`HANDOFF FAILURE: .* lane lock HELD`, `controllers ended: census_after=`, `watchdog stopped: …`, `PENDING controller …`, `CONTROLS_RECEIPT: …`, all K/N/W/C/P predicates) is produced unchanged; the only new output is the record list appended inside the `PENDING controller … → listed for controller cleanup […]` stamp (D169), which no predicate matches against.

## 5. Requests
- **CONTROL_REQUEST_16 (28a7c46b…)**: write set complete and moved to V59 paths (results dir; `execution/op88/s2-v57/runtime/` and `runner-selftest-r57/`; `new1`-only `execution/s2-setup-prep/runner-selftest-r531/` and the V59 stubs lock file); ENV01 action `new1` only; `export GIT_OPTIONAL_LOCKS=0` now inside the executable block (B57-06); standalone `wdcancel=3` exception inline; explicit no-`set -e` caller note; dual-lane arrangement stated as parent-accepted; signal limits updated to name the holder's `p<pid>:<start>` + `g<pid>` records. Set map/codes unchanged.
- **PROOF_REQUEST_17 (262d5884…)**: separately held; not assessed for grant. Bound qualification now truthful (declared maxima 2430 + 50 = 2480 s, + 60 grace = 2540 s > 2100 s; 2100 is a real-time cap with visible overrun 143/124) — this closes B57-04's truth defect without touching the runner. References the setup receipt 0f51a22e… as environment evidence (no reinstall) — I did not re-verify the receipt's claims.

## 6. Verdicts (distinct)
1. **Exact-successor integrity: PASS.**
2. **Runner/stubs/K1: UNCHANGED**; pins and product applicability unchanged; no product clearance asserted.
3. **Driver v59 (924768a2…): S2-V58-A01 CLOSED; V58 closures PRESERVED; no material delta defect; B58-01 carried OPEN-LOW (non-blocking).**
4. **CONTROL_REQUEST_16: GRANTABLE on static review** (stub-only; conditions at grant: LANE-OK on `s2-v59`, PRE-OK, `op88/s2-v57` 15-OK, ENV01 directory action for `new1`, caller block as written incl. `GIT_OPTIONAL_LOCKS=0`). Expected raw exits 0 for seven sets, 3 for standalone `wdcancel`. **Static, unrun; grantability ≠ passing.**
5. **PROOF_REQUEST_17: separately held**, not assessed for grant; bound truth qualified as above.

## 7. Truth
- VERIFIED (read-only): all hashes in §0; three diff bodies; `cmp` identities; every line citation; V58-A counterexample schedule re-derived against v59 source.
- INFERRED (not executed): exec-invariance of `/proc` starttime; `setsid`/`flock` fork structure (flock forks the command child and waits); default TERM disposition of pre-exec/`setsid`/`flock` processes; bash trap timing between simple commands; `${!-}` semantics (same idiom as runner R178).
- TESTED at runtime: **none** by builder or by me. UNRUN: all eight sets, every discriminator, real proof.

## 8. Smallest next action
Grant CONTROL_REQUEST_16 for the eight-set sequence with its own caller block; return raw per-set exits and frozen results directories for dual review. B58-01 does not block; PROOF_REQUEST_17 stays held until CONTROL_REQUEST_16 is green and reviewed.
