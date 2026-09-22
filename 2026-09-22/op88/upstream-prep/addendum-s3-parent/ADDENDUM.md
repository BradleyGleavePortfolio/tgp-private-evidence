# OP88-UPSTREAM-PREP — Addendum: S3 parent 5c7b42b3 restored; PREP2 parent-2 and matrix facts closed

Additive to frozen revision-1 (`../REPORT.md`, `../INPUT_MAP.md`, `../DEPENDENCY_HOLD.md`, `../MANIFEST.sha256` — re-verified 31/31 OK, untouched). Trigger: parent mail 20:59Z hydrating `tgp-private-evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/`. Scope executed: source restoration/verification only. No install, runtime, hooks, commit, source edit, lock, or network; `GIT_NO_LAZY_FETCH=1` on every git call. Frozen 2026-09-22T21:0xZ.

## 1. Packet and bundle verification (`logs/A1`)

- `SHA256SUMS.txt`: 34/34 entries OK (bundle, 16 logs, 10 scripts, 3 reports, 4 publication files). Own sha256 of `SHA256SUMS.txt` = `8646c0753c2ac566e420a863f180b85fee9827c6d3d524918269d82b116ca9fd` (manifest states the parent archive hash is authoritative for it — parent to confirm).
- `s3-backend-5c7b42b3.bundle` sha256 `940ce711a692b40325f3a1ad77aa0b1153cbfbad29c9fe8ef2a1a85b1c6f7b29` = SHA256SUMS line. `git bundle verify` okay; requires only `c23b9d9f…`; sole ref `refs/heads/execute/20260920-s3-backend` → `5c7b42b3…`.
- Imported to isolated `backend-s1s2-d5cd` as `refs/op88/s3-bundle/execute/20260920-s3-backend` (pre-import: object absent).

## 2. Restored S3 identity (`logs/A2`)

| Fact | Observed | Advertised (PUBLICATION_MANIFEST / brief) |
|---|---|---|
| Head / tree | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` / `83211d25d714e4c539cd3aa248a06ef0658fc8e7` | same |
| Parent | `925780e0a1906593e5383c618311b6b17364b8dc` (#525 head) | preserved #524→#525 lineage |
| Commits `c23b9d9..5c7b` | 23; all author = committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; 0 AI-token hits | 23, Bradley Gleave |
| Ancestry | contains #524 `238f0f1f` and #525 `925780e0`; base `c23b9d9` ancestor; merge-base(d5cd, 5c7b) = `c23b9d9`; neither S2 nor S3 contains the other | — |
| Completeness | 0 missing objects in range; 0 missing blobs in tree | — |
| S1-owned paths | `git diff c23b9d9 5c7b -- prisma/migrations test/db` empty (S3 never touches S1) | — |
| Read-only checkout | `worktrees/op88-upstream/wt-s3-5c7b42b3` detached, porcelain 0, no node_modules, files chmod a-w | — |
| Listings | `ls-tree-r-5c7b42b3.txt`, `commits-5c7b42b3.txt` in this directory | — |

## 3. PREP2 facts that were pending in revision-1 — now closed

| Pending item (rev-1) | Result |
|---|---|
| `full-vs-parent2-5c7b42b3.patch` reproduction | `read-tree 5c7b^{tree}` (index = `83211d25…`) + `git apply --cached` → `write-tree` = **`a584a1b95423f95dae8daabf673ef3776604acbb`** (MATCH). PREP2 is now reproduced from **both** parents with the archived patches. |
| `PRESERVATION_MATRIX.tsv` column `eq_S3_5c7b` | Re-derived for all 86 rows: **0 mismatches**. S3_PRESERVED 38/38 PREP2 blobs == 5c7b blobs; FORMATTED_S3_PREP2 6/6 differ from 5c7b (as recorded). All five equality columns are now locally reproduced. |
| Request-03 §0 S3-side blobs | `package-lock.json 354de3da` (sha256 `b7fed5ed…`), `package.json 656d11a2`, `lefthook.yml 54d03749` at 5c7b == PREP2. Six pre-format S3 blobs `c7f45409 61e25bec 22c04573 550f1df5 cd089439 385c6741` == `00-pre-state.txt` records == packet `before/` files. |
| Path arithmetic | 5c7b vs base 47 paths; d5cd vs base 41; union 86 = matrix rows; both-parent overlap exactly `.github/workflows/ci.yml` (AUTO_MERGED) and `.github/workflows/r100-quality-gate.yml` (RESOLVED). |
| Resolution attribution (read-only `git merge-tree --write-tree d5cd 5c7b`, exit 1) | Auto-merge tree `14be0c7f…`; single content conflict `.github/workflows/r100-quality-gate.yml`; auto-merged `ci.yml` blob `85415cdc` == PREP2. Auto tree differs from PREP1 in exactly the three recorded manual resolutions (`r100-quality-gate.yml 0ad6eb8b`, `r100-pathspec.spec.ts be6676d6`, `r75-gate.spec.ts 04190bd6`) and from PREP2 in those three plus the six formatted files — nothing else. Consistent with the state file's "manual resolutions limited to r100 workflow and r100-pathspec/r75-gate specs". Resolutions were **not** re-resolved or judged here; a merge-tree simulation is not a constructed candidate. |

## 4. Exact source readiness for the held S3 request-03 slot

READY (source only): parent 1 `d5cd9b8b` (tree `c0ab87d4`), parent 2 `5c7b42b3` (tree `83211d25`), staged tree `a584a1b9` — all three as objects/refs in one isolated odb; the request-03 §0 state (`HEAD=d5cd9b8b`, `MERGE_HEAD=5c7b42b3`, index write-tree `a584a1b9`, `unmerged 0`, worktree == index) can now be materialised honestly as a detached worktree without inventing anything. It has deliberately **not** been created (parent scope: restoration/verification only; a staged-merge worktree is a mutable live state that should be created only against the granted slot).

STILL HELD (unchanged from `../DEPENDENCY_HOLD.md` §2): P2 pinned Prettier 3.9.6 install (network), P3 app `npm ci` (network, heavy), P4 Prisma engines, P5 canonical lock file/`.holders` creation by parent, P6 repo-local git identity, P8 uutils `timeout` stamping, P9 S2 PG 17.6/fixture (S2 owner), P10 platform node_modules hash, P11 lefthook install. Revision-1 finding F1 (missing 5c7b) is CLOSED by this addendum; F2 (17/7 mutant bytes) remains open and is not touched.

Ordering preserved: S2 clearance (V5.6 dual reviews → N4/N5/N6 → controls → real 164+1 proof + S1 discriminator) precedes any S3 hook-enabled merge; S3 six-file applicability (tsc + targeted Jest) and two independent exact-head attestations remain downstream.

## 5. Source unchanged / isolation (`logs/A4`)

Baseline `source/backend`: HEAD `c23b9d9`, porcelain 0, 1 worktree (itself). Private evidence: HEAD `8c22817e`, porcelain 3 — `LAST_OEPRATOR_HANDOFF.MD`, `LAST_OPERATOR_STATE.md`, `execution/DISPATCHES.md` modified, all parent-owned root/dispatch files (not written by this lane; recorded, not touched). Lane worktrees `wt-s1-56fb0d22`, `wt-s2-d5cd9b8b`, `wt-s3-5c7b42b3`, `backend-s1s2-d5cd` all porcelain 0. Refs: `refs/op88/{s2-bundle/…=d5cd9b8b, s3-bundle/…=5c7b42b3, prep2-tree=a584a1b9, prep1-tree=78a4f0e8}`. No lane processes; lock never taken (file still absent). Nothing shared with the S2 fixer; nothing published.

Method note: `logs/A2` stopped after the matrix section because the script ran under `set -e` and `git merge-tree` exits 1 on conflicts; the simulation was re-run in `logs/A3` with the same inputs. Both logs preserved.

## 6. Smallest next action

Parent: confirm the archive hash of the hydrated `SHA256SUMS.txt` (`8646c075…`) and, when S2 clearance ordering allows, grant the request-03 environment steps (P2/P3/P5/P6 first) against `worktrees/op88-upstream`; this lane will then materialise the `$W` staged-merge state from the three refs above and stop before step 02 unless the heavy allocation is also granted.

## 7. Owned outputs of this addendum

`addendum-s3-parent/{ADDENDUM.md, MANIFEST.sha256, ls-tree-r-5c7b42b3.txt, commits-5c7b42b3.txt, logs/A1–A4}` and `worktrees/op88-upstream/wt-s3-5c7b42b3` + ref `refs/op88/s3-bundle/*`. `MANIFEST.sha256` covers every file in this directory except itself.
