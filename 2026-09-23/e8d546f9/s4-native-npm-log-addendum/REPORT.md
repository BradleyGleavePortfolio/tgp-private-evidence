# S4 native run — npm debug-log retention addendum (additive, read-only collection; frozen)

Executor: `restore_upstream_proof_inputs_muddwjad`. 2026-09-23T02:01:49Z–02:02:55Z. Sole writes: this directory. The S4 result freeze `s4-native-result/SHA256SUMS.native` `02df9f60…` (111 entries) is untouched; nothing rerun; `$HOME/.npm/_logs` originals preserved (11/11 byte-identical after copy).

## Attribution (`logs/A1-inventory.txt`, `logs/A2-attribution.txt`, `logs/A3-copy-and-review.txt`)

Run window 01:50:31Z–01:56:02Z, native WT `/home/user/workspace/worktrees/s4-r6`. All **11** files in `$HOME/.npm/_logs` fall inside the window and are attributable to the native run by `verbose cwd` + `verbose title`; all 11 were copied to `npm-logs/`:

| debug log (UTC) | npm title | cwd | exit | step |
|---|---|---|---|---|
| 01:51:03, :15.1, :15.3, :16, :17, :24, :26, :33 (8 files) | `npm run check:banned / check:flags / check:fixtures / check:production-preflight / check:hooks / lint / type-check / format:check` | WT | 0 | **S20-gates** (`npm run gates` chain, 01:51:03→01:51:35) |
| 01:51:39 | `npm exec vitest run …` | WT | 0 | **S30-focused-vitest** (01:51:39→01:51:53) |
| 01:51:54 | `npm exec vitest run --passWithNoTests=false …` | WT | 0 | **S31-full-suite** (01:51:54→01:55:21) |
| 01:53:21 | `npm run type-check` | `/tmp/importer-gate-UGTIEY` | 2 | **S31-full-suite** → `test/policy-gates.spec.js` L18 (`mkdtempSync(… "importer-gate-")`, the test spawns `npm run type-check` in a temp copy; exit 2 is the test's subject, S31 itself passed 1742/1742) |

Unrelated/not copied: **none** — the parent's working assumption of "11 unrelated files" does not hold; there were no pre-existing logs from other lanes in the directory. **Not present (fact):** debug logs for **S10 `npm ci`** (01:50:54–57) and **S10b `npm ls --all --json`** (01:50:58–01:51:00). Every retained log carries `logfile logs-max:10`; npm prunes the oldest logs beyond that bound, so this run's earliest debug logs were rotated out by its own later npm invocations. The S10 `npm ci --loglevel=info` stdout/stderr (64 registry fetch lines, `added 133 packages`, lefthook postinstall code 0) is preserved in the frozen `runs/…/steps/S10-npm-ci.log`, and S10b's stdout in `steps/S10b-toolchain-provenance.log` (both inside `02df9f60`).

## Credential-pattern review of the 11 copies

12 patterns (GitHub/npm/AWS tokens, private keys, Slack, JWT, `_authToken`, `Authorization`, OpenAI-style keys, `password=`, credentials-in-URL): **0 hits each** → `NO_CREDENTIAL_SHAPES_FOUND`. Copies contain npm `verbose cli/argv/cwd/title/config` fields only; no environment dump. Nothing printed, redacted or edited.

## Lefthook hook creation — what actually ran (from existing logs/source; no claim of "no hook")

- Source at 91990ae9: `package.json` `"prepare": "lefthook install"`, `devDependencies.lefthook 2.1.12`; runner S10b (`s4-r6-validate-v6.sh` L117) **requires** `.git/hooks/pre-commit` mentioning lefthook (`hook_installed=yes`, else exit 90); S20 gate `check:hooks` runs `scripts/check-hook-config.mjs`.
- What ran (S10-npm-ci.log L68–72): `lefthook@2.1.12 postinstall … code 0`, then `> lefthook install` (npm lifecycle `prepare` of the WT package during `npm ci`). Result: `worktrees/s4-r6/.git/hooks/pre-commit` created at 01:50:57Z (71 lines, 32 lefthook mentions, sha256 `ea98e08e…`); no other hook files. S10b then recorded `hook_installed=yes`.
- Not run: no `git commit`/`git push` in any step/console log (0 occurrences); HEAD unchanged 91990ae9, porcelain 0. So: the unchanged runner's `npm ci` **did install a local Git pre-commit hook in the disposable worktree** (a declared runner effect that S10b asserts), while the grant's "No Git hook/commit/push" clause is read as no hook *invocation*/commit/push — none occurred. This is a disclosure of the ambiguity, not a clearance; the hook is inert unless someone commits in `worktrees/s4-r6`.

## Owned outputs
`execution/e8d546f9/s4-native-npm-log-addendum/{REPORT.md, MANIFEST.sha256, logs/A1–A3, npm-logs/ (11 files)}`; `MANIFEST.sha256` covers everything here except itself.
