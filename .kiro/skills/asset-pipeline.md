---
inclusion: manual
---

# asset-pipeline

## Mission
Own asset loading, sandboxed file access, and cache rules.

## When To Use
- Changing GameFS behavior.
- Loading images, audio files, or Lua scripts.
- Adding or tuning asset cache rules.
- Reviewing path safety for asset access.

## When To Skip
- Render pipeline logic, audio playback logic.

## Rules

### GameFS Boundary
- All asset loads must go through `lurek.fs.*` or the Rust `GameFS` API in `src/filesystem/`.
- Direct host path access (`std::fs::read`) inside `src/<module>/` is a defect — it bypasses sandbox rules, breaks relative-path portability, and makes content roots non-fungible.

### Path Normalization
- Convert `\` to `/`, collapse `..` and `.` segments, and lower-case the extension before building a cache key.
- The canonical path is the GameFS-relative string after normalization.
- Two callers with `sprites/hero.png` and `./sprites/hero.png` must hit the same cache slot.

### Layer Ownership
- `src/filesystem/` — sandbox rules, path normalization, access control.
- `src/image/` — decode PNG/JPEG/LIMG to raw RGBA.
- `src/audio/source.rs` — decode WAV/OGG to PCM.
- Render and mixer consume decoded output; they do not own decode.
- Script loader is a separate pipeline from asset loader.

### Supported Formats
- Images: PNG, JPEG, LIMG.
- Audio: WAV, OGG.
- Scripts: `.lua` only.
- Any other format produces a clear error, not a silent fallback.
- When adding a new format, update `docs/specs/filesystem.md` under Supported Formats.

### Cache Invalidation
- Cache key: `(normalized-path, mount-point-id)`.
- Invalidate on unmount or explicit `lurek.fs.cache_clear()`.
- Never invalidate on scene change unless a new content root is mounted for that scene.

### Special Directories
- `save/` is runtime state, not a content root. Do not load game assets from `save/`.
- `mods/` is a secondary content root with lower priority than the primary game root. A mod asset shadows the game asset only when the mod is explicitly mounted.

### Hot-Reload
- `lurek.fs.watch(path, callback)` watches a file for changes.
- In release/dist builds, this API is a no-op. Content that depends on hot-reload must not break when the watcher is absent.

### Error Contract
- Asset errors surface as `mlua::Error::RuntimeError` with pattern: `"lurek.image.load: file not found: <normalized-path>"`.
- Never let a missing asset produce a panic, a blank default, or a log message that the author cannot see.

## References
- `src/filesystem/`
- `src/image/`
- `src/audio/source.rs`
- `docs/specs/filesystem.md`
