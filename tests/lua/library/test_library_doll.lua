-- tests/lua/library/test_library_doll.lua
-- BDD tests for the doll (socket-based visual composition) module

local doll = require("library.doll")

-- â”€â”€ Part â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @covers library.doll.newPart
-- @description Verifies part defaults plus texture, transform, colour, flip, attribute, fixture, origin, and rotation-following helpers.
describe("Part", function()
    -- @description Verifies case: creates with default values.
    it("creates with default values", function()
        local p = doll.newPart()
        expect_not_nil(p, "newPart returns object")
        expect_nil(p:getTexture(), "no default texture")
        expect_nil(p:getQuad(), "no default quad")
        local ox, oy = p:getOffset()
        expect_equal(0, ox, "offsetX=0")
        expect_equal(0, oy, "offsetY=0")
        expect_equal(0, p:getRotation(), "rotation=0")
        local sx, sy = p:getScale()
        expect_equal(1, sx, "scaleX=1")
        expect_equal(1, sy, "scaleY=1")
        expect_equal(0, p:getDrawOrder(), "drawOrder=0")
        expect_equal("", p:getPartType(), "empty partType")
        expect_true(p:isVisible(), "visible by default")
        expect_true(p:getFollowsRotation(), "followsRotation by default")
    end)

    -- @description Verifies case: sets and gets texture.
    it("sets and gets texture", function()
        local p = doll.newPart()
        p:setTexture("hero.png")
        expect_equal("hero.png", p:getTexture())
    end)

    -- @description Verifies case: sets and gets offset.
    it("sets and gets offset", function()
        local p = doll.newPart()
        p:setOffset(10, 20)
        local ox, oy = p:getOffset()
        expect_equal(10, ox)
        expect_equal(20, oy)
    end)

    -- @description Verifies case: sets and gets scale with single arg.
    it("sets and gets scale with single arg", function()
        local p = doll.newPart()
        p:setScale(2)
        local sx, sy = p:getScale()
        expect_equal(2, sx)
        expect_equal(2, sy)
    end)

    -- @description Verifies case: sets and gets scale with two args.
    it("sets and gets scale with two args", function()
        local p = doll.newPart()
        p:setScale(3, 4)
        local sx, sy = p:getScale()
        expect_equal(3, sx)
        expect_equal(4, sy)
    end)

    -- @description Verifies case: sets and gets color.
    it("sets and gets color", function()
        local p = doll.newPart()
        p:setColor(0.5, 0.6, 0.7, 0.8)
        local r, g, b, a = p:getColor()
        expect_near(0.5, r, 0.001)
        expect_near(0.6, g, 0.001)
        expect_near(0.7, b, 0.001)
        expect_near(0.8, a, 0.001)
    end)

    -- @description Verifies case: default color alpha = 1 when omitted.
    it("default color alpha = 1 when omitted", function()
        local p = doll.newPart()
        p:setColor(1, 0, 0)
        local _, _, _, a = p:getColor()
        expect_equal(1, a)
    end)

    -- @description Verifies case: sets and gets flip.
    it("sets and gets flip", function()
        local p = doll.newPart()
        p:setFlip(true, false)
        local fx, fy = p:getFlip()
        expect_true(fx)
        expect_false(fy)
    end)

    -- @description Verifies case: flip with single arg defaults fy to false.
    it("flip with single arg defaults fy to false", function()
        local p = doll.newPart()
        p:setFlip(true)
        local fx, fy = p:getFlip()
        expect_true(fx)
        expect_false(fy)
    end)

    -- @description Verifies case: sets and gets attributes.
    it("sets and gets attributes", function()
        local p = doll.newPart()
        p:setAttribute("material", "steel")
        p:setAttribute("weight", 42)
        expect_equal("steel", p:getAttribute("material"))
        expect_equal(42, p:getAttribute("weight"))
        expect_nil(p:getAttribute("nonexist"))
    end)

    -- @description Verifies case: returns attribute keys.
    it("returns attribute keys", function()
        local p = doll.newPart()
        p:setAttribute("a", 1)
        p:setAttribute("b", 2)
        local keys = p:getAttributeKeys()
        expect_equal(2, #keys, "two keys")
    end)

    -- @description Verifies case: sets and gets fixture ref.
    it("sets and gets fixture ref", function()
        local p = doll.newPart()
        expect_nil(p:getFixture())
        local fixture = { id = 99 }
        p:setFixture(fixture)
        expect_equal(99, p:getFixture().id)
    end)

    -- @description Verifies case: sets and gets followsRotation.
    it("sets and gets followsRotation", function()
        local p = doll.newPart()
        p:setFollowsRotation(false)
        expect_false(p:getFollowsRotation())
    end)

    -- @description Verifies case: sets and gets origin.
    it("sets and gets origin", function()
        local p = doll.newPart()
        p:setOrigin(16, 32)
        local ox, oy = p:getOrigin()
        expect_equal(16, ox)
        expect_equal(32, oy)
    end)
end)

-- â”€â”€ DollTemplate â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @covers library.doll.newTemplate
-- @description Covers template naming, socket registration, duplicate rejection, removal, lookup, ordering, and default socket field values.
describe("DollTemplate", function()
    -- @description Verifies case: creates with name.
    it("creates with name", function()
        local t = doll.newTemplate("player")
        expect_equal("player", t:getName())
    end)

    -- @description Verifies case: renames.
    it("renames", function()
        local t = doll.newTemplate("old")
        t:setName("new")
        expect_equal("new", t:getName())
    end)

    -- @description Verifies case: adds sockets.
    it("adds sockets", function()
        local t = doll.newTemplate("char")
        t:addSocket("head",  "head",  0, -32, 0, 10)
        t:addSocket("torso", "body",  0,   0, 0, 5)
        t:addSocket("legs",  "legs",  0,  32, 0, 0)
        expect_equal(3, t:getSocketCount())
    end)

    -- @description Verifies case: gets socket by name.
    it("gets socket by name", function()
        local t = doll.newTemplate("char")
        t:addSocket("head", "head", 5, -10, 0.1, 10)
        local s = t:getSocket("head")
        expect_not_nil(s)
        expect_equal("head", s.name)
        expect_equal("head", s.acceptType)
        expect_equal(5, s.x)
        expect_equal(-10, s.y)
        expect_near(0.1, s.rotation, 0.001)
        expect_equal(10, s.drawOrder)
    end)

    -- @description Verifies case: get socket returns nil for missing name.
    it("get socket returns nil for missing name", function()
        local t = doll.newTemplate("char")
        expect_nil(t:getSocket("nonexist"))
    end)

    -- @description Verifies case: rejects duplicate socket names.
    it("rejects duplicate socket names", function()
        local t = doll.newTemplate("char")
        t:addSocket("head", "head", 0, 0)
        t:addSocket("head", "head", 5, 5)
        expect_equal(1, t:getSocketCount(), "still 1 socket")
        local s = t:getSocket("head")
        expect_equal(0, s.x, "original socket unchanged")
    end)

    -- @description Verifies case: removes socket.
    it("removes socket", function()
        local t = doll.newTemplate("char")
        t:addSocket("head", "", 0, 0)
        t:addSocket("body", "", 0, 10)
        expect_true(t:removeSocket("head"))
        expect_equal(1, t:getSocketCount())
        expect_nil(t:getSocket("head"))
        expect_not_nil(t:getSocket("body"))
    end)

    -- @description Verifies case: remove nonexistent returns false.
    it("remove nonexistent returns false", function()
        local t = doll.newTemplate("char")
        expect_false(t:removeSocket("nope"))
    end)

    -- @description Verifies case: lists socket names in order.
    it("lists socket names in order", function()
        local t = doll.newTemplate("char")
        t:addSocket("c_legs", "", 0, 0)
        t:addSocket("a_head", "", 0, 0)
        t:addSocket("b_body", "", 0, 0)
        local names = t:getSocketNames()
        expect_equal(3, #names)
        expect_equal("c_legs", names[1])
        expect_equal("a_head", names[2])
        expect_equal("b_body", names[3])
    end)

    -- @description Verifies case: uses defaults for optional parameters.
    it("uses defaults for optional parameters", function()
        local t = doll.newTemplate("simple")
        t:addSocket("s1")
        local s = t:getSocket("s1")
        expect_equal("", s.acceptType)
        expect_equal(0, s.x)
        expect_equal(0, s.y)
        expect_equal(0, s.rotation)
        expect_equal(0, s.drawOrder)
    end)
end)

-- â”€â”€ Doll â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @covers library.doll.newDoll
-- @description Exercises doll transforms, attachment rules, detach flows, socket occupancy queries, and body or userdata references.
describe("Doll", function()
    local function make_template()
        local t = doll.newTemplate("vehicle")
        t:addSocket("chassis",  "chassis",   0,   0, 0, 0)
        t:addSocket("turret",   "weapon",    0, -16, 0, 10)
        t:addSocket("exhaust",  "",          20,  5, 0, -1)
        return t
    end

    -- @description Verifies case: creates with template.
    it("creates with template", function()
        local t = make_template()
        local d = doll.newDoll(t)
        expect_not_nil(d)
        expect_equal(t, d:getTemplate())
    end)

    -- @description Verifies case: default transform.
    it("default transform", function()
        local d = doll.newDoll(make_template())
        local x, y = d:getPosition()
        expect_equal(0, x)
        expect_equal(0, y)
        expect_equal(0, d:getRotation())
        local sx, sy = d:getScale()
        expect_equal(1, sx)
        expect_equal(1, sy)
        expect_true(d:isVisible())
    end)

    -- @description Verifies case: sets position and rotation.
    it("sets position and rotation", function()
        local d = doll.newDoll(make_template())
        d:setPosition(100, 200)
        d:setRotation(1.5)
        local x, y = d:getPosition()
        expect_equal(100, x)
        expect_equal(200, y)
        expect_near(1.5, d:getRotation(), 0.001)
    end)

    -- @description Verifies case: attaches part to matching socket.
    it("attaches part to matching socket", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        part:setPartType("chassis")
        expect_true(d:attach("chassis", part))
        expect_equal(part, d:getPartAt("chassis"))
    end)

    -- @description Verifies case: rejects attach with wrong type.
    it("rejects attach with wrong type", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        part:setPartType("armor")
        expect_false(d:attach("chassis", part), "chassis accepts 'chassis' type only")
    end)

    -- @description Verifies case: accepts any type on empty acceptType socket.
    it("accepts any type on empty acceptType socket", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        part:setPartType("smoke")
        expect_true(d:attach("exhaust", part), "exhaust accepts anything")
    end)

    -- @description Verifies case: rejects attach to nonexistent socket.
    it("rejects attach to nonexistent socket", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        expect_false(d:attach("nonexist", part))
    end)

    -- @description Verifies case: detaches part.
    it("detaches part", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        part:setPartType("chassis")
        d:attach("chassis", part)
        local detached = d:detach("chassis")
        expect_equal(part, detached)
        expect_nil(d:getPartAt("chassis"))
    end)

    -- @description Verifies case: detach nonexistent returns nil.
    it("detach nonexistent returns nil", function()
        local d = doll.newDoll(make_template())
        expect_nil(d:detach("nonexist"))
    end)

    -- @description Verifies case: detachAll clears slots.
    it("detachAll clears slots", function()
        local d = doll.newDoll(make_template())
        local p1 = doll.newPart()
        p1:setPartType("chassis")
        local p2 = doll.newPart()
        p2:setPartType("weapon")
        d:attach("chassis", p1)
        d:attach("turret", p2)
        d:detachAll()
        expect_equal(0, #d:getAttachedSockets())
    end)

    -- @description Verifies case: findSocket returns socket name for a part.
    it("findSocket returns socket name for a part", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        part:setPartType("weapon")
        d:attach("turret", part)
        expect_equal("turret", d:findSocket(part))
    end)

    -- @description Verifies case: findSocket returns nil for unattached part.
    it("findSocket returns nil for unattached part", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        expect_nil(d:findSocket(part))
    end)

    -- @description Verifies case: lists attached and empty sockets.
    it("lists attached and empty sockets", function()
        local d = doll.newDoll(make_template())
        local part = doll.newPart()
        part:setPartType("chassis")
        d:attach("chassis", part)
        expect_equal(1, #d:getAttachedSockets())
        expect_equal(2, #d:getEmptySockets())
    end)

    -- @description Verifies case: body and userData refs.
    it("body and userData refs", function()
        local d = doll.newDoll(make_template())
        expect_nil(d:getBody())
        expect_nil(d:getUserData())
        d:setBody("body_ref")
        d:setUserData({ hp = 100 })
        expect_equal("body_ref", d:getBody())
        expect_equal(100, d:getUserData().hp)
    end)
end)

-- â”€â”€ getDrawList â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @covers library.doll.newDoll
-- @description Validates draw-list generation for empty and populated dolls, combined ordering, world transforms, visibility, and scale effects.
describe("Doll:getDrawList", function()
    -- @description Verifies case: empty doll returns empty list.
    it("empty doll returns empty list", function()
        local t = doll.newTemplate("empty")
        t:addSocket("slot1", "", 0, 0)
        local d = doll.newDoll(t)
        local dl = d:getDrawList()
        expect_equal(0, #dl)
    end)

    -- @description Verifies case: returns entries for attached parts.
    it("returns entries for attached parts", function()
        local t = doll.newTemplate("char")
        t:addSocket("head", "", 0, -20, 0, 10)
        t:addSocket("body", "", 0,   0, 0, 0)
        local d = doll.newDoll(t)
        d:setPosition(100, 200)

        local head = doll.newPart()
        local body = doll.newPart()
        d:attach("head", head)
        d:attach("body", body)

        local dl = d:getDrawList()
        expect_equal(2, #dl, "two entries")
    end)

    -- @description Verifies case: sorts by combined drawOrder.
    it("sorts by combined drawOrder", function()
        local t = doll.newTemplate("char")
        t:addSocket("bg",   "", 0, 0, 0, 0)
        t:addSocket("fg",   "", 0, 0, 0, 20)
        t:addSocket("mid",  "", 0, 0, 0, 10)
        local d = doll.newDoll(t)

        local p1 = doll.newPart()
        local p2 = doll.newPart()
        local p3 = doll.newPart()
        d:attach("bg", p1)
        d:attach("fg", p2)
        d:attach("mid", p3)

        local dl = d:getDrawList()
        expect_equal("bg",  dl[1].socketName)
        expect_equal("mid", dl[2].socketName)
        expect_equal("fg",  dl[3].socketName)
    end)

    -- @description Verifies case: computes world position at doll origin.
    it("computes world position at doll origin", function()
        local t = doll.newTemplate("simple")
        t:addSocket("s", "", 10, 20, 0, 0)
        local d = doll.newDoll(t)
        d:setPosition(100, 200)

        local part = doll.newPart()
        d:attach("s", part)

        local dl = d:getDrawList()
        expect_near(110, dl[1].x, 0.01, "x = doll.x + socket.x")
        expect_near(220, dl[1].y, 0.01, "y = doll.y + socket.y")
    end)

    -- @description Verifies case: applies doll rotation to socket positions.
    it("applies doll rotation to socket positions", function()
        local t = doll.newTemplate("rot")
        t:addSocket("right", "", 10, 0, 0, 0)  -- 10 px to the right
        local d = doll.newDoll(t)
        d:setPosition(0, 0)
        d:setRotation(math.pi / 2)  -- 90 degrees CCW

        local part = doll.newPart()
        d:attach("right", part)

        local dl = d:getDrawList()
        -- After 90 degree rotation, (10, 0) should become approximately (0, 10)
        expect_near(0,  dl[1].x, 0.01, "rotated x")
        expect_near(10, dl[1].y, 0.01, "rotated y")
    end)

    -- @description Verifies case: applies doll scale.
    it("applies doll scale", function()
        local t = doll.newTemplate("scaled")
        t:addSocket("s", "", 10, 20, 0, 0)
        local d = doll.newDoll(t)
        d:setPosition(0, 0)
        d:setScale(2)

        local part = doll.newPart()
        d:attach("s", part)

        local dl = d:getDrawList()
        expect_near(20, dl[1].x, 0.01)
        expect_near(40, dl[1].y, 0.01)
        expect_near(2, dl[1].scaleX, 0.01)
        expect_near(2, dl[1].scaleY, 0.01)
    end)

    -- @description Verifies case: part.followsRotation=false excludes doll rotation.
    it("part.followsRotation=false excludes doll rotation", function()
        local t = doll.newTemplate("nofr")
        t:addSocket("s", "", 0, 0, 0.5, 0)
        local d = doll.newDoll(t)
        d:setRotation(1.0)

        local part = doll.newPart()
        part:setFollowsRotation(false)
        d:attach("s", part)

        local dl = d:getDrawList()
        -- worldRot = socket.rotation + part.rotation = 0.5 + 0 = 0.5 (NOT + doll rotation)
        expect_near(0.5, dl[1].rotation, 0.001)
    end)

    -- @description Verifies case: part.followsRotation=true includes doll rotation.
    it("part.followsRotation=true includes doll rotation", function()
        local t = doll.newTemplate("fr")
        t:addSocket("s", "", 0, 0, 0.5, 0)
        local d = doll.newDoll(t)
        d:setRotation(1.0)

        local part = doll.newPart()
        part:setFollowsRotation(true)
        d:attach("s", part)

        local dl = d:getDrawList()
        -- worldRot = doll.rotation + socket.rotation + part.rotation = 1.0 + 0.5 + 0 = 1.5
        expect_near(1.5, dl[1].rotation, 0.001)
    end)

    -- @description Verifies case: flip negates scale in draw list.
    it("flip negates scale in draw list", function()
        local t = doll.newTemplate("flip")
        t:addSocket("s", "", 0, 0, 0, 0)
        local d = doll.newDoll(t)

        local part = doll.newPart()
        part:setFlip(true, false)
        d:attach("s", part)

        local dl = d:getDrawList()
        expect_near(-1, dl[1].scaleX, 0.01, "flipX negates scaleX")
        expect_near(1,  dl[1].scaleY, 0.01, "no flipY")
    end)

    -- @description Verifies case: part drawOrder adds to socket drawOrder.
    it("part drawOrder adds to socket drawOrder", function()
        local t = doll.newTemplate("order")
        t:addSocket("s1", "", 0, 0, 0, 10)
        t:addSocket("s2", "", 0, 0, 0, 5)
        local d = doll.newDoll(t)

        local p1 = doll.newPart()
        p1:setDrawOrder(-8)  -- combined = 10 + (-8) = 2
        local p2 = doll.newPart()
        p2:setDrawOrder(0)   -- combined = 5 + 0 = 5

        d:attach("s1", p1)
        d:attach("s2", p2)

        local dl = d:getDrawList()
        expect_equal("s1", dl[1].socketName, "s1 drawOrder 2 comes first")
        expect_equal("s2", dl[2].socketName, "s2 drawOrder 5 comes second")
    end)

    -- @description Verifies case: includes part offset in world position.
    it("includes part offset in world position", function()
        local t = doll.newTemplate("offset")
        t:addSocket("s", "", 10, 0, 0, 0)
        local d = doll.newDoll(t)
        d:setPosition(100, 100)

        local part = doll.newPart()
        part:setOffset(5, 3)
        d:attach("s", part)

        local dl = d:getDrawList()
        expect_near(115, dl[1].x, 0.01, "100 + 10 + 5")
        expect_near(103, dl[1].y, 0.01, "100 + 0 + 3")
    end)
end)

-- â”€â”€ Hot-swap â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€

-- @covers library.doll.newDoll
-- @description Tests replacing attached parts at runtime so hot-swapping preserves socket routing and updated draw output.
describe("Doll hot-swap", function()
    -- @description Verifies case: replaces part at socket.
    it("replaces part at socket", function()
        local t = doll.newTemplate("swap")
        t:addSocket("weapon", "", 0, 0, 0, 0)
        local d = doll.newDoll(t)

        local sword = doll.newPart()
        sword:setPartType("melee")
        d:attach("weapon", sword)
        expect_equal(sword, d:getPartAt("weapon"))

        local bow = doll.newPart()
        bow:setPartType("ranged")
        d:attach("weapon", bow)
        expect_equal(bow, d:getPartAt("weapon"))
    end)
end)

test_summary()
