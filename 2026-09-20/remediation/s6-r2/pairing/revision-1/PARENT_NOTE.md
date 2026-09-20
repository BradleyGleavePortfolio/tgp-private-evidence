# S6 pairing fixer packet: frozen revision 1

The original report and every file named by its checksum manifest are preserved byte-for-byte. `BUILDER_SHA256SUMS` is the original manifest. Dependencies, Node binaries, baseline source reconstruction and unreferenced export assets are excluded; the two diagnostic JavaScript bundles named by the original manifest are included.

## Evidence boundaries

- Candidate: `eaccaba98bc4400a0341bcd80409ab317bc85856`, tree `4e27b47221e25127118312b6dade5354937d7890`.
- This candidate has focused 427-test, type-check and lint evidence. Full-suite 3,820-test natural-exit evidence binds only to predecessor `60975b51bd617bbfaa091ce76e57d16945298f82`.
- Stubbed exports are diagnostic only. Authentic exports failed in this lane; the independent export remediation packet and subsequent combined-head validation must close that gap.
- Requested builder routing was Claude Fable 5 / High. The report's stronger runtime-model identity wording is not independently verified by the parent.
- The optional-MMKV root cause is refined by the separate export lane: installed Metro supports a require directly inside a try block, but the second unguarded require made the same module required. This note does not alter the original report.
- No independent S6 R2 clearance, product landing, deployment, activation or customer acceptance is claimed by this packet.

Relative `execution/` and worktree references in the frozen report describe the original workspace. Restore candidate source from the included bundle over public mobile main `a5933fd6de5616493de75f0db907098b149b955c`; evidence paths relative to this packet are preserved.
