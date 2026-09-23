# S3 FINAL-HEAD-B — final revision (all-evidence, exact-head scoped verdict)

Reviewer B `audit_s5_failure_lens_b_mue9oser`, parent EXEC-6c2a68ac. Same review as the interim packet `audits/s3-final-head-b/` (MANIFEST `382bdfee3473543b…`, REPORT `98258fd9…`, FINDINGS `1eaa27e4…`), whose bytes are preserved unchanged; this subpacket only appends the composed-proof result portion and the verdict the interim withheld. Scope: `S3_FINAL_HEAD_REVIEW_SCOPE.md` (`f7230b0f…`). Method: hashes, `diff`, file reads, read-only Git object reads (`GIT_OPTIONAL_LOCKS=0`). No runtime, probes, locks, worktree/index writes; no peer or parent conclusion read (RESULT.md of the executor was hashed and its claims re-derived from raw files, not adopted).

## 1. Source and targeted portions — already complete, not repeated

Interim verified facts stand (head `be0ba827` = tree `a584a1b9`, parents `d5cd/5c7b`; matrix 38/38/10/0; 10 changed paths inspected; failures 03 status 1 and 08 raw 127 preserved with 03R/08D separate; validation packet `1513911d…` 27/27, bundle `d204a582…`, 31 suites / 825 tests). Re-read now: HEAD `be0ba827`, tree `a584a1b9`, porcelain 0, `node_modules/.package-lock.json` `05bc530a…` — unchanged through the composed run.

## 2. Composed-proof result packet `s3-composed-proof-result-02/` — actual inputs

- `MANIFEST.sha256` sha256 `2d4615e776ce3a7c…`, 118 entries, 118/118 OK, non-self-including (119 files = 118 + manifest).
- `runner-output/` is a byte-identical copy of the original lane `execution/6c2a68ac/s3-composed-proof/composition-s3/20260923T174228Z/` (`diff -r` clean); inner `SHA256SUMS` (90 lines) verifies in both places; `SHA256SUMS.outer` (2 lines: SHA256SUMS `c3ccc3fa…`, RECEIPT `046bc10b…`) verifies; RECEIPT `inner_manifest_sha256` = `c3ccc3fa…`.
- Block: `block.granted.txt` == `block.executed.txt` (cmp identical) == the fixed scope block (`cd /home/user/workspace && env -u S2_RUNNER_STUBS CHECKPOINT_DISABLE=1 timeout --foreground -k 60 2100 bash <absolute runner>; echo "runner=$?"`); `caller.sh` wraps exactly that block with `export GIT_OPTIONAL_LOCKS=0` and a pre-launch hash echo (closes CP-04 of the composed-proof-b packet). Raw console `logs/caller.console.log` sha256 `7d048ded…` = value recorded in `90-postclosure.txt`; it shows `S2_RUNNER_STUBS=unset`, `runner_sha256=e876f48c…`, `fixture_sha256=9763698b…`, `runner=0`, `CALLER_DONE`.
- Runner self-stamp (`stamp.txt`): `runner_sha256=e876f48c…` (populated — S2 RB-01 closed), `head=be0ba827… tree=a584a1b9… dirty_lines=0`, `expect_head` equal, `lock_sha256=b7fed5ed…`, `installed_graph … sha256=05bc530a… expect=05bc530a…`, `prisma_cli_sha256=c2a77456…`, `fixture_sha256=9763698b… expect_fixture=9763698b…`, `installed_versions: prisma=6.19.3 client=6.19.3 deepmerge_ts=8.0.0`, `harness_sha256=c766a8d9…`, `release_sh_sha256=8831f8f7…` (both identical to the S2 accepted stamp), lane `NS=s3comp-be0b DB=s1_rls_s3comp_be0b PORT=54354`, canonical lock acquired 17:42:28Z and HELD through cleanup, closure files identical to be0ba827.
- Step outcomes from the step logs / stamp, not from the summary: 10 guard-spec exit 0 `72 passed, 0 failed`; 20 `exit=64` URL_HOST refusal; 21 `exit=64` CONFIRM refusal; 30 precheck (cluster dir absent, no 54354 listener, no scratch files) then fixture-init 0; 31 fixture-start 0 (PostgreSQL 17.6, `cluster=s1-disposable-pg17`, datadir `clusters/s3comp-be0b`, dbs postgres/template0/template1 only); 32 running; 40 composition exit 0 `68 passed, 0 failed (server 17.6, head be0ba82)`; 45 discriminator exit 0 `48 passed, 0 failed (… scoped_status=clean)`; 50 fixture-stop 0; 51 `no server running`; survivors none; `exit-codes.txt`: `final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none`; RECEIPT `receipt_status=ok final_exit=0`; PUBLICATION `publication_status=ok process_exit=0 receipt_final_exit=0` (17:44:07Z).
- Harness header (`harness/harness.log`): `head=be0ba827… tree=a584a1b9… parents=d5cd9b8b… 5c7b42b3…`; `package-lock.json` sha256 `b7fed5ed…` blob `354de3da…`; `prisma_cli=…/worktrees/s3-prep2/node_modules/prisma/build/index.js sha256=c2a77456…`; prisma 6.19.3 / client 6.19.3 / Node v20.20.1; psql 18.6 client against server 17.6 (same as S2).

## 3. S2 comparison — re-derived independently

Baseline: accepted S2 real run `s2-real-composition-result/runner-output/` (MANIFEST `bbde4b0b…`). My own normalisation (mask UTC timestamps, 40/64-hex hashes, short hashes, durations, pids, NS/DB/port, machine/git ids) of the `[release]` lines of the ten cases:

| Case | S2 lines | S3 lines | normalised diff lines | release_sh_exit S2 → S3 |
|---|---|---|---|---|
| C0 | 16 | 16 | 0 | 1 → 1 |
| C0b | 16 | 16 | 0 | 1 → 1 |
| C1 | 26 | 26 | 0 | 0 → 0 |
| C2 | 26 | 26 | 0 | 0 → 0 |
| C3 | 30 | 30 | 0 | 1 → 1 |
| C4 | 26 | 26 | 0 | 0 → 0 |
| C5 | 30 | 30 | 0 | 1 → 1 |
| C5r | 26 | 26 | 0 | 0 → 0 |
| C7 | 21 | 21 | 0 | 1 → 1 |
| C8 | 26 | 26 | 0 | 0 → 0 |

All ten release logs report `prisma_cli = prisma 6.19.3`. Masked `harness.log` diff vs S2 contains only: lane output paths, worktree path `s2-runner53`→`s3-prep2`, the second parent hash (merge commit), `package-lock.json` hash `62b05b90…`→`b7fed5ed…`, and `/tmp` scratch dir names. `exit-codes.txt` differs only in `cleanup_seconds` 0.56→0.54. Expected deltas from the request's comparison template (lock hash, deepmerge-ts 7.1.5→8.0.0, `installed_graph`/`installed_versions` lines replacing `install_stamp:` lines) are exactly the deltas present; nothing else differs.

## 4. Pre-launch history preserved

- First activation stopped before the block: `s3-composed-proof-result/` (MANIFEST `e04842cc…`, 5/5 OK) records the five fixed-path release.sh scratch files present in `/tmp` (mtime 17:07:17Z), which the unchanged harness `test/release/s1s2-composition.sh:75` refuses with exit 70. `block executed: NO; caller.sh written: NO`. Origin traced by me: `scripts/release.sh` (S1S2-preserved blob) writes `/tmp/release_verifiers_discovered.txt` and `/tmp/prisma_verifier.log` at fixed paths; the targeted validation step 14 Jest run (`14-jest-targeted.log`, release.sh spec suite) executed release.sh under stubs at ~17:07Z and left them. Sequencing interaction between two granted lanes, not a source defect.
- `s3-scratch-preservation/` (SHA256SUMS `69a1da31d635de18…`, 11/11 OK): `mv -n` of exactly those five files, hashes identical to the collision record (`e3b0c442…`, `cf6904c8…` ×2, `69fc75c6…`, `3313072d…`), inode/mode/mtime recorded, `expected.sha256 == files.sha256`. Preflight-02 confirms all five absent before launch and 90-postclosure confirms absent after the run (harness cleans its own scratch).
- Accountable closure: `90-postclosure.txt` 17:44:37Z–17:44:38Z (postmaster.pid absent for both clusters, no 54354 socket in `/proc/net/tcp{,6}`, lock fd holders 0, source unchanged head/tree/porcelain/lock/installed-graph, index sha unchanged from preflight). The "re-confirmed 17:47:20Z" statement exists only as the parent's status line in `S3_COMPOSED_PROOF_RUNTIME_GRANT.md` / `REACTIVATION_02.md`; it has no receipted read inside the 118-entry packet and is therefore recorded as parent statement, not verified here (no bearing on the run's evidence).
- Original 03 `step_status=1` and 08 raw 127 failures remain recorded as failures (interim FHB-01/02); nothing here re-labels them.

## 5. Verdict — exact head, scoped

For head `be0ba8274e486dee77f15d18fe367a13ff08ecf5` / tree `a584a1b95423f95dae8daabf673ef3776604acbb` only:

**ACCEPTED as S3 integration into the S1S2 line at this exact head** — source review, targeted validation (31/825) and the single real composed proof (guard 72/72, composition 68/68, discriminator 48/48, receipt/publication ok, ten release cases identical to the accepted S2 run after normalisation, no survivors, source unchanged through the run) are all consistent; no A- or B-class finding in any portion. C-class items (interim FHB-01…04; composed-proof CP-01…05; CF-01…03 below) are recorded, none requires action before this acceptance.

Not covered by this verdict: any remote/hosted environment, product/customer acceptance, deployment, any other head or branch, or any future change to `node_modules`/toolchain. The verdict is bound to the input seal in `INPUTS_VERIFIED_FINAL.sha256` (51 lines).
