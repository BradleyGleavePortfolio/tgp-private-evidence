# v3/ manifest chronology — evidence correction (additive; nothing frozen was modified)

The file name `v3/MANIFEST.v3.sha256` has had two different contents. I did not keep the first index under a distinct name when I expanded it; this note and the additive copy below correct that. The old V3 index is **not** unchanged — it was overwritten in place at 05:20:44Z and is now restored only as a separately named copy.

| When (UTC, 2026-09-22) | Event | `MANIFEST.v3.sha256` content | SHA256 of the index file |
|---|---|---|---|
| ~05:08 | V3 instrument fix prepared (`diag/s6diag.main.js` `cf470101…c1d0`, `diag/s6diag.selftest.js` `425ddec6…6a28`); index written with those **2 entries** | instrument-only | `21bb27fed58079ad096c07643ea08b433cb8fd4ff2a3ec4152df06dd91091068` |
| 05:10:50–52 | Granted self-check A' run against exactly those two files (receipt `logs/selftest-v3/`, `prehash.txt` pins both hashes) | — | — |
| 05:11 | Parent archived the 2-entry index at `tgp-private-evidence/2026-09-22/remediation/s6-diagnostic/instrument-3/v3/MANIFEST.v3.sha256` (176 bytes) | — | `21bb27fe…1068` |
| 05:19:48 | Hooks/specs copied into `v3/diag/` (byte-identical to V1/V2) for the execution-only successor | — | — |
| 05:20:44 | Successor runners written; index **regenerated in place** over `diag/*` + `diag/specs/*` + both runners → **11 entries** | expanded | `50f65b9d7878e2aa52344fa6dc392a3fda94a80c30d84a8d2db5e78e6c05d7e0` |
| 05:29:18 | Correction: exact archived original bytes copied to `v3/MANIFEST.v3.instrument-only.sha256` (SHA256 `21bb27fe…1068`, equal to the archive) | — | — |

Verification performed now (read-only, from `v3/`):
- `sha256sum -c MANIFEST.v3.instrument-only.sha256` → `diag/s6diag.main.js: OK`, `diag/s6diag.selftest.js: OK` (2/2). The two instrument files are byte-identical to what the archived index and the positive self-check pinned.
- `sha256sum -c MANIFEST.v3.sha256` (expanded, `50f65b9d…d7e0`) → 11/11 OK.
- Neither the current runner (`1664fd47…`), setup (`91fe0f1b…`), instrument, nor the expanded manifest was modified by this correction.

Consequences: the V3 runner's step 1 verifies the **expanded** index (`MANIFEST.v3.sha256`), which is a superset of the archived 2-entry index; the instrument hashes it pins are the same as the self-checked ones. This was a bookkeeping lapse on my side (index name reused for a different scope), not a product issue; the source reasoning and the positive instrument receipt remain applicable. Going forward, any change of scope gets a new file name (e.g. `MANIFEST.v3-runner.sha256`) instead of overwriting.
