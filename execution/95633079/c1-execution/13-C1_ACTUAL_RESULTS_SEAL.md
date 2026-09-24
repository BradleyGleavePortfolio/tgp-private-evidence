# C1 recovery + local validation — actual results seal

Additive record by the sole C1 recovery/builder/executor, session `95633079`, 2026-09-24. This is an executor record of what actually ran, **not** an audit verdict, acceptance, or claim of importer/product completeness. Independent A/B attestation of these receipts is a separate pending phase.

## 1. Actual committed head

| Pin | Value |
|---|---|
| HEAD / commit | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |
| Tree | `87798e742c7b48f56b05e9b5c30efa877180a9b3` (== frozen index tree) |
| Parent 1 (ordered) | `5c760b774598532e90d5d217e15adc9285c3c3f4` (accepted S7 foundation) |
| Parent 2 (ordered) | `881c4c791727adef8d423931e1cca83a0ffbb9c9` (PR526 head) |
| Parent 3 | none |
| Author | `Bradley Gleave <bradley@bradleytgpcoaching.com>` 2026-09-24T06:03:26Z |
| Committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` 2026-09-24T06:03:26Z |
| Trailers (`co-authored-by` / `generated with` / `signed-off-by`) | 0 matches |
| Delta vs parent 1 | exactly the 18 frozen paths |
| Post-commit state | `.git/MERGE_HEAD` absent, `git status --porcelain --untracked-files=all` = 0 |

Raw object bytes: `12-actual-commit-object.txt`. Raw message bytes: `12-actual-commit-message.raw`.

**Message byte binding (closes launcher note C04 for this head):** `git log -1 --format=%B` emits the approved text plus one Git-added trailing newline, sha256 `23d221921356ad09c6b19f0589755ed7b9fa7d5c16212e8f862648e19181225b`. With that single trailing newline removed the bytes hash to **`288048d7b7e908f8803d3d70e57465f52cfc9f102bb4bc4b1dba30143ce7cb83`**, exactly the parent-approved `07-merge-message.r2.txt`. The committed message is therefore byte-identical to the approved input modulo Git's newline handling; the launcher's non-fail-closed note was the only reason a difference was recorded.

## 2. Hook statuses (ordinary route, no bypass)

`lefthook install` completed in the first launch with raw **rc 0**; the continuation reused those installed hooks (pre-commit `a868b3a9ee25a048ca80c26b875e2b41b829f7d7fe325b2c3b585e3a368aef46`, commit-msg `a46fa3984a49a61212e9ed239cde4e0e6642cc89a708c92e766cbd0fc64686f8`, native Lefthook 2.1.9 `974486e94169a44b38d60e4d26491ed205416ca16c93621f8f69b52d401c3a79`). `core.hooksPath` unset, no `--no-verify`, no `LEFTHOOK`/`LEFTHOOK_BIN`, no local override file.

| Hook | Job | Result | Time |
|---|---|---|---|
| pre-commit | prod-readiness-quick | ✔️ | 0.02 s |
| pre-commit | banned-cast-tokens (R75 `--cached`, policy `.github/r75-policy.json`) | ✔️ "no positive token change" | 0.35 s |
| pre-commit | prettier (`--check`, pinned 3.9.6) | ✔️ "All matched files use Prettier code style!" | 2.71 s |
| pre-commit | eslint (`--no-warn-ignored --max-warnings 0`, 13 staged files) | ✔️ | 3.89 s |
| pre-commit | tsc `--noEmit` | ✔️ | 48.22 s |
| commit-msg | no-ai-tokens (R3) | ✔️ | 0.01 s |

Preserved qualification carried forward from the accepted foundation: `prod-readiness-quick`'s script is not tracked at this tree, so its conditional `[ -x ]` body did not execute. Its ✔️ is **not** production-readiness evidence. R75, formatter, lint, typecheck and message validation did actually run.

## 3. Targeted Jest (existing lane only, unchanged command)

`timeout -k 30 600 ./node_modules/.bin/jest --ci --runInBand test/contracts/importer-contract.spec.ts src/extension-pair/__tests__` — raw **rc 0**, 06:04:15Z→06:05:23Z.

- Test Suites: **11 passed, 11 total**
- Tests: **190 passed, 190 total**
- Snapshots: 0 total; Time 66.333 s
- PASS: `test/contracts/importer-contract.spec.ts` (60.048 s), `extension-pair.service.spec.ts`, `durable-session.spec.ts`, `durable-intent.spec.ts`, `extension-pair-redeem-contract.spec.ts`, `auth-mint-extension-session.spec.ts`, `extension-pair.controller-wiring.spec.ts`, `extension-pair.dto.spec.ts`, `setup-recovery.spec.ts`, `extension-pair.controller.spec.ts`, `coach-guard-role.spec.ts`
- Post-Jest guard: HEAD unchanged at `a0ea1bea…`, working tree clean.

No PG lane ran. `test/rls-c1-setup.spec.ts` is excluded by the default Jest config and was not executed. No new test, harness or suite expansion was introduced.

## 4. Terminal sentinel and preserved prior receipt

| Receipt | Content |
|---|---|
| `logs/10-validate-continue.sentinel` | `RC=0 STAGE=done END=2026-09-24T06:05:23Z HEAD=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |
| `logs/09-validate.sentinel` (PRESERVED, unchanged) | `RC=71 STAGE=hooks-missing END=2026-09-24T05:53:33Z HEAD=5c760b774598532e90d5d217e15adc9285c3c3f4` |

The first launch's failure stands as failed and was never overwritten, retried, or relabelled; its Lefthook install child's raw rc 0 stands as a separate fact. The frozen launcher `a57c224c6e8e9364393318efaa99c33f4a90877287d7e1a7e370b1c75b220448` was never edited and was not called again. Executed continuation: `10-validate-continue.sh` `47c27fb9c700c797c55e7216378581d193dd8de63ec9f85aff08534f5d81bb1c`, granted A:0/B:0 in `audits/c1-a/REMAINDER_BINDING_REVIEW.md`.

## 5. Recovery provenance (this sandbox)

- Standalone repo `worktrees/s7-c1` with a real `.git/` directory; prerequisite public `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7` fetched depth-1 read-only (tree `842f17f7…` == GitHub API); parents bundle `a238a7b1…` verified; clean checkout of `5c760b77`; frozen patch `a413891a…` applied `--index` (rc 0) → tree `87798e74…`; 18 index blobs identical to `INDEX_BLOBS_18.txt`; `.git/MERGE_HEAD` written directly — **no merge was re-run and nothing was re-resolved**.
- Frozen packets copied to the hard-coded execution paths: original 52/52 (`128496e2…`), formatted 24/24 including historical `logs/00…09-message-check.txt` (`8ef86a1b…`), handoff bundle verified. No stale sentinel or `COMMIT_RESULT.txt` was seeded.
- Environment (absent only): `npm ci --no-audit --no-fund --ignore-scripts --loglevel=error` rc 0, 1117 packages, installed record `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`; Prisma engines recovered at the locked official hash `c2990dca591cba766e3b7ef5d9e8a84796e47ab7`; one `prisma generate` → client `bf679a16e50a6f0c39528887b80c2a03c5d0825b816cec3417fcbc94300b72d5`; external Prettier 3.9.6 restored at `execution/e7d2385c/s5-continuation/tooling/prettier-3.9.6/node_modules/prettier` (CLI `6e922134a3c76fd4de202959bb6aef50bde0c994148075003a15569b7197906e`) with the local `.bin/prettier` link. The committed contract artifact `bdb022dd…` was **not** regenerated. No formatter run, no source edit.

## 6. Portable durability artifact

`bundle/s7-c1-committed-a0ea1bea-from-public-c23b9d9f.bundle`, sha256 **`b5126ab5336dacfe6b7d56ea18d449eb65a764059bd77ce77b022f51e246f128`**, refs `refs/s7/c1-committed` = `a0ea1bea…`, `refs/s7/foundation-5c760b77`, `refs/s7/c1-881c4c79`; `git bundle verify` reports a complete history. `node_modules` is not archived.

## 7. Process and slot state

No task-owned process remains (no Jest, tsc, Lefthook, Prisma, PostgreSQL, launcher or install wrapper; the install wrapper's idle guardian was terminated after its result was captured). Only platform daemons are running. The heavy lock `execution/test-validation.lock` is released after this seal; the recovered environment is retained.

## 8. Explicitly not claimed

No PG fixture, C1 cluster, disposable database or 22-case RLS proof exists or ran. No remote push, merge, deployment, production/customer enablement or source-account write occurred. No S1–S6 / S7-foundation rerun, no E/T-Q0, no source re-audit, no new tests or harness. This seal claims exactly: exact recovery, ordinary genuine-hook commit at `a0ea1bea…`, and the existing targeted contract/pairing Jest lane passing — nothing broader.
