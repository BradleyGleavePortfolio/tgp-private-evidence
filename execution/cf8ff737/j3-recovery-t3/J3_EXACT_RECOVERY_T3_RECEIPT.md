# J3 exact recovery (T3) — receipt

**Result: RECOVERED EXACTLY. Byte/object restoration only. No synthetic/orphan substitute, no new history, no source change.**

The predecessor's blocker (`J3_R5_SOURCE_ONLY_RECOVERY_STATUS.md` §3) was a lookup miss, not missing evidence. The accepted composition `716a606e…` is durably archived as a **complete-history** bundle:
`/tmp/tgp-private-evidence/execution/95633079/ux/mobile-composition/ux-mobile-composed-716a606e.bundle`
(sha256 `a61e43355ff104ab1d663c0ea4d90beaa0d352c55c7db9f193c100bed6751140`, which matches `COMPOSITION_ATTESTATION.md`; `git bundle verify`: okay, "records a complete history").

## Identity receipts (all MATCH)

| Object | Expected | Obtained | Method |
|---|---|---|---|
| Composition commit | `716a606e9d23c77a6d705beccb8cefc6e8228284` | same; tree `430c76a0…` and raw object byte-equal to `03-merge-commit-object.txt` | fetch from the composition bundle |
| r3 commit | `22d056bb9d36d3c9f659e6d870ef443f9a0a697b` | same; tree `4e139900f0f10a3c63bc0baf150257dd0ce8fd60`, parent `716a606e` | fetch from the thin r3 bundle once its prerequisite was present |
| r4 tree | `0ec34e174d52cfdeddfc145b323b6045a3dd5d5c` | same | r3 + `12-r3-to-r4.patch` (sha256 `9bbdbc11…d8b1`) applied to a temp index, then `write-tree` |
| r4 commit | `820dbd04500b06648ce4c0820c1badced55d6d7c` | same | `hash-object -t commit -w` of the raw object recorded in `16-r4-commit.txt`. Hash verified before write (`r4-raw-commit-object.bin`) |
| r5 tree | `823b97006f7df9617bad5516d7ef578189095e82` | same | r4 + `22-r4-to-r5.patch` applied to a temp index, then `write-tree`. The working tree gives the same tree again |
| r4→r5 patch | sha256 `48d1c583…25a5fb6` | `git diff 820dbd04 823b9700` is **byte-identical** (cmp) | regenerated |
| r3→r4 patch | `12-r3-to-r4.patch` | `git diff 22d056bb 820dbd04` is **byte-identical** (cmp) | regenerated |
| Product blob | `92ed52f5cc108f3a098062364d6af793cbb8e2b7` | same in r3, r4, r5 and the working tree | ls-tree / hash-object |
| r5 test blobs | test `a1f65a6b…`, restore `34263aee…` | same | working-tree hash-object |

The pre-r3 blobs that the predecessor listed as missing (`f97adfc…`, `27b0b2b…`, `43ac136…`) are all present in the `716a606e` tree. `git fsck --full`: rc 0.

## Materialized state: `worktrees/ux03-j3`

- A standalone repo with **0 remotes**. `core.hooksPath=/dev/null` is set in the repo-local config, so hooks are disabled. No `node_modules`.
- `HEAD` = `refs/heads/ux03-j3-source-selection` = `820dbd04…`. This is the restored r4 commit, not a new commit.
- r5 is applied **unstaged** to the working tree, matching the frozen r5 posture in `24-r5-freeze-note.md`. `git status` shows only the two test files modified.
- Auxiliary local refs: `compose/importer-presentation-state` (716a606e) and `r3-bundle-head` (22d056bb).

## Not done (per grant)

- No r5 commit, install, env copy, format, typecheck, lint, test, lock, push, or remote write.
- No source re-audit and no peer reviews read.
- Existing receipts are unmodified. `/tmp/tgp-private-evidence` was only read.

## Next

- J3 r5 is now mechanically unblocked. The next step is the parent's r5 commit, using the approved message in `23-r5-commit-message.txt`.
- After that comes the gate run prepared in the predecessor report §7. It needs an environment/`node_modules` reuse decision, which is a separate environment item and is not affected by this recovery.

## Files

- `01-composition-and-r3-materialization.txt`
- `02-r4-r5-exact-reproduction.txt`
- `03-worktree-materialization.txt`
- `r4-raw-commit-object.bin`
- `r3-to-r4.regenerated.patch`
- `r4-to-r5.regenerated.patch`
- `tmp-index-*` (scratch indexes, kept)
