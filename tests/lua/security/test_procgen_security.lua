-- Security coverage for bounded neutral procgen algorithms.

local INF = 1 / 0

-- @describe security: constrained placement and connectivity validation
describe("security: constrained placement and connectivity validation", function()
    -- @security lurek.procgen.placeConstrained
    it("rejects non-finite candidates and invalid attempt bounds", function()
        expect_error(function()
            lurek.procgen.placeConstrained({ { x = INF, y = 0 } }, { count = 1 })
        end)
        expect_error(function()
            lurek.procgen.placeConstrained({ { x = 0, y = 0 } }, { count = 1 }, {
                maxAttempts = 10001,
            })
        end)
        local placements, report = lurek.procgen.placeConstrained(
            { { id = "valid", x = 0, y = 0 } },
            { count = 1 },
            { maxAttempts = 1 }
        )
        expect_equal(1, #placements)
        expect_true(report.complete)
    end)

    -- @security lurek.procgen.validateConnectivity
    it("rejects malformed grids and invalid neighbor modes", function()
        expect_error(function()
            lurek.procgen.validateConnectivity({ width = 2, height = 2, cells = { 0 } })
        end)
        expect_error(function()
            lurek.procgen.validateConnectivity({
                width = 1,
                height = 1,
                cells = { 0 },
            }, { neighbors = 6 })
        end)
        local report = lurek.procgen.validateConnectivity({
            width = 1,
            height = 1,
            cells = { 0 },
        })
        expect_equal(1, #report.components)
    end)
end)

test_summary()
