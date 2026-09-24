# R local acceptance

**Parent:** EXEC-CF8FF737. **Time:** 17:01Z. This is the actual clock. Earlier grant files carry estimated labels; for example, the R PG grant file's mtime is 16:48:50Z. That is C, recorded here.

## Accepted commit

R (T4), identity-ready with canonical platform tokens, is accepted.

| Item | Value |
|---|---|
| Head | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` |
| Tree | `95cdfadc1ae993db23d0d1310ee8029c7867d147` |
| Chain | B `0d69c7ba` → `df36e331` → `7d2895e1` (closure 1) |
| Author and committer | Bradley |
| Trailers | none |

## Proof

A single granted local disposable PG17 run: binding sha `787d34b0…`, from 16:49:06Z to 16:54:09Z.

- Sentinel `RC=0 STAGE=done`, and the outer rc is 0.
- Jest `rls-live` passed 17/17 (R01–R12, with R11 run twice).
- The fixture stopped cleanly.
- The retained B clusters were hashed only, and their hashes were unchanged.
- The worktree was unchanged.

Record: `r-ready/R_PG_PROOF_RESULT.md`.

## Reviews

| Reviewer | Phase-1 result | After closure 1 | Final |
|---|---|---|---|
| A | NO-GO, 3× B | GO | ACCEPT |
| B | NO-GO, 2× B | GO | ACCEPT |

Closure 1 fixed all of those B findings. Neither final has an A or an open B. Records: `r-review-a/R_FINAL_FINDING_A.md` and `r-review-b/R_FINAL_FINDING_B.md`.

## Default Jest

The builder's default-Jest flag is C. The closure delta touches only `migration.sql` and the PG-only spec, so receipt 11 stands.

## Scope

- Synthetic local PG17 only.
- Not proven: PG15 CI, real deployed-writer drain, production applicability.

## Carried to the runbook

C-R1–C-R12 and review B's C-1–C-11, including running R as a BYPASSRLS role and the N-ordering comment in `down.sql`.

## Landing

Landed on backend `integration/importer` as a fast-forward from B.
