# UX-03c local acceptance

**Parent:** EXEC-CF8FF737. **Time:** about 16:58Z.

## Accepted commit

UX-03c (T2) is accepted.

| Item | Value |
|---|---|
| Head | `c7641cb3a4b69de4846a5b5b3a5a939da2c97ebc` |
| Tree | `7a5305e50c4cdeb2b1272ab9c9ace9fb704f67d9` |
| Parent | merge `76d3bb4c8259ac3b50f15fe7f28aca1c419a8c34` |
| Merge parents | UX-03a `797be968` and UX-03b `519b0122` |
| Author and committer | Bradley |
| Trailers | none |

The merge `76d3bb4c` is the byte-exact union of the two children. They changed disjoint paths, 16 in all, and the merge adds no resolution bytes.

## What UX-03c adds

The panel renders the frozen `PAIRING_REASON_COPY` for two cases:

- `failed` with reason `conflict`
- `expired` with reason `challengeUnavailable`

With a null reason, the panel keeps the UX-03a copy. It exposes no nonce, intent id or locator.

## Gate

The heavy slot was held from 16:40:56Z to 16:42:49Z.

| Check | Result |
|---|---|
| tsc | rc0 |
| lint | rc0 |
| Jest | rc0, 11/11 suites, 403/403 tests |

## Independent review

The independent T2 reviewer returned ACCEPT, with no A or B and one inherited C (`ux03c-review/UX03C_FINAL_FINDING.md`).

## Scope

Tests are mocked consumer tests only. There is no live-backend, device, E2E or G3-AUTH claim.

Landing is on mobile `main` as a fast-forward from `797be968`, and it lands UX-03b along with UX-03c.
