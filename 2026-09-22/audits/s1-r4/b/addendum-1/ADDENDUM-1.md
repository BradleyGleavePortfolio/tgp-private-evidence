# S1 R4 reviewer B — correction addendum 1 (frozen; revision-1 left unchanged)

**Subject:** `execution/audits/s1-r4-current/b/revision-1/REPORT.md` (sha256 `5328732392d15498ad47eafcfd6e30a0e091ca0e53cd2b1fcd990b7f59a2fa95`). **Written:** 2026-09-22T04:57Z. Read-only; no tests/DB/install/remote/product work; peer A not read. Bounded source verdict, findings S1-R4B-01..06 and every dynamic/live/hosted hold in revision-1 are **unchanged**.

## Correction 1 — 56fb0d22 has been source-composed; B2 ran on that composition

Revision-1 §5 item 4 ("56fb has never been composed with S2; B1/B2 composed 41f4") and the §3 table row for B1/B2 ("both composed 41f4's verify.sql … no 56fb test file ever executed") are inaccurate for B2. Independently verified in `initialization/recovered/s2-r3-d5cd-readonly` (HEAD `d5cd9b8b…`, tree `c0ab87d4…`, porcelain 0):

- `git merge-base --is-ancestor 56fb0d22… d5cd9b8b…` → exit 0; likewise 56fb → `21ea3252…` exit 0.
- Commit `21ea3252de90cab66c591cf907b65a0ee7eef879` (tree `5aa6630b…`) is a merge with parents `3f49ffc8ac654e96e7eb9921de70a19cc0cba389` (S2 successor) and `56fb0d227558c86fe824f9fb1bc15e222411504f`; subject: "merge(s1-r4): compose frozen S1 test-only successor 56fb0d22 … into S2 successor 3f49ffc8".
- `git diff --stat 56fb0d22 {21ea3252,d5cd9b8b} -- prisma/migrations/20261224000000_rls_close_public_exposure test/db` is empty; controls `6a88a98c…`, discriminator `82da49b2…`, message spec `b8be189d…`, `verify.sql` `266e62e9…` at both composed heads equal 56fb's blobs.
- B2 receipts (`2026-09-21/remediation/s2-composition/b2-failed-and-r3-source/20260922T003854Z/`): `stamp.txt` `head=21ea3252… tree=5aa6630b…`; `exit-codes.txt` `final=1 … composition=1 s1_r4_discriminator=notrun`.

**Corrected statement:** B1 (`9742037b`) composed 41f4. B2 (`21ea3252`) composed 56fb's S1 paths byte-identically; its composition harness failed (66/2, S2-owned C0 construction) and the runner stopped before step 45, so the S1 R4 discriminator was **not run** on that composition either. `d5cd9b8b` (S2 R3 final) still contains 56fb unchanged; no dynamic proof of d5cd exists yet. What remains pending is therefore the **dynamic** composition proof (complete composed run plus the discriminator) on d5cd or its successor, not the source composition itself. Two independent exact-head attestations of the composed head remain required and are not given here.

## Correction 2 — "no 56fb test file ever executed" must distinguish offline from DB execution

Revision-1 §3 (B1/B2 row) says "no 56fb test file ever executed". Precise form: the **offline** message spec `test/db/s1-r4-truncate-message-spec.sh` **did execute** at the frozen head (`runs/offline-20260922T002622Z/message-spec-at-56fb0d22.log`: head 56fb, tree 79eb, porcelain 0, `controls_sha256=6a88a98c…`, `verify_sql_sha256=266e62e9…`, 24 passed / 0 failed, exit 0 — bash+grep only). The **database** controls (`_support/s1-truncate-controls.sh` via harness §4b or `s1-r4-truncate-discriminator.sh`) have **never executed against any database** at 56fb, 21ea3252 or d5cd (`s1_r4_discriminator=notrun` in B1 and B2; no harness §4b run at these heads). Revision-1 §0 and §5 item 1 already used the "against a database" qualifier; §3 did not.

## Not changed

Bounded source verdict at 56fb0d22 (no source defect; S1-R4-A-01 and pre-seed observation source-closed); findings S1-R4B-01..06; DYNAMIC ATTESTATION PENDING items 1–3 and 5 verbatim; item 4 as restated above. Requested model Claude Fable 5 remains requested-only, not observed.
