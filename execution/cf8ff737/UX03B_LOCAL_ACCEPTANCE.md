# UX-03b local acceptance

**Parent:** EXEC-CF8FF737. **Date:** September 24, 2026, about 16:35Z.

UX-03b (T4) is accepted at the bounded local scope.

## Accepted commit

| Item | Value |
|---|---|
| Head | `519b01227f2855fc7968994d389094008f222e20` |
| Branch | `ux03b-c1-setup-correlation` |
| Tree | `3979c681dc6b93604a3cd45d2d6b6a54c01d3d68` |
| Parent | J3 `9ff749c35f64068e156400d2ed37c0b144c2d56d` |
| Author and committer | Bradley Gleave |
| AI trailers | none |
| Hooks | none configured in mobile |

## Evidence

**Gate runs.** All stops are preserved.

| Run | Tree | Result |
|---|---|---|
| 1 | `4b92827d` | tsc rc2, one TS2339. Closed by `UX03B_TSC_CLOSURE_GRANT.md`. |
| 2 | `3d621d60` | Jest rc1, 389/396. Closed by `UX03B_CLOSURE_2_GRANT.md`. |
| 3 | `3979c681` | tsc rc0, eslint rc0, Jest rc0, 11/11 suites, 396/396. |

The total closure delta is four test lines, including one parent-granted single-line seed extension to the J3 restore test. No product line changed after the freeze.

**Independent reviews.** Both T4 reviews accept, with no A and no open B.

- `ux03b-review-a/UX03B_FINAL_FINDING_A.md`: ACCEPT, with 8 C items.
- `ux03b-review-b/UX03B_FINAL_FINDING_B_CLOSURE2.md`: ACCEPT, with C1–C10.

Review B's earlier run-2 NOT ACCEPT record is preserved.

**Fixture provenance.** Both reviewers independently re-derived the fixture from the frozen C1 artifact `bdb022dd…`. It is byte-identical, fixture sha `618007f4…`.

## Behavior accepted

The behavior is consumer-side and fixture-derived.

**Decoding**

- The C1 pair-surface types and decoders are additive and fail closed.
- `import_intent_id` is used for correlation only.
- The hook return shape is additive and backward-compatible with the panel.

**Requests**

- `init` sends `setup_nonce` in the body only.
- `current` is wired.
- There is no redeem call from mobile.

**Mirror and nonce**

- Mirror v2 stores the nonce and discards v1 records.
- The nonce is persisted before init and replayed on same-intent retry and on hydration.

**Error handling**

- A 409 conflict discards the nonce and key, then moves to `failed` with `conflict` and the copy "Get a new code".
- A 410 moves to `expired` with `challengeUnavailable` and the copy "Your code is no longer valid; your setup is kept".

## Qualifications (C)

- Coverage is mocked consumer tests only. There is no live backend, device, E2E, deployment or G3-AUTH claim.
- A v1 mirror is discarded on upgrade, as the grant mandates. Nothing is deployed, so no customer is affected.
- The reason copy is not yet rendered by the panel. UX-03c closes that.

## Next

`UX03C_COMPOSITION_GRANT.md` is now active.
