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

    -- @stress lurek.ui.newContext
    it("keeps 64 retained context trees independent", function()
        local contexts = {}
        for context_index = 1, 64 do
            local context = lurek.ui.newContext({
                viewport = { x = 0, y = 0, w = 320, h = 180 },
            })
            for widget_index = 1, 32 do
                context:create("label", {
                    id = "label_" .. widget_index,
                    text = context_index .. ":" .. widget_index,
                })
            end
            contexts[context_index] = context
        end
        expect_equal("1:1", contexts[1]:getById("label_1"):getText())
        expect_equal("64:1", contexts[64]:getById("label_1"):getText())
    end)
end)

test_summary()
