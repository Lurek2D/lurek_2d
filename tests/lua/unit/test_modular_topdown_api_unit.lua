-- Unit coverage for modular top-down combat API additions.

-- @describe
describe("ecs loadout API", function()
    local function slot()
        return lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, required = true, hardpoint = "left" })
    end

    local function part()
        return lurek.ecs.newPartDef({
            id = "laser_arm",
            slot = "arm",
            tags = { "weapon" },
            stats = { firepower = 4, speed = -1 },
            cost = 25,
            hardpoints = { "muzzle" },
            visuals = { arm = "laser_sprite" },
        })
    end

    local function loadout()
        return lurek.ecs.newLoadout({ slots = { slot() }, baseStats = lurek.ecs.newStatBlock({ speed = 10 }) })
    end

    -- @covers lurek.ecs.newSlotDef
    it("creates slot definitions", function()
        expect_equal("arm", slot():getName())
    end)

    -- @covers lurek.ecs.newPartDef
    it("creates part definitions", function()
        expect_equal("laser_arm", part():getId())
    end)

    -- @covers lurek.ecs.newLoadout
    it("creates loadout containers", function()
        expect_equal("LLoadout", loadout():type())
    end)

    -- @covers lurek.ecs.newStatBlock
    it("creates stat blocks", function()
        expect_equal("LStatBlock", lurek.ecs.newStatBlock():type())
    end)

    -- @covers LStatBlock:get
    it("reads stat values", function()
        local stats = lurek.ecs.newStatBlock({ armor = 3 })
        expect_equal(3, stats:get("armor"))
    end)

    -- @covers LStatBlock:set
    it("sets stat values", function()
        local stats = lurek.ecs.newStatBlock()
        stats:set("armor", 2)
        expect_equal(2, stats:get("armor"))
    end)

    -- @covers LStatBlock:add
    it("adds stat deltas", function()
        local stats = lurek.ecs.newStatBlock({ armor = 2 })
        stats:add("armor", 1)
        expect_equal(3, stats:get("armor"))
    end)

    -- @covers LStatBlock:toTable
    it("exports stat values as a table", function()
        local stats = lurek.ecs.newStatBlock({ firepower = 4 })
        expect_equal(4, stats:toTable().firepower)
    end)

    -- @covers LStatBlock:type
    it("returns stat block type names", function()
        expect_equal("LStatBlock", lurek.ecs.newStatBlock():type())
    end)

    -- @covers LStatBlock:typeOf
    it("recognizes stat block types", function()
        local stats = lurek.ecs.newStatBlock()
        expect_true(stats:typeOf("LStatBlock"))
        expect_true(stats:typeOf("LObject"))
    end)

    -- @covers LSlotDef:getName
    it("reads slot names", function()
        expect_equal("arm", slot():getName())
    end)

    -- @covers LSlotDef:getAccepts
    it("reads accepted part tags", function()
        expect_equal("weapon", slot():getAccepts()[1])
    end)

    -- @covers LSlotDef:isRequired
    it("reads required slot state", function()
        expect_true(slot():isRequired())
    end)

    -- @covers LSlotDef:getHardpoint
    it("reads slot hardpoints", function()
        expect_equal("left", slot():getHardpoint())
    end)

    -- @covers LSlotDef:type
    it("returns slot type names", function()
        expect_equal("LSlotDef", slot():type())
    end)

    -- @covers LSlotDef:typeOf
    it("recognizes slot types", function()
        local def = slot()
        expect_true(def:typeOf("LSlotDef"))
        expect_true(def:typeOf("LObject"))
    end)

    -- @covers LPartDef:getId
    it("reads part ids", function()
        expect_equal("laser_arm", part():getId())
    end)

    -- @covers LPartDef:getSlot
    it("reads part slots", function()
        expect_equal("arm", part():getSlot())
    end)

    -- @covers LPartDef:getTags
    it("reads part tags", function()
        expect_equal("weapon", part():getTags()[1])
    end)

    -- @covers LPartDef:getStats
    it("reads part stat tables", function()
        expect_equal(4, part():getStats().firepower)
    end)

    -- @covers LPartDef:getCost
    it("reads part costs", function()
        expect_equal(25, part():getCost())
    end)

    -- @covers LPartDef:getHardpoints
    it("reads part hardpoints", function()
        expect_equal("muzzle", part():getHardpoints()[1])
    end)

    -- @covers LPartDef:getVisuals
    it("reads part visuals", function()
        expect_equal("laser_sprite", part():getVisuals().arm)
    end)

    -- @covers LPartDef:type
    it("returns part type names", function()
        expect_equal("LPartDef", part():type())
    end)

    -- @covers LPartDef:typeOf
    it("recognizes part types", function()
        local def = part()
        expect_true(def:typeOf("LPartDef"))
        expect_true(def:typeOf("LObject"))
    end)

    -- @covers LLoadout:addSlot
    it("adds slots to loadouts", function()
        local setup = lurek.ecs.newLoadout()
        expect_no_error(function()
            setup:addSlot(slot())
        end)
    end)

    -- @covers LLoadout:equip
    it("equips compatible parts", function()
        expect_true(loadout():equip(part()))
    end)

    -- @covers LLoadout:unequip
    it("unequips parts by slot", function()
        local setup = loadout()
        setup:equip(part())
        expect_true(setup:unequip("arm"))
    end)

    -- @covers LLoadout:validate
    it("validates required slots", function()
        local setup = loadout()
        setup:equip(part())
        expect_true(setup:validate().valid)
    end)

    -- @covers LLoadout:computeStats
    it("computes aggregate stats", function()
        local setup = loadout()
        setup:equip(part())
        expect_equal(9, setup:computeStats():get("speed"))
    end)

    -- @covers LLoadout:getHardpoints
    it("collects equipped hardpoints", function()
        local setup = loadout()
        setup:equip(part())
        expect_equal("left", setup:getHardpoints()[1])
    end)

    -- @covers LLoadout:getCost
    it("sums equipped part costs", function()
        local setup = loadout()
        setup:equip(part())
        expect_equal(25, setup:getCost())
    end)

    -- @covers LLoadout:toComponent
    it("exports loadout component tables", function()
        expect_type("table", loadout():toComponent())
    end)

    -- @covers LLoadout:type
    it("returns loadout type names", function()
        expect_equal("LLoadout", loadout():type())
    end)

    -- @covers LLoadout:typeOf
    it("recognizes loadout types", function()
        local setup = loadout()
        expect_true(setup:typeOf("LLoadout"))
        expect_true(setup:typeOf("LObject"))
    end)
end)

-- @describe
describe("physics top-down combat helpers", function()
    local function world_and_body()
        local world = lurek.physics.newWorld(0, 0)
        local body = world:newBody(120, 50, "dynamic")
        return world, body
    end

    -- @covers LWorld:setWrapBounds
    it("sets wrap bounds for top-down worlds", function()
        local world = lurek.physics.newWorld(0, 0)
        expect_no_error(function()
            world:setWrapBounds(0, 0, 100, 100)
        end)
    end)

    -- @covers LWorld:wrapBody
    it("wraps bodies into configured bounds", function()
        local world, body = world_and_body()
        world:setWrapBounds(0, 0, 100, 100)
        world:wrapBody(body)
        expect_true(body:getX() >= 0 and body:getX() <= 100)
    end)

    -- @covers LWorld:setTopDownDamping
    it("sets top-down damping factors", function()
        local world = lurek.physics.newWorld(0, 0)
        expect_no_error(function()
            world:setTopDownDamping(0.2, 0.3)
        end)
    end)

    -- @covers LBody:applyThrust
    it("applies top-down thrust to bodies", function()
        local _, body = world_and_body()
        expect_no_error(function()
            body:applyThrust(10)
        end)
    end)

    -- @covers LBody:applyTurn
    it("applies top-down turning to bodies", function()
        local _, body = world_and_body()
        expect_no_error(function()
            body:applyTurn(1)
        end)
    end)
end)

-- @describe
describe("rts order and map helpers", function()
    -- @covers LCommandQueue:pushOrder
    it("pushes command queue orders", function()
        local queue = lurek.ai.newCommandQueue()
        queue:pushOrder({ kind = "move", x = 8, y = 4, tag = "path" })
        expect_equal("move", queue:peekOrder().kind)
    end)

    -- @covers LCommandQueue:peekOrder
    it("peeks command queue orders", function()
        local queue = lurek.ai.newCommandQueue()
        queue:pushOrder({ kind = "move", x = 8, y = 4, tag = "path" })
        expect_equal("move", queue:peekOrder().kind)
    end)

    -- @covers LCommandQueue:replaceOrders
    it("replaces command queue orders", function()
        local queue = lurek.ai.newCommandQueue()
        queue:replaceOrders({ { kind = "attackMove", targetX = 16, targetY = 8, tag = "combat" } })
        expect_equal("attackMove", queue:getOrderSnapshot()[1].kind)
    end)

    -- @covers LCommandQueue:cancelByTag
    it("cancels command queue orders by tag", function()
        local queue = lurek.ai.newCommandQueue()
        queue:pushOrder({ kind = "attackMove", targetX = 16, targetY = 8, tag = "combat" })
        expect_equal(1, queue:cancelByTag("combat"))
    end)

    -- @covers LCommandQueue:getOrderSnapshot
    it("returns command queue snapshots", function()
        local queue = lurek.ai.newCommandQueue()
        queue:pushOrder({ kind = "move", x = 8, y = 4, tag = "path" })
        expect_equal("move", queue:getOrderSnapshot()[1].kind)
    end)

    local function pathfinder()
        local grid = lurek.pathfind.newNavGrid(8, 8)
        return lurek.pathfind.newPathfinder(grid)
    end

    -- @covers LUnitPathfinder:findFormationPaths
    it("plans formation paths", function()
        local paths = pathfinder():findFormationPaths({ { x = 1, y = 1 }, { x = 2, y = 1 } }, 8, 8, 1, 1)
        expect_true(#paths >= 1)
    end)

    -- @covers LUnitPathfinder:findAttackMovePaths
    it("plans attack-move paths", function()
        local paths = pathfinder():findAttackMovePaths({ { x = 1, y = 1 }, { x = 2, y = 1 } }, 8, 8, 1, 16)
        expect_true(#paths >= 1)
    end)

    -- @covers LUnitPathfinder:reserveCells
    it("reserves pathfinder cells", function()
        expect_true(pathfinder():reserveCells({ { x = 1, y = 1 }, { x = 2, y = 1 } }) >= 1)
    end)

    -- @covers LUnitPathfinder:clearReservations
    it("clears pathfinder reservations", function()
        local pf = pathfinder()
        pf:reserveCells({ { x = 1, y = 1 }, { x = 2, y = 1 } })
        expect_true(pf:clearReservations() >= 1)
    end)

    local function field()
        return lurek.tilefield.new({ width = 8, height = 8 })
    end

    -- @covers LTileField:setOccupant
    it("sets tile occupants", function()
        local tiles = field()
        tiles:setOccupant(2, 3, 1, 99)
        expect_equal(99, tiles:getOccupant(2, 3, 1))
    end)

    -- @covers LTileField:clearOccupant
    it("clears tile occupants", function()
        local tiles = field()
        tiles:setOccupant(2, 3, 1, 99)
        tiles:clearOccupant(2, 3, 1)
        expect_equal(nil, tiles:getOccupant(2, 3, 1))
    end)

    -- @covers LTileField:getOccupant
    it("reads tile occupants", function()
        local tiles = field()
        tiles:setOccupant(1, 1, 77)
        expect_equal(77, tiles:getOccupant(1, 1, 1))
    end)

    -- @covers LTileField:setResource
    it("sets tile resources", function()
        local tiles = field()
        tiles:setResource(2, 3, 1, "ore")
        expect_equal("ore", tiles:getResource(2, 3, 1))
    end)

    -- @covers LTileField:getResource
    it("reads tile resources", function()
        local tiles = field()
        tiles:setResource(2, 3, 1, "ore")
        expect_equal("ore", tiles:getResource(2, 3, 1))
    end)

    -- @covers LTileField:setBuildable
    it("sets tile buildability", function()
        local tiles = field()
        tiles:setBuildable(2, 3, 1, true)
        expect_true(tiles:isBuildable(2, 3, 1))
    end)

    -- @covers LTileField:isBuildable
    it("reads tile buildability", function()
        local tiles = field()
        tiles:setBuildable(2, 3, 1, true)
        expect_true(tiles:isBuildable(2, 3, 1))
    end)

    -- @covers LTileAwareness:updateSightSources
    it("updates sight for many team sources", function()
        local tiles = field()
        local awareness = lurek.awareness.newTileAwareness(tiles, { players = { "blue" } })
        awareness:updateSightSources("blue", {
            { x = 2, y = 2, z = 1, range = 2 },
            { x = 6, y = 6, z = 1, range = 1 },
        })
        expect_true(awareness:isVisible("blue", 2, 2, 1))
        expect_true(awareness:isVisible("blue", 6, 6, 1))
    end)
end)

-- @describe
describe("presentation and save adapters", function()
    -- @covers LSkeleton:applyLoadoutVisuals
    it("applies loadout visual mappings to skeleton slots", function()
        local slot = lurek.ecs.newSlotDef("weapon", { accepts = { "gun" } })
        local part = lurek.ecs.newPartDef({
            id = "railgun",
            slot = "weapon",
            tags = { "gun" },
            visuals = { weapon_slot = "railgun_attachment" },
        })
        local loadout = lurek.ecs.newLoadout({ slots = { slot } })
        loadout:equip(part)

        local skeleton = lurek.spine.newSkeleton("mech")
        local root = skeleton:addBone("root")
        skeleton:addSlot("weapon_slot", root, "empty")
        expect_equal(1, skeleton:applyLoadoutVisuals(loadout))
    end)

    -- @covers LSpriteBatch:addComposite
    it("adds composite sprite parts to a batch", function()
        local image = lurek.render.newImage("assets/icon.png")
        local batch = lurek.render.newSpriteBatch(image, 8)
        local count = batch:addComposite({
            { x = 0, y = 0, quadX = 0, quadY = 0, quadW = 8, quadH = 8 },
            { x = 8, y = 0, quadX = 0, quadY = 0, quadW = 8, quadH = 8 },
        })
        expect_equal(2, count)
        expect_equal(2, batch:getCount())
    end)

    -- @covers lurek.ui.newStatPanel
    it("creates stat panel widgets", function()
        local stats = lurek.ui.newStatPanel({ speed = 10, armor = 3 })
        expect_equal(2, stats:getChildCount())
    end)

    -- @covers lurek.ui.newSlotGrid
    it("creates slot grid widgets", function()
        local slots = lurek.ui.newSlotGrid({ { name = "torso", part = "medium" }, "weapon" }, 2)
        expect_equal(2, slots:getChildCount())
    end)

    -- @covers lurek.ui.newComparisonBar
    it("creates comparison bar widgets", function()
        local bar = lurek.ui.newComparisonBar("speed", 10, 12)
        expect_equal(3, bar:getChildCount())
    end)

    -- @covers LSaveManager:registerSchema
    it("registers schema names through the existing migration system", function()
        local sm = lurek.save.newSaveManager()
        sm:registerSchema("ecs_loadout", 2, function(data)
            data.migrated = true
            return data
        end)
        expect_equal(2, sm:getSchemaVersion())
    end)
end)

test_summary()
