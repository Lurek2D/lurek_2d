-- Headless regression coverage for the Tactical Mech Shooter game.

local ROOT = "content/games/tactical_mech_shooter/"

local function load_module(path)
    local chunk = lurek.filesystem.load(ROOT .. path)
    assert(type(chunk) == "function", path .. " not loadable")
    return chunk()
end

-- @describe Tactical Mech Shooter headless regressions
describe("Tactical Mech Shooter headless regressions", function()
it("loads content and proves the complete battle integration", function()

local loader = load_module("app/content_loader.lua")
local validator = load_module("app/content_validator.lua")
local content = loader.load(ROOT)
validator.validate(content)
assert(content.content and content.content.corpora.scout)
assert(content.content.weapons.pistol)
assert(content.content.backpacks.none)
assert(content.content.presets.f8)
assert(content.content.presets.f9 and content.content.presets.f10 and content.content.presets.f11 and content.content.presets.f12)
local build = load_module("domain/build.lua")
local composed = assert(build.from_preset(content, "f1"))
assert(composed.cargo_used <= composed.cargo)
assert(composed.cost >= 0)
local economy = load_module("domain/economy.lua")
local campaign = {level = 1, stars = 0, wins = 0, losses = 0}
economy.finish(campaign, true)
assert(campaign.level == 2 and campaign.stars == 3 and campaign.wins == 1)

local bootstrap = load_module("app/bootstrap.lua")
local state = bootstrap.load(ROOT)
state.modules.Movement.bind()
state.modules.Battle.start(state, "f1")
assert(state.phase == "battle" and state.battle.player and #state.battle.model.actors >= 10)
local enemy = nil
local teams = {}
for _, actor in ipairs(state.battle.model.actors) do
    teams[actor.team] = true
    if actor.team ~= "team1" and not enemy then enemy = actor end
end
assert(enemy)
assert(teams.team1 and teams.team2 and teams.team3 and teams.team4)
assert(#state.battle.model.bases == 4)
assert(state.battle.model.pathfinder and state.battle.model.orca, "required navigation systems were not created")
assert(state.battle.model.steering == nil, "unused steering solver should not be constructed")
assert(state.battle.model.director == nil and state.battle.model.ai_lod == nil, "unused AI handles should not be constructed")
assert(state.battle.model.width == 250 and state.battle.model.height == 250, "arena is not 200% of the original dimensions")
assert(state.battle.model.world.tile(state.battle.model, 10, 10) == "grass", "grass biome missing")
assert(state.battle.model.world.tile(state.battle.model, 200, 50) == "sand", "sand biome missing")
assert(state.battle.model.world.tile(state.battle.model, 52, 70) == "water", "water biome missing")
assert(state.battle.model.world.move_multiplier(state.battle.model, 52 * 32, 70 * 32) < 1, "water does not slow movement")
assert(content.content.presets.f9.left == "repair_beam" and content.content.presets.f9.right == "repair_drone_bay")
assert(content.content.presets.f10.left == "sentry_deployer" and content.content.presets.f10.right == "missile_turret_deployer")
assert(content.content.presets.f11.left == "proximity_mine_layer" and content.content.presets.f11.right == "emp_mine_layer")
assert(content.content.presets.f12.backpack == "night_vision" and content.content.weapons.smoke_projector.smoke == true)

local nav = state.modules.Navigation
local ok_values, first_value, second_value = nav.safe_call({
    pair = function() return 17, 29 end,
}, "pair")
assert(ok_values and first_value == 17 and second_value == 29, "protected calls lose multiple return values")

local path = nav.find_path(state.battle.model, state.battle.player, enemy.x, enemy.y)
assert(type(path) == "table" and #path > 0, "pathfinder did not return a route")
state.battle.model.actors[1].pref_vx, state.battle.model.actors[1].pref_vy = 12, 7
nav.update_avoidance(state.battle.model, state.battle.model.actors, 1 / 60)
local has_safe_velocity = false
for _, actor in ipairs(state.battle.model.actors) do
    if not actor.dead and type(actor.safe_vx) == "number" and type(actor.safe_vy) == "number" then
        has_safe_velocity = true
        break
    end
end
assert(has_safe_velocity, "ORCA did not return both safe velocity components")

local player = state.battle.player
state.battle.model.camera:lookAt(player.x, player.y)
local directions = {
    {1, 0}, {1, 1}, {0, 1}, {-1, 1},
    {-1, 0}, {-1, -1}, {0, -1}, {1, -1},
}
for index, direction in ipairs(directions) do
    local length = math.sqrt(direction[1] * direction[1] + direction[2] * direction[2])
    local expected_x, expected_y = direction[1] / length, direction[2] / length
    local target_x, target_y = player.x + expected_x * 500, player.y + expected_y * 500
    state.modules.Movement.update(state, player, 1 / 60, target_x, target_y)
    local cursor_angle = math.atan2(target_y - player.y, target_x - player.x)
    assert(math.cos(player.angle - cursor_angle) > 0.9999, "mech chassis misses cursor in direction " .. index)
    player.cooldowns[1], player.spread_slots[1], player.energy = 0, 0, player.build.max_energy
    local before = #state.battle.model.projectiles
    assert(state.modules.Combat.fire(state, player, target_x, target_y, 1))
    local projectile = state.battle.model.projectiles[before + 1]
    assert(projectile, "cursor shot missing in direction " .. index)
    local velocity_len = math.sqrt(projectile.vx * projectile.vx + projectile.vy * projectile.vy)
    local dot = projectile.vx / velocity_len * expected_x + projectile.vy / velocity_len * expected_y
    assert(dot > 0.9999, "projectile misses cursor in direction " .. index)
end


for i = #state.battle.model.projectiles, 1, -1 do
    state.modules.Physics.destroy(state.battle.model, state.battle.model.projectiles[i])
    table.remove(state.battle.model.projectiles, i)
end

local pyro = assert(build.from_preset(content, "f5"))
player.build = pyro
player.energy = pyro.max_energy
player.cooldowns = {0, 0}
player.spread_slots = {0, 0}
local close_enemy_build = assert(build.from_preset(content, "f2"))
local close_enemy = state.modules.Combat.spawn_actor(
    state, "team2", close_enemy_build, player.x + 120, player.y, #state.battle.model.actors + 1, false
)
local hp_before, effects_before = close_enemy.hp, #state.battle.model.effects
assert(state.modules.Combat.fire(state, player, close_enemy.x, close_enemy.y, 1), "flamethrower did not fire")
assert(close_enemy.hp < hp_before, "flamethrower dealt no cone damage")
assert(#state.battle.model.effects > effects_before, "flamethrower created no visible stream")
assert(pyro.vision_arc and pyro.vision_arc < 360, "corpus field-of-view arc was not composed")

state.modules.Awareness.compute_team(state, "team1")
state.modules.Minimap.update(state)
local pcx, pcy = state.battle.model.world.cell(state.battle.model, player.x, player.y)
assert(state.battle.model.minimap:getFogLevel(pcx, pcy) == 2, "minimap fog is not synchronized with awareness")
assert(pcall(state.modules.Minimap.draw, state), "minimap HUD render failed")
assert(state.modules.Awareness.can_see(state, player, close_enemy), "nearby illuminated enemy is not visible before smoke")
state.modules.Effects.smoke(state, player.x + 60, player.y, 48, 5)
assert(not state.modules.Awareness.can_see(state, player, close_enemy), "smoke does not block line of sight")

player.cooldowns[2], player.energy = 0, pyro.max_energy
local grenade_target_x, grenade_target_y = player.x + 240, player.y + 35
assert(state.modules.Combat.fire(state, player, grenade_target_x, grenade_target_y, 2), "grenade did not fire")
local grenade = state.battle.model.projectiles[#state.battle.model.projectiles]
assert(grenade and grenade.explosive and grenade.target_x and grenade.target_y, "explosive target was not stored")
assert(math.abs(grenade.target_x - grenade_target_x) < 0.01 and math.abs(grenade.target_y - grenade_target_y) < 0.01,
    "explosive target differs from reticle")
grenade.travel = grenade.target_distance
local explosions_before = #state.battle.model.explosions
state.modules.Combat.update(state, 0)
local blast = state.battle.model.explosions[#state.battle.model.explosions]
assert(#state.battle.model.explosions == explosions_before + 1, "explosive did not detonate at target")
assert(math.abs(blast.x - grenade_target_x) < 0.01 and math.abs(blast.y - grenade_target_y) < 0.01,
    "explosion differs from reticle")

local has_min, zoom_min, has_max, zoom_max = state.battle.model.camera:getZoomConstraints()
assert(has_min and has_max and zoom_min == content.game.camera_zoom_min and zoom_max == content.game.camera_zoom_max,
    "camera zoom constraints are not loaded from TOML")
state.battle.model.camera:setZoom(1)
assert(state.modules.Camera.zoom_by(state, state.battle.model, 1), "positive mouse wheel was ignored")
assert(state.battle.model.camera:getZoom() > 1, "positive mouse wheel did not zoom in")
assert(state.modules.Camera.zoom_by(state, state.battle.model, -1), "negative mouse wheel was ignored")
assert(math.abs(state.battle.model.camera:getZoom() - 1) < 0.001, "negative mouse wheel did not zoom out")
state.battle.model.camera:setZoom(1.5)
local screen_x, screen_y = state.battle.model.camera:toScreen(player.x + 123, player.y - 77)
local world_x, world_y = state.battle.model.camera:toWorld(screen_x, screen_y)
assert(math.abs(world_x - (player.x + 123)) < 0.01 and math.abs(world_y - (player.y - 77)) < 0.01,
    "camera zoom screen/world transform is inconsistent")

local _, _, _, base_light = state.battle.model.tilelight:getLight(34, 34, 1)
local _, _, _, shadow_light = state.battle.model.tilelight:getLight(70, 18, 1)
assert(base_light > shadow_light, "team base tile light does not illuminate the map")
assert(not lurek.awareness.lineOfSight(
    state.battle.model.field,
    {x = 120, y = 50, z = 1},
    {x = 130, y = 50, z = 1},
    {channel = "vision"}
), "wall does not block tile line of sight")
local stress_started = os.clock()
for _ = 1, 120 do
    state.modules.Battle.process_physics(state, 1 / 60)
    state.modules.Battle.process(state, 1 / 60)
end
local stress_elapsed = os.clock() - stress_started
assert(stress_elapsed < 5.0, "120-frame battle stress ceiling exceeded: " .. tostring(stress_elapsed))
assert(state.battle.elapsed > 0 and state.battle.model.projectiles ~= nil)
state.modules.Title.draw(state)
state.phase = "hangar"
state.modules.Hangar.draw(state)
state.phase = "battle"
state.modules.Battle.draw(state)
state.modules.Battle.draw_ui(state)
state.last_battle = {score = state.battle.score, win = false}
state.phase = "results"
state.modules.Results.draw(state)
end)
end)

test_summary()
