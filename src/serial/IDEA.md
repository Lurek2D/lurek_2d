# IDEA.md — `serial` module

> Migrated from `ideas/features/serial.md`.
> Status checked against `src/serial/` and `src/lua_api/serial_api.rs`.
> Lua namespace: `lurek.codec`.

---

## Features

### 🤔 CONSIDER — Unified Format Parameter API
**Source**: features/serial.md — Suggestions #4

Instead of format-specific functions, a single:
```lua
lurek.codec.encode(tbl, "json")
lurek.codec.decode(str, "json")
```
Easier to switch formats programmatically. Both APIs could co-exist.
