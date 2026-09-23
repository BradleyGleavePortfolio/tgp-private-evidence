# S5 lint disposition and corrected hooked commit

Parent EXEC-6c2a68ac, 2026-09-23. ACTIVE once for `restore_s5_source_mue9wsph`, requested Claude Fable5/High, individual/cumulative T4. Sole S5 source mutation and runtime ownership return after the18:30Z release. S6 source reviews/preparation remain disjoint and runtime-inactive.

## Concrete defect and minimum correction

Frozen continuation `9d47c0dcdeb8cf7083489606df0600fc5c8b9947de8e46b056e782941f5fec88`,28 entries, verifies.06F succeeded at the exact formatted hash338defe8. Original07 raw1 is a real pre-commit refusal: zero ESLint errors but five no-unused-vars warnings with max-warnings0. Prettier/R75/tsc passed; production precheck was a no-op; commit-msg was not reached. No commit exists. Preserve both prior stopped packets and all statuses unchanged.

The five bindings are baseline constructs, not the16-line teardown fix. Existing ESLint configuration explicitly permits unused binding names beginning `_`; object-rest exclusion semantics must be retained. Minimum correction is exactly five binding renames in `test/rls-g2-pg17-etq0.spec.ts`:

- One `const families = ['clients', 'workouts', 'client_history'];` becomes `const _families = ['clients', 'workouts', 'client_history'];`.
- Three `const { source_platform, ...rest } = r;` become `const { source_platform: _source_platform, ...rest } = r;`.
- One `({ updated_at, ...rest }: any) => rest` becomes `({ updated_at: _updated_at, ...rest }: any) => rest`.

No property-key change, omission change, expression/assertion/control-flow change, new cast/token, ESLint/config/hook alteration or suppression. The existing ignored-name policy is used, not changed. Retain the unused literal declaration rather than widening to code removal. Only pinned Prettier3.9.6 reflow of this same file may accompany these five edits.

This fixes the specific hook blocker and unlocks one normal commit attempt on changed source, then original08–10. It is not a retry of an unchanged failing command. The real commit necessarily reruns its configured hooks; no separate lint/typecheck rerun is requested. Required independent final-head/runner review will cover these five semantic-neutral binding changes and the prior formatting delta without adding a new review cycle.

## Exact preserved substrate

Read this grant, original prep REQUEST.md and both stopped receipts. Reverify prep e9f4a5d5/21, first result492f7104/16 and continuation9d47c0dc/28. Require:

- Worktree `/home/user/workspace/worktrees/s5-r4`, HEAD `143d451ead6ccdbebd92ca3031ba7a89867d6cfc`, detached and refs unchanged.
- Staged tree `756a0d7966c9125749339abbcfd681eb7e713ede`, worktree equals index; spec SHA-256 `338defe8c68834b8f6e23df58547a7b6830c673bcb540a7985823532ee66a430`.
- Full current parent diff SHA-256 `2c92a96464238d88bfe4acb9dbe5e17400f5e51d154e1c1b99c8612b373746df`, core.abbrev8; two paths, spec971/356 and bootstrap34/4.
- Bootstrap mode100755/blob `85a636ba75607604032cef7af1d285cb198ca263`; package-lock `b7fed5ed611c004615022cf69375b83956e9a69604807123fbe0e7965aea9c55`; installed record `05bc530aa44bfa6df64f0daa8edb66c5181abf4bfbc309bd8da2c8aff37b6a44`; Prisma CLI `c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0`, generated client/engine preserved.
- Existing real hooks and pinned formatter link/CLI6e922134; no hooksPath/local override/bypass variables. Repo-local Bradley identity now exists; preserve and verify it.

Fresh output `execution/6c2a68ac/s5-hooked-candidate-lint-continuation/` must be absent. One read-only census may confirm slot free/no attributable survivor/no canonical-lock fd holder. GIT_OPTIONAL_LOCKS=0 for reads; job control off; original bypass/private variables unset. No repair or cleanup on failed applicability.

## Allowed source correction and bounded execution

Preserve the current exact spec and parent diff in the new root, then apply only the five binding substitutions using a visible manual patch. Record a separate pre-format diff proving the five occurrences and unchanged property keys/rest expressions. No other product path may be edited; bootstrap remains byte-identical.

Use an additive original `step.sh` copy with ONLY O changed to the new root and holder label to `S5-HOOKED slot-H3`, plus corresponding comments. Keep P at original prep and all ownership/environment/deadline/raw-status behavior unchanged. No new observer, supervisor or outer timeout. Freeze new command files before each invocation and preserve exact diffs.

- **06L, bound60 seconds, offline1:** pinned CLI `node "$TOOL/node_modules/prettier/bin/prettier.cjs" --write test/rls-g2-pg17-etq0.spec.ts` once, then its `--check` once; require both raw0. Stage only this spec; record new exact source hash/tree/full parent diff/hash/numstat, worktree=index and two paths. Preserve the separate five-binding diff and formatter-only delta.
- **07R, bound1200 seconds, offline1:** original07 command, substituting only its expected-tree guard with06L's frozen new tree. Original message hash `1da4490843c224baa244331121e32fd298847b47f0009ed860e4456f4e0a645b`, normal `git commit`, verified Bradley author/committer and real hooks unchanged.
- **08, bound30 seconds, offline1:** original identity command with only expected tree/parent-diff hash/spec numstat and descriptive labels mechanically updated to frozen06L pins. Parent/refs/two-paths/bootstrap34/4/identity/message/no-trailers/cleanliness/detached checks unchanged.
- **09, bound60 seconds, offline1:** original bundle command, new exported O.
- **10, bound60 seconds, offline1:** original R75 range commands, both original bases unchanged.

Freeze07R/08 substitutions before07R. No00–05/original06/06F/T0/setup/install/generate/link/hook reinstall or standalone test/lint/typecheck. Existing configured real hooks are mandatory even though some passed on the preceding tree. First unexpected nonzero/timeout/unknown/mutation stops; no second edit, retry, amend, reset, alternate formatter, bypass or extra diagnosis.

## Writes and return

Sole writes: exact spec correction/format; necessary S5 index/config/object/HEAD/reflog for the normal commit; attributable existing-tool/npm logs; canonical lock/.holders through the unchanged helper; fresh result/command/diff/bundle root. Simple detached caller with actual wait receipt is allowed. No dependency/client/cache regeneration, other source/tests/configuration, peer/private checkout, DB or remote action.

Return every raw/postcheck and genuine hook result, binding-only and format-only deltas, exact head/tree/parent/message/identity/refs/full diff/bundle and unchanged dependency pins, plus accountable runtime release. Seal non-self-including and freeze. Original06raw1 and07raw1 remain failures.

No fresh51 or product/DB acceptance is implied. After a successful actual head, use the already-required two independent exact-head/runner attestations, then separately granted real proof. No public merge/push/deployment/customer action or spending.

Parent observation qualification: a read-only applicability command used `git write-tree` and `git status` without explicitly exporting GIT_OPTIONAL_LOCKS=0; it reported the same staged756a tree and two paths, but an incidental index metadata refresh is not excluded. No source bytes were changed by the parent; this is recorded, not a new investigation or permission.
