# OP88-UPSTREAM-PREP — dependency hold and portability delta (proposed, NOT applied)

Nothing below has been installed, created, or run. Each item is the smallest concrete delta needed before the archived commands (S3 `SLOT_REQUEST_03` + Addendum A; S2 `SLOT_REQUEST_03_B3_R3`) can execute in this fresh workspace. Ordering follows the wave: S2 clearance (V5.6 dual reviews → controls → real proof) precedes S3 hook-enabled merge.

## 1. Smallest concrete missing dependency (blocks S3 merge commit; does not block S1/S2 real proof)

**Missing object: S3 head commit `5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06`.** Named source per the continuation brief: `tgp-private-evidence/2026-09-20/remediation/s3-evidence-completion/revision-2/s3-backend-5c7b42b3.bundle` (+ its REPORT/PUBLICATION_MANIFEST for the advertised sha256). The `2026-09-20/` directory is not present in this workspace's private-evidence checkout; no other bundle contains 5c7b (search: 0 hits; `git cat-file -e` without lazy fetch: absent). Consequences:
- The PREP2 **tree** is fully reproduced (a584a1b9), so tree-level work (tsc/lint/Jest on a detached checkout of the tree) needs nothing more than dependencies.
- The PREP2 **merge commit** (request-03 steps 07–08: `%P == "d5cd9b8b… 5c7b42b3…"`, `.git/MERGE_HEAD`) cannot be constructed honestly without the 5c7b object. Writing the sha into `MERGE_HEAD` by hand is not acceptable: git would reference a missing parent object and the two-parent ancestry claim would be unverifiable. Also `full-vs-parent2-5c7b42b3.patch` and matrix column `eq_S3_5c7b` stay unverified.
- Parent action requested: restore the `2026-09-20` S3 revision-2 packet (or re-supply the bundle with its manifest) into the private evidence checkout. On arrival this lane will: `sha256sum` vs manifest → `git bundle verify` in `backend-s1s2-d5cd` → fetch to `refs/op88/s3-bundle/*` → assert tree of 5c7b, `git apply --cached full-vs-parent2-5c7b42b3.patch` on `5c7b^{tree}` → `write-tree == a584a1b9`, re-derive `eq_S3_5c7b`, then prepare a detached worktree with `HEAD=d5cd9b8b`, index=a584a1b9, `MERGE_HEAD=5c7b42b3` (the state request-03 §0 requires). No commit.

## 2. Fresh setup prerequisites for archived commands (each is a separate named grant; none granted)

| # | Archived assumption | Fresh workspace | Proposed delta (not applied) | Scope owner |
|---|---|---|---|---|
| P1 | `W=/home/user/workspace/worktrees/s3-composition-prep` (branch `execute/20260922-s3-into-s1s2-prep`, HEAD d5cd, MERGE_HEAD 5c7b, index a584) | absent | `W=/home/user/workspace/worktrees/op88-upstream/wt-prep2-a584a1b9` created from `refs/op88/prep2-tree` after §1; every request-03 `$W` reference maps 1:1 | this lane, after §1 |
| P2 | `TOOL=/home/user/workspace/execution/s3-composition-prep/tooling/prettier-3.9.6` with installed `node_modules/prettier/bin/prettier.cjs` sha256 `6e922134…906e` | manifest only (package.json `6c39ea3d…`, package-lock `3e2189ff…`) in request-02 packet; no binary | re-run PRETTIER-ONLY-01 step 01/02 pattern: copy manifest to `execution/op88/upstream-prep/tooling/prettier-3.9.6/`, `npm ci --ignore-scripts` (registry network, 180+30 s), assert version 3.9.6 + binary sha256 `6e922134…` + `find node_modules -maxdepth 1` = `.bin .package-lock.json prettier`; `TOOL` path substituted in request-03 steps 01/05/06 | grant required (network) |
| P3 | product `node_modules` (request-03 step 02 `npm ci --ignore-scripts`, 1117 pkgs, ~6 min; lock `354de3da`/sha256 `b7fed5ed…9c55`) | absent | run only inside `$W` per step 02 as written; first heavy allocation; must not overlap S2 controls/real proof; `CHECKPOINT_DISABLE=1` exported first (Addendum A) | grant required (network, heavy) |
| P4 | Prisma engines (step 03 `prisma generate`) may fetch from binaries.prisma.sh | no cache | as archived: visible in log, `PRISMA_GENERATE_SKIP_AUTOINSTALL=true CHECKPOINT_DISABLE=1` inline; disclose egress | grant required |
| P5 | canonical lock `/home/user/workspace/execution/test-validation.lock` + `.holders` | absent | parent creates/owns the empty lock file and `.holders` (touch only) before any `flock -n`; `flock -n` would auto-create it otherwise, which would make the first holder the file owner | parent |
| P6 | repo-local identity `Bradley Gleave <bradley@bradleytgpcoaching.com>` (`git var GIT_AUTHOR_IDENT`) | unset in the isolated clone (`git var` fails: identity unknown) | `git config --local user.name/user.email` in `backend-s1s2-d5cd` only, right before step 07; G05 requires verification on the landed commit, not the config | grant with step 07 |
| P7 | `O=/home/user/workspace/execution/s3-composition-prep/slot-03/<UTC>` | absent | `O=/home/user/workspace/execution/op88/upstream-prep/slot-03/<UTC>` | this lane |
| P8 | GNU-style `timeout --kill-after` | uutils coreutils 0.8.0 (`--kill-after` supported; exit 15 observed by S2 under group TERM) | stamp `timeout --version` in every step header; do not assume GNU exit mapping | all lanes |
| P9 | S2 B3: `/home/user/pg17/dist` PG 17.6, `infra/s2-fixture.sh` sha256 `6062f4ce…`, `launch-detached.sh` `64302b3e…`, `check-lock.sh`, A2 dependency closure symlink, `execution/s2-composition/` | none present (only S2-setup-prep proposal copies of launcher/check-lock exist under `2026-09-22/remediation/s2-setup-prep/proposal-1/infra/`; fixture 6062 absent) | S2 owner's separately versioned setup (state: "Missing 6062 fixture requires separately versioned preparation"); PG 17.6 install is a new heavy allocation; outside this lane | S2 owner / parent |
| P10 | Platform `/home/user/node_modules` read-only, 209/210 entries, inventory hash | 209 entries, observed writable, listing sha256 `8c95688c9a441a38…` | record before/after listing hash per slot; do not write there | all lanes |
| P11 | hooks: `core.hooksPath` unset, `.git/hooks` samples only | same in isolated clone (0 active hooks) | lefthook install only at request-03 step 04 | grant |

## 3. What the S1/S2 real-proof slot needs from this lane (ready now)

- Exact source: `refs/op88/s2-bundle/…` = d5cd9b8b (tree c0ab87d4), detached read-only checkouts `wt-s2-d5cd9b8b` and `wt-s1-56fb0d22`.
- Discriminator bytes (`82da49b2…`), controls (`6a88a98c…`), predecessor verifier pin (`2bbce0d7…`), harness (`c766a8d9…`), release.sh (`8831f8f7…`) — staged, hashed.
- 164+1 replay requirement documented; B3 expects harness 68 checks and S1 discriminator 47/48 (S1 interprets) — expectations, not results.
- Not provided by this lane: PG 17.6 fixture, app dependencies, the V5.6 runner (S2 fixer output), any grant.

## 4. Explicitly not done

No product/schema/runner edits; no `npm`/`npx`/network; no PG; no hooks; no commit; no live staged worktree with MERGE_HEAD; no rebuild of the 17/7 mutant controls or of the S3 head; no reading of `execution/op88/s2-v56` or any current peer output.
