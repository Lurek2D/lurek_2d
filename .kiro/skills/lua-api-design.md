---
inclusion: manual
---

# lua-api-design

## Mission
Own the public `lurek.*` API shape for game authors.

## When To Use
- Add or change a `lurek.*` function.
- Review naming or param shape.
- Align callbacks and return types.

## When To Skip
- Rust internals, pure Lua game scripts.

## Rules

### Namespace Rule
All public functions live under `lurek.*` exactly — no bare globals, no `engine.*`, no alternative top-level tables (binding constraint C-01).

### Design Snippet First
Test the API shape with a short Lua snippet in `content/examples/` before writing binding code. A design flaw in a 10-line sketch costs nothing; the same flaw in a bound+tested+documented API costs a breaking change.

### Arity Rule
Prefer fixed-arity functions or option tables. Avoid optional positional arguments beyond 2. `lurek.sprite.draw(sprite, x, y, opts)` is acceptable; `lurek.sprite.draw(sprite, x, y, rot, sx, sy, ox, oy)` is not.

### Return Shape
Must be stable and documented. Functions that return `nil` on failure should say so explicitly in the docstring. Never return `nil` and `error` depending on context for the same function — choose one pattern per function.

### Callback Contracts
Must state: when it fires (frame phase), what arguments it receives (types and units), what happens if it raises an error, and whether it fires once or repeatedly.

### Naming Consistency
Check `src/lua_api/register.rs` and `docs/api/lurek.md` for existing naming patterns before proposing a name.

### Validation
Run `python tools/validate/validate_lua_api.py` on any new or changed binding to verify docstring shape, argument naming, and type annotation completeness.

### Migration Notes Are Mandatory For
Changed argument order, renamed params, removed functions, changed return type, changed callback signature. Migration notes go in `docs/specs/<module>.md`.

### Library vs Core
If a proposed function is only useful for one game genre, check `library/` first. Core `lurek.*` is for universal game behaviors; domain logic belongs in library modules.

### Enums as Strings
Represent as Lua strings with a small closed set, documented in the docstring. An open set is a design smell.

### Generated Files
`docs/api/lurek.lua` and `docs/api/lurek.md` are generated — never hand-edit them. Fix docstring issues in `src/lua_api/<module>_api.rs`, then regenerate with `python tools/gen_all_docs.py`.

## References
- `src/lua_api/`
- `src/lua_api/register.rs`
- `docs/api/lurek.md`
- `docs/specs/`
- `content/examples/`
