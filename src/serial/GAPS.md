# Gap Analysis: `src/serial`

## 1. Architecture & Compliance (BLOCKER)
- **Thin Wrapper Rule Violation**: `src/serial/lua_table.rs` imports `mlua` (`mlua::prelude::{Lua, LuaResult, ...}`) and performs explicit conversion between `SerialValue` and `LuaValue`. The `docs/architecture/philosophy.md` "MANDATORY — Thin Wrapper Rule" requires that `mlua` imports and all Lua mapping logic MUST live strictly inside `src/lua_api/<module>_api.rs`. Domain modules must contain strictly pure-Rust logic without any knowledge of the Lua layer.

## 2. Duplicate / Ghost Code (WARNING)
- **`src/serial/yaml.rs` is dead code**: As per B-05 ("TOML is the human-authored config format... No YAML"), the `.rs` file has been detached from `mod.rs` (commented out), but the physical file `src/serial/yaml.rs` still remains in the directory. It is uncompiled zombie code and should be removed.
- **Duplicated TOML logic**: `src/serial/toml.rs` implements TOML conversion in its rightful module. However, `src/data/toml_convert.rs` also exists, representing a responsibility drift. Both should be consolidated, ideally under `serial`, keeping true to the engine's serialization boundaries.

## 3. AGENT.md Structure (BLOCKER / ERROR)
The `AGENT.md` file in `src/serial/` does **not** adhere to the canonical short format required by the CAG rules (A-02).
- **Missing / Incorrect Metadata Table**: Uses a bulleted `## Module Info` list instead of the required markdown table format (with `**Tier**`, `**Status**`, etc.).
- **Wrong Headings**: Uses `## Module Purpose` instead of `## Purpose`, and `## Files` instead of `## Source Files`.
- **Forbidden Sections**: Contains a `## Key Types` section. According to the `module-audit` skill, this belongs *only* in `docs/specs/serial.md` and strictly does not belong in `AGENT.md`.
- **Missing Required Link**: Lacks the `## Full Specification` section linking to `docs/specs/serial.md`.

## 4. Code Documentation (PASS)
- Public items generally have docstrings. I did not detect `"Consult the module-level documentation..."` placeholders here.

## Remediation Steps
1. **Remove `mlua` from the domain**: Move all logic that converts `SerialValue` to/from `LuaValue` out of `src/serial/lua_table.rs` and into `src/lua_api/serial_api.rs`.
2. **Rename/Refactor**: `lua_table.rs` is a poor core representation name if it is stripped of mlua bindings. It should likely be renamed to `serial_value.rs` representing the pure-Rust intermediate ast tree.
3. **Delete `yaml.rs`**: Delete `src/serial/yaml.rs` entirely.
4. **Fix Duplicate TOML Logic**: Assimilate `src/data/toml_convert.rs` functionality into `src/serial/` and delete from `src/data/`.
5. **Rewrite `src/serial/AGENT.md`**: Convert to the exact short template format required by `.github/skills/module-audit/SKILL.md`.
