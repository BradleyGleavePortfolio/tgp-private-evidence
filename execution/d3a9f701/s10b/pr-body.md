S10-B: run declaration / observation storage (T3/T4) per docs/decisions/2026-09-26-s10-induction.md D-S10-7.

- Scope: `src/scout/induction/observation.{service,controller,dto,module}.ts`; `prisma/schema.prisma` (three additive models, no column change); migration `20270124000000_scout_run_observation_expand` (insert-only tables, forced RLS) with `down.sql`; unit specs; `test/rls-g2-s10b.spec.ts` and its disposable-PG harness.
- Head a2c74e90 on 92b96715 (S10-A landing). Gate: formatting, eslint, tsc, contract unchanged, targeted 150/150, full suite green, repository hooks. Real Postgres 17 proof: 24/24 on a disposable lane (173 migrations applied).
- Not wired into settle or status yet (S10-C). No production enablement.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
