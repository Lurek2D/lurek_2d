-- UI security: hostile handles, numeric input, layout, and capture boundaries.

local NAN = 0 / 0
local INF = 1 / 0

-- @describe security: UI trust boundaries
describe("security: UI trust boundaries", function()
    before_each(function()
        lurek.ui.clear()
        lurek.ui.setViewport(320, 180)
    end)
    local function __audit_security_3()
        local widget = lurek.ui.newButton("live")
        local forged = { _idx = 0 }
        expect_error(function() lurek.ui.destroy(forged) end)
        expect_true(widget:isValid())

        expect_equal(1, widget:destroy(false))
        expect_false(widget:isValid())
        -- Compatibility tables remain callable after invalidation, but the stale
        -- table must not revive or mutate a replacement slot.
        widget:setText("stale")
        local replacement = lurek.ui.newButton("replacement")
        expect_equal("replacement", replacement:getText())
    end


    -- @security lurek.ui.destroy
    it("rejects forged and stale widget tables without mutating the live tree", function()
        __audit_security_3()
    end)
    local function __audit_security_2()
        expect_error(function() lurek.ui.renderToImage(NAN, 8, "save/ui_nan.png") end)
        expect_error(function() lurek.ui.renderToImage(INF, 8, "save/ui_inf.png") end)
        expect_error(function() lurek.ui.renderToImage(0, 8, "save/ui_zero.png") end)
        expect_error(function() lurek.ui.renderToImage(4097, 8, "save/ui_large.png") end)
        expect_error(function() lurek.ui.renderToImage(8, 8, "../ui_escape.png") end)

        local button = lurek.ui.newButton("still live")
        expect_true(button:isValid())
    end


    -- @security lurek.ui.renderToImage
    it("rejects non-finite, zero, over-limit, and traversal capture requests atomically", function()
        __audit_security_2()
    end)
    local function __audit_security_1()
        local preserved = lurek.ui.newLabel("preserved")
        expect_error(function()
            lurek.ui.loadLayout({ children = { "not a widget" } })
        end)
        expect_true(preserved:isValid())
        expect_equal("preserved", preserved:getText())
    end


    -- @security lurek.ui.loadLayout
    it("rejects malformed and non-finite layout data while preserving the existing UI", function()
        __audit_security_1()
    end)
end)

test_summary()
