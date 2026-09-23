# S3 composed-lock release proof — STOPPED BEFORE THE BLOCK (pre-launch collision: pre-existing release.sh scratch files); one shot NOT consumed (revision 1, frozen)

Executor: `restore_s2_substrate_mue9eidh`, T4 sole runtime assignee, parent EXEC-6c2a68ac. Activation: parent mail 17:29Z "ACTIVATE EXACT S3 COMPOSED PROOF ONCE NOW" + `S3_COMPOSED_PROOF_ACTIVATION.md` (sha256 `79dcf2f1…`, untracked in private checkout HEAD `f10c7a44`) + `S3_COMPOSED_PROOF_RUNTIME_GRANT.md` working copy `7f57d7d8…` ("ACTIVE"; HEAD copy `79efc413…` reads "NOT ACTIVE"; diff = that first paragraph only, recorded in `00-preflight.txt`). Both read completely; both executable files (runner `e876f48c…`, fixture `9763698b…`) and `S3_COMPOSED_PROOF_RUNTIME_REQUEST_01.md` re-read. Window 17:29:56–17:32Z.

## 1. Outcome in one line

**The exact block was NOT executed.** A grant-defined stop fired at the read-only prerequisite stage: the five fixed-path release.sh scratch files exist in `/tmp`, and the unchanged frozen harness `test/release/s1s2-composition.sh` refuses at line 75 with exit 70 when any of them exists. The grant forbids executor cleanup of pre-existing scratch and says collisions stop. Launching would have consumed the one shot, created the fresh fixture cluster, and then failed step 40 deterministically. Runtime slot returned unused and clean (§4).

## 2. Prerequisites — everything else PASSED (`00-preflight.txt`, read-only, `GIT_OPTIONAL_LOCKS=0`)

| Check | Result |
|---|---|
| Prep packet manifest `be31c041…` (14 entries) | `sha256sum -c` OK; 14 files, none extra |
| Runner `candidates/run-composition-s3-v5.8-when-granted.sh` | `e876f48c1519004e0863321888715ad6ec2574ca55ff1f558571c61bf43ecbfd` ✔ |
| Fixture `candidates/infra/s3-fixture-be0b.sh` | `9763698b9231af15648c1179df8c99d2e848f6738469cf4ebee8bff1259de21c` ✔ |
| `worktrees/s3-prep2` HEAD / tree / porcelain | `be0ba8274e486dee77f15d18fe367a13ff08ecf5` / `a584a1b95423f95dae8daabf673ef3776604acbb` / 0 ✔ |
| `package-lock.json` | `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55` ✔ |
| Installed npm graph `node_modules/.package-lock.json` | `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44` ✔ (unchanged since receipts) |
| Prisma CLI bytes | `c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0` ✔; generated client + `@prisma/client` present; no S2 stamp (expected) |
| Closure identity `be0ba827..HEAD` (lock/package.json/schema) | identical ✔ |
| Toolchain | psql 18.6, PG17 dist 17.6 executable, node v20.20.1, npm 10.8.2, bash 5.3.9, timeout uutils 0.8.0, flock/setsid 2.41.3, pgrep 4.0.4; `PROVENANCE.txt` `1dfe9fbd…` |
| Env | `S2_RUNNER_STUBS` unset, `CHECKPOINT_DISABLE` unset in shell (block sets it), `PRISMA_ENGINES_MIRROR` unset |
| Fresh roots | `execution/6c2a68ac/s3-composed-proof` absent ✔; `/home/user/pg17/clusters/s3comp-be0b{,.log}` absent ✔; `s3-composed-proof-result` was absent before I created it (§5) |
| s2comp-r53 | present, stopped (`postmaster.pid` absent), untouched |
| Slot (single granted census, `02-census-readonly.txt`, 17:31:22Z) | canonical lock fd holders **0**; no postgres/psql/node/npm/jest/flock/timeout/harness processes for uid 2000; sessions 18155/18219/18493 **empty**; load 0.00, 7.7 GB available |
| **Scratch files** | **`/tmp/prisma_migrate.log`, `/tmp/prisma_status.log`, `/tmp/prisma_verify.log`, `/tmp/prisma_verifier.log`, `/tmp/release_verifiers_discovered.txt` — ALL PRESENT → STOP** |

## 3. The collision, precisely (`01-scratch-collision.txt`)

- All five files are owned by `user` (uid 2000), mode 644, mtime **2026-09-23 17:07:17.67–17:07:17.69Z**. Contents: `prisma_migrate.log` empty; `prisma_status.log` = `prisma_verify.log` = `Database schema is up to date!`; `prisma_verifier.log` = `P1010 VERIFY FAILED`; `release_verifiers_discovered.txt` = `prisma/migrations/20261224000000_rls_close_public_exposure/verify.sql`.
- Attribution (by timestamp and neighbours, not asserted as certain): the same second shows thirteen `release-sh-*` mktemp directories plus `fly-*`, `sbom-*`, `md-*` directories (17:07:15–17:17Z), `jest_1jk` (17:11:54Z), and lane `execution/6c2a68ac/s3-integration-validation/steps` was modified in the 17:05–17:10Z window. This matches the S3 targeted validation's Jest suites exercising `scripts/release.sh` (steps 09–14, reported complete: 31 suites / 825 tests); the `P1010 VERIFY FAILED` content is a negative-case scenario, not a real release failure. They are **not** from the accepted S2 real run (16:22–16:24Z), which the harness captured/removed (post-run check "left behind" passed).
- Why it stops here rather than at the runner: the harness code at `test/release/s1s2-composition.sh:74-75` (blob 38b70f54, unchanged, hash-stamped by the runner) is `for f in $RELEASE_TMP_FILES; do [ -e "$f" ] && { echo "refusing: $f exists (another release.sh run's artifact?)"; exit 70; }; done`, executed inside step 40 **after** steps 10/20/21 and after the fixture is initialised and started (steps 30–32). The run would therefore be a certain first-required-nonzero (composition=70) after consuming the fresh `s3comp-be0b` roots. The grant: "Any collision stops without deleting, adopting or reusing it"; "This allowance does not authorize executor cleanup or touching pre-existing scratch". I neither read them beyond `cat`, nor moved, nor removed them.

## 4. Runtime slot — returned unused, state unchanged

No process started, no lock touched (runner never ran; no flock/probe by me), no fixture created, no listener, no DB, no `/tmp` write, no worktree/node_modules/index/hook write, no private-checkout write, no peer-lane write. `worktrees/s3-prep2` still HEAD be0ba827 / tree a584a1b9 / clean at 17:30:25Z; `s2comp-r53` untouched. Canonical fd holders 0 at 17:31:22Z. The slot is released back to parent EXEC-6c2a68ac with this report. The one-shot authorisation has **not** been consumed; whether it remains valid after the scratch disposition is the parent's call (I do not treat this grant as still active for me).

## 5. Executor observations / C records

- C-1: I created `execution/6c2a68ac/s3-composed-proof-result/` (after verifying absence) **before** completing the scratch pre-existence check, so this required-absent root now exists and holds this stop packet. The grant requires both roots absent before any write; for a re-activation the parent must either accept this packet as the result root's revision 1 (next run writes e.g. `…-result/run-2/` or a sibling root named in the new grant) or name a fresh root. Nothing else was written outside this directory.
- C-2: preflight line `git_index_mtime=` failed (`stat .git/index` after a `cd` — relative path bug, exit noise only); corrected fact appended in `03-corrections.txt`.
- C-3: `ls -la /tmp` listing (names/mtimes only) was used for attribution — a read-only directory listing broader than the five files; recorded in `01-scratch-collision.txt`.
- Grant working copy vs HEAD differ (parent's ACTIVE update, publication pending); ACTIVATION.md untracked. Both hashes recorded.

## 6. Smallest next action (parent disposition; not executed)

Owner of the S3 targeted-validation lane (or parent) disposes of the five `/tmp` scratch files (attribute + remove or archive), confirms `/tmp/prisma_*.log` and `/tmp/release_verifiers_discovered.txt` are absent, then re-issues activation of the unchanged block with an explicit result root decision (§5 C-1). Prep packet `be31c041…`, runner `e876f48c…`, fixture `9763698b…` and every other prerequisite in §2 were verified and need no change. Alternatively, if the parent wants the scratch refusal to be exercised as evidence, that is a different (negative) request — not this grant.

## 7. Files in this packet

`00-preflight.txt`, `01-scratch-collision.txt`, `02-census-readonly.txt`, `03-corrections.txt`, `RESULT.md`, `MANIFEST.sha256` (non-self-including; seal = sha256 of MANIFEST.sha256). Empty `logs/`, `prereq/` directories were created and left empty (no caller.sh was written; no block was run).
