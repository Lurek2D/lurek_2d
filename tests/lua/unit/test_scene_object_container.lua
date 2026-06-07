-- Test file: tests/lua/unit/test_scene_object_container.lua
-- Tests for lurek.scene.newObjectContainer (scene object container for object lifecycle and rendering)

-- @describe lurek.scene.newObjectContainer
describe("lurek.scene.newObjectContainer", function()
    -- @covers lurek.scene.newObjectContainer
    it("creates an object container", function()
        local container = lurek.scene.newObjectContainer()
        assert(container ~= nil, "newObjectContainer should return a container")
        assert(container:type() == "LSceneObjectContainer", "container should have correct type")
    end)

    -- @covers lurek.scene.newObjectContainer
    it("reports zero objects after creation", function()
        local container = lurek.scene.newObjectContainer()
        assert(container:getCount() == 0, "new container should have zero objects")
    end)

    -- @covers lurek.scene.newObjectContainer:add
    it("adds an object to the container", function()
        local container = lurek.scene.newObjectContainer()
        local obj = { layer = 1, x = 0, y = 0 }
        container:add(obj)
        assert(container:getCount() == 1, "container should have one object after add")
    end)

    -- @covers lurek.scene.newObjectContainer:add
    it("adds multiple objects", function()
        local container = lurek.scene.newObjectContainer()
        local obj1 = { layer = 1 }
        local obj2 = { layer = 2 }
        local obj3 = { layer = 0 }
        container:add(obj1)
        container:add(obj2)
        container:add(obj3)
        assert(container:getCount() == 3, "container should have three objects")
    end)

    -- @covers lurek.scene.newObjectContainer:remove
    it("removes an object from the container", function()
        local container = lurek.scene.newObjectContainer()
        local obj = { layer = 1 }
        container:add(obj)
        assert(container:getCount() == 1, "should have one object after add")
        container:remove(obj)
        assert(container:getCount() == 0, "should have zero objects after remove")
    end)

    -- @covers lurek.scene.newObjectContainer:remove
    it("silently ignores remove of non-present object", function()
        local container = lurek.scene.newObjectContainer()
        local obj1 = { layer = 1 }
        local obj2 = { layer = 2 }
        container:add(obj1)
        container:remove(obj2)  -- obj2 was never added
        assert(container:getCount() == 1, "removing non-present object should not affect others")
    end)

    -- @covers lurek.scene.newObjectContainer:clear
    it("removes all objects", function()
        local container = lurek.scene.newObjectContainer()
        container:add({ layer = 1 })
        container:add({ layer = 2 })
        container:add({ layer = 3 })
        assert(container:getCount() == 3, "container should have three objects")
        container:clear()
        assert(container:getCount() == 0, "container should be empty after clear")
    end)

    -- @covers lurek.scene.newObjectContainer:update
    it("calls update on objects with update method", function()
        local container = lurek.scene.newObjectContainer()
        local update_called = false
        local obj = {
            layer = 1,
            update = function(self, dt)
                update_called = true
            end
        }
        container:add(obj)
        container:update(0.016)
        assert(update_called == true, "update method should be called on objects")
    end)

    -- @covers lurek.scene.newObjectContainer:update
    it("passes dt parameter to update method", function()
        local container = lurek.scene.newObjectContainer()
        local dt_value = nil
        local obj = {
            layer = 1,
            update = function(self, dt)
                dt_value = dt
            end
        }
        container:add(obj)
        container:update(0.033)
        assert(dt_value == 0.033, "update should receive correct dt value")
    end)

    -- @covers lurek.scene.newObjectContainer:update
    it("ignores objects without update method", function()
        local container = lurek.scene.newObjectContainer()
        local obj = { layer = 1, x = 5 }  -- no update method
        container:add(obj)
        container:update(0.016)
        -- If no error, ignoring objects without update works
        assert(true, "should not error on objects without update")
    end)

    -- @covers lurek.scene.newObjectContainer:draw
    it("calls draw on objects with draw method", function()
        local container = lurek.scene.newObjectContainer()
        local draw_called = false
        local obj = {
            layer = 1,
            draw = function(self)
                draw_called = true
            end
        }
        container:add(obj)
        container:draw()
        assert(draw_called == true, "draw method should be called on objects")
    end)

    -- @covers lurek.scene.newObjectContainer:draw
    it("ignores objects without draw method", function()
        local container = lurek.scene.newObjectContainer()
        local obj = { layer = 1 }  -- no draw method
        container:add(obj)
        container:draw()
        -- If no error, ignoring objects without draw works
        assert(true, "should not error on objects without draw")
    end)

    -- @covers lurek.scene.newObjectContainer:draw
    it("draws objects in layer order (ascending)", function()
        local container = lurek.scene.newObjectContainer()
        local draw_order = {}

        -- Add objects in mixed order
        container:add({
            layer = 2,
            draw = function(self)
                table.insert(draw_order, 2)
            end
        })
        container:add({
            layer = 0,
            draw = function(self)
                table.insert(draw_order, 0)
            end
        })
        container:add({
            layer = 1,
            draw = function(self)
                table.insert(draw_order, 1)
            end
        })

        container:draw()

        -- Should be drawn in ascending layer order
        assert(draw_order[1] == 0, "layer 0 should be drawn first")
        assert(draw_order[2] == 1, "layer 1 should be drawn second")
        assert(draw_order[3] == 2, "layer 2 should be drawn third")
    end)

    -- @covers lurek.scene.newObjectContainer:draw
    it("draws same-layer objects in insertion order", function()
        local container = lurek.scene.newObjectContainer()
        local draw_order = {}

        -- Add multiple objects with same layer
        container:add({
            layer = 1,
            id = "first",
            draw = function(self)
                table.insert(draw_order, "first")
            end
        })
        container:add({
            layer = 1,
            id = "second",
            draw = function(self)
                table.insert(draw_order, "second")
            end
        })
        container:add({
            layer = 1,
            id = "third",
            draw = function(self)
                table.insert(draw_order, "third")
            end
        })

        container:draw()

        -- Should maintain insertion order for same layer
        assert(draw_order[1] == "first", "first object should be drawn first")
        assert(draw_order[2] == "second", "second object should be drawn second")
        assert(draw_order[3] == "third", "third object should be drawn third")
    end)

    -- @covers lurek.scene.newObjectContainer:getCount
    it("reports correct object count", function()
        local container = lurek.scene.newObjectContainer()
        assert(container:getCount() == 0, "initial count is 0")

        container:add({})
        assert(container:getCount() == 1, "count is 1 after one add")

        container:add({})
        assert(container:getCount() == 2, "count is 2 after two adds")

        container:clear()
        assert(container:getCount() == 0, "count is 0 after clear")
    end)

    -- @covers lurek.scene.newObjectContainer:getObjects
    it("returns objects table", function()
        local container = lurek.scene.newObjectContainer()
        local obj1 = { id = 1 }
        local obj2 = { id = 2 }
        container:add(obj1)
        container:add(obj2)

        local objects = container:getObjects()
        assert(type(objects) == "table", "getObjects should return a table")
    end)

    -- @covers lurek.scene.newObjectContainer:has
    it("has returns true only for added objects", function()
        local container = lurek.scene.newObjectContainer()
        local added = { id = "added" }
        local missing = { id = "missing" }
        container:add(added)

        assert(container:has(added) == true, "has should be true for added object")
        assert(container:has(missing) == false, "has should be false for missing object")
    end)

    -- @covers lurek.scene.newObjectContainer:getByLayer
    it("getByLayer returns only objects from the requested layer", function()
        local container = lurek.scene.newObjectContainer()
        local a = { id = "a", layer = 2 }
        local b = { id = "b", layer = 2 }
        local c = { id = "c", layer = 1 }
        container:add(a)
        container:add(b)
        container:add(c)

        local layer2 = container:getByLayer(2)
        assert(type(layer2) == "table", "getByLayer should return table")
        assert(#layer2 == 2, "layer 2 should have two objects")
        assert(layer2[1] == a and layer2[2] == b, "layer list should preserve insertion order")
    end)

    -- @covers lurek.scene.newObjectContainer:type
    it("reports correct type name", function()
        local container = lurek.scene.newObjectContainer()
        assert(container:type() == "LSceneObjectContainer", "type() should return LSceneObjectContainer")
    end)

    -- @covers lurek.scene.newObjectContainer:typeOf
    it("checks type by name via typeOf", function()
        local container = lurek.scene.newObjectContainer()
        assert(container:typeOf("LSceneObjectContainer") == true, "typeOf should recognize LSceneObjectContainer")
        assert(container:typeOf("other") == false, "typeOf should reject other types")
    end)

    -- @covers lurek.scene.newObjectContainer
    it("uses layer 0 as default for objects without layer", function()
        local container = lurek.scene.newObjectContainer()
        local draw_order = {}

        -- Add object without layer (defaults to 0) and object with explicit layer 1
        container:add({
            draw = function(self)
                table.insert(draw_order, "default")
            end
        })
        container:add({
            layer = 1,
            draw = function(self)
                table.insert(draw_order, "explicit")
            end
        })

        container:draw()

        assert(draw_order[1] == "default", "default layer 0 should be drawn first")
        assert(draw_order[2] == "explicit", "explicit layer 1 should be drawn second")
    end)
end)

test_summary()
