# Runtime Tooling Boundaries

## TL;DR

- `crates/lurek_schema` owns neutral schema/data contracts reused by runtime tooling.
- `docs` owns reflection, editable catalogs, and export payload shaping for any dotted namespace.
- `validator` owns explicit allowlist checks over configured API prefixes; it does not discover live APIs on its own.
- `filesystem` resolves readable paths, `mods` enforces sandbox policy, and `grep` owns text search over the approved result.
- `log` owns sink registration and dispatch, while `devtools` owns developer-facing log policy and retained history through hidden shared sinks.

## Shared Schema Contract

- `crates/lurek_schema` is the owner for schema-shaped structs that are not inherently tied to one runtime module.
- `mods`, docs/export tooling, and validator-adjacent code may reuse those shapes, but they must not fork local copies just to rename fields or re-express the same contract.
- Lua bindings and engine modules may adapt these structs, but the crate remains the neutral source of truth for shared schema layout.

## Docs And Validator

- `docs` may scan arbitrary Lua tables when the caller supplies `table`, `namespace`, and optional `module` scan options.
- `docs` owns catalog construction, entry mutation, reflection, and export. It does not decide whether a namespace is allowed in gameplay or mod content.
- `validator` owns API prefix validation through explicit allowlists.
- Default validator helpers still seed the built-in `lurek.*` list, but custom flows must pass their own dotted roots such as `game.quest`.
- `validator` must not depend on live `docs` state at runtime. The integration boundary is plain strings: qualified names and allowed prefixes.

## Grep, Filesystem, And Mods

- `grep` owns literal search, JSON key search, log search, and Lua-facing result shaping.
- `filesystem` owns GameFS path resolution and host/logical path translation rules.
- `mods` owns whether the active sandbox may call `grep` at all and whether a requested read path is allowed.
- Every Lua-facing grep read must resolve through `SharedState` and `GameFS`, not direct host-path reads.
- Every Lua-facing grep result must return logical GameFS-style paths back to scripts, never leaked host filesystem paths.

## Log And Devtools

- `log` owns the shared sink registry, sink formats, dispatch, file/memory/callback implementations, and user-managed sink APIs.
- `devtools` owns developer log level policy, console mirroring policy, retained history, and optional file persistence for devtools messages.
- Devtools logging must flow through the shared `log` sink registry using a stable tag so visible `lurek.log` sinks can observe the same events.
- Devtools-owned history/file sinks are internal implementation details and must stay hidden from `lurek.log.listSinks`, `removeSink`, and `clearSinks`.

## Enforcement Rules

- Convenience APIs may default to `lurek.*`, but reusable tooling paths must not hardcode `lurek` as the only valid namespace.
- Tooling modules that read files for Lua scripts must go through GameFS plus active sandbox enforcement instead of bypassing those owners.
- Internal observability sinks may share the public registry, but they must be marked hidden so user sink-management calls only affect user-visible sinks.
