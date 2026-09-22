# S6-P1 staging — preservation note (G04)

Current-path integrity for this checkpoint is `MANIFEST.sha256` (current paths only). The root
`execution/s6-r3/SHA256SUMS` no longer lists `s6-p1/` files; the entries below were removed from it because they
referred to bytes that have since been overwritten in place.

## Obsolete digests (historical record only — NOT current files)

| digest | path (as it was) | status |
|---|---|---|
| `f2baae9d52477812e8bcadd433fbba1814b27969b8e797915e56beb6d3d78c32` | `staging/src/services/__tests__/persistedQueryCache.hazardControls.test.tsx` (v1, singleton-bound controls) | **unavailable, unexecuted**; overwritten in place by v2 (adapter-based) before any test run. Not reconstructed; must never be presented as the original. |
| `e90fd651156cdfdbf3342a8da31b38a4f803b66f084006398329cad5f7cabe80` | `staging/src/services/__tests__/persistedQueryCache.identityGate.test.tsx` (v1) | superseded in place by the extended v2 (logged-out delayed ops, drain, timeout fences); unexecuted. |
| `854f26700c57f2397dceb12f6aab92b87f3dc0263cf55cc7e40a87059ee47513` | `SOURCE-MAP.md` (v1) | superseded in place (v2: hydrate-boundary fence, drain, purge-on-null decision). |

Intermediate v2 digests appended to the root file at 5:0x PM (`8b303a48…`, `3796be8f…`, `a31624ac…`, `73cec786…`)
were also removed; `SOURCE-MAP.md` and `identityGate` changed again afterwards. The rootNavigator suite
(`b1ed2f46943df458547f07a9a6989e1ea70ea0c6db3d0f81a647eacd671e7e9d`) is unchanged and is listed in the manifest.

No file in this directory has been executed; no test result exists yet for any version.
