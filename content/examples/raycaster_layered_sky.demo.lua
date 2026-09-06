-- Focused demo: three animated sky layers rendered as elevated ceiling tiles.
-- This file is intentionally short and has no --@api: markers; the generated
-- raycaster.lua file owns exhaustive API coverage.

local map = lurek.raycaster.new(12, 12)

local wall_data = lurek.image.newImageData(8, 4)
wall_data:fill(0, 0, 0, 0)
wall_data:drawRect(0, 0, 4, 4, 120, 130, 150, 255)
wall_data:drawRect(4, 0, 4, 4, 80, 90, 115, 255)
local wall_texture = lurek.render.newImage(wall_data)

local sky_data = lurek.image.newImageData(32, 16)
sky_data:fill(18, 48, 104, 255)
sky_data:drawRect(0, 0, 32, 5, 34, 82, 150, 255)
sky_data:drawRect(0, 11, 32, 5, 10, 28, 72, 255)
for _, star in ipairs({ { 4, 3 }, { 13, 6 }, { 24, 2 }, { 28, 10 } }) do
    sky_data:drawRect(star[1], star[2], 1, 1, 245, 245, 220, 255)
end
local sky_texture = lurek.render.newImage(sky_data)

local moon_data = lurek.image.newImageData(32, 16)
moon_data:fill(0, 0, 0, 0)
moon_data:drawRect(22, 3, 6, 6, 255, 226, 150, 235)
local moon_texture = lurek.render.newImage(moon_data)

local cloud_data = lurek.image.newImageData(32, 16)
cloud_data:fill(0, 0, 0, 0)
cloud_data:drawRect(2, 8, 11, 3, 215, 225, 240, 180)
cloud_data:drawRect(18, 5, 10, 3, 185, 200, 225, 160)
local cloud_texture = lurek.render.newImage(cloud_data)

for i = 0, 11 do
    map:setCell(i, 0, 1)
    map:setCell(i, 11, 1)
    map:setCell(0, i, 1)
    map:setCell(11, i, 1)
end
map:setWallMaterial(1, { texture = wall_texture })

local params = {
    px = 6.0,
    py = 6.0,
    angle = 0.0,
    fov = math.pi / 3,
    rays = 96,
    max_dist = 12.0,
    screen_w = 192,
    screen_h = 120,
    ambient = 0.45,
    floor_r = 0.20,
    floor_g = 0.18,
    floor_b = 0.16,
    ceiling_a = 0.0,
    background = {
        type = "layered_sky",
        top = { 0.04, 0.08, 0.18, 1.0 },
        bottom = { 0.18, 0.30, 0.52, 1.0 },
        layers = {
            -- Back layer: the night/blue-hour sky and stars.
            { texture = sky_texture, height = 2.0, parallax = 1.0, copies = 1 },
            -- Middle layer: a sun or moon that drifts independently.
            { texture = moon_texture, height = 2.1, blend = "add", velocity = { 0.002, 0.0 }, copies = 1 },
            -- Front layer: set copies to 0, 1, or 3 for clear, partial, or heavy cloud cover.
            { texture = cloud_texture, height = 2.2, parallax = 0.8, velocity = { 0.008, 0.0 }, copies = 3 },
        },
    },
}

local function render_at(time_seconds, output_path)
    params.time_seconds = time_seconds
    map:buildScene(params, {}, {}, { [1] = wall_texture })
    local frame = lurek.raycaster.drawLastScene(params.screen_w, params.screen_h)
    lurek.image.savePNG(frame, output_path)
    return frame
end

local first = render_at(0.0, "save/raycaster_layered_sky_t0.png")
local second = render_at(2.0, "save/raycaster_layered_sky_t2.png")
lurek.log.info(string.format(
    "layered sky: %dx%d rendered at t=0 and t=2 (center red %d -> %d)",
    first:getWidth(), first:getHeight(), first:getPixel(96, 60), second:getPixel(96, 60)
))
