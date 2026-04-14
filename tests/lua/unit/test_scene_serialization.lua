-- Lurek2D Lua BDD tests for lurek.scene serializeScene/deserializeScene
-- Headless: no GPU, no audio, no window.

-- @description Covers suite: lurek.scene.serializeScene and deserializeScene.
describe("lurek.scene", function()
    -- @description Covers suite: scene data serialization.
    describe("serializeScene and deserializeScene", function()
        -- @covers lurek.scene.setData
        -- @covers lurek.scene.getData
        -- @covers lurek.scene.serializeScene
        -- @description Verifies that serializeScene captures setData values.
        it("serializeScene captures setData values", function()
            lurek.scene.setData("level", 3)
            lurek.scene.setData("score", 9999)
            local snap = lurek.scene.serializeScene()
            expect_equal("table", type(snap))
            expect_equal("table", type(snap.data))
            expect_equal(3, snap.data.level)
            expect_equal(9999, snap.data.score)
            -- Cleanup
            lurek.scene.clearData()
        end)

        -- @covers lurek.scene.deserializeScene
        -- @description Verifies that deserializeScene restores setData values.
        it("deserializeScene restores setData values", function()
            local snap = { data = { gold = 150, hp = 80 }, stack = {} }
            lurek.scene.clearData()
            lurek.scene.deserializeScene(snap)
            expect_equal(150, lurek.scene.getData("gold"))
            expect_equal(80, lurek.scene.getData("hp"))
            lurek.scene.clearData()
        end)

        -- @covers lurek.scene.serializeScene
        -- @description Verifies that serializeScene with no data returns empty data table.
        it("serializeScene with no data returns empty data table", function()
            lurek.scene.clearData()
            local snap = lurek.scene.serializeScene()
            local count = 0
            for _ in pairs(snap.data) do count = count + 1 end
            expect_equal(0, count)
        end)

        -- @covers lurek.scene.deserializeScene
        -- @description Verifies that deserializeScene with empty data does not error.
        it("deserializeScene with empty snapshot does not error", function()
            local ok, err = pcall(function()
                lurek.scene.deserializeScene({ data = {}, stack = {} })
            end)
            expect_equal(true, ok)
        end)
    end)
end)
test_summary()
