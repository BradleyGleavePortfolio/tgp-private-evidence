# S4 R6 — validation request 1 (single applicable bundle; requires a named parent grant)

Exact source: `/home/user/workspace/worktrees/s4-r6`, branch `execute/20260921-s4-r6`, HEAD
`91990ae9aec72f47a67591892ac09fa1f59d2f16`, tree `840fb2855953d5363fbd144e11b3f81763d9cef7`, parent `88287cff…`,
bundle `execution/s4-r6/artifacts/s4-r6-91990ae9.bundle` (sha256 `af2c8207…bab0dd`, requires `0111be66…`).
Predecessor control: exact `88287cff` (restored ref `execute/20260921-s4-r5` in the same repository, or the
`git archive` export `execution/s4-r6/predecessor-88287cff/`).

Shipping bytes changed (`background.js` only) → fresh package + positive AND proper negative browser proof. No
inheritance of R4 ZIP `6fe9a7be…` or any R5 evidence for the artifact. **Commit hooks did not run at commit (no
toolchain present); step 1–4 below are therefore mandatory, not optional.**

Precondition: two independent exact-head source reviews of `91990ae9` (neither by this builder; no peer-conclusion
sharing before both freeze).

Requested slot (one holder, `flock -n` on `execution/test-validation.lock`, every step stamped with head/tree/dirty,
fail-closed runner: unexpected outcome fails the run, first exit preserved separately from cleanup exit, no forceExit,
no retries, no hidden install beyond step 1, bounded total ~25 min):

1. `npm ci` in the s4-r6 worktree (package-lock sha256 `262d4b69…cdae8`, unchanged from R5) — record `prepare`/
   lefthook install. Then run the six lefthook pre-commit commands explicitly against HEAD (`bash scripts/secrets-scan.sh
   staged` needs a staged diff — substitute `gitleaks detect` on the `88287cff..91990ae9` range plus `history`), because
   they did not execute at commit.
2. Focused vitest: `vitest run test/session-ownership-preflight.spec.js test/refresh-admission-epoch.spec.js
   test/session-ownership.spec.js test/refresh-coalesce.spec.js test/ingest-auth.spec.js test/session-refresh-path.spec.js
   test/session-establishment.spec.js test/start-import-hardening.spec.js test/session-lifecycle.spec.js` — expect all
   pass; report counts (the preflight spec gains 3 cases: 16 → 19).
3. Full suite `npm test` (R4 baseline 1714 on 2bcf; R5 added 25 → expect ≥ 1742 at this head).
4. `npm run gates`; `gitleaks detect` (8.30.0, `.gitleaks.toml`).
5. Discriminators in-slot for the record (all dependency-free, already run offline — see REPORT §4):
   `execution/s4-r6/probes/a01-late-reporting-discriminator.mjs <s4-r6> --expect fixed` (exit 0) and
   `… <predecessor-88287cff export> --expect defect` (exit 0 = reproduced; expect offsets 10/11 on both entrypoints
   under Node 20.20.1 — different Node versions may shift offsets; the invariant, not the offset, is the criterion);
   R5 `a01`/`a02` discriminators `--expect fixed` on s4-r6; auditor B's `bound-admission-probe.mjs` on s4-r6.
6. Package: build ZIP from `91990ae9`, sha256 + inventory, blob-level equality of shipped files to HEAD; abort on
   package failure (no stale dist).
7. Browser: FIRST the Chrome-alone `--remote-debugging-pipe` transport discriminator (15 s bound, bytes-on-fd4
   recorded; this is a transport diagnostic, not loader proof). If dead → stop, report harness-blocked, no blind retry.
   If alive → loader POSITIVE proof on the new ZIP (service worker up, `request_session_state` round trip, pairing
   untouched) AND a PROPER NEGATIVE: a named intentional loader-breaking mutation of the SAME ZIP (e.g. the existing
   classic-content-script-import negative or a documented `manifest.json` `background.service_worker` path mutation),
   preserving original and mutated hashes and the mutation text, requiring the intended exception/receiver-absent
   signature with no unrelated failures. Exit status alone is insufficient; a known-good base ZIP is a comparison only,
   never the expected-failing negative (S4-R5-A-E01).
8. Final exit record: head/tree/dirty, per-step exit codes and durations, lock holder, sentinel, unknowns.

Not requested: DB, multi-process probes, remote push/PR, edits to archive/baseline/frozen worktrees, flag changes.
Success of this bundle does not prove remote revocation, native completion, real-source acceptance or release readiness.
