# S4 R4 audit A — remaining evidence requests

## Current source is not cleared

Source findings S4-R4-A-01 and S4-R4-A-02 are independent of the browser gap. More aggregate passes on the same source cannot remove the observed counterexamples. Parent should route the retained probes to the sole session/worker owner; no heavier audit-owned run is requested. See [checkpoint](CHECKPOINT.md) and [report](REPORT.md).

## Final packet still required

The parent supplied the runner-2 update: exact head `2bcf1563…`, tree `3e23f918…`, clean, package `6fe9a7be…`, positive loader attempt aborted before checks at `Browser.getVersion`, negative control not run. I inspected the underlying receipts and do not classify the failure as environment-only or a product defect without further diagnosis. See [runner exit](../../../s4-r4/logs/slot-run-2.exit.json), [aborted receipt](../../../s4-r4/artifacts/browser-proof-positive.json).

Before any final-head/artifact clearance, provide:

1. Immutable final packet/manifest, preserved failed attempts and source/dirty identity, dependency lock/toolchain/configuration identity, actual child exits, and final artifact/inventory hashes.
2. Either successful exact-package positive loader and paired intended negative control receipts, or the explicit unresolved gap/disposition. A receipt with empty checks is not acceptance. For the negative control, inspect actual syntax exception and no-receiver signature rather than relying solely on `detected` or wrapper exit.
3. Attribution of any required secret/dependency/security checks. Scanner installation is not a scan; the observed `npm run gates` command does not execute the secrets history scan or `npm audit`. Hosted CI/enforcement remains a separate parent gate.
4. For a successor source, discrimination of C1/C2/C3 and unchanged-session controls; the old source should retain its adverse observations, the new source should stop obsolete work without replacement token presentation/use or false auth-loss copy. Preserve existing same-session coalescing, stale-finally isolation, body deadlines and retry-401/current-session cleanup controls. Extend both real worker entrypoints where the same preflight pattern exists.

Parent owns execution scheduling, publication and dual follow-up. Do not rerun heavy checks in each audit lane. If source changes, the affected source/package conclusions become pending until explicitly re-reviewed; unchanged-input evidence may be reused only with an applicability decision.
