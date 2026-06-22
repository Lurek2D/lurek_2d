# scene manual spec overlay

## TL;DR

- Manages stack-based scenes, overlays, and metatable factories.
- Drives lifecycle hooks, lazy preloading, and timed visual transitions.
- Shares parameters, serializes stack snapshots, and sorts sprite depths.

## Summary

- The `scene` module is the high-level flow coordinator for users who want menus, gameplay states, overlays, pause layers, and transitions to behave like one ordered stack instead of a collection of unrelated toggles.
- Scene stacks, shared scene data, lifecycle callbacks, transitions, depth sorting, object containers, and render bridges matter because changing what is active usually affects simulation, UI, rendering, and progression at the same time.
- Push, pop, replace, and overlay semantics are central to the module's value. They let projects layer pause menus over gameplay, cutscenes over maps, or modal flows over existing screens without destroying the context underneath.
- Lifecycle hooks make scenes more than labels: entry, exit, pause, resume, preload, and ready-style behavior let logic and resources react cleanly when control moves between states.
- Shared data, symbolic registration, and transition support extend the feature from visual navigation into game-flow management, so scenes can exchange parameters, re-enter deterministically, and present state changes as unified runtime transitions.
- Stack semantics are one of the hardest recurring problems in game architecture, and this module gives a durable answer to what is active, what is suspended underneath, and how control returns cleanly after an overlay or interruption.
- That matters for pause flows, inventory layers, tutorials, map screens, cutscenes, modal dialogs, failure states, and tool-driven previews that should temporarily change the foreground without tearing down the underlying gameplay context.
- Transition support keeps pacing and presentation tied to the same model as logical scene changes. Fades, wipes, slides, or other handoff effects become part of one scene-change contract instead of ad hoc renderer tricks detached from lifecycle state.
- Shared scene data also broadens the module beyond navigation. Scenes can hand parameters, preserved runtime state, or restore information to one another in a way that stays explicit enough for tooling, replay, or save-oriented workflows.
- That stack model keeps layered game flow understandable once several temporary states coexist.
- Read `scene` as the owner of game-flow structure. Other systems perform the content work inside a scene, but this module decides how scenes are organized, layered, transitioned, and handed off over time.

This module primarily collaborates with `image`, `math`, `render`, `runtime`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
