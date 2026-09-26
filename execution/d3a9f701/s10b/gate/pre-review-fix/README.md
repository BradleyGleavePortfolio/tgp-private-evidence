# S10-B gate (EXEC-D3A9F701) — source only, NOT RUN, NOT GRANTED

Derived by substitution from the accepted S9-C gate `d3a9f701/s9c/gate-3/{s9c-gate-d3a9.sh,PINS.env}`. Full diff: `DELTA-from-s9c-gate-3.diff`.
Nothing here has been executed except `bash -n` and the read-only `--fill-help` git queries.

| file | purpose |
|---|---|
| `s10b-gate-d3a9.sh` | driver (sha256 in `GATE.sha256`) |
| `PINS.env` | every pin; `__FILL_BASE__`, `__FILL_BASE_TREE__`, `__FILL_MIGRATIONS_TREE__` are still open |
| `commit-message.txt` | Bradley-voice message, conventional subject, no trailers, banned-token clean (checked against the commit-msg hook regex) |

## Parent steps before relay (in order; none done by the builder)

1. **Land S10-A** (`s10a/land/land-s10a.sh`). It makes one commit on a4af8e33. Record the sha: `git -C /home/user/workspace/worktrees/d3a9-s10a rev-parse HEAD`, or `git ls-remote origin refs/heads/land/s10a`.
2. **Move the S10-B clone onto BASE.** Keep the untracked S10-B files and the ` M prisma/schema.prisma`. S10-A touches no path S10-B owns, so a fast-forward carries the local changes through:
   ```
   cd /home/user/workspace/worktrees/d3a9-s10b
   git fetch origin refs/heads/land/s10a            # or: git fetch /home/user/workspace/worktrees/d3a9-s10a HEAD
   git merge --ff-only <S10-A sha>                  # branch stays exec-d3a9/s10b
   ```
   If the landing is not a fast-forward of a4af8e33, stop. The gate needs `BASE^ == a4af8e33`.
3. **Fill the pins.** This step is read-only:
   ```
   bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/gate/s10b-gate-d3a9.sh --fill-help <S10-A sha>
   ```
   Paste the `BASE=`, `BASE_TREE=` and `MIGRATIONS_TREE=` lines into `PINS.env`. Confirm three things in the printed checks:
   - all 14 FREEZE lines are `OK`
   - `BASE^` is a4af8e33
   - the schema and contract blobs match
   
   `MIGRATIONS_TREE` should come out as 654550cb99b55473429a9c60ee08319e1b649106. Then re-hash `GATE.sha256`.
4. **Hook set-aside, only if needed.** The gate refuses with rc 70 when `.git/hooks/pre-commit` or `commit-msg` already exists. It never overwrites a hook. Both hooks are absent today; they appear if lefthook ran in the clone. To clear them:
   ```
   TS=$(date -u +%Y%m%dT%H%M%SZ); SA=/home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/gate/hooks-set-aside-$TS
   mkdir -p "$SA"; for h in pre-commit commit-msg; do [ -e .git/hooks/$h ] && sha256sum .git/hooks/$h >> "$SA/SHA256SUMS" && mv .git/hooks/$h "$SA/$h"; done
   ```
   The set-aside copies are evidence. Do not delete them.
5. **node_modules must be absent** in the clone (it is absent today). If a copy exists, move it to `execution/1910a060/runtime/set-aside/`. Do not delete it.
6. **Disk.** The donor is 717 MB and about 2.7 GB is free now. The generated client adds about 45 MB.
7. **The canonical lock must be free.** S9-C gate-2/gate-3 must have finished.

## Relay (one shot; the STARTED sentinel blocks reruns)
```
S10B_GATE_RELAY=1 S10B_BASE=<S10-A sha> \
S10B_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
S10B_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10b/gate/s10b-gate-d3a9.sh
```
`S10B_BASE` is now mandatory and must equal `PINS.env` BASE.

## Deltas vs the S9-C gate-3
- **Scope.**
  - W is `worktrees/d3a9-s10b`, branch `exec-d3a9/s10b`.
  - BASE is the S10-A landing, and `BASE^ == a4af8e33` is enforced.
  - The `a4af8e33..BASE` delta must be exactly the 14 `FREEZE.sha256` paths. The file's sha is pinned. Each committed blob must hash to the FREEZE `POST` sha, and the files must be clean in the worktree.
  - This replaces the S9-B-pins, S9-A and doc-prefix blocks. There is no owned doc.
- **Owned paths.** There are 16: 1 ` M` (`prisma/schema.prisma`) and 15 `??`. Prettier runs on the 12 `.ts`/`.cjs` files only. The schema, the `.sql` files and the `.sh` file must stay byte-identical through formatting.
- **Schema and migration.**
  - The BASE schema must be blob 2e328bbc (sha 0eb41f9a). The working delta must be exactly `+63/-0` and add the three models.
  - Prisma status must be exactly `M schema` plus `?? migration.sql` and `?? down.sql`.
  - BASE must have 172 migration dirs, ending at S7-L, with the tree pinned. The working tree must have 173, ending at `20270124000000_scout_run_observation_expand`, and the only addition must be that dir, holding exactly the two files.
  - The harness constants (`EXPECTED_MIGRATIONS=173`, `S10B_MIGRATION`, `S7L_MIGRATION`, `BASE_HEAD=a4af8e33`) are checked in the bootstrap, pg-harness and db files.
  - After the commit: the prisma delta is exactly those 3 paths, there are no D/M/R changes to accepted migrations, and `ls-tree` shows 173.
- **Lesson 5: prisma generate is always run, and only inside the isolated copy.** The gate uses `cp -a $S10B_DONOR $W/node_modules`, which makes a real directory.
  - It then checks that `@prisma/client`, `.prisma`, `.prisma/client` and `prisma` are real directories that resolve inside `$W`, with no absolute symlinks, and that the prisma CLI is 6.19.3.
  - It runs `$W/node_modules/.bin/prisma generate --schema prisma/schema.prisma` from cwd `$W` with `PRISMA_GENERATE_SKIP_AUTOINSTALL=1` and `CHECKPOINT_DISABLE=1`. Prisma writes `$W/node_modules/.prisma/client`, which sits next to the copied `@prisma/client`.
  - The donor's `.prisma` and `@prisma/client` tree signature (path, size, mtime, mode) and its client `index.d.ts`/`schema.prisma` shas are measured before the copy and after the generate. They must be unchanged and must equal the pinned pre-S10-B values 9042e713 and b8439203.
  - The in-lane client must differ from the donor, carry the three models, and use the engine that matches the `@prisma/engines` copy.
  - `CLIENT_INDEX_DTS` and `CLIENT_SCHEMA` are set to `RECORD`, because nothing was generated at authoring time. The gate logs `POSTGEN_CLIENT` and writes `postgen_client` into the receipt, which the binding uses. Set a 64-hex value to enforce it on any re-gate.
- **Contract: the gate asserts no change.** D-S10-8 (doc L355) lists "OpenAPI bytes" as not owned by S10-B. The generator owner in S10-C regenerates them (L356).
  - The contract is not owned here. Its blob (8ebf936a) and sha (9eacdd3e) must match BASE.
  - Regeneration runs with `IMPORTER_CONTRACT_OUT=$E/contract-regen.json`, a scratch path supported by `scripts/export-importer-contract.ts` L20-25. The output must be byte-identical to `BASE:$CONTRACT`. The canonical file is never written.
  - Then the contract spec runs. The contract must not appear in the delta.
  - `ObservationModule` is unregistered, so no change is expected.
- **Lesson 1.** There are no `cmd | grep -q` pipelines: the pgrep, lslocks, lefthook-version, schema and harness checks all capture output first, then grep a here-string. `grep -rnE '\|\s*grep\s+-[a-zA-Z]*q'` matches only the header comment.
- **Lesson 2.** Pre-existing hooks refuse with rc 70 and point to step 4 above.
- **Lesson 3.** `commit-message.txt` must exist, be non-empty and pass the hook's banned-token regex before the lock is taken (rc 78).
- **Lesson 4.** `check-r75.js --mode=staged` runs twice:
  - Early, on the post-format bytes: stage the owned set, check, `git reset -q`, then verify the index is empty and the status set is restored. This catches an R75 hit before eslint, tsc and jest.
  - On the final staged set, before the commit.
- **Suites.** 7 targeted suites: the 5 S10-A `test/scout/induction/*.spec.ts` files plus `observation.{service,controller}.spec.ts`, requiring "Test Suites: 7 passed, 7 total". Then the full default jest runs once; it ignores `test/rls-*.spec.ts`.
- **Forbidden delta.** Package files, `docs`, `scripts`, `nest-cli.json`, `scout.module.ts`, `lifecycle`, `reconciliation`, `reconstruct`, the 5 S10-A source files, `induction/sources`, `test/fixtures`, `test/contracts`, and the contract.

## Assumptions the parent must verify
- The S10-A landing is exactly one commit on a4af8e33 with the 14 FREEZE bytes. If a formatter changes any S10-A byte, the gate refuses; re-pin `S10A_FREEZE` in that case.
- `HARNESS_BASE_HEAD=a4af8e33` is kept. The S10-B harness pins a4af8e33, which remains an ancestor of the S10-B head. The prisma diff from it is still exactly the S10-B three, because S10-A touches no prisma path. No harness edit is needed. If the parent wants the harness pinned to BASE instead, that is a source change to the bootstrap and db files plus a re-pin.
- `prisma generate` runs offline with the copied engines. The S7-L RT-2 precedent did this, but it is untested on 6.19.3 in this lane. If it tries to download anything, the gate stops at rc 71 with `prisma-generate.log`.
- Merge order: the doc says S10-B "merges after S9-C lands" (L355). This gate commits on the S10-A landing and does not include S9-C. The landing script must handle composition with S9-C.
- The builder summary is right that no S10-B file modifies S10-A bytes; the reviews found none. The gate checks this anyway.
