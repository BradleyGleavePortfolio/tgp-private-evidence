# B1-S1S2-COMPOSITION diagnosis (run composition/20260922T000811Z, closed; NOT rerun)

Frozen fingerprints (before any repair): run dir SHA256SUMS.b1-frozen; harness.log 8647cc5e…dd45; C0.release.log 781f521e…fd0e;
C1.release.log 315c5edb…2c58; C8.release.log 35f809e2…6c43; runs/composition.log 23f1eb2a…e0c1; runs/composition.exit 4355a46b…d865 (=1).
Source under test: head 9742037b tree 5469fbef clean; scripts/release.sh blob a4f76741 sha256 9908234e…f80ac (byte-identical to e15e25c2);
harness test/release/s1s2-composition.sh 499b3836…fb56; S1 paths byte-identical to 41f4d6a9 (verify.sql 266e62e9…9448). Prisma 6.19.3 real, PG 17.6 real.
Exit chain: guard 72/72 → refusals 64/64 → init/start 0 → harness 63 passed / 4 failed (exit 1) → discriminator NOTRUN (runner stops at first
failing step) → stop 0, status "no server running", survivors none, lock FREE. S1 R4 discriminator remains UNPROVEN.

## What PASSED (real, gating behaviour of release.sh is correct)
P1/P2 real `prisma migrate deploy` of 164 parents on both DBs, ledger exactly 164 finished rows, pre-state twin applied, verify.sql fails on pre-state.
C0/C0b refusal when verifier missing (exit 1, no DB contact). C1 positive: candidate applied, verifier discovered+passed, exit 0; C1v ledger 165, psql verify OK
(18 relations, 4 partitions). C2 idempotent. C3 down.sql reversal → verifier FAIL → exit 1 with S1 EXPOSURE text. C4 recovery → 0. C5 allowed-path drift → 1,
class + lost privilege named; C5r → 0. C7 late lock → exit 1, P3018/55P03, candidate named, no success banner. C8 real failed row → resolve --rolled-back →
release 0, ledger 165 excluding rolled-back row. Worktree clean after run.

## The 4 failures — all in release.sh OBSERVABILITY fields (S2-owned scripts/release.sh), none gating, none S1
D1 (fails C1 #2 "pending_before=1", C8 #4): release.sh:212-215
    PENDING_COUNT=$(grep -cE '^[[:space:]]+-[[:space:]]+[^[:space:]]+$' "$STATUS_LOG" || echo 0)
  Prisma 6.19.3 `migrate status` prints pending names bare on their own line (C1.release.log:18-19 "Following migration have not yet been applied:" /
  "20261224000000_rls_close_public_exposure"), not the Prisma-5 indented "- name" the regex expects → 0. Additionally `grep -c` exits 1 on zero matches
  after printing "0", then `|| echo 0` fires → PENDING_COUNT is the two-line string "0\n0" (stray "0" lines at C1.release.log:24 and :67, C8:21,:54).
  Product defect: pending_migrations_detected / pending_before metrics are wrong under the pinned Prisma. Exit gating unaffected (deploy/status/verifier gate).
D2 (fails C1 #3 "ALL_APPLIED == 165"): release.sh:305 `npx prisma db execute --stdin <<SQL` with no --url/--schema. Prisma 6 rejects it:
  C1.release.log:60-62 "WARNING: prisma db execute failed … Error: Either --url or --schema must be provided" → ALL_APPLIED=unknown (line 65).
  Product defect: header contract release.sh:11 promises "ALL_APPLIED=<n>" on success; under real Prisma 6.19.3 it is never produced. Non-gating (WARNING path).
D3 (fails C0 #1 "prisma_cli += prisma"): release.sh:59 `npx --no-install prisma --version | head -1`. With a schema in cwd Prisma 6 prints
  "Prisma schema loaded from prisma/schema.prisma" first (C0.release.log:7, C1:7, C8:7), so the banner never shows the CLI version.
  Product cosmetic defect + harness expectation written against the intended banner. The check's purpose (refusal was not "prisma missing") is otherwise
  satisfied: the banner is not 'prisma cli missing' and C1 later ran the real CLI in the same tree.
Harness-side observation (C8 #4 only): after `migrate resolve --rolled-back`, Prisma 6.19.3 `migrate status` reported "Database schema is up to date!"
  (C8.release.log:19) yet `migrate deploy` re-applied the candidate (C8.release.log:28 "Applying migration …"). So even with D1 fixed, pending_before=1 is not
  a valid C8 expectation under this Prisma; the valid evidence is the "Applying migration `<candidate>`" line plus the ledger check (which passed).

## Classification
product failure (S2 release.sh observability, requires S2 source edit): D1, D2, D3 — 3 lines (59, 212-215, 305). No S1 verifier/migration/guard change needed.
harness failure (S2 harness expectation): C0 regex (D3-dependent) and C8 pending_before expectation (Prisma-6 status semantics). No masking proposed:
  C1 must still assert pending_before=1 and ALL_APPLIED=165 once D1/D2 are fixed; C8 asserts the real "Applying migration" line instead.
Not pre-existing-baselined: no prior real-Prisma run exists to compare; these are first-real-run findings against frozen e15e25c2 release.sh.

## Exact next proof (needs parent go for an isolated successor + one heavy slot; nothing edited yet)
1. Isolated S2 successor commit on a new branch from 9742037b (auditors keep reading frozen 974): scripts/release.sh minimal fix —
   line 59 `… --version | grep -m1 -E '^prisma[[:space:]]+:' || echo 'prisma cli missing'`;
   lines 212-215 count pending via `awk` over the block after "have not yet been applied:" (bare-name lines), ensure single-line 0 default;
   line 305 `prisma db execute --stdin --url "$DATABASE_URL"`. Harness: C0 regex → `prisma_cli += prisma[[:space:]]+:`; C8 → assert "Applying migration `$MIG`" + ledger.
   Applicability: only Prisma-6 output parsing/CLI flags; no gate, exit or verifier-contract change; e15e25c2 release.sh otherwise untouched.
2. Slot B2 (same v3 runner, fresh clusters/s2comp after confirming absent, ≈2 min harness + discriminator, same bounds): expect 67/67 and, for the
   first time, step 45 S1 R4 discriminator run on protected s1_rls_s2comp under the held lock. Discriminator result belongs to S1 R4; S2 only reports it.
