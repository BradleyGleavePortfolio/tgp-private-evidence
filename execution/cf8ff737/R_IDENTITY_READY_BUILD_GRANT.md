# R identity-ready build grant (T4)

Parent EXEC-CF8FF737, September 24, 2026.

**Activation condition:** the parent records B acceptance in `B_DRAIN_LOCAL_ACCEPTANCE.md` at exact head `0d69c7ba7e7d257311cfcb21fa325ebb1ddc1f1c`. This file is not active until the parent messages the builder that the condition is met.

This grant covers a local build only. It does not cover remote push or merge, CI claims, deployment, or real-database drain.

## Tier and route

- **Tier: T4.** R changes the persistent identity contract: it makes the platform column NOT NULL and adds unique keys.
- **Requested route:** Claude Fable 5 / High. This is the requested setting only. No model or effort telemetry is claimed.
- **Reviews:** two independent adversarial exact-head reviews after the build.

## Sole writer and owned areas

### Builder

The only builder is `r_slice_source_only_preparation_mufnlmx0`, requeued as the R builder.

### Worktree

Create a new worktree, `worktrees/s7-r-ready`, on a new branch from `0d69c7ba`. Create it with `git -C worktrees/s7-b-drain worktree add`.

- Never write into, check out in, or reset `worktrees/s7-b-drain`.
- Never touch the B refs or bundles.

### Dependencies

Make an independent physical copy of `worktrees/s7-b-drain/node_modules` using `cp -a`. No hardlinks, no symlinks, no reinstall.

- Record the lock and the hidden-lock sha before copying.
- Check disk space first. Stop if less than 3 GiB would remain.
- Generate the R Prisma client only in the copy. Record the new `index.d.ts` hash and the unchanged engine pins.

### Paths

R may write only:

- `r-prep/R_SLICE_BRIEF.md` §2 paths
- `src/scout/scout-ingest.dto.ts` and its validation spec, per D2
- `execution/cf8ff737/r-ready/**`

## Decisions

Use D1–D4 exactly as frozen in `R_IMPLEMENTATION_DECISIONS_PENDING_B_ACCEPTANCE.md` and acknowledged in `r-prep/DECISIONS_ACK.md`.

- **Migration id:** `20270120000000_scout_identity_ready`. First order-check it and confirm no collision on `0d69c7ba`.
- **Guard identity:** copy the corrected predicate `cardinality(t.tgattr::int2[]) = 0` wherever the R guard reuses the fence identity. Never copy the historical `= '{}'::int2[]` text.
- **Exported contract:** inspect `scripts/export-importer-contract.ts`. Regenerate only if the generator actually encodes the DTO input rule. If it does, the change must leave the C1 pair-surface subset byte-identical. That subset is frozen for UX-03b. If any pair-surface byte would change, stop and report.

## Steps

Follow `r-prep/R_SLICE_BRIEF.md` §9, steps 1–6.

- The first nonzero result stops the work.
- No autonomous retry.
- No scope growth.

### Gates and commit

Gates are:

- tsc
- eslint on two paths
- prettier check
- check-r75
- default Jest (guard spec and DTO spec)

The commit is an ordinary hooked commit. Author and committer are both Bradley Gleave <bradley@bradleytgpcoaching.com>. No AI trailers. No amend.

### Heavy slot

The heavy slot is `execution/test-validation.lock`, taken nonblocking. Take it for gates **only after the parent relays it**. UX-03a and UX-03b may be ahead in the queue.

The R01–R12 real-PG run needs its own separate single-run grant. Request it after the dual actual-head/binding attestations.

## Acceptance

Acceptance is exactly the bounded R01–R12 behaviors in brief §7, plus the DB-free guard, the D2 validation parity, and genuine gates. Behaviors are not a test-count quota.

Local PG17 proof is not PG15 CI. No CI result is claimed without an actual run. CI requires a remote push, which is reserved.

## Out of scope

- N/Q1 and C code
- reader changes
- fence removal
- real databases
- volume rehearsal claims
- re-audits of E/T/B/C1
