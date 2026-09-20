# S6 export repair: frozen revision 1

Original report and every file in `BUILDER_SHA256SUMS` are preserved unchanged. The archived export artifacts are the checksum-listed JavaScript bundles and metadata, not the full asset directories; dependencies, transient caches and unreferenced image/font assets are omitted. This packet is evidence and recoverable source, not an installable native app.

- Head `d7079265ea1263a1af6cd9cd132fc18dcb1793d9`, tree `402a7425862639863b951ffb7da7ed2872ff70f5`, parent `60975b51bd617bbfaa091ce76e57d16945298f82`.
- Requested routing: Claude Fable 5 / High. Runtime model/version wording in the frozen report is not independently verified by the parent.
- Flag-on export was repeated on the committed head. Flags-unset export binds to the precommit tracked source; the report distinguishes this rather than claiming a second committed-head execution.
- Production fallback probes run a serialized module in Node with Metro's loader and mocked platform/storage dependencies. They do not prove full application startup, Hermes execution or native customer import.
- The report's older NEW-2 slow/non-exit shorthand must be read with the pairing packet's newer natural-exit proof: predecessor full Jest completed successfully after a delay.
- Final composition is a separate candidate containing the epoch pairing fix and this export fix. No test or audit clearance transfers automatically.

Restore source from the bundle over public mobile main `a5933fd6de5616493de75f0db907098b149b955c`. No product push, hosted change, flag activation or customer proof is claimed.
