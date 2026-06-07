# Serialize

## Summary

This module serves as the primary data-translation and validation subsystem for Lurek2D, providing a unified frontend to ingest and export data. The subsystem translates all text and binary inputs into a format-agnostic intermediate value tree. Through a single entry point, the codec automatically detects and parses payloads—including JSON, TOML, CSV, XML, INI, and MessagePack—isolating format quirks from the runtime.

The module provides dedicated adapters to bridge scripts and raw files. It handles CSV rows, sectioned INI settings, hierarchical XML nodes, TOML configs, MessagePack binary packets, and JSON streams. The system automatically distinguishes between sequence arrays and maps when bridging dynamic Lua tables to the intermediate tree, preserving layout structures without manual tagging.

To guarantee data integrity, a declarative schema validation engine defines required types and constraints. Validation passes automatically merge schema-defined default values into missing fields. When validation fails, it reports precise paths pointing to the exact entry that broke the contract.

*No public API documented yet.*