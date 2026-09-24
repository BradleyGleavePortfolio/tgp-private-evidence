# R closure 1 — reviewer B delta re-attestation

Reviewer B, EXEC-CF8FF737, 2026-09-24 ~16:45Z. Basis: `R_CLOSURE_1_GRANT.md`, `r-ready/R_CLOSURE_1_READY.md`. Delta only; bytes unchanged since `df36e331` were not re-reviewed. Read-only; no tsc/Jest/PG/push. Did not read `r-review-a/`. Route requested Claude Fable 5 / High; no telemetry claimed.

Disclosure: a second momentary `flock -n <lock> -c true` probe ran inside a lane-state command (nonblocking, released instantly, nothing contended). Same class as the Phase 1 disclosure; no effect on any lane.

## Verdict: GO

## 1. New head (recomputed)

| Item | Recomputed | READY report |
|---|---|---|
| HEAD | `7d2895e1fe03ea82353e8ce0b07aacaf66af74c8` | match |
| TREE | `95cdfadc1ae993db23d0d1310ee8029c7867d147` | match |
| parent | `df36e3310d4088501c93bcac3ce07617d02c749d` | match |
| author/committer | Bradley Gleave <bradley@bradleytgpcoaching.com> both; body has no trailers | G05 ok |
| spec blob | `HEAD:test/rls-g2-r-ready.spec.ts` = `0ae7b76489460dac33dff5434503a361a0acd063` | = EXPECT_SPEC_BLOB |
| bootstrap blob | `67b77f7ab91207cdf6e50bb088517bc9624635bc` (unchanged) | = EXPECT_BOOTSTRAP_BLOB |
| diff df36e331..HEAD | exactly 2 files: `migration.sql` +11/−11, `test/rls-g2-r-ready.spec.ts` +17/−4; `down.sql`, `schema.prisma`, `src/`, `test/utils/`, `test/scout/` untouched | confined per grant §3 |
| worktree | porcelain 0 | clean |
| hooks | receipt 13: Lefthook pre-commit (prod-readiness-quick, banned-cast-tokens, prettier, eslint, tsc 73.6 s) + commit-msg (no-ai-tokens), rc 0; lock held 16:34:10Z–16:35:24Z and verified free | genuine |
| receipts | `RECEIPTS.sha256` 13/13 OK | ok |

## 2. Moved gate (grant §1) — data-safety and atomicity

- Position-only: sorted-line multisets of old and new `migration.sql` are identical (my own `diff <(sort old) <(sort new)` empty); every `-` line pairs with a `+` line. The 11 moved lines (2 comment lines + `IF … RAISE EXCEPTION 'G2-R wide identity already present'; END IF;`) are byte-identical.
- New position: immediately after `END LOOP;` of the narrow-index loop (line 49), before the column-prerequisite gate. New gate order: narrow → wide-present → column shape → fence → NULL → noncanonical ledger → noncanonical staging → DDL.
- Refusal atomicity unchanged: the gate is a pure catalog read (`to_regclass`, `pg_constraint`), has no side effects, and remains inside the single `DO` block that precedes all DDL, inside the same `BEGIN … COMMIT` with `SET LOCAL lock_timeout/statement_timeout` and both `LOCK TABLE … ACCESS EXCLUSIVE` unchanged. Any `RAISE` still aborts the transaction with nothing applied; the set of states the file refuses is identical — only which message is raised first differs when more than one gate would fire (rerun-after-apply now names "already present" rather than the column prerequisite).
- No data path changed: no UPDATE/DELETE/DEFAULT/DROP introduced; NULL/noncanonical still refused, never coerced. `down.sql` blob unchanged.
- Spec consistency: lines 465, 475, 673 (`already present` on post-apply rerun / re-up) are unchanged and are now reachable under the new order; R04 (`fence absent` on E-only) unaffected since wide objects are absent there; nothing in the spec expects `unexpected platform column prerequisite`.

## 3. R11 hunk (grant §2) — closes my B-2

- `expectRefusedUp(message, before, expectedWide = ABSENT)`: the grant's "equivalent route"; every other caller keeps `ABSENT` semantics by default.
- `onlyDecoy(w)`: asserts `ledgerNotNull === false`; `indexes.length + checks.length > 0` (non-vacuous — the decoy must actually be seen); each index def contains `' ON public.g2r_decoy '` (5th element of `wide()` index rows = `pg_get_indexdef`, always schema-qualified, so the real tables would render as `public."ScoutIngestEntity"` and fail); each check's relation (3rd element = `conrelid::regclass::text`) matches `/^(public\.)?g2r_decoy$/`. Destructuring positions verified against harness `wide()` row shapes `[relname, indexrelid, indisunique, indisvalid, def]` and `[conname, oid, rel, convalidated, def]`.
- Snapshot taken after each decoy step and passed as `expectedWide`; the refusal must leave `wide()` byte-equal (including OIDs), so an adopted or dropped decoy would be detected. End-of-test `expect(wide()).toEqual(ABSENT)` after `DROP TABLE` unchanged. Cascade into R01 no longer occurs.
- `any` is permitted (`eslint.config.js` `no-explicit-any: off`); eslint passed in hook.

## 4. Binding refill (grant §4)

- `r-pg-proof.sh` sha256 recomputed `787d34b08f7abcbc18fa077eed29b15167fc762983f47fe58e3de6beb89b3cc2` = READY/PINS; previous `ac437b90…` preserved as `r-pg-proof.sh.v1-ac437b90` (recomputed match). `r-fixture.sh` `6e71d754…35f3` unchanged. `BINDING.sha256` 3/3 OK. `bash -n` ok. Placeholder scan: only the refusal pattern itself.
- Actual `diff v1 → current` equals the shipped `r-pg-proof.sh.diff-closure1-vs-v1`. Changes: header comment; pins lines 26–28 (HEAD/TREE/SPEC); line 45 `G2_R_DATA_DIRECTORY=$RDIR/pg-data` (closes my B-1 — fixture data dir and identity check now agree, and the spec's `beforeAll` regex `/pg17/clusters/r-ready/pg-data$` is satisfiable); lines 74–76 hooks via `git rev-parse --git-path hooks` (resolves to `/home/user/workspace/worktrees/s7-b-drain/.git/hooks`, absolute, both files lefthook — precondition now passes for this linked worktree). Nothing else differs.
- `derive-r-pg-proof.py` updated and pinned (v1 kept).

## 5. Lane state (read-only, 16:45Z)

No postgres processes; `/home/user/pg17/clusters/` = `b-drain`, `b-drain.v4-failed-…` only (no `r-ready`); no `r-ready/runtime*`; 3.8 GiB free (≥3 GiB). Retained B cluster baselines from Phase 1 unchanged.

## 6. Qualifications (C, recorded)

- Default Jest did not run in the hook (Lefthook pre-commit has no Jest step); the two changed files are not imported by any default-Jest suite, so receipt 11 (3 suites/90 tests on df36e331) remains applicable. No new run needed.
- Phase 1 C-1…C-8 carried unchanged.

GO for `R_SINGLE_PG_PROOF_GRANT.md` against HEAD `7d2895e1`, TREE `95cdfadc`, spec blob `0ae7b764`, binding sha `787d34b0…3cc2`, fixture sha `6e71d754…35f3`, subject to the PRE-R3 lane conditions at run start.
