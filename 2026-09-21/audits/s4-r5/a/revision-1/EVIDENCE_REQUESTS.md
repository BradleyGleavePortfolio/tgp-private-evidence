# S4 R5 audit A — scoped follow-up requests

## Source disposition first

1. Route **S4-R5-A-01** to the parent and canonical worker/session owner. Preserve the original R4 counterexample closures, but carry owner identity through final preflight failure reporting, with both Start entrypoints and legitimate-current-failure controls. The remaining observation is current-B authentication-required reporting, **not** post-acknowledgement reproduction or credential misuse. ([frozen report](REPORT.md), [exact observations](preflight-notification-boundary-results.json))
2. Any successor needs an exact clean head/tree plus changed-input applicability and independent follow-up; do not modify the frozen R4 or this R5 audit report.

## One shared attributable validation packet, when parent authorizes it

- Stamp command, source head/tree/dirty state, dependency/lock provenance, tool versions, start/end/duration, actual exits, resource holder and completion sentinel for the applicable focused suite, full suite, gates and actual policy-configured secret scan. A tool installation or staged-only scan is not a whole-history scan.
- Supply the fresh ZIP itself, SHA256, inventory, build receipts and mapping to the exact shipping source; abort dependent stages on package failure rather than inspecting a stale artifact.
- Supply positive browser proof against that ZIP, including successful worker startup and session-state round trip, actual checked assertions/exceptions, and pairing-state observations within the requested loader scope.
- Supply a **proper deliberately failing negative**, not an assumption that a base-good ZIP must fail. Preserve the mutation and original/mutated hashes; distinguish the intended classic-import/receiver failure from unrelated startup or CDP failure, and inspect the recorded exception. The current request's alternative needs correction. ([request line 23](../../../s4-r5/VALIDATION_REQUEST_1.md), [harness predicates](../../../../worktrees/s4-r5/scripts/browser-load-proof.mjs))
- Preserve failed/aborted attempts. R4's empty-check `Browser.getVersion` timeout is unclassified as to product versus environment here; a Chrome-alone diagnostic is not positive extension-runtime proof. ([R4 audit](../../s4-r4/a/REPORT.md))

This auditor requests no duplicate heavy run and will not acquire the canonical lock. Later evidence applicability belongs in a separately dated addendum; publication and integration remain with the parent.
