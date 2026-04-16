# IDEA.md — `debugbridge` module

> No `ideas/features/` file. Assembled from `src/debugbridge/` and `src/lua_api/debugbridge_api.rs`.
> Lua namespace: `lurek.debugbridge`.

---

## Purpose

External debug channel: VS Code extension and MCP server connect to the running engine
to inspect and manipulate live game state without modifying Lua scripts.

---

## Features

### ❌ TODO — Lua DAP Protocol (Debug Adapter Protocol)
**Source**: General debug completeness

No DAP server for VS Code Lua debugging (breakpoints, step, variable inspect in Lua files).
This would be a major developer-experience feature — requires integrating a DAP server
with the LuaJIT VM. High effort but transformative.

---

### ❌ TODO — Hot Reload Trigger from Bridge
**Source**: General dev workflow

No remote hot-reload trigger from VS Code extension. Must manually restart engine to pick
up Lua changes (see `src/app/IDEA.md` — hot reload is the #1 missing engine feature).

---

### 🔇 LOW — Screenshot / Video Capture API
**Source**: General bridge capability

No remote screenshot capture via debugbridge. Minor tooling feature.
