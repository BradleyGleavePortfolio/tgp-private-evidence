# PROD-CI-1 grant: CI closure on the backend production path (T3)

**Parent:** EXEC-CF8FF737. **Time:** 17:12Z.

## Finding

This is an **A finding scoped to the backend production path only**. The evidence is the PR #530 CI run on `integration/importer` `7d2895e1`. Two jobs fail.

### 1. `shellcheck (scripts/*.sh)`

- CI runs shellcheck 0.9.0.
- `scripts/release.sh` line 326 triggers SC2016, because the single-quoted `node -e '…'` JavaScript contains `$queryRaw`. The single quotes are intentional there.
- It was introduced by the accepted S2 D2 change. Production `main` passes under CI 0.9.0.

### 2. "New migrations are reversible" (`migration-dry-run.yml:455`)

The harness applies each new migration's `down.sql` to a database migrated to the tip, then checks forward → down → forward parity.

| Migration | Down result |
|---|---|
| R `20270120` | passes |
| E `20270118` | `down.sql` refuses: `G2-E unexpected platform column prerequisite` |
| B `20270119` | `down.sql` refuses: `G2-B unexpected platform column prerequisite` |

These refusals are by design. The staged G2 downs are fail-closed and must run in reverse order: R.down, then B.down, then E.down. This was attested in R review A.

The harness assumes every down is independent at the tip, which is not true for staged migrations.

### Harm, blocked decision and unlock

- **Harm:** the backend production-deploy decision (#530) would face red required CI. The only way through would be to weaken the fail-closed down guards or ignore CI, which erodes rollback safety.
- **Decision blocked:** the owner's production merge readiness. **Not blocked:** the integration landing or any importer lane.
- **Execution unlocked:** CI on #530 is green and credible for the owner's decision.

## Minimum closure

### A. Shellcheck directive

Add a shellcheck directive, with a reason comment, immediately before the `node -e` command in `scripts/release.sh`:

```
# shellcheck disable=SC2016  # JS source for node -e; $queryRaw must not expand
```

- It is comment-only, and the bytes of the executed command are unchanged.
- Verify with shellcheck 0.9.0 semantics. The local shellcheck-py 0.11 also flags SC2329 on the existing SC2317 directive for `on_error`. That flag is pre-existing on production `main` and not flagged by 0.9.0, so it is C. Add nothing for it unless 0.9.0 flags it.

### B. Order-aware reversibility harness

This change is in `.github/workflows/migration-dry-run.yml`, in the reversibility step only. For each new directory X that has a `down.sql`:

1. Reset and migrate forward, as today, and take the BEFORE dump.
2. Apply the `down.sql` of every migration directory lexically after X, in reverse order, then X's `down.sql`.
3. Re-apply X's `migration.sql` and every later `migration.sql`, in ascending order.
4. Take the AFTER dump and diff it byte-for-byte against BEFORE, as today.

If any later directory lacks a `down.sql`, FAIL with an explicit message. That is conservative and does not weaken the check.

Keep the IRREVERSIBLE marker path unchanged. The gate becomes at least as strict: it proves the full chain reverses in its only valid order.

**No other workflow, job or step changes.** Do not touch deploy configuration, `fly.toml` or `fly-deploy.yml`.

## Owner and worktree

**Owner:** one T3 builder. The requested route is Claude Opus 5 / XHigh.

**Worktree:** `/home/user/workspace/worktrees/prod-ci-1`, created with `git worktree add` from `s7-r-ready` at `7d2895e1` on branch `prod-ci-1`. No `node_modules` are needed. Use `actionlint` if available, `bash -n`, and shellcheck, plus a local dry run of the harness logic if it is feasible without starting a PG cluster.

**Rules:**

- Bradley is author and committer.
- One commit, with no trailers.
- Write only `prod-ci-1` and `execution/cf8ff737/prod-ci-1/`.
- No push.

## Remote gate and review

The parent pushes `land/prod-ci-1` and opens a PR to `integration/importer`. `migration-dry-run` triggers on PRs whose paths include its own workflow file, so it runs there.

The acceptance gate is remote CI green on that PR, plus one independent T3 review. After that, it lands on `integration/importer` and #530 re-runs `infra-lint`.

## Stop point

Write `prod-ci-1/SOURCE_READY.md` with the head, tree, the exact diff and local lint receipts. Then stop.
