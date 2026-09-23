# S2-V59-CONTROLS — executor result: **STOP at set `k` (aggregate 1, control K3 assertion miss)**

Grant: `tgp-private-evidence/execution/e8d546f9/S2_V59_CONTROL_GRANT.md` (sha256 3fe730589a25c950f79a5d75cfa87a0eeb357565ee4afc77e61ca77b19c0b4f1; sha1 150ee908…; git blob 3c1fc536…), activated by parent mail 2026-09-23 after S5 slot closure. Request: frozen `execution/e8d546f9/s2-v59/CONTROL_REQUEST_16.md`. Candidate `SHA256SUMS.outer` 4341ce30553bf950c32b40ef0f6466502bd2f189c99643733fa141dc5bd08bb5 16/16 pre and post. Final audits verified: A `audits/s2-v59-a/MANIFEST.sha256` abbf2c34…, B `audits/s2-v59-b/MANIFEST.sha256` 1a325a4c…. Executor only; no source read for judgement, no repair, no retry.

## Outcome (raw, unchanged)
| set | budget | raw rc | disposition |
|---|---|---|---|
| probe | 20 | **0** | accepted |
| wdtest | 20 | **0** | accepted (watchdog TERM→KILL escalation exercised against validated authority 9157; all W1 predicates PASS) |
| wdcancel | 20 | **3** | accepted — the documented standalone exception (driver cancelled itself at t=18.06 s; controller `p9422:340219` ended; census empty) |
| k | 60 | **1** | **STOP** — K1 PASS, K2 PASS (all steps, refusals 64/64, 10 acks, fd 9 checks), **K3 FAIL** ×2, ONE-STRIKE STOP; K4–K6 NOT RUN |
| new1, new2, neg, neg2 | 60/60/90/150 | — | not run (frozen loop `break` at first non-accepted status) |

Caller stdout: `probe=0`, `wdtest=0`, `wdcancel=3`, `k=1`, `STOP at k (aggregate 1)`. START 01:36:20.971Z, END 01:37:09.509Z. Not a PASS under the grant; returned unchanged for parent disposition.

## The first failure, exactly (set k, results `k-20260923T013657Z-9623/CONTROLS_RESULT.txt` L43–57)
- Control: `K3-term-during-step40` (driver D301: `KA=8 run_runner "$RUNNER" "$OUT57" 3 STUB_HARNESS_MODE=sleep STUB_HARNESS_SLEEP=30 …` → TERM to the runner's enclosure at +3 s).
- Runner output `execution/op88/s2-v57/runner-selftest-r57/20260923T013705Z/`: `exit-codes.txt` = `final=143 first_exit=143 cleanup_exit=0 signal=TERM reap=ok cleanup_seconds=0.20 deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=interrupted(TERM) composition=notrun s1_r4_discriminator=notrun fixture_stop=notrun survivors=none`. Stamp: `SIGNAL SIGTERM at 2026-09-23T01:37:08Z during step '30-fixture-init' (pid=10936 pgid=10936); owned work halts BEFORE any fixture stop`; `HALT … reaped (wait status 0) after 0s`; `REAP ok`; `LOCK: held by runner through cleanup`; receipt/publication ok; outer manifest verifies.
- FAIL 1 (L51): expected `/composition=interrupted\(TERM\) s1_r4_discriminator=notrun fixture_stop=0 survivors=none/` in exit-codes.txt — actual `fixture=interrupted(TERM) composition=notrun … fixture_stop=notrun`. FAIL 2 (L53): `ordering signal=16 reap=19 stop=` (no fixture-stop line exists because the TERM landed before step 40/50).
- PASS around it (L45–50, 52, 54): receipt ok, publication ok, manifests re-verify, no manifest/temporary entry, signal exit recorded first with cleanup class 0, no step-40 child survives, lock held through cleanup. Owned/controller accounting clean (`recorded-owned alive after cleanup: []`, `controllers ended: census_after=[empty]`, `watchdog stopped … census_after=[empty]`).
- Executor's factual timing observation (not a disposition): the TERM (+3 s) arrived while the runner was still in step 30. Step log mtimes in the passing K2 run (`…/20260923T013700Z`): 10 @+0.49 s, 20 @+0.69, 21 @+1.85, 30 @+3.03, 31 @+3.21, 32 @+3.40, 40 @+3.59 — steps 20/21 are the REAL harness refusals (~1.2 s each on this host), so the stub runner reaches step 40 only at ≈+3.4–3.6 s, later than K3's 3 s TERM delay. In the K3 run the 30 log was written at 01:37:08.489, the TERM at 01:37:08. The runner's ownership/cleanup behaviour under that TERM was itself clean (143, reap ok, cleanup 0, lock held then released, no survivors); the miss is the control's step-40 placement expectation on this host. Any correction is a source change for the builder/reviewers, not the executor.

## Preflight / environment (all as granted)
- Worktree `worktrees/s2-runner53` HEAD d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c, porcelain empty (pre and post; `GIT_OPTIONAL_LOCKS=0`). `execution/s2-setup-prep` PRE-OK 37/37 (pre, after ENV01, post); predecessor fb0d7ce4…. `execution/op88/s2-v57` 15/15 (72b9cfb5…) pre and post, writable. Fresh setup result accepted by parent; no reinstall, no real fixture.
- ENV01 (`ENV01_RECEIPT.txt`): `chmod u+w execution/s2-setup-prep` → `mkdir runner-selftest-r531` (755 user) → restore 0555 → PRE-OK 37. Because the sequence stopped before `new1`, `runner-selftest-r531/` is still EMPTY and the V59 stubs predecessor lock file was never created. The 37 manifested files are untouched.
- Tools: bash 5.3.9(1), `timeout_impl=timeout (uutils coreutils) 0.8.0` (driver banner), flock/setsid util-linux 2.41.3, pgrep procps-ng 4.0.4, CLK_TCK 100; EUID 2000; monitor off, errexit off (START line). Pre-snapshot pattern matches: `[]` in every set.
- Caller `caller.sh`: preflight refusals + START/END lines; the CONTROL_REQUEST_16 loop is BYTE-VERBATIM (diff against the request text empty). Launched detached (`setsid -f nohup … > caller-stdout-stderr.txt 2>&1 < /dev/null`) because this executor's tool environment kills non-detached background processes at each tool-call boundary (verified earlier this session with a plain `sleep`); no outer KILL or timeout added; driver ran in the caller's session/group (pgid 8901).

## Writes and signals
- Writes: `execution/e8d546f9/s2-v59/controls-proposed/results/{probe-…,wdtest-…,wdcancel-…,k-…}` (each SHA256SUMS OK + CONTROLS_RECEIPT.txt, publication_status=ok); `execution/op88/s2-v57/runtime/test-validation.lock` (lane lock, FREE after); `execution/op88/s2-v57/runner-selftest-r57/{20260923T013700Z (K2, final 0), 20260923T013705Z (K3, final 143)}` (outer manifests verify); ENV01 directory (empty); this executor directory. Nothing else; canonical lock `execution/test-validation.lock` unchanged (size 0, mtime 00:57:42), never opened.
- Signals: only by the reviewed driver/runner mechanisms (watchdog to validated authority 9157 in wdtest; driver self-cancel + controller `p9422:340219` in wdcancel; runner TERM to its own enclosure groups in K1/K3). Executor sent none. `owned-history.txt` (k): `g9669 g9844 g10628 g10936`; no `skip-*` provenance lines were reached (K4 not run). Controller records: wdcancel `p9422:340219`; others empty.

## Cleanup / slot accounting
Post-run: no caller/driver/runner/stub/sleep/flock processes; zero zombies; lane lock FREE (`flock -n` probe on the lane-private lock only, per the driver's own method — not the canonical lock); all manifests unchanged. Slot released with attributable accounting: **STOP at k, evidence complete and frozen, nothing running, nothing repaired.**

## Truth
Executed: the one granted sequence, once, stopped by the frozen loop at set `k`. Verified: pre/post manifests and worktree, receipts, process/lock state. Not done: any rerun, predicate change, source/packet edit, or judgement of whether K3's expectation or timing is the defect (parent/reviewers). PROOF_REQUEST_17 remains HELD. No product/release clearance follows. V59 source stays frozen.
