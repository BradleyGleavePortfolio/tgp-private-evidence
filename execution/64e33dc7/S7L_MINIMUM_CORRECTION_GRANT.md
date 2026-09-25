# S7-L minimum correction and changed-question review grant

Parent disposition, 2026-09-25. Sole product writer: `s7_l_replacement_builder_muge72rg`, T4, continuing the existing replacement lineage. This is not a new audit or a PG execution grant.

## Preserved candidate and findings

Preserve head `839b54c53ccb252f95b4ec63df0b08595bbe7698`, tree `f02205c60ad0bfeb24ce82d74b0025ee9a185df6`, its gates, exports and original `s7l/binding/` files unchanged. Both independent reviews remain historical records. Review A's original GO does not override the concrete findings in Review B.

- **F1, class A:** after a zero-row writer gate, `classifyClosed` can reread a newly committed Start with a future deadline and fence it as `timed_out`. Concrete harm: a fresh run is permanently terminal and the unique intent cannot be reused. This blocks acceptance of the new S7-L lifecycle bytes. Minimum closure: distinguish an open, not-yet-expired row before calling the timeout fence; return `not_started` for that race without mutation, consistent with the failed gate. Add one regression unit case proving the future-deadline result and absence of fencing/writes. Keep the existing expired-row case. This unlocks changed-question re-attestation and the first new PG proof.
- **F2, class B:** L06 logs in as `anon` and `authenticated`, while the proof bootstrap deliberately makes those roles NOLOGIN. Concrete harm: deterministic connection failure before the intended RLS assertions, consuming the single proof without testing its decision. This blocks only the new proof. Minimum closure: owner-session `SET ROLE` for the existing SELECT, refused INSERT, UPDATE and DELETE checks, as in the accepted S8-B pattern. Keep every assertion and the service-role rollback case. This unlocks execution of the same coverage after binding the corrected spec.

No other C observation is promoted or authorized for remediation. No speculative framework, timeout-policy redesign, accepted-source change or accepted-proof rerun.

## Exact product surface

Only these paths may change from `839b54c5`:

- `src/scout/lifecycle/lifecycle.service.ts`: the minimum F1 classification guard and directly necessary comment.
- `test/scout/lifecycle/lifecycle.service.spec.ts`: one F1 regression case; no deletion or weakening of existing cases.
- `test/rls-g2-s7l.spec.ts`: L06 role-entry mechanism only, preserving its RLS and rollback coverage.

Source edits may proceed now without taking the heavy slot. S8-C remains the current source-gate grantee. Do not run formatting, lint, TypeScript, Jest, hooks or any other heavy gate until the parent explicitly relays the slot.

## Subsequent source-gate relay

After explicit relay, acquire the existing canonical lock nonblocking in the working process, never delete or steal it. Reuse the isolated dependencies and pinned formatter. Run only necessary scoped formatting/lint/R75, the changed lifecycle service unit spec, and genuine ordinary commit hooks with TypeScript heap 4096. No rerun of the unchanged 48 suites, no contract regeneration and no PG action. Preserve all failures and release the slot after the ordinary follow-up commit.

Commit with Bradley Gleave `<bradley@bradleytgpcoaching.com>` as both author and committer, no trailers and no hook bypass. Do not amend or replace `839b54c5`. Export the new exact head/tree/delta and a recoverable bundle under a new versioned location.

## Versioned proof binding and review

Prepare a new filled binding under `s7l/binding/v2/`; do not overwrite the original binding or its receipts. Bind the new exact head/tree and changed spec blob. Preserve unchanged tool and fixture pins, accepted base ancestry and fresh lane isolation. Update the exact-parent check for the ordinary follow-up lineage, rather than incorrectly requiring the new head's direct parent to equal the accepted base. Retain an exact parent pin and accepted-base ancestry check.

Keep the original driver/fixture behavior except mechanical versioned paths and candidate/parent pins required by these corrections. The original fixture can be copied byte-for-byte. Record the exact original-to-v2 binding delta and hashes. No initializer, server, bootstrap, migration or PG test may run.

Both original independent reviewers will re-attest only F1/F2 closure, new head/parent/tree, applicable gates, and the changed filled binding. Do not repeat their unchanged source audit. Their original reports are immutable; each writes a separate `REVIEW_A_V2.md` or `REVIEW_B_V2.md`. Only two GO verdicts on the final head and filled v2 binding permit the parent to consider a separate single-PG execution grant.
