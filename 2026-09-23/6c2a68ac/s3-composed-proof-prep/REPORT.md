# S3-COMPOSED-PROOF-PREP — source-only preparation of the S3 composed-lock release proof (revision 1, frozen)

Executor: `restore_s2_substrate_mue9eidh`, T4 sole builder, parent EXEC-6c2a68ac. Grant: `execution/6c2a68ac/S3_COMPOSED_PROOF_PREPARATION_GRANT.md` sha256 `a2ed8526edd207d8d5b2e102a6246d4d1059807fe5fd329041a3abb8832551be` (read in full; at start untracked in private checkout `68f7fe17`, now tracked and byte-identical at `82b391bd`). Activation: parent mail "ACTIVATE SOURCE-ONLY T4 composed proof preparation" (source work permitted before publication). Work window 2026-09-23 ~17:00–17:15Z. **Nothing was executed** beyond file reads, hashes, git plumbing reads, `diff`, and `bash -n` parse checks in the owned `parse-check/` path. No test, install, DB, process census, port probe, lock operation, signal, product edit, hook, commit, network or private-checkout write. No worktree, module, stamp or index write by this executor.

## 1. Inputs (complete list with hashes: `inputs/INPUTS.sha256`, identities: `inputs/IDENTITIES.txt`)

Grant `a2ed8526…`; SCOPE.md `9e2fe350…`; original request-02 `3bb5d479…` (§6 read; the requirement quoted verbatim in the runtime request §1); accepted v5.7 runner `efa273c7…` (byte copy in `baseline/`); accepted fixture `9fcc3696…` (byte copy in `baseline/`); S2 real result seal `bbde4b0b…` (RESULT.md `95db7818…`, runner-output baseline lines used for the comparison template); S2 setup seal `7f1a68c0…`; S3 install/generation receipts `s3-integration-result/{REPORT.md 08efb782…, SHA256SUMS bf7800bd…, steps 02/03 .cmd/.post, logs 02 3c28d73e…, 03 84286dfb…}`; S3 commit receipts `s3-integration-continuation/{REPORT.md 61b79cf3…, identity.txt f7251bd8…, logs/03R de26d5e5…}`; current S3 candidate bytes (harness `c766a8d9…` blob 38b70f54, release.sh `8831f8f7…` blob c86b3ab9, discriminator `82da49b2…`, guard spec `1356eb0d…`, target guard `6f66e436…`, package.json `afecdb37…`, package-lock.json `b7fed5ed…` blob 354de3da, schema.prisma `61f9ab1c…`, CLI `c2a77456…`, `node_modules/.package-lock.json` `05bc530a…`, deepmerge-ts package.json `9db12600…`).

S3 worktree identity (read-only): `worktrees/s3-prep2` HEAD `be0ba8274e486dee77f15d18fe367a13ff08ecf5`, tree `a584a1b95423f95dae8daabf673ef3776604acbb`, parents `d5cd9b8b` + `5c7b42b3`, porcelain 0, lock `b7fed5ed…` ✔ (all equal to the grant pins). `git diff --quiet d5cd9b8b be0ba827 -- prisma/ scripts/release.sh test/release test/db` → identical; only `package.json`, `package-lock.json` (129 `"version"` lines changed; deepmerge-ts 7.1.5 → 8.0.0; caret ranges → exact pins) and `scripts/check-r75.js` differ (`diffs/s2-to-s3-*`).

## 2. Deliverables in this packet

| File | sha256 | Purpose |
|---|---|---|
| `candidates/run-composition-s3-v5.8-when-granted.sh` | `e876f48c1519004e0863321888715ad6ec2574ca55ff1f558571c61bf43ecbfd` | runner candidate (v5.7 + pins/bindings only; `bash -n` 0) |
| `candidates/infra/s3-fixture-be0b.sh` | `9763698b9231af15648c1179df8c99d2e848f6738469cf4ebee8bff1259de21c` | fixture candidate (NS `s3comp-be0b`, PORT 54354; `bash -n` 0) |
| `diffs/runner.diff` | see MANIFEST | `diff -u` v5.7 → v5.8-s3: **+41 / −17 lines** (17 of the + lines are header comments) |
| `diffs/fixture.diff` | see MANIFEST | `diff -u` 9fcc3696 → fixture candidate: +7 / −2 (5 header comment lines, `PORT=`, `NS=`) |
| `diffs/s2-to-s3-package.json.diff`, `diffs/s2-to-s3-manifests.stat` | see MANIFEST | what the proof isolates |
| `baseline/*` | efa273c7…, 9fcc3696… | byte copies of the accepted predecessors (for independent re-diff) |
| `inputs/INPUTS.sha256`, `inputs/IDENTITIES.txt` | | input hashes / read-only identities |
| `parse-check/bash-n.txt`, `parse-check/static-pins.txt` | | parse-only results; every runner pin re-derived from the substrate and equal |
| `S3_COMPOSED_PROOF_RUNTIME_REQUEST_01.md` | | the exact one-shot request (block, writes, bounds, statuses, stop rules, report template) |
| `MANIFEST.sha256` | seal = sha256 of this file | non-self-including (`find … ! -name MANIFEST.sha256 \| sort \| xargs sha256sum`) |

## 3. Changed bindings — what the two independent reviews must cover (everything else transfers unchanged)

| # | Change (runner unless noted) | v5.7 accepted | v5.8-s3 candidate | Justification / receipt |
|---|---|---|---|---|
| S3-1a | `WT` | `worktrees/s2-runner53` | `worktrees/s3-prep2` | grant target |
| S3-1b | `EXPECT_HEAD` | d5cd9b8b… | be0ba827… | grant pin; `identity.txt` |
| S3-1c | **NEW** `EXPECT_TREE` + one check line after the head check | — | a584a1b9… → refuse 70 | the S3 receipts bound every step to write-tree a584a1b9 before/after (steps 02, 03, 03R, 04–07); tree equality is the link between "what was installed" and "what is executed" |
| S3-1d | `EXPECT_LOCK_SHA` | 62b05b90… | b7fed5ed… | grant pin; `02-app-npm-ci.post` verified the same value after `npm ci` |
| S3-1e | `CLOSURE_REF` | 9742037b… (ancestor at which the S2 closure was installed) | be0ba827… | S3's `npm ci` ran with the staged tree a584a1b9 (HEAD d5cd + MERGE_HEAD), i.e. exactly the manifests this commit carries; there is no distinct ancestor install commit. The `git diff --quiet $CLOSURE_REF HEAD -- package-lock.json package.json prisma/schema.prisma` check is **retained** (grant: prefer keeping guards) and is trivially identical at HEAD; the substantive install binding moves to S3-2. |
| S3-2 | **Install-provenance binding** (the documented "minimum binding adjustment") | `grep -q "^lock=$EXPECT_LOCK_SHA$" node_modules/.s2-composition-install-stamp \|\| refuse 70` | (a) `sha256(node_modules/.package-lock.json) == EXPECT_INSTALLED_LOCK_SHA` (`05bc530a…`) else refuse 70; (b) `node_modules/.prisma/client/index.js` and `node_modules/@prisma/client/` present else refuse 70; (c) informational `installed_versions:` stamp (prisma / @prisma/client / deepmerge-ts via file read, the exact form the parent accepted in step 03R) | S3 **legitimately has no `.s2-composition-install-stamp`**: that stamp was written by the S2 setup-30 step under the S2 grant; S3's node_modules was produced by `s3-integration-result` step 02 (`npm ci --ignore-scripts --no-audit --no-fund`, raw 0, "added 1117 packages", post-check lock `b7fed5ed…` ✔, write-tree ✔) and step 03 (`prisma generate` guarded, raw 0, "Generated Prisma Client (v6.19.3)"). `node_modules/.package-lock.json` is npm's own record of the installed graph (1117 packages, prisma 6.19.3, @prisma/client 6.19.3, deepmerge-ts 8.0.0), mtime **16:44:09Z = the receipted npm-ci end**; pinning its hash binds the runner to that exact receipted installation. **No stamp is written or imitated; the conditional `install_stamp:` echo line is left in place and is a no-op.** If the parent prefers an additive stamp write instead, that is a separate future S3-executor write under its own grant (not prepared here). |
| S3-3a | `LANE` / fixture file name (4 sites) | `execution/s2-setup-prep`, `infra/s2-fixture-r53.sh` | `execution/6c2a68ac/s3-composed-proof-prep/candidates`, `infra/s3-fixture-be0b.sh` | fresh hash-pinned fixture inside this frozen packet |
| S3-3b | `R57` (output lane; variable name kept so F01 guard code is untouched) and real-mode `OUT` | `execution/op88/s2-v57`, `composition-r57/$STAMP` | `execution/6c2a68ac/s3-composed-proof`, `composition-s3/$STAMP` | new lane, created by the runner's own `mkdir -p`; parent may pre-create it empty |
| S3-3c | `DB`/`NS`/`PORT` | `s1_rls_s2comp_r53`/`s2comp-r53`/54353 | `s1_rls_s3comp_be0b`/`s3comp-be0b`/54354 | grant preference; DB within the S1 guard regex `^s1_rls_[a-z0-9_]{1,40}$`; port within 1024–65535 pin rule; fixture greps `^PORT=54354;` and `^NS=s3comp-be0b$` verified (1/1) |
| S3-3d | `EXPECT_FIXTURE_SHA` | 9fcc3696… | 9763698b… | hash of the fixture candidate |
| S3-4 | `S1_R4_LOCK_HOLDER` label string | `run-composition-r57-v5.7 pid=…` | `run-composition-s3-v5.8 pid=…` | informational only |
| Fixture D1/D2 | `PORT=`, `NS=` lines + 5 header comment lines | 54353 / s2comp-r53 | 54354 / s3comp-be0b | DATA/LOG derive from NS; every refusal (D1 own-NS-only, D3 marker, lockcheck) unchanged |

Unchanged (transfer without re-audit): `EXPECT_PRISMA_CLI_SHA` (S3's installed CLI bytes are identical: `c2a77456…`), `CHECKPOINT_DISABLE=1` export, LEADER/adopt/`run_step`/reap/halt/cleanup/receipt/publication code, F01 IDDIR guard, OWNED_PAT/FIXTURE_PAT, steps 10–51 and their bounds, refusal steps (`env -i` offline layer), stub seams (unused in real mode), `set -u`, relative-`$0` self-stamp (hence absolute invocation in the request).

## 4. Applicability — why one run is warranted and what it does / does not show

Request-02 §6 requires a release-path re-observation on the committed composed head because `PRISMA_CLI` → `@prisma/config` → c12 → `deepmerge-ts` moved 7.1.5 → 8.0.0 and every manifest became exact-pinned. The accepted S2 real proof (d5cd, lock 62b05b90) exercised the identical harness (blob 38b70f54), `scripts/release.sh` (blob c86b3ab9), migrations and discriminator that be0ba827 carries; the S3 head changes **only** the dependency graph on that path. Running the unchanged harness through the unchanged runner mechanism, with the S3 node_modules bound to its own receipts, therefore yields a like-for-like comparison of `[release]` steps, `prisma_version`, lock hash, CLI bytes/version and raw exits (template in the runtime request §8). It does **not** show universal importer behaviour, full test-suite health, build/deploy readiness or production clearance, and is not an acceptance of the S3 head; the S3 executor's steps 09–14 remain that lane's own work.

## 5. Unproven / open items (honest list)

1. **Nothing has run.** `bash -n` proves syntax only; the new lines (S3-1c, S3-2) have never executed. Their behaviour follows v5.7 idioms (`[ … ] || { stamp …; finish 70; }`), but the first execution is the granted one-shot.
2. `EXPECT_INSTALLED_LOCK_SHA` binds the file npm wrote; it is not a recursive hash of `node_modules/**` (neither was the S2 stamp). Prisma engine binaries (fetched from binaries.prisma.sh during S3 step 03, disclosed there) are bound only via the CLI byte pin, `.prisma/client` presence and the CLI's own `--version`/generate consistency at run time — same depth as the accepted S2 binding.
3. The runner requires `git status --porcelain` = 0 and unchanged HEAD/tree at run time; the S3 executor owns that worktree and is mid-validation (steps 09–14). If it commits, re-installs, or leaves untracked files, the runner refuses 70 (by design) — sequencing is the parent's call.
4. Output lane `execution/6c2a68ac/s3-composed-proof` does not exist yet (verified absent); collision policy for it must be fixed in the runtime grant. `/home/user/pg17/clusters/s3comp-be0b{,.log}` verified absent at 17:09:59Z (file read only); port 54354 was **not** probed.
5. `deepmerge-ts` version is stamped by reading its package.json (the form accepted in S3 step 03R); the runner does not verify that `@prisma/config` actually resolves it at run time — the harness's `prisma_version`/`[release]` behaviour is the observation request-02 §6 asks for.
6. The two S2 blocks (`env -u S2_RUNNER_STUBS` vs plain) in request §3 — one must be fixed by the grant.

## 6. Executor observations / C records (disclosed, not retro-authorised)

- C-1: I ran `git status --porcelain --untracked-files=all` on `worktrees/s3-prep2` (read-only intent) at 17:09:59Z and once before compaction. `git status` may opportunistically refresh `.git/index`. Observed `.git/index` mtime **17:07:04Z** and sha `b2f6d4c2…` — that predates my 17:09:59Z run (so that run wrote nothing); I cannot attribute the 17:07:04Z write (the S3 executor is active on that worktree) and cannot exclude that my earlier pre-compaction status refreshed the index. HEAD (`16:54:44Z`) and tree unchanged. Future read-only checks in the request specify `GIT_OPTIONAL_LOCKS=0`.
- C-2: `node -p` was used to read `.package-lock.json` JSON fields (a file parse, no product code executed) — within "isolated parse only".
- C-3: `sed -i` was used once on my own candidate to substitute the fixture-hash placeholder (own file, before freeze); all other candidate edits were exact-string replacements (apply_patch-equivalent) recorded in `diffs/`.
- Private archive HEAD advanced `68f7fe17 → 90ff9a6 → 82b391bd` during this work (parent activity; grant now tracked, hash unchanged).

## 7. Ownership

Written only: `/home/user/workspace/execution/6c2a68ac/s3-composed-proof-prep/**` (frozen `chmod -R a-w` after sealing). No runtime slot taken or requested for myself; the S3 builder alone owns runtime steps 09–14; the composed-proof runtime remains HELD pending two independent reviews of §3 and a separate parent grant. The stopped `s2comp-r53` cluster, all S2 lanes and the S3 worktree were not modified.
