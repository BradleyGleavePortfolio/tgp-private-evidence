# S10-C gate — EXEC-D3A9F701 (SOURCE ONLY: NOT RUN, NOT GRANTED)

Derived from the final S10-B gate (`../../s10b/gate/s10b-gate-d3a9.sh`, with every review fix and DELTA-2 applied; it ran rc 0 and landed a2c74e90).
Diffs: `DELTA-from-s10b.diff` (driver) and `DELTA-PINS-from-s10b.diff` (pins). Hashes: `GATE.sha256`.

## Files
| File | Role |
|---|---|
| `s10c-gate-d3a9.sh` | driver (relay + `--fill-help`) |
| `PINS.env` | pins; BASE / BASE_TREE / MIGRATIONS_TREE / OWNED_PINS are `__FILL__` |
| `FROZEN.sha256` | 29 S10-A + S10-B paths (all but observation.module.ts): `FROZEN <sha256> <blob> <path>` at a2c74e90. The driver pins its sha. |
| `commit-message-contract-unchanged.txt`, `commit-message-contract-changed.txt` | Bradley-voice messages. The driver picks one at the contract step. Both are token-checked before the lock. |

## What differs from S10-B
- **BASE.** BASE is the integration/importer tip at gate time: 711c1f8f at 22:34, or later if S11-A1 c8ee9005 / PR #552 lands first. There is no parent-shape pin. Instead, S10B_HEAD a2c74e90 and HARNESS_BASE_HEAD a4af8e33 must each be an ancestor of BASE (`git merge-base --is-ancestor`, checked before the lock). S10B_HEAD..BASE must not touch prisma, any owned path or the contract; otherwise rebase the candidate first. The 29 FROZEN paths must carry their a2c74e90 blobs at BASE and their bytes in the working tree.
- **Owned paths.** There are 11 (REQUIRED_OWNED in the driver): 8 ` M` and 3 `??`. `observation.module.ts` is M because it has been tracked since S10-B. `test/rls-g2-s9c.spec.ts` was added per the parent's 22:34 mail. Generator-owner paths (`scripts/importer-contract.ts`, `test/contracts/importer-contract.spec.ts`) are allowed only if they are listed. The contract artifact must never be listed.
- **No prisma change.** The schema must equal the S10-B bytes d6d01f54, the prisma status must be empty, and there must be 173 migration dirs at BASE and in the working tree. The committed prisma delta must be empty and the migrations tree must equal BASE.
- **Client.** The donor is still the pre-S10-B client (9042e713). The in-clone `prisma generate` is forced. The post-gen client is compared with the S10-B gate's 2c819c8a/aca7a558, and the result is logged as `POSTGEN_MATCHES_S10B=yes|no`. It is recorded, not enforced, because `CLIENT_*=RECORD`.
- **Contract (D-S10-7).** The gate exports to scratch `$E/contract-regen.json`.
  - If the bytes are identical to BASE: `contract_state=unchanged`. The canonical file is untouched and is not in the delta.
  - If they differ: the scratch bytes are copied to `docs/contracts/importer-openapi.json` (`cat >`, keeping the mode), and the file joins the staged set: ` M`, mode 100644, blob checked. The log records `contract_state=changed` with numstat and added/removed paths.
  - In both cases the contract spec (drift check) runs after the decision, and the receipt records `contract_state=`, `blob=` and `sha256=`.
  - The JSON is `.prettierignore`d, so the hook's prettier skips it.
- **Targeted jest.** 7 suites: the 4 S10-C unit specs, observation.{service,controller}, and module-graph. Then the full default suite.
- **it() counts.** `test/rls-g2-s10b.spec.ts` must be 24 and `test/rls-g2-s10c.spec.ts` must be 8. Both are checked before the lock and again on the committed bytes. The receipt records `it_count … total=32`.
- **Commit line.** `NODE_OPTIONS=--max-old-space-size=4096 git commit -F <msg>`, set explicitly (the global export remains).
- **Carried unchanged from S10-B:**
  - symlink-aware hook refusal (`[ -e ] || [ -L ]`) and a plain `.git/hooks` dir;
  - every pin and shape check runs before the sentinel and the lock (prelock.log; a refusal does not consume the grant);
  - TERMINAL-exists refusal, and STARTED written with O_EXCL (`set -C`);
  - under-lock rechecks of HEAD, status, index, hooks, hooksPath and node_modules, plus owned **and FROZEN** bytes and the contract bytes;
  - no `cmd | grep -q`;
  - R75 early and staged;
  - one hooked Bradley commit, no push, no PG.

## Parent steps before relay
1. **Fetch BASE into the clone.** The clone has only a2c74e90; 384035ec and 711c1f8f are not present. Run `git -C /home/user/workspace/worktrees/d3a9-s10c fetch origin integration/importer`. Then move `exec-d3a9/s10c` onto the tip, keeping the working-tree changes: for example `git stash -u` → `git reset --hard <tip>` → `git stash pop`. Or use your usual method. The status must end as exactly the 11 owned entries.
2. **Set node_modules aside.** The clone currently has a real `node_modules` (717 MB, holding the S10-B-generated client), and the gate refuses it. Move it to `/home/user/workspace/execution/1910a060/runtime/set-aside/d3a9-s10c-node_modules-<ts>`; never delete it. **Disk:** `/` had 1.9 GB free at 22:30, and the `cp -a` donor copy needs about 0.72 GB. Moving within the same filesystem frees nothing.
3. **Hook set-aside.** Only needed if `.git/hooks/{pre-commit,commit-msg}` exist. They did not exist at 22:25, and core.hooksPath was unset.
4. **Fill help.** Run `bash s10c-gate-d3a9.sh --fill-help <tip sha>` (read-only). Paste its BASE / BASE_TREE / MIGRATIONS_TREE lines and its OWNED_PINS block into PINS.env. Check its report: `ancestor=yes/yes`, empty prisma delta, empty owned-overlap, 0 frozen mismatches, 173 dirs, no `EXTRA` status entries, and it() 24 / 8. Then re-hash `GATE.sha256`.
5. Relay:
```
S10C_GATE_RELAY=1 S10C_BASE=<tip sha> \
S10C_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
S10C_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s10c/gate/s10c-gate-d3a9.sh
```
Exit codes:
- 78: relay/pin refusal. 70: pre-lock or under-lock state refusal. 71: node_modules, generate or hooks. 72: prettier. 73: tsc, contract or jest. 74: R75 or eslint. 76: sentinel or commit. 75: lock busy.

## Assumptions the parent must verify
- **Harness base checks.** The bootstrap (`g2-s10b-bootstrap.sh` L151-159) requires that the prisma diff from a4af8e33 to the S10-C head is exactly the 3 S10-B files, and that package.json/package-lock.json are unchanged from a4af8e33. D1 (384035ec), S11-0 and S11-A1 must not touch prisma or package manifests. The gate refuses a prisma change S10B..BASE and a manifest-sha drift, and the binding re-checks against a4af8e33 before the lock.
- **Contract state is probably `unchanged`.** This was read, not run. `IMPORTER_BARE_PATHS` in `scripts/importer-contract.ts` L20-36 (not owned by S10-C) lists 15 routes. It does **not** include the ObservationModule routes `POST scout/runs/declaration` and `POST scout/runs/observation` (observation.controller.ts L63/L95/L137). Mounting the module therefore does not add paths to the importer slice. The artifact moves only if an already-listed route's schema changes, for example if a status DTO documents the new `'settled'` basis literal. The builder says there is no DTO field change.
- **Decision if the routes should be in the contract.** If D-S10-7 intends these routes to be in the contract, that means a generator-owner edit: `IMPORTER_BARE_PATHS` plus the `surface completeness` list in `test/contracts/importer-contract.spec.ts`. Those two paths must then be added to OWNED_PINS, since the gate allows them only if they are listed. Without that edit, the gate simply records `contract_state=unchanged`.
- **S9-C spec.** `test/rls-g2-s9c.spec.ts` is committed but not run by the gate (the rls specs are ignored by the default config) or by the binding. Its live proof is therefore not re-established by S10-C, per your 22:34 mail.

## Review fix B3 (s10c_gate_binding_review.md; diff: DELTA-review-fix.diff)
One guard line runs immediately before `git commit`. It re-asserts:
- `.git/hooks/pre-commit` and `.git/hooks/commit-msg` sha256 equal the post-install `HP`/`HC`, which the receipt's `hooks raw` line records and the binding pins;
- `core.hooksPath` is empty;
- `.git/hooks` is the plain dir, not a symlink, and both hook files are regular files.
If any check fails, the guard logs `HOOK_FAIL` and exits rc 71, before the commit.
