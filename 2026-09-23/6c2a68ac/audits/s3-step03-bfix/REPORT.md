# S3-STEP03-BFIX-REVIEW — narrow independent review (T4 proof-boundary child, lane B-fix)

Reviewer: independent nonbuilder/nonexecutor subagent of EXEC-6c2a68ac. Requested Claude Fable 5 / High is policy, not observed telemetry. Read/hash/file-inspect only; no node, candidate, steps, lock, probe, install, source or private writes. Parent verdict not read. Sole writes: this directory.

## Verdict: **GRANTABLE** (proposed replacement observation + explicit resume 04–14), under the exact conditions in §4.

## 1. Stopped result verified

`execution/6c2a68ac/s3-integration-result/`: `SHA256SUMS.txt` bf7800bd…, 20/20 OK, non-self-including, 21 files incl. manifest, no unmanifested files. REPORT.md read completely. Statuses in logs: T00/T01/T02/01/02 `exit=0 step_status=0`; 03 `exit=0` (generate: "Generated Prisma Client (v6.19.3)") with `postchecks_exit=1`, `step_status=1` caused solely by `postcheck: deepmerge-ts version rc=1 | expected=8.0.0 actual=` (stderr `ERR_PACKAGE_PATH_NOT_EXPORTED`); the other four step-03 post-checks (`@prisma/config` 6.19.3, write-tree a584a1b9…, non-staged 0, generated line) rc=0. `.holders` shows 10 lines, five start/end pairs, every `flock -n` acquired immediately, lock not held. 04–14 NOT RUN; no commit created.

Preserved state (re-inspected now, read-only): HEAD d5cd9b8b…, `.git/MERGE_HEAD` 5c7b42b3…, `git write-tree` a584a1b9…, unmerged 0, non-staged 0, `.git/hooks` contains only `*.sample` (0 real hooks), `core.hooksPath` unset, `node_modules/.bin/prettier` absent (step 05 not reached), product `package-lock.json` b7fed5ed…, tooling CLI 6e922134… present.

## 2. Root cause bound to bytes (B-class, affects only this integration proof)

- Root `package.json` carries `overrides: {"@prisma/config@6.19.3": {"deepmerge-ts": "8.0.0"}}`; the lock resolves `node_modules/deepmerge-ts` = 8.0.0 (resolved `…/deepmerge-ts-8.0.0.tgz`, integrity `sha512-ICNjaP0M…`) and contains **no nested copy** under `@prisma/config`; the filesystem agrees (single `node_modules/deepmerge-ts`, no `node_modules/@prisma/config/node_modules/deepmerge-ts`). Installed `node_modules/deepmerge-ts/package.json` (sha256 9db12600 31eec193 9456f013 05b401e2 c7f8c0b4 cb7707aa 0220741e efc71931) has `"version": "8.0.0"` and `exports` keys exactly `types, import, require` — `./package.json` is not exported. Under node v20.20.1 `require('deepmerge-ts/package.json')` therefore cannot succeed for this locked graph; the request-03 recording instruction (request e707ec2a…, §1 step 03 "record `node -p \"require('deepmerge-ts/package.json').version\"` → 8.0.0") is the defective element, not the product tree, the install, or the generate.
- Classification: **B** — invalidates completion of this integration proof only; no product/customer/data consequence (A) exists: no source byte changed, tree a584a1b9 constant through every step, no commit, no hook executed, runtime released.
- Grant rule check (`S3_PREP2_INTEGRATION_GRANT.md` 65950476…): "stop at the first nonzero or unknown" was correctly applied; "compound commands must preserve/check the consequential command's own status rather than mask it with a later … successful metadata read" is honoured by the step runner, which records `exit=` of the command separately from post-checks — so the stop was a truthful post-condition stop, and replacing the observation does not mask any command status.

## 3. Does the proposed replacement exactly close B?

Proposed: `node -p "JSON.parse(require('fs').readFileSync('node_modules/deepmerge-ts/package.json','utf8')).version"` → expected `8.0.0`.

- Records the locked installed version **without executing the package** (no module resolution of `deepmerge-ts`, no evaluation of `dist/*`; only `fs` + `JSON.parse`) and **without bypassing a product failure** (there is none: the consequential command exited 0 and its own status stays recorded). It reads the same hoisted file the original `require()` would have resolved, which is also the copy `@prisma/config` resolves (no nested copy), so it evidences that the override took effect for @prisma/config's resolution.
- Expected value confirmed by my own file read: `8.0.0`. Yes — it exactly closes the single failing post-condition. It is the minimum: one observation, no command re-run, no reinstall, no regenerate.
- Binding: path is relative to cwd `$W=/home/user/workspace/worktrees/s3-prep2`; the lock (b7fed5ed…) pins the version/resolved/integrity; the tree a584a1b9 is unaffected by any of this (`node_modules` is gitignored).

## 4. Exact grant conditions (all C-level; none requires retry or reinstall)

1. Run the replacement observation once, as a **post-record observation for step 03** (label e.g. `03R-deepmerge-record`), from cwd `$W`, under the same request-02 lock/attribution/raw-status pattern (canonical `flock -n`, `.holders` start/end line, header stamp with `CHECKPOINT_DISABLE=1`, `timeout`), with raw `exit=` and the printed value recorded; `step_status` for 03R = 0 iff the value is exactly `8.0.0`. Do **not** re-run the step 03 generate command; the original 03 log stays frozen with its `step_status=1` and the parent disposition supersedes that post-condition explicitly in the resume record.
2. Record alongside, read-only: `sha256sum node_modules/deepmerge-ts/package.json` (expect 9db12600…), `sha256sum package-lock.json` (expect b7fed5ed…), `git write-tree` before/after (expect a584a1b9…), non-staged porcelain 0, `test ! -e node_modules/@prisma/config/node_modules/deepmerge-ts` (expect true). These are file reads, not new tests.
3. Then resume **04–14 in order** on the preserved substrate, without re-running T00–03, `npm ci`, or `prisma generate`; all other request-03 acceptance conditions, bounds, hook checks, commit message, targeted Jest list, first-nonzero stop and no-retry rules unchanged. Step 04's implicit precondition (node_modules present, 1117 packages from the exact lock) holds now.
4. Continue to disclose the already-observed engine-binary fetch (mtimes 16:44:25Z during generate; `PRISMA_ENGINES_MIRROR` unset) in the resumed report; no new network is expected in 04–14 except none (npm offline as specified).
5. Frozen inputs must still verify at resume start: request-03 e707ec2a…, grant 65950476…, stopped result manifest bf7800bd…, tooling CLI 6e922134…, lock b7fed5ed…, tree a584a1b9…, HEAD d5cd…, MERGE_HEAD 5c7b….

## 5. Other A/B in the stopped result? None.

Checked: T01 single declared registry read, tool manifests unchanged (3e2189ff…/6c39ea3d…); T02/01 prettier 3.9.6, tarball sha512 3a9374cf…a057ea, CLI 6e922134…; 02 lock b7fed5ed…, prettier absent from app graph, tree unchanged; 03 generate 0 with guarded env stamped inline and in header; engine fetch disclosed as the grant permits; no unexpected write or tree change; ownership released. C records only: output directory is the grant's `execution/6c2a68ac/s3-integration-result` rather than request-03's `execution/s3-composition-prep/slot-03/<UTC>` (grant supersedes; fine); the same `require('<pkg>/package.json')` idiom is used for `@prisma/config` and succeeded because that package exports `./package.json`.

## 6. Packet

`REPORT.md`, `FINDINGS.md`, `INPUTS_VERIFIED.sha256`, `MANIFEST.sha256` (non-self-including).
