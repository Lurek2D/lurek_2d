-- tests/lua/stress/test_learning_stress.lua
-- Stress tests for lurek.learning: large networks, many GA generations, and high-throughput bandit/Q-learner.

-- @describe Learning module stress tests
describe("lurek.learning stress", function()
    -- @stress lurek.learning.newNeuralNet
    it("handles large neural network creation and forward pass", function()
        local net = lurek.learning.newNeuralNet()
        net:addLayer(100, 200, "relu")
        net:addLayer(200, 100, "relu")
        net:addLayer(100, 50, "relu")
        net:addLayer(50, 10, "sigmoid")
        expect_equal(4, net:layerCount())
        -- Run forward pass with 100 inputs
        local inputs = {}
        for i = 1, 100 do inputs[i] = math.random() end
        local out = net:forward(inputs)
        expect_equal(10, #out, "output should have 10 elements")
    end)

    -- @stress lurek.learning.newNeuralNet
    it("repeated forward passes do not crash", function()
        local net = lurek.learning.newNeuralNet()
        net:addLayer(10, 20, "relu")
        net:addLayer(20, 5, "sigmoid")
        local inputs = {}
        for i = 1, 10 do inputs[i] = 0.5 end
        for iter = 1, 1000 do
            local out = net:forward(inputs)
            expect_equal(5, #out, "output should have 5 elements at iter " .. iter)
        end
    end)

    -- @stress lurek.learning.newGeneticAlgorithm
    it("handles large population genetic algorithm", function()
        local ga = lurek.learning.newGeneticAlgorithm(500, 100, 42)
        expect_equal(500, ga:popSize())
        -- Set fitness and evolve through several generations
        for gen = 1, 20 do
            for i = 0, 499 do
                ga:setFitness(i, math.random())
            end
            ga:evolve()
        end
        expect_equal(20, ga:generation())
    end)

    -- @stress lurek.learning.newQLearner
    it("handles many Q-learning updates", function()
        local q = lurek.learning.newQLearner(100, 10)
        q:setLearningRate(0.1)
        q:setDiscountFactor(0.95)
        -- Simulate many episodes
        for ep = 1, 100 do
            local state = math.random(1, 100)
            for step = 1, 50 do
                local action = q:chooseAction(state)
                local reward = math.random() * 2 - 1
                local next_state = math.random(1, 100)
                q:learn(state, action, reward, next_state)
                state = next_state
            end
            q:endEpisode()
        end
        -- Verify some Q-value was learned
        local v = q:getQValue(1, 1)
        expect_type("number", v, "Q-value should be a number after training")
    end)

    -- @stress lurek.learning.newBandit
    it("handles many bandit pulls", function()
        local b = lurek.learning.newBandit(20, "ucb1", 0.1, 42)
        for i = 1, 10000 do
            local arm = b:select()
            local reward = math.random()
            b:update(arm, reward)
        end
        expect_equal(10000, b:totalPulls())
        local best = b:bestArm()
        expect_true(best >= 0 and best < 20, "best arm should be valid index")
    end)

    -- @stress lurek.learning.newNeuroevolution
    it("neuroevolution evolves many generations", function()
        local ne = lurek.learning.newNeuroevolution({
            { inputs = 4, outputs = 8, activation = "relu" },
            { inputs = 8, outputs = 2, activation = "sigmoid" }
        }, 50, 42)
        for gen = 1, 30 do
            for i = 0, 49 do
                ne:setFitness(i, math.random())
            end
            ne:evolve()
        end
        expect_equal(30, ne:generation())
        local best_net = ne:bestNetwork()
        expect_not_nil(best_net, "bestNetwork should return a net after evolution")
    end)
end)

test_summary()
