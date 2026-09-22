# SLOT A3-S4-VALIDATION — result and first-failure diagnosis

Allocation closed at 00:06:24Z with runner exit 1 (`logs/slot-run-2.exit.json`, last_step `10-browser-proof-positive`). No rerun and no product edit were made under A3. Head `2bcf1563`, tree `3e23f918`, working tree clean before, during and after.

## Cleanup verified (00:16Z)
`scripts/status-slot-run-2.sh`: runner pid 21879 not running; no `chrome`, `vitest`, `browser-load-proof`, `slot-run` or `flock` processes present (`pgrep -af`); no process holds `/home/user/workspace/execution/test-validation.lock` open (/proc fd scan). Chrome's scratch profile is removed by the proof script's own `finally` (`rmSync(scratch)`), so no Chrome debug log survived — a diagnostic limitation, noted below.

## Steps reached (all on exact head 2bcf1563, lock held by flock pid 21878 for the whole run)

| step | result | evidence |
|---|---|---|
| 00 preflight | head/tree/clean OK; base export verified against `git show 84471e99:` | `slot-run-2.console.log` |
| 01 npm ci (lock sha `262d4b69…cdae8`, unchanged) | exit 0 | `logs/01-npm-ci.*` |
| 02 prettier --check (6 changed files) | exit 0 — no formatting follow-up commit needed | `logs/02-*` |
| 03 vitest focused (10 files) | exit 0 — 113/113, incl. `session-ownership` 7/7, `refresh-admission-epoch` 5/5 | `logs/03-*` |
| 04 npm test (full) | exit 0 — 64 files, 1714/1714 | `logs/04-*` |
| 05 gitleaks 8.30.0 checksum-pinned install | exit 0 | `logs/05-*` |
| 06 npm run gates (banned, flags, fixtures, production-preflight, hooks, eslint, tsc ×2, format 51 files) | exit 0 | `logs/06-*` |
| 07 stale-caller probe, reject mode, candidate | exit 0, `pass:true`, `hasSession:true`, `authRequiredCount:0` | `logs/07-*` |
| 08 stale-caller probe, reject mode, base 84471e99 | exit 1 on the intended predicate (`pass:false`, `authRequiredCount:1`, `hasSession:false`; no crash) | `logs/08-*` |
| 09 npm run package (dist wiped first) | exit 0 — `tgp-importer-extension-0.3.0-rc.1.zip` sha256 **`6fe9a7be4be782e2bb28b77f1f6ef55a89db2c4ab8f3ff8bb966bc9dfed82858`**, inventory sha256 `2636b9e6…fde23` | `artifacts/` |
| 10 browser proof positive | **exit 1 — aborted before any check** | `logs/10-*`, `artifacts/browser-proof-positive.json` |
| 11 browser proof negative control | **NOT RUN** (runner stopped fail-closed) — no negative evidence exists for this zip | — |
| 12 final bundle/hashes | NOT RUN | checkpoint-1 bundle of the same head remains valid source evidence |

Reused with explicit applicability: L1-05..08 (coalescer + stale/success pair, same head 2bcf1563 and same base 84471e99, 23:50Z).

Hooks vs gates: the checkpoint commit ran no hooks (lefthook not installed then). `npm ci` in A3 installed lefthook; `check:hooks` verified the pinned hook configuration; eslint/tsc/prettier/banned gates ran explicitly. A gitleaks scan of the tree was NOT executed by `npm run gates` (the `secrets` hook only fires at commit time) — an explicit `gitleaks` scan belongs in the next slot.

## First failure — diagnosis (logs and source only)

Recorded error: `browser load proof aborted: Error: CDP timeout: Browser.getVersion` at `scripts/browser-load-proof.mjs:120`, 16 s after Chrome spawn (00:06:08 → 00:06:24). Evidence JSON: `kind: browser-load-proof:aborted`, `checks: []`, `exceptions: []`, `stderr: []`.

What the source says: the script spawns Chrome (`--headless=new --remote-debugging-pipe --no-sandbox …`) and immediately sends `Browser.getVersion`, the very first CDP command, under a fixed 15 000 ms per-command timeout. The failure fired on that first command; Chrome had emitted nothing on stderr and no target had attached. The extension zip was unpacked but **never evaluated** — no check ran, so this says nothing about the package.

Classification, with confidence stated honestly:
- **Not an artifact defect** (high confidence): zero checks executed; the abort is upstream of extension loading; the zip is byte-preserved for re-evaluation.
- **Environment / timing at the CDP handshake** (most likely, not proven): the same binary (`ms-playwright/chromium-1217`, 273 MB) and same script passed on 2026-09-20 in the R3 lane in 32 s for positive+negative. This sandbox booted ~1 h before the run (`uptime 1:31` at 00:16Z), so this was Chrome's first execution here — cold page-cache load of a 273 MB binary plus shared libs — and it started 3 s after eslint+tsc finished and ~30 s after the full 1714-test vitest run; 15-min load average was 1.53 on 2 CPUs at 00:16Z. A cold, contended first start plausibly exceeds the 15 s first-command window. I cannot prove this from the retained evidence because the scratch profile (and any `chrome_debug.log`) is deleted by the script's cleanup.
- **Harness fragility** (contributing): a single fixed 15 s timeout on the first CDP command with no readiness wait. `scripts/browser-load-proof.mjs` is a preserved R3 file (byte-unchanged in this lane); I am not altering it without parent decision.
- Explicitly not asserted: "flaky", and the R3 browser pass is NOT inherited — it was on different source and a different zip.

## Smallest next validation proposed (harness-only, no source change)
Single short slot, sequential, ≤ 4 min, one Chrome process at a time, same zip `6fe9a7be…2858` (bytes preserved in `artifacts/`):
1. Diagnostic: `time <chrome> --version` twice (cold vs warm exec) — records binary start latency without a browser session.
2. Warm the page cache (`cat <chrome> > /dev/null`), then `node scripts/browser-load-proof.mjs --zip artifacts/…zip --out artifacts/browser-proof-positive-2.json --chrome …` (positive; must exit 0), then the same with `--negative-control` (must exit 0 and print `negative control: DETECTED`). Keep the failed `browser-proof-positive.json` as-is.
3. `gitleaks detect --source worktrees/s4-r4 --no-banner` (explicit secrets scan; exit 0 required) and final bundle + `SHA256SUMS`.
If step 2 fails again with the same `Browser.getVersion` timeout on a warm binary and idle box, the classification changes to "harness/Chrome-environment defect in this sandbox" and I will come back to the parent before touching `browser-load-proof.mjs`.
