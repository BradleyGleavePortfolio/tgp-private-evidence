Exact composition of the accepted S9-B candidate `1e6e5735384a434804bce223c1599162bc660983` (tree `db6dde16c212ee1d2cf42da6bc71bacb68452b8e`) onto integration/importer `771db62aa10dd0065f30d7d8a155d89fd1cfcfc8` (S8-G landed).

- Merge `5407efae319fd913e973c87f3be0d49786c4a3e0`, parents (`771db62aa10dd0065f30d7d8a155d89fd1cfcfc8`, `1e6e5735384a434804bce223c1599162bc660983`), tree `3e2028e9fc40c77db72152eb0e5c860d0a3661db` = `771db62aa10dd0065f30d7d8a155d89fd1cfcfc8` plus the 11 S9-B paths byte for byte; no overlapping path.
- `land/s9-b-accepted` preserves the exact candidate bytes. No migration, contract, schema or module wiring change.
- Landing: one ordinary fast-forward push of this exact head after green CI. The merge button is not used. Non-production. `main` is untouched.
