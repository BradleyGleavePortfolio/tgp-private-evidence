# S5-SOURCE-FINGERPRINT — parent-authorized repo-local `core.abbrev 8` normalization (revision 1, frozen)

Writer: `restore_upstream_proof_inputs_muddwjad` (requested Claude Fable 5; runtime identity not observable). Executed 2026-09-23T01:27:43Z–01:27:46Z per parent decision (a): **only** `git -C /home/user/workspace/worktrees/s5-r4 config --local core.abbrev 8`. No fuller-history fetch, no new fingerprint pin, no code/runner change, no runtime/version/network/install/commit. Environment output-format normalization to reproduce the already-approved frozen patch bytes — not product repair, not a new audit cycle. Original restore packet `execution/e8d546f9/s5-source-restore/` immutable (MANIFEST re-verified OK).

## Before / after — `logs/F1-abbrev-normalization.txt`

| Fact | Before (01:27:43Z) | After (01:27:46Z) |
|---|---|---|
| `core.abbrev` | unset; no origin at any scope | **8**, origin `file:.git/config`, scope local; local config = 4 defaults + this key; `.git/config` sha256 `6ae9e03f…9254` |
| Dirty fingerprint (runner formula `sha256(git diff HEAD; status --porcelain --untracked-files=all; "\n")`) | `16cc5e72…cfa88` (≠ pin) | **`6850b32ef19436abe5b02f96c770f4c36ca8bea070e0c759310f17234c616aa0` = `PIN_DIRTY_FINGERPRINT` (setup L223 and T0 L185 formulas both reproduce it)** |
| Ordinary `git diff HEAD` vs frozen patch `c36258b3…5491` | differs in 4 lines (two `index` lines, 7 vs 8 hex) | **byte-identical**; `git diff HEAD` sha256 = `c36258b3…5491` |
| HEAD | `143d451ead6ccdbebd92ca3031ba7a89867d6cfc` | unchanged |
| Clean base tree | `d0e122d35022377196908b7d132fc34c1af2fc6b` | unchanged |
| Lock blob / sha256 | `354de3dae19449970497da6e4d87f0a1225a8f43` / `b7fed5ed…9c55` | unchanged |
| Status | ` M test/rls-g2-pg17-etq0.spec.ts` / ` M test/utils/g2-pg17-bootstrap.sh`, 0 untracked, index clean | unchanged |
| Post-image blobs | spec `ff5a38b89ecc4de064f04df1dd9213be6a05c15a`, bootstrap `85a636ba75607604032cef7af1d285cb198ca263` | unchanged |
| Hygiene | `node_modules` absent, `dist` absent, hooks 0, remotes 0 | unchanged |

Platform `/home/user/node_modules`: 210 entries (`ls -A`, point in time) — **not modified**; the setup runner takes its own before/after inventory. Baseline `source/backend` and private evidence porcelain 0.

## Readiness

All file/Git-checkable provenance gates of `run-s5-setup-npm-ci.v101.sh` (head, lock blob, pinned status, pinned fingerprint, `node_modules` absent, `/home/user/package.json` absent) and the T0 attribution gate (`ctl-t0-only.v101.sh` L184–185) now pass on the restored worktree. Required setup provenance for the parent to carry: `worktrees/s5-r4/.git/config` contains `core.abbrev=8` (repo-local; the only non-default key). Still runtime-only and not claimed: node/npm identities, the install itself, jest presence, T0 execution. No runtime grant implied.

## Owned outputs

`execution/e8d546f9/s5-source-fingerprint/{REPORT.md, MANIFEST.sha256, logs/F1-abbrev-normalization.txt}` (`MANIFEST.sha256` covers this directory except itself); the single config line in `worktrees/s5-r4/.git/config`.
