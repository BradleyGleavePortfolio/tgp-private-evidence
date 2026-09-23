# S4-NATIVE-UNSHALLOW — additive read-back after the parent's narrow unshallow (revision 1, frozen)

Writer: `restore_upstream_proof_inputs_muddwjad` (source-evidence-only; requested Claude Fable 5, runtime identity not observable). Read-back taken 2026-09-23T01:20:02Z–01:20:24Z with Git/file commands only: no network, install, probes, version commands, process census, runtime, or worktree edit.

Provenance split (recorded honestly): the network metadata fetch was performed by the **parent** under its routine read-only remote authority at 01:18:51Z — `git -C worktrees/s4-r6 -c core.hooksPath=/dev/null fetch --no-tags --unshallow https://github.com/BradleyGleavePortfolio/tgp-importer-extension.git 0111be661922234d670bbf23e23d270eec1b4a4e`; live extension `main` observed by the parent still `0111be66…`. This worker did **not** run any network command in either S4 slice. The original restoration report (`execution/e8d546f9/s4-native-restore/REPORT.md`, `fac69938…`, MANIFEST re-verified OK) is untouched; its §2 shallow finding was a true observation at the time and is now **historical, resolved by the parent's action** — not ignored, not rewritten. Its "01:1xZ" freeze clock is a placeholder, not an exact timestamp; no clock provenance is asserted.

## Exact current read-back (`logs/U1-readback.txt`)

| Fact | Value |
|---|---|
| HEAD | `91990ae9aec72f47a67591892ac09fa1f59d2f16` (unchanged) |
| Tree | `840fb2855953d5363fbd144e11b3f81763d9cef7` (unchanged) |
| Parent | `88287cff47240aa58b5f0fea5da08670f1e87df6` (tree `a2879859…`) |
| Base `0111be66…` | ancestor = yes; its parent `ec7578a6…` now resolvable (commit) |
| Shallow | `rev-parse --is-shallow-repository` = **false**; `.git/shallow` absent (runner S00 L88 satisfied) |
| History | 75 commits total to HEAD; 22 base..HEAD; single root `a1fff36c…`; fsck connectivity ok; 0 missing blobs |
| Cleanliness | porcelain 0 (incl. `--untracked-files=all`), diff-index 0; 158 tracked = 158 worktree files |
| Lockfile | `package-lock.json` `262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8` = `EXPECT_LOCK_SHA` |
| Refused-if-present | `node_modules` absent; `dist` absent |
| Repo hygiene | 0 remotes; 0 active hooks; `core.hooksPath` unset; local config only the four defaults; refs `refs/heads/main`=0111be66, `refs/restored/execute/20260921-s4-r6`=91990ae9; 0 tags; `.git/FETCH_HEAD` present (artifact of the parent's fetch); 3 packs, 852 objects |
| Companions | `execution/s4-r6/predecessor-88287cff` 158 files, 0 blob mismatches vs `88287cff`; probes `PIN_A01_LATE`/`PIN_R5_A01`/`PIN_R5_A02`/`PIN_R5_B` all OK; `PIN_PIPE_V6` `c261ffb4…` OK; runner `94edb27d…`; both dirs 0555, 0 writable |
| Baseline | `source/extension` untouched: HEAD 0111be66, still shallow (only the standalone worktree was unshallowed), porcelain 0 |
| File existence | Chrome present at runner default; `execution/s4-r6-validation/tooling/gitleaks` missing (runner step S11 installs it); canonical lock file exists (empty, from the granted S2 probe) |

## Readiness statement

Every source-side S00 precondition of `s4-r6-validate-v6.sh` that can be checked by file/Git state is now satisfied: head, tree, parent, base ancestry, non-shallow, dirty 0, lockfile, `node_modules`/`dist` absent, all five probe/pipe pins, predecessor blob equality and count. **No additional setup is needed beyond the reviewed native caller and the runtime grant** (the runner itself performs `npm ci`, gitleaks install/version check, and the Chrome trials under S4 Stage 2's slot). Not verified here and left to the runtime grant: node/npm versions, gitleaks 8.30.0, Chrome launch, any test counts. This read-back is not review, control, validation, or release evidence.

## Owned outputs

`execution/e8d546f9/s4-native-unshallow/{REPORT.md, MANIFEST.sha256, logs/U1-readback.txt}`; `MANIFEST.sha256` covers this directory except itself. Nothing else written.
