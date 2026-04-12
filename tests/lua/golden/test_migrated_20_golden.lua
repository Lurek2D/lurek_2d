local function evidence_output_dir()
    return lurek.fs.getAppDir() .. "/tests/lua/golden/evidence_output/migrated_20"
end

local function sample_dir()
    return "tests/lua/golden/samples/migrated_20"
end

local function check_png(name)
    local out = evidence_output_dir() .. "/" .. name .. ".png"
    local sample = sample_dir() .. "/" .. name .. ".png"
    expect_golden_file_match(out, sample, 0.05) -- allow 5% difference for rendering variance
end

local function check_wav(name)
    local out = evidence_output_dir() .. "/" .. name .. ".wav"
    local sample = sample_dir() .. "/" .. name .. ".wav"
    expect_golden_file_match(out, sample, 0.05)
end

-- @description Covers suite: Migrated Golden Tests 20.
describe("Migrated Golden Tests 20", function()
    -- @golden
    -- @covers check_png
    -- @description Compares the generated sprite_8x8 PNG evidence image against the migrated_20 sprite_8x8 golden sample.
    it("matches fixture_sprite_8x8", function() check_png("sprite_8x8") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated sprite_16x16 PNG evidence image against the migrated_20 sprite_16x16 golden sample.
    it("matches fixture_sprite_16x16", function() check_png("sprite_16x16") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated sprite_32x32 PNG evidence image against the migrated_20 sprite_32x32 golden sample.
    it("matches fixture_sprite_32x32", function() check_png("sprite_32x32") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated sprite_64x64 PNG evidence image against the migrated_20 sprite_64x64 golden sample.
    it("matches fixture_sprite_64x64", function() check_png("sprite_64x64") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated tileset_128x128 PNG evidence image against the migrated_20 tileset golden sample.
    it("matches fixture_tileset_128x128", function() check_png("tileset_128x128") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated gradient_horizontal PNG evidence image against the migrated_20 horizontal gradient golden sample.
    it("matches fixture_gradient_horizontal", function() check_png("gradient_horizontal") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated gradient_vertical PNG evidence image against the migrated_20 vertical gradient golden sample.
    it("matches fixture_gradient_vertical", function() check_png("gradient_vertical") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated bezier_curve PNG evidence image against the migrated_20 math bezier golden sample.
    it("matches evidence_math_bezier_curve", function() check_png("bezier_curve") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated bezier_multiple_curves PNG evidence image against the migrated_20 multi-curve bezier golden sample.
    it("matches evidence_math_bezier_multiple", function() check_png("bezier_multiple_curves") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated stereo_two_tones WAV evidence artifact against the migrated_20 stereo audio golden sample.
    it("matches evidence_audio_stereo", function() check_wav("stereo_two_tones") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated frequency_sweep_100_4000 WAV evidence artifact against the migrated_20 sweep audio golden sample.
    it("matches evidence_audio_frequency_sweep", function() check_wav("frequency_sweep_100_4000") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated amplitude_envelope WAV evidence artifact against the migrated_20 envelope audio golden sample.
    it("matches evidence_audio_amplitude_envelope", function() check_wav("amplitude_envelope") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated square_wave_440hz WAV evidence artifact against the migrated_20 square-wave audio golden sample.
    it("matches evidence_audio_square_wave", function() check_wav("square_wave_440hz") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated sawtooth_wave_440hz WAV evidence artifact against the migrated_20 sawtooth-wave audio golden sample.
    it("matches evidence_audio_sawtooth_wave", function() check_wav("sawtooth_wave_440hz") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated white_noise WAV evidence artifact against the migrated_20 white-noise audio golden sample.
    it("matches evidence_audio_white_noise", function() check_wav("white_noise") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated silence_half_second WAV evidence artifact against the migrated_20 silence golden sample.
    it("matches evidence_audio_silence", function() check_wav("silence_half_second") end)
    -- @golden
    -- @covers check_wav
    -- @description Compares the generated waveform_sine_440hz_audio WAV evidence artifact against the migrated_20 waveform visualization golden sample.
    it("matches evidence_audio_waveform_visualization", function() check_wav("waveform_sine_440hz_audio") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated noise_heightmap_colored PNG evidence image against the migrated_20 noise heightmap golden sample.
    it("matches evidence_noise_to_heightmap_render", function() check_png("noise_heightmap_colored") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated all_effects_grid PNG evidence image against the migrated_20 image effects golden sample.
    it("matches evidence_image_all_effects_grid", function() check_png("all_effects_grid") end)
    -- @golden
    -- @covers check_png
    -- @description Compares the generated multi_layer PNG evidence image against the migrated_20 tilemap golden sample.
    it("matches evidence_tilemap_multi_layer", function() check_png("multi_layer") end)
end)

test_summary()
