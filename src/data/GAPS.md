# Gap Analysis: `src/data`

## 1. Architecture & Compliance (BLOCKER)
- **Module Boundary/Responsibility Violation**: The `data` module currently includes `toml_convert.rs`, which parses TOML strings into `toml::Value`. According to `docs/architecture/engine-architecture.md`, `data` is responsible for binary/byte manipulation, while text format parsing (like JSON, TOML, CSV) is explicitly the responsibility of the `serial` module. Including `toml_convert.rs` in `data` breaks the group responsibility boundaries.

## 2. Thin Wrapper Rule Violation (BLOCKER)
- **`LuaDataView` Location**: The `LuaDataView` wrapper struct is defined in `src/data/dataview.rs` instead of `src/lua_api/data_api.rs`. While the `impl LuaUserData` correctly lives in the `lua_api` module, the `docs/architecture/philosophy.md` "MANDATORY — Thin Wrapper Rule" requires that Lua wrapper structs (`Lua<X>`) must logically live in `src/lua_api/<module>_api.rs`. Domain modules should contain ONLY pure-Rust business logic and domain data types.

## 3. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in `src/data/` does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Uses a bulleted `## Module Info` list instead of the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section. According to the `module-audit` skill, this belongs *only* in `docs/specs/data.md` and strictly does not belong in `AGENT.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/data.md`.

## 4. Code Documentation (PASS)
- Public items are documented.
- No placeholder stub text like `"Consult the module-level documentation..."` was detected in the `src/data/` source files.

## Remediation Steps
1. **Move TOML Logic**: Move `toml_convert.rs` to the `src/serial/` module and update `src/serial/mod.rs` and the corresponding Lua API bridge appropriately. The engine API `lurek.data.parseToml` will need to be rewired to `lurek.serial.parseToml`.
2. **Move Lua Wrapper Type**: Move the definition of `pub struct LuaDataView` from `src/data/dataview.rs` into `src/lua_api/data_api.rs`.
3. **Rewrite `src/data/AGENT.md`**: Convert to the exact short template format required by `.github/skills/module-audit/SKILL.md`. Move the detailed `Key Types` list to `docs/specs/data.md`.
