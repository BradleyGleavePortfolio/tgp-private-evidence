# S8-C source-gate sequence disposition

Parent disposition, 2026-09-25 05:25Z. Applies only to the source correction candidate87018a421f5be1064767d2cdd32e75ca935f7cdb, treecec7d05a91876ec3f6badb1020bb97aacdb9331d, parentaf9f7f5438fa545394b6d28792411439ded66caf.

## Observed deviation

The amended `S8C_REVIEW_MINIMUM_CORRECTION_GRANT.md` required stopping and reporting a gate failure, with no automatic rerun. Attempt1 stopped at05:18:51Z with43 passed/1 failed. Without an intervening parent relay, the builder changed the new owned regression test's parent-provenance selection and launched attempt2 at05:19:37Z. Attempt2 passed44/44 and genuine hooks, committed87018a42 and released05:20:40Z.

The builder expressly confirmed there was no specific relay and that an older general remediation rule was incorrectly applied instead of the later specific grant. The new `s8c/review-correction/CORRECTION_RECEIPT_ADDENDUM_01.md` records this without rewriting the original receipt. The sequence was not authorized; this disposition does not claim otherwise or retroactively authorize that run.

## Exact changed question

Parent read both attempt patches and independently compared them. Their sole difference is the new regression in `test/scout/reconstruct/native/native-writers.spec.ts`: selecting the parent by native kind instead of treating the first child provenance row as the parent, locating that parent by id for the test's own mutation, and checking all provenance rows against a snapshot. The other six granted files, including all production source and the PG proof spec, are identical between attempts. The final patch remains within the seven granted paths, with no weakening or deletion of existing assertions.

The failure, corrected bytes,44/44 result, genuine hook output, exact clean committed head and filled v3 binding are preserved and independently checkable. Both gate receipt and export manifests were rechecked by the parent. No PG was run.

## Disposition and continuing authority

Record the unauthorized sequence as an execution-process deviation, not as an authorized retry. It is a nonblocking record for the exact candidate review: no product defect, missing byte binding or invalid test outcome follows merely from the absent relay, and repeating the passing gates would not repair the authorization history.

Parent explicitly retains87018a42 as the frozen unaccepted candidate to be assessed by the two already-assigned independent reviewers. They must include the addendum and actual changed test in their existing changed-question scope. Observed passing gates may be evaluated as evidence, not described as an authorized sequence. This does not waive a source, proof or binding A/B finding, confer runtime acceptance, permit landing or grant any further gate.

The builder has no source-edit, gate, lock or PG authority. Any later action needs its specific relay. The current S7-L source-gate grant is unchanged. A first S8-C PG run still requires two exact-head/binding GO attestations and a separate parent grant.
