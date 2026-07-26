-- Security coverage for hostile multi-listener inputs.

local NAN = 0 / 0

-- @describe security: audio multi-listener validation
describe("security: audio multi-listener validation", function()
    -- @security lurek.audio.setListeners
    it("rejects duplicate ids and non-finite values atomically", function()
        lurek.audio.setListeners({ { id = "preserved", x = 1, y = 2 } })
        expect_error(function()
            lurek.audio.setListeners({
                { id = "duplicate", x = 0, y = 0 },
                { id = "duplicate", x = 1, y = 1 },
            })
        end)
        expect_error(function()
            lurek.audio.setListeners({ { id = "nan", x = NAN, y = 0 } })
        end)
        local listeners = lurek.audio.getListeners()
        expect_equal(1, #listeners)
        expect_equal("preserved", listeners[1].id)
        lurek.audio.setListener(0, 0, 0)
    end)
end)

test_summary()
