# S12-B3 mobile run verdict screen (M-bind): build report (T3)

Builder: T3 subagent for parent fa72efb2. Grant: `s12b3/S12B3_BUILD_GRANT.md`. Rules: `WORKER_RULES.md`.

## Result

| | |
|---|---|
| Clone | `/home/user/workspace/worktrees/fa72-s12b3`. Standalone `git clone --no-hardlinks` of `worktrees/fa72-mobile-rdy`. origin is `no_push://disabled-fa72efb2`. node_modules is a `cp -al` copy from fa72-mobile-rdy (64594 entries in both trees). |
| Base | `a876268c07ceaec5ae56b489466922dfbcda1a05` (mobile main, per the parent) |
| **HEAD** | **`a4d0b85c5ab39e27727ebc343062fbe2621ac934`** |
| **Tree** | **`3352e0f6ce9a9ef48e6783b722332a89a4ecee5a`** |
| Author / committer | Bradley Gleave &lt;bradley@bradleytgpcoaching.com&gt; for both. No trailers (grep for co-authored/signed-off = 0). One commit. |
| Hooks | The clone has no hooks installed: `.git/hooks` holds only `*.sample` files, `core.hooksPath` is unset, and the repo has no lefthook config. The commit ran plain `git commit` with no `--no-verify`, so no hook ran. |
| Push / PR / refs | None |
| Backend | No change. I only read `worktrees/fa72-s11d2` (and `git show 54be96f1:` from it). |
| Flags | No default changed. `importReview` (EXPO_PUBLIC_FF_IMPORT_REVIEW) is still `readFlag(..., false)`. |

## Screens

The UI mounts only inside the `paired` state of `ExtensionPairingPanel`, and only when the pairing carries the server-issued `import_intent_id`. Legacy unbound rows have no id, so nothing is shown. The panel itself mounts only under `extensionImport`.

1. **ImportRunVerdictCard** (new, `src/components/coach/ImportRunVerdictCard.tsx`)
   - Shows a label, the verdict title and body, and a status icon. The success icon appears only for a server-mode `complete`; every other state uses the neutral icon.
   - Shows "Current step" while the run is open, and "Reason" plus "Reason code: `<code>`" once it has ended.
   - Shows "Ended: `<time>`" for `completed_at`, or "Not known yet" when it is null.
   - Shows "Last checked `<time>`". After a failed refresh it shows "Couldn't refresh. Showing what the server said at `<time>`." instead.
   - Has a "Check again" button.
2. **ImportedRosterSection** (inside the card)
   - Mounts only when `featureFlags.importReview` is on and the status read shows a recognised terminal. The hook also requires `extensionImport`.
   - Shows the `roster_bridge_pending` note, the ledger accounting line, and one row per person: display name (or "Name not provided") and "Imported, not yet joined".
   - Shows "Show more" only when the server sent a next cursor.

## Server field → UI state table

Source: `ScoutImportStatusResult` / `ScoutRosterResult` in `docs/contracts/importer-openapi.json` at backend `54be96f1` (contract `2.0.0-c1-s2.0`).

### Transport / whole reading

| Server answer | Decoded as | UI |
|---|---|---|
| Flag off / no coach / no intent | hook `disabled` | Nothing rendered. No request and no listener. |
| First read in flight | `loading` | "Checking import status…" |
| HTTP 404 (uniform: dark, unknown, cross-tenant or no evidence yet) | `notFound` | "Import status: not known yet" plus "The server has nothing to show for this import yet…". A 404 is never shown as "no import" or 0. It replaces an earlier reading, because it is a fresh answer. |
| Any other failure, with no earlier reading | `error` | "Import status: not known yet" plus a connection hint |
| Any other failure, with an earlier reading | earlier reading, `stale=true` | Earlier verdict plus "Couldn't refresh. Showing what the server said at T." |
| Body is not an object, has no `intent_id`, or `intent_id` ≠ requested intent | `unreadable` | "Import status not recognised" (explicit unknown; no crash, no success) |

### `status` × `mode`

| `status` | `mode` | UI title (icon) | Extra |
|---|---|---|---|
| `running` | server / legacy | "Import in progress" (neutral) | Step row from `phase` |
| `complete` | server | "Import complete" (**success icon, the only case**) | Reason line only if `reason_code` is non-null |
| `partial` | server | "Import partly finished" (neutral) | Reason, Ended |
| `blocked` | server | "Import stopped — needs attention" (neutral) | Reason, Ended |
| `failed` | server | "Import didn't finish" (neutral) | Reason, Ended |
| `cancelled` | server | "Import cancelled" (neutral) | Reason, Ended |
| `timed_out` | server | "Import stopped — took too long" (neutral) | Reason, Ended |
| `success` / `partial` / `failed` | legacy | "Import finished" / "Import partly finished" / "Import didn't finish" (neutral) | Adds "Reported by the browser extension. The server did not check this result." No reason line, since legacy rows carry none. Ended. |
| `success` | server | **unknown**: "Import status not recognised" | The server never projects this (CQ-18) |
| `complete` / `blocked` / `cancelled` / `timed_out` | legacy | **unknown** | The legacy projection never emits these |
| unrecognised string, null, absent or non-string | any | **unknown** | Never a success |
| any | unrecognised / null / absent | **unknown** (mode is also `unknown`) | Claim and verdict cannot be told apart |

### `phase` (shown only while `running`)

| `phase` | UI "Current step" |
|---|---|
| `discovering` | "Finding your data" |
| `transferring` | "Copying your data" |
| `reconciling` | "Checking what was copied" |
| null / absent / unrecognised | "Not known yet" |
| any value on a terminal reading | not shown |

### `reason_code` (shown only on server terminals)

| `reason_code` | UI "Reason" (+ "Reason code: `<code>`") |
|---|---|
| `reconciliation_not_performed` | "The copied data hasn't been checked yet." |
| `cancelled_by_coach` | "You cancelled this import." |
| `deadline_exceeded` | "The import went past its time limit." |
| `transfer_failed` | "Copying data from your previous platform failed." |
| `unresolved_family` | "Some kinds of data couldn't be matched to TGP." |
| `revoked` | "Access for this import was withdrawn." |
| `unresolved_identities` | "Some people couldn't be matched to TGP accounts yet." |
| `relationship_unverified` | "Links between records couldn't be checked." |
| `coverage_basis_unknown` | "We can't tell yet whether everything was found." |
| null / absent / unrecognised (non-`complete` terminal) | "Not known yet", and no code line. An unrecognised raw string is never echoed. |
| null on `complete` | no reason line |

### Other status fields

| Field | UI |
|---|---|
| `completed_at` | Terminal only: "Ended: `<locale date/time>`". Null, absent or unparseable → "Not known yet". |
| `claimed_status` | Decoded but **never rendered**. It is the extension's claim and only an input to the arbiter. A test proves `failed` + claim `success` renders no "success" and no success icon. |
| `started_at` | Decoded but not rendered |
| `entity_counts`, `families[]`, `accepted_start_at`, `deadline_at`, `last_observed_at`, `execution_epoch` | Not read and not rendered (see risk C2) |

### Roster (`GET /api/scout/reconstruct/roster`, behind importReview + settled)

| Field | UI |
|---|---|
| 404 / undecodable / other failure | "Imported people: not known yet." Never an empty list. |
| `persons: []` on a valid page | "The server has no imported people to show for this import." |
| `persons[].state = InvitePending` | Row: display name + "Imported, not yet joined" |
| `persons[].state` any other value, or unrecognised | Row: display name + "Imported — joining status not known yet" |
| `display_name` null or blank | "Name not provided" |
| `source_platform`, `source_person_id`, timestamps | Dropped by the decoder; never rendered |
| `roster_bridge_pending: true` | "These people were imported but haven't joined TGP yet, so they aren't in your client list." |
| `roster_bridge_pending` false / absent / non-boolean | "Whether these people have joined TGP: not known yet." |
| `accounting` all non-negative integers | "Found S: R imported, K skipped, F couldn't be imported." (server counts verbatim) |
| `accounting` missing or malformed | "Totals: not known yet." Never zeros. |
| `page.has_more` true **and** a non-empty `next_cursor` | "Show more" (follows the server cursor only) |
| Later page undecodable or failed | Loaded rows stay, plus "Couldn't load everything. The list above may be incomplete." |

## Decoder (`src/types/importRunStatus.ts`)

- The decoders are written by hand, not with Zod, so a single drifted field fails closed on its own instead of throwing the whole read into a `contract` error.
- Nullable enums decode to one of three things: a member, `null` (the server says not known), or `'unknown'` (not recognised).
- `decodeRunStatus` has two cross-field rules, both taken from the backend projection code: `projectServerStatus` never projects `success` (scout.service.ts L542-556), and the legacy `projectReadStatus` projects only `success|partial|failed` (L564-577). I did not add a phase or reason invariant, because `projectLifecycle` (lifecycle.service.ts L1048-1065) does not guarantee one. The UI instead gates phase to `running` and reason to terminals.
- The contract test pins every closed enum against the fixture: status, mode, phase, reason_code, claimed_status and person state. It also pins the source commit, the sha256, the contract version and the path list.

## Reuse of landed patterns (mobile a876268c, PR #296)

- **Terminal success check:** the readiness row never shows a success icon for any terminal (audit B1). Here the icon appears only for server `complete`, which is written only from the S9 reconciliation verdict. Legacy `success` stays neutral.
- **Stale reads:** readiness re-reads on foreground (B2) and discards a reading for a mismatched intent (C5). Here the same foreground re-read is used, a reading for another intent is discarded, the query key is scoped to coach and intent (a new key never shows old data), and a kept reading after a failed refresh is labelled with its read time.
- **Fixture:** built with the same mechanical projection method as the S11-C fixture (derived tool at `s12b3/tooling/extract_s12b3_status_surface_fixture.py`).
- **Existing clients:** the new code uses the shared axios `api` instance and the app's central react-query retry policy (`src/services/queryClient.ts`). The pairing hook is unchanged.

## Files and sha256 (at HEAD a4d0b85c)

| Path | + / − | sha256 |
|---|---|---|
| src/types/importRunStatus.ts | 233 / 0 | 2a6817fc484c24711293bddc62171f0013dc459aee2e19ee7427cec25997b381 |
| src/api/importRunStatusApi.ts | 60 / 0 | d91703a106694d4f88f4f36e40790a0686984d984e68d6e4159ad8756ad123f4 |
| src/hooks/useImportRunStatus.ts | 212 / 0 | c1b30df791b17d88fa35693c17f18f6f921644320269ec977e84719a4cf85167 |
| src/components/coach/ImportRunVerdictCard.tsx | 344 / 0 | 3a4d0715c3d297d490d4f0f416eedb6a50cb9ab6629bdac45d4e5f97b8a1ee29 |
| src/components/coach/ExtensionPairingPanel.tsx | 12 / 1 | b2e15208590e77da5136201ae085a9767b9123b54ca58e4e246cd62d5fdbde4e |
| src/types/__fixtures__/s12b3ScoutStatusSurface.54be96f1.json | 799 / 0 | ce2ca6a3e3937e31026da2a01723c97b2af76f548bbccb9be514abfad7c73c7a |
| src/types/__tests__/importRunStatus.contract.test.ts | 231 / 0 | 603c38ab90fa8f63916feeac3de48df53ecfc3c6f25158a90094f687d7e4b947 |
| src/api/__tests__/importRunStatusApi.test.ts | 74 / 0 | 54ef3c6cecd875b3be08ee9a5beb62843eef7cbfd7ee99bc0bc75a27f3525509 |
| src/hooks/__tests__/useImportRunStatus.test.tsx | 279 / 0 | c1c4c5ae4c165794ea4d0dbf26fd30e1e180d59c48271eac5ada4668610ce044 |
| src/components/coach/__tests__/ImportRunVerdictCard.test.tsx | 354 / 0 | c4e626ccb7b10553f5444346c8e65c72b4951d017bc7cb1efab45b873e68054f |
| src/components/coach/__tests__/ExtensionPairingPanel.verdict.test.tsx | 71 / 0 | 5403d5f6496734dee9746c3ba8b9a0d7088d511f2527507771af34a7d6568bd6 |

Evidence-side tool (not in the commit): `execution/fa72efb2/s12b3/tooling/extract_s12b3_status_surface_fixture.py`, sha256 `351c7cc5cb7d4f98810bc82e3cfa01f8552cf255410fd78ad0b7daba1eb6e3bb`. It is run as `python3 <tool> <(git show 54be96f1:docs/contracts/importer-openapi.json) <fixture>`. Its output reports source sha256 `889d25c6…4dc53f4` and fixture sha256 `ce2ca6a3…c73c7a`. The artifact bytes are identical at 54be96f1, aed23289 and 7fdcbc04 (same sha256).

**LOC:** 2669 insertions and 1 deletion across 11 files. Product source (excluding tests and fixture) is 861 / 1: types 233, api 60, hook 212, card 344, panel 12/1. Tests are 1009 lines and the fixture is 799.

## Commands run (all heavy commands under `flock -w 3600 /home/user/workspace/execution/test-validation.lock`)

The lock inode was 686480 (checked with `stat`). The lock was never probed, deleted or recreated. `[ -e …/PROOF_SLOT_FREE ]` succeeded before every heavy batch. Environment: `NODE_OPTIONS=--max-old-space-size=3072`, and jest ran with `--runInBand`.

| # | Command | RC | Result |
|---|---|---|---|
| 1 | `git clone --no-hardlinks …fa72-mobile-rdy …fa72-s12b3`, set origin to no_push, set Bradley identity, `cp -al node_modules` | 0 (see note) | The tool call timed out at 630 s during `cp -al`. I checked afterwards: the clone, remote and identity were correct, and a `find` count gave 64594 entries in both node_modules trees. |
| 2 | Fixture tool on `git show 54be96f1:docs/contracts/importer-openapi.json` | 0 | 2 paths, 11 schemas, bearer |
| 3 | `npx tsc --noEmit` (first run, before the retry fix) | 0 | |
| 4 | `npx eslint --max-warnings=0` over all 10 touched TS/TSX files | 0 | |
| 5 | `npx jest --runInBand` on 13 related suites/patterns: new contract, api, hook and card tests; all ExtensionPairingPanel suites; extensionImport.contract; useExtensionPairing; useReconstructCounts; importFlags; featureFlagsReleaseInlining; ImportDataScreen*; importReviewApi.drift; extensionPairApi | 1 | 628/630 passed. Two defects in my new tests: (a) the hook's explicit `retry: 1` overrode the test client's `retry:false`, so `waitFor` timed out; fixed by removing it so the app-wide retry policy applies. (b) A `jest.mock` factory referenced an out-of-scope `Text`; fixed with an in-factory `require`. |
| 6 | `npx eslint --max-warnings=0` on the 2 files changed by the fixes | 0 | |
| 7 | `npx jest --runInBand` on useImportRunStatus.test + ExtensionPairingPanel.verdict.test | 0 | 25/25 |
| 8 | `npx tsc --noEmit` on the final bytes | 0 | |
| 9 | `npx jest --runInBand` (**full suite**, final bytes) | 143 (see note) | **Test Suites 330/330 passed. Tests 4369/4369 passed. Snapshots 5/5. 136.965 s.** After the summary, Jest printed "Jest did not exit one second after the test run has completed" and kept holding the lock while other workers queued, so I sent SIGTERM to my own jest pid. RC 143 comes from that kill, not from a test failure. |
| 10 | `git commit -F <msg>` (no `--no-verify`) | 0 | a4d0b85c |

Banned-words test: `ImportRunVerdictCard.test.tsx › banned-words sweep over every state`. It covers every phase, every server terminal × {null, unknown, 9 reason codes}, the legacy terminals, unknown status, and the loading/notFound/error/unreadable views, with the stale label on. It also sweeps the roster page state and checks every string and a11y label for authorized, ready, connected, verified and running. It passed. The existing panel sweeps (ExtensionPairingPanel.test.tsx) also passed in runs 5 and 9.

I did not run any real-PG lane, `*.pg.spec.ts`, `rls-g2-*`, npm install/ci or prisma generate. I did not write to node_modules, did not touch another worker's clone or the runtime dirs, and did not git-commit the evidence repo.

## Findings / risks (Safety ROI)

No A or B findings.

- **C1: full-jest open handle after a green run.** Run 9 passed every suite, but the Jest process did not exit, and I killed it. I have no baseline full run on a876268c to compare. The scoped runs 5 and 7, which include all 5 new suites, exited normally, so the new suites do not hang on their own. Recorded, qualified, continuing.
- **C2: counts not surfaced.** `entity_counts` and `families[]` (staged, native buckets, qualifiers such as `roster_bridge_pending`) are not rendered. The S12 L141 scope is phase, terminal and reason. Adding them later must keep null as "not known yet".
- **C3: copy wording is the builder's plain-language choice** for the 8 statuses, 3 phases and 9 reason codes. It has no owner or UX sign-off. It avoids "running" (UX-03a panel test) and the S11-C banned words. The reason code is also shown verbatim for support.
- **C4: polling.** The card re-reads every 20 s while the run is open or `notFound`, only while the paired panel is mounted. The server throttle is 120/min. Polling stops at a recognised terminal. An `unknown` status keeps polling, which is intentional because it is not a terminal.
- **C5: roster timing.** The roster is fetched only after a recognised terminal. Whether `reconstruct/roster` is populated for a given terminal depends on the backend (IMPORTER-F/S8-F). Anything else reads "not known yet".
- **C6: dark routes.** Before S12-B6 adds `FEATURE_SCOUT_RECONSTRUCT` to the flag workflow, the roster route is dark and returns the uniform 404, so the roster section shows "not known yet" even with importReview on. That is truthful, but the section will be uninformative.
- **C7: Clone step.** The `cp -al` call hit the 630 s tool timeout. I verified completeness only by the entry count (64594 in both trees), not by an inode-level comparison. tsc and the full jest suite both resolved every module.

---

## Round 2: closing review B1–B3 (`s12b3/s12b3_review.md`, NO-GO on a4d0b85c)

| | |
|---|---|
| Parent (unchanged, no amend) | `a4d0b85c5ab39e27727ebc343062fbe2621ac934` |
| **HEAD** | **`77b9a2ad857ad78597c51095dd0a95da3c761cc3`** |
| **Tree** | **`3c7fe24d69c66c330ab7a103fffe2706c3e25149`** |
| Commit | One new commit, "S12-B3: close review B1-B3 on the run verdict card". Author and committer are Bradley Gleave &lt;bradley@bradleytgpcoaching.com&gt;, with no trailers. Plain `git commit` with no hooks installed (same as round 1). No push. Worktree is clean. |
| Diff a4d0b85c..77b9a2ad | 5 files, +228 / −19. Product code +45/−16: `importRunStatus.ts` +17/−3, `ImportRunVerdictCard.tsx` +28/−13 (41 changed lines). Tests +183/−3. |

### What changed

- **B1 (accounting truth).**
  - `DecodedRosterAccounting` gains `unclassified: number | null`. It is decoded on its own with `isCount`. It is `null` when absent (older and pinned-54be96f1 servers) or malformed (−1, 1.5, "5", null, {}). It is never 0 by default and never voids the four family counts. Extra accounting fields are tolerated and not surfaced.
  - The accounting copy now reads "Client records sorted into your roster: S (R imported, K skipped, F couldn't be imported). This count covers client records only."
  - A separate `roster-unclassified` line reads "Records that couldn't be sorted into any kind of data: U. They aren't counted above." When unclassified is null it reads "…: not known yet."
  - The backend source for these semantics is `fa72-s11d2` working tree `src/scout/scout-roster.dto.ts` (ScoutRosterAccountingDto `unclassified`, excluded from `staged`) and `scout-roster.service.ts` (`unclassified: scope.unclassified`). Those files are uncommitted S11-E work, and the pinned fixture (54be96f1) does not contain the field. So the decoder treats it as optional, and the contract test does not pin it.
  - Tests:
    - Decoder: `{0,0,0,0,unclassified:5}` decodes verbatim; absent → null; five malformed values → null only; extra fields ignored.
    - Hook: `unclassified` reaches the view as 5, and absent stays null.
    - Card: zero classified + 5 unclassified shows the 5, scopes the zeros to client records, and never shows "Found 0". A null unclassified renders "not known yet" and never ": 0".
- **B2 (unrecognised vs absent).**
  - New `NOT_RECOGNISED = 'Not recognised by this app version'`.
  - Phase `'unknown'` → step "Not recognised by this app version"; phase `null` → "Not known yet".
  - Reason `'unknown'` → "Not recognised by this app version", with no code line and the raw value never echoed; reason `null` → "Not known yet".
  - Tests cover both branches for an open run (phase), a failed run (reason) and a server `complete` with a new reason code. Each asserts that the other copy is absent.
- **B3 (page-scoped empty).**
  - With zero loaded people and `hasMore` true, the card shows `roster-empty-page` "No people on the pages loaded so far. Show more to keep looking." and keeps the "Show more" button.
  - With zero loaded people and an `incomplete` read, it shows the same message without "Show more", plus the existing incomplete note.
  - The whole-import statement "The server has no imported people to show for this import." remains only for an exhausted, complete read.
  - Tests:
    - Hook: a first page `persons:[]`, `has_more:true`, cursor `C2`, followed by a page with person `a`, ends with hasMore false and persons `['a']`.
    - Card: the empty page with more to load, and the incomplete empty case. Both assert `roster-empty` is absent and that the text never matches /no imported people/i.
- **Review C5 (one-liner).** Each recognised person state keeps its own row copy:

  | State | Row copy |
  |---|---|
  | InvitePending | "Imported, not yet joined" |
  | Invited | "Imported — marked invited, not yet joined" |
  | Claimed | "Imported — marked as joined" |
  | Suspended | "Imported — marked suspended" |
  | Deleted | "Imported — marked removed" |
  | unrecognised | "Imported — joining status not known yet" |

  "Marked" attributes the state to the server record rather than to the app. The test is parameterised over all six rows, with a banned-words check on each.
- **Review C2 (copy).** The 404 body now reads "The server didn't return a status for this import. Check again later." It no longer implies the import has not started.

### State table deltas (supersede the round-1 rows)

| Server field | UI |
|---|---|
| `phase` null / absent (running) | "Current step: Not known yet" |
| `phase` unrecognised (running) | "Current step: Not recognised by this app version" |
| `reason_code` null (non-complete terminal) | "Reason: Not known yet" |
| `reason_code` unrecognised (any server terminal, including complete) | "Reason: Not recognised by this app version" (no code line) |
| `accounting` four counts valid | "Client records sorted into your roster: S (R imported, K skipped, F couldn't be imported). This count covers client records only." |
| `accounting.unclassified` valid integer | "Records that couldn't be sorted into any kind of data: U. They aren't counted above." |
| `accounting.unclassified` absent or malformed | "Records that couldn't be sorted into any kind of data: not known yet." |
| `accounting` block malformed | "Totals: not known yet." (no unclassified line) |
| `persons` empty on loaded pages, and has_more+cursor or incomplete | "No people on the pages loaded so far." (+ " Show more to keep looking." when more remain) |
| `persons` empty, pagination exhausted, read complete | "The server has no imported people to show for this import." |
| `persons[].state` Invited / Claimed / Suspended / Deleted | Own wording (see above) |
| import/status 404 | "Import status: not known yet" + "The server didn't return a status for this import. Check again later." |

### Files at HEAD 77b9a2ad (changed this round)

| Path | + / − | sha256 |
|---|---|---|
| src/types/importRunStatus.ts | 17 / 3 | c13388614d5e165349af5ecef7fd322c7976c475d8d6a535d8d6e7fe0bb7b4cc |
| src/components/coach/ImportRunVerdictCard.tsx | 28 / 13 | 8626a77d4d84a188305f962cd73dbbbdec2e4a636ed8afdd582d4f27bc6e549c |
| src/components/coach/__tests__/ImportRunVerdictCard.test.tsx | 118 changed | 6ae94e9d89083fba11fb50d1fd5fa3268ca8c0b61d63c30161966e4689e1c735 |
| src/hooks/__tests__/useImportRunStatus.test.tsx | 36 / 0 | 33403beaae4d3f99b8fdf721c60988df4ff25e928ac50ee612d4b8a06fc1e95e |
| src/types/__tests__/importRunStatus.contract.test.ts | 32 changed | 0f452705be1109abc98b3887aa679bbc7678009b41b9b5a4b6cb878080139bdd |

The other six round-1 files and the fixture are byte-unchanged; their round-1 sha256 values still hold.

### Commands (round 2)

Each heavy command was run as `flock -w 3600 /home/user/workspace/execution/test-validation.lock bash -c '<cmd>'` with `NODE_OPTIONS=--max-old-space-size=3072`, after `[ -e …/PROOF_SLOT_FREE ]` succeeded. The script was `/tmp/s12b3_r2.sh`. No full jest was run, as instructed.

| # | Command | RC | Result |
|---|---|---|---|
| R2-1 | `npx tsc --noEmit` | 2 | A syntax error in my new hook test: an ASCII apostrophe in a single-quoted test title. |
| R2-2 | `npx eslint --max-warnings=0` (the 5 touched files) | 1 | Same parse error |
| R2-3 | Scoped jest (below) | 1 | 17/18 suites passed, 640/640 tests; the hook suite failed to parse. I fixed the title (’). Logs are kept at `/tmp/s12b3_r2a_*.log`. |
| R2-4 | `npx tsc --noEmit` (final bytes) | **0** | |
| R2-5 | `npx eslint --max-warnings=0` on the same 5 files (final bytes) | **0** | |
| R2-6 | `npx jest --runInBand --detectOpenHandles` on the round-1 related set: importRunStatus.contract, importRunStatusApi, useImportRunStatus, ImportRunVerdictCard, `ExtensionPairingPanel*` (a11y, copy, reconstruct, base, verdict), extensionImport.contract, useExtensionPairing, useReconstructCounts, importFlags, featureFlagsReleaseInlining, `ImportDataScreen*`, importReviewApi.drift, extensionPairApi | **0** | **18/18 suites and 659/659 tests passed.** No open-handle diagnostic ("Jest has detected" count 0), and the process exited on its own. |
| R2-7 | `git commit -F /tmp/s12b3_msg2.txt` | 0 | 77b9a2ad |

The run queued on the lock for about 2.5 min behind another holder. It waited through `flock -w`; the lock was not probed.

Banned-words coverage:
- The existing `ImportRunVerdictCard.test.tsx › banned-words sweep over every state` passed. Its phase-unknown and reason-unknown readings now render the new NOT_RECOGNISED copy.
- New per-test `expectNoBannedWords` checks run on the zero+unclassified card and on all six person-state rows.
- The panel sweeps in the ExtensionPairingPanel suites passed.

I did not run any real-PG lane, `*.pg.spec`, rls-g2, npm install/ci or full jest, did not touch backend or node_modules, and did not commit the evidence repo.

### Round-2 risks

- **C8: `unclassified` pinned only by code reading.** The field comes from uncommitted S11-E backend code and is not in the pinned 54be96f1 fixture, so the contract test does not pin its presence. When S11-E lands, the fixture should be re-extracted and `unclassified` pinned as a required integer. Until then the mobile code works with or without it, and shows "not known yet" when it is absent.
- **C9: new copy has no UX sign-off**, as with round-1 C3. This covers "Not recognised by this app version", the "marked …" person-state rows, and the client-records scoping.
- **C1 (full-jest post-summary hang) is unchanged.** It was not re-investigated, since full jest was out of scope this round. The scoped `--detectOpenHandles` run exited cleanly.
