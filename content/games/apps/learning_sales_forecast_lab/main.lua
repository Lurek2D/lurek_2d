local app = {
    ready = false,
    report = {},
}

local MONTHLY_SALES = { 12100, 12750, 13120, 13800, 14220, 14710, 15180, 14950 }
local PROMO_ACTIVE = { 0, 1, 0, 1, 1, 0, 1, 0 }
local PRICE_TIERS = { "eco", "standard", "premium" }
local ACTION_REWARDS = {
    { 0.2, 0.7, 0.1 },
    { 0.3, 1.4, 0.2 },
    { 0.1, 0.4, 1.6 },
}

local function round2(v)
    return math.floor((v * 100) + 0.5) / 100
end

local function run_sales_forecast()
    local lstm = lurek.learning.newLstm(2, 4)
    local gru = lurek.learning.newGru(2, 4)

    local lstm_hidden = { 0, 0, 0, 0 }
    local gru_hidden = { 0, 0, 0, 0 }

    for i = 1, #MONTHLY_SALES do
        local normalized_sales = MONTHLY_SALES[i] / 20000.0
        local promo = PROMO_ACTIVE[i]
        local features = { normalized_sales, promo }
        lstm_hidden = lstm:forward(features)
        gru_hidden = gru:forward(features)
    end

    local learner = lurek.learning.newQLearner(3, 3)
    learner:setExplorationRate(0.0)
    for state = 1, 3 do
        for action = 1, 3 do
            learner:setQValue(state, action, ACTION_REWARDS[state][action])
        end
    end

    local demand_state = 2
    local best_action = learner:bestAction(demand_state)
    local forecast_score = round2((lstm_hidden[1] + gru_hidden[2]) * 100.0)

    return {
        string.format("sales_points=%d", #MONTHLY_SALES),
        string.format("forecast_score=%0.2f", forecast_score),
        string.format("demand_state=%d", demand_state),
        string.format("recommended_tier=%s", PRICE_TIERS[best_action]),
    }
end

function lurek.init()
    app.report = run_sales_forecast()
    for _, line in ipairs(app.report) do
        print("[learning_sales_forecast_lab] " .. line)
    end
    app.ready = true
end

function lurek.process(_dt)
end

function lurek.draw()
end
