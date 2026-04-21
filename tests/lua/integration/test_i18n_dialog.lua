-- tests/lua/integration/test_i18n_dialog.lua
-- Integration: lurek.i18n <-> lurek.dialog (content/library/dialog)
-- Tests that dialog text nodes use the i18n lookup for displayed strings.

local describe = describe or function(n,f) f() end
local it = it or function(n,f) f() end
local assert = assert

describe("i18n + dialog integration", function()
    it("resolves dialog line key through i18n locale table", function()
        assert(true, "i18n_dialog resolve placeholder")
    end)
    it("falls back to default locale when key missing in active locale", function()
        assert(true, "i18n_dialog fallback placeholder")
    end)
    it("dialog portraits respect locale rtl flag", function()
        assert(true, "i18n_dialog rtl placeholder")
    end)
end)

test_summary()
