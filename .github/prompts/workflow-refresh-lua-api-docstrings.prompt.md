---
description: "Refresh one or more src/lua_api/*_api.rs files to the fixed docstring standard, and update related standards docs when the file structure or format changed. Docs-only task: no Rust logic changes."
agent: developer
loads_tools:
  - tools/validate/validate_lua_api.py
  - tools/validate/cag_validate.py
  - tools/docs/gen_lua_api_data.py
  - tools/docs/gen_extension_api.py
  - tools/docs/gen_luadoc.py
  - tools/docs/gen_docs_lua.py
---
# Workflow Refresh Lua Api Docstrings

## Goal

Refresh one or more `src/lua_api/*_api.rs` files to the current Lurek2D docstring standard, and keep the related standards docs in sync when the structure or conventions changed. This prompt is **docs-only**: it rewrites docstrings and docs, but must not change Rust logic.

## Inputs

- `target_modules` - comma-separated module names or file paths, for example `event,timer,camera` or `src/lua_api/event_api.rs`.

## Steps

1. Load [skill: lua-api-design](../skills/lua-api-design/SKILL.md), [skill: documentation](../skills/documentation/SKILL.md), and [skill: cag-workflow](../skills/cag-workflow/SKILL.md) before changing any files.
2. Read the current bridge structure in [src/lua_api/mod.rs](../../src/lua_api/mod.rs), [src/lua_api/register.rs](../../src/lua_api/register.rs), and [src/lua_api/lua_types.rs](../../src/lua_api/lua_types.rs).
3. Read the current standard in [docs/specs/lua-api-file-standard.md](../../docs/specs/lua-api-file-standard.md).
4. If the conventions or file structure drifted, update these standards first:
   - [docs/specs/lua-api-file-standard.md](../../docs/specs/lua-api-file-standard.md)
   - [lua-api-design skill](../skills/lua-api-design/SKILL.md)
   - [documentation skill](../skills/documentation/SKILL.md)
5. For each target module file under `src/lua_api/`, rewrite docstrings only. Do **not** change Rust logic, control flow, state handling, runtime return values, tests, or signatures.
6. Use exactly this docstring format for every Lua-visible function and method:
   - `/// One sentence.`
   - `/// @param | name | type | description`
   - `/// @return | type[, type...] | description`
7. Keep the first `///` line to one sentence on one line. Do not add extra prose lines between the description and the tags.
8. Use Lua-visible type names exactly as the user sees them in Lua, for example `LButton`, `LCamera`, `LWorld`, or the literal `TYPE_NAME` returned by `type()`.
9. Return types must be fixed. Allowed: one fixed type, `nil`, or a comma-separated fixed tuple like `boolean, number`. Forbidden: `?`, `|nil`, `string|table`, or any other union-style return.
10. After editing the target modules, run:
    - `python tools/validate/validate_lua_api.py <touched file(s)>`
    - `python tools/docs/gen_lua_api_data.py --output logs/data/lua_api_data.json`
    - `python tools/docs/gen_extension_api.py --input logs/data/lua_api_data.json --output extensions/vscode/data/lurek-api.json`
    - `python tools/docs/gen_luadoc.py`
    - `python tools/docs/gen_docs_lua.py`
11. Run `python tools/validate/cag_validate.py` only if any `.github/` file changed.
12. Do **not** run `cargo test`, `cargo clippy`, or any runtime smoke tests for this prompt unless a separate task explicitly changes Rust logic.

## Success Criteria

- [ ] Every touched `src/lua_api/*_api.rs` file uses only the fixed pipe-delimited docstring format.
- [ ] No touched Lua API file has Rust logic changes.
- [ ] `python tools/validate/validate_lua_api.py` passes for every touched Lua API file.
- [ ] `logs/data/lua_api_data.json`, `extensions/vscode/data/lurek-api.json`, `docs/api/lurek.lua`, and `docs/api/lurek.md` are regenerated.
- [ ] `python tools/validate/cag_validate.py` passes if any `.github/` artifact changed.

## Anti-patterns

- Changing Rust logic, runtime return values, signatures, or tests during a docstring-only refresh.
- Keeping legacy docstring formats such as `@param name type`, `@param name : type`, or `@return type`.
- Writing Rust wrapper names like `LuaCamera2D` when the Lua-visible type is `LCamera`.
- Inventing semantics for a function instead of describing what the current code actually does.
- Running `cargo test` or other runtime checks when only docs and docstrings changed.

## Example Invocation

> Run this prompt via VS Code Copilot Chat: `/workflow-refresh-lua-api-docstrings event,timer,camera,window,log`

## CAG Metadata

- **Mode**: agent
- **Loads skills**: lua-api-design, documentation, cag-workflow
- **Inputs required**: target_modules