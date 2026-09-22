# SLOT REQUEST 09 — real proof B3-R55 with runner v5.5 (after request 08 passes and both independent reviews of v5.5 accept). Request, not a grant.

Inputs: runner v5.5 `c3a4d2a9…de49`; fixture `9fcc3696…b881` (unchanged); worktree d5cd9b8b clean; grant05 setup (psql 18.6, `/home/user/pg17/dist` 17.6, `worktrees/s2-runner53/node_modules` stamp `lock=62b05b90…`, prisma CLI `c2a77456…` — refused if different); launcher `s2-setup-prep/infra/launch-detached.sh` `8d0e2c7c…`.
```
cd /home/user/workspace/execution/s2-setup-prep && ./infra/launch-detached.sh start composition-r55 \
  env -u S2_RUNNER_STUBS timeout --foreground -k 60 2100 bash /home/user/workspace/execution/s2-runner55/run-composition-r55-v5.5-when-granted.sh
```
Bounds: 2100 s + 60 s grace (runner cleanup deadline 50 s enforced, starts at the first exceptional reap/signal); ≤2 CPU/<3 GB; sole heavy owner; canonical lock nonblocking through cleanup; loopback 127.0.0.1:54353; fresh `clusters/s2comp-r53` only; DB `s1_rls_s2comp_r53`; confirm literal derived inside the runner; `CHECKPOINT_DISABLE=1` stamped (`client_boundary:` line) — a real run is the first observation of inheritance into `npx`/`node`.
Prechecks (reported): lock FREE; no pg17 postgres; no 54353 listener; cluster dir absent; no `/tmp` release scratch; head/dirty/lockfile/closure; runner/fixture/prisma hashes; PORT/NS literals; toolchain stamp.
Positive: `RECEIPT.txt` `receipt_status=ok final_exit=0 first_exit=0 cleanup_exit=0`; harness `== 68 passed, 0 failed`; discriminator 0 (S1 interprets); stop census empty; `survivors=none`; lock FREE after exit; sentinel 0; owned groups `[none]`, retired list present.
Negative/abnormal: first failing step preserved in `first_exit`; TERM → 143; failed reap → 72 + QUARANTINE, fixture left running, no further slot; stop/status leak or 124 → 71; deadline → 71; receipt failure → 71 (never 0). Cluster retained after any outcome; destroy never called (R53-A-05 hold). B-07 real-mode assumptions (pg_ctl detach, engine children) read from the stamp.
Success does not prove: hosted/customer/native acceptance, S1 discriminator interpretation, anything about processes outside the scoped no-detach claim.
