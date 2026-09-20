# TGP S1–S5 independent R2 review mandate

Authority: current user requested S6 fixers plus R2 audits for S1–S5 on 2026-09-20. This lifts the previous audit hold for these lanes only. No product landing, deployment, hosted configuration mutation, feature activation, or live customer action is authorized by this dispatch.

## Governance and independence

Read `/home/user/workspace/repos/context/AGENT_RULES.md` (G01–G22), the applicable section of `handoffs/op81/CONTINUATION_AND_ROMAN_IMPORT_PLAN.md`, and `/home/user/workspace/execution/doctrine/EXECUTE.txt`. The constitution supersedes old generic numbered-rule ceremony. All five cumulative lanes are T4. G06/G09/G10/G11 require two genuinely independent final-candidate attestations, material finding closure, exact evidence, and boundary/recovery proof. No predetermined verdict.

You did not implement these candidates. Do not read the OTHER CURRENT R2 auditor's report, communicate with that auditor, edit source, install into the frozen worktrees, commit, push, or touch hosted systems. Reading BOTH prior R1 reports is permitted and required for inherited finding closure. Builders' dispositions and passing test counts are claims to independently challenge. Distinguish source defects, evidence gaps, scope limitations, and merge versus release blockers.

Use `/home/user/workspace/worktrees/sN` read-only. These sources are pinned and parent will not move them during R2. Record exact head/tree/base independently. If you need a mutable fixture, write under your assigned audit output directory or a disposable clone there. Do not modify shared repo refs or candidates.

No heavy tests, installs, browser binaries, PostgreSQL cluster creation, or multi-process probes without coordinating with parent. There are 2 CPU / 8 GB RAM. Parent serializes heavy execution using `/home/user/workspace/execution/test-validation.lock`; do not queue a blocking lock for minutes. Prefer inspect the attributable archived test bundle, then send parent exact minimal extra commands and reason when needed. G10 does not require each auditor to rerun the full suite.

## Frozen candidates

| Lane | Repository | Main/base | R2 head | Tree | Packet |
|---|---|---|---|---|---|
| S1 | backend | c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 | 90a6647513f3566393764eee87237d9b5b1f150b | 01c7fba4443758ad7921a724dfb4680fd1f0f2ab | s1-r2/revision-1 |
| S2 | backend | c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 | 0b05fcf5352287109ac88ed2ba3682e441e3a076 | fba0a9f06127979005b70ca3da80584a1e2ce10c | s2-r2/revision-3 |
| S3 | backend | c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7 | 5c7b42b3ea5be84e4c740fa5d7e42a94d5230d06 | 83211d25d714e4c539cd3aa248a06ef0658fc8e7 | s3-evidence-completion/revision-2 |
| S4 | importer | 0111be661922234d670bbf23e23d270eec1b4a4e | c5a5ae12c5b3c3e32a4601c99319ad7c0d980057 | 5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447 | s4-r2/revision-1 |
| S5 | backend | product d7404cd49578647cf72bb633819d8e86ffc3da3a; proof starts after it | 485c67973b56758fb9b8404579f5ddaec87136bd | 2fbf5028413557f99faea3f1de27b1352a4fe8d4 | s5-r2/revision-1 |

Packets are under `/home/user/workspace/repos/evidence/2026-09-20/remediation/`.
R1 reports are under `/home/user/workspace/repos/evidence/2026-09-20/audits/sN-r1/{a,b}/revision-1/REPORT.md`.
Evidence repository snapshot: `7ab6af940c16f087dcaabbf07a55e9154405e68a`. Current context snapshot: `7e731732691b3370ba4e891efcae49e16e8512db`.

## Scope and evidence honesty

Review relevant cumulative risk as well as R1-to-R2 fixes; state exactly what you reviewed. S3 source is UNCHANGED from R1; new evidence is not self-certifying. S5's candidate is validation-only and cannot certify all G2 phases or the whole product stack. S1 owns schema/migrations/generators; no other lane changes them.

S2's exact-head 115/115 log supersedes precommit assurance for that focused scope only. Its final combined preview `6b85395f` remains unexecuted; no Docker/hosted execution claimed. S4 loader/package proof does not prove native import completion. S5 synthetic PG17.6 proves only measured initial E→T/Q0 scope, not production applicability. Read S5 cross-lane dispositions for S1/S2/S5: directions are not implemented changes.

## Report contract

Write `/home/user/workspace/execution/audits/sN-r2/LENS/REPORT.md` and any bounded probe files beside it. Include actual reviewer/tool identity (requested model and actual known identity separately; never invent provider/version), exact identity, review scope, actions, prior-finding disposition by stable ID, new stable IDs, consequence/materiality and affected merge/release boundary, evidence references, unexplained failures, remaining gaps, and an explicit bounded verdict. Explain residual-risk consequences instead of merely naming severity.

Report completion to parent with exact path and smallest follow-up actions. Parent is sole publisher, preserving every completed verdict and revision unchanged in private GitHub before updating the public handoff. Do not publish private findings yourself.
