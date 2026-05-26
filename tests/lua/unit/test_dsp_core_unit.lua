--- Unit tests for lurek.dsp core API.
--- @module test_dsp_core_unit

local T = lurek.test

T.group("lurek.dsp existence", function()
    T.test("lurek.dsp table exists", function()
        T.assertNotNil(lurek.dsp)
    end)

    T.test("lurek.dsp.newEffectParams exists", function()
        T.assertNotNil(lurek.dsp.newEffectParams)
        T.assertEqual(type(lurek.dsp.newEffectParams), "function")
    end)

    T.test("lurek.dsp.processOffline exists", function()
        T.assertNotNil(lurek.dsp.processOffline)
        T.assertEqual(type(lurek.dsp.processOffline), "function")
    end)

    T.test("lurek.dsp.normalize exists", function()
        T.assertNotNil(lurek.dsp.normalize)
        T.assertEqual(type(lurek.dsp.normalize), "function")
    end)

    T.test("lurek.dsp.waveformToPng exists", function()
        T.assertNotNil(lurek.dsp.waveformToPng)
        T.assertEqual(type(lurek.dsp.waveformToPng), "function")
    end)

    T.test("lurek.dsp.spectrogramToPng exists", function()
        T.assertNotNil(lurek.dsp.spectrogramToPng)
        T.assertEqual(type(lurek.dsp.spectrogramToPng), "function")
    end)
end)

T.group("lurek.dsp.newEffectParams", function()
    T.test("creates params with correct fields", function()
        local p = lurek.dsp.newEffectParams("lowpass", 1000, 0.7, 0)
        T.assertEqual(p.type, "lowpass")
        T.assertEqual(p.p1, 1000)
        T.assertEqual(p.p2, 0.7)
        T.assertEqual(p.p3, 0)
    end)

    T.test("supports all effect types", function()
        local types = {
            "lowpass", "highpass", "bandpass", "notch",
            "reverb", "delay", "chorus", "flanger",
            "distortion", "bitcrush", "compressor", "limiter",
            "tremolo", "vibrato", "phaser", "gain",
        }
        for _, t in ipairs(types) do
            local p = lurek.dsp.newEffectParams(t, 1, 2, 3)
            T.assertEqual(p.type, t)
        end
    end)
end)

test_summary()
