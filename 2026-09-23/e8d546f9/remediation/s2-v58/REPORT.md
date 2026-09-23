# S2-V58 — REPORT (T4 Fable sole writer, lane execution/e8d546f9/s2-v58)

Purpose: smallest execution-layer successor of frozen V57 (SHA256SUMS.outer 72b9cfb5…) closing ONLY audit S2-V57-A findings A01..A05 (`execution/e8d546f9/audits/s2-v57-a/AUDIT.json` b519ba6e…, manifest 06a2705a…). Product d5cd, runner v5.7, v5.3.1 predecessor, K1 mechanism, V57 lane, audits: untouched. No controls/probes/lock/install/network/DB/process control/commit executed. Setup sources and worktrees not touched. Review B not read (not frozen at build time).

Builder identity: requested Claude Fable 5 / High per scope; observable identity is an API assistant whose model/version and reasoning setting are not observable at runtime. No independent audit is implied by this report.

## Frozen delta
| File | sha256 | vs V57 |
|---|---|---|
| controls-proposed/run-controls-v58.sh | 1e2e32eb15a7d045dd0f398d96997a65eea09a21575be74387dad5cc9cd277ef (507 lines) | v57 driver 698bbb17… (470); `diffs/controls-driver-v57-to-v58.diff` (95 changed lines, 13 hunks) |
| controls-proposed/stubs/harness.sh | bc9704e639da76915d30d30aceac7120dbd35946f1f2a37b96f5ef9a1593dc5c | v56/v57 d519f41b…; `diffs/stubs-harness-v57-to-v58.diff` (12 lines: A04 additive `start=` provenance + helper + comment) |
| controls-proposed/stubs/fixture.sh | 5560c9f74979b886f913f041057d72f0c7842e553c1f024dd2f1ecd3151dd95b | v56/v57 e415003c…; `diffs/stubs-fixture-v57-to-v58.diff` (5 lines: same) |
| run-composition-r57-v5.7-when-granted.sh | efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c | BYTE-IDENTICAL to V57 (no runner revision) |
| controls-proposed/k1-predecessor-mechanism.sh, stubs/guard-spec.sh, stubs/discriminator.sh | 3359b84a…, 6dc98ce0…, 535dc494… | byte-identical to V57/V56 |
| CONTROL_REQUEST_14.md / PROOF_REQUEST_15.md | see SHA256SUMS.outer | `diffs/control-request-12-to-14.diff`, `diffs/proof-request-13-to-15.diff` |
| FINDINGS_MAP_V58.md | finding → line → change → discriminator (A01..A05 only) | |

Edit method: mechanical copy of the V57 packet files, then targeted exact-string edits (edit tool) on the driver, two stubs and the two requests; no sed -i, no block regeneration. Diffs are the authoritative record.

## What each finding got (one line each; details in FINDINGS_MAP_V58.md)
- A01: watchdog and finish-alarm shells capture their own `$BASHPID` as the first statement and pass it to `wd_parent_ok <self>`; no assertion weakened.
- A02: N1 decoy booked as `p<pid>:<start>` through the controller mechanism, owned AND controller-listed; N1's `owned_cleanup` still ends exactly it, so N2 discrimination is restored.
- A03: predecessor's private lock `$STUBS/test-validation.lock` enumerated (new1 only), asserted from the predecessor stamp, probed at handoff (HELD → 4); predecessor bytes unchanged; new2 predecessor permission dropped (audit's nonblocker note).
- A04: stubs that spawn children publish `start=<ticks>`; the parser promotes a logged number only when the live process still carries that producer-published start identity; QUARANTINE/legacy numbers are reported (`skip-unprovable`) and never recorded. Existing `spawned pid=<n>` substrings and every K7–K10 read of them are unchanged.
- A05: `ctrl_arm` (latch before spawn) / `ctrl_book` (checked booking immediately after `&`) / `resolve_pending_controller` (finish) applied to all five controller spawns; N4's decoy is booked before its 0.2 s acknowledgement wait and stays out of owned work.

## Implemented vs tested vs unrun
- IMPLEMENTED (static): every row of FINDINGS_MAP_V58.md.
- TESTED: **none at runtime.** Static only: `bash -n` on driver, four stubs, K1, runner, and every embedded `bash -c` body (LEADER, publication tail, W1 workload, decoys, holder); A04 regex/sed pipeline and the new A03/N6 predicates exercised against literal sample strings (pure text, no process); `readlink -f` of the two lane paths (no symlink) to support the `fd9=<path>` predicates.
- UNRUN: all discriminators (probe, wdtest, wdcancel, k, new1, new2, neg, neg2) and all real proof. No fake tested claim.

## Boundary returned to the parent (decision, not a defect)
The runner is unchanged and pins its lane to `execution/op88/s2-v57` (runner L97): stub-mode outputs and the runner/driver lane lock land under that restored V57 lane (additive directories only; its 15 manifested files stay valid). The v58 driver follows the runner (`RLANE`). A single-lane arrangement would need a one-line runner edit (new runner hash) — explicitly NOT done; the parent chooses. CONTROL_REQUEST_14 enumerates the resulting write set exactly.

## Concrete open blockers (separate from the delta)
1. ENV01 unchanged: `execution/s2-setup-prep` is 0555, `runner-selftest-r531/` absent → `new1` needs that single directory made writable at grant (CONTROL_REQUEST_14 §4). Not chmod'd by the builder.
2. Real-proof preconditions (fresh PG17 + `npm ci` + install stamp with `lock=$EXPECT_LOCK_SHA`) not present/verified here (PROOF_REQUEST_15 §2).
3. Review B (S2-V57-B) not yet frozen at build time; material B findings, if any, are to be incorporated in a further exact delta only after the parent says frozen.

## Evidence preserved
V57 packet (archive and `execution/op88/s2-v57`) untouched and re-verified 15/15; audit A files untouched; `inputs/INPUT_HASHES.txt` lists every input read (25 hashes).

## One smallest next action
Two independent exact-delta reviews of this frozen packet (five diffs + FINDINGS_MAP_V58.md against S2-V57-A01..A05 and, once frozen, S2-V57-B). Then, if clean and the path arrangement is accepted, grant CONTROL_REQUEST_14 (bounded stub controls with the ENV01 directory authorization and the standalone `wdcancel=3` exception), then PROOF_REQUEST_15. No release, customer or product clearance is asserted.
