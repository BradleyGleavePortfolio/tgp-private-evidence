# S2-R53-INDEPENDENT-PLAN-A — frozen revision 1

## Disposition

**HOLD request06a as written and real-proof request06b.** There are concrete supervision/control-driver defects below; historical stub observations do not establish the changed runner’s real-mode safety. This is a source/evidence assessment, **not execution or DB authorization**. ([Frozen inputs and observations](STATIC_EVIDENCE.json))

**Exact inputs:** backend `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, public base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; runner `fb0d7ce4803fa0d414c703cb0362b2e66626b8d6cf63dfa9054ed8e3eb2dc925`; reimplemented fixture `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881`; source clean; setup packet37/37 and prior runner packet84/84 hashes match. ([Independent read/hash/Git record](STATIC_EVIDENCE.json))

**Independence/authority:** T4 privilege/destructive-fixture/recovery/evidence boundary; not a builder; no current S2 peer report or conclusions accessed. Requested model is inherited parent; actual model/version/reasoning setting are unobservable. Read the complete allocation/review brief, current dispatch, frozen requests05/06, packet report, necessary exact-d5cd consumers and frozen v5.3 controls. No candidate edits, tests, syntax checks, probes, installs, process/lock actions, network or DB execution. Existing S1 revision1 remains untouched. Parent’s separate SETUP-05 grant is neither revoked nor elevated by this review; its actual setup results were not reviewed. ([Mandate](../../../../S2_R53_ALLOCATION_AND_REVIEW.md))

## Material findings — source counterexamples, not newly executed failures

### S2-R53-A-01 — step completion discards descendant ownership before quiescence

**High; blocks06b.** `run_step` waits only for its `setsid timeout --foreground` leader, then clears `STEP_PID/STEP_PGID` at125 without checking remaining group members; subsequent cleanup can see only a new/current group and its command-name allowlist. ([Runner L75–98,112–126,134–147](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))

**Counterexample schedule:** an inner deadline or early leader exit leaves a same-group child whose command does not match `OWNED_PAT`; after125 the group is forgotten, so cleanup can announce `reap=ok`, stop the fixture and release the lock while that child survives, or a successful step can advance to the next stage first. ([Runner L60,117–126,135–158](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))

This is relevant to the actual consumer, not just an arbitrary executable: release’s ledger query is a DB-using `node -e` process, whereas the real-mode Node scan requires `prisma/build/index.js`; real release also introduces nested `timeout --foreground` commands. ([Release L325–338](../../../../../worktrees/s2-runner53/scripts/release.sh), [composition L99–105](../../../../../worktrees/s2-runner53/test/release/s1s2-composition.sh), [runner L60](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))

K3 exercises a signal **while** the leader/group is still recorded; K4 gives its escaped child the specially recognized `s2r53-stub-escapee` name, so neither covers forgotten same-group children or unrecognized escaped descendants. ([Stub and driver](../../../../s2-setup-prep/controls-proposed/stubs/harness.sh), [K3/K4 observations](../../../../s2-runner53/controls/20260922T043943Z/CONTROLS_RESULT.txt))

**Smallest closure:** retain each owned step’s group/descendant identity through a bounded post-wait quiescence check on every exit; forbid next stage and fixture stop unless it is empty, otherwise quarantine. Do not solve ownership by widening global process-name kills. Add authorized no-DB controls for leader-exits-first, inner-timeout and an unnamed descendant/escape; no product/S1 edit is needed.

### S2-R53-A-02 — “48-second worst case” is arithmetic, not an enforced cleanup deadline

**Medium, material; blocks06b’s stated60-second grace claim.** `halt_owned_work` performs unconditional `wait "$STEP_PID"` after its polling loops, and the isolation-anomaly branch waits after TERM with no bound; either can block before the failure/quarantine record is reached. ([Runner L81–98,119–121](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))

The10/5-second “waits” count iterations including unbounded scan work, and `SCAN_HASH_ALLOW=3` does not enforce a deadline around final scans/hashing; `cleanup_seconds` is even stamped before the manifest hash operation. ([Runner L47–48,87–93,146–157](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))

**Counterexample:** if a killed child remains unreaped/blocked, line93 waits beyond the polling allowance instead of reaching `REAP=FAILED`; the outer foreground timeout can kill the runner at its grace limit without finishing quarantine/descendant handling. This is a source possibility, not an observed kernel/process failure in this review. ([Runner L46–48,93–97](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh), [06b launch](../../../../s2-setup-prep/SLOT_REQUEST_06_CONTROLS_AND_PROOF.md))

**Smallest closure:** use one elapsed-time cleanup deadline, bound anomalous isolation and reap completion, never wait indefinitely before publishing quarantine, and budget final evidence work honestly. Add the currently missing hanging-stop/slow-reap control under a separately sufficient allowance; retain separate primary and cleanup exits. No demand for a new supervision framework.

### S2-R53-A-03 — the proposed control driver kills pre-existing pattern matches on refusal

**High; blocks06a runner controls.** Driver25 detects pre-existing matches and calls `finish`; `finish`22 always calls `owned_cleanup`, which rescans global names and sends TERM/KILL at14–17—thus the “ABORT: pre-existing pattern matches” path kills processes the current invocation did not create. ([Driver L14–25](../../../../s2-setup-prep/controls-proposed/run-runner-controls-v531.sh))

**Concrete counterexample:** a pre-existing process with argv0 `s2r53-stub-escapee` is detected before K1; it is then selected by `owned_cleanup` and signalled, despite the preflight refusal and no current child launch. The logged empty pre-snapshot in historical v5.3 does not exercise this path. ([Driver L14–25](../../../../s2-setup-prep/controls-proposed/run-runner-controls-v531.sh), [historical pre-snapshot](../../../../s2-runner53/controls/20260922T043943Z/CONTROLS_RESULT.txt))

**Smallest closure:** refusal before ownership acquisition must exit nonzero without cleanup signals; cleanup must use recorded children/identities belonging to this invocation, not merely a reused name. Add a harmless pre-existing decoy control proving it survives refusal.

### S2-R53-A-04 — proposed runner-control driver can report success on failure/incomplete work and exceed06a

**Medium, material; blocks06a as specified.** `finish`22 exits0 after strikes, precondition ABORT and the soft-budget stop; K2/K5/K6 execute the runner without an outer control deadline, and the60-second allocation is only checked between controls at a45-second soft threshold. ([Driver L11,19–25,42,85,93,98](../../../../s2-setup-prep/controls-proposed/run-runner-controls-v531.sh))

**Counterexamples:** a K2 expectation miss calls `gate`→`finish` and exits0 with later controls unrun; a hung K2 guard stub can consume the runner’s120-second step bound before the next45-second check, exceeding the entire60-second06a allowance. ([Driver L21–22,42–53](../../../../s2-setup-prep/controls-proposed/run-runner-controls-v531.sh), [runner L199](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh), [06a contract](../../../../s2-setup-prep/SLOT_REQUEST_06_CONTROLS_AND_PROOF.md))

**Smallest closure:** derive aggregate exit from failed/skipped/incomplete/cleanup status, preserve actual exits, and enforce an outer allocation deadline with reserved owned-cleanup grace. A bounded negative that fails an assertion and one that exhausts the budget must both exit nonzero without starting subsequent controls.

### S2-R53-A-05 — fixture destroy treats unknown status as stopped

**Medium, material before any destroy authorization; not independently a06b blocker because06b never calls destroy.** Fixture82 interprets every nonzero `pg_ctl status` as “not running,” while its process scan hides errors with `|| true`; with an unavailable/failing status tool and no matching scan output, supplying the literal confirmation reaches `rm -rf`. ([Fixture L20,40–41,79–85](../../../../s2-setup-prep/infra/s2-fixture-r53.sh))

**Smallest closure:** distinguish a recognized stopped result from tool/status/inspection failure and refuse deletion on unknown; retain the explicit path confirmation. Add missing-tool/unexpected-status controls before exposing destroy; keeping destroy explicitly excluded is sufficient for the current no-destroy proof scope.

## What is supported, and what remains pending

- **Source applicability:** d5cd contains56fb as an ancestor and has identical S1 `test/db` and migration paths; the predecessor verifier hash remains `2bbce0d7…323e`, and all three package/schema closure files match974. There are165 migration directories; composition removes only the candidate for genuine164-parent replay, checks applied/ledger counts, uses actual release.sh, and invokes the corrected S1 discriminator afterward. ([Independent Git/hash/count record](STATIC_EVIDENCE.json), [composition L136–175](../../../../../worktrees/s2-runner53/test/release/s1s2-composition.sh), [runner L230–245](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))
- **Target guard improvements:** fresh namespace `s2comp-r53`, port54353 and derived DB/confirmation agree in runner/fixture; init refuses existing state, start refuses already-running state, PG children close fd9, and the real harness runs both S1 guard layers before DROP/CREATE. This supports the intended isolated fixture route, not arbitrary direct helper use or independent proof of postmaster ownership. ([Fixture L19–76](../../../../s2-setup-prep/infra/s2-fixture-r53.sh), [runner L192–233](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh), [composition L46–51,138](../../../../../worktrees/s2-runner53/test/release/s1s2-composition.sh))
- **Observed, stub-only:** prior v5.3 K1–K6 logs show30.85s, strike0, K3 TERM ordering, K4 named escape quarantine, K5 cleanup71 and K6 first failure3; no rerun occurred here. These are attributable observations at `fbc8b9af…`, not executions of `fb0d7ce4…` or the reimplemented fixture; fixture stubs do not initialize/start/stop PostgreSQL. ([Historical controls](../../../../s2-runner53/controls/20260922T043943Z/CONTROLS_RESULT.txt), [stub fixture](../../../../s2-setup-prep/controls-proposed/stubs/fixture.sh))
- **Setup applicability, not acceptance:** parent’s added outer wrappers address setup allocation bounds; S30 pins d5cd/lock, ignores npm lifecycle scripts, explicitly requires local Prisma/client and disables auto-install before generation. Its outside-root check compares counts/presence, not content identity, and is skipped after early npm/generate failure; S20’s existing-dist reuse branch checks self-consistency with provenance, not all fixed pins. Require actual grant-mandated raw logs, post-failure inventory where applicable, independent fixed-hash readback and no-survivor/lock observations before accepting setup—do not infer them from a success stamp or this review. ([Grant](../../../../S2_R53_ALLOCATION_AND_REVIEW.md), [S30 L19–56](../../../../s2-setup-prep/infra/setup-30-npm-ci.sh), [S20 L24–28](../../../../s2-setup-prep/infra/setup-20-pg17.sh))
- **Launcher interpretation:** its `wait` can return0 while still RUNNING after the requested polling interval; only the actual exit sentinel and independent no-survivor verification satisfy completion, as the newer grant requires. ([Launcher L35–43](../../../../s2-setup-prep/infra/launch-detached.sh), [grant completion criteria](../../../../S2_R53_ALLOCATION_AND_REVIEW.md))
- **Lifecycle negatives unresolved:** F1–F5 concern fd9/url only; F6–F9 need a separately frozen safe target/cleanup choice because the pinned fresh namespace would be consumed, and “observe in proof” cannot cover the refused branches a successful proof never visits. Neither05 nor this review authorizes those DB/lifecycle controls. ([Preparation report §5–6](../../../../s2-setup-prep/REPORT.md), [06a exclusions](../../../../s2-setup-prep/SLOT_REQUEST_06_CONTROLS_AND_PROOF.md))

## Smallest next slice / unsigned conclusions

Route **execution-only** fixes A01–A04 to the existing S2 owner in an additive frozen successor; preserve originals, d5cd product source and S1 source. Keep A05 as a mandatory pre-destroy closure or explicitly exclude destroy. Independently inspect the successor and its discriminating bounded controls before06b; do not rerun failed DB proof to discover known supervisor defects.

**REAL PROOF AND FINAL ATTESTATION PENDING:** no new installation, PostgreSQL lifecycle,164+1 composition, TRUNCATE discriminator, inherited-membership behavior, final exact-head acceptance, hosted enforcement, serving-role containment, release/customer/native safety is signed. Parent remains grant/disposition owner; no current-peer consensus or majority vote informed this report. ([Required review and nonproof boundary](../../../../S2_R53_ALLOCATION_AND_REVIEW.md))
