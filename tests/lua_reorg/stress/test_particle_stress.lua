-- Lurek2D Stress Test: Particle System Burst Emission
-- Tests large particle counts and extended lifecycle simulation

local function system_config(overrides)
    local config = {
        maxParticles = 1000,
        emissionRate = 500,
        lifetime = {1, 2},
        speed = {50, 100},
        direction = 0,
        spread = 0,
    }
    if overrides then
        for key, value in pairs(overrides) do
            config[key] = value
        end
    end
    return config
end

local function create_particle_system(overrides)
    return lurek.particle.newSystem(system_config(overrides))
end

local function emit_burst_count(overrides, amount)
    local sys = create_particle_system(overrides)
    sys:emit(amount)
    return sys, sys:getCount()
end

local function update_particle_system(overrides, frames)
    local sys = create_particle_system(overrides)
    sys:start()
    for _ = 1, frames do
        sys:update(1.0 / 60.0)
    end
    return lurek.particle.isActive(sys)
end

local function reset_particle_system_count(overrides, warmup_frames)
    local sys = create_particle_system(overrides)
    sys:start()
    for _ = 1, warmup_frames do
        sys:update(1.0 / 60.0)
    end
    sys:stop()
    sys:reset()
    return sys:getCount()
end

-- @describe particle stress: burst emission
describe("particle stress: burst emission", function()
    -- @stress lurek.particle.newSystem
    it("emits 5000 particles", function()
        local sys, count = emit_burst_count({
            maxParticles = 5000,
            emissionRate = 5000,
            lifetime = {2, 4},
            speed = {50, 150},
            spread = 6.28,
        }, 5000)
        expect_type("userdata", sys)
        expect_true(count > 0, "particles emitted")
    end)

    -- @stress LParticleSystem:update
    it("simulates 120 frames of particle lifecycle", function()
        local active = update_particle_system({
            maxParticles = 2000,
            emissionRate = 100,
            lifetime = {0.5, 1.5},
            speed = {20, 80},
            spread = 3.14,
        }, 120)
        expect_true(active, "system still active")
    end)

    -- @stress LParticleSystem:reset
    it("stop and reset clears all particles", function()
        local count = reset_particle_system_count(nil, 30)
        expect_equal(0, count, "all particles cleared after reset")
    end)
end)
test_summary()
