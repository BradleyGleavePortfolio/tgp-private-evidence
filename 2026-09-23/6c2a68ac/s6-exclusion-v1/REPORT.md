# S6-EXCLUSION-V1 — source-only successor build of the two S6 consumer compositions (EXEC-6c2a68ac, frozen)

Builder: `restore_s6_substrate_mue9osen`, sole T4 builder (requested Claude Fable 5 / High; runtime identity not observable, not asserted). Parent owner EXEC-6c2a68ac. Activated by parent mail (09:32 PDT) on the accepted S5 V32 private proof (`SHA256SUMS.s5-v32-control-result` `a21622ee…2796`; not re-audited, not re-run). Executed 2026-09-23T16:33Z–16:45Z. Sole writes: fresh `/home/user/workspace/execution/6c2a68ac/s6-exclusion-v1/**` (absent before write). Product worktrees, packets and the private checkout were read-only (no write; private HEAD d77233a5 at read, d96fc145 porcelain 0 at freeze — parent publishing, not read as input after the grant read). Methods: read/`sha256sum`/`diff -u`/`patch` on mktemp copies/`bash -n`/deterministic asserted line replacement. NOT done: runtime, probe, process census, lock open/probe, signal, install, hook, commit, product edit, controls/fake, primitive change, historical restoration, observer edit.

## 1. Inputs (all pins verified; `INPUTS.json`, `INPUTS.sha256`)

Grant `S6_EXCLUSION_SUCCESSOR_BUILD_GRANT.md` `295a315d…` (private 9f7ed7a9; unchanged at head d77233a5). Scope map `9cbefd02…` + addendum `0f5d7280…` (scope manifest 57bcbf08 2/2 OK). Frozen S6 consumers setup `8b1ae8c0…`, C6 `2c9748a4…`, seal `6b2be238…`. Accepted V32 launcher `55acc00f…`, runner `61b565e4…` (contract reference), OWN-BLOCK `4aebf96f…`; V32 manifest addc713d verified 0 non-OK. Grant and mail directions were consistent; no missing exact input, no collision, no ownership expansion.

## 2. Candidates (four additive files; `FREEZE.json`, `SHA256SUMS.s6-exclusion-v1`)

| Composition | Launcher | Runner variant | PIN_RUNNER in launcher |
|---|---|---|---|
| S6 setup | `launch-s6-setup-exclusion.v1.sh` **`6035a8f4d726b65afcb381d82903f2b1cfe22602860eda72e84a5afe61a43624`** | `run-c5-setup-npm-ci.v101y.sh` **`8a5a5161cc44ad349bc1923b54217bff84d5ba725a38d46c1adcaad6facf6633`** | = runner sha ✔ |
| S6 C6 | `launch-s6-c6-exclusion.v1.sh` **`ad8130e9b5acd5e222817335c26e971ddf0bd69e858cfaa117568b1af8310a78`** | `run-c6-hazard-v5-conly.v101y.sh` **`692f8db79a283135d1a609bfcb99b1fd81bf09a527692af332805976f755bc66`** | = runner sha ✔ |

Deltas (exact unified diffs in `diffs/`, each reproducing its candidate byte-for-byte via `patch` on a temp copy, `cmp -s`):
- Runners (from the frozen S6 consumers): header note (retained original header), START line publishes `token=${S6_LEASE_INHERITED:-none}` (S5 v101y contract), lock acquisition → `S6_LEASE_INHERITED` inherited-fd-9 branch (readlink fd 9 = `$LOCK`, `$EX/LEASE_HOLDER` names the token and a live holder pid, INHERITED binding line; `else` = the original own-`flock` bytes incl. C6's lock-busy text); C6 only: IDENTITY field order `pid=` first (content unchanged). Setup +17/−3; C6 +19/−7. `flock -n 9` calls / `exec 9>` / child `9>&-` each remain exactly 1.
- Launchers (from V32): H-L1 constants, H-L2 four-marker refusal before the lease (`exit 71`), H-L3 `S6_SETUP_GRANT`/`S6_C6_GRANT` + `S6_LEASE_INHERITED`, H-L4 `REL_KNOWN`/`REL_BOUND` released-attempt → bound IDENTITY → retained SID accounting (replacing the `released=1` boolean and set-emptiness rule), comment-only updates in `runner_bound`. F3 +34/−13, F4 +35/−14; F3↔F4 differ in 14 constant lines only. OWN-BLOCK v10.1 sed-extract `4aebf96f…` identical in all four; unused private `S5X` branch verbatim; no observer file (O-A).

Static evidence: `STATIC_CHECKS.txt` (bash -n rc 0 ×4; block identity ×4; patch reproduction ×5; code-line occurrence counts: launchers +1 `exit` = gate 71, runners +1 = word "exits" in the evidence line; constants cross-check; gate precedes `exec 9>`), `PATTERN_CHECKS.txt` (exact grep/sed expressions vs synthesized lines: START regex accepts only our session+token; INHERITED fixed string exact; attempt-name sed matches both consumers' released lines and rejects never-released/REFUSED/launcher lines; `^pid=` yields a pid on the new C6 shape and the setup shape, EMPTY on the old C6 shape). The specific boundary (known selftest SID must not authorize release when C's released attempt has no bound IDENTITY) is traced from source in `docs/FINDINGS_MAP_AND_REQUEST.md` §3: it yields `CENSUS=unknown` ⇒ SELF-HOLD; `release` is reachable only from `CENSUS=empty`.

## 3. Findings and disposition

- A/B (concrete defect in the composition that I could not fix within scope, missing exact input, collision, ungranted consequential change): **none** — no stop condition met.
- C (recorded, continue): C-1 second `local` line in `session_state`; C-2 addendum sed `state=released.*` kept verbatim (no over-match in practice); C-3 setup `CANON_EX` `execution/s6-diagnostic` not yet present (created by the launcher's `mkdir -p` at first granted launch; nothing created here); C-4 private `S5X` defaults verbatim in the C6 copy; C-5 canonical lock file absent at S6-RESTORE (15:40Z), present at freeze (16:46Z; existence only, not opened/probed; created by other granted activity). Details in `docs/FINDINGS_MAP_AND_REQUEST.md` §4.
- Carried, unchanged: v3/B-01 early-death hold consequence, `EXCLUSION_UNPRESERVED` + inner-timeout raw combination, `released-then-cancelled` discoverability via `inner_sids`, A-01 indistinguishability boundary, HOLD_BOUND branch now non-final under the launcher.

## 4. Ownership and next step

Owned outputs: `s6-exclusion-v1/{REPORT.md, FREEZE.json, INPUTS.json, INPUTS.sha256, STATIC_CHECKS.txt, PATTERN_CHECKS.txt, SHA256SUMS.s6-exclusion-v1, 4 candidates, diffs/5, docs/FINDINGS_MAP_AND_REQUEST.md, inputs/10 read-only copies, tools/2 derivation scripts (evidence, not candidates)}`. Manifest is non-self-including. Nothing else in the workspace was written; `source/mobile` a5933fd6, `worktrees/s6-diagnostic` d51a1910 and `execution/op88/s6-c6-prep` (19/19) re-observed unchanged.

Request: two independent nonbuilder reviewers assess both exact final compositions from source (incl. the §3 boundary); on dual closure the parent may grant actual S6 setup, then separately C6-only, when a runtime slot is available. No runtime claim, product clearance, primitive re-audit or framework is made or requested here. S6 execution remains HELD.
