---
name: agent-md
description: "Load this skill when creating or maintaining AGENT.md files inside Luna2D src/ module directories. Owns required section structure, content quality rules, sync contracts between AGENT.md/source/Lua API, and the scaffold+validate workflow. Skip it for writing production Rust code, tests, or Lua scripts."
---

# AGENT.md Authoring and Maintenance Skill

## Load When

- Creating a new `src/<module>/AGENT.md` from scratch
- Updating an existing AGENT.md after changing source files, types, or Lua API bindings
- Running `tools/validate_agent_md.py` to check compliance
- Reviewing whether an AGENT.md is in sync with the Lua wrapper

## Owns

- Required section structure and content quality rules for all `src/<module>/AGENT.md` files
- `tools/validate_agent_md.py` — validation and scaffold tool
- Sync contract between AGENT.md, source `.rs` files, `///` docstrings, and `src/lua_api/<module>_api.rs`

## Does Not Cover

- Writing production Rust code → use `rust-coding` skill
- Writing or reviewing Lua API Rust bindings → use `lua-api-design` skill
- End-to-end module quality audits → use `module-audit` skill

## Purpose

Every `src/<module>/` directory MUST contain a hand-maintained `AGENT.md` file.
This file is the canonical domain reference an AI agent reads before working
in that module. It is **not auto-generated** — it is written and updated
by the agent that last touched the module. Scripts can scaffold repetitive
sections and validate completeness, but the prose and accuracy are manual.

Validate with: `python tools/validate_agent_md.py --module <name>`
Scaffold missing sections: `python tools/validate_agent_md.py --scaffold <name>`

---

## Required Sections (ERROR if missing)

### 1. Header Metadata Table

Must be the first content after the `# \`<module>\` — Agent Reference` heading.

```markdown
| Property       | Value                                                |
|----------------|------------------------------------------------------|
| **Tier**       | Tier 1 — Core Engine Subsystems                      |
| **Status**     | Implemented — Full / Partial / Stub                  |
| **Lua API**    | `luna.<module>` (or `—` if none)                     |
| **Source**     | `src/<module>/`                                      |
| **Rust Tests** | `tests/unit/<module>_tests.rs`                       |
| **Lua Tests**  | `tests/lua/unit/test_<module>.lua` (or `—` if none)  |
| **Architecture** | `docs/API/<module>-design.md` (if exists, else `—`) |
```

### 2. `## Summary`

- **Minimum 500 characters, target 1000**
- Must cover: what the module does, how it works, key design decisions, what is
  intentionally NOT included (scope boundary)
- Agents must be able to determine from this alone whether to load this module
  or a different one

### 3. `## Architecture`

ASCII block diagram of the module's internal structure. Show: types, data flow,
subsystems, and relationships between components.

### 4. `## Source Files`

Table mapping every `.rs` file in `src/<module>/` (except `mod.rs`) to its
one-line purpose. Must stay in sync — run `validate_agent_md.py` to detect
unlisted files.

### 5. `## Submodules`

One subsection per Rust submodule. Each entry names the submodule path and
lists every public `struct` and `enum` with a one-line description.

### 6. `## Key Types`

Two H3 subsections: `### Structs` and `### Enums`. Every `pub struct` and
`pub enum` gets an H4 entry with its full path (`<module>::<file>::Name`) and a
description taken from its `///` doc comment. Every public function that is a
constructor or primary operation should be mentioned here too.

### 7. `## Lua API`

Paragraph describing the full Lua-facing surface. Must reference the file
`src/lua_api/<module>_api.rs` (or `src/lua_api/<module>_api/` for module dirs).
Enumerate all exposed function names in `luna.<module>.*`. If there is no Lua API,
write `No Lua API — internal Rust module only.`

### 8. `## Lua Examples`

At least one `\`\`\`lua` block showing real usage of `luna.<module>.*`. Must be
correct against the actual API. Cover the most common use case in `luna.load` /
`luna.update` / `luna.draw` pattern.

### 9. `## Item Summary`

Markdown table:

```markdown
| Kind       | Count |
|------------|-------|
| `struct`   | N     |
| `enum`     | N     |
| `fn`       | N     |
| **Total**  | **N** |
```

### 10. `## References`

List every other module this module relates to, the direction of the
relationship, and the separation of duties. Format:

```markdown
| Module          | Relationship | Notes                           |
|-----------------|--------------|---------------------------------|
| `engine`        | Imports from | Uses SharedState and SlotMap    |
| `math`          | Imports from | Vec2, Color, Rect               |
| `lua_api`       | Imported by  | Binds public API to Lua         |
```

Also include: which modules are **similar** and what differentiates them
(e.g., `sound` vs `audio`, `image` vs `graphics`).

### 11. `## Notes`

Unique facts an agent must know before editing this module:
- Hardware or OS-specific behaviour (e.g., "audio falls back to headless on CI")
- External crate constraints (e.g., "rapier2d 0.32 — do not call from multiple threads")
- Known limitations or intentional omissions
- Best practices for this module (what patterns are safe, which are fragile)
- Breaking change surface (what Lua scripts will break if this API changes)

---

## Sync Contract

`AGENT.md` is the single manual truth source. Keep it in sync with:

| What changes               | What to update in AGENT.md                        |
|----------------------------|----------------------------------------------------|
| New `.rs` file added       | Source Files table + Submodules section            |
| New `pub struct` / `enum`  | Submodules, Key Types, Item Summary count          |
| New Lua binding added      | Lua API section + Lua Examples code block          |
| Lua binding renamed        | Lua API section + Lua Examples                     |
| Dependency added / removed | References table + Notes if behaviour changes      |
| Scope boundary change      | Summary + Notes                                    |

**Rule**: If you touched a `.rs` file in `src/<module>/` or its Lua API wrapper,
you MUST update `AGENT.md` before the commit.

---

## Scaffolding vs Manual Prose

The scaffold tool (`validate_agent_md.py --scaffold`) auto-fills:
- Source Files table (from `src/<module>/*.rs`)
- Submodules skeleton (from `//!` doc comments)
- Key Types skeleton (from `pub struct` / `pub enum` names)
- Item Summary counts (from a source scan)

**All prose descriptions inside those sections are manual.** The scaffold
produces `TODO:` placeholders that must be replaced with accurate descriptions.
Do not leave `TODO:` entries in committed AGENT.md files.

---

## Anti-Patterns

- Writing Lua API descriptions without consulting `src/lua_api/<module>_api.rs`
- Copying struct descriptions from a different module
- Leaving the Summary under 500 characters
- Omitting the References table (forces agents to guess dependencies)
- Describing functions that no longer exist
- Duplicating architecture facts that live in `docs/architecture/`
  (reference, don't copy)
