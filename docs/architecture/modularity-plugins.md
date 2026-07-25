# Modularity And Plugins

## Status

Current modularity contract plus a proposed packaging direction. Implementation details and acceptance gates live in [RFC: Optional Module Packaging](proposals/optional-module-packaging.md).

## Current Contract

- Lurek2D ships as one Rust binary with its Lua API registered at startup.
- Rust modules are compiled into that binary; they are not dynamically discovered plugins.
- Pure-Lua reuse lives in `lurek_2d_content/library/` and consumes public `lurek.*` APIs.
- Sandboxed game mods use the public runtime and mods/filesystem policy.
- Developer tooling in the extension or Workbench is not a runtime plugin.

## Module Classification

`docs/meta/modules.toml` owns the current module registry, public flag, namespace, source path, examples, tests, and tier/group metadata. Architecture prose must not maintain a second exhaustive module table.

## Durable Plugin Requirements

Any future optional native/module system must:

- preserve one public registration owner in `src/lua_api/`;
- make dependencies and load order deterministic;
- prevent optional modules from becoming hidden `SharedState` requirements;
- define behavior when an optional public surface is absent;
- keep save formats and handles compatible or explicitly versioned;
- prove build/test matrices and measure binary impact before changing defaults;
- include a rollback to the all-in binary.

## Non-Goals

- Arbitrary untrusted native code sandboxing.
- Replacing pure-Lua packages or game mods.
- Hot-reloading Rust state without an explicit lifetime and migration design.
- Promising a binary-size target before reproducible measurements exist.

## Decision Boundary

The current all-in binary remains authoritative until the RFC is accepted and its gates pass. Proposed feature flags, dynamic libraries, ABI promises, and extraction candidates are not current runtime facts.
