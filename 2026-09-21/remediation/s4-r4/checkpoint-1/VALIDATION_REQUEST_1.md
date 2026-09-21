# S4 R4 — minimal validation slot request #1

Worker: `s4_r4_auth_race_fixer_mubv6s6j` (S4 R4 builder). Requested model Claude Fable 5 / High; actual verifiable identity: API-hosted AI subagent.
Written 2026-09-21 ~16:45 PDT. Nothing below has been executed; only `node --check`/`bash -n` and by-eye Prettier style review have run so far.

## Source fingerprint (frozen, clean)

| item | value |
|---|---|
| worktree | `/home/user/workspace/worktrees/s4-r4` (sole writer: this worker) |
| branch | `execute/20260921-s4-r4` |
| base (frozen) | `84471e99b278e964f7cb3f6bf9c78491064c41b7` |
| checkpoint head | `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3` |
| checkpoint tree | `3e23f91824689d1f179a116af948eae0ed5ae170` |
| dirty | none (`git status --porcelain` empty) |
| commit identity | author AND committer `Bradley Gleave <bradley@bradleytgpcoaching.com>`; no trailers |
| hooks | lefthook is NOT installed in this clone (`prepare` never ran; only `.sample` hooks) — the checkpoint commit ran no hooks. `--no-verify` was not used. Gates + gitleaks run explicitly in the slot below. |
| patch | `execution/s4-r4/artifacts/s4-r4-checkpoint1-84471e99..2bcf1563.patch` sha256 `2ca23ea330aa39b6516723423b6371e378ce92a6e6514e811cee413b983d5d79` |
| changed files | `background.js` (+218/-…), `shared/session.js` (+109/-…), `shared/log.js` (+1 KNOWN_EVENTS entry), `shared/replay/engine.js` (comment only), new `test/refresh-admission-epoch.spec.js`, new `test/session-ownership.spec.js` — 6 files, +829/−67 |
| untouched | `shared/net.js`, `shared/pairing.js`, `scripts/browser-load-proof.mjs`, manifest, message kinds, backend contracts |

## Dependency provenance

- `package.json` sha256 `74abc0d56c90efd5190b698d05691deda497af28ab4073549e501920bfd907b3`, `package-lock.json` sha256 `262d4b692e9cc1a7908435c36b8a4077d2dc130d37421a7a76175e4acc9cdae8` — byte-identical to the files R3 installed from (same hashes in `repos/tgp-private-evidence/2026-09-20/remediation/s4-r3/revision-1/logs/01-npm-ci.meta.json`). Not modified by R4.
- Exact pins: vitest 4.1.11, eslint 10.10.0, prettier 3.9.6, typescript 5.9.2, lefthook 2.1.12. Toolchain present: node v20.20.1, npm 10.8.2. No `node_modules` anywhere; no prettier/tsc/vitest/gitleaks binaries available outside the slot.
- gitleaks 8.30.0 via checksum-pinned `scripts/install-gitleaks.sh` (network fetch from GitHub releases) into `/home/user/.local/tgp-gitleaks` — only needed for the lefthook `secrets` hook / `check:hooks`; can be skipped if parent prefers no network install (then hooks-gate result is reported as not run).
- Chrome for browser proof: `/home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome` (already on disk).

## Commands (all through the wrapper; one lock, whole run)

Wrapper: `execution/s4-r4/scripts/run-slot.sh <label> <timeout-s> <cmd…>` — NONBLOCKING `flock -n` on `/home/user/workspace/execution/test-validation.lock` (exit 75, nothing run, if busy), stamps head/tree/dirty/diff-sha/toolchain/lock/command/start/end/exit into `execution/s4-r4/logs/<label>.meta.json`, tees to `logs/<label>.log`, preserves child exit code.

Parent said the whole granted run is one lock. To keep one holder for the whole run I will run the sequence below inside a single `flock -n` shell (`flock -n /home/user/workspace/execution/test-validation.lock bash execution/s4-r4/scripts/slot-run-1.sh`) whose inner steps each write their own meta stamp; the wrapper fd-9 lock is not re-taken inside (same process group, would fail closed) — inner steps stamp only.

Sequence (cwd `worktrees/s4-r4`):

1. `npm ci --no-audit --no-fund` (runs `prepare` → `lefthook install`, installing hooks for future commits) — ~1–3 min
2. `npx prettier --check background.js shared/session.js shared/log.js shared/replay/engine.js test/refresh-admission-epoch.spec.js test/session-ownership.spec.js` — seconds. If it fails I apply `prettier --write` to those files only, commit a follow-up as Bradley, and re-run.
3. `npx vitest run test/refresh-admission-epoch.spec.js test/session-ownership.spec.js test/refresh-coalesce.spec.js test/session-lifecycle.spec.js test/session-refresh-path.spec.js test/auth-body-deadline.spec.js test/start-import-hardening.spec.js test/ingest-auth.spec.js test/ingest-settlement.spec.js test/ingest-legacy-settlement.spec.js` — focused, ~1 min
4. `npm test` (full vitest) — ~2–3 min
5. `npm run gates` (banned/flags/fixtures/production-preflight/hooks/lint/type-check/format) — ~1–2 min. `check:hooks` may need gitleaks: `bash scripts/install-gitleaks.sh /home/user/.local/tgp-gitleaks` first (network).
6. Predecessor negative controls (dependency-free node, no network):
   - `node execution/s4-r4/scripts/coalescer-admission-probe.mjs worktrees/s4-r4` → expected PASS
   - `node execution/s4-r4/scripts/stale-caller-probe.mjs worktrees/s4-r4 success` and `… reject` → expected PASS
   - same three against a detached base checkout `git -C worktrees/s4-r4 worktree add /home/user/workspace/worktrees/s4-r4-base 84471e99` (read-only, removed afterwards) → expected FAIL (exit 1) with JSON showing the replacement session wiped / 2 refresh fetches. Base run needs the base's `test/helpers/background-mock.js` only (no deps).
7. `npm run package` → `dist/*.zip`; `sha256sum dist/*.zip > execution/s4-r4/artifacts/SHA256SUMS` — seconds
8. `node scripts/browser-load-proof.mjs --zip dist/<pkg>.zip --out execution/s4-r4/artifacts/browser-proof-positive.json --chrome /home/user/.cache/ms-playwright/chromium-1217/chrome-linux64/chrome` and `… --negative-control --out …/browser-proof-negative-control.json` — ~1 min each, single Chrome process each, sequential
9. `git bundle create execution/s4-r4/artifacts/s4-r4-<head>.bundle 0111be661922234d670bbf23e23d270eec1b4a4e..execute/20260921-s4-r4` + `git bundle verify`; hashes.

Target identity for every step: head `2bcf1563…` tree `3e23f918…` (or the follow-up commit if step 2 reformats — reported explicitly; any follow-up commit invalidates earlier steps, so I re-run 3–9 on the final head before freezing).

## Bounds
Expected total ≤ 15 min wall clock; ≤ 2 CPUs, < 2 GB RAM (vitest + one Chrome). No remote push, no live backend, no DB. Network only for `npm ci` (registry, lockfile-pinned) and optionally the gitleaks tarball.

## Artifact destinations
`execution/s4-r4/logs/*.log`, `logs/*.meta.json`, `artifacts/` (patch, bundle, zip, SHA256SUMS, probe JSON, browser proof JSON), `REPORT.md`.

## Negative controls included
- `test/refresh-admission-epoch.spec.js` case 5: an already-snapshotted stale run IS detached (predecessor semantics kept where correct).
- `test/session-ownership.spec.js` negative controls: current-session 401→refresh-null and 401→refresh-OK→retry-401 still clear tokens and broadcast `auth_required` exactly once.
- Base-vs-candidate probe pair (step 6): the same probes must FAIL on 84471e99 and PASS on the candidate.
- Browser proof `--negative-control` must fail as designed on the fresh zip.
