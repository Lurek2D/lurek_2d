-- Lurek2D Library Window Config Tests
-- @testCategory library

local window_config = require("library.window_config")

-- @describe window_config library     new
describe("window_config library     new", function()
    -- @library lurek.library_window_config
    it("returns builder", function()
        local cfg = window_config.new()
        expect_not_nil(cfg, "new() must return non-nil builder")
    end)
end)

-- @describe window_config library     fluent chaining
describe("window_config library     fluent chaining", function()
    -- @library lurek.library_window_config
    it("fluent chaining returns self", function()
        local cfg = window_config.new()
        local result = cfg:title("Test"):size(800, 600):resizable(false)
        expect_true(result == cfg, "chained calls must return the same object")
    end)
end)

-- @describe window_config library     title size resizable
describe("window_config library     title size resizable", function()
    -- @library lurek.library_window_config
    it("title stores value visible in serialize", function()
        local cfg = window_config.new()
        cfg:title("My Game")
        local data = cfg:serialize()
        expect_equal(data.title, "My Game", "title must be stored")
    end)

    -- @library lurek.library_window_config
    it("size stores width and height", function()
        local cfg = window_config.new()
        cfg:size(1920, 1080)
        local data = cfg:serialize()
        expect_equal(data.width, 1920, "width must be 1920")
        expect_equal(data.height, 1080, "height must be 1080")
    end)

    -- @library lurek.library_window_config
    it("resizable stores flag", function()
        local cfg = window_config.new()
        cfg:resizable(false)
        local data = cfg:serialize()
        expect_equal(data.resizable, false, "resizable must be false")
    end)
end)

-- @describe window_config library     preset retro
describe("window_config library     preset retro", function()
    -- @library lurek.library_window_config
    it("returns correct config", function()
        local cfg = window_config.preset("retro")
        expect_not_nil(cfg, "preset('retro') must return non-nil")
        local data = cfg:serialize()
        expect_equal(data.title, "Retro Game", "retro preset title must be 'Retro Game'")
        expect_equal(data.width, 960, "retro preset width must be 960")
        expect_equal(data.height, 720, "retro preset height must be 720")
        expect_equal(data.scaling_mode, "pixel_perfect", "retro must use pixel_perfect scaling")
    end)
end)

-- @describe window_config library     preset hd
describe("window_config library     preset hd", function()
    -- @library lurek.library_window_config
    it("returns correct config", function()
        local cfg = window_config.preset("hd")
        expect_not_nil(cfg, "preset('hd') must return non-nil")
        local data = cfg:serialize()
        expect_equal(data.title, "HD Game", "hd preset title must be 'HD Game'")
        expect_equal(data.width, 1280, "hd preset width must be 1280")
        expect_equal(data.height, 720, "hd preset height must be 720")
        expect_equal(data.scaling_mode, "letterbox", "hd must use letterbox scaling")
    end)
end)

-- @describe window_config library     serialize deserialize roundtrip
describe("window_config library     serialize deserialize roundtrip", function()
    -- @library lurek.library_window_config
    it("roundtrip preserves all fields", function()
        local cfg = window_config.new()
        cfg:title("Roundtrip"):size(640, 480):resizable(false):vsync(false):fullscreen(true)
        local data = cfg:serialize()
        local cfg2 = window_config.new()
        cfg2:deserialize(data)
        local data2 = cfg2:serialize()
        expect_equal(data2.title, "Roundtrip", "title must survive roundtrip")
        expect_equal(data2.width, 640, "width must survive roundtrip")
        expect_equal(data2.height, 480, "height must survive roundtrip")
        expect_equal(data2.resizable, false, "resizable must survive roundtrip")
        expect_equal(data2.vsync, false, "vsync must survive roundtrip")
        expect_equal(data2.fullscreen, true, "fullscreen must survive roundtrip")
    end)
end)

-- @describe window_config library     apply
describe("window_config library     apply", function()
    -- @library lurek.library_window_config
    it("does not error headlessly", function()
        local cfg = window_config.new()
        cfg:title("Headless Test"):size(800, 600)
        local ok = pcall(function() cfg:apply() end)
        expect_true(ok, "apply() must not error in headless environment")
    end)
end)

-- @describe window_config library     getScaleFactor
describe("window_config library     getScaleFactor", function()
    -- @library lurek.library_window_config
    it("returns positive number", function()
        local cfg = window_config.new()
        cfg:size(1280, 720):gameSize(640, 360)
        local scale = cfg:getScaleFactor()
        expect_true(scale > 0, "scale factor must be positive")
        expect_equal(scale, 2.0, "1280/640 = 2.0 scale factor with letterbox")
    end)

    -- @library lurek.library_window_config
    it("returns 1.0 when no game size set", function()
        local cfg = window_config.new()
        cfg:size(1280, 720)
        local scale = cfg:getScaleFactor()
        expect_equal(scale, 1.0, "scale must be 1.0 without game size")
    end)
end)

test_summary()
