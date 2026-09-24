#!/usr/bin/env python3
"""
S7-2' pair-surface consumer fixture extraction (UX-03b, EXEC-cf8ff737).

Mechanically derives the mobile consumer fixture from the committed C1 contract
artifact. No hand edits: the output is a deterministic (sorted-key, 2-space)
JSON projection of exactly the five pair-surface paths plus the transitive
closure of every `#/components/schemas/*` reference reachable from them, and
the `bearer` security scheme they declare.

Usage:
  python3 extract_pair_surface_fixture.py <source-openapi.json> <out-fixture.json>

The source SHA-256 is verified against the parent-recorded value before any
extraction and is embedded in the fixture under `$fixture.source.sha256`.
"""
import hashlib
import json
import sys

EXPECTED_SOURCE_SHA256 = "bdb022dd6c4fb64cdf291fdde3796b99e4b23004f676b7cb46a58460526ba4e5"
SOURCE_COMMIT = "a0ea1bea92ba830d5ffb712a3dcb26e7be0a0992"
SOURCE_ARTIFACT = "docs/contracts/importer-openapi.json"
SOURCE_REPOSITORY = "growth-project-backend"
EXPECTED_VERSION = "2.0.0-c1-s1.1"

PAIR_PATHS = [
    "/api/extension/pair/init",
    "/api/extension/pair/status",
    "/api/extension/pair/current",
    "/api/extension/pair/session",
    "/api/extension/pair/redeem",
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
    if sha != EXPECTED_SOURCE_SHA256:
        raise SystemExit(f"source sha mismatch: {sha} != {EXPECTED_SOURCE_SHA256}")
    doc = json.loads(raw)
    if doc["info"]["version"] != EXPECTED_VERSION:
        raise SystemExit(f"unexpected contract version {doc['info']['version']}")

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
            "name": "c1-pair-surface",
            "purpose": (
                "S7-2' consumer-frozen pair surface of the C1 importer contract, "
                "mechanically projected for the TGP mobile consumer contract test. "
                "Do not hand-edit; regenerate with "
                "execution/cf8ff737/ux03b/extract_pair_surface_fixture.py."
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
                    "exact copy of the five listed path items; transitive closure of "
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
