# S7-2 C1 independent review B — Part 3: actual commit and targeted results attestation

Reviewer: independent non-builder B (T4) continuation, session `95633079`. Observed 2026-09-24 ~06:10–06:25Z. Requested route Claude Fable 5 / High (requested routing, not observed telemetry).

This file is ADDITIVE to the sealed source-phase review B preserved at `resume-evidence/execution/e7d2385c/audits/s7-c1-b/` (`S7_C1_REVIEW_B.md` sha256 `d1880833fb2865a9589af951fc3521fac55fa5c052fcd6e25f53903dbd56fabb`, `FINDINGS.md` `b7d25b63aa48f84a4995f15f90ace94e1c4d78566e1e1064543c38f759c89623`, `MANIFEST.sha256` re-verified OK before this work). That review's source verdict (GRANTABLE for the ordinary genuine-hook commit of tree `87798e74` and the existing targeted Jest lane; NOT YET GRANTABLE for the C1 real-PG run pending the fixture prerequisite) and its findings A=0 / B=0 / C1–C9 are carried forward UNCHANGED. The old archive was not modified; sole writes are `execution/95633079/audits/c1-b/**`.

Mode: static reads, git object inspection (`GIT_OPTIONAL_LOCKS=0 GIT_NO_LAZY_FETCH=1`, worktree `worktrees/s7-c1` treated read-only, no object/ref/index write by me), sha256/sha1 recomputation, `diff`/`cmp`. No code run, no runtime, no install, no commit, no probe, no PG. Source review, S1–S6, S7 foundation, formatting, hooks install and tests were NOT rerun. Reviewer A's conclusions were NOT read (its file `audits/c1-a/REMAINDER_BINDING_REVIEW.md` is referenced by name in executor receipts; I did not open it or any `c1-a/**` file). Inputs used were raw packets only: `execution/95633079/c1-execution/**`, `execution/e7d2385c/s7-c1-formatted/**` (launcher, message, INDEX_BLOBS_18, FILES10, MANIFEST, logs/09-*, logs/10-*), and git objects in `worktrees/s7-c1`.

## 1. Actual head — independently attested from the git object

| Item | Observed by me | Required (§8 of sealed B) | Result |
|---|---|---|---|
| HEAD | `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` (detached; `.git/HEAD` holds the raw SHA) | — | as reported |
| Commit SHA recomputed | `sha1("commit 1959\0" + raw object)` = `a0ea1bea…` | — | object bytes authentic |
| tree | `87798e742c7b48f56b05e9b5c30efa877180a9b3` | frozen tree | MATCH |
| parent 1 | `5c760b774598532e90d5d217e15adc9285c3c3f4` | accepted foundation | MATCH (ordered first) |
| parent 2 | `881c4c791727adef8d423931e1cca83a0ffbb9c9` | PR526 head | MATCH (ordered second) |
| parent 3 | none (`rev-parse HEAD^3` fails; `rev-list --parents` shows exactly two) | none | MATCH |
| author | `Bradley Gleave <bradley@bradleytgpcoaching.com> 1790229806 +0000` (= 2026-09-24T06:03:26Z) | Bradley identity | MATCH |
| committer | identical string and timestamp | == author | MATCH |
| trailers | 0 matches for `co-authored-by|generated with|signed-off-by` (case-insensitive); `git interpret-trailers --parse` on the body → 0 lines | 0 | MATCH |
| merge-base(5c760b77, 881c4c79) | `925780e0a1906593e5383c618311b6b17364b8dc` | as in sealed B §1 | MATCH |
| `12-actual-commit-object.txt` | byte-identical to `git cat-file commit HEAD` and to `cat-file -p HEAD` | — | packet copy faithful |

## 2. Message bytes — exact qualification

- Approved file `s7-c1-formatted/07-merge-message.r2.txt`: 1669 bytes, sha256 `288048d7b7e908f8803d3d70e57465f52cfc9f102bb4bc4b1dba30143ce7cb83`, ends `s.\n`.
- **Raw commit-object body** (bytes after the header blank line of `git cat-file commit HEAD`): 1669 bytes, sha256 `288048d7…`; `cmp` against the approved file → **byte-identical, no difference at all**.
- `git log -1 --format=%B`: 1670 bytes, sha256 `23d221921356ad09c6b19f0589755ed7b9fa7d5c16212e8f862648e19181225b` — the approved text plus one newline appended by the `%B` formatter. This is what the launcher's non-fatal predicate compared, producing the log line `NOTE message-bytes-differ-from-file (git may strip trailing newline); recorded` (log line 390).
- Qualification recorded exactly: the NOTE is an artifact of the `%B` rendering, not of the committed message. The packet file `12-actual-commit-message.raw` (1670 B, `23d22192…`) is the `%B` rendering, not the raw object body, although the executor seal labels it "raw message bytes"; the seal's statement that the committed message equals the approved input "modulo Git's newline handling" is correct but weaker than the fact — the object body needs no modulo. `.git/COMMIT_EDITMSG` is 1669 bytes (written 06:04:14Z), consistent.
- Subject line: `merge(s7-c1): compose C1-S1 durable setup recovery 881c4c79 onto accepted foundation 5c760b77` — matches the reflog entry `commit (merge): …`.

## 3. Genuine hooks — all configured steps, ordinary route

Configured steps at `HEAD:lefthook.yml` (blob `54d03749…`, unchanged from foundation): pre-commit `banned-cast-tokens`, `tsc`, `eslint`, `prettier`, `prod-readiness-quick` (5, `parallel: true`); commit-msg `no-ai-tokens` (1).

Observed in `10-validate-continue.log` (lines 5–389, LEFTHOOK_VERBOSE=1 shell trace visible):
- `+ call_lefthook run pre-commit` → `+ lefthook -h` (PATH lookup, fails) → `+ /home/user/workspace/worktrees/s7-c1/node_modules/lefthook-linux-x64/bin/lefthook run pre-commit`; `loading config: /home/user/workspace/worktrees/s7-c1/lefthook.yml`; `🥊 lefthook v2.1.9 hook: pre-commit`.
- Staged set enumerated by lefthook = the 18 paths; eslint job invoked on the 13 `.ts` files; prettier `--check` on 15 files (13 `.ts` + json + md); `banned-cast-tokens` printed `R75 --cached; policy=:.github/r75-policy.json … OK — no positive token change`; prettier printed `All matched files use Prettier code style!`.
- `summary: (done in 48.24 seconds)` → `✔️ prod-readiness-quick (0.02 s)`, `✔️ banned-cast-tokens (0.35 s)`, `✔️ prettier (2.71 s)`, `✔️ eslint (3.89 s)`, `✔️ tsc (48.22 s)`.
- `+ call_lefthook run commit-msg .git/COMMIT_EDITMSG` via the same native binary; `hook: commit-msg`; `summary: (done in 0.01 seconds)` → `✔️ no-ai-tokens`.
- No `skip`, `no files`, failure or error line anywhere in the hook output.

Hook installation state in the worktree now: `.git/hooks/pre-commit` sha256 `a868b3a9ee25a048ca80c26b875e2b41b829f7d7fe325b2c3b585e3a368aef46`, `.git/hooks/commit-msg` `a46fa3984a49a61212e9ed239cde4e0e6642cc89a708c92e766cbd0fc64686f8`, both executable, mtime 05:53:33.740Z (== `HOOKS_END` of the original launcher; unchanged through the 06:04 commit, i.e. no reinstall/rewrite), byte-identical to the preserved copies in `09-hooks-missing-evidence/` and differing from each other only in the final `call_lefthook run "pre-commit"` / `"commit-msg"` line. Both reference the absolute native path `…/node_modules/lefthook-linux-x64/bin/lefthook` (sha256 `974486e9…`); neither contains the string `.bin/lefthook`. `core.hooksPath` unset; no `lefthook-local.yml` / `.lefthook-local.yml`; repo-local `user.name/user.email` = Bradley identity; `git remote` count 0.

Original failure, preserved raw and unchanged: `logs/09-validate.log` (sha256 `e255d8ff…`) shows `sync hooks: ✔️(commit-msg, pre-commit)`, `HOOKS_END … rc=0`, then `STOP hooks-missing rc=71`; `logs/09-validate.sentinel` = `RC=71 STAGE=hooks-missing END=2026-09-24T05:53:33Z HEAD=5c760b77…` (packet copies byte-identical to the `s7-c1-formatted/logs` originals). Independent root cause: frozen launcher line 45 requires `grep -q "$W/node_modules/.bin/lefthook" .git/hooks/pre-commit`, but Lefthook 2.1.9 writes hooks that reference the native `lefthook-linux-x64/bin/lefthook` path (0 occurrences of `.bin/lefthook` in the hook). Install child rc 0 and genuine hooks stand as separate facts; the RC71 stays a recorded failure of the detector predicate, not relabelled.

## 4. Remainder script (`47c27fb9…`) — independent read

- `sha256sum 10-validate-continue.sh` = `47c27fb9c700c797c55e7216378581d193dd8de63ec9f85aff08534f5d81bb1c` (== `10-CONTINUATION.sha256`, == `08-launch.txt` second LAUNCH line).
- My own `diff` of the frozen launcher (`a57c224c…`, re-hashed OK) against it is byte-identical to the recorded `10-diff-vs-frozen.txt`. Verified verbatim: the 19 rc-70 preconditions (frozen lines 19–37 == remainder 23–41); frozen lines 46–47 (hooksPath unset; tree `87798e74` + clean) == remainder 66–67; stage 2 and stage 3 bodies identical modulo the `09-jest.log`→`10-jest.log` name. Changes are confined to header comments, the `10-*` log/sentinel names, two added rc-70 guards (frozen launcher hash still `a57c224c…`; prior sentinel still `RC=71 STAGE=hooks-missing`), and stage 1R which replaces the single `.bin/lefthook` string predicate with hash/route/version/no-bypass assertions on the actually installed hooks. No `lefthook install`, no hook rewrite, no `--no-verify` (the only textual match is inside a comment), no `LEFTHOOK=0`, no retry, no suite change.

## 5. Post-commit state and 18 paths

- `git diff-tree -r 5c760b77 HEAD` → exactly 18 entries (6 A, 12 M). The 18 `(mode, blob, path)` triples equal `s7-c1-formatted/INDEX_BLOBS_18.txt` exactly (my normalised diff: empty). `HEAD^{tree}` == `git write-tree` == `87798e74…` at observation time.
- `git status --porcelain --untracked-files=all` → 0 lines; `git diff --name-only` 0; `git diff --cached --name-only` 0. `.git/MERGE_HEAD`, `MERGE_MODE`, `MERGE_MSG` all absent.
- Reflog `.git/logs/HEAD`: `checkout: moving from master to 5c760b77…` then `5c760b77… → a0ea1bea… commit (merge): merge(s7-c1): …` — a single commit event, no amend/reset.
- Refs: `refs/s7/foundation-5c760b77`, `refs/s7/c1-881c4c79` (05:43Z, recovery), `refs/s7/c1-committed` = `a0ea1bea…` (06:05:52Z, created by the executor after the script's terminal for bundling — not part of the granted script; see C13). `.git/shallow` = `c23b9d9f…` only.
- Bundle `bundle/s7-c1-committed-a0ea1bea-from-public-c23b9d9f.bundle` sha256 `b5126ab5…` (== `BUNDLE.sha256`, OK); `git bundle list-heads` → the three refs above with `a0ea1bea…` at `refs/s7/c1-committed`; `git bundle verify` → "records a complete history". Durability artifact only; not part of acceptance.

## 6. Targeted Jest results, skip and drift claims

- Command in the log/script: `timeout -k 30 600 ./node_modules/.bin/jest --ci --runInBand test/contracts/importer-contract.spec.ts src/extension-pair/__tests__` — the exact lane granted in sealed B §8 (no edits, no new tests, no `--passWithNoTests`).
- `10-jest.log` (sha256 `9a9cd3c1…`, byte-identical to `s7-c1-formatted/logs/10-jest.log`): `Test Suites: 11 passed, 11 total`, `Tests: 190 passed, 190 total`, `Snapshots: 0 total`, `Time: 66.333 s`; no `skipped`, `todo`, `failed` or `FAIL` line. `JEST_END … rc=0` (raw status captured before the summary grep). Nest `ERROR` lines in the log are the service's expected logging inside negative-path unit cases (exhausted code-mint attempts; generateLink/verifyOtp failures), each within a `PASS` suite.
- Suite scope check against HEAD: `src/extension-pair/__tests__/` holds 11 files; `test-doubles.test.ts` does not match `testRegex '\.spec\.ts$'` and is a helper, so 10 spec suites + `test/contracts/importer-contract.spec.ts` = 11 — the count is exactly the expected population, not a subset. `test/rls-c1-setup.spec.ts` is excluded by `testPathIgnorePatterns` `'<rootDir>/test/rls-.*\.spec\.ts$'` in the default config — the PG proof did not run and is not claimed.
- Drift assertion included: `HEAD:test/contracts/importer-contract.spec.ts` contains `describe('drift check')` → `it('the checked-in artifact is byte-identical to a fresh regeneration')` (line 62) and the cold-subprocess variant (line 922), plus `info.version` `2.0.0-c1-s1.1` and the 409/410 envelope checks; the suite passed (60.0 s). The committed artifact `docs/contracts/importer-openapi.json` remained `bdb022dd…` (precondition guard passed; not regenerated by the executor).
- Post-Jest guard passed (HEAD unchanged, clean), terminal sentinel `RC=0 STAGE=done END=2026-09-24T06:05:23Z HEAD=a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` (packet and `logs/` copies identical).

## 7. Environment and scope (receipts read, not rerun)

Receipts 01–08 are internally consistent with the launcher's 22 precondition guards (`06-precondition-dryrun.txt` 22/22 OK; `PRECONDITIONS_OK` in both 09 and 10 logs): recovery from public `c23b9d9f…` (depth-1, read-only fetch through the proxy) + parents bundle `a238a7b1…` + frozen patch `a413891a…` applied `--index` → tree `87798e74`, `MERGE_HEAD` restored as metadata without re-merge; `npm ci --ignore-scripts` rc 0 with installed record `05bc530a…`; Prisma engines at locked hash `c2990dca…` (one network fetch); `prisma generate` client `bf679a16…`; external Prettier 3.9.6 CLI `6e922134…`. Both packet manifests still verify (`8ef86a1b…` 24/24, `128496e2…`). No remote configured, no push, no deployment, no PG cluster directory present, no formatter run, no source edit. At observation time the heavy lock file is held by a different lane (ux07-mobile validation, separate worktree), consistent with the C1 executor's release after its seal.

## 8. Findings for this phase (Safety-ROI classes)

**Class A: none. Class B: none.** No decision is blocked by evidence quality here; the actual-head receipts are exact, bound and independently recomputed.

Class C (record, qualify, continue — no new cycle), numbered after the sealed C1–C9:
- **C10** Launcher `NOTE message-bytes-differ-from-file` is a `%B`-formatter artifact; the raw commit-object body is byte-identical to `288048d7…`. Packet `12-actual-commit-message.raw` is the `%B` rendering (1670 B, `23d22192…`) despite its "raw" label.
- **C11** `prod-readiness-quick ✔️` executed an empty conditional (`scripts/prod-readiness-precheck.sh` untracked at this tree, as at the foundation); it is not readiness evidence. The other four pre-commit jobs and commit-msg genuinely ran.
- **C12** Original RC71 = frozen-launcher detector string (`.bin/lefthook`) vs Lefthook 2.1.9's native hook route; install rc 0, hooks genuine. Failure preserved unchanged; the remainder script strengthened the hook boundary (hash-pinned hooks, native binary hash and version, no-bypass env, no local override) rather than weakening it.
- **C13** Two writes inside `.git` after the script's terminal 06:05:23Z, outside the granted script: `refs/s7/c1-committed` (06:05:52Z, for the bundle) and a stat-only refresh of `.git/index` (06:09:52Z). HEAD, tree, 18 blobs and clean state are unchanged; no product effect.
- **C14** Network reads during rehydration were limited to the documented depth-1 fetch, product/tooling `npm ci`, and the Prisma engine download at the locked hash — consistent with SCOPE's "absent tooling may be rehydrated to recorded pins".
- **C15** Jest population: `test-doubles.test.ts` is intentionally outside `testRegex`; 11 suites is the complete expected set; 190/190, 0 skipped/todo.

## 9. Part 3 verdict — FROZEN

Every item of the sealed B §8 same-review acceptance list for the actual commit is met on the head that actually landed: lefthook all five pre-commit ✔️ + commit-msg ✔️; raw object `tree 87798e74`, `parent 5c760b77` then `parent 881c4c79`, author == committer == Bradley Gleave, body `cmp`-equal to `288048d7…`, 0 trailers; `MERGE_HEAD` gone, porcelain 0; `diff-tree 5c760b77 HEAD` == the 18 frozen paths/blobs; targeted Jest all 11 suites passed, 190/190, 0 skipped, drift assertions included; terminal `RC=0 STAGE=done` at 06:05:23Z with the original RC71 receipt preserved.

**Attested: head `a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992` is the ordinary genuine-hook local commit of the frozen tree with the approved message and identity, and the existing targeted Jest lane passed on it.** A=0, B=0 for this phase.

**Final C1 acceptance is NOT yet possible.** Still outstanding in this same review: Part 2 (minimum PG fixture variant diff against `s5-fixture.sh` `3a7d57bf…`, substitution-only acceptance) and Part 4 (the existing 22-case `rls-c1-setup` real-PG proof: guards pass, `Tests: 22 passed, 22 total`, rc 0, fixture init/start/stop rc 0, 0 postgres processes, no `postmaster.pid`, S5 cluster untouched, lock released). This attestation claims local commit + targeted unit/contract evidence only — not merge eligibility, deployment, consumer-contract freeze or product acceptance.
