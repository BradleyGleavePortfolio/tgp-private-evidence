# S4-NATIVE-RESTORE — source-only restoration of S4 R6 proof inputs (revision 1, frozen)

Writer: `restore_upstream_proof_inputs_muddwjad`, T4 source-only restoration builder (requested Claude Fable 5; runtime identity not observable, not asserted). Frozen 2026-09-23T01:1xZ. Hash/file-state only. No runtime, install, network, hooks, tests, browser, version commands, process census, source edit, or touch of any mutable runtime/v6 path.

Inputs read (only): `execution/e8d546f9/s4-v61/runner/s4-r6-validate-v6.sh` (sha256 `94edb27d…0301`; pins L32–57 and S00 block L83–106), `s4-r6-lib-v6.sh` (`64db67a6…5336`, hash only), `tgp-private-evidence/2026-09-22/op88/remediation/s4-v6/SLOT_REQUEST_V6.md` §3 (`c0fe3556…7198`), current R6 packet `2026-09-22/remediation/s4-r6/revision-1/` (`SHA256SUMS` 86/86 OK; `PREDECESSOR_EXPORT_NOTE.txt`, `probes/`, `artifacts/s4-r6-91990ae9.bundle`), baseline `source/extension` (read-only). No R5 bundle, no historical reports.

## 1. Restored (all targets ABSENT before write; nothing overwritten) — `logs/R1`, `logs/R2-R3`

| Runner pin | Target | Restored identity |
|---|---|---|
| `WT=/home/user/workspace/worktrees/s4-r6`; `EXPECT_HEAD` 91990ae9, `EXPECT_TREE` 840fb285, `EXPECT_PARENT` 88287cff, `EXPECT_BASE` 0111be66 ancestor, dirty 0, `EXPECT_LOCK_SHA` 262d4b69…, no `node_modules`, no `dist` | standalone repo: byte copy of `source/extension/.git` (origin removed, 0 remotes, no promisor, `GIT_NO_LAZY_FETCH=1`), current R6 bundle `af2c8207c9b04ca9089115e39e0a3298c6519b8f58b7238cc1a7c718a9bab0dd` verified (`git bundle verify` okay; requires 0111be66 = local base) and fetched offline to `refs/restored/execute/20260921-s4-r6`; `checkout --force --detach 91990ae9` | HEAD **`91990ae9aec72f47a67591892ac09fa1f59d2f16`**; tree **`840fb2855953d5363fbd144e11b3f81763d9cef7`**; parent **`88287cff47240aa58b5f0fea5da08670f1e87df6`** (tree `a2879859…76f9`); base **`0111be66…`** is ancestor, 22 commits base..HEAD; porcelain 0 (also with `--untracked-files=all`); 158 tracked = 158 worktree files, diff-index 0, 0 missing blobs, fsck connectivity ok; `package-lock.json` `262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8` ✔; `node_modules` absent, `dist` absent; hooks 0, `core.hooksPath` unset; author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`. |
| `PRED=/home/user/workspace/execution/s4-r6/predecessor-88287cff` (S00: every file's blob id == `88287cff:<path>`, file count == tree count) | `git archive 88287cff` from the restored odb | 158 files = 158 tree entries; **predecessor_blob_mismatches = 0** (runner predicate reproduced); the packet's one added `test/R6-CANDIDATE-COPY.session-ownership-preflight.spec.js` (`16c49c83…`) was **not** included per instruction (exact tracked tree only); the runner excludes that name from its predicate and no runner/launcher/control/probe step reads it. Frozen 0555. |
| `PROBES=/home/user/workspace/execution/s4-r6/probes` | tar copy of `revision-1/probes/` (8 files) | `a01-late-reporting-discriminator.mjs` **`890d45f7…2fbc`** = `PIN_A01_LATE` ✔; `reused/a01-preflight-barrier-discriminator.mjs` **`d1e1d428…d342`** = `PIN_R5_A01` ✔; `reused/a02-queued-refresh-discriminator.mjs` **`93465881…5d16`** = `PIN_R5_A02` ✔; `reused/bound-admission-probe.mjs` **`ae6d3e12…3cef`** = `PIN_R5_B` ✔; `spec-shim/{hooks,register,run-spec,vitest-shim}.mjs` copied with the packet (unpinned by the runner; hashes in log). Frozen 0555. |
| `PIN_PIPE_V6` | not a probes file; `execution/e8d546f9/s4-v61/runner/chrome-pipe-discriminator-v6.mjs` (pre-existing, untouched) | `c261ffb4…531b` ✔ |

## 2. Concrete boundary for the parent (not a defect in the restoration)

**Shallow repository.** Baseline `source/extension` is a shallow clone grafted at `0111be66` (`.git/shallow` = 0111be66; the raw commit object names parent `ec7578a6…`, which is absent). The restored `worktrees/s4-r6` therefore reports `git rev-parse --is-shallow-repository` = **true**, while runner S00 L88 requires `false` (`chk … shallow`). Ancestry base→parent→head is fully verifiable locally (22 commits, fsck ok), but the pre-base history cannot be materialised without network, which this slice does not have. Options are the parent's: (a) supply pre-0111 history/unshallow under an explicit grant, or (b) treat the shallow check as an environment fact for the V61 review. Nothing was fetched or altered here.

## 3. Environment inputs by file existence only — `logs/R4`

PRESENT: WT + lockfile + `scripts/install-gitleaks.sh` + `scripts/secrets-scan.sh`; PRED; PROBES; V61 runner/lib/pipe/launcher; Chrome at the runner default `/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome` (exec bit yes, 273,505,496 bytes, sha256 `696170a79640ec5b50c7518140ace06c69a49cfb295bf527d4a85e26a12b89a7` — file state only, not launched); `/usr/local/bin/{node,npm,python3}` (paths only, versions not queried); canonical lock file (exists, empty — created 00:56Z by the granted S2 probe; not opened here). Runtime lane `execution/s4-r6-validation/` and `…/v6/` exist (S4 Stage 1's) — neither read nor written.

Correctly ABSENT (runner refuses if present): `worktrees/s4-r6/node_modules`, `worktrees/s4-r6/dist`.

MISSING against runner requirements: `execution/s4-r6-validation/tooling/gitleaks/` (and any `gitleaks` on PATH) — installed by runner step S11 via `scripts/install-gitleaks.sh`, version-checked 8.30.0 at S11b; `node_modules` — created by the runner's own fresh `npm ci` step (must stay absent now). Node/npm versions (`EXPECT_NODE v20.20.1`, `EXPECT_NPM 10.8.2`) not verified this slice (not authorized); S2 setup at 00:57Z recorded the same sandbox's node v20.20.1 / npm 10.8.2 in its stamp, which the parent may cross-reference.

## 4. Bounded next setup proposal (not executed)

None needed for source. For runtime (when a slot is granted to S4 Stage 2): the runner installs gitleaks and node_modules itself; the only external prerequisite outside the runner is the parent's decision on the shallow precondition (§2). Chrome is already present at the default path.

## 5. Not done / not claimed

No fetch/install of tooling, no version commands, no process census, no hooks, no commit, no runtime path writes, no product edit. Baseline `source/extension` unchanged (HEAD 0111be66, porcelain 0, refs 2, 1 worktree). Private evidence porcelain 0. Success proves exact source and probe bytes at the pinned paths only — not validation, controls, review or release.

## 6. Owned outputs

`worktrees/s4-r6/**`; `execution/s4-r6/{predecessor-88287cff,probes}/**` (0555); `execution/e8d546f9/s4-native-restore/{REPORT.md, MANIFEST.sha256, logs/R1, R2-R3, R4}`. `MANIFEST.sha256` covers this directory except itself; restored trees are identified by the Git ids and pin hashes above.
