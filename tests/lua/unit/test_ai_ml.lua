-- Lurek2D AI — Machine learning primitives: NeuralNet, GeneticAlgorithm, Bandit, Neuroevolution

-- =========================================================================
-- 1. NeuralNet factory
-- =========================================================================
-- @description Verifies the NeuralNet factory and basic inference.
describe("lurek.ai.newNeuralNet factory", function()
    -- @covers lurek.ai.newNeuralNet
    it("exists as a function", function()
        expect_type("function", lurek.ai.newNeuralNet)
    end)

    -- @covers lurek.ai.newNeuralNet
    it("creates a userdata object", function()
        local net = lurek.ai.newNeuralNet()
        expect_type("userdata", net)
    end)

    -- @covers lurek.ai.newNeuralNet
    it("starts with zero layers", function()
        local net = lurek.ai.newNeuralNet()
        expect_equal(net:layerCount(), 0)
    end)

    -- @covers lurek.ai.newNeuralNet
    it("addLayer increments layer count", function()
        local net = lurek.ai.newNeuralNet()
        net:addLayer(2, 4, "relu")
        net:addLayer(4, 1, "sigmoid")
        expect_equal(net:layerCount(), 2)
    end)

    -- @covers lurek.ai.newNeuralNet
    it("forward returns table of correct size", function()
        local net = lurek.ai.newNeuralNet()
        net:addLayer(3, 2, "relu")
        local out = net:forward({0.5, 0.1, 0.9})
        expect_type("table", out)
        expect_equal(#out, 2)
    end)

    -- @covers lurek.ai.newNeuralNet
    it("paramCount is positive after adding layers", function()
        local net = lurek.ai.newNeuralNet()
        net:addLayer(2, 3, "tanh")
        -- 2*3 weights + 3 biases = 9
        expect_equal(net:paramCount(), 9)
    end)

    -- @covers lurek.ai.newNeuralNet
    it("setWeights / getWeights roundtrip", function()
        local net = lurek.ai.newNeuralNet()
        net:addLayer(2, 2, "relu")
        local n = net:paramCount()
        local w = {}
        for i = 1, n do w[i] = i * 0.01 end
        net:setWeights(w)
        local w2 = net:getWeights()
        expect_equal(#w2, n)
        expect_near(w2[1], 0.01, 0.0001)
    end)
end)

-- =========================================================================
-- 2. GeneticAlgorithm factory
-- =========================================================================
-- @description Verifies the GeneticAlgorithm factory and evolution API.
describe("lurek.ai.newGeneticAlgorithm factory", function()
    -- @covers lurek.ai.newGeneticAlgorithm
    it("exists as a function", function()
        expect_type("function", lurek.ai.newGeneticAlgorithm)
    end)

    -- @covers lurek.ai.newGeneticAlgorithm
    it("creates a userdata object", function()
        local ga = lurek.ai.newGeneticAlgorithm(10, 5, 42)
        expect_type("userdata", ga)
    end)

    -- @covers lurek.ai.newGeneticAlgorithm
    it("popSize matches argument", function()
        local ga = lurek.ai.newGeneticAlgorithm(20, 4, 1)
        expect_equal(ga:popSize(), 20)
    end)

    -- @covers lurek.ai.newGeneticAlgorithm
    it("getGenes returns table of expected length", function()
        local ga = lurek.ai.newGeneticAlgorithm(5, 8, 7)
        local genes = ga:getGenes(0)
        expect_type("table", genes)
        expect_equal(#genes, 8)
    end)

    -- @covers lurek.ai.newGeneticAlgorithm
    it("evolve increments generation", function()
        local ga = lurek.ai.newGeneticAlgorithm(6, 4, 3)
        -- Assign trivial fitness before evolve
        for i = 0, 5 do ga:setFitness(i, i * 0.1) end
        local g0 = ga:generation()
        ga:evolve()
        expect_equal(ga:generation(), g0 + 1)
    end)

    -- @covers lurek.ai.newGeneticAlgorithm
    it("bestGenes returns a table", function()
        local ga = lurek.ai.newGeneticAlgorithm(4, 3, 9)
        for i = 0, 3 do ga:setFitness(i, i * 0.5) end
        ga:evolve()
        local best = ga:bestGenes()
        expect_type("table", best)
    end)
end)

-- =========================================================================
-- 3. Bandit factory
-- =========================================================================
-- @description Verifies the Bandit factory and arms API.
describe("lurek.ai.newBandit factory", function()
    -- @covers lurek.ai.newBandit
    it("exists as a function", function()
        expect_type("function", lurek.ai.newBandit)
    end)

    -- @covers lurek.ai.newBandit
    it("creates a userdata object", function()
        local b = lurek.ai.newBandit(5, "epsilon_greedy", 0.1, 42)
        expect_type("userdata", b)
    end)

    -- @covers lurek.ai.newBandit
    it("armCount matches argument", function()
        local b = lurek.ai.newBandit(8, "ucb1", 0.0, 1)
        expect_equal(b:armCount(), 8)
    end)

    -- @covers lurek.ai.newBandit
    it("select returns a valid arm index", function()
        local b = lurek.ai.newBandit(4, "epsilon_greedy", 0.2, 10)
        local idx = b:select()
        expect_equal(idx >= 0 and idx < 4, true)
    end)

    -- @covers lurek.ai.newBandit
    it("update does not crash", function()
        local b = lurek.ai.newBandit(3, "ucb1", 0.0, 5)
        b:update(0, 1.0)
        b:update(1, 0.5)
        b:update(2, 0.8)
        expect_equal(b:totalPulls(), 3)
    end)

    -- @covers lurek.ai.newBandit
    it("bestArm returns a valid index after updates", function()
        local b = lurek.ai.newBandit(3, "ucb1", 0.0, 5)
        b:update(0, 0.1)
        b:update(1, 0.9)
        b:update(2, 0.3)
        expect_equal(b:bestArm() >= 0, true)
    end)

    -- @covers lurek.ai.newBandit
    it("thompson_sampling strategy creates successfully", function()
        local b = lurek.ai.newBandit(4, "thompson", 0.0, 7)
        local idx = b:select()
        expect_equal(idx >= 0 and idx < 4, true)
    end)

    -- @covers lurek.ai.newBandit
    it("reset clears pull history", function()
        local b = lurek.ai.newBandit(2, "epsilon_greedy", 0.5, 99)
        b:update(0, 1.0)
        b:reset()
        expect_equal(b:totalPulls(), 0)
    end)
end)

-- =========================================================================
-- 4. Neuroevolution factory
-- =========================================================================
-- @description Verifies the Neuroevolution factory and basic API.
describe("lurek.ai.newNeuroevolution factory", function()
    -- @covers lurek.ai.newNeuroevolution
    it("exists as a function", function()
        expect_type("function", lurek.ai.newNeuroevolution)
    end)

    -- @covers lurek.ai.newNeuroevolution
    it("creates a userdata object", function()
        local ne = lurek.ai.newNeuroevolution(
            {{inputs=2, outputs=4, activation="relu"},
             {inputs=4, outputs=1, activation="sigmoid"}},
            10, 42)
        expect_type("userdata", ne)
    end)

    -- @covers lurek.ai.newNeuroevolution
    it("popSize matches argument", function()
        local ne = lurek.ai.newNeuroevolution(
            {{inputs=2, outputs=2, activation="relu"}}, 8, 1)
        expect_equal(ne:popSize(), 8)
    end)

    -- @covers lurek.ai.newNeuroevolution
    it("chromosomeToNet returns a NeuralNet userdata", function()
        local ne = lurek.ai.newNeuroevolution(
            {{inputs=2, outputs=2, activation="tanh"}}, 5, 3)
        local net = ne:chromosomeToNet(0)
        expect_type("userdata", net)
    end)

    -- @covers lurek.ai.newNeuroevolution
    it("bestNetwork returns userdata after evolve", function()
        local ne = lurek.ai.newNeuroevolution(
            {{inputs=2, outputs=1, activation="sigmoid"}}, 4, 7)
        for i = 0, 3 do ne:setFitness(i, i * 0.2) end
        ne:evolve()
        local best = ne:bestNetwork()
        expect_type("userdata", best)
    end)

    -- @covers lurek.ai.newNeuroevolution
    it("evolve increments generation", function()
        local ne = lurek.ai.newNeuroevolution(
            {{inputs=1, outputs=1, activation="linear"}}, 4, 11)
        for i = 0, 3 do ne:setFitness(i, 1.0) end
        ne:evolve()
        expect_equal(ne:generation(), 1)
    end)
end)

-- Print summary
test_summary()
