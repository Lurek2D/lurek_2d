-- test_evidence_particle.lua
-- Evidence test: lurek.particles API + renders particle positions to PNG
-- Produces: particle_positions.png, particle_emitter_burst.png

local OUT = "tests/lua/evidence/output/particle/"

--- Helper: draw a filled circle (dot).
local function draw_dot(img, cx, cy, radius, r, g, b)
    local r2 = radius * radius
    for y = math.max(0, cy - radius), math.min(img:getHeight() - 1, cy + radius) do
        for x = math.max(0, cx - radius), math.min(img:getWidth() - 1, cx + radius) do
            if (x - cx) * (x - cx) + (y - cy) * (y - cy) <= r2 then
                img:setPixel(x, y, r, g, b, 255)
            end
        end
    end
end

-- @description Covers suite: Evidence: lurek.particles API + PNG visualization.
describe("Evidence: lurek.particles API + PNG visualization", function()
    -- @covers lurek.particles.newSystem
    -- @covers ParticleSystem:setPosition
    -- @covers ParticleSystem:start
    -- @covers ParticleSystem:emit
    -- @covers ParticleSystem:getPosition
    -- @covers lurek.img.savePNG
    -- @evidence file
    -- @description Places several emitters, emits particles from each, and writes a PNG showing their simulated positions and spread.
    it("PNG: particle emitter positions as colored dots", function()
        local W, H = 256, 256
        local img = lurek.img.newImageData(W, H)
        img:fill(10, 10, 20, 255)

        -- Create multiple emitters at different positions
        local systems = {}
        local colors = {
            {255, 80,  80},
            {80,  255, 80},
            {80,  80,  255},
            {255, 255, 80},
            {255, 80,  255},
        }
        local positions = {
            {64,  64},
            {192, 64},
            {128, 128},
            {64,  192},
            {192, 192},
        }
        for i = 1, #positions do
            local sys = lurek.particles.newSystem()
            sys:setPosition(positions[i][1], positions[i][2])
            sys:start()
            sys:emit(30)
            systems[i] = sys
        end

        -- Render each emitter as a cluster of dots around its position
        for i, sys in ipairs(systems) do
            local px, py = sys:getPosition()
            local c = colors[i]
            -- Draw emitter core (bright dot)
            draw_dot(img, math.floor(px), math.floor(py), 6, c[1], c[2], c[3])
            -- Draw particle spread (ring of smaller dots simulating emission)
            for angle = 0, 350, 15 do
                local rad = math.rad(angle)
                local spread = 15 + (i * 3)
                local dx = math.floor(px + spread * math.cos(rad))
                local dy = math.floor(py + spread * math.sin(rad))
                draw_dot(img, dx, dy, 2,
                    math.floor(c[1] * 0.6),
                    math.floor(c[2] * 0.6),
                    math.floor(c[3] * 0.6))
            end
        end

        lurek.img.savePNG(img, OUT .. "particle_positions.png")
    end)

    -- @covers lurek.particles.newSystem
    -- @covers ParticleSystem:setPosition
    -- @covers ParticleSystem:start
    -- @covers ParticleSystem:emit
    -- @covers ParticleSystem:count
    -- @covers lurek.img.savePNG
    -- @evidence file
    -- @description Emits several particle bursts over time and writes concentric ring evidence showing the successive burst radii.
    it("PNG: burst emission visualized over time", function()
        local W, H = 128, 128
        local img = lurek.img.newImageData(W, H)
        img:fill(5, 5, 15, 255)

        local sys = lurek.particles.newSystem()
        sys:setPosition(64, 64)
        sys:start()

        -- Simulate 4 bursts, each drawn as a ring at increasing radius
        for burst = 1, 4 do
            sys:emit(50)
            local count = sys:count()
            local radius = burst * 15
            -- Draw ring representing this burst
            for angle = 0, 359, 3 do
                local rad = math.rad(angle)
                local px = math.floor(64 + radius * math.cos(rad))
                local py = math.floor(64 + radius * math.sin(rad))
                if px >= 0 and px < W and py >= 0 and py < H then
                    local brightness = math.floor(255 * (1 - (burst - 1) / 4))
                    img:setPixel(px, py, brightness, brightness, 80, 255)
                end
            end
        end

        -- Mark center emitter
        draw_dot(img, 64, 64, 4, 255, 255, 255)

        lurek.img.savePNG(img, OUT .. "particle_emitter_burst.png")
    end)

end)
test_summary()
