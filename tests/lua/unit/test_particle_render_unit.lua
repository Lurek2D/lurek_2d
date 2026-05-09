-- tests/lua/integration/test_particle_render.lua
-- Unit: lurek.particle <-> lurek.render
-- Tests that particle systems produce correct render draw calls each frame.

local describe = describe or function(n,f) f() end
local it = it or function(n,f) f() end

local function find_visible_pixel(img, width, height)
    for y = 0, height - 1 do
        for x = 0, width - 1 do
            local r, g, b, a = img:getPixel(x, y)
            if a > 0 then
                return r, g, b, a
            end
        end
    end
    return nil
end

-- @describe particle + render integration
describe("particle + render integration", function()
    -- @covers LImageData:getPixel
    -- @covers LParticleSystem:emit
    -- @covers LParticleSystem:getCount
    -- @covers LParticleSystem:setParticleLifetime
    -- @covers LParticleSystem:setPosition
    -- @covers LParticleSystem:setSizes
    -- @covers LParticleSystem:setSpeed
    -- @covers LParticleSystem:stop
    -- @covers LParticleSystem:toImage
    -- @covers lurek.particle.newSystem
    it("spawned particles produce visible pixels in the rendered image", function()
        local ps = lurek.particle.newSystem({ maxParticles = 8 })

        ps:stop()
        ps:setPosition(32, 32)
        ps:setSpeed(0, 0)
        ps:setSizes(8, 8)
        ps:setParticleLifetime(1.0, 1.0)
        ps:emit(1)

        local img = ps:toImage(64, 64)
        local _, _, _, alpha = find_visible_pixel(img, 64, 64)

        expect_true(ps:getCount() > 0, "particle count should increase after emit")
        expect_true(alpha ~= nil and alpha > 0, "rendered image should contain a visible particle")
    end)

    -- @covers LParticleSystem:emit
    -- @covers LImageData:getPixel
    -- @covers LParticleSystem:render
    -- @covers LParticleSystem:setColors
    -- @covers LParticleSystem:setParticleLifetime
    -- @covers LParticleSystem:setPosition
    -- @covers LParticleSystem:setSizes
    -- @covers LParticleSystem:setSpeed
    -- @covers LParticleSystem:stop
    -- @covers LParticleSystem:toImage
    -- @covers lurek.particle.newSystem
    it("particle render configuration remains usable after color changes", function()
        local ps = lurek.particle.newSystem({ maxParticles = 8 })

        ps:stop()
        ps:setPosition(32, 32)
        ps:setSpeed(0, 0)
        ps:setSizes(8, 8)
        ps:setParticleLifetime(1.0, 1.0)
        ps:setColors({ 1, 0, 0, 1 }, { 1, 0, 0, 1 })
        ps:emit(1)

        local ok_render = pcall(function()
            ps:render()
        end)
        local img = ps:toImage(64, 64)
        local r, g, b, a = img:getPixel(0, 0)

        expect_true(ok_render, "particle system should stay renderable after color configuration")
        expect_type("number", r)
        expect_type("number", g)
        expect_type("number", b)
        expect_type("number", a)
    end)

    -- @covers LParticleSystem:emit
    -- @covers LParticleSystem:getCount
    -- @covers LParticleSystem:render
    -- @covers LParticleSystem:setParticleLifetime
    -- @covers LParticleSystem:setPosition
    -- @covers LParticleSystem:setSizes
    -- @covers LParticleSystem:setSpeed
    -- @covers LParticleSystem:stop
    -- @covers LParticleSystem:toImage
    -- @covers LParticleSystem:update
    -- @covers lurek.particle.newSystem
    it("expired particles are removed from the live renderable set", function()
        local ps = lurek.particle.newSystem({ maxParticles = 8 })

        ps:stop()
        ps:setPosition(32, 32)
        ps:setSpeed(0, 0)
        ps:setSizes(8, 8)
        ps:setParticleLifetime(0.01, 0.01)
        ps:emit(1)
        ps:update(0.1)

        local ok_render = pcall(function()
            ps:render()
        end)
        local ok_image = pcall(function()
            ps:toImage(64, 64)
        end)

        expect_equal(0, ps:getCount())
        expect_true(ok_render, "expired systems should still render without error")
        expect_true(ok_image, "expired systems should still support CPU image rendering")
    end)
end)
test_summary()

