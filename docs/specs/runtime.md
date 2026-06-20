# runtime

## TL;DR

- Manages engine shared state, asset registries, and configurations.
- Supports headless or windowed modes and stable error codes.
- Reports frame profiling, memory budgets, and locale messages.

## General Info

- Module group: `Core Runtime`
- Source path: `src/runtime/`
- Binding: None direct
- Namespace: `lurek.runtime`
- Lua API surface: `41` functions, `8` types, `0` methods
- Rust test path(s): tests/rust/unit/runtime_tests.rs, tests/rust/unit/window_tests.rs, tests/rust/ext/graphics_runtime_smoke_tests.rs, plus runtime-focused unit coverage embedded in src/runtime/messages.rs
- Lua test path(s): tests/lua/config/test_config.lua, tests/lua/unit/test_runtime_core_unit.lua

## Summary

- The `runtime` module is the shared engine-state surface that many other modules depend on before they expose their own user-facing features.
- Its role is to keep the rest of the engine coherent. Configuration, shared state, execution mode, error vocabulary, resource keys, logging support, and OS-aware helpers live here so the engine has one common operating language.
- This central vocabulary matters because large engines become fragile when every subsystem invents its own concepts for startup state, environment mode, resource identity, logging, or global context.
- Mode handling is especially important because the same engine may run in normal interactive play, headless automation, docs generation, tests, screenshots, or other specialized workflows that need different assumptions.
- Shared state, resource-key helpers, and runtime-wide error types give other modules a stable way to coordinate without dissolving into ad hoc registries and inconsistent failure reporting.
- Logging and environment-aware helpers belong here for the same reason: runtime-wide diagnostics and platform context should be centralized rather than redefined in each subsystem.
- That shared operating layer is what makes higher-level systems easier to compose around one startup and execution contract.
- Headless support is especially important because non-interactive execution should feel first-class for CI, docs, evidence capture, and automation instead of like a reduced afterthought.
- It also gives tool and gameplay code one place to agree on environment mode, startup assumptions, and shared process-level state.
- It gives the engine one durable answer to runtime context.
- That keeps “how the engine is running” separate from “what a feature is doing,” which is exactly the boundary `runtime` should own.
- `runtime` should stabilize common policy and state, but it should not absorb the domain logic of the modules that depend on it.
- Read `runtime` as the shared operating layer of the engine.

This module primarily collaborates with `audio`, `camera`, `event`, `filesystem`, `image`, `input`, `light`, `lua_api`, and adjacent engine modules. Its responsibility should stay inside the Core Runtime group rather than absorb behavior owned by those neighbors.

## Imports

- `audio`: Imports or references `audio` from `src/audio/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `filesystem` from `src/filesystem/`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Core Runtime` into `Platform Services`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: `src/lua_api/system_api.rs`, `src/lua_api/engine_api.rs`, and `src/lua_api/register.rs` expose the runtime contract to Lua. `src/runtime/` must not import the binding layer.
- `midi`: Imports or references `src/midi/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `mods`: Imports or references `src/mods/`. Cross-group dependency from `Core Runtime` into `Feature Systems`.
- `parallax`: Imports or references `parallax` from `src/parallax/`.
- `particle`: Imports or references `particle` from `src/particle/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `raycaster`: Imports or references `raycaster` from `src/raycaster/`.
- `render`: Imports or references `render` from `src/render/`.
- `repl`: Imports or references `src/repl/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `tilemap` from `src/tilemap/`.
- `timer`: Imports or references `timer` from `src/timer/`.
- `ui`: Imports or references `ui` from `src/ui/`.

## Files

### config.rs

- This file owns the typed runtime configuration schema that turns `conf.toml` into deterministic startup policy.
- It stores top-level config plus mode, window, render, module, performance, TUI, CLI, and headless sections.
- Default implementations define the baseline engine shape used when projects omit config or provide partial data.
- Module validation lives here because feature toggles must disable unsupported dependency combinations centrally.
- Headless-profile helpers also live here so no-window startup can force a supported subset of enabled modules.
- Load helpers merge file overrides over defaults, log read or parse problems, and preserve a usable config result.
- Serde support is part of the boundary because this data moves between disk, runtime defaults, and inspections.
- Open it when startup policy changes; shared mutable state and execution modes consume these contracts elsewhere.

### error.rs

- This file owns the engine-wide runtime error vocabulary used by startup, subsystems, tooling, and Lua bridges.
- `EngineError` stores typed failure variants, while codes, categories, and recovery hints standardize diagnostics.
- `ErrorSnapshot` provides a serializable view so UI overlays, logs, and external tools can consume the same data.
- `EngineResult` keeps callers on one shared error contract instead of fragmenting result types by subsystem.
- Open it when failure taxonomy changes; shared state and message lookup consume this contract elsewhere.

### headless.rs

- This file owns no-window runtime execution for automation, tests, eval snippets, and batch Lua workflows.
- `HeadlessOptions` captures inputs, while the main entry points map engine errors to process-oriented outcomes.
- Startup wiring creates shared state, headless Lua VM bindings, package paths, and stdout-backed `print` behavior.
- Frame stepping calls the usual lurek callbacks with configured dt and optional callback timeout enforcement.
- Timeout helpers own hook-based abort logic so runaway Lua code fails cleanly during unattended execution.
- Open it when non-GUI runtime flow changes; config, modes, and shared state contracts live in sibling files.

### log_messages.rs

- This file owns the stable log identifier catalog used across runtime and subsystem logging sites.
- It defines one symbolic code set grouped by domain so operators can filter and recognize repeated conditions.
- The `log_msg!` macro formats ids through the message catalog, keeping call sites compact and output consistent.
- Log-level overrides also live here because message identity and runtime log visibility are operationally linked.
- Large constant sections are intentional: they are the compatibility surface that tools and humans both rely on.
- Subsystem ranges cover startup, GPU, filesystem, animation, ECS, save, networking, and many later extensions.
- Open this file when adding or changing a stable runtime log code, not when editing the prose catalog text.
- Use `messages.rs` for human-readable strings and this file for durable ids, macro wiring, and level helpers.
- Open it when logging contracts change; runtime modules across the repo depend on these shared identifiers.

### lua_execution.rs

- This file owns shared Lua execution policy used by GUI app, headless runs, and other host-side callers.
- `LuaExecutionPolicy` centralizes callback timeout configuration and instruction-hook cadence.
- The helper executes already-resolved Lua functions and removes timeout hooks with RAII cleanup.
- Keeping this logic in runtime avoids diverging timeout semantics between GUI and headless hosts.
- Open it when Lua callback timeout policy or hook cleanup behavior changes.

### messages.rs

- This file owns the embedded runtime message catalog that resolves stable identifiers into display text.
- It parses TOML once, flattens nested tables into one map, and exposes lookup helpers with readable fallback.
- Catalog initialization is lazy so message resolution does not impose setup cost until the runtime needs it.
- Open it when runtime text lookup changes; log ids and shared error reporting live in sibling files.

### mod.rs

- This module is the runtime index, re-exporting config, shared state, modes, errors, messages, and headless flow.
- It is the navigation point for startup policy, shared engine state, process modes, and stable runtime contracts.
- `shared_state.rs` owns the mutable cross-system hub, while `config.rs` owns TOML-backed startup configuration.
- `error.rs` owns failure vocabulary, `mode.rs` owns startup mode parsing, and `headless.rs` runs no-window sessions.
- `messages.rs` and `log_messages.rs` own runtime text lookup plus stable log identifiers and formatting helpers.
- Change this file when public runtime exports move; change siblings when startup or shared-state rules change.

### mode.rs

- This file owns the startup mode vocabulary that selects GUI, TUI, CLI, or headless runtime entry paths.
- `RuntimeMode` and its parse error keep config files and CLI parsing aligned on the same accepted mode tokens.
- String conversion stays beside the enum so user-facing labels remain stable across logs, config, and tooling.
- Open it when runtime entry-mode semantics change; shared state and startup execution live in sibling files.

### os.rs

- This file owns the runtime-facing OS helpers used for platform labels, browser launch, locales, and host info.
- It exposes compile-time OS naming, logical processor count, memory size, URL opening, and locale preferences.
- Power-state reporting also lives here so Lua and Rust read one host abstraction instead of ad hoc probes.
- URL launching is validated here because runtime callers need one policy gate for allowed external schemes.
- Open it when platform-query semantics change; startup config and shared state live in sibling runtime files.

### resource_keys.rs

- This file owns the slotmap key types used to reference runtime-managed resources without exposing pool internals.
- It defines cheap copyable handles for textures, fonts, canvases, meshes, shaders, buses, and related objects.
- Open it when runtime resource identity changes; actual pools and eviction policy live in shared state.

### shared_state.rs

- This file owns `SharedState`, the mutable runtime hub that lets separate engine systems coordinate each frame.
- It stores render commands, resource pools, timers, window state, input snapshots, and many subsystem handles.
- Resource ownership for textures, fonts, canvases, meshes, shaders, particles, and related assets lives here.
- Frame-level services include timing, default fonts, render settings, screenshot requests, and debug overlays.
- Async file operations, filesystem identity, and poll helpers live here so background I/O shares one runtime hub.
- Budget enforcement and LRU eviction stay here because they require a global view of runtime-managed resources.
- Window, fullscreen, scaling, and error snapshot state also live here for Lua bindings and app-loop coordination.
- Helper methods cover construction, timer stepping, resource touching, memory stats, async requests, and fonts.
- Open it when cross-system runtime ownership changes; app, Lua bindings, and headless flow depend on this file.



## Lua API Ref

### Functions

- `lurek.engine.fps() -> number`: Returns the latest frames-per-second value stored by the runtime.
- `lurek.engine.frameCount() -> integer`: Returns the number of frames counted by the shared runtime clock.
- `lurek.engine.getConfigRevision() -> integer`: Returns the configuration reload revision counter.
- `lurek.engine.getFrameBudget() -> number`: Returns the target frame budget for a 60 FPS update loop.
- `lurek.engine.getFrameProfile() -> table`: Returns the latest frame timing profile split by engine phase.
- `lurek.engine.getFrameProfileText() -> string`: Returns the latest frame timing profile formatted as one text line.
- `lurek.engine.getResourceStats() -> table`: Returns current resource memory usage and object counts by resource kind.
- `lurek.engine.getVersion() -> string`: Returns the engine crate version string embedded at build time.
- `lurek.engine.isDebug() -> boolean`: Returns whether the engine binary was built with debug assertions.
- `lurek.engine.memoryUsage() -> table`: Returns Lua VM memory usage as bytes and rounded kilobytes.
- `lurek.engine.platform() -> string`: Returns the current desktop operating system name.
- `lurek.engine.setResourceBudget(budget_bytes) -> nil`: Sets the resource memory budget used by resource statistics reporting.
- `lurek.engine.uptime() -> number`: Returns total engine runtime accumulated by the main loop.
- `lurek.runtime.errorSnapshot(msg) -> string`: Creates a JSON-encoded error snapshot from a message string, useful for diagnostics and error reporting.
- `lurek.runtime.getArch() -> string`: Returns the CPU architecture of the host system.
- `lurek.runtime.getArgs() -> string[]`: Returns the command-line arguments passed to the engine as a 1-indexed table of strings.
- `lurek.runtime.getBatchResults(results) -> number`: Summarizes batch results by counting passed, failed, and skipped tasks.
- `lurek.runtime.getClipboardText() -> string`: Reads the current text content from the system clipboard. Returns an empty string if the clipboard is unavailable or contains no text.
- `lurek.runtime.getConfig() -> table`: Returns a table containing the current engine runtime configuration values.
- `lurek.runtime.getDebugOverlay() -> boolean`: Returns whether the on-screen debug overlay is currently enabled.
- `lurek.runtime.getEnv(name) -> string`: Reads an environment variable by name. Returns `nil` if the variable is not set.
- `lurek.runtime.getInfo() -> table`: Returns a table with comprehensive engine and host information.
- `lurek.runtime.getLastError() -> table`: Returns the most recent engine error as a table, or `nil` if no error has occurred.
- `lurek.runtime.getLogLevel() -> string`: Returns the current engine log verbosity level as a string.
- `lurek.runtime.getMemorySize() -> number`: Returns the total physical memory of the host system in megabytes.
- `lurek.runtime.getMessage(id) -> string`: Resolves a message string by its identifier from the engine message catalog.
- `lurek.runtime.getMessageCount() -> number`: Returns the total number of messages registered in the engine message catalog.
- `lurek.runtime.getOS() -> string`: Returns the name of the host operating system as a string.
- `lurek.runtime.getPowerInfo() -> string`: Returns the current power supply state, battery percentage, and estimated time remaining.
- `lurek.runtime.getPreferredLocales() -> string[]`: Returns a list of the user's preferred locale identifiers from the operating system.
- `lurek.runtime.getProcessorCount() -> number`: Returns the number of logical processors available on the host machine.
- `lurek.runtime.getVersion() -> string`: Returns the semantic version string of the Lurek2D engine.
- `lurek.runtime.hasMessage(id) -> boolean`: Checks whether a message identifier exists in the engine message catalog.
- `lurek.runtime.log(level, message) -> nil`: Writes a message to the engine log at the specified severity level.
- `lurek.runtime.openURL(url) -> boolean`: Opens a URL in the default system browser. Only `http://`, `https://`, and `mailto:` schemes are permitted.
- `lurek.runtime.parseArgs(args?) -> table`: Parses command-line arguments into structured flags, options, and positional values. Supports `--key=value`, `--key value`, `-flag`, and `--` end-of-options.
- `lurek.runtime.reloadConfig() -> nil`: Requests a reload of the engine configuration from `conf.lua`. The reload is deferred until the next frame.
- `lurek.runtime.runBatch(tasks, opts?) -> table`: Executes a table of named task functions sequentially, collecting pass/fail results and elapsed time for each.
- `lurek.runtime.setClipboardText(text) -> nil`: Copies a string to the system clipboard. Logs a warning if the clipboard is unavailable or the write fails.
- `lurek.runtime.setDebugOverlay(enabled) -> nil`: Enables or disables the on-screen debug overlay that shows FPS, draw calls, and other diagnostics.
- `lurek.runtime.setLogLevel(level) -> nil`: Sets the engine-wide log verbosity level at runtime.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LEngineGetFrameProfileResult Type

- Generated result shape from @field tags.

##### Fields

- `app_frame_total_ms` (`number`): App frame total ms.
- `app_render_ms` (`number`): App render ms.
- `app_tick_ms` (`number`): App tick ms.
- `app_update_ms` (`number`): App update ms.
- `callback_total_ms` (`number`): Callback total ms.
- `draw_ms` (`number`): Draw ms.
- `draw_ui_ms` (`number`): Draw ui ms.
- `fixed_update_ms` (`number`): Fixed update ms.
- `process_late_ms` (`number`): Process late ms.
- `process_ms` (`number`): Process ms.
- `process_physics_ms` (`number`): Process physics ms.

##### Methods

- No documented methods.

#### LEngineGetResourceStatsResult Type

- Generated result shape from @field tags.

##### Fields

- `app_frame_total_ms` (`number`): App frame total ms.
- `app_render_ms` (`number`): App render ms.
- `app_tick_ms` (`number`): App tick ms.
- `app_update_ms` (`number`): App update ms.
- `budget_bytes` (`integer`): Budget bytes.
- `callback_total_ms` (`number`): Callback total ms.
- `canvas_bytes` (`integer`): Canvas bytes.
- `canvas_count` (`integer`): Canvas count.
- `draw_ms` (`number`): Draw ms.
- `draw_ui_ms` (`number`): Draw ui ms.
- `fixed_update_ms` (`number`): Fixed update ms.
- `font_bytes` (`integer`): Font bytes.
- `font_count` (`integer`): Font count.
- `process_late_ms` (`number`): Process late ms.
- `process_ms` (`number`): Process ms.
- `process_physics_ms` (`number`): Process physics ms.
- `shader_bytes` (`integer`): Shader bytes.
- `shader_count` (`integer`): Shader count.
- `texture_bytes` (`integer`): Texture bytes.
- `texture_count` (`integer`): Texture count.
- `total_bytes` (`integer`): Total bytes.

##### Methods

- No documented methods.

#### LEngineMemoryUsageResult Type

- Generated result shape from @field tags.

##### Fields

- `lua_bytes` (`integer`): Lua bytes.
- `lua_kb` (`number`): Lua kb.

##### Methods

- No documented methods.

#### LRuntimeGetConfigResult Type

- Generated result shape from @field tags.

##### Fields

- `config_reload_revision` (`integer`): Config reload revision.
- `default_font_bold` (`boolean`): Configured bold variant flag for the default render font.
- `default_font_size` (`integer`): Configured built-in default render font point size.
- `fixed_update_tick_rate` (`number`): Fixed update tick rate.
- `frame_budget_warn_ms` (`number`): Frame budget warn ms.
- `log_level` (`string`): Log level.
- `lua_callback_timeout_ms` (`number`): Lua callback timeout ms.
- `physics_tick_rate` (`number`): Physics tick rate.
- `runtime_mode` (`string`): Runtime mode.
- `vsync` (`boolean`): Vsync.

##### Methods

- No documented methods.

#### LRuntimeGetInfoResult Type

- Generated result shape from @field tags.

##### Fields

- `engine` (`string`): Engine name.
- `lua_version` (`string`): Lua version string.
- `memory` (`number`): Total physical memory in MiB.
- `os` (`string`): Host operating system name.
- `processors` (`integer`): Number of logical processors.
- `renderer` (`string`): Renderer backend name.
- `version` (`string`): Engine version string.

##### Methods

- No documented methods.

#### LRuntimeGetLastErrorResult Type

- Generated result shape from @field tags.

##### Fields

- `category` (`string`): Error category.
- `code` (`string`): Error code.
- `hint` (`string?`): Optional hint for resolution.
- `message` (`string`): Error message.

##### Methods

- No documented methods.

#### LRuntimeParseArgsResult Type

- Generated result shape from @field tags.

##### Fields

- `flags` (`table`): Boolean flags indexed by name.
- `options` (`table`): String options indexed by name.
- `positional` (`string[]`): Positional argument values.

##### Methods

- No documented methods.

#### LRuntimeRunBatchResult Type

- Generated result shape from @field tags.

##### Fields

- `error` (`string?`): Error message when status is `failed`.
- `status` (`string`): Task status: `passed`, `failed`, or `skipped`.
- `time` (`number`): Elapsed time in seconds.

##### Methods

- No documented methods.

## References

- `audio`: Imports or references `audio` from `src/audio/`.
- `camera`: Imports or references `camera` from `src/camera/`.
- `event`: Imports or references `event` from `src/event/`.
- `filesystem`: Imports or references `filesystem` from `src/filesystem/`.
- `image`: Imports or references `src/image/`. Cross-group dependency from `Core Runtime` into `Platform Services`.
- `input`: Imports or references `input` from `src/input/`.
- `light`: Imports or references `light` from `src/light/`.
- `lua_api`: `src/lua_api/system_api.rs`, `src/lua_api/engine_api.rs`, and `src/lua_api/register.rs` expose the runtime contract to Lua. `src/runtime/` must not import the binding layer.
- `midi`: Imports or references `src/midi/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `mods`: Imports or references `src/mods/`. Cross-group dependency from `Core Runtime` into `Feature Systems`.
- `parallax`: Imports or references `parallax` from `src/parallax/`.
- `particle`: Imports or references `particle` from `src/particle/`.
- `province`: Imports or references `src/province/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `raycaster`: Imports or references `raycaster` from `src/raycaster/`.
- `render`: Imports or references `render` from `src/render/`.
- `repl`: Imports or references `src/repl/`. Cross-group dependency from `Core Runtime` into `Edge/Integration`.
- `sprite`: Imports or references `sprite` from `src/sprite/`.
- `tilemap`: Imports or references `tilemap` from `src/tilemap/`.
- `timer`: Imports or references `timer` from `src/timer/`.
- `ui`: Imports or references `ui` from `src/ui/`.

## Notes

- No additional module-specific notes.
