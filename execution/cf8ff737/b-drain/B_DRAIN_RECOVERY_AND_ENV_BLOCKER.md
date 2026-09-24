# B/drain — exact recovery result and minimum environment proposal

Worker `b_drain_exact_recovery_and_remainder_mufn6ybc`, 2026-09-24 14:46–14:50Z. Requested route Claude Fable 5 (live label Claude Fable 5.1) / High; observed identity and effort are NOT telemetry and are not claimed. Nothing installed, generated, staged, committed, run against PostgreSQL, pushed or spent. Heavy slot NOT taken (no execution needed yet).

## 1. Exact source recovery — DONE (byte restoration only)

| Item | Result | Receipt |
|---|---|---|
| Durable bundle | `c1-execution/bundle/s7-c1-committed-a0ea1bea-from-public-c23b9d9f.bundle`, sha256 `b5126ab5…246f128` == BUNDLE.sha256, `git bundle verify` ok, 3 refs | `recovery/00-bundle-verify.txt` |
| Repo | `/home/user/workspace/worktrees/s7-b-drain`, standalone real `.git`, no remote, no hooks, `core.hooksPath` unset, repo-local identity Bradley Gleave `<bradley@bradleytgpcoaching.com>` (author and committer per `git var`) | `recovery/02-recovered-head.txt` |
| HEAD | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`, tree `87798e742c7b48f56b05e9b5c30efa877180a9b3`, parents `5c760b77` `881c4c79`, ident Bradley/Bradley 2026-09-24T06:03:26Z (== COMMIT_RESULT.txt), 2143 tracked files, porcelain empty | same |
| Shallow graft | `.git/shallow` = `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` (tree `842f17f7…` as recorded) — identical to the original s7-c1 shape (`01-source-recovery-receipt.txt`: "shallow graft = c23b9d9f only"). No network. | `recovery/01-clone.log` |
| Recovery note (C) | `git clone` of the bundle fetched 0 objects because its refs live under `refs/s7/*`; explicit fetch received the 3179-object pack; ref update needed the same shallow graft the source repo had. Recorded, no consequence. | `recovery/01-clone.log` |
| v4 candidate | 11 paths copied from `frozen-v3/files` + `frozen-v4/files` (both packets `sha256sum -c` intact); `frozen-v4/SOURCE.sha256` verifies; live `mode blob path` list == `frozen-v4/BLOBS.git-sha1`; temp-index `write-tree` = **`f4922ca070e887fb7f613ce955b12621b5c33156`**; real index clean, 11 untracked, 0 tracked modified | `recovery/03-frozen-packets.txt`, `04-v4-source-verify.txt`, `04-live-blobs.txt` |
| Sealed PG inputs | `execution/95633079/s7-b-drain/fixture-proposal-v3/` restored to its canonical (hardcoded `D=`) path; `PROPOSAL.v3.sha256` verifies; `b-fixture.sh` = `4525f01d…`; template still has exactly the 5 placeholders | `recovery/05-fixture-proposal-v3-restore.txt` |
| Commit message | `remainder/commit-message.txt` sha256 `fca0b6aa…` == original driver pin, == handoff §7 text | `recovery/06-commit-message-copy.txt` |

Original RC71 driver/logs/sentinel remain untouched in private evidence (`s7-b-drain/phase-a/`).

## 2. Phase-A stage-2 remainder — BLOCKED (class B, execution-only)

**A/B DEFECT (B):** the granted remainder (lefthook install, `tsc`, `eslint`, `prettier --check`, `check-r75`, `jest`, hooked commit) needs the accepted dependency environment; it does not exist in this sandbox and no durable equivalent exists anywhere.

Checked (read-only, no census beyond this):
- `worktrees/s7-c1` absent; `worktrees/s7-b-drain/node_modules` absent; the verified 717M RC71 copy is gone with the old runtime.
- C1 seal: "`node_modules` is not archived"; private evidence is 384M and holds no dependency tree.
- `~/.npm/_cacache` (1022 index entries): 0 entries for `prisma-6.19.3`, `lefthook-2.1.9`, `jest-30.4.2`, `typescript-5.9.3`, `eslint-10.5.0`, `prettier-3.9.6`.
- `/home/user/node_modules` is the sandbox's generic tool set, not the product graph.
- `/usr/local/lib/node_modules/convex/node_modules/prettier` is **3.9.9**; its `bin/prettier.cjs` happens to hash `6e922134…` (the launcher is version-independent), so the approved target hash alone does not prove 3.9.6 — recorded as C; the proposal pins `--version 3.9.6` and `package.json` version in addition to the hash. Not used.
- `/home/user/pg17` and `/usr/bin/psql` absent (irrelevant to phase A; recorded).

**WHY IT BLOCKS:** no local binaries → gates cannot execute; no generated Prisma client → `tsc` cannot even be attempted; no lefthook → no genuine hooks → no commit under G05/G07. Product bytes are exact and unaffected (no A).

**MINIMUM FIX (proposal, NOT run — `env-recovery/env-recovery.sh`, awaiting parent disposition):** reproduce the C1-recorded environment route once, refusing on any pin mismatch, under the canonical slot:

| Step | Command (exact C1 route) | Pin that must match |
|---|---|---|
| 1 | `npm ci --no-audit --no-fund --ignore-scripts --loglevel=error` in the recovered worktree (lock blob `354de3da`, package.json `656d11a2`, node v20.20.1, npm 10.8.2 — all already equal) | `node_modules/.package-lock.json` sha256 `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`; versions lefthook 2.1.9, prisma/@prisma/client 6.19.3, jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, eslint 10.5.0; write-tree still `87798e74` |
| 2 | `./node_modules/.bin/prisma version` (pinned CLI fetches engines, exactly as C1) then `./node_modules/.bin/prisma generate` | engines hash `c2990dca…`; libquery `a2924eab…`, schema-engine `5d42b181…`; `.prisma/client/index.d.ts` sha256 `bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5` |
| 3 | tooling-only `npm ci --ignore-scripts` from preserved manifests (`package.json` `6c39ea3d…`, `package-lock.json` `3e2189ff…`) into uniquely named `execution/cf8ff737/b-drain/tooling/prettier-3.9.6/`; then absolute link `node_modules/.bin/prettier → …/prettier/bin/prettier.cjs` (same shape as C1/RC71) | `prettier.cjs` sha256 `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`, `--version` 3.9.6 |

Necessity: generation/installation is required because no copy exists to reuse — this is the "actual necessity" case, not a re-buy of existing evidence. Network: registry reads only (integrity-pinned by the lock), the same three reads C1 made; no spending, no product lock change, no tracked-file change. Bound ≈ 6–8 min (C1: 6 min). Product remains at `87798e74`/untracked v4.

Not proposed now: PG 17.6 jar/binary or `psql` (only needed for the later separate PG grant; pins are in `c1-pg/ENVIRONMENT_RECOVERY.md`), any cluster, any accepted-suite rerun, any source edit.

**EXECUTION UNLOCKED:** on rc 0 of the above, run the stage-2 remainder driver (`remainder/remainder.sh`, being written next; not run): reassert base/v4/pins + the two dependency hashes + formatter target hash/version → `lefthook install` → stage 11 paths (tree must equal `f4922ca0`) → ordered gates with first-nonzero stop → hooked Bradley commit with the pinned message → substitution-only filled binding at `execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh` → bundle/patch → release slot.

## 3. Requested disposition

GO / NO-GO on `env-recovery.sh` (step 1–3 above). On GO I run it and, if rc 0, the remainder in the same slot, then return actual head/gate/binding receipts without self-acceptance.
