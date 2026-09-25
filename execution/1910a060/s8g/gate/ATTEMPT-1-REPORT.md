# S8-G gate attempt 1 — STOPPED at tsc (rc 73), state preserved, lock released

Driver `s8g-gate-1910.sh` (sha256 `392b5f92…`, `SCRIPT.sha256`), launched 2026-09-25T22:01:19Z (`LAUNCH.txt`, pid 7946/7955) with the relayed donor and prettier prefix on base `H=62471b11` (after `build/REBASED.md`). Lock inode 667698 was free at launch (`waited=0s`), held on fd 9 from 22:01:19Z to 22:02:51Z, released at exit (`lslocks` shows no holder; file preserved, inode 667698).

| Stage | Result |
|---|---|
| preconditions | OK (HEAD 62471b11, branch, exactly 14 paths at PREFORMAT shas, schema/lock pins, no node_modules/hooks) |
| node_modules | `cp -a` donor 21 s; hidden lock `05bc530a…`, client `9042e713…`/`b8439203…` == pins; no prisma generate needed |
| hooks | lefthook 2.1.9 installed into the clone; path-normalized bodies == S8-F reference (`9dcf80f4…`/`4ab9b419…`); own hooks reference own `node_modules/lefthook-linux-x64/bin/lefthook` |
| prettier prefix | manifest 56/56 OK, `prettier --version` 3.9.9 |
| prettier | check-1 rc 1 (layout only) → `--write` on the flagged in-scope files → check-2 rc 0. Post-format copies in `postformat/`; shas in `gate.log` POSTFORMAT lines |
| eslint (13 files, `--max-warnings 0`) | rc 0 |
| **tsc --noEmit (whole repo)** | **rc 2 — exactly one error**: `test/scout/orchestration/reconstruct-run.spec.ts(77,48) TS2352: Conversion of type 'Staged' to type 'Record<string, unknown>' may be a mistake` (`tsc.raw.log`). Run stopped per policy (no fix-and-retry inside the run). |
| jest / commit | not reached |

## Preserved state
- Evidence: this directory (`gate.log`, `tsc.raw.log`, `eslint.raw.log`, prettier logs, `STARTED`, `TERMINAL` = `RC=73 STAGE=tsc`, `SHA256SUMS`, `freeze/` pre-format copies, `postformat/` copies, `POSTFAIL-tree.txt` = blob+sha256 of all 14 files exactly as the run left them).
- Clone `worktrees/1910a060-s8g`: HEAD `62471b11`, no commit, index empty, `node_modules` (attempt-1 copy, 717M) and the two lefthook hooks still present; the 14 files are prettier-formatted (uncommitted).

## Fix applied OUTSIDE the run (source prep, one line, test file only)
`reconstruct-run.spec.ts` L77: `(s as Record<string, unknown>)[k] === v` → `s[k as keyof Staged] === v` (no cast to an unrelated type; no R75 token). It was the only tsc diagnostic, so no further type errors are expected — but this is unverified until attempt 2 runs (no tsc outside the slot).

## Attempt 2 (prepared, NOT launched — awaiting parent disposition)
`attempt-2/s8g-gate-1910-a2.sh` (`bash -n` OK): identical stages; differences — requires `S8G_GATE_RELAY=2`; evidence under `attempt-2/`; reuses the pinned attempt-1 `node_modules` and hooks (verified against the same pins: hidden lock, client, path-normalized hook bodies, own-path reference) instead of re-copying/re-installing; preconditions pin the corrected tree via `attempt-2/PREFORMAT.sha256` + `attempt-2/freeze/`. Launch: `S8G_GATE_RELAY=2 S8G_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules S8G_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 timeout -k 30 7200 bash attempt-2/s8g-gate-1910-a2.sh`. Alternative disposition: delete `node_modules` + hooks and rerun the attempt-1 shape from a fresh copy (driver would need `E` and `STARTED` reset; not prepared).
