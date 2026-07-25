# RFC: Effects Pipeline Consolidation

- Status: Proposed
- Owner: renderer and effect maintainers
- Canonical current boundary: [Effects, Particles, Image, And Overlay Boundaries](../effects-particles-overlay-plan.md)

## Goal

Consolidate post-processing and particle GPU execution behind renderer-owned pass planning while preserving separate domain state in `effect`, `overlay`, `particle`, and `image`.

## Proposed Work

1. Inventory current render targets, effect descriptors, particle snapshots, and Lua entry points.
2. Introduce one validated renderer-facing pass description where current paths duplicate orchestration.
3. Migrate one effect path and one particle path without changing public behavior.
4. Add recovery tests for stale handles, resize/surface loss, and unavailable GPU capabilities.
5. Remove superseded internal paths only after evidence and generated docs remain stable.

## Acceptance Gates

- One renderer-owned GPU submission path.
- No second mutable owner for particle, overlay, effect, or image state.
- Public Lua signatures remain compatible or have an accepted migration.
- Rust planning tests, Lua integration tests, and visual evidence pass.
- Rollback can restore the prior internal path without data migration.

## Retirement

Delete this RFC after implementation is reflected in current architecture, or when maintainers reject the proposal. Do not leave completed phases as permanent architecture prose.
