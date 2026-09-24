# Reviewer A — acknowledgement of parent v4 grant (2026-09-24 01:05 PDT)

Received. FB-3 consolidated with reviewer B's independently found defect as B-BD-FRESH-FAKE. Writer grant: fresh fenced one-NULL-row fake for the existing zero-retry unit assertion + one-file format check + refreeze as v4; every other v3 byte fixed/applicable. The differing static predictions of the cumulative transaction count across reports are non-blocking wording (the closure is identical) and no reconciliation cycle is opened.

No work performed now. On exact v4 arrival, same-review of the single hunk / new pins only:
- v4 tree exists; vs v3 exactly 1 `M` (`src/scout/scout-ledger-backfill.spec.ts`), all other 10 blobs identical to v3 (`00b105ff…` set), S5 donors unchanged;
- hunk content: new `FakeLedger` with one NULL-platform row, `fenced = true`, `faults = ['lock']`, assertions on that fake only (`transactions 1`, pass `{chunks 0, lockFailures 1, stalledByLocks true}`, outcome `'stalled'`); nothing else in the file changed except Prettier output;
- format-only correspondence (pre-format blob → formatted) if applicable;
- packet hashes; then narrowed phase-A gate and pin-binding requirements as in `B_DRAIN_V3_BINDING_REVIEW_A.md` §3–4, with the v4 tree replacing v3.

Status: WAITING for exact v4.
