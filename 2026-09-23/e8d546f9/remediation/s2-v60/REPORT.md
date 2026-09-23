# S2-V60 — REPORT (T4 Fable sole writer, lane execution/e8d546f9/s2-v60; SOURCE-ONLY)

Purpose: smallest exact successor of frozen V59 (4341ce30…) correcting ONLY the actual V59 control failure S2-V59-K3-PLACEMENT (set `k` aggregate 1 at 2026-09-23T01:37:09Z, frozen in `execution/e8d546f9/s2-v59-control-result`, manifest d749a4b1…): K3's "TERM during step 40" was placed by a 3 s elapsed-time bound while the unchanged runner reaches step 40 ≈3.6 s after enclosure start on this host. V60 places the TERM by the runner's own attributable evidence (adoption ack `.pgid/40-composition.pgid.ack` + harness workload line) through a controller of the reviewed N5b shape. No runtime, probe, lock, network, install, worktree or product action; syntax/hash/diff only.

Builder identity: requested Claude Fable 5 / High per scope; observable identity is an API assistant whose model/version and reasoning setting are not observable at runtime. Builder output is not audit.

## Frozen delta
| File | vs V59 |
|---|---|
| controls-proposed/run-controls-v60.sh (552 lines) | v59 driver 924768a2… (520); `diffs/controls-driver-v59-to-v60.diff` (hunks: header; lane paths R59→R60; K1 path; banner; K3 block D320–342) |
| run-composition-r57-v5.7-when-granted.sh | efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c BYTE-IDENTICAL (V57=V58=V59=V60) |
| stubs/*.sh, SHA256SUMS.stubs, k1-predecessor-mechanism.sh | byte-identical to V59 (cmp) |
| CONTROL_REQUEST_18.md | `diffs/control-request-16-to-18.diff`: continuation (`k new1 new2 neg neg2`), retained V59 probe/wdtest/wdcancel evidence, K1/K2 inseparability statement, ENV01 already applied, V60 paths, K3 controller signal scope |
| PROOF_REQUEST_19.md | `diffs/proof-request-17-to-19.diff`: paths + prerequisite wording only (bound qualification retained) |
| FINDINGS_MAP_V60.md | causal boundary from preserved evidence; change; discriminator; §3 necessity report for K4/N4b (NOT changed) |
| inputs/INPUT_HASHES.txt (85), inputs/K2_K3_STEP_TIMING.txt | exact inputs incl. the actual K2/K3 runner outputs and their step/ack mtimes |

## Implemented vs tested vs unrun
- IMPLEMENTED (static): the single K3 change (FINDINGS_MAP_V60.md §2) and the continuation request.
- TESTED: **none at runtime.** Static: `bash -n` on driver, stubs, K1, runner, embedded bodies (LEADER, publication tail, W1 workload, the new K3 controller subshell); predicate cross-check against the actual K2/K3 outputs (ack file name exists as `.pgid/40-composition.pgid.ack`; `^stub harness .* mode=` line present in K2's 40-composition.log; `lock acquired pid=` stamp parses; runner producer L223 emits `SIGNAL SIGTERM … during step '<label>'`).
- UNRUN: all discriminators. No fake tested claim.

## Necessity reported before expansion (not changed)
K4 (`… 3`, escape mode spawns inside step 40) and N4b (`… 4`, asserts TERM during step 40) use the same elapsed-time placement; K4 is predicted to STOP the continuation for the same cause. Parent decision requested (FINDINGS_MAP_V60.md §3) — a V61 with the identical mechanism for K4/N4b would be one further exact delta.

## One smallest next action
Two independent exact-delta reviews of this packet (driver diff + requests + map against the preserved V59 failure evidence). Then either the parent authorizes the K4/N4b extension first, or grants CONTROL_REQUEST_18 as is (predicted STOP at K4). Runtime remains ungranted. No product/release clearance asserted.
