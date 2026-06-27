-- content/examples/light.lua
-- Auto-generated from content/examples2/light_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/light.lua
-- lurek.light is the 2D render-light and occluder module. Tile-based gameplay
-- lighting, sun occlusion, and light blockers live in lurek.tilefield.

--- Light Module Part 1: module functions and LLight class


--@api: lurek.light.newLight
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(400, 300, 200)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    example_print_log("radius = " .. light:getRadius())
end

--@api: lurek.light.setEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    lurek.light.newLight(64, 64, 96)
    lurek.light.setEnabled(true)
    local count = lurek.light.getLightCount()
    local max_lights = lurek.light.getMaxLights()
    example_print_log("light world enabled = " .. tostring(lurek.light.isEnabled()))
end

--@api: lurek.light.setAmbient
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.setAmbient(0.1, 0.1, 0.15, 1)
    local r, g, b, a = lurek.light.getAmbient()
    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    example_print_log("ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: lurek.light.getLightCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    lurek.light.newLight(0, 0, 100)
    lurek.light.newLight(50, 50, 80)
    local enabled = lurek.light.isEnabled()
    example_print_log("lights = " .. lurek.light.getLightCount())
end

--@api: lurek.light.getMaxLights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.setMaxLights(128)
    lurek.light.clear()
    lurek.light.newLight(32, 32, 64)
    local count = lurek.light.getLightCount()
    example_print_log("max lights = " .. lurek.light.getMaxLights())
end

--@api: lurek.light.clear
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.newLight(0, 0, 50)
    lurek.light.newLight(40, 20, 70)
    local before = lurek.light.getLightCount()
    lurek.light.clear()
    example_print_log("after clear: lights = " .. lurek.light.getLightCount())
end

--@api: lurek.light.advanceFlickers
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(200, 200, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:addFlicker(0.5, 1.0, 4.0)
    light:setFlickerEnabled(true)
    lurek.light.advanceFlickers(0.016)
    example_print_log("flickers advanced")
end

--@api: lurek.light.getGroupCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local a = lurek.light.newLight(0, 0, 50)
    local b = lurek.light.newLight(10, 10, 50)
    a:setGroupId(1)
    b:setGroupId(1)
    example_print_log("group 1 count = " .. lurek.light.getGroupCount(1))
end

--@api: lurek.light.setGroupColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    local first = lurek.light.newLight(10, 10, 60)
    local second = lurek.light.newLight(30, 20, 60)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupColor(1, 1, 0, 0, 1)
    local r, g, b, a = first:getColor()
    example_print_log("group 1 count = " .. lurek.light.getGroupCount(1))
    example_print_log("group 1 color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: lurek.light.setGroupIntensity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupIntensity(1, 3.0)
    example_print_log("group 1 count = " .. lurek.light.getGroupCount(1))
    example_print_log("group 1 intensity = " .. first:getIntensity())
end

--@api: lurek.light.setGroupEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    local first = lurek.light.newLight(20, 20, 70)
    local second = lurek.light.newLight(40, 40, 70)
    first:setGroupId(1)
    second:setGroupId(1)
    lurek.light.setGroupEnabled(1, false)
    example_print_log("group 1 count = " .. lurek.light.getGroupCount(1))
    example_print_log("group 1 enabled = " .. tostring(first:isEnabled()))
end

--@api: lurek.light.getGodRayHints
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    local light = lurek.light.newLight(120, 90, 160)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("directional")
    light:setDirection(0.75)
    local hints = lurek.light.getGodRayHints()
    example_print_log("god ray hints = " .. #hints)
    example_print_log("first hint angle = " .. hints[1].angle)
end

--@api: lurek.light.getNormalMapHints
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    local light = lurek.light.newLight(80, 60, 120)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("assets/textures/sample_normal.png")
    light:setNormalStrength(0.8)
    local hints = lurek.light.getNormalMapHints()
    example_print_log("normal map hints = " .. #hints)
    example_print_log("first hint strength = " .. hints[1].strength)
end

--@api: lurek.light.syncAmbient
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.setAmbient(0.2, 0.25, 0.3, 1.0)
    local r, g, b, a = lurek.light.syncAmbient()
    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    example_print_log("sync ambient = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LLight:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    example_print_log("pos = " .. x .. "," .. y)
end

--@api: LLight:getPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setPosition(200, 150)
    local x, y = light:getPosition()
    example_print_log("pos = " .. x .. "," .. y)
end

--@api: LLight:setRadius
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setRadius(250)
    example_print_log("radius = " .. light:getRadius())
end

--@api: LLight:getRadius
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setRadius(250)
    example_print_log("radius = " .. light:getRadius())
end

--@api: LLight:setColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    example_print_log("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LLight:getColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setColor(1, 0.5, 0, 0.9)
    local r, g, b, a = light:getColor()
    example_print_log("color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LLight:setIntensity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setIntensity(5)
    example_print_log("intensity = " .. light:getIntensity())
end

--@api: LLight:getIntensity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setIntensity(5)
    example_print_log("intensity = " .. light:getIntensity())
end

--@api: LLight:setEnergy
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnergy(2.5)
    example_print_log("energy = " .. light:getEnergy())
end

--@api: LLight:getEnergy
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnergy(2.5)
    example_print_log("energy = " .. light:getEnergy())
end

--@api: LLight:setLightType
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    example_print_log("type = " .. light:getLightType())
end

--@api: LLight:getLightType
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    example_print_log("type = " .. light:getLightType())
end

--@api: LLight:setDirection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("directional")
    light:setDirection(1.57)
    example_print_log("direction = " .. light:getDirection())
end

--@api: LLight:getDirection
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("directional")
    light:setDirection(1.57)
    example_print_log("direction = " .. light:getDirection())
end

--@api: LLight:setFalloff
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFalloff("smooth")
    example_print_log("falloff = " .. light:getFalloff())
end

--@api: LLight:getFalloff
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFalloff("smooth")
    example_print_log("falloff = " .. light:getFalloff())
end

--@api: LLight:setBlendMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setBlendMode("add")
    example_print_log("blend = " .. light:getBlendMode())
end

--@api: LLight:getBlendMode
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setBlendMode("add")
    example_print_log("blend = " .. light:getBlendMode())
end

--@api: LLight:setAttenuation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    example_print_log("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api: LLight:getAttenuation
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setAttenuation(1, 0.1, 0.01)
    local c, l, q = light:getAttenuation()
    example_print_log("attenuation c=" .. c .. " l=" .. l .. " q=" .. q)
end

--@api: LLight:setInnerAngle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    example_print_log("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api: LLight:getInnerAngle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    example_print_log("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api: LLight:setOuterAngle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    example_print_log("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api: LLight:getOuterAngle
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightType("spot")
    light:setInnerAngle(0.3)
    light:setOuterAngle(0.8)
    example_print_log("inner = " .. light:getInnerAngle() .. " outer = " .. light:getOuterAngle())
end

--@api: LLight:setEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnabled(false)
    example_print_log("enabled = " .. tostring(light:isEnabled()))
end

--@api: LLight:isEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setEnabled(false)
    example_print_log("enabled = " .. tostring(light:isEnabled()))
end

--@api: LLight:setGroupId
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setGroupId(5)
    example_print_log("group = " .. light:getGroupId())
end

--@api: LLight:getGroupId
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setGroupId(5)
    example_print_log("group = " .. light:getGroupId())
end

--@api: LLight:setLightMask
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightMask(3)
    example_print_log("mask = " .. light:getLightMask())
end

--@api: LLight:getLightMask
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setLightMask(3)
    example_print_log("mask = " .. light:getLightMask())
end

--@api: LLight:isValid
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    example_print_log("valid = " .. tostring(light:isValid()))
    light:remove()
    example_print_log("valid after remove = " .. tostring(light:isValid()))
end

--@api: LLight:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    example_print_log("type = " .. light:type())
    example_print_log("is LLight = " .. tostring(light:typeOf("LLight")))
end

--@api: LLight:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    example_print_log("type = " .. light:type())
    example_print_log("is LLight = " .. tostring(light:typeOf("LLight")))
    example_print_log("is Object = " .. tostring(light:typeOf("LObject")))
end

--- Light Module Part 2: shadows, flicker, transitions, cookies, normals, LOccluder

--@api: LLight:setShadowEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(200, 200, 150)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    example_print_log("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api: LLight:isShadowEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(200, 200, 150)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    example_print_log("shadows = " .. tostring(light:isShadowEnabled()))
end

--@api: LLight:setShadowColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    example_print_log("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LLight:getShadowColor
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowColor(0, 0, 0.1, 0.8)
    local r, g, b, a = light:getShadowColor()
    example_print_log("shadow color = " .. r .. "," .. g .. "," .. b .. "," .. a)
end

--@api: LLight:setShadowFilter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    example_print_log("shadow filter = " .. light:getShadowFilter())
end

--@api: LLight:getShadowFilter
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowFilter("pcf5")
    example_print_log("shadow filter = " .. light:getShadowFilter())
end

--@api: LLight:setShadowSmooth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    example_print_log("shadow smooth = " .. light:getShadowSmooth())
end

--@api: LLight:getShadowSmooth
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSmooth(2.0)
    example_print_log("shadow smooth = " .. light:getShadowSmooth())
end

--@api: LLight:setShadowSoftness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    example_print_log("shadow softness = " .. light:getShadowSoftness())
end

--@api: LLight:getShadowSoftness
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowEnabled(true)
    light:setShadowSoftness(1.5)
    example_print_log("shadow softness = " .. light:getShadowSoftness())
end

--@api: LLight:setShadowMask
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowMask(7)
    example_print_log("shadow mask = " .. light:getShadowMask())
end

--@api: LLight:getShadowMask
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setShadowMask(7)
    example_print_log("shadow mask = " .. light:getShadowMask())
end

--@api: LLight:addFlicker
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(100, 100, 80)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:addFlicker(0.5, 1.0, 8.0)
    local speed, strength = light:getFlicker()
    example_print_log("flicker speed = " .. speed)
    example_print_log("flicker strength = " .. strength)
end

--@api: LLight:setFlicker
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    example_print_log("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api: LLight:getFlicker
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(3.0, 0.4)
    local speed, strength = light:getFlicker()
    example_print_log("flicker speed=" .. speed .. " strength=" .. strength)
end

--@api: LLight:setFlickerEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    example_print_log("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api: LLight:isFlickerEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setFlicker(2.0, 0.3)
    light:setFlickerEnabled(true)
    example_print_log("flicker on = " .. tostring(light:isFlickerEnabled()))
end

--@api: LLight:setCookie
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setCookie("content/examples/assets/images/sample_texture.png")
    example_print_log("cookie = " .. light:getCookie())
end

--@api: LLight:getCookie
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setCookie("content/examples/assets/images/sample_texture.png")
    example_print_log("cookie = " .. light:getCookie())
end

--@api: LLight:clearCookie
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setCookie("content/examples/assets/images/sample_texture.png")
    light:clearCookie()
    example_print_log("cookie = " .. tostring(light:getCookie()))
end

--@api: LLight:setNormalMap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    example_print_log("normal map = " .. light:getNormalMap())
end

--@api: LLight:getNormalMap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    example_print_log("normal map = " .. light:getNormalMap())
end

--@api: LLight:clearNormalMap
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalMap("content/examples/assets/images/sample_normal.dds")
    light:clearNormalMap()
    example_print_log("normal map = " .. tostring(light:getNormalMap()))
end

--@api: LLight:setNormalStrength
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalStrength(1.5)
    example_print_log("normal strength = " .. light:getNormalStrength())
end

--@api: LLight:getNormalStrength
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setNormalStrength(1.5)
    example_print_log("normal strength = " .. light:getNormalStrength())
end

--@api: LLight:setVolumetric
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 200)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setVolumetric(true)
    example_print_log("volumetric = " .. tostring(light:isVolumetric()))
end

--@api: LLight:isVolumetric
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 200)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setVolumetric(true)
    example_print_log("volumetric = " .. tostring(light:isVolumetric()))
end

--@api: LLight:transitionTo
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:setColor(1, 0, 0, 1)
    light:setIntensity(1.0)
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    example_print_log("progress = " .. light:transitionProgress())
end

--@api: LLight:updateTransition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    local applied = light:updateTransition(0.5)
    example_print_log("applied = " .. tostring(applied))
end

--@api: LLight:transitionProgress
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:updateTransition(0.5)
    example_print_log("progress = " .. light:transitionProgress())
end

--@api: LLight:stopTransition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local light = lurek.light.newLight(0, 0, 100)
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.25)
    local light_count = lurek.light.getLightCount()
    light:transitionTo({color = {0, 0, 1, 1}, intensity = 3.0, radius = 200}, 2.0)
    light:stopTransition()
    example_print_log("stopped, progress = " .. light:transitionProgress())
end

--@api: lurek.light.newOccluder
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local verts = {0, 0, 100, 0, 100, 50, 0, 50}
    local occ = lurek.light.newOccluder(verts)
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    example_print_log("occluder valid = " .. tostring(occ:isValid()))
end

--@api: LOccluder:setPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    example_print_log("occ pos = " .. x .. "," .. y)
end

--@api: LOccluder:getPosition
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setPosition(50, 75)
    local x, y = occ:getPosition()
    example_print_log("occ pos = " .. x .. "," .. y)
end

--@api: LOccluder:setVertices
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    example_print_log("vertex count = " .. #v / 2)
end

--@api: LOccluder:getVertices
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 20, 0, 20, 20, 0, 20})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setVertices({0, 0, 30, 0, 30, 30, 0, 30})
    local v = occ:getVertices()
    example_print_log("vertex count = " .. #v / 2)
end

--@api: LOccluder:setOpacity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setOpacity(0.6)
    example_print_log("opacity = " .. occ:getOpacity())
end

--@api: LOccluder:getOpacity
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setOpacity(0.6)
    example_print_log("opacity = " .. occ:getOpacity())
end

--@api: LOccluder:setEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setEnabled(false)
    example_print_log("enabled = " .. tostring(occ:isEnabled()))
end

--@api: LOccluder:isEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setEnabled(false)
    example_print_log("enabled = " .. tostring(occ:isEnabled()))
end

--@api: LOccluder:setLightMask
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setLightMask(5)
    example_print_log("occ mask = " .. occ:getLightMask())
end

--@api: LOccluder:getLightMask
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    occ:setLightMask(5)
    example_print_log("occ mask = " .. occ:getLightMask())
end

--@api: LOccluder:isValid
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    example_print_log("valid = " .. tostring(occ:isValid()))
    occ:remove()
    example_print_log("valid after remove = " .. tostring(occ:isValid()))
end

--@api: LOccluder:type
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    example_print_log("type = " .. occ:type())
    example_print_log("is LOccluder = " .. tostring(occ:typeOf("LOccluder")))
end

--@api: LOccluder:typeOf
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local occ = lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    example_print_log("type = " .. occ:type())
    example_print_log("is LOccluder = " .. tostring(occ:typeOf("LOccluder")))
    example_print_log("is Object = " .. tostring(occ:typeOf("LObject")))
end

--@api: lurek.light.getOccluderCount
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    lurek.light.newOccluder({0, 0, 10, 0, 10, 10, 0, 10})
    lurek.light.newOccluder({20, 20, 30, 20, 30, 30, 20, 30})
    local enabled = lurek.light.isEnabled()
    example_print_log("occluders = " .. lurek.light.getOccluderCount())
end

--- Light Module: LLight:remove, LOccluder:remove, lurek.light functions

--@api: LLight:remove
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local lt = lurek.light.newLight(200, 300, 150)
    lt:setColor(1.0, 0.85, 0.55, 1.0)
    lt:setIntensity(1.5)
    example_print_log("lights = " .. lurek.light.getLightCount())
    lt:remove()
    example_print_log("after remove = " .. lurek.light.getLightCount())
end

--@api: LOccluder:remove
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local vtbl = { 0, 0, 100, 0, 100, 100, 0, 100 }
    local occ = lurek.light.newOccluder(vtbl)
    occ:setPosition(8, 12)
    occ:setOpacity(0.9)
    local occluder_count = lurek.light.getOccluderCount()
    example_print_log("occluders = " .. lurek.light.getOccluderCount())
    occ:remove()
    example_print_log("after remove = " .. lurek.light.getOccluderCount())
end

--@api: lurek.light.getAmbient
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local r, g, b, a = lurek.light.getAmbient()
    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    local max_lights = lurek.light.getMaxLights()
    example_print_log("ambient", r, g, b, a)
end

--@api: lurek.light.isEnabled
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    local enabled = lurek.light.isEnabled()
    local count = lurek.light.getLightCount()
    local max_lights = lurek.light.getMaxLights()
    local r, g, b, a = lurek.light.getAmbient()
    example_print_log("enabled = " .. tostring(enabled))
end

--@api: lurek.light.setMaxLights
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.setMaxLights(64)
    lurek.light.clear()
    lurek.light.newLight(48, 48, 96)
    local count = lurek.light.getLightCount()
    example_print_log("max lights = " .. lurek.light.getMaxLights())
end

--@api: lurek.light.drawToImage
do
    local function example_print_log(...)
        local parts = {}
        for i = 1, select("#", ...) do
            parts[i] = tostring(select(i, ...))
        end
        lurek.log.info(table.concat(parts, " "))
    end

    lurek.light.clear()
    lurek.light.setAmbient(0.04, 0.04, 0.06, 1.0)
    local light = lurek.light.newLight(200, 72, 180, { shadowEnabled = true, shadowFilter = "pcf5" })
    light:setColor(1.0, 0.9, 0.7, 1.0)
    light:setIntensity(1.6)
    local occ = lurek.light.newOccluder({160, 128, 240, 128, 240, 144, 160, 144})
    local light_count = lurek.light.getLightCount()
    local occ_count = lurek.light.getOccluderCount()
    local img = lurek.light.drawToImage(400, 300)
    example_print_log("lurek.light.drawToImage type=" .. type(img))
    example_print_log("lurek.light.drawToImage size=" .. img:getWidth() .. "x" .. img:getHeight())
    example_print_log("preview lights=" .. light_count .. " occluders=" .. occ_count .. " valid=" .. tostring(occ:isValid()))
end

--@api: lurek.light.setShader
do
    local shader = lurek.shader.new([[
@fragment
fn fs(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0, color.a);
}
]], { target = "light" })
    lurek.light.setShader(shader)
    lurek.log.info("[light] world shader=" .. tostring(lurek.light.getShader() ~= nil))
end

--@api: lurek.light.getShader
do
    local shader = lurek.shader.new("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "light" })
    lurek.light.setShader(shader)
    local active = lurek.light.getShader()
    local target = active and active:getTarget() or "nil"
    lurek.light.setShader(nil)
    lurek.log.info("[light] world shader target=" .. target)
end

--@api: LLight:setShader
do
    local light = lurek.light.newLight(400, 300, 180)
    local shader = lurek.shader.new([[
@fragment
fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "light" })
    light:setShader(shader)
    lurek.log.info("[light] light shader=" .. tostring(light:getShader() ~= nil))
end

--@api: LLight:getShader
do
    local light = lurek.light.newLight(400, 300, 180)
    local shader = lurek.shader.new("@fragment fn fs(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> { return color; }", { target = "light" })
    light:setShader(shader)
    local active = light:getShader()
    local target = active and active:getTarget() or "nil"
    light:setShader(nil)
    lurek.log.info("[light] light shader target=" .. target)
end
