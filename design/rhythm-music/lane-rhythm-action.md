# Lane Rhythm Action

**Category:** Rhythm and music  
**Reference games:** Friday Night Funkin', Rhythm Doctor, Muse Dash, Crypt of the NecroDancer  
**Document type:** Technical game design and architecture

## Design target

A timing-first 2D rhythm game where authored charts, input judgement, audio sync, readable feedback, and replayable scoring are the product core. The game can be lane-based, call-and-response, or rhythm-action, but the architecture must treat music timing as authoritative instead of approximating beats through frame time.

## Market positioning

Use the reference set to frame expectations around precise judgement, readable chart language, retry speed, and song identity. Target itch.io with a short song pack, strong character or visual hook, and immediate browser-like onboarding. Target Steam with calibration tools, controller/keyboard remapping, practice mode, difficulty tiers, leaderboards or local score attack, accessibility options, and enough licensed or original music to justify repeat play.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Beat timing and judgement | `lurek.audio.newBeatClock`, `lurek.audio.beatClockFromSource`, `lurek.audio.judgeBeat` |
| Music and sound routing | `lurek.audio`, audio buses, fades, source position queries |
| Input bindings and replay | `lurek.input`, action maps, recording/playback support |
| Chart data | `lurek.filesystem`, `lurek.serialize`, `lurek.dataframe` |
| Note rendering and effects | `lurek.render`, `lurek.sprite`, `lurek.animation`, `lurek.tween`, `lurek.particle` |
| Menus and results | `lurek.ui`, `lurek.scene`, `lurek.save` |
| Debug and calibration | `lurek.overlay`, `lurek.log`, `lurek.devtools` |

## Runtime architecture

Make the song timeline the authority. A `SongSession` owns source handle, chart metadata, beat clock, calibration offset, judgement windows, score state, combo state, and current section. The update loop samples audio time, computes visible chart windows, resolves input against pending notes, and emits result records. Rendering consumes those records for hit flashes, lane effects, character animation, and UI feedback.

Chart loading should produce stable note IDs, beat positions, lanes/actions, hold durations, difficulty labels, and optional event markers for camera, animation, lyrics, or boss attacks. Do not let rendering create or destroy gameplay notes. Notes exist in chart-time; visibility is a projection from audio time plus scroll speed.

Use separate scenes for song select, calibration, gameplay, pause, fail, and result. A Steam-oriented build needs options for global offset, per-device latency, audio volume buses, colorblind lane markers, reduced flashes, and practice sections.

## Suggested project structure

```text
my_rhythm_game/
  data/songs/catalog.toml
  data/songs/*/chart_easy.json
  data/songs/*/chart_hard.json
  data/rules/judgement.toml
  scripts/state/song_session.lua
  scripts/systems/chart_loader.lua
  scripts/systems/judgement.lua
  scripts/systems/scoring.lua
  scripts/systems/calibration.lua
  scripts/ui/song_select.lua
  scripts/ui/results.lua
  assets/music/
  assets/characters/
  assets/ui/
```

## Data and content model

- Author songs, charts, judgement windows, lane themes, character animation cues, and result thresholds as data, not hidden constants.
- Store score records by song ID, difficulty, modifier set, calibration profile, and chart hash so patched charts do not corrupt old scores.
- Keep replay data as input events plus chart/audio identifiers rather than captured world state.
- Save unlocked songs, best ranks, accessibility settings, offset profiles, and tutorial completion through `lurek.save`.

## Technical design notes

- Use `lurek.audio` beat clocks and source position queries for judgement; `dt` should animate visuals but not define hit timing.
- Use `lurek.input.define`, action categories, conflict detection, and serialized bindings for keyboard/gamepad parity.
- Use `lurek.ui` for song filters, difficulty selection, calibration sliders, result breakdowns, and accessibility settings.
- Use `lurek.overlay` to show audio time, chart beat, latency offset, nearest note delta, dropped input events, and score state during development.

## Vertical slice acceptance

The first slice should include three songs, two difficulties per song, calibration, four-lane input, tap and hold notes, miss/bad/good/perfect judgements, combo, fail state, result screen, saved best scores, and a debug overlay for timing deltas.

## Risks

The major risk is timing drift. Do not couple judgement to frame rate, animation progress, or render visibility. Validate every chart against audio start, offset, BPM changes, and note windows before treating scoring bugs as player skill issues.
