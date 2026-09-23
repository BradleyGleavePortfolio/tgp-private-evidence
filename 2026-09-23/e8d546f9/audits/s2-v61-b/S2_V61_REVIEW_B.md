# S2-V61-B — independent exact-candidate review (T4), FROZEN 2026-09-23T02:07:24Z

Reviewer: lane B (non-builder, non-executor). Requested identity: Claude Fable 5 / High per scope — requested policy, not an observable runtime claim. Method: hash, `cmp`, recomputed `diff -u … | tail -n +3`, bounded source reads of the candidate driver, the unchanged runner/stubs, the V59 result files and both frozen result reviews. **Nothing executed** (no `bash -n`, probe, lock, network, process). Sole writes: `execution/e8d546f9/audits/s2-v61-b/`. Not read: current V61 peer, state, takeover. V60 packet touched only to verify the provenance diff (no separate audit; the builder discloses a post-freeze edit/revert on V60 with unchanged final manifest — I make no continuous-immutability claim about V60).

## 0. Exact inputs
| Object | Hash / status |
|---|---|
| `s2-v61/SHA256SUMS.outer` | **ed2413420bd1ae917649cff6924683c8279f45fb31505e46ff10051d513d7b7a**, 20/20 OK (`find` count 21 = 20 + manifest) |
| driver `controls-proposed/run-controls-v61.sh` | 42d9362b8234141bf5f68a997a5c113ced8154f068fdb87384674b7dd875ddc1 (567 lines; V59 520) |
| runner `run-composition-r57-v5.7-when-granted.sh` | efa273c7… — `cmp` identical to V59 (= V57 = V58) |
| stubs ×4, `SHA256SUMS.stubs` 19683d2f…, `k1-predecessor-mechanism.sh` 3359b84a… | `cmp` identical to V59 |
| `diffs/controls-driver-v59-to-v61.diff` 4abda882… | recomputed body **byte-identical** (148 lines) |
| `diffs/controls-driver-v60-to-v61.diff` c072380a… | recomputed body byte-identical; V60 driver 19f8602a…, V60 lane 2eb52088… verifies |
| `diffs/control-request-16-to-20.diff`, `diffs/proof-request-17-to-21.diff` | recomputed bodies byte-identical |
| `inputs/INPUT_HASHES.txt` | 97/97 OK from workspace root |
| CONTROL_REQUEST_20 0e8ab7ec…, PROOF_REQUEST_21 84930d07…, REPORT fd983f61…, FINDINGS_MAP c3c240d4… | read |
| Result reviews | A `audits/s2-v59-result-a/MANIFEST.sha256` 96e4d876… (read after my freeze); B (mine) 41b5b5e0… |

## 1. Delta inventory (V59 → V61, everything)
Header block (24 added comment lines); `R59`→`R61` constants D103–105 (results/stubs/K1 under `s2-v61`; `RLANE`, `LANE_LOCK`, `OUT57`, `PRE_LOCK` value unchanged, one comment `CONTROL_REQUEST_16`→`20`); new helper pair `step40_arm`/`step40_wait` D274–289; banner `S2-V61` D291; K1 script path D315; K3 D340–353; K4 D354–367; `need N4 … 40` D489; N4b D498–501. Nothing else — no change to `enclose`, `run_runner`, `need`/`clip`/`left`, watchdog, `ctrl_*`, `owned_*`, `finish`/publication, selectors, budgets, K1/K2/K5–K10, N1–N3, N4a, N5–N8.

## 2. Helper and sites — parent's checklist
| Check | Result | Evidence |
|---|---|---|
| Event placement | YES | Controller polls ≤80×0.1 s for the NEW runner dir carrying `.pgid/40-composition.pgid.ack` **and** `^stub harness .* mode=<mode>` in `40-composition.log` (K4 also `^escapee pid=[0-9]+ start=[0-9]+`). Producers verified: runner L155 writes the ack before the leader execs; stub `harness.sh` L10 prints `stub harness db=… mode=<mode> …` first, L13 prints `escapee pid=<n> start=<ticks>` after the `setsid -f` spawn + 0.3 s; K2's actual `40-composition.log` L1 matches the regex. |
| Current identity | YES | Runner pid from its own `lock acquired pid=` stamp; `ps -o pgid=` must equal `$CURF` (E7 authority written by `enclose` only for a validated leader `pg==pid`, `≠MY_PGID`, `≠PARENT_PGID`, D136); mismatch/empty → exit 2, no signal. Foreign runner dirs (other lane user) fail the pgid test. |
| Latch / book | YES | `ctrl_arm "<name>-step40-controller" p owned` before spawn; `ctrl_book "$S40C"` immediately after `&` (ctrl_book itself sets STRIKE on failure; the `|| say FAIL` mirrors N5b/decoy usage). Unbooked-on-cancel path covered by existing `resolve_pending_controller`. |
| Cleanup | YES | Controller-listed (`controller_cleanup` finally path) and owned-registered (`owned_live`/`owned_cleanup`); self-exits ≤8 s; `step40_wait` reaps it with a targeted `wait "$S40C"` **before** the `surv=$(owned_live)` line, so it never appears as a survivor. Log written under `$CTL` (inside the write set). |
| Single TERM | YES | One `kill -TERM "$p"` then `exit 0`; timeout → `exit 1` no signal; not current → `exit 2` no signal. Never `-<pgid>`, never `$$`/caller. |
| Same shape as N5b | YES | D520–527 (N5b seam controller) is the same body with a different trigger line and 100 vs 80 polls; N5b already asserts `RC=143`. |
| 143 not 124 justified | YES | Under V59 the 124 asserted that `timeout` itself fired (the elapsed-time guess). Under V61 `timeout` is a fail-safe (K3 12 s, K4 25 s, N4b 12 s, KA default 5); the TERM is delivered to the runner pid by the controller — the same delivery kind `timeout --foreground` used in the V59 K3 run — so the runner exits 143 by its own `finish` and `timeout` propagates it. 124 now means the fail-safe fired → explicit FAIL text. **Qualification:** 143 propagation through uutils `timeout --foreground` when the child exits on its own has not yet been observed in this lane (only 0 and 124/137 have); the first K3 execution is the first observation — inferred from timeout semantics, not runtime-verified (B61-03). |
| Scenario/order/survivor assertions preserved | YES | K3: all V59 predicates verbatim (`^final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok`; `composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none`; survivors none; SIGNAL<REAP<stop ordering; LOCK HELD; timing) **plus** added `^SIGNAL SIGTERM .* during step '40-composition'`. K4: all V59 predicates (`cleanup_exit=72 … reap=FAILED`, `fixture_stop=REFUSED survivors=present`, QUARANTINE content, no stop log, lock not handed off) **plus** the stamp assertion. N4b: unchanged assertions. No sleep lengthened, no predicate weakened. |
| Truthful `need` / caps | YES with one LOW | K3 12+5 grace+bookkeeping ≤ 18; K4 25+5 ≤ 32; N4 N4a≈6 + N4b 12+5 + decoy waits ≤ 40; neg2 sum 140 ≤ 142. Set `k` remains gated live by `need` (declared sum 98 > 60 by design). See B61-01 for the K6 margin. |
| Runner/stubs/K1 unchanged | YES | `cmp` |

## 3. Findings (stable IDs)
| ID | Sev | Finding | Disposition |
|---|---|---|---|
| **B61-01** | LOW (budget, grantor decision) | Set `k` K6 gate is tight. V59 actuals: K1 2.84 s, K2 5.44 s, K3 3.85 s (TERM at 3 s). V61 projection: K3 ≈4.5–5 s (TERM ≈3.7 s + stop + bookkeeping), K4 ≈20–21 s (TERM ≈4.0 s; runner `poll_until_quiet` waits the full 10 s TERM + 5 s KILL because `owned_scan` keeps seeing the `s2r53-stub-escapee` pattern — runner R118/R171/R203–206; then quarantine + publication + driver `owned_cleanup`), K5 ≈5.5 s → K6 `need 10` at t≈39–41 s with `left−8` ≈ 11–13 s. Margin 1–3 s; sandbox jitter (git wrapper ≈0.5 s per runner start) could produce a **truthful raw 3** (budget exhaustion, K6 NOT RUN) — never a false PASS. | Not a driver defect; not a grant blocker. Smallest remedy, if the grantor prefers to avoid a probable second `k` run: raise `[k]` in the CONTROL_REQUEST_20 loop (existing `CTL_BUDGET` input; watchdog schedule scales with it) — a request-text decision, driver bytes untouched. Otherwise accept and re-run `k` alone on a 3. |
| B61-02 | INFO | Stale header comment D95: "declared max 8+15+12+25+15+10 = 85" — now 8+15+18+32+15+10 = 98. | Cosmetic; carry. |
| B61-03 | INFO (qualification) | 143 propagation via uutils `timeout --foreground` for a self-exiting child is inferred, not yet observed in-lane (N5b also depends on it, unrun). | First K3 run observes it; a 124 is reported truthfully as FAIL. |
| B61-04 | INFO | Early runner exit before step 40 (e.g. refusal 70) leaves the controller polling; `step40_wait` blocks ≤8 s then FAIL rc=1 — bounded, inside declared maxima. `$mode` is interpolated into a BRE (`sleep`/`escape` only). | None. |
| Carried | — | B58-01/02/03/04, B59-01 (PROOF_REQUEST_21 L5 "Supersedes PROOF_REQUEST_13 only by path" wording), R59-01 disclosure present in PROOF_REQUEST_21 L3, R59-02/03 unchanged (runner immutable). | As before. |

## 4. Applicability of retained V59 evidence (my clarified relevant-input rule applied hunk by hunk)
Shared paths executed by P1/W1/C1 that V61 changes: **none**. The only delta they touch at all is (a) the `CTL` root constant (result directory location; `mkdir -p` at D106 — `s2-v61/controls-proposed/` is 755 user-owned, `results/` will be created exactly as V59's was), (b) the banner string, (c) two function **definitions** parsed at load but invoked only by K3/K4/N4b. A parse error in (c) would abort every set at load — it would surface at the very first continued set and cannot make a retained result wrong. → **P1/W1/C1 (0/0/3 on V59 bytes) RETAINED; no repeat necessary.** K1/K2 body unchanged (K1 only the script path prefix to identical bytes) — repeated solely because set `k` is one invocation with no per-control selector (correctly not built). N2/N3 child drivers run `CTL_SET=k` and stop at K1–K2 by design (not verified at runtime; V59 `neg` never ran) — they do not reach the changed K3.

## 5. Requests
- **CONTROL_REQUEST_20 — grantable (static).** Loop byte-identical in structure to 16 (five sets, same budgets, same STOP rule, `GIT_OPTIONAL_LOCKS=0`), write set = V59's with V61 lane paths, signal scope accurately extended for the step-40 controller, ENV01 correctly stated as already applied. Grantor decision pending on B61-01 (`[k]` budget). Every discriminator remains UNRUN.
- **PROOF_REQUEST_21 — separate, HELD** (prerequisite: 20 green + two reviews; bound qualification and R59-01 disclosure carried).

## 6. Verdicts (distinct)
1. Integrity: PASS (20/20; all recomputed diffs identical; 97/97 inputs; runner/stubs/K1 byte-identical).
2. Material closure: S2-V59-K3-PLACEMENT corrected at K3 and at both same-class NOT-RUN sites K4/N4b with one driver-only mechanism of the already-reviewed N5b shape; Result-A A01 requirements and my §6 criteria met; no relabel, no weakening, no runner revision, no new framework.
3. Introduced defects: **none material.** B61-01 LOW is a budget-margin qualification (truthful 3 possible), B61-02..04 INFO.
4. Control grantability: **CONTROL_REQUEST_20 grantable** as written (B61-01 to the grantor).
5. Real proof: not cleared; PROOF_REQUEST_21 held. No product/release clearance.

## 7. Truth
VERIFIED: hashes, cmp, four diff recomputations, producer lines (runner L136/L155/R118/R171/R201–216/L458; harness L10/L13; K2 actual log), V59 timings (`[t=…]` lines), permissions. INFERRED: K3/K4 wall projections; 143 propagation. EXECUTED: nothing (no `bash -n`; builder's syntax claim unverified by me).

## 8. Smallest next action
Parent decides B61-01 (`[k]` budget in the request text or accept); grant CONTROL_REQUEST_20; executor runs the five continued sets under V61 bytes; dual result review of the new evidence. If a 124 appears at K3/K4/N4b, read the controller log first (`<name>.step40-controller.log` in the result dir) — it states whether the TERM was ever sent.
