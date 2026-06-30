# mods manual spec overlay

## TL;DR

- Manages mod lifecycles using dependency sorting, permission sandboxing, and hot reloads.

## Summary

- The `mods` module is the governed extension surface for projects that want external content packs to behave like controlled runtime extensions instead of unrestricted code drops.
- Schemas, registries, loaders, managers, and sandbox rules work together so mod content can be discovered, validated, ordered, and constrained under one lifecycle.
- Real mod workflows need more than file loading: projects also need dependency sorting, manifest metadata, capability boundaries, reload behavior, and explicit trust policy.
- That policy layer is the main reason the module exists, because external content can be powerful without automatically receiving unrestricted code or data access.
- The same system is useful for shipped player-facing mod ecosystems and for internal extension-style content workflows during development.
- Controlled reload behavior and dependency ordering are especially important because modded projects need predictable iteration, recoverable startup, and explicit load precedence rather than a best-effort folder scan.
- Default sandbox policy is deny-by-default for APIs, hooks, and read roots unless a mod is promoted into an explicit allow-all or allow-list mode.
- Sandbox policy can now travel with manifest metadata or Lua-created `LMod` handles, and `LMod:runHook(...)` is the live execution boundary that activates API, hook, filesystem, network, and memory enforcement.
- Manifest and content parsing are strict TOML decoders with byte, field, and count limits instead of line-based best-effort parsing.
- Discovery and reload flows now build structured scan and load-plan reports so missing dependencies, cycles, checksum failures, and path-policy violations are explicit.
- Hot reload is atomic at the registry level: the previous valid snapshot stays active when the new manifest set fails validation.
- `sandbox.max_memory` is enforced at hook execution time when the underlying Lua runtime supports memory limits; file writes and top-level network entry points are blocked through the normal Lua API surface while the sandbox is active.
- It keeps mod power visible, explicit, and reviewable.
- Read `mods` as the runtime policy layer for modded content: filesystem and runtime systems provide capabilities, but `mods` decides how external content is described, admitted, isolated, and managed.

This module primarily collaborates with `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- Manifest `checksum` is an integrity checksum, not a trust signature. The legacy key name `signature` is still accepted as a checksum alias for compatibility.
- Allowed read paths are canonical roots; prefix-only string matching is not sufficient for mod sandbox reads.
- `ModScanPolicy`, `ModScanReport`, `ModLoadPlan`, and `ModReloadReport` are the authoritative diagnostics surfaces for scans, dependency validation, and hot reload outcomes.
- Manifest validation now enforces identifier, capability, asset-path, config-schema, and byte/count limits before a mod joins the registry.
- Capability enforcement currently includes runtime boundary checks for `lurek.filesystem`, `lurek.grep`, and top-level `lurek.network` entry points, including write denial when a mod sandbox disables file writes.

## Architecture Links

- [Module Scope Boundaries](../../architecture/module-scope-boundaries.md)
- [Runtime Tooling Boundaries](../../architecture/runtime-tooling-boundaries.md)
