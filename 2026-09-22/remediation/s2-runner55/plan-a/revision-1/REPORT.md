# S2-V5.5-INDEPENDENT-CLOSURE A — frozen revision 1

**T4 independent nonbuilder review. HOLD control08 as written; HOLD proof09.** The first sufficient blocker is deterministic: runner line103 clears the identity directory initialized at94, redirecting identity removal/writes to filesystem-root paths instead of the output directory. ([Runner L94,103,162–164,202–203](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

Scope is the actual v5.4→v5.5 execution delta and its control/proof requests, not a product re-audit. ([Review contract](../../../../EXECUTION_REPAIR_WAVE_2.md), [control08](../../../../s2-runner55/CONTROL_REQUEST_08.md), [proof09](../../../../s2-runner55/PROOF_REQUEST_09.md))

No candidate execution, tests, probes, syntax checks, process/lock actions, installation, DB, network, source edits or current r55 peer B access. Both expressly permitted prior r54 reports were read. Requested model: inherited parent; actual runtime model/version/reasoning: unobservable, not asserted.

## Exact identity

| Input | Verified identity |
|---|---|
| Product R3 | `d5cd9b8b0690a2e6f2c3fd8ff320a1ceb13d650c`, tree `c0ab87d4dc584b2a7ccad53db16fa551b93fe359`, clean tracked/untracked status. ([Static evidence](STATIC_EVIDENCE.json)) |
| Source base | `c23b9d9f3fcc106b92c061ceb7d04d7ec53038d7`. ([Contract](../../../../EXECUTION_REPAIR_WAVE_2.md)) |
| Runner | `c3a4d2a9a234dda141122a44d46a3902a8575001a26ffcadc2029080a768de49`. ([Static evidence](STATIC_EVIDENCE.json)) |
| Driver | `a5a2d73f8b0138362ef391c4cbd58ea846673be1846bfaf92561bde2a538312c`. ([Static evidence](STATIC_EVIDENCE.json)) |
| Outer input manifest | `0d7332992da568bb8855a9d19a540e2389cd9bd345ec914639cf295a072788a4`, 16/16 match. ([Static evidence](STATIC_EVIDENCE.json)) |
| Unchanged fixture | `9fcc3696a48627b4ed10544cc6c8911e9f13d95fc7acf7ff324770363c24b881`. ([Static evidence](STATIC_EVIDENCE.json)) |
| Installed Prisma CLI | `c2a77456b70e8ba1e640e122824ed694433828a7c0d76ff3db7fc376b4b0e1a0`, same bytes previously analyzed. ([Static evidence](STATIC_EVIDENCE.json), [prior exact excerpts](../../../s2-r54/a/revision-1/CLIENT_GRAPH_EXCERPTS.json)) |

## What is actually source-closed

| Prior finding / claim | Narrow disposition |
|---|---|
| R54-A-04 / R54B-01 checkpoint side branch | **Environment correction source-closed for the inspected bytes:** export1 precedes all clients; both env-i refusals explicitly carry1; unchanged shell/npx consumers preserve it. No namespace framework needed. Hash verification is present but occurs after the first CLI execution; F06 below. ([Runner L68,75,292–299,315–319](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [prior client inheritance excerpts](../../../s2-r54/a/revision-1/CLIENT_GRAPH_EXCERPTS.json), [unchanged consumer hashes](STATIC_EVIDENCE.json)) |
| R54-A-01 K1 caller-group adoption | **Normal acquisition branch source-corrected:** K1 now has an exclusive self-publishing enclosure; arbitrary harness-PGID log adoption removed; own/parent groups excluded. No dynamic N4 attestation; acquisition/watchdog residuals below. ([Driver L43–61,104–105](../../../../s2-runner55/controls-proposed/run-controls-v55.sh)) |
| R54-A-02 stop descendant ownership | **Partial:** stop/status get new groups, group census and reaping; hanging sleeper60 remains independently recorded. Identity initialization/failure paths prevent full closure. ([Runner L198–218](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [fixture stub L7–8](../../../../s2-runner55/controls-proposed/stubs/fixture.sh)) |
| R53-A-02 deadline anchor | **Anchor source-closed:** first-wins `deadline_start` now precedes halt, anomaly, quiescence-failure reap and signal cleanup. Whole-operation deadline is not closed; F03/F05. ([Runner L104,121,147,171,189,224](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh)) |
| R54-A-03 / R54B-03 post-hash mutation | **Original deterministic mutation source-closed:** stamp/exit files are no longer appended after inner hashing; separate receipt/outer manifest ordering is acyclic. Publication success/deadline truth remains open in F05. ([Runner L254–266](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh)) |
| R54B-02 retired groups | **Partial:** normal empty steps and normally empty stop/status groups retire; driver drops empty group records after cleanup. Its watchdog independently reloads historical group files and plain PID records are never retired; F03. ([Runner L109,194,216](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [driver L50–51,61,98](../../../../s2-runner55/controls-proposed/run-controls-v55.sh)) |
| R53-A-03 refusal; A04 handoff result | **Original refusal closure retained; new positive result gate source-corrected:** precondition refusal sends no workload signals; survivors/new matches/nonfree private lock force4 at finish. No N6 negative executed, and watchdog-owned work is omitted from the census. ([Driver L67–75,93–98](../../../../s2-runner55/controls-proposed/run-controls-v55.sh)) |
| Product/fixture/no-destroy boundary | Existing source/script/fixture pins and real1500s composition/164+1 invocation preserved; R53-A-05 remains a separate pre-destroy hold. ([Runner diff](../../../../s2-runner55/diffs/runner-v5.4-to-v5.5.diff), [proof09](../../../../s2-runner55/PROOF_REQUEST_09.md)) |

## Material findings and smallest closures

### S2-R55-A-01 — HIGH — identity directory is cleared before first use

Line94 sets `IDDIR="$OUT/.pgid"` and creates it; line103 resets `IDDIR=` with no later assignment. Thus line162 constructs `/10-guard-spec.pgid` for the first step and202 constructs root-level cleanup identities, with `rm -f` and writes outside the declared lane. This path expansion is deterministic; root permissions and actual execution outcome were not probed. ([Runner L94,103,162–164,202–203](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

The child shell does not gate `exec timeout` on a successful identity write, so inability to write the root path still permits the client to run before the parent detects unknown acquisition and refuses. ([Runner L163–179,203–217](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

**Smallest closure:** remove the later reset; verify the nonempty identity directory is exactly the invocation's output subdirectory before any remove/write; make publication failure stop before client exec. No root-file cleanup is authorized. **Blocks control08 and proof09 outright.**

### S2-R55-A-02 — HIGH — unknown/startup acquisition is not consistently fail-closed

Even after correcting F01, the child publishes then immediately execs; interruption before the parent appends the group at181 invokes PID-only TERM without consuming the already-published identity. A foreground timeout/client may already have descendants outside the name pattern, leaving the same startup interruption accounting gap as the prior A01 continuation. There is also an interval between background launch and assignment of `STEP_PID`. ([Runner L122–142,144–153,163–181](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

Cleanup clients and driver enclosures handle missing publication less strictly than `run_step`: they merely log, wait, and can return rc0. In `owned_cleanup_cmd`, the unknown-PID check follows `wait`, so a completed unknown leader with surviving unnamed descendants does not set a failure; the driver similarly does not set a strike/nonzero on unconfirmed enclosure identity. ([Runner L203–218](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [driver L54–58](../../../../s2-runner55/controls-proposed/run-controls-v55.sh))

**Smallest closure:** use the same checked, invocation-exclusive startup contract for step/cleanup/enclosure paths: publication must succeed before work; interruption resolves the current published identity before cleanup, or keeps uncertainty as quarantine/nonzero rather than “empty.” Do not let the client run before its identity is recoverably registered/acknowledged, and do not silently accept a dead unconfirmed leader. PID-only fallback must remain bounded without adopting caller groups. **Prior R53-A-01 and R54-A-02 remain partially open; N5 is necessary.**

### S2-R55-A-03 — HIGH — watchdog bypasses ownership retirement and is not a total deadline

The watchdog selects the **newest historical `.pgid` file**, not a live, identity-confirmed active registry entry. Files survive pruning; a completed/retired group's numeric ID can therefore be reloaded and signalled after reuse. This bypasses the exact retirement correction requested for R54B-02, and the watchdog does not apply the enclosure's full identity/parent-group validation. ([Driver L50–58,98](../../../../s2-runner55/controls-proposed/run-controls-v55.sh))

The watchdog is a background shell waiting on a separate `sleep`; finish/abort signal and wait only that shell, with neither the sleeper's PID nor an exclusive watchdog group in the census. Terminating the shell can leave the sleeper alive outside the supposedly complete handoff. Separately, `prune_groups` retains every plain PID forever, including a decoy already killed by N1 cleanup, leaving another stale-number signal authority through later controls. These are source consequences, not observed survivors or foreign signals. ([Driver L42,50–51,61,68,75,98,215–234](../../../../s2-runner55/controls-proposed/run-controls-v55.sh))

The watchdog sends one TERM to an enclosure but never cancels/escalates the **driver** or its publication work; finish cancels it before the final scans/hash, and elapsed classification occurs before unbounded manifest generation. Hence the advertised90/60s hard totals still are not implemented, despite improved per-call grace clipping. ([Driver L67–80,97–98](../../../../s2-runner55/controls-proposed/run-controls-v55.sh), [control08](../../../../s2-runner55/CONTROL_REQUEST_08.md))

**Smallest closure:** keep exactly one current validated enclosure authority and clear it at retirement; do not use historical files as kill targets. Own/reap the watchdog sleeper too, retire dead plain-PID records, and implement bounded driver cancellation/escalation plus reserved owned cleanup/publication. Missing/unsafe handoff stays nonzero. **Blocks control08; R53-A-04/R54B-02 remain open.** No global process-name kills or general supervision framework is requested.

### S2-R55-A-04 — MEDIUM — two control predicates cannot pass the intended bytes

K2 still requires `REAP ok … (recorded groups [digits]`, while the sole runner REAP-ok message is now `(owned groups […] retired […])`; the ordinary successful path retires all step groups. This is a deterministic stale checker, independent of F01. ([Driver L119](../../../../s2-runner55/controls-proposed/run-controls-v55.sh), [runner L141,194](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

`run_runner` unconditionally requires `RECEIPT.txt` for the frozen v5.3.1 predecessor too; K7pre/K8pre call it, but that predecessor writes only the old stamp/exit/manifest format. `new1` therefore strikes on its first predecessor run even if the counterexample is reproduced correctly, and stops before K7. ([Driver L85–89,163–170,180](../../../../s2-runner55/controls-proposed/run-controls-v55.sh), [predecessor L153–158](../../../../s2-setup-prep/run-composition-r53-v5.3.1-when-granted.sh))

**Smallest closure:** assert the new retired/active ownership predicate for v5.5; apply the receipt requirement only to successors that implement it and independently preserve/check predecessor format. Do not weaken the tested safety property or change frozen predecessor bytes. **Blocks `k` and `new1` as valid discriminators.**

The final37-file verification command is also relative-path-sensitive: control08 leaves cwd at `s2-runner55/controls-proposed`, but the supplied predecessor manifest entries are relative to `s2-setup-prep`. Run the verification from that manifest's own directory in the amended request. ([Control08](../../../../s2-runner55/CONTROL_REQUEST_08.md), [predecessor manifest](../../../../s2-setup-prep/SHA256SUMS.outer))

### S2-R55-A-05 — MEDIUM — receipt/outer-manifest failure can still exit0

The new layout fixes the old post-hash append, but line263's receipt write is not checked and line264 explicitly ignores outer-manifest failure. Both occur after final selection and the last deadline check, so an unsuccessful receipt/outer-manifest write can leave a0 process result. The reported total also excludes this final work. ([Runner L259–266](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

The inner timeout wraps only `xargs`, not the `find/sort` pipeline or spawned hash children; it has no kill-after escalation, and `hb` is raised to2 even when no deadline remains. This is not the promised bound on the full evidence phase, nor a census of all helper descendants. ([Runner L257–258](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh))

**Smallest closure:** bounded ownership of the complete evidence operation, check every publication status, reserve final failure reporting, and classify the actual exit after publication/deadline outcomes; retain the acyclic manifest layout. A missing/failed final receipt must never correspond to accepted0, even if its own failure prevents writing another receipt. **R53-A-02 remains open; authoritative proof09/positive-control receipt acceptance held.**

### S2-R55-A-06 — MEDIUM — client-byte refusal happens after CLI execution

The new exact CLI hash check is at298, but the real-mode version stamp already executes that CLI at292. A mismatch is therefore refused only **after** executing unbound client bytes; this is narrower than the new fail-before-use pin claim. Current installed bytes match; no mismatch or changed dependency was executed here. ([Runner L290–299](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [installed hash](STATIC_EVIDENCE.json))

**Smallest closure:** move existence/hash checks before the first CLI invocation; keep the environment export and existing dependency closure. **Proof09 precondition-order hold only; no independent stub-control blocker.**

## Proposed N4/N5/N6: necessary gaps, not executed results

| Proposed control | Assessment / minimal discriminator |
|---|---|
| N4 caller-group decoy | **Necessary before safety closure.** N1 tests refusal before work, not an unrelated caller-group process surviving K1/enclosure cleanup. Keep a harmless unowned caller-group decoy alive through normal and exceptional cleanup; record exclusive identity and the untouched decoy. ([Driver L104–112,213–221](../../../../s2-runner55/controls-proposed/run-controls-v55.sh), [map](../../../../s2-runner55/FINDINGS_MAP.md)) |
| N5 startup interruption | **Necessary, material source residual F02.** Cover fast exit, publication failure and interruption before/after publication but before parent adoption; reject unknown acquisition and verify no owned descendants remain/no caller group signalled. A narrowly declared synchronization seam or controlled publication failure is preferable to a sleep that probabilistically misses the race; do not rewrite frozen bytes and call them the target. ([Runner L163–181,203–218](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [map](../../../../s2-runner55/FINDINGS_MAP.md)) |
| N6 failed handoff | **Necessary before accepting the new gate.** Inject a private-lane lock held at the final gate by a separately owned controller, or a bounded known-owned survivor condition; require4, no next set, preserved evidence and eventual controller-owned cleanup. No need for an unkillable hostile child or canonical lock. Include watchdog termination/no-sleeper and active-versus-retired identity checks in the corrected control scope. ([Driver L67–74,98](../../../../s2-runner55/controls-proposed/run-controls-v55.sh), [map](../../../../s2-runner55/FINDINGS_MAP.md)) |

These omissions are **evidence gaps separate from source defects**; adding them is not a reason to execute the known-broken frozen08 first. They should be prepared/reviewed and granted with the minimal successor, not treated as an already-passed prerequisite. ([Control08 noncoverage](../../../../s2-runner55/CONTROL_REQUEST_08.md))

## Final dispositions and nonproof

- **Control08: HOLD all sets as written.** F01/F02/F03 prevent a safe ownership/deadline recommendation; F04 additionally prevents valid `k/new1` completion; F05 prevents authoritative receipt acceptance. ([Runner](../../../../s2-runner55/run-composition-r55-v5.5-when-granted.sh), [driver](../../../../s2-runner55/controls-proposed/run-controls-v55.sh))
- **Proof09: HOLD independently.** The prospective command/target/setup reuse/no-destroy scope remains applicable, but source residuals and necessary exact-successor controls are unresolved; F06 is real-only. ([Proof09](../../../../s2-runner55/PROOF_REQUEST_09.md))
- **Checkpoint correction is a real source improvement, not historical egress evidence.** No historical network receipt was observed; no retroactive incident claim or K9 ownership pass is made. ([Contract qualification](../../../../EXECUTION_REPAIR_WAVE_2.md), [prior exact client excerpts](../../../s2-r54/a/revision-1/CLIENT_GRAPH_EXCERPTS.json))
- **All v5.5 controls and real dynamic attestations remain NOTRUN/PENDING.** Historical v5.3 stub results, setup05 and source review do not prove real fixture lifecycle, composition/discriminator, actual no-survivor/lock handoff, final S1/S2 dual acceptance, hosted/customer/native or release safety. ([Prepared map](../../../../s2-runner55/FINDINGS_MAP.md), [proof09](../../../../s2-runner55/PROOF_REQUEST_09.md))

Recovery: preserve every prior packet and this frozen report; additive execution-only smallest corrections, new hashes and narrow independent closure before separate control permission. No source/fixture rebuild, reinstall, root-path remediation, DB/destroy, blind retry or broad process management redesign is authorized here.
