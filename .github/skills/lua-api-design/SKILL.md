---
name: lua-api-design
description: "Load this skill when designing or modifying the lurek.* Lua API surface. It owns naming conventions, parameter patterns, callback contracts, and API consistency rules. Skip it for Rust internals or pure Lua scripting."
---
# lua-api-design

## Mission

Own the lurek.* Lua API surface design: naming, signatures, parameter patterns, callback contracts, Thin Wrapper Rule, and docstring conventions.

## When To Load

- Adding a new lurek.* function or type
- Renaming or changing the signature of an existing API
- Designing callback contracts or event patterns
- Reviewing API consistency across modules

## When To Skip

- Writing Rust domain logic -> use rust-coding skill
- Pure Lua scripting -> use lua-scripting skill
- Lua-Rust bridge mechanics -> use lua-rust-bridge skill

## Domain Knowledge

**Gold standard reference:** `docs/specs/lua-api-file-standard.md` is the canonical file-layout and docstring contract. For the current bridge layout, also read `src/lua_api/mod.rs`, `src/lua_api/register.rs`, and `src/lua_api/lua_types.rs`.

**Thin Wrapper Rule (TST-03):** src/lua_api/<module>_api.rs holds ONLY impl LuaUserData, registration functions, and type conversions. Business logic lives in src/<module>/. This keeps bindings testable and domain code Lua-agnostic.

**Naming conventions:** Rust snake_case becomes Lua camelCase. Constructors: lurek.<module>.new<Type>(). Getters: get<Property>(). Setters: set<Property>(value). Predicates: is<Property>(). Actions: verb form (play, stop, load, save).

**Registration pattern:** flat function body (no nested helpers), section separators between logical groups of functions, doc block above the optional `let s = state.clone();` bridge line, then the `tbl.set(...)` or `methods.add_*` call.

**Docstring format (parsed by tools/docs/gen_lua_api_data.py):** exactly one description line plus pipe-delimited tags:
- `/// One sentence.`
- `/// @param | name | type | description`
- `/// @return | type[, type...] | description`

Rules:
- No legacy formats.
- No extra prose lines after the first `///` line.
- `@return` describes one fixed return shape; use comma-separated fixed types for multi-return.
- No `?`, `|nil`, or union returns.
- Lua-visible userdata types must use the name the player sees in Lua, e.g. `LButton`, `LCamera`, or the literal returned by `type()`.

**Parameter conventions:** optional params use Lua nil (not sentinel values). Tables for multi-field options. Callbacks accept `(self, ...)` where self is the object. Return self for chainable setters only when the runtime already does that; doc tasks must not change logic.

**Forbidden inside registration closures:** lua.load() (eval), serialization logic, struct construction beyond simple wrappers, iteration algorithms, any business logic. These belong in src/<module>/.

**Callback storage:** use LuaRegistryKey for storing Lua functions across frames. Never store LuaFunction directly (it holds a borrow).

**Validation tool:** tools/validate/validate_lua_api.py src/lua_api/ checks all bindings against these conventions.

**Docs-only refresh rule:** when the task is docstring cleanup or standards alignment, do not change Rust logic, signatures, state handling, tests, or runtime return values. Update comments, generated docs, and standards files only.

## Companion File Index

None - all guidance is inline.

## References

- src/lua_api/timer_api.rs - gold standard API file
- src/lua_api/mod.rs - API registration entry point
- tools/validate/validate_lua_api.py - API convention validator
- tools/docs/gen_lua_api_data.py - docstring parser
