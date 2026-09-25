# S7-L corrected-candidate single PostgreSQL proof grant

Parent grant, 2026-09-25 05:39Z. Executor `s7_l_replacement_builder_muge72rg` is the sole heavy-slot grantee for exactly one invocation below. This is a new candidate-bound execution, not acceptance or a replay of the failed v2 run; no automatic correction or further retry is authorized.

## Exact identity

| Item | Pin |
|---|---|
| HEAD | `a68cdac70d81aea384fdc99c01c9c983a08e80eb` |
| Tree | `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb` |
| Exact parent | `54970cd937afc8dea689b33243961abfef8b9dd6` |
| Preserved v1 ancestor | `839b54c53ccb252f95b4ec63df0b08595bbe7698` |
| Accepted base | `93389265a846095b846fa8f1fb0dad782fb6ee9f` |
| Worktree | `/home/user/workspace/worktrees/64e33dc7-s7l`, clean |
| Proof spec blob | `94e7fac4b8cbb8a8e2146700cbdc7ce9129b9f92` |
| v3 driver SHA256 | `0c33b22279324b39132d06f4c7e5e00d9158bdb89e2174306389e043d7dedffd` |
| v3 fixture SHA256 | `721468ac49eae624697feafa78ddfbddab9fee41303be03c36c66c923e6f7945` |
| v3 BINDING.sha256 file SHA256 | `82f501a33c8e0325e6b0781a6afdf12533a89e1b945cc8b3a56761182a16aac2` |
| RUNTIME_CORRECTION_REVIEW_A.md SHA256 | `4f327e70a3774905d482794fa5cbc310426f7c189294ae27bb6a3b271b7bd33e` |
| RUNTIME_CORRECTION_REVIEW_B.md SHA256 | `98663915c20455322c20909f7e29a0757b4f47e6a18e7a3924c6a2004615b176` |

Both independent changed-question reviews are GO. Parent read both reports in full, the one-hunk committed correction, correction receipt, complete filled driver and README, and the exact filled driver/fixture deltas. The manifest and supplement were recomputed. The only product-file delta from the failed v2 candidate is the observed psql message literal and same-stanza `try/finally` holder release; all other assertions and product bytes remain preserved.

## Release and fresh-lane observations

S8-C's first proof terminated naturally with bootstrap rc7 at05:33:24Z, before Jest. Its execution authority ended and its source, failed cluster and receipts are frozen. At05:38:04Z parent independently observed no canonical lock entry, relevant heavy process or listener on55641/55642; lock inode691716 was intact. `recovery-reset/proof-v3` and the new S7-L sentinel were absent, and both retained lanes had no postmaster.pid.

| Retained lane | postgresql.conf SHA256 | pg_control SHA256 |
|---|---|---|
| `clusters/s7l` | `ae1fc878604dae6681f71580187d6da7e440268930c44cadaf45d83304358bdd` | `c2d8ebd859f64bd69e044b1e8e3ac21b6802b16d8a3d584528b96c8854153c15` |
| `clusters/s8-c` | `46678e67ad66198fc3d6cc91d1a288a49f53c5d3bbd5bd08936562e83043680d` | `3159f28c439a67e8dbeda6b380f0f31e4a6436bfef9a8392f5c3e4cfa778b720` |

These observations do not override live preflight. Neither retained lane may be started, adopted, repaired, moved or destroyed. Their conf/control hashes must remain unchanged under the driver's existing pre/post checks.

## One authorized invocation

```sh
timeout -k 30 3900 bash /home/user/workspace/tgp-private-evidence/execution/64e33dc7/s7l/binding/v3/s7l-pg-proof.sh
```

Read this grant fully and reverify the exact candidate and binding hashes read-only immediately before launch. Use one durable detached supervisor with explicit stdin and stdout/stderr redirection and a launch receipt under `s7l/binding/v3/run/`. The actual driver must acquire and hold the existing canonical nonblocking flock on fd9; no separate holder and no lock removal. Record supervisor/driver identity, exact command and time. A tool return or timeout is never authority to launch again.

The only authorized runtime sequence is the unchanged driver's bound fresh old-root preparation, init/start/bootstrap, identity, single S7-L Jest proof, bounded stop, post checks, receipts and sentinel. Fresh data is `recovery-reset/proof-v3/clusters/s7l/pg-data`, socket `proof-v3/run/s7l`, old-root `proof-v3/s7l/old-root`, port55641, database `g2_s7l_disposable`, with the pinned synthetic identities. The driver permits its committed offline old-root helper and isolated OLD-client generation; candidate-client generation, installation, other test suites, source edits, commits or pushes are not granted.

First nonzero ends the run through existing bound cleanup. Preserve raw output and actual exit status, report any surviving process or non-exiting stage to parent, and do not autonomously repair, retest, remove a sentinel, destroy data or kill a broad process set. Keep v1/v2 bindings, failed v2 logs/data/old-root and S8-C's failed run untouched.

## Terminal evidence and acceptance boundary

After an actual terminal result, write `s7l/binding/v3/run/PROOF_RUN_RECEIPT.md` with stage reach, raw Jest totals, migration state reported by the driver, natural versus forced exit, observed stop/port/process/lock state and retained data. Qualify the known driver-log hash-before-END ordering without rewriting raw receipts. Then freeze and stop.

The existing independent reviewers will assess only this new runtime evidence. A pass is not self-issued product acceptance and cannot retroactively accept v2; parent disposition and dependency validation precede any authorized non-production integration landing. Production, activation, principal policy and all other reserved boundaries remain unchanged. S8-C remains limited to independent read-only failure diagnosis; it has no runtime or source-correction authority.
