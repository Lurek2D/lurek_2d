# IDEA.md — `data` module

> Migrated from `ideas/features/data.md`.
> Status checked against `src/data/` and `src/lua_api/data_api.rs`.
> Lua namespace: `lurek.data`.

---

## Features

### 🤔 CONSIDER — Rename Module Namespace
**Source**: features/data.md — Structural Issues

`lurek.data` is very generic — the module specifically handles binary buffer manipulation.
Consider `lurek.buffer` or `lurek.binary` for clarity. This is a **breaking API change**
requiring MAJOR version bump and Lua-Designer sign-off.

---

### 🤔 CONSIDER — Clarify Boundary with `compute`
**Source**: features/data.md — Structural Issues

`data` = I/O-oriented binary manipulation (byte buffers, compression, hashing).
`compute` = mathematical operations on dense numerical arrays (NdArray).
This distinction is correct but undocumented. Add a one-liner to each module's docs and
`docs/specs/data.md` pointing to the other.
