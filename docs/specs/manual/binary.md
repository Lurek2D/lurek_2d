# binary manual spec overlay

## TL;DR

- Manages byte buffers, format packing, compression, hashing, and byte-safe encodings.
- Controls compression, cryptographic hashing, and element ring buffers.

## Summary

- The `binary` module is the byte-oriented data surface for users who need exact control over compact formats, protocol payloads, and structured runtime interchange.
- Mutable byte containers, typed views, sequential writers, and pack-style helpers work together so a script can both inspect existing binary data and build new payloads without inventing its own low-level buffer rules.
- Compression, encoding, hashes, checksums, and ring-buffer helpers matter because real binary workflows usually involve transport safety, storage reduction, and integrity checks alongside raw reads and writes.
- Byte encodings, compression, hashes, checksums, and schema-like packing utilities make the module useful for both debug tooling and production-facing data paths such as saves, networking, and cached assets.
- Exact offset control, byte-order awareness, and sequential write semantics are especially valuable when interoperating with protocols or compact save formats where structure must be reproduced precisely.
- The module therefore acts as the engine's low-level data construction kit whenever higher-level structured formats are too heavy or too opaque for the problem at hand.
- That also makes it useful when tests or tools need to inspect raw payload layout instead of only decoded high-level values.
- It keeps raw layout work first-class.
- Read `binary` as the shared byte-language of the engine: other modules decide what the data means, but `binary` owns how that data is packed, transformed, verified, and moved around safely.
- Structured interchange formats such as TOML and MessagePack belong to `serialize`; `binary` must not expose format-specific structured parsers just because a format can be represented as bytes.

This module is mostly self-contained inside the `Foundations` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
