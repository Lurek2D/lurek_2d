--- Example usage for library.tilefield_minimap.

local TilefieldMinimap = require("library.tilefield_minimap")

local field = lurek.tilefield.new({ width = 4, height = 3, levels = 1 })
field:setBlock(2, 1, 1, "move", true)
field:setCost(3, 2, 1, "move", 4)
field:addPointLight({ x = 2, y = 2, z = 1, radius = 2, intensity = 1.0 })
field:computeLight({ includePointLights = true, includeGlobalLight = false })

local helper = TilefieldMinimap.new({
    field = field,
    width = 4,
    height = 3,
})

helper:syncBlockLayer("move", 1, {
    blocked_value = 9,
    style = {
        visible = true,
        alpha = 0.8,
        blend = "replace",
        colors = {
            [9] = { 0.9, 0.15, 0.1, 1.0 },
        },
    },
})

helper:syncCostLayer("move", 2, {
    scale = 2,
    style = {
        visible = true,
        alpha = 0.45,
        blend = "add",
    },
})

helper:syncLightLayer(3, {
    style = {
        visible = true,
        alpha = 0.7,
        blend = "add",
    },
})

print("[tilefield_minimap] layers synced")
