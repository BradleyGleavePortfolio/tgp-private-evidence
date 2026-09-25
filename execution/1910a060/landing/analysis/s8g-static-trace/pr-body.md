Exact composition of the accepted S8-G candidate `820ce85be2ebf994112afbb90739eb9469ad628e` (tree `7ede6dbb8f6f2d0ddcc349882a47ef67d415c32a`) onto integration/importer `9497ca5275938c9228c6ec6fa0dfa8c34f39f724` (S9-A landed).

- Merge `663ce133bb5b486fc27920df09b635bebf87617e`, parents (`9497ca5275938c9228c6ec6fa0dfa8c34f39f724`, `820ce85be2ebf994112afbb90739eb9469ad628e`), tree `60214a647a0a28270deaa85ba7e65da4cb9e3556` = `9497ca5275938c9228c6ec6fa0dfa8c34f39f724` plus the 14 S8-G paths byte for byte; no overlapping path.
- `land/s8-g-accepted` preserves the exact candidate bytes. No migration, contract, schema or module wiring change.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
