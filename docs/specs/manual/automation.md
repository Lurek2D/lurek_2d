# automation manual spec overlay

## TL;DR

- Replays precise input steps, chords, device actions, and visual test assertions.

## Summary

- The `automation` module is the scripted replay layer for users who want deterministic QA, repeatable demos, or regression-oriented gameplay checks.
- It turns authored steps into real runtime input flow, covering the parsing of automation scripts, ordered playback, and step-level control over how the scenario advances.
- Steps can model keyboard, mouse, wheel, text, touch, and gamepad input, including positions, click counts, axis values, pressure, and duration-generated release events.
- Chord steps such as `ctrl+a` or `shift+mouse1` are authored as one automation event but replay as the same primitive callbacks and input-state transitions that real user input would produce.
- Simulation and assertion features work together here: the same module can replay actions, wait on conditions, and verify visual or behavioral outcomes under the same timing rules.
- Determinism is the key promise: authored steps should replay under controlled timing.
- Read it as the coordination layer above raw input and clocks. Neighboring modules provide the low-level events and timing primitives, while `automation` turns them into a reusable test workflow.

This module primarily collaborates with `event`, `input`, `runtime`, `timer`. Its responsibility should stay inside the Feature Systems group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
