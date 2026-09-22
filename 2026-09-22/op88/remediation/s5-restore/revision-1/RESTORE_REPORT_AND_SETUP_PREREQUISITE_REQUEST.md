# OP88 S5 source-restore child — `/home/user/workspace/worktrees/s5-r4` restored; ONE concrete prerequisite gap found (fingerprint gate), NOT silently fixed

Worker: `s5_selective_v7_fixer_mud58q6n` acting as the separately authorized T4 source-restore-only child. Exclusive writes: `/home/user/workspace/worktrees/s5-r4` (created 20:59:18Z, absent before) and `/home/user/workspace/execution/op88/s5-restore`. Window 20:59:18–21:01:33 UTC. Commands used: `git clone --no-hardlinks`, `git remote set-url`, `git bundle verify`, `git fetch <bundle>`, `git checkout`, `git apply --check`/`git apply`, `git rev-parse|status|diff|merge-base|rev-list|log|write-tree|show|config --get|count-objects`, `sha256sum`, `diff`, `cp`, `ls`, `df`. **No** GitHub/network fetch was needed or performed, no scripts/hooks/commit/install/DB/lock, no config written, no V7 frozen input or archive byte touched (private evidence porcelain 0; baseline `source/backend` HEAD `c23b9d9f` porcelain 0 before and after). Full command log: `logs/restore-20260922T205918Z.log`.

## 1. Restoration result — exact, per `checkpoint-1/RECREATE.md` steps 1–4

| Step | Observed | Expected |
|---|---|---|
| Baseline | `source/backend` HEAD `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`, clean; `blob:none` partial clone, but **0 objects of the `c23b9d9f` commit (tree+blobs) missing locally** | `c23b9d9f` |
| Bundle | `s5-r3-candidate.bundle` sha256 `e42aa021442a8a004bf796e2958461bf79d11c1666fe8fb08ef46dd80bd75b48`; `git bundle verify` okay; contains `refs/heads/execute/20260921-s5-r3` = `143d451e…`, requires `c23b9d9f` | same |
| Clone | `git clone --no-hardlinks source/backend worktrees/s5-r4` rc 0; origin set to `no_fetch` / push `no_push`; no promisor config in the clone | RECREATE step 3 |
| Bundle import | `git fetch <bundle> refs/heads/execute/20260921-s5-r3:…` rc 0; **0 objects of `143d451e` missing** → no GitHub fetch required | — |
| Clean head | HEAD `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`, tree `d0e122d35022377196908b7d132fc34c1af2fc6b`, porcelain 0 lines, `c23b9d9f` is ancestor (rc 0), 32 commits above base, all 32 author = committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`, 0 AI trailers; `package-lock.json` blob `354de3dae19449970497da6e4d87f0a1225a8f43` | all as pinned |
| Dirty patch | `s5-r4-dirty-from-143d451e.patch` sha256 `c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491`; `git apply --check` rc 0; `git apply` rc 0; porcelain exactly ` M test/rls-g2-pg17-etq0.spec.ts` / ` M test/utils/g2-pg17-bootstrap.sh`; 2 files, +50/−4; `git diff --check` clean; index tree still `d0e122d3…` (working tree only) | as pinned |
| File identity | worktree `test/rls-g2-pg17-etq0.spec.ts` sha256 `01f3cfc09a700f1b3c76625774d08b37cdcc407453515e635cc0e7c2c7bac25d` = wave-6 candidate copy; `git show HEAD:test/rls-g2-pg17-etq0.spec.ts` sha256 `54c85d8d…48f1` = wave-6 predecessor copy; `test/utils/g2-pg17-db.ts` `d51eb32a…46bb` = wave-6 copy; `test/utils/g2-pg17-bootstrap.sh` (dirty) `d3348db8…5340` | matches preserved wave-6 inputs |
| Not present (correct) | `node_modules`, `.git/hooks/pre-commit`, generated client, repo-local `user.name`/`user.email` (not configured by this child; no commit is authorized) | — |

Source is restored byte-exactly at the file level. Worktree size 34 MB. Snapshot: `WORKTREE_IDENTITY.txt`; live `git diff HEAD` bytes preserved as `live-git-diff-HEAD.patch` (`4e3d93de…12a0`).

## 2. The one concrete gap — dirty fingerprint gate does not reproduce under this repository's configuration

- Pinned `PIN_DIRTY_FINGERPRINT` = `6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0` (setup `74736a58` L23, v6 driver L23, V7 T0-only driver, `RECREATE.md` step 4).
- Live formula result now: `{ git diff HEAD; printf '%s\n' "$(git status --porcelain --untracked-files=all)"; } | sha256sum` = **`16cc5e727a5490ccb8c37a192a517338546e85598b7ae32d6357e1081a9cfa88`** ≠ pinned.
- Cause, proven read-only: `diff <(cat patch) <(git diff HEAD)` differs in exactly two lines — the `index` headers: preserved `index 77bb94b6..ff5a38b8 100644` / `index c85eaca0..85a636ba 100755` vs live `index 77bb94b..ff5a38b` / `index c85eaca..85a636b`. Git's auto `core.abbrev` scales with repository object count; the original worktree (full baseline) produced 8-hex abbreviations, this restoration (12 972 objects, from the `blob:none` baseline of 12 624) produces 7. Content lines are identical.
- Confirmations: sha256(preserved patch bytes + porcelain) = `6850b32e…6aa0` exactly, i.e. the pin encodes the patch bytes; and a one-shot, non-persisted `git -c core.abbrev=8 diff HEAD` + porcelain reproduces **`6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0`**. `core.abbrev` remains **unset** in the worktree; nothing was persisted.

Consequence: with the worktree as restored, setup `74736a58` would refuse at `provenance-dirty-fingerprint` (rc 2, before any child), and the V6/V7 drivers would refuse at the T2-2 attribution gate (rc 2). The source is exact; the gate's byte encoding depends on an environment parameter the RECREATE recipe did not pin.

### Proposed smallest correction (NOT applied; parent decision)
Option A (recommended): `git -C /home/user/workspace/worktrees/s5-r4 config --local core.abbrev 8` — a repo-local, non-source, reversible setting inside the restore child's owned worktree; predicted to make all existing pinned gates pass without changing any script hash. Add the line to a RECREATE addendum so future restorations are deterministic. Independent reviewer should confirm the predicted value before any grant relies on it.
Option B: re-pin the fingerprint to `16cc5e72…fa88` in setup/driver — rejected here: it would change three frozen artefacts (new hashes, new reviews) and encode this environment instead of the patch bytes.
Option C: restore from a full (non-partial) baseline so auto-abbrev returns 8 — non-deterministic and requires broad GitHub fetching; not proposed.

## 3. Exact setup prerequisite request (fresh isolated dependency setup; nothing granted or run here)

Frozen setup runner preserved byte-identical in `setup-v1-frozen-copy/run-s5-setup-npm-ci.v1.sh` sha256 `74736a5878fe4620adfb8dfe8f0a1c88e12b4f08a5313d3a52017e1deb8ebeaa` (+ its S6 derivation diff `6f48c9b1…3cf3`). The historical positive record (1117 packages, inner FINAL 0) is **historical evidence only**; no node_modules exists now and none is claimed.

Runner-pinned prerequisites vs current state:
| Prerequisite (runner line) | Current | Status |
|---|---|---|
| `WT=/home/user/workspace/worktrees/s5-r4` at HEAD `143d451e`, lock blob `354de3da`, exact porcelain (L16, L21–24, L81–83) | restored exactly | ready |
| dirty fingerprint `6850b32e` before AND after (L23, L84, final accounting) | live `16cc5e72`; predicted `6850b32e` only with `core.abbrev=8` | **BLOCKED pending §2 decision** |
| `node_modules` absent in WT (one install only, L85) | absent | ready |
| `/home/user/package.json` absent (L86) | absent | ready |
| ancestor `/home/user/node_modules` inventory hash gate (L34, read-only) | present, 210 entries (contemporaneous count; gate is the hash) | ready |
| `LOCK=/home/user/workspace/execution/test-validation.lock` opened+`flock -n` by the runner (L19, L64) | path absent; runner creates and holds it — **canonical lock acquisition = separate grant** | grant-gated |
| `EX=/home/user/workspace/execution/s5-r4`, `LOGS=$EX/logs/setup-v1` (L17–18; runner `mkdir -p`) | absent; created by the runner at launch, outside op88 ownership | parent must own/approve the path |
| `npm ci --ignore-scripts` registry network (L90), budget 1200 s → TERM → 30 s → KILL, `taskset -c 0,1` | npm 10.8.2, node 20.20.1, `taskset`/`flock`/`setsid` present; network not granted | grant-gated |
| disk | 9.6 GB free | sufficient for a ~1100-package install |
| Not needed for setup/T0 | `/home/user/pg17` absent, no cluster — correct, not claimed | — |

Launch line when (and only when) granted, unchanged from `TIER2_SETUP_REQUEST_V1.md` except that the runner may be executed from the frozen copy path: `mkdir -p /home/user/workspace/execution/s5-r4/logs/setup-v1 && setsid nohup timeout -k 30 1290 bash /home/user/workspace/execution/op88/s5-restore/setup-v1-frozen-copy/run-s5-setup-npm-ci.v1.sh > /home/user/workspace/execution/s5-r4/logs/setup-v1/run-setup.out 2>&1 < /dev/null &` (the runner records its own sha256 in `START`). Positive = `FINAL rc=0`, `FIRST_EXIT npm-ci rc=0 how=exited`, `cleanup_exit=0`, ancestor `UNCHANGED`, `dirty_fingerprint_after=6850b32e…`, `hooks_pre_commit=absent`, `generated_client=absent`, 12× `OK` identities. Expected refusals: lock busy 75; any provenance mismatch 2 (incl. the fingerprint gap above if unresolved); npm failure = its rc, no retry.

## 4. Truth
- Implemented: exact source restoration (clone, bundle import, checkout, patch) and evidence. Tested: only git/hash verifications listed. Unrun: setup, Jest, controls, anything network.
- The fingerprint gap is an environment-encoding finding about the pin, not a source discrepancy; all preserved file hashes match the wave-6 copies. Wave 6 remains FAIL; V7 packet untouched (`SHA256SUMS.controls-v7-selective` still verifies 15/15).
- Smallest next action: parent (or the assigned independent reviewer) decides §2 Option A; after confirmation of `6850b32e` under the persisted setting, the setup grant can be assessed against §3.
