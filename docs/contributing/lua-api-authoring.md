# Lua API Authoring Guide

## Scope

This guide defines how a Rust owner exposes an existing behavior through `lurek.*`. It does not create domain behavior: add or change the domain owner first, then make the binding thin and documented.

## File responsibilities

- `src/<module>/` owns domain behavior, state, validation that is independent of Lua, and private tests.
- `src/lua_api/<module>_api.rs` owns Lua argument conversion, namespace registration, Lua-visible userdata, and contextual errors.
- `src/lua_api/register.rs` owns VM-wide registration order and global setup.
- `docs/meta/modules.toml` owns the public namespace and associated example/test metadata.

Do not let an API file become a second implementation of the module. If conversion is substantial, name and test the adapter; if the behavior is domain logic, move it behind the domain boundary.

## Registration pattern

Register one public namespace under the existing `lurek.*` contract. Registration must be deterministic, fail with context, and respect the module configuration or compile-time feature gate that owns availability.

```rust
// Pseudocode: preserve the repository's live registration helpers and signatures.
let api = lua.create_table()?;
api.set("operation", lua.create_function(|_, args| {
    // validate Lua input -> call domain owner -> convert result
})?)?;
lurek.set("module", api)?;
```

Use the repository's current binding utilities rather than inventing a parallel validation or handle convention.

## Argument, result, and error rules

- Validate Lua-visible types, table fields, enum strings, ranges, and optional values at the boundary.
- Preserve domain errors and add the public API name when it helps a script author locate the failure.
- Return Lua-native values and stable table shapes; do not expose internal Rust types or backend handles.
- Do not hold a `SharedState` borrow across a Lua callback or another re-entrant boundary call.
- Use explicit handles/userdata for owned resources and reject stale or wrong-kind handles.
- Document defaults, units, mutation timing, ownership transfer, callback timing, and failure behavior when applicable.

## Docstrings and generated documentation

Binding docstrings are the source for callable facts in generated API references and LuaCATS stubs. Write concise, factual descriptions for public functions, userdata methods, fields, constants, callbacks, and enums.

Good public documentation answers:

1. What the call does and which owner performs the work.
2. The accepted input shape, defaults, units, and limits.
3. What is returned or mutated, including resource ownership.
4. When callbacks run and which arguments they receive.
5. Which errors or invalid states a caller must handle.

File-level `//!` documentation describes the Rust file's responsibility, owned state/contract, neighboring boundary, and why a maintainer should open it. It is not a copy of every callable docstring.

## Lua script conventions

- Use `lurek.*` as the public engine surface.
- Keep callback-local frame logic separate from persistent game state.
- Multiply time-based motion by `dt`.
- Use project-relative forward-slash asset paths.
- Keep game state in explicit tables or script modules; do not rely on hidden runtime-surviving upvalues for scene lifecycle.

## Required proof

- Add/update the module's public example block for user-visible behavior.
- Add/update Lua coverage for public behavior and failure paths.
- Add Rust coverage only for private conversion or implementation seams that Lua tests cannot prove.
- Regenerate/check generated documentation when binding annotations or module metadata change.

See [Rust File-Level Docstrings](rust-file-docstrings.md), [Quality Assurance](quality-assurance.md), and the [Documentation System](https://github.com/Lurek2D/lurek_2d/blob/main/docs/architecture/docs-system.md).
