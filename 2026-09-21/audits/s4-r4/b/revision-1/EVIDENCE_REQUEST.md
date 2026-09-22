# S4 R4 audit B — evidence request (revision 1, 2026-09-22T00:19Z)

Bound to HEAD `2bcf1563d85bc2109e99805e4ce1b06fce4dcdb3`, tree `3e23f91824689d1f179a116af948eae0ed5ae170`, zip sha256 `6fe9a7be4be782e2bb28b77f1f6ef55a89db2c4ab8f3ff8bb966bc9dfed82858`.

Requested from the parent as ONE attributable bundle (do not duplicate heavy runs for me):

1. Loader proof on the shipped bytes
   - Positive: `node scripts/browser-load-proof.mjs --zip <6fe9a7be zip> --out ... --chrome <same binary>` → all checks PASS, `exceptions: []`, Chrome product/version present in receipt.
   - Negative control: same with `--negative-control` → `detected: true`, `noReceiver: true`, `syntaxExceptionSeen: true`, `unrelatedFailures: []`.
   - Discriminator for the runner-2 abort (`CDP timeout: Browser.getVersion`, no stderr): in the SAME slot, run the positive harness against the base zip `90883cad44cd78b60a18ab232aba0b965ae40ab6edb99054138cac61c0f6a9a7` (R3 packet) back to back with the candidate; record `chrome --version`, Chrome stderr, exit code and host load (`uptime`) immediately before each launch.
     - base fails too → environment; document and retry once the host is idle.
     - base passes, candidate aborts → product investigation required before any attestation.
2. Final runner exit JSON with `failed_steps: 0`, `head_at_end` / `tree_at_end` unchanged, `dirty_at_end: ""`.
3. Final packet SHA256SUMS covering: bundle, zip, inventory, stage logs 01–11 and their meta JSON, browser receipts.

Already evaluated from runner-2 (no repeat needed): npm ci, prettier, focused (10 files), full vitest (64 files / 1714 passed), gates, stale-caller probe reject mode (candidate 0 / base 1), package, checkpoint bundle verify + SHA256SUMS.

Optional (not blocking, owner backlog): add the pending-admission schedule (probe P-C in `probes/pending-admission-replacement-probe.mjs`) as a spec case and reword the `expectReplacementIntact` invariant (S4-R4B-01).
