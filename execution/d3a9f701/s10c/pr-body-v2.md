S10-C: settled-basis record, run-coverage wiring and module registration (D-S10-7 row S10-C).

What it does
- facts.service: one module-level (platform, token) family resolver; staged platform facts from the source mappers; collect(db, coach, intent, run) takes the run binding as a parameter and evaluates run coverage from the run's declaration (a poisoned challenge collapses to empty, never to a guess).
- lifecycle.service: the settle lock also reads accepted_start_at and passes the run context to reconciliation; after the terminal CAS hits, the same transaction writes the settled basis (the evidence digests of that run epoch's observations). readReport answers from the settled basis only when it applies to the run.
- scout.module / observation.module: registers the observation service once (drops the duplicate PrismaService provider).
- Tests: unit and coverage specs for facts and lifecycle, wiring spec, RLS spec rls-g2-s10c (8), S9-C live assertions superseded by D-S10-4, S8-G settle-hook fake transaction extended for the basis write.

Gates
- Two independent reviews GO (plus delta). Gate v2: prettier, R75, eslint, tsc, contract check, targeted and full jest, sentinel commit. Real-PG proof on the disposable lane (RLS s10b 24 + s10c 8).
- No schema or migration change (173 migrations, schema blob unchanged). Production LOC 407.


Supersedes #553: the real-PG proof of 6674bc59 found four spec-premise defects in rls-g2-s10c (duplicate and fenced settles are a 200 ack no-op; the coach import.complete notice; the retry re-drive belongs to S11-B). This candidate is the same gate tree with only that spec corrected.
