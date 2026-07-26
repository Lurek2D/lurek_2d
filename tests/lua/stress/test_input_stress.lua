-- Stress coverage for isolated player-owned input contexts.

-- @describe input stress: isolated player contexts
describe("input stress: isolated player contexts", function()
    -- @stress lurek.input.newPlayerContext
    it("keeps 256 contexts with local action maps isolated", function()
        local contexts = {}
        for player = 1, 256 do
            local context = lurek.input.newPlayerContext(player)
            for action = 1, 16 do
                context:defineButton("action_" .. action, { bindings = { "keyboard:a" } })
            end
            contexts[player] = context
        end
        expect_true(contexts[1]:removeAction("action_1"))
        expect_false(contexts[1]:removeAction("action_1"))
        expect_true(contexts[256]:removeAction("action_1"))
    end)
end)

test_summary()
