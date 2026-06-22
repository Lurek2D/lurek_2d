# cinematic manual spec overlay

## TL;DR

- Multi-track timeline system for orchestrating game sequences.
- Supports Tween, Camera, Audio, and Signal track types with frame-accurate scheduling.

## Summary

The `cinematic` module is the timeline authoring surface for cutscenes, scripted reveals, and other multi-system sequences. It lets motion, camera, audio, tween, and signal tracks advance against one playhead so designers can choreograph timing instead of hand-synchronizing callbacks. Playback controls such as play, pause, seek, loop, labels, and branching keep the same timeline useful for both fixed sequences and reactive presentation logic. It gives multi-system presentation one explicit sequencing surface inside the engine.

This module is mostly self-contained inside the `Edge/Integration` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
