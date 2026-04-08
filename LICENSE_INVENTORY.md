# License Inventory

Status: explicit module and direct dependency license inventory reviewed on 2026-04-08.

Purpose: answer two concrete questions for this repository:

1. Which first-party modules and packages are in the project?
2. Which direct dependencies are used, and what licenses do they carry?

This document is not legal advice.

## 1. Direct Answer

- ML or inference models found in the repository: none.
- First-party Luna2D Rust modules: MIT.
- First-party Lua library modules under `library/`: MIT.
- Root Rust package `luna2d`: MIT.
- First-party VS Code extension package `luna2d-vscode`: MIT.
- Direct Cargo dependencies reviewed here: permissive only. No direct GPL, LGPL, or AGPL dependency was identified in `Cargo.toml`.
- Direct VS Code extension runtime dependency reviewed here: MIT.

## 2. Scope

### Included

- First-party compiled Rust modules declared in `src/lib.rs`.
- First-party Lua library modules under `library/`.
- Direct dependencies declared in `Cargo.toml`.
- Direct runtime dependency declared in `vscode-extension/package.json`.

### Excluded from this table

- Fonts and other asset provenance review.
- Full transitive license notice packs for every Cargo and npm dependency.
- Generated outputs under `build/`, `dist/`, `target/`, `logs/`, `save/`, and `work/`.

## 3. First-Party Packages

| Package | Path | License | Notes |
|---|---|---|---|
| luna2d | `Cargo.toml` | MIT | Root engine package. |
| luna2d-vscode | `vscode-extension/package.json` | MIT | First-party VS Code extension package. |
| Repository-authored docs, demos, examples, and tools | `docs/`, `demos/`, `examples/`, `tools/` | MIT | Covered by the repository root MIT license unless a file states otherwise. |

## 4. First-Party Rust Modules

All currently compiled Rust modules listed below are first-party Luna2D code and therefore covered by the root MIT license.

| Module | Path | License |
|---|---|---|
| ai | `src/ai/` | MIT |
| animation | `src/animation/` | MIT |
| audio | `src/audio/` | MIT |
| automation | `src/automation/` | MIT |
| camera | `src/camera/` | MIT |
| compute | `src/compute/` | MIT |
| data | `src/data/` | MIT |
| dataframe | `src/dataframe/` | MIT |
| serial | `src/serial/` | MIT |
| engine | `src/engine/` | MIT |
| entity | `src/entity/` | MIT |
| event | `src/event/` | MIT |
| filesystem | `src/filesystem/` | MIT |
| graph | `src/graph/` | MIT |
| graphics | `src/graphics/` | MIT |
| gui | `src/gui/` | MIT |
| image | `src/image/` | MIT |
| input | `src/input/` | MIT |
| light | `src/light/` | MIT |
| fx | `src/fx/` | MIT |
| math | `src/math/` | MIT |
| minimap | `src/minimap/` | MIT |
| modding | `src/modding/` | MIT |
| network | `src/network/` | MIT |
| particle | `src/particle/` | MIT |
| pathfinding | `src/pathfinding/` | MIT |
| physics | `src/physics/` | MIT |
| pipeline | `src/pipeline/` | MIT |
| procgen | `src/procgen/` | MIT |
| raycaster | `src/raycaster/` | MIT |
| savegame | `src/savegame/` | MIT |
| scene | `src/scene/` | MIT |
| spine | `src/spine/` | MIT |
| lua_api | `src/lua_api/` | MIT |
| terminal | `src/terminal/` | MIT |
| thread | `src/thread/` | MIT |
| tilemap | `src/tilemap/` | MIT |
| timer | `src/timer/` | MIT |
| window | `src/window/` | MIT |

### Migration-state module names

These names are no longer compiled as active Rust modules in `src/lib.rs`, but they still exist as first-party Luna2D domain names through the Lua library layer.

| Name | Current form | License |
|---|---|---|
| battle | `library/battle/` | MIT |
| cardgame | `library/cardgame/` | MIT |
| combat | `library/combat/` | MIT |
| crafting | `library/crafting/` | MIT |
| dialog | `library/dialog/` | MIT |
| economy | `library/economy/` | MIT |
| inventory | `library/inventory/` | MIT |
| item | `library/item/` | MIT |
| province_map | `library/province_map/` | MIT |
| quest | `library/quest/` | MIT |
| stats | `library/stats/` | MIT |

## 5. First-Party Lua Library Modules

All Lua library modules under `library/` are first-party Luna2D code and therefore MIT-licensed.

| Library Module | Path | License |
|---|---|---|
| battle | `library/battle/` | MIT |
| cardgame | `library/cardgame/` | MIT |
| combat | `library/combat/` | MIT |
| crafting | `library/crafting/` | MIT |
| dialog | `library/dialog/` | MIT |
| doll | `library/doll/` | MIT |
| economy | `library/economy/` | MIT |
| inventory | `library/inventory/` | MIT |
| item | `library/item/` | MIT |
| province_map | `library/province_map/` | MIT |
| quest | `library/quest/` | MIT |
| stats | `library/stats/` | MIT |

## 6. Direct Cargo Dependencies and Licenses

This section lists the direct dependencies declared in `Cargo.toml`, using the research-phase resolved versions and license metadata.

| Crate | Resolved Version | License | Scope |
|---|---:|---|---|
| winit | 0.30.13 | Apache-2.0 | normal |
| bytemuck | 1.25.0 | Zlib OR Apache-2.0 OR MIT | normal |
| pollster | 0.3.0 | Apache-2.0 OR MIT | normal |
| mlua | 0.9.9 | MIT | normal |
| image | 0.24.9 | MIT OR Apache-2.0 | normal |
| ddsfile | 0.5.2 | MIT | normal |
| rodio | 0.17.3 | MIT OR Apache-2.0 | normal |
| fontdue | 0.9.3 | MIT OR Apache-2.0 OR Zlib | normal |
| log | 0.4.29 | MIT OR Apache-2.0 | normal |
| env_logger | 0.10.2 | MIT OR Apache-2.0 | normal |
| thiserror | 1.0.69 | MIT OR Apache-2.0 | normal |
| fastrand | 2.3.0 | Apache-2.0 OR MIT | normal |
| rapier2d | 0.32.0 | Apache-2.0 | normal |
| gilrs | 0.11.1 | Apache-2.0 OR MIT | normal |
| rusty_enet | 0.4.0 | MIT | normal |
| slotmap | 1.1.1 | Zlib | normal |
| flate2 | 1.1.9 | MIT OR Apache-2.0 | normal |
| lz4_flex | 0.11.6 | MIT | normal |
| sha2 | 0.10.9 | MIT OR Apache-2.0 | normal |
| sha1 | 0.10.6 | MIT OR Apache-2.0 | normal |
| md-5 | 0.10.6 | MIT OR Apache-2.0 | normal |
| base64 | 0.22.1 | MIT OR Apache-2.0 | normal |
| hex | 0.4.3 | MIT OR Apache-2.0 | normal |
| roxmltree | 0.20.0 | MIT OR Apache-2.0 | normal |
| serde | 1.0.228 | MIT OR Apache-2.0 | normal |
| serde_json | 1.0.149 | MIT OR Apache-2.0 | normal |
| csv | 1.4.0 | Unlicense OR MIT | normal |
| indexmap | 2.13.0 | Apache-2.0 OR MIT | normal |
| toml | 0.8.23 | MIT OR Apache-2.0 | normal |
| directories | 5.0.1 | MIT OR Apache-2.0 | normal |
| sysinfo | 0.30.13 | MIT | normal |
| sys-locale | 0.3.2 | MIT OR Apache-2.0 | normal |
| arboard | 3.6.1 | MIT OR Apache-2.0 | normal |
| rfd | 0.14.1 | MIT | normal |
| zip | 2.4.2 | MIT | normal |
| tempfile | 3.27.0 | MIT OR Apache-2.0 | normal |
| wgpu | 22.1.0 | MIT OR Apache-2.0 | target-specific |
| windows-sys | 0.59.0 | MIT OR Apache-2.0 | target-specific |
| winresource | 0.1.31 | MIT | build |

### Direct Cargo dependency summary

- No direct Cargo dependency reviewed here is GPL, LGPL, or AGPL.
- The direct dependency license families present are MIT, Apache-2.0, Zlib, and Unlicense OR MIT.
- The vendored Lua toolchain used through `mlua` was reported as MIT in the research pass.

## 7. Direct VS Code Extension Runtime Dependency

| Package | Resolved Version | License |
|---|---:|---|
| @modelcontextprotocol/sdk | 1.29.0 | MIT |

Note: this is the direct runtime dependency declared in `vscode-extension/package.json`. A full packaged VSIX redistribution audit was not part of this table.

## 8. Model Findings

No machine-learning or inference model files were found in the repository.

No `.onnx`, `.tflite`, `.gguf`, `.pt`, `.pth`, `.safetensors`, `.pb`, `.mlmodel`, or `.model` files were identified during the audit.

`@modelcontextprotocol/sdk` uses the word `model`, but it is a protocol SDK dependency, not an ML weight file.

## 9. Remaining Caveat

The main direct-dependency follow-up item still worth checking is `gilrs`, because the manifest notes a bundled `SDL_GameControllerDB` path. The crate license itself is permissive, but separate notice handling for that bundled database may still need confirmation for release packaging.

## 10. Bottom Line

If your question is "what modules and direct package dependencies am I using, and are any of them GPL-style licenses?", the answer from this audit is:

- first-party Luna2D modules are MIT,
- the root Rust package is MIT,
- the first-party VS Code extension package is MIT,
- the direct Cargo dependencies reviewed here are permissive only, and
- no ML or inference models were found in the repository.

This is an engineering inventory, not legal advice.