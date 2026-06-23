local VisibilityMinimap = require("library.visibility_minimap")

local field = lurek.tilefield.new({ width = 6, height = 5, levels = 1 })
field:setBlock(4, 3, 1, "vision", true)
field:setBlock(5, 3, 1, "action", true)

local visibility = lurek.visibility.newTileVisibility(field, { players = { "player" } })
visibility:computeVisible("player", {
    origin = { x = 2, y = 3, z = 1 },
    range = 4,
    channel = "vision",
})
visibility:computeAction("player", {
    origin = { x = 2, y = 3, z = 1 },
    range = 3,
    channel = "action",
})

local helper = VisibilityMinimap.new({ visibility = visibility, width = 6, height = 5 })
helper:syncFog("player")
helper:syncActionLayer("player", 1, {
    action_value = 7,
    style = {
        visible = true,
        alpha = 0.65,
        blend = "add",
        colors = {
            [7] = { 0.2, 0.8, 1.0, 0.85 },
        },
    },
})

return helper:getMinimap()
