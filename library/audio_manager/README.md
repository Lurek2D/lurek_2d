# audio_manager

A music and SFX orchestration layer on top of `lurek.audio`. Adds music crossfade, per-group volume control, SFX pooling, and a mute/unmute API that native `lurek.audio` does not expose as a single unit.

## Usage

```lua
local AudioManager = require("library/audio_manager")
local am = AudioManager.new({ master_volume = 0.8 })

am:playMusic("assets/audio/theme.ogg", { loop = true, fade_in = 1.0 })
am:playSfx("jump")
am:setGroupVolume("sfx", 0.5)
am:crossfade("assets/audio/battle.ogg", 2.0)

-- call every frame
function lurek.update(dt)
    am:update(dt)
end
```

## Dependencies

- `lurek.audio` (optional — stubs work headlessly in tests)
