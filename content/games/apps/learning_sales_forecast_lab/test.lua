describe("learning_sales_forecast_lab", function()
    it("computes deterministic recommendation from concrete sales data", function()
        local monthly_sales = { 12100, 12750, 13120, 13800, 14220, 14710, 15180, 14950 }
        local promo_active = { 0, 1, 0, 1, 1, 0, 1, 0 }

        local lstm = lurek.learning.newLstm(2, 4)
        local gru = lurek.learning.newGru(2, 4)

        local lstm_hidden = { 0, 0, 0, 0 }
        local gru_hidden = { 0, 0, 0, 0 }

        for i = 1, #monthly_sales do
            local features = { monthly_sales[i] / 20000.0, promo_active[i] }
            lstm_hidden = lstm:forward(features)
            gru_hidden = gru:forward(features)
        end

        expect_equal(#lstm_hidden, 4)
        expect_equal(#gru_hidden, 4)

        local learner = lurek.learning.newQLearner(3, 3)
        learner:setExplorationRate(0.0)
        learner:setQValue(2, 1, 0.3)
        learner:setQValue(2, 2, 1.4)
        learner:setQValue(2, 3, 0.2)

        local action = learner:bestAction(2)
        expect_equal(action, 2)
    end)
end)

test_summary()
