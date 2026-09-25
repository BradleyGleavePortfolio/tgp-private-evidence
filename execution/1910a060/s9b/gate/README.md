# S9-B gate driver (prepared 2026-09-25 ~15:10 PT; NOT RUN; waits for the parent's relay on base M2)

Files:

- `s9b-gate-1910.sh` — one-shot driver modeled step-for-step on the accepted `../../s9a/gate/s9a-gate-1910.sh`
  (be88909f). `bash -n` clean. Both refusal paths exercised without a relay (exit 78; no `STARTED`, no lock touch).
- `PINS.env` — every hash the driver checks. `BASE=__FILL_M2__` is the only unfilled value; it is filled with the M2
  sha at relay (or passed as `S9B_BASE=`; both set and different → refuse). If the running reviews require a change
  to an owned file, the owned `SHA_*` line here is what gets updated (re-hash), never the driver.
- `commit-message.txt` (Addendum A included) / `commit-message-no-addendum.txt` (doc left at landed bytes). Both pass
  the lefthook R3 token scan and the driver's trailer check (tested with the hook's own regex).

Relay (parent only):

```
S9B_GATE_RELAY=1 S9B_BASE=<M2 40-hex> S9B_INCLUDE_ADDENDUM=<1|0> \
S9B_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
S9B_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
timeout -k 30 5400 bash /home/user/workspace/tgp-private-evidence/execution/1910a060/s9b/gate/s9b-gate-1910.sh
```

Clone state the driver requires at launch (parent composition, not this lane):

- `worktrees/1910a060-s9b` HEAD == M2, branch `exec1910/s9b`, no `node_modules`, no `.git/hooks/{pre-commit,commit-msg}`.
- `git status --porcelain --untracked-files=all` is EXACTLY the 10 owned new files (`??`) plus ` M docs/decisions/
  2026-09-25-s9-reconciliation.md` when `S9B_INCLUDE_ADDENDUM=1` (delta must be +99/-0 — `PINS.env DOC_ADDED_LINES` — against the landed bytes
  `cda68d82…`). With `=0` the doc must be at the landed bytes.
- The four S9-A paths are tracked at M2, clean, and at the accepted post-format sha256 (`211b474a`/`eca66f33`/
  `d16158ad`/`dc084dce`); the pre-format read-only copies this lane used (`eff1479c`/…) must no longer be in the
  working tree (they are the parent's to drop when re-basing the clone — this lane does not touch them).
- Every owned file at its pre-format sha256 in `PINS.env` (the bytes the reviews are reading).
- `prisma/schema.prisma` `0eb41f9a…`, `package-lock.json` `b7fed5ed…`, 172 migration dirs ending at
  `20270123000000_scout_run_lifecycle_expand` — all verified identical at `1c5fbb04` and `62471b11`, so the S8-F
  donor (`hidden lock 05bc530a…`, client `9042e713…`/`b8439203…`) fits M2 without an in-lane `prisma generate`
  (the RT-2 fallback is kept, as in the S9-A driver).

Step list and exit codes: 78 relay/pins refused (before lock), 76 sentinel / commit, 75 lock, 70 preconditions /
staged set, 71 node_modules / hooks / prefix, 72 prettier scope, 74 eslint / R75, 73 tsc / jest. Steps: lock (flock -n
fd 9, inode 667698 pinned and cross-checked with `runtime/LOCK_ESTABLISHED.txt`) → preconditions → `cp -a` donor →
`lefthook install` + path-normalized hook check vs `worktrees/1910a060-s8f` → prettier 3.9.9 prefix verify →
`prettier --check`/`--write`/`--check` on the owned `.ts`/`.cjs` (+ `.md` when included; `.sh` has no prettier
parser) with post-format copies under `postformat/` → `eslint --no-warn-ignored --max-warnings 0` on the owned
`.ts`/`.cjs` → `tsc --noEmit` whole repo (heap 4096) → `node scripts/check-r75.js` → `jest --ci` targeted (own
unit + guard, S9-A `reconcile.spec` on the committed bytes, S8-C/S8-B/S7-L db guards, locked_defaults,
doctrine-cleanup) → `jest --ci` full default config once (`timeout 2700`; rls-* excluded by `jest.config.js`) → stage
exactly the owned paths → `check-r75.js --mode=staged` → one hooked commit as Bradley Gleave → lineage/delta/identity/
trailer checks (forbidden-path delta check on `prisma`, `lifecycle`, `reconstruct`, S9-A files) → receipts
(`HEAD-<sha>.txt`, patch, manifest, `SHA256SUMS`). No push. The PG proof is a separate grant (`../binding/v2`).

Known relay-time risks (honest): hand-written source has not been formatted or type-checked; if `tsc`/`eslint`/
`jest` fail, the driver stops at that stage (one-shot), the failing log is in this directory, and the fix is a new
review + re-hash cycle on the owned file — not a rerun of the same bytes.
