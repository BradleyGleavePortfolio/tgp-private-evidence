# C1 independent reviewer A — final exact-head attestation

## Verdict

**ACCEPTED — independent reviewer A, scoped C1 local acceptance. A: 0; B: 0.** The existing source review, completed genuine-hook commit/targeted-test phase, reviewed fixture/binding, and the single actual 22-case PostgreSQL proof satisfy the frozen C1 acceptance at **`a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`**. This concludes the same A review; it does not speak for reviewer B or substitute for the parent's independent dual-review disposition. ([frozen A source verdict](/home/user/workspace/resume-evidence/execution/e7d2385c/audits/s7-c1-a/REPORT.md), [actual commit/targeted attestation](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md), [fixture/binding review](/home/user/workspace/execution/95633079/audits/c1-a/PG_FIXTURE_BINDING_REVIEW.md), [actual PG log](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [actual 22-case result](/home/user/workspace/execution/95633079/c1-pg/run/jest.log))

Acceptance is limited to C1 durable setup/recovery at the recorded local boundary. It is **not** remote landing, deployment, production readiness, consumer contract freeze, full-history migration validation, credential-delivery/active-connection proof, Start/cancel/progress/native-writing capability, integrated importer completion or customer acceptance; inherited setup/activation limits remain in force. ([existing source qualifications](/home/user/workspace/resume-evidence/execution/e7d2385c/audits/s7-c1-a/FINDINGS.md), [frozen PG acceptance/exclusions](/home/user/workspace/resume-evidence/execution/e7d2385c/s7-c1-pg-preparation/C1_PG_PROOF_PREPARATION.md), [actual executor scope](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))

## Independence and evidence reuse

Reviewer A is an independent nonbuilder successor continuing the original T4 A review. The final phase used static reads, hashes, read-only Git HEAD/tree/status inspection, and narrowly relevant installed-package metadata only. No source/fixture re-audit, source recovery, code execution, probe, install, generator, hook, test, PG run or new process census was performed by A; no B report or conclusions were consulted.

The completed source and predecessor evidence was reused at its unchanged boundaries rather than rerun. Earlier A phase reports remain immutable: source grant, original execution binding, first-install receipt/path disposition, exact remainder binding, actual commit/190-test attestation, and fixture/binding review. ([original source report](/home/user/workspace/resume-evidence/execution/e7d2385c/audits/s7-c1-a/REPORT.md), [execution binding](/home/user/workspace/execution/95633079/audits/c1-a/EXECUTION_BINDING_REVIEW.md), [install receipt](/home/user/workspace/execution/95633079/audits/c1-a/HOOK_INSTALL_RECEIPT_REVIEW.md), [remainder binding](/home/user/workspace/execution/95633079/audits/c1-a/REMAINDER_BINDING_REVIEW.md), [actual commit phase](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md), [fixture phase](/home/user/workspace/execution/95633079/audits/c1-a/PG_FIXTURE_BINDING_REVIEW.md))

## Exact accepted candidate and executed bindings

The final live read-only check still shows the same HEAD/tree and empty porcelain status; the raw object identity, exactly two ordered parents, author/committer and exact approved raw message were independently established in A's preceding actual-head phase and remain applicable. ([preceding exact-object attestation](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md), [preserved raw object](/home/user/workspace/execution/95633079/c1-execution/12-actual-commit-object.txt), [PG post-state receipt](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))

| Binding | Exact accepted value |
|---|---|
| Commit / final HEAD | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |
| Tree | `87798e742c7b48f56b05e9b5c30efa877180a9b3` |
| Parent 1 | `5c760b774598532e90d5d217e15adc9285c3c3f4` |
| Parent 2 | `881c4c791727adef8d423931e1cca83a0ffbb9c9` |
| Author and committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` |
| Raw approved/committed message SHA-256 | `288048d7b7e908f8803d3d70e57465f52cfc9f102bb4bc4b1dba30143ce7cb83` |
| C1 PG spec blob | `cc3b0e4da17add10aade720c1b7e10a9f78db937` |
| Reviewed fixture SHA-256 | `27b816afb53ebaa5afbad73b6075eddd366d611799a44a44fa549b5f43ca5040` |
| Reviewed/executed PG binding SHA-256 | `505061752aa09d4b6cfbd60bbc45835ee3613932dbcca1816130bed975c4eef2` |
| Original fixture packet manifest SHA-256 | `e612bd35ee52f4ec0a849416720693592fdc485fcdd8749299b41e03d657163b` |

A independently rehashed the fixture, PG binding and original manifest at final review; they remain unchanged, and the actual launch receipt names those exact fixture/binding identities. ([PG launch receipt](/home/user/workspace/execution/95633079/c1-pg/run/LAUNCH.txt), [fixture](/home/user/workspace/execution/95633079/c1-pg/c1-fixture.sh), [binding](/home/user/workspace/execution/95633079/c1-pg/c1-pg-proof.sh), [original manifest](/home/user/workspace/execution/95633079/c1-pg/MANIFEST.sha256))

## Missing-environment prerequisite fulfilled

The separately granted recovery completed once from `06:27:38Z` to `06:29:19Z`, raw RC 0, before the proof launch at `06:29:57Z`. Its actual log records the expected psql 18.6 package, exact recorded jar/txz/postgres/initdb hashes, matching pg_ctl prefix, server 17.6, provenance creation and absence of any cluster after recovery; it did not reconstruct S5. ([environment launch](/home/user/workspace/execution/95633079/c1-pg/env/LAUNCH.txt), [complete recovery log](/home/user/workspace/execution/95633079/c1-pg/env/c1-env-recovery.log), [recovery sentinel](/home/user/workspace/execution/95633079/c1-pg/env/c1-env-recovery.sentinel), [executor recovery receipt](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))

| Material recovered input | Actual recorded value |
|---|---|
| psql | `/usr/bin/psql`, PostgreSQL 18.6, Ubuntu `18.6-0ubuntu0.26.04.1` |
| Client entrypoint SHA-256 | `a200e38c89b111d3abdf26927b186fdd423bef3d84f157af0f4b65db6f8e6c94` |
| PG17.6 jar SHA-256 | `23da5a044b4fb7a5a081a45008c95749c873305328d73f86aefd56922ce1d29d` |
| Inner txz SHA-256 | `26fa633461a3340913015503d0783d73a28384110257e2f17d9936bdf8b067c0` |
| postgres SHA-256 | `23cd174849b273064c47d581b55be596be2f5cf0ee5d3e76c0146e2464bf873a` |
| initdb SHA-256 | `b7db9bc2463a4ffbe1e405977512afb50c9846fd3af2b694e315e6d5a270882a` |
| pg_ctl SHA-256 | `af53d826845af4679a0aaba2bda319f5e527f3b94f3794c67fa174049c9b9401` |

The recovered inputs satisfy the already-reviewed environmental prerequisite; this conclusion uses the attributable recovery records and proof's successful binary/version/identity guards, not an A-executed installation or PG probe. ([reviewed prerequisites](/home/user/workspace/execution/95633079/audits/c1-a/PG_FIXTURE_BINDING_REVIEW.md), [raw preconditions and server identity](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log))

## Frozen acceptance reconciled to actual results

| Existing criterion | Actual result and disposition |
|---|---|
| One exact proof, no expanded lane | Launch receipt records `timeout -k 30 900 bash c1-pg-proof.sh`; raw log contains one Jest start/end for `./node_modules/.bin/jest --config jest.rls.config.js test/rls-c1-setup.spec.ts --runInBand --ci`. The executor records one run and no retry. No E/T-Q0 or 190-test rerun is part of this lane. [Launch](/home/user/workspace/execution/95633079/c1-pg/run/LAUNCH.txt), [raw run log](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [executor receipt](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md) |
| Fresh, acknowledged, exact database | Preflight records absent C1 directory, free 55439, zero postgres and S5 absent. Init names role `user`, marker `c1-disposable-pg17` and the exact data path; the one database creation returns 0. Identity is `/home/user/pg17/clusters/c1-builder/pg-data`, server version number **170006**. [Raw run log lines 3–11](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log) |
| Raw init/start/create status | Fixture init, start and `CREATE DATABASE` each return **0**; required fixture success markers are present. [Raw run log lines 5–10](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log) |
| Existing 22 cases actually execute | **1 suite passed / 1 total; 22 tests passed / 22 total; 0 snapshots; no skipped/todo/failed entries; raw Jest RC 0.** All 22 named case outcomes are present, including process-exit recovery, lock contention, rollback, constraints, RLS and guarded down behavior. No acknowledged-target/forbidden-database/server-identity guard refusal appears in the complete raw Jest log. [Complete case log](/home/user/workspace/execution/95633079/c1-pg/run/jest.log), [saved raw Jest exit](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log) |
| Bounds and normal termination | Proof wall interval is `06:29:57Z`–`06:30:27Z`; Jest is `06:29:59Z`–`06:30:27Z` with reported time 26.684 s. No timeout, quarantine or cleanup-failure branch is recorded. The error diagnostic for exhausted mint attempts remains preserved with the passing collision case, not hidden or treated as a production incident. [Run timing/status](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [raw case/diagnostic log](/home/user/workspace/execution/95633079/c1-pg/run/jest.log) |
| Stop and retention | `C1_FIXTURE_STOP_OK`, raw stop RC **0**; run reports zero postgres, free port and retained exact data directory. The reviewed success guard additionally requires no `postmaster.pid`; the executor's later `06:30:50Z` cleanup receipt explicitly confirms its absence and retained marker/listen configuration. [Run stop evidence](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [reviewed stop-state guard](/home/user/workspace/execution/95633079/c1-pg/c1-pg-proof.sh), [actual cleanup receipt §3](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md) |
| S5, worktree and ownership | S5 remains **ABSENT**, not recreated. Post records unchanged worktree/HEAD; A's final read-only HEAD/tree/status inspection agrees. The executor's `06:30:50Z` receipt reports no task-owned Jest/node/pg_ctl/timeout/proof/fixture survivors and **zero canonical-lock holders**; its transient self-matching process count is explicitly resolved as its own check shell, not relabelled proof execution. A uses this attributable cleanup receipt without commissioning another process proof. [Post and final sentinel](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [cleanup/lock receipt](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md) |
| Terminal head-bound evidence | `RC=0 STAGE=done END=2026-09-24T06:30:27Z HEAD=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`. This agrees with the raw stages and the already-attested committed candidate. [Actual sentinel](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.sentinel), [prior exact-head attestation](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md) |

## Qualification disposition — no reopened cycle

- **C01–C03 remain recorded and nonblocking:** exact composed contract `2.0.0-c1-s1.1` remains unfrozen for consumers; original formatter/generated-schema wording limits and setup-only/activation boundaries are unchanged. ([frozen source findings](/home/user/workspace/resume-evidence/execution/e7d2385c/audits/s7-c1-a/FINDINGS.md))
- **C04 is resolved for the committed message:** A's actual raw-object extraction matched the approved message hash exactly; the earlier formatted `git log` newline note does not indicate a changed message. ([actual-head/message attestation](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md))
- **C05/C06 and the optional readiness-script limit stay explicit:** the original launcher remains failed RC 71 with a successful install child; the accepted remainder reused genuine hooks and passed 11 suites/190 tests without rewriting that history. The inherited quick-readiness conditional wrapper is not production-readiness proof. ([actual commit/targeted attestation](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md))
- **C07 is handled exactly as recorded:** `run/RECEIPTS.sha256` is a pre-final log snapshot, not a terminal seal. Its final-log mismatch is expected after `POST_OK`/`END`; the raw terminal proof/Jest/sentinel and final recovery-log identities used here are independently hashed below. No script fix or repeated proof is requested. ([original qualification](/home/user/workspace/execution/95633079/audits/c1-a/PG_FIXTURE_BINDING_REVIEW.md), [pre-final receipt](/home/user/workspace/execution/95633079/c1-pg/run/RECEIPTS.sha256), [executor final-hash receipt](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))
- **C08 remains a limitation, not an observed failed path:** the actual run ended normally within its bounds and has attributable successful stop/no-survivor/lock-release evidence; no guarantee of autonomous cleanup for every hypothetical interruption is asserted. ([fixture-phase qualification](/home/user/workspace/execution/95633079/audits/c1-a/PG_FIXTURE_BINDING_REVIEW.md), [actual cleanup](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))
- **Observed Jest version wording is retained, not concealed:** the proof's CLI banner says `30.4.1`; A's static metadata read finds `jest`, `jest-cli` and `@jest/core` packages each `30.4.2`, and the installed-record SHA-256 still equals the accepted `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`. This is a diagnostic/package-label distinction, not evidence of changed test selection or failed assertions, and causes no rerun or investigation cycle. ([observed CLI banner](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [Jest package](/home/user/workspace/worktrees/s7-c1/node_modules/jest/package.json), [CLI package](/home/user/workspace/worktrees/s7-c1/node_modules/jest-cli/package.json), [core package](/home/user/workspace/worktrees/s7-c1/node_modules/@jest/core/package.json), [accepted installed-record pin](/home/user/workspace/resume-evidence/execution/e7d2385c/audits/s7-c1-a/evidence/provenance-pins.txt))

## Terminal evidence identities

The following are the final file identities independently recomputed by A, not claims derived from the pre-final running-log checksum files. ([proof log](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.log), [Jest log](/home/user/workspace/execution/95633079/c1-pg/run/jest.log), [proof sentinel](/home/user/workspace/execution/95633079/c1-pg/run/c1-pg-proof.sentinel), [recovery log](/home/user/workspace/execution/95633079/c1-pg/env/c1-env-recovery.log), [recovery sentinel](/home/user/workspace/execution/95633079/c1-pg/env/c1-env-recovery.sentinel), [compact cleanup receipt](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))

| File | SHA-256 |
|---|---|
| `run/c1-pg-proof.log` | `c0b13a6ea75c048d0f583ae48916aff15761b8225544a8c0b965c51841e298ed` |
| `run/jest.log` | `33b1695ec06e9edd998806fd220a917bc4e85b7fb0a911a361fe31323e522261` |
| `run/c1-pg-proof.sentinel` | `431b4cfc9be277ee5258e21d73947664ed38e01b780265a955262dcadd10d763` |
| `env/c1-env-recovery.log` | `5d90930a2aba2b834e3fc73d52838f1f3e5ca757db693fe83f01f354db6664f5` |
| `env/c1-env-recovery.sentinel` | `9131413d085c7730ddb1aff3361571c61de1a699bf4033d42bf42d9298456891` |
| `ACTUAL_PG_PROOF_RECEIPT.md` | `ce422b42195974ca66258dda55e1a9944bda160bbe5d39adbec8d22eec3c0b49` |

The previously checked portable committed bundle remains the durability reference `b5126ab5336dacfe6b7d56ea18d449eb65a764059bd77ce77b022f51e246f128`; no new bundle/restore exercise was commissioned by this final phase. ([prior bundle attestation](/home/user/workspace/execution/95633079/audits/c1-a/ACTUAL_COMMIT_TARGETED_ATTESTATION.md), [bundle hash record](/home/user/workspace/execution/95633079/c1-execution/bundle/BUNDLE.sha256))

**A's C1 review is complete. No A/B closure, rerun, new criterion or C-fix cycle remains requested.** The parent may record this independent scoped acceptance and advance only through the separately authorized next work boundary; this report neither approves another reviewer's conclusions nor grants future product/runtime scope. ([completed frozen criteria](/home/user/workspace/resume-evidence/execution/e7d2385c/s7-c1-pg-preparation/C1_PG_PROOF_PREPARATION.md), [actual accepted run](/home/user/workspace/execution/95633079/c1-pg/ACTUAL_PG_PROOF_RECEIPT.md))
