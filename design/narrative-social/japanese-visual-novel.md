# Japanese Visual Novel

> Category: `narrative-social`
> Scope: story-first Japanese-style visual novel, kinetic novel, route-based romance/drama, mystery VN, courtroom VN, or social deduction VN built with Lurek2D.
> Implementation tracker: #47

## Market positioning

A Japanese visual novel built in Lurek2D should sell the promise of a polished reading experience with expressive characters, strong pacing, attractive UI, and reliable save/rollback behavior. The target is not an editor-first Ren'Py clone. The target is a code-first Lua workflow that gives writers and solo developers enough reusable runtime structure to build a professional VN without rebuilding backlog, route flags, save slots, auto-read, skip mode, gallery unlocks, and scene presentation in every project.

Best fit:

- short commercial VN for itch.io or Steam
- kinetic novel with high presentation polish
- branching romance or mystery with route flags and endings
- courtroom, investigation, social deduction, or character-driven adventure
- AI-assisted writing prototype where generated text is still stored as authored content

Not the goal:

- a drag-and-drop VN editor
- full Ren'Py language compatibility
- mobile-first or browser-first release target
- unbounded LLM-generated dialogue without save/replay determinism

## Player promise

The player reads, listens, chooses, and revisits. Every click should feel safe: the player can view the backlog, rollback to a previous checkpoint, quick save, quick load, skip already-read lines, auto-advance lines, and trust that route choices are preserved correctly.

## Core loop

1. Title screen loads preferences, persistent unlocks, and save metadata.
2. A scene script selects background, music, character sprites, speaker, and text.
3. Text reveals with typewriter pacing, voice playback, and optional side portrait.
4. Player advances, opens backlog, toggles auto/skip, saves, loads, or rolls back.
5. Choices set flags, affinity values, route markers, inventory clues, or case evidence.
6. Chapter ends unlock CGs, scene replay entries, music room tracks, and endings.
7. New Game+ or route replay uses persistent data to branch differently.

## Suggested project structure

```text
content/games/<vn_name>/
  conf.toml
  main.lua
  assets/
    backgrounds/
    characters/
      mio/
      ren/
    cg/
    ui/
    audio/
      bgm/
      sfx/
      voice/
  data/
    script/
      chapter_01.ink
      chapter_02.ink
    characters.toml
    gallery.toml
    music_room.toml
    routes.toml
    strings/
      en.toml
      ja.toml
  scripts/
    systems/
      vn_runtime.lua
      scene_commands.lua
      backlog_view.lua
      gallery_view.lua
      save_slots.lua
    screens/
      title_screen.lua
      dialogue_screen.lua
      choice_screen.lua
      preferences_screen.lua
```

## State model

Keep story state explicit and serializable.

```lua
GameState = {
  profile = {
    language = "en",
    text_speed = 42,
    auto_delay = 1.2,
    skip_unread = false,
    volumes = { master = 1.0, music = 0.8, voice = 1.0, sfx = 0.9 },
  },
  story = {
    script_id = "chapter_01",
    knot = "START",
    cursor = 1,
    route = "common",
    flags = {},
    affinity = {},
    variables = {},
  },
  presentation = {
    background = nil,
    characters = {},
    cg = nil,
    textbox_visible = true,
    music = nil,
  },
  history = {},
  rollback = {},
  persistent = {
    seen_lines = {},
    unlocked_cg = {},
    unlocked_music = {},
    unlocked_replays = {},
    endings = {},
  },
}
```

## Data and content model

### Character registry

Character data should live in content files, not hard-coded branches.

```toml
[mio]
name = "Mio"
color = "#c8ffc8"
default_portrait = "assets/characters/mio/portrait.png"
voice_prefix = "mio"

[mio.sprites]
neutral = "assets/characters/mio/neutral.png"
smile = "assets/characters/mio/smile.png"
surprised = "assets/characters/mio/surprised.png"
```

### Script format

Use `library.narrative` Ink-flavoured scripts for route flow and tags, or raw `lurek.dialog` node tables for fully Lua-authored timelines. Tags should drive scene commands.

```ink
=== START ===
# bg:school_evening
# music:after_school
Mio waits near the gate. # speaker:mio # sprite:mio.smile:right # voice:mio_001
* Walk home with her | -> MIO_ROUTE
* Say you are busy | -> NEUTRAL_ROUTE
```

### Backlog entry

Every displayed line should emit a stable entry.

```lua
BacklogEntry = {
  line_id = "chapter_01:START:0004",
  speaker_id = "mio",
  speaker_name = "Mio",
  text_key = "chapter_01.start.0004",
  resolved_text = "Mio waits near the gate.",
  voice = "mio_001",
  tags = { "bg:school_evening", "music:after_school" },
  checkpoint_id = "chapter_01:START:0004",
  route = "common",
}
```

## Lurek API strategy

| Need | Existing surface | Strategy |
|---|---|---|
| Dialogue reveal and choices | `lurek.dialog`, `library.dialog`, `library.narrative` | Use sequencer for line reveal and choices; use narrative scripts for route flow. |
| Scene stack | `lurek.scene` | Title, load, gameplay, preferences, gallery, replay screens. |
| UI | `lurek.ui` | Retained dialogue box, choice list, backlog scroll, save slots, preferences tabs. |
| Presentation | `lurek.render`, `lurek.sprite`, `lurek.tween`, `lurek.cinematic` / `library.cinematic` | Backgrounds, CGs, character sprites, transitions, camera shake, timeline cues. |
| Audio | `lurek.audio`, `library.audio_manager` | BGM, SFX, voice, fade in/out, per-bus volume. |
| Save and persistent data | `lurek.save`, `lurek.serialize` | Slots, quick save, persistent unlocks, schema migration. |
| Localization | `lurek.i18n` | Store line keys separately from display text where possible. |
| AI-assisted workflow | `lurek.agent` | Optional script QA, branch summaries, route consistency checks. |

## Runtime architecture

The recommended architecture is a thin `library.vn` runtime that composes existing modules.

```lua
local vn = require("library.vn")

local runtime = vn.newRuntime({
  historyLimit = 300,
  rollbackLimit = 64,
  autoDelay = 1.2,
})

runtime:bindStory(story)
runtime:bindSequencer(dialog_seq)
runtime:bindSaveManager(save_mgr)
runtime:bindAudio(audio_manager)
runtime:onLine(function(entry)
  backlog:add(entry)
  persistent.seen_lines[entry.line_id] = true
end)
```

## Need implementation notes

The current engine pieces are enough for a basic VN, but a production Japanese-style VN needs a genre runtime. Track this under issue #47.

Required new library/API layer:

- `library.vn.newRuntime(opts)` for coordinating story, dialog, scene, audio, save, history, and presentation.
- Backlog/history API with stable line ids, speaker metadata, voice ids, tags, route id, and checkpoint id.
- Rollback checkpoint ring that snapshots story cursor, variables, visible presentation state, current audio cues, selected choices, and game-defined collectors.
- Auto-read and skip modes with options for read-only skip and voice-aware timing.
- Persistent unlock registry for CG gallery, music room, ending list, and scene replay.
- VN preferences model: text speed, auto delay, skip unread, font scale, textbox opacity, language, and bus volumes.
- Save-slot helpers that can collect screenshots/thumbnails later if engine screenshot access is promoted.
- Deterministic testing hooks: run until label, assert line seen, dump route flags, export backlog JSON.

Implementation should start in pure Lua under `library/vn/`. Promote to Rust only for engine-privileged pieces such as screenshot thumbnails, lower-level text shaping, or deep runtime snapshot helpers.

## Vertical slice

Build a two-scene slice before adding content volume.

Minimum slice:

- title screen with New Game, Load, Preferences, Gallery
- one school background, one bedroom background, one CG
- two character speakers, each with three expressions
- 80-120 lines of script
- two choices, one affinity flag, one route branch, one ending marker
- BGM with fade, one SFX, optional voice stub ids
- backlog view, quick save/load, normal save slot list
- auto-read and skip-read mode
- rollback to the last three checkpoints
- one gallery unlock after ending

## Test strategy

- Headless route test: load script, run to each ending, assert flags and ending ids.
- Backlog test: emit lines, choices, and voice ids; verify stable ordering and serialization.
- Rollback test: choose option A, rollback, choose option B, verify route state changes correctly.
- Save migration test: save old schema, migrate to current runtime schema.
- Localization test: same line ids resolve across `en` and `ja` string tables.

## Production risks

- Content scale grows faster than code scale; build validation tools early.
- Rollback is easy to fake for dialogue and hard to make correct across custom Lua state.
- Voice timing and skip/auto behavior can become inconsistent unless centralized.
- Japanese text needs font, line wrapping, punctuation, and UI-density QA.
- AI-generated route text must be committed as deterministic content before shipping.

## Acceptance checklist

- [ ] A VN can be played using only `main.lua`, `library.vn`, content files, and existing Lurek modules.
- [ ] Backlog survives save/load and shows speaker, text, and voice metadata.
- [ ] Rollback restores story variables, visible sprites, and selected choices.
- [ ] Auto and skip modes stop safely at choices.
- [ ] Persistent gallery/music/ending unlocks are separate from slot saves.
- [ ] Tests can run a route without manual clicking.
