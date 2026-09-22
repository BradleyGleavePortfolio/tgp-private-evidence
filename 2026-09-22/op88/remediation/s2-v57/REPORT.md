# OP88-S2-V57 — REPORT (T4 Fable sole writer, lane execution/op88/s2-v57)

Purpose: smallest execution-only successor of frozen V5.6 closing A01–A07 (audit A) and material D-01/D-02/D-03, D-04, R-1..R-3, P-01..P-03 (review B), preserving V5.6 closed properties. Product d5cd, V56 lane, sources, audits: untouched. No controls/probes/lock/install/network/DB/CLI/destroy executed. No canonical writes, no commits, no chmod of `execution/s2-setup-prep`.

## Frozen delta
| File | sha256 | lines | vs base |
|---|---|---|---|
| run-composition-r57-v5.7-when-granted.sh | efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c | 470 | v5.6 8980bca0… (422); diff `diffs/runner-v5.6-to-v5.7.diff` (96 changed lines) |
| controls-proposed/run-controls-v57.sh | 698bbb175c768707aef41b52b1b98ba2450791771ac63a34af4bb8d9654c637f | 470 | v56 10c48b69… (385); diff `diffs/controls-driver-v56-to-v57.diff` (356 changed lines) |
| controls-proposed/k1-predecessor-mechanism.sh, controls-proposed/stubs/* | byte-identical to v56 (see inputs/INPUT_HASHES.txt, SHA256SUMS.outer) | | |
| FINDINGS_MAP_V57.md | finding → line → change → discriminator (original IDs) | | |
| CONTROL_REQUEST_12.md / PROOF_REQUEST_13.md | separated bounded control grant vs real-proof grant | | |

Edit method: runner header/rename/halt/run_step/cleanup edits via the edit tool; runner publication tail and driver core/sets replaced as whole blocks via a Python block-replacement script (no sed -i); driver renames `$OUT56→$OUT57`, `$STUBS/test-validation.lock→$LANE_LOCK`, `$R55→$R57` via exact string replacement in the same script. Diffs are the authoritative record.

## Implemented vs tested vs unrun
- IMPLEMENTED (static): every row of FINDINGS_MAP_V57.md.
- TESTED: **none at runtime.** Static only: `bash -n` on both scripts; `bash -n` on every embedded `bash -c` body and both LEADER strings; producer↔predicate string cross-check (runner/stub producer lines vs driver `expect`/grep patterns — all present); read-only parse of `/proc/$$/stat` field 22 + `getconf CLK_TCK` on this host (identity mechanism parses; not a control).
- UNRUN: all discriminators (probe, wdtest, wdcancel, k, new1, new2, neg, neg2), all real proof. No fake tested claim.

## Concrete open blockers (separate from the delta)
1. ENV01 (audit A addendum): `execution/s2-setup-prep` mode 0555, `runner-selftest-r531/` absent → sets new1/new2 need that single directory made writable at grant (CONTROL_REQUEST_12 §3). Not chmod'd by the builder.
2. Real-proof preconditions (fresh PG17 + `npm ci` + install stamp with `lock=$EXPECT_LOCK_SHA`) absent in this environment (PROOF_REQUEST_13 §2). No earlier setup positive reused.
3. Ownership-architecture boundary: none hit — the existing leader/ack/CURRENT architecture accommodated checked registration and pending-latch recovery without rescope.
Known design note (not a defect claim): the driver's cancellation stage is at WD_KILL_AT+2 s (was +1) so a control that observed the KILL escalation (W1) finishes before the driver is TERMed; standalone `wdcancel` exits 3 by design (CONTROL_REQUEST_12).

## Evidence preserved
All 19 V56 files and prior failed/positive evidence untouched (V56 lane immutable, manifest 41cd5371…). Inputs read: inputs/INPUT_HASHES.txt (21 hashes).

## One smallest next action
Two independent exact-successor audits of this frozen packet (diffs + FINDINGS_MAP_V57.md against A01–A07 / B D-01..D-05, R-1..R-3, P-01..P-03). Then, if clean, grant CONTROL_REQUEST_12 (bounded stub controls, with the ENV01 directory authorization), then PROOF_REQUEST_13.
