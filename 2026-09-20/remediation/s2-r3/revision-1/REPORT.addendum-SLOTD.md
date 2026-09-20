# S2 R3 REPORT — Addendum (SLOT D, 2026-09-20 23:25–23:31Z)

Supersedes the frozen-head statements of REPORT.md/HEAD.txt for `1c6db2b6`. New frozen head:
**`e15e25c28824b43558f7c231eec26a5ac64bafa9`** (tree `b2fa201d…`), branch `execute/20260920-s2-r3`, clean, author and
committer `Bradley Gleave <bradley@bradleytgpcoaching.com>` (git var verified before, fields verified after). Bundle
`bundle/s2-r3-e15e25c2.bundle` (sha256 `1e99b323883ec1d4dced5574208b9ce93e8d5d5e0d34aa6219a7ffae68cb8c6c`, requires
`c23b9d9f`, `git bundle verify` OK). The `1c6db2b6` bundle/HEAD/manifest are left in place as history.

## 1. First real jest run at 1c6db2b6 (shared S1 npm-ci tree, Node v20.20.1, jest 30.4.1)
- Attempt `20260920T232526Z` (wrapper rev 2, `NODE_PATH` only): **all 4 suites failed to compile, 0 tests** —
  ts-jest could not resolve `@types/jest` (`TS2582/TS2304`). Root cause: TypeScript resolves `@types` by walking
  `node_modules/` up from the spec; `NODE_PATH` does not influence it. Log preserved.
- Resolution without install: `worktrees/s2-r3/node_modules` → symlink to `worktrees/s1-r3/node_modules` (git-ignored;
  `git status` stays clean; shared tree used read-only). Wrapper rev 3 requires and verifies this layout.
- Attempt `20260920T232605Z`: **171 passed, 1 failed** (172). Failure: `delivery-artifact.spec.ts › operator workflows —
  dispatch inputs are data › fly-launch-env-set.yml` — the assertion requires `"${APP_NAME}"`; the workflow had
  `"$APP_NAME"` at lines 61/79 (quoted, env-only, still safe — the test was stricter than the workflow).

## 2. Withdrawal
REPORT.md §4 / earlier messages claimed a plain-Node mirror of the new jest assertions returned "all true". That mirror was
**not faithful** for the brace-form assertion above; the claim is withdrawn. Only the real jest runs recorded here count.

## 3. Fix on the new head (parent-approved)
`e15e25c2` — `fix(delivery): brace-quote APP_NAME in fly-launch-env-set` — two tokens `"$APP_NAME"` → `"${APP_NAME}"`. No
behavioural change; brings the seventh app-input workflow to the same braced form as the other six. Tests unchanged.

## 4. Proof bound to e15e25c2 (all under the canonical non-blocking lock; lock released 23:29:46Z)
| Check | Result | Log |
|---|---|---|
| jest `test/ci` (real, shared tree) | **4 suites / 172 tests passed, exit 0** | `logs/jest-test-ci-at-e15e25c2-attempt-20260920T232827Z.log` |
| p01 workflow static | 19 workflows, 0 failures | `logs/FINAL-proof-at-e15e25c2.log` |
| p02 hostile dispatch exec (fake flyctl) | 352 step executions, 0 failures | same |
| p03 release.sh verifier contract (fake prisma) | 16/16 | same |
| shellcheck 0.10.0 (`scripts/**/*.sh`, 10 files) | 0 findings | same |
| actionlint 1.7.7 (with shellcheck) | 0 findings | same |
| braced/unbraced `APP_NAME` in fly-launch-env-set.yml | 2 / 0 | same |
| git state after proof | head `e15e25c2`, clean | same |

Not run / not claimed: full backend jest suite, hosted GitHub runners, Fly, any DB. Identity of the runtime is not verified.

## 5. /tmp hygiene
The e15e25c2 p03 run again wrote fake-npx content to the five hardcoded `/tmp/prisma_*`/`/tmp/release_verifiers_*` paths
(under the lock). Moved under the lock to `logs/tmp-contamination-quarantine-2/` at 23:30Z; `/tmp` is clear. Follow-up
(later head): make `release.sh` honour `TMPDIR`.

## 6. Composition (no execution)
`git merge-tree --write-tree b7d7fe5 e15e25c2` → tree `3d494b74b1e2894060540a6944c3c9462ae253c8`, exit 0, no conflicts.
`COMPOSITION_PROOF_PLAN.md` updated to S1 ADDENDUM_02: 164 parent migrations replayed by real `migrate deploy` + candidate
= 165 (record actual), dedicated DB `s1_rls_s2comp`, S1's exact preparation recipe, then unmodified integrated release.sh.
Awaiting a DB grant; runner not yet written (interface variables per S1 ADDENDUM_01/02 to be pinned first).
