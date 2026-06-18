-- content/examples/tools/event_signal_vs_eventbus.lua
-- Run by copying this file into a game folder as main.lua.

--- Signal versus EventBus: local callback set versus named broker

local function example_print_log(...)
    local parts = {}
    for i = 1, select("#", ...) do
        parts[i] = tostring(select(i, ...))
    end
    lurek.log.info(table.concat(parts, " "))
end

local player = {
    hp = 10,
    ui_dirty = false,
    log = {},
}

-- Use LSignal when one owner needs a small, isolated callback set.
local health_signal = lurek.event.newSignal()
health_signal:connect("changed", function(hp, reason)
    player.ui_dirty = true
    player.hp = hp
    example_print_log("signal health changed to " .. hp .. " after " .. reason)
end)
health_signal:emit("changed", 8, "trap")

-- Use LEventBus when multiple systems listen to named events through one broker.
local bus = lurek.patterns.newEventBus("gameplay")
bus:on("inventory.item_used", function(item_name)
    player.log[#player.log + 1] = "used " .. item_name
    example_print_log("analytics saw item use: " .. item_name)
end, 10)
bus:on("inventory.item_used", function(item_name)
    example_print_log("quest system checked: " .. item_name)
end)
bus:emit("inventory.item_used", "small_potion")

example_print_log("ui dirty = " .. tostring(player.ui_dirty))
example_print_log("log entries = " .. #player.log)
