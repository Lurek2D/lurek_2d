# `bin` — Agent Reference

| Property | Value |
|----------|-------|
| **Tier** | Unassigned |
| **Status** | Implemented — Full |
| **Lua API** | `—` |
| **Source** | `src/bin/` |
| **Rust Tests** | `tests/unit/bin_tests.rs` |
| **Lua Tests** | `tests/lua/unit/test_bin.lua` |
| **Architecture** | — |

## Summary

The `bin` module contains the `lunec` compiler binary entry point — a minimal CLI wrapper that
accepts a game directory path, runs the Luna2D engine in headless mode to syntax-check the
game's Lua scripts, and reports any parse or runtime errors to stderr with an exit code.

`lunec` is distinct from the main `luna2d` binary: it performs a dry-run validation pass
(no window, no GPU, no audio) and exits after the `luna.load()` callback returns, making it
suitable for use in CI pipelines and editor extensions.

The source file is `src/bin/lunec.rs`. It is not a library module; it exposes no public Rust
API and has no Lua bindings. Configuration uses the same `conf.lua` → `Config` path as the
main runtime.

**Scope boundary**: `lunec` delegates all engine logic to the `luna2d` library crate. Its
sole responsibility is argument parsing, headless execution, and exit-code propagation.
## Architecture

```
bin (module root)
  ├── lunec.rs — # lunec — Console-less Luna2D Launcher This is an alternative binary entry point for Luna2D that suppresses the console window on Windows by setting the `windows_subsystem = "windows"` attribute. Behavior is otherwise identical to the main `luna2d` binary. ## Purpose When distributing a game to end users on Windows, running via `lunec.exe` prevents the black terminal window from appearing alongside the game window. This provides a polished, professional feel for released games. ## Usage ```sh lunec path/to/my_game     # Launch game without console window lunec                     # Splash screen, no console ``` ## Platform Notes - **Windows**: `windows_subsystem = "windows"` hides the console. - **Linux/macOS**: No behavioral difference from the standard binary; the attribute is ignored on non-Windows platforms.
```

## Source Files

| File | Purpose |
|------|---------|
| `lunec.rs` | # lunec — Console-less Luna2D Launcher This is an alternative binary entry point for Luna2D that suppresses the console window on Windows by setting the `windows_subsystem = "windows"` attribute. Behavior is otherwise identical to the main `luna2d` binary. ## Purpose When distributing a game to end users on Windows, running via `lunec.exe` prevents the black terminal window from appearing alongside the game window. This provides a polished, professional feel for released games. ## Usage ```sh lunec path/to/my_game     # Launch game without console window lunec                     # Splash screen, no console ``` ## Platform Notes - **Windows**: `windows_subsystem = "windows"` hides the console. - **Linux/macOS**: No behavioral difference from the standard binary; the attribute is ignored on non-Windows platforms. |

## Submodules

### `bin::lunec`

# lunec — Console-less Luna2D Launcher This is an alternative binary entry point for Luna2D that suppresses the console window on Windows by setting the `windows_subsystem = "windows"` attribute. Behavior is otherwise identical to the main `luna2d` binary. ## Purpose When distributing a game to end users on Windows, running via `lunec.exe` prevents the black terminal window from appearing alongside the game window. This provides a polished, professional feel for released games. ## Usage ```sh lunec path/to/my_game     # Launch game without console window lunec                     # Splash screen, no console ``` ## Platform Notes - **Windows**: `windows_subsystem = "windows"` hides the console. - **Linux/macOS**: No behavioral difference from the standard binary; the attribute is ignored on non-Windows platforms.

## Key Types

### Structs

No public structs.

### Enums

No public enums.

## Lua API

No Lua API — internal Rust module only.

## Lua Examples

```lua
-- TODO: Add usage example
```

## Item Summary

| Kind | Count |
|------|-------|
| `struct` | 0 |
| `enum`   | 0 |
| `fn`     | 0 |
| **Total** | **0** |

## References

| Module | Relationship | Notes |
|--------|--------------|-------|
| `engine` | Imports from | Uses SharedState, EngineError |
| `math` | Imports from | Vec2, Color, Rect |
| `lua_api` | Imported by | Binds public API to Lua |

TODO: Add entries for similar modules and explain the separation of duties.

## Notes

TODO: Document unique facts an agent must know before editing this module:
- External crate constraints (version, thread-safety, API limitations)
- Hardware or OS-specific behaviour (e.g., headless fallback on CI)
- Known limitations or intentional omissions
- Best practices and anti-patterns for this module
- What Lua scripts will break if the API changes
