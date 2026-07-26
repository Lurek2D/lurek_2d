# Rust File-Level Docstring Guide

These rules define how `//!` file-level docstrings under `src/` should be written for both human readers and
agent-driven retrieval.

## Quantitative Policy

- Every Rust source file in `src/` must begin with one contiguous `//!` block.
- Required line count is determined by file LOC and enforced by `tools/audit/module_docstring_audit.py`.
- Every `//!` line body must be between **90** and **120** characters after the prefix.
- `mod.rs` files use **2x** the normal LOC-based line count.
- `src/lua_api/*.rs` files use exactly **1** file-level line because callable behavior is documented on item docs.

## Qualitative Goal

The block must let a reader answer, before scanning item docs:

1. What functionality this file provides.
2. What state, contracts, or resources it owns.
3. What boundary it represents inside the engine.
4. Which neighboring systems matter when behavior changes here.
5. Why an agent or maintainer would open this file instead of a sibling file.

## Required Content Shape

Each line should carry one concrete fact. Across the whole block, cover the file from these angles:

- Primary responsibility:
  Name the feature, subsystem, or runtime job this file delivers.
- Owned data or contracts:
  Mention the main structs, tables, registries, caches, adapters, or invariants owned here.
- Public behavior:
  Summarize the class of operations, helpers, or entrypoints this file exposes.
- Boundary and integration:
  State whether the file is a crate root, subsystem owner, runtime adapter, renderer, storage layer, or API edge.
- Navigation value:
  Tell a future reader why this file is the right owner for a specific kind of change.

## Writing Rules

- Prefer functional descriptions over taxonomy.
  Good: "Owns save-slot persistence, dirty tracking, and disk serialization for game state."
  Bad: "This file is part of the save module."
- Name real symbols only when they help orient the reader.
- Mention neighboring modules only when they are actual change partners.
- Use plain English and concrete nouns: cache, command, registry, scene state, render pass, Lua boundary, archive loader.
- Keep one idea per line.
- Avoid filler, history, slogans, and style commentary.
- Do not restate the filename unless it adds orientation.
- Do not duplicate several lines with slight wording changes.

## Anti-Patterns

Do not write lines that only say:

- that the file exists
- that it belongs to a module
- that it contains code for a subsystem
- that docs should be regenerated
- that agents should read it, without saying why
- that the file has functions, structs, or helpers, without naming their job

## Rewrite Process

- Read the full file first.
- Identify the file owner role and the most important neighboring systems.
- Draft lines around delivered behavior, owned state, and boundary.
- Check every line for the 90-120 character window.
- Regenerate affected specs after each edited batch.
