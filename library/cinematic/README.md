# cinematic

A multi-track scrubbable cutscene system. Lets you compose Timeline tracks for camera moves, dialogue lines, audio cues, tween animations, and custom signals — all scrubbed by a single playhead with pause/resume/skip support.

## Usage

```lua
local cinematic = require("library/cinematic")

local tl = cinematic.Timeline.new()
tl:cameraTo(0, { x = 400, y = 200, zoom = 1.5, duration = 2.0 })
tl:dialog(1.5, { speaker = "Guard", text = "Who goes there?" })
tl:audio(1.8, { file = "assets/audio/thunder.ogg" })
tl:signal(4.0, "cutscene_end")

tl:play()

function lurek.update(dt)
    tl:update(dt)
end
```

## Dependencies

- `lurek.tween`, `lurek.camera`, `lurek.audio`, `lurek.event` (all optional)
