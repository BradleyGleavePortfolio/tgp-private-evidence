# S7-L v3 proof failure disposition

## Final causal disposition and owner freeze

Both new immutable runtime reports are complete: `s7l/reviews/RUNTIME_V3_REVIEW_A.md` and `RUNTIME_V3_REVIEW_B.md`. Parent read both fully and adopts their common narrow classification: one class-B proof-tool defect in `test/utils/g2-s7l-worker.cjs`, with the custom-output OLD client and service importing distinct Prisma runtime module instances. The accepted writer's P2002 `instanceof` catch therefore fails in the proof worker; no S7-L product defect is evidenced. The expectation must remain unchanged.

Their proposed minimum closure is to extend only the existing worker resolver for `@prisma/client/runtime/library` and its `.js` form to the custom client's runtime file when present, otherwise fall through. This is not implemented or granted. The owner subsequently requested handoff at05:56Z; `HANDOFF_FREEZE.md` suspends all action. Any new correction, gates, head/binding and single-run proof require a new operator grant.

The final result remains FAILED:23 passed/1 failed, no acceptance. The OLD replay row-unchanged check, OLD status read and L12 server-row protection after the failing assertion remain unverified. Prior reports and failed-run artifacts are preserved, not rewritten.

Parent disposition, 2026-09-25 05:43Z. The single invocation under `S7L_V3_SINGLE_PG_PROOF_GRANT.md` is terminal. Its authority has ended; a68cdac7 is not accepted, and no source repair or PG retry is granted by this record.

## Observed result

Exact head `a68cdac70d81aea384fdc99c01c9c983a08e80eb`, tree `6c00e2483d0407e1ba8b8e97d03ff0e1ea2b88eb`, v3 driver `0c33b22279324b39132d06f4c7e5e00d9158bdb89e2174306389e043d7dedffd`. Bootstrap and identity succeeded at05:39:56Z with171 migrations and no S7-L columns before the spec. The single Jest invocation exited naturally at05:41:41Z:

```text
JEST_END rc=1 2026-09-25T05:41:41Z
Test Suites: 1 failed, 1 total
Tests:       1 failed, 23 passed, 24 total
Snapshots:   0 total
Time:        104.302 s, estimated 295 s
POST_JEST applied_migrations=172
STOP_FIRST_FAILURE stage=jest rc=1
S7L_FIXTURE_STOP_OK
CLEANUP_STOP rc=0 postgres_procs=0 port55641_listeners=0 survivor_pid=none
END rc=1 stage=jest 2026-09-25T05:41:42Z
```

The single failure is L05/L12, the OLD image legacy-writer test, at spec line986: `expect(replay.result).toEqual(ack(oldIntent))`, expected an acknowledgement and received undefined. Its causal classification is not yet established; a failed result extraction must not be assumed to prove either a product defect or harmless harness mismatch.

The 23 passing tests are real observations, including the corrected lock-timeout stanza, lifecycle migration/application and other reached assertions. They do not turn the failed suite into acceptance; later assertions within the failed test were not reached. Preserve the exact output rather than rerunning any accepted history.

At05:43:14Z parent observed no canonical lock entry, relevant heavy process or listener on55641/55642; inode691716 remained intact. The sentinel records rc1 at the expected head. No parent signal or forced exit was needed for this run. Data in `proof-v3/clusters/s7l` is retained, along with all failed v2 and S8-C v3 evidence.

## Narrow runtime review

Existing independent reviewers may read this new v3 run, its terminal receipt when finished, and only the relevant frozen spec/harness/worker/accepted OLD-writer code needed to classify the L05/L12 failure and smallest closure. No repeated source audit, peer reads, tests, database probes, lock or Git writes.

Write only new immutable `s7l/reviews/RUNTIME_V3_REVIEW_A.md` and `RUNTIME_V3_REVIEW_B.md`. Identify exact test reach, natural exit/cleanup and the existing log-before-END hash qualification. Original runtime and correction reviews remain untouched.

The builder may finish only its previously granted terminal receipt and then stop. No acceptance, landing, source correction or new PG execution is authorized; those require later parent disposition. S8-C may receive a separate narrow source-gate relay now that actual release is verified, but no S8-C PG grant exists.
