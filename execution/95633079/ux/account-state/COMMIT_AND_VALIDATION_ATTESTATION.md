# UX-01 account-state — ordinary commit + minimum targeted validation: actual results

Outcome: **commit made exactly as approved; validation STOPPED at the first nonzero (stage 1 of 4). 1 of 56 tests failed; the failing assertion is a test-timing expectation in the new hook test, not observed product misbehaviour. No fix applied, no retry, no gate expansion. Disposition required.** Lock released; zero owned survivors.

## Grant honoured

- Heavy slot: `execution/test-validation.lock` acquired nonblocking (`flock -n`, fd 200) at 2026-09-24T06:45:35Z, released 06:48:30Z (`validation-receipts/00-lock-status.txt`). No other holder was present; nothing of another holder was touched.
- Runner: `validation-receipts/ux01-commit-validate.sh` (sha256 recorded below), stdout in `validation-receipts/launcher-stdout.log`. First nonzero stops; raw logs/status files written before this report.
- No remote write, no deploy, no browser, no npm install/ci, no S6/C6/full coach suite, no package run.

## 1. Ordinary commit (FIRST, per A) — done

| Item | Value |
|---|---|
| Worktree / branch | `worktrees/ux01-state` / `ux01-account-state` |
| Parent | `bc7b4e96fc1db54568bc209dbe1f7a4121501ac9` (accepted base) |
| **Commit** | **`327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`** |
| **Tree** | **`a33cb8919495ed24e30623188dbb9f59c67df8bd`** = reviewed candidate tree (A/B SOURCE_GRANTABLE), unchanged |
| Author | `Bradley Gleave <bradley@bradleytgpcoaching.com> 1790232336 +0000` |
| Committer | `Bradley Gleave <bradley@bradleytgpcoaching.com> 1790232336 +0000` |
| Identity source | repo-local `.git/config` `user.name`/`user.email` set in this standalone worktree (global config carried no identity; `git var` verified before commit, `01-preflight.txt`) |
| Hooks | `core.hooksPath` unset; `.git/hooks` contains only `*.sample`; no `--no-verify` or any bypass flag used (`git commit -q -F COMMIT_MESSAGE.txt`) |
| Message | byte-exact handoff §7 text (`COMMIT_MESSAGE.txt` sha256 `d5e08a01…4165f`; `02-commit-message-actual.txt` differs only by git's one appended `\n`, verified by `diff`); `git interpret-trailers --parse` → 0 trailers; no co-author |
| Raw object | `validation-receipts/02-commit-object.txt` (`git cat-file commit HEAD`) |
| `git status --porcelain` after commit | empty |
| `git status --porcelain` after node_modules copy and after the stop | empty (node_modules is gitignored) |

Durability exports (of the committed candidate, NOT a passing attestation):
- `ux01-account-state-327731d4.bundle` sha256 `aa9c155e955ace329944144d93e3a0ab10cadef2e6a71ea140ce5f3d754bf65b` (`git bundle verify`: complete history)
- `0001-ux01-account-state-327731d4.patch` (`git format-patch -1`) sha256 `55b510c231f0d38687b8f1a0afe1603e5a94fb26309bc4a5e7cec6e0fc59a1ec`

## 2. Environment reuse — done, recorded (`validation-receipts/03-env-reuse.txt`)

- Node `v20.20.1`, npm `10.8.2` (`/usr/local/bin`), same as the accepted sibling receipt.
- `package.json` and `package-lock.json` byte-identical to `worktrees/ux07-mobile` (`cmp`); lock sha256 `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`.
- Sibling installed record `node_modules/.package-lock.json` sha256 `c4d7824b8b519c4a1720f13deb37b3d65e3f9987aca7734e352cee0ed0ac450b`; sibling accepted install receipt `npm ci exit_status=0 duration_s=367` preserved in place (`execution/95633079/ux/mobile-presentation/validation-receipts/03-npm-ci*.{log,txt}`), not modified.
- `cp -a --reflink=auto worktrees/ux07-mobile/node_modules worktrees/ux01-state/node_modules` rc=0, 166 s, 768M; `node_modules` is a real directory, 0 top-level symlinks; copied `.package-lock.json` sha256 identical (`c4d7824b…`). No `npm ci`. No network package resolution; only `./node_modules/.bin/{jest,tsc,eslint}` were invoked.

## 3. Validation on the committed, unchanged tree — STOPPED at stage 1

| # | Command (from worktree root, bounded, TERM+30s) | RC | Duration | Result |
|---|---|---|---|---|
| 1 | `./node_modules/.bin/jest --ci --runInBand src/storage/__tests__/importOfferDecision.test.ts src/hooks/__tests__/useImportOfferDecision.test.tsx` (unfiltered) | **1** | 5 s | Suites: 1 passed (storage), 1 failed (hook). Tests: **55 passed, 1 failed, 56 total**. |
| 2 | `jest --ci --runInBand src/services/__tests__/authActions.test.ts -t 'import_offer_decision'` | — | — | NOT RUN (stopped at first nonzero) |
| 3 | `tsc --noEmit` | — | — | NOT RUN |
| 4 | `eslint` on exactly the six changed files | — | — | NOT RUN |

Raw: `validation-receipts/04-jest-new-files.log`, `04-jest-new-files-status.txt`.

### The one failure (verbatim from the log)

```
● useImportOfferDecision — reading the persisted answer › is loading (render nothing) until the read settles, then ready with null when unanswered
  expect(received).toBe(expected)   Expected: "loading"   Received: "ready"
  at src/hooks/__tests__/useImportOfferDecision.test.tsx:121:35
```

Failing lines (committed tree):
```ts
120    const { result } = await renderHook(() => useImportOfferDecision(true));
121    expect(result.current.status).toBe('loading');   // ← fails
122    expect(result.current.decision).toBeNull();
123    await waitFor(() => expect(result.current.status).toBe('ready'));
124    expect(result.current.decision).toBeNull();
```

Cause (from the evidence, not a guess): RNTL 14's `renderHook` is async and awaits `act`, which flushes microtasks; against the in-memory AsyncStorage jest mock the read settles inside that same flush, so by the time `renderHook` resolves the hook has already moved `loading → ready`. The assertion demanded an intermediate state that is not observable without holding the read open. The hook's intermediate `loading` state IS exercised and passed in the two tests that hold the read open with a deferred `getItem` ("a recorded answer supersedes a read still in flight" asserts `loading` at line 215; "account switch (A→B) resets BEFORE reading B" asserts `loading` at line 330). The final state asserted at lines 123–124 (`ready`, `null`) is what the hook actually produced. This was exactly the static-only assurance point C3(a) flagged in the handoff.

Product impact: none observed. The 55 passing tests include the full storage suite (key scoping, cross-user purge, corrupt/version/unknown discard, write-failure semantics, clear) and every other hook property (disabled inert, unresolved refuses to record, immediate reflection, serialized writes, failed write re-offer, A→null / A→B reset and stale-read discard, late write after sign-out/switch removed). `tsc`/`eslint` did not run, so type/lint cleanliness of the six files remains unproven.

## 4. Disposition needed (Class B — blocked on a decision; no harm)

Concrete minimum closure, either of:

- **(i) test-only edit, 2 lines**: delete lines 121–122 of `src/hooks/__tests__/useImportOfferDecision.test.tsx` (the un-held immediate `loading` assertion; the held-read tests already pin that state), or hold the read open with the same `deferred()` + `mockImplementationOnce` pattern the neighbouring tests use. Either produces a new candidate tree (test blob only; the three product blobs `83118fff…`, `ddede726…`, `ceb33c45…` untouched) that must be re-frozen and, per rule, receives its A/B re-binding or the parent's explicit C-qualification for a test-only line change; then re-run stages 1–4 from the top on the new committed tree under a fresh slot.
- **(ii) parent C-qualifies the failure as a test-expectation artefact** and grants running stages 2–4 on the committed tree `327731d4` as-is, recording the 1/56 failure. Not recommended: it leaves a red test in the candidate.

Not done and not proposed: changing the hook to delay the read (would add an artificial render of `loading`, i.e. a product change to satisfy a test).

## 5. State at report time

- HEAD `327731d4c6daf9c319fd0a79fc9cf4be9dc2f580`, tree `a33cb891…`, `git status --porcelain` empty, branch `ux01-account-state`. Commit preserved; nothing amended.
- `execution/test-validation.lock` released 06:48:30Z; `flock -n … true` probe afterwards: free.
- Owned survivors: 0 (no jest/tsc/eslint/cp/bash runner processes; the only `node` processes on the host are the platform's code-mode daemon, not mine).
- Sibling `worktrees/ux07-mobile` untouched (read-only source of the copy).
- Runner script sha256: see `validation-receipts/RUNNER_SHA256.txt`.
