# S4 CodeQL closure — SOURCE_READY

**Grant:** `/home/user/workspace/execution/cf8ff737/S4_CODEQL_CLOSURE_GRANT.md`
**Owner:** one T2 builder (this run). Requested route: Claude Sonnet 5 / High — no telemetry confirms the actual model/effort used; not claimed as verified.
**Repo:** tgp-importer-extension, worktree `/home/user/workspace/worktrees/ext-s4-cq` (fresh clone of `/tmp/landing/ext-full`, `322b749a` fetched from `/home/user/workspace/worktrees/ext-ux07-on-s4` refs `ux07-on-s4-linear`).

## Head, tree, parent

- **Parent (base):** `322b749a75d83378d4bb46426e15a25be0d8001b` — "feat(popup): apply Roman presentation tokens to the S4 popup and pairing page" (UX-07 on S4).
- **Head (this commit):** `aa0abd8310af7b5a5d45fe844611efbc3977d74c`
- **Tree:** `d1f9721cdc881a3649917b3bc21fc821121d61c7`
- **Author / committer:** `Bradley Gleave <bradley@bradleytgpcoaching.com>` / `Bradley Gleave <bradley@bradleytgpcoaching.com>` — verified on the landed commit (`git log --format='%an <%ae> / %cn <%ce>'`).
- **History:** linear, one commit on top of `322b749a`, no merge commits, no trailers (confirmed via `git show -s --format=%B`, no AI co-author line).
- **Branch:** `s4-cq`, not pushed anywhere. `main` in this clone still points at `0111be6` (untouched).

```
* aa0abd8 (s4-cq) fix(codeql): close the S4 CodeQL findings on shipping, auth-deadline stubs and fixture regex
* 322b749 feat(popup): apply Roman presentation tokens to the S4 popup and pairing page
* 91990ae S4 R6: revalidate the preflight owner synchronously at the notification (S4-R5-A-01)
```

## Scope discipline

Exactly the three files the grant permits, nothing else:

```
scripts/lib/shipping.mjs        | 12 +++++++++---
test/auth-body-deadline.spec.js | 24 ++++++++++++------------
test/package-integrity.spec.js  |  9 ++++++++-
3 files changed, 29 insertions(+), 16 deletions(-)
```

No other file in the repo was written. No other worktree, PG cluster, or `/home/user/workspace/execution/test-validation.lock` was touched.

## The three fixes

**Fix 1 — `js/file-system-race` (`scripts/lib/shipping.mjs:228-240`).**
Removed the check-then-use `existsSync`/`statSync` pair ahead of `readFileSync` on each locale's `messages.json`. The read is now attempted directly inside a `try`/`catch`; `ENOENT` and `EISDIR` map to the original `_locales/${locale} has no messages.json` error, any other error rethrows. Behavior at the call site is unchanged — same error message, same control flow. The unrelated `existsSync`/`statSync` check in `resolveReference` (line 63, a path-existence guard with no subsequent content read) was left alone: it is a different function, not part of the flagged race, and out of the grant's minimum closure.

**Fix 2 — `js/superfluous-trailing-arguments` (`test/auth-body-deadline.spec.js`).**
The `fetchImpl` stub in the "session refresh" describe block is invoked as `fetchImpl(url, init)` (line 372, unchanged). Fixed all 12 zero-arity definitions assigned to that variable — 9 as `async (_url, _init) =>` and 3 as `(_url, _init) =>` — to accept the arguments they are actually called with. Confirmed count matches the grant's "12 call sites" exactly (9 + 3). No assertions were changed; only stub signatures. The distinct `vi.fn(async () => ...)`-wrapped locals in the earlier `fetchWithTimeout consumer` describe block, and the `fetch:` dependency-injection properties in the `pairing` describe block (routed through `shared/pairing.js` → `shared/net.js`, a different call path CodeQL did not flag here), were left untouched — they are outside the flagged closure.

**Fix 3 — `js/regex/unmatchable-caret` (`test/package-integrity.spec.js:118`, now ~125).**
Replaced:
```
/["'][^"']*(?:^|\/)(?:test\/fixtures|fixtures|__mocks__|mocks)\/[^"']*["']/
```
with:
```
/["'](?:[^"']*\/)?(?:test\/fixtures|fixtures|__mocks__|mocks)\/[^"']*["']/
```
so a quoted fixture/mock specifier matches whether the segment is bare (`"fixtures/a.json"`) or nested after a path (`"src/nested/fixtures/a.json"`). Added one positive self-check (`"the fixture/mock reference pattern matches a bare and a nested specifier"`) proving both forms match, per the grant.

**Pre-check required by the grant, done before editing:** ran `collectShipping(root)` over the real tree with both the old and the corrected regex against every shipped `.js`/`.html` file. Neither pattern matches any real shipped file (`OLD regex flags: []`, `NEW regex flags: []`). The corrected, strictly-broader assertion does not catch a real shipped file, so no STOP was required and the pattern was not weakened — it was corrected to actually enforce what it always claimed to.

## Exact diff

Full parent→head diff saved at `/home/user/workspace/execution/cf8ff737/s4-cq/s4-cq.diff` (163 lines). Summary above; the file has the byte-exact patch.

## Gate receipts (run on this worktree, this head)

1. **`npm ci`** — clean install, 133 packages, 0 vulnerabilities, lefthook installed. Run twice (pre-edit baseline and post-commit final); both clean.

2. **`npm test`** (final, on committed head `aa0abd8`):
   ```
   Test Files  65 passed (65)
        Tests  1743 passed (1743)
      Duration  234.26s
   ```
   All 65 spec files green, including `test/auth-body-deadline.spec.js` and `test/package-integrity.spec.js` (with the new self-check test).

   **Baseline note (G08):** on the pre-edit baseline at `322b749a` (before any of the three fixes), a full-suite `npm test` run showed one flake: `test/policy-gates.spec.js > pre-commit hook semantic validation > rejects a semantic error in test JavaScript through both entrypoints` timed out at the 5000ms default under full-suite parallel load. Re-run in isolation, it passed in 3763ms. This is a pre-existing timing flake in an unrelated file at the base commit, not a regression from this change, and not one of the three files this grant permits touching. The final full-suite run on the committed head (`aa0abd8`) was clean with no flake.

3. **`npm run gates`** (final, on committed head `aa0abd8`):
   ```
   check:banned            OK: banned-token net clean (source patterns + origin/main commit identity)
   check:flags             OK: sole auth path is enabled — no dark-merged dead-end
   check:fixtures          production fixture exclusion — scanned=44 violations=0 — OK
   check:production-preflight   PASS manifest-v3 / background-worker-declared / background-worker-exists / version-format / forbidden-production-markers
   check:hooks             OK: pinned pre-commit hook semantically checks the effective 117-file production/test/scripts set and formatting
   lint (eslint --max-warnings=0)   clean
   type-check (tsc x2)     clean
   format:check (prettier)  OK: Prettier checked 52 tracked files with no ignored or unformatted file
   ```
   All eight sub-checks passed.

4. **Genuine pre-commit hook (G07/G04):** the commit went through lefthook's real pre-commit hook, not `--no-verify`. The `secrets` step needed a working `gitleaks` binary, which was missing from this sandbox; installed the real checksum-verified 8.30.0 binary via the repo's own `scripts/install-gitleaks.sh` (SHA-256-pinned download from the official GitHub release, verified against the pinned checksum before execution) into a private tooling directory outside the repo, then added it to `PATH`. All six hook steps ran for real and passed: `secrets` (gitleaks, `[]` findings), `banned`, `deploy-readiness`, `format`, `lint`, `type-check`.

5. **CodeQL SARIF gate (`scripts/check-codeql-sarif.mjs`):** per the grant, this runs remotely — the parent pushes the result to `land/s4-r6` so PR #27's `codeql` check is the gate. Not runnable locally in this closure; not claimed as run.

## Disk

Floor of 3 GiB was maintained throughout: `/` had 4.7–4.9 GiB free at every checkpoint (started at 4.9G free, ended at 4.7G free after `npm ci` + test artifacts).

## Bundle

`git bundle create` of the `s4-cq` branch, verified:
```
/home/user/workspace/execution/cf8ff737/s4-cq/s4-cq.bundle
The bundle contains this ref:
aa0abd8310af7b5a5d45fe844611efbc3977d74c refs/heads/s4-cq
The bundle records a complete history.
```

## What was not done / boundaries respected

- Never pushed anywhere (no remote push attempted).
- Never touched any other worktree (`ext-ux07-on-s4`, `prod-ci-1`, `s7-*`, `ux03*`, etc.) — read-only fetch of `322b749a` from `ext-ux07-on-s4` only, as instructed.
- Never touched any PG cluster.
- Never touched `/home/user/workspace/execution/test-validation.lock`.
- No files written outside this clone and `/home/user/workspace/execution/cf8ff737/s4-cq/`.
- No AI co-author trailer; no invented review or telemetry claim. The requested route was Claude Sonnet 5 / High; this report does not certify that route ran, since no telemetry exists to prove it.

## Stop point

Builder work is complete. This file and the diff/bundle are the deliverable. Per the grant, one independent T2 review follows next; this builder stops here.
