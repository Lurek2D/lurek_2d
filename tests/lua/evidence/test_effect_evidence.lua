-- Evidence tests: effect module
-- Artifacts are generated through lurek.effect constructors, stack ordering, and capture-state APIs.
-- This file intentionally avoids file-level @covers markers; evidence ownership is described per artifact block.

local OUT = evidence_output_dir("effect")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

describe("Evidence: lurek.effect API", function()
    before_each(function()
        ensure_evidence_dir("effect")
    end)

    -- Does: Runs "exports stack ordering after insert, remove, and dedup" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.effect.newStack, LPostFxStack:insert, LPostFxStack:remove, and LPostFxStack:dedup without needing a special evidence-only renderer.
    -- Artifact: tests/artifacts/current/effect/effect_stack_state.json
    -- Why: This is meaningful only if the serialized order and enabled handles come from lurek.effect stack mutation APIs rather than from helper-only bookkeeping.
    it("exports stack ordering after insert remove and dedup", function()
        local stack = lurek.effect.newStack(320, 180)
        local blur = lurek.effect.newEffect("blur")
        local bloom = lurek.effect.newEffect("bloom")
        local crt = lurek.effect.newEffect("crt")

        stack:add(bloom)
        stack:insert(1, blur)
        stack:add(crt)
        stack:add(blur)
        local removed = stack:dedup()
        stack:setEnabled(2, false)
        stack:remove(crt)

        local enabled = stack:getEnabledEffects()
        local effect1 = stack:getEffect(1)
        local effect2 = stack:getEffect(2)
        local json = string.format(
            '{"count":%d,"removed":%d,"first":"%s","second":"%s","enabled_count":%d,"enabled_first":"%s"}',
            stack:getEffectCount(),
            removed,
            effect1:getTypeName(),
            effect2:getTypeName(),
            #enabled,
            enabled[1] and enabled[1]:getTypeName() or "nil"
        )
        write_text(OUT .. "effect_stack_state.json", json)
    end)

    -- Does: Runs "exports capture lifecycle and preset metadata" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.effect.newPresetStack, LPostFxStack:beginCapture, LPostFxStack:endCapture, and lurek.effect.getPresetNames.
    -- Artifact: tests/artifacts/current/effect/effect_capture_preset_state.json
    -- Why: This is meaningful only if the recorded lifecycle flags and preset metadata come directly from the effect owner API.
    it("exports capture lifecycle and preset metadata", function()
        local stack = lurek.effect.newPresetStack("retro_tv", 256, 144)
        local before = stack:isCapturing()
        stack:beginCapture()
        local during = stack:isCapturing()
        stack:apply()
        stack:endCapture()
        local after = stack:isCapturing()

        local preset_names = lurek.effect.getPresetNames()
        local json = string.format(
            '{"before":%s,"during":%s,"after":%s,"width":%d,"height":%d,"effect_count":%d,"preset_count":%d}',
            tostring(before),
            tostring(during),
            tostring(after),
            stack:getWidth(),
            stack:getHeight(),
            stack:getEffectCount(),
            #preset_names
        )
        write_text(OUT .. "effect_capture_preset_state.json", json)
    end)

    -- Does: Runs "exports image-effect chain metadata" and turns the owner-module result into an inspectable artifact.
    -- Shows: The artifact should expose the behavior produced by lurek.effect.newImageEffect, LImageEffect:getEffectCount, and LImageEffect:getEffect.
    -- Artifact: tests/artifacts/current/effect/effect_image_chain_state.json
    -- Why: This is meaningful only if the serialized chain summary comes from effect owner methods rather than helper-side reconstruction.
    it("exports image-effect chain metadata", function()
        local image_effect = lurek.effect.newImageEffect({
            { type = "blur", radius = 3.0, strength = 0.5 },
            { type = "bloom", threshold = 0.7, intensity = 1.2 },
        })
        local first = image_effect:getEffect(1)
        local second = image_effect:getEffect(2)
        local json = string.format(
            '{"count":%d,"first":"%s","second":"%s","first_radius":%.2f,"second_intensity":%.2f}',
            image_effect:getEffectCount(),
            first:getType(),
            second:getType(),
            first:getParameter("radius", 0.0),
            second:getParameter("intensity", 0.0)
        )
        write_text(OUT .. "effect_image_chain_state.json", json)
    end)
end)

test_summary()
