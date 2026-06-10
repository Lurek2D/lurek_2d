# Serialize

## Summary

- The serialize module gives users one multi-format surface for decoding, encoding, and validation.
- It supports JSON, TOML, CSV, XML, INI, and MessagePack through a shared intermediate value model.
- Automatic format detection helps ingest unknown text payloads in tool-style workflows.
- Lua table bridging converts between script data and typed serialized structures.
- Codec adapters isolate format-specific quirks so callers can use consistent APIs.
- Schema validation enforces structure and constraints before data reaches gameplay logic.
- Default-merge helpers fill missing fields from schema definitions.
- Path-specific validation errors make malformed data easier to diagnose quickly.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Foundations group rather than absorb behavior owned by those neighbors.

*No public API documented yet.*