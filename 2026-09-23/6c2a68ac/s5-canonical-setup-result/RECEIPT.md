# S5 canonical setup — bounded receipt (one granted execution)

Executor `repair_s5_binding_mue9vjso` (not an independent auditor). Grant `S5_CANONICAL_SETUP_GRANT.md` sha256 `73d19856950578dfac6518f486443afeafcbfcb471629ddca7d1735f68ebaaa5`; activation `S5_CANONICAL_SETUP_ACTIVATION.md` `7b8e03ae93761fa010f51ddf3cf81a1782ed2a2908467c0e178130bcc1c8c906`. Launched 17:51:45Z, launcher returned 17:57:19Z, slot released 17:59:03Z (`RUNTIME_RELEASE.txt`). One attempt; no retry, signal, recovery, marker action, chmod, reinstall, hook or Prisma generation.

## Statuses, kept separate (activation §record separately)

| layer | actual | source |
|---|---|---|
| **launcher actual wait** (direct `setsid -w env … bash launcher` return in the detached caller) | **90** | `caller.receipt`, `launcher.raw_wait_status` |
| **launcher published final** | `LEASE_RELEASED how=session-live-after-runner-then-empty raw=observed 0 cleanup=escalated(rc=0) publication=ok recovery=none inner=[1932] final_rc=90` | `evidence-copy.s5-r4/LEASE_RELEASE`, `logs/setup-exclusion/launcher.EXIT_RECORD` |
| launcher raw observation of runner leader (pid 1583 = gate→`timeout`) | `RUNNER_RAW observed rc=0` | launcher.EXIT_RECORD 17:57:19Z |
| launcher first census after runner exit | `census=live detail=[1583:live 1932:empty]` → one escalation `GROUP_REAPED pgid=1583 how=group:1` → `AFTER_ESCALATION census=empty detail=[1583:empty 1932:empty] reap_rc=0` | launcher.EXIT_RECORD |
| **runner FINAL** | `FINAL rc=0`; `FIRST_EXIT npm-ci rc=0 how=exited`; `CLEANUP_FAILURES=0`; ancestor inventory `d0a75154…` UNCHANGED; `final census RETIRED id=1932` | `logs/setup-v1/setup.EXIT_RECORD` |
| **npm child raw** (pid 1932, own session 1932) | `raw=observed 0 validation_rc=0 how=exited state=released`; `added 1117 packages in 5m`; npm debug log 1298 lines (deprecation warnings only) | `attempts/attempt-4ScKZr/EXIT`, `setup.npm-ci.out`, `npm-logs/` |
| runner cleanup | `npm-ci cleanup_exit=0 group_signal=empty`; after-checks rc 0 (dirty status/fingerprint unchanged, no hooks, strict resolution OK, generated client absent) | setup.EXIT_RECORD, `setup.after.txt`, `setup.module-paths.txt` |
| **lease** | HELD 17:51:45Z token `20260923T175145Z-1521-15879` → RELEASED 17:57:19Z on positive empty census; `LEASE_HOLDER state=RELEASED(session-live-after-runner-then-empty)`; no SELF_HOLD, no QUARANTINE | `LEASE_HOLDER`, `LEASE_RELEASE` |
| launcher stdout/stderr | both empty | `launcher.stdout`, `launcher.stderr` |

**Runner 0 is not launcher 0.** The launcher's final is exceptional 90: after the runner leader (1583) exited 0, the launcher's typed census found one member still live in outer session/pgid 1583 (identity not recorded by the frozen launcher; inner npm session 1932 was already empty), escalated once inside its own outer session (TERM to group 1583, `how=group:1`), re-censused positive empty, and released. The executor did not identify or signal anything; per the activation this is not normal setup PASS and is left to the parent's evaluation.

## V32 binding as observed in canonical use
Runner START (its first write): `START pid=1629 pgid=1583 ppid=1583 token=20260923T175145Z-1521-15879 runner_sha256=61b565e4…` — pgid equals the launcher's SESSION and the token equals the launcher's TOKEN; INHERITED line present with the same token; launcher `runner=[released=1 final=0 unpreserved=0 cleanup_failures=0]` (record bound as this attempt's).

## Grant acceptance clauses vs actual

| clause | actual |
|---|---|
| attributable raw npm 0 | yes (1932, adopted attempt-4ScKZr) |
| runner FINAL 0 with cleanup/ancestor checks satisfied | yes |
| **launcher raw/final 0** | **raw observed 0; final 90 (exceptional, escalated once) — NOT met** |
| valid released lease with exact outer/inner sessions empty | yes (positive empty census 1583/1932; postrun no member, no lock fd holder) |
| unchanged product/index/lock/fingerprint | yes: HEAD 143d451e, tree d0e122d3, lock blob 354de3da / sha256 b7fed5ed, patch c36258b3, fingerprint 6850b32e, index diff 0, status = pinned two files (`POSTRUN_OBSERVATIONS.txt`) |
| modules resolve inside this worktree with all strict pins | yes: 12/12 OK (jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, @prisma/client 6.19.3, prisma 6.19.3, lefthook 2.1.9, eslint 10.5.0; prettier absent as expected) |
| no hooks, no generated Prisma client | yes (pre-commit absent in worktree and common git dir; `.prisma/client` absent) |

Installed state: `worktrees/s5-r4/node_modules` 651 top entries, 463,269,112 bytes, `.package-lock.json` sha256 `05bc530a…`. Preserved as-is.

## Preconditions (PRECONDITIONS.txt, 17:51:16Z)
All pins matched before launch; `execution/s5-r4` absent; worktree node_modules absent; `/home/user/package.json` absent; no pre-commit hook; uid 2000; job control off; 6.6 GB free / 7.7 GB available RAM; node v20.20.1, npm 10.8.2, git 2.53.0, uutils timeout 0.8.0, util-linux setsid/taskset 2.41.3, procps 4.0.4; no `S5X_*`/`S5_LEASE_INHERITED` in the launching environment (caller unsets and records `[]`); source seal `addc713d` verified before and after.

## Writes
Driver-side: `worktrees/s5-r4/node_modules/**` (npm ci), `execution/s5-r4/**` (launcher/runner records), the canonical lock via the launcher only, npm cache/registry reads. Executor: only `execution/6c2a68ac/s5-canonical-setup-result/**` (`caller.sh` 2f1a338d…, `COMMAND.txt`, `PRECONDITIONS.txt`, `caller.receipt`, `caller.out`, `launcher.stdout/stderr/raw_wait_status`, `POSTRUN_OBSERVATIONS.txt`, `RUNTIME_RELEASE.txt`, immutable `evidence-copy.s5-r4/` == canonical EX by `SHA256SUMS.canonical-ex.s5-r4` (15 files), this receipt, manifest `SHA256SUMS.s5-canonical-setup-result` non-self-including). Nothing in `execution/s5-r4` or the worktree was modified by the executor; no product source/index/Git/hook/Prisma/private-checkout/remote write.

## Nonclaims
Not T0, real DB, integration, product clearance, deployment or customer proof. The transient live member of session 1583 at 17:57:19Z is unidentified (the frozen launcher records only the count); the executor performed no archaeology. Executor runtime identity is unasserted telemetry. Parent evaluates the exceptional-90 substrate; no rerun or audit is implied by this receipt.
