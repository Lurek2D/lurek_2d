-- UI stress: bounded retained-tree work and recovery after a large frame.

-- @describe stress: retained UI workload
describe("stress: retained UI workload", function()
    before_each(function()
        lurek.ui.clear()
        lurek.ui.setViewport(1280, 720)
    end)

    -- @stress lurek.ui.newButton
    it("creates, lays out, renders, and clears a bounded retained tree", function()
        local root = lurek.ui.getRoot()
        local count = 512
        for index = 1, count do
            local button = lurek.ui.newButton("row " .. index)
            button:setPosition((index % 32) * 36, math.floor(index / 32) * 24)
            button:setSize(32, 20)
            root:addChild(button)
        end
        lurek.ui.update(0.016)
        lurek.ui.draw()
        lurek.ui.clear()
        local recovered = lurek.ui.newButton("recovered")
        expect_true(recovered:isValid())
    end)

    -- @stress lurek.ui.renderToImage
    it("captures at the supported boundary shape then accepts a fresh valid capture", function()
        local button = lurek.ui.newButton("capture")
        lurek.ui.getRoot():addChild(button)
        lurek.ui.renderToImage(512, 512, "save/ui_stress_capture.png")
        lurek.ui.renderToImage(64, 64, "save/ui_stress_recovery.png")
        expect_true(button:isValid())
    end)
end)

test_summary()
