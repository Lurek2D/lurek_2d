-- Stress coverage for tilefield data plus tilelight over large multi-level fields.

-- @describe tilefield stress
describe("tilefield stress", function()
    -- @stress lurek.tilefield.new
    -- @stress lurek.tilelight.new
    it("computes colored lighting and exports on 100x100x4 field under budget", function()
        local field = lurek.tilefield.new({ width = 100, height = 100, levels = 4 })
        field:setProfile("light_filter", {
            blocks = { move = true, vision = false, action = true, light = false },
            costs = { light = 0.45 },
            sunOcclusion = 0.35,
        })
        for level = 1, 4 do
            for i = 1, 250 do
                local x = (i * 17 + level * 3) % 100 + 1
                local y = (i * 29 + level * 5) % 100 + 1
                local profile = "wall"
                if i % 5 == 0 then
                    profile = "light_filter"
                elseif i % 3 == 0 then
                    profile = "window"
                end
                field:applyProfile(x, y, level, profile)
            end
        end

        local light_map = lurek.tilelight.new(field)
        for i = 1, 40 do
            light_map:addPointLight({
                x = (i * 11) % 100 + 1,
                y = (i * 19) % 100 + 1,
                z = i % 4 + 1,
                radius = 10 + (i % 4),
                intensity = 0.35 + (i % 5) * 0.08,
                color = {
                    r = ((i * 3) % 10) / 10,
                    g = ((i * 7) % 10) / 10,
                    b = ((i * 5 + 4) % 10) / 10,
                },
            })
        end

        light_map:setGlobalLight({ intensity = 0.25, color = { r = 1, g = 0.72, b = 0.38 } })
        local started = os.clock()
        light_map:compute({ includePointLights = true, includeGlobalLight = true })
        local elapsed = os.clock() - started

        local move = field:exportBlockLayer("move", 1)
        local light = light_map:exportLayer(1)
        expect_equal(10000, #move)
        expect_equal(10000, #light)
        expect_true(elapsed < 0.75, "tilelight compute stress budget exceeded: " .. tostring(elapsed))
    end)
end)

test_summary()
