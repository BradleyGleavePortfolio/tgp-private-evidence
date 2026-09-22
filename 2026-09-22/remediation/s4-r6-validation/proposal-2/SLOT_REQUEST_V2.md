# S4 R6 — native validation V2 (execution-only successor; prepared, NOT executed; no grant assumed)

Successor slice **S4-R6-VALIDATION-V2**. Product head unchanged and frozen: `91990ae9aec72f47a67591892ac09fa1f59d2f16`
(tree `840fb2855953d5363fbd144e11b3f81763d9cef7`, parent `88287cff…`, base `0111be66…`, historical hooks **0/6**,
UNACCEPTED). No product/source edit. The three V1 files under `execution/s4-r6-validation/` stay immutable (their
`SHA256SUMS` still verifies); V2 lives only under `execution/s4-r6-validation/v2/`. The original R6 packet
`execution/s4-r6/` is read-only input (pins below). Frozen source audits closed R5-A-01 narrowly and requested no
analogous runtime fix; nothing here touches that question.

## V2 packet (hashes in `v2/SHA256SUMS`, non-self-including)

| file | role | sha256 |
|---|---|---|
| `launcher/s4-r6-launch-v2.sh` | exact bounded detached launcher + supervisor (the only entry point) | `13fed63063ec5511c50255263e69b410df35fad625e48efb0613355ab2d53c8f` |
| `runner/s4-r6-validate-v2.sh` | validation runner (refuses direct invocation) | `fa5dbaef8834a5766536e63c1f8772eaa3eb0e6f7173cdbbba14b99bcf09b2ff` |
| `runner/chrome-pipe-discriminator-v2.mjs` | Chrome-alone pipe transport diagnostic, confirmed-exit cleanup | `c261ffb408dc5a724a17c5ad0889b500918fde5d1aa29420b39ced4c4d04531b` |
| `controls/C1..C4*.sh` | proposed fake safety controls (stubs; none executed) | see `SHA256SUMS` |

Only `bash -n`, `node --check` and Python `ast.parse` of the embedded blocks were run on these files. No install,
test, package, browser, network, lock or worktree action was taken. Nothing under `runs/` or `tooling/` exists.

## Findings → changes (S4-R6-VALIDATION-PLAN-A, all five material)

| id | V1 defect | V2 closure (where) |
|---|---|---|
| **VPA-01** ownership | descendant walk (incl. its own subshell), reparented children lost, KILL of already-gone PID counted as failure, profile grep as proof; pipe helper exit 0 with `childExit:null` | Owned boundary = the runner's own session/process group created by the launcher's `setsid` (runner asserts `sid==pgid==$$`, else refuses). Census = `pgrep -g PGID` written to a file by a direct child (no command substitution; pgrep excludes itself; `$$` filtered). Reparented orphans keep the PGID and are found. After **every** step: TERM → ≤10 s → KILL → ≤5 s → re-census; non-empty = blocking `cleanup unverified` (runner `reap_owned`, `step`). Step children run with `9>&-` so the lock fd cannot outlive the runner. The launcher does an independent final census after runner exit; any owned orphan it has to reap → `FAILED_RUNNER_LEFT_ORPHANS`; any survivor after group KILL → `QUARANTINED_SURVIVORS`. Nothing outside the group is ever signalled; `tgp-*` proof processes found outside the group are recorded and block success (`CLEAN_RC=2`). Pipe helper v2: verdict requires the `exit` event; unconfirmed child → `CLEANUP_UNVERIFIED`, exit 3, scratch profile retained (blocking). Native harness's fire-and-forget `SIGKILL` (browser-load-proof.mjs:673) is covered by the post-step group reap. |
| **VPA-02** truth | `CLEAN_RC` ignored by RESULT/exit; final source only printed; summary writer unchecked before sentinel | RESULT order: latched failure → `FAILED`/`HARNESS_BLOCKED`; else cleanup exit ≠0 → `FAILED_CLEANUP` (exit 4); else source not clean at exact head/tree → `FAILED_SOURCE_STATE` (exit 6); else warnings → `WARNINGS` (exit 3); else `SUCCESS`. Exit record is written to `.tmp`, parsed back, then renamed; sentinel only after that, else `FAILED_PUBLICATION` (exit 7, no sentinel). The launcher re-derives `OVERALL` independently and requires runner exit 0 **and** parsed `result==SUCCESS` **and** sentinel **and** empty group without supervisor reaping. First failure and cleanup exit are preserved as separate fields. |
| **VPA-03** launch | redirect into non-existent `runs/`; optional outer timeout; pre/post commands and cleanup unbounded; trap timing | One exact launcher: creates `runs/<RUN_ID>` **atomically** (`mkdir`, no `-p`; exists = refuse), reserves `console.log` inside it first, writes `LAUNCH_TOKEN`, starts `setsid bash runner` detached, records `OWNED_PGID`, then supervises with a **mandatory** deadline (`S4R6_OUTER_S`, default 3300) and grace (`S4R6_GRACE_S`, default 45): TERM to `-PGID`, grace, KILL to `-PGID`, verify. Writes `SUPERVISOR_RECORD.json` (timeout/interrupt/signal route/orphans/survivors/runner exit) even when the runner cannot write its own record. In the runner every pre/post command (toolchain provenance, evidence parsing, package binding, receipt joins) is itself a bounded `step` (`timeout --kill-after=30`); the final reap is loop-bounded (≤15 s). |
| **VPA-04** joins | run dir reuse, sentinel not rejected, first-wildcard ZIP, inventory claims never compared to actual ZIP bytes, receipts not joined, predecessor hash printed not compared, probes unpinned | Fresh exclusive run dir + launcher-generated safe id (`VALIDATION-V2-<utc>-<pid>-<rand>`); runner refuses any pre-existing `steps/`, `dist/`, record or sentinel. S50 packages into the empty `runs/<id>/dist`; S50b requires **exactly one** inventory + one ZIP, ZIP named by `inventory.zip.file`, **actual** sha256 and byte size equal to the inventory, `source.head == 91990ae9`, `source.clean == true`, every `files[].sha256` equal to the HEAD blob. S62b/S63b require the receipt's `package.sha256`, `package.path` and `package.inventory.zipSha256` to name that same actual ZIP hash; S63b additionally requires harness exit 0, `mutation.file == content/main.js`, recorded `sha256AfterMutation`, `detected`, `syntaxExceptionSeen`, no unrelated failures. S00 enforces pins: a01 late-reporting probe `890d45f7…`, reused R5 probes `d1e1d428…`/`93465881…`/`ae6d3e12…`, pipe helper v2 `c261ffb4…`, and the predecessor export compared **file-for-file by git blob id** against `88287cff` (count and content), excluding only the one labelled spec copy. |
| **VPA-05** latch | hook missing, gitleaks version, evidence parse/count, discriminator sign only appended anomalies; later steps still ran | `block()` latches the first blocking failure with step, exit and reason; every later `step` returns `NOTRUN` with the latch reason. Blocking now: hook not installed (S10b exit 90), gitleaks ≠ 8.30.0 (S11b, 91), focused evidence not 19 preflight cases / any non-pass (S30b, 92), full evidence any fail/pending/todo or total ≠ 1742 (S31b, 93 — the total is an arithmetic expectation 1714+25+3; a mismatch is recorded as `COUNT_MISMATCH` and must be explained, never relabelled), package binding (94), positive join (95), owned orphans surviving (96), negative criterion (97), worktree not clean at exact head after any step (98). Expected-negative S45 (`--expect defect` on the candidate) is `required=0`: exit **1** is the pass, exit 0 or 2 blocks — an intentional negative exit is distinguished from a failed prerequisite. `warn()` exists for informational notes and yields `WARNINGS` (non-success) rather than a global failure; V2 currently emits none. |

Not done on purpose: no general framework, no retry, no relaxed criteria, no repetition of harmless controls, no shim.
Cold/warm pipe labels are dropped (both trials use fresh profiles; renamed `trial1/trial2-fresh-profile`).

## Exact launch (parent, only after an explicit grant; S2 currently holds the sole heavy slot)

```
cd /home/user/workspace/execution/s4-r6-validation/v2
bash launcher/s4-r6-launch-v2.sh            # defaults: S4R6_OUTER_S=3300 S4R6_GRACE_S=45
echo "launcher exit=$?"
```
Outputs (all under `execution/s4-r6-validation/runs/VALIDATION-V2-<utc>-<pid>-<rand>/`): `console.log`, `LAUNCH_TOKEN`,
`OWNED_PGID`, `steps/*.log|*.json` (incl. Vitest JSON, package identity, browser receipts, pipe json), `dist/` (ZIP +
inventory), `reaps.log`, `blocks.log`, `EXIT_RECORD.json`, `RUN_COMPLETE.sentinel`, `SUPERVISOR_RECORD.json`.
Launcher exit: 0 SUCCESS · 124 TIMEOUT · 143 INTERRUPTED · 5 QUARANTINED_SURVIVORS · 6 FAILED_RUNNER_LEFT_ORPHANS ·
7 FAILED_PUBLICATION · 70–73 refusals · otherwise the runner's exit (runner: 75 lock busy, 4 cleanup, 6 source state,
8 harness blocked, 3 warnings, else first failure's exit). Absent sentinel = did not complete = UNKNOWN, never pass.
Worst-case bound: outer 3300 s + 45 s grace (+≤15 s runner reap); typical ≈ 15 min.

Step table, budgets and per-step criteria are unchanged from `SLOT_REQUEST_V1.md` §Steps except: S10b/S11b/S30b/S31b/
S50b/S62b/S63b are now explicit blocking steps; S60/S61 renamed to trial1/trial2; every failure class above is blocking.
Network: S10 `npm ci` (lockfile-pinned) and S11 gitleaks 8.30.0 (checksum-verified by the repo script) only.

## Requested first: simplest bounded no-network fake safety controls (none executed yet)

Run **before** any validation slot, sequentially, each via the launcher in `S4R6_CONTROL=1` mode (outputs go to
`v2/control-runs/CONTROL-V2-…`, the real runner refuses `kind=CONTROL`). Aggregate ≤ 60 s; no lock, worktree, install
or network; only `sleep` stubs in an owned group:

| control | command (cwd `v2/controls`) | expected |
|---|---|---|
| C1 deadline + reparented orphan + TERM-immune stub | `S4R6_CONTROL=1 S4R6_RUNNER=$PWD/C1-timeout-orphan-stub.sh S4R6_OUTER_S=6 S4R6_GRACE_S=3 bash ../launcher/s4-r6-launch-v2.sh` | `OVERALL=TIMEOUT`, exit 124, `signalled=TERM+KILL`, `survivors_after_kill=""`, `SUPERVISOR_RECORD.json` written |
| C2 runner exits 0 but leaves owned orphan | `S4R6_CONTROL=1 S4R6_RUNNER=$PWD/C2-runner-leaves-orphan-stub.sh S4R6_OUTER_S=30 bash ../launcher/s4-r6-launch-v2.sh` | `OVERALL=FAILED_RUNNER_LEFT_ORPHANS`, exit 6, orphan reaped, no survivors |
| C3 SUCCESS record without sentinel | `S4R6_CONTROL=1 S4R6_RUNNER=$PWD/C3-publication-failure-stub.sh S4R6_OUTER_S=30 bash ../launcher/s4-r6-launch-v2.sh` | `OVERALL=FAILED_PUBLICATION`, exit 7 |
| C4 real runner invoked directly | `bash C4-direct-runner-refusal.sh` | runner exit 71 before lock/worktree/tools are touched; nothing created |

These exercise exactly the VPA-01/02/03 signal, reaping and publication paths the review said cannot be validated by
reading. The runner's latch (VPA-05) and joins (VPA-04) are deterministic in-script logic left to the reviewers' static
assessment; they are proven or refuted by the first real run's `NOTRUN`/`blocks.log` records.

## Exact next request

1. Two independent reviewers assess the changed V2 files (hashes above) — not the product, not the V1 packet.
2. Parent grants the four fake controls (≤60 s, no network). Any unexpected control result stops V2 (new version required).
3. Then, when S2 releases the heavy slot, parent grants one V2 validation run with the exact launch above.
4. Result `SUCCESS` from V2 is builder evidence only; the two independent final evidence attestations remain required
   before any acceptance, and historical hooks stay 0/6 regardless.

Nothing was executed; no grant is assumed; V2 files are frozen at the hashes above (any byte change = V3 + new request).
