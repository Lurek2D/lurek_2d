-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_learning_core_unit.lua
do
-- Unit tests for lurek.learning neural network module.

local function new_qlearner(states, actions)
    return lurek.learning.newQLearner(states or 5, actions or 3)
end

local function new_two_layer_net()
    local net = lurek.learning.newNeuralNet()
    net:addLayer(2, 3, "relu")
    net:addLayer(3, 1, "sigmoid")
    return net
end

local function new_bandit()
    return lurek.learning.newBandit(3, "epsilon_greedy", 0.0, 99)
end

local function new_ga(pop_size, gene_count, seed)
    return lurek.learning.newGeneticAlgorithm(pop_size or 6, gene_count or 4, seed or 42)
end

local function new_neuroevolution(pop_size, seed)
    return lurek.learning.newNeuroevolution({
        { inputs = 2, outputs = 3, activation = "tanh" },
        { inputs = 3, outputs = 1, activation = "sigmoid" }
    }, pop_size or 5, seed or 7)
end

local function new_lstm(input_size, hidden_size)
    return lurek.learning.newLstm(input_size or 2, hidden_size or 3)
end

local function new_gru(input_size, hidden_size)
    return lurek.learning.newGru(input_size or 2, hidden_size or 3)
end

local function new_conv2d()
    return lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
end

local function new_pool2d()
    return lurek.learning.newMaxPool2D(2, 2, 2, 2)
end

local function new_positional_encoding()
    return lurek.learning.newPositionalEncoding(4, 16)
end

local function new_mha()
    return lurek.learning.newMultiHeadAttention(4, 2)
end

local function new_transformer_encoder()
    return lurek.learning.newTransformerEncoder(4, 2, 8)
end

local function new_transformer_decoder()
    return lurek.learning.newTransformerDecoder(4, 2, 8)
end

local function load_onnx_model()
    return lurek.learning.loadOnnx("tests/lua_reorg/fixtures/minimal_identity.onnx")
end

local function zeros(count)
    local values = {}
    for i = 1, count do
        values[i] = 0.0
    end
    return values
end

local function expect_vector_close(expected, actual, tolerance)
    expect_equal(#expected, #actual)
    for i = 1, #expected do
        expect_near(expected[i], actual[i], tolerance or 1e-6)
    end
end

-- @describe lurek.learning module unit tests
describe("lurek.learning", function()
    -- @covers lurek.learning.newNeuralNet
    it("creates a neural network", function()
        local net = lurek.learning.newNeuralNet()
        expect_true(net ~= nil, "network should be created")
        expect_equal(net:layerCount(), 0)
    end)

    -- @covers LNeuralNet:forward
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

    -- @covers LGeneticAlgorithm:evolve
    it("evolves a generation", function()
        local ga = lurek.learning.newGeneticAlgorithm(10, 4, 123)
        ga:setFitness(0, 1.0)
        ga:setFitness(1, 0.5)
        ga:evolve()
        expect_equal(ga:generation(), 1)
    end)

    -- @covers LGeneticAlgorithm:generation
    it("generation returns the current generation index", function()
        local ga = new_ga(5, 3, 11)
        expect_equal(0, ga:generation())
        ga:setFitness(0, 1.0)
        ga:evolve()
        expect_equal(1, ga:generation())
    end)

    -- @covers LGeneticAlgorithm:popSize
    it("popSize returns the configured population size", function()
        local ga = new_ga(9, 3, 11)
        expect_equal(9, ga:popSize())
    end)

    -- @covers LGeneticAlgorithm:setFitness
    it("setFitness changes which chromosome is considered best", function()
        local ga = new_ga(4, 3, 22)
        local genes = ga:getGenes(1)
        ga:setFitness(1, 5.0)
        local best = ga:bestGenes()
        expect_equal(#genes, #best)
        for i = 1, #genes do
            expect_near(genes[i], best[i], 1e-6)
        end
    end)

    -- @covers LGeneticAlgorithm:getGenes
    it("getGenes returns the chromosome genes by zero-based index", function()
        local ga = new_ga(4, 5, 33)
        local genes = ga:getGenes(0)
        expect_equal(5, #genes)
    end)

    -- @covers LGeneticAlgorithm:bestGenes
    it("bestGenes returns the genes for the highest-fitness chromosome", function()
        local ga = new_ga(4, 4, 44)
        local chosen = ga:getGenes(2)
        ga:setFitness(2, 9.0)
        ga:setFitness(1, 1.0)
        local best = ga:bestGenes()
        expect_equal(#chosen, #best)
        for i = 1, #chosen do
            expect_near(chosen[i], best[i], 1e-6)
        end
    end)

    -- @covers LGeneticAlgorithm:type
    it("type returns LGeneticAlgorithm", function()
        local ga = new_ga()
        expect_equal("LGeneticAlgorithm", ga:type())
    end)

    -- @covers LGeneticAlgorithm:typeOf
    it("typeOf recognizes genetic algorithms and objects", function()
        local ga = new_ga()
        expect_true(ga:typeOf("LGeneticAlgorithm"))
        expect_true(ga:typeOf("LObject"))
        expect_false(ga:typeOf("LNeuroevolution"))
    end)

    -- @covers lurek.learning.newQLearner
    it("creates a q-learner", function()
        local q = lurek.learning.newQLearner(5, 3)
        expect_true(q ~= nil, "qlearner should be created")
        expect_equal(q:getStateCount(), 5)
        expect_equal(q:getActionCount(), 3)
    end)

    -- @covers LQLearner:learn
    it("learns from transitions", function()
        local q = lurek.learning.newQLearner(3, 2)
        q:setLearningRate(0.5)
        q:learn(1, 1, 1.0, 2)
        local v = q:getQValue(1, 1)
        expect_true(v > 0, "Q-value should increase after positive reward")
    end)

    -- @covers lurek.learning.wrap
    it("wrap creates a generic model wrapper", function()
        local q = new_qlearner(4, 2)
        local model = lurek.learning.wrap(q)
        expect_equal("LModel", model:type())
    end)

    -- @covers LModel:predict
    it("predict delegates to the wrapped model", function()
        local q = new_qlearner(4, 2)
        q:setExplorationRate(0.0)
        q:setQValue(1, 2, 5.0)
        local model = lurek.learning.wrap(q)
        expect_equal(2, model:predict(1))
    end)

    -- @covers LModel:type
    it("type returns LModel", function()
        local model = lurek.learning.wrap(new_bandit())
        expect_equal("LModel", model:type())
    end)

    -- @covers LModel:typeOf
    it("typeOf recognizes model wrappers and objects", function()
        local model = lurek.learning.wrap(new_two_layer_net())
        expect_true(model:typeOf("LModel"))
        expect_true(model:typeOf("LObject"))
        expect_false(model:typeOf("LNeuralNet"))
    end)

    -- @covers lurek.learning.newBandit
    it("creates a bandit with ucb1 strategy", function()
        local b = lurek.learning.newBandit(5, "ucb1", 0.1, 42)
        expect_true(b ~= nil, "bandit should be created")
        expect_equal(b:armCount(), 5)
        expect_equal(b:totalPulls(), 0)
    end)

    -- @covers LBandit:select
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

    -- @covers LNeuroevolution:chromosomeToNet
    it("converts chromosome to network", function()
        local ne = lurek.learning.newNeuroevolution({
            { inputs = 2, outputs = 3, activation = "tanh" }
        }, 5, 7)
        local net = ne:chromosomeToNet(0)
        expect_true(net ~= nil, "should convert chromosome 0 to net")
        expect_equal(net:layerCount(), 1)
    end)

    -- @covers LNeuroevolution:evolve
    it("evolve advances the neuroevolution generation", function()
        local ne = new_neuroevolution(4, 17)
        ne:setFitness(0, 1.0)
        ne:evolve()
        expect_equal(1, ne:generation())
    end)

    -- @covers LNeuroevolution:setFitness
    it("setFitness updates the best fitness score", function()
        local ne = new_neuroevolution(4, 18)
        ne:setFitness(1, 7.5)
        expect_equal(7.5, ne:bestFitness())
    end)

    -- @covers LNeuroevolution:bestNetwork
    it("bestNetwork matches the chromosome with the highest fitness", function()
        local ne = new_neuroevolution(4, 19)
        ne:setFitness(2, 6.0)
        local expected = ne:chromosomeToNet(2)
        local best = ne:bestNetwork()
        local input = {0.25, -0.5}
        expect_vector_close(expected:forward(input), best:forward(input), 1e-6)
    end)

    -- @covers LNeuroevolution:bestFitness
    it("bestFitness returns the maximum assigned chromosome fitness", function()
        local ne = new_neuroevolution(4, 20)
        ne:setFitness(0, 1.25)
        ne:setFitness(3, 2.5)
        expect_equal(2.5, ne:bestFitness())
    end)

    -- @covers LNeuroevolution:popSize
    it("popSize returns the neuroevolution population size", function()
        local ne = new_neuroevolution(6, 21)
        expect_equal(6, ne:popSize())
    end)

    -- @covers LNeuroevolution:generation
    it("generation returns the current neuroevolution generation", function()
        local ne = new_neuroevolution(4, 22)
        expect_equal(0, ne:generation())
    end)

    -- @covers LNeuroevolution:type
    it("type returns LNeuroevolution", function()
        local ne = new_neuroevolution()
        expect_equal("LNeuroevolution", ne:type())
    end)

    -- @covers LNeuroevolution:typeOf
    it("typeOf recognizes neuroevolution handles and objects", function()
        local ne = new_neuroevolution()
        expect_true(ne:typeOf("LNeuroevolution"))
        expect_true(ne:typeOf("LObject"))
        expect_false(ne:typeOf("LGeneticAlgorithm"))
    end)

    -- @covers LQLearner:chooseAction
    it("chooseAction follows greedy policy when exploration is zero", function()
        local q = new_qlearner()
        q:setExplorationRate(0.0)
        q:setQValue(1, 1, 0.5)
        q:setQValue(1, 2, 2.0)
        expect_equal(2, q:chooseAction(1))
    end)

    -- @covers LQLearner:bestAction
    it("bestAction returns the highest valued action", function()
        local q = new_qlearner()
        q:setQValue(1, 1, 0.5)
        q:setQValue(1, 2, 1.2)
        q:setQValue(1, 3, 0.8)
        expect_equal(2, q:bestAction(1))
    end)

    -- @covers LQLearner:getQValue
    it("getQValue returns stored q-values", function()
        local q = new_qlearner(10, 4)
        q:setQValue(2, 3, 7.5)
        expect_equal(7.5, q:getQValue(2, 3))
    end)

    -- @covers LQLearner:setQValue
    it("setQValue stores values for state-action pairs", function()
        local q = new_qlearner(8, 4)
        q:setQValue(3, 2, 4.2)
        expect_equal(4.2, q:getQValue(3, 2))
    end)

    -- @covers LQLearner:endEpisode
    it("endEpisode decays exploration and increments episode count", function()
        local q = new_qlearner(8, 4)
        q:setExplorationRate(0.8)
        q:setExplorationDecay(0.5)
        q:endEpisode()
        expect_equal(1, q:getEpisodeCount())
        expect_equal(0.4, q:getExplorationRate())
    end)

    -- @covers LQLearner:getEpisodeCount
    it("getEpisodeCount returns completed episode count", function()
        local q = new_qlearner(10, 4)
        q:endEpisode()
        q:endEpisode()
        expect_equal(2, q:getEpisodeCount())
    end)

    -- @covers LQLearner:getStateCount
    it("getStateCount returns learner state capacity", function()
        local q = new_qlearner(5, 3)
        expect_equal(5, q:getStateCount())
    end)

    -- @covers LQLearner:getActionCount
    it("getActionCount returns learner action capacity", function()
        local q = new_qlearner(5, 3)
        expect_equal(3, q:getActionCount())
    end)

    -- @covers LQLearner:setLearningRate
    it("setLearningRate updates alpha", function()
        local q = new_qlearner(10, 4)
        q:setLearningRate(0.05)
        expect_equal(0.05, q:getLearningRate())
    end)

    -- @covers LQLearner:getLearningRate
    it("getLearningRate returns alpha", function()
        local q = new_qlearner(10, 4)
        q:setLearningRate(0.05)
        expect_equal(0.05, q:getLearningRate())
    end)

    -- @covers LQLearner:setDiscountFactor
    it("setDiscountFactor updates gamma", function()
        local q = new_qlearner(10, 4)
        q:setDiscountFactor(0.95)
        expect_equal(0.95, q:getDiscountFactor())
    end)

    -- @covers LQLearner:getDiscountFactor
    it("getDiscountFactor returns gamma", function()
        local q = new_qlearner(10, 4)
        q:setDiscountFactor(0.95)
        expect_equal(0.95, q:getDiscountFactor())
    end)

    -- @covers LQLearner:setExplorationRate
    it("setExplorationRate updates epsilon", function()
        local q = new_qlearner(10, 4)
        q:setExplorationRate(0.35)
        expect_equal(0.35, q:getExplorationRate())
    end)

    -- @covers LQLearner:getExplorationRate
    it("getExplorationRate returns epsilon", function()
        local q = new_qlearner(10, 4)
        q:setExplorationRate(0.35)
        expect_equal(0.35, q:getExplorationRate())
    end)

    -- @covers LQLearner:setExplorationDecay
    it("setExplorationDecay updates epsilon decay", function()
        local q = new_qlearner(10, 4)
        q:setExplorationDecay(0.97)
        expect_equal(0.97, q:getExplorationDecay())
    end)

    -- @covers LQLearner:getExplorationDecay
    it("getExplorationDecay returns epsilon decay", function()
        local q = new_qlearner(10, 4)
        q:setExplorationDecay(0.97)
        expect_equal(0.97, q:getExplorationDecay())
    end)

    -- @covers LQLearner:serialize
    it("serialize exports learner state", function()
        local q = new_qlearner(5, 3)
        q:setQValue(1, 1, 1.5)
        local json = q:serialize()
        expect_type("string", json)
        expect_true(#json > 0)
    end)

    -- @covers LQLearner:deserialize
    it("deserialize restores learner state", function()
        local source = new_qlearner(5, 3)
        source:setQValue(2, 3, 3.14)
        local saved = source:serialize()
        local restored = new_qlearner(5, 3)
        restored:deserialize(saved)
        expect_equal(3.14, restored:getQValue(2, 3))
    end)

    -- @covers LQLearner:type
    it("type returns LQLearner", function()
        local q = new_qlearner(10, 4)
        expect_equal("LQLearner", q:type())
    end)

    -- @covers LQLearner:typeOf
    it("typeOf recognizes qlearner and object", function()
        local q = new_qlearner(10, 4)
        expect_true(q:typeOf("LQLearner"))
        expect_true(q:typeOf("LObject"))
        expect_false(q:typeOf("LNeuralNet"))
    end)

    -- @covers LQLearner:predict
    it("predict aliases chooseAction", function()
        local q = new_qlearner(4, 2)
        q:setExplorationRate(0.0)
        q:setQValue(1, 2, 2.0)
        expect_equal(2, q:predict(1))
    end)

    -- @covers LNeuralNet:addLayer
    it("addLayer appends a layer definition", function()
        local net = lurek.learning.newNeuralNet()
        net:addLayer(2, 3, "relu")
        expect_equal(1, net:layerCount())
    end)

    -- @covers LNeuralNet:setWeights
    it("setWeights accepts exact parameter counts", function()
        local net = new_two_layer_net()
        local weights = {}
        for i = 1, net:paramCount() do
            weights[i] = 0.0
        end
        expect_true(net:setWeights(weights))
    end)

    -- @covers LNeuralNet:getWeights
    it("getWeights exports all trainable weights", function()
        local net = new_two_layer_net()
        local weights = net:getWeights()
        expect_equal(net:paramCount(), #weights)
    end)

    -- @covers LNeuralNet:paramCount
    it("paramCount returns total trainable parameters", function()
        local net = new_two_layer_net()
        expect_equal(13, net:paramCount())
    end)

    -- @covers LNeuralNet:layerCount
    it("layerCount returns the number of layers", function()
        local net = new_two_layer_net()
        expect_equal(2, net:layerCount())
    end)

    -- @covers LNeuralNet:type
    it("type returns LNeuralNet", function()
        local net = lurek.learning.newNeuralNet()
        expect_equal("LNeuralNet", net:type())
    end)

    -- @covers LNeuralNet:typeOf
    it("typeOf recognizes neural nets and objects", function()
        local net = lurek.learning.newNeuralNet()
        expect_true(net:typeOf("LNeuralNet"))
        expect_true(net:typeOf("LObject"))
        expect_false(net:typeOf("LQLearner"))
    end)

    -- @covers LNeuralNet:predict
    it("predict aliases forward", function()
        local net = new_two_layer_net()
        local out = net:predict({0.5, 0.5})
        expect_equal(1, #out)
    end)

    -- @covers LBandit:update
    it("update records rewards for arms", function()
        local b = new_bandit()
        b:update(1, 1.0)
        expect_equal(1, b:totalPulls())
    end)

    -- @covers LBandit:bestArm
    it("bestArm returns the highest valued arm", function()
        local b = new_bandit()
        b:update(0, 0.0)
        b:update(1, 2.0)
        expect_equal(1, b:bestArm())
    end)

    -- @covers LBandit:reset
    it("reset clears accumulated pulls", function()
        local b = new_bandit()
        b:update(0, 1.0)
        b:reset()
        expect_equal(0, b:totalPulls())
    end)

    -- @covers LBandit:armCount
    it("armCount returns configured arm count", function()
        local b = lurek.learning.newBandit(5, "ucb1", 0.1, 42)
        expect_equal(5, b:armCount())
    end)

    -- @covers LBandit:totalPulls
    it("totalPulls returns the number of updates", function()
        local b = new_bandit()
        b:update(1, 1.0)
        expect_equal(1, b:totalPulls())
    end)

    -- @covers LBandit:type
    it("type returns LBandit", function()
        local b = new_bandit()
        expect_equal("LBandit", b:type())
    end)

    -- @covers LBandit:typeOf
    it("typeOf recognizes bandits and objects", function()
        local b = new_bandit()
        expect_true(b:typeOf("LBandit"))
        expect_true(b:typeOf("LObject"))
        expect_false(b:typeOf("LQLearner"))
    end)

    -- @covers LBandit:predict
    it("predict aliases select", function()
        local b = new_bandit()
        local arm = b:predict()
        expect_true(arm >= 0 and arm < 3)
    end)

    -- @covers lurek.learning.defineEnv
    it("defineEnv returns LEnv with correct type", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0, 0.0} end,
            step  = function(a) return {{0.1, 0.2}, 1.0, false, {}} end,
            obs_space    = { shape = {2}, low = {-1}, high = {1} },
            action_space = { shape = {1}, low = {0}, high = {3}, n = 4 },
        })
        expect_true(env ~= nil, "env should be created")
        expect_equal(env:type(), "LEnv")
        expect_true(env:typeOf("LEnv"), "typeOf LEnv")
        expect_true(env:typeOf("LObject"), "typeOf LObject")
        expect_true(not env:typeOf("LBandit"), "typeOf LBandit false")
    end)

    -- @covers LEnv:type
    it("type returns LEnv", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0} end,
            step  = function() return {{0.0}, 0.0, false, {}} end,
            obs_space = { shape = {1}, low = {-1}, high = {1} },
            action_space = { n = 2 },
        })
        expect_equal("LEnv", env:type())
    end)

    -- @covers LEnv:typeOf
    it("typeOf recognizes env and object", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0} end,
            step  = function() return {{0.0}, 0.0, false, {}} end,
            obs_space = { shape = {1}, low = {-1}, high = {1} },
            action_space = { n = 2 },
        })
        expect_true(env:typeOf("LEnv"))
        expect_true(env:typeOf("LObject"))
        expect_false(env:typeOf("LFrameStack"))
    end)

    -- @covers LEnv:obsSpace
    it("LEnv:obsSpace and actionSpace return tables", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0} end,
            step  = function(a) return {{0.0}, 0.0, false, {}} end,
            obs_space    = { shape = {3}, low = {-1}, high = {1} },
            action_space = { n = 4 },
        })
        local obs = env:obsSpace()
        expect_true(obs ~= nil, "obsSpace not nil")
        expect_equal(#obs.shape, 1)
        expect_equal(obs.shape[1], 3)
        local act = env:actionSpace()
        expect_true(act ~= nil, "actionSpace not nil")
        expect_equal(act.n, 4)
    end)

    -- @covers LEnv:actionSpace
    it("LEnv:actionSpace exposes action metadata", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0} end,
            step  = function(a) return {{0.0}, 0.0, false, {}} end,
            obs_space    = { shape = {1}, low = {-1}, high = {1} },
            action_space = { n = 3, low = {0}, high = {2} },
        })
        local act = env:actionSpace()
        expect_equal(3, act.n)
        expect_equal(0, act.low[1])
        expect_equal(2, act.high[1])
    end)

    -- @covers LEnv:reset
    it("LEnv:reset returns obs table", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {1.0, 2.0, 3.0} end,
            step  = function(a) return {{0.0, 0.0, 0.0}, 0.0, false, {}} end,
            obs_space    = { shape = {3}, low = {-1}, high = {1} },
            action_space = { n = 2 },
        })
        local obs = env:reset()
        expect_true(obs ~= nil, "obs not nil")
        expect_equal(#obs, 3)
        expect_equal(obs[1], 1.0)
    end)

    -- @covers LEnv:step
    it("LEnv:step returns obs, reward, done, info", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0} end,
            step  = function(a) return {{0.5}, 2.5, false, {score=99}} end,
            obs_space    = { shape = {1}, low = {0}, high = {1} },
            action_space = { n = 2 },
        })
        local obs, reward, done, info = env:step(1)
        expect_true(obs ~= nil, "obs not nil")
        expect_equal(obs[1], 0.5)
        expect_equal(reward, 2.5)
        expect_true(not done, "not done yet")
    end)

    -- @covers lurek.learning.frameStack
    it("frameStack returns LFrameStack with correct type", function()
        local fs = lurek.learning.frameStack(3)
        expect_true(fs ~= nil, "frame stack created")
        expect_equal(fs:type(), "LFrameStack")
        expect_true(fs:typeOf("LFrameStack"), "typeOf LFrameStack")
        expect_true(fs:typeOf("LObject"), "typeOf LObject")
        expect_equal(fs:capacity(), 3)
    end)

    -- @covers LFrameStack:get
    it("LFrameStack:push and get return flat vector", function()
        local fs = lurek.learning.frameStack(3)
        fs:push({1.0, 2.0})
        fs:push({3.0, 4.0})
        local flat = fs:get()
        -- 3 frames * 2 dims = 6 elements (last frame zero-padded)
        expect_equal(#flat, 6)
        -- first frame: 1,2 (oldest pushed first but capacity*dim padded)
        expect_true(flat[1] ~= nil, "flat[1] not nil")
    end)

    -- @covers LFrameStack:push
    it("push records frames up to capacity", function()
        local fs = lurek.learning.frameStack(2)
        fs:push({1.0})
        fs:push({2.0})
        expect_equal(2, #fs:get())
    end)

    -- @covers LFrameStack:reset
    it("LFrameStack:reset clears frames", function()
        local fs = lurek.learning.frameStack(2)
        fs:push({1.0})
        fs:push({2.0})
        fs:reset()
        local flat = fs:get()
        -- After reset with no dim info, returns empty/zeros
        expect_equal(#flat, 0)
    end)

    -- @covers LFrameStack:capacity
    it("capacity returns retained frame count", function()
        local fs = lurek.learning.frameStack(5)
        expect_equal(5, fs:capacity())
    end)

    -- @covers LFrameStack:type
    it("type returns LFrameStack", function()
        local fs = lurek.learning.frameStack(3)
        expect_equal("LFrameStack", fs:type())
    end)

    -- @covers LFrameStack:typeOf
    it("typeOf recognizes frame stacks and objects", function()
        local fs = lurek.learning.frameStack(3)
        expect_true(fs:typeOf("LFrameStack"))
        expect_true(fs:typeOf("LObject"))
        expect_false(fs:typeOf("LTensor"))
    end)

    -- @covers lurek.learning.normalizeEnv
    it("normalizeEnv wraps an env and type is LEnv", function()
        local base = lurek.learning.defineEnv({
            reset = function() return {2.0, 4.0} end,
            step  = function(a) return {{2.0, 4.0}, 1.0, false, {}} end,
            obs_space    = { shape = {2}, low = {0}, high = {10} },
            action_space = { n = 2 },
        })
        local wrapped = lurek.learning.normalizeEnv(base, {1.0, 2.0}, {1.0, 2.0})
        expect_true(wrapped ~= nil, "wrapped env not nil")
        expect_equal(wrapped:type(), "LEnv")
        local obs = wrapped:reset()
        -- (2-1)/1 = 1.0, (4-2)/2 = 1.0
        expect_true(math.abs(obs[1] - 1.0) < 0.001, "obs[1] normalized")
        expect_true(math.abs(obs[2] - 1.0) < 0.001, "obs[2] normalized")
    end)

    -- @covers lurek.learning.timeLimit
    it("timeLimit forces done after max_steps", function()
        local env = lurek.learning.defineEnv({
            reset = function() return {0.0} end,
            step  = function(a) return {{0.0}, 0.0, false, {}} end,
            obs_space    = { shape = {1}, low = {0}, high = {1} },
            action_space = { n = 2 },
        })
        local limited = lurek.learning.timeLimit(env, 3)
        expect_equal(limited:type(), "LEnv")
        limited:reset()
        local _, _, done1 = limited:step(1)
        local _, _, done2 = limited:step(1)
        local _, _, done3 = limited:step(1)
        expect_true(not done1, "step 1 not done")
        expect_true(not done2, "step 2 not done")
        expect_true(done3, "step 3 done (time limit reached)")
    end)

    -- @covers lurek.learning.newTensor
    it("newTensor creates LTensor with correct type", function()
        local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
        expect_true(t ~= nil, "tensor should be created")
        expect_equal(t:type(), "LTensor")
        expect_true(t:typeOf("LTensor"), "typeOf LTensor")
        expect_true(t:typeOf("LObject"), "typeOf LObject")
        expect_true(not t:typeOf("LOnnxModel"), "typeOf LOnnxModel false")
    end)

    -- @covers LTensor:shape
    it("LTensor:shape returns correct dimensions", function()
        local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
        local s = t:shape()
        expect_equal(#s, 2)
        expect_equal(s[1], 2)
        expect_equal(s[2], 3)
    end)

    -- @covers LTensor:data
    it("LTensor:data returns flat element array", function()
        local t = lurek.learning.newTensor({3}, {10.5, 20.5, 30.5})
        local d = t:data()
        expect_equal(#d, 3)
        expect_true(math.abs(d[1] - 10.5) < 0.001, "d[1] close to 10.5")
        expect_true(math.abs(d[2] - 20.5) < 0.001, "d[2] close to 20.5")
        expect_true(math.abs(d[3] - 30.5) < 0.001, "d[3] close to 30.5")
    end)

    -- @covers LTensor:len
    it("LTensor:len returns total element count", function()
        local t = lurek.learning.newTensor({4, 2}, {1, 2, 3, 4, 5, 6, 7, 8})
        expect_equal(t:len(), 8)
    end)

    -- @covers LTensor:get
    it("LTensor:get returns element by one-based index", function()
        local t = lurek.learning.newTensor({3}, {7.0, 8.0, 9.0})
        expect_true(math.abs(t:get(1) - 7.0) < 0.001, "get(1) = 7.0")
        expect_true(math.abs(t:get(2) - 8.0) < 0.001, "get(2) = 8.0")
        expect_true(math.abs(t:get(3) - 9.0) < 0.001, "get(3) = 9.0")
    end)

    -- @covers LTensor:type
    it("LTensor:get out of bounds returns error", function()
        local t = lurek.learning.newTensor({2}, {1.0, 2.0})
        expect_equal("LTensor", t:type())
        local ok, err = pcall(function() return t:get(5) end)
        expect_true(not ok, "out-of-bounds get should error")
        expect_true(err ~= nil, "error message not nil")
    end)

    -- @covers LTensor:typeOf
    it("typeOf recognizes tensors and objects", function()
        local t = lurek.learning.newTensor({1}, {0.0})
        expect_true(t:typeOf("LTensor"))
        expect_true(t:typeOf("LObject"))
        expect_false(t:typeOf("LOnnxModel"))
    end)

    -- @covers lurek.learning.loadOnnx
    it("loadOnnx on missing file returns error", function()
        local ok, err = pcall(function()
            return lurek.learning.loadOnnx("nonexistent_does_not_exist.onnx")
        end)
        expect_true(not ok, "missing file should return error")
        expect_true(err ~= nil, "error message not nil")
    end)

    -- @covers lurek.learning.newLstm
    it("newLstm creates LLSTM and supports forward/reset", function()
        local lstm = new_lstm()
        expect_true(lstm ~= nil, "lstm should be created")
        expect_equal(lstm:type(), "LLSTM")
        local out = lstm:forward({0.1, -0.2})
        expect_equal(#out, 3)
        lstm:reset()
        expect_true(lstm:setWeights(zeros(lstm:paramCount())), "setWeights should accept exact param count")
    end)

    -- @covers LLSTM:forward
    it("forward returns one hidden-state vector per call", function()
        local lstm = new_lstm()
        local out = lstm:forward({0.1, -0.2})
        expect_equal(3, #out)
    end)

    -- @covers LLSTM:reset
    it("reset restores the recurrent state to its initial output path", function()
        local lstm = new_lstm()
        local first = lstm:forward({0.1, -0.2})
        lstm:forward({0.1, -0.2})
        lstm:reset()
        local after_reset = lstm:forward({0.1, -0.2})
        expect_vector_close(first, after_reset, 1e-6)
    end)

    -- @covers LLSTM:setWeights
    it("setWeights accepts a full flattened parameter array", function()
        local lstm = new_lstm()
        expect_true(lstm:setWeights(zeros(lstm:paramCount())))
    end)

    -- @covers LLSTM:getWeights
    it("getWeights returns the flattened lstm parameters", function()
        local lstm = new_lstm()
        expect_equal(lstm:paramCount(), #lstm:getWeights())
    end)

    -- @covers LLSTM:paramCount
    it("paramCount returns the number of trainable lstm parameters", function()
        local lstm = new_lstm()
        expect_true(lstm:paramCount() > 0)
    end)

    -- @covers LLSTM:type
    it("type returns LLSTM", function()
        local lstm = new_lstm()
        expect_equal("LLSTM", lstm:type())
    end)

    -- @covers LLSTM:typeOf
    it("typeOf recognizes lstm wrappers and objects", function()
        local lstm = new_lstm()
        expect_true(lstm:typeOf("LLSTM"))
        expect_true(lstm:typeOf("LObject"))
        expect_false(lstm:typeOf("LGRU"))
    end)

    -- @covers lurek.learning.newGru
    it("newGru creates LGRU and supports forward/reset", function()
        local gru = new_gru()
        expect_true(gru ~= nil, "gru should be created")
        expect_equal(gru:type(), "LGRU")
        local out = gru:forward({0.1, -0.2})
        expect_equal(#out, 3)
        gru:reset()
    end)

    -- @covers LGRU:forward
    it("forward returns one hidden-state vector for the gru layer", function()
        local gru = new_gru()
        expect_equal(3, #gru:forward({0.1, -0.2}))
    end)

    -- @covers LGRU:reset
    it("reset restores the gru hidden state to its initial output path", function()
        local gru = new_gru()
        local first = gru:forward({0.1, -0.2})
        gru:forward({0.1, -0.2})
        gru:reset()
        local after_reset = gru:forward({0.1, -0.2})
        expect_vector_close(first, after_reset, 1e-6)
    end)

    -- @covers LGRU:setWeights
    it("setWeights accepts a full flattened gru parameter array", function()
        local gru = new_gru()
        expect_true(gru:setWeights(zeros(gru:paramCount())))
    end)

    -- @covers LGRU:getWeights
    it("getWeights returns the flattened gru parameters", function()
        local gru = new_gru()
        expect_equal(gru:paramCount(), #gru:getWeights())
    end)

    -- @covers LGRU:paramCount
    it("paramCount returns the number of trainable gru parameters", function()
        local gru = new_gru()
        expect_true(gru:paramCount() > 0)
    end)

    -- @covers LGRU:type
    it("type returns LGRU", function()
        local gru = new_gru()
        expect_equal("LGRU", gru:type())
    end)

    -- @covers LGRU:typeOf
    it("typeOf recognizes gru wrappers and objects", function()
        local gru = new_gru()
        expect_true(gru:typeOf("LGRU"))
        expect_true(gru:typeOf("LObject"))
        expect_false(gru:typeOf("LLSTM"))
    end)

    -- @covers lurek.learning.newConv2D
    it("newConv2D forward returns tensor", function()
        local conv = new_conv2d()
        expect_true(conv ~= nil, "conv should be created")
        local input = lurek.learning.newTensor({1, 2, 2}, {1.0, 2.0, 3.0, 4.0})
        local out = conv:forward(input)
        expect_true(out ~= nil, "conv forward should return tensor")
        local shape = out:shape()
        expect_equal(shape[1], 1)
        expect_equal(shape[2], 2)
        expect_equal(shape[3], 2)
    end)

    -- @covers LConv2D:forward
    it("forward preserves the expected output tensor geometry", function()
        local conv = new_conv2d()
        local out = conv:forward(lurek.learning.newTensor({1, 2, 2}, {1.0, 2.0, 3.0, 4.0}))
        local shape = out:shape()
        expect_equal(1, shape[1])
        expect_equal(2, shape[2])
        expect_equal(2, shape[3])
    end)

    -- @covers LConv2D:setWeights
    it("setWeights accepts a full flattened conv parameter array", function()
        local conv = new_conv2d()
        expect_true(conv:setWeights(zeros(conv:paramCount())))
    end)

    -- @covers LConv2D:getWeights
    it("getWeights returns the flattened conv parameters", function()
        local conv = new_conv2d()
        expect_equal(conv:paramCount(), #conv:getWeights())
    end)

    -- @covers LConv2D:paramCount
    it("paramCount returns the number of trainable conv parameters", function()
        local conv = new_conv2d()
        expect_equal(2, conv:paramCount())
    end)

    -- @covers LConv2D:type
    it("type returns LConv2D", function()
        local conv = new_conv2d()
        expect_equal("LConv2D", conv:type())
    end)

    -- @covers LConv2D:typeOf
    it("typeOf recognizes conv wrappers and objects", function()
        local conv = new_conv2d()
        expect_true(conv:typeOf("LConv2D"))
        expect_true(conv:typeOf("LObject"))
        expect_false(conv:typeOf("LMaxPool2D"))
    end)

    -- @covers lurek.learning.newMaxPool2D
    it("newMaxPool2D forward downsamples tensor", function()
        local pool = new_pool2d()
        expect_true(pool ~= nil, "pool should be created")
        local input = lurek.learning.newTensor({1, 4, 4}, {
            1, 5, 2, 3,
            7, 4, 0, 6,
            9, 1, 8, 2,
            3, 2, 4, 1,
        })
        local out = pool:forward(input)
        local shape = out:shape()
        expect_equal(shape[1], 1)
        expect_equal(shape[2], 2)
        expect_equal(shape[3], 2)
    end)

    -- @covers LMaxPool2D:forward
    it("forward returns the maximum value from each pooling window", function()
        local pool = new_pool2d()
        local input = lurek.learning.newTensor({1, 4, 4}, {
            1, 5, 2, 3,
            7, 4, 0, 6,
            9, 1, 8, 2,
            3, 2, 4, 1,
        })
        local out = pool:forward(input)
        local data = out:data()
        expect_equal(4, #data)
        expect_equal(7, data[1])
        expect_equal(6, data[2])
        expect_equal(9, data[3])
        expect_equal(8, data[4])
    end)

    -- @covers LMaxPool2D:type
    it("type returns LMaxPool2D", function()
        local pool = new_pool2d()
        expect_equal("LMaxPool2D", pool:type())
    end)

    -- @covers LMaxPool2D:typeOf
    it("typeOf recognizes max-pool wrappers and objects", function()
        local pool = new_pool2d()
        expect_true(pool:typeOf("LMaxPool2D"))
        expect_true(pool:typeOf("LObject"))
        expect_false(pool:typeOf("LConv2D"))
    end)

    -- @covers lurek.learning.newPositionalEncoding
    it("newPositionalEncoding apply returns encoded tensor", function()
        local pe = new_positional_encoding()
        expect_true(pe ~= nil, "positional encoding should be created")
        local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
        local encoded = pe:apply(x)
        expect_true(encoded ~= nil, "encoded tensor should be returned")
        local d = encoded:data()
        expect_true(math.abs(d[1]) > 0 or math.abs(d[2]) > 0, "encoding should change values")
    end)

    -- @covers LPositionalEncoding:apply
    it("apply injects positional values into the input tensor", function()
        local pe = new_positional_encoding()
        local out = pe:apply(lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0}))
        local data = out:data()
        expect_true(math.abs(data[1]) > 0 or math.abs(data[2]) > 0)
    end)

    -- @covers LPositionalEncoding:type
    it("type returns LPositionalEncoding", function()
        local pe = new_positional_encoding()
        expect_equal("LPositionalEncoding", pe:type())
    end)

    -- @covers LPositionalEncoding:typeOf
    it("typeOf recognizes positional encodings and objects", function()
        local pe = new_positional_encoding()
        expect_true(pe:typeOf("LPositionalEncoding"))
        expect_true(pe:typeOf("LObject"))
        expect_false(pe:typeOf("LMultiHeadAttention"))
    end)

    -- @covers lurek.learning.newMultiHeadAttention
    it("newMultiHeadAttention forward returns tensor", function()
        local mha = new_mha()
        expect_true(mha ~= nil, "mha should be created")
        local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
        local out = mha:forward(x)
        local shape = out:shape()
        expect_equal(shape[1], 2)
        expect_equal(shape[2], 4)
    end)

    -- @covers LMultiHeadAttention:forward
    it("forward preserves the sequence length and model width", function()
        local mha = new_mha()
        local out = mha:forward(lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0}))
        local shape = out:shape()
        expect_equal(2, shape[1])
        expect_equal(4, shape[2])
    end)

    -- @covers LMultiHeadAttention:setWeights
    it("setWeights accepts a full flattened mha parameter array", function()
        local mha = new_mha()
        expect_true(mha:setWeights(zeros(mha:paramCount())))
    end)

    -- @covers LMultiHeadAttention:getWeights
    it("getWeights returns the flattened mha parameters", function()
        local mha = new_mha()
        expect_equal(mha:paramCount(), #mha:getWeights())
    end)

    -- @covers LMultiHeadAttention:paramCount
    it("paramCount returns the number of trainable mha parameters", function()
        local mha = new_mha()
        expect_true(mha:paramCount() > 0)
    end)

    -- @covers LMultiHeadAttention:type
    it("type returns LMultiHeadAttention", function()
        local mha = new_mha()
        expect_equal("LMultiHeadAttention", mha:type())
    end)

    -- @covers LMultiHeadAttention:typeOf
    it("typeOf recognizes mha wrappers and objects", function()
        local mha = new_mha()
        expect_true(mha:typeOf("LMultiHeadAttention"))
        expect_true(mha:typeOf("LObject"))
        expect_false(mha:typeOf("LPositionalEncoding"))
    end)

    -- @covers lurek.learning.newTransformerEncoder
    it("newTransformerEncoder forward returns tensor", function()
        local enc = new_transformer_encoder()
        expect_true(enc ~= nil, "encoder should be created")
        local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
        local out = enc:forward(x)
        local shape = out:shape()
        expect_equal(shape[1], 2)
        expect_equal(shape[2], 4)
    end)

    -- @covers LTransformerEncoder:forward
    it("forward preserves the encoder tensor geometry", function()
        local enc = new_transformer_encoder()
        local out = enc:forward(lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1}))
        local shape = out:shape()
        expect_equal(2, shape[1])
        expect_equal(4, shape[2])
    end)

    -- @covers LTransformerEncoder:setWeights
    it("setWeights accepts a full flattened encoder parameter array", function()
        local enc = new_transformer_encoder()
        expect_true(enc:setWeights(zeros(enc:paramCount())))
    end)

    -- @covers LTransformerEncoder:getWeights
    it("getWeights returns the flattened encoder parameters", function()
        local enc = new_transformer_encoder()
        expect_equal(enc:paramCount(), #enc:getWeights())
    end)

    -- @covers LTransformerEncoder:paramCount
    it("paramCount returns the number of trainable encoder parameters", function()
        local enc = new_transformer_encoder()
        expect_true(enc:paramCount() > 0)
    end)

    -- @covers LTransformerEncoder:type
    it("type returns LTransformerEncoder", function()
        local enc = new_transformer_encoder()
        expect_equal("LTransformerEncoder", enc:type())
    end)

    -- @covers LTransformerEncoder:typeOf
    it("typeOf recognizes encoder wrappers and objects", function()
        local enc = new_transformer_encoder()
        expect_true(enc:typeOf("LTransformerEncoder"))
        expect_true(enc:typeOf("LObject"))
        expect_false(enc:typeOf("LTransformerDecoder"))
    end)

    -- @covers lurek.learning.newTransformerDecoder
    it("newTransformerDecoder forward returns tensor", function()
        local dec = new_transformer_decoder()
        expect_true(dec ~= nil, "decoder should be created")
        local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
        local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
        local out = dec:forward(x, e)
        local shape = out:shape()
        expect_equal(shape[1], 2)
        expect_equal(shape[2], 4)
    end)

    -- @covers LTransformerDecoder:forward
    it("forward preserves the decoder tensor geometry", function()
        local dec = new_transformer_decoder()
        local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
        local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
        local out = dec:forward(x, e)
        local shape = out:shape()
        expect_equal(2, shape[1])
        expect_equal(4, shape[2])
    end)

    -- @covers LTransformerDecoder:setWeights
    it("setWeights accepts a full flattened decoder parameter array", function()
        local dec = new_transformer_decoder()
        expect_true(dec:setWeights(zeros(dec:paramCount())))
    end)

    -- @covers LTransformerDecoder:getWeights
    it("getWeights returns the flattened decoder parameters", function()
        local dec = new_transformer_decoder()
        expect_equal(dec:paramCount(), #dec:getWeights())
    end)

    -- @covers LTransformerDecoder:paramCount
    it("paramCount returns the number of trainable decoder parameters", function()
        local dec = new_transformer_decoder()
        expect_true(dec:paramCount() > 0)
    end)

    -- @covers LTransformerDecoder:type
    it("type returns LTransformerDecoder", function()
        local dec = new_transformer_decoder()
        expect_equal("LTransformerDecoder", dec:type())
    end)

    -- @covers LTransformerDecoder:typeOf
    it("typeOf recognizes decoder wrappers and objects", function()
        local dec = new_transformer_decoder()
        expect_true(dec:typeOf("LTransformerDecoder"))
        expect_true(dec:typeOf("LObject"))
        expect_false(dec:typeOf("LTransformerEncoder"))
    end)

    -- @covers LOnnxModel:run
    it("OnnxModel:run executes inference and returns output tensors", function()
        local model = load_onnx_model()
        local input = lurek.learning.newTensor({1}, {42.0})
        local outputs = model:run({ input })
        expect_type("table", outputs)
        expect_equal(1, #outputs)
        expect_equal("LTensor", outputs[1]:type())
        expect_near(42.0, outputs[1]:data()[1], 0.001)
    end)

    -- @covers LOnnxModel:inputCount
    it("OnnxModel:inputCount reports the number of model inputs", function()
        local model = load_onnx_model()
        expect_equal(1, model:inputCount())
    end)

    -- @covers LOnnxModel:outputCount
    it("OnnxModel:outputCount reports the number of model outputs", function()
        local model = load_onnx_model()
        expect_equal(1, model:outputCount())
    end)

    -- @covers LOnnxModel:type
    it("OnnxModel:type returns the userdata type name", function()
        local model = load_onnx_model()
        expect_equal("LOnnxModel", model:type())
    end)

    -- @covers LOnnxModel:typeOf
    it("OnnxModel:typeOf recognizes model and object inheritance", function()
        local model = load_onnx_model()
        expect_true(model:typeOf("LOnnxModel"))
        expect_true(model:typeOf("LObject"))
        expect_false(model:typeOf("LTensor"))
    end)
end)
end
-- END test_learning_core_unit.lua

test_summary()
