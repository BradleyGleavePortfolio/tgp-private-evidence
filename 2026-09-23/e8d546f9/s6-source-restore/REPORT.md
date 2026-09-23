# S6-SOURCE-RESTORE — mobile candidate d51a1910 + exact frozen C6 packet (revision 1, frozen)

Writer: `restore_upstream_proof_inputs_muddwjad`, T4 source-only restoration builder (requested Claude Fable 5; runtime identity not observable, not asserted). Executed 2026-09-23T01:31:17Z–01:32:11Z. Mechanical copy/checkout only: no edits, adaptation, hazard change, A/B/D retest, install, network, tool versions, process census, lock probe, runtime, or commit. Shared-primitive adaptations remain PAUSED (not touched).

Inputs read (only): `2026-09-22/op88/remediation/s6-c6-prep/{S6_C6_PREP.md, C6_EXECUTION_REQUEST.md, C6_SETUP_CORRECTION_REQUEST.md, MANIFEST.sha256}` and the runner/observer path pins; `execution/op88/OWNED_LAUNCH_SCOPE.md` (current C6 boundary: S6 C6-only runner `746e244d`, setup `91fe0f1b`, hazard v5 `a91bb732`/adapter/instrument `cf470101` immutable; S6 adaptations paused until primitive acceptance); G01–G22 (already loaded); bundle `2026-09-21/remediation/s6-r3/checkpoint-1/s6-r3.bundle`; baseline `source/mobile` (read-only).

## 1. Restored (both targets ABSENT before write; nothing overwritten)

| Target | Identity | Log |
|---|---|---|
| `/home/user/workspace/worktrees/s6-diagnostic` — standalone repo: byte copy of `source/mobile/.git`, origin removed (0 remotes, no promisor, `GIT_NO_LAZY_FETCH=1`); bundle `c0ad2994f899775bd821029b62c1c492991bf1ddf1ab184ec0a88a9d7e439662` ✔ verified `okay` (requires a5933fd6 = local base), fetched offline to `refs/restored/execute/20260921-s6-r3`; `checkout --force --detach` | HEAD **`d51a191098f483cea9abec6cc7e9f3beffd18c06`**; tree **`62bf67b88e0f123f1a23ee34a1a75cb43029d9fb`**; parent `55db31a0…`; base **`a5933fd6de5616493de75f0db907098b149b955c`** is ancestor, 15 commits base..HEAD (matches prep §2); porcelain 0 (also `--untracked-files=all`), diff-index 0; 1090 tracked = 1090 files; 0 missing blobs; fsck connectivity ok; `package-lock.json` blob `6c56385d33db5fa703f8dc37a78381b8e2ba89a1` / sha256 `840be0b8…6b69` and `package.json` sha256 `63e2e2e2…0d5f` = prep §2 provenance; lockfile pins `@tanstack/query-core 5.100.14`; `jest.setup.js` present; `node_modules` absent, `dist` absent, hooks 0, `core.hooksPath` unset; HEAD author/committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`. Repo is shallow at a5933fd6 (as the baseline; no C6 script checks shallowness). | `logs/M1` |
| `/home/user/workspace/execution/op88/s6-c6-prep` — tar copy with modes of the frozen packet (source manifest re-verified 19/19 first) | 20 files (19 + `MANIFEST.sha256`); **19/19 OK from its own directory; canonical `MANIFEST.sha256` sha256 = `04d761f0421cfbdc99058bbbcf9c5ad4d420a76ae45b258c33c0ed0e925709a6`**; runner-subset `c6/MANIFEST.c6.sha256` 11/11 OK; hazard v5 **`a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d`**, adaptor **`3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3`**, instrument `s6diag.main.js` **`cf4701010365cb87326c17c901c4f6c941b84ea5d3dceb3f4c5e38c21e51c1d0`**; C6 runner `746e244d…1c11b` (= OWNED_LAUNCH_SCOPE reference), observer `f140787a…`, classifier `2715cf11…`; exec bits 1/2 `*.sh` as archived; files made read-only, directories 0755; `logs/` **not** created. | `logs/M2` |

## 2. File-existence-only setup inputs — `logs/M3`

PRESENT: WT + `package.json`/`package-lock.json`/`jest.setup.js` + the two product files cited by the review; C6 packet, runner, observer; platform `/home/user/node_modules` (210 entries, point-in-time, untouched — the setup's ancestor gate compares its own before/after); `/usr/local/bin/{node,npm}` (paths only); canonical lock file (exists, empty; not probed). Preserved setup script `run-c5-setup-npm-ci.v3.sh` `91fe0f1b…7bd1` present in private evidence (read-only; not restored — outside this slice's writes).

Correctly ABSENT: `worktrees/s6-diagnostic/node_modules` (the C6 runner would `die provenance-node-modules-absent-setup-not-granted 2` until a separately granted positive fresh setup), `dist`, `.git/hooks/pre-commit`, `/home/user/package.json` (setup P4), `execution/op88/s6-c6-prep/logs`, `execution/s6-diagnostic` (historical setup `EX` path — not created; ownership decision per `C6_SETUP_CORRECTION_REQUEST.md` §5).

Observation recorded, not acted on: private-evidence porcelain 1 = untracked parent-owned `execution/e8d546f9/S2_V59_CONTROL_GRANT.md` (HEAD 3c97cab); not read or written by this slice.

## 3. Ownership scope returned

Fresh sole ownership taken and now released for parent disposition: `worktrees/s6-diagnostic/**` (pristine, clean head), `execution/op88/s6-c6-prep/**` (exact frozen packet at its pinned path), `execution/e8d546f9/s6-source-restore/**`. **All runtime held**: no setup grant, no C-only run, no controls, no primitive adaptation; C6 blockers B1–B4 (prep §8) and the paused primitive acceptance stand unchanged. Baseline `source/mobile` unchanged (HEAD a5933fd6, porcelain 0, refs 2, 1 worktree).

## 4. Owned outputs

`execution/e8d546f9/s6-source-restore/{REPORT.md, MANIFEST.sha256, logs/M1, M2, M3}`; `MANIFEST.sha256` covers this directory except itself. Restored trees are identified by the Git ids and the packet's own canonical manifest above.
