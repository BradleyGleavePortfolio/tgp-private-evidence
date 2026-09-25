# Bounded formatter tooling restoration

T3 environment-only continuation for `replacement_runtime_setup_muge72qn`. The S7-L source slot released at 04:17:21Z; parent observed no canonical flock holder at 04:19:38Z. Current grantee is the runtime setup worker for this narrow step only; both builders must wait for the next source-gate relay.

S7-L's genuine hooks refuse because Prettier is absent from the locked dependency tree and an unpinned download is not authorized. Durable accepted S8-B draft receipt records `prettier 3.9.9`. Restore exactly `prettier@3.9.9` as an isolated runtime tool under `execution/64e33dc7/recovery-reset/tools/prettier-3.9.9`, not as a product dependency.

Acquire canonical `execution/test-validation.lock` nonblocking in the actual tooling driver process and retain it through completion. Do not use a separate lock-holder whose lifetime can end before its child work. Never delete an existing lock. Use apply_patch for any manual script creation.

Read the exact registry metadata for this version, record tarball URL/integrity, fetch/install only this exact pinned package into the isolated tool prefix, with no project dependency or lockfile changes. Verify actual package version and integrity. Run only its version command, not product formatting/tests/compile. No donor, builder worktree or platform node_modules mutation. No PG or database operation.

Return a receipt under `execution/64e33dc7/runtime/formatter/` with raw command/result evidence, exact tool files/hash, and deterministic builder-local copy instructions that make the genuine existing `npx prettier` hook resolve this pin offline. Builders will copy it under their own later slot, without changing tracked package files or locked dependency identities. An environment-local formatter package/bin is tooling, not a hidden product dependency.

If the pinned version is unavailable or metadata/integrity disagrees, report that exact blocker; do not silently choose latest. Release the slot when done and leave the donor/platform trees unchanged.
