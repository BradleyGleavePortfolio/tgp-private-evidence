# S5-SOURCE-RESTORE (EXEC-6c2a68ac follow-on) — fresh `worktrees/s5-r4` = 143d451e + frozen two-file patch c36258b3 + repo-local `core.abbrev=8` — EXACT, COMPLETE

Writer: sole T4 source-restoration builder for the S5 canonical follow-on (requested Claude Fable 5 / High; runtime identity not observable, not asserted). Parent owner: EXEC-6c2a68ac. Executed 2026-09-23T15:46:26Z–15:47:12Z. Mechanical restoration only: no install, test, version probe, process census, canonical lock operation, signal, hook, product authorship, commit, network, or private-checkout write. Ownership of `worktrees/s5-r4/**` and this directory is released on this exact completion.

## Inputs read (only)

- Live G01–G22 (`tgp-startup/live/AGENT_RULES.md`); private `execution/6c2a68ac/SCOPE.md` (read-only archive checkout, not modified).
- Archived `2026-09-23/e8d546f9/s5-source-restore/REPORT.md` + `logs/S1-S2`, `S3` and `2026-09-23/e8d546f9/s5-source-fingerprint/REPORT.md` + `logs/F1` — the exact prior procedure and parent decision (a) that this restoration reproduces.
- Frozen setup runner / T0 control (read for pins and the fingerprint formula only, not executed): `2026-09-23/e8d546f9/remediation/s5-v101/controls-v101-t0/run-s5-setup-npm-ci.v101.sh` (`5f94783b…8087`; `PIN_HEAD`, `PIN_LOCK_BLOB`, `PIN_DIRTY_FINGERPRINT`, `PIN_DIRTY_STATUS` L49–52; `dirty_fingerprint()` L172; gates L221–226) and `ctl-t0-only.v101.sh` (`51fb43b7…d62c`; pins L70–71, gate L184–185).
- S5 bundle `2026-09-21/remediation/s5-r3/b3-pinned-resume/checkpoint-5-B3/s5-r3-candidate.bundle` — sha256 `e42aa021442a8a004bf796e2958461bf79d11c1666fe8fb08ef46dd80bd75b48` ✔, `git bundle verify` okay, requires c23b9d9f (= baseline HEAD).
- Patch packet `2026-09-22/remediation/s5-r4/checkpoint-1/` — `SHA256SUMS` 17/17 OK; `s5-r4-dirty-from-143d451e.patch` sha256 `c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491` ✔ (103 lines).
- Baseline `/home/user/workspace/source/backend` read-only: HEAD `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`, porcelain 0, shallow, in-pack 2512 before; HEAD/porcelain/remotes/refs/config sha256 (`0a9562c6…0e0a`) unchanged after.

Pre-checks: `worktrees/s5-r4` ABSENT, `execution/6c2a68ac/s5-source-restore` ABSENT, `execution/s5-r4` ABSENT (no collision). Git 2.53.0.

## 1. S1 — clean 143d451e restored — `logs/S1-restore-clean-head.txt`

| Fact | Value | Archived S1 | Match |
|---|---|---|---|
| Method | standalone repo = byte copy (`cp -a`) of `source/backend/.git`; `origin` remote and `branch.main` section removed → 0 remotes, no promisor; bundle fetched offline to `refs/restored/execute/20260921-s5-r3`; `checkout --force --detach 143d451e` | same | ✔ |
| HEAD | **`143d451ead6ccdbebd92ca3031ba7a89867d6cfc`** = `PIN_HEAD` | same | ✔ |
| Clean base tree | **`d0e122d35022377196908b7d132fc34c1af2fc6b`** | same | ✔ |
| Parent / ancestry | `b94c24889c8f5bf40a2749ad57c26173ab5ad64a`; c23b ancestor yes; 32 commits c23b..HEAD; shallow (as baseline) | same | ✔ |
| Clean state | porcelain 0; 2114 tracked = 2114 worktree files; 0 missing blobs; fsck connectivity ok | same | ✔ |
| Lock blob / sha256 | **`354de3dae19449970497da6e4d87f0a1225a8f43`** = `PIN_LOCK_BLOB`; `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55` | same | ✔ |
| Clean fingerprint (pre-patch) | `01ba4719c80b6fe911b091a7c05124b64eeece964e09c058ef8f9805daca546b` | same | ✔ |
| Refs | `refs/heads/main`=c23b9d9f, `refs/restored/execute/20260921-s5-r3`=143d451e (2 refs) | same | ✔ |

## 2. S2 — frozen patch replayed (working tree only) — `logs/S2-apply-frozen-patch.txt`

| Fact | Value | Match |
|---|---|---|
| Patch | `c36258b3…5491`, 103 lines, touches exactly `test/rls-g2-pg17-etq0.spec.ts` (`77bb94b6→ff5a38b8`, 100644) and `test/utils/g2-pg17-bootstrap.sh` (`c85eaca0→85a636ba`, 100755) | ✔ |
| Pre-image blobs at HEAD | `77bb94b638dfe74ed8e6b33d25d853cf51362ad2`, `c85eaca0cb3cb959d6238af2d20fe80fd4b2ef76`; `git apply --check` ok; `git apply` applied; index untouched, 0 untracked | ✔ |
| Status | `git status --porcelain` = `' M test/rls-g2-pg17-etq0.spec.ts\n M test/utils/g2-pg17-bootstrap.sh'` = **`PIN_DIRTY_STATUS` ✔** | ✔ |
| Post-image blobs (hash-object of working files) | spec **`ff5a38b89ecc4de064f04df1dd9213be6a05c15a`**, bootstrap **`85a636ba75607604032cef7af1d285cb198ca263`** = patch post-ids → tree content byte-exact; modes 644/755 | ✔ |
| Lock blob after | `354de3da…` / `b7fed5ed…9c55` unchanged | ✔ |
| Fingerprint with `core.abbrev` unset (auto; in-pack 2860 → 7-hex abbrev) | `16cc5e727a5490ccb8c37a192a517338546e85598b7ae32d6357e1081a9cfa88` ≠ pin; `git diff HEAD` vs patch differs in exactly the 4 `index`-line bytes | same contradiction as archived §2, reproduced not inferred |

## 3. S3 — repo-local `core.abbrev=8` only; fingerprint EXACT — `logs/S3-abbrev8-fingerprint.txt`

Executed exactly one config write, the parent-authorized decision (a) from the archived fingerprint packet: `git -C /home/user/workspace/worktrees/s5-r4 config --local core.abbrev 8`.

| Fact | Value | Match |
|---|---|---|
| `core.abbrev` | `8`, scope local, origin `file:.git/config`; local config = 4 defaults + this key (5 keys, no remote/branch sections) | ✔ |
| `.git/config` sha256 | **`6ae9e03f2f3302c88364cd54aa2edccca09d09fdd87e07d6e5606d71a1bf9254`** = archived post-normalization value → config bytes identical | ✔ |
| `git diff HEAD` sha256 | **`c36258b39d0c92f0b760f11982a61427c6e7cce963eecffe2554f447346c5491`** = frozen patch → byte-identical | ✔ |
| Dirty fingerprint, setup runner formula L172 `sha256(git diff HEAD; status --porcelain --untracked-files=all; "\n")` | **`6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0`** = `PIN_DIRTY_FINGERPRINT` | ✔ |
| Dirty fingerprint, T0 gate formula (`ctl-t0-only.v101.sh` L185) | `6850b32e…6aa0` | ✔ |
| HEAD / clean tree / lock blob / status / post-image blobs | unchanged from §1–§2 | ✔ |
| Hygiene | `node_modules` absent, `dist` absent, active hooks 0 (`pre-commit` absent, `core.hooksPath` unset), remotes 0, refs 2 | ✔ |
| Not created | `execution/s5-r4` absent; `/home/user/package.json` absent | ✔ |

Readiness statement (file/Git-checkable only): the provenance gates of `run-s5-setup-npm-ci.v101.sh` L221–224 (head, lock blob, pinned status, pinned fingerprint) and L225–226 (`node_modules` absent, `/home/user/package.json` absent) and the T0 attribution gate (`ctl-t0-only.v101.sh` L184–185) all evaluate true on this fresh worktree. Required provenance for the parent to carry: `worktrees/s5-r4/.git/config` contains `core.abbrev=8` as its only non-default key. Still runtime-only and NOT claimed: node/npm identities, the install, jest presence, T0 execution. No runtime grant requested or implied; S5 setup/T0 activation remains the parent's.

## 4. Not done / not claimed

No install, test, version probe, process census, canonical lock creation/open/probe, signal, hook, product edit, commit, network access (bundle fetch and `cp -a` are local-filesystem only), or private-checkout write. `source/backend` unchanged (HEAD c23b9d9f, porcelain 0, remotes 1, refs 2, config sha256 unchanged). `tgp-private-evidence` porcelain shows 4 modified + 1 untracked parent-owned files that pre-existed this run and are unrelated to my paths; nothing under it was written by this builder. Success here proves exact source bytes and exact pinned fingerprint only.

## 5. Owned outputs (released on completion)

`/home/user/workspace/worktrees/s5-r4/**` (including the single `core.abbrev=8` config line); `/home/user/workspace/execution/6c2a68ac/s5-source-restore/{REPORT.md, MANIFEST.sha256, logs/S1-restore-clean-head.txt, logs/S2-apply-frozen-patch.txt, logs/S3-abbrev8-fingerprint.txt}`. `MANIFEST.sha256` covers this directory except itself.
