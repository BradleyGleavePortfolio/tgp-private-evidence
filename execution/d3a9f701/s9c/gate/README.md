# S9-C gate (EXEC-D3A9F701) — source only, NOT RUN

Derived step-for-step from the accepted S9-B gate `execution/1910a060/s9b/gate/s9b-gate-1910.sh` (+ its PINS.env / README).
The R75 working-tree call without `--mode` stays removed; R75 runs only as `--mode=staged` after staging.

## Files
| file | purpose |
|---|---|
| `s9c-gate-d3a9.sh` | driver (755; `bash -n` OK) |
| `PINS.env` | every pin; owned-file shas are `__FILL_*__` (parent fills after the fix round freezes) |
| `commit-message.txt` | D-S9-8 commit message (subject 70 chars; R3 regex + no trailers checked by the driver) |

## Relay command (parent only)
```
S9C_GATE_RELAY=1 S9C_BASE=5407efae319fd913e973c87f3be0d49786c4a3e0 \
S9C_DONOR=/home/user/workspace/worktrees/1910a060-s8f/node_modules \
S9C_PRETTIER_PREFIX=/home/user/workspace/execution/1910a060/runtime/tools/prettier-3.9.9 \
timeout -k 30 7200 bash /home/user/workspace/tgp-private-evidence/execution/d3a9f701/s9c/gate/s9c-gate-d3a9.sh
```
Clone required: `W=/home/user/workspace/worktrees/d3a9-s9c-r2`, branch `exec-d3a9/s9c-r2`, HEAD = BASE 5407efae (tree 3e2028e9), no
`node_modules`, no `.git/hooks/{pre-commit,commit-msg}`, no `core.hooksPath`, index clean, and `git status --porcelain
--untracked-files=all` exactly = OWNED_PINS (` M` for state M, `??` for state N) + ` M docs/decisions/2026-09-25-s9-reconciliation.md`.

## Steps (same order/refusal semantics as S9-B)
relay + one-shot STARTED sentinel -> nonblocking `flock -n` fd9 on test-validation.lock (inode 692282 == PINS == d3a9f701/runtime/LOCK_ESTABLISHED.txt)
-> preconditions (HEAD/branch/tree, exact status set, owned shas + modes, doc = BASE bytes as byte prefix + `+DOC_ADDED_LINES/-0`,
the S9-B paths (`git diff --name-only 9497ca52 1e6e5735` = 11; the 10 non-doc paths pinned in S9B_PINS, the doc owned here) tracked+clean at their pinned bytes, S9-A files tracked+clean, prisma
unchanged, schema/lockfile pins, 172 migration dirs + last = 20270123000000_scout_run_lifecycle_expand matching g2-s9c-pg-harness.ts,
`[ ! -e node_modules ]`, no hooks) -> `cp -a` donor node_modules (NM lock 05bc530a…, client index.d.ts 9042e713…, schema b8439203…)
-> lefthook 2.1.9 install + path-normalized hook compare with 1910a060-s8f -> verified prettier 3.9.9 prefix
-> **copy every owned file to `preformat/`** -> prettier check, then `--write` on OWNED non-.sh paths only -> doc prefix re-check
-> **POSTFORMAT shas recorded** (`postformat/`, SHA256SUMS) -> eslint (owned .ts/.cjs) -> `tsc --noEmit` (heap 4096)
-> **NEW: `npm run -s contract:importer`**, then docs/contracts/importer-openapi.json byte-unchanged (cmp before/after) and
`test/contracts/importer-contract.spec.ts` run -> targeted jest (`--ci --runTestsByPath $SUITES`, 14 suites, count asserted)
-> full default jest once -> stage exactly the owned paths (index == STAGED_EXPECT, 755 modes as `100755`) -> R75 `--mode=staged`
-> one genuine hooked commit as Bradley Gleave <bradley@bradleytgpcoaching.com> (no trailers) -> committed tree == staged tree,
forbidden-delta check -> receipts `HEAD-<12>.txt` (`blob <path> <blobsha> sha256=<sha>` lines), patch, name-status manifest -> release.

`--runTestsByPath` is required: `src/scout/scout.service.spec.ts` is outside the default jest roots (devloop-3 used the same form:
14 suites / 551 tests passed).

## Exit codes
78 relay / pins unfilled or inconsistent (before lock; grant not consumed) · 76 sentinel present / commit / delta · 75 lock ·
70 preconditions / staging · 71 node_modules / hooks / prettier prefix · 72 prettier / preformat · 74 eslint / R75 ·
73 tsc / contract regen / jest.

## Parent must fill in PINS.env (driver refuses 78 while any is `__FILL_*__`)
- `OWNED_PINS`: sha256 of each owned file at the frozen fix-round bytes (format `<sha> <mode> <M|N> <path>`).
  The r2 clone (02:26Z) also shows ` M src/scout/reconstruct/native/native-rules.ts` and `?? src/scout/lifecycle/reason-domains.ts`
  (not in freeze-1). If they are part of the fix round, add both lines; native-rules.ts is under the forbidden prefix
  `src/scout/reconstruct`, so it also needs `FORBIDDEN_EXCEPTIONS='src/scout/reconstruct/native/native-rules.ts'` and a reviewer
  disposition against D-S9-8 (not owned). Without the exception the driver refuses 78 at relay.
- `SHA_CONTRACT_JSON` (must equal the importer-openapi.json OWNED_PINS sha), `DOC_ADDED_LINES`, `SHA_DOC_ADDENDUM`.

## Dry checks done (no lock, no npm/jest/tsc/prettier)
- `bash -n` OK; unset relay -> 78; unfilled pins -> 78; native-rules.ts owned without exception -> 78; with exception -> reaches lock stage.
- A `/tmp` copy with the lock step removed and doc checks stubbed (doc not yet modified in r2), pins filled from the current r2 bytes,
  ran the precondition block read-only (`GIT_OPTIONAL_LOCKS=0`) against r2 -> `DRY_PRECONDITIONS_OK`.
