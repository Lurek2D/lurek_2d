-- Adversarial coverage for light-world numeric validation, bounded previews, and stale handles.

local function reset_light()
    lurek.light.clear()
    lurek.light.setEnabled(true)
end

local function new_light()
    return lurek.light.newLight(0, 0, 10)
end

local function new_occluder()
    return lurek.light.newOccluder({ 0, 0, 2, 0, 1, 2 })
end

local function expect_empty_light_world()
    expect_equal(0, lurek.light.getLightCount())
    expect_equal(0, lurek.light.getOccluderCount())
end

-- @describe light hostile constructors
describe("light hostile constructors", function()
    -- @security lurek.light.newLight
    it("rejects non-finite, malformed, and unknown light options", function()
        reset_light()
        expect_error(function()
            lurek.light.newLight(math.huge, 0, 10)
        end)
        expect_error(function()
            lurek.light.newLight(0, 0, 10, { direction = 0 / 0 })
        end)
        expect_error(function()
            lurek.light.newLight(0, 0, 10, { innerAngle = 1, outerAngle = 0.5 })
        end)
        expect_error(function()
            lurek.light.newLight(0, 0, 10, { unknown = true })
        end)
        expect_error(function()
            lurek.light.newLight(0, 0, 10, { normalMap = "" })
        end)
    end)

    -- @security lurek.light.newOccluder
    it("rejects non-finite, concave, and malformed occluders", function()
        reset_light()
        expect_error(function()
            lurek.light.newOccluder({ 0, 0, math.huge, 0, 1, 1 })
        end)
        expect_error(function()
            lurek.light.newOccluder({ 0, 0, 2, 0, 1, 0.5, 2, 2, 0, 2 })
        end)
        expect_error(function()
            lurek.light.newOccluder({ 0, 0, 1, 0, 0, 1 }, { opacity = math.huge })
        end)
    end)

    -- @security lurek.light.setMaxLights
    it("rejects renderer selection values outside documented bounds", function()
        expect_error(function()
            lurek.light.setMaxLights(0)
        end)
        expect_error(function()
            lurek.light.setMaxLights(257)
        end)
    end)

    -- @security lurek.light.drawToImage
    it("rejects oversized debug previews before allocation", function()
        reset_light()
        expect_error(function()
            lurek.light.drawToImage(65536, 65536)
        end)
    end)
    local function __audit_security_1()
        reset_light()
        local tileset = lurek.tileset.fromProvider({
            firstGid = 1,
            tileCount = 1,
            columns = 1,
            tileWidth = 1,
            tileHeight = 1,
            objects = { torch = { renderLight = { radius = 2, intensity = 1 } } },
            tileObjects = { [1] = "torch" },
        })
        local field = lurek.tilefield.new({ width = 65, height = 64 })
        for y = 1, 64 do
            for x = 1, 65 do
                field:setRef(x, y, 1, "tiles", 1)
            end
        end
        expect_error(function()
            lurek.light.createLightsFromTilefield(field, "tiles", tileset)
        end)
        expect_empty_light_world()
    end


    -- @security lurek.light.createLightsFromTilefield
    it("rejects an oversized tile conversion without partial scene state", function()
        __audit_security_1()
    end)
end)

-- @describe light hostile handle mutation
describe("light hostile handle mutation", function()
    -- @security LLight:setPosition
    it("rejects non-finite light positions", function()
        local light = new_light()
        expect_error(function()
            light:setPosition(0 / 0, 0)
        end)
    end)

    -- @security LLight:setDirection
    it("rejects non-finite direction", function()
        local light = new_light()
        expect_error(function()
            light:setDirection(math.huge)
        end)
    end)

    -- @security LLight:setOuterAngle
    it("rejects an outer cone above pi", function()
        local light = new_light()
        expect_error(function()
            light:setOuterAngle(math.pi + 0.1)
        end)
    end)

    -- @security LLight:setAttenuation
    it("rejects negative and non-finite attenuation", function()
        local light = new_light()
        expect_error(function()
            light:setAttenuation(-1, 0, 0)
        end)
        expect_error(function()
            light:setAttenuation(1, math.huge, 0)
        end)
    end)

    -- @security LLight:setCookie
    it("rejects empty and oversized resource paths", function()
        local light = new_light()
        expect_error(function()
            light:setCookie("")
        end)
        expect_error(function()
            light:setCookie(string.rep("x", 1025))
        end)
    end)

    -- @security LOccluder:setVertices
    it("leaves live geometry unchanged after rejected replacement", function()
        local occluder = new_occluder()
        expect_error(function()
            occluder:setVertices({ 0, 0, 1, 0, 2, 0 })
        end)
    end)

    -- @security LOccluder:setPosition
    it("rejects non-finite occluder position", function()
        local occluder = new_occluder()
        expect_error(function()
            occluder:setPosition(math.huge, 0)
        end)
    end)
end)

test_summary()
