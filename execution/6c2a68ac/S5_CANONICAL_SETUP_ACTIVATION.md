# S5 canonical setup activation

Parent EXEC-6c2a68ac, 2026-09-23. ACTIVATE exactly one canonical setup under `S5_CANONICAL_SETUP_GRANT.md`; sole runtime is assigned to `repair_s5_binding_mue9vjso`.

S3 executor has returned runtime after its one-shot proof: closure17:44:37Z, re-confirmed17:47:20Z, no attributable processes, socket54354 or lock fd holders. Its frozen packet2d4615e7/118 proceeds to the two existing final-head reviewers independently. S6 is source-only. No additional lock probe or setup audit is required.

Use the unchanged V32 launcher55acc00f and runner61b565e4 with all exact source/worktree/fingerprint/module-absence and fresh-path prerequisites in the grant. One npm-ci workload, no scripts, generation, hooks or tests. Preserve partial state on failure; no retries, manual signals or cleanup.

For actual launcher return capture, the grant's accepted detached transport may use the same simple caller pattern as S6 C6: detached caller invokes `setsid -w env CHECKPOINT_DISABLE=1 S5_SETUP_GRANT=granted-by-parent bash <absolute frozen launcher>` and records its direct return. This is transport/wait only, not another supervisor, observer or timeout. Launcher remains its own session leader; source, deadlines, lease ownership and assertions are unchanged.

Record separately actual launcher wait, published final, runner raw/FINAL, npm child raw, cleanup and lease release. Do not interpret runner0 as launcher0. An exceptional90 is not normal setup PASS; parent will evaluate the actual substrate and accountable closure without automatically adding a rerun or audit.

Sole result root `execution/6c2a68ac/s5-canonical-setup-result`, fresh absent. Read current grant/activation before starting. Return the slot promptly after accountable closure, then freeze the bounded receipt. T0 is NOT ACTIVE until a separate parent disposition and grant.
