Exact composition of the accepted S8-G candidate `1279b419ee60b25163c7e6d2809b749dd723fee9` (tree `44ece797c9183ee33198b2c43e402f943911369a`) onto integration/importer `9497ca5275938c9228c6ec6fa0dfa8c34f39f724` (S9-A landed).

- Merge `771db62aa10dd0065f30d7d8a155d89fd1cfcfc8`, parents (`9497ca5275938c9228c6ec6fa0dfa8c34f39f724`, `1279b419ee60b25163c7e6d2809b749dd723fee9`), tree `74c06f8ffe26eda1e99251ecf1bbcdface6689ff` = `9497ca5275938c9228c6ec6fa0dfa8c34f39f724` plus the 14 S8-G paths byte for byte; no overlapping path.
- `land/s8-g-accepted` preserves the exact candidate bytes. No migration, contract, schema or module wiring change.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
