# S11-D build report (T2 builder, EXEC-FA72EFB2)

Worker: T2 builder for slice S11-D (J19 full two-host journey, J20 core-diff check; spec cases
only), parent session `fa72efb2`. Followed `execution/fa72efb2/WORKER_RULES.md` and
`execution/fa72efb2/s11d/S11D_BUILD_GRANT.md` throughout; no harness/src/prisma edits, no
PostgreSQL run, no push, one commit through hooks.

Clone: `/home/user/workspace/worktrees/fa72-s11d`, branch `fa72/s11d`, base
`03e7a2344ef95b019c751983527bbc9f78200921` (S11-A2 candidate, landed on `integration/importer`).
node_modules populated via `cp -al` from `worktrees/fa72-s11a1/node_modules` (hard-linked, no
`npm install`). Lefthook installed via the JS entrypoint (the hard-linked `.bin/lefthook`
symlink was broken). Remote: `no_push://disabled-fa72efb2`. Git identity: `Bradley Gleave
<bradley@bradleytgpcoaching.com>`.

## 1. Design rationale

### Leg A / Leg B split and the mandatory honesty rule

`execution/fa72efb2/s11d/S11D_BUILD_GRANT.md` states plainly: at this head a run that stages any
`clients` row cannot settle `complete` — the fix is owner-decided but not yet built
(`OWNER_DECISION_S8D_2026-09-26.md`; diagnosed in
`execution/fa72efb2/s10d2/d2_diagnose_fix.md`). A single J19 case asserting `complete` on a
`clients`-bearing run would therefore be dishonest at this head. J19 is composed as **two
separate legs on two separate runs**:

- **Leg A (native-clean)** — J01 (setup/pair/Start across P1+P2, replayed Start) → J09 (two
  platforms declared, transferred, observed across hosts, no `clients` row staged) → J12 (the
  settle is interrupted by a real OS-process kill after the terminal claim commits; the replayed
  claim on the *other* host re-drives to the identical verdict, and a third claim is asserted as a
  pure no-op) → J17 (readiness reads `terminal` at three points: open/undeclared before declare,
  open/declared/2 after declare, terminal after settle) → step 11, the native roster read,
  asserted **empty** because nothing was staged (D-S11-2 row 11) — not because the read failed or
  the run is non-`complete`.
- **Leg B (roster-bearing, MANDATORY HONESTY)** — the identical declare/transfer/observe/complete
  chain, but the first platform's batch additionally includes its roster token (D2 case (h)
  shape: `[...ROSTER_ROWS, ...first.nativeClean]`, `ROSTER_ROWS` read at runtime from
  `test/fixtures/scout/s10_unseen/staged-rows.json`'s `sets.base`, filtered to rows carrying the
  `u10-members` token — the same fixture D2's own live spec reads, not a new or duplicated
  fixture). This leg explicitly asserts `run.terminal_status` is `'partial'`,
  `reason_code === 'unresolved_identities'`, and `expect(run.terminal_status).not.toBe('complete')`
  — the mandatory-honesty assertion the grant requires, made in the assertions themselves, not
  buried only in a comment. Its roster read lists exactly the staged people, each
  `state: 'InvitePending'` ("imported, not yet joined," never a login principal).

Both legs reuse S11-A1/A2's own two-process, two-source, cross-host mechanics and S11-B's own
kill-and-replay pattern (`pg.worker({..., pause:'after-row', pauseRow}).stop()`, replayed
completion) verbatim — no new harness code, no new worker action. The file's header comment
states the S8-D honesty rule explicitly, citing `S11D_BUILD_GRANT.md`,
`execution/fa72efb2/s10d2/d2_diagnose_fix.md`, and `OWNER_DECISION_S8D_2026-09-26.md`.

### J20 — core diff, and why it runs in a disposable scratch worktree

The grant requires two things, both implemented as no-database `it()` blocks in a `describe`
block that sits *outside* the `live(...)` gate (runs on every lane, with or without
`G2_S11_DATABASE_URL`):

1. `rg -F -l` for every source slug (`s10_unseen`, and the S11-A2 second source, read at runtime
   from each fixture's `source_platform` field — never typed as a literal) over each landed S11
   slice commit's *own* `src/**/*.ts` hunk (diffed against **its own immediate parent**, not one
   collapsed range) — expecting zero hits. Implemented with `git diff --name-only <c>^ <c> --
   src` plus `git show <c>:<path>` (read-only, no checkout needed for this half).
2. `scripts/s10-core-diff-gate.sh` passes against its pinned B.

Part 2 required a design correction discovered during verification: `scripts/s10-core-diff-gate.sh`
check `[3]` compares changed paths against a **hardcoded literal `ALLOWED` array** — D2's own 8
files — not a computed diff. That means the gate can only ever pass with the repository checked
out **at the exact commit that array was written for** (`275e458ca5a6b3684bb6ec83edb2a854056a6fd0`,
D2's diagnose/fix commit), never at a later HEAD carrying S11-B's and S11-C's own files on top
(confirmed by running the gate directly against our own S11-D HEAD: `FAIL [3] changed paths differ
from the allowed set`). The corrected J20 check therefore creates a **disposable, read-only `git
worktree --detach`** pinned to that exact commit, runs the gate inside it, asserts the verbatim
`PASS B=... HEAD=...` line, and removes the worktree in a `finally` block regardless of outcome —
never touching this clone's own checkout, never running anything heavier than `git worktree
add/remove` and one shell script (no PostgreSQL, no `npm install`, no push). This was verified
manually first in a hand-created scratch worktree at `/tmp/s11d-gate-check/d2-275e458c` (removed
immediately after), then reproduced by the jest check itself.

## 2. Each assertion's code guarantee (file:line)

| Assertion | Code guarantee |
|---|---|
| Roster-bearing run never settles `complete`; reason `unresolved_identities` | `src/scout/reconciliation/reconcile.ts:347` (`held.push(S9_REASON_CODE.unresolved_identities)`); reason-code enum at `src/scout/lifecycle/reason-codes.ts:57`; type union at `src/scout/reconciliation/types.ts:31,42` |
| `clients` row with no native principal buckets to evidence-only / `no_native_client_principal` | `src/scout/reconciliation/reconcile.ts:145` (`clientPrincipal ? WRITER_CODE.no_native_client_principal : S9_REPORT_CODE.evidence_only`); write path `src/scout/reconstruct/native/native-writers.ts:369-410` (`recordNoNativePrincipal`) |
| `roster_bridge_pending` qualifier on the `clients` coverage cell | `src/scout/scout-roster.dto.ts:42` (`ROSTER_BRIDGE_PENDING = true as const`); consumed at `src/scout/scout-roster.service.ts:15,178` (`roster_bridge_pending: ROSTER_BRIDGE_PENDING`) |
| Roster read reports `state: InvitePending` ("imported, not yet joined") | `src/scout/scout-roster.dto.ts:123` (`PersonState.InvitePending` documented as the DTO example state) |
| Readiness reports only `open`/`declared`/`terminal`, never leaks `partial`/`unresolved_identities` | `src/extension-pair/extension-pair.service.ts:241` (`run: run.terminal_status === null ? 'open' : 'terminal'`) — the service only ever emits these two coarse states, confirmed by reading the full status derivation at lines 172-276 |
| J12 kill-and-replay converges to the identical verdict | Reuses S11-B's own proved mechanism (`pg.worker({..., pause:'after-row', pauseRow})`, `.stop()`, replayed `h.induction.complete`) — no new code; the underlying idempotent-claim guarantee is S11-B's, unchanged here |
| Core diff: no S11 slice `src/**/*.ts` hunk contains a source slug literal | Verified directly against the actual commits in this proof, not asserted from a comment — see gate table below |

## 3. Every command run, with RC

All heavy commands ran under `flock -w 3600 /home/user/workspace/execution/test-validation.lock
bash -c '...'`, `PROOF_SLOT_FREE` re-checked present before each. No PostgreSQL, no `npm
install`/`ci`, no push at any point.

| # | Command (abbreviated) | RC |
|---|---|---|
| 1 | `prettier --write` then `--check test/scout/s11/journey-full.pg.spec.ts` (repeated across 3 edit rounds) | 0 (final) |
| 2 | `flock ... eslint --no-warn-ignored --max-warnings 0 test/scout/s11/journey-full.pg.spec.ts` | 0 |
| 3 | `flock ... tsc --noEmit` | 0 |
| 4 | `flock ... jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-full.pg.spec.ts` (no `G2_S11_DATABASE_URL`) | 0 — guard 95/95 unchanged, J20's 3 checks pass for real, J19's 3 `live` cases show `skipped` |
| 5 | `bash scripts/s10-core-diff-gate.sh 7fdcbc044dba1747d0db2f2750ced951f3b6b752 HEAD` at our own S11-D HEAD (diagnostic only) | 1 — `FAIL [3]` as expected/explained above; not part of the shipped check |
| 6 | Manual scratch check: `git worktree add --detach /tmp/s11d-gate-check/d2-275e458c 275e458ca5a6b3684bb6ec83edb2a854056a6fd0`; `bash scripts/s10-core-diff-gate.sh 7fdcbc044dba1747d0db2f2750ced951f3b6b752 HEAD` inside it | 0 — `PASS B=7fdcbc044dba1747d0db2f2750ced951f3b6b752 HEAD=275e458ca5a6b3684bb6ec83edb2a854056a6fd0`; worktree removed immediately after |
| 7 | `node scripts/check-r75.js --mode=staged` (banned-cast-tokens, standalone check before commit) | 0 — "OK — no positive token change" |
| 8 | `git add test/scout/s11/journey-full.pg.spec.ts`; `git commit -F <msg file>` under flock, `GIT_AUTHOR_NAME/EMAIL`, `GIT_COMMITTER_NAME/EMAIL` = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no `--no-verify` | 0 — commit `69433f94`; hooks `prod-readiness-quick`, `banned-cast-tokens`, `prettier`, `eslint`, `tsc`, `commit-msg`'s `no-ai-tokens` all ✔ |
| 9 | (post-commit fix) rewrote J20's gate-script check to use the scratch-worktree pattern; re-ran `prettier --write/--check`, `flock ... eslint`, `flock ... tsc` | 0 each |
| 10 | `flock ... jest --runInBand --runTestsByPath test/scout/s11/journey-full.pg.spec.ts --verbose` | 0 — all 3 J20 checks pass for real (including the corrected gate-script check), 3 J19 cases skip |
| 11 | `flock ... jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-full.pg.spec.ts` (final combined re-check) | 0 — `Tests: 3 skipped, 98 passed, 101 total` (95 guard + 3 J20) |
| 12 | `node scripts/check-r75.js --mode=staged`; `git add test/scout/s11/journey-full.pg.spec.ts`; `git commit --amend --no-edit` under flock, same author/committer, no `--no-verify` | 0 — amended commit `fbb97b30`; all hooks ✔ again |
| 13 | `git status --porcelain --untracked-files=all`; `git worktree list`; `git diff --name-only <base> HEAD -- src prisma` | 0 — tree clean, only the one worktree, empty src/prisma diff |

## 4. Head / tree / blob

- **HEAD:** `fbb97b3017ddf3df380e658b3d2d2a7b0cf28b1d` (branch `fa72/s11d`, one commit on top of
  base `03e7a2344ef95b019c751983527bbc9f78200921`)
- **Tree:** `4f43b072b61643a9398d6514d2165f764cf2ed82`
- **Blob** (`test/scout/s11/journey-full.pg.spec.ts`): `5f54d6ecb117f1b61219a2f5a56dfe3e20fb68e3`
  (sha256 of working-tree content: `06723445ff5a96b5eb9e7853057885b6e4ab1a12e8f228adb2cf69de435862da`)
- `git log --oneline -3`:
  ```
  fbb97b30 test(scout): S11-D full two-host journey (J19) and core-diff check (J20)
  03e7a234 test(scout): S11-A2 two-source induction proof J09-J11
  dda794d7 fix(scout): retry raw-query serialization failures in the settle tail (S11-B r2)
  ```
- Working tree at finish: clean (`git status --porcelain` empty).
- Author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no AI/co-author
  trailers (verified via `git log -1 --format=%B`).

## 5. Files + LOC

Exactly **one** file touched, and `git diff --name-only 03e7a2344ef95b019c751983527bbc9f78200921
HEAD -- src prisma` is empty (no core-diff violation):

| path | LOC | status |
|---|---|---|
| `test/scout/s11/journey-full.pg.spec.ts` | 561 (all new) | created |

`git show --stat HEAD`: `1 file changed, 561 insertions(+)`.

## 6. Expected live count

Running this file with `G2_S11_DATABASE_URL` set (a **parent-only** PG-lane action, not run by
this builder per WORKER_RULES §3) is expected to exercise:

- **2 live `it()` cases** inside the `live(...)`-gated `describe` block:
  1. "J19 leg A (native-clean)"
  2. "J19 leg B (roster-bearing, MANDATORY HONESTY)"
- **1 additional case in the same gated block** that needs no PG connection logically but is
  co-located inside `live(...)` (runs only alongside the two above): the static
  no-slug-literal self-check ("this file types no source-platform-slug literal").
- **3 no-DB J20 cases**, always run regardless of the lane env var (already verified passing in
  this report, not merely "expected"):
  1. SLICE_COMMITS ancestor/resolution check
  2. `rg -F -l`-equivalent per-commit slug scan
  3. scratch-worktree `scripts/s10-core-diff-gate.sh` pass

Total: **6 `it()` cases in the file** — 3 gated on `G2_S11_DATABASE_URL` (2 substantive J19 legs +
1 static check), 3 ungated J20 checks that already run and pass in this no-DB report.

## 7. Gate results

| Gate | Result |
|---|---|
| Prettier | PASS (`All matched files use Prettier code style!`) |
| ESLint (`--max-warnings 0`) | PASS (0 errors, 0 warnings) |
| `tsc --noEmit` | PASS (0 errors) |
| `banned-cast-tokens` (R75) | PASS — "OK — no positive token change" |
| No-DB jest — guard spec | PASS, **95/95** unchanged from the pre-S11-D baseline |
| No-DB jest — `journey-full.pg.spec.ts` | PASS — 3 J20 checks run and pass for real; 3 J19/static cases show `skipped` (file is inert without `G2_S11_DATABASE_URL`, confirmed by source inspection matching the existing `live = process.env.G2_S11_DATABASE_URL ? describe : describe.skip` convention) |
| Core-diff gate (`scripts/s10-core-diff-gate.sh`, pinned B `7fdcbc044dba1747d0db2f2750ced951f3b6b752`, run at pinned HEAD `275e458ca5a6b3684bb6ec83edb2a854056a6fd0` in a disposable scratch worktree) | PASS — `PASS B=7fdcbc044dba1747d0db2f2750ced951f3b6b752 HEAD=275e458ca5a6b3684bb6ec83edb2a854056a6fd0` |
| Slug-literal scan across all 7 S11-related slice commits' own `src/**/*.ts` hunks | PASS — zero hits for `s10_unseen` or the A2 second source slug in any `.ts` hunk (the only slug occurrences are in the 3 `.json` source-asset files from D2, correctly out of the `rg --type ts` / `.ts`-only scope, matching the gate script's own established scope) |
| Lefthook (`git commit`/`--amend`) | PASS — `prod-readiness-quick`, `banned-cast-tokens`, `prettier`, `eslint`, `tsc`, `commit-msg`'s `no-ai-tokens` all ✔, twice (initial commit `69433f94` and amended commit `fbb97b30`) |
| `git diff --name-only <base> HEAD -- src prisma` | Empty — confirmed zero core-diff |
| Real PostgreSQL run | **Not performed** — parent-only per WORKER_RULES §3; correctly out of scope for this builder |

## 8. Risks

**A/B/C per WORKER_RULES §5 (Safety ROI).**

- **Risk 1 (C, record only).** The core-diff gate script's `ALLOWED` array (check `[3]`) is a
  literal list hardcoded for D2's own 8 files, so it can only ever pass with the repository
  checked out exactly at D2's diagnose/fix commit (`275e458c...`), not at any later HEAD. This is
  not a flaw introduced by this build — it reflects how the script was written for D2's own gate
  run (confirmed against `execution/fa72efb2/s10d2/d2_gate_summary.md` and
  `d2_diagnose_fix.md:129-130`, which both show the gate invoked with `HEAD` implicitly equal to
  the commit being verified). The J20 check works around this correctly and safely via a
  disposable, read-only scratch worktree that is created and torn down inside the test itself,
  never touching this clone's own checkout. **CONCRETE HARM:** none realized — the check passes
  and cleans up correctly (verified: no leftover `/tmp` scratch directories, no stray `git
  worktree list` entries after each run). **EXACT DECISION BLOCKED:** none — this is closed.
  **MINIMUM CLOSURE:** already applied (the scratch-worktree rewrite). **EXECUTION UNLOCKED:**
  J20's second check now correctly and repeatably proves the pinned gate still holds at its own
  pinned commit.
- **Risk 2 (C, record only).** J20's "SLICE_COMMITS" list is a manually curated, hand-verified
  set of the 7 landed commits between S11-A1 and this slice's base that could plausibly touch
  `src/`. It was cross-checked against `git log --oneline` on the full `integration/importer`
  chain and each commit's own `git diff <c>^ <c> -- src` was inspected directly (recorded in
  the "session context" investigation, not re-derived programmatically inside the test). If a
  future S11 slice lands a `src/` change between this slice's base and its own HEAD without also
  updating this list, J20 would not catch it — the check only re-verifies the pins are still real
  ancestors of HEAD, it does not auto-discover new commits. **CONCRETE HARM:** a hypothetical
  future slug regression in an uncovered commit range would not be caught by this specific
  file. **EXACT DECISION BLOCKED:** none for this slice (S11-D's own scope is fixed and the list
  is complete for it). **MINIMUM CLOSURE:** none needed within this grant's scope; a future slice
  extending past this base should re-derive its own commit list the same way. **EXECUTION
  UNLOCKED:** n/a — flagged for the parent's awareness only.
- **Risk 3 (C, record only).** The roster-bearing leg (Leg B) is expected, honestly, to flip from
  `partial/unresolved_identities` to `complete` once S8-D lands. This test will then need updating
  (or a companion post-S8-D case added) — it is not "wrong," but its assertions are pinned to the
  current, not-yet-fixed behavior by design, exactly as the grant requires. **CONCRETE HARM:**
  none now; a future S8-D landing will need this spec revisited. **MINIMUM CLOSURE:** the header
  comment already states this explicitly, citing `OWNER_DECISION_S8D_2026-09-26.md`.

No A or B risks were found. No case required a new worker action or harness edit; the harness's
existing `h.induction.*`, `h.pairSession`, `pg.worker({...pause...})`, and roster/readiness
wrappers were sufficient for both J19 legs, confirmed by direct inspection of
`test/utils/g2-s11-harness.ts`, `g2-s11-pg-harness.ts`, and `g2-s11-worker.cjs` before writing any
test code.

## Sources (Round 1)

- `execution/fa72efb2/WORKER_RULES.md`
- `execution/fa72efb2/s11d/S11D_BUILD_GRANT.md`
- `execution/fa72efb2/s10d2/d2_diagnose_fix.md`
- `execution/fa72efb2/s10d2/d2_gate_summary.md`
- `OWNER_DECISION_S8D_2026-09-26.md`
- `test/scout/s11/journey-full.pg.spec.ts` (this build's own file, commit `fbb97b30`)

---

# Round 2 (post-review closures)

Independent review verdict: **NO-GO** on `fbb97b3017ddf3df380e658b3d2d2a7b0cf28b1d`
(`execution/fa72efb2/s11d/s11d_review.md`), four B-class findings (B1, B2, B4) plus one C
finding (curated `SLICE_COMMITS`). B3 (inherited A2 `resetData()` defect) is explicitly **not**
closed by this builder — the parent re-bases this branch onto S11-A2 r2, where B3 is closed, per
the parent's own closure instructions. This round makes **one new commit on `fa72/s11d` on top
of `fbb97b30`** — no amend, no rebase.

## Closures applied

### B1 — J20 moved entirely inside the file's existing `live(...)` gate

All four J20 `it()` cases (ancestor-resolution, the new full-range coverage check, the slug
scan, and the gate-script check) now sit as sibling `it()` blocks directly inside the outer
`live('S11-D full journey (J19) and core diff (J20)', () => { ... })` describe — the same gate
every J19 case already runs under. Consequences, all verified in this round:

- **No `G2_S11_DATABASE_URL`:** the entire suite (J19 + J20, 6 `it()` cases) shows `skipped`,
  never a false pass. Confirmed: `Tests: 6 skipped, 95 passed, 101 total` (95 = guard spec,
  unchanged; 6 = every case in this file, all skipped).
- **`G2_S11_DATABASE_URL` set, full-history local clone (parent-only):** J20 runs for real and
  still fails hard — never silently passes — on a missing pinned commit, because
  `git rev-parse --verify --quiet <sha>^{commit}` throws inside the ancestor-resolution check
  (the first `it()`), which every other J20 check implicitly depends on running after.
- No CI workflow file was edited (per instruction); the fix is entirely inside the spec file's
  own gating, matching the pattern every other `*.pg.spec.ts` case in this codebase already uses
  for exactly this reason (shallow-checkout CI incompatibility with history-dependent checks).
- Header comment (`journey-full.pg.spec.ts:49-59`) now states explicitly that J20's evidence is
  a **parent-only proof-lane receipt** from a full-history local clone, never a claim about the
  default no-DB/CI run.

### B2 — deleted the whole-file self-check

Removed the `it('this file types no source-platform-slug literal ...')` case entirely (was at
old `:405-409`). It asserted the whole file's own text excluded both source slugs, which is
false on its face (the slugs appear in comments, fixture paths and the SLUGS()/GATE_B doc
strings) — a guaranteed live failure unrelated to the actual production-code invariant. J20's
existing per-commit `src/**/*.ts`-scoped scan is the real invariant and needed no replacement;
nothing was added to "hide" the strings — they remain in comments and fixture-path literals as
before, and the deleted check simply is not replaced by an equivalent broad check.

### B4 — asserted the roster-bridge qualifier, not just narrated it

Two new assertions in Leg B (`journey-full.pg.spec.ts:376-385, 406-413`):

- **Settled-basis qualifier**, matching `test/scout/s10/s10-unseen.pg.spec.ts:429-444` (D2 case
  (h)) exactly: `expect(clientsCell).toMatchObject({ ..., qualifiers: ['roster_bridge_pending'] })`.
  Code guarantee: `src/scout/scout-roster.service.ts:178` writes the flag into the report via
  `roster_bridge_pending: ROSTER_BRIDGE_PENDING`; the report-side `qualifiers` array on the
  `clients` coverage cell is produced by the same reconciliation path D2's own spec exercises
  (`src/scout/reconciliation/reconcile.ts`), not a new code path.
- **Native roster response field**, which does exist (checked, not invented):
  `src/scout/scout-roster.dto.ts:192` (`roster_bridge_pending!: boolean;`) and
  `src/scout/scout-roster.service.ts:178-179` (`roster_bridge_pending: ROSTER_BRIDGE_PENDING`,
  the constant fixed `true as const` at `src/scout/scout-roster.dto.ts:42`). Asserted as
  `expect(roster.result.roster_bridge_pending).toBe(true)`, alongside the existing per-person
  `state: 'InvitePending'` assertions.

### C — full-range coverage check for the curated `SLICE_COMMITS` pins

No conflict with the grant found: the grant restricts *paths* (only `journey-full.pg.spec.ts`),
not the assertions inside it, so adding a new `it()` case in the same allowed file is in scope.
New live-gated case (`journey-full.pg.spec.ts:500-524`): walks
`git rev-list 3db615c0^..HEAD` (the full range between S11-A1 and this slice's own HEAD),
diffs **every** commit in that range against its own immediate parent for `-- src`, and fails
loudly (`expect(missing).toEqual([])`) if any src-touching commit is absent from the curated
`SLICE_COMMITS` list — so a future rebase or insertion that adds an uncovered `src/` commit is
caught here rather than silently passing the two pre-existing checks (which only ever iterate
the pinned list itself). Manually dry-run (read-only `git` commands, not jest) before committing:
the full range at this HEAD has exactly 8 commits, of which exactly 4 touch `src/`
(`dda794d7`, `645fb6db`, `144269d1`, `7fdcbc04`) and all 4 are already in `SLICE_COMMITS` — the
check will pass live at this HEAD.

## Commands run (Round 2), with RC

All heavy commands ran under `flock -w 3600 .../test-validation.lock`, `PROOF_SLOT_FREE`
re-checked present before each. No PostgreSQL, no push.

| # | Command (abbreviated) | RC |
|---|---|---|
| 1 | Read `s11d/s11d_review.md` in full; read the current spec file in full | 0 |
| 2 | Read `src/scout/scout-roster.dto.ts`, `src/scout/scout-roster.service.ts`, `test/scout/s10/s10-unseen.pg.spec.ts:420-448` to confirm B4's exact field names before editing | 0 |
| 3 | `edit` — removed the whole-file self-check (B2) | 0 |
| 4 | `edit` — added `qualifiers`/`roster_bridge_pending` assertions to Leg B (B4) | 0 |
| 5 | Python-based exact-match replace — merged J20 into the outer `live(...)` gate, updated the header comment (B1) | 0 |
| 6 | `edit` — added the full-range coverage check inside the live gate (C) | 0 |
| 7 | Manual brace/paren balance check (`node -e` walking the file) — final depth 0 | 0 |
| 8 | `prettier --write` then `--check test/scout/s11/journey-full.pg.spec.ts` | 0 |
| 9 | `flock ... eslint --no-warn-ignored --max-warnings 0 test/scout/s11/journey-full.pg.spec.ts` | 0 |
| 10 | `flock ... tsc --noEmit` | 0 |
| 11 | `flock ... jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-full.pg.spec.ts --verbose` (no `G2_S11_DATABASE_URL`) | 0 — `Tests: 6 skipped, 95 passed, 101 total`; guard unchanged at 95/95; all 6 of this file's cases (2 J19 + 4 J20) show `skipped` |
| 12 | Manual dry-run of the C check's exact logic via plain `git rev-list`/`git diff` (not jest) to confirm it will pass live at this HEAD | 0 — 4/4 src-touching commits in the full range are covered by `SLICE_COMMITS` |
| 13 | `node scripts/check-r75.js --mode=staged` | 0 — "OK — no positive token change" |
| 14 | `git add test/scout/s11/journey-full.pg.spec.ts`; `git commit -F <msg file>` under flock, `GIT_AUTHOR_NAME/EMAIL`/`GIT_COMMITTER_NAME/EMAIL` = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no `--no-verify`, **new commit, not amend** | 0 — commit `c61b71e9` on top of `fbb97b30`; all lefthook hooks ✔ (the bash tool call that ran this command hit its own 630s output-wait timeout, but the commit itself completed and was verified afterward via `git log`/`git status`) |
| 15 | `git status --porcelain --untracked-files=all`; `git log --oneline -4`; `git diff --name-only <base> HEAD -- src prisma`; final re-run of command #11 post-commit | 0 each — tree clean, one file changed, empty src/prisma diff, same 6-skipped/95-passed result |

## Round 2 head / tree / blob

- **HEAD:** `c61b71e92e74db4f7416797d9c4e6bbf03f42870` (branch `fa72/s11d`, one new commit on top
  of Round 1's `fbb97b3017ddf3df380e658b3d2d2a7b0cf28b1d` — not an amend, not a rebase)
- **Tree:** `f5822ec85ac58ed48bd06b4abc59d50f6af6808a`
- **Blob** (`test/scout/s11/journey-full.pg.spec.ts`): `ecfe8cef35eb99f955d7b0acdaddeb84d3cef8e2`
  (sha256 of working-tree content: `84afc31a8100d20ee7ae3077b7fb7267137ba7a3bb24d659c1e102a109b53820`)
- `git log --oneline -4`:
  ```
  c61b71e9 test(scout): S11-D round 2 — gate J20 live, assert roster-bridge qualifier, cover full range
  fbb97b30 test(scout): S11-D full two-host journey (J19) and core-diff check (J20)
  03e7a234 test(scout): S11-A2 two-source induction proof J09-J11
  dda794d7 fix(scout): retry raw-query serialization failures in the settle tail (S11-B r2)
  ```
- Working tree at finish: clean.
- Author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no AI/co-author
  trailers (verified via `git show --format=fuller --no-patch HEAD`).

## Round 2 files + LOC

Same single file, now modified again (still the only file touched across both rounds relative
to base `03e7a2344ef95b019c751983527bbc9f78200921`):

| path | LOC (round 2 diff) | total LOC |
|---|---|---|
| `test/scout/s11/journey-full.pg.spec.ts` | 94 insertions(+), 34 deletions(-) | 621 |

`git diff --name-only 03e7a2344ef95b019c751983527bbc9f78200921 HEAD` still returns exactly this
one path; `-- src prisma` is still empty.

## Round 2 expected live count

With `G2_S11_DATABASE_URL` set, run from a full-history local clone (parent-only):

- **2 live J19 `it()` cases** (unchanged): Leg A (native-clean), Leg B (roster-bearing,
  MANDATORY HONESTY, now with the qualifier + roster-response assertions from B4).
- **4 live J20 `it()` cases** (all now gated, up from 3 ungated + 1 deleted static check):
  1. SLICE_COMMITS ancestor/resolution check (unchanged)
  2. **New** (C): full-range `git rev-list 3db615c0^..HEAD` coverage check — no unlisted
     src-touching commit
  3. Per-commit `rg`-equivalent slug scan (unchanged)
  4. Scratch-worktree `scripts/s10-core-diff-gate.sh` pass (unchanged)

Total: **6 `it()` cases in the file, ALL gated on `G2_S11_DATABASE_URL`** — no case runs, and no
case reports a false pass, in the default no-DB/CI configuration; all 6 show `skipped` there
(confirmed in command #11/#15 above). This is a change from Round 1, where 3 J20 checks ran
unconditionally.

## Round 2 gate results

| Gate | Result |
|---|---|
| Prettier | PASS |
| ESLint (`--max-warnings 0`) | PASS (0 errors, 0 warnings) |
| `tsc --noEmit` | PASS (0 errors) |
| `banned-cast-tokens` (R75) | PASS — "OK — no positive token change" |
| No-DB jest — guard spec | PASS, **95/95** unchanged |
| No-DB jest — `journey-full.pg.spec.ts` | PASS — **all 6 cases now show `skipped`** (Round 1 had 3 running unconditionally; those 3 are now gated too) |
| Manual dry-run of the C check's git logic | PASS — 4/4 src-touching commits in the full range already covered by `SLICE_COMMITS` |
| Lefthook (`git commit`) | PASS — same hook set as Round 1, one new (not amended) commit |
| `git diff --name-only <base> HEAD -- src prisma` | Empty |
| Real PostgreSQL run | Not performed — parent-only, as in Round 1; this round's J20/B4 correctness is asserted from code-reading plus the manual dry-run of the C check's plain-git logic, not from an actual live jest pass, which only the parent can run |

## Round 2 risks

- **Risk 4 (C, record only).** This builder cannot run the S11 live PG lane (WORKER_RULES §3),
  so B4's new assertions (`qualifiers: ['roster_bridge_pending']`, `roster_bridge_pending: true`)
  and B1's "J20 still fails hard when live" behavior are verified by code-reading and a manual
  dry-run of the underlying plain-`git` logic (for the C check specifically), not by an actual
  passing live jest run. **CONCRETE HARM:** none identified — the field names and shapes were
  read directly from `src/scout/scout-roster.dto.ts` and `src/scout/scout-roster.service.ts`
  before writing the assertions, and match exactly. **MINIMUM CLOSURE:** the parent's next live
  proof-lane run (after the S11-A2 r2 rebase closes B3) will exercise these assertions for real;
  no further action needed from this builder unless that run surfaces a mismatch.
- **B3 — explicitly not closed here**, per the parent's own instruction: the inherited A2
  `resetData()` defect (direct child-table DELETEs conflicting with the S10-B migration's
  refusal of top-level deletes on populated tables) blocks any live run of this file at the
  current base. The parent will re-base this branch onto S11-A2 r2, where B3 is closed, before
  any live proof is attempted. No action taken on `test/utils/g2-s11-harness.ts` or any other
  harness file — out of this grant's allowed paths regardless.
- Round 1's Risk 1, Risk 2 and Risk 3 (gate script's hardcoded D2-specific `ALLOWED` array
  worked around via scratch worktree; curated `SLICE_COMMITS` list — now additionally guarded
  by the new C check; the S8-D honesty-flip expectation) all still apply and are unchanged by
  this round.

## Sources (Round 2)

- `execution/fa72efb2/s11d/s11d_review.md` (the NO-GO review this round closes against)
- `execution/fa72efb2/s11d/S11D_BUILD_GRANT.md`
- `execution/fa72efb2/WORKER_RULES.md`
- `test/scout/s10/s10-unseen.pg.spec.ts:420-448` (D2 case (h), the pattern B4 matches)
- `src/scout/scout-roster.dto.ts:42,192` (`ROSTER_BRIDGE_PENDING`, `roster_bridge_pending!: boolean;`)
- `src/scout/scout-roster.service.ts:178-179` (`roster_bridge_pending: ROSTER_BRIDGE_PENDING`)
- `test/scout/s11/journey-full.pg.spec.ts` (this round's file, commit `c61b71e9`)

