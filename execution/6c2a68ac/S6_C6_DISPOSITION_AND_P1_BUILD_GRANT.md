# S6 C6 disposition and P1 product build

Parent EXEC-6c2a68ac, 2026-09-23. C6 is CONSUMED, runtime returned. P1 source-only product implementation is COMPLETE/FROZEN698cf631/15, patch20c6594c/nine paths, by `restore_s6_substrate_mue9osen`, requested Claude Fable 5 / High. Source mutation authority is consumed; exact independent review is now governed by `S6_P1_EXACT_CANDIDATE_REVIEW_SCOPE.md`. No runtime is granted by this document.

## Evidence and decision

Frozen C6 result `execution/6c2a68ac/s6-c6-result`, manifest `64a99289ad9320238418b4e3c8e40e80030172bb90b817ed9b5a745ca9199239`, 31 entries, is accepted as the scoped diagnostic result, not product acceptance. All six hazard assertions passed on d51, mode d51-singleton, no overlapping act; two persistent 600000ms Query.removeObserver timers remained, C hit its 90-second budget and returned143. Frozen classifier outcome is `i-TWO-RESIDUAL-removeObserver-HANG`. Hook-only cleanup is insufficient; the in-case orphan hypothesis is supported. Broader application harm and the exact initiating event are not established by the timer stacks alone.

Launcher wait90 was directly observed and matches published90; runner143 and cleanup0 remain separate. The owned outer-session exception was resolved with its existing TERM path and empty re-census. The transient member's identity is UNKNOWN. Accountable runtime closure was reported17:37:43Z and confirmed17:38:23Z. Normal setup/launcher0 is not established. No repeat C6, setup, primitive audit, new controls, masking or reconstruction of that unknown member is authorized.

### Defect, minimum correction and execution unlocked

- A/product: the existing P1 shared anonymous-key, cross-identity memory/restore and late persisted-write hazards reproduced in the actual six-control run. Minimum correction is identity-authorized persistence, retirement/restore/write fences and transition ordering using the already-prepared P1 design.
- B/proof and product-lifecycle qualification: in-case query teardown leaves two observed long-lived orphan timers despite hook settlement. The minimum additional product change must settle the relevant query/observer lifecycle without weakening privacy clearing or merely hiding timers. Trace the actual pinned query-core implementation; do not assume one added await alone solves removeObserver-after-clear.
- Execution unlocked: the same unchanged v5 hazard/adapter can discriminate the product fix, and the existing identity-gate/RootNavigator suites can establish the new boundary. Runtime, true-hooked commit and two independent final-head attestations follow in this same bounded lane. No further baseline diagnostic is needed.

## Scope and ownership

Individual and cumulative T4: authenticated identity, privacy/cache isolation, auth lifecycle and trusted evidence. T3 triggers include provider composition and asynchronous teardown. Bounded T1: NO. Builder is sole product author, not an auditor; parent only orchestrates and disposes. Independent nonbuilders will review the exact frozen candidate, then complete those same reviews against the eventual exact hooked head and actual results.

Use the existing installed worktree `/home/user/workspace/worktrees/s6-diagnostic`, starting from clean HEAD `d51a191098f483cea9abec6cc7e9f3beffd18c06`, tree `62bf67b88e0f123f1a23ee34a1a75cb43029d9fb`, lock SHA-256 `840be0b8d5f4ed8272afd20290c8ebf6f6dacc394e6edae4ae5403e9fabe6b69`. Preserve the base Git object and all frozen baseline evidence. Reuse its installed substrate; do not clone, reinstall, move modules or create a new dependency graph.

Sole writes now: the enumerated product/test files below in this worktree and fresh `execution/6c2a68ac/s6-p1-product-build/**`. Git index/config/hooks/HEAD remain unchanged in this source-only phase. Read-only Git operations use `GIT_OPTIONAL_LOCKS=0`. No private-checkout writes. No changes under source/mobile, other lanes, node_modules, existing result packets, canonical lock or /tmp scratch.

## Implementation boundary

Read the existing `2026-09-21/remediation/s6-r3/s6-p1-staging-1/SOURCE-MAP.md` and staged identity-gate/RootNavigator tests in the private checkout, the actual C6 result and the relevant pinned product/query-core source. These are implementation inputs, not authority to execute the historical plan's commands or overwrite its packets.

Permitted product paths:

1. `src/services/queryClient.ts`: replace import-time anonymous persistence singleton with identity-bound persistence, exact hydrate/write retirement fences and bounded drain/restore. Preserve cache-key prefix, same-user buster/max-age semantics, persistence opt-out and derived-cache-only purge. No dependency changes or private library APIs.
2. New `src/services/PersistedQueryCacheGate.tsx`: structurally prevent replacement children seeing previous identity memory; bootstrap unknown is distinct from committed logged-out; retire/drain/settle/clear in an explicit safe order. Address stale completion and rapid identity transition paths without a general lifecycle framework.
3. `App.tsx`: use plain QueryClientProvider; identity persistence moves to the gate.
4. `src/navigation/RootNavigator.tsx`: use committed bootstrap identity (token plus valid cached user and no role-selection state), place gate without remounting NavigationContainer or altering navigation/ref/replay behavior.
5. `src/services/authActions.ts`: only the minimum query/persistence teardown coordination needed by the observed lifecycle defect and P1 boundary. This expressly supersedes the old SOURCE-MAP exclusion on signOut order, but does not authorize changing auth success/failure rules, credentials, analytics, user-store semantics or unrelated cleanup.

Permitted test paths: add the already-staged `src/services/__tests__/persistedQueryCache.identityGate.test.tsx` and `src/__tests__/rootNavigatorPersistedCacheGate.test.tsx`; narrowly adapt or extend existing `queryClient.persister.test.ts` and `queryClient.signout.test.ts` only for the changed public contract and actual ordering defect. Preserve existing assertions and negative protection. Record any staged-test adaptation and its concrete reason. Test infrastructure expansion is not authorized.

Frozen v5 hazard `a91bb732716b500122e291714bf437872cb81930c020812042f84ed87f6a184d` and adapter `3796be8fae738993bcc5c30dd7d4cf9b303329b8faa990ca03e31c2460cd35f3` remain unchanged outside the product patch. Later, their post-fix T1/T2/T3 must fail on the intended hazard assertions while T-WIRING/T0/T4 execute and pass. An import error, hang, skipped assertion or forced exit is not a behavioral flip.

Keep gcTime600000 and normal query defaults unchanged. No clearAllTimers, forceExit, unref masking, shortened cache lifetime, test-only disposal of hidden query objects, changed C6 classifier, new instrumentation, Node upgrade, package/lock/feature-flag changes or dependency patching. Do not touch pending offline workout/food mutations, broader AsyncStorage, native DB rows or credentials. Derived query-cache prefix purge remains within previously authorized scope.

The old design is not a mandate to preserve a demonstrably unsafe race. If a concrete fix within these paths requires a small deviation, implement it and explain it against the hazard and test boundary. If preserving privacy and actual query lifecycle requires a wider product/API change, freeze the narrow work and report the exact A/B defect, minimum added scope and execution it would unlock.

## Source-only output

Record initial pins, implement the bounded product correction, and freeze a non-self-including manifest of the exact candidate files, reproducible patch, concise changed-path/rationale map, retained baseline references and proposed exact validation commands. Include source analysis of cancellation/observer removal/clear and old-write completion across A→B→A, logout and interrupted transitions. This is examination of consequential boundaries, not a new framework or speculative test family.

No npm/node/Jest/tsc/eslint/formatter, app execution, install, generation, lock/probe/signal, hook install, commit, export, network or remote action now. Static file/Git/hash/diff inspection only. No attempt to declare runtime success from source.

Freeze promptly and return exact hashes for the two independent reviews. Product validation and a true-hooked local commit require the next explicit activation; no public push, merge, deployment or customer action. The S3 composed runtime and S5 setup queue are independent of this source-only work.
