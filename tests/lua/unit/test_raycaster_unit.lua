-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_raycaster_core_unit.lua
do
-- tests/lua/unit/test_raycaster_core_unit.lua
-- Canonical unit coverage for lurek.raycaster and related userdata APIs.

local TEXTURE_PATH = "content/examples/assets/images/sample_texture.png"
local MODEL_PATH = "content/examples/assets/models/sample_tank.obj"

local function load_texture()
    return lurek.render.newImage(TEXTURE_PATH)
end

local function load_masked_texture()
    local img = lurek.image.newImageData(8, 8)
    img:fill(0, 0, 0, 0)
    for y = 0, 7 do
        for x = 2, 5 do
            img:setPixel(x, y, 255, 255, 255, 255)
        end
    end
    return lurek.render.newImage(img)
end

local function load_model()
    return lurek.render.loadModel(MODEL_PATH)
end

local function make_map(w, h)
    local map = lurek.raycaster.new(w, h)
    for i = 0, w - 1 do
        map:setCell(i, 0, 1)
        map:setCell(i, h - 1, 1)
    end
    for i = 0, h - 1 do
        map:setCell(0, i, 1)
        map:setCell(w - 1, i, 1)
    end
    return map
end

local function scene_params()
    return {
        px = 8.0,
        py = 8.0,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 16.0,
        screen_w = 160,
        screen_h = 100,
    }
end

local function make_scene_adapter_fixture(x, y, angle)
    local world = lurek.physics.newWorld(0, 0)
    local body = world:newBody(x or 10.0, y or 8.0, "dynamic")
    if angle ~= nil then
        body:setAngle(angle)
    end
    local adapter = lurek.raycaster.newSceneAdapter()
    return world, body, adapter
end

local function multilevel_params()
    return {
        px = 0.5,
        py = 1.5,
        angle = 0.0,
        fov = math.pi / 3,
        rays = 32,
        max_dist = 8.0,
        screen_w = 160,
        screen_h = 100,
        active_level = 1,
    }
end

local function multilevel_levels()
    return {
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 0.0,
            ceiling_height = 1.0,
        },
        {
            width = 4,
            height = 4,
            cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            },
            floor_offset = 1.0,
            ceiling_height = 2.0,
        },
    }
end

local function make_persistent_multilevel_grid()
    local grid = lurek.raycaster.newMultiLevelGrid(multilevel_levels())
    grid:setActiveLevel(1)
    return grid
end

-- @describe lurek.raycaster functions
describe("lurek.raycaster functions", function()
    -- @covers lurek.raycaster.applyLitShade
    it("applyLitShade scales rgb channels by the base shade", function()
        local r, g, b = lurek.raycaster.applyLitShade(0.5, 1.0, 0.8, 0.6)
        expect_near(0.5, r, 1e-5)
        expect_near(0.4, g, 1e-5)
        expect_near(0.3, b, 1e-5)
    end)

    -- @covers lurek.raycaster.distanceShade
    it("distanceShade darkens as distance approaches maxDistance", function()
        local near = lurek.raycaster.distanceShade(0, 10)
        local mid = lurek.raycaster.distanceShade(5, 10)
        local far = lurek.raycaster.distanceShade(9, 10)
        expect_true(near >= mid)
        expect_true(mid >= far)
    end)

    -- @covers lurek.raycaster.new
    it("new creates a raycaster map with requested dimensions", function()
        local map = lurek.raycaster.new(16, 12)
        expect_equal(16, map:width())
        expect_equal(12, map:height())
    end)

    -- @covers lurek.raycaster.newDoorManager
    it("newDoorManager returns an empty door manager", function()
        local doors = lurek.raycaster.newDoorManager()
        expect_equal(0, doors:count())
    end)

    -- @covers lurek.raycaster.newHeightMap
    it("newHeightMap returns a height map with default floor and ceiling", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        expect_near(0.0, hm:floorAt(0, 0), 1e-5)
        expect_near(1.0, hm:ceilingAt(0, 0), 1e-5)
    end)

    -- @covers lurek.raycaster.newMap
    it("newMap is an alias for raycaster construction", function()
        local map = lurek.raycaster.newMap(8, 6)
        expect_equal(8, map:width())
        expect_equal(6, map:height())
    end)

    -- @covers lurek.raycaster.newPointLight
    it("newPointLight stores the configured light values", function()
        local light = lurek.raycaster.newPointLight(10.0, 20.0, 0.2, 0.4, 0.6, 5.0, 0.8, 1)
        local r, g, b = light:color()
        expect_near(10.0, light:x(), 1e-5)
        expect_near(20.0, light:y(), 1e-5)
        expect_near(0.2, r, 1e-5)
        expect_near(0.4, g, 1e-5)
        expect_near(0.6, b, 1e-5)
        expect_equal(1, light:level())
    end)

    -- @covers lurek.raycaster.newSpriteManager
    it("newSpriteManager returns an empty sprite manager", function()
        local sprites = lurek.raycaster.newSpriteManager()
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers lurek.raycaster.newSceneAdapter
    it("newSceneAdapter returns an empty adapter userdata", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        expect_equal("LSceneAdapter", adapter:type())
        local inputs = adapter:sceneInputs()
        expect_equal(0, #inputs.sprites)
        expect_equal(0, #inputs.lights)
        expect_equal(0, #inputs.models)
    end)

    -- @covers LSceneAdapter:sceneInputs
    it("sceneInputs snapshots sprite, light, and model inputs from a moved physics body", function()
        local _, body, adapter = make_scene_adapter_fixture(10.0, 8.0, math.pi / 2)
        adapter:bindBodySprite(body, load_texture(), {
            id = 41,
            level = 1,
            size = 1.5,
            offset_x = 0.5,
        })
        adapter:bindBodyLight(body, 4.0, {
            level = 1,
            intensity = 1.25,
            color = { 1.0, 0.5, 0.25 },
            offset_y = 0.5,
        })
        adapter:bindBodyModel(body, load_model(), {
            id = 84,
            level = 1,
            yaw_offset = 0.25,
            offset_x = 0.5,
            z = 0.2,
            scale = 0.3,
        })

        body:setPosition(12.0, 9.0)
        local inputs = adapter:sceneInputs()
        expect_type("table", inputs)
        expect_equal(1, #inputs.sprites)
        expect_equal(1, #inputs.lights)
        expect_equal(1, #inputs.models)

        local sprite = inputs.sprites[1]
        expect_equal(41, sprite.id)
        expect_equal(1, sprite.level)
        expect_near(12.0, sprite.x, 1e-5)
        expect_near(9.5, sprite.y, 1e-5)
        expect_type("number", sprite.texture)

        local light = inputs.lights[1]
        expect_equal(1, light.level)
        expect_near(11.5, light.x, 1e-5)
        expect_near(9.0, light.y, 1e-5)
        expect_near(1.25, light.intensity, 1e-5)
        expect_near(0.5, light.color[2], 1e-5)

        local model = inputs.models[1]
        expect_equal(84, model.id)
        expect_equal(1, model.level)
        expect_near(12.0, model.x, 1e-5)
        expect_near(9.5, model.y, 1e-5)
        expect_near(math.pi / 2 + 0.25, model.yaw, 1e-5)
        expect_near(0.2, model.z, 1e-5)
        expect_near(0.3, model.scale, 1e-5)
        expect_type("userdata", model.model)
    end)

    -- @covers lurek.raycaster.newMultiLevelGrid
    it("newMultiLevelGrid can clone stacked level tables into a persistent userdata", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        expect_equal(2, grid:levelCount())
        expect_equal("LMultiLevelGrid", grid:type())
    end)

    -- @covers lurek.raycaster.projectColumn
    it("projectColumn returns a positive projected height", function()
        local height = lurek.raycaster.projectColumn(5.0, math.pi / 3, 200)
        expect_type("number", height)
        expect_true(height > 0)
    end)

    -- @covers lurek.raycaster.buildMultiLevelScene
    it("buildMultiLevelScene accepts stacked levels with a ceiling opening", function()
        local wall = load_texture()
        local quad_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 0.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    floor_holes = { true, false, false, false },
                    floor_texture = wall,
                },
            },
            {},
            {},
            {}
        )
        expect_type("number", quad_count)
        expect_true(quad_count > 0)

        local persistent_grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_offset = 0.0,
                ceiling_height = 1.0,
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
                floor_holes = { true, false, false, false },
                floor_texture = wall,
            },
        })
        persistent_grid:setActiveLevel(1)
        local cached_quad_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 0.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            persistent_grid,
            {},
            {},
            {}
        )
        expect_true(cached_quad_count > 0)

        local feature_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 0.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 1, 0, 0 },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    wall_features = {
                        {
                            x = 1,
                            y = 0,
                            kind = "window",
                            sill_height = 0.25,
                            lintel_height = 0.8,
                            alpha = 0.4,
                        },
                    },
                },
            },
            {},
            {},
            { [1] = wall }
        )
        expect_type("number", feature_count)
        expect_true(feature_count > 0)

        local floor_tex = load_texture()
        local ceil_tex = load_texture()
        local pit_tex = load_texture()
        local surface_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 0.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    floor_texture = wall,
                    floor_cell_textures = {
                        { x = 0, y = 0, texture = floor_tex },
                    },
                    ceiling_cell_textures = {
                        { x = 0, y = 0, texture = ceil_tex },
                    },
                    lowered_floor_cells = {
                        {
                            x = 0,
                            y = 0,
                            texture = pit_tex,
                            depth = 0.35,
                            r = 0.8,
                            g = 0.7,
                            b = 0.6,
                            blocked = true,
                        },
                    },
                },
            },
            {},
            {},
            {}
        )
        expect_type("number", surface_count)
        expect_true(surface_count > 0)

        local sprites = lurek.raycaster.newSpriteManager()
        sprites:add(0.5, 0.5, wall, 0.9, 0)
        local upper = sprites:add(0.5, 0.5, wall, 0.9)
        sprites:setLevel(upper, 1)
        local managed_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 0.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 2,
                    height = 2,
                    cells = { 0, 0, 0, 0 },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                },
            },
            {},
            sprites,
            {}
        )
        expect_type("number", managed_count)
        expect_true(managed_count > 0)

        local model = load_model()
        local with_model_count = lurek.raycaster.buildMultiLevelScene(
            {
                px = 0.5,
                py = 1.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 48,
                max_dist = 10.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                },
            },
            {},
            {},
            {},
            {
                { model = model, x = 2.5, y = 1.5, level = 1, yaw = math.pi / 6, z = 0.2, scale = 0.22 },
            }
        )
        expect_true(with_model_count > managed_count)
    end)

    -- @covers lurek.raycaster.buildMultiLevelSceneFromAdapter
    it("buildMultiLevelSceneFromAdapter projects adapter-backed entities into stacked levels", function()
        local _, body, adapter = make_scene_adapter_fixture(2.5, 1.5)
        adapter:bindBodySprite(body, load_texture(), {
            id = 701,
            level = 1,
            size = 1.0,
        })
        adapter:bindBodyLight(body, 4.0, {
            level = 1,
            intensity = 1.0,
            color = { 1.0, 0.85, 0.6 },
        })
        local count = lurek.raycaster.buildMultiLevelSceneFromAdapter(
            multilevel_params(),
            multilevel_levels(),
            adapter,
            {}
        )
        expect_true(count > 0)
    end)

    -- @covers lurek.raycaster.pickScreenMultiLevelFromAdapter
    it("pickScreenMultiLevelFromAdapter resolves the owning stacked level and id", function()
        local _, body, adapter = make_scene_adapter_fixture(2.5, 1.5)
        adapter:bindBodySprite(body, load_texture(), {
            id = 701,
            level = 1,
            size = 1.0,
        })
        local hit = lurek.raycaster.pickScreenMultiLevelFromAdapter(
            80,
            50,
            multilevel_params(),
            multilevel_levels(),
            {},
            adapter
        )
        expect_not_nil(hit)
        expect_equal("sprite", hit.surface)
        expect_equal(1, hit.level)
        expect_equal(701, hit.id)
    end)

    -- @covers lurek.raycaster.getLastBuildStats
    it("getLastBuildStats reports lighting cache reuse for the most recent scene build", function()
        local map = make_map(16, 16)
        local wall = load_texture()
        for y = 1, 14 do
            for x = 1, 14 do
                map:setCeilingTextureCell(x, y, wall)
            end
        end

        local count = map:buildScene(scene_params(), {
            lurek.raycaster.newPointLight(8.0, 8.0, 1.0, 0.9, 0.8, 4.0, 1.25),
        }, {}, {
            [1] = wall,
        })
        expect_true(count > 0)

        local stats = lurek.raycaster.getLastBuildStats()
        expect_type("table", stats)
        expect_true(stats.lightingSamples > 0)
        expect_true(stats.lightingCacheMisses > 0)
        expect_equal(
            stats.lightingSamples,
            stats.lightingCacheHits + stats.lightingCacheMisses
        )
        expect_true(stats.lightingCacheHits > 0)
    end)

    -- @covers lurek.raycaster.pickScreenMultiLevel
    it("pickScreenMultiLevel resolves floor shafts and wall hits with level metadata", function()
        local wall = load_texture()
        local params = {
            px = 1.5,
            py = 1.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 8.0,
            screen_w = 160,
            screen_h = 100,
            active_level = 1,
            camera_height = 0.5,
        }

        local upper_floor_hit = lurek.raycaster.pickScreenMultiLevel(
            80,
            90,
            params,
            {
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    floor_texture = wall,
                },
            },
            {}
        )
        expect_equal(1, upper_floor_hit.level)
        expect_equal("floor", upper_floor_hit.surface)

        local shaft_hit = lurek.raycaster.pickScreenMultiLevel(
            80,
            90,
            params,
            {
                {
                    width = 8,
                    height = 8,
                    cells = {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                    ceiling_holes = {
                        false, false, false, false, false, false, false, false,
                        false, false, false, true, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                    },
                },
                {
                    width = 8,
                    height = 8,
                    cells = {
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                        0, 0, 0, 0, 0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    floor_holes = {
                        false, false, false, false, false, false, false, false,
                        false, false, false, true, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                        false, false, false, false, false, false, false, false,
                    },
                },
            },
            {}
        )
        expect_equal(0, shaft_hit.level)
        expect_equal("floor", shaft_hit.surface)

        local wall_hit = lurek.raycaster.pickScreenMultiLevel(
            80,
            50,
            {
                px = 1.5,
                py = 2.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
                camera_height = 0.5,
            },
            {
                {
                    width = 8,
                    height = 8,
                    cells = { 0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0 },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 8,
                    height = 8,
                    cells = { 0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 1, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0,
                              0, 0, 0, 0, 0, 0, 0, 0 },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                },
            },
            { [1] = wall }
        )
        expect_equal(1, wall_hit.level)
        expect_equal("wall", wall_hit.surface)
        expect_equal(4, wall_hit.x)
        expect_equal(2, wall_hit.y)
        expect_type("number", wall_hit.texture)

        local persistent_grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 8,
                height = 8,
                cells = { 0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0 },
            },
            {
                width = 8,
                height = 8,
                cells = { 0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 1, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        persistent_grid:setActiveLevel(1)
        local cached_wall_hit = lurek.raycaster.pickScreenMultiLevel(
            80,
            50,
            {
                px = 1.5,
                py = 2.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
                camera_height = 0.5,
            },
            persistent_grid,
            { [1] = wall }
        )
        expect_equal(1, cached_wall_hit.level)

        local sprite_hit = lurek.raycaster.pickScreenMultiLevel(
            80,
            50,
            {
                px = 0.5,
                py = 1.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 32,
                max_dist = 8.0,
                screen_w = 160,
                screen_h = 100,
                active_level = 1,
            },
            {
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 4,
                    height = 4,
                    cells = {
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                        0, 0, 0, 0,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                },
            },
            {},
            {
                { id = 7, x = 2.5, y = 1.5, level = 1, texture = load_texture(), size = 1.0 },
            }
        )
        expect_not_nil(sprite_hit)
        expect_equal("sprite", sprite_hit.surface)
        expect_equal(1, sprite_hit.level)
        expect_equal(7, sprite_hit.id)
        expect_equal(2, sprite_hit.x)
        expect_equal(1, sprite_hit.y)

        local feature_hit = lurek.raycaster.pickScreenMultiLevel(
            160,
            118,
            {
                px = 2.5,
                py = 5.5,
                angle = 0.0,
                fov = math.pi / 3,
                rays = 64,
                max_dist = 20.0,
                screen_w = 320,
                screen_h = 200,
                active_level = 1,
                camera_height = 0.5,
            },
            {
                {
                    width = 12,
                    height = 10,
                    cells = {
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    },
                    floor_offset = 0.0,
                    ceiling_height = 1.0,
                },
                {
                    width = 12,
                    height = 10,
                    cells = {
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    },
                    floor_offset = 1.0,
                    ceiling_height = 2.0,
                    wall_features = {
                        {
                            x = 6,
                            y = 5,
                            kind = "window",
                            sill_height = 0.3,
                            lintel_height = 0.75,
                            alpha = 0.35,
                        },
                    },
                },
            },
            { [1] = wall }
        )
        expect_not_nil(feature_hit)
        expect_equal(1, feature_hit.level)
        expect_equal(6, feature_hit.x)
        expect_equal("window", feature_hit.feature.kind)
        expect_equal("lower", feature_hit.feature.section)
    end)
end)

-- @describe LSceneAdapter methods
describe("LSceneAdapter methods", function()
    -- @covers LSceneAdapter:addSprite
    it("addSprite stores a static billboard entry", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addSprite(6.5, 4.0, load_texture(), {
            id = 91,
            level = 1,
            size = 1.25,
            angle = 0.3,
        })
        local sprite = adapter:sceneInputs().sprites[1]
        expect_equal(91, sprite.id)
        expect_equal(1, sprite.level)
        expect_near(6.5, sprite.x, 1e-5)
        expect_near(4.0, sprite.y, 1e-5)
        expect_near(1.25, sprite.size, 1e-5)
        expect_type("number", sprite.texture)
    end)

    -- @covers LSceneAdapter:addDirectionalSprite
    it("addDirectionalSprite stores directional texture handles and facing angle", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        local front = load_texture()
        local right = load_texture()
        local back = load_texture()
        local left = load_texture()
        adapter:addDirectionalSprite(6.0, 5.0, front, right, back, left, {
            id = 92,
            level = 2,
            size = 1.1,
            angle = math.pi / 4,
        })
        local sprite = adapter:sceneInputs().sprites[1]
        expect_equal(92, sprite.id)
        expect_equal(2, sprite.level)
        expect_type("number", sprite.front_texture)
        expect_type("number", sprite.right_texture)
        expect_type("number", sprite.back_texture)
        expect_type("number", sprite.left_texture)
        expect_near(math.pi / 4, sprite.angle, 1e-5)
    end)

    -- @covers LSceneAdapter:bindBodySprite
    it("bindBodySprite follows a moved physics body", function()
        local _, body, adapter = make_scene_adapter_fixture(4.0, 3.0)
        adapter:bindBodySprite(body, load_texture(), {
            id = 93,
            offset_x = 0.5,
            size = 1.0,
        })
        body:setPosition(5.0, 3.5)
        local sprite = adapter:sceneInputs().sprites[1]
        expect_equal(93, sprite.id)
        expect_near(5.5, sprite.x, 1e-5)
        expect_near(3.5, sprite.y, 1e-5)
    end)

    -- @covers LSceneAdapter:bindBodyDirectionalSprite
    it("bindBodyDirectionalSprite resolves body angle into the directional snapshot", function()
        local _, body, adapter = make_scene_adapter_fixture(4.0, 3.0, math.pi / 2)
        adapter:bindBodyDirectionalSprite(
            body,
            load_texture(),
            load_texture(),
            load_texture(),
            load_texture(),
            {
                id = 94,
                offset_y = 0.5,
                angle_offset = 0.25,
            }
        )
        local sprite = adapter:sceneInputs().sprites[1]
        expect_equal(94, sprite.id)
        expect_near(3.5, sprite.x, 1e-5)
        expect_near(3.0, sprite.y, 1e-5)
        expect_near(math.pi / 2 + 0.25, sprite.angle, 1e-5)
    end)

    -- @covers LSceneAdapter:addLight
    it("addLight stores a static point light entry", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addLight(7.0, 2.5, 5.0, {
            intensity = 1.4,
            color = { 0.8, 0.7, 0.6 },
            level = 1,
        })
        local light = adapter:sceneInputs().lights[1]
        expect_equal(1, light.level)
        expect_near(7.0, light.x, 1e-5)
        expect_near(2.5, light.y, 1e-5)
        expect_near(5.0, light.radius, 1e-5)
        expect_near(1.4, light.intensity, 1e-5)
        expect_near(0.7, light.color[2], 1e-5)
    end)

    -- @covers LSceneAdapter:bindBodyLight
    it("bindBodyLight follows a moved physics body", function()
        local _, body, adapter = make_scene_adapter_fixture(3.0, 6.0)
        adapter:bindBodyLight(body, 3.5, {
            intensity = 0.9,
            offset_y = -0.25,
        })
        body:setPosition(4.0, 5.0)
        local light = adapter:sceneInputs().lights[1]
        expect_near(4.0, light.x, 1e-5)
        expect_near(4.75, light.y, 1e-5)
        expect_near(3.5, light.radius, 1e-5)
    end)

    -- @covers LSceneAdapter:addModel
    it("addModel stores a static OBJ instance entry", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addModel(load_model(), 6.5, 2.5, {
            id = 95,
            level = 1,
            yaw = 0.4,
            z = 0.2,
            scale = 0.3,
        })
        local model = adapter:sceneInputs().models[1]
        expect_equal(95, model.id)
        expect_equal(1, model.level)
        expect_near(6.5, model.x, 1e-5)
        expect_near(2.5, model.y, 1e-5)
        expect_near(0.4, model.yaw, 1e-5)
        expect_near(0.2, model.z, 1e-5)
        expect_near(0.3, model.scale, 1e-5)
        expect_type("userdata", model.model)
    end)

    -- @covers LSceneAdapter:bindBodyModel
    it("bindBodyModel follows a moved physics body", function()
        local _, body, adapter = make_scene_adapter_fixture(4.0, 4.0, 0.5)
        adapter:bindBodyModel(body, load_model(), {
            id = 96,
            offset_x = 0.5,
            yaw_offset = 0.2,
            z = 0.1,
            scale = 0.25,
        })
        body:setPosition(5.0, 4.0)
        local model = adapter:sceneInputs().models[1]
        expect_equal(96, model.id)
        expect_near(5.438791, model.x, 1e-5)
        expect_near(4.239713, model.y, 1e-5)
        expect_near(0.7, model.yaw, 1e-5)
    end)

    -- @covers LSceneAdapter:clear
    it("clear removes every tracked entry class at once", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addSprite(1.0, 1.0, load_texture())
        adapter:addLight(1.0, 1.0, 2.0)
        adapter:addModel(load_model(), 1.0, 1.0)
        adapter:clear()
        local inputs = adapter:sceneInputs()
        expect_equal(0, #inputs.sprites)
        expect_equal(0, #inputs.lights)
        expect_equal(0, #inputs.models)
    end)

    -- @covers LSceneAdapter:clearSprites
    it("clearSprites removes only sprite entries", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addSprite(1.0, 1.0, load_texture())
        adapter:addLight(1.0, 1.0, 2.0)
        adapter:clearSprites()
        local inputs = adapter:sceneInputs()
        expect_equal(0, #inputs.sprites)
        expect_equal(1, #inputs.lights)
    end)

    -- @covers LSceneAdapter:clearLights
    it("clearLights removes only light entries", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addSprite(1.0, 1.0, load_texture())
        adapter:addLight(1.0, 1.0, 2.0)
        adapter:clearLights()
        local inputs = adapter:sceneInputs()
        expect_equal(1, #inputs.sprites)
        expect_equal(0, #inputs.lights)
    end)

    -- @covers LSceneAdapter:clearModels
    it("clearModels removes only model entries", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        adapter:addModel(load_model(), 1.0, 1.0)
        adapter:addLight(1.0, 1.0, 2.0)
        adapter:clearModels()
        local inputs = adapter:sceneInputs()
        expect_equal(0, #inputs.models)
        expect_equal(1, #inputs.lights)
    end)

    -- @covers LSceneAdapter:type
    it("type returns the scene adapter userdata name", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        expect_equal("LSceneAdapter", adapter:type())
    end)

    -- @covers LSceneAdapter:typeOf
    it("typeOf accepts the scene adapter type name", function()
        local adapter = lurek.raycaster.newSceneAdapter()
        expect_true(adapter:typeOf("LSceneAdapter"))
        expect_true(adapter:typeOf("LObject"))
    end)
end)

-- @describe LMultiLevelGrid methods
describe("LMultiLevelGrid methods", function()
    -- @covers LMultiLevelGrid:addLevel
    it("addLevel appends a new level and returns its index", function()
        local grid = lurek.raycaster.newMultiLevelGrid()
        local index = grid:addLevel({
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
            floor_offset = 1.0,
            ceiling_height = 2.0,
        })
        expect_equal(0, index)
    end)

    -- @covers LMultiLevelGrid:levelCount
    it("levelCount reports the number of stored levels", function()
        local grid = lurek.raycaster.newMultiLevelGrid()
        grid:addLevel({
            width = 2,
            height = 2,
            cells = { 0, 0, 0, 0 },
        })
        expect_equal(1, grid:levelCount())
    end)

    -- @covers LMultiLevelGrid:setActiveLevel
    it("setActiveLevel updates the active slice used by the grid", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        grid:setActiveLevel(1)
    end)

    -- @covers LMultiLevelGrid:activeLevel
    it("activeLevel returns the selected slice index", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        grid:setActiveLevel(1)
        expect_equal(1, grid:activeLevel())
    end)

    -- @covers LMultiLevelGrid:getFloorOffset
    it("getFloorOffset returns the active-level floor offset", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
            { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 1.25, ceiling_height = 2.5 },
        })
        grid:setActiveLevel(1)
        expect_near(1.25, grid:getFloorOffset(), 1e-5)
    end)

    -- @covers LMultiLevelGrid:setFloorOffset
    it("setFloorOffset updates the active-level floor offset", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.0, ceiling_height = 1.0 },
        })
        grid:setFloorOffset(0.75)
        expect_near(0.75, grid:getFloorOffset(), 1e-5)
    end)

    -- @covers LMultiLevelGrid:getCeilingHeight
    it("getCeilingHeight returns the active-level ceiling height", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 2.25 },
        })
        expect_near(2.25, grid:getCeilingHeight(), 1e-5)
    end)

    -- @covers LMultiLevelGrid:setCeilingHeight
    it("setCeilingHeight clamps the ceiling above the active floor offset", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 }, floor_offset = 0.5, ceiling_height = 1.5 },
        })
        grid:setCeilingHeight(0.55)
        expect_near(0.6, grid:getCeilingHeight(), 1e-5)
    end)

    -- @covers LMultiLevelGrid:setCell
    it("setCell writes a wall value on the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setActiveLevel(1)
        grid:setCell(1, 0, 7)
        expect_equal(7, grid:getCell(1, 0))
    end)

    -- @covers LMultiLevelGrid:getCell
    it("getCell reads the active level wall value", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
            { width = 2, height = 2, cells = { 0, 5, 0, 0 } },
        })
        grid:setActiveLevel(1)
        expect_equal(5, grid:getCell(1, 0))
    end)

    -- @covers LMultiLevelGrid:setHalfWallCell
    it("setHalfWallCell stores a half-height feature on the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
        })
        grid:setHalfWallCell(0, 0, 0.5)
        local feature = grid:getWallFeatureCell(0, 0)
        expect_equal("half", feature.kind)
        expect_near(0.5, feature.height, 1e-5)
    end)

    -- @covers LMultiLevelGrid:setWindowCell
    it("setWindowCell stores a window descriptor on the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
        })
        grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
        local feature = grid:getWallFeatureCell(0, 0)
        expect_equal("window", feature.kind)
        expect_near(0.25, feature.sill_height, 1e-5)
        expect_near(0.8, feature.lintel_height, 1e-5)
        expect_near(0.4, feature.alpha, 1e-5)
    end)

    -- @covers LMultiLevelGrid:setDoorCell
    it("setDoorCell stores a door descriptor on the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
        })
        grid:setDoorCell(0, 0, "vertical", 0.6, 0.9)
        local feature = grid:getWallFeatureCell(0, 0)
        expect_equal("door", feature.kind)
        expect_equal("vertical", feature.direction)
        expect_near(0.6, feature.open_amount, 1e-5)
        expect_near(0.9, feature.alpha, 1e-5)
    end)

    -- @covers LMultiLevelGrid:clearWallFeatureCell
    it("clearWallFeatureCell removes an active-level wall feature override", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
        })
        grid:setWindowCell(0, 0, 0.25, 0.8, 0.4)
        grid:clearWallFeatureCell(0, 0)
        expect_nil(grid:getWallFeatureCell(0, 0))
    end)

    -- @covers LMultiLevelGrid:getWallFeatureCell
    it("getWallFeatureCell returns nil when no active-level feature is present", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 1, 0, 0, 0 } },
        })
        expect_nil(grid:getWallFeatureCell(1, 1))
    end)

    -- @covers LMultiLevelGrid:getFloorTexture
    it("getFloorTexture returns nil when the active level has no default floor texture", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        expect_nil(grid:getFloorTexture())
    end)

    -- @covers LMultiLevelGrid:setFloorTexture
    it("setFloorTexture stores and clears the active-level default floor texture", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setFloorTexture(load_texture())
        expect_type("number", grid:getFloorTexture())
        grid:setFloorTexture(nil)
        expect_nil(grid:getFloorTexture())
    end)

    -- @covers LMultiLevelGrid:getFloorTextureCell
    it("getFloorTextureCell returns nil when no active-level floor override is set", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        expect_nil(grid:getFloorTextureCell(1, 1))
    end)

    -- @covers LMultiLevelGrid:setFloorTextureCell
    it("setFloorTextureCell stores and clears active-level floor overrides", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setFloorTextureCell(1, 1, load_texture())
        expect_type("number", grid:getFloorTextureCell(1, 1))
        grid:setFloorTextureCell(1, 1, nil)
        expect_nil(grid:getFloorTextureCell(1, 1))
    end)

    -- @covers LMultiLevelGrid:getCeilingTexture
    it("getCeilingTexture returns nil when the active level has no default ceiling texture", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        expect_nil(grid:getCeilingTexture())
    end)

    -- @covers LMultiLevelGrid:setCeilingTexture
    it("setCeilingTexture stores and clears the active-level default ceiling texture", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setCeilingTexture(load_texture())
        expect_type("number", grid:getCeilingTexture())
        grid:setCeilingTexture(nil)
        expect_nil(grid:getCeilingTexture())
    end)

    -- @covers LMultiLevelGrid:getCeilingTextureCell
    it("getCeilingTextureCell returns nil when no active-level ceiling override is set", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        expect_nil(grid:getCeilingTextureCell(1, 1))
    end)

    -- @covers LMultiLevelGrid:setCeilingTextureCell
    it("setCeilingTextureCell stores and clears active-level ceiling overrides", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setCeilingTextureCell(1, 1, load_texture())
        expect_type("number", grid:getCeilingTextureCell(1, 1))
        grid:setCeilingTextureCell(1, 1, nil)
        expect_nil(grid:getCeilingTextureCell(1, 1))
    end)

    -- @covers LMultiLevelGrid:getLoweredFloorCell
    it("getLoweredFloorCell returns stored lowered-floor options on the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 4, height = 4, cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            } },
        })
        grid:setLoweredFloorCell(2, 2, {
            texture = load_texture(),
            depth = 0.35,
            blocked = false,
        })
        local cell = grid:getLoweredFloorCell(2, 2)
        expect_type("table", cell)
        expect_type("number", cell.texture)
        expect_equal(false, cell.blocked)
    end)

    -- @covers LMultiLevelGrid:setLoweredFloorCell
    it("setLoweredFloorCell stores and clears lowered-floor metadata on the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 4, height = 4, cells = {
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
                0, 0, 0, 0,
            } },
        })
        grid:setLoweredFloorCell(1, 1, {
            texture = load_texture(),
            depth = 0.3,
            blocked = true,
        })
        local cell = grid:getLoweredFloorCell(1, 1)
        expect_near(0.3, cell.depth, 1e-5)
        grid:setLoweredFloorCell(1, 1, nil)
        expect_nil(grid:getLoweredFloorCell(1, 1))
    end)

    -- @covers LMultiLevelGrid:setFloorHole
    it("setFloorHole toggles the active-level floor opening flag", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setActiveLevel(1)
        grid:setFloorHole(1, 0, true)
        expect_true(grid:isFloorHole(1, 0))
    end)

    -- @covers LMultiLevelGrid:isFloorHole
    it("isFloorHole reads imported floor-hole data from the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_holes = { false, false, false, false },
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                floor_holes = { false, true, false, false },
            },
        })
        grid:setActiveLevel(1)
        expect_true(grid:isFloorHole(1, 0))
    end)

    -- @covers LMultiLevelGrid:setCeilingHole
    it("setCeilingHole toggles the active-level ceiling opening flag", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
            { width = 2, height = 2, cells = { 0, 0, 0, 0 } },
        })
        grid:setActiveLevel(1)
        grid:setCeilingHole(1, 1, true)
        expect_true(grid:isCeilingHole(1, 1))
    end)

    -- @covers LMultiLevelGrid:isCeilingHole
    it("isCeilingHole reads imported ceiling-hole data from the active level", function()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                ceiling_holes = { false, false, false, false },
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
                ceiling_holes = { false, false, false, true },
            },
        })
        grid:setActiveLevel(1)
        expect_true(grid:isCeilingHole(1, 1))
    end)

    -- @covers LMultiLevelGrid:buildScene
    it("buildScene renders a persistent stacked world", function()
        local wall = load_texture()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 2,
                height = 2,
                cells = { 0, 0, 0, 0 },
            },
            {
                width = 2,
                height = 2,
                cells = { 0, 1, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
                floor_texture = wall,
            },
        })
        grid:setActiveLevel(1)
        local count = grid:buildScene({
            px = 0.5,
            py = 0.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 8.0,
            screen_w = 160,
            screen_h = 100,
            camera_height = 0.5,
        }, {}, {}, { [1] = wall })
        expect_true(count > 0)
    end)

    -- @covers LMultiLevelGrid:pickScreen
    it("pickScreen resolves hits from the persistent stacked world", function()
        local wall = load_texture()
        local grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 8,
                height = 8,
                cells = { 0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0 },
            },
            {
                width = 8,
                height = 8,
                cells = { 0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 1, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0,
                          0, 0, 0, 0, 0, 0, 0, 0 },
                floor_offset = 1.0,
                ceiling_height = 2.0,
            },
        })
        grid:setActiveLevel(1)
        local hit = grid:pickScreen(80, 50, {
            px = 1.5,
            py = 2.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 32,
            max_dist = 8.0,
            screen_w = 160,
            screen_h = 100,
            camera_height = 0.5,
        }, { [1] = wall })
        expect_equal(1, hit.level)
        expect_equal("wall", hit.surface)
        expect_equal(4, hit.x)
        expect_equal(2, hit.y)
        expect_type("number", hit.texture)

        local feature_grid = lurek.raycaster.newMultiLevelGrid({
            {
                width = 12,
                height = 10,
                cells = {
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                },
                floor_offset = 0.0,
                ceiling_height = 1.0,
            },
            {
                width = 12,
                height = 10,
                cells = {
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                        1, 0, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1,
                    1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1,
                },
                floor_offset = 1.0,
                ceiling_height = 2.0,
                wall_features = {
                    {
                        x = 6,
                        y = 5,
                        kind = "window",
                        sill_height = 0.3,
                        lintel_height = 0.75,
                        alpha = 0.35,
                    },
                },
            },
        })
        feature_grid:setActiveLevel(1)
        local feature_hit = feature_grid:pickScreen(160, 118, {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
            camera_height = 0.5,
        }, { [1] = wall })
        expect_not_nil(feature_hit)
        expect_equal(1, feature_hit.level)
        expect_equal(6, feature_hit.x)
        expect_equal("window", feature_hit.feature.kind)
        expect_equal("lower", feature_hit.feature.section)
    end)

    -- @covers LMultiLevelGrid:buildSceneFromAdapter
    it("buildSceneFromAdapter resolves adapter-backed entities on the active level", function()
        local grid = make_persistent_multilevel_grid()
        local _, body, adapter = make_scene_adapter_fixture(2.5, 1.5)
        adapter:bindBodySprite(body, load_texture(), {
            id = 601,
            level = 1,
            size = 1.0,
        })
        adapter:bindBodyLight(body, 4.0, {
            level = 1,
            intensity = 1.0,
            color = { 1.0, 0.8, 0.6 },
        })
        local count = grid:buildSceneFromAdapter(multilevel_params(), adapter, {})
        expect_true(count > 0)
    end)

    -- @covers LMultiLevelGrid:pickScreenFromAdapter
    it("pickScreenFromAdapter resolves the active-level sprite id", function()
        local grid = make_persistent_multilevel_grid()
        local _, body, adapter = make_scene_adapter_fixture(2.5, 1.5)
        adapter:bindBodySprite(body, load_texture(), {
            id = 601,
            level = 1,
            size = 1.0,
        })
        local hit = grid:pickScreenFromAdapter(80, 50, multilevel_params(), {}, adapter)
        expect_not_nil(hit)
        expect_equal("sprite", hit.surface)
        expect_equal(601, hit.id)
        expect_equal(1, hit.level)
    end)

    -- @covers LMultiLevelGrid:type
    it("type returns the multilevel grid userdata name", function()
        local grid = lurek.raycaster.newMultiLevelGrid()
        expect_equal("LMultiLevelGrid", grid:type())
    end)

    -- @covers LMultiLevelGrid:typeOf
    it("typeOf accepts the multilevel grid type name", function()
        local grid = lurek.raycaster.newMultiLevelGrid()
        expect_true(grid:typeOf("LMultiLevelGrid"))
    end)
end)

-- @describe LDoorManager methods
describe("LDoorManager methods", function()
    -- @covers LDoorManager:addDoor
    it("addDoor registers a door and returns its index", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(3, 5, "horizontal", 1.0)
        expect_equal(0, id)
        expect_equal(1, doors:count())
    end)

    -- @covers LDoorManager:closeDoor
    it("closeDoor transitions an open door back toward closed state", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(1, 1, "vertical", 1.0)
        doors:openDoor(id)
        doors:update(1.1)
        doors:closeDoor(id)
        doors:update(0.5)
        expect_equal("closing", doors:getDoor(id).state)
    end)

    -- @covers LDoorManager:count
    it("count returns the number of registered doors", function()
        local doors = lurek.raycaster.newDoorManager()
        doors:addDoor(1, 1, "vertical", 1.0)
        doors:addDoor(2, 2, "horizontal", 1.0)
        expect_equal(2, doors:count())
    end)

    -- @covers LDoorManager:getDoor
    it("getDoor returns door state records", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(3, 3, "vertical", 1.0)
        local door = doors:getDoor(id)
        expect_equal(3, door.x)
        expect_equal(3, door.y)
        expect_equal("closed", door.state)
    end)

    -- @covers LDoorManager:openDoor
    it("openDoor begins the opening transition", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(1, 1, "vertical", 1.0)
        doors:openDoor(id)
        doors:update(0.5)
        expect_equal("opening", doors:getDoor(id).state)
    end)

    -- @covers LDoorManager:type
    it("type returns the door manager userdata name", function()
        local doors = lurek.raycaster.newDoorManager()
        expect_equal("LDoorManager", doors:type())
    end)

    -- @covers LDoorManager:typeOf
    it("typeOf accepts the door manager type name", function()
        local doors = lurek.raycaster.newDoorManager()
        expect_true(doors:typeOf("LDoorManager"))
    end)

    -- @covers LDoorManager:update
    it("update advances openAmount over time", function()
        local doors = lurek.raycaster.newDoorManager()
        local id = doors:addDoor(1, 1, "vertical", 1.0)
        doors:openDoor(id)
        doors:update(0.5)
        expect_near(0.5, doors:getDoor(id).openAmount, 1e-5)
    end)
end)

-- @describe LHeightMap methods
describe("LHeightMap methods", function()
    -- @covers LHeightMap:ceilingAt
    it("ceilingAt returns the configured ceiling height", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setCeiling(1, 2, 0.75)
        expect_near(0.75, hm:ceilingAt(1, 2), 1e-5)
    end)

    -- @covers LHeightMap:floorAt
    it("floorAt returns the configured floor height", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setFloor(1, 2, 0.25)
        expect_near(0.25, hm:floorAt(1, 2), 1e-5)
    end)

    -- @covers LHeightMap:setCeiling
    it("setCeiling updates one cell", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setCeiling(0, 0, 1.5)
        expect_near(1.5, hm:ceilingAt(0, 0), 1e-5)
    end)

    -- @covers LHeightMap:setFloor
    it("setFloor updates one cell", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        hm:setFloor(0, 0, -0.3)
        expect_near(-0.3, hm:floorAt(0, 0), 1e-5)
    end)

    -- @covers LHeightMap:type
    it("type returns the height map userdata name", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        expect_equal("LHeightMap", hm:type())
    end)

    -- @covers LHeightMap:typeOf
    it("typeOf accepts the height map type name", function()
        local hm = lurek.raycaster.newHeightMap(4, 4)
        expect_true(hm:typeOf("LHeightMap"))
    end)
end)

-- @describe LPointLight methods
describe("LPointLight methods", function()
    -- @covers LPointLight:color
    it("color returns the rgb channels", function()
        local light = lurek.raycaster.newPointLight(0, 0, 0.2, 0.4, 0.6, 5, 1)
        local r, g, b = light:color()
        expect_near(0.2, r, 1e-5)
        expect_near(0.4, g, 1e-5)
        expect_near(0.6, b, 1e-5)
    end)

    -- @covers LPointLight:intensity
    it("intensity returns the configured brightness", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 5, 0.8)
        expect_near(0.8, light:intensity(), 1e-5)
    end)

    -- @covers LPointLight:level
    it("level returns the optional owning multilevel slice", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 5, 0.8, 2)
        expect_equal(2, light:level())
    end)

    -- @covers LPointLight:radius
    it("radius returns the configured falloff radius", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 5, 1)
        expect_near(5.0, light:radius(), 1e-5)
    end)

    -- @covers LPointLight:set
    it("set overwrites position color and intensity", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        light:set(7, 9, 0, 0, 1, 6, 2, 3)
        local r, g, b = light:color()
        expect_near(7.0, light:x(), 1e-5)
        expect_near(9.0, light:y(), 1e-5)
        expect_near(0.0, r, 1e-5)
        expect_near(0.0, g, 1e-5)
        expect_near(1.0, b, 1e-5)
        expect_near(6.0, light:radius(), 1e-5)
        expect_near(2.0, light:intensity(), 1e-5)
        expect_equal(3, light:level())
    end)

    -- @covers LPointLight:setLevel
    it("setLevel can make a point light level-specific or global again", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        light:setLevel(1)
        expect_equal(1, light:level())
        light:setLevel(nil)
        expect_nil(light:level())
    end)

    -- @covers LPointLight:type
    it("type returns the point light userdata name", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        expect_equal("LPointLight", light:type())
    end)

    -- @covers LPointLight:typeOf
    it("typeOf accepts the point light type name", function()
        local light = lurek.raycaster.newPointLight(0, 0, 1, 1, 1, 1, 1)
        expect_true(light:typeOf("LPointLight"))
    end)

    -- @covers LPointLight:x
    it("x returns the light world x coordinate", function()
        local light = lurek.raycaster.newPointLight(10, 20, 1, 1, 1, 1, 1)
        expect_near(10.0, light:x(), 1e-5)
    end)

    -- @covers LPointLight:y
    it("y returns the light world y coordinate", function()
        local light = lurek.raycaster.newPointLight(10, 20, 1, 1, 1, 1, 1)
        expect_near(20.0, light:y(), 1e-5)
    end)
end)

-- @describe LRaycaster methods
describe("LRaycaster methods", function()
    -- @covers LRaycaster:buildMinimapWindow
    it("buildMinimapWindow returns sampled tile records", function()
        local map = make_map(16, 16)
        map:setCell(4, 4, 1)
        local samples = map:buildMinimapWindow(5.5, 5.5, 3, 0.2, {})
        expect_type("table", samples)
        expect_true(#samples > 0)
        expect_type("number", samples[1].x)
    end)

    -- @covers LRaycaster:buildScene
    it("buildScene returns a quad count for a simple scene", function()
        local map = make_map(16, 16)
        local wall = load_texture()
        local count = map:buildScene(scene_params(), {}, {}, { [1] = wall })
        expect_type("number", count)
        local light = lurek.raycaster.newPointLight(8.0, 8.0, 1.0, 0.9, 0.8, 4.0, 1.5)
        local managed_count = map:buildScene(scene_params(), { light }, {}, {})
        expect_type("number", managed_count)
        map:setCeilingTextureCell(8, 8, 1)
        local params = scene_params()
        params.sun_r = 0.7
        params.sun_g = 0.8
        params.sun_b = 1.0
        params.sun_intensity = 0.6
        params.sun_angle = 0.0
        params.roof_darkness = 0.5
        local tinted_count = map:buildScene(params, {}, {}, {})
        expect_type("number", tinted_count)

        local tex = load_texture()
        local directional_count = map:buildScene(scene_params(), {}, {
            {
                x = 10.5,
                y = 8.0,
                size = 1.0,
                angle = math.pi,
                front_texture = tex,
                right_texture = tex,
                back_texture = tex,
                left_texture = tex,
            },
        }, {})
        expect_type("number", directional_count)
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:addDirectional(10.5, 8.0, tex, tex, tex, tex, math.pi, 1.0)
        local directional_managed_count = map:buildScene(scene_params(), {}, sprites, { [1] = tex })
        expect_type("number", directional_managed_count)
        expect_true(id > 0)
    end)

    -- @covers LRaycaster:buildSceneWithModels
    it("buildSceneWithModels returns a quad count without models", function()
        local map = make_map(16, 16)
        local baseline = map:buildSceneWithModels(scene_params(), nil, nil, nil, nil)
        expect_type("number", baseline)
        local model = load_model()
        local with_model = map:buildSceneWithModels(scene_params(), nil, nil, nil, {
            { model = model, x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
        })
        expect_true(with_model > baseline)
    end)

    -- @covers LRaycaster:buildSceneFromAdapter
    it("buildSceneFromAdapter includes adapter-backed sprites and models in the scene", function()
        local map = make_map(16, 16)
        local _, body, adapter = make_scene_adapter_fixture(10.5, 8.0)
        adapter:bindBodySprite(body, load_texture(), {
            id = 501,
            size = 1.0,
        })
        adapter:bindBodyLight(body, 4.0, {
            intensity = 1.1,
            color = { 1.0, 0.8, 0.5 },
        })
        adapter:bindBodyModel(body, load_model(), {
            id = 502,
            yaw_offset = math.pi / 4,
            z = 0.15,
            scale = 0.22,
        })

        local baseline = map:buildScene(scene_params(), {}, {}, {})
        local count = map:buildSceneFromAdapter(scene_params(), adapter, {})
        expect_true(count > baseline)
    end)

    -- @covers LRaycaster:pickScreenFromAdapter
    it("pickScreenFromAdapter resolves the adapter-backed sprite id", function()
        local map = make_map(16, 16)
        local _, body, adapter = make_scene_adapter_fixture(10.5, 8.0)
        adapter:bindBodySprite(body, load_texture(), {
            id = 501,
            size = 1.0,
        })
        local hit = map:pickScreenFromAdapter(80, 50, scene_params(), adapter)
        expect_not_nil(hit)
        expect_equal("sprite", hit.surface)
        expect_equal(501, hit.id)
    end)

    -- @covers LRaycaster:castFloorRow
    it("castFloorRow returns per-pixel uv tables", function()
        local map = make_map(5, 5)
        local uvs = map:castFloorRow(2.5, 2.5, 1.0, 0.0, 0.0, 0.66, 100)
        expect_type("table", uvs)
        if #uvs > 0 then
            expect_type("number", uvs[1].u)
            expect_type("number", uvs[1].v)
        end
    end)

    -- @covers LRaycaster:castRay
    it("castRay hits solid walls and can pass through fully open doors", function()
        local map = lurek.raycaster.new(10, 10)
        map:setCell(8, 4, 1)
        local hit = map:castRay(1.5, 4.5, 0.0, 20.0)
        expect_not_nil(hit)
        expect_equal(true, hit.hit)
        expect_equal(1, hit.cell_value)

        local closed_door_map = lurek.raycaster.new(12, 6)
        closed_door_map:setCell(5, 2, 2)
        closed_door_map:setDoorCell(5, 2, "vertical", 0.0, 0.25)
        closed_door_map:setCell(9, 2, 1)
        local closed_door_hit = closed_door_map:castRay(1.5, 2.5, 0.0, 20.0)
        expect_not_nil(closed_door_hit)
        expect_equal(2, closed_door_hit.cell_value)

        local open_door_map = lurek.raycaster.new(12, 6)
        open_door_map:setCell(5, 2, 2)
        open_door_map:setDoorCell(5, 2, "vertical", 1.0, 0.25)
        open_door_map:setCell(9, 2, 1)
        local open_door_hit = open_door_map:castRay(1.5, 2.5, 0.0, 20.0)
        expect_not_nil(open_door_hit)
        expect_equal(1, open_door_hit.cell_value)
    end)

    -- @covers LRaycaster:castRayMulti
    it("castRayMulti returns layered hits through transparent walls", function()
        local map = lurek.raycaster.new(16, 16)
        map:setCell(5, 8, 2)
        map:setCell(10, 8, 1)
        map:setWallAlpha(2, 0.5)
        local hits = map:castRayMulti(2, 8.5, 0, 20, 4)
        expect_type("table", hits)
        expect_true(#hits >= 1)
    end)

    -- @covers LRaycaster:castRays
    it("castRays returns exactly the requested number of ray tables", function()
        local map = lurek.raycaster.new(20, 20)
        local rays = map:castRays(10.0, 10.0, 0.0, math.pi / 2, 64, 30.0)
        expect_equal(64, #rays)
    end)

    -- @covers LRaycaster:castRaysFlat
    it("castRaysFlat returns flat numeric output", function()
        local map = make_map(8, 8)
        local flat = map:castRaysFlat(4.0, 4.0, 0.0, math.pi / 3, 5, 20.0)
        expect_equal(25, #flat)
        expect_type("number", flat[1])
    end)

    -- @covers LRaycaster:computeTileLight
    it("computeTileLight returns rgb and luma values in range", function()
        local map = lurek.raycaster.new(8, 8)
        local r, g, b, luma = map:computeTileLight(3, 3, 0.2, {
            { x = 3.5, y = 3.5, radius = 4.0, intensity = 8.0, color = { 1.0, 0.8, 0.5 } },
        })
        expect_true(r >= 0 and r <= 1)
        expect_true(g >= 0 and g <= 1)
        expect_true(b >= 0 and b <= 1)
        expect_true(luma >= 0 and luma <= 1)
        local light = lurek.raycaster.newPointLight(3.5, 3.5, 1.0, 0.8, 0.5, 4.0, 8.0, 1)
        local r2, g2, b2, luma2 = map:computeTileLight(3, 3, 0.2, {
            light,
            { x = 2.5, y = 2.5, radius = 3.0, intensity = 2.0, color = { 0.2, 0.4, 1.0 } },
        })
        expect_true(r2 >= 0 and r2 <= 1)
        expect_true(g2 >= 0 and g2 <= 1)
        expect_true(b2 >= 0 and b2 <= 1)
        expect_true(luma2 >= 0 and luma2 <= 1)

        local solid = lurek.raycaster.new(8, 3)
        solid:setCell(4, 1, 1)
        local sr, sg, sb = solid:computeTileLight(2, 1, 0.0, {
            { x = 5.5, y = 1.5, radius = 8.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
        })

        local windowed = lurek.raycaster.new(8, 3)
        windowed:setCell(4, 1, 1)
        windowed:setWindowCell(4, 1, 0.25, 0.8, 0.35)
        local wr, wg, wb = windowed:computeTileLight(2, 1, 0.0, {
            { x = 5.5, y = 1.5, radius = 8.0, intensity = 8.0, color = { 1.0, 0.8, 0.6 } },
        })
        expect_true(wr > sr)
        expect_true(wg > sg)
        expect_true(wb > sb)
    end)

    -- @covers LRaycaster:drawCameraSweep
    it("drawCameraSweep returns image data", function()
        local map = lurek.raycaster.new(8, 8)
        local img = map:drawCameraSweep(2.0, 2.0, 1.0, 20.0, 4, 16, 16)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:pickScreen
    it("pickScreen resolves wall, floor, ceiling, sprite, and model hits", function()
        local map = make_map(16, 16)

        local wall_hit = map:pickScreen(80, 50, scene_params())
        expect_not_nil(wall_hit)
        expect_equal("wall", wall_hit.surface)
        expect_equal(15, wall_hit.x)
        expect_equal(8, wall_hit.y)
        expect_equal(1, wall_hit.cell_value)
        expect_type("number", wall_hit.u)
        expect_type("number", wall_hit.v)

        local floor_hit = map:pickScreen(80, 90, scene_params())
        expect_not_nil(floor_hit)
        expect_equal("floor", floor_hit.surface)

        local ceiling_hit = map:pickScreen(80, 10, scene_params())
        expect_not_nil(ceiling_hit)
        expect_equal("ceiling", ceiling_hit.surface)

        local sprite_hit = map:pickScreen(80, 50, scene_params(), {
            { id = 42, x = 10.5, y = 8.0, texture = load_texture(), size = 1.0 },
        })
        expect_not_nil(sprite_hit)
        expect_equal("sprite", sprite_hit.surface)
        expect_equal(42, sprite_hit.id)
        expect_equal(10, sprite_hit.x)
        expect_equal(8, sprite_hit.y)
        expect_type("number", sprite_hit.texture)

        local model_hit = map:pickScreen(80, 60, scene_params(), nil, {
            { id = 84, model = load_model(), x = 10.5, y = 8.0, yaw = math.pi / 4, z = 0.15, scale = 0.22 },
        })
        expect_not_nil(model_hit)
        expect_equal("model", model_hit.surface)
        expect_equal(84, model_hit.id)
        expect_equal(10, model_hit.x)
        expect_equal(8, model_hit.y)

        local feature_params = {
            px = 2.5,
            py = 5.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 20.0,
            screen_w = 320,
            screen_h = 200,
        }

        local half_map = make_map(12, 10)
        half_map:setCell(7, 5, 1)
        half_map:setHalfWallCell(7, 5, 0.5)
        local half_center = half_map:pickScreen(160, 100, feature_params)
        expect_not_nil(half_center)
        expect_equal(7, half_center.x)
        expect_equal(5, half_center.y)
        expect_type("table", half_center.feature)
        expect_equal("half", half_center.feature.kind)
        expect_equal("body", half_center.feature.section)
        expect_near(0.5, half_center.wall_height, 0.02)

        local half_upper = half_map:pickScreen(160, 84, feature_params)
        expect_not_nil(half_upper)
        expect_equal("wall", half_upper.surface)
        expect_equal(11, half_upper.x)
        expect_equal(5, half_upper.y)
        expect_nil(half_upper.feature)

        local window_map = make_map(12, 10)
        window_map:setCell(7, 5, 1)
        window_map:setWindowCell(7, 5, 0.3, 0.75, 0.35)
        local window_open = window_map:pickScreen(160, 100, feature_params)
        expect_not_nil(window_open)
        expect_equal(11, window_open.x)
        expect_equal(5, window_open.y)
        expect_nil(window_open.feature)

        local window_lower = window_map:pickScreen(160, 114, feature_params)
        expect_not_nil(window_lower)
        expect_equal(7, window_lower.x)
        expect_equal("window", window_lower.feature.kind)
        expect_equal("lower", window_lower.feature.section)
        expect_true(window_lower.wall_height < 0.31)

        local window_upper = window_map:pickScreen(160, 84, feature_params)
        expect_not_nil(window_upper)
        expect_equal(7, window_upper.x)
        expect_equal("window", window_upper.feature.kind)
        expect_equal("upper", window_upper.feature.section)
        expect_true(window_upper.wall_height > 0.74)

        local door_map = make_map(12, 10)
        door_map:setCell(7, 5, 1)
        door_map:setDoorCell(7, 5, "vertical", 0.25, 0.9)
        local door_panel = door_map:pickScreen(160, 100, feature_params)
        expect_not_nil(door_panel)
        expect_equal(7, door_panel.x)
        expect_equal("door", door_panel.feature.kind)
        expect_equal("panel", door_panel.feature.section)

        local open_door_map = make_map(12, 10)
        open_door_map:setCell(7, 5, 1)
        open_door_map:setDoorCell(7, 5, "vertical", 0.6, 0.9)
        local door_gap = open_door_map:pickScreen(160, 100, feature_params)
        expect_not_nil(door_gap)
        expect_equal(11, door_gap.x)
        expect_equal(5, door_gap.y)
        expect_nil(door_gap.feature)
        local masked = {
            { id = 77, x = 10.5, y = 8.0, texture = load_masked_texture(), size = 2.5 },
        }

        local center_hit = map:pickScreen(80, 50, scene_params(), masked)
        expect_not_nil(center_hit)
        expect_equal("sprite", center_hit.surface)
        expect_equal(77, center_hit.id)

        local transparent_hit = map:pickScreen(30, 50, scene_params(), masked)
        expect_not_nil(transparent_hit)
        expect_true(transparent_hit.surface ~= "sprite")
        expect_equal("wall", transparent_hit.surface)
    end)

    -- @covers LRaycaster:drawDepthMap
    it("drawDepthMap returns image data", function()
        local map = lurek.raycaster.new(8, 8)
        local img = map:drawDepthMap(1.0, 1.0, 0.0, 1.0, 8, 32, 16, 20.0)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawLineOfSight
    it("drawLineOfSight returns image data", function()
        local map = lurek.raycaster.new(8, 8)
        local img = map:drawLineOfSight(1.0, 1.0, 6.0, 6.0, 4)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawTopDown
    it("drawTopDown returns image data", function()
        local map = make_map(8, 8)
        local img = map:drawTopDown(4.5, 4.5, 0, 16)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:drawView
    it("drawView returns image data of the requested size", function()
        local map = make_map(16, 16)
        local img = map:drawView(8, 8, 0, math.pi / 3, 320, 200, 100)
        expect_equal(320, img:getWidth())
        expect_equal(200, img:getHeight())
    end)

    -- @covers LRaycaster:extractMinimap
    it("extractMinimap returns a minimap image", function()
        local map = make_map(16, 16)
        local img = map:extractMinimap(8, 8, 0, 4, 8)
        expect_type("userdata", img)
    end)

    -- @covers LRaycaster:getCeilingTextureCell
    it("getCeilingTextureCell returns nil when no override is set", function()
        local map = lurek.raycaster.new(8, 8)
        expect_nil(map:getCeilingTextureCell(0, 0))
    end)

    -- @covers LRaycaster:getCell
    it("getCell reads back values written to the grid", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(1, 2, 3)
        expect_equal(3, map:getCell(1, 2))
    end)

    -- @covers LRaycaster:setHalfWallCell
    it("setHalfWallCell stores feature metadata", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(1, 1, 1)
        map:setHalfWallCell(1, 1, 0.5)
        local feature = map:getWallFeatureCell(1, 1)
        expect_type("table", feature)
        expect_equal("half", feature.kind)
        expect_near(0.5, feature.height, 1e-5)
    end)

    -- @covers LRaycaster:setWindowCell
    it("setWindowCell stores a transparent opening descriptor", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(1, 1, 1)
        map:setWindowCell(1, 1, 0.3, 0.75, 0.4)
        local feature = map:getWallFeatureCell(1, 1)
        expect_equal("window", feature.kind)
        expect_near(0.3, feature.sill_height, 1e-5)
        expect_near(0.75, feature.lintel_height, 1e-5)
        expect_near(0.4, feature.alpha, 1e-5)
        expect_true(map:lineOfSight(0.5, 1.5, 3.5, 1.5))
    end)

    -- @covers LRaycaster:getWallFeatureCell
    it("getWallFeatureCell returns nil when no feature is assigned", function()
        local map = lurek.raycaster.new(4, 4)
        expect_nil(map:getWallFeatureCell(1, 1))
    end)

    -- @covers LRaycaster:getFloorTextureCell
    it("getFloorTextureCell returns nil when no override is set", function()
        local map = lurek.raycaster.new(8, 8)
        expect_nil(map:getFloorTextureCell(0, 0))
    end)

    -- @covers LRaycaster:getLoweredFloorCell
    it("getLoweredFloorCell returns stored lowered-floor options", function()
        local map = lurek.raycaster.new(8, 8)
        map:setLoweredFloorCell(2, 2, { texture = 1, depth = 0.35, blocked = true })
        local cell = map:getLoweredFloorCell(2, 2)
        expect_type("table", cell)
        expect_equal(1, cell.texture)
        expect_equal(true, cell.blocked)
    end)

    -- @covers LRaycaster:getWallAlpha
    it("getWallAlpha returns the configured transparency", function()
        local map = lurek.raycaster.new(4, 4)
        map:setWallAlpha(2, 0.5)
        expect_near(0.5, map:getWallAlpha(2), 1e-5)
    end)

    -- @covers LRaycaster:setDoorCell
    it("setDoorCell can make a wall cell non-blocking when fully open", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(1, 1, 1)
        map:setDoorCell(1, 1, "horizontal", 1.0)
        local feature = map:getWallFeatureCell(1, 1)
        expect_equal("door", feature.kind)
        expect_equal("horizontal", feature.direction)
        expect_false(map:isBlocked(1, 1))
    end)

    -- @covers LRaycaster:applyDoorManager
    it("applyDoorManager syncs animated doors onto blocking tiles", function()
        local map = lurek.raycaster.new(6, 4)
        local doors = lurek.raycaster.newDoorManager()
        map:setCell(2, 1, 2)

        local id = doors:addDoor(2, 1, "vertical", 1.0)
        map:applyDoorManager(doors, 0.8)
        expect_true(map:isBlocked(2, 1))
        expect_equal("door", map:getWallFeatureCell(2, 1).kind)

        doors:openDoor(id)
        doors:update(1.0)
        map:applyDoorManager(doors, 0.8)
        expect_false(map:isBlocked(2, 1))

        local empty = lurek.raycaster.newDoorManager()
        map:applyDoorManager(empty, 0.8)
        expect_equal(nil, map:getWallFeatureCell(2, 1))
        expect_true(map:isBlocked(2, 1))
    end)

    -- @covers LRaycaster:clearWallFeatureCell
    it("clearWallFeatureCell removes a stored wall feature override", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(1, 1, 1)
        map:setWindowCell(1, 1, 0.25, 0.75, 0.4)
        map:clearWallFeatureCell(1, 1)
        expect_nil(map:getWallFeatureCell(1, 1))
    end)

    -- @covers LRaycaster:gridMove
    it("gridMove moves forward along the cardinal direction", function()
        local map = make_map(8, 8)
        local nx, ny, moved = map:gridMove(4.5, 4.5, 2, "forward", 1.0)
        expect_equal(true, moved)
        expect_type("number", nx)
        expect_type("number", ny)
    end)

    -- @covers LRaycaster:height
    it("height returns the map height in cells", function()
        local map = lurek.raycaster.new(5, 3)
        expect_equal(3, map:height())
    end)

    -- @covers LRaycaster:isBlocked
    it("isBlocked reports non-zero wall cells as blocked", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(0, 0, 1)
        expect_true(map:isBlocked(0, 0))
        expect_false(map:isBlocked(1, 1))
    end)

    -- @covers LRaycaster:isWalkBlocked
    it("isWalkBlocked respects lowered floor blocking flags", function()
        local map = lurek.raycaster.new(8, 8)
        map:setLoweredFloorCell(3, 3, { texture = load_texture(), depth = 0.3, blocked = true })
        expect_true(map:isWalkBlocked(3, 3))
    end)

    -- @covers LRaycaster:lineOfSight
    it("lineOfSight returns false when a wall blocks the path", function()
        local map = lurek.raycaster.new(10, 10)
        map:setCell(5, 5, 1)
        expect_false(map:lineOfSight(1.0, 5.5, 9.0, 5.5))

        local window_map = lurek.raycaster.new(10, 10)
        window_map:setCell(5, 5, 1)
        window_map:setWindowCell(5, 5, 0.25, 0.8, 0.35)
        expect_true(window_map:lineOfSight(1.0, 5.5, 9.0, 5.5))

        local door_map = lurek.raycaster.new(10, 10)
        door_map:setCell(5, 5, 1)
        door_map:setDoorCell(5, 5, "vertical", 0.0, 0.25)
        expect_false(door_map:lineOfSight(1.0, 5.5, 9.0, 5.5))
    end)

    -- @covers LRaycaster:projectSprite
    it("projectSprite returns projection fields for a visible sprite", function()
        local map = lurek.raycaster.new(10, 10)
        local sp = map:projectSprite(5.0, 5.0, 1.0, 5.0, 0.0, math.pi / 2, 320.0)
        expect_type("table", sp)
        expect_type("number", sp.screen_x)
        expect_type("number", sp.scale)
        expect_type("number", sp.distance)
        expect_type("boolean", sp.visible)
    end)

    -- @covers LRaycaster:revealCellsFromRays
    it("revealCellsFromRays returns cell records with coordinates", function()
        local map = lurek.raycaster.new(16, 16)
        local cells = map:revealCellsFromRays(8.5, 8.5, 0.0, math.pi / 3, 8, 8.0, 0.25)
        expect_type("table", cells)
        if #cells > 0 then
            expect_type("number", cells[1].x)
            expect_type("number", cells[1].y)
        end
    end)

    -- @covers LRaycaster:setCeilingTextureCell
    it("setCeilingTextureCell stores and clears per-cell texture overrides", function()
        local map = lurek.raycaster.new(8, 8)
        map:setCeilingTextureCell(3, 3, 2)
        expect_equal(2, map:getCeilingTextureCell(3, 3))
        map:setCeilingTextureCell(3, 3, nil)
        expect_nil(map:getCeilingTextureCell(3, 3))
    end)

    -- @covers LRaycaster:setCell
    it("setCell writes an integer wall value to one cell", function()
        local map = lurek.raycaster.new(4, 4)
        map:setCell(0, 0, 7)
        expect_equal(7, map:getCell(0, 0))
    end)

    -- @covers LRaycaster:setCells
    it("setCells fills the grid from a flat Lua table", function()
        local map = lurek.raycaster.new(2, 2)
        map:setCells({ 1, 2, 3, 4 })
        expect_equal(4, map:getCell(1, 1))
    end)

    -- @covers LRaycaster:setFloorTextureCell
    it("setFloorTextureCell stores and clears per-cell texture overrides", function()
        local map = lurek.raycaster.new(8, 8)
        map:setFloorTextureCell(1, 1, 1)
        expect_equal(1, map:getFloorTextureCell(1, 1))
        map:setFloorTextureCell(1, 1, nil)
        expect_nil(map:getFloorTextureCell(1, 1))
    end)

    -- @covers LRaycaster:setLoweredFloorCell
    it("setLoweredFloorCell stores lowered-floor metadata", function()
        local map = lurek.raycaster.new(8, 8)
        map:setLoweredFloorCell(4, 4, {
            texture = load_texture(),
            depth = 0.3,
            blocked = false,
        })
        local cell = map:getLoweredFloorCell(4, 4)
        expect_near(0.3, cell.depth, 1e-5)
    end)

    -- @covers LRaycaster:setWallAlpha
    it("setWallAlpha changes the transparency for a wall type", function()
        local map = lurek.raycaster.new(4, 4)
        map:setWallAlpha(1, 0.75)
        expect_near(0.75, map:getWallAlpha(1), 1e-5)
    end)

    -- @covers LRaycaster:tryMove
    it("tryMove advances through empty space", function()
        local map = lurek.raycaster.new(6, 6)
        local nx, ny, moved = map:tryMove(1.5, 1.5, 1.0, 0.0)
        expect_equal(true, moved)
        expect_near(2.5, nx, 0.001)
        expect_near(1.5, ny, 0.001)
    end)

    -- @covers LRaycaster:type
    it("type returns the raycaster userdata name", function()
        local map = lurek.raycaster.new(8, 8)
        expect_equal("LRaycaster", map:type())
    end)

    -- @covers LRaycaster:typeOf
    it("typeOf accepts the raycaster type name", function()
        local map = lurek.raycaster.new(8, 8)
        expect_true(map:typeOf("LRaycaster"))
    end)

    -- @covers LRaycaster:width
    it("width returns the map width in cells", function()
        local map = lurek.raycaster.new(5, 3)
        expect_equal(5, map:width())
    end)
end)

-- @describe LSpriteManager methods
describe("LSpriteManager methods", function()
    -- @covers LSpriteManager:add
    it("add returns unique numeric sprite ids", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local a = sprites:add(1, 1, "a.png")
        local b = sprites:add(2, 2, "b.png")
        local c = sprites:add(30, 30, load_texture(), 1.0, 2)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_type("number", a)
        expect_true(a ~= b)
        expect_type("number", c)
        expect_type("number", proj[1].texture_id)
        expect_equal(2, proj[1].level)
    end)

    -- @covers LSpriteManager:addDirectional
    it("addDirectional returns a sprite id and projects the front variant", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:addDirectional(2, 0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_type("number", id)
        expect_equal("front.png", proj[1].texture)
        expect_equal("front", proj[1].variant)
    end)

    -- @covers LSpriteManager:clear
    it("clear removes all registered sprites", function()
        local sprites = lurek.raycaster.newSpriteManager()
        sprites:add(1, 1, "a.png")
        sprites:add(2, 2, "b.png")
        sprites:clear()
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers LSpriteManager:remove
    it("remove deletes a sprite by id", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(1, 1, "a.png")
        sprites:remove(id)
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers LSpriteManager:setPosition
    it("setPosition updates projected distance from the camera", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(0, 0, "spr")
        sprites:setPosition(id, 3, 4)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_near(5.0, proj[1].distance, 0.01)
    end)

    -- @covers LSpriteManager:setLevel
    it("setLevel updates the multilevel slice metadata exposed to sorting", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(2, 0, "spr")
        sprites:setLevel(id, 3)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_equal(3, proj[1].level)
    end)

    -- @covers LSpriteManager:setFacing
    it("setFacing changes the directional variant chosen for the viewer", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:addDirectional(2, 0, "front.png", "right.png", "back.png", "left.png", math.pi, 1.0)
        sprites:setFacing(id, 0.0)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_equal("back.png", proj[1].texture)
        expect_equal("back", proj[1].variant)
    end)

    -- @covers LSpriteManager:setDirectionalTextures
    it("setDirectionalTextures replaces the bitmap set used by sortAndProject", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(2, 0, "old.png")
        sprites:setDirectionalTextures(id, "front2.png", "right2.png", "back2.png", "left2.png", math.pi)
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_equal("front2.png", proj[1].texture)
        expect_equal("front", proj[1].variant)
    end)

    -- @covers LSpriteManager:setVisible
    it("setVisible toggles sprite participation in projection", function()
        local sprites = lurek.raycaster.newSpriteManager()
        local id = sprites:add(5, 5, "ghost.png")
        sprites:setVisible(id, false)
        expect_equal(0, #sprites:sortAndProject(0, 0, 0))
    end)

    -- @covers LSpriteManager:sortAndProject
    it("sortAndProject returns far sprites before near sprites", function()
        local sprites = lurek.raycaster.newSpriteManager()
        sprites:add(2, 0, "near.png")
        sprites:add(10, 0, "far.png")
        local proj = sprites:sortAndProject(0, 0, 0)
        expect_equal(2, #proj)
        expect_equal("far.png", proj[1].texture)
        expect_equal("near.png", proj[2].texture)
    end)

    -- @covers LSpriteManager:type
    it("type returns the sprite manager userdata name", function()
        local sprites = lurek.raycaster.newSpriteManager()
        expect_equal("LSpriteManager", sprites:type())
    end)

    -- @covers LSpriteManager:typeOf
    it("typeOf accepts the sprite manager type name", function()
        local sprites = lurek.raycaster.newSpriteManager()
        expect_true(sprites:typeOf("LSpriteManager"))
    end)
end)
end
-- END test_raycaster_core_unit.lua

test_summary()
