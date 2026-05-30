# `<module>`

<!--
  TEMPLATE — merged module reference format.
  Copy this file to docs/specs/<module>.md and fill in every section.
  Summary is manual prose.
  Imports, Files, and Lua API Ref are scaffolded by tools/docs/gen_module_specs.py.
-->

## TL;DR

- A short 1-2 sentence summary of what this module does.

## General Info

- Module group: `<Foundations | Core Runtime | Platform Services | Feature Systems | Edge/Integration>`
- Source path: `src/<module>/`
- Binding: `src/lua_api/<module>_api.rs` or `None direct`
- Namespace: `lurek.<namespace>` or `None direct`
- Lua API surface: `<N>` functions, `<N>` types, `<N>` methods
- Rust test path(s): `tests/rust/unit/<module>_tests.rs`
- Lua test path(s): `tests/lua/unit/test_<module>_core_unit.lua`

## Summary

- Several sentences describing the module's purpose, design, and public interface.
- Describe the module's scope boundary and how it interacts with other modules.

## Imports

- `math`: Explain why this module depends on or interacts with `src/math/`.
- `runtime`: Explain the separation of duties with `src/runtime/`.

## Files

- `mod.rs`: Module root and re-export surface.
- `type_a.rs`: Describe the file's purpose.
- `type_b.rs`: Describe the file's purpose.

## Lua API Ref

### Functions

- `lurek.<namespace>.example`: Describe what the binding exposes.

### Callbacks

- `lurek.<namespace>.exampleAsync` param `callback` (`function`): Describe callback contract and invocation shape.

### Enums

- No documented module-level enums/constants.

### Types

#### `TypeA` Type

- One-line description of the Lua-visible type.

##### Fields

- `field` (`type`): Describe the field.

##### Methods

- `TypeA:method`: Describe what the Lua-visible method does.
