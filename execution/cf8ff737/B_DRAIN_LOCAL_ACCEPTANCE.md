# B/drain local acceptance

Parent EXEC-CF8FF737, September 24, 2026, about 15:50Z. B is accepted at the bounded local engineering scope.

## Accepted candidate

| Item | Value |
|---|---|
| Head | `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c` |
| Tree | `d02f9b124bee52107f8ad2f286f8af611b859fe6` |
| Parent | failed v4 `75a2863bf79a44f84050406d6878ec9a87f4053e`, preserved |
| Base | C1 `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` |
| Author and committer | Bradley Gleave |
| Message | `fix(importer): recognize empty trigger column vectors` |

## Evidence bound

- **Phase A (v4 and v5).** Both phases used genuine Lefthook hooks. The gates were tsc, eslint, prettier and check-r75. Jest passed 42/42 in the DB-free suites.
- **First real-PG proof, run at v4 `75a2863b`.** It FAILED with RC1: 11 passed and 8 failed, out of 19. The failure is preserved and not rewritten, at `execution/95633079/s7-b-drain/runtime/run/`.
  - **Root cause:** the empty trigger-vector comparison was dimension-sensitive.
  - **Classification:** A, B path only.
  - **Minimum closure:** exactly two predicate lines changed to `cardinality(t.tgattr::int2[]) = 0`.
- **Second real-PG proof, run at v5 `0d69c7ba`.** It was a single granted run, `B_V5_SINGLE_PG_PROOF_GRANT.md`, from 15:37:47Z to 15:38:57Z.
  - **Preconditions:** the PRE-1 preserving rename left identical hashes.
  - **Environment:** a fresh PG 17.6 disposable fixture, bootstrapped with 164 old migrations and with identity OK.
  - **Result:** Jest RC0, 19/19 in 52.4 s, exiting naturally.
  - **Teardown:** the fixture stopped with 0 survivors and the port free.
  - **Receipts:** outer receipts verified 8/8, including by the parent.
- **Reviewer A**, `b-review-a/B_DRAIN_V5_PG_PROOF_FINAL_FINDING_A.md`: ACCEPT, with no open A or B.
- **Reviewer B**, `b-review-b/B_DRAIN_REVIEW_B_FINAL_FINDING.md`: ACCEPT, with no A or B.
  - Both reviewers worked independently and did not read each other's reports.
  - Attribution holds: the diff from v4 is exactly the two predicate blobs, with the spec, fixture, bootstrap, tooling and PG all pinned identical.

## Qualifications (C, recorded; none gate)

- **Environment.** This is a local disposable synthetic fixture on PG17.6.
  - It is not PG15 CI.
  - It is not a remote push or merge, a deployment, a real-database drain, or customer or production acceptance.
- **Retained data directories.** Two stopped datadirs are retained:
  - `clusters/b-drain`, which holds v5.
  - `clusters/b-drain.v4-failed-75a2863b-20260924T151250Z`.

  Disposing of them is a later hygiene decision. Any future B-identity run repeats the preserving rename (C-13).
- **Inner-manifest timing.** The inner runner manifest seals the log before its own POST lines. The outer manifest closes this gap.
- **Earlier C items.** C-3, C-6, C-8, C-9, C-10, C-11 and C-12 carry over unchanged, and so does the jest-cli version-label note.

## Consequence

- **Reuse.** The review is closed for this candidate. Do not repeat the proof or re-audit the unchanged bytes unless the candidate or a material dependency changes.
- **Next lane.** R activates under `R_IDENTITY_READY_BUILD_GRANT.md` from this head.
- **Reserved.** Remote product publication of `0d69c7ba` remains reserved. It is not requested or implied here.
