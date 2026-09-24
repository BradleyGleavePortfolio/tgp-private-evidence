# S4 CodeQL closure grant (T2)

**Parent:** EXEC-CF8FF737. **Time:** 17:27Z.

## Finding

This is an **A finding scoped to the extension landing path only**.

Extension `main` requires the `codeql` check, and the repository's own SARIF gate (`scripts/check-codeql-sarif.mjs`) requires zero findings. PR #27 (S4 `91990ae9`) fails that gate with three findings. S4 introduced all three files; they do not exist on `main` `0111be66`, where CodeQL passes.

1. **`js/file-system-race`** at `scripts/lib/shipping.mjs:234`. The code checks `existsSync` and `statSync`, then calls `readFileSync` on locale `messages.json`.
2. **`js/superfluous-trailing-arguments`** at `test/auth-body-deadline.spec.js:372`. The helper `fetchImpl = async () => …` is invoked as `fetchImpl(url, init)`.
3. **`js/regex/unmatchable-caret`** at `test/package-integrity.spec.js:118`. In `/["'][^"']*(?:^|\/)(?:test\/fixtures|fixtures|__mocks__|mocks)\/…/`, the `^` can never match. As a result, a bare quoted `"fixtures/…"` or `"mocks/…"` reference is not caught. **This weakens the production-fixture exclusion assertion.**

## Harm, blocked decision and unlock

- **Harm:** S4, and UX-07 which sits on top of it, cannot land on extension `main`. The package-integrity negative check also has a real blind spot.
- **Decision blocked:** landing on extension `main`.
- **Execution unlocked:** PR #27 can go green, so a single owner approval lands S4, UX-07 and this closure.

## Minimum closure

Make one commit on `322b749a` (UX-07 on S4). It may change only these three files.

**Fix 1: file-system race.** Remove the check-then-use pattern. Read `messages.json` directly inside try/catch and map ENOENT/EISDIR to the same `_locales/${locale} has no messages.json` error. The behavior is otherwise identical.

**Fix 2: trailing arguments.** Make the `fetchImpl` stub signatures accept the passed arguments, for example `async (_url, _init) =>`, everywhere the rule flagged; there are 12 call sites. Alternatively, adjust the invocation. **No assertion changes.**

**Fix 3: unmatchable caret.** Replace the regex so a quoted specifier matches whether the fixture/mock segment comes at the start of the string or after a `/`. For example:

```
/["'](?:[^"']*\/)?(?:test\/fixtures|fixtures|__mocks__|mocks)\/[^"']*["']/
```

Add one positive self-check proving that the pattern matches both a bare and a nested fixture specifier. **If the corrected assertion now fails against a real shipped file, STOP and report it. Do not weaken the pattern.**

## Owner and worktree

**Owner:** one T2 builder. The requested route is Claude Sonnet 5 / High.

**Worktree:** a new full clone at `/home/user/workspace/worktrees/ext-s4-cq`, from `/tmp/landing/ext-full`, fetching `322b749a` from `/home/user/workspace/worktrees/ext-ux07-on-s4`. Branch `s4-cq` at `322b749a`.

**Rules:**

- Bradley is author and committer.
- One commit, with no trailers.
- Linear history.
- No push.

## Gates

These are light and need no slot:

1. `npm ci`
2. `npm test`
3. `npm run gates`

CodeQL runs remotely. The parent pushes the result to `land/s4-r6` so PR #27 carries S4, UX-07 and the CQ fix linearly, and the PR's `codeql` and `test` checks are the gate.

## Review and stop point

One independent T2 review follows. The builder writes `s4-cq/SOURCE_READY.md` and stops.
