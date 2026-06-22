# save manual spec overlay

## TL;DR

- Manages game saves with compression, auto-save timers, and schema migrations.

## Summary

- The `save` module is the persistence-lifecycle surface for users who want game state to be stored, versioned, and restored as a managed workflow instead of a raw file dump.
- Save managers, metadata, migration support, schema versions, and summary information work together so save files can evolve over time without every project rolling its own compatibility rules.
- That matters because persistence is usually more than writing bytes: projects also need naming, summaries, migration paths, and validation.
- It also needs a clear lifecycle for selecting, migrating, and restoring stored game state.
- Read `save` as the owner of save and load policy. Serialization modules decide how data is encoded, but `save` decides how game-state persistence is packaged, versioned, and coordinated for users.

This module primarily collaborates with `binary`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- Slot names are restricted to non-empty ASCII `[A-Za-z0-9_-]` identifiers with a bounded maximum length; path traversal and separator-like input must be rejected before any save/delete/load path is constructed.
- Save collection rejects cyclic Lua tables, non-finite numbers, oversized strings/keys, and oversized table graphs before serialization begins.
- Parser and compression reads are bounded by explicit depth, entry-count, key/string, and compressed/decompressed byte limits; malformed or oversized payloads must fail with a concrete reason.
- Compressed saves use a versioned `LUREK_SAVE v1` header with LZ4 + Base64 metadata, declared uncompressed size, and SHA-256 integrity verification; legacy `--[[COMPRESSED]]` payloads remain readable.
- Slot writes use temp-file plus rename semantics and keep a `.bak` recovery copy when replacing an existing slot; loads may recover from the backup when the primary payload is corrupt.
- Migration routing is strict: missing version steps or downgrade attempts must be reported instead of silently skipping versions.

## Architecture Links

- Intentionally empty.
