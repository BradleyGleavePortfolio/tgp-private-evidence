# S5-V31-A independent T4 audit

Reviewer: independent nonbuilder A  
Date: 2026-09-23  
Method: read, hash, compare, and diff only. I did not execute a candidate, control, syntax check, probe, test, lock operation, process operation, signal, installation, or source edit. I did not read the current peer audit, private live summaries, or TAKEOVER material.

## Exact scope and inputs

- Governing scope: `/home/user/workspace/tgp-private-evidence/execution/6c2a68ac/SCOPE.md`.
- Live G01–G22: `/home/user/workspace/tgp-startup/live/AGENT_RULES.md`, SHA-256 `edd63115537049e41ada062d35c74b4a1224f1bf784272ca45cf6c61398e173c`.
- Source packet: `2026-09-23/e8d546f9/remediation/s5-setup-exclusion-v31`.
  - Manifest SHA-256 `fab2b49e6f990795d980f973d58edcdeb6fbff27dcfe2a77036265bf4b7738e9`.
  - All 14 manifested entries matched.
  - Launcher SHA-256 `d5d9b2b8552a6b3f26fcb89a33892135f4954f4c898b985c021378ccc501c630`.
  - Runner SHA-256 `81ff20b0f62ab91d81b0af00d7688910bf8b223d7463aecd43a1595a66c3742a`.
  - Embedded and named OWN-BLOCK v10.1 SHA-256 `4aebf96f6b7c8962b7a4b10dfc25acb7a793a24744bc0e79de77675031b1c6c5`.
  - Recomputed V3→V3.1 and V2→V3.1 diffs matched the frozen diffs exactly.
- Control successor: `2026-09-23/e8d546f9/remediation/s5-setup-v31-controls-v2`.
  - Manifest SHA-256 `7d4a150dd05f4af5847bf810f9f37ccc8f443454e8f35a684d3abfc52ecd6e26`.
  - All 9 manifested entries matched.
  - Driver SHA-256 `f34769c3d35d853c741a50eecad9da95581067ab59c00f0f6e1c793f187ac62e`.
  - Fake SHA-256 `4e7858a240e9b70409b82cf474ced52cb32437d9a2d7c80d56ee2161cc07704e`.
  - Recomputed predecessor→successor diff matched the frozen diff exactly.
  - The predecessor driver and fake, launcher copy, and all ten `check` statements matched their named frozen inputs byte-for-byte.
- Named prior V3 reviews were read and verified:
  - A manifest `d9104403fa899235f2f3ca8e7a32ac341155eae4297cd9901533b41e2fc4741c` (23/23).
  - B manifest `3bb45135f2ea906e4f09cc9c7d8e889bace398876f22513913444377e7056145` (3/3).
- Named predecessor source manifest `8b128b4dbef5f26ca11a26480bc07bdaf6bcc40c9c381c7da0c47e34109841c9` and controls manifest `19529fa7ef7247dc72fa3a447c16ad3557b111d71c21b70ebae924d025976e73` were independently verified.

The frozen `SYNTAX_CHECKS.txt` files are builder evidence only. I did not rerun them.

## Verdict

**Material finding S5-V31-A-01 remains open. Source closure is denied, so the prerequisite for one private control grant is not met.**

The V3.1 delta does close the ordinary positive early-death trace in which this attempt successfully truncates and writes its START line: the line has the created outer session PGID, its stamp is not before the pre-spawn floor, the runner has not reached npm adoption, the outer session is positively empty, and the raw runner status remains the release status. It does not, however, provide exact attempt identity or categorically exclude stale import.

## Material finding

### S5-V31-A-01 — START fallback is time/number correlation, not exact attempt binding

Severity: Medium, material at the T4 canonical exclusion/evidence boundary.  
Affected source: launcher lines 180–192 and 227–230; unchanged runner lines 205–212.

`runner_bound` accepts a record without the current token when:

1. some matching START line has `pgid=$SESSION`; and
2. its UTC-second stamp is lexically not less than `SPAWN_TS`.

Both stamps have one-second resolution. The exclusive lock orders attempts, but that ordering is not encoded below one second. Therefore an earlier legitimate record from the same UTC second compares equal, not less. If its recorded PGID number equals the newly assigned session number after numeric reuse, the stale line passes. A future-dated stale line caused by a clock rollback also passes; the packet expressly says clock stepping is not defended.

This is observable when this attempt does not successfully replace the shared START record, including an early START publication failure: the old readable file can remain and be evaluated. It also applies to a never-adopted attempt, where no current runner truncation occurs. Once the fallback binds, `runner_truth` imports the old record's `state=released`, `FINAL`, `EXCLUSION_UNPRESERVED`, and cleanup fields. That can create a stale-derived unknown/dead hold and false release-record contents. The direction is generally exclusion-conservative, but exact provenance and truthful attempt evidence are not established.

The source comment and request infer that “predates this spawn” implies a stamp less than `SPAWN_TS`; that implication is false at the chosen precision. Exclusive locking prevents concurrent legitimate holders, not timestamp equality or later numeric reuse. The P3b control proves only positive recognition after the fake has truncated the stale file. P3a uses a deliberately old 2026-01-01 stamp. Neither is a negative control for the accepted equality/future cases.

Smallest sound closure: put an unguessable current-attempt value in the earliest checked runner publication—preferably the inherited lease token in START—and require it before importing any runner facts. A distinct per-attempt record path with checked identity would also close the class. Merely adding PID equality, increasing timestamp precision, or retaining the current `>=` comparison reduces probability but is not exact binding. Any source change requires fresh dual exact final-byte review.

## Required assessments

### 1. Source closure

- **Exact attempt binding / stale import:** not closed because of S5-V31-A-01.
- **Early-adopted death:** source-closed only for the START-successfully-published branch. The current delta turns that branch from an unrecoverable unknown hold into a raw-status release after positive empty census. START absent/unpublished is not closed by this fallback.
- **V3-B-01:** not fully closed as an exact-attempt claim; the positive intended branch is statically coherent.
- **V3-B-02:** remains closed as an applicability statement. Every old V2 fake is incompatible with V3/V3.1; the new fake writes the required current binding in its adopted non-early cases.
- **Prior V3 A findings:** the V3.1 delta does not alter the previously reviewed evidence-unavailability, retained-SID, corrective-release, or prior-record-preservation logic.
- **Primitive/runner applicability:** the runner and both embedded primitive blocks are byte-identical to the named hashes. The new launcher code adds no primitive call, signal authority, registration, retirement, or inner-session signaling. Applicability is positive for the static composition, but this is not runtime evidence.

### 2. Private-control grantability

**Not grantable now.** The control request makes dual V3.1 source closure a prerequisite, and S5-V31-A-01 prevents this reviewer’s source closure.

Apart from that blocked prerequisite, the successor control delta is statically acceptable:

- P2 now waits up to 10 seconds for this attempt’s atomically published `SELF_HOLD` reason record, using the token preserved from `LEASE_HOLDER.at-running`.
- Timeout does not convert the wait into success; the unchanged conjunction is still evaluated and fails on its own terms if the record is absent.
- All ten assertion statements are byte-identical to the predecessor; there is no assertion weakening.
- The four cases preserve raw status, release receipt, retained-owner state, lock state, prior records, and named fault artifacts. P2’s FIFO gives an attributable blocking point rather than a sleep-only race.
- The driver issues no explicit workload/holder signal; its `kill -0` uses are liveness reads. P3a causes the launcher’s existing ownership primitive to TERM its exact unadopted direct child. The requested outer `timeout` may signal the driver, and timeout helpers may signal only their own helper processes.
- Ordinary waits and polls are bounded by the named case limits plus the 180-second outer command. A failed case may deliberately leave a detached private holder beyond the driver bound; `finish` reports rather than kills it. That is a parent recovery boundary, not proof of holder termination.
- Writes are intended under the fresh `S5X_OUT/<UTC-second>` private tree. Freshness and canonical non-aliasing are request-time prerequisites, not fully enforced by the script: a grant would need the parent to verify a nonexisting, resolved, nonsymlinked output root outside both frozen packets and canonical paths.
- The controls exercise the launcher’s embedded ownership primitive with a fake. They do not execute the unchanged real npm runner, install dependencies, or establish canonical runner/T0 behavior.

If the source is repaired and receives two clear exact reviews, these exact control bytes may be reconsidered for one private run with the stated command, a fresh resolved output root, the 180-second driver bound, retained evidence, and an explicit parent recovery plan for any reported live holder. This report itself is not that grant.

### 3. Canonical setup and T0

**Held.** No canonical lock, canonical setup, npm install, T0, or runtime activation is authorized. Canonical setup requires corrected exact source identity, dual final-byte closure, successful attributable private recovery evidence on the exact reviewed controls, and fresh source/dependency/resource/grant prerequisites. T0 remains a separate downstream activation and evidence decision.

### 4. Product clearance

**None.** This review does not establish dependency installation, T0 success, product tests, database/native/browser behavior, merge eligibility, deployment, or product/release acceptance.

## Final disposition

- Source packet: **BLOCKED — one material exact-binding finding.**
- Control bytes: **STATICALLY ACCEPTABLE BUT NOT GRANTABLE while source closure is blocked.**
- One private control run: **NO GRANT.**
- Canonical setup/T0: **HELD.**
- Product clearance: **NONE.**

