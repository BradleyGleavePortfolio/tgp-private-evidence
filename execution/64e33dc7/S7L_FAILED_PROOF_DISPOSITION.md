# S7-L first proof failure and bounded cleanup

Parent checkpoint, 2026-09-25 05:14Z. Candidate `54970cd937afc8dea689b33243961abfef8b9dd6`, tree `513c71d7c1390787e1521ccbfa46b30bb52b5462`, and v2 binding remain unchanged and unaccepted.

The one granted proof began at05:06:22Z, bootstrapped171 accepted migrations successfully, verified the OLD database identity, and started its single Jest invocation at05:06:59Z. Observed Jest summary: one failed suite; 21 failed, 3 passed, 24 total; 294.68 seconds. The command had not exited when the parent read the summary at05:12Z, and reported open handles. No passing lifecycle-runtime claim is supported.

The first reported failure is the held-table-lock test expecting the literal SQLSTATE `55P03`, while psql's default error output contains `canceling statement due to lock timeout` without that code. Later tests encounter lock timeouts or absent lifecycle columns. This is an observed sequence, not yet a final classification of all failures; the two existing independent reviewers are determining the first causal defect and cascades from the frozen sources and raw output.

## Narrow cleanup instruction

At05:12Z the parent instructed the sole executor to preserve outputs and report process identity. If Jest remains alive after its completed failed summary, TERM is authorized only for the verified Jest child or its own proof-stage process group, not the driver or lock holder. The existing driver's bound stop/postcheck/receipt cleanup must then finish. No broad kill, database probe, retry, forceExit addition, fixture destruction or source edit is authorized. The canonical lock remains owned until that cleanup ends.

Read-only observation at05:12:48Z identified driver17284, parent timeout17283, stage timeout19276 and Jest19277. The executor must reverify live ownership before any signal; these observed IDs are not permission to signal a reused process.

## Independent disposition

The original S7-L reviewers A and B are reactivated for runtime-only failure disposition, without re-auditing unchanged source or reading peer reports. New reports are `s7l/reviews/RUNTIME_REVIEW_A.md` and `RUNTIME_REVIEW_B.md`. They may diagnose before cleanup completes but must bind their final account to observed terminal cleanup. Each actual A/B must name harm, affected decision, smallest source/proof correction and execution unlocked; C does not authorize fixes or reruns.

The failed run, original candidate, original reviews and all binding versions are preserved verbatim. Any subsequent new candidate or proof needs a separately scoped correction and execution grant. Backend integration remains accepted933; production main is untouched.

## Observed termination and release, 2026-09-25 05:14:22Z

The executor's launch call remained pending. Parent reverified the exact Jest command, worktree, parent chain and distinct process groups, then sent TERM only to the Jest-stage group19276; driver17284/group17283 was not signalled. `binding/v2/run/PARENT_TERM.txt` records the live verification and action.

The unchanged driver then recorded `JEST_END rc=124`, `POST_JEST applied_migrations=171`, `STOP_FIRST_FAILURE stage=jest`, `CLEANUP_STOP rc=0 postgres_procs=0 port55641_listeners=0 survivor_pid=none`, and `END rc=124 stage=jest`, all at05:14:22Z. This is a forced stage exit after a failed test summary, not a natural Jest rc1 and never a pass. The sentinel binds unchanged head54970cd9 and lock inode691716. Parent subsequently observed no lock holder, zero postgres, no55641/55642 listeners and only the platform Node processes. The data directory remains retained. S7-L execution authority is ended; its two reviewers continue read-only failure disposition.
