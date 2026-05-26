# narrative

An Ink-flavored branching narrative engine. Compiles a subset of Ink syntax (knots, diverts, choices, variables, conditionals) to a runtime story object, then drives `continue()`/`choose()` playback. Supports save/restore of story position and variable state.

## Usage

```lua
local narrative = require("library/narrative")

local story = narrative.Story.new()
story:loadFile("assets/story/chapter1.ink")
story:start()

while story:canContinue() do
    local line = story:continue()
    print(line.text)
end

if story:hasChoices() then
    for i, c in ipairs(story:choices()) do
        print(i, c.text)
    end
    story:choose(1)
end
```

## Dependencies

- `lurek.filesystem.read` (optional), `lurek.save` (optional)
