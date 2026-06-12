-- Canonical unit coverage for lurek.midi.

local MIDI_FILE = "content/examples/assets/audio/sample_midi.mid"
local SOUND_FONT = "work/lua_midi_unit/minimal_soundfont.sf2"

local function write_minimal_soundfont()
    write_file(
        SOUND_FONT,
        string.char(82, 73, 70, 70, 0, 0, 0, 0, 115, 102, 98, 107)
    )
end

-- @describe lurek.midi module
describe("lurek.midi module", function()
    before_each(function()
        lurek.midi.clearSoundFont()
        write_minimal_soundfont()
    end)

    after_each(function()
        lurek.midi.clearSoundFont()
    end)

    -- @covers lurek.midi.newPlayer
    it("newPlayer returns a midi player even when parsing is disabled", function()
        local player = lurek.midi.newPlayer(MIDI_FILE)
        expect_equal("LMidiPlayer", player:type())
        expect_false(player:isLoaded())
        expect_nil(player:getFilePath())
    end)

    -- @covers lurek.midi.loadSoundFont
    it("loadSoundFont loads a valid sf2 fixture", function()
        local loaded = lurek.midi.loadSoundFont(SOUND_FONT)
        expect_true(loaded)
        expect_true(lurek.midi.hasSoundFont())
    end)

    -- @covers lurek.midi.hasSoundFont
    it("hasSoundFont reflects the global soundfont state", function()
        expect_false(lurek.midi.hasSoundFont())
        expect_true(lurek.midi.loadSoundFont(SOUND_FONT))
        expect_true(lurek.midi.hasSoundFont())
    end)

    -- @covers lurek.midi.clearSoundFont
    it("clearSoundFont removes the loaded soundfont", function()
        expect_true(lurek.midi.loadSoundFont(SOUND_FONT))
        expect_true(lurek.midi.hasSoundFont())
        lurek.midi.clearSoundFont()
        expect_false(lurek.midi.hasSoundFont())
    end)
end)

test_summary()
