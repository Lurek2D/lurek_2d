-- examples/ai.lua
-- luna.ai — Game AI subsystems: AIWorld, FSM, Behavior Trees, Steering,
-- Q-Learning, Utility AI, GOAP, Influence Maps, Squads, and Command Queues.
-- All luna.ai API methods demonstrated with code and comments.

-- ── AIWorld ───────────────────────────────────────────────────────────────────

-- newWorld() → AIWorld
-- Container that manages AI agents and a shared global blackboard.
local world = luna.ai.newWorld()

-- addAgent(name, x, y) → Agent
local agent = world:addAgent("soldier_01", 100, 200)

-- getAgent(name) → Agent?
local found = world:getAgent("soldier_01")

-- removeAgent(name)
world:removeAgent("soldier_01")

-- getAgentCount() → integer
local n = world:getAgentCount()

-- getGlobalBlackboard() → Blackboard
local global_bb = world:getGlobalBlackboard()

-- update(dt) — tick all agents
world:update(0.016)

-- ── Agent Methods ─────────────────────────────────────────────────────────────

-- Recreate agent for demos below
local a = world:addAgent("hero", 400, 300)

-- Identity
local name = a:getName()    -- "hero"

-- Position and movement
a:setPosition(500, 300)
local ax, ay = a:getPosition()

a:setVelocity(50, 0)         -- pixels/s
local vx, vy = a:getVelocity()

a:setMaxSpeed(200)
local ms = a:getMaxSpeed()

a:setMaxForce(400)
local mf = a:getMaxForce()

a:setPriority(10)            -- higher = processed first each tick
local pri = a:getPriority()

-- Decision model (set at construction or update)
-- "fsm" | "bt" | "utility" | "goap" — actual model object set via setDecisionModel
-- a:setDecisionModel(fsm_object)
-- a:getDecisionModel() → model object

-- Tags for group classification
a:addTag("ally")
a:addTag("melee")
a:removeTag("melee")
local has = a:hasTag("ally")  -- true

-- Per-agent blackboard
local bb = a:getBlackboard()

-- ── Blackboard ────────────────────────────────────────────────────────────────

-- newBlackboard() → Blackboard (standalone, or use agent/world getBlackboard())
local bb2 = luna.ai.newBlackboard()

-- setNumber / getNumber
global_bb:setNumber("player_x", 320)
local px = global_bb:getNumber("player_x")   -- 320

-- setString / getString
global_bb:setString("state", "patrol")
local state = global_bb:getString("state")   -- "patrol"

-- setBool / getBool
global_bb:setBool("alerted", false)
local alerted = global_bb:getBool("alerted")  -- false

-- hasKey(key) → boolean
local has_key = global_bb:hasKey("player_x")  -- true

-- remove(key)
global_bb:remove("state")

-- ── Finite State Machine ──────────────────────────────────────────────────────

-- newStateMachine() → StateMachine
local fsm = luna.ai.newStateMachine()

-- addState(name, onEnter, onExit, onUpdate)
-- onEnter/onExit/onUpdate are Lua callbacks: function(agent, dt)
fsm:addState("patrol",
    function(agent) print(agent:getName() .. " starts patrolling") end,
    function(agent) print(agent:getName() .. " stops patrolling") end,
    function(agent, dt)
        -- movement logic here
    end
)

fsm:addState("chase",
    function(agent) agent:getBlackboard():setBool("chasing", true) end,
    function(agent) agent:getBlackboard():setBool("chasing", false) end,
    function(agent, dt) end
)

-- addTransition(from, to, condition_fn)
-- condition_fn(agent) → boolean : returns true to trigger transition
fsm:addTransition("patrol", "chase", function(agent)
    local bb3 = agent:getBlackboard()
    return bb3:getBool("alerted")
end)

fsm:addTransition("chase", "patrol", function(agent)
    return not agent:getBlackboard():getBool("alerted")
end)

-- setInitialState(name)
fsm:setInitialState("patrol")

-- update(agent, dt) — tick the FSM for a given agent
fsm:update(a, 0.016)

-- getCurrentState(agent) → string
local cur = fsm:getCurrentState(a)  -- "patrol"

-- ── Behavior Tree ─────────────────────────────────────────────────────────────

-- newBehaviorTree() → BehaviorTree
local bt = luna.ai.newBehaviorTree()

-- BT node constructors (return BTNode objects)
local root_seq = luna.ai.newSequence()         -- runs children left-to-right until one fails
local selector  = luna.ai.newSelector()        -- tries children until one succeeds
local parallel  = luna.ai.newParallel("requireAll", "requireOne")  -- run all children concurrently
local inverter  = luna.ai.newInverter()        -- inverts child result (success↔failure)
local repeater  = luna.ai.newRepeater(5)       -- repeat child N times (0 = infinite)
local succeeder = luna.ai.newSucceeder()        -- always succeeds

local action = luna.ai.newAction(function(agent, dt)
    -- perform an action; return "success" | "failure" | "running"
    agent:setPosition(agent:getPosition())   -- example: stay in place
    return "success"
end)

local condition = luna.ai.newCondition(function(agent, dt)
    return agent:getBlackboard():getBool("alerted")  -- true = success
end)

-- addChild(node) — attach children to composite/decorator nodes
root_seq:addChild(condition)
root_seq:addChild(action)

-- setRoot(node) — assign root node to the tree
bt:setRoot(root_seq)

-- update(agent, dt) → "success" | "failure" | "running"
local result = bt:update(a, 0.016)

-- ── Steering Behaviors ────────────────────────────────────────────────────────

-- newSteeringManager() → SteeringManager
local steering = luna.ai.newSteeringManager()

-- addBehavior(type, weight, opts?) — types include:
--   "seek", "flee", "pursue", "evade", "arrive", "wander",
--   "cohesion", "separation", "alignment", "obstacleAvoidance",
--   "pathFollow", "interpose", "hide"
steering:addBehavior("seek",     1.0)
steering:addBehavior("arrive",   1.0, { slowRadius = 80, stopRadius = 10 })
steering:addBehavior("wander",   0.3, { wanderRadius = 50, wanderDist = 100 })
steering:addBehavior("separation", 0.8)

-- setTarget(x, y) — target position for seek/flee/pursue/evade/arrive/interpose/hide
steering:setTarget(600, 400)

-- update(agent, dt) → force_x, force_y — returns a steering force
local fx, fy = steering:update(a, 0.016)

-- applyForce(agent) — directly applies the computed force to the agent
steering:applyForce(a)

-- ── Q-Learning ────────────────────────────────────────────────────────────────

-- newQLearner(stateCount, actionCount) → QLearner
local q = luna.ai.newQLearner(16, 4)   -- 16 states, 4 actions

-- setLearningRate(v) / getLearningRate() → number
q:setLearningRate(0.1)

-- setDiscount(v) / getDiscount() → number
q:setDiscount(0.95)

-- setEpsilon(v) / getEpsilon() → number  (exploration rate)
q:setEpsilon(0.1)

-- chooseAction(state) → integer (action index, 0-based)
local action_idx = q:chooseAction(0)

-- update(state, action, reward, nextState)
q:update(0, action_idx, 1.0, 1)

-- getBestAction(state) → integer
local best = q:getBestAction(2)

-- ── Utility AI ────────────────────────────────────────────────────────────────

-- newUtilityAI() → UtilityAI
local util_ai = luna.ai.newUtilityAI()

-- addAction(name, scorer_fn, executor_fn)
-- scorer_fn(agent, blackboard) → number (0..1 how useful this action is right now)
-- executor_fn(agent, dt) — called when this action wins
util_ai:addAction("attack",
    function(ag, bb) return bb:getNumber("distance_to_enemy") < 150 and 1.0 or 0.0 end,
    function(ag, dt) -- attack logic
    end
)

util_ai:addAction("flee",
    function(ag, bb) return ag:getBlackboard():getNumber("health") < 20 and 0.9 or 0.0 end,
    function(ag, dt) -- flee logic
    end
)

-- update(agent, dt) — score all actions and execute the highest-scoring one
util_ai:update(a, 0.016)

-- getBestAction(agent) → string — just query without executing
local best_action = util_ai:getBestAction(a)

-- ── GOAP (Goal-Oriented Action Planning) ──────────────────────────────────────

-- newGOAPPlanner() → GOAPPlanner
local goap = luna.ai.newGOAPPlanner()

-- addAction(name, preconditions, effects, cost, executor_fn)
goap:addAction("getAmmo",
    { hasAmmo = false },
    { hasAmmo = true },
    1.0,
    function(agent, dt) -- collect ammo logic
    end
)

goap:addAction("shootEnemy",
    { hasAmmo = true, canSeeEnemy = true },
    { enemyDead = true },
    1.0,
    function(agent, dt) -- shoot logic
    end
)

-- plan(agent, worldState, goalState) → boolean — compute a plan
local worldState = { hasAmmo = false, canSeeEnemy = true, enemyDead = false }
local goalState  = { enemyDead = true }
local planned = goap:plan(a, worldState, goalState)

-- update(agent, dt) — execute current plan step
if planned then
    goap:update(a, 0.016)
end

-- getDone() → boolean — true when plan is complete or failed
local done = goap:getDone()

-- ── Influence Map ─────────────────────────────────────────────────────────────

-- newInfluenceMap(width, height, cellSize) → InfluenceMap
local imap = luna.ai.newInfluenceMap(50, 40, 20)

-- addLayer(name) → integer (layer id)
local threat_layer = imap:addLayer("threat")
local control_layer = imap:addLayer("control")

-- propagate(layer, x, y, strength, falloff)
imap:propagate(threat_layer, 300, 200, 1.0, 0.1)

-- getValue(layer, x, y) → number
local v = imap:getValue(threat_layer, 300, 200)

-- update(decayRate?)
imap:update(0.95)

-- ── Squad (Formation) ─────────────────────────────────────────────────────────

-- newSquad(name) → Squad
local squad = luna.ai.newSquad("alpha_squad")

-- addMember(agent) / removeMember(agent)
squad:addMember(a)

-- setFormation(type, opts?) — types: "line", "column", "wedge", "circle", "box"
squad:setFormation("wedge", { spacing = 30 })

-- getFormationPosition(memberIndex) → x, y
local fx2, fy2 = squad:getFormationPosition(0)

-- update(leaderX, leaderY, leaderAngle, dt)
squad:update(400, 300, 0, 0.016)

-- ── Command Queue (RTS) ───────────────────────────────────────────────────────

-- newCommandQueue() → CommandQueue
local cmdq = luna.ai.newCommandQueue()

-- push(command) — command is a table with a "type" field
cmdq:push({ type = "moveTo", x = 500, y = 300, speed = 150 })
cmdq:push({ type = "attack", targetName = "enemy_01" })
cmdq:push({ type = "idle",   duration = 2.0 })

-- update(agent, dt) — execute front command; auto-advances when done
cmdq:update(a, 0.016)

-- hasCommands() → boolean
local busy = cmdq:hasCommands()

-- clearCommands()
cmdq:clearCommands()
