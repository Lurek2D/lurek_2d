-- test_crafting_core_unit.lua
--
-- lurek.crafting is NOT a native engine API.
-- The crafting system is a pure-Lua library loaded via require("library.crafting").
-- Full behavioral coverage lives in:
--   tests/lua/library/test_library_crafting.lua
--
-- This file only verifies that the engine namespace does NOT accidentally
-- expose a lurek.crafting table, and that the library can be required and
-- its core factories return the expected types.

local C = require("library.crafting")

-- @describe lurek.crafting engine namespace
describe("lurek.crafting engine namespace", function()
    -- @covers lurek
    it("lurek.crafting is nil - not a native engine module", function()
        expect_nil(lurek.crafting)
    end)
end)

-- @describe library.crafting basic sanity
describe("library.crafting basic sanity", function()
    -- @covers C.newRecipe
    it("newRecipe returns an object with the expected fields", function()
        local r = C.newRecipe("test_sword")
        expect_not_nil(r)
        expect_equal("test_sword", r.id)
        expect_equal("", r.category)
        expect_equal(true, r.hand_craftable)
        expect_equal(0, r.cooldown)
    end)

    -- @covers C.newIngredient
    it("newIngredient returns an object with item_type and quantity", function()
        local ing = C.newIngredient("iron_ingot", 3)
        expect_not_nil(ing)
        expect_equal("iron_ingot", ing.item_type)
        expect_equal(3, ing.quantity)
    end)

    -- @covers C.newIngredient
    -- @covers C.newRecipe
    it("recipe accumulates ingredients", function()
        local r = C.newRecipe("plank")
        r:addIngredient(C.newIngredient("log", 1))
        r:addIngredient(C.newIngredient("log", 1))
        expect_equal(2, #r.ingredients)
        r:clearIngredients()
        expect_equal(0, #r.ingredients)
    end)

    -- @covers C.newRecipeOutput
    -- @covers C.newRecipe
    it("recipe accumulates outputs", function()
        local r = C.newRecipe("planks")
        r:addOutput(C.newRecipeOutput("plank", 4))
        expect_equal(1, #r.outputs)
        r:clearOutputs()
        expect_equal(0, #r.outputs)
    end)

    -- @covers C.newRecipe
    -- @covers Recipe:getTags
    -- @covers Recipe:hasTag
    it("recipe tags table works with hasTag/getTags", function()
        local r = C.newRecipe("arrow")
        local tags = r:getTags()
        tags[#tags + 1] = "ammo"
        tags[#tags + 1] = "wood"
        expect_equal(true, r:hasTag("ammo"))
        expect_equal(false, r:hasTag("metal"))
        expect_equal(2, #tags)
    end)

    -- @covers C.newRecipeRegistry
    it("newRecipeRegistry add / get / remove / count", function()
        local reg = C.newRecipeRegistry()
        local r = C.newRecipe("sword")
        reg:add(r)
        expect_equal(1, reg:count())
        expect_not_nil(reg:get("sword"))
        expect_equal(true, reg:remove("sword"))
        expect_equal(nil, reg:get("sword"))
        expect_equal(0, reg:count())
    end)

    -- @covers C.newRecipeRegistry
    it("registry findByIngredient returns matching recipes", function()
        local reg = C.newRecipeRegistry()
        local r = C.newRecipe("iron_sword")
        r:addIngredient(C.newIngredient("iron_ingot", 2))
        reg:add(r)
        local found = reg:findByIngredient("iron_ingot")
        expect_equal(1, #found)
        expect_equal("iron_sword", found[1].id)
    end)

    -- @covers C.newCraftSkill
    it("newCraftSkill getLevel and addXP", function()
        local s = C.newCraftSkill("smithing")
        expect_equal("smithing", s.name)
        expect_equal(1, s:getLevel())
        s:addXP(100)
        expect_equal(2, s:getLevel())
    end)

    -- @covers C.newModifierEntry
    -- @covers C.newModifierPool
    it("newModifierPool add and roll", function()
        local pool = C.newModifierPool()
        pool:add(C.newModifierEntry("keen", 1.0))
        pool:add(C.newModifierEntry("heavy", 1.0))
        local entry = pool:roll()
        expect_not_nil(entry)
        if entry ~= nil then
            expect_type("string", entry.name)
        end
    end)
end)

test_summary()
