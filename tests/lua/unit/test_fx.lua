-- tests/lua/unit/test_fx.lua
-- BDD tests for lurek.fx post-processing and image-effect API

describe("fx module API surface", function()
  it("getEffectTypes returns a table", function()
    local types = lurek.fx.getEffectTypes()
    expect_equal(type(types), "table")
  end)

  it("getEffectTypes contains at least one entry", function()
    local types = lurek.fx.getEffectTypes()
    local count = 0
    for _ in pairs(types) do count = count + 1 end
    expect_equal(count > 0, true)
  end)
end)

describe("fx postfx stack", function()
  it("newStack creates a stack object", function()
    local stack = lurek.fx.newStack()
    expect_equal(type(stack), "userdata")
  end)

  it("stack:count returns zero for empty stack", function()
    local stack = lurek.fx.newStack()
    expect_equal(stack:count(), 0)
  end)

  it("newPass returns an effect userdata", function()
    local eff = lurek.fx.newPass("pixelate", { size = 4 })
    expect_equal(type(eff), "userdata")
  end)

  it("stack:add and count increment", function()
    local stack = lurek.fx.newStack()
    local eff = lurek.fx.newPass("pixelate", { size = 2 })
    stack:add(eff)
    expect_equal(stack:count(), 1)
  end)

  it("stack:remove decrements count", function()
    local stack = lurek.fx.newStack()
    local eff = lurek.fx.newPass("pixelate", { size = 2 })
    stack:add(eff)
    stack:remove(eff)
    expect_equal(stack:count(), 0)
  end)
end)

test_summary()
