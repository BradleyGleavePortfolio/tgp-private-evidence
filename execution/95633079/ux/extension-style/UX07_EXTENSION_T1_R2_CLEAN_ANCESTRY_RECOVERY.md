# UX-07 extension presentation — clean-ancestry recovery receipt

**Purpose:** isolate the existing reviewed r2 source candidate from the external `/home/node_modules/string_decoder@1.1.1` proof contamination. This is recovery only, not a source change or validation run.

## Recovered repository

| Item | Pin |
|---|---|
| New isolated repository | `/tmp/tgp-ux07-extension` |
| Recovery base / detached HEAD | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Applied preserved artifact | `UX07_EXTENSION_T1_R2_SOURCE_DIFF.patch` |
| Applied patch SHA-256 | `e5ae9a412e3440f4521df2ba364d941836e64e4325d2432e37104c7abfef5737` |
| Recovered r2 candidate tree | `3750a2ea9f6e57b7de96c0102aab66d761776189` |
| `popup/popup.html` candidate blob | `f003a81804d15e5fc34fefbeaab228f371a14a7d` |
| `popup/pair.html` candidate blob | `01f6839b0b7657520167556fc9ae71c56ea80474` |
| Changed paths from base | `popup/pair.html`, `popup/popup.html` only |

## Isolation checks

- `/tmp/node_modules` is absent.
- `/node_modules` is absent.
- The recovered repository has no `node_modules` directory.
- The original worktree remains at base `0111be661922234d670bbf23e23d270eec1b4a4e` with its prior two uncommitted popup HTML changes; it was not altered by this recovery.

## Method and boundary

The isolated repository was reconstructed from local Git objects at the exact base and the preserved, hash-verified r2 patch. `git apply --check` completed before the patch was applied. A temporary Git index then produced the recovered candidate tree and verified both candidate blobs.

No remote action, install, test, type-check, hook execution, commit, build, browser/runtime action, deployment, or publication occurred. The next validation sequence remains deferred until a new heavy-slot grant: one clean-ancestry `npm ci`, `npm run type-check`, `npm run check:hooks`, then only the unexecuted suffix checks (`lint` and `format`) before an ordinary local commit if all pass. The targeted tests and full gates will not be repeated under this recovery route.

