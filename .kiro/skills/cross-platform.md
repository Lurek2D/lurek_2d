---
inclusion: manual
---

# cross-platform

## Mission
Own platform-specific Rust behavior and compatibility rules.

## When To Use
- Add cfg-gated code.
- Handle OS-specific file or window behavior.
- Review Windows, Linux, or macOS differences.
- Check portability of a build or runtime change.

## When To Skip
- Pure game logic, Lua script work.

## Rules

### Supported Targets
Windows x86_64, Linux x86_64, macOS x86_64, macOS ARM64. No mobile, no WASM (binding constraint A-02). Never add `cfg(target_os = "android")` or `cfg(target_arch = "wasm32")`.

### Windows as Primary
Windows is the primary development and CI platform. PowerShell 5.1 minimum for scripts — do not use PowerShell 7-only syntax (`??=`, `ForEach-Object -Parallel`).

### Path Handling Checklist
1. Use `std::path::Path` and `PathBuf`.
2. Never use `\` as a path separator literal.
3. Never use `:` or drive letters in GameFS paths.
4. Never call `std::fs` directly in engine modules — use GameFS.

### winit and wgpu
These abstract most platform differences. When a window/GPU issue is platform-specific, check `winit`/`wgpu` issue trackers before adding a `cfg` branch.

### Platform-Specific Code Pattern
Isolate in a `platform/` submodule or behind a `cfg` block with a `// Platform-specific:` comment explaining why the branch exists. Undocumented `cfg` branches are invisible maintenance debt.

### Audio Differences
`rodio` uses: Windows = WASAPI, Linux = ALSA/PipeWire, macOS = CoreAudio. The Lua API surface is identical on all platforms. Test `lurek.audio.devices()` separately on each target.

### Install Scripts
`tools/dist/install.ps1` targets Windows only. Linux installation is manual. Document clearly which install path applies to which platform.

### Testing cfg Branches
When adding a cfg-gated feature, add a corresponding test or smoke scenario that exercises the cfg path on the affected platform. An untested cfg branch will regress at next update.

## References
- `src/window/`
- `src/app/`
- `src/filesystem/`
- `tools/dist/`
- `Cargo.toml`
