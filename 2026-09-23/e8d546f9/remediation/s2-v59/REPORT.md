# S2-V59 — REPORT (T4 Fable sole writer, lane execution/e8d546f9/s2-v59)

Purpose: smallest additive execution-layer successor of frozen V58 (SHA256SUMS.outer efde06b5…, immutable, plus its B disposition 1c265fcd…, immutable) closing ONLY S2-V58-A01 (`execution/e8d546f9/audits/s2-v58-a/AUDIT.json` 6ffd1b73…, manifest db115961…): a g-kind (N6 holder) controller child was known only as `g<pid>` and was discarded when cancellation preceded its setsid transition. Product d5cd, runner v5.7, stubs, K1, predecessor, V57/V58 lanes, audits: untouched. No controls/probes/lock/install/network/DB/process control/commit executed. Current V58 review B not read.

Builder identity: requested Claude Fable 5 / High per scope; observable identity is an API assistant whose model/version and reasoning setting are not observable at runtime. Builder output is not audit.

## Frozen delta
| File | sha256 | vs V58 |
|---|---|---|
| controls-proposed/run-controls-v59.sh | see SHA256SUMS.outer (520 lines) | v58 driver 1e2e32eb… (507); `diffs/controls-driver-v58-to-v59.diff` (41 changed lines, 5 hunks: header, lane paths R58→R59, helpers D159–169, K1 path, banner) |
| run-composition-r57-v5.7-when-granted.sh | efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c | BYTE-IDENTICAL (V57 = V58 = V59) |
| stubs/*.sh, SHA256SUMS.stubs, k1-predecessor-mechanism.sh | as V58 | byte-identical (cmp) |
| CONTROL_REQUEST_16.md / PROOF_REQUEST_17.md | see SHA256SUMS.outer | `diffs/control-request-14-to-16.diff` (17 lines: V59 paths, `GIT_OPTIONAL_LOCKS=0` in the loop, holder record wording, accepted dual-lane wording), `diffs/proof-request-15-to-17.diff` (13 lines: V59 paths, export, setup receipt reference, corrected bound qualification) |
| FINDINGS_MAP_V59.md | S2-V58-A01 → lines → change → discriminator | |

Edit method: mechanical copy of the V58 packet, then exact-string edits (edit tool / exact Python string replacement asserting single occurrence) on the driver and the two requests. Diffs are the authoritative record.

## The fix in one paragraph
`ctrl_recs <pid>` (D159–160) enumerates the controller records for a live child: kind `p` → `p<pid>:<start>`; kind `g` → `p<pid>:<start>` AND `g<pid>`. `ctrl_book` and `resolve_pending_controller` now book/list every record from it. The direct child therefore carries identity-bound pid-only authority from the fork on (bounded TERM/KILL of exactly that process while no owned session exists), and the session record takes over through the unchanged validated-member path once setsid has happened; `controller_cleanup`'s existing TERM → re-evaluate → KILL → census covers the transition window. The caller's group is never a target. No new control, list, or framework; no runner/stub/provenance change.

## Implemented vs tested vs unrun
- IMPLEMENTED (static): the single row of FINDINGS_MAP_V59.md plus the carried request items.
- TESTED: **none at runtime.** Static only: `bash -n` on the driver, four stubs, K1, runner, and every embedded `bash -c` body (LEADER, publication tail, W1 workload); record-set word-splitting checked on literal text.
- UNRUN: all eight sets and all real proof. No fake tested claim.

## Carried, unchanged
Dual-lane RLANE arrangement (parent-accepted); ENV01 (`new1` needs `execution/s2-setup-prep/runner-selftest-r531/` writable at grant); predecessor lock path (now `execution/e8d546f9/s2-v59/controls-proposed/stubs/test-validation.lock`, `new1` only); standalone `wdcancel=3` exception inside the loop; `GIT_OPTIONAL_LOCKS=0` export; setup receipt `execution/e8d546f9/s2-setup-result/SETUP_RESULT.md` cited as applicable environment evidence (no reinstall). Residuals B57-03/05/07 and the optional `record` shape guard remain as documented in the V58 B disposition.

## One smallest next action
Dual exact-delta closure review of this frozen packet (one driver diff + two request diffs + FINDINGS_MAP_V59.md against S2-V58-A01, and current V58 B once frozen). Then, if clean, one grant of CONTROL_REQUEST_16 for all eight sets in sequence (raw status, `wdcancel=3` accepted), then PROOF_REQUEST_17. No release, customer or product clearance is asserted.
