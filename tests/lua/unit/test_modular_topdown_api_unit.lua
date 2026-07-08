-- Unit coverage for modular top-down combat API additions.

describe("ecs loadout API", function()
    -- @covers lurek.ecs.newSlotDef
    -- @covers lurek.ecs.newPartDef
    -- @covers lurek.ecs.newLoadout
    -- @covers lurek.ecs.newStatBlock
    -- @covers LStatBlock:get
    -- @covers LStatBlock:set
    -- @covers LStatBlock:add
    -- @covers LStatBlock:toTable
    -- @covers LSlotDef:getName
    -- @covers LSlotDef:getAccepts
    -- @covers LSlotDef:isRequired
    -- @covers LSlotDef:getHardpoint
    -- @covers LPartDef:getId
    -- @covers LPartDef:getSlot
    -- @covers LPartDef:getTags
    -- @covers LPartDef:getStats
    -- @covers LPartDef:getCost
    -- @covers LPartDef:getHardpoints
    -- @covers LPartDef:getVisuals
    -- @covers LLoadout:equip
    -- @covers LLoadout:unequip
    -- @covers LLoadout:validate
    -- @covers LLoadout:computeStats
    -- @covers LLoadout:getHardpoints
    -- @covers LLoadout:getCost
    it("equips compatible parts and aggregates stats", function()
        local slot = lurek.ecs.newSlotDef("arm", { accepts = { "weapon" }, required = true, hardpoint = "left" })
        local part = lurek.ecs.newPartDef({
            id = "laser_arm",
            slot = "arm",
            tags = { "weapon" },
            stats = { firepower = 4, speed = -1 },
            cost = 25,
            hardpoints = { "muzzle" },
        })
        local loadout = lurek.ecs.newLoadout({ slots = { slot }, baseStats = lurek.ecs.newStatBlock({ speed = 10 }) })
        local extra = lurek.ecs.newStatBlock()
        extra:set("armor", 2)
        extra:add("armor", 1)

        expect_equal("arm", slot:getName())
        expect_equal("weapon", slot:getAccepts()[1])
        expect_true(slot:isRequired())
        expect_equal("left", slot:getHardpoint())
        expect_equal("laser_arm", part:getId())
        expect_equal("arm", part:getSlot())
        expect_equal("weapon", part:getTags()[1])
        expect_equal(4, part:getStats().firepower)
        expect_equal(25, part:getCost())
        expect_equal("muzzle", part:getHardpoints()[1])
        expect_equal(nil, part:getVisuals().missing_slot)
        expect_equal(3, extra:get("armor"))
        expect_true(loadout:equip(part))
        expect_true(loadout:validate().valid)
        expect_equal(25, loadout:getCost())
        expect_equal(9, loadout:computeStats():get("speed"))
        expect_equal(4, loadout:computeStats():toTable().firepower)
        local has_muzzle = false
        for _, hardpoint in ipairs(loadout:getHardpoints()) do
            if hardpoint == "muzzle" then
                has_muzzle = true
            end
        end
        expect_true(has_muzzle)
        expect_type("table", loadout:toComponent())
        expect_true(loadout:unequip("arm"))
    end)
end)

describe("physics top-down combat helpers", function()
    -- @covers LWorld:setWrapBounds
    -- @covers LWorld:wrapBody
    -- @covers LWorld:setTopDownDamping
    -- @covers LBody:applyThrust
    -- @covers LBody:applyTurn
    it("wraps bodies and accepts thrust helpers", function()
        local world = lurek.physics.newWorld(0, 0)
        world:setTopDownDamping(0.2, 0.3)
        world:setWrapBounds(0, 0, 100, 100)
        local body = world:newBody(120, 50, "dynamic")

        expect_no_error(function()
            body:applyThrust(10)
            body:applyTurn(1)
            world:wrapBody(body)
        end)
        local x = body:getX()
        expect_true(x >= 0 and x <= 100)
    end)

    -- @covers LWorld:spawnBallisticProjectile
    it("stores combat projectile metadata", function()
        local world = lurek.physics.newWorld(0, 0)
        local target = world:newBody(16, 0, 8, 8, "static")
        local id = world:spawnBallisticProjectile({
            from = { x = 0, y = 0, z = 1 },
            target = { x = 16, y = 0, z = 1 },
            speed = 8,
            gravity = 0,
            radius = 1,
            maxTime = 2,
            sampleDt = 0.25,
            homingTarget = target,
            factionMask = 3,
            pierceCount = 1,
            impact = "primary",
        })
        local projectile = world:getBallisticProjectile(id)
        expect_equal(3, projectile.factionMask)
        expect_equal(1, projectile.pierceCount)
        expect_equal("primary", projectile.impact)
    end)
end)

describe("rts order and map helpers", function()
    -- @covers LCommandQueue:pushOrder
    -- @covers LCommandQueue:peekOrder
    -- @covers LCommandQueue:replaceOrders
    -- @covers LCommandQueue:cancelByTag
    -- @covers LCommandQueue:getOrderSnapshot
    it("manages RTS-style orders", function()
        local queue = lurek.ai.newCommandQueue()
        queue:pushOrder({ kind = "move", x = 8, y = 4, tag = "path" })
        expect_equal("move", queue:peekOrder().kind)
        queue:replaceOrders({ { kind = "attackMove", targetX = 16, targetY = 8, tag = "combat" } })
        expect_equal("attackMove", queue:getOrderSnapshot()[1].kind)
        expect_equal(1, queue:cancelByTag("combat"))
    end)

    -- @covers LUnitPathfinder:findFormationPaths
    -- @covers LUnitPathfinder:findAttackMovePaths
    -- @covers LUnitPathfinder:reserveCells
    -- @covers LUnitPathfinder:clearReservations
    it("plans batch paths and tracks reservations", function()
        local grid = lurek.pathfind.newNavGrid(8, 8)
        local pathfinder = lurek.pathfind.newPathfinder(grid)
        local starts = { { x = 1, y = 1 }, { x = 2, y = 1 } }
        local formation = pathfinder:findFormationPaths(starts, 8, 8, 1, 1)
        local attack = pathfinder:findAttackMovePaths(starts, 8, 8, 1, 16)

        expect_true(#formation >= 1)
        expect_true(#attack >= 1)
        expect_true(pathfinder:reserveCells(starts) >= 1)
        expect_true(pathfinder:clearReservations() >= 1)
    end)

    -- @covers LTileField:setOccupant
    -- @covers LTileField:clearOccupant
    -- @covers LTileField:setResource
    -- @covers LTileField:isBuildable
    it("stores RTS occupancy, resources, and buildability", function()
        local field = lurek.tilefield.new({ width = 8, height = 8 })
        field:setOccupant(2, 3, 1, 99)
        field:setOccupant(1, 1, 77)
        field:setResource(2, 3, 1, "ore")
        field:setBuildable(2, 3, 1, true)
        expect_equal(77, field:getOccupant(1, 1, 1))
        expect_equal(99, field:getOccupant(2, 3, 1))
        expect_equal("ore", field:getResource(2, 3, 1))
        expect_true(field:isBuildable(2, 3, 1))
        field:clearOccupant(2, 3, 1)
        expect_equal(nil, field:getOccupant(2, 3, 1))
    end)

    -- @covers LTileAwareness:updateSightSources
    it("updates sight for many team sources", function()
        local field = lurek.tilefield.new({ width = 8, height = 8 })
        local awareness = lurek.awareness.newTileAwareness(field, { players = { "blue" } })
        awareness:updateSightSources("blue", {
            { x = 2, y = 2, z = 1, range = 2 },
            { x = 6, y = 6, z = 1, range = 1 },
        })
        expect_true(awareness:isVisible("blue", 2, 2, 1))
        expect_true(awareness:isVisible("blue", 6, 6, 1))
    end)
end)

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
    -- @covers lurek.ui.newSlotGrid
    -- @covers lurek.ui.newComparisonBar
    it("creates standard UI widgets for loadout data", function()
        local stats = lurek.ui.newStatPanel({ speed = 10, armor = 3 })
        local slots = lurek.ui.newSlotGrid({ { name = "torso", part = "medium" }, "weapon" }, 2)
        local bar = lurek.ui.newComparisonBar("speed", 10, 12)
        expect_equal(2, stats:getChildCount())
        expect_equal(2, slots:getChildCount())
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
