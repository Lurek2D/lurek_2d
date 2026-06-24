local M = {
    id = "particle",
    title = "Particle Designer",
    summary = "Emitter sandbox",
    workspace = "preview",
    actions = {
        { id = "preset-fire", label = "Fire", w = 72 },
        { id = "preset-sparks", label = "Sparks", w = 86 },
        { id = "restart", label = "Restart", w = 92 },
        { id = "export-toml", label = "Export TOML", w = 118 },
    },
}

local function model(ctx)
    local state = ctx.editor_state.particle
    if not state then
        state = {
            emission_rate = 48,
            lifetime_min = 0.25,
            lifetime_max = 0.95,
            speed_min = 58,
            speed_max = 180,
            spread = 0.72,
            seed = 42,
            elapsed = 0,
        }
        ctx.editor_state.particle = state
    end
    return state
end

local function pseudo(seed, i)
    local v = math.sin(seed * 12.9898 + i * 78.233) * 43758.5453
    return v - math.floor(v)
end

function M.update(ctx, dt)
    local s = model(ctx)
    s.elapsed = s.elapsed + dt
end

function M.draw(ctx, r, ui)
    local s = model(ctx)
    ui.text("Particle Designer", r.x + 24, r.y + 20, ui.color.text)
    ui.text("Deterministic emitter preview. Output target: particles/*.toml plus Lua loader snippet.", r.x + 24, r.y + 46, ui.color.muted)

    local px, py, pw, ph = r.x + 28, r.y + 88, r.w - 56, r.h - 132
    ui.rect(px, py, pw, ph, { 0.018, 0.021, 0.027, 1 })
    ui.rect_line(px, py, pw, ph, ui.color.line)
    ui.line(px + pw * 0.5, py + 24, px + pw * 0.5, py + ph - 24, { 0.12, 0.16, 0.19, 1 })
    ui.line(px + 24, py + ph * 0.68, px + pw - 24, py + ph * 0.68, { 0.12, 0.16, 0.19, 1 })

    local cx, cy = px + pw * 0.5, py + ph * 0.68
    for i = 1, 96 do
        local life = pseudo(s.seed, i)
        local angle = -math.pi * 0.5 + (pseudo(s.seed + 7, i) - 0.5) * s.spread * 2
        local speed = s.speed_min + pseudo(s.seed + 19, i) * (s.speed_max - s.speed_min)
        local age = (s.elapsed * 0.7 + life) % 1
        local x = cx + math.cos(angle) * speed * age * 1.1
        local y = cy + math.sin(angle) * speed * age * 1.1 + age * age * 80
        local size = math.max(2, 8 * (1 - age))
        local warm = pseudo(s.seed + 31, i)
        lurek.render.setColor(1.0, 0.42 + warm * 0.32, 0.12, 0.85 * (1 - age))
        lurek.render.circle("fill", x, y, size)
    end

    ui.text("emission_rate=" .. s.emission_rate .. "  speed=" .. s.speed_min .. ".." .. s.speed_max .. "  seed=" .. s.seed, px + 18, py + ph - 28, ui.color.muted)
end

function M.inspect(ctx)
    local s = model(ctx)
    return {
        { label = "Native API", value = "lurek.particle" },
        { label = "Output", value = "fire.particle.toml" },
        { label = "Emission", value = tostring(s.emission_rate) .. "/s" },
        { label = "Lifetime", value = s.lifetime_min .. ".." .. s.lifetime_max },
        { label = "Speed", value = s.speed_min .. ".." .. s.speed_max },
        { label = "Spread", value = tostring(s.spread) },
        { label = "Seed", value = tostring(s.seed) },
    }
end

function M.export(ctx)
    local s = model(ctx)
    return string.format([[# fire.particle.toml
seed = %d
max_particles = 192
emission_rate = %.1f
lifetime_min = %.2f
lifetime_max = %.2f
speed_min = %.1f
speed_max = %.1f
spread = %.2f

-- Lua usage:
local fire = lurek.particle.fromTOML("particles/fire.particle.toml")]], s.seed, s.emission_rate, s.lifetime_min, s.lifetime_max, s.speed_min, s.speed_max, s.spread)
end

return M

