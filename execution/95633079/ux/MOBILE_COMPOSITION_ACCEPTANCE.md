# Mobile presentation and account-state composition acceptance

Parent EXEC-95633079 accepts the pure local composition at `716a606e9d23c77a6d705beccb8cefc6e8228284`, tree `430c76a0a686f8756ea0d77f37613d3f85561fb2`. This decision follows both independent exact-binding attestations; it does not accept J3 UI wiring or expand remote/runtime authority.

## Exact boundary

| Item | Accepted value |
|---|---|
| First parent | Presentation `df0ad112529afcd9bfdf084e9930c90ee0bfffb3`, tree `377e4b7a497a69c2f1e68236a3f1527913c7429b` |
| Second parent | Account state `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820`, tree `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` |
| Merge base | Accepted S6 `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` |
| Local repository | `worktrees/ux-mobile-composed`, branch `compose/importer-presentation-state` |
| Scope | 12 presentation paths plus 6 state paths; intersection 0; union 18 |
| Source identity | 18/18 blobs equal their owning accepted parent; all other paths equal base; combined diff has zero authored hunks |
| Commit | Ordinary two-parent local merge, Bradley Gleave author and committer, approved single-line message, zero trailers |
| State | Clean; no remotes; no configured hooks and no bypass; accepted source worktrees untouched |

The predicted merge tree equals the actual tree. The cross-diff from presentation to merge is byte-identical to the accepted state delta, and the cross-diff from state to merge is byte-identical to the accepted presentation delta.

## Independent basis

- **Reviewer A:** `mobile-composition-review-a/COMPOSITION_REVIEW_A_ATTESTATION.md`, with `BLOB_UNION_CHECK.txt` and `MANIFEST.sha256`. ACCEPTED, Class A none, Class B none.
- **Reviewer B:** `mobile-composition-review-b/COMPOSITION_BINDING_REVIEW_B.md`, with `MANIFEST.sha256`. ACCEPTED, Class A none, Class B none.
- **Executor:** `mobile-composition/COMPOSITION_ATTESTATION.md` and raw object, predicted union, cross-diff and export receipts.

Both reviewers independently bound the objects, ordered parents, exact blob union, identity/message, clean state and transferred evidence. The existing `SettingsScreen` import of `authActions.signOut` predates both deltas, and the state delta changes no exported contract; the union introduces no new import edge or shared configuration change.

## Evidence applicability and qualifications

Accepted presentation source and runtime evidence applies to its identical 12 blobs. Accepted account-state evidence applies to its identical 6 blobs: 55 reasoned-transfer passes from the preserved r1 run, two cases executed on r2, and r2 typecheck plus six-path lint; never a claim that 57 cases ran together.

No install, generator, test or whole-project typecheck ran on the composed tree itself. Applicability is the reviewers' byte-identity and no-new-edge conclusion, not a new execution receipt; later authored changes require their own scoped binding. The original r1 red-case commit remains in additive history and is superseded by the accepted r2 head. These are Class C qualifications, not grounds for replay.

## Portable evidence

| Artifact | SHA-256 |
|---|---|
| `mobile-composition/ux-mobile-composed-716a606e.bundle` | `a61e43355ff104ab1d663c0ea4d90beaa0d352c55c7db9f193c100bed6751140` |
| `mobile-composition/composed-union-base-to-716a606e.patch` | `c93661ac75fe010da86e6d0eef862a2b5e2697f9bd924fbe74d9033b79887795` |
| Accepted state cross-diff | `abaab9f10724e5ebb07ba2594d7c5477d032a2b40a9a59d7f4988adf1cc05dfc` |
| Accepted presentation cross-diff | `54b3c312125cb6deb07f88f0b7c12e630e97d3ca5df62fd3977a1a26df950118` |

## Continuation

J3 source-selection presentation is assigned to the existing T2 mobile writer in new isolated `worktrees/ux03-j3/**` and `execution/95633079/ux/j3-source-selection/**`, based on this accepted composition. The grant is source-only and consumes the existing controller, safe URL flow and accepted local Later contract without changing their authority.

This is the map's early-codeable J3 restyle, not full UX-03 pairing/handoff acceptance. Home eligibility, intent/origin binding, server copy, lifecycle, consumer completion, product remote push/merge, deployment and flag enablement remain outside this acceptance and grant.
