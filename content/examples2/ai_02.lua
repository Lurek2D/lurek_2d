--@api-stub: LBTNode:typeOf
-- Returns whether this BT node handle matches a supported type name.
do
  -- typeOf accepts "LBTNode" and "Object". Other strings return false.
  local node = lurek.ai.newSelector()
  local is_node = node:typeOf("LBTNode")
  local is_other = node:typeOf("LImage")
  -- All BT node kinds (action, selector, etc.) respond true to "LBTNode".
  print("LBTNode:typeOf: LBTNode=" .. tostring(is_node) .. " LImage=" .. tostring(is_other))
end

--@api-stub: LSteeringManager:addSeek
-- Adds a seek behavior that steers toward a target position.
do
  -- Seek produces a force pointing directly at (tx, ty) with the given weight.
  -- Weight controls how much this behavior contributes to the combined output.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(400, 300, 1.0)
  local fx, fy = steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  -- Seek never slows down near the target; use arrive for deceleration.
  print("LSteeringManager:addSeek: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addFlee
-- Adds a flee behavior that steers away from a threat position.
do
  -- Flee produces a force pointing directly away from (tx, ty).
  local steer = lurek.ai.newSteeringManager()
  steer:addFlee(200, 200, 1.0)
  local fx, fy = steer:calculate(210, 195, 0, 0, 100, 200, 1 / 60)
  -- Flee is the opposite of seek; useful for panic or danger avoidance.
  print("LSteeringManager:addFlee: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addArrive
-- Adds an arrive behavior that decelerates smoothly near a target position.
do
  -- Arrive works like seek but slows down within the deceleration radius.
  -- The 3rd argument is the deceleration distance; 4th is weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addArrive(300, 300, 50, 1.0)
  local fx, fy = steer:calculate(280, 290, 30, 10, 100, 200, 1 / 60)
  -- Use arrive for movement that stops gracefully at a destination.
  print("LSteeringManager:addArrive: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addWander
-- Adds a wander behavior for random undirected exploration movement.
do
  -- Wander projects a circle ahead and picks a random point on it each tick.
  -- Args: circle_radius, circle_distance, jitter_amount, weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addWander(25, 50, 8, 0.5)
  local fx, fy = steer:calculate(100, 100, 10, 0, 80, 150, 1 / 60)
  -- Wander produces natural-looking exploration without explicit waypoints.
  print("LSteeringManager:addWander: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:addPursue
-- Adds a pursue behavior that chases another named agent.
do
  -- Pursue steers toward a named agent registered in the AI world.
  -- Pass the agent name string and an optional weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addPursue("target_agent", 1.0)
  local count = steer:getBehaviorCount()
  -- Pursue is better than seek for chasing moving enemies.
  print("LSteeringManager:addPursue: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:addEvade
-- Adds an evade behavior that moves away from another named agent.
do
  -- Evade steers away from a named agent registered in the AI world.
  -- Pass the agent name string and an optional weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addEvade("enemy_agent", 1.0)
  local count = steer:getBehaviorCount()
  -- Evade is better than flee for escaping moving pursuers.
  print("LSteeringManager:addEvade: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:addFlock
-- Adds a flocking behavior with separation, alignment, and cohesion weights.
do
  -- Flock uses a neighbor radius to find nearby agents and combines three forces.
  -- Args: neighbor_radius, separation_weight, alignment_weight, cohesion_weight, behavior_weight.
  local steer = lurek.ai.newSteeringManager()
  steer:addFlock(80, 1.5, 1.0, 1.0, 1.0)
  local count = steer:getBehaviorCount()
  -- Flocking creates emergent group patterns like bird murmurations.
  print("LSteeringManager:addFlock: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:getBehaviorCount
-- Returns the number of behaviors currently registered in this manager.
do
  -- Each add call increments the count. clearPath does not affect behavior count.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(100, 100, 1.0)
  steer:addWander(10, 20, 3, 0.5)
  local count = steer:getBehaviorCount()
  -- Use behavior count for debug or to limit how many behaviors stack.
  print("LSteeringManager:getBehaviorCount: " .. tostring(count))
end

--@api-stub: LSteeringManager:setCombineMode
-- Sets how multiple behaviors are combined into the final force.
do
  -- Modes: "weighted" (sum all * weight), "priority" (first non-zero wins),
  -- "truncated" (sum until max force reached).
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("priority")
  local mode = steer:getCombineMode()
  -- "weighted" is the default and works for most cases.
  print("LSteeringManager:setCombineMode: " .. mode)
end

--@api-stub: LSteeringManager:getCombineMode
-- Returns the current combine mode string.
do
  local steer = lurek.ai.newSteeringManager()
  steer:setCombineMode("truncated")
  local mode = steer:getCombineMode()
  -- Use getCombineMode for serialization or debug display.
  print("LSteeringManager:getCombineMode: " .. mode)
end

--@api-stub: LSteeringManager:getLastSteering
-- Returns the x,y force from the most recent calculate() call.
do
  -- getLastSteering returns 0,0 before the first calculate call.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(200, 200, 1.0)
  steer:calculate(50, 50, 0, 0, 100, 200, 1 / 60)
  local lx, ly = steer:getLastSteering()
  -- Use getLastSteering for debug visualization without recalculating.
  print("LSteeringManager:getLastSteering: " .. tostring(lx) .. "," .. tostring(ly))
end

--@api-stub: LSteeringManager:calculate
-- Computes the combined steering force for the agent's current state.
do
  -- Args: pos_x, pos_y, vel_x, vel_y, max_speed, max_force, dt.
  -- Returns two numbers: force_x, force_y.
  local steer = lurek.ai.newSteeringManager()
  steer:addSeek(500, 300, 1.0)
  steer:addWander(15, 30, 4, 0.3)
  local fx, fy = steer:calculate(100, 100, 20, 5, 150, 250, 1 / 60)
  -- Apply the force to velocity: vel = vel + force * dt, clamped to max_speed.
  print("LSteeringManager:calculate: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LSteeringManager:setPath
-- Sets a waypoint path for path-following behavior.
do
  -- Path is an array of {x=n, y=n} tables. The agent follows waypoints in order.
  -- reach_radius controls how close the agent must be to advance to the next point.
  local steer = lurek.ai.newSteeringManager()
  local waypoints = {
    { x = 50, y = 50 },
    { x = 200, y = 80 },
    { x = 350, y = 200 },
    { x = 400, y = 400 },
  }
  steer:setPath(waypoints, 16.0, 1.0)
  local has = steer:hasPath()
  -- Path following uses the internal pathfinding force during calculate.
  print("LSteeringManager:setPath: hasPath=" .. tostring(has))
end

--@api-stub: LSteeringManager:clearPath
-- Removes the current path from this steering manager.
do
  -- clearPath stops path-following without removing other behaviors.
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({ { x = 10, y = 10 }, { x = 100, y = 100 } }, 8.0, 1.0)
  steer:clearPath()
  local has = steer:hasPath()
  -- After clear, calculate no longer includes path-following force.
  print("LSteeringManager:clearPath: hasPath=" .. tostring(has))
end

--@api-stub: LSteeringManager:hasPath
-- Returns whether this steering manager has an active path.
do
  -- hasPath returns false before setPath or after clearPath.
  local steer = lurek.ai.newSteeringManager()
  local before = steer:hasPath()
  steer:setPath({ { x = 0, y = 0 }, { x = 50, y = 50 } }, 5.0, 1.0)
  local after = steer:hasPath()
  -- Check hasPath before calling getPathProgress.
  print("LSteeringManager:hasPath: before=" .. tostring(before) .. " after=" .. tostring(after))
end

--@api-stub: LSteeringManager:getPathProgress
-- Returns the current waypoint index and total waypoint count.
do
  -- Returns two integers: current_index (1-based), total_count.
  local steer = lurek.ai.newSteeringManager()
  steer:setPath({
    { x = 0, y = 0 },
    { x = 100, y = 50 },
    { x = 200, y = 100 },
  }, 10.0, 1.0)
  local idx, total = steer:getPathProgress()
  -- Use progress for UI (e.g. "Waypoint 2/5") or completion checks.
  print("LSteeringManager:getPathProgress: " .. tostring(idx) .. "/" .. tostring(total))
end

--@api-stub: LSteeringManager:type
-- Returns the Lua-visible type name for this steering manager handle.
do
  local steer = lurek.ai.newSteeringManager()
  local t = steer:type()
  print("LSteeringManager:type: " .. t)
end

--@api-stub: LSteeringManager:typeOf
-- Returns whether this steering handle matches a supported type name.
do
  local steer = lurek.ai.newSteeringManager()
  local is_steer = steer:typeOf("LSteeringManager")
  local is_other = steer:typeOf("LAgent")
  print("LSteeringManager:typeOf: LSteeringManager=" .. tostring(is_steer) .. " LAgent=" .. tostring(is_other))
end

--@api-stub: LSteeringManager:setSpatialHashCellSize
-- Sets the cell size for the internal spatial hash used by flocking.
do
  -- Spatial hash accelerates neighbor lookups for flocking.
  -- Smaller cells = more precise but more memory; bigger cells = faster but less accurate.
  local steer = lurek.ai.newSteeringManager()
  steer:setSpatialHashCellSize(32)
  -- Set cell size before adding flock behaviors for best performance.
  print("LSteeringManager:setSpatialHashCellSize: done")
end

--@api-stub: LSteeringManager:enableSpatialHash
-- Enables or disables the spatial hash for neighbor queries.
do
  -- When disabled, flocking uses brute-force neighbor checks.
  -- Enable it when you have many agents (> 20) sharing a manager.
  local steer = lurek.ai.newSteeringManager()
  steer:enableSpatialHash(true)
  steer:setSpatialHashCellSize(48)
  -- Spatial hash only helps with flock-type behaviors.
  print("LSteeringManager:enableSpatialHash: done")
end

--@api-stub: LSteeringManager:addCustomBehavior
-- Registers a custom steering behavior backed by a Lua callback.
do
  -- Custom behaviors let you implement game-specific steering logic.
  -- The callback receives (agent, dt) and must return fx, fy force values.
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt)
    -- Simple constant push to the right
    return 50, 0
  end, 0.8)
  local count = steer:getBehaviorCount()
  -- Custom behaviors integrate with all other behaviors via combine mode.
  print("LSteeringManager:addCustomBehavior: behaviors=" .. tostring(count))
end

--@api-stub: LSteeringManager:applyCustomSteering
-- Runs enabled custom steering callbacks for an agent and returns the combined force.
do
  -- applyCustomSteering(agent, dt) invokes all custom callbacks registered
  -- with addCustomBehavior and returns the weighted combined force.
  local world = lurek.ai.newWorld()
  local npc = world:addAgent("pusher")
  npc:setPosition(100, 100)
  local steer = lurek.ai.newSteeringManager()
  steer:addCustomBehavior(function(agent, dt)
    return 25, -10
  end, 1.0)
  local fx, fy = steer:applyCustomSteering(npc, 1 / 60)
  -- Use for scripted nudges: knockback, wind gusts, or magnetic fields.
  print("LSteeringManager:applyCustomSteering: fx=" .. tostring(fx) .. " fy=" .. tostring(fy))
end

--@api-stub: LDialogueAI:setFSMState
-- Sets the current FSM state string used for topic/branch gating.
do
  -- Topics and branches can require a specific FSM state to be eligible.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("battle_cry", 0.5, "combat", nil, "cry_score")
  dlg:setFSMState("combat")
  dlg:setUtilityScore("cry_score", 0.8)
  local topic = dlg:selectTopic()
  -- Without matching FSM state, gated topics are skipped.
  print("LDialogueAI:setFSMState: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setBTStatus
-- Sets the current behavior tree status string used for topic/branch gating.
do
  -- Topics can gate on BT status: "success", "failure", "running".
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("victory", 0.6, nil, "success", "vic_score")
  dlg:setBTStatus("success")
  dlg:setUtilityScore("vic_score", 0.9)
  local topic = dlg:selectTopic()
  -- BT status reflects the outcome of the agent's last behavior tick.
  print("LDialogueAI:setBTStatus: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:setUtilityScore
-- Sets a named utility score used to weight topics and branches.
do
  -- Each topic/branch references a score key. Higher score = more likely selected.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("greeting", 0.3, nil, nil, "greet_val")
  dlg:addTopic("farewell", 0.3, nil, nil, "bye_val")
  dlg:setUtilityScore("greet_val", 0.2)
  dlg:setUtilityScore("bye_val", 0.9)
  local topic = dlg:selectTopic()
  -- Update scores each frame from game state for dynamic dialogue.
  print("LDialogueAI:setUtilityScore: topic=" .. tostring(topic))
end

--@api-stub: LDialogueAI:clearUtilityScores
-- Removes all utility scores, resetting topic selection to base weights only.
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:setUtilityScore("a", 1.0)
  dlg:setUtilityScore("b", 0.5)
  dlg:clearUtilityScores()
  -- After clear, topics fall back to their base weight for selection.
  print("LDialogueAI:clearUtilityScores: done")
end

--@api-stub: LDialogueAI:addTopic
-- Registers a named topic with base weight, optional FSM/BT gates, and a score key.
do
  -- Args: name, base_weight, required_fsm_state (nil=any), required_bt_status (nil=any), score_key.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("weather_chat", 0.4, nil, nil, "chat_score")
  dlg:addTopic("combat_taunt", 0.3, "combat", "running", "taunt_score")
  local count = dlg:getTopicCount()
  -- Topics form the first level of dialogue selection.
  print("LDialogueAI:addTopic: count=" .. tostring(count))
end

--@api-stub: LDialogueAI:addBranch
-- Adds a named branch under a topic with its own gating and scoring.
do
  -- Branches subdivide a topic into specific lines or responses.
  -- Args: topic_name, branch_name, base_weight, fsm_gate, bt_gate, score_key.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("threat", 0.5, nil, nil, "threat_score")
  dlg:addBranch("threat", "mock", 0.4, nil, nil, "mock_score")
  dlg:addBranch("threat", "demand", 0.6, nil, nil, "demand_score")
  dlg:setUtilityScore("threat_score", 0.8)
  dlg:setUtilityScore("mock_score", 0.3)
  dlg:setUtilityScore("demand_score", 0.7)
  local topic = dlg:selectTopic()
  local branch = topic and dlg:selectBranch(topic) or nil
  -- Branch selection narrows the topic to a specific dialogue line.
  print("LDialogueAI:addBranch: branch=" .. tostring(branch))
end

--@api-stub: LDialogueAI:selectTopic
-- Returns the name of the highest-scoring eligible topic or nil.
do
  -- Selection considers base_weight * utility_score, filtered by FSM/BT gates.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("joke", 0.2, nil, nil, "joke_v")
  dlg:addTopic("quest_hint", 0.8, nil, nil, "hint_v")
  dlg:setUtilityScore("joke_v", 0.5)
  dlg:setUtilityScore("hint_v", 0.9)
  local topic = dlg:selectTopic() or "none"
  -- Nil result means no topic passes all gates.
  print("LDialogueAI:selectTopic: " .. topic)
end

--@api-stub: LDialogueAI:selectBranch
-- Returns the name of the highest-scoring eligible branch for a given topic.
do
  -- selectBranch(topic_name) returns nil if the topic has no branches.
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("trade", 0.5, nil, nil, "trade_v")
  dlg:addBranch("trade", "buy", 0.5, nil, nil, "buy_v")
  dlg:addBranch("trade", "sell", 0.5, nil, nil, "sell_v")
  dlg:setUtilityScore("trade_v", 1.0)
  dlg:setUtilityScore("buy_v", 0.3)
  dlg:setUtilityScore("sell_v", 0.7)
  local branch = dlg:selectBranch("trade") or "none"
  -- Use the selected branch to pick dialogue text from a table.
  print("LDialogueAI:selectBranch: " .. branch)
end

--@api-stub: LDialogueAI:getTopicCount
-- Returns the number of topics registered in this dialogue AI.
do
  local dlg = lurek.ai.newDialogueAI()
  dlg:addTopic("a", 0.5, nil, nil, "a_v")
  dlg:addTopic("b", 0.3, nil, nil, "b_v")
  dlg:addTopic("c", 0.2, nil, nil, "c_v")
  local count = dlg:getTopicCount()
  -- Topic count helps validate setup completeness.
  print("LDialogueAI:getTopicCount: " .. tostring(count))
end

--@api-stub: LDialogueAI:type
-- Returns the Lua-visible type name for this dialogue AI handle.
do
  local dlg = lurek.ai.newDialogueAI()
  local t = dlg:type()
  print("LDialogueAI:type: " .. t)
end

--@api-stub: LDialogueAI:typeOf
-- Returns whether this dialogue handle matches a supported type name.
do
  local dlg = lurek.ai.newDialogueAI()
  local is_dlg = dlg:typeOf("LDialogueAI")
  local is_other = dlg:typeOf("LQLearner")
  print("LDialogueAI:typeOf: LDialogueAI=" .. tostring(is_dlg) .. " LQLearner=" .. tostring(is_other))
end

--@api-stub: LQLearner:chooseAction
-- Selects an action for a given state using the current exploration policy.
do
  -- chooseAction(state) returns an action index. With high exploration rate,
  -- the action may be random; with low rate, it picks the highest Q-value.
  local ql = lurek.ai.newQLearner(5, 3)
  ql:setExplorationRate(0.0)
  ql:setQValue(0, 1, 0.9)
  local action = ql:chooseAction(0)
  -- With 0 exploration, chooseAction always returns the best known action.
  print("LQLearner:chooseAction: action=" .. tostring(action))
end

--@api-stub: LQLearner:bestAction
-- Returns the action with the highest Q-value for a given state.
do
  -- bestAction ignores exploration; it always returns the greedy choice.
  local ql = lurek.ai.newQLearner(4, 3)
  ql:setQValue(2, 0, 0.3)
  ql:setQValue(2, 1, 0.8)
  ql:setQValue(2, 2, 0.5)
  local best = ql:bestAction(2)
  -- Use bestAction for evaluation; use chooseAction for training.
  print("LQLearner:bestAction: " .. tostring(best))
end

--@api-stub: LQLearner:learn
-- Updates the Q-value for a (state, action) pair after observing a reward.
do
  -- learn(state, action, reward, next_state) applies the Q-learning update rule.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.5)
  ql:setDiscountFactor(0.9)
  ql:learn(0, 0, 1.0, 1)
  local qval = ql:getQValue(0, 0)
  -- Q-value increases toward rewards over repeated learn calls.
  print("LQLearner:learn: Q(0,0)=" .. tostring(qval))
end

--@api-stub: LQLearner:getQValue
-- Returns the current Q-value for a specific (state, action) pair.
do
  -- Q-values start at 0 and change through learn() or setQValue().
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setQValue(1, 0, 0.75)
  local val = ql:getQValue(1, 0)
  local zero = ql:getQValue(1, 1)
  -- Read Q-values for debug visualization or policy export.
  print("LQLearner:getQValue: (1,0)=" .. tostring(val) .. " (1,1)=" .. tostring(zero))
end

--@api-stub: LQLearner:setQValue
-- Directly sets the Q-value for a specific (state, action) pair.
do
  -- setQValue is useful for loading pre-trained policies from save files.
  local ql = lurek.ai.newQLearner(4, 2)
  ql:setQValue(0, 0, 0.5)
  ql:setQValue(0, 1, 0.9)
  local best = ql:bestAction(0)
  -- After setting, bestAction and chooseAction see the new values.
  print("LQLearner:setQValue: best=" .. tostring(best))
end

--@api-stub: LQLearner:endEpisode
-- Signals the end of a training episode and applies exploration decay.
do
  -- endEpisode multiplies exploration rate by the decay factor.
  -- Call it after a game round ends (win, lose, or timeout).
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(1.0)
  ql:setExplorationDecay(0.95)
  ql:endEpisode()
  local rate = ql:getExplorationRate()
  -- Over many episodes, exploration decreases toward zero.
  print("LQLearner:endEpisode: rate=" .. tostring(rate))
end

--@api-stub: LQLearner:getEpisodeCount
-- Returns the number of completed episodes since creation.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:endEpisode()
  ql:endEpisode()
  ql:endEpisode()
  local episodes = ql:getEpisodeCount()
  -- Use episode count for logging or stopping training after N episodes.
  print("LQLearner:getEpisodeCount: " .. tostring(episodes))
end

--@api-stub: LQLearner:getStateCount
-- Returns the number of states this Q-learner was initialized with.
do
  local ql = lurek.ai.newQLearner(8, 4)
  local states = ql:getStateCount()
  -- State count is fixed at creation; you cannot add states later.
  print("LQLearner:getStateCount: " .. tostring(states))
end

--@api-stub: LQLearner:getActionCount
-- Returns the number of actions this Q-learner was initialized with.
do
  local ql = lurek.ai.newQLearner(8, 4)
  local actions = ql:getActionCount()
  -- Action count is fixed at creation; you cannot add actions later.
  print("LQLearner:getActionCount: " .. tostring(actions))
end

--@api-stub: LQLearner:setLearningRate
-- Sets how quickly new rewards override old Q-values.
do
  -- Learning rate (alpha) between 0 and 1. Higher = faster learning, less stable.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.2)
  local rate = ql:getLearningRate()
  -- Typical values: 0.1 for stability, 0.5 for fast adaptation.
  print("LQLearner:setLearningRate: " .. tostring(rate))
end

--@api-stub: LQLearner:getLearningRate
-- Returns the current learning rate.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setLearningRate(0.15)
  local rate = ql:getLearningRate()
  print("LQLearner:getLearningRate: " .. tostring(rate))
end

--@api-stub: LQLearner:setDiscountFactor
-- Sets how much future rewards are valued relative to immediate rewards.
do
  -- Discount factor (gamma) between 0 and 1. Higher = more forward-looking.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setDiscountFactor(0.99)
  local gamma = ql:getDiscountFactor()
  -- 0.99 plans far ahead; 0.5 focuses on immediate rewards.
  print("LQLearner:setDiscountFactor: " .. tostring(gamma))
end

--@api-stub: LQLearner:getDiscountFactor
-- Returns the current discount factor.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setDiscountFactor(0.9)
  local gamma = ql:getDiscountFactor()
  print("LQLearner:getDiscountFactor: " .. tostring(gamma))
end

--@api-stub: LQLearner:setExplorationRate
-- Sets the probability of choosing a random action instead of the best one.
do
  -- Exploration rate (epsilon) between 0 and 1. 1.0 = pure random, 0.0 = pure greedy.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(0.5)
  local rate = ql:getExplorationRate()
  -- Start high and decay over episodes for explore-then-exploit.
  print("LQLearner:setExplorationRate: " .. tostring(rate))
end

--@api-stub: LQLearner:getExplorationRate
-- Returns the current exploration rate.
do
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(0.3)
  local rate = ql:getExplorationRate()
  print("LQLearner:getExplorationRate: " .. tostring(rate))
end

--@api-stub: LQLearner:setExplorationDecay
-- Sets the multiplicative decay applied to exploration rate each episode.
do
  -- Decay factor between 0 and 1. Each endEpisode: rate = rate * decay.
  local ql = lurek.ai.newQLearner(3, 2)
  ql:setExplorationRate(1.0)
  ql:setExplorationDecay(0.9)
  ql:endEpisode()
  local rate = ql:getExplorationRate()
  -- After 1 episode with 0.9 decay: rate = 1.0 * 0.9 = 0.9.
  print("LQLearner:setExplorationDecay: rate=" .. tostring(rate))
end

print("ai_02.lua")
