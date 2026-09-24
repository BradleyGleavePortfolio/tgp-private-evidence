# S8-0 builder report (T3)

- Worktree `/home/user/workspace/worktrees/s8-0`, branch `s8-0`, base `c7a5fe8dd0b82fb2c81847d875e0e03912faff26`.
- File: `docs/decisions/2026-09-24-s8-native-contract.md`, 444 lines, sha256 `ae88b127cf63f0f36a83afc08eadd4a1f1932987c2cc6797feb6810a43da582e`, blob `4c1b2c3cae98b59932294bfbe8273f17e00a5347`.
- Commit `72fa09cb95b0c842e2bbcd47998b041f5cd365bd`. Author and committer are Bradley Gleave <bradley@bradleytgpcoaching.com>, with no trailers. The commit is 1 file, +444. Not pushed.
- Hooks: all hooks ran and passed genuinely under lefthook 2.1.9.
  - pre-commit: prod-readiness-quick, banned-cast-tokens, prettier and tsc (66 s). eslint was not selected because its glob matches no `.md` files.
  - commit-msg: no-ai-tokens.
  - Logs: `commit-2.log` passed. `commit.log` is the first attempt: tsc ran out of memory on the default heap (rc 134) while the s8-a tsc was running at the same time, so no commit was made.
- Environment:
  - `node_modules` was copied read-only from `worktrees/s7-nq1`. The hidden lock `05bc530a…` and `package-lock.json` `b7fed5ed…` are identical at both bases.
  - Prisma was regenerated for this base's schema: client `index.d.ts` `7c367454…`, which matches the R-schema client in nq1 receipt 02.
  - `NODE_OPTIONS=--max-old-space-size=4096`, as in the nq1 gate precedent.
  - Hook shims were installed by `lefthook install` into a private `hooks/` directory under this folder, reached through a per-command `core.hooksPath` environment override. The shared `.git/hooks` and repo config were not changed.
- Decisions recorded: D-S8-1 to D-S8-4. D-S8-2 uses the interim (b); option (a) is reserved to Bradley.

## Review closure (A1–A3 + C1)

- New commit `e322602dfd0ba2d60bd6f9a77ea9cfce26f83f38`, parent `72fa09cb`. This is a follow-up commit, not an amend. Author and committer are Bradley, with no trailers. The commit is 1 file, +95/−32.
- All hooks passed. pre-commit: prod-readiness-quick, banned-cast-tokens, prettier and tsc (55 s). commit-msg: no-ai-tokens. Log: `commit-3.log`. Not pushed.
- File now: 507 lines, sha256 `efc98c3a9ca43e5e10454494559703bd1ecf071b6c980b7e4bedf8fb4138028d`, blob `e177069f`.
- Changed line ranges in the new file (all within the one file): L24, L59-68, L81, L94-95, L133-139, L150-151, L153-155, L161-162, L164-170, L174-181, L194-201, L214, L249-276, L388, L402, L416, L431-438, L492-493, L496-497.
- Mapping to findings:
  - **A1:** L249-276 (§3.6 revision rule, corrected citations), plus the §4.2 row (L388) and the §4.3 row (L402).
  - **A2:** L136 and L150-155 (§3.2), L161-181 (§3.3), L194-201 (§3.4), L214 (§3.5), L416 and L431-438 (§4.4), and L496-497 (S8-B acceptance).
  - **A3:** L59-68 (D-S8-1), L94-95 (D-S8-3), and L492-493 (S8-A acceptance).
  - **C1:** L24 and L81 (Person L6920-6934).
  - L133-139 is the §3.2 table. Prettier realigned all of it; only the L136 row has new wording.
