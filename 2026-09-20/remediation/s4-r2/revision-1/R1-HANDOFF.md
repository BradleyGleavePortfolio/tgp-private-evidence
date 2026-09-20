# S4 R1 handoff — frozen candidate, proof pending

Status: WRITTEN + partially TESTED. Not audited, not merged, not deployed, not
enabled, not customer-accepted. Incomplete is not clearance.

## Frozen identity

- Worktree: `/home/user/workspace/worktrees/s4-importer`, branch `execute/20260920-s4-importer`
- Head: `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba`, tree `b8abca3c458e6bc1494333b1c44af8f38b651591`
- Parent: `49c1aa96fa2d6df9a09f22c97952b45d10271952` (= PR #25 head, preserved; chain #21 `fc7fdf6` → #23 `15636ff` → #24 `c0824cb` → #25 `49c1aa9` all ancestors)
- Merge-base with origin/main: `0111be661922234d670bbf23e23d270eec1b4a4e`
- Author/committer (`git var`): `Bradley Gleave <bradley@bradleytgpcoaching.com>`, no co-author trailer
- Bundle: `execution/s4-importer/s4-importer-a6d885a.bundle` (sha256 `9d6b1c303f6aed66dfb5fb5ef81874981021edf63adde627f156ea61e3d9e204`, refs: branch + origin/main, `git bundle verify` ok)

## Package (NEW candidate, not a recovered Agent83 artifact; no inherited audit claims)

- `dist/tgp-importer-extension-0.3.0-rc.1.zip` — 36 files, 208731 bytes,
  sha256 `0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c`
- Built twice from the dirty tree and once from clean head `a6d885a` → identical hash. Shipping bytes are identical to #25 head `49c1aa9` (this commit touches no manifest-reachable file).
- Copies: `execution/s4-importer/artifacts/tgp-importer-extension-0.3.0-rc.1.zip` and `.inventory.json` (source head, clean=true, per-file sha256/kind/referrers).

## Changed files in a6d885a (all non-shipping)

- `scripts/lib/shipping.mjs`, `scripts/package-extension.mjs` — manifest-closure packager, deterministic zip, CRC-verified reader
- `test/package-integrity.spec.js` — 15 tests
- `scripts/browser-load-proof.mjs` — isolated Chrome loader/boundary proof via DevTools pipe; `--negative-control`
- `jsconfig.json`, `types/punycode.d.ts` — pin `string_decoder` like `punycode` (root cause: stray `/home/user/node_modules/string_decoder@1.1.1` in this sandbox is pulled by `@types/node/process.d.ts` into the checked program, failing `tsc -p jsconfig.json` and therefore `check:hooks`; traced with `--explainFiles`)
- `package.json` — `package`, `proof:browser`, `proof:browser:control` scripts; `docs/PACKAGE_PROOF.md`

## Measured so far (this environment: Node v20.20.1, npm 10.8.2, 2 vCPU)

- Baseline on 49c1aa9: vitest 59 files / 1654 tests pass, exit 0 — `execution/s4-importer/logs/baseline-49c1aa9-vitest.log`
- `npx vitest run test/package-integrity.spec.js` — 15/15 pass (pre-commit tree; two spec defects fixed before commit)
- `tsc -p jsconfig.json` and `tsc -p jsconfig.scripts.json` — exit 0 after the pin
- `check:hooks`, `check:banned`, `check:flags`, `check:fixtures`, `check:production-preflight` — OK; eslint on new files clean; prettier check clean
- `unzip -tq` on the archive — OK

## Pending (NOT yet measured — do not treat as proven)

- Browser load proof (`scripts/browser-load-proof.mjs`, positive + negative control) — queued behind `execution/test-validation.lock` (held by S6 stage-A jest since 16:48Z); runner `execution/s4-importer/run-browser-proof.sh`, output will land in `execution/s4-importer/logs/browser-load-proof.<tag>.json` and `browser-proof.<tag>.log`
- Full vitest on a6d885a (expected 60 files / 1669 tests)
- `npm run lint` on the whole tree, `format:check` via repo script

## Known open items

- Browser proof, when it lands, is loader/boundary evidence only — not native import completion (G02/G09).
- Chrome available is Chrome for Testing 147.0.7727.15; `minimum_chrome_version` 116 not exercised.
- `optional_host_permissions ["*://*/*"]` remains (optional, user gesture); `platform_tab_live` message unhandled by worker (pre-existing, caught).
- Membership donor `312280bb` (C2b-0B): merges cleanly with head per `git merge-tree`, touches only `shared/blueprint/{membership,snapshot,url-templates}.js` + docs/tests, none manifest-reachable → zero effect on shipping bytes; not cherry-picked, disposition left to owner.
- #26 `d595092`: content already incorporated at 49c1aa9; not re-applied.
