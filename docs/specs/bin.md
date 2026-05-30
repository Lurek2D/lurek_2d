# bin

## TL;DR

- The `bin` module groups standalone executable entry points for headless tasks and normal app launch, with clear command behavior and process-level integration.


## General Info

- Module group: `Edge/Integration`
- Source path: `src/bin/`
- Binding: None direct
- Namespace: None direct
- Lua API surface: `0` functions, `0` types, `0` methods
- Rust test path(s): None found in the workspace
- Lua test path(s): None found in the workspace

## Summary

The `bin` module is the executable entry layer for process-level tasks. It does not define gameplay features. Instead, it provides focused programs that start the engine in specific modes, such as normal interactive launch or headless automation workflows.

Its functional goal is clear command behavior. Each binary maps user input to a concrete operation, runs that operation with predictable side effects, reports results, and exits with meaningful status codes. This makes the tooling usable both by humans and by CI scripts.

The module is intentionally small and integration-focused. Heavy logic should stay in shared library modules, while binaries stay thin wrappers around those APIs. This keeps maintenance costs lower and avoids logic drift between tool paths and runtime paths.

In practice, this module helps operational work stay stable: validation runs, packaging, screenshot pipelines, and standard launch flow can all be invoked through explicit entry points. That reliability is the main value of this module boundary.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Files

### lurek_headless.rs

- Implements the headless CLI runner used for validation, packaging, and screenshot batch workflows.
- Dispatches subcommands into deterministic offline operations without opening an interactive runtime window.
- Runs game validation tooling and archive packaging against target directories for CI and release prep.
- Captures batch screenshots across multiple games to support visual smoke checks in automation pipelines.
- Serves as the command-line entrypoint for non-interactive engine operations.

### lurekc.rs

- Defines the console-suppressed desktop launcher that delegates to the shared engine bootstrap.
- Reuses the main runtime startup path while controlling subsystem behavior on Windows.
- Serves as the minimal binary entrypoint for standard interactive game launch.

## Lua API Ref

- No dedicated direct `lurek.*` namespace is exposed by this module.
