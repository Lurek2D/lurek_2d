# IDEA.md — `thread` module

> Migrated from `ideas/features/thread.md`.
> Status checked against `src/thread/` and `src/lua_api/thread_api.rs`.
> Lua namespace: `lurek.thread`.

---

## Features

### ✅ DONE — Isolated Lua VM Worker Threads
**Source**: features/thread.md — Summary

`lurek.thread.new(code)` — spawns isolated LuaJIT VM in OS thread.

---

### ✅ DONE — MPMC Channel with Push / Pop / Peek / Demand / Supply
**Source**: features/thread.md — Summary

Typed MPMC channel for inter-thread communication.

---

### ✅ DONE — Channel Demand with Timeout
**Source**: features/thread.md — Feature Gaps #7 (IMPLEMENTED)

`channel:demand(timeout)` with optional timeout parameter found at `thread_api.rs:181`.

---

### ✅ DONE — Thread Error Propagation
**Source**: features/thread.md — Summary

`thread:getError()` retrieves error from failed worker.

---

### ✅ DONE — `call_in_main` (Main-Thread Scheduling from Worker)
**Source**: features/thread.md — Summary

Workers can schedule callbacks onto the main thread via `call_in_main`.

---

### ✅ DONE — Table Serialization Through Channels
**Source**: features/thread.md — Feature Gaps #1 / Suggestions #1

`ChannelValue::Table(Vec<(ChannelValue, ChannelValue)>)` variant in `src/thread/channel.rs`.
`channel:pushTable(t)` and `channel:popTable()` registered in `src/lua_api/thread_api.rs`.
Recursive serialization — nested tables are fully supported.

---

### ✅ DONE — Thread Pool
**Source**: features/thread.md — Feature Gaps #2 / Suggestions #2

`lurek.thread.newPool(n, workerCode)` in `src/lua_api/thread_api.rs`.
`LuaThreadPool` userdata: `submit`, `collect`, `join`, `size`, `getInputChannel`, `getOutputChannel`.
Backed by `src/thread/pool.rs` — reuses `n` pre-spawned worker VMs.

---

### ✅ DONE — Filesystem Read Access in Workers
**Source**: features/thread.md — Feature Gaps #4 / Suggestions #4

`lurek.fs.read(path)` registered in worker VMs via `register_thread_safe_modules()` in
`src/thread/worker.rs`. Path-traversal guard (`..` check) is applied. Enables background
asset loading without main-thread round-trips.

---

### ✅ DONE — ByteData Channel Type
**Source**: features/thread.md — Suggestions #6

`ChannelValue::Bytes(Vec<u8>)` variant added to `src/thread/channel.rs`.
`channel:pushBytes(data)` and `channel:popBytes()` registered in `src/lua_api/thread_api.rs`.
Aligns with `lurek.data.ByteData` for audio samples, texture pixels, and save-data blobs.

---

### ✅ DONE — Promise / Future Sugar
**Source**: features/thread.md — Feature Gaps #3 / Suggestions #3

`lurek.thread.async(fn, args)` in `src/lua_api/thread_api.rs` returns `LuaPromise`.
`LuaPromise` userdata: `isDone()`, `result()`, `getError()`.
Backed by `src/thread/promise.rs` — worker writes result to `__promise_result` channel.

---

### ✅ DONE — Worker Module System (`require`)
**Source**: features/thread.md — Feature Gaps #6

`package.path = "./?.lua;./?/init.lua"` set in `register_thread_safe_modules()` in
`src/thread/worker.rs`. Workers can `require` any Lua module accessible from the game folder.
