# Edited Files Log

This file tracks which Lua unit test files have already been reviewed and edited.
Do NOT re-edit files already listed here in a new session.

## Session: 2026-05-07 (pierwsze 8 plików — alfabetycznie)

### Files Reviewed (no changes needed — passed audit, tests are real)
- test_ai_core_unit.lua — PASS
- test_animation_core_unit.lua — PASS
- test_audio_core_unit.lua — PASS
- test_automation_core_unit.lua — PASS
- test_battle_core_unit.lua — PASS
- test_camera_core_unit.lua — PASS
- test_collision_core_unit.lua — PASS
- test_compute_core_unit.lua — PASS

## Session: 2026-05-08 (pliki 9–15 alfabetycznie)

### Files Reviewed (no changes needed — passed audit, tests are real)
- test_crafting_core_unit.lua — PASS, no stubs, real tests
- test_data_core_unit.lua — PASS, no stubs, real tests (pack/unpack/compress/DataView)
- test_debugbridge_core_unit.lua — PASS, no stubs, real tests
- test_devtools_core_unit.lua — PASS, no stubs, real tests
- test_dialog_core_unit.lua — PASS, intentionally minimal (namespace contract only, library tested in tests/lua/library/)
- test_docs_core_unit.lua — PASS, no stubs, real tests

### Files Edited (had issues — fixed)
- test_dataframe_core_unit.lua — Fixed 2x wrong `@covers LTween:getValue` → `@covers LVecFrame:getValue`

## Session: 2026-05-08 — session 3 (pliki 16–30 alfabetycznie)

### Files Reviewed (no changes needed — passed audit, tests are real)
- test_drawlayer_unit.lua — PASS, z-order queue tests
- test_ecs_core_unit.lua — PASS, spawn/components/query
- test_effect_core_unit.lua — PASS, 2258 lines real tests
- test_engine_core_unit.lua — PASS, real tests
- test_event_core_unit.lua — PASS, 819 lines
- test_filesystem_core_unit.lua — PASS, 1166 lines read/write/async
- test_font_unit.lua — PASS, 59 lines real render/font tests
- test_graph_core_unit.lua — PASS, 1204 lines
- test_html_core_unit.lua — PASS, real HTML layout tests
- test_i18n_core_unit.lua — PASS, full i18n coverage
- test_image_core_unit.lua — PASS, ImageData effect methods
- test_input_core_unit.lua — PASS, keyboard/mouse/gamepad
- test_light_core_unit.lua — PASS, getters/setters round-trip
- test_log_core_unit.lua — PASS, setLevel/sinks/memory

### Files Edited (had issues — fixed)
- test_globe_core_unit.lua — Fixed UTF-8 BOM, added missing `@covers lurek.globe.MAX_PROVINCES`, repaired `--` header comment

## Session: 2026-05-08 — session 4 (pliki 31–45 alfabetycznie)

### Files Reviewed (no changes needed — passed audit, tests are real)
- test_minimap_core_unit.lua — PASS, real minimap construction/terrain tests
- test_mods_core_unit.lua — PASS, real mod lifecycle/manager tests
- test_parallax_core_unit.lua — PASS, real scroll/layer tests
- test_particle_core_unit.lua — PASS, real emission/config tests
- test_pathfind_core_unit.lua — PASS, NavGrid/pathfinding tests
- test_patterns_core_unit.lua — PASS, EventBus/SignalBus/StateMachine tests
- test_pipeline_core_unit.lua — PASS, DAG pipeline tests
- test_procgen_core_unit.lua — PASS, noise/voronoi/flood tests
- test_province_core_unit.lua — PASS, province registry tests
- test_raycaster_core_unit.lua — PASS, raycaster grid/ray tests
- test_render_core_unit.lua — PASS, render API existence and behavior
- test_render_font_unit.lua — PASS, font load/set/get round-trip

### Files Edited (had issues — fixed)
- test_math_core_unit.lua — BOM removed; header `--` repaired; `@covers lurek.math.pi` and `@covers lurek.math.tau` added
- test_network_core_unit.lua — BOM removed; header `--` repaired; 22 missing `@covers` added for `lurek.net.*` and `LNetworkHost:*` methods
- test_physics_core_unit.lua — BOM removed; header `--` repaired; 11 missing `@covers` added in cellular constants and cell-access sections

## Session: 2026-05-08 — session 5 (pliki 46–60 alfabetycznie)

### Files Reviewed (no changes needed — passed audit, tests are real)
- test_runtime_core_unit.lua — PASS, real runtime/system metadata tests
- test_save_core_unit.lua — PASS, real SaveManager lifecycle tests
- test_scene_core_unit.lua — PASS, real scene stack/transition/registry tests
- test_shape_core_unit.lua — PASS, real compound-shape builder tests
- test_spine_core_unit.lua — PASS, real skeleton/bone/slot tests
- test_sprite_core_unit.lua — PASS, real sheet/atlas frame tests
- test_system_core_unit.lua — PASS, real runtime/system helper tests
- test_terminal_core_unit.lua — PASS, real terminal widget/state tests
- test_thread_core_unit.lua — PASS, real channel/message tests
- test_timer_core_unit.lua — PASS, real timing/scheduler tests
- test_tween_core_unit.lua — PASS, real tween lifecycle/easing tests
- test_ui_core_unit.lua — PASS, real layout loader/widget tree tests
- test_window_core_unit.lua — PASS, real window getter/fullscreen tests

### Files Edited (had issues — fixed)
- test_serial_core_unit.lua — Added 2 missing `-- @describe` markers above `INI decode` and `lurek.serial unified codec API`
- test_tilemap_core_unit.lua — BOM removed; header `--` repaired; added missing `@covers` for IsoMap tile-part constants

## Next session: no more files in tests/lua/unit matching `test_*.lua`

## Session: 2026-05-08 - session 5 (pliki 31-45 alphabetically) - VERIFICATION PASS

### Files Verified (all passed audit, no changes needed)
- test_math_core_unit.lua (31) - PASS, real math API tests
- test_minimap_core_unit.lua (32) - PASS, real minimap construction/terrain tests
- test_mods_core_unit.lua (33) - PASS, real mod lifecycle/manager tests
- test_network_core_unit.lua (34) - PASS, real network API tests
- test_parallax_core_unit.lua (35) - PASS, real scroll/layer tests
- test_particle_core_unit.lua (36) - PASS, real emission/config tests
- test_pathfind_core_unit.lua (37) - PASS, NavGrid/pathfinding tests
- test_patterns_core_unit.lua (38) - PASS, EventBus/SignalBus/StateMachine tests
- test_physics_core_unit.lua (39) - PASS, real physics API tests
- test_pipeline_core_unit.lua (40) - PASS, DAG pipeline tests
- test_procgen_core_unit.lua (41) - PASS, noise/voronoi/flood tests
- test_province_core_unit.lua (42) - PASS, province registry tests
- test_raycaster_core_unit.lua (43) - PASS, raycaster grid/ray tests
- test_render_core_unit.lua (44) - PASS, render API existence and behavior
- test_render_drawlayer_unit.lua (45) - PASS, z-order queue tests

### Notes
- All 15 files passed lua_test_structure_audit.py (no issues detected)
- No stubbed tests, no commented-out code, no @covers errors
- File 45 (test_render_drawlayer_unit.lua) was missing from session 4's report - added here
- Session 4 mistakenly listed test_render_font_unit.lua (46) which belongs in later session

### Known Test Failures (out of scope)
- lua_unit_crafting_unit: test_crafting_core_unit.lua (file 9) - fixed in session 6
- lua_security_render: security probe failures - not part of this session

## Session: 2026-05-08 - session 6 (pliki 1-15 alfabetycznie) - COMPLETED

### Files Reviewed (audit + execution)
- test_ai_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_animation_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_audio_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_automation_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_battle_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_camera_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_collision_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_compute_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_crafting_core_unit.lua — PASS after fix in this session
- test_data_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_dataframe_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_debugbridge_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_devtools_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_dialog_core_unit.lua — PASS, real tests, no stubs/placeholders
- test_docs_core_unit.lua — PASS, real tests, no stubs/placeholders

### Files Edited (had issues — fixed)
- test_crafting_core_unit.lua — replaced invalid call `r:addTag(...)` with valid tag-table flow using `Recipe:getTags()` + `Recipe:hasTag()`; kept `@covers` markers aligned with called symbols.
