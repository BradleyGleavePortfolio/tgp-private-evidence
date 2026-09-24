# B/drain v5 minimum correction and phase-A grant

Parent EXEC-CF8FF737, 2026-09-24. Bradley's EXECUTE continues. This grant follows new failed real-PG evidence, not a reopening of unchanged accepted work.

## Disposition and grading

Both independent successor reviewers identify the same candidate defect in actual head `75a2863bf79a44f84050406d6878ec9a87f4053e`: dimension-sensitive equality between an empty trigger int2vector cast and an empty int2 array returns false. This makes the drain-complete verdict unreachable and prevents the B down migration from executing.

Classification **A**, blocking only B/drain acceptance and its product path. The builder's initial B-only classification is superseded by the concrete product consequence. The failed proof remains RC1, 11 passed / 8 failed / 19 total, not a pass. Nineteen is the exact committed spec denominator; twenty-six was a stale expectation, not a changed criterion.

Minimum closure is two product lines in two existing files. Tier remains T4: persisted-data/migration safety and operator truthfulness; persistent contract also triggers T3; not bounded T1. Builder and two independent reviewers remain on the requested Fable/High route; parent is GPT 6 Astra orchestrator. Requested routing is not observed telemetry.

Acceptance: exact two-line delta, genuine hooks and affected gates, ordinary new commit, actual-head/filled-binding dual continuation review, separately granted single PG proof and final dual disposition. Any additional source change or proof-route change beyond the mechanical needs below requires a named A/B necessity before execution.

## Sole builder and source authority

Retain `b_drain_exact_recovery_and_remainder_mufn6ybc` as sole writer of `worktrees/s7-b-drain/**` and its existing evidence areas. Additive v5 evidence belongs under `execution/cf8ff737/b-drain/v5/**`.

Starting head must remain `75a2863bf79a44f84050406d6878ec9a87f4053e`, clean, with its original failed evidence intact. Author exactly:

- `src/scout/scout-ledger-backfill.ts`: replace `t.tgattr::int2[] = '{}'::int2[]` with `cardinality(t.tgattr::int2[]) = 0`.
- `prisma/migrations/20270119000000_scout_ledger_obsolete_writer_fence/down.sql`: make the identical predicate replacement.

No other predicate, forward migration, spec, fixture, schema, dependency, gate list, runtime contract or source path changes. No formatting churn. Freeze the exact delta/tree with blob identities and preserve a patch.

The actual failed assertion caused a paused-worker cascade, but Jest exited naturally and existing cleanup completed. Reviewer A qualifies the open-handle issue C. The parent's minimum-closure disposition is **no try/finally test change, no new control, no new cleanup harness** for this correction. Record this known failure-cascade qualification; the full existing live test remains mandatory.

## Execution after J3 releases the slot

Source edits and preparation may proceed in parallel with J3. Heavy gates and hook execution must wait for parent's relay of J3's released canonical slot. Do not contend, remove locks, or stall J3.

Reuse the already verified dependency tree, generated Prisma client, PG tooling and formatter. No copy/install/generation. Reassert the applicable existing pins; a mismatch is a named proof obstacle, not permission for silent recovery.

Prepare and then execute once, after release, the existing affected phase-A gate sequence under the canonical nonblocking lock: tsc, affected eslint, prettier check, check-r75 staged, the existing two DB-free suites with 42 cases. Preserve genuine local Lefthook pre-commit and commit-msg execution. Ordinary commit only, Bradley author and committer, no amend/rebase/bypass/trailers.

Approved message:

```text
fix(importer): recognize empty trigger column vectors
```

The new commit has parent `75a2863bf79a44f84050406d6878ec9a87f4053e`. Preserve both original and corrected commits, and a portable full-history bundle if feasible from the already restored graph. Do not erase the failed v4 history.

Record the actual committed head/tree, clean state, exact message/identities, gate and hook exits, and no-owned-survivor cleanup. Stop at first nonzero; no automatic repair, retry or amend.

## Binding preparation, no PG execution

Prepare a fresh additive filled binding with the actual new head/tree and unchanged spec/bootstrap/fixture pins. Keep the sealed proposal and original filled binding/run byte-identical.

The first proof's completed receipts and retained datadir must not be overwritten. Identify the minimum mechanical arrangement for a new run: separate receipt root, reuse the verified obsolete-writer checkout/client where identity permits, and preserve the old stopped B datadir before any later clean disposable fixture creation. Do not execute this arrangement yet. If the sealed template's hardcoded paths require any change beyond the five pin substitutions, present that exact small diff for independent binding disposition instead of silently treating it as unchanged.

Both existing independent reviewers review only this delta and actual execution/binding applicability. They do not repeat the full unchanged source audit or gates. A new single PG proof needs its own parent grant after dual actual-head/binding attestation and slot availability.

R remains blocked on B final acceptance. J3 and unrelated accepted evidence remain unaffected. No remote product push/merge, deployment, customer/production enablement, security/governance policy change, live data, new spending or external commitment is granted.
