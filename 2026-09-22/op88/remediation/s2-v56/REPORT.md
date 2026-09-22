# REPORT — OP88-S2-V56 (S2 T4 Fable fixer): runner v5.6 + controls driver v56, static preparation only

Lane: `/home/user/workspace/execution/op88/s2-v56` (owned). Product d5cd9b8b… unchanged. No canonical state writes, no publication, no commits/hooks, no lock acquisition, no controls/client/version/install/DB/network/destroy execution. Only `bash -n` (both scripts + LEADER text) executed.

## Inputs (exact; full list inputs/INPUT_HASHES.txt, 27 entries)
- Frozen runner v5.5 c3a4d2a9a234dda141122a44d46a3902a8575001a26ffcadc2029080a768de49; driver v55 a5a2d73f8b0138362ef391c4cbd58ea846673be1846bfaf92561bde2a538312c; outer manifest 0d733299…88a4.
- Review A REPORT fb91a51dcc64b5b792a9865043f25b722cfa702434b5f49d93dded8ae18c1c97; Review B REPORT 8d35b22317b8a5c2cffe188167305efd72a79c1bd810eb5a45238bee9c718c70.
- Predecessor v5.3.1 fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925 (37-file SHA256SUMS.outer ea926206… verifies OK from its own directory).
- Bundle 3b6cee48… verified; clone `worktrees/op88-s2` at d5cd9b8b…, tree c0ab87d4…, dirty 0 (verification only, not a runner pin).

## Outputs (frozen; manifest SHA256SUMS.outer is non-self-including)
| file | sha256 |
|---|---|
| run-composition-r56-v5.6-when-granted.sh (422 lines) | 8980bca0936a34b25950f90bc97731d073c7d1dab95178ee80db8edb0d0e1de1 |
| controls-proposed/run-controls-v56.sh (385 lines) | 10c48b69f63cbc6795a6818aef5ce0aa5e7ac76a82f24af9d6dfce2ca1997de5 |
| controls-proposed/k1-predecessor-mechanism.sh, stubs/*.sh, SHA256SUMS.stubs | byte-identical to frozen v55 (3359b84a…, 535dc494…, e415003c…, 6dc98ce0…, d519f41b…) |
| diffs/runner-v5.5-to-v5.6.diff (+99/−34) | c6403b9fa26a05e8ce55ec8de9be8063b9b47d9a210d79aae126072a4a6e43bf |
| diffs/controls-driver-v55-to-v56.diff (+182/−36) | 9d6d74601924bf6120040679c9785883e79ec7fc66e27ad91cedbb3f81876a03 |
| FINDINGS_MAP_V56.md | 3eecbda6fee72f45069df954fce28a2fd7ff9f4d35d1c792a401fc1b30512306 |
| CONTROL_REQUEST_10.md | 5942481356496594a8e5959835193675cd37d628f33a4d6e181f62599cd87208 |
| PROOF_REQUEST_11.md | c6094f0c6c5f094688f58bafb06ae10cfa7034f3e34c32b7d5e9d65ac55a85da |
| checkpoint-20260922T2128Z/ | interim immutable source checkpoint (runner 059ed010…, driver cce8c326…) — superseded by the frozen files above by one fix (regular-file test on id files, N5a determinism); kept as history |

## Implemented vs tested vs unrun
- IMPLEMENTED (static): F01 IDDIR single-assignment + guard (A-01/B-01); F02 fail-closed publish→register→ack→exec leader, published-but-unadopted resolution, stub seams STUB_PUBLISH_FAIL/STUB_HOLD_ACK (A-02); F05 bounded, status-checked publication, outer manifest verified, PUBLICATION.txt, 0→71 (A-05/B-05); F06 CLI pin before `--version` (B-06); dead cleanup branch removed, unconfirmed cleanup client → leak/71 (A-06/B-04). Driver: E7 single CURRENT authority, owned watchdog sleeper + census in gate, TERM→KILL→driver-TERM escalation with `on_cancel` → finish 3 (A-03/B-03); E8 enclose() same contract, unconfirmed → STRIKE (A-02 mirror); E9 K2 predicate `owned groups [none] retired [...]`, successor-only receipt predicates, predecessor actual format (A-04/B-02); E10 bounded publication + CONTROLS_RECEIPT.txt; sets probe/wdtest/neg2 (N4, N5a, N5b, N6, N7).
- TESTED: none beyond `bash -n`. Every producer↔predicate pair cross-checked statically (FINDINGS_MAP_V56.md §C, 55 predicates).
- UNRUN: all controls (CONTROL_REQUEST_10, seven sets, stub-only) and real proof (PROOF_REQUEST_11, fresh setup grant required).

## Finding closure
All material A/B findings have an implemented change and a named discriminating control (FINDINGS_MAP_V56.md §A/§B). No majority waiver used. Pre-publication window closed by construction (no exec before ack). Residual observations OBS-1..4 recorded for reviewers (no change made).

## Deviations / notes
- Lane path: PREP names `execution/s2-runner56`; OP88 brief governs → `execution/op88/s2-v56`.
- WT/LANE/PRE_RUNNER pins unchanged (smallest delta); prerequisites absent in this sandbox are listed in CONTROL_REQUEST_10 with a PROPOSED (not applied) path amendment.
- One global rename in my owned driver used `sed -i` (`$OUT54`→`$OUT56`, 9 occurrences); all other edits via the edit tool.
- Parent environment (Bash 5.3.9, uutils timeout 0.8.0, no PG17/deps) means no setup positive is current; requests are split: safe stub controls (10) vs later setup/real proof (11).

## Blockers
No sandbox blockers for this static slice. Execution blockers: grant + environment restoration (worktree at d5cd, s2-setup-prep with v5.3.1 bytes) for CONTROL_REQUEST_10; fresh setup grant for PROOF_REQUEST_11.

## One smallest next action
Two independent exact-successor reviews of the frozen candidate (verify `cd /home/user/workspace/execution/op88/s2-v56 && sha256sum -c --quiet SHA256SUMS.outer`), then decide CONTROL_REQUEST_10.
