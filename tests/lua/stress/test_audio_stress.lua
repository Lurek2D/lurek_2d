-- Stress coverage for the existing lurek.audio multi-listener surface.

-- @describe audio stress: listener limit and atomic validation
describe("audio stress: listener limit and atomic validation", function()
    -- @stress lurek.audio.setListeners
    it("accepts 64 listeners and atomically rejects 65", function()
        local listeners = {}
        for i = 1, 64 do
            listeners[i] = {
                id = "listener_" .. i,
                x = i,
                y = -i,
                z = i % 3,
                weight = 1,
            }
        end
        lurek.audio.setListeners(listeners, { policy = "weighted" })
        expect_equal(64, #lurek.audio.getListeners())

        listeners[65] = { id = "listener_65", x = 65, y = -65 }
        expect_error(function()
            lurek.audio.setListeners(listeners)
        end)
        expect_equal(64, #lurek.audio.getListeners())
        lurek.audio.setListener(0, 0, 0)
    end)
end)

test_summary()
