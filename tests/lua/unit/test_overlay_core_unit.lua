-- Unit tests for lurek.overlay screen overlay module.

-- @describe lurek.overlay module unit tests
describe("lurek.overlay", function()
    -- @covers lurek.overlay.new
    it("creates an overlay controller", function()
        local ov = lurek.overlay.new(800, 600)
        expect_true(ov ~= nil, "overlay should be created")
    end)

    -- @covers Overlay:getWidth
    -- @covers Overlay:getHeight
    it("reports correct dimensions", function()
        local ov = lurek.overlay.new(1920, 1080)
        expect_equal(1920, ov:getWidth())
        expect_equal(1080, ov:getHeight())
    end)

    -- @covers Overlay:getDimensions
    it("returns both dimensions", function()
        local ov = lurek.overlay.new(800, 600)
        local w, h = ov:getDimensions()
        expect_equal(800, w)
        expect_equal(600, h)
    end)

    -- @covers Overlay:isActive
    it("starts inactive", function()
        local ov = lurek.overlay.new(800, 600)
        expect_true(not ov:isActive(), "new overlay should be inactive")
    end)

    -- @covers Overlay:triggerFlash
    it("triggerFlash activates overlay", function()
        local ov = lurek.overlay.new(800, 600)
        ov:triggerFlash(1, 1, 1, 1, 0.5)
        expect_true(ov:isActive(), "flash should activate overlay")
    end)

    -- @covers Overlay:triggerShake
    it("triggerShake activates overlay", function()
        local ov = lurek.overlay.new(800, 600)
        ov:triggerShake(3.0, 0.3)
        expect_true(ov:isActive(), "shake should activate overlay")
    end)

    -- @covers Overlay:triggerFade
    it("triggerFade activates overlay", function()
        local ov = lurek.overlay.new(800, 600)
        ov:triggerFade("out", 1.0, 0, 0, 0)
        expect_true(ov:isActive(), "fade should activate overlay")
    end)

    -- @covers Overlay:clear
    it("clear deactivates all overlays", function()
        local ov = lurek.overlay.new(800, 600)
        ov:triggerFlash(1, 1, 1, 1, 0.5)
        ov:triggerShake(5.0, 0.3)
        ov:clear()
        expect_true(not ov:isActive(), "clear should deactivate all")
    end)

    -- @covers Overlay:resize
    it("resize updates dimensions", function()
        local ov = lurek.overlay.new(800, 600)
        ov:resize(1024, 768)
        expect_equal(1024, ov:getWidth())
        expect_equal(768, ov:getHeight())
    end)

    -- @covers Overlay:update
    it("update does not crash with zero dt", function()
        local ov = lurek.overlay.new(800, 600)
        ov:update(0)
        expect_true(true, "update(0) should not crash")
    end)

    -- @covers Overlay:update
    it("update progresses flash to completion", function()
        local ov = lurek.overlay.new(800, 600)
        ov:triggerFlash(1, 1, 1, 1, 0.1)
        -- Advance well past duration
        ov:update(0.5)
        expect_true(not ov:isActive(), "flash should complete after update past duration")
    end)

    -- @covers Overlay:getLightningAlpha
    it("lightning alpha starts at 0", function()
        local ov = lurek.overlay.new(800, 600)
        expect_near(0.0, ov:getLightningAlpha(), 0.01)
    end)

    -- @covers Overlay:triggerLightning
    it("triggerLightning increases alpha", function()
        local ov = lurek.overlay.new(800, 600)
        ov:triggerLightning()
        expect_true(ov:getLightningAlpha() > 0.0, "lightning alpha should increase")
    end)

    -- @covers lurek.overlay.newTransition
    it("creates a screen transition", function()
        local t = lurek.overlay.newTransition("fade", 1.0)
        expect_true(t ~= nil, "transition should be created")
    end)
end)

test_summary()
