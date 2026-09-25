# S7-L replacement source-gate relay

Parent relay, 2026-09-25. Sole grantee: `s7_l_replacement_builder_muge72rg`, under the existing T4 replacement build grant. No product-scope expansion, PG run, acceptance, push or production authority.

## Exact checkpoint and runtime

`s7l/checkpoints/draft-01-source` captures new replacement source from accepted base `93389265a846095b846fa8f1fb0dad782fb6ee9f` on `exec64/s7l-replacement` at 03:43:16Z. Manifest SHA-256: `6485fe78cae2cd7c96ea34bc360ba9bb78ffe00f5d1ac20ed5418e0531f6831a`. Parent verified all 20 exported files plus the tracked patch. Manifest product paths are relative to its `files/` directory; the patch is relative to the checkpoint root. This is source preservation, not proof or acceptance.

Runtime setup ended rc0 and released the canonical flock at 03:29:43Z. Parent subsequently observed no holder. Read `runtime/RUNTIME_SETUP_RECEIPT.md` for exact donor/tooling identities and copy instructions.

## Authorized source gates

The S7-L builder may acquire `/home/user/workspace/execution/test-validation.lock` nonblocking and run only its new candidate's source gates. Preserve the lock file; refuse a live holder. Record acquisition/release, processes, commands, raw outputs and actual candidate identities.

- Copy the isolated dependency donor with real `cp -a`, verify the two lockfile hashes, and generate Prisma only inside the S7-L worktree for its changed schema.
- Generate the real lifecycle contract through its owned generator. Do not include another lane's unfinished DTO/source changes.
- Run scoped format/lint/R75 checks, TypeScript with heap 4096, affected default Jest, and genuine existing commit hooks. No full historical PG or accepted-proof rerun.
- Complete remaining source/test/binding authoring under the original grant. A new checkpoint captures any bytes newer than draft-01 before the hooked commit. Do not hold the heavy slot while doing lengthy source-only authoring.
- Make ordinary Bradley-author/committer commits without trailers, preserve any failed gate logs, and export the exact final source as a self-contained bundle with base/head/tree and manifest.

Source-gate failure permits only the minimum in-scope correction and necessary gate rerun; classify consequential out-of-scope A/B to the parent. Do not bypass hooks, relax tests, alter dependencies/workflows, use the platform dependency tree, or silently widen tooling. If a required executable is absent, report the exact minimum tooling requirement rather than invoke an unpinned download.

Release the slot and return SOURCE_READY with actual gate outcomes and a fresh candidate-bound proof driver. Two independent nonbuilder attestations and a separate exact one-run grant must precede any real-PG proof.
