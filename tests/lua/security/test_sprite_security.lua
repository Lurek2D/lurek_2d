-- Adversarial coverage for sprite indexing, bounded constructors, parsers, and timing.

local function small_sheet() return lurek.sprite.newSheet(32, 16, 16, 16) end
local function reentrant_animator()
    local animator = lurek.sprite.newAnimator({ walk = { row = 1, from = 1, to = 2, fps = 10 } })
    animator:onFrame(function() animator:play("walk", true) end)
    animator:play("walk", true)
    return animator
end

-- @describe sprite hostile inputs
describe("sprite hostile inputs", function()
    -- @security lurek.sprite.newSheet
    it("rejects non-divisible and oversized uniform grids before allocation", function()
        expect_error(function() lurek.sprite.newSheet(65, 32, 32, 32) end)
        expect_error(function() lurek.sprite.newSheet(1000000, 1000000, 1, 1) end)
    end)

    -- @security lurek.sprite.newSprite
    it("rejects stale texture IDs at construction and normal-map assignment", function()
        expect_error(function() lurek.sprite.newSprite(7, 0, 0) end)
        local image = lurek.render.newImage("assets/icon.png")
        local sprite = lurek.sprite.newSprite(image:getId(), 0, 0)
        image:release()
        expect_error(function() sprite:setNormalMap(7) end)
    end)

    -- @security LSpriteSheet:getFrame
    it("rejects zero rather than aliasing the first frame", function()
        local sheet = small_sheet()
        expect_error(function() sheet:getFrame(0) end)
    end)

    -- @security LSpriteSheet:nameGroup
    it("rejects zero and out-of-range group starts", function()
        local sheet = small_sheet()
        expect_error(function() sheet:nameGroup("zero", 0, 1) end)
        expect_error(function() sheet:nameGroup("past", 2, 2) end)
    end)

    -- @security lurek.sprite.parseAtlas
    it("rejects duplicate, zero-sized, and oversized atlas records", function()
        expect_error(function()
            lurek.sprite.parseAtlas('{"frames":[{"filename":"a","frame":{"x":0,"y":0,"w":1,"h":1}},{"filename":"a","frame":{"x":1,"y":0,"w":1,"h":1}}]}')
        end)
        expect_error(function()
            lurek.sprite.parseAtlas('{"frames":{"a":{"frame":{"x":0,"y":0,"w":0,"h":1}}}}')
        end)
    end)

    -- @security lurek.sprite.newAnimator
    it("rejects non-finite or excessive clip speeds", function()
        expect_error(function()
            lurek.sprite.newAnimator({ bad = { row = 1, from = 1, to = 2, fps = 0 / 0 } })
        end)
        expect_error(function()
            lurek.sprite.newAnimator({ fast = { row = 1, from = 1, to = 2, fps = 1001 } })
        end)
    end)

    -- @security LSpriteAnimator:update
    it("permits callback playback mutation after event state is snapshotted", function()
        local animator = reentrant_animator()
        animator:update(0.2)
    end)
end)

test_summary()
