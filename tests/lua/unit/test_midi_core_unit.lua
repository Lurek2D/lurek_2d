--- Unit tests for lurek.midi core API.

local T = lurek.test

-- @describe lurek.midi existence
describe("lurek.midi existence", function()
    -- @covers lurek.midi existence
    it("lurek.midi table exists", function()
        T.assertNotNil(lurek.midi)
    end)

    -- @covers lurek.midi existence
    it("lurek.midi.newPlayer exists", function()
        T.assertNotNil(lurek.midi.newPlayer)
        T.assertEqual(type(lurek.midi.newPlayer), "function")
    end)

    -- @covers lurek.midi existence
    it("lurek.midi.hasSoundFont exists", function()
        T.assertNotNil(lurek.midi.hasSoundFont)
        T.assertEqual(type(lurek.midi.hasSoundFont), "function")
    end)

    -- @covers lurek.midi existence
    it("lurek.midi.loadSoundFont exists", function()
        T.assertNotNil(lurek.midi.loadSoundFont)
        T.assertEqual(type(lurek.midi.loadSoundFont), "function")
    end)

    -- @covers lurek.midi existence
    it("lurek.midi.clearSoundFont exists", function()
        T.assertNotNil(lurek.midi.clearSoundFont)
        T.assertEqual(type(lurek.midi.clearSoundFont), "function")
    end)
end)

-- @describe lurek.midi.newPlayer
describe("lurek.midi.newPlayer", function()
    -- @covers lurek.midi.newPlayer
    it("creates a player", function()
        local player = lurek.midi.newPlayer()
        T.assertNotNil(player)
    end)
end)

-- @describe lurek.midi.hasSoundFont
describe("lurek.midi.hasSoundFont", function()
    -- @covers lurek.midi.hasSoundFont
    it("returns boolean", function()
        local has = lurek.midi.hasSoundFont()
        T.assertEqual(type(has), "boolean")
    end)
end)
test_summary()
