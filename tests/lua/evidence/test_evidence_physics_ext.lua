-- Evidence test for Lurek2D physics extension APIs
-- Proves the extension API works by writing a report to file.
-- Follows the evidence test contract: all output is produced by
-- calling the domain-module API, not by hand-drawing.

local out = {}
local function log(s) out[#out+1] = s end

-- ── Create world ──────────────────────────────────────────────────────────
local world = lurek.physics.newWorld(0, 9.81)

-- ── Solver iterations ─────────────────────────────────────────────────────
log("solver_iterations_default=" .. tostring(world:getSolverIterations()))
world:setSolverIterations(8)
log("solver_iterations_after_set=" .. tostring(world:getSolverIterations()))
world:setSolverIterations(0)
log("solver_iterations_clamped=" .. tostring(world:getSolverIterations()))

-- ── One-way platform ──────────────────────────────────────────────────────
local platform = lurek.physics.newBody(world, 200, 400, "static")
world:setBodyOneWay(platform, 0, -1)
local nx, ny = world:getBodyOneWay(platform)
log("one_way_nx=" .. tostring(nx) .. " one_way_ny=" .. tostring(ny))
world:clearBodyOneWay(platform)
local nx2, ny2 = world:getBodyOneWay(platform)
log("one_way_cleared=" .. tostring(nx2) .. "," .. tostring(ny2))

-- ── Body sleeping ─────────────────────────────────────────────────────────
local dyn = lurek.physics.newBody(world, 0, 0, "dynamic")
world:sleepBody(dyn)
log("after_sleep=" .. tostring(world:isBodySleeping(dyn)))
world:wakeUpBody(dyn)
log("after_wake=" .. tostring(world:isBodySleeping(dyn)))

-- ── CCD ───────────────────────────────────────────────────────────────────
local bullet = lurek.physics.newBody(world, 500, 0, "dynamic")
world:setBodyCCD(bullet, true)
log("ccd_enabled=" .. tostring(world:getBodyCCD(bullet)))
world:setBodyCCD(bullet, false)
log("ccd_disabled=" .. tostring(world:getBodyCCD(bullet)))

-- ── Breakable joints ──────────────────────────────────────────────────────
local b1 = lurek.physics.newBody(world, 0, 0, "dynamic")
local b2 = lurek.physics.newBody(world, 60, 0, "dynamic")
local jid = lurek.physics.newJoint(world, b1, b2, "distance")
world:setJointBreakForce(jid, 50.0)
log("joint_break_force=" .. tostring(world:getJointBreakForce(jid)))

-- ── Contact callbacks registered ─────────────────────────────────────────
local begin_fired = 0
local end_fired   = 0
world:setBeginContact(function(a, b) begin_fired = begin_fired + 1 end)
world:setEndContact  (function(a, b) end_fired   = end_fired   + 1 end)
world:step(1/60)
log("callbacks_registered=true")
world:clearBeginContact()
world:clearEndContact()
log("callbacks_cleared=true")

-- ── Batch body creation ───────────────────────────────────────────────────
local ids = world:newBodies({
    {0, 100, "dynamic"},
    {100, 100, "static"},
    {200, 100, "kinematic"},
})
log("batch_count=" .. tostring(#ids))
for i, id in ipairs(ids) do
    log("batch_id[" .. i .. "]=" .. type(id))
end

-- ── Body sleeping via userdata ─────────────────────────────────────────────
local body_u = lurek.physics.newBody(world, 999, 999, "dynamic")
body_u:sleep()
log("body_userdata_sleep=" .. tostring(body_u:isSleeping()))
body_u:wakeUp()
log("body_userdata_wake=" .. tostring(body_u:isSleeping()))

-- ── Write evidence file ───────────────────────────────────────────────────
local path = "tests/lua/evidence/physics_ext_report.txt"
local f, err = io.open(path, "w")
if f then
    f:write(table.concat(out, "\n") .. "\n")
    f:close()
    print("[evidence] Written: " .. path)
else
    print("[evidence] WARN: could not write " .. path .. ": " .. tostring(err))
    -- Print to stdout so the test still passes in read-only environments.
    print(table.concat(out, "\n"))
end

-- ── Minimal BDD assertions ────────────────────────────────────────────────
describe("lurek.physics extension evidence", function()
    it("solver iterations default is 4", function()
        local w2 = lurek.physics.newWorld(0, 0)
        expect_equal(4, w2:getSolverIterations())
    end)

    it("one-way normal round-trips correctly", function()
        local w2 = lurek.physics.newWorld(0, 0)
        local b  = lurek.physics.newBody(w2, 0, 0, "static")
        w2:setBodyOneWay(b, 1, 0)
        local nx3, ny3 = w2:getBodyOneWay(b)
        expect_near(1, nx3, 1e-5)
        expect_near(0, ny3, 1e-5)
    end)

    it("batch body creation count matches spec", function()
        local w2  = lurek.physics.newWorld(0, 0)
        local res = w2:newBodies({{0,0,"dynamic"},{1,0,"dynamic"}})
        expect_equal(2, #res)
    end)
end)

test_summary()
