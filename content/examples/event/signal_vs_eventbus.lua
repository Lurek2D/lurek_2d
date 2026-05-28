-- content/examples/event/signal_vs_eventbus.lua
-- Run by copying this file into a game folder as main.lua.

--- Signal versus EventBus: local callback set versus named broker

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
    print("signal health changed to " .. hp .. " after " .. reason)
end)
health_signal:emit("changed", 8, "trap")

-- Use LEventBus when multiple systems listen to named events through one broker.
local bus = lurek.patterns.newEventBus("gameplay")
bus:on("inventory.item_used", function(item_name)
    player.log[#player.log + 1] = "used " .. item_name
    print("analytics saw item use: " .. item_name)
end, 10)
bus:on("inventory.item_used", function(item_name)
    print("quest system checked: " .. item_name)
end)
bus:emit("inventory.item_used", "small_potion")

print("ui dirty = " .. tostring(player.ui_dirty))
print("log entries = " .. #player.log)
