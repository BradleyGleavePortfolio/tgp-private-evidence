# CORRECTION-1 to land-s8f-1910.sh: pre-run, directed by parent grant LAND-S8F-1 (2026-09-25 ~21:47Z)

- Script sha256 before (committed in evidence 66f22fc): `32cfd0781cb284666a189a3e5a0d1ec70a309205681dcd96ee1cfe542a10c7cf`
- Script sha256 after: `2adc7e1054cc660045b32378f328dc72ed4b1618364533581b914df5e3f64dfd` (`bash -n` OK)
- The diff is in `analysis/CORRECTION-1.diff`. It is the only change.

## Defect

lefthook 2.1.9 hook bodies embed the owning clone's absolute `node_modules` path. The fixed raw pins
`3b741de3…` / `71029ce8…` in HOOK_PRECOMMIT / HOOK_COMMITMSG come from the historical shared clone. With those pins,
compose would have refused with rc 71 in the new clone `worktrees/1910a060-land-s8f`.

## Fix

The fix uses the same method as `s9a/gate/s9a-gate-1910.sh` L42-46 and L117-132. After `lefthook install`, compose now checks:

1. Both hooks exist and are executable, and the reference hooks exist in `HOOK_REF_ROOT=/home/user/workspace/worktrees/1910a060-s8f/.git/hooks`.
2. `node_modules/.bin/lefthook version` is `2.1.9`.
3. Each clone's absolute root is replaced with `@CLONE_ROOT@` in both hook bodies. The own normalized sha256 must equal the reference normalized sha256.
4. Each own hook references `$W/node_modules/lefthook-linux-x64/bin/lefthook` and does not reference the reference clone root.
5. Raw and normalized hashes are logged (HOOK_RAW, HOOK_NORMALIZED). The COMPOSE_RECEIPT `hooks` line now records the raw and normalized values and the lefthook version.

RECIPE.md §5 step 7 ("checks the hook sha256 values 3b741de3… and 71029ce8…") is superseded by this note.
