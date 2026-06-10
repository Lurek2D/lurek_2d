# Mod Manager Lab

**Category:** apps / mod tooling  
**Status:** skeleton

Companion tool for validating mod metadata, dependencies, package pipeline steps, and local filesystem state.

**Modules:** `mods`, `validator`, `pipeline`, `filesystem`

Next steps:
- Add local mod list and dependency graph.
- Validate selected mods and show precise failures.
- Connect this app to `rpg/modded_arena`.

Run:

```bash
cargo run -- content/games/apps/mod_manager_lab
```
