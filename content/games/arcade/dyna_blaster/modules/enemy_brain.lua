local M = {}
M.__index = M

local function sign(v)
    if v > 0 then return 1 end
    if v < 0 then return -1 end
    return 0
end

local function state_for(ctx, player_pos, bombs)
    local gx, gy = ctx.gx, ctx.gy

    local nearest_bomb_dist = 999
    for i = 1, #bombs do
        local b = bombs[i]
        local d = math.abs(gx - b.gx) + math.abs(gy - b.gy)
        if d < nearest_bomb_dist then
            nearest_bomb_dist = d
        end
    end

    local dx = player_pos.gx - gx
    local dy = player_pos.gy - gy
    local player_dist = math.abs(dx) + math.abs(dy)

    if nearest_bomb_dist <= 2 then
        return "evade"
    end
    if player_dist <= 6 then
        return "chase"
    end
    return "patrol"
end

function M.new(cfg)
    return setmetatable({
        cfg = cfg,
        ai_world = nil,
        enemies = {},
        map_grid = nil,
    }, M)
end

function M:reset(map_grid)
    self.ai_world = lurek.ai.newWorld()
    self.enemies = {}
    self.map_grid = map_grid
end

function M:add_enemy(id, gx, gy)
    if not self.ai_world then
        return
    end

    local agent = self.ai_world:addAgent("enemy_" .. tostring(id))
    local fsm = lurek.ai.newStateMachine()
    fsm:addState("patrol", {})
    fsm:addState("chase", {})
    fsm:addState("evade", {})
    fsm:setInitialState("patrol")

    local bb = agent:getBlackboard()
    bb:setString("mode", "patrol")
    bb:setNumber("target_x", gx)
    bb:setNumber("target_y", gy)

    self.enemies[id] = {
        id = id,
        agent = agent,
        fsm = fsm,
        bb = bb,
        gx = gx,
        gy = gy,
        desired_dx = 0,
        desired_dy = 0,
        patrol_dx = 1,
        patrol_dy = 0,
        repath_timer = 0,
    }

    agent:setDecisionModel("custom")
    agent:setPosition(gx, gy)
end

function M:remove_enemy(id)
    local e = self.enemies[id]
    if not e then
        return
    end
    if self.ai_world and e.agent then
        self.ai_world:removeAgent(e.agent)
    end
    self.enemies[id] = nil
end

function M:sync_enemy_position(id, gx, gy)
    local e = self.enemies[id]
    if not e then
        return
    end
    e.gx = gx
    e.gy = gy
    if e.agent then
        e.agent:setPosition(gx, gy)
    end
end

function M:choose_patrol(ctx)
    local dirs = {
        { 1, 0 },
        { -1, 0 },
        { 0, 1 },
        { 0, -1 },
    }

    if math.random() < 0.7 then
        return ctx.patrol_dx, ctx.patrol_dy
    end

    local pick = dirs[math.random(1, #dirs)]
    ctx.patrol_dx, ctx.patrol_dy = pick[1], pick[2]
    return ctx.patrol_dx, ctx.patrol_dy
end

function M:choose_chase(ctx, player_pos)
    if (not self.map_grid) then
        return sign(player_pos.gx - ctx.gx), sign(player_pos.gy - ctx.gy)
    end

    if ctx.repath_timer <= 0 then
        local step = self.map_grid:first_path_step(ctx.gx, ctx.gy, player_pos.gx, player_pos.gy)
        if step then
            ctx.bb:setNumber("target_x", step.x)
            ctx.bb:setNumber("target_y", step.y)
        else
            ctx.bb:setNumber("target_x", player_pos.gx)
            ctx.bb:setNumber("target_y", player_pos.gy)
        end
        ctx.repath_timer = 0.35
    end

    local tx = ctx.bb:getNumber("target_x", player_pos.gx)
    local ty = ctx.bb:getNumber("target_y", player_pos.gy)
    return sign(tx - ctx.gx), sign(ty - ctx.gy)
end

function M:choose_evade(ctx, bombs)
    local best_dx, best_dy = 0, 0
    local best_score = -999
    local dirs = {
        { 1, 0 },
        { -1, 0 },
        { 0, 1 },
        { 0, -1 },
    }

    for i = 1, #dirs do
        local d = dirs[i]
        local nx, ny = ctx.gx + d[1], ctx.gy + d[2]
        local score = 0
        for j = 1, #bombs do
            local b = bombs[j]
            score = score + math.abs(nx - b.gx) + math.abs(ny - b.gy)
        end
        if score > best_score then
            best_score = score
            best_dx, best_dy = d[1], d[2]
        end
    end

    return best_dx, best_dy
end

function M:update(dt, player_pos, bombs)
    if not self.ai_world then
        return
    end

    local ids = {}
    for id, _ in pairs(self.enemies) do
        ids[#ids + 1] = id
    end

    for i = 1, #ids do
        local id = ids[i]
        local ctx = self.enemies[id]
        if ctx then
            ctx.repath_timer = math.max(0, ctx.repath_timer - dt)

            local mode = state_for(ctx, player_pos, bombs)
            if mode ~= ctx.fsm:getCurrentState() then
                ctx.fsm:forceState(mode)
                ctx.bb:setString("mode", mode)
            end

            local dx, dy = 0, 0
            if mode == "evade" then
                dx, dy = self:choose_evade(ctx, bombs)
            elseif mode == "chase" then
                dx, dy = self:choose_chase(ctx, player_pos)
            else
                dx, dy = self:choose_patrol(ctx)
            end

            ctx.desired_dx = dx
            ctx.desired_dy = dy
            ctx.agent:setVelocity(dx, dy)
        end
    end

    self.ai_world:update(dt)
end

function M:get_desired_step(id)
    local e = self.enemies[id]
    if not e then
        return 0, 0
    end
    return e.desired_dx, e.desired_dy
end

return M
