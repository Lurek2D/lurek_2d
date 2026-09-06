-- Integration: raycaster per-cell texture overrides and render image userdata
-- @describe raycaster + render integration
describe("raycaster + render integration", function()
    -- @integration LImage:getId
    -- @integration LRaycaster:getFloorTextureCell
    -- @integration LRaycaster:getCeilingTextureCell
    -- @integration LRaycaster:setFloorTextureCell
    -- @integration LRaycaster:setCeilingTextureCell
    -- @integration lurek.raycaster.new
    -- @integration lurek.render.newImage
    -- @integration lurek.raycaster.new
    -- @integration lurek.render.newImage
    it("accepts LImage userdata in per-cell overrides", function()
        local rc = lurek.raycaster.new(8, 8)
        local floor_img = lurek.render.newImage("assets/icon.png")
        local ceil_img = lurek.render.newImage("assets/icon.png")

        rc:setFloorTextureCell(1, 1, floor_img)
        rc:setCeilingTextureCell(1, 1, ceil_img)

        expect_equal(floor_img:getId(), rc:getFloorTextureCell(1, 1))
        expect_equal(ceil_img:getId(), rc:getCeilingTextureCell(1, 1))
    end)

    -- @integration LRaycaster:buildScene
    -- @integration lurek.raycaster.drawLastScene
    -- @integration lurek.image.newImageData
    -- @integration lurek.render.newImage
    -- @integration LRaycaster:setCell
    -- @integration lurek.raycaster.new
    it("renders layered sky behind transparent ceiling space and animates it", function()
        local rc = lurek.raycaster.new(8, 8)
        for i = 0, 7 do
            rc:setCell(i, 0, 1)
            rc:setCell(i, 7, 1)
            rc:setCell(0, i, 1)
            rc:setCell(7, i, 1)
        end
        local sky_data = lurek.image.newImageData(8, 4)
        sky_data:fill(20, 40, 120, 255)
        local cloud_data = lurek.image.newImageData(8, 4)
        cloud_data:fill(0, 0, 0, 0)
        cloud_data:drawRect(2, 1, 3, 1, 220, 230, 240, 220)
        local sky = lurek.render.newImage(sky_data)
        local clouds = lurek.render.newImage(cloud_data)
        local roof_data = lurek.image.newImageData(4, 4)
        roof_data:fill(190, 45, 28, 255)
        local roof = lurek.render.newImage(roof_data)
        local params = {
            px = 3.5,
            py = 3.5,
            angle = 0.0,
            fov = math.pi / 3,
            rays = 64,
            max_dist = 8.0,
            screen_w = 160,
            screen_h = 100,
            ceiling_a = 0.0,
            background = {
                type = "layered_sky",
                top = { 0.0, 0.0, 0.0, 1.0 },
                bottom = { 0.0, 0.0, 0.0, 1.0 },
                layers = {
                    { texture = sky, height = 1.5, copies = 1 },
                    { texture = clouds, height = 1.5, velocity = { 0.5, 0.0 }, copies = 1 },
                },
            },
            time_seconds = 0.0,
        }
        rc:buildScene(params, {}, {}, {})
        local first = lurek.raycaster.drawLastScene(160, 100)
        params.time_seconds = 0.75
        rc:buildScene(params, {}, {}, {})
        local second = lurek.raycaster.drawLastScene(160, 100)
        expect_equal(160, first:getWidth())
        expect_equal(100, first:getHeight())
        local changed = 0
        for y = 0, 49 do
            for x = 0, 159 do
                local r0, g0, b0, a0 = first:getPixel(x, y)
                local r1, g1, b1, a1 = second:getPixel(x, y)
                if r0 ~= r1 or g0 ~= g1 or b0 ~= b1 or a0 ~= a1 then
                    changed = changed + 1
                end
            end
        end
        expect_true(changed > 0)

        -- A real ceiling texture is geometry, so it must cover the background sky.
        for y = 1, 6 do
            for x = 1, 6 do
                rc:setCeilingTextureCell(x, y, roof)
            end
        end
        params.time_seconds = 0.0
        params.ceiling_a = 1.0
        rc:buildScene(params, {}, {}, {})
        local roof_frame = lurek.raycaster.drawLastScene(160, 100)
        local covered = 0
        for y = 0, 49 do
            for x = 0, 159 do
                local r0, g0, b0, a0 = first:getPixel(x, y)
                local r1, g1, b1, a1 = roof_frame:getPixel(x, y)
                if r0 ~= r1 or g0 ~= g1 or b0 ~= b1 or a0 ~= a1 then
                    covered = covered + 1
                end
            end
        end
        expect_true(covered > 0)
    end)
end)
test_summary()
