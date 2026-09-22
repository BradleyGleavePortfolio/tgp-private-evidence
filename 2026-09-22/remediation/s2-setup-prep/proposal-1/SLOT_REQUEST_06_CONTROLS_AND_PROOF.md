# SLOT REQUEST 06 — (a) no-DB controls for v5.3.1 + fixture guard, then (b) real proof B3-R53. Request, not a grant. Frozen 2026-09-22.

Ordering: **06a may run any time (no setup needed); 06b only after request 05 succeeded AND both independent frozen-packet reviews are accepted.** Neither is authorised by the preparation brief.

## 06a — bounded no-DB controls (≤ 60 s total, lane-private lock, temp paths, one at a time)
Inputs: runner v5.3.1 `fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925`; fixture `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881`; driver `controls-proposed/run-runner-controls-v531.sh` `759d958f…09ba`; stubs byte-identical to s2-runner53 (`controls-proposed/stubs/SHA256SUMS.stubs-copied`); fixture driver `controls-proposed/run-fixture-lockcheck-controls.sh` `84f988aa…a3b9`.
```
cd /home/user/workspace/execution/s2-setup-prep/controls-proposed
bash run-fixture-lockcheck-controls.sh          # F1–F5, expected < 3 s
bash run-runner-controls-v531.sh                # K1–K6 against v5.3.1, historical total 30.85 s
```
Expected: F1 acquired/0, F2 inherited fd9/0, F3 busy/75, F4 different-file not mistaken/0, F5 url `127.0.0.1:54353`; K2 `final=0 first_exit=0 cleanup_exit=0 … refusal_hosted=64 refusal_noconfirm=64`, K3 `final=143 … composition=interrupted(TERM)` with stamp order SIGNAL < REAP ok < fixture stop, K4 `cleanup_exit=72 reap=FAILED fixture_stop=REFUSED` + `QUARANTINE.txt`, K5 `final=71 first_exit=0`, K6 `final=3`. Any miss → one-strike stop; outputs under `controls-proposed/results/` and `runner-selftest-r531/`. Canonical lock never touched; owned survivors killed by recorded pid only.
Not covered by 06a: real-mode refusal branches, fixture D3–D6 lifecycle refusals (need PG + canonical lock; see REPORT §5 F6–F9 and flag 3).

## 06b — real proof B3-R53 (after 05 + reviews)
```
cd /home/user/workspace/execution/s2-setup-prep && ./infra/launch-detached.sh start composition-r53 \
  env -u S2_RUNNER_STUBS timeout --foreground -k 60 2100 bash /home/user/workspace/execution/s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh
```
- Bounds unchanged from 03/03A: 2100 s + 60 s kill grace; runner cleanup worst case 48 s (margin 12 s); ≤2 CPU / <3 GB; sole heavy owner; loopback `127.0.0.1:54353` only; fresh `/home/user/pg17/clusters/s2comp-r53` only; DB `s1_rls_s2comp_r53` (+`_lock`); confirm literal `DESTROY-127.0.0.1:54353/s1_rls_s2comp_r53,s1_rls_s2comp_r53_lock` is derived inside the runner, never passed in.
- Launch prechecks (reported, not assumed): `check-lock.sh` FREE; no pg17 postgres; no 54353 listener; `clusters/s2comp-r53` absent; `/tmp` release scratch files absent; head d5cd9b8b clean; runner sha `fb0d7ce4…`; fixture sha `9fcc3696…` and literal `PORT=54353;`/`NS=s2comp-r53`; setup-30 stamp `lock=62b05b90…`; toolchain stamp line present (uutils timeout expected).
- Steps: guard spec → refusals 64/64 (hosted URL, no confirm) → fixture init (inherits fd 9) / start / status → real 164+1 composition (harness, 68 checks) → S1 56fb0d22 discriminator (S1 interprets) → cleanup: owned-work reap check → bounded fixture stop (20+3 s) → status → survivor/listener/lock proof.
- Positive: `exit-codes.txt` `final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok … fixture_stop=0 survivors=none`; harness `== 68 passed, 0 failed`; discriminator exit 0; `check-lock.sh` FREE after exit; sentinel `runs/composition-r53.exit` = 0.
- Negative/abnormal (all visible, never generic): first failing step → `first_exit=<code>` and the runner stops after that step (cleanup always); outer TERM → `interrupted(TERM)`, `first_exit=143`, launcher sentinel 124; failed reap → `cleanup_exit=72`, `QUARANTINE.txt`, fixture left running, **no further slot until the parent inspects**; stop failure/survivor → 71. Cluster `s2comp-r53` is retained after any outcome (stopped when stop succeeded); destroy is never requested by the runner.
- Output: `execution/s2-setup-prep/composition-r53/<utc>/` (stamp.txt, exit-codes.txt, 10–51 logs, harness/, s1-r4/, SHA256SUMS) + `runs/composition-r53.{pid,log,exit,cmd}`.
- No source/runner/fixture change after grant without re-attribution and a new grant. No retry.

## Success does not prove
Real release composition acceptance beyond the 68 checks on this fixture, S1 discriminator interpretation (S1's), hosted enforcement, production safety, customer acceptance.
