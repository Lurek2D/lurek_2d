# midi manual spec overlay

## TL;DR

- Synthesizes MIDI files.

## Summary

- The `midi` module is the playback surface for projects that want symbolic music control instead of treating every cue as rendered audio.
- It combines transport, playback state, and SoundFont-backed synthesis under one runtime surface.
- That makes it useful for adaptive scoring, live control, and note-driven playback.
- Read it as the bridge from MIDI data to audible output.

This module primarily collaborates with `audio`, `runtime`. Its responsibility should stay inside the `Platform Services` group rather than absorb behavior owned by those neighbors.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
