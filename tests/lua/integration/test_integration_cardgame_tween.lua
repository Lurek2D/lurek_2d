-- Integration test: library.cardgame × lurek.tween.
--
-- Scope: Animates a cardgame Card's `tile_x` / `tile_y` position via
-- `lurek.tween.tween`, verifies a callback fires on tween completion,
-- composes two tweens with `lurek.tween.sequence`, and probes the
-- "in-out-quad" easing midpoint with `expect_near`.
--
-- Fallback: none. `lurek.tween` is gated by `modules.tween` (default true)
-- and the runtime namespace matches the user-requested name. Cards expose
-- mutable `tile_x` / `tile_y` fields that tween can drive directly.
--
-- @covers library.cardgame.defineCardType
-- @covers library.cardgame.newCard
-- @covers Card.setTilePosition
-- @covers Card.getTilePosition
-- @covers lurek.tween.tween
-- @covers lurek.tween.sequence
-- @covers lurek.tween.update
-- @covers lurek.tween.cancelAll

local cg = require("library.cardgame")

local function fresh_card()
    cg.clearCardTypes()
    cg.resetIdCounter()
    cg.defineCardType("knight", { name = "Knight" })
    return cg.newCard("knight")
end

describe("integration: library.cardgame × lurek.tween", function()

    -- @description A linear tween drives a card's tile_x toward the target across multiple update ticks.
    it("tween updates card tile_x toward target over multiple updates", function()
        lurek.tween.cancelAll()
        local card = fresh_card()
        card:setTilePosition(0, 0)

        lurek.tween.tween(2.0, card, { tile_x = 10 }, "linear")
        lurek.tween.update(0.5)
        local x_quarter = card.tile_x
        lurek.tween.update(0.5)
        local x_half = card.tile_x
        lurek.tween.update(1.0)

        expect_near(2.5,  x_quarter, 0.5)
        expect_near(5.0,  x_half,    0.5)
        expect_near(10.0, card.tile_x, 1e-5)
    end)

    -- @description A finished tween invokes a cardgame-side callback exactly once.
    it("finished tween triggers a cardgame onComplete callback once", function()
        lurek.tween.cancelAll()
        local card = fresh_card()
        card:setTilePosition(0, 0)

        local fired = 0
        lurek.tween.tween(1.0, card, { tile_x = 5 }, "linear", function()
            fired = fired + 1
            card:addTag("arrived")
        end)
        lurek.tween.update(1.5)

        expect_equal(1, fired)
        expect_true(card:hasTag("arrived"))
        expect_near(5.0, card.tile_x, 1e-5)
    end)

    -- @description Two chained tweens move a card to A then to B in sequence.
    it("sequence chains two card movement tweens", function()
        lurek.tween.cancelAll()
        local card = fresh_card()
        card:setTilePosition(0, 0)

        local seq_tween = lurek.tween.sequence(
            lurek.tween.tween(1.0, card, { tile_x = 4 }, "linear"),
            lurek.tween.tween(1.0, card, { tile_x = 10 }, "linear")
        )
        expect_not_nil(seq_tween)

        lurek.tween.update(1.0)
        expect_near(4.0, card.tile_x, 0.5)
        lurek.tween.update(1.0)
        expect_near(10.0, card.tile_x, 0.5)
    end)

    -- @description The "inOutQuad" easing produces ~0.5 at t=0.5 of its duration.
    it("inOutQuad easing reaches midpoint value at half duration", function()
        lurek.tween.cancelAll()
        local card = fresh_card()
        card:setTilePosition(0, 0)

        lurek.tween.tween(2.0, card, { tile_x = 1.0 }, "inOutQuad")
        lurek.tween.update(1.0)
        expect_near(0.5, card.tile_x, 1e-5)
    end)

    -- @description Tweening tile_x and tile_y in a single tween updates both axes together.
    it("tween animates tile_x and tile_y simultaneously", function()
        lurek.tween.cancelAll()
        local card = fresh_card()
        card:setTilePosition(0, 0)

        lurek.tween.tween(1.0, card, { tile_x = 3, tile_y = 6 }, "linear")
        lurek.tween.update(1.0)
        local x, y = card:getTilePosition()
        expect_near(3.0, x, 1e-5)
        expect_near(6.0, y, 1e-5)
    end)

    -- @description Failure path: tween() rejects a non-numeric duration with an error.
    it("tween rejects a non-numeric duration", function()
        lurek.tween.cancelAll()
        local card = fresh_card()
        expect_error(function()
            lurek.tween.tween("oops", card, { tile_x = 1 })
        end)
    end)

end)

test_summary()
