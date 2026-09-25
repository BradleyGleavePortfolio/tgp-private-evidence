# S8-C first proof failure disposition

Parent disposition, 2026-09-25 05:35Z. The single run granted by `S8C_SINGLE_PG_PROOF_GRANT.md` is terminal and failed. Its execution authority is exhausted; no retry, repair, generation, source change, binding change or database action is granted here.

## Observed reach and result

The exact candidate was `87018a421f5be1064767d2cdd32e75ca935f7cdb`, tree `cec7d05a91876ec3f6badb1020bb97aacdb9331d`, through v3 driver SHA256 `9ddb52de66c306601080141c38867d25cd048c951e7c57086996ee4ef40eacd8`. The driver log reports migrations successfully applied, then bootstrap exited naturally with rc7 at 05:33:24Z:

```text
candidate client schema is not the candidate prisma/schema.prisma (stale client; regenerate in the runtime slot, never here)
BOOTSTRAP rc=7 2026-09-25T05:33:24Z
STOP_FIRST_FAILURE stage=bootstrap rc=7 2026-09-25T05:33:24Z
S8C_FIXTURE_STOP_OK
CLEANUP_STOP rc=0 postgres_procs=0 port55642_listeners=0 survivor_pid=none
END rc=7 stage=bootstrap 2026-09-25T05:33:24Z
```

No Jest invocation was reached. The sentinel records rc7, stage bootstrap, this candidate head and canonical lock inode691716. At05:34:42Z parent observed no canonical lock entry, relevant heavy process or listener on55641/55642. The failed S8-C lane and all outputs are retained; the source and v3 binding remain frozen.

The refusal is the committed bootstrap's raw `cmp -s` of the generated client's schema copy against candidate `prisma/schema.prisma` at lines197-198. Parent's limited read-only diff shows formatting/alignment and block-attribute ordering differences, not enough by itself to conclude that every semantic element is equivalent. The diagnostic's suggested regeneration is not authority to regenerate. Independent causal disposition must precede a minimum correction decision.

## Narrow independent review assignment

The two existing S8-C nonbuilder reviewers may read only this new run's receipts, logs, sentinel, relevant frozen bootstrap and candidate/generated-client schema material. They must establish the actual causal mismatch, proof/tool/product classification, minimum closure, run reach, cleanup and receipt qualifications. No unchanged source audit, peer-review reading, lock acquisition, tests, generation, database probes or mutations.

New immutable outputs are `s8c/reviews/RUNTIME_REVIEW_A.md` and `s8c/reviews/RUNTIME_REVIEW_B.md`. Existing source reports remain unchanged. The builder may finish only the already granted terminal receipt in `s8c/binding/v3/run/PROOF_RUN_RECEIPT.md`, then stop.

## Boundaries

This failed run provides no native-writer runtime acceptance and authorizes no landing, flags, readers, principal policy or production decision. Any correction and subsequent run require separate exact scope, frozen binding, independent changed-question attestations and an explicit new execution grant; this run's sentinel and data must not be reset or reused.

S7-L's exact a68cdac7/v3 package is independently under changed-question review. It has no PG grant yet; the free slot alone is not permission to run.
