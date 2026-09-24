# UX-07 extension presentation — r2 A-01 correction receipt

**Purpose:** minimal closure evidence for independent-review finding A-01 only.

## Authorized one-line correction

| Item | Value |
|---|---|
| Affected path | `popup/pair.html` |
| Selector | `input` |
| Removed declaration | `border: 1px solid #8e9d91;` |
| Replacement declaration | `border: 1px solid var(--muted);` |
| Correction scope | One CSS declaration; no markup, ID, form, copy, state, controller, manifest, CSP, asset, font-loader, protocol, or configuration change. |

`--muted` is already defined in the same candidate style block as `#53655b`; `--cream` remains `#fffdf8`.

## Contrast measurement

| Boundary | Foreground / background | WCAG contrast |
|---|---|---:|
| Enabled pairing input border | `#53655b` / `#fffdf8` | **6.11:1** |

The corrected visible input boundary exceeds the 3:1 non-text AA threshold identified in A-01.

## Exact r2 pins

| Item | Pin |
|---|---|
| Base commit | `0111be661922234d670bbf23e23d270eec1b4a4e` |
| Base tree | `4465c42dbb915e67b3c2e0e925f284caa3333468` |
| Prior reviewed r1 candidate tree | `130afa99778327b79cc69a494f085493efc4df95` |
| Replacement r2 candidate tree | `3750a2ea9f6e57b7de96c0102aab66d761776189` |
| `popup/popup.html` r2 blob (unchanged from r1) | `f003a81804d15e5fc34fefbeaab228f371a14a7d` |
| `popup/pair.html` r2 blob | `01f6839b0b7657520167556fc9ae71c56ea80474` |
| `manifest.json` blob (unchanged) | `035373d20b91c05e7fb8b0d628a5570014a812fc` |
| `popup/popup.js` blob (unchanged) | `296e3052001027907b40743c7c615085bff7d686` |
| `popup/pair.js` blob (unchanged) | `11c0bcb9e324e86e2677a608c00df833be412d11` |
| `package.json` blob (unchanged) | `cf10ffb7c120a2faba0860f8a9adce1cc6a505ef` |

The changed path set from the exact base remains exactly `popup/popup.html` and `popup/pair.html`. The r1→r2 delta changes only the input border declaration in `popup/pair.html`.

## Additive review artifacts

| Artifact | SHA-256 | Bytes |
|---|---|---:|
| `UX07_EXTENSION_T1_R2_DELTA.patch` (r1→r2, one-line correction) | `b3faca825c717ef7e57a62721b92b4847c1bd2a33f40d0ebe20f05a3b8abec7d` | 398 |
| `UX07_EXTENSION_T1_R2_SOURCE_DIFF.patch` (base→r2 full candidate) | `e5ae9a412e3440f4521df2ba364d941836e64e4325d2432e37104c7abfef5737` | 8,696 |

The original source packet and r1 patch remain unchanged in this evidence directory.

## Execution boundary

No install, test suite, build, browser/runtime interaction, packaged validation, commit, deployment, publication, or remote write was performed. The remaining validation plan is unchanged from the r1 packet; this receipt supplies only the bounded source correction and contrast evidence requested for same-review delta closure.

