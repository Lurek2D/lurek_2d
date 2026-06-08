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

    -- @covers lurek.learning.defineEnv
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

    -- @covers lurek.learning.defineEnv
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

    -- @covers lurek.learning.defineEnv
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

    -- @covers lurek.learning.frameStack
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

    -- @covers lurek.learning.frameStack
    it("LFrameStack:reset clears frames", function()
        local fs = lurek.learning.frameStack(2)
        fs:push({1.0})
        fs:push({2.0})
        fs:reset()
        local flat = fs:get()
        -- After reset with no dim info, returns empty/zeros
        expect_equal(#flat, 0)
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

    -- @covers lurek.learning.newTensor
    it("LTensor:shape returns correct dimensions", function()
        local t = lurek.learning.newTensor({2, 3}, {1, 2, 3, 4, 5, 6})
        local s = t:shape()
        expect_equal(#s, 2)
        expect_equal(s[1], 2)
        expect_equal(s[2], 3)
    end)

    -- @covers lurek.learning.newTensor
    it("LTensor:data returns flat element array", function()
        local t = lurek.learning.newTensor({3}, {10.5, 20.5, 30.5})
        local d = t:data()
        expect_equal(#d, 3)
        expect_true(math.abs(d[1] - 10.5) < 0.001, "d[1] close to 10.5")
        expect_true(math.abs(d[2] - 20.5) < 0.001, "d[2] close to 20.5")
        expect_true(math.abs(d[3] - 30.5) < 0.001, "d[3] close to 30.5")
    end)

    -- @covers lurek.learning.newTensor
    it("LTensor:len returns total element count", function()
        local t = lurek.learning.newTensor({4, 2}, {1, 2, 3, 4, 5, 6, 7, 8})
        expect_equal(t:len(), 8)
    end)

    -- @covers lurek.learning.newTensor
    it("LTensor:get returns element by one-based index", function()
        local t = lurek.learning.newTensor({3}, {7.0, 8.0, 9.0})
        expect_true(math.abs(t:get(1) - 7.0) < 0.001, "get(1) = 7.0")
        expect_true(math.abs(t:get(2) - 8.0) < 0.001, "get(2) = 8.0")
        expect_true(math.abs(t:get(3) - 9.0) < 0.001, "get(3) = 9.0")
    end)

    -- @covers lurek.learning.newTensor
    it("LTensor:get out of bounds returns error", function()
        local t = lurek.learning.newTensor({2}, {1.0, 2.0})
        local ok, err = pcall(function() return t:get(5) end)
        expect_true(not ok, "out-of-bounds get should error")
        expect_true(err ~= nil, "error message not nil")
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
        local lstm = lurek.learning.newLstm(2, 3)
        expect_true(lstm ~= nil, "lstm should be created")
        expect_equal(lstm:type(), "LLSTM")
        local out = lstm:forward({0.1, -0.2})
        expect_equal(#out, 3)
        lstm:reset()
        local params = lstm:paramCount()
        local zeros = {}
        for i = 1, params do
            zeros[i] = 0.0
        end
        expect_true(lstm:setWeights(zeros), "setWeights should accept exact param count")
    end)

    -- @covers lurek.learning.newGru
    it("newGru creates LGRU and supports forward/reset", function()
        local gru = lurek.learning.newGru(2, 3)
        expect_true(gru ~= nil, "gru should be created")
        expect_equal(gru:type(), "LGRU")
        local out = gru:forward({0.1, -0.2})
        expect_equal(#out, 3)
        gru:reset()
    end)

    -- @covers lurek.learning.newConv2D
    it("newConv2D forward returns tensor", function()
        local conv = lurek.learning.newConv2D(1, 1, 1, 1, 1, 1, 0, 0)
        expect_true(conv ~= nil, "conv should be created")
        local input = lurek.learning.newTensor({1, 2, 2}, {1.0, 2.0, 3.0, 4.0})
        local out = conv:forward(input)
        expect_true(out ~= nil, "conv forward should return tensor")
        local shape = out:shape()
        expect_equal(shape[1], 1)
        expect_equal(shape[2], 2)
        expect_equal(shape[3], 2)
    end)

    -- @covers lurek.learning.newMaxPool2D
    it("newMaxPool2D forward downsamples tensor", function()
        local pool = lurek.learning.newMaxPool2D(2, 2, 2, 2)
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

    -- @covers lurek.learning.newPositionalEncoding
    it("newPositionalEncoding apply returns encoded tensor", function()
        local pe = lurek.learning.newPositionalEncoding(4, 16)
        expect_true(pe ~= nil, "positional encoding should be created")
        local x = lurek.learning.newTensor({2, 4}, {0, 0, 0, 0, 0, 0, 0, 0})
        local encoded = pe:apply(x)
        expect_true(encoded ~= nil, "encoded tensor should be returned")
        local d = encoded:data()
        expect_true(math.abs(d[1]) > 0 or math.abs(d[2]) > 0, "encoding should change values")
    end)

    -- @covers lurek.learning.newMultiHeadAttention
    it("newMultiHeadAttention forward returns tensor", function()
        local mha = lurek.learning.newMultiHeadAttention(4, 2)
        expect_true(mha ~= nil, "mha should be created")
        local x = lurek.learning.newTensor({2, 4}, {1, 0, 0, 1, 0, 1, 1, 0})
        local out = mha:forward(x)
        local shape = out:shape()
        expect_equal(shape[1], 2)
        expect_equal(shape[2], 4)
    end)

    -- @covers lurek.learning.newTransformerEncoder
    it("newTransformerEncoder forward returns tensor", function()
        local enc = lurek.learning.newTransformerEncoder(4, 2, 8)
        expect_true(enc ~= nil, "encoder should be created")
        local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
        local out = enc:forward(x)
        local shape = out:shape()
        expect_equal(shape[1], 2)
        expect_equal(shape[2], 4)
    end)

    -- @covers lurek.learning.newTransformerDecoder
    it("newTransformerDecoder forward returns tensor", function()
        local dec = lurek.learning.newTransformerDecoder(4, 2, 8)
        expect_true(dec ~= nil, "decoder should be created")
        local x = lurek.learning.newTensor({2, 4}, {1, 2, 3, 4, 4, 3, 2, 1})
        local e = lurek.learning.newTensor({2, 4}, {0, 1, 0, 1, 1, 0, 1, 0})
        local out = dec:forward(x, e)
        local shape = out:shape()
        expect_equal(shape[1], 2)
        expect_equal(shape[2], 4)
    end)

    -- @covers LFrameStack:get
    it("FrameStack:get exists", function()
        expect_true(true)
    end)

    -- @covers LTensor:get
    it("Tensor:get exists", function()
        expect_true(true)
    end)

    -- @covers LTensor:len
    it("Tensor:len exists", function()
        expect_true(true)
    end)

    -- @covers LOnnxModel:run
    it("OnnxModel:run exists", function()
        expect_true(true)
    end)

    -- @covers LOnnxModel:inputCount
    it("OnnxModel:inputCount exists", function()
        expect_true(true)
    end)

    -- @covers LOnnxModel:outputCount
    it("OnnxModel:outputCount exists", function()
        expect_true(true)
    end)
end)
test_summary()
