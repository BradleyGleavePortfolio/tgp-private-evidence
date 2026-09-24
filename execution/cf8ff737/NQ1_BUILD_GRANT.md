# N/Q1 build grant (T4)

**Parent:** EXEC-CF8FF737. **Time:** 17:12Z.

**Basis:** `nq1-prep/NQ1_SLICE_BRIEF.md` is adopted as the build spec. R is ACCEPTED and LANDED at `7d2895e1`, so the brief's B1 (the hard-link hazard while R was running) is closed by sequencing. Hard links are still forbidden.

## Parent decisions (frozen)

Each decision was made at the parent level, following the brief's recommendation.

- **P1:** an unresolvable legacy token returns the existing 400 `'malformed cursor'` response. No new message is added. The restart semantics are documented in the contract.
- **P2:** on R, the response is always 400. There is no fallback and no runtime switch.
- **P3:** bump the contract version label once. The pair-surface section stays unchanged.

## Owner and worktree

**Owner:** one T4 builder, `nq1_final_writer_reader_t4_build`. The requested route is Claude Fable 5 / High.

**Worktree:** `/home/user/workspace/worktrees/s7-nq1`, created with `git worktree add` from `s7-r-ready` at `7d2895e1` on branch `s7-nq1`.

**Dependencies:**

- The worktree gets its own physical `node_modules`: `cp -a` without hard links, and verify link count 1 on the `.prisma` client files.
- Then run `prisma generate` inside `s7-nq1` only.
- Stop if free disk would fall below 3 GiB.

## Scope

**NQ1-a (reader):** the cursor module, both reader services, DTOs and controllers, the regenerated contract and version pin, and unit tests.

**NQ1-b (final writer):** the `schema.prisma` ledger line and comment, `scout-reconstruct.service.ts` and three test fakes. It includes:

- a five-field upsert;
- the null-claim removal;
- staged ordering by (source_id, source_platform);
- keeping the P2002 retry;
- mapping a narrow collision to 409.

**NQ1-c (PG proof, test-only source):**

- The spec, harness and guard adapted from R's, with a sixth disposable database identity. The accepted R head is the T/old side.
- Proof cases N01–N06 and Q01–Q07, as in the brief.
- A binding runner in the R pattern at `execution/cf8ff737/nq1/binding/`, filled with pins and sha256.

**Out of scope:**

- Any migration, and any C work (contraction or C.down).
- Native writers and G3-AUTH.
- Consumer changes: mobile and the extension need none.

## Rules

G01–G22 apply:

- Bradley Gleave <bradley@bradleytgpcoaching.com> is author and committer.
- No trailers.
- Genuine Lefthook hooks.
- Never overwrite others' work.
- Write only in `s7-nq1` and `execution/cf8ff737/nq1/`.
- Never touch `s7-r-ready`, `s7-b-drain` or the PG clusters.
- No push.

## Gates

**Light gates, no slot:** tsc and lint.

**Heavy gates:** the affected default Jest set and the full default Jest. They need `execution/test-validation.lock`, and the parent relays it. Ask the parent when the source is frozen. Never start or init any PG cluster without a separate single-PG grant.

## Stop point

1. Write `nq1/SOURCE_READY.md` with the head, tree and diff stat, the owned-path proof, the gate receipts, the filled binding and a bundle.
2. Stop. The parent then dispatches two independent T4 attestations, followed by a single PG grant.

The first nonzero result stops the run. Report it unchanged.
