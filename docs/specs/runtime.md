# runtime

## TL;DR

- The `runtime` module forms the very foundation of the Lurek2D dependency graph.

## General Info

- Module group: `Core Runtime`
- Source path: `src/runtime/`
- Lua API path(s): None direct
- Primary Lua namespace: `lurek.runtime`
- Rust test path(s): tests/rust/unit/runtime_tests.rs, tests/rust/unit/window_tests.rs, tests/rust/ext/graphics_runtime_smoke_tests.rs, plus runtime-focused unit coverage embedded in src/runtime/messages.rs
- Lua test path(s): tests/lua/config/test_config.lua, tests/lua/unit/test_runtime_core_unit.lua

## Summary

As a Core Runtime tier component, it defines the essential shared state, engine configuration, unified error handling, and structured logging mechanisms upon which every other engine subsystem relies. At the heart of the module is `SharedState`, a central, mutable state container accessed via `RefCell` borrows. It orchestrates cross-module communication during a frame, tracking window state, input aggregation, timing profiles, asynchronous file I/O (GameFS), render pipeline configurations, and managing slot-map resource pools (textures, fonts, shaders, particle systems, etc.) while enforcing memory budgets via LRU eviction.

Configuration is driven by the `Config` struct, which parses the `conf.toml` file at startup. It dictates window settings, renderer preferences, performance caps (like Lua callback timeouts), and feature-toggles (`ModulesConfig`) that selectively load or auto-disable engine subsystems based on prerequisites. The runtime actively supports hot-reloading for many configuration values, allowing live tweaks to target FPS, physics ticks, log levels, and viewport settings without restarting the game. The module also robustly handles different startup modes (`gui`, `tui`, `headless`, `cli`), with the headless path specifically designed for script automation and CI testing without requiring window or audio contexts.

Error handling is unified under `EngineError`, an exhaustive enum that categorizes failures across all domains (IO, Lua, GPU, audio, network, physics) with stable, machine-readable codes (e.g., `E1001`) and actionable recovery hints. Complementing this is a comprehensive log message catalog driven by an embedded TOML file. It provides structured, consistent diagnostic output (using codes like `L001` or `G012`) via the `log_msg!` macro. To ensure safe and efficient resource management across the engine, the module defines strongly-typed `slotmap` keys (`TextureKey`, `FontKey`, etc.) that act as lightweight, generationally-checked handles suitable for storage within Lua userdata. Though most of the infrastructure is consumed through higher-level modules, the canonical runtime Lua surface is `lurek.runtime`.

### Lua API Bridge and Registration

The old `lua_api` spec duplicated this runtime namespace. Its relevant contract now lives here: `src/lua_api/` is the Edge/Integration bridge that creates sandboxed Lua VMs, installs the sealed `lurek` global, and registers every enabled `lurek.*` namespace against the runtime `SharedState`.

Module registration is trait-based. Each binding file implements a `register(lua, lurek, state)` entry point, and `src/lua_api/register.rs` walks the static `MODULES` slice using `always!` and `gated!` entries. Feature-gated modules that cannot appear in that static slice are registered after the standard pass. Binding files remain translation-only: they parse Lua values, borrow `SharedState`, call domain modules, and convert results back to Lua without owning business logic.

For the full Lua/Rust boundary design, see [docs/architecture/lua-rust-boundary.md](../architecture/lua-rust-boundary.md).

## Files

### config.rs

- This file defines the typed runtime configuration model that turns human-edited TOML into engine startup policy.
- It gathers window, renderer, module, performance, and environment-facing options into one coherent structure.
- Default values and user overrides meet here, which lets the engine begin from a known baseline and then absorb project-specific changes.
- Module toggles are not merely flags in this file.
- They also participate in dependency validation so invalid feature combinations degrade into a supported runtime shape.
- Serialization support matters here because configuration is both loaded from disk and, in some workflows, written back or inspected programmatically.
- The design is intentionally declarative so callers can reason about engine behavior before subsystems are even initialized.
- This file therefore acts as the contract between external project configuration and internal runtime setup.
- Many startup decisions appear later in code, but their authoritative knobs are described here.
- In practice this is the runtime's policy schema expressed as Rust data.

### error.rs

- This file centralizes engine failure reporting so subsystems can surface problems through one shared error vocabulary.
- Variants are grouped by operational meaning as well as by source, which helps logs, tools, and UI distinguish recovery paths.
- Stable codes and snapshot forms exist here because runtime failures must remain readable both to humans and to external automation.
- The convenience result alias keeps the rest of the codebase aligned with the same error contract.
- In effect this file is the runtime's common language for things going wrong.

### headless.rs

- This file implements the runtime path for executing games and scripts without opening a window or interactive frontend.
- It exists for automation, tests, batch jobs, and command-line workflows that still need the engine lifecycle to run correctly.
- Startup wiring here prepares the Lua environment, script roots, and output behavior so headless sessions still feel like real engine sessions.
- Frame stepping follows the normal update rhythm closely enough that gameplay logic can be exercised without a graphical loop.
- Error mapping is also handled here because command-line callers need process-oriented outcomes while tests may need structured failures.
- The file is therefore the engine's bridge from full runtime behavior to non-visual execution contexts.

### log_messages.rs

- This file defines the stable identifier layer for engine logs so messages can be grouped, filtered, and recognized across versions.
- Codes are organized by subsystem domain rather than by source file, which makes operational analysis easier than raw string logs alone.
- The constant catalog gives every log site a compact symbolic handle that remains readable in terminals and machine parsers.
- Log level overrides also live here because message identity and message visibility are tightly related runtime concerns.
- The supporting macro turns those codes into consistent formatted output without forcing every call site to rebuild the same pattern.
- Stability is a design goal of this file.
- External tools, tests, and support workflows can rely on these identifiers without scraping fragile prose.
- The file therefore acts as the diagnostic index of the engine rather than just a pile of string constants.
- It gives the runtime a structured logging spine that other modules can lean on.
- When logs matter for debugging or automation, this is where their shared vocabulary begins.

### messages.rs

- This file loads and resolves the embedded message catalog that backs structured runtime text.
- Lookup behavior is lazy so the engine pays setup cost only when message resolution is actually needed.
- Nested catalog data is flattened through recursive extraction so callers can ask for stable identifiers without knowing storage shape.
- Fallback behavior is defined here as well, ensuring missing catalog entries degrade into readable raw keys instead of silent blanks.

### mod.rs

- This module provides the foundational runtime layer that the rest of the engine stands on during startup and per-frame execution.
- Configuration, shared mutable state, error contracts, operating modes, and resource handle types are gathered here.
- At the highest level this is the engine's coordination core, not a gameplay feature module.

### mode.rs

- This file defines the small mode vocabulary that tells the engine which style of runtime entry path to follow.
- String conversion rules are kept close to the enum so configuration parsing and CLI parsing agree on accepted names.
- Parse errors remain explicit here because mode selection failures should be readable before the rest of startup proceeds.
- The file therefore turns user-facing startup labels into one typed branch point for the runtime.

### os.rs

- This file exposes the runtime's view of the host operating system for startup policy and script-facing platform checks.
- Detection is compile-time oriented rather than probe-heavy, which keeps the answer stable and cheap for every call site.
- Startup code relies on this information for platform-shaped defaults such as paths and environment-sensitive behavior.
- Lua-visible platform queries also depend on the same source so scripts and Rust agree on the current host label.
- The file is intentionally narrow because it exists to answer identity questions, not to abstract whole platform APIs.

### resource_keys.rs

- This file defines the typed handle keys used to reference runtime-managed resources without exposing storage internals.
- The handles are cheap to copy and safe to hold across frames, which is essential for Lua userdata and engine-facing APIs.
- It is the type-safety layer that lets many resource pools share one slotmap-style ownership pattern.

### shared_state.rs

- This file defines the shared mutable runtime container that lets otherwise separate engine systems coordinate during startup and each frame.
- It gathers cross-cutting state for windowing, timing, resources, input, rendering, async work, and several feature subsystems into one borrowable hub.
- Resource pools live here because textures, canvases, fonts, shaders, meshes, and similar assets need one authoritative ownership home.
- Frame-local render state also accumulates here so gameplay code can enqueue visual intent without talking directly to the GPU backend.
- Input aggregation and timing data share the same structure because many systems consume them repeatedly throughout a frame.
- Memory budget enforcement belongs here as well, since eviction decisions depend on a global view of runtime-managed assets.
- Async filesystem operations are tracked here so polling and completion can integrate cleanly with the main loop.
- Several feature modules store their live handles or derived outputs in this container when they need to survive across calls and script boundaries.
- The file is intentionally broad because it is not modeling one feature.
- It is modeling the practical state surface of the whole running engine.
- Without this container, subsystems would duplicate ownership logic or pass oversized parameter sets through every call.
- In practice this is the mutable coordination nucleus of the runtime.

## Lua API Ref

- Binding: None direct
- Namespace: `lurek.runtime`

### Functions

- `lurek.engine.fps`: Returns the latest frames-per-second value stored by the runtime.
- `lurek.engine.frameCount`: Returns the number of frames counted by the shared runtime clock.
- `lurek.engine.getConfigRevision`: Returns the configuration reload revision counter.
- `lurek.engine.getFrameBudget`: Returns the target frame budget for a 60 FPS update loop.
- `lurek.engine.getFrameProfile`: Returns the latest frame timing profile split by engine phase.
- `lurek.engine.getFrameProfileText`: Returns the latest frame timing profile formatted as one text line.
- `lurek.engine.getResourceStats`: Returns current resource memory usage and object counts by resource kind.
- `lurek.engine.getVersion`: Returns the engine crate version string embedded at build time.
- `lurek.engine.isDebug`: Returns whether the engine binary was built with debug assertions.
- `lurek.engine.memoryUsage`: Returns Lua VM memory usage as bytes and rounded kilobytes.
- `lurek.engine.platform`: Returns the current desktop operating system name.
- `lurek.engine.setResourceBudget`: Sets the resource memory budget used by resource statistics reporting.
- `lurek.engine.uptime`: Returns total engine runtime accumulated by the main loop.
- `lurek.runtime.errorSnapshot`: Creates a JSON-encoded error snapshot from a message string, useful for diagnostics and error reporting.
- `lurek.runtime.getArch`: Returns the CPU architecture of the host system.
- `lurek.runtime.getArgs`: Returns the command-line arguments passed to the engine as a 1-indexed table of strings.
- `lurek.runtime.getBatchResults`: Summarizes batch results by counting passed, failed, and skipped tasks.
- `lurek.runtime.getClipboardText`: Reads the current text content from the system clipboard. Returns an empty string if the clipboard is unavailable or contains no text.
- `lurek.runtime.getConfig`: Returns a table containing the current engine runtime configuration values.
- `lurek.runtime.getDebugOverlay`: Returns whether the on-screen debug overlay is currently enabled.
- `lurek.runtime.getEnv`: Reads an environment variable by name. Returns `nil` if the variable is not set.
- `lurek.runtime.getInfo`: Returns a table with comprehensive engine and host information.
- `lurek.runtime.getLastError`: Returns the last error for Lua scripts in this module.
- `lurek.runtime.getLogLevel`: Returns the current engine log verbosity level as a string.
- `lurek.runtime.getMemorySize`: Returns the total physical memory of the host system in megabytes.
- `lurek.runtime.getMessage`: Resolves a message string by its identifier from the engine message catalog.
- `lurek.runtime.getMessageCount`: Returns the total number of messages registered in the engine message catalog.
- `lurek.runtime.getOS`: Returns the name of the host operating system as a string.
- `lurek.runtime.getPowerInfo`: Returns the current power supply state, battery percentage, and estimated time remaining.
- `lurek.runtime.getPreferredLocales`: Returns a list of the user's preferred locale identifiers from the operating system.
- `lurek.runtime.getProcessorCount`: Returns the number of logical processors available on the host machine.
- `lurek.runtime.getVersion`: Returns the semantic version string of the Lurek2D engine.
- `lurek.runtime.hasMessage`: Checks whether a message identifier exists in the engine message catalog.
- `lurek.runtime.log`: Writes a message to the engine log at the specified severity level.
- `lurek.runtime.openURL`: Opens a URL in the default system browser. Only `http://`, `https://`, and `mailto:` schemes are permitted.
- `lurek.runtime.parseArgs`: Parses command-line arguments into structured flags, options, and positional values. Supports `--key=value`, `--key value`, `-flag`, and `--` end-of-options.
- `lurek.runtime.reloadConfig`: Requests a reload of the engine configuration from `conf.lua`. The reload is deferred until the next frame.
- `lurek.runtime.runBatch`: Executes a table of named task functions sequentially, collecting pass/fail results and elapsed time for each.
- `lurek.runtime.setClipboardText`: Copies a string to the system clipboard. Logs a warning if the clipboard is unavailable or the write fails.
- `lurek.runtime.setDebugOverlay`: Enables or disables the on-screen debug overlay that shows FPS, draw calls, and other diagnostics.
- `lurek.runtime.setLogLevel`: Sets the engine-wide log verbosity level at runtime.

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
