# B/drain v5 — exact delta binding (reviewer A, successor; same review; preliminary until head/gates/binding land)

Read-only recomputation against the live worktree and `execution/cf8ff737/b-drain/v5/prep/*`. No gate run, no peer B, no source re-audit beyond the two granted lines. Fable/High requested only; no telemetry claimed.

## Verdict
**v5 candidate tree `d02f9b124bee52107f8ad2f286f8af611b859fe6` is exactly the granted minimum correction and nothing else.** It differs from the SOURCE_GRANTABLE v4 tree `f4922ca0…` in precisely two blobs, each a one-line predicate substitution, and both blobs are byte-identical to the ones I precomputed independently from the grant text before the builder's files appeared (`b-review-a/v5-expect/`, README + EXPECTED.git-sha1). No A/B finding. Phase-A gates on v5 may proceed on the already-recovered environment when the slot allows; the phase-A source verdict transfers to v5 for every unchanged blob.

## Recomputed facts
| Item | Observed |
|---|---|
| Base for v5 | HEAD `75a2863b…` (tree `f4922ca0…`), real index clean (`write-tree` still `f4922ca0…`); porcelain = exactly ` M` on the two granted paths |
| `git diff-tree -r f4922ca0 d02f9b12` | exactly 2 entries, both `M`, mode 100644→100644: `down.sql 91e646dd→7deaf700`, `scout-ledger-backfill.ts 957fb8c6→11d0a3fe` |
| Live working files | `git diff d02f9b12` empty → worktree == v5 tree; `git hash-object` of the two files == the new blobs |
| Expected (precomputed by A from the grant) | backfill `11d0a3fed8c1937b579ace267d7d90e71a2b5623`, down.sql `7deaf7009ced136df6c7f06e1989060b15568dfa` — **identical** |
| Content of the delta | backfill.ts:257 `AND t.tgattr::int2[] = '{}'::int2[]` → `AND cardinality(t.tgattr::int2[]) = 0`; down.sql:64 same substitution; 2 insertions/2 deletions total; no whitespace or comment churn |
| Builder patch | `v5.delta.patch` sha `a1da778e…`, hunks equal to my `git diff` of the live worktree |
| Untouched | forward `migration.sql`, both specs (`9b31fd18…`, `5477059a…`), harness/fixture/bootstrap, schema, deps, gate list, `lefthook.yml` |

## Correctness of the granted predicate (qualifying note, not a re-audit)
`cardinality(int2[])` returns 0 for both an ndim=0 array and the ndim=1/dim=0 array that an int2vector cast produces, so the new predicate is true for the shipped column-less trigger and false for any trigger with a column list — the structural identity the probe and `down.sql` intend is preserved. The unit fake (`scout-ledger-backfill.spec.ts:102`) keys on the substring `pg_trigger` only, so the 42-test unit gate is unaffected by the change; the PG proof is the only place this line is actually exercised, as before.

## What remains for this same review
1. Phase-A remainder on v5: hooked commit with parent `75a2863b…` (or `a0ea1bea…` if the parent directs a fresh single commit — either is bindable; the grant text implies commit on top of the current head), tree must equal `d02f9b12…`, Bradley author/committer, message to be pinned by the grant, gates tsc/eslint/prettier/check-r75/jest rc 0.
2. Fresh additive filled binding: five pins with `EXPECT_HEAD` = new head, `EXPECT_TREE=d02f9b124bee52107f8ad2f286f8af611b859fe6`, spec/bootstrap/fixture pins unchanged (`9b31fd18…`, `b4503eef…`, `4525f01d…`); diff vs sealed template must remain exactly the 5 pin lines, or any path change is presented as a small diff for disposition (grant §50).
3. Arrangement note for the second PG run (separate receipt root, retained first datadir) — bind when presented; do not execute.
