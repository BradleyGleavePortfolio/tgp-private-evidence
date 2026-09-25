# S8-C replacement source-gate relay

Sole grantee: `s8_c_replacement_builder_muge72rc`, T4 under `S8C_REPLACEMENT_BUILD_GRANT.md`. This grant activates only on the parent's explicit relay after S7-L's source-gate release. It does not authorize a PG run, product push, acceptance or production action.

## Candidate and runtime

Continue the exact new replacement draft in `/home/user/workspace/worktrees/64e33dc7-s8c`, branch `exec64/s8c-replacement`, based on accepted `93389265a846095b846fa8f1fb0dad782fb6ee9f`. Preserve the published original checkpoint and addenda. New exports go to versioned `s8c/checkpoints/v3/` or later; no overwrite of an earlier export.

Read `runtime/RUNTIME_SETUP_RECEIPT.md` and `runtime/formatter/FORMATTER_TOOLING_RECEIPT.md` completely. Acquire the existing canonical `execution/test-validation.lock` nonblocking in the actual driver process and hold it through source-gate work and cleanup. Refuse a live holder; never delete the lock. Use bounded commands and preserve raw failures.

- Make a real isolated `cp -a` of the accepted-base donor dependencies, not links. Verify both package-lock hashes. S8-C's schema must remain byte-identical to the accepted base; do not generate or mutate the donor.
- Copy the verified isolated Prettier 3.9.9 prefix into a fresh S8-C runtime-owned directory outside the worktree. Verify its file manifest and relative bin link. Set the builder-local npm prefix and offline mode, then verify `npx --no-install prettier --version` inside the worktree.
- No dependency, workflow, hook, platform node_modules or product configuration edits. No unpinned download. Use heap 4096 for TypeScript and genuine hooks.

## Narrow generator execution transfer

After the explicit source relay, S8-C may execute the unchanged accepted-base importer contract generator in its own worktree and include its derived `docs/contracts/importer-openapi.json`. This is the sole temporary overlap exception to the original grant's artifact exclusion. No other worker may generate in this worktree.

Expected semantic delta: add `programs` to the reconstruct entity-type enum and the entities family-query enum, derived from the actual DTO family list. No manual JSON, generator script, contract version or contract-spec edit is authorized. If the generated semantic delta differs, report the concrete difference before widening scope. S7-L's separate lifecycle artifact remains its own candidate; later composition must regenerate from the combined real DTOs under a parent composition grant.

## Authorized gates and commit

Run scoped formatting, ESLint, R75, TypeScript, new native/guard default-config Jest tests and the minimum affected existing mapper, reconstruction and generated-contract tests. Select by actual changed dependencies; no full historical suite or accepted PG rerun. A failure authorizes only minimum in-scope remediation and the necessary rerun. Preserve initial failures and do not weaken coverage.

Commit ordinarily through genuine existing hooks as Bradley Gleave `<bradley@bradleytgpcoaching.com>` for both author and committer, with no trailers. Do not bypass hooks. Export the actual base/head/tree, changed-path manifest and a self-contained Git bundle. No product push.

Release the heavy slot immediately after the source gates and hooked commit, and report actual release plus head/tree promptly. Complete source-only binding pin fill from that committed clean head, preserving the template, diff and hashes; do not silently replace mismatched tool pins. Return the final source receipt and filled binding for two independent nonbuilder reviews.

## Proof boundary

No initdb, server, bootstrap, migration, PG test or fixture action is authorized by this grant. Source preparation of the proof is not execution. Both independent attestations must bind the final committed head and filled driver before a separate exact one-run PG grant.

Keep reader/customer/flag activation off until accepted S8-F native materialization. No S8-D/E principal decision, lifecycle implementation, production or security-governance change.

## Activation, 2026-09-25 04:31Z

S7-L completed its genuine hooked commit at `839b54c53ccb252f95b4ec63df0b08595bbe7698`, tree `f02205c60ad0bfeb24ce82d74b0025ee9a185df6`, and its actual driver released the lock at 04:30:19Z with rc0. Parent observed no lock holder, no relevant heavy process and a clean S7-L worktree at 04:31:04Z. S8-C is now the sole source-gate grantee, including the narrowly transferred derived-artifact generation above. S7-L binding preparation and independent reviews may proceed without the slot.
