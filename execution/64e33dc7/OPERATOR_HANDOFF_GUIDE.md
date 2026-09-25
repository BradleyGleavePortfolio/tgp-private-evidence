# TGP importer: frozen operator handoff

Owner-requested freeze: September 24, 2026 at 10:56 PM PDT / September 25 at 05:56Z. This guide records the final state of session `64e33dc7-18e7-42d0-add5-7db69dc37a24`; it is a recovery and continuation guide, not authorization to resume. All workers have acknowledged the freeze, all twelve known session workers are completed, and no new product gate or database proof was run during handoff.

## Start here

Read `HANDOFF_FREEZE.md` first. It overrides all earlier grants, dispatch rows and sections called "Live", including the written-but-undelivered S8-C 05:43 relay. The next operator must explicitly re-establish ownership and scope before any work starts.

The evidence repository is [tgp-private-evidence](https://github.com/BradleyGleavePortfolio/tgp-private-evidence). All paths in this guide are relative to `execution/64e33dc7/` there unless stated otherwise; source candidates are preserved as Git bundles and exact patches, not promoted product branches.

- **Canonical entry points:** repository-root `LAST_OEPRATOR_HANDOFF.MD` (historical spelling retained), `LAST_OPERATOR_STATE.md`, `DISPATCHES.md`, and `execution/DISPATCHES.md` now begin with the freeze.
- **Owner doctrine:** the five original uploaded Word documents are copied unchanged into `handoff/owner-inputs/`, with hashes. The existing agent-context repository also contains `roadmap/M-IMPORTER-PRODUCT-MISSION_v1.md`; governance and reserved-owner boundaries remain in force.
- **Recovery integrity:** verify `handoff/RECOVERY_INDEX.sha256` and the lane-specific manifests before restoring. A historical self-hash or log-before-END qualification does not justify modifying old evidence.
- **Do not rebuild lost predecessors:** `OWNER_RECOVERY_RESET.md` explicitly authorized these replacement lineages from accepted base `93389265`. Earlier unrecovered S7-L/S8-C heads remain unaccepted history; their proof receipts do not validate replacement bytes.

## Accepted and already landed

The backend accepted integration and production heads were rechecked during handoff. No product branch was changed by the handoff operation.

| Surface | State to preserve |
|---|---|
| Backend `integration/importer` | `93389265a846095b846fa8f1fb0dad782fb6ee9f`, tree `a315dd651b8c54c2e82f2260fcc6058f0d13b64a`. N/Q1, C, S8-A and S8-B are already accepted and landed. Do not reopen or rerun them as new work. |
| Backend production `main` | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`, unchanged. [PR #530](https://github.com/BradleyGleavePortfolio/growth-project-backend/pull/530) remains open and draft into main, not authorized for merge. |
| Mobile `main` | `affc28184bb18b29d2011d25325ecba50587f9d1`. The two test-only CI corrections and accepted M1 composition are closed and landed through [PR #295](https://github.com/BradleyGleavePortfolio/growth-project-mobile/pull/295). Existing evidence: 325 suites, 4,180 tests, 5 snapshots, type/lint/configuration/CodeQL passed. No store release is implied. |
| Extension staging `land/s4-r6` | `8901d5f50eaadd6bad19e933c9e76b6539299669`, accepted staging composition. [PR #27](https://github.com/BradleyGleavePortfolio/tgp-importer-extension/pull/27) is open, REVIEW_REQUIRED and BLOCKED. Main remains `0111be661922234d670bbf23e23d270eec1b4a4e`; non-author approval and protection must not be bypassed. |

## Work completed but not accepted

### S7-L: lifecycle implementation and proof corrections

The current candidate is committed, clean and recoverable. Its latest database proof got through the migration and 23 passing tests, but the overall proof failed and no acceptance or landing occurred.

- **Exact identity:** HEAD `a68cdac70d81aea384fdc99c01c9c983a08e80eb`, tree `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb`; branch `exec64/s7l-replacement`.
- **Lineage:** accepted `93389265` → initial candidate `839b54c5` → source correction `54970cd9` → proof-spec correction `a68cdac7`. Genuine hooks and Bradley author/committer were used; no source WIP or stash remains.
- **Completed corrections:** the future-deadline lifecycle guard plus one regression case, L06 owner-session SET ROLE, then the proof's lock-timeout message and unconditional held-transaction release. The first correction's unit spec passed 29/29; applicable scoped source gates and genuine hooks are recorded.
- **V2 run:** 21 failed / 3 passed, with the S7-L schema never applied. A wrong stderr expectation caused the holder-release cascade; the parent terminated only the stuck Jest stage, cleanup succeeded, and the failed lane is preserved.
- **V3 run:** 23 passed / 1 failed / 24, natural rc1, 104.302 seconds, 172 migrations after re-apply. Cleanup reported zero PostgreSQL processes, listeners or survivors. Corrected lock handling, schema/catalog/RLS, lifecycle guards, fences, CAS, down/up and other reached checks passed as observations, not acceptance.
- **Remaining blocker:** both `s7l/reviews/RUNTIME_V3_REVIEW_A.md` and `_B.md` identify one proof-tool B. The OLD custom-output Prisma client throws an error from its private runtime, while the OLD service imports the error class from the shared package runtime. Two module instances make the intended P2002 `instanceof` catch fail.
- **Unverified tail:** OLD replay acknowledgement, replay row-unchanged assertion, OLD status read and L12 protection of a server run. The failing expectation remains correct and must not be weakened.

The proposed smallest fix, not started or granted, is only `test/utils/g2-s7l-worker.cjs`: redirect the runtime-library deep import, with and without `.js`, to the custom client's `runtime/library.js` when present; otherwise preserve normal resolution. No product service, migration, spec, bootstrap or other helper change is currently indicated.

Recover source from `s7l/bundle/v3/`; the full-history bundle is standalone, while the thin bundle depends on accepted base. Read `s7l/HANDOFF_FREEZE.md`, `s7l/binding/v3/run/PROOF_RUN_RECEIPT.md` and both latest runtime reviews. The failed v3 binding is driver `0c33b22279324b39132d06f4c7e5e00d9158bdb89e2174306389e043d7dedffd`, manifest file `82f501a33c8e0325e6b0781a6afdf12533a89e1b945cc8b3a56761182a16aac2`; it is consumed and must not be rerun.

### S8-C: coach-native writers and bootstrap WIP

The source implementation and narrow review corrections are committed and independently reviewed. Its sole database attempt stopped before Jest because the proof bootstrap required byte equality where Prisma emits normalized text.

- **Exact committed identity:** HEAD `87018a421f5be1064767d2cdd32e75ca935f7cdb`, tree `cec7d05a91876ec3f6badb1020bb97aacdb9331d`; branch `exec64/s8c-replacement`.
- **Lineage:** accepted `93389265` → `527fe2bc` → one-test correction `af9f7f54` → seven-path minimum review correction `87018a42`.
- **Completed closures:** preserve failed target-verification outcomes without rewriting provenance; `enum_unmapped` on enum-map misses; child provenance namespace `workouts.exercise` plus collision regression; legacy PG fixture staged on `truecoach`. Both v3 source/binding reviews were GO for one separately granted proof, not acceptance.
- **Process deviation:** the builder fixed an owned test and ran a second gate attempt without the required parent relay. Both attempts and the admission are retained. `S8C_GATE_SEQUENCE_DISPOSITION.md` records this as unauthorized, not retroactively authorized; observed 44/44 and genuine-hook evidence remains evidence only.
- **Only PG run:** natural rc7 at bootstrap after 171 migrations; no Jest and no test totals. Cleanup succeeded with zero PostgreSQL processes/listeners/survivors. Both runtime reviewers confirm a proof-tool defect, not a stale client or an evidenced product defect.
- **Cause:** generated schema copy `ded50406332707e4fd473a75e0a5407d54eb309085a99edcaaceaa05cb25b249` is the correct output from the accepted input schema. Prisma normalizes formatting and a block-attribute ordering; regenerating would reproduce the mismatch.
- **Exact unfinished change:** only `test/utils/g2-s8c-bootstrap.sh`, unstaged +7/-2, WIP blob `7c3fba471f991e3750eb56fd29e271101652196e`, SHA256 `0fdb0a4111c1c4914b7c4ca309e34bcca17f0a956d1719b5eb0b56c503c99eb5`. It replaces raw comparison with the expected schema-copy hash; missing and mismatched copies still exit7, and all other checks remain.

The bootstrap WIP had a preparation-time `bash -n` check only. No gated run, hooked follow-up commit, v4 binding, v6 checkpoint or bootstrap-correction review exists; the prepared scripts and previews have never run. The 05:43 source-gate relay was written into a document but never delivered, and is revoked by the owner freeze.

Recover the committed head from `s8c/checkpoints/v5/s8c-87018a42.bundle` with accepted base present. Recover WIP from `s8c/handoff-freeze/uncommitted-wip.full-index.binary.patch` or the exact file copy there; the full-index patch SHA256 is `c5e86f2371750cd4b654611b81a31a6b87740a8128eb2b43d7590b2d484eee8a`. Read its `HANDOFF_FREEZE.md`, plus `s8c/bootstrap-correction/SOURCE_EDIT_READY.md` and the revoked historical minimum grant for precise intended scope.

The consumed v3 driver is `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8`; its manifest file is `ede987a6536f35103f978d97690e45ed84d58c196615560561fbef3d9f7514ec`. Preserve its sentinel and failed lane.

## Drafted or planned, not executed

- **S8-F native readers:** 15-path source draft, 10 modified and 5 untracked files, on accepted base `93389265`. All 21 checkpoint-manifest entries and all 15 live files matched during freeze. `s8f/build/` contains byte copies, tracked patch, untracked hashes, exact status and DRAFT_READY. No formatter, lint, typecheck, Jest, commit or PG run has occurred.
- **S8-F prerequisites:** accepted S8-C composition, unskip F03 once canonical `programs` is present, and a narrow contract-generation/spec-property ownership grant. Typed `target_kind` dispatch and provenance checks are drafted, but unverified. Do not interpret the draft as native-reader activation.
- **S8-G orchestration:** `s8g/READINESS.md` is complete and already part of the evidence history. No implementation has started. It awaits accepted S7-L and S8-C interfaces and integration composition; use its E1-E6 and N1-N4 checklist instead of starting another broad architecture audit.
- **S8-D/E:** native client principal/roster direction remains owner-reserved. Coach-owned S8-C is not authority to implement or activate those paths.
- **S9 and downstream UX:** not accepted or activated by this work. Existing planning and presentation work must be continued according to dependency gates, not restarted; production, real-account actions, flags/readers, store releases, security/protection and spending remain reserved.

## Suggested next execution sequence, after a new grant

This sequence is planning only. Source work may be parallel where write surfaces are disjoint, but CPU-heavy gates and database proofs remain serialized under the actual canonical lock.

1. **Take ownership and verify recovery.** Read the freeze, owner doctrine, manifests, final heads and relevant reviews. Verify current remote refs and runtime state; do not assume the prior sandbox or workers still exist. Reassign sole writers explicitly.
2. **Finish the prepared S8-C bootstrap correction.** Reuse the exact one-file WIP rather than redrafting it. Regrant only syntax check and an ordinary genuine-hook commit on `87018a42`, stop on first failure, then export v6 and freeze v4. No regenerate/install/default Jest or PG belongs in this source step.
3. **Authorize the narrow S7-L worker correction.** Adopt the two runtime reviewers' common finding; grant only the worker resolver change on `a68cdac7`. Preserve all expectations, run only applicable scoped gates and genuine hooks, and create a new exact head and versioned proof binding.
4. **Re-attest changed questions only.** Two independent nonbuilder reviews for each new head and complete filled binding. S8-C's reserved filenames are `BOOTSTRAP_CORRECTION_REVIEW_A/B.md`; S7-L needs newly assigned immutable review filenames. Neither review may silently reuse a prior head's GO.
5. **Grant one new proof per candidate separately.** Use fresh lane/socket/old-root paths as applicable, fresh single-run sentinel, exact head/tree/blob/tool/fixture hashes, verified quiescent other lanes and bounded first-failure cleanup. Preserve every old failed run. Do not automatically rerun on failure.
6. **Accept only observed success and review.** A full passing proof and review of its receipts are still required. Only then compose and land dependency-valid work to non-production `integration/importer` under renewed continuation authority; no production promotion follows.
7. **Resume F and G after prerequisites.** Compose the existing F draft with accepted C; implement G from its readiness checklist once accepted L/C interfaces are pinned. Reconcile contract/schema ownership explicitly and avoid overlapping writers.

Important fresh-lane detail: S8-C's prepared v4 driver work was designed to protect both old top-level lanes and `proof-v3/clusters/*/`. If the next operator also creates a new S7-L v4 lane, enumeration must be reconsidered under an explicit minimal binding grant before either proof; do not blindly assume the old preview protects newly introduced sibling paths.

## Recovery packet and verification

| Recovery unit | Location | Verification / use |
|---|---|---|
| S7-L full source lineage | `s7l/bundle/v3/s7l-v3-a68cdac70d81-full-history.bundle` | `git bundle verify`; six-entry v3 SHA256SUMS passes. Import to a new recovery branch, not main. |
| S8-C committed lineage | `s8c/checkpoints/v5/s8c-87018a42.bundle` | Requires accepted `93389265`; five-entry checkpoint manifest passes. |
| S8-C uncommitted work | `s8c/handoff-freeze/` | Exact full-index binary patch, file byte copy, index/status record and prepared-script copies; 12-entry manifest passes. |
| S8-F full draft | `s8f/build/` | Copy checkpoint paths onto exact base, or tracked patch plus five untracked copies; 21-entry manifest passes. No hidden product WIP remains outside this packet. |
| S8-G readiness | `s8g/READINESS.md` | Complete text, no source code draft. |
| S7-L final failed run | `s7l/binding/v3/run/` | Raw logs, launch, sentinel, terminal receipt and nine-entry RUN_FREEZE manifest. |
| Earlier proofs / source receipts | Existing `s7l/` and `s8c/` versioned directories | Original reports, failed gates, historical bindings and candidate checkpoints remain immutable. |
| Stopped database evidence | `handoff/offline-recovery/` | Three compressed stopped-lane snapshots, both OLD generated clients, raw PG logs, package runtime bytes, member lists and SHA256 manifest. Offline copy only; never start these as a new proof. |
| Owner inputs | `handoff/owner-inputs/` | Five original DOCX documents with SHA256 manifest, unchanged. |
| Worker freeze register | `handoff/AGENT_FREEZE_REGISTER.md` | Eight explicit lane acknowledgements plus completion confirmation for all twelve session workers. |

No dependency installation, toolchain binary tree or full disposable `node_modules` directory is included; those are reproducible environment inputs rather than unfinished source. The existing `runtime/RUNTIME_SETUP_RECEIPT.md`, original setup grant/scripts, frozen PINS and generated-client snapshots preserve the identity and setup history; any necessary provisioning in a new sandbox needs an explicit bounded grant.

## Runtime and governance guardrails

- **Canonical lock:** `/home/user/workspace/execution/test-validation.lock`; historical inode691716. Never delete, steal or replace it to make a proof start. In a fresh sandbox establish ownership explicitly rather than treating absent processes as inherited authority.
- **Toolchain:** PostgreSQL17.6, psql18.6 wrapper, Node20.20.1, Prisma6.19.3, isolated Prettier3.9.9, lefthook2.1.9. Exact hashes remain in each binding and setup receipt; preserve the mismatched-version qualifications already reviewed rather than silently repinning tools.
- **Git discipline:** Bradley Gleave `<bradley@bradleytgpcoaching.com>` author and committer, ordinary hooked commits, no AI trailers, no amend, bypass or force push. Product branches were not pushed during this handoff; Git bundles on the private evidence repository are deliberate recovery exports.
- **Review discipline:** single writer per surface, two independent nonbuilder attestations, changed-question scope, no peer-report reading while reviewing. Record class-C qualifications without creating extra fixes or broad audits.
- **First failure:** stop, preserve raw evidence, classify, then obtain a minimum new grant. The earlier unauthorized S8-C rerun must not become precedent.
- **Known manifest qualifications:** historical driver receipts hash their log before its final END line; new whole-run freezes capture the complete file. S7-L v1 SHA256SUMS has a self-entry mismatch. Original evidence is not rewritten.
- **Production boundary:** no main promotion, flags/readers activation, real customer/account activity, branch-protection/security changes, extension approval bypass, native client principal policy, store publication or spending authority is conferred by this handoff.

## Bottom line

The implementation work is substantially drafted and checkpointed, but neither new backend candidate is runtime-accepted. The next operator should close two narrowly identified proof-tool defects, not rebuild either product feature or restart accepted audits; then obtain fresh exact-bound proof evidence and proceed through the existing dependency gates.
