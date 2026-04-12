-- Lurek2D Integration Test: Audio + Event System
-- Tests audio playback triggered by event dispatching

-- @description Covers suite: audio + event integration.
describe("audio + event integration", function()
    -- @covers lurek.audio.setMasterVolume
    -- @covers lurek.event.Dispatcher.emit
    -- @covers lurek.event.newDispatcher
    -- @description Verifies emitting a mute event invokes the registered handler and drives the audio master volume to zero.
    it("event triggers volume change", function()
        local dispatcher = lurek.event.newDispatcher()
        local volume_set = false

        dispatcher:on("mute", function(data)
            lurek.audio.setMasterVolume(0.0)
            volume_set = true
        end)

        dispatcher:emit("mute", {})
        expect_true(volume_set, "mute handler was called")
        expect_near(0.0, lurek.audio.getMasterVolume(), 0.01, "volume is 0")

        -- Restore
        lurek.audio.setMasterVolume(1.0)
    end)

    -- @covers lurek.audio.getMasterVolume
    -- @covers lurek.event.Dispatcher.emit
    -- @description Verifies an event callback can restore a previously saved audio volume after the system has been muted.
    it("unmute event restores volume", function()
        local dispatcher = lurek.event.newDispatcher()
        local saved_volume = 0.8

        dispatcher:on("unmute", function(data)
            lurek.audio.setMasterVolume(saved_volume)
        end)

        lurek.audio.setMasterVolume(0.0)
        dispatcher:emit("unmute", {})
        expect_near(saved_volume, lurek.audio.getMasterVolume(), 0.01, "volume restored")

        -- Reset
        lurek.audio.setMasterVolume(1.0)
    end)

    -- @covers lurek.audio.setMasterVolume
    -- @covers lurek.event.Dispatcher.on
    -- @description Verifies event payload data flows into the audio API so a slider-style event can set the requested volume level.
    it("volume slider event applies value from data", function()
        local dispatcher = lurek.event.newDispatcher()

        dispatcher:on("volume_change", function(data)
            if data and data.level then
                lurek.audio.setMasterVolume(data.level)
            end
        end)

        dispatcher:emit("volume_change", { level = 0.42 })
        expect_near(0.42, lurek.audio.getMasterVolume(), 0.01, "volume set from event data")

        -- Reset
        lurek.audio.setMasterVolume(1.0)
    end)

    -- @covers lurek.audio
    -- @covers lurek.event.Dispatcher.on
    -- @description Verifies multiple listeners registered on the same event are all invoked for a single audio-related dispatch.
    it("multiple event listeners on same event", function()
        local dispatcher = lurek.event.newDispatcher()
        local call_count = 0

        dispatcher:on("sfx", function(data) call_count = call_count + 1 end)
        dispatcher:on("sfx", function(data) call_count = call_count + 1 end)

        dispatcher:emit("sfx", {})
        expect_equal(2, call_count, "both listeners called")
    end)
end)
test_summary()
