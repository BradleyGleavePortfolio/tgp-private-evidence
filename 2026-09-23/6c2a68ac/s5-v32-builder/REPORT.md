# S5-V32 builder REPORT — `repair_s5_binding_mue9vjso` (sole T4 builder)

**Tier: T4 static candidate.** Nothing was executed, probed, locked, signalled, installed, committed or written outside `/home/user/workspace/execution/6c2a68ac/s5-v32-builder/`. Authorized static tooling only: `bash -n`, `diff -u`, `patch` on `mktemp` copies, `sed`/`grep`/`cmp`/`sha256sum`. Runtime identity of the builder is unasserted telemetry. Frozen 2026-09-23 ~16:00Z for two independent changed-candidate reviews.

## Concise A/B statement (Bradley doctrine, parent mail 4)

| class | defect | minimum fix (this candidate) | execution unlocked |
|---|---|---|---|
| **B (proof-invalidating — stale current-attempt attribution)** S5-V31-A-01 | v3.1 `runner_bound` fallback bound the shared runner record by `pgid=$SESSION` + one-second stamp floor; an equal/future-stamped stale record with a reused session number would be imported as this attempt's (false hold / false facts) | runner v101y publishes `token=<inherited lease token>` in its first (truncating) START write; launcher v3.2 accepts a START line only with `pgid=$SESSION` **and** `token=$TOKEN`; stamp floor / `SPAWN_TS` removed. Two files, +14/-11 and +6/-2, primitive bytes unchanged | one private controls proof `ctl-v32.sh` (11 checks, incl. new negative P3c), then canonical setup/T0 and S6 per parent — **no runtime until grant** |
| **B (proof-invalidating — acknowledgement timing)** V31-B-01 | P1 waited for state/reason then read a later HEARTBEAT line → possible false FAIL | one bounded `wait_text` (5 s) before the unchanged `P1.inner_live_hold` conjunction | same proof run |
| C (hygiene, nonblocking) O-B-01 | failed conjunction gave no per-operand evidence | FAIL-only `diag` snapshot in `check()`; no predicate changed/reordered; already built and parse-checked, does not delay freeze | — |
| C (carried) V31-B-02/03/04 | predecessor-hash mislabel; informational | header correction in `ctl-v32.sh` only | — |

No A-class (actual product harm) defect is asserted: the candidate is not launched and canonical paths are untouched.

## Deliverables

```
s5-v32-builder/
  REPORT.md (this)                     SHA256SUMS.s5-v32-builder (non-self-including, covers both packets' files + FREEZE.json)
  s5-setup-exclusion-v32/              manifest SHA256SUMS.s5-setup-exclusion-v32 = addc713d7297796cc98fccfb7c05bde770bedf341322a17a38850ed0cd25adba (18 files) ; FREEZE.json outside it
    launch-s5-setup-exclusion.v32.sh   55acc00fe9b04d0e015f37bbdac90e582925c4b4564f7aaaa55c21a13304cf0a  (v3.1 d5d9b2b8 -> v3.2)
    run-s5-setup-npm-ci.v101y.sh       61b565e48fa4c14f765fe223bfc3a8baac27ca2867763c91e6a57135fc4ea1b3  (v101x 81ff20b0 -> v101y)
    verify-embedded-block.v32.sh       e3716e40288438f3716e1b302453c0c73b4fa5f53c72f78c822d5d39e8f650dc
    diffs/launcher-v31-to-v32.diff, runner-v101x-to-v101y.diff, launcher-v3-to-v32.cumulative.diff (all reproduce candidates byte-for-byte via patch)
    FINDINGS_MAP_AND_REQUEST_V32.md, SYNTAX_CHECKS.txt, INPUTS.json, inputs/ (frozen predecessors + audits, hashes verified)
  s5-setup-v32-controls/               manifest SHA256SUMS.s5-setup-v32-controls = b99771a79d80e768a710475cd772e0fd1ccc37ca504fbfc723acabed039f036e (11 files) ; FREEZE.json outside it
    ctl-v32.sh                         4323dc41953f321394e0ee98ffa7c2186943b83067b2cb6886a03aafbca35a3c  (ctl-v31.v2.sh f34769c3 -> v32; PIN_L 55acc00f)
    fake-runner.v32.sh                 045d5284993217e98b85932bb33d6ba6e9a272097070ffd1f3c0f42a7b02f838  (fake v31 4e7858a2 -> v32)
    diffs/ctl-v31v2-to-v32.diff, fake-v31-to-v32.diff ; REQUEST_V32_CONTROLS.md, SYNTAX_CHECKS.txt, INPUTS.json, inputs/
```

## SCOPE S5-V32 acceptance mapping (SCOPE.md 20c07d23)

| acceptance clause | how met | evidence |
|---|---|---|
| close S5-V31-A-01 with exact current-attempt binding in the earliest checked publication | runner's first write (START, L210) carries the inherited token; launcher form (b) requires `pgid=$SESSION` AND `token=$TOKEN`; form (a) INHERITED token line unchanged | `diffs/runner-v101x-to-v101y.diff`, `diffs/launcher-v31-to-v32.diff` L185–189 |
| stale equal/future timestamp records cannot supply current runner facts | no stamp operand remains; token mismatch → `exit_record=not-this-attempt` regardless of stamp; static pattern table below; negative control P3c (equal/not-before-spawn stamp, exact session number, foreign token) | `SYNTAX_CHECKS.txt`, `ctl-v32.sh` P3c |
| retain early-death liveness | START-line binding retained (token-bearing); P3b unchanged and still LAST | `ctl-v32.sh` L124–126 byte-identical |
| raw-status truth, no-handoff/last-owner behaviour | untouched code (diff confined to header, L38, L41, L170, L185–189, L193, L227 removal) | cumulative diff |
| unchanged OWN-BLOCK v10.1 bytes | sed-extract sha256 `4aebf96f…` in both files == `inputs/own-block-v101.sh` | `SYNTAX_CHECKS.txt`, `verify-embedded-block.v32.sh` |
| preserve all prior assertions; add only the negatives the finding requires | 10 predecessor `check` statements byte-identical; +1 negative (P3c); P2 token-bound wait retained | `SYNTAX_CHECKS.txt` (controls) |
| freeze diffs, hashes, requests, non-self-including manifests | per-packet manifests (exclude self and FREEZE.json), top-level manifest, FREEZE.json | this tree |

### Static evidence: v3.2 START pattern vs synthesized lines (grep on literal text; no candidate executed)
Matches: our v101y START; our fake v32 START. Rejects: stale same-pgid equal-stamp foreign token; stale same-pgid **future** stamp; `token=none` (standalone shape); v101x shape (no token field, same pgid, future stamp); our token with other pgid; our token as prefix of a longer token; pgid prefix (1234 vs 12345); unanchored line. INHERITED fixed-string: ours matches, stale token rejected.

## Design decisions the reviewers should weigh
1. **SPAWN_TS removed** (not kept as redundant floor): with exact token identity the floor adds nothing and a wall-clock step-back between HELD and runner START would create a false negative → unrecoverable unknown hold on a genuinely bound runner. Alternative (one line, not chosen): `&& stamp >= SPAWN_TS` after the token match. Parent may direct either; no other line changes.
2. `pgid=$SESSION` retained in form (b) as structural provenance (P3b proves actual-platform pgid behaviour if granted); it is no longer the identity carrier.
3. Standalone runner runs publish `token=none` — a launcher never accepts `none` because `TOKEN` is always non-empty (`date-pid-RANDOM`).
4. P3c fixture writes via the shim that *is* the SESSION pid (only way to obtain "exactly this attempt's number" deterministically without execution-order races); it writes only under `S5X_EX`, seeds before `exec "$@"`, and the launcher reads the record only after the 2 s confirm + refusal path, so ordering is deterministic. Future-stamp class needs no separate case (identical code path, no stamp operand).
5. `diag` is FAIL-only and post-evaluation; tools limited to those already used by the driver (no `stat`, no `%N`).

## Findings carried / disposition
* V31-B-01 closed (P1 wait). V31-B-02 corrected in controls header only (predecessor of ctl-v31.v2.sh is ctl-v31.sh e87b0a2e; "18a743e4" retained-header text is a mislabel). V31-B-03/04 informational, unchanged.
* O-B-01 (s5-v2-result-b): addressed by `diag` (nonblocking class C).
* Parent mail 3 timeout facts: `REQUEST_V32_CONTROLS.md` lists the genuine `timeout` semantics relied on (outer `--foreground -k 10 180`; inner child-status propagation and no pgid move — P3b exposes; bounded `timeout N cat fifo` in P2/finish); GNU is not asserted, no tool change requested.

## Nonclaims
* Nothing executed; no runtime, probe, lock, census, grant, or environment archaeology. Static expectation "11/11 PASS" is not evidence.
* Runtime identity (model/runtime) unasserted telemetry.
* `TOKEN` = `date -u +%Y%m%dT%H%M%SZ-$$-$RANDOM`: "unguessable" is the reviewer's/parent's designation; the closure's property is exact identity (a stale record cannot carry a token it never received), not secrecy against a `/proc`-reading adversary.
* `diag` is a post-evaluation snapshot (ms gap, up to one heartbeat of record drift), not inline per-operand evaluation.
* No claim about the actual platform's pgid/`timeout` behaviour; P3b/P3c would show it.
* `patch` reproduction and `bash -n` were performed on the candidates and on mktemp copies only; no canonical or private-checkout path was written.

## Stop triggers checked
No new material ambiguity (parent mails 1–4 resolved the earlier ones), no primitive change, no authority expansion, no collision (only `s5-v32-builder/**` written; no worktree/s5-r4 touched), no unscoped behaviour. Freeze complete; awaiting two independent reviews, then the single private proof under grant.
