# J3 r5 — environment and hook applicability prep (source-only)

This prep is source-only. No install, commit, gate, lock, network or config change was made in this turn. There was no source audit and no history enumeration.

## 1. Pins, all taken from existing receipts

| Pin | Value | Evidence | Recovered r4 (`820dbd04`) |
|---|---|---|---|
| Node | `v20.20.1` | `03-env-reuse.txt`; grant | sandbox `/usr/local/bin/node` = v20.20.1 ✔ |
| npm | `10.8.2` | same | sandbox `/usr/local/bin/npm` = 10.8.2 ✔ |
| `package-lock.json` sha256 | `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69` | grant; `03-env-reuse.txt` | `git show HEAD:package-lock.json` ✔ |
| `package.json` | unchanged from composition `716a606e` (sha256 `63e2e2e2…0d5f`) | `git diff --quiet 716a606e HEAD` | ✔ |
| Installed record `node_modules/.package-lock.json` sha256 | `c4d7824b8b519c4a1720f13deb37b3d65e3f9987aca7734e352cee0ed0ac450b` | grant; `03-env-reuse.txt`; account-state receipts | **absent (no node_modules)** |

`package.json` has no `engines`, no `packageManager` and no root `preinstall`/`postinstall`/`prepare` script.

## 2. Why the environment is missing, and which sources are ruled out

- **Original route.** J3 r3/r4 made an isolated `cp -a` real-directory copy from `worktrees/ux01-state/node_modules`, after verifying that the package inputs were identical. That copy does not exist in this sandbox. Only `worktrees/ux03-j3` and `worktrees/s7-b-drain` exist.
- **Not archived.** A bounded search of `/tmp/tgp-private-evidence` found no archived mobile `node_modules` and no tarball carrying installed record `c4d7824b…`. The only hits are receipts that mention the hash.
- **B's dependencies are ineligible** because their lock graph differs:
  - `s7-b-drain/package-lock.json` sha256 is `b7fed5ed…`.
  - Its installed record is `05bc530a…`, a different repository and graph.
  - Per the parent's instruction, they must not be used.

## 3. Minimum environment recovery: the existing recorded mobile recipe

The original accepted mobile tree came from a single `npm ci`. It is recorded in `mobile-presentation/COMMIT_ATTESTATION.md` and `validation-receipts/03-npm-ci-status.txt`: `npm ci exit_status=0 duration_s=367`, lock unchanged before and after. That run was plain `npm ci`; the log contains audit output, so it was not run with `--no-audit`. UX-01 and J3 then copied that tree, and the copies carry the same installed record `c4d7824b…`.

Proposed single step. It needs an explicit necessity grant because it uses the network/registry, and the J3 grant granted no install.

```
cd /home/user/workspace/worktrees/ux03-j3
node -v   # must be v20.20.1
npm -v    # must be 10.8.2
sha256sum package-lock.json   # must be 840be0b8…6b69
npm ci    # exact recorded recipe; bound ~600s; first nonzero stops
sha256sum node_modules/.package-lock.json   # must equal c4d7824b…450b, else STOP (mismatch is not success)
sha256sum package-lock.json; git status --porcelain   # lock unchanged; only the two r5 test files M
```

Parent choices:

- **Flags.** Plain `npm ci` is the recorded original. `--no-audit --no-fund` only suppress reporting and do not change the graph, so they are acceptable if the parent prefers them.
- **Do not add `--ignore-scripts`.** The recorded mobile tree was built with dependency lifecycle scripts enabled. Adding the flag could change installed contents without changing the installed-record hash, so the hash would not catch it.
- **Expected warnings.** The EBADENGINE warnings (for example `@testing-library/react-native@14.0.0` wants Node ≥22) were already present in the accepted run. They are not a new finding.

Stop conditions:

- Wrong Node or npm version.
- Lock hash drift.
- Installed record ≠ `c4d7824b…`.
- Any change to a tracked file.

## 4. Commit and hook route

**Original legitimate route.** r3 and r4 both used an ordinary `git commit` with no bypass flag:

- Mobile has no configured hooks. `core.hooksPath` was unset, `.git/hooks` held only `*.sample`, and there was no `.husky`. This is recorded in `01-preflight.txt`, `15-r4-stage-and-treecheck.txt` and `mobile-presentation/COMMIT_ATTESTATION.md` §Commit.
- The grant says: "The existing mobile no-configured-hooks posture may stand if confirmed; no hook execution is invented or bypassed."
- Identity was repo-local `user.name` = `Bradley Gleave` and `user.email` = `bradley@bradleytgpcoaching.com` (`02-identity.txt`).

**Recovered repo.** It checks out the same posture at source level:

- The tracked tree has no `.husky` or `.githooks`.
- `package.json` has no husky, lint-staged or simple-git-hooks.
- `.git/hooks` holds only `*.sample`.

**One deviation.** I set `core.hookspath=/dev/null` in the repo-local config during this restoration. It is not the original posture and must not be the route for the new commit.

**Commit-time route** (for the future execution grant; not done now):

1. Run `git config --unset core.hooksPath` to return to the original unset/default posture. Confirm `.git/hooks` holds only `*.sample` and there is no `.husky`.
2. Set repo-local `user.name "Bradley Gleave"` and `user.email bradley@bradleytgpcoaching.com`. Check both identities with `git var GIT_AUTHOR_IDENT` / `GIT_COMMITTER_IDENT`.
3. Preflight:
   - `HEAD` = `820dbd04…`.
   - Only the two test files are modified.
   - The working-tree blobs are `a1f65a6b…` (test) and `34263aee…` (restore), and the product blob is `92ed52f5…`.
4. Stage exactly `src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx` and `src/screens/coach/__tests__/ImportDataScreen.test.tsx`. `git write-tree` must equal `823b97006f7df9617bad5516d7ef578189095e82`.
5. Commit with `git commit -F <evidence>/validation-receipts/23-r5-commit-message.txt`. Use no `--no-verify`, no amend and no trailers. The expected parent is `820dbd04…` and the expected tree `823b9700…`.

## 5. Approved message (exact)

`23-r5-commit-message.txt`: 49 bytes, no trailing newline, single subject, empty body, no trailers:

```
test(importer): complete J3 screen mock isolation
```

## 6. Gate commands in original order, on the actual r5 head

These come from the J3 grant: the r4 section, reaffirmed for r5. The grant's local-binary form supersedes the `npx` form in the predecessor's §7.

1. `./node_modules/.bin/tsc --noEmit`, bounded at 180 s.
2. `./node_modules/.bin/eslint src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx`, bounded at 120 s. This lints only the two changed test files; the earlier product-file lint still applies because the product blob is unchanged.
3. `./node_modules/.bin/jest src/screens/coach/__tests__/ImportDataScreen.test.tsx src/screens/coach/__tests__/ImportDataScreen.restore.test.tsx --silent --runInBand`, bounded at 180 s. This is the full two-file, 50-case run with no filter.

Use ordinary small kill grace. The first nonzero exit stops the run, with no fix, retry, formatter or wider suite. Preserve the raw receipts and leave the commit unamended.

## 7. What the separate execution grant must cover

- A canonical `execution/test-validation.lock` slot. B currently owns the heavy slot.
- One `npm ci` necessity exception using the recorded recipe (§3), verified to installed record `c4d7824b…`.
- The hook-posture reset and repo-local identity (§4).
- The ordinary r5 commit (§4–5).
- The three gates (§6).

Nothing else is needed: no new dependency, config or source change.
