--- AI Examples Part 5: Need System (cont.), AI Director, HTN, MCTS, Emotion, ORCA, Neural Net, Genetic Algorithm

--@api-stub: LNeedSystem:valueOf
-- Returns the current value of a named need.
do
    local ns = lurek.ai.newNeedSystem()
    ns:addNeed("hunger", 0.1, 0.7, 2.0)
    ns:update(2.0)
    local val = ns:valueOf("hunger")
    print("hunger value = " .. val)
end

--@api-stub: LNeedSystem:type
-- Returns the type name string "LNeedSystem".
do
    local ns = lurek.ai.newNeedSystem()
    print("type = " .. ns:type())
end

--@api-stub: LNeedSystem:typeOf
-- Checks whether this object is of the given type name.
do
    local ns = lurek.ai.newNeedSystem()
    print("is LNeedSystem = " .. tostring(ns:typeOf("LNeedSystem")))
end

--@api-stub: LAIDirector:pushEvent
-- Reports a gameplay event intensity to the director for tension tracking.
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(0.5)
    dir:pushEvent(0.8)
    print("events pushed, tension = " .. dir:tension())
end

--@api-stub: LAIDirector:update
-- Advances the director state by dt seconds, updating phase transitions.
do
    local dir = lurek.ai.newAIDirector()
    dir:pushEvent(1.0)
    dir:update(2.0)
    print("phase after update = " .. dir:phase())
end

--@api-stub: LAIDirector:tension
-- Returns the current tension value (0..1 range).
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.6)
    print("tension = " .. dir:tension())
end

--@api-stub: LAIDirector:phase
-- Returns the current phase name (e.g. "build", "sustain", "peak", "relax").
do
    local dir = lurek.ai.newAIDirector()
    local p = dir:phase()
    print("initial phase = " .. p)
end

--@api-stub: LAIDirector:spawnRateFactor
-- Returns a multiplier for enemy spawn rate based on current tension.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:update(0.1)
    print("spawn rate factor = " .. dir:spawnRateFactor())
end

--@api-stub: LAIDirector:lootFactor
-- Returns a multiplier for loot drops based on current tension.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.2)
    dir:update(0.1)
    print("loot factor = " .. dir:lootFactor())
end

--@api-stub: LAIDirector:ambientIntensity
-- Returns the suggested ambient intensity (audio, effects) based on tension.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.7)
    dir:update(0.1)
    print("ambient intensity = " .. dir:ambientIntensity())
end

--@api-stub: LAIDirector:setTension
-- Directly sets the tension value, overriding natural buildup.
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.5)
    print("tension set to " .. dir:tension())
end

--@api-stub: LAIDirector:reset
-- Resets the director to initial state (zero tension, starting phase).
do
    local dir = lurek.ai.newAIDirector()
    dir:setTension(0.9)
    dir:reset()
    print("after reset, tension = " .. dir:tension())
end

--@api-stub: LAIDirector:type
-- Returns the type name string "LAIDirector".
do
    local dir = lurek.ai.newAIDirector()
    print("type = " .. dir:type())
end

--@api-stub: LAIDirector:typeOf
-- Checks whether this object is of the given type name.
do
    local dir = lurek.ai.newAIDirector()
    print("is LAIDirector = " .. tostring(dir:typeOf("LAIDirector")))
end

--@api-stub: LHTNDomain:addPrimitive
-- Adds a primitive task with preconditions, effects, and facts it clears.
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("chop", { "has_axe" }, { "has_wood" }, {})
    htn:addPrimitive("build", { "has_wood" }, { "shelter_done" }, { "has_wood" })
    print("primitives = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:addCompound
-- Adds a compound task with ordered methods containing preconditions and subtasks.
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("mine", {}, { "has_ore" }, {})
    htn:addPrimitive("smelt", { "has_ore" }, { "has_metal" }, { "has_ore" })
    htn:addCompound("get_metal", {
        { name = "mine_and_smelt", preconditions = {}, sub_tasks = { "mine", "smelt" } },
    })
    print("compound added, tasks = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:plan
-- Decomposes a root task given world state facts and returns primitive task names.
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("gather", {}, { "has_food" }, {})
    htn:addPrimitive("cook", { "has_food" }, { "meal_ready" }, { "has_food" })
    htn:addCompound("prepare_meal", {
        { name = "full_cook", preconditions = {}, sub_tasks = { "gather", "cook" } },
    })
    local plan = htn:plan("prepare_meal", { has_food = 0, meal_ready = 0 })
    if plan then
        print("plan = " .. table.concat(plan --[[@as table]], " -> "))
    end
end

--@api-stub: LHTNDomain:taskCount
-- Returns the total number of registered tasks (primitive + compound).
do
    local htn = lurek.ai.newHTNDomain()
    htn:addPrimitive("a", {}, {}, {})
    htn:addPrimitive("b", {}, {}, {})
    print("task count = " .. htn:taskCount())
end

--@api-stub: LHTNDomain:type
-- Returns the type name string "LHTNDomain".
do
    local htn = lurek.ai.newHTNDomain()
    print("type = " .. htn:type())
end

--@api-stub: LHTNDomain:typeOf
-- Checks whether this object is of the given type name.
do
    local htn = lurek.ai.newHTNDomain()
    print("is LHTNDomain = " .. tostring(htn:typeOf("LHTNDomain")))
end

--@api-stub: LMCTSEngine:search
-- Runs Monte Carlo tree search from a root state and returns the best action.
do
    local mcts = lurek.ai.newMCTSEngine(100, 1.4, 10, 42)
    local action = mcts:search(
        1,
        function(state) return { 1, 2, 3 } end,
        function(state, act) return state + act end,
        function(state) return -math.abs(state - 5) end
    )
    print("best action = " .. tostring(action))
end

--@api-stub: LMCTSEngine:type
-- Returns the type name string "LMCTSEngine".
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("type = " .. mcts:type())
end

--@api-stub: LMCTSEngine:typeOf
-- Checks whether this object is of the given type name.
do
    local mcts = lurek.ai.newMCTSEngine(50, 1.0, 5, 0)
    print("is LMCTSEngine = " .. tostring(mcts:typeOf("LMCTSEngine")))
end

--@api-stub: LEmotionModel:add
-- Registers an emotion with rest value, decay rate, and minimum visibility threshold.
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.3, 0.1, 0.2)
    em:add("anger", 0.0, 0.05, 0.3)
    print("emotions registered")
end

--@api-stub: LEmotionModel:trigger
-- Increases an emotion's value by the given amount.
do
    local em = lurek.ai.newEmotionModel()
    em:add("fear", 0.0, 0.1, 0.2)
    em:trigger("fear", 0.7)
    print("fear = " .. em:get("fear"))
end

--@api-stub: LEmotionModel:get
-- Returns the current value of a named emotion.
do
    local em = lurek.ai.newEmotionModel()
    em:add("sadness", 0.2, 0.05, 0.1)
    em:trigger("sadness", 0.5)
    local val = em:get("sadness")
    print("sadness = " .. val)
end

--@api-stub: LEmotionModel:dominant
-- Returns the name of the emotion with the highest current value.
do
    local em = lurek.ai.newEmotionModel()
    em:add("joy", 0.0, 0.1, 0.1)
    em:add("anger", 0.0, 0.1, 0.1)
    em:trigger("joy", 0.3)
    em:trigger("anger", 0.8)
    print("dominant = " .. tostring(em:dominant()))
end

--@api-stub: LEmotionModel:isActive
-- Returns true if the emotion is above its minimum visibility threshold.
do
    local em = lurek.ai.newEmotionModel()
    em:add("surprise", 0.0, 0.1, 0.5)
    em:trigger("surprise", 0.2)
    print("surprise active = " .. tostring(em:isActive("surprise")))
    em:trigger("surprise", 0.5)
    print("surprise active = " .. tostring(em:isActive("surprise")))
end

--@api-stub: LEmotionModel:update
-- Advances time, decaying emotions toward their rest values.
do
    local em = lurek.ai.newEmotionModel()
    em:add("excitement", 0.0, 0.2, 0.1)
    em:trigger("excitement", 1.0)
    em:update(3.0)
    print("excitement after 3s = " .. em:get("excitement"))
end

--@api-stub: LEmotionModel:reset
-- Resets all emotions to their rest values.
do
    local em = lurek.ai.newEmotionModel()
    em:add("rage", 0.0, 0.1, 0.2)
    em:trigger("rage", 1.0)
    em:reset()
    print("rage after reset = " .. em:get("rage"))
end

--@api-stub: LEmotionModel:type
-- Returns the type name string "LEmotionModel".
do
    local em = lurek.ai.newEmotionModel()
    print("type = " .. em:type())
end

--@api-stub: LEmotionModel:typeOf
-- Checks whether this object is of the given type name.
do
    local em = lurek.ai.newEmotionModel()
    print("is LEmotionModel = " .. tostring(em:typeOf("LEmotionModel")))
end

--@api-stub: LORCASolver:addAgent
-- Adds an agent with position, radius, and max speed. Returns zero-based index.
do
    local orca = lurek.ai.newORCASolver(2.0)
    local idx = orca:addAgent(10.0, 20.0, 0.5, 3.0)
    print("agent index = " .. idx)
end

--@api-stub: LORCASolver:setPreferredVelocity
-- Sets the preferred velocity for an agent by index.
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPreferredVelocity(0, 2.0, 1.0)
    print("preferred velocity set for agent 0")
end

--@api-stub: LORCASolver:setPosition
-- Updates the position of an agent by index.
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 0.5, 5.0)
    orca:setPosition(0, 5.0, 3.0)
    print("position updated for agent 0")
end

--@api-stub: LORCASolver:compute
-- Computes collision-free velocities for all agents over dt.
do
    local orca = lurek.ai.newORCASolver(1.5)
    orca:addAgent(0, 0, 0.5, 3.0)
    orca:addAgent(5, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 1.0, 0.0)
    orca:setPreferredVelocity(1, -1.0, 0.0)
    orca:compute(0.016)
    print("collision avoidance computed")
end

--@api-stub: LORCASolver:getSafeVelocity
-- Returns the safe velocity for an agent after compute().
do
    local orca = lurek.ai.newORCASolver(1.5)
    orca:addAgent(0, 0, 0.5, 3.0)
    orca:setPreferredVelocity(0, 2.0, 0.0)
    orca:compute(0.016)
    local vx, vy = orca:getSafeVelocity(0)
    print("safe velocity = " .. vx .. ", " .. vy)
end

--@api-stub: LORCASolver:agentCount
-- Returns the number of agents in the solver.
do
    local orca = lurek.ai.newORCASolver(2.0)
    orca:addAgent(0, 0, 1.0, 2.0)
    orca:addAgent(5, 5, 1.0, 2.0)
    print("agent count = " .. orca:agentCount())
end

--@api-stub: LORCASolver:type
-- Returns the type name string "LORCASolver".
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("type = " .. orca:type())
end

--@api-stub: LORCASolver:typeOf
-- Checks whether this object is of the given type name.
do
    local orca = lurek.ai.newORCASolver(1.0)
    print("is LORCASolver = " .. tostring(orca:typeOf("LORCASolver")))
end

--@api-stub: LNeuralNet:addLayer
-- Adds a layer with input count, output count, and activation function name.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(4, 8, "relu")
    nn:addLayer(8, 2, "sigmoid")
    print("layers = " .. nn:layerCount())
end

--@api-stub: LNeuralNet:forward
-- Feeds an input array through the network and returns the output array.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 3, "relu")
    nn:addLayer(3, 1, "sigmoid")
    local out = nn:forward({ 0.5, 0.8 })
    print("output[1] = " .. out[1])
end

--@api-stub: LNeuralNet:setWeights
-- Sets all network weights from a flat number array.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 2, "relu")
    local count = nn:paramCount()
    local weights = {}
    for i = 1, count do weights[i] = 0.1 * i end
    nn:setWeights(weights)
    print("weights set, count = " .. count)
end

--@api-stub: LNeuralNet:getWeights
-- Returns all network weights as a flat number array.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(2, 2, "relu")
    local w = nn:getWeights()
    print("weight count = " .. #w)
end

--@api-stub: LNeuralNet:paramCount
-- Returns the total number of trainable parameters (weights + biases).
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(3, 4, "relu")
    nn:addLayer(4, 1, "sigmoid")
    print("param count = " .. nn:paramCount())
end

--@api-stub: LNeuralNet:layerCount
-- Returns the number of layers in the network.
do
    local nn = lurek.ai.newNeuralNet()
    nn:addLayer(5, 10, "relu")
    nn:addLayer(10, 5, "relu")
    nn:addLayer(5, 2, "sigmoid")
    print("layer count = " .. nn:layerCount())
end

--@api-stub: LNeuralNet:type
-- Returns the type name string "LNeuralNet".
do
    local nn = lurek.ai.newNeuralNet()
    print("type = " .. nn:type())
end

--@api-stub: LNeuralNet:typeOf
-- Checks whether this object is of the given type name.
do
    local nn = lurek.ai.newNeuralNet()
    print("is LNeuralNet = " .. tostring(nn:typeOf("LNeuralNet")))
end

--@api-stub: LGeneticAlgorithm:evolve
-- Runs one generation of selection, crossover, and mutation.
do
    local ga = lurek.ai.newGeneticAlgorithm(10, 5, 42)
    for i = 0, 9 do
        ga:setFitness(i, math.random())
    end
    ga:evolve()
    print("evolved to generation " .. ga:generation())
end

--@api-stub: LGeneticAlgorithm:generation
-- Returns the current generation number.
do
    local ga = lurek.ai.newGeneticAlgorithm(8, 4, 0)
    print("initial generation = " .. ga:generation())
    for i = 0, 7 do ga:setFitness(i, 1.0) end
    ga:evolve()
    print("after evolve = " .. ga:generation())
end

print("ai_05.lua")
