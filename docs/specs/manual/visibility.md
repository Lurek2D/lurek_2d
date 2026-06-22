# visibility manual spec overlay

## TL;DR

- Geometry-agnostic fog-of-war and shadowcasting field-of-view simulation.

## Summary

- The `visibility` module is the shared answer to fog-of-war, line-of-sight, and remembered exploration for users building map-aware gameplay.
- It combines adjacency rules, reveal cost, ownership flags, events, shadowcasting, and stored state so the same module can answer both gameplay questions and presentation needs.
- That makes it more than a single visibility check: current sight, remembered discovery, reveal transitions, and display-friendly output are meant to behave as one coherent information system.
- Team-specific reveal state and remembered exploration are especially important because many map-aware games care not only about what is visible now, but also about what was discovered earlier and by whom.
- That unified state is what lets fog-of-war, scouting, and map presentation stay aligned.
- It also keeps team knowledge explicit.
- Read this module as the authority for what an actor currently knows about a space.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
