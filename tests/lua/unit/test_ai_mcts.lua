-- Lurek2D AI — MCTSEngine tests

-- =========================================================================
-- 1. Factory
-- =========================================================================
-- @description Verifies the MCTSEngine factory and basic API.
describe("lurek.ai.newMCTSEngine factory", function()
    -- @covers lurek.ai.newMCTSEngine
    it("exists as a function", function()
        expect_type("function", lurek.ai.newMCTSEngine)
    end)

    -- @covers lurek.ai.newMCTSEngine
    it("creates a userdata object", function()
        local mcts = lurek.ai.newMCTSEngine(50, 1.41, 10, 42)
        expect_type("userdata", mcts)
    end)
end)

-- =========================================================================
-- 2. Search
-- =========================================================================
-- @description Verifies the search() closure-based API with a trivial game.
--
-- Trivial game: state = integer 0..5.  Actions: +1 or +2.
-- Evaluate: higher state = better score.  Best first action from 0 = +2.
describe("MCTSEngine search", function()
    -- @covers lurek.ai.newMCTSEngine
    it("returns an integer action from search", function()
        local mcts = lurek.ai.newMCTSEngine(100, 1.41, 5, 42)
        local function get_actions(state)
            if state >= 5 then return {} end
            return {1, 2}
        end
        local function apply_action(state, action)
            return state + action
        end
        local function evaluate(state)
            return state / 5.0
        end
        local action = mcts:search(0, get_actions, apply_action, evaluate)
        expect_type("number", action)
    end)

    -- @covers lurek.ai.newMCTSEngine
    it("returns nil when no actions available from root", function()
        local mcts = lurek.ai.newMCTSEngine(50, 1.41, 5, 1)
        local action = mcts:search(
            100,
            function(_) return {} end,
            function(s, a) return s + a end,
            function(s) return s * 0.01 end
        )
        expect_equal(action, nil)
    end)

    -- @covers lurek.ai.newMCTSEngine
    it("prefers higher reward action", function()
        local mcts = lurek.ai.newMCTSEngine(200, 1.41, 8, 99)
        -- Game: state is a bank balance. Action 1 adds 1, action 2 adds 10.
        -- Evaluate linearly.  Best action always 2.
        local action = mcts:search(
            0,
            function(s)
                if s >= 20 then return {} end
                return {1, 2}
            end,
            function(s, a)
                return s + a
            end,
            function(s)
                return s / 20.0
            end
        )
        expect_equal(action, 2)
    end)
end)

-- Print summary
test_summary()
