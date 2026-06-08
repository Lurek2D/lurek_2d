---
name: cross-platform
description: "Load this skill when handling platform-specific code, cfg gates, or Windows/Linux/macOS differences. Skip it for pure game logic or Lua scripts."
---
# cross-platform

## Use when
- Add cfg-gated code.
- Handle OS-specific file or window behavior.
- Review Windows, Linux, or macOS differences.
- Check portability of a build or runtime change.

## Avoid when
- Pure game logic.
- Lua script work.

## Repo rules
- Targets: Windows x86_64, Linux x86_64, macOS x86_64, macOS ARM64. No mobile, no WASM.
- Windows is the primary development and CI platform. PowerShell 5.1 is the min shell version.
- Platform drift checklist for path handling: use `std::path::Path` and `PathBuf`, never use `\` as a path separator literal, never use `:` or drive letters in GameFS paths, never call `std::fs` directly. Use GameFS..
- `winit` and `wgpu` abstract most platform differences for window and GPU. Check `winit`/`wgpu` issues before adding platform `cfg` blocks.
- Platform pattern: Isolate in `platform/` or `cfg` block with comment explaining why. No undocumented `cfg` blocks.
- Audio differences: `rodio` has platform-specific output device enumeration. Windows uses WASAPI, Linux uses ALSA/PipeWire, macOS uses CoreAudio.
- Install script behavior: `tools/dist/install.ps1` targets Windows only. Linux installation is manual or via a future Makefile.
- CI platform testing minimum: Windows x86_64, Linux x86_64. macOS can use the free GitHub Actions macOS runner but is optional given resource cost.
- Add test for cfg-gated features. Untested gates regress.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `src/window/`
- `src/app/`
- `src/filesystem/`
- `tools/dist/`
- `Cargo.toml`

