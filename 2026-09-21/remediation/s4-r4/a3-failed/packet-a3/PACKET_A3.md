# S4 R4 — frozen packet after SLOT A3 (checkpoint 1 + A3 evidence)

Worker `s4_r4_auth_race_fixer_mubv6s6j`; requested Claude Fable 5 / High, actual verifiable identity: API-hosted AI subagent. Reimplementation lane. Integrity list: `packet-a3/SHA256SUMS` (55 files).

## Source identity (frozen, unchanged through A3)
head `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3` · tree `3e23f91824689d1f179a116af948eae0ed5ae170` · parent/base `84471e99…` · bundle prereq `0111be66…` · author = committer Bradley Gleave · clean before/during/after (exit record `dirty_at_end: ""`). Bundle: `artifacts/checkpoint1-2bcf1563/s4-r4-checkpoint1-2bcf1563.bundle` sha256 `dbaa346c…4c3b2` (parent-verified import). Hooks: none ran at commit (lefthook absent then); A3 ran the gates explicitly.

## Package
`artifacts/tgp-importer-extension-0.3.0-rc.1.zip` sha256 **`6fe9a7be4be782e2bb28b77f1f6ef55a89db2c4ab8f3ff8bb966bc9dfed82858`** (fresh build from wiped `dist/` on 2bcf1563; inventory `2636b9e6d636048ef0edc4469181d1bd230eb51837407b1f7c905312e11fde23`). R3 zip `90883cad…` is not inherited.

## Actual step counts (A3, lock held 00:01:20Z–00:06:24Z by flock pid 21878, runner pid 21879, all on 2bcf1563)
- 01 `npm ci` (lock sha `262d4b69…cdae8`) exit 0
- 02 prettier --check 6 changed files: exit 0 (no format commit needed)
- 03 vitest focused: 10 files, **113/113** (session-ownership 7/7, refresh-admission-epoch 5/5)
- 04 `npm test`: **64 files, 1714/1714**
- 05 gitleaks 8.30.0 checksum-pinned install: exit 0 (installed only; **no tree scan was executed** — `check:hooks` validates hook config, the secrets hook fires at commit)
- 06 `npm run gates`: exit 0 (banned-token+commit identity, flags, fixtures, production-preflight 5 PASS, hooks config, eslint 0 warnings, tsc ×2, Prettier 51 tracked files)
- 07 stale-caller probe reject-mode, candidate: exit 0, `pass:true`, `hasSession:true`, `authRequiredCount:0`
- 08 same probe, base 84471e99 export (hash-verified): exit 1 on intended predicate `authRequiredCount:1`, `hasSession:false`, `pass:false`, no crash
- L1 (23:50Z, reused, same head/base): coalescer candidate 0 / base 1 (2 duplicate presentations); stale success-mode candidate 0 / base 1
- 09 package: exit 0 → zip above
- 10 browser proof POSITIVE: **exit 1, aborted** — `CDP timeout: Browser.getVersion`, 00:06:08→00:06:24Z, `checks: []`, `exceptions: []`, `stderr: []`
- 11 browser proof NEGATIVE CONTROL: **NOT RUN** — no negative evidence exists for zip 6fe9a7be
- 12 final bundle: NOT RUN (checkpoint-1 bundle of the identical head stands)

## Cleanup (verified 00:16Z)
runner/Chrome/vitest/flock processes absent (`pgrep -af`); lock file open by no process (/proc fd scan); exit record written by runner after stop.

## First failure — smallest observed transport cause
Transport in the script is **`--remote-debugging-pipe` over spawn stdio fds 3 (in) / 4 (out)** — there is **no WebSocket, no TCP port, no Node `ws`** in the path. Observed: Node wrote `{"id":1,"method":"Browser.getVersion"}\0` to fd 3 and received **zero bytes on fd 4 within the fixed 15 000 ms** per-command timeout; Chrome wrote **zero bytes to stderr**; no `Target.*` event arrived. Chrome did exec (a spawn failure would surface as an unhandled `error` event, not this timeout) and did not fail at the loader (that prints to stderr). The script has no `child.on("exit")` handler, so "Chrome exited silently" vs "Chrome alive but not yet serving the pipe" are **indistinguishable in the retained evidence**; the scratch profile (and any `chrome_debug.log`) was deleted by the script's own `finally`. Same binary + same script passed in R3 on 2026-09-20 (32 s, different zip). Context, not proof: first Chrome exec in this sandbox (booted ~1 h earlier; 273 MB binary cold), started 3 s after eslint/tsc and 30 s after the 1714-test run; 15-min load 1.53 on 2 CPUs. **No environment-only or "flaky" label is asserted; no retry and no source change were made.**

## Discriminator to separate Chrome / pipe transport / harness (proposed, ≤ 3 min, one Chrome at a time, no source change)
1. Chrome-alone, no Node: `timeout 60 <chrome> --headless=new --remote-debugging-pipe --no-sandbox --user-data-dir=<scratch> about:blank 3<<(printf '{"id":1,"method":"Browser.getVersion"}\0') 4>fd4.out 2>chrome.err`, timing first byte on fd 4, run cold then warm (`cat <chrome> >/dev/null` between). Also record Chrome's exit code.
   - bytes on fd 4 in < 15 s both runs → Chrome + pipe fine → **harness path** (Node spawn/stdio handling) is the cause → re-run the proof once on the same zip.
   - cold > 15 s, warm < 15 s → **cold-start latency vs fixed 15 s first-command timeout** → warm then re-run positive + negative proof on the same zip.
   - never answers / non-zero exit with `chrome.err` content → **Chrome environment defect in this sandbox**; back to parent with the stderr.
2. Then `gitleaks detect --source <worktree> --no-banner` (explicit secrets scan) and final bundle + SHA256SUMS on the same head.
