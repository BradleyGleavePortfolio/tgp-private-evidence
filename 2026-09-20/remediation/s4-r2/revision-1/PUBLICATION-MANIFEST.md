# S4 R2 publication manifest — candidate c5a5ae1

All source bundles require only the PUBLIC base `0111be661922234d670bbf23e23d270eec1b4a4e`
(origin/main of github.com/BradleyGleavePortfolio/tgp-importer-extension). Nothing was
pushed to that repo; audits and evidence stay in `execution/` (private archive is parent-owned).
Contains no binaries, no secrets, no customer data; the only "token" anywhere is the literal
string `synthetic.header.payload-not-a-real-credential`.

## Heads

| ref | commit | tree | note |
|---|---|---|---|
| public base | `0111be661922234d670bbf23e23d270eec1b4a4e` | — | origin/main |
| PR #25 head (preserved) | `49c1aa96` | — | last public chain member |
| R1 frozen head | `a6d885a10d7dbc64e99961f44e0f6fe7bea5dfba` | `b8abca3c458e6bc1494333b1c44af8f38b651591` | unchanged, audited (not cleared) |
| R2 intermediate | `a2a52fd461398c34b301e5ebfaeafae7c7c8de6c` | `7c7f86adaa97795a2cb1b5d79f6498bf0810180c` | gating + origin-only text + harness rebind |
| **R2 final** | **`c5a5ae12c5b3c3e32a4601c99319ad7c0d980057`** | **`5f3c8f6a729427ce6c23bcb1ba18dc7b986b7447`** | worker-readiness wait |

## Source bundles (`git bundle verify` OK; refs `execute/20260920-s4-importer`, `origin/main`)

| file | sha256 | head |
|---|---|---|
| `s4-importer-a6d885a.bundle` | `9d6b1c303f6aed66dfb5fb5ef81874981021edf63adde627f156ea61e3d9e204` | a6d885a (R1) |
| `s4-importer-c5a5ae1.bundle` | `f99feba3b4016159cb7ed9351a0f05d5e41f235a6ebf0210e23b170791d97ca9` | c5a5ae1 (R2) — supersedes, contains a6d885a |

Restore: `git clone <public repo> && git fetch ../s4-importer-c5a5ae1.bundle execute/20260920-s4-importer:execute/20260920-s4-importer`

## Shipping packages (36 files each; `node scripts/package-extension.mjs` reproduces byte-identically)

| file | sha256 | bytes | source head |
|---|---|---|---|
| `artifacts/tgp-importer-extension-0.3.0-rc.1.zip` (+ `.inventory.json`) | `0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c` | 208731 | a6d885a (= #25 shipping bytes) |
| `artifacts/tgp-importer-extension-0.3.0-rc.1.c5a5ae1.zip` (+ `.c5a5ae1.inventory.json`) | `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98` | 209725 | a2a52fd / c5a5ae1 (identical shipping bytes; harness commit is non-shipping) |

## Logs — PASSED (all at c5a5ae1, clean tree, under test-validation.lock)

- `logs/full-gates.c5a5ae1.log` — summary: vitest/lint/type-check/format:check/gates all exit 0; package reproduce `e2ee1f5c…`
- `logs/vitest.c5a5ae1.log` — 61 files / 1678 tests passed
- `logs/lint.c5a5ae1.log`, `logs/type-check.c5a5ae1.log`, `logs/format-check.c5a5ae1.log`, `logs/gates.c5a5ae1.log`
- `logs/browser-proof.r2c.log` — positive 11/11 PASS exit 0; negative control DETECTED exit 0
- `logs/browser-load-proof.r2c.positive.json`, `logs/browser-load-proof.r2c.negative-control.json` — evidence bound to zip `e2ee1f5c…`, inventory source head c5a5ae1
- `logs/baseline-49c1aa9-vitest.log` — R1 baseline at #25: 59 files / 1654 passed

## Logs — FAILED / HELD (preserved, not hidden)

- `logs/browser-proof.try1.log`, `try2.log`, `try3.log`, `browser-load-proof.try3.json` — R1 harness bound to Chrome component extension (`nkeimh…` thunk.js); diagnosis in `DIAGNOSIS-browser-proof-try1-3.md`
- `logs/run-try4.out` — try4 cancelled per user override (see `HELD-STATUS.md`)
- `logs/browser-proof.r2a.log`, `browser-load-proof.r2a.positive.json`, `browser-load-proof.r2a.negative-control.json` — at a2a52fd, both aborted (`chrome.runtime` undefined ~1.5 s after launch; attach raced worker bindings); fixed in c5a5ae1
- `logs/browser-proof.r2b-dry.log`, `browser-load-proof.r2b-dry.*.json` — dry run of the uncommitted readiness fix at a2a52fd+dirty (PASS/DETECTED); superseded by r2c

## Scripts / patches / held deltas

- `run-browser-proof.sh` — lock-wrapped positive+negative proof runner (records head/tree/dirty/zip hash)
- `run-full-gates.sh` — lock-wrapped vitest/lint/type-check/format/gates/package runner
- `uncommitted-harness-fix-after-a6d885a.patch`, `browser-load-proof.harness-fix.uncommitted.mjs` — the held R1 harness delta (frozen per user override); its content is incorporated in a2a52fd/c5a5ae1, kept for traceability
- In-repo: `scripts/package-extension.mjs`, `scripts/lib/shipping.mjs`, `scripts/browser-load-proof.mjs`, `test/package-integrity.spec.js`, `test/router-principal-gate.spec.js`, `docs/PACKAGE_PROOF.md`

## Documents

`REPORT.md` (this candidate), `R2-CHECKPOINT.md`, `R1-HANDOFF.md`, `HELD-STATUS.md`, `DIAGNOSIS-browser-proof-try1-3.md`, `MILESTONE-1.md`; auditor reports `execution/audits/s4-r1/{a,b}/REPORT.md` (parent-owned).

## Reproducible browser setup (no binaries, no secrets)

1. Node 20.x; `npm ci` in the restored worktree.
2. Chrome for Testing 147.0.7727.15 (any recent Chrome ≥116 with MV3 should work): `npx @puppeteer/browsers install chrome@147.0.7727.15` or Playwright's `chromium-1217`; point `TGP_CHROME=<path to chrome binary>` (or `--chrome`). If absent the script exits 2 and prints `GAP: no Chrome binary` — an explicit gap, never a pass.
3. `openssl` on PATH (the script generates a throwaway self-signed cert per run and pins its SPKI via `--ignore-certificate-errors-spki-list`).
4. `npm run package` → expect zip sha256 `e2ee1f5c…` at c5a5ae1.
5. `npm run proof:browser` (exit 0 = all checks pass) and `npm run proof:browser:control` (exit 0 = defect detected by signature). Evidence JSON path printed on stdout.
6. Chrome flags used (from the script): `--headless=new --remote-debugging-pipe --user-data-dir=<tmp> --disable-extensions-except=<dir> --load-extension=<dir> --host-resolver-rules="MAP app.truecoach.co 127.0.0.1, MAP * ~NOTFOUND" --testing-fixed-https-port=<port> --ignore-certificate-errors-spki-list=<spki> --no-first-run --no-default-browser-check --disable-background-networking --disable-component-update --disable-sync --disable-gpu --no-sandbox`. No real network egress is possible from the browser (resolver rule).

## File hashes (every file in execution/s4-importer at publication time)

| file | sha256 |
|---|---|
| `artifacts/tgp-importer-extension-0.3.0-rc.1.c5a5ae1.inventory.json` | `531a8af7234e0b413b2e48522ac43ad5c1413d54e5777db703f3a652df632936` |
| `artifacts/tgp-importer-extension-0.3.0-rc.1.c5a5ae1.zip` | `e2ee1f5cc09094f3485c07db866d02f73f2a086d5a4d22e362da5e904b2e1e98` |
| `artifacts/tgp-importer-extension-0.3.0-rc.1.inventory.json` | `1e6f82ce53e9f669bd4e07e74fdc625b23e2a8905b109704b601bf5c1084b20a` |
| `artifacts/tgp-importer-extension-0.3.0-rc.1.zip` | `0b2f377dacfeca2eba84e90792cea11ff262b8e78b49717ee2badf81ae927e6c` |
| `logs/baseline-49c1aa9-vitest.log` | `6bb65cbae642050428e58201f788f4ca87a97b46a8fa6861abc2c38b1425115d` |
| `logs/browser-load-proof.r2a.negative-control.json` | `d19be13f84ad48396bbdafa561c70f6150571e41b0a182ee6cd6be0e8dc4b81b` |
| `logs/browser-load-proof.r2a.positive.json` | `61193bee5e8eb22f5176fd22ab550f63fdbff77a5b0a5375f72281ac2549bf55` |
| `logs/browser-load-proof.r2b-dry.negative-control.json` | `62e7ca7c4e35dd5c8370664c4f9f54e693a9b3459098e6d961f05c6b9a782324` |
| `logs/browser-load-proof.r2b-dry.positive.json` | `b1d56045c873a56c5281e0add8e4e498e364c75bd642e977fbfd0d8dba4abc47` |
| `logs/browser-load-proof.r2c.negative-control.json` | `4b022ae0cd1b54c3bf822d0fa97864fb31143a7cf59bd9fc2a91f3865f0fecb4` |
| `logs/browser-load-proof.r2c.positive.json` | `a1653ede4403e358da2ac66d60840badf0f1473c4e241051517da5dbfc714f38` |
| `logs/browser-load-proof.try3.json` | `61025385a255d5c4f2361ca997f3618e7ac30054f7f9d944540b283a2ba5f08e` |
| `logs/browser-proof.r2a.log` | `ec5bfe136a6cab000fd9d16e9d1be92f4d67973e0d048fe9504e205ea8c67dcf` |
| `logs/browser-proof.r2b-dry.log` | `5209325375384c88f40a4507fd3561c6f50db92aee478993fc47ca8adf0df3fc` |
| `logs/browser-proof.r2c.log` | `2006224ea1f4cbc62711c9fa856fdb56abb070fddd61f3290ee7afa192fe2760` |
| `logs/browser-proof.try1.log` | `f0976be62f05b2c79f87f1630f91ba27e31e744057b9e17e5e45a0385172acc7` |
| `logs/browser-proof.try2.log` | `9b2d3e9592c9d9c7dafe035d8bdc54b3268a659fc60e1233eaa03cc15d074d3f` |
| `logs/browser-proof.try3.log` | `fd8f0ed5be94aa8f42cad665b61ff0d21decdba22ecbddaef68f1c7e71e3659f` |
| `logs/format-check.c5a5ae1.log` | `1e7a027b3ec2bc637848868c5b3891d6701a49b5a4e0dcf9c259162b0701bb53` |
| `logs/full-gates.c5a5ae1.log` | `25e7894435729d833a5c0c5c5cdec427a00b93943813522bc63b185819ebbfbd` |
| `logs/gates.c5a5ae1.log` | `adaabc0161c6dc7bb52ff80531471e20173781419727ff5cc2b1339e31e7de7a` |
| `logs/lint.c5a5ae1.log` | `bcbab0c0e27a5f1eb98ebffc7844edb3d9469cd9486c90d59b7c1175fa235172` |
| `logs/run-full-gates.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-r2a.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-r2b-dry.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-r2c.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-try1.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-try2.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-try3.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/run-try4.out` | `e3b0c44298fc1c149afbf4c8996fb92427ae41e4649b934ca495991b7852b855` |
| `logs/type-check.c5a5ae1.log` | `9413499f5cb01ccae380beea8d5e824b7797091a5ca65c170d10b15d84be4e79` |
| `logs/vitest.c5a5ae1.log` | `bc735801290d144b3a548a2b3691dcb8de8ca2b288af3cbb5df0e2273b493e05` |
| `DIAGNOSIS-browser-proof-try1-3.md` | `d337ffd5ddd9215e4d6ae30bf317bfac82b8db6bba8a2b77d03ec2239522ccd4` |
| `HELD-STATUS.md` | `f225f76ba6f64366a30e3070feca219953f916ebd6dbdaa5626ab2e6b5aad950` |
| `MILESTONE-1.md` | `b0422630f0ab06c9fe10e7e10834e3cdc570fcc8383d9431fdcb4d41f5d6e721` |
| `R1-HANDOFF.md` | `3c05c446be611f24edd3eee8df0c229807a7a570beb26d1e4a7e2b018a9b7aec` |
| `R2-CHECKPOINT.md` | `122b883c7338c03045b5726b8010e9db683e6471c355b3d168420faefebfa01b` |
| `REPORT.md` | `ad40f2322fd656f9477f7cbf208c2178f4511391bd2fec89689d46da8edae1c2` |
| `run-browser-proof.sh` | `89c608002f04fd655824648cc8320f61406025f618e569f338dbe1ced8bacb0f` |
| `run-full-gates.sh` | `355a5c63bbcb9c7899710052ced2908ec15ba888cd89c7742b6e8d8c36a520f4` |
| `uncommitted-harness-fix-after-a6d885a.patch` | `c3120729729ac51558d84a9d217e677429dce8709ba1aea0ed345d3a32299725` |
| `browser-load-proof.harness-fix.uncommitted.mjs` | `c08fb85c413f9465e076938410f56b6d11b57a4e453d8c779d7e4690c836ba3b` |
| `s4-importer-a6d885a.bundle` | `9d6b1c303f6aed66dfb5fb5ef81874981021edf63adde627f156ea61e3d9e204` |
| `s4-importer-c5a5ae1.bundle` | `f99feba3b4016159cb7ed9351a0f05d5e41f235a6ebf0210e23b170791d97ca9` |
