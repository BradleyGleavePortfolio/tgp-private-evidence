# S2-V59 — additive applicability note for frozen review B of V58 (S2-V58-B58-01..04)

Status: tiny additive note only, outside the frozen V59 packet. V59 (`execution/e8d546f9/s2-v59/SHA256SUMS.outer` 4341ce30553bf950c32b40ef0f6466502bd2f189c99643733fa141dc5bd08bb5) re-verified LANE-OK at write time and UNCHANGED; V58 (efde06b5…) and its B disposition (1c265fcd…) unchanged. No revision, no runner/stub/provenance change, no runtime. Sole writer: the V59 builder; lane `execution/e8d546f9/s2-v59-disposition/` only.

Inputs (hashes in `INPUTS.sha256`): review B `execution/e8d546f9/audits/s2-v58-b/S2_V58_REVIEW_B.md` 5f2729ba… (MANIFEST b2a3f895…, verified before reading); audit A `audits/s2-v58-a/AUDIT.json` 6ffd1b73… (manifest db115961…); frozen V59 manifest; parent instruction 2026-09-23 (B's V58 grant recommendation NOT acted on; A58 N6 schedule still binds; V59 remains the candidate; no optional B58-01/helper relocation or other LOW fix).

## 1. Why B's §5.4/§7 recommendation is not the path
B found no material V58 delta defect and recommends granting CONTROL_REQUEST_14. B did not consider the audit-A schedule S2-V58-A01 (cancellation of a g-kind controller between its `&` and its setsid transition; B §2 row A05 checks only the p-kind N4 case and lists N6 as "latched"). That schedule is a valid static counterexample on the changed N6 helper, so V58 is not granted; V59 closes it (FINDINGS_MAP_V59.md, driver D159–169). CONTROL_REQUEST_16 (V59) supersedes CONTROL_REQUEST_14; the caller block already contains B's condition (c) `export GIT_OPTIONAL_LOCKS=0`, and conditions (a)/(b) are unchanged text.

## 2. B58 findings against frozen V59 (line numbers = v59 driver `run-controls-v59.sh` 924768a2…; v58 → v59 offset +13 in the affected region)
| B id | Sev | V59 state | Disposition |
|---|---|---|---|
| **B58-01** finish-alarm calls `wd_parent_ok "$FA_SELF"` (v58 D191 → v59 D204) but `wd_parent_ok` is defined after the traps (v58 D247/D211 → v59 D260/D224) | LOW | **Unchanged in V59** (carried): the ordering gap is exactly as B describes; only a `finish` entered during the preamble D225–D259 whose tail exceeds `pb` seconds is affected; `abort()` and every post-D260 `finish` are correct; no false 0. | **OPEN-LOW, carried by parent decision** — the one-line relocation is not authorized for V59 (single-fix scope). Recorded for the next authorized delta, if any. |
| **B58-02** predecessor lock file is created (v5.3.1, `new1` only) inside the frozen packet's `controls-proposed/stubs/` | INFO | Path moved with the lane: `execution/e8d546f9/s2-v59/controls-proposed/stubs/test-validation.lock` (driver D88 `PRE_LOCK=$STUBS/test-validation.lock`; CONTROL_REQUEST_16 write set). Manifest `sha256sum -c` stays valid (extra file); driver probe never creates it (`-e` guard). | **Policy point, unchanged**; same class as the parent-accepted additive directories under `execution/op88/s2-v57`. No change. |
| **B58-03** `ctrl_book` clears the latch even when a CTRL write fails for a live child (I/O failure class) | INFO | Same in V59 (D161–164: `ok=1` on any failed read-back; latch cleared; `STRIKE=1`). For kind g the record set now has two entries; a partial write still STRIKEs. | **Non-material, unchanged**; run cannot end 0. |
| **B58-04** stale comment `TERM(driver)@+1 s` | INFO | Carried (v59 D258). | Cosmetic; unchanged. |

B's carried B57-03/04/05/06/07 dispositions agree with `s2-v58-disposition/B_DISPOSITION_V58.md`; V59 carries them identically (CONTROL_REQUEST_16 loop exports `GIT_OPTIONAL_LOCKS=0`; PROOF_REQUEST_17 carries the corrected bound qualification).

## 3. B's static set walk (§4) vs V59
Applies unchanged to V59 for probe/k/new1/new2/wdtest/wdcancel/neg (no V59 change touches those paths). neg2: additionally `controller-pids.txt` shows both `p<HOLDER>:<start>` and `g<HOLDER>`; the normal-path lines B lists are unchanged.

## 4. Truth / next
Nothing run. This note is read/hash only. Next: A59/B59 independent review of the V59 N6 delta (in progress per parent); controls (CONTROL_REQUEST_16, all eight sets once, raw status, `wdcancel=3` accepted) only after both; no runtime grant yet.
