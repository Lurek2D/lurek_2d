--- Unit tests for lurek.midi core API.

local T = lurek.test

-- @describe lurek.midi
describe("lurek.midi", function()
    -- @covers lurek.midi
    it("lurek.midi table exists", function()
        T.assertNotNil(lurek.midi)
    end)

    -- @covers lurek.midi.newPlayer
    it("lurek.midi.newPlayer creates a player", function()
        T.assertNotNil(lurek.midi.newPlayer)
        T.assertEqual(type(lurek.midi.newPlayer), "function")
        local player = lurek.midi.newPlayer()
        T.assertNotNil(player)
        T.assertEqual(player:type(), "LMidiPlayer")
    end)

    -- @covers lurek.midi.hasSoundFont
    it("lurek.midi.hasSoundFont returns boolean", function()
        T.assertNotNil(lurek.midi.hasSoundFont)
        T.assertEqual(type(lurek.midi.hasSoundFont), "function")
        local has = lurek.midi.hasSoundFont()
        T.assertEqual(type(has), "boolean")
    end)

    -- @covers lurek.midi.loadSoundFont
    it("lurek.midi.loadSoundFont exists", function()
        T.assertNotNil(lurek.midi.loadSoundFont)
        T.assertEqual(type(lurek.midi.loadSoundFont), "function")
    end)

    -- @covers lurek.midi.clearSoundFont
    it("lurek.midi.clearSoundFont exists", function()
        T.assertNotNil(lurek.midi.clearSoundFont)
        T.assertEqual(type(lurek.midi.clearSoundFont), "function")
    end)
end)
test_summary()
