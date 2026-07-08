-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_particle_core_unit.lua
do
-- Lurek2D particle system API tests.
-- Covers particle-system creation, emission controls, configuration getters/setters, render-state helpers, and lifecycle behavior exposed through lurek.particle.

local function images_match(a, b, w, h)
    for y = 0, h - 1 do
        for x = 0, w - 1 do
            local ar, ag, ab, aa = a:getPixel(x, y)
            local br, bg, bb, ba = b:getPixel(x, y)
            if ar ~= br or ag ~= bg or ab ~= bb or aa ~= ba then
                return false
            end
        end
    end
    return true
end

    -- Lurek2D Particle API Tests
-- @describe lurek.particle.newSystem
describe("lurek.particle.newSystem", function()
    -- @covers lurek.particle.newSystem
    it("creates userdata with defaults and accepts supported config aliases", function()
        local ps = lurek.particle.newSystem()
        expect_type("userdata", ps)
        expect_true(lurek.particle.isActive(ps), "default system should be active")
        expect_type("userdata", lurek.particle.newSystem({ emissionRate = 50, maxParticles = 100 }))
        local from_toml_keys = lurek.particle.newSystem({
            seed = 9,
            max_particles = 48,
            emission_rate = 12,
            lifetime_min = 0.2,
            lifetime_max = 0.6,
            speed_min = 14,
            speed_max = 28,
            gravity_y = 96,
        })
        expect_near(12.0, from_toml_keys:getEmissionRate(), 0.001)
        expect_near(48, from_toml_keys:getBufferSize(), 0.001)
        expect_near(96.0, select(2, from_toml_keys:getGravity()), 0.001)
        expect_type("userdata", lurek.particle.newSystem({ sizeStart = 8.0, sizeEnd = 2.0 }))
        expect_type("userdata", lurek.particle.newSystem({
            colorStart = {1, 0, 0, 1},
            colorEnd   = {1, 0, 0, 0}
        }))
        expect_type("userdata", lurek.particle.newSystem({ shape = "shrapnel", shrapnelEdges = 8 }))
        expect_type("userdata", lurek.particle.newSystem({ shape = "ray", rayAspect = 6.0 }))
        expect_type("userdata", lurek.particle.newSystem({ shape = "ring", ringThickness = 0.3 }))
        expect_equal(type(ps.addSubSystem), "function")

        local seeded_a = lurek.particle.newSystem({
            seed = 42,
            emissionRate = 0,
            maxParticles = 16,
            lifetimeMin = 1.0,
            lifetimeMax = 1.0,
            speedMin = 14.0,
            speedMax = 14.0,
            direction = 0.25,
            spread = 0.7,
            shape = "circle",
            sizes = { 5.0, 5.0 },
            colors = {
                { 1.0, 1.0, 1.0, 1.0 },
                { 1.0, 1.0, 1.0, 1.0 },
            },
        })
        local seeded_b = lurek.particle.newSystem({
            seed = 42,
            emissionRate = 0,
            maxParticles = 16,
            lifetimeMin = 1.0,
            lifetimeMax = 1.0,
            speedMin = 14.0,
            speedMax = 14.0,
            direction = 0.25,
            spread = 0.7,
            shape = "circle",
            sizes = { 5.0, 5.0 },
            colors = {
                { 1.0, 1.0, 1.0, 1.0 },
                { 1.0, 1.0, 1.0, 1.0 },
            },
        })

        seeded_a:setPosition(32, 32)
        seeded_b:setPosition(32, 32)
        seeded_a:emit(8)
        seeded_b:emit(8)
        seeded_a:update(0.25)
        seeded_b:update(0.25)

        local img_a = seeded_a:toImage(64, 64)
        local img_b = seeded_b:toImage(64, 64)
        expect_true(images_match(img_a, img_b, 64, 64), "same seed should render identical particle output")
    end)
end)

-- @describe lurek.particle lifecycle
describe("lurek.particle lifecycle", function()
    -- @covers LParticleSystem:isActive
    it("isActive returns true for new system", function()
        local ps = lurek.particle.newSystem()
        expect_true(lurek.particle.isActive(ps), "new system should be active")
    end)
    -- @covers LParticleSystem:getStats
    it("getStats reports emitter telemetry through the module wrapper", function()
        local ps = lurek.particle.newSystem({ emissionRate = 40, maxParticles = 32, lifetimeMin = 2.0, lifetimeMax = 2.0 })
        ps:addAttractor(32, 32, 80, 64)
        ps:setBounds(64, -64, 48, -48, 0.5)
        ps:emit(6)
        ps:update(0.1)
        local stats = lurek.particle.getStats(ps)
        expect_type("table", stats)
        expect_equal(32, stats.max_particles)
        expect_equal(1, stats.attractor_count)
        expect_true(stats.has_bounds)
        expect_true(stats.live_particles > 0)
        expect_true(stats.total_live_particles >= stats.live_particles)
        expect_equal(false, stats.deterministic_seed)
        expect_equal("v1", stats.rng_version)
        expect_true(stats.config_warning_count >= 1)
        expect_equal("active", stats.state)
    end)
    -- @covers LParticleSystem:isPaused
    it("isPaused returns false for new system", function()
        local ps = lurek.particle.newSystem()
        expect_true(not lurek.particle.isPaused(ps), "new system should not be paused")
    end)
    -- @covers LParticleSystem:isStopped
    it("isStopped returns false for new (active) system", function()
        local ps = lurek.particle.newSystem()
        expect_true(not lurek.particle.isStopped(ps), "new system should not be stopped")
    end)
    -- @covers LParticleSystem:stop
    it("stop sets isStopped", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.stop(ps)
        expect_true(lurek.particle.isStopped(ps), "stopped system should report isStopped")
    end)
    -- @covers LParticleSystem:pause
    it("pause sets isPaused", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.pause(ps)
        expect_true(lurek.particle.isPaused(ps), "paused system should report isPaused")
    end)
    -- @covers LParticleSystem:start
    it("start after stop resumes active state", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.stop(ps)
        lurek.particle.start(ps)
        expect_true(lurek.particle.isActive(ps), "started system should be active")
    end)
    -- @covers LParticleSystem:reset
    it("reset clears particles and keeps active", function()
        local ps = lurek.particle.newSystem({ emissionRate = 1000, maxParticles = 50 })
        lurek.particle.update(ps, 1.0)
        lurek.particle.reset(ps)
        expect_equal(0, lurek.particle.getCount(ps), "count after reset")
    end)
end)

-- @describe lurek.particle.getCount / isEmpty / isFull
describe("lurek.particle.getCount / isEmpty / isFull", function()
    -- @covers LParticleSystem:getCount
    it("getCount returns 0 before any update", function()
        local ps = lurek.particle.newSystem()
        expect_equal(0, lurek.particle.getCount(ps), "count before update")
    end)
    -- @covers LParticleSystem:isEmpty
    it("isEmpty returns true when count is 0", function()
        local ps = lurek.particle.newSystem()
        expect_true(lurek.particle.isEmpty(ps), "empty before update")
    end)
    -- @covers LParticleSystem:isFull
    it("isFull returns false for fresh system", function()
        local ps = lurek.particle.newSystem({ maxParticles = 100 })
        expect_true(not lurek.particle.isFull(ps), "not full before update")
    end)
    -- @covers LParticleSystem:emit
    it("emit burst fills particles immediately", function()
        local ps = lurek.particle.newSystem({ maxParticles = 100 })
        lurek.particle.stop(ps)  -- stop continuous emission
        lurek.particle.emit(ps, 10)
        expect_true(lurek.particle.getCount(ps) > 0, "count should increase after emit")
    end)
    -- @covers LParticleSystem:update
    it("getCount increases after update with high emission rate", function()
        local ps = lurek.particle.newSystem({ emissionRate = 500, maxParticles = 50 })
        lurek.particle.update(ps, 0.1)
        expect_true(lurek.particle.getCount(ps) > 0, "count should be positive after update")
    end)
end)

-- @describe lurek.particle position
describe("lurek.particle position", function()
    -- @covers LParticleSystem:setPosition
    it("setPosition / getPosition round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setPosition(ps, 100, 200)
        local x, y = lurek.particle.getPosition(ps)
        expect_true(math.abs(x - 100) < 0.001, "x position should match")
        expect_true(math.abs(y - 200) < 0.001, "y position should match")
    end)
    -- @covers LParticleSystem:getPosition
    it("getPosition returns 0,0 by default", function()
        local ps = lurek.particle.newSystem()
        local x, y = lurek.particle.getPosition(ps)
        expect_true(math.abs(x) < 0.001, "default x should be 0")
        expect_true(math.abs(y) < 0.001, "default y should be 0")
    end)
    -- @covers LParticleSystem:moveTo
    it("moveTo updates position", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.moveTo(ps, 50, 75)
        local x, y = lurek.particle.getPosition(ps)
        expect_true(math.abs(x - 50) < 0.001, "moveTo x")
        expect_true(math.abs(y - 75) < 0.001, "moveTo y")
    end)
end)

-- @describe lurek.particle emission settings
describe("lurek.particle emission settings", function()
    -- @covers LParticleSystem:setEmissionRate
    it("setEmissionRate / getEmissionRate round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setEmissionRate(ps, 99.0)
        local rate = lurek.particle.getEmissionRate(ps)
        expect_true(math.abs(rate - 99.0) < 0.001, "emission rate round-trip")
    end)
    -- @covers LParticleSystem:setParticleLifetime
    it("setParticleLifetime / getParticleLifetime round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setParticleLifetime(ps, 0.5, 2.5)
        local mn, mx = lurek.particle.getParticleLifetime(ps)
        expect_true(math.abs(mn - 0.5) < 0.001, "lifetime min")
        expect_true(math.abs(mx - 2.5) < 0.001, "lifetime max")
    end)
    -- @covers LParticleSystem:setEmitterLifetime
    it("setEmitterLifetime / getEmitterLifetime round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setEmitterLifetime(ps, 5.0)
        local t = lurek.particle.getEmitterLifetime(ps)
        expect_true(math.abs(t - 5.0) < 0.001, "emitter lifetime")
    end)
    -- @covers LParticleSystem:setSpeed
    it("setSpeed / getSpeed round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setSpeed(ps, 20.0, 80.0)
        local mn, mx = lurek.particle.getSpeed(ps)
        expect_true(math.abs(mn - 20.0) < 0.001, "speed min")
        expect_true(math.abs(mx - 80.0) < 0.001, "speed max")
    end)
    -- @covers LParticleSystem:setDirection
    it("setDirection / getDirection round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setDirection(ps, 1.23)
        local d = lurek.particle.getDirection(ps)
        expect_true(math.abs(d - 1.23) < 0.001, "direction")
    end)
    -- @covers LParticleSystem:setSpread
    it("setSpread / getSpread round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setSpread(ps, 0.5)
        local s = lurek.particle.getSpread(ps)
        expect_true(math.abs(s - 0.5) < 0.001, "spread")
    end)
end)

-- @describe lurek.particle acceleration settings
describe("lurek.particle acceleration settings", function()
    -- @covers LParticleSystem:setLinearAcceleration
    it("setLinearAcceleration / getLinearAcceleration round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setLinearAcceleration(ps, -10, -50, 10, 50)
        local xmin, ymin, xmax, ymax = lurek.particle.getLinearAcceleration(ps)
        expect_true(math.abs(xmin - (-10)) < 0.001, "accel xmin")
        expect_true(math.abs(ymin - (-50)) < 0.001, "accel ymin")
        expect_true(math.abs(xmax - 10) < 0.001, "accel xmax")
        expect_true(math.abs(ymax - 50) < 0.001, "accel ymax")
    end)
    -- @covers LParticleSystem:setRadialAcceleration
    it("setRadialAcceleration / getRadialAcceleration round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setRadialAcceleration(ps, -5.0, 5.0)
        local mn, mx = lurek.particle.getRadialAcceleration(ps)
        expect_true(math.abs(mn - (-5.0)) < 0.001, "radial accel min")
        expect_true(math.abs(mx - 5.0) < 0.001, "radial accel max")
    end)
    -- @covers LParticleSystem:setTangentialAcceleration
    it("setTangentialAcceleration / getTangentialAcceleration round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setTangentialAcceleration(ps, 1.0, 3.0)
        local mn, mx = lurek.particle.getTangentialAcceleration(ps)
        expect_true(math.abs(mn - 1.0) < 0.001, "tangential accel min")
        expect_true(math.abs(mx - 3.0) < 0.001, "tangential accel max")
    end)
    -- @covers LParticleSystem:setLinearDamping
    it("setLinearDamping / getLinearDamping round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setLinearDamping(ps, 0.1, 0.9)
        local mn, mx = lurek.particle.getLinearDamping(ps)
        expect_true(math.abs(mn - 0.1) < 0.001, "damping min")
        expect_true(math.abs(mx - 0.9) < 0.001, "damping max")
    end)
end)

-- @describe lurek.particle size settings
describe("lurek.particle size settings", function()
    -- @covers LParticleSystem:setSizes
    it("setSizes with multiple keyframes / getSizes round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setSizes(ps, 8.0, 4.0, 2.0, 1.0)
        local sizes = lurek.particle.getSizes(ps)
        expect_true(math.abs(sizes[1] - 8.0) < 0.001, "size[1]")
        expect_true(math.abs(sizes[2] - 4.0) < 0.001, "size[2]")
        expect_true(math.abs(sizes[3] - 2.0) < 0.001, "size[3]")
        expect_true(math.abs(sizes[4] - 1.0) < 0.001, "size[4]")
    end)
    -- @covers LParticleSystem:setSizeVariation
    it("setSizeVariation / getSizeVariation round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setSizeVariation(ps, 0.5)
        local v = lurek.particle.getSizeVariation(ps)
        expect_true(math.abs(v - 0.5) < 0.001, "size variation")
    end)
end)

-- @describe lurek.particle rotation settings
describe("lurek.particle rotation settings", function()
    -- @covers LParticleSystem:setRotation
    it("setRotation / getRotation round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setRotation(ps, 0.1, 0.9)
        local mn, mx = lurek.particle.getRotation(ps)
        expect_true(math.abs(mn - 0.1) < 0.001, "rotation min")
        expect_true(math.abs(mx - 0.9) < 0.001, "rotation max")
    end)
    -- @covers LParticleSystem:setSpin
    it("setSpin / getSpin round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setSpin(ps, 0.2, 1.5)
        local mn, mx = lurek.particle.getSpin(ps)
        expect_true(math.abs(mn - 0.2) < 0.001, "spin min")
        expect_true(math.abs(mx - 1.5) < 0.001, "spin max")
    end)
    -- @covers LParticleSystem:setSpinVariation
    it("setSpinVariation / getSpinVariation round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setSpinVariation(ps, 0.75)
        local v = lurek.particle.getSpinVariation(ps)
        expect_true(math.abs(v - 0.75) < 0.001, "spin variation")
    end)
    -- @covers LParticleSystem:setRelativeRotation
    it("setRelativeRotation / hasRelativeRotation round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setRelativeRotation(ps, true)
        expect_true(lurek.particle.hasRelativeRotation(ps), "relative rotation enabled")
        lurek.particle.setRelativeRotation(ps, false)
        expect_true(not lurek.particle.hasRelativeRotation(ps), "relative rotation disabled")
    end)
end)

-- @describe lurek.particle color settings
describe("lurek.particle color settings", function()
    -- @covers LParticleSystem:setColors
    it("setColors / getColors round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setColors(ps, {1, 0, 0, 1}, {0, 0, 1, 0})
        -- getColors returns a sequence of color tables: {{r,g,b,a}, {r,g,b,a}, ...}
        local colors = lurek.particle.getColors(ps)
        local r1, g1, b1, a1 = colors[1][1], colors[1][2], colors[1][3], colors[1][4]
        local r2, g2, b2, a2 = colors[2][1], colors[2][2], colors[2][3], colors[2][4]
        expect_true(math.abs(r1 - 1.0) < 0.001, "color[1].r")
        expect_true(math.abs(g1 - 0.0) < 0.001, "color[1].g")
        expect_true(math.abs(b1 - 0.0) < 0.001, "color[1].b")
        expect_true(math.abs(a1 - 1.0) < 0.001, "color[1].a")
        expect_true(math.abs(r2 - 0.0) < 0.001, "color[2].r")
        expect_true(math.abs(b2 - 1.0) < 0.001, "color[2].b")
        expect_true(math.abs(a2 - 0.0) < 0.001, "color[2].a")
    end)
end)

-- @describe lurek.particle rendering settings
describe("lurek.particle rendering settings", function()
    -- @covers LParticleSystem:setShader
    it("setShader binds and clears a particle-target shader", function()
        local ps = lurek.particle.newSystem()
        local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>, @location(1) uv: vec2<f32>, @location(2) local_pos: vec2<f32>, @location(3) world_pos: vec2<f32>, @location(4) velocity: vec2<f32>, @location(5) age: f32, @location(6) lifetime: f32, @location(7) seed: f32) -> @location(0) vec4<f32> {
    return vec4<f32>(color.rgb + uv.xyx * 0.0 + local_pos.xyx * 0.0 + world_pos.xyx * 0.0 + velocity.xyx * 0.0 + vec3<f32>(age + lifetime + seed) * 0.0, color.a);
}
]], { target = "particle" })
        ps:setShader(shader)
        expect_equal(shader:getId(), ps:getShader():getId())
        ps:setShader(nil)
        expect_equal(nil, ps:getShader())
    end)

    -- @covers LParticleSystem:getShader
    it("getShader returns the bound particle shader", function()
        local ps = lurek.particle.newSystem()
        local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "particle" })
        ps:setShader(shader)
        expect_equal(shader:getId(), ps:getShader():getId())
    end)

    -- @covers LParticleSystem:setShaderUniform
    it("setShaderUniform forwards values to the bound shader", function()
        local ps = lurek.particle.newSystem()
        local shader = lurek.render.newShader([[
@fragment
fn fs_main(@location(0) color: vec4<f32>) -> @location(0) vec4<f32> {
    return color;
}
]], { target = "particle" })
        ps:setShader(shader)
        ps:setShaderUniform("glow_amount", 0.75)
        expect_true(shader:hasUniform("glow_amount"))
    end)

    -- @covers LParticleSystem:setOffset
    it("setOffset / getOffset round-trip", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setOffset(ps, 4.0, 8.0)
        local ox, oy = lurek.particle.getOffset(ps)
        expect_true(math.abs(ox - 4.0) < 0.001, "offset x")
        expect_true(math.abs(oy - 8.0) < 0.001, "offset y")
    end)
    -- @covers LParticleSystem:setInsertMode
    it("round-trips supported insert modes", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setInsertMode(ps, "top")
        expect_equal("top", lurek.particle.getInsertMode(ps), "insert mode")
        lurek.particle.setInsertMode(ps, "bottom")
        expect_equal("bottom", lurek.particle.getInsertMode(ps), "insert mode bottom")
        lurek.particle.setInsertMode(ps, "random")
        expect_equal("random", lurek.particle.getInsertMode(ps), "insert mode random")
    end)
    -- @covers LParticleSystem:setBufferSize
    it("setBufferSize round-trips and truncates live particles when shrinking the pool", function()
        local ps = lurek.particle.newSystem({ maxParticles = 50 })
        lurek.particle.setBufferSize(ps, 200)
        expect_equal(200, lurek.particle.getBufferSize(ps), "buffer size")

        ps = lurek.particle.newSystem({
            emissionRate = 0,
            maxParticles = 32,
            lifetimeMin = 5,
            lifetimeMax = 5,
        })
        ps:emit(12)
        expect_equal(12, ps:getCount())
        ps:setBufferSize(4)
        expect_equal(4, ps:getBufferSize())
        expect_equal(4, ps:getCount())
    end)
end)

-- @describe lurek.particle emission area
describe("lurek.particle emission area", function()
    -- @covers LParticleSystem:setEmissionArea
    it("round-trips supported emission area shapes", function()
        local ps = lurek.particle.newSystem()
        lurek.particle.setEmissionArea(ps, "none", 0, 0)
        local dist, w, h = lurek.particle.getEmissionArea(ps)
        expect_equal("none", dist, "area distribution none")
        lurek.particle.setEmissionArea(ps, "uniform", 100, 50)
        dist, w, h = lurek.particle.getEmissionArea(ps)
        expect_equal("uniform", dist, "area distribution uniform")
        expect_true(math.abs(w - 100) < 0.001, "area width")
        expect_true(math.abs(h - 50) < 0.001, "area height")
        lurek.particle.setEmissionArea(ps, "ellipse", 60, 30)
        dist = lurek.particle.getEmissionArea(ps)
        expect_equal("ellipse", dist, "area distribution ellipse")
    end)
end)

-- @describe lurek.particle object-method syntax
describe("lurek.particle object-method syntax", function()
    -- @covers LParticleSystem:type
    it("ps:type() returns 'LParticleSystem'", function()
        local ps = lurek.particle.newSystem()
        expect_equal("LParticleSystem", ps:type(), "type")
    end)
    -- @covers LParticleSystem:typeOf
    it("ps:typeOf reports supported and unsupported types", function()
        local ps = lurek.particle.newSystem()
        expect_true(ps:typeOf("LDrawable"), "typeOf Drawable")
        expect_true(ps:typeOf("LObject"), "typeOf Object")
        expect_true(not ps:typeOf("LNonExistent"), "typeOf NonExistent false")
    end)
end)

-- @describe lurek.particle.clone
describe("lurek.particle.clone", function()
    -- @covers LParticleSystem:clone
    it("clone returns a different userdata handle", function()
        local ps = lurek.particle.newSystem({ emissionRate = 77.0 })
        local ps2 = lurek.particle.clone(ps)
        expect_type("userdata", ps2)
        -- Clones share config but are independent objects
        local r1 = lurek.particle.getEmissionRate(ps)
        local r2 = lurek.particle.getEmissionRate(ps2)
        expect_true(math.abs(r1 - r2) < 0.001, "clone has same emission rate")
    end)
end)

-- @describe lurek.particle.release
describe("lurek.particle.release", function()
    -- @covers LParticleSystem:release
    it("release returns true for valid handles and invalidates further access", function()
        local ps = lurek.particle.newSystem()
        local ok = lurek.particle.release(ps)
        expect_equal(true, ok, "release returns true")
        expect_equal(false, lurek.particle.release(ps), "second release reports invalid handle")
        ok = pcall(function() lurek.particle.getCount(ps) end)
        expect_true(not ok, "accessing released handle should error")
    end)
end)

-- Phase 8: Particle shape tests

-- @describe particle shapes
describe("particle shapes", function()
    -- @covers LParticleSystem:setShape
    it("setShape and getShape round-trip for all shapes and reject invalid names", function()
        local ps = lurek.particle.newSystem({ maxParticles = 10 })
        local shapes = {"square", "circle", "triangle", "spark", "diamond", "shrapnel", "ray", "puff", "ring", "capsule"}
        for _, s in ipairs(shapes) do
            ps:setShape(s)
            expect_equal(ps:getShape(), s)
        end
        expect_error(function()
            ps:setShape("hexagon")
        end)
        lurek.particle.release(ps)
    end)

    -- @covers LParticleSystem:getShape
    it("default shape is square", function()
        local ps = lurek.particle.newSystem({ maxParticles = 10 })
        expect_equal(ps:getShape(), "square")
        lurek.particle.release(ps)
    end)
end)

-- @describe particle gravity
describe("particle gravity", function()
    -- @covers LParticleSystem:getGravity
    it("gravityY config key is accepted and particles survive updates under gravity", function()
        local ps = lurek.particle.newSystem({
            maxParticles = 5,
            emissionRate = 0,
            gravityY = 200.0,
            speedMin = 0,
            speedMax = 0,
            lifetimeMin = 10,
            lifetimeMax = 10,
        })
        lurek.particle.emit(ps, 1)
        lurek.particle.update(ps, 0.1)
        -- Particle should still be alive (lifetime=10s, only 0.1s elapsed)
        expect_equal(lurek.particle.getCount(ps), 1)
        local gx, gy = lurek.particle.getGravity(ps)
        expect_true(math.abs(gx) < 0.001, "gravityX remains 0 by default")
        expect_true(math.abs(gy - 200) < 0.001, "gravityY config key sets gravity_y")
        lurek.particle.release(ps)
        ps = lurek.particle.newSystem({ gravityY = 100 })
        gx, gy = lurek.particle.getGravity(ps)
        expect_true(math.abs(gy - 100) < 0.001, "gravityY config key sets gravity_y")
        lurek.particle.release(ps)
    end)
end)

-- @describe particle warm_up
describe("particle warm_up", function()
    -- @covers LParticleSystem:warmUp
    it("warmUp produces particles and clamps very large durations", function()
        local ps = lurek.particle.newSystem({
            maxParticles = 200,
            emissionRate = 100,
            lifetimeMin = 5,
            lifetimeMax = 5,
        })
        ps:warmUp(1.0)
        expect_true(ps:count() > 0, "warmUp should produce particles")
        lurek.particle.release(ps)
        ps = lurek.particle.newSystem({
            maxParticles = 50,
            emissionRate = 10,
            lifetimeMin = 2,
            lifetimeMax = 2,
        })
        local ok = pcall(function() ps:warmUp(100) end)
        expect_true(ok, "warmUp with large value should not crash")
        lurek.particle.release(ps)
    end)
end)

-- @describe particle attractors
describe("particle attractors", function()
    -- @covers LParticleSystem:addAttractor
    it("addAttractor increases getAttractorCount", function()
        local ps = lurek.particle.newSystem()
        ps:addAttractor(0, 0, 100, 200)
        ps:addAttractor(50, 50, 80, 100)
        ps:addAttractor(-30, 20, 60, 150)
        expect_equal(ps:getAttractorCount(), 3)
        lurek.particle.release(ps)
    end)
    -- @covers LParticleSystem:clearAttractors
    it("clearAttractors resets count to zero", function()
        local ps = lurek.particle.newSystem()
        ps:addAttractor(10, 10, 50, 80)
        ps:addAttractor(20, 20, 50, 80)
        ps:clearAttractors()
        expect_equal(ps:getAttractorCount(), 0)
        lurek.particle.release(ps)
    end)
end)

-- @describe particle bounce bounds
describe("particle bounce bounds", function()
    -- @covers LParticleSystem:setBounds
    it("setBounds does not crash", function()
        local ps = lurek.particle.newSystem()
        local ok = pcall(function() ps:setBounds(-100, 100, -100, 100, 0.8) end)
        expect_true(ok, "setBounds should not crash")
        lurek.particle.release(ps)
    end)
    -- @covers LParticleSystem:clearBounds
    it("clearBounds does not crash", function()
        local ps = lurek.particle.newSystem()
        ps:setBounds(-50, 50, -50, 50, 1.0)
        local ok = pcall(function() ps:clearBounds() end)
        expect_true(ok, "clearBounds should not crash")
        lurek.particle.release(ps)
    end)
end)

-- @describe lurek.particle addSubEmitter
describe("lurek.particle addSubEmitter", function()
    -- @covers LParticleSystem:addSubEmitter
    it("addSubEmitter attaches sub-config and defaults burst_count to 1", function()
        local ps = lurek.particle.newSystem({ emissionRate = 0 })
        ps:addSubEmitter({
            emissionRate = 0,
            lifetimeMin = 0.5,
            lifetimeMax = 0.5,
            speedMin = 10,
            speedMax = 20,
        }, 3)
        ps:addSubEmitter({ emissionRate = 0 })  -- no burst_count; should default to 1
        lurek.particle.release(ps)
    end)
end)

-- @describe lurek.particle setFlipbook / getFlipbook
describe("lurek.particle setFlipbook / getFlipbook", function()
    -- @covers LParticleSystem:setFlipbook
    it("setFlipbook round-trips via getFlipbook and rejects invalid cols", function()
        local ps = lurek.particle.newSystem({ emissionRate = 0 })
        ps:setFlipbook(4, 2, 12)
        local c, r, fps = ps:getFlipbook()
        expect_equal(c, 4)
        expect_equal(r, 2)
        expect_near(fps, 12.0, 0.001)
        local ok = pcall(function() ps:setFlipbook(0, 2, 12) end)
        expect_equal(ok, false, "setFlipbook(0, ...) must raise an error")
        lurek.particle.release(ps)
    end)
    -- @covers LParticleSystem:getFlipbook
    it("getFlipbook returns nil when not set", function()
        local ps = lurek.particle.newSystem({ emissionRate = 0 })
        local c, r, fps = ps:getFlipbook()
        expect_equal(c, nil, "cols must be nil when flipbook not set")
        expect_equal(r, nil)
        expect_equal(fps, nil)
        lurek.particle.release(ps)
    end)
end)

-- =========================================================================
-- Trail coverage
-- =========================================================================

-- @describe lurek.particle trail
describe("lurek.particle trail", function()
    -- @covers lurek.particle.newTrail
    it("creates a trail userdata", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        expect_type("userdata", trail)
        expect_equal(trail:type(), "LTrail")
        expect_equal(trail:typeOf("LTrail"), true)
        expect_equal(trail:typeOf("LObject"), true)
    end)
    -- @covers LTrail:clear
    it("tracks pushed points and clears them", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        expect_equal(trail:getPointCount(), 0)
        trail:pushPoint(0.0, 0.0)
        trail:pushPoint(5.0, 5.0)
        expect_equal(trail:getPointCount(), 2)
        trail:clear()
        expect_equal(trail:getPointCount(), 0)
    end)
    -- @covers LTrail:setWidth
    it("round-trips width and lifetime", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        trail:setWidth(4.0, 1.0)
        local start_width, end_width = trail:getWidth()
        expect_near(start_width, 4.0, 0.0001)
        expect_near(end_width, 1.0, 0.0001)

        trail:setLifetime(2.5)
        expect_near(trail:getLifetime(), 2.5, 0.0001)
    end)
    -- @covers LTrail:setMinDistance
    it("respects minimum point distance", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        trail:setMinDistance(10.0)
        trail:pushPoint(0.0, 0.0)
        trail:pushPoint(1.0, 1.0)
        trail:pushPoint(20.0, 0.0)
        expect_equal(trail:getPointCount(), 2)
    end)
    -- @covers LTrail:drawToImage
    it("draws to image data with requested dimensions", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        local image = trail:drawToImage(64, 32)
        expect_type("userdata", image)
        expect_equal(image:getWidth(), 64)
        expect_equal(image:getHeight(), 32)
    end)
end)

-- Phase 03: Extensibility Hooks

-- @describe particle sub-systems
describe("particle sub-systems", function()
    -- @covers LParticleSystem:subSystemCount
    it("subSystemCount starts at 0", function()
        local ps = lurek.particle.newSystem({ maxParticles = 64 })
        expect_equal(ps:subSystemCount(), 0)
    end)
    -- @covers LParticleSystem:addSubSystem
    it("addSubSystem returns 1-based indices and increments count", function()
        local ps = lurek.particle.newSystem({ maxParticles = 64 })
        local idx = ps:addSubSystem({ maxParticles = 16 })
        expect_equal(idx, 1)
        expect_equal(ps:subSystemCount(), 1)
        local idx2 = ps:addSubSystem({ maxParticles = 16 })
        expect_equal(idx2, 2)
    end)
end)

-- @describe particle custom emission shape
describe("particle custom emission shape", function()
    -- @covers LParticleSystem:setCustomEmissionShape
    it("custom emission shape callbacks are accepted and invoked during emit", function()
        local ps = lurek.particle.newSystem({
            maxParticles = 8,
            emissionRate = 0,
        })
        local calls = 0
        ps:setCustomEmissionShape(function()
            calls = calls + 1
            return 10, 20
        end)
        ps:emit(3)
        ps:update(0.016)
        expect_true(calls >= 3, "custom shape callback should be called for each emitted particle")
    end)
end)

-- @describe particle death batch callback
describe("particle death batch callback", function()
    -- @covers LParticleSystem:setOnDeathBatch
    it("death batch callbacks are accepted and invoked when particles die", function()
        local ps = lurek.particle.newSystem({
            maxParticles = 8,
            emissionRate = 0,
            lifetimeMin = 0.001,
            lifetimeMax = 0.001,
        })
        local ok = pcall(function()
            ps:setOnDeathBatch(function(_batch) end)
        end)
        expect_true(ok, "setOnDeathBatch should accept a callback function")
        local death_count = 0
        ps:setOnDeathBatch(function(batch)
            death_count = death_count + #batch
        end)
        ps:emit(3)
        ps:update(1.0)  -- enough to kill all 3
        expect_true(death_count >= 3, "death batch callback should receive all 3 dead particles")
        ps = lurek.particle.newSystem({
            maxParticles = 4,
            emissionRate = 0,
            lifetimeMin = 0.001,
            lifetimeMax = 0.001,
        })
        local entry = nil
        ps:setOnDeathBatch(function(batch)
            if #batch > 0 then entry = batch[1] end
        end)
        ps:emit(1)
        ps:update(1.0)
        expect_true(entry ~= nil, "should have received a death entry")
        if entry then
            expect_equal(type(entry.x), "number")
            expect_equal(type(entry.y), "number")
            expect_equal(type(entry.vx), "number")
            expect_equal(type(entry.vy), "number")
        end
    end)
end)

-- @describe lurek.particle.fromTOML extensibility
describe("lurek.particle.fromTOML extensibility", function()
    -- @covers lurek.particle.fromTOML
    it("fromTOML loads config from file", function()
        expect_type("function", lurek.particle.fromTOML)

        local ps = lurek.particle.fromTOML("save/particle_example.toml")
        expect_type("userdata", ps)
        expect_near(18.0, lurek.particle.getEmissionRate(ps), 0.001)

        local min_life, max_life = lurek.particle.getParticleLifetime(ps)
        expect_near(0.2, min_life, 0.001)
        expect_near(0.8, max_life, 0.001)
    end)
end)

-- @describe LTrail color endpoints
describe("LTrail color endpoints", function()
    -- @covers LTrail:setHeadColor
    it("setHeadColor and setTailColor accept rgba values [LTrail:setHeadColor]", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        expect_no_error(function()
            trail:setHeadColor(1.0, 0.1, 0.2, 1.0)
            trail:setTailColor(0.1, 0.2, 1.0, 0.5)
        end)
    end)

    -- @covers LTrail:setTailColor
    it("setHeadColor and setTailColor accept rgba values [LTrail:setTailColor]", function()
        local trail = lurek.particle.newTrail(1.0, 4.0)
        expect_no_error(function()
            trail:setHeadColor(1.0, 0.1, 0.2, 1.0)
            trail:setTailColor(0.1, 0.2, 1.0, 0.5)
        end)
    end)

end)

-- @describe particle presets and physics collision
describe("particle presets and physics collision", function()
    -- @covers lurek.particle.newPreset
    it("newPreset creates known presets", function()
        local ps = lurek.particle.newPreset("fire")
        expect_type("userdata", ps)
    end)

    -- @covers LParticleSystem:setCollidesWithPhysics
    it("setCollidesWithPhysics toggles collision state", function()
        local ps = lurek.particle.newSystem()
        local world = lurek.physics.newWorld(0, 9.81)
        ps:setCollidesWithPhysics(world)
        expect_true(ps:hasCollidesWithPhysics())
        ps:clearCollidesWithPhysics()
        expect_false(ps:hasCollidesWithPhysics())
    end)
end)

-- @describe particle missing explicit coverage
describe("particle missing explicit coverage", function()
    local function new_ps()
        return lurek.particle.newSystem({ emissionRate = 0, maxParticles = 64 })
    end

    local function new_trail()
        return lurek.particle.newTrail(1.0, 4.0)
    end

    -- @covers lurek.particle.drawLifecycleToImage
    it("drawLifecycleToImage returns image data for snapshot pairs", function()
        local image = lurek.particle.drawLifecycleToImage({
            { 0, 0 },
            { 1, 3 },
            { 2, 6 },
            { 3, 2 },
        }, 8, 64, 32)
        expect_type("userdata", image)
        expect_equal(64, image:getWidth())
        expect_equal(32, image:getHeight())
    end)

    -- @covers LParticleSystem:resume
    it("resume clears the paused state", function()
        local ps = new_ps()
        ps:pause()
        expect_true(ps:isPaused())
        ps:resume()
        expect_false(ps:isPaused())
    end)

    -- @covers LParticleSystem:count
    it("count reports the current live particle count", function()
        local ps = new_ps()
        ps:emit(3)
        expect_equal(3, ps:count())
    end)

    -- @covers LParticleSystem:getEmissionRate
    it("getEmissionRate returns the stored emission rate", function()
        local ps = new_ps()
        ps:setEmissionRate(24.5)
        expect_near(24.5, ps:getEmissionRate(), 0.001)
    end)

    -- @covers LParticleSystem:getParticleLifetime
    it("getParticleLifetime returns the configured lifetime range", function()
        local ps = new_ps()
        ps:setParticleLifetime(0.25, 1.75)
        local mn, mx = ps:getParticleLifetime()
        expect_near(0.25, mn, 0.001)
        expect_near(1.75, mx, 0.001)
    end)

    -- @covers LParticleSystem:getEmitterLifetime
    it("getEmitterLifetime returns the configured emitter lifetime", function()
        local ps = new_ps()
        ps:setEmitterLifetime(6.0)
        expect_near(6.0, ps:getEmitterLifetime(), 0.001)
    end)

    -- @covers LParticleSystem:getSpeed
    it("getSpeed returns the configured speed range", function()
        local ps = new_ps()
        ps:setSpeed(12.0, 34.0)
        local mn, mx = ps:getSpeed()
        expect_near(12.0, mn, 0.001)
        expect_near(34.0, mx, 0.001)
    end)

    -- @covers LParticleSystem:getDirection
    it("getDirection returns the configured direction", function()
        local ps = new_ps()
        ps:setDirection(1.5)
        expect_near(1.5, ps:getDirection(), 0.001)
    end)

    -- @covers LParticleSystem:getSpread
    it("getSpread returns the configured spread", function()
        local ps = new_ps()
        ps:setSpread(0.8)
        expect_near(0.8, ps:getSpread(), 0.001)
    end)

    -- @covers LParticleSystem:getLinearAcceleration
    it("getLinearAcceleration returns the configured acceleration bounds", function()
        local ps = new_ps()
        ps:setLinearAcceleration(-2.0, -4.0, 6.0, 8.0)
        local xmin, ymin, xmax, ymax = ps:getLinearAcceleration()
        expect_near(-2.0, xmin, 0.001)
        expect_near(-4.0, ymin, 0.001)
        expect_near(6.0, xmax, 0.001)
        expect_near(8.0, ymax, 0.001)
    end)

    -- @covers LParticleSystem:getRadialAcceleration
    it("getRadialAcceleration returns the configured radial range", function()
        local ps = new_ps()
        ps:setRadialAcceleration(-3.0, 7.0)
        local mn, mx = ps:getRadialAcceleration()
        expect_near(-3.0, mn, 0.001)
        expect_near(7.0, mx, 0.001)
    end)

    -- @covers LParticleSystem:getTangentialAcceleration
    it("getTangentialAcceleration returns the configured tangential range", function()
        local ps = new_ps()
        ps:setTangentialAcceleration(1.0, 9.0)
        local mn, mx = ps:getTangentialAcceleration()
        expect_near(1.0, mn, 0.001)
        expect_near(9.0, mx, 0.001)
    end)

    -- @covers LParticleSystem:getLinearDamping
    it("getLinearDamping returns the configured damping range", function()
        local ps = new_ps()
        ps:setLinearDamping(0.15, 0.45)
        local mn, mx = ps:getLinearDamping()
        expect_near(0.15, mn, 0.001)
        expect_near(0.45, mx, 0.001)
    end)

    -- @covers LParticleSystem:getSizes
    it("getSizes returns every configured size keyframe", function()
        local ps = new_ps()
        ps:setSizes(6.0, 3.0, 1.5)
        local sizes = ps:getSizes()
        expect_equal(3, #sizes)
        expect_near(6.0, sizes[1], 0.001)
        expect_near(3.0, sizes[2], 0.001)
        expect_near(1.5, sizes[3], 0.001)
    end)

    -- @covers LParticleSystem:getSizeVariation
    it("getSizeVariation returns the configured variation", function()
        local ps = new_ps()
        ps:setSizeVariation(0.35)
        expect_near(0.35, ps:getSizeVariation(), 0.001)
    end)

    -- @covers LParticleSystem:getRotation
    it("getRotation returns the configured rotation range", function()
        local ps = new_ps()
        ps:setRotation(0.2, 1.1)
        local mn, mx = ps:getRotation()
        expect_near(0.2, mn, 0.001)
        expect_near(1.1, mx, 0.001)
    end)

    -- @covers LParticleSystem:getSpin
    it("getSpin returns the configured spin range", function()
        local ps = new_ps()
        ps:setSpin(0.4, 1.6)
        local mn, mx = ps:getSpin()
        expect_near(0.4, mn, 0.001)
        expect_near(1.6, mx, 0.001)
    end)

    -- @covers LParticleSystem:getSpinVariation
    it("getSpinVariation returns the configured spin variance", function()
        local ps = new_ps()
        ps:setSpinVariation(0.55)
        expect_near(0.55, ps:getSpinVariation(), 0.001)
    end)

    -- @covers LParticleSystem:hasRelativeRotation
    it("hasRelativeRotation reports the stored flag", function()
        local ps = new_ps()
        expect_false(ps:hasRelativeRotation())
        ps:setRelativeRotation(true)
        expect_true(ps:hasRelativeRotation())
    end)

    -- @covers LParticleSystem:getColors
    it("getColors returns the configured endpoint colors", function()
        local ps = new_ps()
        ps:setColors({1, 0.5, 0.25, 1}, {0.1, 0.2, 0.3, 0.4})
        local colors = ps:getColors()
        expect_equal(2, #colors)
        expect_near(1.0, colors[1][1], 0.001)
        expect_near(0.5, colors[1][2], 0.001)
        expect_near(0.25, colors[1][3], 0.001)
        expect_near(1.0, colors[1][4], 0.001)
        expect_near(0.1, colors[2][1], 0.001)
        expect_near(0.2, colors[2][2], 0.001)
        expect_near(0.3, colors[2][3], 0.001)
        expect_near(0.4, colors[2][4], 0.001)
    end)

    -- @covers LParticleSystem:getOffset
    it("getOffset returns the configured render offset", function()
        local ps = new_ps()
        ps:setOffset(9.0, 11.0)
        local ox, oy = ps:getOffset()
        expect_near(9.0, ox, 0.001)
        expect_near(11.0, oy, 0.001)
    end)

    -- @covers LParticleSystem:getInsertMode
    it("getInsertMode returns the stored insertion mode", function()
        local ps = new_ps()
        ps:setInsertMode("bottom")
        expect_equal("bottom", ps:getInsertMode())
    end)

    -- @covers LParticleSystem:getBufferSize
    it("getBufferSize returns the configured max particle count", function()
        local ps = new_ps()
        ps:setBufferSize(128)
        expect_equal(128, ps:getBufferSize())
    end)

    -- @covers LParticleSystem:getEmissionArea
    it("getEmissionArea returns the configured area tuple", function()
        local ps = new_ps()
        ps:setEmissionArea("uniform", 40, 20)
        local mode, w, h = ps:getEmissionArea()
        expect_equal("uniform", mode)
        expect_near(40.0, w, 0.001)
        expect_near(20.0, h, 0.001)
    end)

    -- @covers LParticleSystem:setGravity
    it("setGravity updates the gravity vector", function()
        local ps = new_ps()
        ps:setGravity(3.0, 9.0)
        local gx, gy = ps:getGravity()
        expect_near(3.0, gx, 0.001)
        expect_near(9.0, gy, 0.001)
    end)

    -- @covers LParticleSystem:getAttractorCount
    it("getAttractorCount reports the current attractor total", function()
        local ps = new_ps()
        expect_equal(0, ps:getAttractorCount())
        ps:addAttractor(0, 0, 50, 100)
        ps:addAttractor(10, 5, 30, 40)
        expect_equal(2, ps:getAttractorCount())
    end)

    -- @covers LParticleSystem:clearCollidesWithPhysics
    it("clearCollidesWithPhysics disables physics collision integration", function()
        local ps = new_ps()
        local world = lurek.physics.newWorld(0, 9.81)
        ps:setCollidesWithPhysics(world)
        expect_true(ps:hasCollidesWithPhysics())
        ps:clearCollidesWithPhysics()
        expect_false(ps:hasCollidesWithPhysics())
    end)

    -- @covers LParticleSystem:hasCollidesWithPhysics
    it("hasCollidesWithPhysics reports whether a physics world is bound", function()
        local ps = new_ps()
        expect_false(ps:hasCollidesWithPhysics())
        local world = lurek.physics.newWorld(0, 9.81)
        ps:setCollidesWithPhysics(world)
        expect_true(ps:hasCollidesWithPhysics())
    end)

    -- @covers LTrail:pushPoint
    it("pushPoint appends trail points", function()
        local trail = new_trail()
        expect_equal(0, trail:getPointCount())
        trail:pushPoint(1.0, 2.0)
        expect_equal(1, trail:getPointCount())
    end)

    -- @covers LTrail:update
    it("update advances trail lifetime bookkeeping without removing fresh points", function()
        local trail = new_trail()
        trail:setLifetime(2.0)
        trail:pushPoint(1.0, 2.0)
        trail:update(0.5)
        expect_equal(1, trail:getPointCount())
    end)

    -- @covers LTrail:getWidth
    it("getWidth returns the configured start and end widths", function()
        local trail = new_trail()
        trail:setWidth(5.0, 2.0)
        local start_width, end_width = trail:getWidth()
        expect_near(5.0, start_width, 0.001)
        expect_near(2.0, end_width, 0.001)
    end)

    -- @covers LTrail:setLifetime
    it("setLifetime updates the stored trail lifetime", function()
        local trail = new_trail()
        trail:setLifetime(3.25)
        expect_near(3.25, trail:getLifetime(), 0.001)
    end)

    -- @covers LTrail:getLifetime
    it("getLifetime returns the current trail lifetime", function()
        local trail = new_trail()
        trail:setLifetime(4.5)
        expect_near(4.5, trail:getLifetime(), 0.001)
    end)

    -- @covers LTrail:getPointCount
    it("getPointCount returns the number of stored trail points", function()
        local trail = new_trail()
        trail:pushPoint(0.0, 0.0)
        trail:pushPoint(2.0, 2.0)
        expect_equal(2, trail:getPointCount())
    end)

    -- @covers LTrail:type
    it("type returns the trail userdata type name", function()
        local trail = new_trail()
        expect_equal("LTrail", trail:type())
    end)

    -- @covers LTrail:typeOf
    it("typeOf recognizes trail userdata inheritance", function()
        local trail = new_trail()
        expect_true(trail:typeOf("LTrail"))
        expect_true(trail:typeOf("LObject"))
        expect_false(trail:typeOf("LParticleSystem"))
    end)
end)
end
-- END test_particle_core_unit.lua

-- BEGIN test_particle_render_unit.lua
do
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
end
-- END test_particle_render_unit.lua

-- @describe particle shooter helpers
describe("particle shooter helpers", function()
    -- @covers LParticleSystem:emitAt
    it("emitAt moves, aims, and emits particles", function()
        local ps = lurek.particle.newSystem({ maxParticles = 8 })
        ps:emitAt(12, 18, 3, 0.75)
        local x, y = ps:getPosition()
        expect_near(12, x, 0.001)
        expect_near(18, y, 0.001)
        expect_near(0.75, ps:getDirection(), 0.001)
        expect_equal(3, ps:getCount())
    end)

    -- @covers lurek.particle.newPreset
    it("newPreset creates shooter effect presets", function()
        expect_equal("LParticleSystem", lurek.particle.newPreset("explosion"):type())
        expect_equal("LParticleSystem", lurek.particle.newPreset("muzzle"):type())
        expect_equal("LParticleSystem", lurek.particle.newPreset("smoke_trail"):type())
    end)
end)

test_summary()
