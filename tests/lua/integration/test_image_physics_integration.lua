-- Integration: image alpha data feeds physics shape inference and receives physics debug output.

-- @describe image + physics shape and debug integration
describe("image + physics shape and debug integration", function()
    -- @integration LImageData:drawCircle
    -- @integration LImageData:getPixel
    -- @integration LPhysicsShape:getRadius
    -- @integration LPhysicsShape:getType
    -- @integration LWorld:drawDebug
    -- @integration LWorld:newCircleBody
    -- @integration lurek.image.newImageData
    -- @integration lurek.physics.newWorld
    -- @integration lurek.physics.shapeFromImage
    it("turns alpha pixels into a collision shape and draws the world back onto an image", function()
        local source = lurek.image.newImageData(32, 32)
        source:drawCircle(16, 16, 8, 255, 255, 255, 255)
        local shape = lurek.physics.shapeFromImage(source, { alphaThreshold = 1 })
        expect_equal("circle", shape:getType())

        local world = lurek.physics.newWorld(0, 0)
        world:newCircleBody(16, 16, shape:getRadius(), "static")
        local debug = lurek.image.newImageData(32, 32)
        world:drawDebug(debug, 0, 255, 0, 255)
        local _, green, _, alpha = debug:getPixel(24, 16)
        expect_true(green > 0 and alpha > 0)
    end)
end)

test_summary()
