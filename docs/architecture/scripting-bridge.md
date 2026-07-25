# Lua-Rust Scripting Bridge

## Purpose

The scripting bridge defines how Rust-owned behavior becomes the public `lurek.*` Lua API. It owns registration, conversion, callback invocation, Lua-visible errors, and VM lifetime rules.

## Boundary Shape

```text
Lua script
  -> registered lurek.* function or userdata method
  -> argument conversion and validation
  -> Rust domain owner
  -> result conversion or Lua error
```

`src/lua_api/` owns the public names and registration graph. Domain modules may use `mlua` internally when Lua identity is essential—for example stored callbacks or arbitrary Lua values—but they do not register an independent public surface.

## Registration

1. Runtime construction creates the Lua VM and shared Rust owners.
2. Binding modules register `lurek.*` tables, functions, userdata, and callbacks.
3. Each wrapper captures only the shared owner access required for its operation.
4. Script loading begins only after registration succeeds.

A registration failure aborts startup. Partial registration is not a supported runtime mode.

## Wrapper Rules

- Validate names, ranges, handles, paths, and table shapes before mutating domain state.
- Convert Lua values at the boundary and call the existing Rust owner.
- Keep reusable algorithms and policy out of wrappers.
- Return documented absence for expected misses and Lua errors for invalid requests or failed operations.
- Preserve callback/table identity only when the owning feature requires it.
- Do not hold Rust borrows across calls back into Lua.

## Callback Lifecycle

- The runtime discovers optional lifecycle callbacks after script load.
- Stored callbacks remain valid only while their Lua VM and owning registry remain alive.
- Invocation enters Lua through the runtime owner, records callback context, and translates errors with the callback name.
- Disabling or unregistering a callback releases the registry reference.
- Shutdown clears registries before dropping the VM.

Re-entrant Lua calls are allowed only where the owning API explicitly supports them. Async or worker completion must return to the VM-owning thread before invoking Lua.

## Handles And Userdata

- Rust owns resources and mutable domain state.
- Lua receives userdata or opaque IDs with checked operations.
- Each use validates that the handle exists and matches the expected owner/type.
- Release removes or invalidates the owned entry.
- Lua garbage collection does not silently define GPU, audio, physics, or scene-resource lifetime unless the userdata contract explicitly implements that behavior.

Handles copied into saves are data only. Restore recreates owned resources through validated APIs.

## Filesystem And Trust

Script paths pass through the game filesystem and mods/filesystem policy before host access. Bindings must not turn user-controlled paths into unrestricted host paths. Imported bytes remain external input until the target parser validates them.

## Error And Fallback Rules

- Missing optional callbacks: no-op.
- Unknown optional query result: documented `nil`, `false`, or empty result.
- Invalid arguments, handles, or forbidden paths: Lua error with owner context.
- Rust/domain failure: translate the structured error; do not panic across the boundary.
- Callback failure: stop the affected call, retain primary Rust ownership, and report the callback name.

## Documentation And Tests

Source binding docs own signatures and public descriptions. Generated API artifacts expose them; specs add module intent; examples demonstrate use; Lua tests prove the public boundary. Rust tests cover conversion and private owner seams that cannot be expressed through the public API.
