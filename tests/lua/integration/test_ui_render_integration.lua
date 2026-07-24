-- Integration: retained UI lowering, render-software capture, and image decoding.

-- @describe integration: UI capture through render and image
describe("integration: UI capture through render and image", function()
    before_each(function()
        lurek.ui.clear()
        lurek.ui.setViewport(160, 96)
    end)

    -- @integration lurek.ui.newButton
    -- @integration lurek.ui.renderToImage
    -- @integration lurek.image.newImageData
    it("lowers retained UI into a capture that image can decode", function()
        local button = lurek.ui.newButton("Capture me")
        button:setPosition(8, 8)
        button:setSize(120, 32)
        lurek.ui.getRoot():addChild(button)

        local path = "save/ui_render_integration.png"
        lurek.ui.renderToImage(160, 96, path)
        local image = lurek.image.newImageData(path)
        expect_equal(160, image:getWidth())
        expect_equal(96, image:getHeight())
        expect_true(button:isValid())
    end)
end)

test_summary()
