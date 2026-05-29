# lua_api

## TL;DR



## General Info

- Module group: `Edge/Integration`
- Source path: `src/lua_api/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.agent`
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

Binding layer that registers and documents the public lurek.* Lua API surface.

This module primarily collaborates with `agent`, `ai`, `animation`, `app`, `asset`, `audio`, `automation`, `binary`, and adjacent engine modules. Its responsibility should stay inside the Edge/Integration group rather than absorb behavior owned by those neighbors.

## Files

### agent_api.rs

- File: src/lua_api/agent_api.rs

### ai_api.rs

- File: src/lua_api/ai_api.rs

### animation_api.rs

- File: src/lua_api/animation_api.rs

### asset_api.rs

- File: src/lua_api/asset_api.rs

### audio_api.rs

- File: src/lua_api/audio_api.rs

### automation_api.rs

- File: src/lua_api/automation_api.rs

### binary_api.rs

- File: src/lua_api/binary_api.rs

### callback_registry.rs

- File: src/lua_api/callback_registry.rs

### camera_api.rs

- File: src/lua_api/camera_api.rs

### charts_api.rs

- File: src/lua_api/charts_api.rs

### color_api.rs

- File: src/lua_api/color_api.rs

### compute_api.rs

- File: src/lua_api/compute_api.rs

### cursor_api.rs

- File: src/lua_api/cursor_api.rs

### dataframe_api.rs

- File: src/lua_api/dataframe_api.rs

### debugbridge_api.rs

- File: src/lua_api/debugbridge_api.rs

### devtools_api.rs

- File: src/lua_api/devtools_api.rs

### dialog_api.rs

- File: src/lua_api/dialog_api.rs

### docs_api.rs

- File: src/lua_api/docs_api.rs

### dsp_api.rs

- File: src/lua_api/dsp_api.rs

### ecs_api.rs

- File: src/lua_api/ecs_api.rs

### effect_api.rs

- File: src/lua_api/effect_api.rs

### engine_api.rs

- File: src/lua_api/engine_api.rs

### event_api.rs

- File: src/lua_api/event_api.rs

### filesystem_api.rs

- File: src/lua_api/filesystem_api.rs

### flownet_api.rs

- File: src/lua_api/flownet_api.rs

### font_api.rs

- File: src/lua_api/font_api.rs

### globe_api.rs

- File: src/lua_api/globe_api.rs

### grep_api.rs

- File: src/lua_api/grep_api.rs

### html_api.rs

- File: src/lua_api/html_api.rs

### i18n_api.rs

- File: src/lua_api/i18n_api.rs

### image_api.rs

- File: src/lua_api/image_api.rs

### input_api.rs

- File: src/lua_api/input_api.rs

### layout_api.rs

- File: src/lua_api/layout_api.rs

### learning_api.rs

- File: src/lua_api/learning_api.rs

### light_api.rs

- File: src/lua_api/light_api.rs

### log_api.rs

- File: src/lua_api/log_api.rs

### lua_module.rs

- File: src/lua_api/lua_module.rs

### lua_types.rs

- File: src/lua_api/lua_types.rs

### mapblock_api.rs

- File: src/lua_api/mapblock_api.rs

### math_api.rs

- File: src/lua_api/math_api.rs

### midi_api.rs

- File: src/lua_api/midi_api.rs

### minimap_api.rs

- File: src/lua_api/minimap_api.rs

### mod.rs

- File: src/lua_api/mod.rs

### mods_api.rs

- File: src/lua_api/mods_api.rs

### network_api.rs

- File: src/lua_api/network_api.rs

### overlay_api.rs

- File: src/lua_api/overlay_api.rs

### parallax_api.rs

- File: src/lua_api/parallax_api.rs

### particle_api.rs

- File: src/lua_api/particle_api.rs

### pathfind_api.rs

- File: src/lua_api/pathfind_api.rs

### patterns_api.rs

- File: src/lua_api/patterns_api.rs

### physics_api.rs

- File: src/lua_api/physics_api.rs

### pipeline_api.rs

- File: src/lua_api/pipeline_api.rs

### procgen_api.rs

- File: src/lua_api/procgen_api.rs

### province_api.rs

- File: src/lua_api/province_api.rs

### raycaster_api.rs

- File: src/lua_api/raycaster_api.rs

### register.rs

- File: src/lua_api/register.rs

### render_api.rs

- File: src/lua_api/render_api.rs

### repl_api.rs

- File: src/lua_api/repl_api.rs

### save_api.rs

- File: src/lua_api/save_api.rs

### scene_api.rs

- File: src/lua_api/scene_api.rs

### serialize_api.rs

- File: src/lua_api/serialize_api.rs

### spine_api.rs

- File: src/lua_api/spine_api.rs

### sprite_api.rs

- File: src/lua_api/sprite_api.rs

### system_api.rs

- File: src/lua_api/system_api.rs

### terminal_api.rs

- File: src/lua_api/terminal_api.rs

### thread_api.rs

- File: src/lua_api/thread_api.rs

### tilemap_api.rs

- File: src/lua_api/tilemap_api.rs

### timer_api.rs

- File: src/lua_api/timer_api.rs

### tween_api.rs

- File: src/lua_api/tween_api.rs

### ui_api.rs

- File: src/lua_api/ui_api.rs

### validator_api.rs

- File: src/lua_api/validator_api.rs

### visibility_api.rs

- File: src/lua_api/visibility_api.rs

### window_api.rs

- File: src/lua_api/window_api.rs

## Lua API Ref

- Binding: None direct
- Namespace: `lurek.agent`

### Functions

- No documented module-level functions.

### Enums

- No documented module-level enums/constants.

### Types

- No documented module types.

## References

- `agent`: Imports or references `src/agent/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `ai`: Imports or references `src/ai/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `animation`: Imports or references `src/animation/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `app`: Imports or references `src/app/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `asset`: Imports or references `src/asset/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `audio`: Imports or references `src/audio/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `automation`: Imports or references `src/automation/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `binary`: Imports or references `src/binary/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `camera`: Imports or references `src/camera/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `charts`: Imports or references `src/charts/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `color`: Imports or references `src/color/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `compute`: Imports or references `src/compute/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `cursor`: Imports or references `src/cursor/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `dataframe`: Imports or references `src/dataframe/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `debugbridge`: Imports or references `src/debugbridge/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `devtools`: Imports or references `src/devtools/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `dialog`: Imports or references `src/dialog/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `docs`: Imports or references `src/docs/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `dsp`: Imports or references `src/dsp/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `ecs`: Imports or references `src/ecs/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `effect`: Imports or references `src/effect/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `event`: Imports or references `src/event/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `filesystem`: Imports or references `src/filesystem/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `flownet`: Imports or references `src/flownet/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `globe`: Imports or references `src/globe/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `grep`: Imports or references `src/grep/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `html`: Imports or references `src/html/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `i18n`: Imports or references `src/i18n/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `input`: Imports or references `src/input/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `layout`: Imports or references `src/layout/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `learning`: Imports or references `src/learning/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `light`: Imports or references `src/light/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `log`: Imports or references `src/log/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `mapblock`: Imports or references `src/mapblock/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `math`: Imports or references `src/math/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `midi`: Imports or references `src/midi/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `minimap`: Imports or references `src/minimap/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `mods`: Imports or references `src/mods/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `network`: Imports or references `src/network/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `overlay`: Imports or references `src/overlay/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `parallax`: Imports or references `src/parallax/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `particle`: Imports or references `src/particle/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `pathfind`: Imports or references `src/pathfind/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `patterns`: Imports or references `src/patterns/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `physics`: Imports or references `src/physics/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `pipeline`: Imports or references `src/pipeline/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `procgen`: Imports or references `src/procgen/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `province`: Imports or references `src/province/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `raycaster`: Imports or references `src/raycaster/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `render`: Imports or references `src/render/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
- `repl`: Imports or references `src/repl/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `runtime`: Imports or references `src/runtime/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `save`: Imports or references `src/save/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `scene`: Imports or references `src/scene/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `serialize`: Imports or references `src/serialize/`. Cross-group dependency from `Edge/Integration` into `Foundations`.
- `spine`: Imports or references `src/spine/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `sprite`: Imports or references `src/sprite/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `terminal`: Imports or references `src/terminal/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `thread`: Imports or references `src/thread/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `tilemap`: Imports or references `src/tilemap/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `timer`: Imports or references `src/timer/`. Cross-group dependency from `Edge/Integration` into `Core Runtime`.
- `tween`: Imports or references `src/tween/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `ui`: Imports or references `src/ui/`. Cross-group dependency from `Edge/Integration` into `Feature Systems`.
- `validator`: Imports or references `src/validator/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `visibility`: Imports or references `src/visibility/`. Dependency stays inside `Edge/Integration` and should remain acyclic.
- `window`: Imports or references `src/window/`. Cross-group dependency from `Edge/Integration` into `Platform Services`.
