-- test.lua
--
-- Testuje wymagane interfejsy dla modułu procesowania mapy prowincji.
-- Uruchamiany automatycznie w ramach globalnego testu gier (`games_load_test`).
--
-- Sprawdzane interfejsy:
--   - lurek.image.newProvinceGrid
--   - lurek.image.newImageData
--   - lurek.serial.fromToml
--   - lurek.filesystem.read

describe("eu2 demo", function()

    --- check that all required APIs exist
    it("required APIs exist", function()
        assert(type(lurek.image.newProvinceGrid) == "function",
            "lurek.image.newProvinceGrid must exist")
        assert(type(lurek.image.newImageData) == "function",
            "lurek.image.newImageData must exist")
        assert(type(lurek.serial.fromToml) == "function",
            "lurek.serial.fromToml must exist")
        assert(type(lurek.filesystem.read) == "function",
            "lurek.filesystem.read must exist")
    end)
end)
