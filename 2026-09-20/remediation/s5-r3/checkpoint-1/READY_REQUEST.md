# S5 R3 → parent: fixture/runner ready request (2026-09-20 ~23:02 UTC)

Source work is complete and committed; worktree clean. Requesting the serialized slot when S1 guard review is done.

- Head `9f38ab033b08ae30ce2fc62d0150520239d6a5c8` (tree `49d2e03c…`), branch `execute/20260920-s5-r3`, parent `485c6797` unchanged; Bradley Gleave author+committer verified; test-only delta (5 files, +212/−14). Bundle `execution/s5-r3/s5-r3-candidate.bundle` verified against public base `c23b9d9f`, contains O `925780e0`. Checksums in `SHA256SUMS`.
- Done offline: O fixture as detached self-contained clone (`test/utils/g2-pg17-old-root.sh`; workspace fixture at `execution/s5-r3/old-root-925780e0`, `alternates=none`; recipe also exercised from public-base clone + bundle; archive/branch/dirty negatives refused). Shell syntax, worker `node --check`, foreign-tsc syntax-only parse (labelled; zero grammar errors; not a type proof).
- Fixed: S5-R2-A-02/B-03 (terminal contract asserted both branches + new deterministic refused test with fixture-only `txTimeout`, labelled not a production guarantee), S5-R2-A-03/B-01 (real Git identity O recipe), B-07 (port). Mapped to S1: A-01/B-02 with measured facts in `S1_HANDOFF_E_RECOVERY.md` (forward file NOT idempotent; catalog-first; `--single-transaction` redundant; drain is a process boundary).

Requested, in order, each only when granted:
1. Heavy slot: `bash execution/s5-r3/npm-ci.sh` (S5's own lock `354de3da`; `flock -n`, exits 75 if busy; ~2–4 min).
2. After S1 guard review + lane s5 up: `G2_PG17_PASSWORD=… bash execution/s5-r3/run-proof.sh reset && … run-proof.sh all` (guard→oldroot→bootstrap→live; `flock -n`; ~5 min; expected 26/26, OLD_ROOT_OK, BOOTSTRAP_OK, live 51/51, PROOF_EXIT=0). One infra-class rerun max; all runs preserved.

Interface facts for S1/S2 are in `S1_HANDOFF_E_RECOVERY.md` (catalog/history probes). Nothing else needed from Bradley.
