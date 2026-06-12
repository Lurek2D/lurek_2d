# FS Module Contract

## Mission & Scope
- Own sandboxed file access, mounts, archive reads, and stream handles.
- Keep script I/O inside controlled workspace/game paths.

## Files
- `path.rs`, `mount.rs`: Normalization and virtual roots.
- `file.rs`, `archive.rs`: Handles and archive-backed reads.

## Rules
- Normalize paths before access and reject traversal outside the sandbox.
- Keep mount precedence deterministic.
- Do not expose host absolute paths through Lua-facing errors.

## Workflow
- Validate with `cargo test --test filesystem_tests`.
