# rhythm

A BPM-aware beat-grid scheduler for rhythm games. Drives a Clock that fires beat and bar events at precise intervals, optionally synchronized to an audio source position. Supports BPM ramping, off-beat scheduling, and subdivisions (quarter, eighth, sixteenth notes).

## Usage

```lua
local rhythm = require("library/rhythm")

local clock = rhythm.Clock.newClock({ bpm = 120, time_sig = { 4, 4 } })

clock:on("beat", function(beat_num)
    -- spawn note at beat_num
end)
clock:on("bar", function(bar_num)
    print("Bar", bar_num)
end)

clock:start()

function lurek.update(dt)
    clock:update(dt)
end

-- Sync to audio
clock:fromAudio(music_source)
```

## Dependencies

- `lurek.audio.Source.getPosition` (optional), `lurek.timer.getMicroTime` (optional)
