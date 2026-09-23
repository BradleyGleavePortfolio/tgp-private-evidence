# S3 composed-lock release proof — exact ONE-SHOT runtime request 01 (HELD; source-only preparation, nothing executed)

Prepared 2026-09-23 by T4 sole builder `restore_s2_substrate_mue9eidh` under `execution/6c2a68ac/S3_COMPOSED_PROOF_PREPARATION_GRANT.md` (sha256 `a2ed8526edd207d8d5b2e102a6246d4d1059807fe5fd329041a3abb8832551be`, tracked in private checkout HEAD `82b391bd`). This document is a REQUEST. It grants nothing. Execution requires two independent reviews of the changed bindings (REPORT.md §3) and a separate explicit parent runtime grant on a free canonical slot.

## 1. What one run proves (request-02 §6, verbatim intent)

Original S3 request-02 §6 (`2026-09-22/remediation/s3-composition-prep/request-02/SLOT_REQUEST_02_…md`, sha256 `3bb5d479…`): "one run of the unchanged `test/release/s1s2-composition.sh` (blob `38b70f54…`) on the committed composed head, diffing `[release]` steps, `prisma_version`, `sha256 package-lock.json` (`b7fed5ed…`) and exit codes against the d5cd B3 run. Its `PRISMA_CLI=node_modules/prisma/build/index.js` resolves `@prisma/config` → c12 → `deepmerge-ts` 8.0.0 in this tree (7.1.5 in every prior B-run)."

The composed head `be0ba827` carries the SAME harness blob `38b70f548974fcb88c24c5d5d35147ce091f11b0` (`test/release/s1s2-composition.sh`, sha256 `c766a8d9…`), the same `scripts/release.sh` blob `c86b3ab9…` and identical `prisma/`, `test/db/` and `test/release/` as d5cd (git diff --quiet: identical). Only `package.json`/`package-lock.json` (and the unrelated `scripts/check-r75.js`) differ. The run therefore isolates the changed dependency graph (lock `b7fed5ed…`, deepmerge-ts 8.0.0, exact-pinned manifests) as the only variable against the accepted S2 real proof (seal `bbde4b0b…`, head d5cd, lock `62b05b90…`, deepmerge-ts 7.1.5).

## 2. Exact candidates (frozen in this packet; hashes are the grant pins)

| Role | Path (absolute) | sha256 | Derived from |
|---|---|---|---|
| Runner | `/home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/candidates/run-composition-s3-v5.8-when-granted.sh` | `e876f48c1519004e0863321888715ad6ec2574ca55ff1f558571c61bf43ecbfd` | accepted v5.7 `efa273c7…` (+41/−17 lines; `diffs/runner.diff`) |
| Fixture | `/home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/candidates/infra/s3-fixture-be0b.sh` | `9763698b9231af15648c1179df8c99d2e848f6738469cf4ebee8bff1259de21c` | accepted `9fcc3696…` (+7/−2 lines, NS/PORT pins + header only; `diffs/fixture.diff`) |

The runner pins (all statically verified against the read-only substrate at 17:09:59Z, `parse-check/static-pins.txt`): WT `worktrees/s3-prep2`; HEAD `be0ba8274e486dee77f15d18fe367a13ff08ecf5`; TREE `a584a1b95423f95dae8daabf673ef3776604acbb`; lock `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`; installed graph `node_modules/.package-lock.json` `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`; Prisma CLI bytes `c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0`; fixture `9763698b…`; CLOSURE_REF `be0ba827…`; DB `s1_rls_s3comp_be0b`; NS `s3comp-be0b`; PORT `54354`; `CHECKPOINT_DISABLE=1` exported.

## 3. The exact command block (one shot; run at most ONCE; absolute path; no stubs)

```bash
cd /home/user/workspace && env -u S2_RUNNER_STUBS CHECKPOINT_DISABLE=1 timeout --foreground -k 60 2100 bash /home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/candidates/run-composition-s3-v5.8-when-granted.sh; echo "runner=$?"
```

Transport: the same detached `setsid -f nohup bash caller.sh` pattern accepted for the S2 real proof (caller `36dcde77…` in `s2-real-composition-result/`), with THIS block as the caller body and the caller's stdout/stderr captured in the executor's owned result lane. No added timeout, enclosure, supervisor or signal beyond the block. `S2_RUNNER_STUBS` must be unset (the `env -u` makes that explicit); the accepted S2 block did not use `env -u` — if the reviewer prefers byte-parity with the S2 block, drop `env -u S2_RUNNER_STUBS` and pre-check the variable is unset instead (either form is acceptable to this builder; the grant must fix one).

Absolute invocation makes the runner's self-stamp `runner_sha256=` populated (the S2 real run's was empty because `$0` was relative after `cd $WT`; disclosed in `s2-real-composition-result/RESULT.md`). Nothing in the runner is changed for this.

## 4. Writes (exhaustive) and what stays untouched

Runner-owned writes (created by the runner itself with `mkdir -p`):
- `/home/user/workspace/execution/6c2a68ac/s3-composed-proof/composition-s3/<UTC-STAMP>/**` — stamp.txt, step logs 10/20/21/30/31/32/40/45/50/51, `harness/**`, `s1-r4/**`, `.pgid/**`, `exit-codes.txt`, inner `SHA256SUMS`, `RECEIPT.txt`, `PUBLICATION.txt`, `SHA256SUMS.outer` (identical publication mechanism to v5.7).
- Canonical lock hold: `flock -n` on `/home/user/workspace/execution/test-validation.lock` for the whole run (exit 75 if busy — no waiting). No `.holders` append is performed by v5.7/v5.8 (unchanged).
- Fixture (via the runner only): `/home/user/pg17/clusters/s3comp-be0b/` (initdb, marker `s1-disposable-pg17`), `/home/user/pg17/clusters/s3comp-be0b.log`, socket under `/home/user/pg17/run`; databases `s1_rls_s3comp_be0b` and `s1_rls_s3comp_be0b_lock` on 127.0.0.1:54354; the harness/discriminator write only inside those databases and `$OUT`.
- Runtime executor-owned (outside the runner): its own fresh result lane (e.g. `execution/6c2a68ac/s3-composed-proof-result/**`: caller.sh, preflight, runner console, copy of runner output via `tar -cf - . | tar -xpf -`, RESULT.md, non-self-including MANIFEST.sha256, `chmod -R a-w`).

Untouched by design: `worktrees/s3-prep2` tracked files, index, Git metadata, hooks, `node_modules/**` (read and executed only; no stamp is written), `worktrees/s2-runner53/**`, `/home/user/pg17/clusters/s2comp-r53{,.log}` (stopped S2 cluster: never started, adopted, reused or destroyed — the fixture's D1 refuses any DATA other than its own NS), `execution/op88/**`, `execution/s2-setup-prep/**`, this frozen prep packet, the private archive.

## 5. Bounds (unchanged v5.7 mechanism)

Outer `timeout --foreground -k 60 2100` (TERM at 2100 s, KILL at 2160 s). Inner per-step (`run_step` bounds, unchanged): 10 guard spec 120 s; 20/21 refusals (offline string layer, `env -i`) 120 s each; 30 fixture init 120 s; 31 start 120 s; 32 status 30 s; 40 composition `BOUND40=1500` s; 45 discriminator 300 s; 50/51 stop/status inside the cleanup budgets; cleanup budgets `STOP_BUDGET=20 STOP_KILL=3 STATUS_BUDGET=5 STATUS_KILL=2 REAP_TERM_WAIT=10 REAP_KILL_WAIT=5 OUTER_GRACE=60`. The accepted S2 real run took 96 s wall (16:22:30–16:24:06Z); a fresh S3 run is expected in the same order (fresh initdb + 10 release cases + 48 discriminator checks).

## 6. Expected statuses (from the accepted S2 run; S3 must be compared, not assumed)

`runner=0`; `exit-codes.txt` = `final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok … guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none`; guard spec `72 passed`, harness `== 68 passed, 0 failed (server 17.6, head be0ba82, …)`, discriminator `48 passed`; `RECEIPT ok`, `PUBLICATION ok`; new stamp lines: `installed_graph: … sha256=05bc530a… expect=05bc530a…`, `installed_versions: prisma=6.19.3 client=6.19.3 deepmerge_ts=8.0.0`.

## 7. Stop rules (any one → stop, record raw status, do NOT rerun, return to parent)

- Pre-launch (runtime executor, read-only): candidate hashes ≠ §2; `worktrees/s3-prep2` HEAD/tree/porcelain ≠ pins (use `GIT_OPTIONAL_LOCKS=0`); `node_modules/.package-lock.json` ≠ `05bc530a…`; `/home/user/pg17/clusters/s3comp-be0b` or `.log` already present (collision); `execution/6c2a68ac/s3-composed-proof` already present with content (collision, unless the grant pre-creates it empty); canonical lock observed held (read-only `/proc` fd scan only — no flock probe unless granted); any listener on 54354 may ONLY be checked if the grant authorises that probe (otherwise the fixture's own `start` failure is the detector).
- Runner statuses: `70` refusal (pins/closure/install-binding/toolchain/fixture; 25 sites), `75` canonical lock busy (1 site), `71` receipt/publication failure or cleanup past deadline reclassified by `finish` (F05), `12` receipt self-check mismatch, non-zero `cleanup_exit`/`first_exit` propagated as `final`, `124`/`137` outer timeout, any non-zero step where S2 had 0 (or ≠64 on 20/21). Survivors ≠ `none` → stop and report; never kill by hand beyond the runner's own cleanup.
- Anything the runtime executor must do that is not in §3/§4 → C record (do not call it authorised); scope/binding conflicts → return to parent.

## 8. Report template for the eventual result (grant: "compare release steps, actual Prisma/CLI/dependency versions, lock and raw exits against the accepted S2 run")

Diff, line-for-line where the S2 baseline is in `s2-real-composition-result/runner-output/`:
1. `harness/harness.log` header block — `head=`, `tree=`, `sha256 … package-lock.json` (S2 `62b05b90…` blob a23abae6 → expect `b7fed5ed…` blob 354de3da), `prisma_cli=… sha256=c2a77456…` (expect same), `prisma_version:` (S2 `prisma : 6.19.3;@prisma/client : 6.19.3;…debian-openssl-3.0.x`), `psql=… 18.6`, `node=v20.20.1`, `== 68 passed`.
2. `harness/C*.release.log` — `[release]` line counts per case (S2: C0 16, C0b 16, C1 26, C2 26, C3 30, C4 26, C5 30, C5r 26, C7 21, C8 26) and per-line text after masking `machine_id`, `git_sha`, timestamps; `prisma_cli = prisma 6.19.3`.
3. `stamp.txt` — `prisma=` CLI `--version` output, `installed_versions` (deepmerge_ts 8.0.0 vs 7.1.5), toolchain versions, `runner_sha256=` (must be `e876f48c…`, populated).
4. `exit-codes.txt` and each step log's raw exit vs §6; `s1-r4/s1-r4-discriminator.log` 48/48.
5. State the claim narrowly: one composed-graph release-path re-observation on `be0ba827`/lock `b7fed5ed`; no universal importer, dependency-tree, production or acceptance clearance is implied.
