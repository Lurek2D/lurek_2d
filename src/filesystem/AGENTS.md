# FS Module Contract

## Mission & Scope
- Own sandboxed file access, mounts, and stream handles.
- Keep script I/O inside controlled workspace/game paths.

## Files
- `vfs.rs`: Virtual roots, path checks, and file access.
- `file_data.rs`, `file_handle.rs`: File values and open handles.
- `async_loader.rs`, `watcher.rs`: Background loads and file watching.

## Rules
- Normalize paths before access and reject traversal outside the sandbox.
- Keep mount precedence deterministic.
- Do not expose host absolute paths through Lua-facing errors.

## Workflow
- Validate with `cargo test --test filesystem_tests`.
