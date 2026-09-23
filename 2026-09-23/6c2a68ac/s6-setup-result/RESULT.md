# S6-SETUP actual result — one canonical launch of the frozen setup composition (EXEC-6c2a68ac; runtime RELEASED)

Executor: `restore_s6_substrate_mue9osen`, sole canonical runtime (requested Claude Fable 5 / High; not observable). Grant: `S6_ACTUAL_SETUP_AND_C6_GRANTS.md` (working-tree sha256 `697fa1c6…5c0a`, SETUP ACTIVE) + `S3_TARGETED_RESULT_AND_S6_SETUP_ACTIVATION.md` (`1324fb0e…4301`), private HEAD acebe867 at census. Source: sealed packet `001b840f…` 28/28; launcher `6035a8f4…` + colocated runner `8a5a5161…` (PIN_RUNNER match), OWN-BLOCK `4aebf96f…`. Executed once: launch 2026-09-23T17:16:04Z, release 17:22:37Z. No retry, no manual signal, no lock probe, no marker/cleanup action, no C6, no outer timeout, no observer. Sole writes only: worktree `node_modules`, `execution/s6-diagnostic/**` (launcher/runner records, npm logs), canonical lock via the launcher, this packet.

## 1. Command actually executed (`LAUNCH.txt`)

`setsid nohup env CHECKPOINT_DISABLE=1 S6_SETUP_GRANT=granted-by-parent bash /home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/launch-s6-setup-exclusion.v1.sh > execution/6c2a68ac/s6-setup-result/launcher.out 2>&1 < /dev/null &` from `/home/user/workspace`, S5X_*/S6_LEASE_INHERITED/S6_C6_GRANT unset. Launcher pid 18155 = own session/pgid 18155, ppid 1, fd 9 → canonical lock (observed read-only). `launcher.out` is empty (0 bytes; all launcher output goes to its records).

## 2. Preconditions at 17:15:37Z (`PRECONDITIONS.txt`) — all held

Worktree d51a1910 / tree 62bf67b8, porcelain 0, lock blob 6c56385d / sha 840be0b8, `node_modules` absent, hooks 0; `execution/s6-diagnostic` absent (fresh), no EXIT_RECORD/LEASE_HOLDER, all four marker paths absent, `/home/user/package.json` absent; uid 2000 non-root; monitor off; node v20.20.1, npm 10.8.2, setsid/timeout(uutils 0.8.0)/taskset/flock/pgrep/ps present; disk 7.7 G avail, mem 7.7 G avail, 2 cpus; ancestor `/home/user/node_modules` 210 entries inventory `d0a75154…`; one census: only the platform code-mode daemon (node, `/opt/code-mode`), no npm/Jest workload, nothing signalled; canonical lock file existed (0 bytes; not opened).

## 3. Actual statuses (separated; verbatim records in `evidence/`)

| Layer | Fact | Source |
|---|---|---|
| npm child (pid 18493, own session) | **raw 0**, `how=exited`, 386 s (17:16:05→17:22:31); "added 1099 packages in 6m"; `cleanup_exit=0 group_signal=empty`; attempt `attempt-cXTgb8` IDENTITY published, adopted, `EXIT raw=observed 0 validation_rc=0` | `evidence/runner/setup.EXIT_RECORD`, `attempts/attempt-cXTgb8/{IDENTITY,ADOPT,EXIT}`, `setup.npm-ci.out` |
| runner (pid 18266, session 18219) | START `pgid=18219 token=20260923T171604Z-18155-14635`; INHERITED fd 9 binding line; provenance rc 0; after-checks rc 0; `FIRST_EXIT npm-ci rc=0 how=exited`; ancestor inventory before = after `d0a75154…` **UNCHANGED**; `CLEANUP_FAILURES=0`; tree_status_lines 0; **`FINAL rc=0`** | `setup.EXIT_RECORD`, `setup.provenance.txt`, `setup.after.txt` |
| strict resolution | **20/20 OK**, all inside the worktree `node_modules`: react 19.2.3, react-test-renderer 19.2.3, react-native 0.85.3, @testing-library/react-native 14.0.0, @tanstack/{react-query, query-core, react-query-persist-client, query-persist-client-core, query-async-storage-persister} 5.100.14, @react-native-async-storage/async-storage 3.1.1, jest-expo 56.0.4, jest / jest-circus / jest-runtime / @jest/core / babel-jest 29.7.0, @babel/core 7.29.0, babel-preset-expo 56.0.15, zustand 5.0.13, scheduler 0.27.0 | `setup.module-paths.txt` |
| launcher (pid 18155) | `LEASE_HELD` → `RUNNER_LAUNCH pid=18219 confirm_rc=0 adoption=published state=released` → **`RUNNER_RAW observed rc=0`** → `SESSION_CENSUS census=live detail=[18219:live 18493:empty] inner=[18493] runner=[released=1 final=0 unpreserved=0 cleanup_failures=0]` → `SESSION_LIVE after runner exit` → one escalation inside the owned outer session: `GROUP_REAPED pgid=18219 how=group:1` (TERM sufficed; no KILL) → `AFTER_ESCALATION census=empty detail=[18219:empty 18493:empty] reap_rc=0` → **`LEASE_RELEASED how=session-live-after-runner-then-empty raw=observed 0 cleanup=escalated(rc=0) publication=ok recovery=none inner=[18493] final_rc=90`**; `LEASE_HOLDER state=RELEASED(...)`; `LEASE_RELEASE` receipt valid (token/holder/session/inner/census/runner fields) | `evidence/launcher/logs/launcher.EXIT_RECORD`, `LEASE_HOLDER`, `LEASE_RELEASE`, `attempts/attempt-40uw4e/{IDENTITY,ADOPT}` |
| closure (17:25:13Z) | no process in sessions 18155/18219/18493; no process holds an fd on the canonical lock; no npm/Jest/node workload; launcher exit therefore = its `exit 90` (not directly waited — detached transport; the `final_rc=90` in LEASE_RELEASE/EXIT_RECORD is the launcher's own published exit code) | `POST_CLOSURE.txt` |

## 4. Acceptance criteria vs observed (grant "Stage S6-SETUP")

| Criterion | Observed | Met |
|---|---|---|
| actual npm raw 0 | 0 (`how=exited`) | yes |
| cleanup 0 | runner `cleanup_exit=0`, `CLEANUP_FAILURES=0` | yes |
| unchanged within-run ancestor inventory | before = after `d0a75154…`; 210 entries after | yes |
| clean product tree / lock | porcelain 0 (incl. `--untracked-files=all`; `node_modules` gitignored), lock sha 840be0b8 unchanged, `.git/index` sha unchanged (`4b37d9b7…`), HEAD/tree unchanged | yes |
| all 20 strict module resolutions inside the worktree | 20/20 OK | yes |
| runner FINAL 0 | `FINAL rc=0` | yes |
| launcher actual raw 0 | `RUNNER_RAW observed rc=0` | yes |
| launcher final 0 | **`final_rc=90`** (exceptional path `session-live-after-runner-then-empty`) | **NO** |
| valid release | `LEASE_RELEASE` published, `publication=ok`, holder state RELEASED, census empty | yes |
| no attributable survivors | after escalation census empty; post-closure sessions empty; no fd on lock | yes |

The composition did what its frozen source specifies for a `live` census after the runner leader exited: no release on a live outer session, one TERM→(KILL if needed) escalation strictly inside the exact owned OUTER session (inner session 18493 was already `empty` and was never signalled; the holder never signalled itself), re-census, release only on `empty`, with the exceptional-path code 90 (raw 0 preserved separately in `raw=observed 0`). Identity of the one live member of session 18219 at 17:22:37Z is **not recorded** by the frozen primitive (it records the number of signalled groups, `group:1`, not pids/commands); the runner's only background process is the npm gate (session 18493, empty), and the runner's `FINAL rc=0` was written in the same second as the census. I do not assert what the member was. This is a factual deviation from the literal "launcher final 0" criterion for the parent to evaluate; nothing was retried.

## 5. Lifecycle / hook / network output (recorded honestly)

- npm log (`evidence/runner/npm-logs/2026-09-23T17_16_05_313Z-debug-0.log`, sha256 `7497495d…8464`, 233,769 bytes): 631 registry `GET 200` fetches from `https://registry.npmjs.org/` (cache `/home/user/.npm`); exit 0.
- Lifecycle scripts executed (no `--ignore-scripts`, as granted): exactly one — `@sentry/cli@2.58.4 postinstall node ./scripts/install.js` `{ code: 0 }`. No `prepare`/`preinstall` runs logged.
- Git hook metadata: `.git/hooks` active 0, `core.hooksPath` unset, `.husky` absent — no local hook installation was produced.
- Warnings: `EBADENGINE` for `@testing-library/react-native@14.0.0` (requires node ^22.13 || >=24; current v20.20.1) — install proceeded; 11 distinct `deprecated` warnings (glob 7.x, rimraf 3, inflight, uuid 7, eslint 8.57.1, @xmldom/xmldom 0.7.13, etc.). No `error` lines.
- `node_modules`: 701 top-level entries, 607,674,962 bytes (768 MB on disk), `.bin` 45 entries; disk 6.7 G available after.
- Ancestor `/home/user/node_modules` and `/home/user/package.json` (absent) untouched.

## 6. Ownership and runtime

Runtime slot RELEASED at 17:22:37Z (launcher exit) and confirmed at 17:25:13Z: no owned process, no lock fd, no lease holder. Partial state: none (install completed; nothing to preserve beyond the records). Source packet still 28/28; `source/mobile` a5933fd6, `s6-c6-prep` 19/19 and `logs/` absent — untouched. C6 NOT started. Packet manifest `SHA256SUMS.s6-setup-result` is non-self-including. Parent evaluates §4 directly; no self-audit is claimed.
