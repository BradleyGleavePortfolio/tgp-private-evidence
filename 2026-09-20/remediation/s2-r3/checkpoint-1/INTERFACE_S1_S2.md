# S1 ↔ S2 verifier interface (R3)

Written by S2 fixer for the S1 fixer (`s1_r3_safety_fixer_muaeeplu`). Facts only; no schema writes by S2.

## What S2's runner (`scripts/release.sh`) will require
1. `prisma/migrations/<dir>/verify.sql` for every `<dir>` listed in `scripts/release-required-verifiers.txt` (S2-owned file, one migration directory name per line, `#` comments). Missing/unresolved entry or an empty list → `release.sh` exits non-zero at **step 0, before `prisma migrate deploy`** (no DB contact).
2. Every discovered `verify.sql` is executed after `migrate deploy` with `npx prisma db execute --url "$DIRECT_URL" --file <verify.sql>`; non-zero exit (a `RAISE EXCEPTION`) fails the release_command.
3. The runner asserts `ran == discovered >= required >= 1`.

## What S2 has written into the contract file
`20261224000000_rls_close_public_exposure` — the directory name observed in the frozen S1 R2 head `90a6647513f3566393764eee87237d9b5b1f150b`.

## Asks of S1
- Confirm the migration directory name on the S1 R3 head (rename → tell S2/parent; the contract file must match exactly).
- Confirm `verify.sql` exits non-zero via `prisma db execute` on a drifted synthetic DB and zero on a correct one (S1's synthetic fixture; S2 has no DB slot). S2 does not assume psql.
- Role/grant postconditions inside `verify.sql` are S1's; S2 will not widen grants or demote checks.

## Final state at S2 head 1c6db2b6 (2026-09-20 22:57Z)
- Contract file: `scripts/release-required-verifiers.txt` (pinned path, no env override). Entry: `20261224000000_rls_close_public_exposure`.
- Entry rules enforced by release.sh step 0: bare directory name `^[A-Za-z0-9_][A-Za-z0-9_-]*$`, no duplicates, no CRLF, must resolve to `prisma/migrations/<name>/verify.sql` in the image; ≥1 entry required.
- Runner: `npx prisma db execute --url "${DIRECT_URL}" --file <verifier>`; a RAISE = release failure after `migrate deploy`.
- S1 action if the migration directory is renamed: update the one line in the contract file (S2-owned file, S1-owned name) in the same change.
- S2 candidate alone fails closed at step 0 (no DB contact); integrated S1+S2 is the first candidate that can pass step 0.
