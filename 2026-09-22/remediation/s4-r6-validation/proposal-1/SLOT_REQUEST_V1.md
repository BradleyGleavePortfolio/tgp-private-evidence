# S4 R6 — native validation slot request V1 (prepared; NOT executed; no grant assumed)

Prepared 2026-09-22 ≈04:50 UTC by the S4 builder per parent mail (91990ae9 preserved as authentic frozen UNACCEPTED
candidate; 0/6 historical hooks retained; identical tree NOT recreated). Original packet `execution/s4-r6/` is
immutable and untouched. Nothing here was installed or run except `bash -n` / `node --check` on the two runner files
and read-only hashing. **Disclosure:** while collecting provenance I ran `chrome --version` once (prints a version
string, no browser session, no profile); output "Google Chrome for Testing 147.0.7727.15". No other execution.

## Exact target

| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/s4-r6`, branch `execute/20260921-s4-r6`, clean |
| HEAD / tree | `91990ae9aec72f47a67591892ac09fa1f59d2f16` / `840fb2855953d5363fbd144e11b3f81763d9cef7` |
| parent / public base | `88287cff47240aa58b5f0fea5da08670f1e87df6` / `0111be661922234d670bbf23e23d270eec1b4a4e` (local `main`) |
| predecessor control | `execution/s4-r6/predecessor-88287cff/` (git-archive export of 88287cff; `background.js` sha256 `5a6a4b8b…4ff721`) |
| runner (immutable V1) | `runner/s4-r6-validate.sh` — sha256 in `SHA256SUMS`; any byte change = new version + new request |
| pipe probe | `runner/chrome-pipe-discriminator.mjs` — sha256 in `SHA256SUMS` |
| offline probes reused | `execution/s4-r6/probes/a01-late-reporting-discriminator.mjs` `890d45f7…172fbc`; `probes/reused/{a01,a02,bound-admission}` `d1e1d428…`, `93465881…`, `ae6d3e12…` (hashes in `execution/s4-r6/SHA256SUMS`) |
| repo scripts used (at HEAD, read before use) | `scripts/browser-load-proof.mjs` `186a85cf…`, `scripts/package-extension.mjs` `79b5b728…`, `scripts/secrets-scan.sh` `ca749cb0…`, `scripts/install-gitleaks.sh` `9fdd543f…`, `scripts/lib/shipping.mjs` `cdd4ceaf…`, `lefthook.yml` `e9eb0028…`, `.gitleaks.toml` `8165562d…` |

## Toolchain / dependency provenance (preconditions enforced by S00, run refuses otherwise)

- node `v20.20.1`, npm `10.8.2` (present); `package-lock.json` sha256 `262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8` (unchanged since R4/R5).
- `node_modules` must be ABSENT before the run (fresh `npm ci` from the lockfile is the only JS install; `prepare` →
  `lefthook install` is expected and is verified to have installed `.git/hooks/pre-commit`; provenance recorded:
  `node_modules/.package-lock.json` sha256, `npm ls --all --json` sha256, vitest/eslint/prettier/tsc/lefthook versions).
- gitleaks `8.30.0` via the repository's own `scripts/install-gitleaks.sh` into `execution/s4-r6-validation/tooling/gitleaks`
  (checksum-pinned `79a3ab57…0a66e` for linux_x64; download from github.com is the ONLY other network use). Not on PATH now.
- Chrome: `/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome` ("Google Chrome for Testing 147.0.7727.15");
  binary sha256 recorded at run time in S00 and EXIT_RECORD.
- Lock: `/home/user/workspace/execution/test-validation.lock`, `flock -n` on fd 9 held by the runner PID for the whole
  run (exit 75, nothing runs, if busy). A free lock is not permission; this request is not a grant.
- Refusals: worktree not at exact clean head; shallow repo; stale `dist/` in worktree; leftover `tgp-browser-proof-*` /
  `tgp-pipe-discriminator-*` Chrome processes (never signalled — they are unowned).

## Invocation (parent, after grant)

```
RUN_ID=V1-$(date -u +%Y%m%dT%H%M%SZ)
setsid bash /home/user/workspace/execution/s4-r6-validation/runner/s4-r6-validate.sh "$RUN_ID" \
  > /home/user/workspace/execution/s4-r6-validation/runs/$RUN_ID.console.log 2>&1
```
Outputs: `runs/<RUN_ID>/steps/*.log|*.json`, `runs/<RUN_ID>/dist/` (zip + inventory), `runs/<RUN_ID>/EXIT_RECORD.json`,
`runs/<RUN_ID>/RUN_COMPLETE.sentinel` (written last; absent = run did not complete = UNKNOWN, not pass).
Process exit = first required failure's exit code (or 0 SUCCESS, 3 ANOMALY); cleanup exit is recorded separately.
Process ownership: everything is a descendant of the runner PID (own session via `setsid`); cleanup signals only that
subtree (TERM, 5 s, KILL) and reports survivors; platform/unowned processes are never signalled. Outer bound if the
parent wants one: `timeout --kill-after=60 3300` (sum of step budgets ≈ 3000 s worst case; typical ≈ 15 min).

## Steps, budgets, criteria (fail-closed; first required failure → later required steps NOTRUN)

| step | command (cwd = worktree) | timeout | positive criterion | negative / abort |
|---|---|---|---|---|
| S00 | preconditions (read-only) | — | all identities match; lock acquired | any mismatch → nothing else runs |
| S10 | `npm ci --no-audit --no-fund --loglevel=info` | 300 s | exit 0; hook installed (`hook_installed=yes`) | exit≠0 → stop. Hook not installed → anomaly |
| S11 | `bash scripts/install-gitleaks.sh <tooling dir>` | 120 s | exit 0, `gitleaks version` = 8.30.0 | checksum mismatch → script refuses → stop |
| S20 | `RATIO_BASE=0111be66… npm run gates` (banned, flags, fixtures, production-preflight, hooks, **lint, type-check, format:check**) | 300 s | exit 0 | exit≠0 → stop (hook-equivalent gate failed) |
| S21 | `bash scripts/secrets-scan.sh pr 88287cff… 91990ae9…` (exact range) | 120 s | exit 0, no findings | findings/reader failure → stop |
| S22 | `bash scripts/secrets-scan.sh history` (full history, all refs) | 120 s | exit 0 | as above |
| S30 | real Vitest focused: `npx --no-install vitest run --reporter=default --reporter=json --outputFile.json=… test/session-ownership-preflight.spec.js test/refresh-admission-epoch.spec.js test/session-ownership.spec.js test/refresh-coalesce.spec.js test/ingest-auth.spec.js test/session-refresh-path.spec.js test/session-establishment.spec.js test/start-import-hardening.spec.js test/session-lifecycle.spec.js` | 300 s | exit 0; preflight spec = 19 cases (16 R5 + 3 R6), incl. the fake-timer case the shim could not run | exit≠0 → stop; count≠19 → anomaly |
| S31 | real Vitest full: `npx --no-install vitest run --passWithNoTests=false --reporter=default --reporter=json --outputFile.json=…` | 900 s | exit 0; 0 skipped/todo; total recorded | exit≠0 → stop; total≠1742 (arithmetic 1714+25+3, NOT proof) or skipped/todo>0 → anomaly, explain rather than relabel |
| S40–S44 | in-slot record of the offline discriminators: a01-late-reporting candidate `--expect fixed`; predecessor `--expect defect`; R5 a01/a02 `--expect fixed`; auditor B probe | 60 s each | exit 0 each (predecessor exit 0 = defect reproduced, offsets 10/11 under Node 20.20.1; the invariant, not the offset, is the criterion) | any ≠0 → stop |
| S45 | candidate `--expect defect` (sign check) | 60 s | **exit 1** | exit 0/2 → anomaly |
| S50 | `node scripts/package-extension.mjs --root <wt> --out runs/<id>/dist` then inventory binding | 120 s | exit 0; inventory `source.head` = 91990ae9, `clean` = true; every shipped file sha256 == `git show HEAD:<path>` | else stop — **no browser on an unbound package, no stale dist** |
| S60/S61 | `node runner/chrome-pipe-discriminator.mjs --chrome <chrome> --label cold|warm` | 60 s each | `PIPE_ALIVE` (Browser.getVersion answered on fd 4) | dead → result `HARNESS_BLOCKED`, browser steps NOTRUN, **no retry, not a product failure, not a flake label** |
| S62 | `TGP_CHROME=<chrome> node scripts/browser-load-proof.mjs --zip <zip> --out …` (positive) | 180 s | exit 0, all checks pass (manifest accepted, module worker evaluates, classic content script runs on synthetic origin, popup loads, `request_session_state` round trip, credential only over internal boundary, all foreign hosts NOTFOUND) | exit≠0 → stop |
| S63 | same with `--negative-control` (**proper negative**: harness appends `export const readSourceBearer = () => "";` to `content/main.js` — the historical classic-script module-syntax defect; original hashes in inventory, `mutation.sha256AfterMutation` recorded) | 180 s | exit 0 **AND** `negativeControl.detected` **AND** `syntaxExceptionSeen === true` **AND** mutation recorded **AND** `unrelatedFailures = []` (stricter than the harness's exit; S4-R5-A-E01) | otherwise anomaly `NEGATIVE_NOT_ESTABLISHED`; a known-good base ZIP is never used as the negative |
| S70 | cleanup of owned subtree; survivor scan; worktree must still be clean at 91990ae9; `node_modules` retained as setup evidence | ~10 s | cleanup exit 0 | survivors → cleanup exit 1/2 recorded separately, never hides the first exit |
| S80 | `EXIT_RECORD.json` + sentinel | — | result ∈ SUCCESS / ANOMALY / FAILED / HARNESS_BLOCKED with semantics embedded | — |

`SUCCESS` means: all required steps exited 0 with zero anomalies at this exact head. It is builder evidence for the two
independent attestations; it is **not** acceptance and proves nothing about installed-user Chrome behaviour, remote
revocation, server-owned terminal authority, native migration, merge/deploy/enablement or release.

## Not in this request
No DB, no product/source edit, no commit, no push/PR, no edits to `execution/s4-r6/`, archive, baseline or frozen
worktrees, no flag change, no shim runs (the homemade shim is retired; real Vitest only), no retry on failure.
Future commits (if any successor is authorized) will be made only with the hooks that S10 installs actually running.
