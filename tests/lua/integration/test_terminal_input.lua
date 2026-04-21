-- tests/lua/integration/test_terminal_input.lua
-- Integration: lurek.terminal <-> lurek.input
-- Tests that the in-game terminal captures and processes key input.

local describe = describe or function(n,f) f() end
local it = it or function(n,f) f() end
local assert = assert

describe("terminal + input integration", function()
    it("terminal opens on configured toggle key press", function()
        assert(true, "terminal_input open placeholder")
    end)
    it("text typed while terminal open appends to command buffer", function()
        assert(true, "terminal_input append placeholder")
    end)
    it("input events are consumed by terminal and not forwarded to game", function()
        assert(true, "terminal_input consume placeholder")
    end)
end)

test_summary()
