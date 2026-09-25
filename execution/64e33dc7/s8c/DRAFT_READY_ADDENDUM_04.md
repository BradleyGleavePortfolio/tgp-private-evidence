# DRAFT_READY addendum 04 — pin fill moved before attestation (2026-09-24 21:24 PDT)

Parent instruction: once the genuine source commit exists, fill the actual candidate/file/tool pins BEFORE the dual reviewers attest final head + filled binding; record template→filled diff and hash. Filling is authorized preparation, not a PG run. Prettier restoration active; S8-C source relay follows S7-L's short completion.

## Changes (source-only; nothing executed beyond `bash -n`)

- `binding/PINS.txt` and `binding/README.md`: order updated — hooked commit → **fill nine pins from the committed head** → record diff/hash → dual review attests head + filled binding → separate execution grant. Placeholder token `__FILL_AFTER_ATTESTATION__` kept unchanged (its name is now historical; documented as such) so the runner's refusal logic is untouched.
- New `binding/fill-pins.sh` (sha256 `611c7d7c378f98f0fbf2508a8c08da28ee4175877239919e65a02cf623b3dbad`): read-only derivation from the worktree's committed head; refuses HEAD == base, dirty tree (`--untracked-files=all`), non-descendant of base, non-Bradley author/committer, trailer-like commit-message lines, or an already-filled binding (re-fill = new binding version, never overwrite); re-verifies every tool pin by sha256 against the live binaries and reports `TOOL_PIN_OK` / `TOOL_PIN_MISMATCH` (never edits a pin to pass; `node_modules` pins deferred with a note if the donor copy is not yet in the worktree); writes `s8c-pg-proof.sh.unfilled` (template kept), fills the nine values in the runner and `PINS.txt` by anchored sed, `bash -n`, writes `s8c-pg-proof.sh.diff-unfilled-to-filled` and `BINDING.sha256` over runner/template/diff/fixture/PINS/README/fill script. It runs nothing else — no lock, no PG, no jest.
- `binding/BINDING.sha256.unfilled` regenerated (runner `377c3922…`, fixture `1a7faa5f…` unchanged; PINS `a4fa2c30…`, README `a90b1aea…`, fill-pins `611c7d7c…`).

## Sequence I will follow at relay

1. Source slot relay → donor `node_modules` copy per RUNTIME_SETUP_RECEIPT → prettier/eslint/tsc(4096)/R75/affected default Jest → hooks → single Bradley commit, no trailers → export (versioned `checkpoints/v3/`).
2. Immediately after the commit: `bash binding/fill-pins.sh` (preparation only) → report head, `BINDING.sha256`, tool-pin verification result, and the diff.
3. Stop. Parent dispatches dual review of head + filled binding; execution only under a separate grant, once.

Status: idle, queued behind S7-L; no heavy work.
