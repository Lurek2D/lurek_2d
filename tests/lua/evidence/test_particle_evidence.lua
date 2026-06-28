-- Evidence tests: particle module
-- Artifacts are generated from live lurek.particle systems and trails.
-- This file intentionally avoids file-level @covers markers; evidence ownership is described per artifact block.

local Fixture = lurek.filesystem.load("tests/fixtures/particle_evidence_fixture.lua")()
local OUT = evidence_output_dir("particle")

local function save_png(img, path)
    lurek.image.savePNG(img, path)
    expect_evidence_created(path)
end

local function save_gif(frames, path, options)
    lurek.image.saveGIF(frames, path, options or { delayMs = 90, speed = 10 })
    expect_evidence_created(path)
end

local function reset_particle_outputs()
    local names = {
        "particle_attractor_contraction.png",
        "particle_attractor_field.gif",
        "particle_attractor_motion.gif",
        "particle_burst_evolution.gif",
        "particle_emitter_burst.png",
        "particle_emitter_cluster_snapshot.png",
        "particle_explosion_renderer.png",
        "particle_lifecycle_chart.png",
        "particle_over_paint_renderer.png",
        "particle_paint_composite.png",
        "particle_archetype_showcase.png",
        "particle_bounds_bounce_box.gif",
        "particle_control_state_timeline.gif",
        "particle_emission_area_shapes.png",
        "particle_preset_showcase.png",
        "particle_rain_renderer.png",
        "particle_shape_size_keyframes.png",
        "particle_spark_trail_renderer.png",
        "particle_specialized_renderers.png",
        "particle_subemitter_death_burst.gif",
        "particle_trail_decay.gif",
        "particle_trail_ribbon_decay.gif",
        "particle_trail_wave_ribbon.png",
        "particle_velocity_burst.gif",
    }
    for _, name in ipairs(names) do
        pcall(function()
            lurek.filesystem.remove(OUT .. name)
        end)
        if os and os.remove then
            pcall(function()
                os.remove(OUT .. name)
            end)
        end
    end
end

local function paste(dst, src, x, y)
    dst:paste(src, x, y)
end

local function draw_border(img, x, y, w, h, r, g, b)
    img:drawRect(x, y, w, 2, r, g, b, 255)
    img:drawRect(x, y + h - 2, w, 2, r, g, b, 255)
    img:drawRect(x, y, 2, h, r, g, b, 255)
    img:drawRect(x + w - 2, y, 2, h, r, g, b, 255)
end

local function warm_particle_system(ps, frames, dt)
    ps:start()
    for _ = 1, frames do
        ps:update(dt)
    end
end

local function panel_from_system(ps, w, h, border)
    local img = ps:drawToImage(w, h)
    draw_border(img, 2, 2, w - 4, h - 4, border[1], border[2], border[3])
    return img
end

local function draw_count_meter(img, x, y, w, h, count, max_count, r, g, b)
    img:drawRect(x, y, w, h, 24, 28, 40, 255)
    img:drawRect(x, y, math.max(1, math.floor(w * math.min(1, count / math.max(1, max_count)))), h, r, g, b, 255)
end

reset_particle_outputs()

-- @describe Evidence: lurek.particle API
describe("Evidence: lurek.particle API", function()
    before_each(function()
        ensure_evidence_dir("particle")
    end)

    -- Does: Builds four seeded emitter archetypes, warms each live system, and places their owner-rendered snapshots into one comparison image.
    -- Shows: Flame, smoke, rain, and snow behaviors are visually distinct through direction, speed, size, shape, color, and gravity settings.
    -- Artifact: tests/artifacts/current/particle/particle_archetype_showcase.png
    -- Why: This proves particle emitter configuration and rendering with deterministic seeds; sheet layout only keeps related LParticleSystem:drawToImage outputs inspectable together.
    it("PNG: seeded emitter archetype showcase", function()
        local archetypes = {
            {
                x = 64,
                y = 98,
                emit = 95,
                frames = 18,
                dt = 0.045,
                border = { 255, 112, 40 },
                config = {
                    seed = 3101,
                    maxParticles = 160,
                    emissionRate = 80,
                    shape = "circle",
                    lifetimeMin = 0.7,
                    lifetimeMax = 1.2,
                    sizeMin = 3,
                    sizeMax = 7,
                    speedMin = 22,
                    speedMax = 70,
                    spread = 80,
                    colors = {
                        { 1.0, 0.92, 0.32, 1.0 },
                        { 1.0, 0.28, 0.08, 0.75 },
                        { 0.18, 0.10, 0.05, 0.0 },
                    },
                },
                configure = function(ps)
                    ps:setDirection(-90)
                    ps:setGravity(0, -22)
                end,
            },
            {
                x = 64,
                y = 94,
                emit = 85,
                frames = 22,
                dt = 0.050,
                border = { 160, 170, 180 },
                config = {
                    seed = 3102,
                    maxParticles = 150,
                    emissionRate = 60,
                    shape = "puff",
                    lifetimeMin = 1.2,
                    lifetimeMax = 2.0,
                    sizeMin = 4,
                    sizeMax = 12,
                    speedMin = 8,
                    speedMax = 28,
                    spread = 120,
                    colors = {
                        { 0.40, 0.42, 0.42, 0.70 },
                        { 0.20, 0.21, 0.22, 0.25 },
                        { 0.06, 0.06, 0.07, 0.0 },
                    },
                },
                configure = function(ps)
                    ps:setDirection(-90)
                    ps:setGravity(0, -8)
                end,
            },
            {
                x = 64,
                y = 16,
                emit = 130,
                frames = 16,
                dt = 0.055,
                border = { 100, 160, 255 },
                config = {
                    seed = 3103,
                    maxParticles = 180,
                    emissionRate = 120,
                    shape = "ray",
                    lifetimeMin = 0.55,
                    lifetimeMax = 0.95,
                    sizeMin = 2,
                    sizeMax = 4,
                    speedMin = 70,
                    speedMax = 130,
                    spread = 35,
                    colors = {
                        { 0.55, 0.72, 1.0, 0.75 },
                        { 0.35, 0.52, 0.95, 0.35 },
                    },
                },
                configure = function(ps)
                    ps:setDirection(90)
                    ps:setGravity(0, 45)
                end,
            },
            {
                x = 64,
                y = 18,
                emit = 105,
                frames = 22,
                dt = 0.060,
                border = { 230, 240, 255 },
                config = {
                    seed = 3104,
                    maxParticles = 170,
                    emissionRate = 75,
                    shape = "circle",
                    lifetimeMin = 1.3,
                    lifetimeMax = 2.4,
                    sizeMin = 2,
                    sizeMax = 4,
                    speedMin = 12,
                    speedMax = 32,
                    spread = 120,
                    colors = {
                        { 0.92, 0.96, 1.0, 0.95 },
                        { 0.72, 0.84, 1.0, 0.45 },
                    },
                },
                configure = function(ps)
                    ps:setDirection(90)
                    ps:setGravity(8, 14)
                end,
            },
        }
        local sheet = lurek.image.newImageData(522, 140)
        sheet:fill(8, 10, 16, 255)

        for i, item in ipairs(archetypes) do
            local ps = lurek.particle.newSystem(item.config)
            ps:setPosition(item.x, item.y)
            item.configure(ps)
            ps:emit(item.emit)
            warm_particle_system(ps, item.frames, item.dt)
            local panel = ps:drawToImage(120, 120)
            local x = 10 + (i - 1) * 128
            paste(sheet, panel, x, 10)
            draw_border(sheet, x, 10, 120, 120, item.border[1], item.border[2], item.border[3])
            lurek.particle.release(ps)
        end

        save_png(sheet, OUT .. "particle_archetype_showcase.png")
    end)

    -- Does: Emits a deterministic burst and records twelve owner-rendered frames while gravity and lifetime fade the particles.
    -- Shows: The GIF makes the emitter lifecycle visible: dense spawn, outward velocity, gravity drift, and particle fade-out over time.
    -- Artifact: tests/artifacts/current/particle/particle_velocity_burst.gif
    -- Why: This is meaningful particle evidence because LParticleSystem:emit, LParticleSystem:update, gravity, speed, spread, size, color, and alpha keyframes all affect the pixels.
    it("GIF: velocity burst lifecycle", function()
        local ps = lurek.particle.newSystem({
            seed = 2101,
            maxParticles = 260,
            emissionRate = 0,
            shape = "circle",
            lifetimeMin = 0.9,
            lifetimeMax = 1.4,
            sizeMin = 3,
            sizeMax = 8,
            speedMin = 55,
            speedMax = 155,
            spread = 360,
            colors = {
                { 1.0, 0.88, 0.22, 1.0 },
                { 1.0, 0.30, 0.10, 0.65 },
                { 0.25, 0.18, 0.12, 0.0 },
            },
            alphas = { 1.0, 0.70, 0.0 },
        })
        ps:setPosition(128, 132)
        ps:setGravity(0, 72)
        ps:start()
        ps:emit(180)

        local frames = {}
        for i = 1, 12 do
            ps:update(0.075)
            frames[i] = ps:drawToImage(256, 180)
        end

        save_gif(frames, OUT .. "particle_velocity_burst.gif", { delayMs = 85, speed = 10 })
        lurek.particle.release(ps)
    end)

    -- Does: Runs one puff emitter with a central attractor and records the particle field while the attractor pulls particles inward.
    -- Shows: The GIF should reveal convergence toward the attractor point, not just a static cloud.
    -- Artifact: tests/artifacts/current/particle/particle_attractor_field.gif
    -- Why: This proves attractor behavior because every frame is the direct output of LParticleSystem:addAttractor, emit, update, and drawToImage.
    it("GIF: attractor field convergence", function()
        local ps = lurek.particle.newSystem(Fixture.scenes.attractor)
        ps:setPosition(128, 96)
        ps:addAttractor(128, 96, 900, 220)
        ps:start()
        ps:emit(180)

        local frames = {}
        for i = 1, 14 do
            ps:update(0.065)
            frames[i] = ps:drawToImage(256, 180)
        end

        save_gif(frames, OUT .. "particle_attractor_field.gif", { delayMs = 80, speed = 10 })
        lurek.particle.release(ps)
    end)

    -- Does: Pushes a moving point through LTrail, then keeps updating after input stops so old samples expire.
    -- Shows: The GIF makes trail behavior legible as a growing ribbon that tapers and disappears with lifetime.
    -- Artifact: tests/artifacts/current/particle/particle_trail_ribbon_decay.gif
    -- Why: This is owned by lurek.particle.newTrail, LTrail:pushPoint, LTrail:update, and LTrail:drawToImage; GIF encoding is only the container.
    it("GIF: trail ribbon growth and decay", function()
        local trail = lurek.particle.newTrail(0.75, 12.0)
        trail:setWidth(14, 1)
        trail:setHeadColor(1.0, 0.86, 0.24, 1.0)
        trail:setTailColor(0.10, 0.42, 1.0, 0.0)

        local frames = {}
        local points = Fixture.trail_points(18, 256, 180)
        for i = 1, 24 do
            if i <= #points then
                trail:pushPoint(points[i].x, points[i].y)
            end
            trail:update(0.055)
            frames[i] = trail:drawToImage(256, 180)
        end

        save_gif(frames, OUT .. "particle_trail_ribbon_decay.gif", { delayMs = 65, speed = 10 })
    end)

    -- Does: Composites a live particle system onto an existing image using both over-image and in-place paint APIs.
    -- Shows: The artifact distinguishes background, copied overlay particles, and in-place painted particles on the same target.
    -- Artifact: tests/artifacts/current/particle/particle_paint_composite.png
    -- Why: This proves the particle compositing APIs are real particle render paths rather than isolated image drawing helpers.
    it("PNG: particle paint composite", function()
        local bg = lurek.image.newImageData(220, 140)
        bg:fill(16, 20, 28, 255)
        bg:drawRect(20, 24, 180, 92, 32, 42, 58, 255)
        bg:drawRect(28, 32, 164, 76, 18, 24, 34, 255)

        local ps = lurek.particle.newSystem({
            seed = 3110,
            maxParticles = 140,
            emissionRate = 80,
            shape = "circle",
            lifetimeMin = 0.7,
            lifetimeMax = 1.2,
            sizeMin = 3,
            sizeMax = 7,
            speedMin = 20,
            speedMax = 68,
            spread = 90,
            colors = {
                { 1.0, 0.92, 0.32, 1.0 },
                { 1.0, 0.28, 0.08, 0.75 },
                { 0.18, 0.10, 0.05, 0.0 },
            },
        })
        ps:setPosition(110, 96)
        ps:setDirection(-90)
        ps:setGravity(0, -18)
        ps:emit(100)
        warm_particle_system(ps, 12, 0.045)
        local composite = ps:drawOverImage(bg)
        ps:paintOnto(composite)

        save_png(composite, OUT .. "particle_paint_composite.png")
        lurek.particle.release(ps)
    end)

    -- Does: Converts measured live particle counts from a deterministic emitter into the module lifecycle debug image.
    -- Shows: The bars expose spawn, saturation, and decay as a compact count-over-time artifact.
    -- Artifact: tests/artifacts/current/particle/particle_lifecycle_chart.png
    -- Why: The counts are sampled from LParticleSystem:update/getCount and rendered by lurek.particle.drawLifecycleToImage, so the chart explains particle pool behavior rather than generic charting.
    it("PNG: lifecycle count chart", function()
        local ps = lurek.particle.newSystem({
            seed = 2107,
            maxParticles = 80,
            emissionRate = 70,
            lifetimeMin = 0.45,
            lifetimeMax = 0.75,
            speedMin = 25,
            speedMax = 90,
            spread = 180,
            shape = "circle",
        })
        ps:setPosition(80, 90)
        ps:start()

        local snapshots = {}
        for i = 1, 14 do
            if i == 1 then
                ps:emit(24)
            end
            ps:update(0.10)
            snapshots[i] = { i - 1, ps:getCount() }
        end

        local img = lurek.particle.drawLifecycleToImage(snapshots, 80, 280, 110)
        save_png(img, OUT .. "particle_lifecycle_chart.png")
        lurek.particle.release(ps)
    end)

    -- Does: Compares none, uniform, ellipse, and custom emission areas from deterministic particle systems.
    -- Shows: The PNG makes spawn geometry visible as different particle distributions, not a generic dot cloud.
    -- Artifact: tests/artifacts/current/particle/particle_emission_area_shapes.png
    -- Why: This is particle evidence because each panel comes from LParticleSystem:setEmissionArea or setCustomEmissionShape plus emit/update/drawToImage.
    it("PNG: emission area shape comparison", function()
        local sheet = lurek.image.newImageData(520, 145)
        sheet:fill(8, 10, 16, 255)
        local specs = {
            { mode = "none", border = { 255, 180, 70 } },
            { mode = "uniform", border = { 90, 170, 255 } },
            { mode = "ellipse", border = { 190, 120, 255 } },
            { mode = "custom", border = { 90, 230, 150 } },
        }
        for i, spec in ipairs(specs) do
            local ps = lurek.particle.newSystem({
                seed = 5200 + i,
                maxParticles = 140,
                emissionRate = 0,
                shape = "circle",
                lifetimeMin = 1.2,
                lifetimeMax = 1.8,
                sizeMin = 2,
                sizeMax = 4,
                speedMin = 5,
                speedMax = 18,
                spread = 360,
                colors = {
                    { spec.border[1] / 255, spec.border[2] / 255, spec.border[3] / 255, 0.95 },
                    { spec.border[1] / 255, spec.border[2] / 255, spec.border[3] / 255, 0.20 },
                },
            })
            ps:setPosition(64, 68)
            if spec.mode == "uniform" then
                ps:setEmissionArea("uniform", 86, 52)
            elseif spec.mode == "ellipse" then
                ps:setEmissionArea("ellipse", 88, 54)
            elseif spec.mode == "custom" then
                local k = 0
                ps:setCustomEmissionShape(function()
                    k = k + 1
                    local a = k * 0.62
                    return math.cos(a) * 36, math.sin(a) * 18
                end)
            else
                ps:setEmissionArea("none", 0, 0)
            end
            ps:emit(120)
            warm_particle_system(ps, 10, 0.04)
            local panel = panel_from_system(ps, 120, 120, spec.border)
            paste(sheet, panel, 10 + (i - 1) * 128, 12)
            lurek.particle.release(ps)
        end
        save_png(sheet, OUT .. "particle_emission_area_shapes.png")
    end)

    -- Does: Emits high-speed particles inside configured bounds and records the bounce field over time.
    -- Shows: The GIF demonstrates particle collision bounds and restitution as particles stay inside the box instead of leaving the frame.
    -- Artifact: tests/artifacts/current/particle/particle_bounds_bounce_box.gif
    -- Why: This belongs to particle because the motion is controlled by LParticleSystem:setBounds, speed, spread, gravity, update, and drawToImage.
    it("GIF: bounds bounce box", function()
        local ps = lurek.particle.newSystem({
            seed = 5301,
            maxParticles = 180,
            emissionRate = 0,
            shape = "circle",
            lifetimeMin = 2.0,
            lifetimeMax = 2.5,
            sizeMin = 3,
            sizeMax = 5,
            speedMin = 80,
            speedMax = 155,
            spread = 360,
            colors = {
                { 0.35, 0.70, 1.0, 1.0 },
                { 0.95, 0.45, 0.18, 0.4 },
            },
        })
        ps:setPosition(128, 86)
        ps:setBounds(20, 236, 20, 156, 0.92)
        ps:emit(130)
        ps:start()
        local frames = {}
        for i = 1, 16 do
            ps:update(0.06)
            local img = ps:drawToImage(256, 176)
            draw_border(img, 20, 20, 216, 136, 120, 190, 255)
            frames[i] = img
        end
        save_gif(frames, OUT .. "particle_bounds_bounce_box.gif", { delayMs = 75, speed = 10 })
        lurek.particle.release(ps)
    end)

    -- Does: Configures a short-lived parent burst with a child sub-emitter and records the death burst phase.
    -- Shows: The GIF makes parent-to-child emission visible as particles bloom again after the first particles expire.
    -- Artifact: tests/artifacts/current/particle/particle_subemitter_death_burst.gif
    -- Why: This is particle-specific evidence for LParticleSystem:addSubEmitter plus lifetime/update/render behavior.
    it("GIF: sub-emitter death burst", function()
        local ps = lurek.particle.newSystem({
            seed = 5401,
            maxParticles = 260,
            emissionRate = 0,
            shape = "shrapnel",
            lifetimeMin = 0.22,
            lifetimeMax = 0.38,
            sizeMin = 3,
            sizeMax = 6,
            speedMin = 60,
            speedMax = 120,
            spread = 360,
            colors = {
                { 1.0, 0.86, 0.20, 1.0 },
                { 1.0, 0.28, 0.08, 0.25 },
            },
        })
        ps:addSubEmitter({
            seed = 5402,
            maxParticles = 180,
            emissionRate = 0,
            shape = "circle",
            lifetimeMin = 0.6,
            lifetimeMax = 0.9,
            sizeMin = 2,
            sizeMax = 4,
            speedMin = 20,
            speedMax = 70,
            spread = 360,
            colors = {
                { 0.35, 0.75, 1.0, 0.85 },
                { 0.05, 0.12, 0.30, 0.0 },
            },
        }, 4)
        ps:setPosition(128, 90)
        ps:emit(70)
        ps:start()
        local frames = {}
        for i = 1, 18 do
            ps:update(0.055)
            frames[i] = ps:drawToImage(256, 180)
        end
        save_gif(frames, OUT .. "particle_subemitter_death_burst.gif", { delayMs = 70, speed = 10 })
        lurek.particle.release(ps)
    end)

    -- Does: Renders particle shape, size-keyframe, color-keyframe, and flipbook configuration variations as a visual contact sheet.
    -- Shows: The PNG demonstrates particle render vocabulary and lifetime styling controls.
    -- Artifact: tests/artifacts/current/particle/particle_shape_size_keyframes.png
    -- Why: The panels are generated from LParticleSystem:setShape, setSizes, setColors, setFlipbook, emit, update, and drawToImage.
    it("PNG: shape size color keyframes", function()
        local sheet = lurek.image.newImageData(520, 145)
        sheet:fill(8, 10, 16, 255)
        local specs = {
            { shape = "circle", sizes = { 9, 4, 1 }, color = { 255, 180, 60 }, flip = false },
            { shape = "ray", sizes = { 4, 9, 2 }, color = { 90, 170, 255 }, flip = true },
            { shape = "puff", sizes = { 12, 8, 2 }, color = { 170, 180, 190 }, flip = false },
            { shape = "shrapnel", sizes = { 7, 3, 1 }, color = { 255, 90, 130 }, flip = true },
        }
        for i, spec in ipairs(specs) do
            local ps = lurek.particle.newSystem({
                seed = 5500 + i,
                maxParticles = 120,
                emissionRate = 0,
                lifetimeMin = 0.9,
                lifetimeMax = 1.4,
                speedMin = 25,
                speedMax = 90,
                spread = 360,
            })
            ps:setPosition(60, 70)
            ps:setShape(spec.shape)
            ps:setSizes(spec.sizes[1], spec.sizes[2], spec.sizes[3])
            ps:setColors({ spec.color[1] / 255, spec.color[2] / 255, spec.color[3] / 255, 1.0 }, { 0.05, 0.05, 0.10, 0.0 })
            if spec.flip then
                ps:setFlipbook(4, 2, 12)
            end
            ps:emit(95)
            warm_particle_system(ps, 12, 0.05)
            local panel = panel_from_system(ps, 120, 120, spec.color)
            paste(sheet, panel, 10 + (i - 1) * 128, 12)
            lurek.particle.release(ps)
        end
        save_png(sheet, OUT .. "particle_shape_size_keyframes.png")
    end)

    -- Does: Records one emitter through active, paused, resumed, and stopped phases while drawing live particles and count meters.
    -- Shows: The GIF makes runtime emitter state controls visible as emission freezes, resumes, then decays.
    -- Artifact: tests/artifacts/current/particle/particle_control_state_timeline.gif
    -- Why: This is particle evidence for start, pause, resume, stop, update, getCount, and drawToImage state transitions.
    it("GIF: emitter control state timeline", function()
        local ps = lurek.particle.newSystem({
            seed = 5601,
            maxParticles = 180,
            emissionRate = 100,
            shape = "circle",
            lifetimeMin = 0.8,
            lifetimeMax = 1.2,
            sizeMin = 2,
            sizeMax = 5,
            speedMin = 25,
            speedMax = 80,
            spread = 170,
            colors = {
                { 0.95, 0.72, 0.20, 1.0 },
                { 0.25, 0.55, 1.0, 0.0 },
            },
        })
        ps:setPosition(128, 92)
        ps:start()
        local frames = {}
        for i = 1, 20 do
            if i == 7 then
                ps:pause()
            elseif i == 11 then
                ps:resume()
            elseif i == 16 then
                ps:stop()
            end
            ps:update(0.07)
            local img = ps:drawToImage(256, 176)
            local count = ps:getCount()
            draw_count_meter(img, 18, 154, 220, 8, count, 180, 255, 190, 80)
            if ps:isPaused() then
                img:drawRect(18, 18, 32, 18, 255, 200, 70, 220)
            elseif ps:isStopped() then
                img:drawRect(18, 18, 32, 18, 230, 70, 80, 220)
            else
                img:drawRect(18, 18, 32, 18, 90, 220, 140, 220)
            end
            frames[i] = img
        end
        save_gif(frames, OUT .. "particle_control_state_timeline.gif", { delayMs = 70, speed = 10 })
        lurek.particle.release(ps)
    end)

    -- Does: Binds particle-target shaders to particle systems and emits three particle-specific visual artifacts.
    -- Shows: Dissolve, glow, and trail-tint use cases are drawn as particle behavior snapshots tied to LParticleSystem:setShader.
    -- Artifact: tests/artifacts/current/particle/particle_shader_visual_01_dissolve.png, tests/artifacts/current/particle/particle_shader_visual_02_glow.png, tests/artifacts/current/particle/particle_shader_visual_03_trail_tint.png
    -- Why: Particle shaders are render-time visual modifiers, so evidence should show particle shapes, aging, glow, and trail semantics instead of unrelated UI.
    it("PNG: shader-backed particle visual variants", function()
        dofile("tests/lua/fixtures/shader_visual_helpers.lua")
        local ShaderEvidence = _G.ShaderEvidence
        ShaderEvidence.emit("particle", {
            { target = "particle", slug = "dissolve" },
            { target = "particle", slug = "glow" },
            { target = "particle", slug = "trail_tint" },
        }, OUT)
    end)
end)

test_summary()
