Exact composition of the accepted S8-F candidate `e1ec2fecb71f315b6721d426ba0dacb84f304498` (tree `2fe0201ff132dfdc53ea82b3f26ed0fc8d1c65d6`) onto integration/importer `1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`.

- Merge `62471b116267fdec6746073c4b4c80a154d09834`, parents (`1c5fbb0441178e0cfe6e9f8d72e955c645c265e9`, `e1ec2fecb71f315b6721d426ba0dacb84f304498`), tree `23614f0b7dc33dc37b90cf4f27fcb8331912e60f` = the 17 S8-F paths byte for byte plus `docs/decisions/2026-09-25-s9-reconciliation.md`.
- `land/s8-f-accepted` preserves the exact candidate bytes. No migration, no contract change against the S8-F tree.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
