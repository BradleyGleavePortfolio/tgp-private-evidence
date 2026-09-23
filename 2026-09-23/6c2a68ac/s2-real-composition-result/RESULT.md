# S2 real composition proof — result (EXEC-6c2a68ac, revision 1, frozen)

Grant: `tgp-private-evidence/execution/6c2a68ac/S2_REAL_COMPOSITION_GRANT.md` (sha256 `7d85637447ea68f09fcf90288c0ac9f20d6a9f9ab66a7ea095ce9a89ddc8daf2`). Activation: `S2_SETUP_ACCEPTANCE_AND_REAL_PROOF_ACTIVATION.md` (sha256 `e8dcfc61585181abd674786d983b930b8aefddcb74e5068a12b5804a0aa4be7f`), private HEAD `3853035942c81c94eb8ad3c3df7d53f097006091`. Governing request `execution/e8d546f9/s2-v61/PROOF_REQUEST_21.md` (`84930d07…8639`). Sole executor `restore_s2_substrate_mue9eidh` (requested identity is not runtime telemetry, not asserted). ONE attempt, 2026-09-23 16:22:30Z–16:24:06Z. No retry, no manual signal, no destroy, no install, no network by the executor, no source/product/private-checkout edit.

## 1. Identities confirmed before launch (`00-preflight.txt`, 16:22:01Z)

V61 packet PRE-OK 20/20 (`SHA256SUMS.outer` `ed241342…7b7a`); runner `run-composition-r57-v5.7-when-granted.sh` `efa273c7de7d4bcc34b6f5be0fae74e412d73a5e82fc9e504a0e2a4c10367e1c` (read completely, 470 lines); fixture `9fcc3696…4b881` with `^PORT=54353;` and `^NS=s2comp-r53` (read completely); worktree HEAD `d5cd9b8b…`, tree `c0ab87d4…`, porcelain 0, lock `62b05b90…1390`; installed CLI `c2a77456…e1a0`; install stamp exact `lock=` line; PG 17.6 postgres/initdb pins `23cd1748…`/`b7db9bc2…`, `PROVENANCE.txt result=success`; psql 18.6; accepted setup result MANIFEST `7f1a68c0…` intact. Fresh-only: `/home/user/pg17/clusters` absent, no 54353 listener, no pg17 postgres, no release `/tmp` scratch, `composition-r57/` absent. Canonical lock file present size 0, no process had it open (read-only `/proc` fd scan — **no flock/lock probe by the executor**). 8.5 GB free, 7715 MB RAM, load 0.00. Census: platform code-mode node daemons only. `S2_RUNNER_STUBS` unset; `timeout` = uutils coreutils 0.8.0 (not GNU). Stray `0` line in the preflight is the `pgrep -c … || echo 0` idiom printing twice; `pg17_postgres_running=0` stands.

## 2. Exact invocation

`caller.sh` (sha256 `36dcde77bc0ac3adf02c16d9afc843ba4300a1b305cb24416e5447161367efd1`) exports `CHECKPOINT_DISABLE=1`, unsets `S2_RUNNER_STUBS`, stamps both, then runs the grant block **byte-identical** to the grant and to PROOF_REQUEST_21 (`cmp` OK against `grant-block.expected.txt` and `request21-block.expected.txt`; `caller-block.actual.txt` `22a29042…8284`):

```sh
export GIT_OPTIONAL_LOCKS=0
cd /home/user/workspace/execution/e8d546f9/s2-v61 && sha256sum -c --quiet SHA256SUMS.outer \
 && timeout --foreground -k 60 2100 bash run-composition-r57-v5.7-when-granted.sh; echo "runner=$?"
```

Transport (accepted): `setsid -f nohup bash caller.sh > caller-stdout-stderr.txt 2>&1 < /dev/null` from the result directory (`launch-stamp.txt`, 16:22:30Z). No supervisor, no extra timeout, no enclosure change. Caller pid 11135 (own session/group), outer `timeout` pid 11148, runner pid 11149. `CHECKPOINT_DISABLE=1` stamped in the caller's first stdout line and by the runner's `client_boundary` stamp.

## 3. Actual statuses (raw, from `caller-stdout-stderr.txt`, `exit-codes.txt`, `RECEIPT.txt`, `PUBLICATION.txt`)

- Block status printed by the grant's own echo: **`runner=0`**. Caller ended 16:24:06Z; wall 96 s (cap 2100 s not approached).
- `exit-codes.txt`: `final=0 first_exit=0 cleanup_exit=0 signal=none reap=ok cleanup_seconds=0.56 deadline_exceeded=no guard_spec=0 refusal_hosted=64 refusal_noconfirm=64 fixture=0 composition=0 s1_r4_discriminator=0 fixture_stop=0 survivors=none`.
- `RECEIPT.txt`: `receipt_status=ok`, `final_exit=0 first_exit=0 cleanup_exit=0`, `hash_rc=0`, `inner_manifest_sha256=ae04aaba30bd630b009dab14e7592f860884b2b31e385bdfa2dbf8d6362c4822`.
- `PUBLICATION.txt`: `publication_status=ok deadline_exceeded_at_publication=no`, `process_exit=0 receipt_final_exit=0`.
- Stdout last runner line: `RECEIPT: receipt_status=ok final_exit=0 first_exit=0 cleanup_exit=0  PUBLICATION: status=ok publication_file=ok deadline_at_publication=no process_exit=0`.

| Step | Raw exit | Evidence |
|---|---|---|
| 0 lock | acquired | `lock acquired pid=11149 fd9=…/execution/test-validation.lock`; head/dirty/lockfile/closure (`9742037b`) checks passed; CLI pin verified before first CLI execution |
| 10 guard-spec | 0 | `== 72 passed, 0 failed (guard spec, offline, head d5cd9b8)` |
| 20 refusal-hosted | 64 (expected) | `S1-GUARD REFUSED URL_HOST` — no DB contact |
| 21 refusal-noconfirm | 64 (expected) | `S1-GUARD REFUSED CONFIRM` — no DB contact |
| 30 fixture-init | 0 | precheck clean; `lock: … inherited fd9 from caller pid=13172`; cluster `/home/user/pg17/clusters/s2comp-r53` |
| 31 fixture-start | 0 | `PostgreSQL 17.6 … cluster=s1-disposable-pg17 datadir=/home/user/pg17/clusters/s2comp-r53` |
| 32 fixture-status | running | `pg_ctl: server is running (PID: 13230)` |
| 40 composition | 0 | `== 68 passed, 0 failed (server 17.6, head d5cd9b8)`; 0 `FAIL` lines; controls C0/C0b/P/C1/C2/C3/C4/C5/C5r/C7/C8 logs under `runner-output/harness/` |
| 45 s1-r4-discriminator | 0 | `== 48 passed, 0 failed (server 17.6, head d5cd9b8 scoped_status=clean)`; `post_tree_dirty_lines=0` |
| 50 fixture-stop | 0 | `stopped`; owned client group census empty |
| 51 status-after-stop | — | `pg_ctl: no server running` |
| cleanup | 0 | `REAP ok` (8 groups retired), `no surviving fixture/owned-work processes, nothing listening on 54353`, deadline not exceeded |

## 4. Runner output (pinned lane, untouched) and copies

Runner output `execution/op88/s2-v57/composition-r57/20260923T162230Z/` (left exactly as the runner wrote it; not modified or re-permissioned by the executor): inner `SHA256SUMS` 90 entries verifies, `SHA256SUMS.outer` verifies; only `SHA256SUMS`, `SHA256SUMS.outer`, `RECEIPT.txt`, `PUBLICATION.txt` are outside the inner manifest (as designed); `QUARANTINE.txt`, `dirty.txt`, `preexisting-tmp-LISTING.txt` absent. A mode-preserving copy is `runner-output/` here (94 files; inner and outer manifests re-verify on the copy).

## 5. Post-run accounting (`90-postrun.txt`, 16:25:02Z)

No caller/timeout/runner process alive; survivor census (fixture postgres, harness, discriminator, guard spec, psql, Prisma CLI, step leaders) empty; no `sleep 1` git-wrapper helper alive; 54353 not listening; canonical lock file present size 0, **no process holds it open** (read-only fd scan; no flock probe run). Source unchanged: WT HEAD `d5cd9b8b…` porcelain 0, CLI `c2a77456…`, V61 PRE-OK 20/20, setup-prep PRE-OK 37/37, op88/s2-v57 PRE-OK 15/15, fixture `9fcc3696…`. Outside-root platform `node_modules` 209 entries, no prisma. Fixture data dir `/home/user/pg17/clusters/s2comp-r53` and `s2comp-r53.log` remain on disk, server stopped (`postmaster.pid` absent), `/home/user/pg17/run` empty — not destroyed, per grant. No release `/tmp` scratch left. Disk 8.5 → 8.4 GB.

## 6. Qualifications / deviations (for parent judgement)

- **Runner self-stamp `runner_sha256=` is EMPTY** in `stamp.txt` (stderr: `sha256sum: run-composition-r57-v5.7-when-granted.sh: No such file or directory`). Cause: the grant block invokes the runner by relative path and the runner hashes `$0` after `cd $WT`. The V61 controls driver invoked it by absolute path, so their stamps carried `efa273c7…`. Runner identity for this run is established externally by the block's own `sha256sum -c --quiet SHA256SUMS.outer` (PRE-OK 20/20, V61 manifest `ed241342…`) executed immediately before the runner in the same block, and by the preflight hash `efa273c7…` at 16:22:01Z. Runner logic is unaffected; not a stop per the grant's stop list; executor did not alter the block to "fix" it.
- Carried from the grant: the short-lived git telemetry-wrapper helper condition — no universal process-containment claim; census after exit found none.
- Executor observations beyond the grant's literal command (all read-only, disclosed): `pgrep -fa` censuses, `/proc/*/fd` readlink scan for the lock, `ss -ltnH`, `df`/`meminfo`, `git status`/`rev-parse`, `sha256sum`, `ls`/`stat`. **No** `flock`, `kill`, `check-lock.sh`, or other lock probe.
- Preflight stray `0` line (see §1).

## 7. What this proves / does not

Actual runner 0 with real PG 17.6 fixture, real `scripts/release.sh` composition harness (68/68), S1 R4 TRUNCATE discriminator (48/48), guard spec (72/72), expected refusals 64/64, receipt and publication OK, scoped cleanup with no survivors, unchanged source inputs. It is local real composition evidence only — not merge, deployment, native importer reconstruction, customer acceptance, universal-importer completion, S1/S2 applicability disposition (parent's) or S3 integration.

## 8. Ownership

Runtime slot released at 16:25:02Z; lock file unheld; no attributable workload. Executor makes no further writes outside this directory. Parent evaluates directly.

## 9. Owned outputs

`execution/6c2a68ac/s2-real-composition-result/{RESULT.md, 00-preflight.txt, caller.sh, caller-block.actual.txt, grant-block.expected.txt, request21-block.expected.txt, launch-stamp.txt, caller-stdout-stderr.txt, 90-postrun.txt, runner-output/**}`. `MANIFEST.sha256` covers every file here except itself; directory frozen `a-w`.
