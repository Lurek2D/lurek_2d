# Rust File Docstrings

These rules define how `//!` file-level docstrings under `src/` should be written for both human readers and retrieval-oriented tooling.

## Quantitative Policy

- Every Rust source file in `src/` must begin with one contiguous `//!` block.
- Required line count is determined by file LOC and enforced by `tools/audit/module_docstring_audit.py`.
- Every `//!` line body must be between 90 and 120 characters after the prefix.
- `mod.rs` files use 2x the normal LOC-based line count.
- `src/lua_api/*.rs` files use exactly one file-level line because callable behavior is documented on item docs.

## Qualitative Goal

The block should let a reader answer, before scanning item docs:

1. What functionality the file provides.
2. What state, contracts, or resources it owns.
3. What boundary it represents inside the engine.
4. Which neighboring systems matter when behavior changes there.
5. Why a maintainer should open this file instead of a sibling file.

## Required Content Shape

Across the block, cover the file from these angles:

- Primary responsibility.
- Owned data or contracts.
- Public behavior.
- Boundary and integration.
- Navigation value.

Each line should carry one concrete fact.

## Writing Rules

- Prefer functional descriptions over taxonomy.
- Name real symbols only when they help orient the reader.
- Mention neighboring modules only when they are actual change partners.
- Use plain English and concrete nouns such as cache, command, registry, scene state, render pass, Lua boundary, or archive loader.
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
- that readers or agents should open it, without saying why
- that the file has functions, structs, or helpers, without naming their job

## Rewrite Process

1. Read the full file first.
2. Identify the owner role and the most important neighboring systems.
3. Draft lines around delivered behavior, owned state, and boundary.
4. Check every line for the 90 to 120 character window.
5. Regenerate affected specs after each edited batch.
