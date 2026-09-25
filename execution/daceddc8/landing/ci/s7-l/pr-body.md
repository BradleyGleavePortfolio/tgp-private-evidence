Exact candidate bytes for S7-L, the server-owned import run lifecycle. Head `df713fd9217df524915348ef8a42c797f288dde1` (tree `796f437f`) is a fast-forward of `integration/importer` `93389265`.

**Not yet accepted. Do not merge.** This draft is pre-staged only so CI runs early. The S7-L PG-4b proof is pending. The PR is marked ready and fast-forwarded only after that proof passes and on the operator's word.

- Lineage: `a68cdac7` plus one test-only follow-up, `test/utils/g2-s7l-worker.cjs`.
- Includes the expand-only migration `20270123000000_scout_run_lifecycle_expand`, which has a refusing down.
- Author and committer: Bradley Gleave. No trailers.
- Landing method: an ordinary fast-forward push of this exact head. The GitHub merge button is not used.
- Scope: `integration/importer` only, which is non-production. Nothing here targets `main`, which stays the owner-reserved production boundary (#530).
- The Danger PR-title failure is the known class C.
