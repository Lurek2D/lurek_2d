-- Lurek2D Lua BDD tests for lurek.entity component observers
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.entity component observers.
describe("lurek.entity", function()
    -- @description Covers suite: onComponentAdded and onComponentRemoved.
    describe("component observers", function()
        -- @covers lurek.entity.newUniverse
        -- @covers lurek.entity.onComponentAdded
        -- @covers lurek.entity.flushObservers
        -- @description Verifies that onComponentAdded callback fires via flushObservers.
        it("onComponentAdded fires after flushObservers", function()
            local w = lurek.entity.newUniverse()
            local fired = 0
            local last_id = nil
            local last_name = nil
            w:onComponentAdded("hp", function(id, name)
                fired = fired + 1
                last_id = id
                last_name = name
            end)
            local e = w:spawn()
            w:set(e, "hp", 100)
            expect_equal(0, fired) -- not fired yet
            w:flushObservers()
            expect_equal(1, fired)
            expect_equal(e, last_id)
            expect_equal("hp", last_name)
        end)

        -- @covers lurek.entity.onComponentRemoved
        -- @covers lurek.entity.flushObservers
        -- @description Verifies that onComponentRemoved callback fires after removing a component.
        it("onComponentRemoved fires after flushObservers", function()
            local w = lurek.entity.newUniverse()
            local fired = 0
            w:onComponentRemoved("hp", function(id, name)
                fired = fired + 1
            end)
            local e = w:spawn()
            w:set(e, "hp", 50)
            w:flushObservers()   -- consume add event
            w:remove(e, "hp")
            expect_equal(0, fired) -- not yet
            w:flushObservers()
            expect_equal(1, fired)
        end)

        -- @covers lurek.entity.onComponentAdded
        -- @description Verifies that removing a non-existent component does not fire remove events.
        it("removing absent component does not fire remove event", function()
            local w = lurek.entity.newUniverse()
            local fired = 0
            w:onComponentRemoved("hp", function() fired = fired + 1 end)
            local e = w:spawn()
            -- hp never set
            w:remove(e, "hp")
            w:flushObservers()
            expect_equal(0, fired)
        end)

        -- @covers lurek.entity.onComponentAdded
        -- @description Verifies that multiple observers on the same component all fire.
        it("multiple observers on same component all fire", function()
            local w = lurek.entity.newUniverse()
            local count = 0
            w:onComponentAdded("pos", function() count = count + 1 end)
            w:onComponentAdded("pos", function() count = count + 1 end)
            local e = w:spawn()
            w:set(e, "pos", {x=0,y=0})
            w:flushObservers()
            expect_equal(2, count)
        end)
    end)
end)
test_summary()
