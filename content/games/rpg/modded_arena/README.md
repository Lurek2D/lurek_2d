# Modded Arena

**Category:** rpg / moddable combat  
**Status:** skeleton

Arena RPG where enemies, loot rules, and NPC dialog can be loaded from local mod packs.

**Modules:** `mods`, `filesystem`, `asset`, `save`, `dialog`

Next steps:
- Add example mod folders inside this demo.
- Load enemy and loot definitions from mod metadata.
- Persist enabled mods and validate compatibility.

Run:

```bash
cargo run -- content/games/rpg/modded_arena
```
