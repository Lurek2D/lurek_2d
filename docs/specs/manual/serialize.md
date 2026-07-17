# serialize manual spec overlay

## TL;DR

- Translates JSON, TOML, CSV, XML, INI, and MessagePack via one intermediate tree and validates neutral ChangeSet envelopes.
- Validates data against schemas.
- Enforces bounded decode, encode, and Lua-conversion limits for depth, nodes, strings, rows, and input size.

## Summary

- The `serialize` module is the format-translation surface for users who want several external data formats to map into one shared runtime value model.
- JSON, TOML, CSV, XML, INI, MessagePack, schemas, and codec entrypoints all matter here because a project often needs to move content between several representations without rewriting conversion logic each time.
- The module is useful both for loading or saving data and for validating whether translated data actually fits an expected structure.
- Its shared intermediate tree is the key user-facing idea: several formats can participate in the same workflows because they resolve into one normalized serial representation.
- That normalized representation is what makes cross-format tooling practical. Validators, exporters, migration steps, and transforms can reason about one value model instead of reimplementing logic for every source format.
- That also makes migrations easier to reason about.
- Safety is part of the contract. Lua conversion, autodetection, CSV parsing, and MessagePack decode must stay bounded and reject cyclic or non-finite inputs instead of recursing or allocating without policy.
- Read `serialize` as the normalization layer for structured data moving between external formats and engine-facing workflows.
- `encodeChangeSet()` and `decodeChangeSet()` are schema-light transport helpers. They validate the stable `schema`, `revision`, and ordered `{objectId, component, operation, payload}` records, then delegate actual encoding to the existing codec front door.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

## Notes

- `SerializeLimits` are part of the module contract for untrusted or generated data. Depth, node, string, input-byte, and CSV budgets should stay explicit.
- Lua table cycles and non-finite numbers are rejected rather than coerced or silently serialized.
- `SerialFormat` exposes capability flags so tooling can discover whether a format can encode, decode text, or decode bytes before attempting the operation.

## Architecture Links

- Intentionally empty.
