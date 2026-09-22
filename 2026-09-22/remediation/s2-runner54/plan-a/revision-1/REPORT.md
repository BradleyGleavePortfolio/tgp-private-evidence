# S2-V5.4-INDEPENDENT-CLOSURE A — revision 1

**T4; independent nonbuilder source review. HOLD request07 as written; HOLD real proof.** This is the narrow runner/driver successor review, not a product R3 re-audit or a grant. ([Contract](../../../../EXECUTION_REPAIR_WAVE_2.md), [request07](../../../../s2-runner54/CONTROL_REQUEST_07.md))

Requested model: inherited parent; actual runtime model/version/reasoning setting: **unobservable, not asserted**. No current r54 peer B material was read; only expressly permitted frozen r53 A/B reports. No candidate execution, syntax check, probe, test, control, installation, process signal, DB or network activity occurred in this review.

## Identity and evidence separation

| Bound input | Identity / disposition |
|---|---|
| Product | HEAD `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`; tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`; base `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`; tracked/untracked Git status clean. ([Static evidence](STATIC_EVIDENCE.json), [contract](../../../../EXECUTION_REPAIR_WAVE_2.md)) |
| v5.4 runner | `3f404479476c5b6a662c946268fd8ed59e3d69c867176431d921aca743604327`. ([14-file manifest verification](STATIC_EVIDENCE.json)) |
| v54 driver | `6638ec06fd517a390546cfd28ae3d2a23398e56a5ee6e98c27872e348889c6a4`. ([14-file manifest verification](STATIC_EVIDENCE.json)) |
| v5.4 outer manifest | `f38d9216ff03ff7aba8cfcc2d23a0921309af280abe4956b2170f0e336b411a8`, all14 entries match. ([Static evidence](STATIC_EVIDENCE.json)) |
| Unchanged fixture | `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881`; destroy remains forbidden, A05 not closed. ([Static evidence](STATIC_EVIDENCE.json), [fixture L79–85](../../../../s2-setup-prep/infra/s2-fixture-r53.sh)) |
| Setup05 | Existing S30 receipt records exit0, clean d5cd and installed Prisma6.19.3 CLI `c2a77456…e1a0`; reuse the installed inputs, not a new install or proof pass. ([Setup receipt](../../../../s2-setup-prep/runs/setup-30-grant05.log), [install stamp](../../../../s2-setup-prep/grant05/install-stamp.actual.txt)) |
| Stub evidence | Historical v5.3 K1–K6 only; **v5.4 K1–K10/N1–N3 NOT RUN**. No result transfer across runner bytes. ([Historical observations](../../../../s2-runner53/controls/20260922T043943Z/CONTROLS_RESULT.txt), [prepared map](../../../../s2-runner54/FINDINGS_MAP.md)) |

## Prior stable findings: exact closure, not a blanket rejection

| Stable finding | Current source disposition |
|---|---|
| **S2-R53-A-01 / S2-R53B-01** | **Partial closure.** For a successfully captured owned group, retaining it, checking post-exit membership and halting it independently of leader liveness correct the concrete inner124/leader-first mechanism. Fast-start registration and actual detached client paths remain below; no dynamic closure signed. ([Runner L94–119,138–161](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh)) |
| **S2-R53-A-02** | **Partial closure / still open.** No unconditional wait on a PID still reported alive; anomaly polling and stop/status clipping improve the source. They do not enforce the advertised single50s total including receipt work; see §3. ([Runner L98–113,141–147,165–201](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh)) |
| **S2-R53-A-03** | **Original pre-existing-match refusal path source-closed; N1 pending.** `abort` bypasses cleanup/signals and returns2. This does **not** close the distinct shared-group adoption defect in §1. ([Driver L49,66–70,175–183](../../../../s2-runner54/controls-proposed/run-controls-v54.sh)) |
| **S2-R53-A-04** | **Partial closure / still open.** Assertion/incomplete/budget paths now return1/3 and stop before the next control; refusal returns2. Actual aggregate deadline and cleanup-to-result gating remain absent; see §4. ([Driver L40–62,179–198](../../../../s2-runner54/controls-proposed/run-controls-v54.sh)) |
| **S2-R53-A-05** | **Unchanged pre-destroy hold only.** No destroy grant or requested enlargement of this slice. ([Contract](../../../../EXECUTION_REPAIR_WAVE_2.md), [prior A finding](../../../s2-r53/a/revision-1/FINDINGS.json)) |

Pins, real40 bound1500, fd9 closure except init, first-versus-cleanup selection, 164+1 invocation and no-destroy scope remain in the focused diff; this preserves applicability, not execution acceptance. ([Runner diff](../../../../s2-runner54/diffs/runner-v5.3.1-to-v5.4.diff), [runner L207–289](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

## 1. S2-R54-A-01 — HIGH: K1 adopts the caller's group as owned

K1 launches with **foreground timeout, no new session/group**; its nested foreground harness logs its inherited PGID, and `record_from_run` promotes that PGID to an ownership record. ([Driver L35,75–83](../../../../s2-runner54/controls-proposed/run-controls-v54.sh), [K1 L4–9](../../../../s2-runner54/controls-proposed/k1-predecessor-mechanism.sh), [harness L6–8](../../../../s2-runner54/controls-proposed/stubs/harness.sh))

`owned_live` expands the whole group and excludes only the current driver's PID plus the narrow **pattern** pre-snapshot, not unrelated caller/launcher/sibling PIDs; the immediately following cleanup sends TERM/KILL to those expanded PIDs. A recorded group number is not evidence that this invocation created an exclusive group. ([Driver L26–43,83](../../../../s2-runner54/controls-proposed/run-controls-v54.sh))

**Consequence:** set `k` can signal an unrelated process sharing its launch group; `neg` reaches the same path in N2 and can signal its own outer driver. N1's decoy-refusal fix does not protect these processes, which need not match the pre-snapshot pattern. This is a source counterexample schedule, not an observed kill. ([Driver L66–83,175–190](../../../../s2-runner54/controls-proposed/run-controls-v54.sh))

**Smallest closure:** put the *K1 control enclosure* in a newly created, identity-confirmed group while keeping the predecessor's internal foreground mechanism unchanged; only adopt that exclusive group, never a group inferred from an arbitrary child log. Retain an unrelated caller-group decoy through cleanup in a later authorized negative. **Blocks `k` and `neg`.**

## 2. S2-R54-A-02 — HIGH: hanging-stop control creates an unowned child

The new stop stub runs `sleep60`, but does not publish its PID; runner stop/status use foreground timeout outside `run_step`, acquire no owned group, and are absent from `OWNED_PGIDS`. ([Fixture stub L7](../../../../s2-runner54/controls-proposed/stubs/fixture.sh), [runner L176–187](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

K10 asserts `fixture_stop=124 survivors=none` and20–27s, yet the final runner scan is only names/listeners and the driver records only step groups, harness groups and explicitly printed spawned PIDs—not this plain stop sleeper. A direct-child timeout therefore does not establish that the stop's descendant is gone; exact124 versus escalation behavior on the installed timeout/signal-disposition combination is **unobserved**. ([Driver L30–43,165–172](../../../../s2-runner54/controls-proposed/run-controls-v54.sh), [runner L166,181–188](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

**Smallest closure:** give stop/status a bounded, explicitly owned client group and verify its empty census before handoff; print and independently check the hanging stub child's identity. Never signal the caller group. Preserve primary0 versus cleanup failure and account the reap inside the same cleanup deadline. **Blocks `new2`; also blocks real cleanup's no-survivor claim.** The real fixture's pg_ctl15s bound helps normal operation but does not supply the missing wrapper ownership guarantee. ([Fixture L20,77–78](../../../../s2-setup-prep/infra/s2-fixture-r53.sh))

## 3. S2-R53-A-02 continued, plus S2-R54-A-03 — MEDIUM: total deadline and immutable receipts

**Deadline remains open:** post-exit halt at158 runs before `CLEANUP_T0/DEADLINE` are initialized at167–168, so this reap is outside the alleged single50s interval; final `deadline_check` and `FINAL` selection precede unbounded manifest work, and line201 exits the already-selected result without checking the post-hash elapsed time or hash exit. `SCAN_HASH_ALLOW=3` reserves arithmetic room; it does not bound the operation. ([Runner L87–98,153–170,190–201](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

**New deterministic receipt defect, S2-R54-A-03:** line198 hashes both `exit-codes.txt` and `stamp.txt`; line200 then appends to **both**. Consequently their manifest entries describe pre-append bytes, not the delivered files. Calling the appended line “not covered” cannot exempt it from a whole-file hash. ([Runner L195–200](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

**Smallest closure:** begin one deadline before the first exceptional reap; bound evidence generation within its remaining allowance and gate cleanup/final truth after that work. Freeze hashed files before hashing; put later timing/finalization in a distinct, explicitly excluded receipt with an additive outer manifest, or equivalent finite non-self-hashing ordering. A missing/failed/over-budget receipt must not leave `cleanup_exit=0`. **Blocks the claimed50s guarantee and authoritative success receipts, in stub and real modes.**

K10 exercises nominal stop timeout, not deadline exhaustion through the final receipt phase; its20–27s predicate cannot close this issue even if it later passes. ([Driver L165–172](../../../../s2-runner54/controls-proposed/run-controls-v54.sh))

## 4. S2-R53-A-04 continued — MEDIUM: request07 is not four hard60s invocations

The request invokes each driver directly, with no aggregate timeout; driver `need/clip` gates only before controls and clips the TERM bound without its kill grace, then does unbounded assertions/final bookkeeping. For example K2 declares15 but permits15+5; K8 declares8 but permits8+5; N1–N3 invoke child drivers synchronously without a wrapper bound. ([Request07](../../../../s2-runner54/CONTROL_REQUEST_07.md), [driver L50–62,85,150,179,186,193](../../../../s2-runner54/controls-proposed/run-controls-v54.sh))

`owned_cleanup` merely prints its post-cleanup survivors; `finish` does not use that result or a held lane lock to reject exit0. Thus a completed assertion list is still not a safe handoff predicate. ([Driver L40–48](../../../../s2-runner54/controls-proposed/run-controls-v54.sh))

**Smallest closure:** enforce one aggregate allocation deadline including kill grace, nested invocations and cleanup/receipt reserve; preserve recorded identities during interruption. Make remaining owned survivors/cleanup failure/nonfree required lock status a nonzero terminal result that prevents subsequent sets. Do not add only an outer foreground timeout that can strand the driver's descendants. **Blocks request07's `k/new1/new2/neg` hard-budget contract as written.**

## 5. S2-R53-A-01 continued — MEDIUM: ownership acquisition still has a gap

If a fast leader exits before the `ps` sample, `STEP_PGID` can be empty; the anomaly refusal requires the PID to be alive, so execution appends an empty group, waits, then treats an empty failed `pgrep -g` lookup as no members. A signal between launch and group registration likewise reaches a halt routine scanning only the accumulated list. These are the very fast-leader/interruption boundaries under review, not a hostile-process hypothesis. ([Runner L94–105,121–149,153–161](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

The anomaly branch has a second ownership violation: if the nonisolated PID remains alive, line146 records its observed **nonexclusive** PGID, which cleanup subsequently group-signals. ([Runner L141–147,102–108](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

**Smallest closure:** retain an invocation-created exclusive identity through startup as well as completion; unknown acquisition must refuse/quarantine, never certify emptiness or adopt the caller's group. Publish the group identity before the client can escape the startup accounting, and handle interruption during acquisition with owned PID-only fallback until exclusive group identity is confirmed. Add a later bounded immediate-exit/startup-interruption control. **Full A01/B01 closure remains pending.**

## 6. S2-R54-A-04 — HIGH for real proof: K9 is reachable through Prisma's optional checkpoint worker

**Independent reachability result:** K9 is not merely an invented hostile `sleep` concern. The actual graph is runner→composition/release/discriminator→local Prisma CLI for `migrate`/`db execute`; that CLI command dispatcher invokes `V1e`, which calls checkpoint `check` unless `CHECKPOINT_DISABLE` is set. ([Composition L147,230](../../../../../worktrees/s2-runner53/test/release/s1s2-composition.sh), [release L210,249,258,290](../../../../../worktrees/s2-runner53/scripts/release.sh), [discriminator L58–69](../../../../../worktrees/s2-runner53/test/db/s1-r4-truncate-discriminator.sh), [CLI L4062,4084 / exact excerpts](CLIENT_GRAPH_EXCERPTS.json))

Installed Prisma6.19.3 checkpoint code defaults `unref=true`, forks `build/child` with **`detached:true`**, then unrefs/disconnects; the child performs optional telemetry/cache work under its own timeout rather than being joined by the client step. Runner/harness/release/discriminator do not pin `CHECKPOINT_DISABLE=1`. ([CLI L49 / exact excerpts](CLIENT_GRAPH_EXCERPTS.json), [worker L82814–82905](../../../../../worktrees/s2-runner53/node_modules/prisma/build/child.js), [runner L210,274–284](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

This is an actual reachable group-detaching client side branch, including near a short `db execute` or interruption; its completion, surviving PID and argv were **not observed** here. The anchored `^node …prisma/build/index.js` scan is not ownership of the forked `build/child` worker, whose launch executable/argv are not pinned to that literal; even a coincidental pattern match only diagnoses/quarantines, not owns/reaps the detached child. ([CLI fork excerpt](CLIENT_GRAPH_EXCERPTS.json), [runner L74,94–118](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh))

**Smallest necessary boundary:** pin and stamp `CHECKPOINT_DISABLE=1` before all actual Prisma clients, preserving it through npx/subshell invocation, and bind that scoped no-detach claim to the inspected dependency bytes. This removes this optional side branch without product edits, process-name kills, namespaces, or a general hostile-child supervisor. The installed npm spawn path inherits environment; the inspected Prisma schema-engine spawn does not request detach, and the generated client uses the library engine. ([npm spawn environment L19–35 and CLI schema-engine excerpts](CLIENT_GRAPH_EXCERPTS.json), [generated client L3341](../../../../../worktrees/s2-runner53/node_modules/.prisma/client/index.js))

PostgreSQL's intentionally started server is a separate explicit fixture lifecycle, not a reason to namespace client commands or run initdb as a remapped root. I do **not** recommend the proposed `unshare` design on this evidence; the disclosed capability probe is outside authorized preparation and supplies no acceptance. ([Fixture L69–78](../../../../s2-setup-prep/infra/s2-fixture-r53.sh), [builder disclosure](../../../../s2-runner54/FINDINGS_MAP.md), [contract](../../../../EXECUTION_REPAIR_WAVE_2.md))

**Blocks real proof until the narrow optional-detach path is excluded or genuinely owned; it does not independently block DB-free stub controls.** K9 must remain labeled a boundary observation rather than an ownership pass; checkpoint exclusion would not turn arbitrary future detached commands into covered clients. ([K9 L157–162](../../../../s2-runner54/controls-proposed/run-controls-v54.sh))

## Grantability, recovery and explicit pending attestation

| Action | Frozen A disposition |
|---|---|
| request07 `k` | **HOLD**: shared-group cleanup; aggregate bound/final cleanup truth; startup ownership. |
| request07 `new1` | **HOLD as written**: aggregate bound/final cleanup truth and startup ownership; no separate K1-specific objection to this set. |
| request07 `new2` | **HOLD**: unowned stop child; bound/receipt guarantees. |
| request07 `neg` | **HOLD**: N2 reaches shared-group K1; nested aggregate bounds; N1 refusal change alone is source-closed. |
| Real composition/discriminator | **HOLD/PENDING**: no successor controls observed; source residuals above; actual-client optional detach exclusion needed. |
| Setup05 | Preserve/reuse existing setup; no reinstall or revalidation execution requested by this review. |
| Fixture destroy | **FORBIDDEN**; stable A05 remains. |

These dispositions follow the line-bound findings above, not the hypothetical outcome of any unrun control. ([Runner](../../../../s2-runner54/run-composition-r54-v5.4-when-granted.sh), [driver](../../../../s2-runner54/controls-proposed/run-controls-v54.sh), [contract](../../../../EXECUTION_REPAIR_WAVE_2.md))

**Recovery:** freeze this packet; make only additive execution-layer successors for the smallest closures; rehash/review the delta, then obtain a distinct bounded control grant. Do not repair or rerun old packets, erase fixtures, or use manual post-timeout process-name inspection as a waiver.

**Dynamic attestation remains unsigned:** real fresh PG17 fixture lifecycle, exact real command/target/first-cleanup exits, composition164+1 and named predicates, actual S1 discriminator, final no-owned-survivor/lock handoff evidence and final S1/S2 composed-candidate independent attestations. Stub pass, setup pass, source review and capability availability prove none of those; no hosted/customer/native release or runtime model identity is attested. ([Prior pending proof](../../../s2-r53/a/revision-1/ATTESTATION.json), [current nonproof contract](../../../../EXECUTION_REPAIR_WAVE_2.md))
