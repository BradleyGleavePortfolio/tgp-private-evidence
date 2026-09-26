#!/usr/bin/env python3
"""
S12-B3 scout status/roster consumer fixture extraction (M-bind, EXEC-fa72efb2).
Derived from execution/fa72efb2/mobile-readiness/tooling/extract_s11c_pair_surface_fixture.py;
only the source commit, the path list, the name and the purpose differ.

Mechanically derives the mobile consumer fixture for the S12-B3 verdict
screen from the committed backend contract artifact at landed commit
54be96f18c314cae35d1e5d3000af9f06d693d81 (artifact sha256 889d25c6..., identical
to the 7fdcbc04 artifact). Same methodology as the frozen
C1 extractor (execution/cf8ff737/ux03b/extract_pair_surface_fixture.py):
exact copy of the two scout read path items, transitive closure of
every `#/components/schemas/*` $ref reachable from them, the security
schemes they declare, deterministic (sorted-key, 2-space) JSON output.

Usage:
  python3 extract_s12b3_status_surface_fixture.py <source-openapi.json> <out-fixture.json>

The source SHA-256 is embedded in the fixture under `$fixture.source.sha256`
(no pre-verification against a pinned value, unlike the C1 extractor, because
this is the FIRST projection of this commit — the resulting fixture's sha is
what the mobile contract test pins going forward).
"""
import hashlib
import json
import sys

SOURCE_COMMIT = "54be96f18c314cae35d1e5d3000af9f06d693d81"  # landed integration/importer (S11-A2); artifact byte-identical to 7fdcbc04
SOURCE_ARTIFACT = "docs/contracts/importer-openapi.json"
SOURCE_REPOSITORY = "growth-project-backend"

PAIR_PATHS = [
    "/api/scout/import/status",
    "/api/scout/reconstruct/roster",
]

SCHEMA_REF_PREFIX = "#/components/schemas/"


def walk_refs(node, out):
    """Collect every `$ref` string under `node` into `out` (recursive)."""
    if isinstance(node, dict):
        ref = node.get("$ref")
        if isinstance(ref, str):
            out.add(ref)
        for v in node.values():
            walk_refs(v, out)
    elif isinstance(node, list):
        for v in node:
            walk_refs(v, out)


def schema_closure(paths_subset, schemas):
    """Transitive closure of schema names referenced from the path subset."""
    pending = set()
    walk_refs(paths_subset, pending)
    names = set()
    while pending:
        ref = pending.pop()
        if not ref.startswith(SCHEMA_REF_PREFIX):
            raise SystemExit(f"unsupported $ref outside components.schemas: {ref}")
        name = ref[len(SCHEMA_REF_PREFIX):]
        if name in names:
            continue
        if name not in schemas:
            raise SystemExit(f"dangling $ref: {ref}")
        names.add(name)
        nested = set()
        walk_refs(schemas[name], nested)
        pending |= {r for r in nested if r[len(SCHEMA_REF_PREFIX):] not in names}
    return names


def security_scheme_names(paths_subset):
    names = set()
    for path_item in paths_subset.values():
        for op in path_item.values():
            for req in op.get("security", []) or []:
                names |= set(req.keys())
    return names


def main(src_path, out_path):
    raw = open(src_path, "rb").read()
    sha = hashlib.sha256(raw).hexdigest()
    doc = json.loads(raw)

    paths_subset = {}
    for p in PAIR_PATHS:
        if p not in doc["paths"]:
            raise SystemExit(f"pair path missing from source: {p}")
        paths_subset[p] = doc["paths"][p]

    schemas = doc["components"]["schemas"]
    closure = schema_closure(paths_subset, schemas)
    sec_names = security_scheme_names(paths_subset)
    sec_schemes = doc["components"].get("securitySchemes", {})
    for n in sec_names:
        if n not in sec_schemes:
            raise SystemExit(f"security scheme missing from source: {n}")

    fixture = {
        "$fixture": {
            "name": "s12b3-scout-status-surface",
            "purpose": (
                "S12-B3 (M-bind) consumer-frozen scout import status + reconstruct "
                "roster surface of the importer contract, mechanically projected for "
                "the TGP mobile verdict consumer contract test. Do not hand-edit; "
                "regenerate with execution/fa72efb2/s12b3/tooling/"
                "extract_s12b3_status_surface_fixture.py."
            ),
            "source": {
                "repository": SOURCE_REPOSITORY,
                "commit": SOURCE_COMMIT,
                "artifact": SOURCE_ARTIFACT,
                "sha256": sha,
                "contract_version": doc["info"]["version"],
                "openapi": doc["openapi"],
            },
            "extraction": {
                "method": (
                    "exact copy of the two listed path items; transitive closure of "
                    "every #/components/schemas/* $ref reachable from them; security "
                    "schemes named by their `security` requirements; JSON re-serialised "
                    "with sorted keys and 2-space indent"
                ),
                "paths": list(PAIR_PATHS),
                "schemas": sorted(closure),
                "securitySchemes": sorted(sec_names),
            },
        },
        "openapi": doc["openapi"],
        "info": doc["info"],
        "paths": paths_subset,
        "components": {
            "schemas": {n: schemas[n] for n in sorted(closure)},
            "securitySchemes": {n: sec_schemes[n] for n in sorted(sec_names)},
        },
    }
    out = json.dumps(fixture, indent=2, sort_keys=True, ensure_ascii=False) + "\n"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(out)
    print(f"source sha256 {sha}")
    print(f"fixture sha256 {hashlib.sha256(out.encode('utf-8')).hexdigest()}")
    print(f"paths {len(paths_subset)} schemas {sorted(closure)} security {sorted(sec_names)}")


if __name__ == "__main__":
    if len(sys.argv) != 3:
        raise SystemExit(__doc__)
    main(sys.argv[1], sys.argv[2])
