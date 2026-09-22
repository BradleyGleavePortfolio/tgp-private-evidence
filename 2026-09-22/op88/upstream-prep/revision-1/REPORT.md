# OP88-UPSTREAM-PREP — preparation report (revision 1, frozen)

Role: op88 T4 upstream integration preparer (Fable integration builder role as assigned; actual runtime model/settings not observable — not asserted). Not an auditor; no clearance claimed. Read: live `AGENT_RULES.md` G01–G22, private `LAST_OPERATOR_STATE.md`, `LAST_OEPRATOR_HANDOFF.MD`, `execution/OP88_WAVE1.md`, `execution/S1_S3_CONTINUATION_BRIEF.md`, repair-wave §S3-PRETTIER-ONLY-01 / §S3-PREP2-FORMAT-ONLY / §S3 request03 addendum, and only the named packets (S1 R4 A/B + B addendum, s2-composition b2-failed-and-r3-source, S3 prep2-format / request-03 / request-03-addendum-a, request-02 tooling manifest). No current peer output read (`execution/op88/s2-v56`, audits) — none exists in the workspace yet either. Parent mail 20:49Z acknowledged (fresh env, no PG/app deps, ownership e952dc9, no setup/runtime grant).

## 1. Result in one paragraph

S1 (56fb0d22, tree 79ebf175) and S2 (d5cd9b8b, tree c0ab87d4) are restored exactly and offline from the single verified S2 R3 bundle (sha256 `3b6cee48…0f75`, verify ok, prerequisite c23b9d9, 23 commits identical to the archived list, 0 missing objects) into isolated `worktrees/op88-upstream/`. The preserved S3 PREP2 tree `a584a1b95423f95dae8daabf673ef3776604acbb` is reproduced byte-exactly from parent 1 plus the archived full patch (and PREP1 `78a4f0e8` by reversing the six-file patch), with every packet claim re-derivable locally confirmed. The S3 head **5c7b42b3 is absent** from this workspace (no bundle, no `2026-09-20/` packet); this is the single concrete missing dependency for the S3 two-parent merge commit — it does not block S1/S2 real proof. All archived commands are mapped to fresh paths with eleven proposed (unapplied) portability deltas; fresh setup prerequisites are listed, not claimed installed.

## 2. Implemented vs tested vs unrun

| Category | Done here | Evidence |
|---|---|---|
| Implemented (preparation) | isolated clone; bundle hash+verify+import; two detached read-only checkouts; PREP2/PREP1 tree reproduction via temporary index; tree refs; immutable tar.gz snapshot (round-trip = same tree id); staged S1 discriminator set with hashes; input map; dependency hold | `logs/00…08`, `INPUT_MAP.md`, `DEPENDENCY_HOLD.md`, `staged-inputs/` |
| Verified read-only | commit/tree/parent/author identities; ancestry 56fb→21ea→d5cd; S1 blob sha256 set (verify/migration/down/guard/bootstrap/controls/discriminator/message-spec/harness) = frozen tables; predecessor verifier `2bbce0d7…`; release.sh/harness/lock hashes; 164→165 migration count with the single 165th named; schema.prisma/migration_lock unchanged vs base; six formatted blobs + three resolutions + lock/package/lefthook blobs at PREP2; 86-row matrix (4 of 5 equality columns); 46-path list hash `44b8a947…` | `logs/02,03,03b,05` |
| Tested | nothing. No formatter, tsc, eslint, Jest, Prisma, PG, hook, npm, network | — |
| Unrun / still pending upstream | S2 V5.6 dual reviews → N4/N5/N6 → controls → real 164+1 composition + S1 TRUNCATE discriminator (47/48 expected, S1 interprets); S3 request-03 steps 01–14; six-file applicability (tsc + targeted Jest); composed-lock release-path re-observation; two independent exact-head attestations for any composed head | — |

## 3. Findings and closure state

- F1 (blocker for S3 commit, not for S1/S2): S3 head `5c7b42b3` object absent. Smallest closure: parent restores `2026-09-20/remediation/s3-evidence-completion/revision-2/s3-backend-5c7b42b3.bundle` + manifest; this lane then verifies/imports and re-derives `eq_S3_5c7b` and the parent-2 patch (DEPENDENCY_HOLD §1). Not rebuilt.
- F2 (evidence gap, inherited, unchanged): 17/7 mutant controls (`e60f9523…`) bytes not preserved anywhere; S1-R4B-03 remains as recorded. Not rebuilt.
- F3 (portability, informational): baseline is a `blob:none` partial clone with a promisor remote; plain `git cat-file` on an unknown oid attempts a network fetch. The isolated copy has promisor disabled and origin URL neutralised; all lane git calls used `GIT_NO_LAZY_FETCH=1`. Recommend the same guard in any fresh runner header. (My very first probe in the baseline, before setting the guard, triggered three failed upload-pack lookups; no objects changed — recorded honestly.)
- F4 (method note): first archive round-trip check reported tree `99aac39b` because `git add -A` skipped two tracked-but-gitignored paths; re-check with `-f` gives `a584a1b9`. Both attempts preserved in `logs/07-archive-roundtrip.txt`. Archive was correct throughout.
- F5 (environment vs state file): `/home/user/node_modules` observed writable (state says read-only); canonical lock file absent; git identity unset in the fresh clone; `timeout` is uutils 0.8.0. See DEPENDENCY_HOLD §2 P5/P6/P8/P10.
- F6 (informational): the archived commit-message AI-token regex hits once across the 23 historical S2 messages on "ships the generated @prisma/client" (commit 93a85544). The archived check targets only the new merge commit; no action.

## 4. Source unchanged / isolation

Baseline `source/backend`: HEAD c23b9d9, porcelain 0, no registered extra worktrees, origin URL and hooks untouched (`logs/08`). Private evidence checkout: porcelain 0 (HEAD 8c22817e as checked out here; parent reports its own publication e952dc9). Lane worktrees: `wt-s2-d5cd9b8b` and `wt-s1-56fb0d22` detached, porcelain 0, files chmod a-w; `backend-s1s2-d5cd` detached at c23b9d9 with refs `refs/op88/{s2-bundle/…, prep2-tree, prep1-tree}`. No live staged worktree with `MERGE_HEAD` was created (would require the missing 5c7b object). No lane processes remain; canonical lock never taken (file absent, not created). Nothing shared with the S2 fixer; nothing published.

## 5. What success does not prove

Runtime composition, S1 TRUNCATE behaviour, serving-role safety, hook-enabled integration, six-file semantic equivalence, S3 applicability, or any audit clearance. Restoration is not a passing test.

## 6. One smallest next action

Parent: restore the S3 revision-2 packet containing `s3-backend-5c7b42b3.bundle` (with its SHA256 manifest) into `tgp-private-evidence/2026-09-20/…`; on arrival this lane completes the parent-2 verification and stages the request-03 `$W` state — still without dependencies, hooks or commit, and only after S2 clearance ordering is respected.

## 7. Owned outputs

`execution/op88/upstream-prep/{REPORT.md, INPUT_MAP.md, DEPENDENCY_HOLD.md, MANIFEST.sha256, logs/00–08, staged-inputs/s1-56fb0d22/**, staged-inputs/s3-prep2-tree-a584a1b9/**}` and `worktrees/op88-upstream/{backend-s1s2-d5cd, wt-s2-d5cd9b8b, wt-s1-56fb0d22}`. `MANIFEST.sha256` covers every file under `upstream-prep/` except itself.
