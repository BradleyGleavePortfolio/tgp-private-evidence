# S3 COMPOSED-PROOF-B — changed-binding review of runner v5.8-s3 + fixture s3comp-be0b (source closure and one-shot grantability)

Reviewer B `audit_s5_failure_lens_b_mue9oser`, parent EXEC-6c2a68ac. Scope `S3_COMPOSED_PROOF_DUAL_REVIEW_SCOPE.md` sha256 `3530614c70f0eba0…`. Method: hashes, `diff -u` re-derivation, file reads, read-only Git object reads (`GIT_OPTIONAL_LOCKS=0`), directory-existence reads. No `bash -n`, node, probes, process census, locks, or writes outside `audits/s3-composed-proof-b/**`. Peer dir `audits/s3-composed-proof-a/**` and parent conclusions not read. Transferred v5.7 primitives (LEADER/adopt/halt/cleanup/receipt/publication, F01 guard, steps 10–51, fixture D1–D6) are **not** re-audited; my `s1s2-real-b` seal (`ab50754d…`) is reused for their accepted behaviour.

## 1. Packet and candidate identity (independent)

- `s3-composed-proof-prep/MANIFEST.sha256` = `be31c041667b7c12…`, 14 entries, 14/14 OK, non-self-including.
- Runner candidate sha256 `e876f48c1519004e0863321888715ad6ec2574ca55ff1f558571c61bf43ecbfd`; fixture candidate `9763698b9231af15648c1179df8c99d2e848f6738469cf4ebee8bff1259de21c` — equal to the scope/mail pins.
- Baselines `baseline/run-composition-r57-v5.7-when-granted.sh` = `efa273c7…` and `baseline/s2-fixture-r53.sh` = `9fcc3696…` are byte-identical to the accepted originals at `execution/op88/s2-v57/…` and `execution/s2-setup-prep/infra/…` (and the private copy).
- `diff -u baseline candidate` reproduced both `diffs/runner.diff` (41 added / 17 removed lines) and `diffs/fixture.diff` byte-for-byte (bodies).

## 2. Every changed runner line, checked

| Change | Verified against | Result |
|---|---|---|
| Header comment block (+17 lines) | — | Comments only; no code. |
| `WT=…/worktrees/s3-prep2` | worktree exists, HEAD be0ba827 | ok |
| `EXPECT_HEAD=be0ba827…` | `git rev-parse HEAD` | ok |
| `EXPECT_TREE=a584a1b9…` + new check `[ "$TREE" = "$EXPECT_TREE" ] \|\| refuse 70` | `TREE=$(git rev-parse HEAD^{tree})` is already defined at v5.7 line 408 (now 408) **before** the new check at 416; `set -u` safe; same `[ … ] \|\| { stamp; finish 70; }` idiom as the head check | ok; strictly additive refusal |
| `EXPECT_LOCK_SHA=b7fed5ed…` | `sha256sum worktrees/s3-prep2/package-lock.json` = `b7fed5ed…` | ok |
| `EXPECT_INSTALLED_LOCK_SHA=05bc530a…` + new refusal + generated-client presence refusal | `sha256sum node_modules/.package-lock.json` = `05bc530a…`; mtime 2026-09-23 16:44:09 = receipted `npm ci` end (`02-app-npm-ci.log exit=0 utc=16:44:09Z`, "added 1117 packages"); file lists 1117 packages, lockfileVersion 3, `deepmerge-ts 8.0.0`, `prisma/@prisma/client/@prisma/config 6.19.3`, no nested deepmerge-ts under `@prisma/config`; `node_modules/.prisma/client/index.js` and `node_modules/@prisma/client/` present; `.s2-composition-install-stamp` absent (so the v5.7 stamp refusal would have refused 70 unconditionally — replacement necessary) | ok; see CP-01 for the provenance qualification |
| `EXPECT_PRISMA_CLI_SHA` unchanged `c2a77456…` | `sha256sum node_modules/prisma/build/index.js` = `c2a77456…` | ok (same CLI bytes as S2) |
| `installed_versions:` stamp (informational, `2>/dev/null`) | deepmerge form is the fs-read form accepted in 03R; prisma/client via relative-path `require('./node_modules/…/package.json')` (relative path, exports map not applicable) | ok; informational only, cannot cause PASS/FAIL |
| `CLOSURE_REF=be0ba827…` | check `git diff --quiet $CLOSURE_REF HEAD -- package-lock.json package.json prisma/schema.prisma` is tautological at HEAD | retained, harmless (CP-02) |
| `LANE=…/s3-composed-proof-prep/candidates`, fixture file name (4 sites), `EXPECT_FIXTURE_SHA=9763698b…`, `grep ^PORT=54354;` / `^NS=s3comp-be0b$` | fixture lines 26–27 are exactly `PORT=54354; SUPER=…` and `NS=s3comp-be0b`; packet frozen read-only | ok |
| `R57=…/execution/6c2a68ac/s3-composed-proof`, `OUT=$R57/composition-s3/$STAMP` | F01 `iddir_guard` requires `IDDIR == "$OUT/.pgid"` and `OUT` matching `"$R57"/*/*` → `composition-s3/<stamp>` satisfies; `mkdir -p "$OUT"` (line 145) creates the absent lane root itself; root verified absent now | ok; absent-root policy consistent with the scope |
| `DB=s1_rls_s3comp_be0b`, `NS=s3comp-be0b`, `PORT=54354` | S1 guard `S1_GUARD_DB_RE='^s1_rls_[a-z0-9_]{1,40}$'` in a584 → matches; real-mode `OWNED_PAT` psql clause is port-parametrised (`-p 54354`), so S2's 54353 lane is outside the scan; `/home/user/pg17/clusters/` contains only `s2comp-r53{,.log}`; `s3comp-be0b{,.log}` absent | ok |
| `S1_R4_LOCK_HOLDER="run-composition-s3-v5.8 …"` | discriminator uses it only as a free-text `LOCK_STAMP` ("held by caller: …"), no format check | ok |

No other line differs. No product assertion, harness, release script, guard, discriminator, stub or cleanup logic is touched (the `git diff --quiet d5cd9b8b be0ba827 -- prisma/ scripts/release.sh test/release test/db` identity is also independently true from my final-head matrix: those paths are S1S2_PRESERVED blobs, harness blob `38b70f54…`, `scripts/release.sh` `c86b3ab9…`).

## 3. Fixture candidate

Only `PORT=54353→54354`, `NS=s2comp-r53→s3comp-be0b` and five header comment lines differ. `DATA`/`LOG` derive from `NS`; `init` refuses if `DATA` exists, if anything listens on the port, or if a postgres serves `DATA`; `start` refuses instead of adopting and also checks the port listener → a port collision is detected by the fixture's own `init`/`start` failure (raw 70 in step 30/31), matching the scope statement that no separate probe is needed. `destroy` still requires `S2_FIXTURE_DESTROY_CONFIRM` equal to its own `DATA`, so the stopped `s2comp-r53` cluster cannot be touched by this fixture.

## 4. Request block, writes, statuses, comparison template

- Block: `cd /home/user/workspace && env -u S2_RUNNER_STUBS CHECKPOINT_DISABLE=1 timeout --foreground -k 60 2100 bash <absolute runner path>; echo "runner=$?"` — matches the scope's fixed choice (retain `env -u S2_RUNNER_STUBS CHECKPOINT_DISABLE=1`). `STUBS=${S2_RUNNER_STUBS-}` → empty → real mode; the runner itself re-exports `CHECKPOINT_DISABLE=1`. Outer bound equals the runner's documented `timeout --foreground -k 60 2100`.
- Absolute invocation makes `runner_sha256=$(sha256sum "$0")` populated (closes the S2 RB-01 empty self-stamp); expected value `e876f48c…`.
- Writes list (§4) is exhaustive for what the changed lines can touch: new lane under `execution/6c2a68ac/s3-composed-proof/**`, fixture `s3comp-be0b` cluster/log/socket, DBs `s1_rls_s3comp_be0b{,_lock}` on 54354, canonical lock hold (75 if busy, no wait). Worktree `s3-prep2` tracked content / node_modules are read and executed only.
- Expected statuses (§6) and stop rules (§7) are copied from the accepted S2 run and marked "compare, not assume"; the comparison template (§8) names the actual S2 baseline files that exist in `s2-real-composition-result/runner-output/` (10/20/21/30/31/32/40/50/51 logs, stamp, harness logs) and the exact expected deltas (lock `62b05b90`→`b7fed5ed`, deepmerge 7.1.5→8.0.0, `installed_graph`/`installed_versions` lines replacing `install_stamp:` lines).

## 5. False-PASS / unsafe-cleanup / wrong-fixture / invalid-comparison analysis

- False PASS: every changed binding is a pin that can only add a refusal (tree, installed graph, client presence, fixture hash/NS/PORT). No accepted assertion was removed; the S2 stamp refusal was replaced by a same-strength or stronger file-hash refusal. PASS still requires the unchanged harness 68/68, discriminator 48/48, receipt/publication.
- Unsafe unowned cleanup: `FIXTURE_PAT`/`OWNED_PAT` are used only in `owned_scan`/survivor *reporting*; every `kill` targets recorded step groups/pids only (unchanged v5.7). No unowned process can be signalled. See CP-03 for the false-FAIL side.
- Wrong fixture / data mutation: fixture is hash-pinned inside a read-only packet; NS/PORT cross-checked by grep; DB name inside the S1 guard namespace; S2 cluster stopped and never referenced.
- Invalid S2 comparison: same harness/release/migration/guard/discriminator blobs; same CLI bytes; only the dependency graph differs, which is exactly the request-02 §6 question.

## 6. Decision

**Source closure: CLOSED** for the changed bindings (all pins independently re-derived and equal; no smuggled logic change).
**One-shot grantability: GRANTABLE** — no A, no B. C items CP-01…CP-05 in `FINDINGS.md` (record/qualify/continue; none requires a runner or fixture byte change).
Not an acceptance of any result: the single real run, once executed and frozen, is to be compared per request §8 and consumed by the final-head review (`audits/s3-final-head-b/`), which remains open for exactly that input. Not product, hosted, deployment or customer clearance.
