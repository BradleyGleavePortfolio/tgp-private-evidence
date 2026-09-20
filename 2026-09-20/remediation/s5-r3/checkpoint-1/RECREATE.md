# S5 R3 — recreate instructions (exact)

Everything below is reproducible from `s5-r3-candidate.bundle` plus the public backend base; nothing depends on this sandbox's object store, alternates or worktrees.

## 0. Identity of what you are recreating

| Item | Value |
|---|---|
| S5 R3 head | `9f38ab033b08ae30ce2fc62d0150520239d6a5c8` (tree `49d2e03cbb60d81d010bfc524ae2e1a4cd1f425a`) |
| Parent (frozen S5 R2 head, unchanged) | `485c67973b56758fb9b8404579f5ddaec87136bd` (tree `2fbf5028413557f99faea3f1de27b1352a4fe8d4`) |
| Branch | `execute/20260920-s5-r3` |
| Bundle prerequisite (public base) | backend `main` `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` |
| Product base (#529) | `d7404cd49578647cf72bb633819d8e86ffc3da3a`; `git merge-base main execute/20260920-s5-r3` = `c23b9d9f…`; the S5 delta vs `d7404cd4` is test-only (7 files, +1556/−3) |
| O writer source | `925780e0a1906593e5383c618311b6b17364b8dc` (contained in the bundle's history) |
| Dependency lock | `package-lock.json` blob `354de3dae19449970497da6e4d87f0a1225a8f43`, `package.json` blob `656d11a20c6abee819a0b04e9f04c0b66c0a05ef` (identical to S3, different from S1/S2 — S5 needs its own `node_modules`) |
| Author/committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` (verify with `git log -1 --format='%an <%ae> / %cn <%ce>'`) |

## 1. Restore source

```bash
git clone --branch main <backend remote> recovered-s5 && cd recovered-s5
git rev-parse HEAD                      # must print c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 (or contain it)
git bundle verify ../s5-r3-candidate.bundle      # "is okay"; requires c23b9d9f
git fetch ../s5-r3-candidate.bundle execute/20260920-s5-r3:execute/20260920-s5-r3
git switch execute/20260920-s5-r3
git rev-parse HEAD HEAD^{tree}          # 9f38ab03... / 49d2e03c...
git cat-file -t 925780e0a1906593e5383c618311b6b17364b8dc   # commit
git diff --stat 485c67973b56758fb9b8404579f5ddaec87136bd HEAD   # 5 files, +212/-14
```

## 2. Preserved-O fixture (offline, git only) — corrects S5-R2-A-03

```bash
G2_PG17_OLD_ROOT=/abs/path/outside/repo/old-root-925780e0 bash test/utils/g2-pg17-old-root.sh create
# prints: old_root=... head=925780e0a1906593e5383c618311b6b17364b8dc detached=yes migrations=164 alternates=none
#         G2_PG17_OLD_ROOT_OK
```
Default is a self-contained local clone (no alternates). `G2_PG17_OLD_ROOT_SHARED=1` opts into `--shared` when the source repository is guaranteed to stay in place. The script refuses: a non-absolute path, a path inside the candidate root, an existing non-Git directory (e.g. a `git archive` extraction), a branch (non-detached) HEAD, a dirty `package.json package-lock.json src prisma`, manifests differing from the candidate, presence of the E migration directory, a migration count ≠ 164, non-identical `src/scout/*` service files, a ledger model mentioning `source_platform`, or a non-symlink `node_modules`. It never deletes anything.

Logs of this recipe being exercised in the sandbox: `logs/oldroot-bundle-restore-recipe-*.log` (public base clone + R2 bundle fetch + script → OK, `alternates=none`), `logs/oldroot-negatives-*.log` (archive extraction, branch HEAD, dirty path all refused with rc 4), `logs/oldroot-create-*.log` (first attempt failed rc 4 on an over-broad schema check, preserved), `logs/oldroot-recreate-selfcontained-*.log`.

## 3. Dependencies (heavy; parent slot only)

```bash
bash execution/s5-r3/npm-ci.sh      # flock -n on execution/heavy-validation.lock; npm ci --ignore-scripts; prisma generate
```

## 4. Fixture server (S1-owned lane)

`/home/user/pg17/lane-pg.sh s5 start` per S1's `RECREATE_PG17_SYNTHETIC.md` (zonky embedded PostgreSQL 17.6, loopback port 54325, roles `s5_super` superuser, `postgres` NOSUPERUSER BYPASSRLS LOGIN, `service_role`). Password only via `G2_PG17_PASSWORD`. S1's disposable-target guard review must precede this step.

## 5. Proof (serialized; nonblocking lock)

```bash
G2_PG17_PASSWORD=<fixture> bash execution/s5-r3/run-proof.sh reset    # drops ONLY g2_s5_etq0_disposable
G2_PG17_PASSWORD=<fixture> bash execution/s5-r3/run-proof.sh all      # guard -> oldroot -> bootstrap -> live
```
Expected: `test/scout/g2-pg17-db-guard.spec.ts` 26/26; `G2_PG17_OLD_ROOT_OK`; `G2_PG17_BOOTSTRAP_OK` (164 then 165 migrations); `test/rls-g2-pg17-etq0.spec.ts` 51/51 (50 existing + 1 new deterministic refused-branch test); `PROOF_EXIT=0`. Every stage writes `logs/env-<stage>-<TS>.log` with head/tree/status/env (password never logged) and `logs/exit-<stage>-<TS>.log`. If the lock is busy the runner exits 75 without queueing. A failed run is preserved and a second run is allowed only for an infra-class failure (OOM 137, lock busy, server not up), with both logs kept.

## 6. What a reviewer should read in the live log

- `PG17_CLAIM_RACE {"branch":...}` then `PG17_CLAIM_RACE_WORKER {...}`: both branches now end in assertions, not logs (spec "characterizes down against an actual T claim transaction...").
- `PG17_CLAIM_REFUSED_WORKER {...}` from the new test: `result {staged:1,reconstructed:1,...}`, `failure` undefined, `events 1`.
