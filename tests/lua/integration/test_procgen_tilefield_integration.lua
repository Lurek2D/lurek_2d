-- Integration: procgen output can be converted into tilefield profiles.

-- @describe integration: procgen feeds tilefield
describe("integration: procgen feeds tilefield", function()
    -- @integration lurek.procgen.cellularAutomata
    -- @integration lurek.tilefield.new
    -- @integration LTileField:applyProfile
    -- @integration LTileField:blocks
    -- @integration LTileField:exportBlockLayer
    -- @integration lurek.pathfind.newNavGridFromField
    -- @integration LNavGrid:isBlocked
    it("cellular cave cells become tilefield wall and empty profiles", function()
        local width, height = 12, 10
        local cave = lurek.procgen.cellularAutomata(width, height, {
            fill = 0.47,
            iterations = 2,
            seed = 91,
        })
        local field = lurek.tilefield.new({ width = width, height = height })

        local blocked_count = 0
        for y = 1, height do
            for x = 1, width do
                local i = (y - 1) * width + x
                if cave[i] == 1 then
                    field:applyProfile(x, y, 1, "wall")
                    blocked_count = blocked_count + 1
                else
                    field:applyProfile(x, y, 1, "empty")
                end
            end
        end

        local layer = field:exportBlockLayer("move", 1)
        local counted = 0
        for _, blocked in ipairs(layer) do
            if blocked then counted = counted + 1 end
        end

        local nav = lurek.pathfind.newNavGridFromField(field, { level = 1 })
        expect_true(blocked_count > 0, "deterministic cave should contain some walls")
        expect_equal(blocked_count, counted)
        expect_equal(field:blocks(1, 1, 1, "move"), nav:isBlocked(1, 1))
    end)
end)

test_summary()
