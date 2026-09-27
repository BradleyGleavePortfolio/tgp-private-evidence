# S12-B5 build grant (EXEC-42D8C5B5) — T2, builder claude_sonnet_5_0
Tier: T2. Why: read-only catalog script for a production RLS check (owner question 8); written and reviewed, NOT run against production.
Base: backend 419a756da4e6eebc28e22b19d0c08d72549f6d4e (= origin/cand/x42/s12b1-on-s8d1: S11-DE → S8-D1 → S12-B2 → S12-B1, the composed
stack now in landing proof; integration/importer will FF to it). Fresh clone: `git clone --no-hardlinks /home/user/workspace/repos/backend <clone>`,
fetch origin cand refs with api_credentials github; node_modules `cp -al` from the donor per WORKER_RULES. Commit as Bradley Gleave through the
hooks; push every commit to the preserve ref named below. Rules: execution/42d8c5b5/WORKER_RULES.md (lock for every tsc/jest/prettier run).
Clone /home/user/workspace/worktrees/x42-s12b5, branch x42/s12b5, preserve ref cand/x42/s12b5.
Scope: execution/fa72efb2/s12/S12_PILOT_READINESS.md §2b row S12-B5 (+ the owner-question text it cites): one read-only SQL script (scripts/ or
docs/pilot/) querying pg_policies / pg_class.relrowsecurity / relforcerowsecurity for WorkoutSession, WeightLog, Habit, CheckIn,
ClientWorkoutAssignment* (and any table the readiness doc lists), emitting an explicit expected-vs-actual verdict per table; transaction READ ONLY;
no DDL/DML; documented invocation for Bradley. Validate on a throwaway local PG from the runtime (migrate deploy at base) under the lock and record
the output (note that local ≠ production; the out-of-band production RLS gap is the reason this exists).
Report execution/42d8c5b5/s12b5/BUILD.md.
