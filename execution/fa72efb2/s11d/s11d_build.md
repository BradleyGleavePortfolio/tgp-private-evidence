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


---

# Round 3 (real-PG proof v1 diagnosis)

Real-PG proof v1 (`s11d/PROOF_V1_FINDING.md`) ran candidate `a52d20d6` (Round 2's commit,
mis-titled in that finding as `fbb97b30`'s successor — the actual candidate committed was Round
2's `c61b71e9` from `worktrees/fa72-s11d`, re-based by the parent onto the S11-A2 r2 base
`54be96f1` inside the new standalone clone `worktrees/fa72-s11d2` as `a52d20d6` on top of
`38d0d366`) against a full-history local clone. Result: **J20 passed 4/4 live**; **J19 leg A and
leg B both failed**. Classification per the finding: B (candidate spec defects; no product
finding implied). This round diagnoses and fixes both, working in `worktrees/fa72-s11d2` on
branch `fa72/s11d-r2`, **one new commit on top of `38d0d366`** — no amend, no rebase.
`worktrees/fa72-s11d` (Round 1/2's worktree) was not touched this round, per the parent's
instruction.

## Diagnosis

### Leg A — `redrive.pushes` expected 1, received 0 (`journey-full.pg.spec.ts:270`)

**Root cause**: the assertion encoded a wrong assumption about the product's re-drive contract,
never checked against a live-passing precedent before Round 1/2.

- `src/scout/scout.service.ts:369-371` (the docblock immediately above `completeServerRun`)
  states explicitly: "the stored claim stays the arbiter input, and **the push and analytics
  event stay first-claim-only**."
- The code enforces this exactly: the P2002 branch at `src/scout/scout.service.ts:407-412`
  (taken when a second claim hits the ledger's unique constraint because the first claim already
  committed — the G1 re-drive path) calls `this.lifecycle.onTransferSettled(...)` directly and
  never calls `notifyComplete` or `analytics.capture`. Those two calls only happen on the
  **first-claim** success path at lines 415-419, which the interrupted worker never reached
  because it was killed before getting there.
- The precedent that already exercises this exact shape live and passes:
  `test/scout/s11/settle-redrive.pg.spec.ts:263-266` — the `J12 (G1)` case calls
  `expectNoClaimSideEffects(replay)` on the winning re-drive claim, and that helper
  (`settle-redrive.pg.spec.ts:231-235`) asserts `expect(r.pushes).toBe(0)` and
  `expect(r.pushCalls).toEqual([])`. Every other G1/re-drive case in that file
  (`J12 edge`, `J13`, `J14`) asserts the same `expectNoClaimSideEffects` on its own replay.
- **Fix**: `journey-full.pg.spec.ts:270` (now further down after the added comment) changed from
  `expect(redrive.pushes).toBe(1)` to `expect(redrive.pushes).toBe(0)`, with a comment citing
  both the service docblock and the precedent spec's line numbers. `redrive.queries.filter(
  isTerminal)).toHaveLength(1)` was already correct and unchanged — the terminal write still
  happens exactly once, only the notification/analytics side effects are absent.
- No product change; this is a genuine spec defect fixed by aligning with documented,
  live-verified behavior. **Not a product finding.**

### Leg B — `report.coverage` undefined (`journey-full.pg.spec.ts:157` via `:376`)

**Root cause**: a field-name mismatch. The local `Report`/`byFamily`/`coverage` helpers
(originally at `journey-full.pg.spec.ts:150-159`) read `report.coverage`, but the real report
type has no such array field.

- `src/scout/reconciliation/types.ts:301-324` (`ReconciliationReportV1`) declares
  `readonly families: readonly ReconciliationFamilyV1[]` (line 324) — the per-family coverage
  array is named **`families`**, not `coverage`.
- A same-named but unrelated `coverage` field does exist, but on a different type entirely:
  `RunFactsV1` at `types.ts:242` (`readonly coverage: Readonly<Record<string, CoverageFact>> |
  null`) — a `Record`, not an array, and not the shape `ScoutRunSettledBasis.report` (what
  `settledBasisRows` returns) ever produces.
- The live-passing precedent already reads the correct field:
  `test/scout/s10/s10-unseen.pg.spec.ts:302-303` — `const familyOf = (basis, family) =>
  basis.report.families.find((f) => f.family === family);`. D2's own spec exercises this
  accessor across many live-passing cases (`s10-unseen.pg.spec.ts:319-445`).
- **Fix**: renamed the local `Report` type's field from `coverage` to `families`, and both
  helper bodies (`coverage()`, `byFamily()`) from `report.coverage` to `report.families`. No
  other field on `ReconciliationFamilyV1` (`types.ts:267-292`) needed a rename — `family`,
  `completeness_basis`, `observed_unique`, `qualifiers` are all declared there verbatim and
  already matched what this spec asserted.
- No product change; this is a genuine spec defect (wrong field name), fixed to match the real
  DTO. **Not a product finding.**

## Audit of every other J19 report/cell/roster/status field access

Per the parent's instruction, every remaining J19 assertion in both legs was checked against a
live-passing precedent, citing the precedent's file:line. No further mismatches found:

| Assertion (journey-full.pg.spec.ts) | Field(s) | Precedent (file:line) | Result |
|---|---|---|---|
| `basis.report` `toMatchObject({ basis: 'settled', conditions: [] })` | `basis`, `conditions` | `src/scout/reconciliation/types.ts:307-313` (`ReconciliationReportV1.basis`); `s10-unseen.pg.spec.ts:319` (`conditions`) | Match — declared fields, live-asserted shape |
| `basis.report.required_families` | `required_families` | `types.ts:315`; `s10-unseen.pg.spec.ts:320` | Match |
| `byFamily(...).observed_unique`, `.completeness_basis`, `.qualifiers` | `ReconciliationFamilyV1` fields | `types.ts:267-292`; `s10-unseen.pg.spec.ts:322,325-327,436` | Match (after the `families` rename above) |
| `run.terminal_status`, `run.reason_code` | run-row fields | `s10-unseen.pg.spec.ts:314-315,351-352` | Match |
| `redrive.queries.filter(isTerminal)` | query-shape helper | `settle-redrive.pg.spec.ts:52` (identical `isTerminal` definition) and `:263` (same usage) | Match |
| `third.pushes` `toBe(0)` (no-op third claim) | `pushes` | `settle-redrive.pg.spec.ts:233` (`expectNoClaimSideEffects`, asserted on every replay including a closed-gate no-op) | Match — already correct, no change needed |
| `roster.result.accounting.staged`, `.persons`, `.roster_bridge_pending` | roster response fields | `src/scout/scout-roster.service.ts:164-179` (response object literal) | Match |
| `person.state`, `.source_platform`, `.source_person_id` | roster person fields | `src/scout/scout-roster.service.ts:220-227` (`materialize()` push shape) | Match |
| `person.state` `toBe('InvitePending')` | Prisma enum value | `prisma/schema.prisma:6952` (`InvitePending` enum member; Prisma serializes enum members as their literal name) | Match |
| `midStatus.result` `toMatchObject({ status, phase, claimed_status })`; `midStatus.queries.filter(...)` `toEqual([])` | status-read fields | `settle-redrive.pg.spec.ts` `statusOf` usage pattern (same harness function, same shape) | Match |
| `readiness.result.readiness` `{ run, source_declared, declared_platforms }`; readiness never leaks `partial`/reason codes | readiness fields | `src/extension-pair/extension-pair.service.ts:241` (readiness only ever emits `open`/`terminal`, cited in Round 1) | Match — already verified pre-Round-1 |

No further B-class defects found. The two fixes above (leg A's `pushes`, leg B's `families`) are
the complete set required to make both legs consistent with already-live-passing precedent.

## Commands run (Round 3), with RC

All heavy commands ran under `flock -w 3600 .../test-validation.lock`, `PROOF_SLOT_FREE`
re-checked present before each. No PostgreSQL, no push.

| # | Command (abbreviated) | RC |
|---|---|---|
| 1 | Read `s11d/PROOF_V1_FINDING.md` and `s11d/binding/v1/run/jest-full.log` in full (read-only; never edited) | 0 |
| 2 | Read `test/scout/s11/settle-redrive.pg.spec.ts` in full (the G1 re-drive precedent) | 0 |
| 3 | Read `test/scout/s10/s10-unseen.pg.spec.ts:1-60,290-450` (the `familyOf`/D2 precedent) | 0 |
| 4 | `grep`/`read` of `src/scout/scout.service.ts` (`complete`, `completeServerRun`, `notifyComplete`), `src/scout/reconciliation/types.ts` (`ReconciliationReportV1`, `ReconciliationFamilyV1`, `RunFactsV1`), `src/scout/scout-roster.service.ts`, `prisma/schema.prisma` | 0 |
| 5 | `edit` — flipped `redrive.pushes` to `toBe(0)` with citation comment (leg A) | 0 |
| 6 | `edit` — renamed `Report.coverage` → `Report.families` and both helper bodies (leg B) | 0 |
| 7 | `prettier --write` then `--check test/scout/s11/journey-full.pg.spec.ts` | 0 |
| 8 | `flock ... eslint --no-warn-ignored --max-warnings 0 test/scout/s11/journey-full.pg.spec.ts` | 0 |
| 9 | `flock ... tsc --noEmit` | 0 |
| 10 | `flock ... jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-full.pg.spec.ts --verbose` (no `G2_S11_DATABASE_URL`) | 0 — `Tests: 6 skipped, 95 passed, 101 total` |
| 11 | `git add test/scout/s11/journey-full.pg.spec.ts`; `node scripts/check-r75.js --mode=staged` | 0 — "OK — no positive token change" |
| 12 | `git commit -F <msg file>` under flock, `GIT_AUTHOR_NAME/EMAIL`/`GIT_COMMITTER_NAME/EMAIL` = `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no `--no-verify`, **new commit, not amend** | First attempt RC=1 (lefthook's own `tsc` hook OOM'd — "JavaScript heap out of memory" — while a concurrent sibling worker's `tsc` process was also running under the same flock at the same moment; no commit was created, tree remained staged-but-uncommitted). Re-ran after confirming memory was free and no competing process remained, with `NODE_OPTIONS=--max-old-space-size=4096` exported for the hook's own subshell: RC=0 — commit `aed23289` created, all six lefthook hooks (`prod-readiness-quick`, `banned-cast-tokens`, `eslint`, `prettier`, `tsc`, `no-ai-tokens`) passed |
| 13 | `git status --porcelain --untracked-files=all`; `git log --oneline -5`; `git diff --name-only 03e7a2344ef95b019c751983527bbc9f78200921 HEAD -- src prisma`; `git diff --name-only 03e7a2344ef95b019c751983527bbc9f78200921 HEAD`; final re-run of command #10 post-commit | 0 each — tree clean; `-- src prisma` empty; full diff shows only `test/scout/s11/journey-full.pg.spec.ts` (this round) plus `test/utils/g2-s11-harness.ts` (the parent's own prior S11-A2 r2 rebase commit `54be96f1`, not touched by this round's commit — confirmed via `git show --stat` and `git log -- test/utils/g2-s11-harness.ts` showing only `54be96f1`); same 6-skipped/95-passed result |

## Round 3 head / tree / blob

- **HEAD:** `aed23289024898cceca7385d3778cd7373b7424d` (branch `fa72/s11d-r2`, one new commit on
  top of the proof-v1 candidate `38d0d366` — not an amend, not a rebase)
- **Tree:** `6787b25531ab7614c9de70e745381a996d66b119`
- **Blob** (`test/scout/s11/journey-full.pg.spec.ts`): `9ca2ebb6c1f0f43d3984dfcaf94021de03abbd6d`
  (sha256 of working-tree content: `110a02df004301f553fdbce44a77872d29f3484d6aa25fa7bb6bc914f79abffe`)
- `git log --oneline -5`:
  ```
  aed23289 fix(scout): S11-D round 3 — J19 leg A push count and leg B report field name
  38d0d366 test(scout): S11-D round 2 — gate J20 live, assert roster-bridge qualifier, cover full range
  a52d20d6 test(scout): S11-D full two-host journey (J19) and core-diff check (J20)
  54be96f1 test(scout): S11-A2 r2 reset the S10-B tables only by cascade
  03e7a234 test(scout): S11-A2 two-source induction proof J09-J11
  ```
- Working tree at finish: clean.
- Author and committer both `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no AI/co-author
  trailers.

## Round 3 files + LOC

Still the single spec file (relative to the S11-A2 r2 base `03e7a2344ef95b019c751983527bbc9f78200921`,
the harness file `test/utils/g2-s11-harness.ts` also differs, but that is the parent's own
`54be96f1` commit, not this round's):

| path | LOC (round 3 diff) | total LOC |
|---|---|---|
| `test/scout/s11/journey-full.pg.spec.ts` | 17 insertions(+), 5 deletions(-) | 633 |

## Round 3 expected live count

Unchanged from Round 2's structure — still **6 `it()` cases, ALL gated inside `live(...)`**:
2 J19 legs + 4 J20 checks. What changes this round is correctness, not count: J20 already
passed 4/4 in proof v1; J19's 2 legs are now expected to pass as well, since both diagnosed
defects (leg A's push-count assumption, leg B's field name) are fixed and independently verified
against live-passing precedent code paths and specs. This builder did not and cannot run the
live PG lane to confirm (WORKER_RULES §3) — that confirmation is proof v2, parent-owned.

## Round 3 gate results

| Gate | Result |
|---|---|
| Prettier | PASS |
| ESLint (`--max-warnings 0`) | PASS (0 errors, 0 warnings) |
| `tsc --noEmit` (manual, pre-commit) | PASS (0 errors) |
| `banned-cast-tokens` (R75) | PASS — "OK — no positive token change" |
| No-DB jest — guard spec | PASS, **95/95** unchanged |
| No-DB jest — `journey-full.pg.spec.ts` | PASS — all 6 cases still show `skipped` (fix is inside the live-gated body; no-DB behavior is unaffected by design) |
| Lefthook (`git commit`), attempt 1 | **FAIL** (RC=1) — the hook's own `tsc` sub-process hit an out-of-memory abort while a concurrent sibling worker held the same flock lock for its own `tsc` run; no commit was created (verified via `git log`/`git status` immediately after) |
| Lefthook (`git commit`), attempt 2 | PASS (RC=0) — re-ran after confirming free memory and no competing process, with a larger `NODE_OPTIONS` heap cap for the hook's subshell; all 6 hooks passed, commit `aed23289` created |
| `git diff --name-only <base> HEAD -- src prisma` | Empty |
| Real PostgreSQL run | Not performed this round either — parent-only; this round's diagnosis is verified by source-reading and citing precedent specs/lines, per the finding's own required closure ("diagnose both against passing live specs, fix the spec only") |

## Round 3 risks

- **Risk 5 (C, record only).** The first commit attempt failed with an out-of-memory abort in
  the pre-commit `tsc` hook, caused by resource contention with a concurrent sibling worker
  under the shared flock lock, not by any defect in this round's change (the identical manual
  `tsc --noEmit` had already passed cleanly moments earlier under the standard 3072 MB cap).
  **CONCRETE HARM:** none — no commit was created by the failed attempt (verified), so no
  corrupt or partial commit exists on `fa72/s11d-r2`; the retry succeeded cleanly. **MINIMUM
  CLOSURE:** none needed beyond what was done (confirm free memory, retry with a larger heap cap
  for the hook's own subshell); noting it here in case the same contention recurs for a sibling
  worker's own heavy `tsc`/`jest` runs under this shared lock.
- **This builder cannot run the live PG lane** (WORKER_RULES §3), so leg A's and leg B's fixes
  are verified by source-reading (`scout.service.ts`'s own docblock and P2002 branch,
  `reconciliation/types.ts`'s field declarations) and by citing live-passing precedent specs
  (`settle-redrive.pg.spec.ts`, `s10-unseen.pg.spec.ts`), not by an actual passing live jest run
  of this file. **CONCRETE HARM:** none identified — both root causes trace to an explicit,
  unambiguous source-code contract (the docblock's own words; the type declaration's own field
  name) rather than to inferred behavior. **MINIMUM CLOSURE:** proof v2 (parent-owned) will
  confirm both legs pass for real.
- **B3 remains parent-owned and is already closed** in this base (`54be96f1`, "S11-A2 r2 reset
  the S10-B tables only by cascade" — confirmed present in the log above), consistent with the
  parent's stated plan; no action was needed or taken on it this round.
- Round 1's Risk 1, Risk 2, Risk 3, and Round 2's Risk 4 all still apply and are unchanged by
  this round.

## Sources (Round 3)

- `execution/fa72efb2/s11d/PROOF_V1_FINDING.md` (the proof-v1 FAILED finding this round diagnoses)
- `execution/fa72efb2/s11d/binding/v1/run/jest-full.log` (read-only; the preserved failing run's exact output, never edited)
- `test/scout/s11/settle-redrive.pg.spec.ts:52,165,231-266,403` (the G1 re-drive precedent; `isTerminal`, `expectNoClaimSideEffects`, `pushes` assertions)
- `test/scout/s10/s10-unseen.pg.spec.ts:302-303,314-327,436` (D2's `familyOf`/`basis.report.families` precedent)
- `src/scout/scout.service.ts:281-419` (`complete`, `completeServerRun`, `notifyComplete`, the docblock at :369-371 and the P2002 branch at :407-412)
- `src/scout/reconciliation/types.ts:242,267-292,301-324` (`RunFactsV1.coverage`, `ReconciliationFamilyV1`, `ReconciliationReportV1.families`)
- `src/scout/scout-roster.service.ts:164-227` (roster response and `materialize()` shapes)
- `prisma/schema.prisma:6952` (`PersonState.InvitePending` enum member)
- `test/scout/s11/journey-full.pg.spec.ts` (this round's file, commit `aed23289`)

# Round 4 (real-PG proof v2 diagnosis — T4 escalation)

Proof v2 (`s11d/binding/v2/run/jest-full.log`, preserved, never edited; launcher `binding/v2/launcher.out`: `JEST_END full rc=1`,
`Tests: 2 failed, 4 passed, 6 total`) ran candidate `aed23289` (Round 3). J20 passed 4/4 again. J19 leg A stopped at
`journey-full.pg.spec.ts:313` (`lateReadiness.failure` was a 404 "Pairing session not found. Create a new pairing code."); J19 leg B
stopped at `:426` (`roster.result.accounting.staged` expected 2, received 0). `s11d/PROOF_V2_FINDING.md` did not exist when this
round started (only `PROOF_V1_FINDING.md`); the diagnosis below is taken from the v2 log itself. Work in
`/home/user/workspace/worktrees/fa72-s11d2`, branch `fa72/s11d-r2`, ONE new commit on top of `aed23289` (no amend, no rebase), spec
file only, through lefthook. No PostgreSQL, no push, no src/prisma/harness edit.

## Diagnosis

### Leg A — `pairCurrent` 404 after the terminal (`:312-313` pre-edit) — SPEC DEFECT, fixed

- The harness signature is `pairCurrent(host, coach, nonce?)` → worker `pairing.current(input.coach, body.nonce)`
  (`test/utils/g2-s11-harness.ts:322-323`; `test/utils/g2-s11-worker.cjs:403-404`). The spec passed `intentId` as that third
  argument (live: `g2g_19`, `"body":{"nonce":"a4713392-…"}`, jest-full.log:240).
- `ExtensionPairService.current(coachId, nonce)` filters `nonce ? { setup_nonce: nonce } : { superseded_at: null }`
  (`src/extension-pair/extension-pair.service.ts:192-193`); `readSetup` does one `importIntent.findFirst` on that filter and throws
  `NotFoundException('Pairing session not found. Create a new pairing code.')` when nothing matches (`:200-206`). This leg's
  `pairInit` posted `body: {}` (`g2g_1`, log:2) → `init(coach, 's11-label', undefined)` → the intent row was created with
  `setup_nonce: undefined` (NULL) (`:124-131`), so `setup_nonce = <intentId>` matches no row. **Nothing is consumed, bound or
  expired at the terminal** — the same no-nonce `pairCurrent('P1', COACH_A)` already passed live earlier in this leg (`g2g_3`,
  log:30, `status: paired`), and leg B's post-terminal `pairSession` read `run: 'terminal'` fine (`g2g_32`, log:422).
- Live-passing precedent for the terminal read: S11-C `test/scout/s11/readiness.pg.spec.ts:139-145` (R4 "then terminal":
  `h.pairCurrent('P1', COACH)` with NO nonce → `{ run: 'terminal', … }`), and `:82-83` (R1 compares `pairCurrent`'s echo to the
  `pairSession` result including `import_intent_id`).
- **Fix** (`journey-full.pg.spec.ts:321`): `h.pairCurrent('P2', COACH_A)` — no nonce, mirroring R4 exactly; plus
  `expect(lateReadiness.result.import_intent_id).toBe(intentId)` (`:325`) so the "current setup" read is provably this run's
  setup (`readSetup` echoes `import_intent_id: row.id`, service `:216`). Not a product finding.

### Leg A — step-11 empty roster tightened (`:340`)

While tracing leg B (below) it became clear that at this head the roster reader returns an empty projection for every S11 source
regardless of what was staged, so `persons: []` / `staged: 0` alone did not discriminate "empty because none were staged" from "empty
because the reader cannot see this source". Added `expect(h.persons(COACH_A)).toEqual([])` — the direct `Person` read
`journey-induction.pg.spec.ts:147` and `settle-redrive.pg.spec.ts:146` use live — immediately before the roster read. Guaranteed by:
no roster token in either native-clean set (`:224-226`, live-passed), the second source has no roster family
(`journey-induction.pg.spec.ts:13`), `resetData()` deletes `Person` before each case (`g2-s11-harness.ts:292`), and only
`clientsFamily.persist` writes `Person` (`src/scout/reconstruct/families.ts:83-101`).

### Leg B — `accounting.staged` 0 vs 2 (`:443` post-edit) — PRODUCT FINDING, NOT bent. STOPPED.

Full write-up: `s11d/S11D_R4_LEG_B_ROSTER_FINDING.md` (class B). Summary of the trace:

- What `accounting.staged` counts: `scoutIngestEntity.count({ where: { coach_id, intent_id, entity_type: RECONSTRUCT_ENTITY_TYPE } })`
  (`src/scout/scout-roster.service.ts:72-76,109`), `RECONSTRUCT_ENTITY_TYPE = 'clients'` (`src/scout/scout-reconstruct.dto.ts:91`).
  Ledger counts and the page use the same literal (`:110-128`). No token resolution; no family/token parameter on the controller
  (`scout-roster.controller.ts:85-90`) or in the worker action (`g2-s11-worker.cjs:409-416`).
- What this run staged: `entity_type = 'u10-members'` (the source token; `scout-ingest.service.ts:88`; live `g2g_24`, log:310).
  The engine reconstructs by token (`family-plan.ts:88-92`; `scout-reconstruct.service.ts:248-253`) and ledgers under
  `ledgerType = row.entity_type ?? family.entityType` = `'u10-members'` (`:445`, `:576-582`). S9 joins on that same token identity
  (`facts.service.ts:87-88,414-416`) — which is exactly why leg B's own settled-basis assertions PASSED live (`:399-417`:
  `partial/unresolved_identities`, `observed_unique 2`, `qualifiers ['roster_bridge_pending']`).
- Therefore the IMPORTER-G roster read sees `staged 0 / reconstructed 0 / persons []` for ANY token-mapped source at this head
  (`u10-members`; S11-A1's `people`, `g2-s11-harness.ts:55-56`), while the Person rows exist (D2 (h) proves `persons: 2` by SQL,
  `s10-unseen.pg.spec.ts:293,451`). The only live-passing roster-with-people precedent (`test/rls-g2-ledger-expand.spec.ts:244-256,310`)
  ingests with the literal `entity_type: 'clients'`. S11-A1's step-11 roster read asserts only `intent_id` + cross-host equality
  (`journey-core.pg.spec.ts:262-267`). D2 (h) never calls the roster reader.
- The S11 decision record wording ("a native roster read (step 11) that lists exactly the reconstructed identities",
  `docs/decisions/2026-09-26-s11-journey.md:432-433`) and the grant's leg-B wording are therefore genuinely contradicted by the
  product for the `s10_unseen` source at this head; satisfying them needs a `src` change (reader resolving tokens through the
  registry, or engine ledgering under the canonical family — the latter would move S9's join key). Per the grant's STOP rule and
  D-S11-6, the assertion at `:443-453` is left byte-identical, and the finding is reported for re-grading instead.
- Also true at S8-D1 (`worktrees/fa72-s8d1` HEAD `03b574e4`: `scout-roster.service.ts:75` and `scout-reconstruct.service.ts:445`
  unchanged), so S8-D1's §6 patch expectation for this file (`s8d1/s8d1_build.md:125`, `accounting.staged === rosterIds.size`) is
  unrunnable too. Sibling IMPORTER-I reader has the same `entity_type: family` scoping (`scout-entities.service.ts:113,180,236,330`) —
  recorded, not asserted here.

**Consequence for the next live run: leg B WILL still fail at `:443` on this commit.** Expected live result of r4 as-is: 5 passed /
1 failed (leg A, J20×4 pass; leg B fails). Do not bind r4 expecting 6/6; the parent must first decide the leg-B re-grade.

## Assertion trace (post-edit line numbers, `test/scout/s11/journey-full.pg.spec.ts` at `913811fd`)

Legend: LIVE = already executed and passed in proof v2 (jest-full.log process names in brackets); PREC = live-passing precedent line;
CODE = executing code path.

| Line | Assertion | CODE (file:line) | PREC / LIVE | Status |
|---|---|---|---|---|
| 177-183 | pair init/redeem ok; `pairCurrent('P1')` paired | `extension-pair.service.ts:75-135,207-215` | LIVE g2g_1-3 | passes |
| 185-190 | start ok, `runCount 1`, replayed start identical | `run.controller`/lifecycle start idempotent | LIVE g2g_4-5 | passes |
| 195-200 | early readiness `open/false/0` | `extension-pair.service.ts:234-244` | LIVE g2g_6; readiness R2 `:93-98` | passes |
| 205-216 | declare ok; mid readiness `open/true/2` | `:239-243` (distinct platforms) | LIVE g2g_7-8; readiness R3 `:112-117` | passes |
| 220-226 | stagedCount = both native-clean sets; no `u10-members` token | `scout-ingest.service.ts:82-95`; fixture sets | LIVE g2g_9-12 | passes |
| 231 | observation rows = first.families + second.families | S10-B observation store | LIVE g2g_13-14; induction J09 | passes |
| 247-257 | victim paused `after-row`, killed; run open `reconciling`, epoch 1, no basis | `scout.service.ts:368-392` claim; S11-B kill | LIVE (g2g_15 absent = killed); settle-redrive `:165-230` | passes |
| 261-269 | mid status `running/reconciling/success`, no writes | `scout.service.ts:460-540` | LIVE g2g_16 | passes |
| 279-282 | re-drive ack, 1 terminal write, 0 pushes | `scout.service.ts:407-419` | LIVE g2g_17; settle-redrive `:231-266` | passes |
| 284-290 | run `complete`, reason null, 1 basis row | arbiter CAS + settled basis | LIVE (reached :313) | passes |
| 294-298 | third claim: ack, 0 terminal, 0 pushes, still 1 basis | closed-gate no-op path | LIVE g2g_18; settle-redrive J15 | passes |
| 304-309 | report `settled`, `conditions []`, `required_families [clients, programs, workouts]`, all cells `source_signed_enumeration`, clients `observed_unique 0` | `reconciliation/types.ts:301-324` | LIVE (reached :313); D2 `s10-unseen.pg.spec.ts:311-335` | passes |
| 322 | `pairCurrent('P2', COACH_A)` no failure | `extension-pair.service.ts:193` `{superseded_at:null}` → the one intent for COACH_A (init `:120-131`; `resetData` `:293` clears `ImportIntent`) | readiness R4 `:139-140`; same call LIVE g2g_3 | **FIXED r4** |
| 325 | echoed `import_intent_id === intentId` | `extension-pair.service.ts:216` | readiness R1 `:82-83` | new r4 |
| 326-330 | readiness `terminal/true/2` | `:241-243` (`terminal_status 'complete'` non-null; 2 declared platforms) | readiness R4 `:140-144`, R5 `:154-158`; LIVE g2g_32 (leg B, same shape) | passes |
| 331 | body has no `complete` | `PairSessionResult` = status/import_intent_id/chosen_platform/readiness only (`:207-221`) | readiness R4 `:145` (`not.toContain('timed_out')`) | passes |
| 340 | `h.persons(COACH_A)` = [] | `families.ts:83-101` only Person writer; no clients rows staged (`:224-226`) | induction `:147`, settle-redrive `:146` | new r4 |
| 342-344 | roster P1 ok, `persons []`, `staged 0` | `scout-roster.service.ts:91-97` gate (terminal non-null), `:109` count, `:132` materialize | journey-core `:263-266` | passes (C: non-discriminating alone at this head — hence :340) |
| 346-347 | roster P2 byte-identical | same deterministic object (`:165-179`; no time fields) | journey-core `:267` | passes |
| 353-354 | status P1 == P2; `complete`/null | `getImportStatus` read-only at terminal | induction `:296-304`; journey-core `:253-258` | passes |
| 373-386 | leg B pair/start/declare ok; stagedCount; roster ids distinct | as leg A | LIVE g2g_20-28 | passes |
| 394-395 | complete ack | `scout.service.ts:368-419` | LIVE g2g_31 | passes |
| 399-401 | `partial`, `unresolved_identities`, not `complete` | `reconcile.ts:136-146,347` | LIVE; D2 (h) `:432-433` | passes |
| 404-417 | `conditions ['unresolved_identities']`; clients cell `source_signed_enumeration`, `observed_unique 2`, `qualifiers ['roster_bridge_pending']` | `facts.service.ts:145-147`; `types.ts:267-292` | LIVE; D2 (h) `:435-444` | passes |
| 421-428 | `pairSession('P2')` terminal/true/2; no `partial`/reason leak | `extension-pair.service.ts:188-189,241-243` | LIVE g2g_32; readiness R5 `:153-159` | passes |
| 436 | roster read ok (gate passes: `terminal_status 'partial'` non-null) | `scout-roster.service.ts:91-97` | LIVE g2g_33 | passes |
| 442 | `roster_bridge_pending === true` | `scout-roster.dto.ts:42`; service `:178` | LIVE g2g_33 | passes |
| **443** | `accounting.staged === 2` | `scout-roster.service.ts:72-76,109` counts `entity_type='clients'`; rows are `u10-members` | NO precedent exists for a token-mapped source; LIVE g2g_33 = 0 | **BLOCKED — product finding, unchanged** |
| 447-450 | ids == staged roster ids; each `InvitePending`, `source_platform == first.platform` | would need ledger rows under `'clients'` (`:119-128`) — none exist for this run | `rls-g2-ledger-expand.spec.ts:244-256` only with literal `clients` token | blocked behind :443 (would receive `[]`) |
| 453 | roster P2 byte-identical | deterministic object | journey-core `:267` | would pass |
| 536-647 | J20 ×4 | unchanged | LIVE v1+v2 4/4 | passes |

## Commands run (Round 4), with RC

Heavy commands ran ONLY as `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '…'` with
`/home/user/workspace/execution/fa72efb2/PROOF_SLOT_FREE` checked present immediately before (it was absent when this round started
at ~19:46Z and appeared at 19:47Z; nothing heavy ran before that). No PostgreSQL, no push, no npm/prisma.

| # | Command (abbreviated) | RC |
|---|---|---|
| 1 | Read (read-only) `WORKER_RULES.md`, `S11D_BUILD_GRANT.md`, `PROOF_V1_FINDING.md`, `s11d_build.md` r1-3, `s11d_review.md` r2-3, `binding/v1/run/jest-full.log` (via r3 report), `binding/v2/run/jest-full.log` (`rg -n PG17_PROCESS`, failure blocks :452-490), `binding/v2/launcher.out`, `S11D_PG_PROOF_GRANT.md`, `PARENT_REBASE_NOTE.md` | 0 (`cat PROOF_V2_FINDING.md` RC 1 — file does not exist) |
| 2 | `nl -ba`/`rg` over `src/extension-pair/extension-pair.service.ts:60-135,180-280`, `test/scout/s11/readiness.pg.spec.ts:60-165`, `test/utils/g2-s11-harness.ts:219-330`, `test/utils/g2-s11-worker.cjs:380-470` | 0 |
| 3 | `nl -ba`/`rg` over `src/scout/scout-roster.service.ts` (full), `scout-roster.controller.ts:60-90`, `scout-roster.dto.ts:30-45`, `scout-reconstruct.dto.ts:1-30,85-120`, `scout-reconstruct.service.ts:225-300,440-640`, `reconstruct/orchestration/family-plan.ts`, `reconstruct/families.ts:66-104`, `reconstruct/sources/s10_unseen.json`, `reconciliation/facts.service.ts:76-95` + `rg entity_type`, `scout-ingest.service.ts:80-95`, `scout-entities.service.ts` (`rg entity_type`) | 0 |
| 4 | Precedent reads: `test/scout/s10/s10-unseen.pg.spec.ts:20-70,280-300,425-454`; `test/rls-g2-ledger-expand.spec.ts` (`rg roster|staged|entity_type`); `test/utils/g2-tq0-worker.cjs:78-96`; `test/scout/s11/journey-core.pg.spec.ts:225-274`; `journey-induction.pg.spec.ts:290-307,396-409`; `test/scout/roster/scout-roster.service.spec.ts` (`rg entity_type`); `docs/decisions/2026-09-26-s11-journey.md:115-135,420-440`; evidence `s8d/s8d_decision_record.md:40-52`, `s8d1/s8d1_build.md:20-40` + patch head; `git -C worktrees/fa72-s8d1 log -1` + `rg ledgerType|RECONSTRUCT_ENTITY_TYPE` there (read-only) | 0 |
| 5 | `git status/log/branch` in fa72-s11d2 (clean, HEAD aed23289, branch fa72/s11d-r2); `ls PROOF_SLOT_FREE` | 0 (ls RC 2 at 19:46Z — absent; present from 19:47Z) |
| 6 | `edit` ×3 on `test/scout/s11/journey-full.pg.spec.ts`: no-nonce `pairCurrent` + comment; `import_intent_id` echo assertion; `h.persons(COACH_A)` empty assertion + comment | 0 |
| 7 | `prettier --write` then `--check` on the spec (prettier 3.9.9 from runtime/tools, light) | 0 ("unchanged", all files formatted) |
| 8 | `flock … eslint --no-warn-ignored --max-warnings 0 test/scout/s11/journey-full.pg.spec.ts` | 0 |
| 9 | `flock … tsc --noEmit` — first launch (plain `&` inside the tool shell) was torn down with the tool call and produced NO result (log empty; no tsc process; not counted as a pass or fail) | n/a (aborted, no output) |
| 10 | `flock … tsc --noEmit` (relaunched via `nohup setsid`, `NODE_OPTIONS=--max-old-space-size=3072`) | 0 (`TSC_RC=0`) |
| 11 | `flock … jest --runInBand --runTestsByPath test/utils/g2-s11-db-guard.spec.ts test/scout/s11/journey-full.pg.spec.ts` (no `G2_S11_DATABASE_URL`) | 0 — `Tests: 6 skipped, 95 passed, 101 total`; guard 95/95; pg spec skips cleanly |
| 12 | `git add test/scout/s11/journey-full.pg.spec.ts`; `node scripts/check-r75.js --mode=staged` | 0 — "OK — no positive token change" |
| 13 | `flock … git commit -F /tmp/s11d_r4_msg.txt` with `GIT_AUTHOR_*`/`GIT_COMMITTER_*` = Bradley Gleave <bradley@bradleytgpcoaching.com>, no `--no-verify`, NEW commit (not amend) | 0 — lefthook pre-commit: prod-readiness-quick ✔, banned-cast-tokens ✔, eslint ✔, prettier ✔, tsc ✔ (49.9 s); commit-msg no-ai-tokens ✔; `[fa72/s11d-r2 913811fd]` |
| 14 | `git status --porcelain --untracked-files=all` (empty); `git diff --name-only aed23289 HEAD` (spec only); `… -- src prisma test/utils .github` (empty); `git diff --check aed23289 HEAD` | 0 each |
| 15 | `write` `s11d/S11D_R4_LEG_B_ROSTER_FINDING.md`; append this Round 4 section to `s11d/s11d_build.md` | 0 |

## Round 4 head / tree / blob

- **HEAD:** `913811fdd37016e13ed4e01ddaed7678982641fc` (branch `fa72/s11d-r2`; parent `aed23289024898cceca7385d3778cd7373b7424d`;
  one new commit, no amend)
- **Tree:** `2d6c7bf75d70d90900b3f506cbfa3db41e01d9f7`
- **Blob** `test/scout/s11/journey-full.pg.spec.ts`: `0a2d7b7e07716533fd39cddbe527344be286c7fa`
  (sha256 `3c86d84045af3daf0d8dbec91a71ddafcd543fba16e06834dedf9ab484c6b903`; 650 LOC; r4 diff +18/−1)
- Author and committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no AI/co-author trailers (grep 0). Working tree clean.
- `git log --oneline -3`: `913811fd` r4 · `aed23289` r3 · `38d0d366` r2.
- Evidence files this round (not git-committed — parent commits): `s11d/S11D_R4_LEG_B_ROSTER_FINDING.md`, this section.

## Round 4 expected live count

Still 6 `it()` cases inside `live(...)`. Honest expectation for a live run of `913811fd` at this head: **5 pass / 1 fail** —
leg A (fixed) + J20 ×4 pass; **leg B fails at `:443`** (`accounting.staged` 0 ≠ 2) until the roster-reader finding is re-graded. This
builder did not and cannot run the PG lane (WORKER_RULES §3).

## Round 4 risks

- **B (reported, blocking leg B)** — `S11D_R4_LEG_B_ROSTER_FINDING.md`: IMPORTER-G roster reader is scoped to the literal `clients`
  `entity_type`; the S8-G engine ledgers token-mapped sources under their token. CONCRETE HARM: native review shows an empty roster
  (`staged: 0`, a silent zero) for every newly inducted source; J19 step 11 unprovable as worded; S8-D1 §6 patch expectation also
  unrunnable. EXACT DECISION BLOCKED: landing S11-D leg B (#565). MINIMUM CLOSURE: parent/owner re-grade — reader token→family
  resolution (natural home S8-D2) or an explicit decision-record re-wording of step 11 with leg B asserting Person rows by SQL.
  EXECUTION UNLOCKED: S11-D landing; truthful S8-D2 roster contract.
- **C (recorded)** — sibling IMPORTER-I entities reader has the same `entity_type: family` scoping; not asserted by this file.
- **C (recorded)** — the r4 `h.persons(COACH_A)` assertion is a tightening of an existing step-11 claim, not a new worker action or
  harness change (`h.persons` already exists and is used live by two S11 specs).
- **C (recorded)** — command #9: a heavy command launched with a bare `&` inside a tool shell was torn down with the call and left no
  result; relaunched with `nohup setsid` and completed RC 0. No lock was stolen or left held (`flock` exits with its child).
- Rounds 1-3 risks unchanged.

## Sources (Round 4)

- `execution/fa72efb2/s11d/binding/v2/run/jest-full.log:2-490` and `binding/v2/launcher.out` (read-only)
- `src/extension-pair/extension-pair.service.ts:75-135,188-249`
- `test/scout/s11/readiness.pg.spec.ts:73-160`
- `test/utils/g2-s11-harness.ts:55-62,219-330`; `test/utils/g2-s11-worker.cjs:397-416`
- `src/scout/scout-roster.service.ts:57-180`; `scout-roster.controller.ts:77-90`; `scout-roster.dto.ts:33-42`; `scout-reconstruct.dto.ts:13-21,91`
- `src/scout/scout-reconstruct.service.ts:233-290,440-612`; `src/scout/reconstruct/orchestration/family-plan.ts:82-100`;
  `src/scout/reconstruct/families.ts:75-103`; `src/scout/reconstruct/sources/s10_unseen.json`; `src/scout/scout-ingest.service.ts:82-95`
- `src/scout/reconciliation/facts.service.ts:78-91,404-423`
- `test/scout/s10/s10-unseen.pg.spec.ts:56-58,292-300,429-453`; `test/rls-g2-ledger-expand.spec.ts:233-317`;
  `test/scout/s11/journey-core.pg.spec.ts:253-274`; `test/scout/s11/journey-induction.pg.spec.ts:147,295-306`
- `docs/decisions/2026-09-26-s11-journey.md:117-129,424-435`
- `execution/fa72efb2/s8d1/s8d1_build.md:27,38,111,125`; `worktrees/fa72-s8d1` @ `03b574e4` (read-only rg)

Addendum (end of Round 4): `s11d/PROOF_V2_FINDING.md` appeared during this round (parent-written). Its two stop points (`:313` 404
on `pairCurrent`; `:426` `accounting.staged` 0 vs 2) match the v2-log diagnosis above; its stated assumption for leg A ("the pairing
session is still readable after the terminal") is confirmed TRUE by the code — the 404 was the nonce-argument misuse, not readability.
