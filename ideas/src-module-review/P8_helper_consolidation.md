# P8 — Helper Consolidation (TODO(helper) Synthesis)

> Generated: 2026-04-18 | Session: src-module-review-20260418

## Summary

~92 TODO(helper) entries found across all 49 modules. Helpers are Lua-level convenience wrappers or content/library/ modules that reduce boilerplate in game scripts.

## Priority 1: High-Impact Helpers (pattern repeated in 3+ games/demos)

| # | Helper | Source module | Description | Target location |
|---|--------|-------------|-------------|-----------------|
| 1 | **input_action_map** | input | Action→key binding pattern repeated in every game script | content/library/input/ |
| 2 | **audio_manager** | audio | Common play/stop/fadeIn/fadeOut pattern | content/library/audio/ |
| 3 | **sprite_animator** | sprite | SpriteSheet + Animation wrapping for sprite-sheet playback | content/library/animator/ |
| 4 | **camera_follow_config** | camera | follow_smooth + dead_zone + look_ahead preset group | content/library/camera/ |
| 5 | **tween_chain** | tween | Named, reusable multi-step animation scripts | content/library/ui/transitions |
| 6 | **particle_presets** | particle | Common particle configs (fire, smoke, rain, snow, sparks) | content/library/particle_presets/ |
| 7 | **anim_controller** | animation | Animation + SpriteSheet + state machine for game characters | content/library/animator/ |
| 8 | **window_config_helper** | window | conf.lua window settings pattern (width/height/title/fullscreen) | content/library/config/ |

## Priority 2: Medium-Impact Helpers (pattern repeated in 2+ games/demos)

| # | Helper | Source module | Description | Target location |
|---|--------|-------------|-------------|-----------------|
| 9 | **music_player** | audio | Playlist/shuffle/crossfade pattern | content/library/audio/ |
| 10 | **tween_color** | tween | Tweening Color userdata (r,g,b,a as a unit) | content/library/tween/ |
| 11 | **viewport_setup** | camera | Auto-wire viewport resize to window resize event | content/library/camera/ |
| 12 | **fs_json_helper** | filesystem | JSON read/write pattern repeated in game scripts | content/library/json/ |
| 13 | **camera_follow_walker** | tilemap | TileWalker + camera centering for RPG demos | content/library/rpg/ |
| 14 | **one_way_platform** | physics | Manual contact filter for platformer one-way platforms | content/library/platformer/ |
| 15 | **terrain_explosion** | physics | Circle-fill + rebuild for destructible terrain | content/library/terrain/ |
| 16 | **image_utils** | image | Palette cycling / animated palette swap wrapper | content/library/image/ |
| 17 | **parallax_presets** | parallax | Standard parallax configs (mountains, trees, foreground) | content/library/parallax_presets/ |
| 18 | **save-utils** | save | Auto-slot-rotation, save browser UI, import/export | content/library/save/ |
| 19 | **net-sync** | network | Entity state sync, client prediction, interpolation buffers | content/library/network/ |
| 20 | **i18n-loader** | i18n | Auto-discover and load locale TOML files from conventional dir | content/library/i18n/ |

## Priority 3: Quality-of-Life Helpers (nice to have)

| # | Helper | Source module | Description | Target location |
|---|--------|-------------|-------------|-----------------|
| 21 | **lurek.timer.delay(seconds)** | timer | Coroutine-based yield-for-duration sugar for cutscene scripting | Engine API extension |
| 22 | **lurek.thread.async(fn)** | thread | Promise from Lua closure without boilerplate channel plumbing | Engine API extension |
| 23 | **lurek.data.crc32(str)** | data | Quick CRC-32 checksum (currently only md5/sha256 exposed) | Engine API extension |
| 24 | **lurek.math.clamp** | math | First-class clamp; content/library/stats re-implements it | Engine API extension |
| 25 | **codec_auto_detect** | serial | Sniff content/extension → pick correct decoder | content/library/serial/ |
| 26 | **pipeline_builder** | pipeline | Declarative table-driven pipeline construction helper | content/library/pipeline/ |
| 27 | **tilemap_minimap** | tilemap | Render downscaled tilemap to image for minimap HUD | content/library/tilemap/ |
| 28 | **config_inspector** | runtime | Lua helper to dump current Config as table for debugging | content/library/debug/ |
| 29 | **frame_profiler** | app | Per-callback timing breakdown display | content/library/debug/ |
| 30 | **anim_preview** | animation | Render animation frames to ImageData grid for debug UI | content/library/debug/ |
| 31 | **virtual_dpad** | input | Touch-screen D-pad emulation for mobile-style games | content/library/input/ |
| 32 | **nine_slice** | image | Lua-side nine-slice draw helper using atlas region insets | content/library/ui/ |
| 33 | **seedable_rng** | math | Promote lurek.math.newRng() adoption in game scripts | Documentation improvement |

## Rust-Level Helpers (internal refactoring, not Lua-facing)

| # | Helper | Source module | Description |
|---|--------|-------------|-------------|
| 34 | **format_log_line** | log | Unify formatting across Sink::write, Sink::write_structured, and log_structured |
| 35 | **parse_level** | log | Implement FromStr for SinkLevel properly (None instead of defaulting to Debug) |
| 36 | **PostFxEffectType string↔enum** | effect | Centralize from_name/name conversion |
| 37 | **parse_blend_mode / parse_falloff / parse_shadow_filter** | light | Centralize string↔enum parsing for light enums |

## Grouping by Library Module

Several helpers naturally cluster into existing or new content/library/ modules:

| Library module | Helpers | Status |
|----------------|---------|--------|
| `content/library/animator/` | sprite_animator (#3), anim_controller (#7), anim_preview (#30) | Exists (init.lua) |
| `content/library/audio/` | audio_manager (#2), music_player (#9) | Exists (init.lua) |
| `content/library/input/` | input_action_map (#1), virtual_dpad (#31) | Exists (init.lua) |
| `content/library/camera/` | camera_follow_config (#4), viewport_setup (#11) | New |
| `content/library/ui/` | nine_slice (#32) | Exists (transitions.lua) |
| `content/library/tween/` | tween_chain (#5), tween_color (#10) | New |
| `content/library/debug/` | config_inspector (#28), frame_profiler (#29), anim_preview (#30) | New |
| `content/library/particle_presets/` | particle_presets (#6) | New |
| `content/library/parallax_presets/` | parallax_presets (#17) | New |
| `content/library/platformer/` | one_way_platform (#14) | Exists |
| `content/library/rpg/` | camera_follow_walker (#13) | Exists |

## Implementation Priority

1. **Engine API extensions** (#21-24): Low effort, high value — add lurek.timer.delay, lurek.thread.async, lurek.data.crc32, lurek.math.clamp
2. **High-impact library helpers** (#1-8): Create or extend content/library/ modules
3. **Medium-impact library helpers** (#9-20): Fill gaps in existing library modules
4. **Debug helpers** (#28-30): Useful for development workflows
5. **Rust-level helpers** (#34-37): Internal quality improvement
