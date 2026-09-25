Exact composition of the accepted S9-A candidate `be88909f4bf6a727a3bd376385aba91f209f989a` (tree `54349476c9f92296f4595bda45d64a48534c4553`) onto integration/importer `62471b116267fdec6746073c4b4c80a154d09834` (S8-F landed).

- Merge `9497ca5275938c9228c6ec6fa0dfa8c34f39f724`, parents (`62471b116267fdec6746073c4b4c80a154d09834`, `be88909f4bf6a727a3bd376385aba91f209f989a`), tree `737c34a3b50cb823c9317d13e1b23797127338b9` = `62471b116267fdec6746073c4b4c80a154d09834` plus the 4 S9-A paths byte for byte; no overlapping path.
- `land/s9-a-accepted` preserves the exact candidate bytes. No migration, contract, schema or module wiring change.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
