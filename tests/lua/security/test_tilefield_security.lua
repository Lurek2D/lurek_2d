-- Adversarial coverage for bounded tilefield construction, import, and restore.

local function new_field(opts)
    return lurek.tilefield.new(opts)
end

-- @describe tilefield hostile inputs
describe("tilefield hostile inputs", function()
    -- @security lurek.tilefield.new
    it("rejects oversized dense fields before allocation", function()
        expect_error(function()
            lurek.tilefield.new({
                width = 3,
                height = 2,
                limits = { maxCells = 4 },
            })
        end)
    end)

    -- @security lurek.tilefield.newFieldMap
    it("rejects aggregate field-map products", function()
        expect_error(function()
            lurek.tilefield.newFieldMap({
                width = 2,
                height = 2,
                fieldWidth = 2,
                fieldHeight = 2,
                limits = { maxFields = 2 },
            })
        end)
    end)

    -- @security lurek.tilefield.fromProvider
    it("rejects provider rows above the configured ceiling", function()
        expect_error(function()
            lurek.tilefield.fromProvider({
                width = 4,
                height = 4,
                limits = { maxProviderRows = 8 },
                getCell = function()
                    return { costs = { move = 1 } }
                end,
            })
        end)
    end)

    -- @security LTileField:setCost
    it("rejects non-finite costs", function()
        local field = new_field({ width = 2, height = 2 })
        expect_error(function()
            field:setCost(1, 1, 1, "move", 0 / 0)
        end)
    end)

    -- @security LTileField:setCategoryFilter
    it("rejects non-finite category filters", function()
        local field = new_field({ width = 2, height = 2 })
        expect_error(function()
            field:setCategoryFilter(1, 1, 1, "light", { 1, 0 / 0, 1 })
        end)
    end)

    -- @security LTileField:setModifier
    it("rejects non-finite modifier values", function()
        local field = new_field({ width = 2, height = 2 })
        expect_error(function()
            field:setModifier("bad", { costMul = { move = 0 / 0 } })
        end)
    end)

    -- @security LTileField:setProfile
    it("rejects non-finite authored emitter metadata", function()
        local field = new_field({ width = 2, height = 2 })
        expect_error(function()
            field:setProfile("nan_light", {
                light = { radius = 0 / 0, intensity = 1, color = { 1, 1, 1 } },
            })
        end)
    end)

    -- @security LTileField:restore
    it("restores transactionally when a snapshot layer is malformed", function()
        local field = new_field({ width = 2, height = 2 })
        field:setBlock(1, 1, 1, "move", true)
        local before = field:snapshot()
        before.width = 0
        expect_error(function()
            field:restore(before)
        end)
        expect_true(field:blocks(1, 1, 1, "move"))
    end)

    -- @security LTileField:setResource
    it("rejects oversized resource labels", function()
        local field = new_field({ width = 2, height = 2, limits = { maxStringLength = 8 } })
        expect_error(function()
            field:setResource(1, 1, 1, string.rep("x", 9))
        end)
    end)

    -- @security LTileField:getDirtyRects
    it("keeps dirty output bounded under repeated hostile edits", function()
        local field = new_field({
            width = 4,
            height = 4,
            limits = { maxDirtyRects = 1 },
        })
        field:setBlock(1, 1, 1, "move", true)
        field:setBlock(4, 4, 1, "move", true)
        expect_true(#field:getDirtyRects() <= 1)
    end)
end)

test_summary()
