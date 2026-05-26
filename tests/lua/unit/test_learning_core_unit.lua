-- Unit tests for lurek.learning neural network module.

-- @describe lurek.learning module unit tests
describe("lurek.learning", function()
    -- @covers lurek.learning.newNeuralNet
    it("creates a neural network", function()
        local net = lurek.learning.newNeuralNet()
        expect_true(net ~= nil, "network should be created")
        expect_equal(net:layerCount(), 0)
    end)

    -- @covers lurek.learning.newNeuralNet
    it("adds layers and runs forward pass", function()
        local net = lurek.learning.newNeuralNet()
        net:addLayer(2, 3, "relu")
        net:addLayer(3, 1, "sigmoid")
        expect_equal(net:layerCount(), 2)
        expect_equal(net:paramCount(), 2 * 3 + 3 + 3 * 1 + 1)
        local out = net:forward({0.5, 0.5})
        expect_true(#out == 1, "output should have 1 element")
    end)

    -- @covers lurek.learning.newGeneticAlgorithm
    it("creates a genetic algorithm", function()
        local ga = lurek.learning.newGeneticAlgorithm(20, 5, 42)
        expect_true(ga ~= nil, "GA should be created")
        expect_equal(ga:popSize(), 20)
        expect_equal(ga:generation(), 0)
    end)

    -- @covers lurek.learning.newGeneticAlgorithm
    it("evolves a generation", function()
        local ga = lurek.learning.newGeneticAlgorithm(10, 4, 123)
        ga:setFitness(0, 1.0)
        ga:setFitness(1, 0.5)
        ga:evolve()
        expect_equal(ga:generation(), 1)
    end)

    -- @covers lurek.learning.newQLearner
    it("creates a q-learner", function()
        local q = lurek.learning.newQLearner(5, 3)
        expect_true(q ~= nil, "qlearner should be created")
        expect_equal(q:getStateCount(), 5)
        expect_equal(q:getActionCount(), 3)
    end)

    -- @covers lurek.learning.newQLearner
    it("learns from transitions", function()
        local q = lurek.learning.newQLearner(3, 2)
        q:setLearningRate(0.5)
        q:learn(1, 1, 1.0, 2)
        local v = q:getQValue(1, 1)
        expect_true(v > 0, "Q-value should increase after positive reward")
    end)

    -- @covers lurek.learning.newBandit
    it("creates a bandit with ucb1 strategy", function()
        local b = lurek.learning.newBandit(5, "ucb1", 0.1, 42)
        expect_true(b ~= nil, "bandit should be created")
        expect_equal(b:armCount(), 5)
        expect_equal(b:totalPulls(), 0)
    end)

    -- @covers lurek.learning.newBandit
    it("selects and updates arms", function()
        local b = lurek.learning.newBandit(3, "epsilon_greedy", 0.1, 99)
        local arm = b:select()
        expect_true(arm >= 0 and arm < 3, "arm should be valid index")
        b:update(arm, 1.0)
        expect_equal(b:totalPulls(), 1)
    end)

    -- @covers lurek.learning.newNeuroevolution
    it("creates neuroevolution population", function()
        local ne = lurek.learning.newNeuroevolution({
            { inputs = 2, outputs = 4, activation = "relu" },
            { inputs = 4, outputs = 1, activation = "sigmoid" }
        }, 10, 42)
        expect_true(ne ~= nil, "neuroevolution should be created")
        expect_equal(ne:popSize(), 10)
        expect_equal(ne:generation(), 0)
    end)

    -- @covers lurek.learning.newNeuroevolution
    it("converts chromosome to network", function()
        local ne = lurek.learning.newNeuroevolution({
            { inputs = 2, outputs = 3, activation = "tanh" }
        }, 5, 7)
        local net = ne:chromosomeToNet(0)
        expect_true(net ~= nil, "should convert chromosome 0 to net")
        expect_equal(net:layerCount(), 1)
    end)
end)

test_summary()
