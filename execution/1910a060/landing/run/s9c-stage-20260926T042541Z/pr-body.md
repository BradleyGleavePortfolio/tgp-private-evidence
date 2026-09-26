Exact composition of the accepted S9-C candidate `2e9f6c054b86b749b58a9232c79153a872d9ec18` (tree `02e7b312c7a318e80c1e468854ef2555a10e8873`) onto integration/importer `a4af8e330bd4d6f882f0aebd411200b76d651aba` (S10-0 decision record landed).

- Merge `e6f20300b495fa9eee9539ae58d30e3b60e5a78c`, parents (`a4af8e330bd4d6f882f0aebd411200b76d651aba`, `2e9f6c054b86b749b58a9232c79153a872d9ec18`), tree `944562f61f3f8fcef28a4f0f558fa930322bb388` = `a4af8e330bd4d6f882f0aebd411200b76d651aba` plus the 22 S9-C paths byte for byte; no overlapping path.
- `land/s9-c-accepted` preserves the exact candidate bytes. No migration or schema change. The importer contract changes by regeneration only (blob `752f9dbe1a6bdee0c20504a35dce60757880d427`); the S9 decision record gains the append-only Addendum B.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
