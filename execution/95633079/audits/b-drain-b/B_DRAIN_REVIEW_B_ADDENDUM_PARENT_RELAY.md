# Reviewer B — addendum: parent-relayed dispositions received 2026-09-24 00:40 PDT (no new work)

Status of my frozen outputs: unchanged (`REVIEW_B.sha256`). Product grant for the four v2 product files stays
frozen. This note only records what the parent relayed and what reviewer B will check on the v3 changed lines,
so the same-review scope is explicit before the candidate arrives. Nothing executed; peer-A not opened.

## Relayed items and reviewer-B position

1. **`pg_get_triggerdef` schema qualification depends on `search_path`** (relayed, independently identified
   elsewhere). Acknowledged as a defect my source report did not surface: `pg_get_triggerdef` qualifies the
   function name only when the function's schema is not visible on the caller's `search_path`, so under the
   default `"$user", public` path the shipped string with `public.scout_ledger_platform_fence()` does not match →
   down.sql would refuse as "fence absent", `readDrainState.fenced` could report false, and the spec `fence()`
   snapshot would differ. Property affected: fence detection (product `down.sql`, `scout-ledger-backfill.ts`
   `readDrainState`, spec helper). v3 direction relayed: search-path-independent exact effective-fence predicate
   (e.g. join `pg_trigger`→`pg_proc`/`pg_namespace` on oid + `tgtype`/`tgenabled`/argument checks), with the
   absent-fence→false branch preserved. On v3 I will verify: predicate equality under both `search_path=''`
   and default path; no widening (an unrelated trigger or disabled trigger still false); down.sql refusal
   semantics unchanged; migration.sql up-guard uses the same predicate. Since this touches product bytes
   (`down.sql`, `scout-ledger-backfill.ts`; possibly `migration.sql`), those changed lines are re-gated and
   re-read — changed lines only, not a re-audit; the frozen v2 grant is superseded for those files by the v3
   changed-lines review.
2. **`has_function_privilege` ACL assertion vs Supabase default privileges.** Fixture default
   `GRANT ALL ON FUNCTIONS TO anon, authenticated, service_role` yields explicit grants; `REVOKE … FROM PUBLIC`
   does not remove them, so the spec's three-roles `'f'` expectation is wrong. Agreed test-only correction; no
   wider product REVOKEs (correct — the fence is never invoked directly and E's posture is unchanged). On v3 I
   will verify the assertion describes the actual effective ACL without weakening the "not SECURITY DEFINER /
   PUBLIC revoked" checks.
3. **Runner outer timeout 2400 s < sum of soft bounds (2835 s) → raised to 3600 s** with graces; no autonomous
   cleanup guarantee or new framework. Agreed (matches my BIND-4 note); I will check the new bound covers
   init+start+old-root+bootstrap+identity+jest+stop+cleanup with the `-k` grace and that first-failure exit
   semantics are unchanged.
4. **Confirmed accepted into v3 from my findings:** B-1 (allow `lockRetries: 0`, unit assertion), B-2 (actual
   S1+C1 SQL + `migrate resolve`, relative counts, exact-B-only deployment assertion), B identity adapter,
   BIND-1 order (copy → genuine hooks → gates → commit → pins). O-client generate approved in principle only.

## What reviewer B will do when v3 arrives (same review)

Read `git diff 3739193a..<v3 tree>` plus the adapter files; check items 1–4 above line by line; confirm pins
(head/tree/spec/bootstrap blobs, fixture sha) from the committed head; update the manifest verdict for the
changed product lines; then wait for actual results. No rerun, no re-audit of unchanged lines.
