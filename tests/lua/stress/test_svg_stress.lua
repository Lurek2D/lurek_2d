-- Lurek2D Stress Test: SVG vector rendering and hit-testing

-- @describe svg stress: cached drawing
describe("svg stress: cached drawing", function()
    -- @stress LSvgImage:draw
    it("repeated direct SVG draws build and reuse cached meshes without errors", function()
        local svg = lurek.svg.load("tests/lua/fixtures/svg_large.svg")
        local issued = 0
        expect_no_error(function()
            for i = 1, 200 do
                svg:draw(i % 8, i % 6, 0, 1, 1, 0, 0)
                issued = issued + 1
            end
        end)
        expect_equal(200, issued, "all direct SVG draw calls completed")
    end)

    -- @stress LSvgImage:cacheToCanvas
    it("canvas-baked SVG groups handle repeated draw calls after caching", function()
        local svg = lurek.svg.load("tests/lua/fixtures/svg_large.svg")
        svg:cacheToCanvas("large_group", 240, 120)
        expect_type("userdata", svg:getCanvas("large_group"))
        local issued = 0
        expect_no_error(function()
            for i = 1, 200 do
                svg:draw(i % 5, i % 7)
                issued = issued + 1
            end
        end)
        expect_equal(200, issued, "all canvas-cached SVG draw calls completed")
    end)
end)

-- @describe svg stress: province-style picking
describe("svg stress: province-style picking", function()
    -- @stress LSvgImage:getElementAtPoint
    it("repeated prefix hit-tests over larger SVG maps stay deterministic", function()
        local svg = lurek.svg.load("tests/lua/fixtures/svg_large.svg")
        local hits = 0
        for i = 1, 240 do
            local col = i % 4
            local row = math.floor(i / 4) % 3
            local id = svg:getElementAtPoint("large_", col * 30 + 10, row * 30 + 10)
            if id ~= nil then
                hits = hits + 1
            end
        end
        expect_equal(240, hits, "every generated pick landed inside a known SVG cell")
    end)
end)
test_summary()
