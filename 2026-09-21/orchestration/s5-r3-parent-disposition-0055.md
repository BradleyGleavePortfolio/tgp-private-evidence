# S5 R3 parent disposition

Recorded2026-09-22 00:55 UTC after both independent reports froze. This is orchestration and scope disposition, not a third audit or self-certification.

## Current decision

Exact143d451ead6ccdbebd92ca3031ba7a89867d6cfc remains NOT CLEARED for cumulative validation-harness acceptance or merge. Preserve the independently attributable B3 guard27/27 and live51/51, single ordinary lock hold and clean normal stop; no finding establishes that those executed assertions failed.

Audit A's high-severity source/control-flow findings block the affected next actions despite audit B's bounded conditional acceptance. Specifically, an assertion failure in beforeAll is not a no-mutation refusal if afterAll still deletes data; a newly acquired stop lock is not continuous ownership; a destroy path that suppresses stop/removal failure is not safe recovery.

Audit B's characterization of resume as fail-closed and its proposed destroy-plus-full sequence do not override those concrete paths. No destroy, reset, resume, full, DB connection or additional test execution is granted at143d.

## Preserved applicability

- B3 proves final-head pinned generate-only and resume using earlier bootstrap state, not a fresh complete bootstrap at143d.
- The candidate-runtime evidence field is empty because the script hashes a nonexistent file; the raw error remains in original logs. Independent static checks substantiate actual runtime provenance but do not retroactively supply missing enforcement.
- The conditional P2028 durable-failure branch remains unexecuted. Do not claim blanket branch coverage; adding a new timing variant is outside the present safety repair.
- The current stopped cluster is mutated. Preserve it, the B2 client/quarantine, earlier failed logs, all bundles and both independent reports.
- The00:38 lock-file touch is not evidence of an S5 run. S2's attributed B2 runner began00:38:54 and opens the shared lock without writing S5's private log; other parent probes also read/probe the canonical lock. File mtime alone cannot identify a holder or infer a test.
- Original npm debug files cited for the auto-install are absent at their paths and were not found in the inspected preservation locations. Keep that retention limit explicit; do not reconstruct raw files from narrative.

## Authorized isolated successor

The canonical S5 builder is authorized source preparation only in a new isolated successor above143d. Scope is test/helper source, owned execution wrappers and truthful recreation/disclosure documentation; no application, schema, migration, dependency or framework changes.

- Gate mutating teardown on successful completion of every read-only identity/pre-state check, with the flag set before the first authorized setup mutation so partial setup can still clean up.
- Maintain supervisor lock ownership through worker termination, stop and liveness verification; separate first-exit and cleanup-exit records. Do not let a daemon inherit the lock or declare a safe handoff with survivors.
- Refuse destroy on actual stop failure or surviving processes, propagate removal failure and verify absence before success. This is a source correction, not permission to delete.
- Enforce the pre-live zero-session snapshot for mutating paths and document its snapshot limitation.
- Resolve/hash actual runtimes, fail required provenance reads, enforce both engine comparisons if claimed, and make generation negatives assert the intended refusal class.
- Add separately dated accurate reconstruction and evidence instructions, including full/resume limits, hash working directories, the empty runtime field, cumulative assertion changes and the non-pristine cluster.

Before any new execution, freeze the offline driver's isolation and commands for a separate grant. Required controls are predecessor-negative/successor-positive setup refusal, partial setup, busy target, TERM, timeout, stop failure and removal failure, with no real DB access. A later fresh-full request requires exact-head review, proven cleanup safety and an explicit preservation/replacement decision; it is not automatic.
