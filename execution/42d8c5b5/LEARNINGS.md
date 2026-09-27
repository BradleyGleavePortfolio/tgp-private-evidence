# EXEC-42D8C5B5 learnings (durable, one line each)
- Lost-bytes control: the predecessor sandbox died with unpushed candidate commits. Workers now push every commit to cand/x42/<slice>
  immediately (WORKER_RULES rule 3), and the parent commits evidence at every state transition.
- A proof runner's negative tests must fail in PREFLIGHT with a bad SHA (exit 70) before PG starts. Never spend a PG run discovering a bad input.
- Spec assertions must trace to the executing registry. S11-D leg B has failed live three times on harness wiring (token filter → wrong
  registry seam). Before any journey spec proof, statically trace every asserted value through the exact registry the reader receives.
- Hard-coded commit SHAs in a spec (J20 pins) couple the tree to the commit identity. Re-creating a commit changes the tree, so proof reuse needs a J20 re-run.
- Run the PG proof in parallel with independent reviews: the v1 live failure and review B's static finding agreed, and neither waited on the other.
- 2026-09-27: A repo-wide "rename vendor names" instruction reached an applied migration and unrelated domains. Grants that edit wording must name the in-scope paths explicitly and exclude prisma/migrations/**.
- 2026-09-27: The extension repo disallows merge commits (rebase/squash only). The backend repo allows merge commits.
- 2026-09-27: A builder's 'pkill -f vitest' killed other lanes' test runs. Rule added: kill only your own recorded PIDs.
