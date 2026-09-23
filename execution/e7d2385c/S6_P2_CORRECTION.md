# S6 P2 minimum correction

Parent EXEC-e7d2385c. Individual/cumulative T4: identity/privacy, async retirement and trusted acceptance tests. Canonical builder Claude Fable 5 / High. Bounded T1 NO. Source-only successor to frozen P1; no new architecture, harness or audit lane. The existing two nonbuilder reviewers retain their independent reviews and later attest the changed exact candidate.

## Concrete disposition

Independent A source packet 0266ff530ea2db2864975d01ebb0dee97e916cdacbe28c54b3cd0ca903ffff32 is preserved under `execution/e7d2385c/audits/s6-a`. Parent accepts its concrete findings for minimum builder remediation, not as parent self-audit:

- S6-A-01, CLASS A. CONCRETE HARM: cleanup does not invalidate a suspended transition, so gate unmount can permit an orphan identity persistence that later writes another identity's data. EXACT DECISION BLOCKED: S6 identity/privacy source closure. MINIMUM CLOSURE: synchronously invalidate effect-owned transition and retire/drain the persistence owned by that effect; add a targeted interrupted-unmount regression in the existing tests. EXECUTION UNLOCKED: changed-source closure and existing bounded validation.
- S6-A-02, CLASS A. CONCRETE HARM: signOut completion precedes retirement/drain/final derived-cache purge; private late writes may survive completed logout. EXACT DECISION BLOCKED: logout late-write privacy closure. MINIMUM CLOSURE: coordinate the existing persistence retirement/drain and final purge with awaited signOut itself, without depending on a later React effect and without changing credentials, analytics, unrelated stores or offline mutations. Add a targeted existing-suite assertion at signOut completion. EXECUTION UNLOCKED: existing hazard and identity/lifecycle proof.
- S6-A-03, CLASS B. CONCRETE HARM: unawaited RNTL lifecycle operations, premature deferred-read release and fixture-write contamination produce unrelated test failures or misleading acceptance. EXACT DECISION BLOCKED: use of the new identity suite as acceptance proof. MINIMUM CLOSURE: await actual lifecycle helpers, wait for the existing deferred read to begin, distinguish seeded writes from post-retirement writes. Preserve the behavioral assertions. EXECUTION UNLOCKED: existing focused test execution.

The second reviewer is still assessing original P1 independently. Do not send A findings to that reviewer before its source findings freeze. The builder may begin these demonstrated corrections now in separate isolated source; any later B findings require explicit parent disposition. Do not turn C qualifications into changes.

## Builder and owned paths

After sealing and returning S6 preparation, `s6_frozen_source_recovery_muei56l7` may become the sole P2 builder. Original `worktrees/s6-diagnostic` and frozen P1/shared inputs remain read-only for both reviewers.

Sole new writes: `worktrees/s6-p2/**` as an isolated local clone/object store based on d51, and `execution/e7d2385c/s6-p2/**`. Apply the exact frozen P1 patch, then manual apply_patch corrections. No reference rewriting in the original worktree, private checkout writes, peer outputs or old packet mutation. No product remote operation.

Product edits are restricted to the existing nine authorized P1 paths. The expected causal core is PersistedQueryCacheGate.tsx, queryClient.ts, authActions.ts and their existing identity/signout tests; touch other P1 files only if the minimal interface propagation is necessary and explain why. Do not expand into unrelated App/navigation/provider behavior.

Preserve dependency/lockfile, gcTime/defaults, same-user max-age/buster, persistence opt-out, cache-key prefix, derived-cache-only purge, credential/account semantics, analytics, offline mutation queues, source evidence and frozen v5 hazard/adapter. No timer masking, private-library APIs, arbitrary waits, new supervisor/framework or new test harness.

## Freeze and next boundary

No npm/install/node/Jest/tsc/formatter/hooks/commit or other product runtime. S5 retains the sole heavy slot. Static hash/diff/source inspection is authorized.

Return exact final candidate source, patch from d51 and separate P1-to-P2 diff, concise finding closure map and only finding-specific test changes, unchanged input pins and minimum actual-validation request. Seal promptly. Parent will give both existing reviewers the changed bytes and all frozen prior findings for scoped follow-up; unchanged conclusions remain applicable.

Then execute the accepted bounded validation and true-hooked commit when the runtime slot transfers. No further baseline diagnostic or private control is required merely because P2 exists.
