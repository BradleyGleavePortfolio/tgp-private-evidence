# B/drain — same-review actual-head / identity / gates / binding attestation (reviewer A, successor)

Continuation of `audits/b-drain-a/B_DRAIN_V4_BINDING_REVIEW_A.md` §3–4 and of my `B_DRAIN_CONTINUATION_A_PRELIM_20260924T1456Z.md`. Successor reviewer A; requested route Claude Fable 5 (live label 5.1) / High — request only, no telemetry observed or claimed. Peer B unread. Read-only recomputation against the live repo and receipts (`git rev-parse/ls-tree/diff-tree/cat-file/log`, `sha256sum`, `diff`, `flock -n … true`); no gate rerun, no source re-audit, no candidate/worktree/index write. Observed 2026-09-24 15:05–15:08Z.

## 0. Disposition

**Committed head `75a2863bf79a44f84050406d6878ec9a87f4053e` is BOUND: it is exactly the SOURCE_GRANTABLE v4 tree on the accepted base, produced through genuine hooks and the granted gates, and the filled binding is substitution-only with correct pins. From reviewer A's side the single B PG proof is GRANTABLE once the already-pinned PG 17.6 / psql recipe (`c1-pg/c1-env-recovery.sh` route) has been re-executed with matching hashes — that recovery is the only remaining precondition and is not a new finding.** No A/B finding is open. The original source verdict remains applicable unchanged.

## 1. Environment recovery (B-ENV-ABSENT closure) — recomputed, matches

| Pin | Observed by this reviewer |
|---|---|
| `node_modules/.package-lock.json` | `05bc530a…` == C1 record; real directory inside the worktree (not a symlink); 649 entries / 717M (same as the RC71 copy) |
| `.prisma/client/index.d.ts` / client `schema.prisma` | `bf679a16…` / `cbb5d402…` == C1 records |
| Prisma engines | libquery `a2924eab…`, schema-engine `5d42b181…`, engines hash `c2990dca…` in `02-prisma-version.txt` |
| Resolved versions | lefthook 2.1.9, prisma/@prisma/client 6.19.3, jest 30.4.2, typescript 5.9.3, eslint 10.5.0, ts-jest 29.4.9 |
| Lefthook native binary | `974486e9…` == C1 `hook-hashes.txt` |
| Prettier | `.bin/prettier` → `execution/cf8ff737/b-drain/tooling/prettier-3.9.6/node_modules/prettier/bin/prettier.cjs`, sha `6e922134…`, package + `--version` 3.9.6 |
| Tracked bytes | `write_tree` `87798e74…` before/after; product lock contains no `node_modules/prettier` package (link precondition legitimately held) |
| Sentinel | `RC=0 STAGE=done END=2026-09-24T15:01:17Z`; npm ci rc 0 (1117 packages), tooling npm ci rc 0 (1 package) |

Qualification (C): this is a **hash-equal reconstruction via the recorded C1 route**, not a copy of the C1 tree; the sealed template's prose "not a fresh npm ci" is satisfied in substance by its two machine-checked hashes. Recorded; no change requested.

## 2. Hooks, staging, gates — from receipts (no rerun)

- Pre-state: no non-sample hooks, `core.hooksPath` unset, index clean, exactly 11 untracked paths equal to `frozen-v4/BLOBS.git-sha1` (builder `00-live-blobs.txt` diff empty; my independent hash-object pass in the prelim note agrees).
- `lefthook install` rc 0 → `.git/hooks/pre-commit` `e5723334…`, `commit-msg` `29f83d8e…`, both executable and lefthook-referencing, resolving to the **local** `node_modules/lefthook-linux-x64/bin/lefthook` (no global lefthook on PATH). Hashes differ from C1's (`a868b3a9…`/`a46fa398…`) only because the generated shim embeds the repo path — expected (C). Status after install still exactly 11 lines.
- Staged tree `f4922ca0…` (11 `A`).
- Gates, in order, first-nonzero stop, all rc 0: `tsc --noEmit -p tsconfig.json`; `eslint --no-warn-ignored --max-warnings 0` on the 8 TS paths; `prettier --check` on the same 8 ("All matched files use Prettier code style!"); `node scripts/check-r75.js --mode=staged` ("OK — no positive token change", policy `.github/r75-policy.json`); `jest src/scout/scout-ledger-backfill.spec.ts test/scout/g2-b-drain-db-guard.spec.ts --runInBand` → **2 suites passed, 42 tests passed, 0 skipped/todo/failed**, 9.7 s. This is the real phase-A settlement of the FB-3/B-BD-FRESH-FAKE hunk (my static trace predicted pass; the gate now proves it).

## 3. Commit — recomputed from the object

| Field | Observed |
|---|---|
| HEAD | `75a2863bf79a44f84050406d6878ec9a87f4053e` |
| tree | `f4922ca070e887fb7f613ce955b12621b5c33156` (== granted v4) |
| parent | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` (single parent == accepted C1; no `MERGE_HEAD`) |
| author / committer | both `Bradley Gleave <bradley@bradleytgpcoaching.com>` 1790262250 +0000 (from `git cat-file -p HEAD`) |
| message | == pinned `commit-message.txt` (`fca0b6aa…`, handoff §7) after trailing-blank normalisation; no trailers; no co-author/AI tokens |
| committed blobs | `git ls-tree -r HEAD` for the 11 paths == my `verify/v4-blobs.git-sha1` (modes incl. 100755 bootstrap); `diff-tree -p base..HEAD` sha256 `9206197e…` == my `recomputed.v4.diff` |
| S5 donors at HEAD | `0e73d76d`, `ab9aaab4`, `85a636ba`, `4fed8bcd`, `b9080538` unchanged |
| hook execution | `05-commit.stderr` (LEFTHOOK_VERBOSE): `call_lefthook run pre-commit` via the local binary → summary ✔ prod-readiness-quick (no-op, script untracked, as C1 recorded), ✔ banned-cast-tokens, ✔ prettier, ✔ eslint, ✔ tsc (47 s); `call_lefthook run commit-msg` → ✔ no-ai-tokens. Commit rc 0; `git commit -F`, no `--no-verify`, no amend/rebase. The "❌ R3 violation" strings in the trace are the hook's own echo source printed by verbose mode, not a failure |
| post-state | porcelain empty; detached HEAD; bundle `$BASE..HEAD` verifies (`ded7af9d…`), patch `e7ade9db…` |

Identity caveat per G05: author/committer fields verified on the landed object; this is not a cryptographic signature or human review.

## 4. Filled PG binding — substitution-only, correct pins

- Source template `fixture-proposal-v3/binding/b-pg-proof.sh` sha `25eb6837…` (== sealed `PROPOSAL.v3.sha256`, verified against the private copy); filled copy `runtime/binding/b-pg-proof.sh` sha `a64d24de…`.
- My own `diff -u` template→filled: exactly 10 changed lines (5 `-`/5 `+`), lines 25–29 only: `EXPECT_HEAD=75a2863b…`, `EXPECT_TREE=f4922ca0…`, `EXPECT_SPEC_BLOB=9b31fd18…` (== `HEAD:test/rls-g2-b-drain.spec.ts`), `EXPECT_BOOTSTRAP_BLOB=b4503eef…` (== `HEAD:test/utils/g2-b-drain-bootstrap.sh`), `EXPECT_FIXTURE_SHA=4525f01d…` (== restored `b-fixture.sh`). The only remaining `__` is the script's own placeholder-refusal `case *__*` on line 64. `bash -n` OK. `D=` still points at the unchanged sealed fixture dir; `RT=…/runtime`.
- Historical "v3" comments do not override the actual v4 pins (as the parent grant states). Env pins `EXPECT_NM_LOCK_SHA`/`EXPECT_NM_CLIENT_SHA` match the recovered environment (§1).

## 5. Slot and survivors

Canonical lock `execution/test-validation.lock` acquirable (`flock -n … true` succeeded at 15:07Z); no `remainder.sh`/`env-recovery.sh`/jest/tsc/lefthook process alive. Builder's sentinel `RC=0 STAGE=done END=2026-09-24T15:04:59Z HEAD=75a2863b… LOCK=released-on-exit` consistent.

## 6. PG-run readiness (for the parent's separate single-run grant)

Preconditions the filled script will check and their current state:
- Head/tree/spec/bootstrap/fixture/donor pins — **satisfied now** (§3–4).
- `node_modules` isolated + two hashes + jest/ts-node/prisma executables — **satisfied now** (§1).
- `/home/user/pg17/dist/bin/{postgres,initdb}` hashes `23cd1748…`/`b7db9bc2…`, `/usr/bin/psql`, `PROVENANCE.txt` — **absent in this runtime**; recover via the already-pinned `c1-pg/c1-env-recovery.sh` route (Maven jar `23da5a04…`, txz `26fa6334…`, apt `postgresql-client-18`), verify the same hashes, no cluster creation. This is recorded environment recovery, not a finding.
- O `925780e0` ancestor — satisfied; S5 dir absent — satisfied (recorded as-is); C1 cluster absent — tolerated by the template (`c1_cluster=ABSENT`).
- Invocation: `timeout -k 30 3600 bash …/runtime/binding/b-pg-proof.sh`, single run, no retry. Reviewer A will then bind `RECEIPTS.sha256`, jest summary, sentinel, stop/no-survivor lines.

C (later phase, no action): old-root `git clone` from a shallow source is unobserved in this lineage; the helper's own O-identity gate would surface any failure honestly.

## 7. Files written by this section
`B_DRAIN_ACTUAL_HEAD_BINDING_REVIEW_A.md` (this), `MANIFEST.sha256` (covers prelim note and this file). Nothing else touched.
