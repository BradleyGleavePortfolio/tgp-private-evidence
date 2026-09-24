# UX-01 local account-state acceptance

Parent EXEC-95633079 records **ACCEPTED** for the local account-scoped offer-decision state slice at `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820`, following both independent same-review final attestations. This accepts the six-path state boundary, not the whole UX-01 job or any visible journey, eligibility, intent binding, server copy, release or customer readiness.

## Exact accepted boundary

| Item | Value |
|---|---|
| Accepted commit | `8fd4cf759c2a8dd3f9ef9772f6dadb2035d93820` |
| Accepted tree | `17a6ce1acea7e4d6e926113faeb6a57eafa684f3` |
| Direct parent | `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`, original state commit retained unamended |
| Accepted base | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9`, S6 |
| Scope | Storage module, state hook, minimal exact-key sign-out list entry and three test files |
| Author and committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` on both ordinary commits |
| Hooks | No configured hooks, no bypass |
| Portable bundle SHA-256 | `c8e8faae82ef4a3616b7683fba101b0d789a2d3536b0e79f92b81dbff44c55cb` |
| Two-commit format-patch SHA-256 | `47c1f6710a3e3796ea5bb360b16e2aba58b7dd2e2fbcc78da0a546f9e424b771` |

## Actual proof and independent disposition

A's `account-state-review-a/UX01_STATE_REVIEW_A_FINAL_HEAD_ATTESTATION.md` and B's `account-state-review-b/ADDENDUM_02_FINAL_ACTUAL_HEAD_AND_RESULTS.md` both ACCEPT the exact local boundary. Class A: none. Class B: none open; B-UX01-TEST-TIMING is closed.

The original run at `327731d4` returned RC1 with 55 passed and one timing assertion failed. Only that test body changed, preserving all four original assertions and all product blobs. The corrected case passed at the accepted r2 head, as did the first execution of the new filtered sign-out case, whole-project typecheck and six-path ESLint. Both latter logs are empty with RC0.

Evidence accounting is deliberately split: 55 inherited passes (37 storage and 18 hook cases) from the retained original run, plus one corrected case and one new sign-out case executed at r2. These 57 cases were never run together. Both reviewers independently accepted the reasoned transfer because the only changed test body is isolated and all other relevant inputs remain unchanged. The 18 hook and seven existing S6 cases shown as filter-skipped at r2 are not claimed as executed there.

The matching accepted mobile dependency installation was copied into an isolated real directory, not reinstalled or shared mutably. Package/lock/installed-record pins match. Raw original failure, original commit, both source packets, test-only correction, continued execution logs, ordinary commit objects and portability exports remain under `account-state/`; no history was amended or relabelled.

The runtime lock was released at `2026-09-24T06:58:38Z`, with zero owned survivors reported. No remote product action occurred.

## Preserved qualifications and consumer boundaries

All source and continuation C findings remain recorded, including same-owner non-secret late-write windows, per-instance cache state, passive-effect wording limits, failed-write re-offer behavior, declaration-versus-case counts, one-second timestamp wording and reasoned transfer of passing cases. None creates another fix, audit, test or control.

The state means a device-local answer for the resolved account. `ready && null` is not server eligibility, never-asked-on-another-device proof, or absence of a server intent. A returned boolean is not “saved to your account.” Sign-out cleanup makes no claim about independent desktop extension revocation. The existing extension-import kill switch stays OFF by default.

## Next executable slice

Compose this exact accepted state lineage with accepted mobile presentation `df0ad112529afcd9bfdf084e9930c90ee0bfffb3` as a pure local union over accepted S6. Their changed paths are disjoint; no PR293 re-adoption, state rewrite or accepted test rerun is needed. A conflict or any authored product delta would require a new scoped disposition rather than a guessed resolution.

Then assign the canonical **UX-03 J3 source-selection restyle** to the sole mobile UI writer, using the accepted `ImportSetupView` and real `useImportOfferDecision` Later callback while preserving existing source selection/login behavior. Home eligibility and server intent/source-origin binding remain gated by their owning backend contracts. No routine Bradley decision is required.
