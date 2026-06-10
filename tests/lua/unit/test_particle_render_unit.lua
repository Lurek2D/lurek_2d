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
    -- @covers LParticleSystem:toImage
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

    -- @covers LParticleSystem:drawExplosionToImage
    it("drawExplosionToImage renders explosion particles", function()
        local ps = lurek.particle.newSystem({ maxParticles = 16 })
        ps:setPosition(32, 32)
        local ok = pcall(function()
            ps:drawExplosionToImage(64, 64)
        end)
        expect_true(ok, "drawExplosionToImage should be callable")
    end)

    -- @covers LParticleSystem:drawRainToImage
    it("drawRainToImage renders rain particles", function()
        local ps = lurek.particle.newSystem({ maxParticles = 16 })
        ps:setPosition(32, 32)
        local ok = pcall(function()
            ps:drawRainToImage(64, 64)
        end)
        expect_true(ok, "drawRainToImage should be callable")
    end)

    -- @covers LParticleSystem:drawSparkTrailToImage
    it("drawSparkTrailToImage renders spark particles", function()
        local ps = lurek.particle.newSystem({ maxParticles = 16 })
        ps:setPosition(32, 32)
        local ok = pcall(function()
            ps:drawSparkTrailToImage(64, 64)
        end)
        expect_true(ok, "drawSparkTrailToImage should be callable")
    end)

    -- @covers LParticleSystem:drawOverImage
    it("drawOverImage draws particles over existing image", function()
        local ps1 = lurek.particle.newSystem({ maxParticles = 16 })
        ps1:setPosition(32, 32)
        local img = ps1:toImage(64, 64)
        local ps2 = lurek.particle.newSystem({ maxParticles = 16 })
        ps2:setPosition(32, 32)
        local ok = pcall(function()
            ps2:drawOverImage(img)
        end)
        expect_true(ok, "drawOverImage should be callable")
    end)

    -- @covers LParticleSystem:paintOnto
    it("paintOnto paints particles onto an image", function()
        local ps1 = lurek.particle.newSystem({ maxParticles = 16 })
        ps1:setPosition(32, 32)
        local img = ps1:toImage(64, 64)
        local ps2 = lurek.particle.newSystem({ maxParticles = 16 })
        ps2:setPosition(32, 32)
        ps2:setColors({ 1, 1, 1, 1 }, { 1, 1, 1, 1 })
        local ok = pcall(function()
            ps2:paintOnto(img)
        end)
        expect_true(ok, "paintOnto should be callable")
    end)
end)
test_summary()
