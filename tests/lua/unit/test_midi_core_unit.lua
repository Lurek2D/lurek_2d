--- Unit tests for lurek.midi core API.
--- @module test_midi_core_unit

local T = lurek.test

T.group("lurek.midi existence", function()
    T.test("lurek.midi table exists", function()
        T.assertNotNil(lurek.midi)
    end)

    T.test("lurek.midi.newPlayer exists", function()
        T.assertNotNil(lurek.midi.newPlayer)
        T.assertEqual(type(lurek.midi.newPlayer), "function")
    end)

    T.test("lurek.midi.hasSoundFont exists", function()
        T.assertNotNil(lurek.midi.hasSoundFont)
        T.assertEqual(type(lurek.midi.hasSoundFont), "function")
    end)

    T.test("lurek.midi.loadSoundFont exists", function()
        T.assertNotNil(lurek.midi.loadSoundFont)
        T.assertEqual(type(lurek.midi.loadSoundFont), "function")
    end)

    T.test("lurek.midi.clearSoundFont exists", function()
        T.assertNotNil(lurek.midi.clearSoundFont)
        T.assertEqual(type(lurek.midi.clearSoundFont), "function")
    end)
end)

T.group("lurek.midi.newPlayer", function()
    T.test("creates a player", function()
        local player = lurek.midi.newPlayer()
        T.assertNotNil(player)
    end)
end)

T.group("lurek.midi.hasSoundFont", function()
    T.test("returns boolean", function()
        local has = lurek.midi.hasSoundFont()
        T.assertEqual(type(has), "boolean")
    end)
end)

test_summary()
