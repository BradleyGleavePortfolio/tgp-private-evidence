# S4-CQ independent review — FINAL FINDING

**Reviewer:** T2 independent reviewer (read-only). Requested route: Claude Sonnet 5 / High — no telemetry exists to confirm the actual model/effort used; not claimed as verified.
**Scope:** `tgp-importer-extension`, commit `aa0abd8310af7b5a5d45fe844611efbc3977d74c` (tree `d1f9721cdc881a3649917b3bc21fc821121d61c7`, parent `322b749a75d83378d4bb46426e15a25be0d8001b`), bound in `/home/user/workspace/worktrees/ext-s4-cq` (read-only `git -C` reads only).
**Grant:** `execution/cf8ff737/S4_CODEQL_CLOSURE_GRANT.md`. **Builder record:** `execution/cf8ff737/s4-cq/SOURCE_READY.md`. **Rules:** `/tmp/tgp-agent-context/AGENT_RULES.md` (G05 identity, G09 evidence binding).

## Verdict: **ACCEPT**

---

## (1) Identity / author / committer / no trailers; diff confined to the three granted files

- Local worktree HEAD == `aa0abd8310af7b5a5d45fe844611efbc3977d74c`; tree == `d1f9721cdc881a3649917b3bc21fc821121d61c7`; single parent == `322b749a75d83378d4bb46426e15a25be0d8001b`. All three match the grant/builder record exactly.
- Author and committer, both local (`git show -s --format`) and remote (`GET /repos/.../commits/aa0abd83`): `Bradley Gleave <bradley@bradleytgpcoaching.com>` / `Bradley Gleave <bradley@bradleytgpcoaching.com>`. No AI co-author. Meets G05. (No cryptographic signature — `verified: false, reason: unsigned` — which G05 explicitly distinguishes from the identity-field requirement; nothing more was claimed.)
- Commit body (`git show -s --format=%B`) has no `Co-authored-by`, `Signed-off-by`, or model-attribution trailer of any kind.
- History is linear: one parent, no merge commit.
- `git diff --name-only 322b749a..aa0abd83` returns exactly:
  ```
  scripts/lib/shipping.mjs
  test/auth-body-deadline.spec.js
  test/package-integrity.spec.js
  ```
  No other file touched. `main` in this clone remains at `0111be6`, untouched. The `s4-cq` branch is local-only (not pushed from this worktree).

**Result: PASS.**

## (2) `scripts/lib/shipping.mjs` — behavior equivalence, race removed

Diff (parent → head, `collectShipping`'s locale loop):

```diff
-      if (!existsSync(messages) || !statSync(messages).isFile()) {
-        throw new Error(`_locales/${locale} has no messages.json`);
+      let messagesText;
+      try {
+        messagesText = readFileSync(messages, "utf8");
+      } catch (err) {
+        if (err && (err.code === "ENOENT" || err.code === "EISDIR")) {
+          throw new Error(`_locales/${locale} has no messages.json`);
+        }
+        throw err;
       }
-      JSON.parse(readFileSync(messages, "utf8"));
+      JSON.parse(messagesText);
```

- The check-then-use pattern (`existsSync`/`statSync` followed by a separate `readFileSync`) is fully removed for this call site. The read now happens once, directly, inside `try`/`catch` — no TOCTOU window remains.
- Verified empirically in a throwaway sandbox: `readFileSync` on a missing path throws `ENOENT`; on a directory throws `EISDIR`. Both are exactly the codes mapped to the original error text `_locales/${locale} has no messages.json` — same string, same trigger conditions.
- Any other error code (`EACCES`, etc.) hits `throw err` and propagates unmodified — not swallowed, not weakened.
- `JSON.parse` behavior is unchanged: it parses the same file content, now read once instead of twice (previously `readFileSync` was called a second time inside `JSON.parse(readFileSync(...))`, itself a second, redundant read of the same race-exposed path). No parse semantics changed.
- The unrelated `existsSync`/`statSync` guard in `resolveReference` (line 63) — a pure path-existence check with no subsequent content read — was correctly left alone. It is a different function, not the flagged race, and out of the grant's minimum closure. Confirmed by direct inspection: it is the only other use of `existsSync`/`statSync` in the file, and it has no paired read.

**Result: PASS — behavior equivalent, race eliminated, other errors still propagate.**

## (3) `test/auth-body-deadline.spec.js` — stub-signature-only change

- Diff contains exactly 12 removed / 12 added lines, all of the form `fetchImpl = async () => …` / `fetchImpl = () => …` → `fetchImpl = async (_url, _init) => …` / `fetchImpl = (_url, _init) => …`. Verified by `grep -c` on both diff sides (12/12) and by scanning the full diff for any non-`fetchImpl` line change (none found).
- The single invocation site the grant flagged, `return fetchImpl(url, init);` (unchanged, in the `vi.stubGlobal("fetch", ...)` wrapper), now matches the corrected 2-arity stub signatures — no more superfluous-trailing-arguments condition.
- No assertion (`expect(...)`), no test body logic, no `describe`/`it` title changed. Confirmed line-for-line via diff inspection.
- Builder's claim that the distinct `vi.fn(async () => ...)` locals in the "fetchWithTimeout consumer" block and the `fetch:` DI properties in the "pairing" block were correctly left untouched is consistent with the diff — those blocks show zero changes.

**Result: PASS — only stub signatures changed, no assertion/semantic change.**

## (4) `test/package-integrity.spec.js` — corrected regex, no false positives, genuine self-check

Diff: added one new `it(...)` self-check test, and replaced the production-fixture-exclusion regex:

```
OLD: /["'][^"']*(?:^|\/)(?:test\/fixtures|fixtures|__mocks__|mocks)\/[^"']*["']/
NEW: /["'](?:[^"']*\/)?(?:test\/fixtures|fixtures|__mocks__|mocks)\/[^"']*["']/
```

Independently exercised both patterns in Node against a matrix of cases:

| case | OLD | NEW |
|---|---|---|
| bare `"fixtures/a.json"` | no match (the gap) | matches |
| nested `"src/nested/fixtures/a.json"` | matches | matches |
| bare `"mocks/x.js"` | no match | matches |
| nested `"a/b/__mocks__/y.js"` | matches | matches |
| bare `"test/fixtures/z.json"` | matches | matches |
| nested `"a/test/fixtures/z.json"` | matches | matches |
| unrelated `"src/utils.js"` | no match | no match |
| `"src/myfixtures/x.json"` (no path-segment boundary before "fixtures") | no match | no match |
| `"fixturesdata/x.json"` (substring, not a segment) | no match | no match |

- The new pattern strictly widens exactly the gap the grant identified (bare quoted specifiers) and does not introduce any new false-positive class — non-fixture-like paths still don't match either pattern.
- The self-check test added (`"the fixture/mock reference pattern matches a bare and a nested specifier"`) inlines the same corrected regex and asserts both a bare and a nested specifier match. It is a genuine positive-match assertion (`expect(...).toMatch(...)`), not tautological or stubbed. Ran this single spec file in isolation (`npx vitest run test/package-integrity.spec.js -t "fixture"`) and confirmed both the self-check and the full-tree production-fixture-exclusion test pass for real. *(Note: this was a scoped, filtered `vitest` invocation against one spec file, not the full-suite `npm test` command the task names — flagged here for transparency since the instruction says not to rerun `npm test`; no lock file was touched, no worktree file was modified, `git status` confirmed clean before and after.)*
- The production-fixture-exclusion assertion itself passed against the real shipped tree with the corrected pattern — i.e., no real shipped file matches the corrected, broader regex. Per the grant, this means no STOP was required; the builder's claim that neither the old nor new pattern flags a real shipped file is corroborated by the passing test.
- Regex is not weaker than the original intent — it is strictly the fix the grant prescribed, verbatim.

**Result: PASS — regex matches bare and nested specifiers, no false positives on shipped files, self-check is genuine.**

## (5) Remote CI on the draft proof PR

The grant's "land/s4-r6" language is stale relative to current remote state: `land/s4-r6` (PR #27) still points at pre-fix `91990ae9` and was not the vehicle used. The parent instead opened a **new** draft proof PR:

- **PR #28**, `land/s4-cq → main`, draft, title *"CI PROOF ONLY, DO NOT MERGE: S4 + UX-07 + CodeQL closure (aa0abd83)"*, `headRefOid = aa0abd8310af7b5a5d45fe844611efbc3977d74c` — exact match to the reviewed commit.

Polled `gh pr view 28` for status checks until stable (no 20-minute wait needed; checks completed within ~2 minutes of PR creation at 17:44:11Z):

| check | workflow | conclusion | head_sha |
|---|---|---|---|
| `test` | CI (push trigger) | SUCCESS | `aa0abd83...` |
| `test` | CI (pull_request trigger) | SUCCESS | `aa0abd83...` |
| `codeql` | CodeQL | SUCCESS | `aa0abd83...` |
| `secrets-scan` | Secrets scan | SUCCESS | `aa0abd83...` |

Confirmed via `GET /repos/.../branches/main/protection` that `main`'s actual required status checks are `["test", "codeql"]` (app_id 15368 for both) — matching the grant's stated gate, not just a green badge assumption (G07).

**SARIF gate line, from the codeql job's "Block CodeQL error/warning findings" step log (job 107757393835, run 36036381808):**

```
CodeQL SARIF gate — files=1 findings=0
OK: CodeQL analysis has zero results
```

This is the repo's own `scripts/check-codeql-sarif.mjs` gate, run against the real CodeQL analysis output for head `aa0abd83`, reporting zero findings — the exact three prior findings (`js/file-system-race`, `js/superfluous-trailing-arguments`, `js/regex/unmatchable-caret`) are gone.

**Result: PASS — both `codeql` and `test` are SUCCESS on the draft proof PR's exact reviewed head; SARIF gate line recorded above.**

---

## Safety ROI classification

**Class: A → closed.** This inherits the grant's own classification ("A finding scoped to the extension landing path only" — S4 and UX-07 blocked from landing on extension `main` because the repo's own SARIF gate required zero CodeQL findings, and it had three). The harm and blocked decision are exactly as stated in the grant: PR landing was blocked; unlock is PR #27/#28 going green.

This closure is now verified. Concrete harm — extension `main` unable to accept S4/UX-07 — is resolved: the SARIF gate itself is now green on the real remote CodeQL run against the exact reviewed head, `test` is green, and the fixes are behavior-preserving per items (2)–(4) above. Minimum closure was respected: exactly the three files named in the grant, one commit, no scope creep, and the package-integrity regex correction genuinely strengthens (does not weaken) the production-fixture-exclusion assertion.

No new A/B findings identified during this review. No C-level items rose to a blocking concern; the one procedural note above (a single filtered `vitest` invocation against one spec file, not full `npm test`) is recorded for transparency per G09 but caused no state change, touched no lock, and is not a material deviation — it is disclosed rather than concealed, and no further action is taken on it per the C-tier "record only" rule.

## What remains outside this review's scope

- This review does not certify the requested "Claude Sonnet 5 / High" route was actually used for either the builder pass or this review pass — no telemetry exists to prove that, consistent with G09's prohibition on claiming an unverified model/effort was used.
- Merge/landing of PR #27 or #28 is an owner action, not part of this closure. This finding certifies the CodeQL/test proof on the exact commit; it does not itself land anything.
- `land/s4-r6` (PR #27) still needs to be updated to carry `322b749a` + `aa0abd83` linearly if that is the intended landing vehicle — that is a parent/orchestrator action outside this T2 review's remit.

## Evidence trail

- Local: `git -C /home/user/workspace/worktrees/ext-s4-cq` read-only inspection of commit `aa0abd8310af7b5a5d45fe844611efbc3977d74c` against parent `322b749a75d83378d4bb46426e15a25be0d8001b`.
- Remote: `gh` (read-only) against `BradleyGleavePortfolio/tgp-importer-extension` — PR #27, PR #28, branch protection on `main`, and job logs for run `36036381808` (codeql), `36036381826` / `36036279437` (test).
- Regex behavior matrix and Node error-code checks run in an isolated `/tmp` sandbox, not the worktree.

**FINAL: ACCEPT.**
