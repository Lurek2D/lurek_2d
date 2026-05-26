# dialog

A typewriter dialog sequencer with branching choices. Loads dialog scripts (tables or JSON), drives a typewriter effect, and surfaces a choice API for player decisions. Fires events on line start, finish, and choice selection.

## Usage

```lua
local dialog = require("library/dialog")

local seq = dialog.Sequencer.new()
seq:load({
    { speaker = "Innkeeper", text = "Welcome, traveller." },
    { speaker = "Innkeeper", text = "Stay the night?",
      choices = { { text = "Yes", goto = "rest" }, { text = "No", goto = "leave" } } },
    { id = "rest", speaker = "Innkeeper", text = "Rest well." },
    { id = "leave", speaker = "Innkeeper", text = "Safe travels." },
})
seq:start()

function lurek.update(dt) seq:update(dt) end
-- advance on key press:
if lurek.input.keyPressed("space") then seq:advance() end
```

## Dependencies

- `lurek.patterns.newEventBus` (optional), `lurek.i18n` (optional)
