# B/drain single real-PostgreSQL proof grant

Parent EXEC-CF8FF737, September 24, 2026. This is the separate local proof grant required after the exact stage-2 remainder; it is not deployment, remote product publication, or customer acceptance.

## Preconditions satisfied

- Actual local head `75a2863bf79a44f84050406d6878ec9a87f4053e`; tree `f4922ca070e887fb7f613ce955b12621b5c33156`; parent accepted C1 `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992`.
- Genuine hooks and granted affected gates passed, including two suites / 42 tests.
- Independent reviewer A: `b-review-a/B_DRAIN_ACTUAL_HEAD_BINDING_REVIEW_A.md`, actual head and five-pin binding bound, single proof GRANTABLE.
- Independent reviewer B: `b-review-b/B_DRAIN_REVIEW_B_ACTUAL_HEAD_ATTESTATION.md`, independently ACTUAL-HEAD ATTESTED / GO; no open source or binding A/B.
- Tooling-only recovery completed rc0 at 2026-09-24 15:10:41Z. PostgreSQL 17.6 postgres/initdb hashes and psql 18.6 match the inherited recipe. No clusters or postgres processes were present at its recorded completion.

## Exact execution

Sole executor remains `b_drain_exact_recovery_and_remainder_mufn6ybc`.

Execute the already-filled runner **once**, unchanged:

```text
timeout -k 30 3600 bash /home/user/workspace/execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh
```

Runner SHA-256: `a64d24dec5f7ef2a8c733f4b68d2532819c4b56253106e29a9824cc6c247b6b9`.

The runner takes the canonical nonblocking lock and reasserts the pinned head/tree/spec/bootstrap/fixture/environment. Its own bounded sequence is authorized: create/start only the B disposable PG17 fixture; restore the pinned obsolete-writer checkout; run the approved B bootstrap with old migrations and required old-client generation; assert B identity; execute only `test/rls-g2-b-drain.spec.ts` with the sealed Jest arguments once; stop only the owned fixture; preserve the datadir and raw evidence; verify observed no-owned-survivor/port-free state and release the slot.

S5 and C1 accepted proofs and absent clusters are not recreated or rerun. No copy/reinstall/regeneration beyond the old-client generation already inside this specific sealed bootstrap. No live data, production access, remote product write, source edits, gate expansion or hidden retry.

First nonzero stops. Preserve the original failure, sentinel and all output. Report the exact blocked stage and smallest closure; do not erase receipts, silently restart the runner or manufacture a success.

## After exit

Notify parent immediately that the B slot is released, with actual exit, head, result count, fixture stop and survivor observations. J3 has the next queued heavy slot under `J3_R5_ENV_COMMIT_AND_GATES_GRANT.md`, even while these B results undergo final independent disposition.

Both independent reviewers continue their existing review to bind this one run to the actual head and render final acceptance findings. No new source audit or duplicate heavy proof. The builder cannot self-accept.

C-only detached-head hygiene is recorded and does not gate this proof; the verified portable bundle already preserves the commit. No additional task or delay is created for it.
