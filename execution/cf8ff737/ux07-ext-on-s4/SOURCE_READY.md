# SOURCE_READY: UX-07 extension presentation composed onto S4

**T2 builder, single lane.** Parent: EXEC-CF8FF737 (`UX07_EXT_ON_S4_COMPOSITION_GRANT.md`). Scope: apply the accepted UX-07 token styling to S4's new popup elements, resolving the one genuine `popup/popup.html` conflict between `91990ae9` (S4) and `6fd7e4a9` (UX-07 extension presentation). No push performed. No remote touched. No other worktree, PG cluster, or `execution/test-validation.lock` touched.

**Not claimed:** CI, mergeability, deployment, packaged-extension/browser runtime behavior, or customer readiness. This is local source, tests, and static gates only, exactly as scoped.

## Merge route used

**Ordinary merge commit**, per the grant's primary instruction (no linear-history enforcement was found in this checkout's CI/branch config — `.github/workflows/*` and `lefthook.yml` show no fast-forward-only or linear-history requirement). Author and committer are both `Bradley Gleave <bradley@bradleytgpcoaching.com>` on both commit fields; no AI co-author, no trailers.

## Head, tree, parents

| Item | Value |
|---|---|
| HEAD | `14fc6ab933637918423ea0e307fa052355761952` |
| Tree | `cce803153b7114dc3941a4ff6a6d43fff483685a` |
| Parent 1 (S4, `91990ae9`) | `91990ae9aec72f47a67591892ac09fa1f59d2f16` |
| Parent 2 (UX-07 extension, `6fd7e4a9`) | `6fd7e4a95ec2bc400cb8bec62a95955280a31f12` |
| Author | `Bradley Gleave <bradley@bradleytgpcoaching.com>` |
| Committer | `Bradley Gleave <bradley@bradleytgpcoaching.com>` |
| Subject | `merge: apply UX-07 token styling to S4 extension popup` |
| Trailers | none |
| Branch | `ux07-on-s4` in `/home/user/workspace/worktrees/ext-ux07-on-s4` |

## Diff against `91990ae9`

```
 popup/pair.html  | 115 ++++++++++++++++++++++++---------
 popup/popup.html | 193 ++++++++++++++++++++++++++++++++++++++-----------------
 2 files changed, 218 insertions(+), 90 deletions(-)
```

Only the two allowed paths changed (`git diff --name-only 91990ae9 HEAD` returns exactly `popup/pair.html` and `popup/popup.html`). Full patch: `ux07-on-s4.patch` (SHA-256 `95e25b0c4a4ef03511818b75d79e94cec1bc8b70bfaf6c8c4d0a25874c5a23f9`).

`popup/pair.html` merged with **no conflict** (S4 never touched this file — confirmed by `git show 91990ae9 --stat -- popup/pair.html` returning empty); its content is exactly UX-07's `6fd7e4a9` version, verified byte-identical by diff.

### The conflict and its resolution

`git merge-tree 91990ae9 6fd7e4a9` reported exactly one conflict, in `popup/popup.html`, at two independent hunks inside `<style>`:

**Hunk 1 — `body` background/color/sizing:**
```diff
       body {
-        width: 340px;
-        max-width: calc(100vw - 32px);
-        margin: 0;
-        padding: 16px;
-        font:
-          14px/1.45 system-ui,
-          sans-serif;
-        background: #0f172a;
-        color: #f8fafc;
+        width: 22.5rem;
+        max-width: 100%;
+        margin: 0;
+        padding: 1.25rem;
+        font: 0.9375rem/1.5 var(--font-body);
+        background: var(--bone);
+        color: var(--ink);
       }
```
Resolution: kept UX-07's side (Roman token system, `22.5rem` layout width per the accessibility bar's no-overflow requirement).

**Hunk 2 — `.status-*` color rules:**
```diff
-      .status-created { color: #38bdf8; }
-      .status-ingest_started { color: #fbbf24; }
-      .status-ingest_succeeded { color: #22c55e; }
-      .status-ingest_partial { color: #fbbf24; }
-      .status-ingest_empty { color: #fbbf24; }
-      .status-ingest_failed { color: #f87171; }
+      .status-created { color: var(--ink); }
+      .status-ingest_started { color: var(--forest); }
+      .status-ingest_succeeded { color: var(--forest); }
+      .status-ingest_partial { color: var(--ink); }
+      .status-ingest_empty { color: var(--ink); }
+      .status-ingest_failed { color: var(--error); }
```
Resolution: kept UX-07's token mapping unchanged (these selectors exist verbatim in both sides; UX-07's values already satisfy contrast on the bone/cream background — see contrast table).

**Beyond the two git-flagged hunks**, the grant requires applying the accepted token system to every *new* S4 element that git's line-based merge left on the old dark palette, since those selectors are additions rather than line-level conflicts (`#outcome-coverage`/`#outcome-native`/`#outcome-no-receipt`, `#outcome-guidance`, `.transfer-family` and its `p + p` caution rule, `details`/`summary`, `#intent-id`, `.actions`/`.actions button`, `#action-feedback`, `h2`, `h3`, `p`, `#error` word-wrap). Each was re-expressed in the token system (`--bone`, `--cream`, `--ink`, `--forest`, `--muted`, `--line`, `--error`, `--error-surface`, `--focus-ring`), following UX-07's own patterns for the equivalent selectors it already carried (`.row`, `.label`, `#empty`, `#start-import`, focus-visible, reduced-motion). No id, class, `hidden` attribute, `aria-*` attribute, text node, or script reference was added, removed, or renamed — only `style`/presentation attributes and the `<style>` block content changed, as the grant requires.

Full resolved `<style>` block is in `popup/popup.html` lines 7–226 of the committed tree.

## S4-invariance proof

**1. Markup/body byte-identity (style-stripped):** Both `popup/popup.html` and `popup/pair.html`, with their entire `<style>...</style>` block removed, are byte-identical to the corresponding S4 (`91990ae9`) file content. Verified programmatically (regex strip + `diff`, both empty):
```
popup.html: style-stripped identical to S4 = True  (diff: no output)
pair.html:  style-stripped identical to S4 = True  (diff: no output)
```

**2. `popup/popup.js` unchanged:**
```
$ git diff 91990ae9 HEAD -- popup/popup.js
(empty)
```

**3. Every other tracked path unchanged:**
```
$ git diff 91990ae9 HEAD -- . ":(exclude)popup/popup.html" ":(exclude)popup/pair.html"
(empty)
$ git diff --name-only 91990ae9 HEAD -- . ":(exclude)popup/popup.html" ":(exclude)popup/pair.html"
(empty)
```

No id, class, `hidden` attribute, `aria-*` attribute, text node, or script reference in S4's markup was touched. Only the `<style>` block and (unchanged) presentation attributes in the two allowed files changed.

## Contrast table

All pairs use the actual rendered background for that element. WCAG relative-luminance formula, independently computed (not reused from prior review without recomputation, since new pairs are introduced here).

| Text/UI on background | Foreground | Background | Ratio | Threshold | Pass |
|---|---|---|---|---|---|
| Body text (`--ink` on `--bone`) | `#17251f` | `#f7f4ec` | 14.465:1 | 4.5:1 | ✅ |
| `#empty` box text (`--ink` on `--cream`) | `#17251f` | `#fffdf8` | 15.640:1 | 4.5:1 | ✅ |
| `.label` / `.transfer-family p + p` caution text (`--muted` on `--bone`) | `#53655b` | `#f7f4ec` | 5.652:1 | 4.5:1 | ✅ |
| `.label` on `--cream` | `#53655b` | `#fffdf8` | 6.111:1 | 4.5:1 | ✅ |
| `.status-ingest_started` / `_succeeded` (`--forest` on `--bone`) | `#16533c` | `#f7f4ec` | 8.177:1 | 4.5:1 | ✅ |
| `--forest` on `--cream` | `#16533c` | `#fffdf8` | 8.841:1 | 4.5:1 | ✅ |
| `.status-ingest_failed` / `#error` text (`--error` on `--bone`) | `#7e231b` | `#f7f4ec` | 8.914:1 | 4.5:1 | ✅ |
| `#error` box text (`--error` on `--error-surface`) | `#7e231b` | `#fbece8` | 8.522:1 | 4.5:1 | ✅ |
| `#error` box border, non-text (`--error` on `--error-surface`) | `#7e231b` | `#fbece8` | 8.522:1 | 3:1 | ✅ |
| `.row` / `.transfer-family` divider border, non-text (`--line` on `--bone`) | `#cbd2c8` | `#f7f4ec` | 1.406:1 | 3:1 (n/a — see note) | note |
| `#empty` box border (`--line` on `--cream`) | `#cbd2c8` | `#fffdf8` | 1.520:1 | 3:1 (n/a — see note) | note |
| `.actions button` border, non-text control (`--muted` on `--cream`) | `#53655b` | `#fffdf8` | 6.111:1 | 3:1 | ✅ |
| `#start-import` label (white on `--forest`) | `#ffffff` | `#16533c` | 8.987:1 | 4.5:1 | ✅ |
| `#start-import` hover (white on `--forest-pressed`) | `#ffffff` | `#0f432f` | 11.265:1 | 4.5:1 | ✅ |
| `#start-import:disabled` text (`--ink` on `#aeb9b0`) | `#17251f` | `#aeb9b0` | 7.848:1 | 4.5:1 | ✅ |
| `:focus-visible` outline, non-text (`--focus-ring` on `--bone`) | `#0f4b37` | `#f7f4ec` | 9.177:1 | 3:1 | ✅ |
| `:focus-visible` outline on `--cream` | `#0f4b37` | `#fffdf8` | 9.922:1 | 3:1 | ✅ |

**Note on `--line`:** `.row`, `.transfer-family`, and `#empty` use `--line` (`#cbd2c8`) only as a plain decorative divider/rule, never as the border of an actionable control (button, input, or other interactive element) and never as the sole indicator of state or boundary a user must perceive to operate the UI. WCAG 2.2's 3:1 non-text-contrast requirement (1.4.11) applies to UI components and their boundaries, not to purely decorative separators — this is the same distinction the accepted UX-07 review applied when it left `.row` borders on `--line` unchanged and closed A-01 (the *input* border) separately by moving it to `--muted`. Every border that is part of an interactive control's visible boundary in this composition (`.actions button`, `#error`, `:focus-visible`) uses `--muted`, `--error`, or `--focus-ring`, each of which clears 3:1 as tabled above. This is the identical treatment `.row`'s border already received in the R2-accepted UX-07 file, carried forward unchanged; no new decorative-border defect was introduced.

**Caution copy (`.transfer-family p + p`):** the S4 dark theme used `#fbbf24` (yellow) on `#0f172a`. That selector renders the "unconfirmed" line inside each per-platform outcome section built by `popup.js` (`row.appendChild` for `[tag, text]` pairs, second `<p>` = `line.unconfirmed`). Resolved to `--muted` (`#53655b`) at `font-weight: 600` on `--bone`/`--cream` — 5.652:1 / 6.111:1, clears 4.5:1, and reads as secondary/cautionary emphasis (heavier weight, not a color statement of failure), distinct from `--error` which is reserved for `#error` and `.status-ingest_failed`. This satisfies the grant's explicit instruction not to reuse the dark theme's yellow and not to read as error.

## Accessibility bar checklist

- **Contrast:** every text/background and non-text/background pair introduced or recolored is tabled above; all clear their threshold.
- **Caution vs. error:** `.transfer-family p + p` uses `--muted`, not `--error`; visually distinct from `#error`/`.status-ingest_failed` (`--error`). Confirmed above.
- **Targets:** `.actions button` `min-height: 2.75rem` (44px) unchanged in spirit from S4's `44px`; `summary` set to `min-height: 2.75rem` (44px) with `display:flex; align-items:center` so the clickable row itself, not just the text baseline, meets the target — S4's original `summary` was `min-height: 28px`, raised to close a real target-size gap the grant's bar requires. `#start-import` `min-height: 3rem` (48px), already ≥44px.
- **Focus visibility:** `button:focus-visible, summary:focus-visible { outline: 3px solid var(--focus-ring); outline-offset: 3px; }` — carried from UX-07, extended to `summary` since S4 added it. 9.177:1/9.922:1 non-text contrast, tabled above.
- **Motion:** the only transitions are `.actions button` hover (160ms) and `#start-import` hover/focus (160ms), both already covered by the existing `@media (prefers-reduced-motion: reduce)` block (unchanged from UX-07, applies to `*`/`*::before`/`*::after` transition-duration).
- **Layout/overflow:** `body { width: 22.5rem; max-width: 100% }` (UX-07's value, kept). `#intent-id { overflow-wrap: anywhere }` unchanged from S4 markup/CSS-selector-list (long ids wrap). `#error { overflow-wrap: anywhere }` carried. No fixed-width element wider than `22.5rem` was introduced.
- **One concept per moment / hidden complexity:** no structural change was made (markup is byte-identical to S4), so this governs visual weight only, per the grant. `#intent-id`/`details` stay visually secondary: `details`/`summary` render in `--muted`/`--ink` at `0.875rem`, below the `h1`/`h2` heading weight, and the technical `Intent`/`Platform` rows stay inside the collapsed `<details>` exactly as S4 built them.
- **No mascot/gamification:** no mascot, streak, badge, leaderboard, or decorative motion was added; none existed in S4's markup and none was introduced here.

## Design sources applied

1. Accepted UX-07 styling and review records — [`EXTENSION_PRESENTATION_ACCEPTANCE.md`](file:///tmp/tgp-private-evidence/execution/95633079/ux/EXTENSION_PRESENTATION_ACCEPTANCE.md), [`extension-review/UX07_EXTENSION_T1_R2_A01_ADDITIVE_CLOSURE.md`](file:///tmp/tgp-private-evidence/execution/95633079/ux/extension-review/UX07_EXTENSION_T1_R2_A01_ADDITIVE_CLOSURE.md) (A-01 input-border closure: `--muted` border on `--cream`, 6.111:1 — the same token pair reused here for `.actions button`), [`extension-review/UX07_EXTENSION_T1_R2_FINAL_ACTUAL_ATTESTATION.md`](file:///tmp/tgp-private-evidence/execution/95633079/ux/extension-review/UX07_EXTENSION_T1_R2_FINAL_ACTUAL_ATTESTATION.md).
2. Project UX doctrine applicability — [`UX_DOCTRINE_APPLICABILITY.md`](file:///tmp/tgp-private-evidence/execution/cf8ff737/ux-doctrine/UX_DOCTRINE_APPLICABILITY.md): one concept per moment (no new structure added, so applied to visual weight only), caution-not-failure copy treatment, hidden-complexity (`details`/`#intent-id` stay secondary), no mascot/gamification.
3. Bradley's mobile design doctrine docx (`Mobile-App-Design-Intelligence-Exhaustive-Agent-Training.docx`, extracted via `python-docx`), applied as generic guidance subordinate to 1 and 2:
   - Part VII.2 ("Hide the Work: The Invisible Interface Doctrine") and VII.3 ("Cognitive De-Load as Performance Engineering," including "one concept per moment... present exactly one decision at a time") — supports keeping `details`/`#intent-id` visually secondary and not adding competing visual weight to the new S4 elements.
   - Part II.2 ("Treat error states as trust-building opportunities... 'Something went wrong' destroys trust") — supports the caution-copy weight decision (informational emphasis, not alarm) for `.transfer-family p + p`; no copy text was changed, only its visual treatment.
   - Part III ("The PBL Fallacy... Points, Badges, and Leaderboards... the most thoroughly documented failures") — confirms the no-gamification constraint; nothing in this composition adds points/badges/leaderboards/streaks.

## Gate receipts

| Gate | Command | RC | Result |
|---|---|---|---|
| 1 | `npm ci` | 0 | 133 packages added, 0 vulnerabilities. Disk before: 3.8 GB free; after: 3.4 GB free (floor: 3 GiB — not breached). |
| 2 | `npm test` | 0 | 65 test files / 1742 tests, all passed. |
| 3 | `npm run gates` | 0 | `check:banned` OK, `check:flags` OK (`PAIRING_ENABLED=true`), `check:fixtures` OK (44 scanned, 0 violations), `check:production-preflight` OK (5/5 static checks), `check:hooks` OK (117-file set), `lint` OK (0 eslint warnings/errors), `type-check` OK (`tsc` clean, both configs), `format:check` OK (52 tracked files, Prettier clean). |

No nonzero gate result occurred; no stop condition was triggered.

**Baseline note (not a gate, informational):** the first `npm test` attempt on the unmodified S4 checkout (before this merge existed) hit a transient failure — `test/policy-gates.spec.js` timed out at 5000ms on a subprocess-spawning hook-semantics test, under measured sandbox load average 11.5 on 2 vCPUs. A clean rerun of the identical unmodified baseline immediately after (rc=0, same 65/65, 1742/1742) confirms this was sandbox CPU contention, not a source defect in S4 or in this composition. This is recorded for transparency; it predates and is independent of this grant's edit, and did not recur in any gate run against the actual candidate (HEAD `14fc6ab9`).

**Local tooling note:** the pre-commit `secrets` hook step initially failed with `gitleaks unavailable`. This is a missing local binary, not a source/policy finding. `scripts/install-gitleaks.sh` (checksum-pinned, HTTPS-only, install-only into a private local directory `/home/user/workspace/.local-tooling`, no repo/policy file changed) was run once to install gitleaks `8.30.0`, matching the version the repo's own `secrets-scan.sh` requires. The commit was then retried and passed cleanly through the full genuine hook chain (`banned`, `secrets`, `deploy-readiness`, `lint`, `format`, `type-check`), all ✔️. No hook was bypassed, disabled, or substituted.

## Bundle and patch

- Bundle: `execution/cf8ff737/ux07-ext-on-s4/ux07-on-s4.bundle` — `git bundle verify` returns OK. Contains ref `HEAD` = `14fc6ab933637918423ea0e307fa052355761952`, requiring base refs `91990ae9...` and `0111be66...`. SHA-256: `0591c3c9cb36786257ca3323946f62396ad9468c5be9407d152bb22b78ff611d`.
- Patch: `execution/cf8ff737/ux07-ext-on-s4/ux07-on-s4.patch` — `git diff 91990ae9 HEAD`, 2 files changed, 218 insertions, 90 deletions. SHA-256: `95e25b0c4a4ef03511818b75d79e94cec1bc8b70bfaf6c8c4d0a25874c5a23f9`.

## Stop / next action

No gate returned nonzero. No stop condition was triggered. This grant's scope is complete: the merge commit exists on `ux07-on-s4` in the assigned worktree, S4-invariance is proven, the contrast table is computed and passes, and all three local gates are clean.

Per the grant, this agent stops here. The parent pushes `ux07-on-s4` to `land/ux07-on-s4` for the deterministic remote CI gate and dispatches the independent T2 reviewer. No push, remote action, or review was performed by this builder.

## Parent addendum (17:16Z): linear-history form

Extension `main` branch protection requires linear history. The builder could not see this, because it is enforced on the remote and not in CI or hooks. A merge commit therefore cannot land on `main`, and GitHub's rebase-merge would drop the conflict resolution.

The parent created a linear commit with an identical tree. The reviewed and landed identity is this linear commit:

| Item | Value |
|---|---|
| Commit | `322b749a75d83378d4bb46426e15a25be0d8001b` |
| Tree | `cce803153b7114dc3941a4ff6a6d43fff483685a`, identical to merge `14fc6ab9` |
| Parent | S4 `91990ae9` only |
| Author and committer | Bradley |
| Trailers | none |

- **Pushed:** `land/ux07-on-s4`, for remote CI (`test` and `codeql`).
- **Local gates:** the gate receipts above apply unchanged, because the tree is identical.
- **Merge `14fc6ab9`:** kept locally for history.
