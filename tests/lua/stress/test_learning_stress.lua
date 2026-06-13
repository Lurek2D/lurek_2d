-- tests/lua/stress/test_learning_stress.lua
-- Stress tests for lurek.learning: large networks, many GA generations, and high-throughput bandit/Q-learner.

local function configure_large_network(net)
    net:addLayer(100, 200, "relu")
    net:addLayer(200, 100, "relu")
    net:addLayer(100, 50, "relu")
    net:addLayer(50, 10, "sigmoid")
end

local function repeated_inputs(count, value)
    local inputs = {}
    for i = 1, count do
        inputs[i] = value
    end
    return inputs
end

local function run_genetic_generations(ga, generations)
    for _ = 1, generations do
        for i = 0, ga:popSize() - 1 do
            ga:setFitness(i, math.random())
        end
        ga:evolve()
    end
end

local function train_q_learner(q, episodes, steps_per_episode)
    q:setLearningRate(0.1)
    q:setDiscountFactor(0.95)
    for _ = 1, episodes do
        local state = math.random(1, 100)
        for _ = 1, steps_per_episode do
            local action = q:chooseAction(state)
            local reward = math.random() * 2 - 1
            local next_state = math.random(1, 100)
            q:learn(state, action, reward, next_state)
            state = next_state
        end
        q:endEpisode()
    end
end

local function train_bandit(bandit, pulls)
    for _ = 1, pulls do
        local arm = bandit:select()
        local reward = math.random()
        bandit:update(arm, reward)
    end
end

local function evolve_neuroevolution(ne, generations, population_size)
    for _ = 1, generations do
        for i = 0, population_size - 1 do
            ne:setFitness(i, math.random())
        end
        ne:evolve()
    end
end

local function validate_large_network_instance(net)
    configure_large_network(net)
    expect_equal(4, net:layerCount())

    local inputs = {}
    for i = 1, 100 do
        inputs[i] = math.random()
    end

    local out = net:forward(inputs)
    expect_equal(10, #out, "output should have 10 elements")
end

local function build_small_forward_net()
    local net = lurek.learning.newNeuralNet()
    net:addLayer(10, 20, "relu")
    net:addLayer(20, 5, "sigmoid")
    return net
end

local function validate_ga_population(ga)
    expect_equal(500, ga:popSize())
    run_genetic_generations(ga, 20)
    expect_equal(20, ga:generation())
end

local function validate_q_training(q)
    train_q_learner(q, 100, 50)
    local v = q:getQValue(1, 1)
    expect_type("number", v, "Q-value should be a number after training")
end

local function validate_bandit_training(bandit)
    train_bandit(bandit, 10000)
    expect_equal(10000, bandit:totalPulls())
    local best = bandit:bestArm()
    expect_true(best >= 0 and best < 20, "best arm should be valid index")
end

local function validate_neuroevolution_run(ne)
    evolve_neuroevolution(ne, 30, 50)
    expect_equal(30, ne:generation())
    local best_net = ne:bestNetwork()
    expect_not_nil(best_net, "bestNetwork should return a net after evolution")
end

-- @describe Learning module stress tests
describe("lurek.learning stress", function()
    -- @stress lurek.learning.newNeuralNet
    it("handles large neural network creation and forward pass", function()
        local net = lurek.learning.newNeuralNet()
        validate_large_network_instance(net)
    end)

    -- @stress LNeuralNet:forward
    it("repeated forward passes do not crash", function()
        local net = build_small_forward_net()
        local inputs = repeated_inputs(10, 0.5)
        for iter = 1, 1000 do
            local out = net:forward(inputs)
            expect_equal(5, #out, "output should have 5 elements at iter " .. iter)
        end
    end)

    -- @stress lurek.learning.newGeneticAlgorithm
    it("handles large population genetic algorithm", function()
        local ga = lurek.learning.newGeneticAlgorithm(500, 100, 42)
        validate_ga_population(ga)
    end)

    -- @stress lurek.learning.newQLearner
    it("handles many Q-learning updates", function()
        local q = lurek.learning.newQLearner(100, 10)
        validate_q_training(q)
    end)

    -- @stress lurek.learning.newBandit
    it("handles many bandit pulls", function()
        local b = lurek.learning.newBandit(20, "ucb1", 0.1, 42)
        validate_bandit_training(b)
    end)

    -- @stress lurek.learning.newNeuroevolution
    it("neuroevolution evolves many generations", function()
        local ne = lurek.learning.newNeuroevolution({
            { inputs = 4, outputs = 8, activation = "relu" },
            { inputs = 8, outputs = 2, activation = "sigmoid" }
        }, 50, 42)
        validate_neuroevolution_run(ne)
    end)
end)
test_summary()
