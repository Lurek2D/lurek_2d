---
name: threading
description: "Load this skill when designing or implementing multi-threaded Lua behaviour in Lurek2D using the lurek.thread API: spawning worker threads, using Channel for inter-VM communication, handling errors in background threads, or understanding which lurek.* modules are safe to use in worker VMs. Use for: background computation, async file I/O in workers, producer-consumer patterns, parallel data processing. Skip it for Rust-side thread management internals (see docs/specs/thread.md), or for general game scripting (use lua-scripting)."
---
# threading

## Mission

Own the lurek.thread API patterns: one-VM-per-thread model, Channel-based communication, worker VM module availability, and thread lifecycle management.

## When To Load

- Spawning Lua worker threads for background computation
- Using Channel for inter-VM communication
- Determining which lurek.* modules are safe in worker VMs
- Implementing producer-consumer or parallel processing patterns

## When To Skip

- Rust-side thread management -> see docs/specs/thread.md
- General game scripting -> use lua-scripting skill

## Domain Knowledge

**Core model:** one Lua VM per thread, no shared state between VMs. All cross-VM communication uses Channel objects. This is a hard constraint from LuaJIT's design (binding constraint B-04).

**Thread creation:** lurek.thread.newThread(code_string) creates a new thread with an isolated Lua VM. The code string is compiled and executed in the new VM.

**Channel API:** push(value) is non-blocking, adds to queue. pop() is non-blocking, returns value or nil. demand() BLOCKS until a value is available. peek() reads without removing. getCount() returns queue length. clear() empties the queue.

**ChannelValue types:** only nil, boolean, number, and string can be sent through channels. For structured data, serialize to string (e.g., JSON via lurek.data) before pushing.

**Worker-safe modules (available in worker VMs):** math, thread, timer (read-only), filesystem (read-only), runtime (read-only), data, image.

**Worker-unsafe modules (main thread only):** render, audio, physics, input. Calling these from a worker thread will error.

**Critical anti-pattern:** NEVER call demand() in update() or draw() — it blocks the main thread and freezes the game. Use pop() (non-blocking) in the main thread, demand() only in worker threads.

**Thread lifecycle:** threads do not auto-stop when the game exits. Always send a "quit" message through the channel and have workers check for it in their main loop.

## Companion File Index

None - all guidance is inline.

## References

- src/thread/ - Rust thread module
- src/lua_api/thread_api.rs - Lua thread bindings
- docs/specs/thread.md - thread module specification
