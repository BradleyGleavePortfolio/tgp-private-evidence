# B/drain phase A — actual result (environment recovery + stage-2 remainder)

Worker `b_drain_exact_recovery_and_remainder_mufn6ybc`, 2026-09-24 14:54–15:05Z, under `B_ENVIRONMENT_RECOVERY_AND_REMAINDER_GRANT.md`. Requested route Claude Fable 5 (live label 5.1) / High; observed identity/effort not claimed as telemetry. Heavy slot `execution/test-validation.lock` held by the two drivers only (fd 9, `flock -n`), **released on exit; verified free at 15:05Z**. No PG tooling/cluster/bootstrap/O-client, no push/merge/deploy, no real data, no spending. Not self-accepted.

## 1. Environment recovery — rc 0, all pins matched

Driver `env-recovery/env-recovery.sh` (sha in `MANIFEST.sha256`, unchanged from proposal), launched 14:54:59Z, `DONE rc=0` 15:01:17Z. Receipts `env-recovery/logs/`.

| Step | Actual | Pin |
|---|---|---|
| `npm ci --no-audit --no-fund --ignore-scripts --loglevel=error` (node v20.20.1, npm 10.8.2) | 14:55:00→15:00:56Z, "added 1117 packages in 6m", rc 0; 649 entries, 717M | `node_modules/.package-lock.json` sha256 `05bc530a…bfd6b44` ✔; lefthook 2.1.9, prisma/@prisma/client 6.19.3, jest 30.4.2, ts-jest 29.4.9, typescript 5.9.3, eslint 10.5.0 ✔; write-tree `87798e74` unchanged ✔ |
| `prisma version` (engines fetch) + `prisma generate` | rc 0 | engines `c2990dca…` ✔; libquery `a2924eab…` ✔; schema-engine `5d42b181…` ✔; `.prisma/client/index.d.ts` sha256 `bf679a16…b72d5` ✔; tracked tree unchanged ✔ |
| Tooling Prettier from preserved manifests (`6c39ea3d…`/`3e2189ff…`) → `execution/cf8ff737/b-drain/tooling/prettier-3.9.6/` | rc 0, "added 1 package" | `prettier.cjs` sha256 `6e922134…7906e` ✔, `package.json` 3.9.6 ✔, `--version` 3.9.6 ✔; product `node_modules/.bin/prettier` → that CLI (absolute link, same shape as C1/RC71) |

No tracked byte changed at any step (`04-environment-receipt.txt`: HEAD `a0ea1bea`, write-tree `87798e74`, porcelain = 11 untracked v4 paths only).

## 2. Stage-2 remainder — rc 0

Driver `remainder/remainder.sh` (stages 2–7 = original `phase-a.sh` 31e061ec… verbatim except canonical binding path, template-hash guard, receipt copy — `remainder/remainder-vs-original-stage2-7.diff`), launched 15:03:04Z, `DONE rc=0` 15:04:59Z. Receipts `remainder/logs/`. RC71 detector not re-run; no recopy/reinstall/regenerate/census.

| Stage | Actual |
|---|---|
| Preflight/env reassert | base `a0ea1bea`/`87798e74`, 11 paths/modes/blobs == `frozen-v4/BLOBS.git-sha1`, `SOURCE.sha256` ✔, 8 accepted-file pins ✔, identity ✔, message sha `fca0b6aa` ✔, no bypass env, nm-record `05bc530a` ✔, client `bf679a16` ✔, prettier target `6e922134` + 3.9.6 ✔ (`01-env-reassert.txt`) |
| Genuine hooks | `./node_modules/.bin/lefthook install` rc 0, "sync hooks: ✔️(pre-commit, commit-msg)"; both hooks executable, reference Lefthook, `hooksPath` unset; sha256 pre-commit `e5723334…`, commit-msg `29f83d8e…` (`02-*`) |
| Stage | `git add` 11 paths → `write-tree` **`f4922ca070e887fb7f613ce955b12621b5c33156`** ✔, 11 `A` |
| Gates (first-nonzero stop, none) | tsc rc 0 (47 s) · eslint 8 paths rc 0 · prettier --check 8 paths rc 0 "All matched files use Prettier code style!" · check-r75 --mode=staged rc 0 "OK — no positive token change" · jest 2 suites, **42/42 passed** (9.7 s) — `04-*.log` |
| Hooked commit | `git commit -F commit-message.txt` rc 0; Lefthook pre-commit ran tsc ✔ eslint ✔ prettier ✔ banned-cast-tokens ✔ prod-readiness-quick ✔ (summary 47.03 s); commit-msg no-ai-tokens ✔ (`05-commit.stderr`, raw with ANSI) |
| **Head** | **`75a2863bf79a44f84050406d6878ec9a87f4053e`**, tree `f4922ca0…3156` ✔, parent `a0ea1bea…0992` ✔, author = committer = `Bradley Gleave <bradley@bradleytgpcoaching.com>` 2026-09-24T15:04:10Z, message == handoff §7 (diff empty), no trailers, 11 files +2323, post-commit porcelain empty (`06-*`) |
| Filled binding (NOT run) | template `fixture-proposal-v3/binding/b-pg-proof.sh` sha `25eb6837…` preserved; `execution/95633079/s7-b-drain/runtime/binding/b-pg-proof.sh` sha `a64d24de…`; substitution-only diff = exactly 10 changed lines (5 placeholders): EXPECT_HEAD `75a2863b…`, EXPECT_TREE `f4922ca0…`, EXPECT_SPEC_BLOB `9b31fd18…`, EXPECT_BOOTSTRAP_BLOB `b4503eef…`, EXPECT_FIXTURE_SHA `4525f01d…`; `D=` unchanged; `bash -n` ok; `PINS.txt` |
| Portable exports | `remainder/bundle/s7-b-drain-75a2863b….bundle` (requires `a0ea1bea`, verify ok) sha `ded7af9d…`, `.patch` sha `e7ade9db…`, `BUNDLE.sha256` |

Worktree `/home/user/workspace/worktrees/s7-b-drain`: HEAD `75a2863b`, clean, standalone, no remote. `refs/s7/*` C1 refs retained.

## 3. Qualifications (C, nonblocking)

- "No environment equivalent" was checked only on: absent `worktrees/s7-c1` and old copy, private-evidence repo (no dependency tree archived), `~/.npm/_cacache` index (no pinned tarballs), `/home/user/node_modules` (generic), `/usr/local/lib/node_modules` (Prettier 3.9.9 — launcher hash coincides, version differs; not used). No wider census.
- Bundle refs live under `refs/s7/*` and required restoring the original shallow graft `c23b9d9f`; recorded in `recovery/01-clone.log`.
- Registry reads during `npm ci`/engine fetch/tooling `npm ci` are the same three C1 made; none afterward (`npm_config_offline=true` during the remainder).

## 4. PG tooling recovery — PROPOSAL ONLY (not run; separate grant)

`/home/user/pg17` and `/usr/bin/psql` are absent here (checked). The sealed runner requires `dist/bin/postgres` sha `23cd1748…`, `initdb` sha `b7db9bc2…`, `/usr/bin/psql`, `PROVENANCE.txt result=success`. Minimum: rerun the accepted C1 route byte-for-byte — `pg-tooling/b-pg-env-recovery.sh` is `c1-pg/c1-env-recovery.sh` (sha `0db738a6…`, ran RC=0 06:29Z) with exactly one changed line (receipt dir → `execution/cf8ff737/b-drain/pg-tooling/env/`; `pg-tooling/b-pg-env-recovery.sh.diff-vs-c1`). Pins/paths/bounds unchanged: apt `postgresql-client-18` (accept major ≥17; recorded 18.6, 600 s update + 900 s install), Maven jar `embedded-postgres-binaries-linux-amd64-17.6.0.jar` (300 s) SHA1 `81633223…`, jar sha256 `23da5a04…`, txz `26fa6334…`, extract to `/home/user/pg17/dist`, postgres/initdb sha256 as above, `pg_ctl` prefix `af53d826…`, refuses rc 70 on any mismatch, writes `PROVENANCE.txt`; outer bound `timeout -k 30 1500`; canonical slot. Creates no cluster, database, O-root or process; no C1/S5 rerun. After it, the single-run PG grant would execute the already filled `runtime/binding/b-pg-proof.sh` (outer `timeout -k 30 3600`).

## 5. Next

Parent: bind actual head `75a2863b` + gate receipts + filled binding for the two successor reviewers; then GO/NO-GO on `pg-tooling/b-pg-env-recovery.sh` and the separate single-run PG proof. No further action by this worker until then.
