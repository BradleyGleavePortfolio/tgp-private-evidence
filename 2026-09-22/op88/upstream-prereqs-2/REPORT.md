# OP88-S1S2-STATIC-PREREQS — static prerequisite restoration (revision 1, frozen)

Writer: op88 upstream preparer acting as T4 canonical Fable builder role (model/settings not observable — not asserted). Source-only preparation in parallel with the independent S2 V5.6 audits; no audit output read. Frozen 2026-09-22T21:4xZ. Not review clearance; separate from any future controls/proof grant.

Inputs read (only): `execution/op88/s2-v56/CONTROL_REQUEST_10.md` §Environment prerequisites (sha256 `59424813…`, LANE-OK verified read-only), `execution/op88/s2-v56/inputs/INPUT_HASHES.txt`, frozen predecessor packet `tgp-private-evidence/2026-09-22/remediation/s2-setup-prep/proposal-1/` (37-entry `SHA256SUMS.outer` sha256 `ea926206…c6ee` = V5.6 input map), the verified S2 R3 bundle (`3b6cee48…0f75`), and — for path pins only — a bounded `rg` of the frozen v5.6 runner/driver (`WT=`, `LANE=`, `EXPECT_HEAD=`, `PRE_RUNNER=`, porcelain predicate). Product heads unchanged: d5cd9b8b / 56fb0d22.

## 1. Restored source and packets (both targets were ABSENT before write; no overwrite)

| CONTROL_REQUEST_10 prerequisite | Target | Restored identity | Evidence |
|---|---|---|---|
| 1. `worktrees/s2-runner53` at HEAD d5cd9b8b, tree c0ab87d4, `git status --porcelain --untracked-files=all | wc -l` = 0 | `/home/user/workspace/worktrees/s2-runner53` (standalone repo: byte copy of local baseline c23b9d9 + offline fetch of the verified bundle, `GIT_NO_LAZY_FETCH=1`, origin URL neutralised, promisor off) | HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`; tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`; **porcelain (untracked-files=all) = 0**; 2090 tracked files, 0 missing blobs; 23 commits since base; 56fb ancestor; detached HEAD, ref `refs/restored/execute/20260921-s2-composition-r2`; hooks 0, `core.hooksPath` unset, no node_modules; release.sh `8831f8f7…`, harness `c766a8d9…`, discriminator `82da49b2…`, verify.sql `266e62e9…`, lock `62b05b90…`; 165 migration dirs (164+1); tree id cross-checked against the op88-upstream odb | `logs/P2` |
| 2. `execution/s2-setup-prep/` restored from the frozen proposal; predecessor runner `fb0d7ce4…`; 37-file manifest verifying from ITS OWN directory | `/home/user/workspace/execution/s2-setup-prep/` — 38 files copied by tar with modes (37 manifest entries + `SHA256SUMS.outer`); nothing else created (no `runner-selftest-r531/`) | `cd execution/s2-setup-prep && sha256sum -c --quiet SHA256SUMS.outer` → **PRE-OK, 37/37**; runner sha256 `fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925`; manifest sha256 `ea926206e5a6fedc42b89c62bc1d27bb691d93969d90a7b32d87d2d058c6c7ee`; directory frozen `chmod -R a-w` | `logs/P1` |
| 3. Tools | observed: bash 5.3.9; `timeout` uutils coreutils 0.8.0 (`-k`/`--kill-after` and `--foreground` accepted per `--help`; not exercised); flock util-linux 2.41.3; pgrep procps-ng 4.0.4; setsid util-linux 2.41.3; sha256sum uutils 0.8.0; awk = mawk 1.3.4; git 2.53.0. node/npm present but not invoked. Versions recorded for the future grant receipt | `logs/P3` |
| 4. No pre-existing pattern matches | `pgrep -f` census for runner/stub/fixture/controls patterns: 0; postgres/psql/prettier/jest: 0 | `logs/P3` |

Notes on identity fidelity (recorded, not amended): (a) in the copied packet only 3 of 15 `*.sh` carry an exec bit, exactly as in the private-evidence checkout; the v5.6 driver invokes `bash "$PRE_RUNNER"`, so no mode change was made. (b) The s2-runner53 checkout is detached (the frozen runner checks `rev-parse HEAD`/tree/porcelain, not a branch name); file modes are as checked out and were deliberately NOT made read-only so the granted runner sees an unmodified tree. (c) Bundle prerequisite satisfied by the local base; no network at any step.

## 2. Distinguish: restored source vs pending gates

RESTORED (static, verified, hash-bound): prerequisites 1 and 2 above; tool inventory (3) and clean census (4) observed at 21:41:59Z (census is time-bound and must be re-observed at grant time).

STILL HELD / NOT DONE (unchanged): canonical lock file absent, not created; no installs (PG 17.6, app `node_modules`, clients — the packet's `infra/setup-10/20/30` scripts were copied, not run); no stub/real controls (`run-controls-v56.sh` sets probe…neg2 untouched); no runner selftest; no fixture/realproof state; no product/runner/path edits (the proposed v5.6.1 path amendment is unnecessary — both pins now resolve as frozen); no hooks/commit/schema; no DB/client/version invocation. Independent V5.6 A/B reviews remain the gate before CONTROL_REQUEST_10 can be granted; PROOF_REQUEST_11 remains further downstream (needs S2 owner's PG/fixture setup).

## 3. Preservation and isolation

`execution/op88/upstream-prep` 31/31 OK and `addendum-s3-parent` 7/7 OK (untouched). `worktrees/op88-s2`, `s5-r4`, `s6-diagnostic` neither read nor written. `worktrees/op88-upstream` unchanged (only used read-only for a tree-id cross-check). Baseline `source/backend` HEAD c23b9d9, porcelain 0, 1 worktree. Private evidence porcelain 0 at exit. No lane processes; lock never opened. Sole NEW writes: `execution/op88/upstream-prereqs-2/**`, `execution/s2-setup-prep/**` (38 files), `worktrees/s2-runner53/**`.

## 4. Missing concrete dependency

None for the static prerequisites of CONTROL_REQUEST_10 (all four items now satisfied or observed). Unchanged from earlier holds: PG 17.6 / fixture install and app dependencies for PROOF_REQUEST_11; 17/7 mutant control bytes (S1-R4B-03) still unpreserved.

## 5. Smallest next action

Parent: after both independent V5.6 exact-successor reviews freeze, grant CONTROL_REQUEST_10 (stub-only) against the now-restored pins; the grant receipt should re-run `LANE-OK`/`PRE-OK` and re-observe the pgrep census and `timeout_impl` at start. No Bradley decision needed for this preparation.

## 6. Owned outputs

`execution/op88/upstream-prereqs-2/{REPORT.md, MANIFEST.sha256, logs/P1–P3}`; `MANIFEST.sha256` covers this directory except itself. Restored targets are identified by the hashes above (and by their own `SHA256SUMS.outer` for s2-setup-prep); they are not re-listed in this manifest to keep the frozen predecessor manifest the single authority for its 37 files.
