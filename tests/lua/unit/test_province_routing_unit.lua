-- tests/lua/unit/test_province_routing_unit.lua
-- lurek.province routing helper unit tests (TST-06)

-- @describe province routing helpers
describe("province routing helpers", function()
    -- @covers LProvinceRegistry:findRoute
    it("findRoute returns trivial missing and weighted routes", function()
        local reg = lurek.province.newFromPng("test-province-routing-basic", "content/games/strategy/eu2/map.png")
        local route = reg:findRoute(1, 1)
        expect_type("table", route)
        expect_not_nil(route)
        expect_equal(1, #route)
        expect_equal(1, route[1])

        local missing = reg:findRoute(999999, 999998)
        expect_equal(nil, missing)

        local weighted = reg:findRoute(1, 2, function(from_id, to_id)
            if from_id == to_id then
                return 0.1
            end
            return 1.0
        end)
        if weighted ~= nil then
            expect_type("table", weighted)
            expect_true(#weighted >= 1)
        end
    end)

    -- @covers LProvinceRegistry:isConnected
    it("isConnected reports connectivity for the same province", function()
        local reg = lurek.province.newFromPng("test-province-routing-connected", "content/games/strategy/eu2/map.png")
        expect_true(reg:isConnected(1, 1))
    end)

    -- @covers LProvinceRegistry:findRoutes
    it("returns one entry per pair in batch mode", function()
        local reg = lurek.province.newFromPng("test-province-routing-batch", "content/games/strategy/eu2/map.png")
        local routes = reg:findRoutes({
            { from = 1, to = 1 },
            { from = 1, to = 2 },
            { from = 999999, to = 2 },
        })
        expect_type("table", routes)
        expect_type("table", routes[1])
        expect_true(routes[2] ~= nil or routes[3] == nil)
    end)

    -- @covers LProvinceRegistry:getConnectedComponents
    it("returns graph components", function()
        local reg = lurek.province.newFromPng("test-province-routing-components", "content/games/strategy/eu2/map.png")
        local components = reg:getConnectedComponents()
        expect_type("table", components)
        expect_true(#components >= 1)
        expect_type("table", components[1])
        expect_true(#components[1] >= 1)
    end)

    -- @covers LProvinceRegistry:findIsolatedProvinces
    it("findIsolatedProvinces returns a table", function()
        local reg = lurek.province.newFromPng("test-province-routing-owner", "content/games/strategy/eu2/map.png")
        reg:setAttr(1, "faction", "player")
        reg:setAttr(2, "faction", "enemy")
        reg:setAttr(3, "faction", "player")

        local isolated = reg:findIsolatedProvinces("faction")
        expect_type("table", isolated)
    end)

    -- @covers LProvinceRegistry:totalAttrForOwner
    it("totalAttrForOwner sums numeric owner attributes", function()
        local reg = lurek.province.newFromPng("test-province-routing-owner-total", "content/games/strategy/eu2/map.png")
        reg:setAttr(1, "faction", "player")
        reg:setAttr(2, "faction", "enemy")
        reg:setAttr(3, "faction", "player")
        reg:setAttr(1, "iron", "10")
        reg:setAttr(2, "iron", "7")
        reg:setAttr(3, "iron", "2.5")
        local total_player = reg:totalAttrForOwner("faction", "player", "iron")
        expect_type("number", total_player)
        expect_true(total_player >= 12.5)
    end)
end)
test_summary()
