# J3 r5 — execution result (actual)

The driver ran once, pinned at `2fe6a00f0dd4540f21821813f31ed76143e11b309f700de5c9ed68f2d416a632`. It ran from 2026-09-24T15:18:14Z to 15:25:34Z (pid 10085) and held the canonical `flock -n` slot throughout. The terminal sentinel reads:
`RC=0 STAGE=complete HEAD=9ff749c35f64068e156400d2ed37c0b144c2d56d LOCK=released-on-exit`.

This result is not self-accepted. It goes to the independent reviewer for disposition.

## Stages

| Stage | Result | Receipt |
|---|---|---|
| 0 preflight | OK (all pins) | `00-preflight.txt` |
| 1 `npm ci` (plain, one run) | exit 0 in 387 s. Node v20.20.1, npm 10.8.2. Lock `840be0b8…` unchanged; package.json `63e2e2e2…` unchanged. **Installed record `c4d7824b…450b` matches.** `node_modules` is a real directory with 0 top-level symlinks. Tracked bytes unchanged. The 5 EBADENGINE warnings match the accepted run's, and audit output was printed as in the original. | `01-npm-ci.log`, `01-npm-ci-status.txt`, `02-env-pins.txt` |
| Gate binaries | typescript 6.0.3, eslint 8.57.1, jest 29.7.0, jest-expo 56.0.4, @testing-library/react-native 14.0.0, react-native-safe-area-context 5.8.0 | `02-env-pins.txt` |
| 2 hook posture | The recovery-only local `core.hooksPath=/dev/null` was unset (rc 0). The effective, global and system values are all empty. `.git/hooks` holds only `*.sample`, and there is no `.husky`. Repo-local Bradley identity was set. This is the recorded no-configured-hooks posture: **not a bypass, and no hook executed.** | `03-hooks-identity.txt` |
| 3 commit | Exactly the 2 test paths were staged; write-tree = `823b97006f7df9617bad5516d7ef578189095e82`. Committed with an ordinary `git commit -F 23-r5-commit-message.txt`, rc 0. | `04-stage-treecheck.txt`, `05-*` |
| 4 verify | See the head table below | `06-post-commit.txt` |
| Gate 1: `tsc --noEmit` | rc 0 in 30 s | `07-gate1.txt` |
| Gate 2: ESLint on the 2 tests | rc 0 in 1 s | `07-gate2.txt` |
| Gate 3: Jest on the 2 full files, `--silent --runInBand` | rc 0 in 14 s. **2/2 suites and 50/50 tests passed** (`ImportDataScreen.test.tsx` then `.restore.test.tsx`) | `07-gate3.txt` |
| 6 exports | See the portable-evidence table below | `08-exports.txt` |

### Actual head (stage 4)

| Field | Value |
|---|---|
| Head | `9ff749c35f64068e156400d2ed37c0b144c2d56d` |
| Tree | `823b97006f7df9617bad5516d7ef578189095e82` |
| Parent | single parent, `820dbd04500b06648ce4c0820c1badced55d6d7c` |
| Message | `test(importer): complete J3 screen mock isolation`: body empty, trailers 0 |
| Author / committer | Bradley Gleave <bradley@bradleytgpcoaching.com>, timestamp 1790263486 +0000 |
| Product blob | `92ed52f5…`, unchanged |
| Tracked state | clean |
| Change size | +5 / -0 |

### Portable evidence (stage 6)

| Artifact | Verification | sha256 |
|---|---|---|
| Bundle `j3-r5-committed-9ff749c.bundle` | `git bundle verify`: okay; **complete history** with no prerequisites. It covers the composition → r3 → r4 → r5 chain. | `37e243c1…946e` |
| Patch `j3-r5-committed.patch` | — | `bca6f8af…dd74` |
| Committed diff `820dbd04..9ff749c3` | sha256 `48d1c583…` = the frozen r5 patch | — |

## Cleanup and release

- **Survivors:** the owned-descendant checks after every process stage report `none` (`99-survivors.txt`). After the run, `pgrep` matched only the checking shell itself.
- **Lock:** a post-run `flock -n` probe succeeded, so the slot is free. This probe was taken and released instantly.
- **Worktree:** tracked state is clean and untracked files are empty. `node_modules` is ignored and stays in place for reuse.
- **Launcher output:** `receipts-launcher.out`.
- **Manifest:** `MANIFEST.sha256` covers the driver and all receipts.

## Not done

- No retry, edit, amend, formatter run or wider suite.
- No remote, push or deploy.
- No change to existing receipts.
- This is mocked component-interaction coverage only, not device, browser or end-to-end proof.
