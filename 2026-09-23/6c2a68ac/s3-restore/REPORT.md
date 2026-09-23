# S3-PREP2-RESTORE — staged tree a584a1b9 reproduced from both parents and materialised as a fresh worktree (revision 1, frozen)

Writer: T4 sole source-only S3 PREP2 restoration builder, parent EXEC-6c2a68ac. Requested policy Claude Fable 5 / High; actual model/runtime telemetry is not observable from inside the sandbox and is not asserted. Executed 2026-09-23T15:47–15:50Z. Mechanical restoration only — not installation, testing, formatting, independent review, controls, commit or runtime. Nothing written to the private checkout; frozen evidence untouched (packet 25/25 OK before and after).

Inputs read (only): live G01–G22 `tgp-startup/live/AGENT_RULES.md` (edd63115…); private `execution/6c2a68ac/SCOPE.md` (29c1c965…); archived `2026-09-23/e8d546f9/upstream/REPORT.md` (b16955a1…, its `MANIFEST.sha256` verified 6/6) §2 as the method to reproduce; named packet `2026-09-22/remediation/s3-composition-prep/prep2-format/` (`SHA256SUMS.txt` 25/25 OK; own sha256 f836d544…): `REPORT.md`, `00-pre-state.txt`, `05-post-state.txt`, `six-files.txt`, `PRESERVATION_MATRIX.tsv`, `before/`, `after/`, three `patches/`; candidate bundle evidence needed for the two parents only: `2026-09-21/remediation/s2-composition/b2-failed-and-r3-source/s2-composition-r3-d5cd9b8b-from-public-c23b9d9.bundle` (sha256 **3b6cee481319dd518268b7573ebed142fa234e193b874d8712a6cdf5493c0f75** = its `ARCHIVE_SHA256SUMS` line) and `2026-09-20/remediation/checkpoint-1724/s3-backend/s3-backend-5c7b42b3.bundle` (sha256 **940ce711a692b40325f3a1ad77aa0b1153cbfbad29c9fe8ef2a1a85b1c6f7b29** = `checkpoint-1724/SHA256SUMS` line 44). The sibling `execution/6c2a68ac/s2-restore/REPORT.md` was read only to locate the d5cd bundle path. Not read: `2026-09-23/e8d546f9/s3-prep2-materialize/`, PREP1/request-03 packets, any audit/review conclusion, product code beyond hashing/`ls-tree`.

## 1. Collision and ownership

Both owned targets were ABSENT before write (`logs/P0`): `/home/user/workspace/worktrees/s3-prep2`, `/home/user/workspace/execution/6c2a68ac/s3-restore`. Read-only inputs unchanged after all steps (`logs/P5`): `source/backend` HEAD c23b9d9f, porcelain 0, refs 2, loose 0, packs 1, one worktree (itself); `worktrees/s2-runner53` HEAD d5cd9b8b, porcelain 0. Canonical `execution/test-validation.lock` absent before and after; never created/opened/probed.

## 2. Tree reproduction from BOTH parents (`logs/P1`, `logs/P2`)

Standalone repo `worktrees/s3-prep2/.git` = byte copy of `source/backend/.git` (shallow at c23b, as baseline), `origin` removed (remotes 0), `GIT_NO_LAZY_FETCH=1` on every call, no promisor/partial-clone config, hooks 0 non-sample, `core.hooksPath` unset. Both bundles `git bundle verify` okay (sole prerequisite c23b present); fetched from local files into `refs/restored/execute/20260921-s2-composition-r2` = **d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c** and `refs/restored/execute/20260920-s3-backend` = **5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06**. `fsck --connectivity-only` exit 0.

| Parent | Tree | Commits since c23b | Author/committer (all) | Missing objects |
|---|---|---|---|---|
| d5cd9b8b (S2, HEAD) | c0ab87d4dc584b2a7ccad53db16fa551b93fe359 | 23 | `Bradley Gleave <bradley@bradleytgpcoaching.com>` both fields | 0 |
| 5c7b42b3 (S3, MERGE_HEAD) | 83211d25d714e4c539cd3aa248a06ef0658fc8e7; parent 925780e0 | 23 | same | 0 |

`merge-base d5cd 5c7b` = c23b9d9f (computable here because both bundle lineages start at c23b); neither parent contains the other; 56fb0d22 is an ancestor of d5cd. Tree `a584a1b9` was ABSENT from the odb before patch application.

| Reproduction (temporary `GIT_INDEX_FILE`, no worktree touched) | write-tree | Result |
|---|---|---|
| `read-tree d5cd^{tree}` (c0ab87d4) + `apply --cached full-vs-parent1-d5cd9b8b.patch` (91c0096d…) | **a584a1b95423f95dae8daabf673ef3776604acbb** | MATCH; 48 paths vs d5cd |
| `read-tree 5c7b^{tree}` (83211d25) + `apply --cached full-vs-parent2-5c7b42b3.patch` (3fdc2265…) | **a584a1b95423f95dae8daabf673ef3776604acbb** | MATCH; 48 paths vs 5c7b; 86 vs base |
| cross-check: `read-tree a584a1b9` + `apply --cached -R prep2-six-files-vs-prep1-78a4f0e8.patch` | 78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69 | MATCH (PREP1 tree); `diff --name-only 78a4f0e8 a584a1b9` == `six-files.txt` |

Blob facts inside `a584a1b9`: six archived `after/` files byte-identical to the tree blobs (sha256 1712cd53, 33ae2353, 4217faf8, f2ea4367, 344a4837, 9d515dc6); six archived `before/` files byte-identical to the 5c7b blobs (282ec9d6, 2632094f, ba40b646, 42c97a77, 4bc8d92f, 142fc045) = `00-pre-state.txt` records; closure blobs `package-lock.json 354de3da`, `package.json 656d11a2`, `lefthook.yml 54d03749` equal at 5c7b and in the tree; PREP1 resolutions `r100-quality-gate.yml 0ad6eb8b`, `r100-pathspec.spec.ts be6676d6`, `r75-gate.spec.ts 04190bd6`; `ci.yml 85415cdc`. All equal the packet REPORT and the archived upstream §2.

## 3. Materialised worktree — exact head/index/worktree semantics (`logs/P3`)

`/home/user/workspace/worktrees/s3-prep2` is a **standalone repository** (own `.git` directory; not a linked worktree of `source/backend`; `git-common-dir` = `.git`). State reproduces the recorded PREP2 `05-post-state.txt` exactly:

| Component | Value | Meaning |
|---|---|---|
| `HEAD` | detached at **d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c** | parent 1 (S2 candidate); no branch ref points here; 0 commits ahead |
| `.git/MERGE_HEAD` | **5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06** | recorded in-progress merge parent 2; written as a plain file (the recorded fact), NOT produced by running `git merge` |
| Index (`git write-tree`) | **a584a1b95423f95dae8daabf673ef3776604acbb** | staged PREP2 tree; `ls-files -u` = 0 unmerged |
| Worktree | == index (`git diff --quiet` identical; `diff-files` 0); 2116 tracked = 2116 files; 0 untracked (`--untracked-files=all`) | `git status --porcelain` = 48 lines, **byte-identical** to the recorded listing in `05-post-state.txt` |
| Committed | **NO** — no commit object exists for this tree | a later granted slot would create it; identity/hook/dependency steps are not done here |
| `MERGE_MSG` / `MERGE_MODE` | absent | not recorded in the packet; not invented. `git commit` works without `MERGE_MSG` (message must then be supplied); no `--no-ff` marker is needed for a true two-parent merge |
| Refs | `refs/heads/main`=c23b; `refs/restored/execute/20260921-s2-composition-r2`=d5cd; `refs/restored/execute/20260920-s3-backend`=5c7b; `refs/restored/prep2-tree`=a584a1b9; `refs/restored/prep1-tree`=78a4f0e8 | tree refs keep the objects reachable for gc |
| Modes | 16 `100755` tree entries are `+x` on disk; `git diff --cached --check HEAD` clean; files left owner-writable at default umask (no chmod applied — the recorded PREP2 state had a writable worktree) | — |
| Environment | no `node_modules`, no hooks installed, `core.hooksPath` unset, remotes 0, shallow at c23b, loose objects 24 (tree/patch products), packs 3 | `lefthook.yml` is a tracked file only; nothing installed it |

Method (repo-local, inside the new restoration only): `checkout --force --detach d5cd` (the copied index described the uncopied baseline tree, so `--force` was required, as in the two prior restoration lanes) → `read-tree --reset -u a584a1b9` (sets index and worktree; HEAD unchanged) → write `MERGE_HEAD` → `update-ref` the two tree refs.

## 4. Preservation matrix (`logs/P4`, `PRESERVATION_MATRIX.rederived.tsv`)

Re-derived for all 86 rows from this odb (class from blob equalities; five `y/n` columns): **0 mismatches**; the re-derived TSV is byte-identical to the archived one (sha256 **2d75f532f9f46454a93c1ebdb0f880c0aca2789d4b06d486c398926d156c37a3** both). Path arithmetic: 5c7b vs base 47, d5cd vs base 41, union 86 = matrix rows = `a584a1b9` vs base; two-parent overlap exactly `.github/workflows/ci.yml` and `.github/workflows/r100-quality-gate.yml`.

| class | count | meaning |
|---|---|---|
| S3_PRESERVED | 38 | blob == 5c7b |
| S1S2_PRESERVED | 38 | blob == d5cd (incl. `fly-logs-dump.yml` deletion) |
| FORMATTED_S3_PREP2 | 6 | new blobs; differ from 5c7b, d5cd, base and PREP1 |
| RESOLVED_PREP1 | 3 | manual PREP1 resolutions, unchanged since PREP1 |
| AUTO_MERGED | 1 | `ci.yml` |
| UNEXPECTED | 0 | |

S1-owned paths (`prisma/migrations`, `test/db`): 0 paths differ d5cd→a584a1b9 and 0 paths differ c23b→5c7b.

## 5. Dependencies and ordering (observed, not executed)

- Source prerequisites for a hook-enabled S3 commit are now all present locally as objects: parent 1 d5cd, parent 2 5c7b, staged tree a584a1b9. Environment steps remain absent/held and were NOT started: pinned Prettier 3.9.6 tooling, app `npm ci`, Prisma engines, canonical lock file/holders, repo-local git identity (`user.name`/`user.email` not set in this repo — a commit here without them would use ambient identity; G05 requires `Bradley Gleave <bradley@bradleytgpcoaching.com>` on both fields), lefthook installation.
- Ordering per SCOPE and the packet: S2 clearance/activation precedes any S3 hook-enabled merge; the six formatted files still need independent revalidation (tsc + the S3 specs importing them) before any S3 attestation — the S3 source reviews for those six paths are not byte-current.
- Tool metadata only: git 2.53.0 (note: `/usr/bin/git` on this image is a telemetry wrapper around git; observed in the P5 census as transient own shells), bash 5.3.9.
- Foreign processes observed at P0 (S2 V61 `run-controls-v61.sh`, PIDs 19582/19616/23740/23751/23785, another lane's active slot) were untouched; none present at P5. This lane started no background process and sent no signal.

## 6. Not done / not claimed

No install, dependency, test, formatter run, DB, browser, network, hook, commit, product edit, lock creation/open/probe, process signal, remote write, or private-checkout write. `MERGE_HEAD` records state; no `git merge` was executed and no resolution was re-judged. No review, applicability, equivalence, product-clearance or release claim; runtime/semantic equivalence of the six formatted files is not asserted. Requested model/runtime identity is policy, not telemetry. The private checkout HEAD moved f41027ab → 634fd693 during this lane (parent commits; porcelain 4 → 0); this lane did not write there. The archived upstream lane's statement that `merge-base d5cd 5c7b` was uncomputable is not contradicted: it depends on which objects that odb held; here it is c23b.

## 7. Smallest next action

Parent: accept this restoration as the exact source substrate for the held S3 request-03 slot; grant environment steps (identity, tooling, lock/holders) only under an explicit slot after S2 clearance ordering is satisfied; then six-file applicability (tsc + targeted Jest) and two independent exact-head attestations on the committed head.

## 8. Owned outputs and released ownership

Written: `worktrees/s3-prep2/**` (standalone repo + 2116-file worktree); `execution/6c2a68ac/s3-restore/{REPORT.md, MANIFEST.sha256, PRESERVATION_MATRIX.rederived.tsv, logs/P0–P5}`. `MANIFEST.sha256` covers `REPORT.md`, `PRESERVATION_MATRIX.rederived.tsv` and `logs/*` (non-self-including); the worktree is identified by its Git refs/hashes above, not re-listed. Ownership of both paths is released to parent EXEC-6c2a68ac on this report; this lane holds no process, lock, slot or PID.
