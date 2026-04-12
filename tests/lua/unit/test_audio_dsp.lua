-- Tests for Real-Time Audio DSP & Buses API
-- Implementing tests for the new flat handles and parameter sweeping logic per audio DSP design

-- @description Covers suite: lurek.audio.create_bus.
describe("lurek.audio.create_bus", function()
    -- @covers lurek.audio.create_bus
    -- @covers lurek.audio.add_effect
    -- @covers lurek.audio.newSource
    -- @covers lurek.audio.play
    -- @covers lurek.audio.remove_effect
    -- @covers lurek.audio.set_bus_volume
    -- @covers lurek.audio.set_effect_param
    -- @description Verifies bus creation is side-effect only and returns no handle.
    it("creates a bus without returning an object", function()
        local result = lurek.audio.create_bus("sfx")
        expect_equal(nil, result)
    end)

    -- @covers lurek.audio.create_bus
    -- @description Verifies create_bus rejects empty bus names.
    it("errors if empty string is provided", function()
        expect_error(function()
            lurek.audio.create_bus("")
        end, "invalid bus name")
    end)
end)

-- @description Covers suite: lurek.audio.set_bus_volume.
describe("lurek.audio.set_bus_volume", function()
    -- @covers lurek.audio.set_bus_volume
    -- @covers lurek.audio.create_bus
    -- @description Verifies bus volume can be changed after creating the named bus.
    it("sets the volume of an existing bus", function()
        lurek.audio.create_bus("music")
        -- Should not error
        lurek.audio.set_bus_volume("music", 0.75)
    end)

    -- @covers lurek.audio.set_bus_volume
    -- @description Verifies set_bus_volume errors when the requested bus name is unknown.
    it("errors if bus does not exist", function()
        expect_error(function()
            lurek.audio.set_bus_volume("nonexistent_bus", 0.5)
        end, "bus not found")
    end)
end)

-- @description Covers suite: lurek.audio.play with bus.
describe("lurek.audio.play with bus", function()
    -- @covers lurek.audio.play
    -- @covers lurek.audio.newSource
    -- @covers lurek.audio.create_bus
    -- @description Verifies play accepts an explicit bus option and returns a numeric playback id.
    it("accepts a bus parameter in options", function()
        lurek.audio.create_bus("ambient")
        local src = lurek.audio.newSource("tests/fixtures/sine_mono_44100.wav", "static")
        local id = lurek.audio.play(src, { bus = "ambient" })
        expect_type("number", id)
    end)

    -- @covers lurek.audio.play
    -- @covers lurek.audio.newSource
    -- @description Verifies play falls back to the master bus when no bus is supplied.
    it("defaults to master bus if none provided", function()
        local src = lurek.audio.newSource("tests/fixtures/sine_mono_44100.wav", "static")
        local id = lurek.audio.play(src, {})
        expect_type("number", id)
    end)

    -- @covers lurek.audio.play
    -- @description Verifies play rejects requests targeting a nonexistent bus name.
    it("errors if bus does not exist", function()
        local src = lurek.audio.newSource("tests/fixtures/sine_mono_44100.wav", "static")
        expect_error(function()
            lurek.audio.play(src, { bus = "fake_bus" })
        end, "bus not found")
    end)
end)

-- @description Covers suite: lurek.audio.add_effect.
describe("lurek.audio.add_effect", function()
    -- @covers lurek.audio.add_effect
    -- @covers lurek.audio.create_bus
    -- @description Verifies adding an effect to a bus returns a numeric effect id.
    it("adds an effect and returns an integer ID", function()
        lurek.audio.create_bus("sfx2")
        local effect_id = lurek.audio.add_effect("sfx2", "lowpass")
        expect_type("number", effect_id)
    end)

    -- @covers lurek.audio.add_effect
    -- @description Verifies add_effect accepts an initial parameter table during construction.
    it("accepts initial parameters", function()
        lurek.audio.create_bus("sfx3")
        local effect_id = lurek.audio.add_effect("sfx3", "reverb", { room_size = 0.8, mix = 0.4 })
        expect_type("number", effect_id)
    end)

    -- @covers lurek.audio.add_effect
    -- @description Verifies unknown effect type names are rejected.
    it("errors on invalid effect type", function()
        lurek.audio.create_bus("sfx4")
        expect_error(function()
            lurek.audio.add_effect("sfx4", "magic_wand")
        end, "invalid effect")
    end)

    -- @covers lurek.audio.add_effect
    -- @description Verifies add_effect fails when the target bus does not exist.
    it("errors if bus does not exist for effect", function()
        expect_error(function()
            lurek.audio.add_effect("nope_bus", "lowpass")
        end, "bus not found")
    end)
end)

-- @description Covers suite: lurek.audio.set_effect_param.
describe("lurek.audio.set_effect_param", function()
    -- @covers lurek.audio.set_effect_param
    -- @covers lurek.audio.add_effect
    -- @description Verifies effect parameters can be mutated after creating an effect instance.
    it("mutates an effect parameter without errors", function()
        lurek.audio.create_bus("music2")
        local efx = lurek.audio.add_effect("music2", "lowpass")
        -- set cutoff
        lurek.audio.set_effect_param("music2", efx, "cutoff", 500.0)
    end)

    -- @covers lurek.audio.set_effect_param
    -- @description Verifies set_effect_param rejects unknown effect ids.
    it("errors if effect ID does not exist", function()
        lurek.audio.create_bus("music3")
        expect_error(function()
            lurek.audio.set_effect_param("music3", 9999, "cutoff", 500.0)
        end, "effect not found")
    end)

    -- @covers lurek.audio.set_effect_param
    -- @description Verifies parameter validation is effect-type specific.
    it("errors if parameter name is invalid for effect type", function()
        lurek.audio.create_bus("music4")
        local efx = lurek.audio.add_effect("music4", "lowpass")
        expect_error(function()
            lurek.audio.set_effect_param("music4", efx, "room_size", 0.5)
        end, "invalid parameter")
    end)
end)

-- @description Covers suite: lurek.audio.remove_effect.
describe("lurek.audio.remove_effect", function()
    -- @covers lurek.audio.remove_effect
    -- @covers lurek.audio.set_effect_param
    -- @description Verifies removing an effect invalidates later parameter writes to that effect id.
    it("removes an existing effect", function()
        lurek.audio.create_bus("sfx5")
        local efx = lurek.audio.add_effect("sfx5", "bandpass")
        lurek.audio.remove_effect("sfx5", efx)

        -- Further operations on it should error
        expect_error(function()
            lurek.audio.set_effect_param("sfx5", efx, "center", 1000.0)
        end, "effect not found")
    end)

    -- @covers lurek.audio.remove_effect
    -- @description Verifies remove_effect rejects unknown effect ids on an otherwise valid bus.
    it("errors if effect not found", function()
        lurek.audio.create_bus("sfx6")
        expect_error(function()
            lurek.audio.remove_effect("sfx6", 1234)
        end, "effect not found")
    end)
end)
test_summary()
