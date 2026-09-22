# OP88-UPSTREAM-PREP — execution-ready input map (S1 / S2 / S3)

Writer: op88 T4 upstream integration preparer (Fable integration builder role; not an auditor, not a fixer). Contract: `execution/OP88_WAVE1.md` §S1/S3 OP88-UPSTREAM-PREP + common contract. Frozen 2026-09-22T20:5xZ. Nothing here is a clearance, a test result, or a grant.

Isolated restoration root: `/home/user/workspace/worktrees/op88-upstream/` (owned by this lane only; not shared with the S2 V5.6 fixer; baseline `/home/user/workspace/source/backend` untouched — see REPORT §4).

## 1. Restored identities (verified locally, no network; `GIT_NO_LAZY_FETCH=1` on every git call)

| Item | Exact identity | Where restored | Verification (log) |
|---|---|---|---|
| Public base | commit `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` | `worktrees/op88-upstream/backend-s1s2-d5cd` (byte copy of local baseline; HEAD detached at c23b9d9; porcelain 0; hooks 0; origin URL neutralised, promisor off) | `logs/00-clone-state.txt` |
| S2 bundle | `s2-composition-r3-d5cd9b8b-from-public-c23b9d9.bundle` sha256 `3b6cee481319dd518268b7573ebed142fa234e193b874d8712a6cdf5493c0f75` = ARCHIVE_SHA256SUMS = LAST_OPERATOR_STATE "3b6cee48…0f75"; `git bundle verify` okay; prerequisite `c23b9d9f…`; sole head `d5cd9b8b…` | fetched to `refs/op88/s2-bundle/execute/20260921-s2-composition-r2` | `logs/01-s2-bundle-verify-import.txt` |
| S2 head | `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, parent `21ea3252…` | detached worktree `wt-s2-d5cd9b8b` (porcelain 0, no node_modules) | `logs/02-s2-identities.txt`, `logs/03-heads-checkout-and-s1-blobs.txt` |
| S1 head | `56fb0d227558c86fe824f9fb1bc15e222411504f`, tree `79ebf1750ca0e49e511666bafcfaf967f0ba39cc`, parent `41f4d6a9…`; ancestor of `21ea3252` (2nd parent) and of `d5cd9b8b` | detached worktree `wt-s1-56fb0d22` (porcelain 0) — restored FROM the S2 bundle; no separate S1 bundle exists in this workspace | same |
| B2 composed head | `21ea3252de90cab66c591cf907b65a0ee7eef879`, tree `5aa6630b7b293cc00c4841961967f3d9eeba1fbe`, parents `3f49ffc8` + `56fb0d22` | in odb | same |
| Commit list | 23 commits `c23b9d9..d5cd9b8b` identical to archived `commits-r3.txt`; all author = committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no trailers | — | `logs/02-s2-identities.txt` |
| Object completeness | 0 missing objects reachable in `c23b9d9..d5cd9b8b`; 0 missing blobs in d5cd and 56fb trees | — | same |
| S3 PREP2 tree | `a584a1b95423f95dae8daabf673ef3776604acbb` **reproduced exactly** = `read-tree d5cd9b8b^{tree}` + `git apply --cached patches/full-vs-parent1-d5cd9b8b.patch` (archived PREP2 packet, all 25 packet hashes OK) | `refs/op88/prep2-tree`; immutable snapshot `staged-inputs/s3-prep2-tree-a584a1b9/prep2-tree-a584a1b9.tar.gz` (round-trips to the same tree id) | `logs/04-prep2-tree-reproduction.txt`, `logs/07-archive-roundtrip.txt` |
| S3 PREP1 tree | `78a4f0e8c22e9b9e902bbaae0b9f5623b9fbfa69` reproduced by reverse-applying `prep2-six-files-vs-prep1-78a4f0e8.patch` on PREP2 | `refs/op88/prep1-tree` | `logs/04-…` |
| S3 head | `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06` | **ABSENT** — no object, no bundle, no `2026-09-20/` packet, no `initialization/recovered/s3-r2-5c7b` in this workspace | `logs/04-…`, `logs/06-…` |

No resolutions were invented: the PREP2 tree came only from the archived patch; the three PREP1 resolutions (`0ad6eb8b`, `be6676d6`, `04190bd6`) and six formatted blobs (`f59584d9 8440664f d5c60dfb af24f743 acd38f2d a8885dfd`) are byte-equal to the packet's `after/` files; `PRESERVATION_MATRIX.tsv` columns prep2_blob / eq_prep1 / eq_S2_d5cd / eq_base_c23b re-derived for all 86 rows with zero mismatches (the one `fly-logs-dump.yml` line is a notation difference: matrix says `absent`, tree shows deleted). Column `eq_S3_5c7b` is NOT re-derivable locally (`logs/05-prep2-tree-content-verification.txt`). Indirect S3 evidence only: the packet's six `before/` files hash to the S3 blob ids recorded in `00-pre-state.txt` (`c7f45409 61e25bec 22c04573 550f1df5 cd089439 385c6741`).

## 2. S1 inputs ready (bytes from commit 56fb0d22 == d5cd9b8b, `git diff 56fb0d22 d5cd9b8b -- prisma/migrations test/db` empty)

Staged read-only under `staged-inputs/s1-56fb0d22/` (SHA256SUMS inside, non-self-including):

| File | sha256 | Matches |
|---|---|---|
| `prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql` | `266e62e9…9448` | FROZEN_COMPOSED_SUCCESSOR, S1 R4 B §1 |
| `…/migration.sql` | `72b0ad5a…e344` | same |
| `…/down.sql` | `dd7dd6f3…7bdeb` | same |
| `test/db/_support/s1-target-guard.sh` | `6f66e436…8ec` | same |
| `test/db/_support/supabase-like-bootstrap.sql` | `e8c42d2e…a60` | same |
| `test/db/_support/s1-truncate-controls.sh` | `6a88a98c…a65c` | same |
| `test/db/s1-r4-truncate-discriminator.sh` (the unrun discriminator) | `82da49b2…9921` | same |
| `test/db/s1-r4-truncate-message-spec.sh` (offline 24/24 spec) | `b8be189d…9937` | same |
| `test/db/s1-rls-close-public-exposure.sh` (full harness) | `776a0339…5fd` | same |
| `test/db/s1-harness-guard.spec.sh` | `1356eb0d…` | (not previously tabulated) |
| `predecessor-b7d7fe59/verify.sql` (provenance pin for the discriminator) | `2bbce0d7…323e` | pinned value |

Replay requirement preserved: base `c23b9d9` has **164** migration directories; `d5cd9b8b`, `56fb0d22` and PREP2 `a584a1b9` each have **165**; the single 165th is `20261224000000_rls_close_public_exposure`; `prisma/schema.prisma` and `migration_lock.toml` unchanged vs base. Real replay is 164 parents + candidate 165 against a fresh PG 17.6 cluster — never ledger-only; not run here.

NOT available: the 17/7 negative-control mutant controls (sha256 `e60f9523…`) — referenced by S1 R4 B (S1-R4B-03) and A evidence, bytes never preserved; zero files in the private evidence hash to it. Not rebuilt (would be reimplementation).

## 3. S2 inputs ready

- `scripts/release.sh` sha256 `8831f8f7…f073` (blob `c86b3ab9`), `test/release/s1s2-composition.sh` sha256 `c766a8d9…3867` (68-check harness, R3 delta vs B2 harness `44737549…`), `package-lock.json` `62b05b90…1390`, at d5cd — all match SLOT_REQUEST_03_B3_R3 / FROZEN_COMPOSED_SUCCESSOR.
- Archived S2 runner history and B3 request are readable at `tgp-private-evidence/2026-09-21/remediation/s2-composition/b2-failed-and-r3-source/` (immutable; not copied). The S2 V5.6 successor is the S2 fixer's output and is **not** an input here; this lane does not read `execution/op88/s2-v56`.
- Commit-message note for any future hook check: the archived `git cat-file -p HEAD | grep -c -iE 'co-authored|generated|…'` regex is intended for the new merge commit only; applied to the 23 historical messages it hits once on the benign phrase "ships the generated @prisma/client" (commit 93a85544 body).

## 4. S3 inputs ready / partially ready

| Input | Status |
|---|---|
| PREP2 tree `a584a1b9` (46 hook-matching staged paths, list sha256 `44b8a947…` all present in tree; 48 paths vs d5cd; 6 vs PREP1; 86 vs base) | READY as tree object + tar.gz snapshot |
| Product `package-lock.json` blob `354de3da` (sha256 `b7fed5ed…`), `package.json` `656d11a2`, `lefthook.yml` `54d03749` at PREP2 (= S3 values per request-03) | READY in tree |
| Request-03 (`e707ec2a…`) and Addendum A (`68872675…`) — both sha256 OK | READY, readable in place |
| Pinned formatter tooling manifest (`tooling/prettier-3.9.6/{package.json 6c39ea3d…, package-lock.json 3e2189ff…, PROVENANCE.md}`) at request-02 packet | READY as manifest; **binary not installed** (expected sha256 `6e922134…906e`, v3.9.6) |
| Merge parent 2 / `MERGE_HEAD` = `5c7b42b3` | **MISSING** (see DEPENDENCY_HOLD §1) |
| `full-vs-parent2-5c7b42b3.patch` reproduction | not testable without 5c7b |

## 5. Environment observed (fresh workspace, 2026-09-22T20:53Z)

node v20.20.1, npm 10.8.2 (libnpmexec `index.js`/`file-exists.js` present at the archived paths — request-03 §2 resolution reasoning is portable), git 2.53.0, bash 5.3.9, python 3.14.3, `timeout` = uutils coreutils 0.8.0 (stamp it; not GNU), flock util-linux 2.41.3. `~/.npm/_npx` absent (N0=0 as archived). Platform `/home/user/node_modules`: 209 entries, listing sha256 `8c95688c9a441a38…`, `.bin/eslint` present (W1 shadowing still applies), no `.bin/prettier`; observed **writable** here (state file said read-only — record, do not rely). No PG 17.6 (`/home/user/pg17/dist`, psql, pg_ctl, initdb all absent). No app `node_modules` anywhere in the lane. Canonical lock `execution/test-validation.lock` and `.holders` absent. Disk 9.7 GB free, 2 CPU, 7 GB RAM. Only platform daemons running (code-mode tsx/esbuild), none owned by this lane.
