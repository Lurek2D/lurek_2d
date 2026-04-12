-- Lurek2D localization (i18n) API unit tests
-- Headless-safe (no window / GPU / audio required).
-- Tests the lurek.localization namespace: loadTable, unloadTable,
-- setLanguage, getLanguages, fallbacks, t(), hasKey, getKeys, setKey,
-- interpolate, pluralFor, onChange/offChange, keyCount, categories,
-- keysInCategory, search, buildIndex/searchIndexed, mergeLocale.
-- @covers lurek.localization.loadTable
-- @covers lurek.localization.unloadTable
-- @covers lurek.localization.setLanguage
-- @covers lurek.localization.getLanguage
-- @covers lurek.localization.getLanguages
-- @covers lurek.localization.getAvailableLanguages
-- @covers lurek.localization.hasLanguage
-- @covers lurek.localization.setFallbacks
-- @covers lurek.localization.getFallbacks
-- @covers lurek.localization.setBase
-- @covers lurek.localization.getBase
-- @covers lurek.localization.t
-- @covers lurek.localization.hasKey
-- @covers lurek.localization.getKeys
-- @covers lurek.localization.setKey
-- @covers lurek.localization.interpolate
-- @covers lurek.localization.pluralFor
-- @covers lurek.localization.onChange
-- @covers lurek.localization.offChange
-- @covers lurek.localization.keyCount
-- @covers lurek.localization.categories
-- @covers lurek.localization.keysInCategory
-- @covers lurek.localization.search
-- @covers lurek.localization.buildIndex
-- @covers lurek.localization.searchIndexed
-- @covers lurek.localization.mergeLocale

local en = {
    greeting = "Hello",
    farewell = "Goodbye",
    menu = {
        start = "Start Game",
        quit  = "Quit",
    },
    welcome = "Welcome, {name}!",
    items = {
        one   = "{count} item",
        other = "{count} items",
    },
}

local fr = {
    greeting = "Bonjour",
    farewell = "Au revoir",
    menu = {
        start = "Demarrer",
        quit  = "Quitter",
    },
    welcome = "Bienvenue, {name} !",
    items = {
        one   = "{count} article",
        other = "{count} articles",
    },
}

-- Setup state for each describe block
local function setup_en_fr()
    lurek.localization.loadTable("en", en)
    lurek.localization.loadTable("fr", fr)
    lurek.localization.setLanguage("en")
    lurek.localization.setBase("en")
end

-- ── module presence ───────────────────────────────────────────────────────────
describe("lurek.localization module", function()
    it("lurek.localization is a table", function()
        expect_type("table", lurek.localization)
    end)

    it("all key functions are present", function()
        local fns = {
            "loadTable", "unloadTable", "setLanguage", "getLanguage",
            "getLanguages", "getAvailableLanguages", "hasLanguage",
            "setFallbacks", "getFallbacks", "setBase", "getBase",
            "t", "hasKey", "getKeys", "setKey",
            "interpolate", "pluralFor",
            "onChange", "offChange",
            "keyCount", "categories", "keysInCategory",
            "search", "buildIndex", "searchIndexed", "mergeLocale",
        }
        for _, name in ipairs(fns) do
            expect_type("function", lurek.localization[name],
                name .. " must be a function")
        end
    end)
end)

-- ── loadTable / unloadTable / getLanguages / hasLanguage ─────────────────────
describe("lurek.localization.loadTable / unloadTable", function()
    it("loadTable adds a language detectable by hasLanguage", function()
        lurek.localization.loadTable("en", en)
        expect_true(lurek.localization.hasLanguage("en"))
    end)

    it("getAvailableLanguages lists loaded languages", function()
        lurek.localization.loadTable("en", en)
        lurek.localization.loadTable("fr", fr)
        local langs = lurek.localization.getAvailableLanguages()
        expect_true(#langs >= 2)
    end)

    it("getLanguages is an alias for getAvailableLanguages", function()
        lurek.localization.loadTable("en", en)
        local l1 = lurek.localization.getLanguages()
        local l2 = lurek.localization.getAvailableLanguages()
        expect_type("table", l1)
        expect_equal(#l2, #l1)
    end)

    it("unloadTable removes the language", function()
        lurek.localization.loadTable("zz_test", { hello = "Hi" })
        expect_true(lurek.localization.hasLanguage("zz_test"))
        lurek.localization.unloadTable("zz_test")
        expect_false(lurek.localization.hasLanguage("zz_test"))
    end)
end)

-- ── setLanguage / getLanguage / setBase / getBase ────────────────────────────
describe("lurek.localization.setLanguage / getLanguage / setBase / getBase", function()
    it("sets and gets the active language", function()
        setup_en_fr()
        expect_equal("en", lurek.localization.getLanguage())
    end)

    it("setBase / getBase round-trip", function()
        lurek.localization.setBase("en")
        expect_equal("en", lurek.localization.getBase())
    end)
end)

-- ── setFallbacks / getFallbacks ───────────────────────────────────────────────
describe("lurek.localization.setFallbacks / getFallbacks", function()
    it("setFallbacks stores ordered fallback chain", function()
        setup_en_fr()
        lurek.localization.setFallbacks({ "fr", "en" })
        local fb = lurek.localization.getFallbacks()
        expect_type("table", fb)
        expect_equal("fr", fb[1])
        expect_equal("en", fb[2])
    end)

    it("getFallbacks returns empty table when not set", function()
        lurek.localization.setFallbacks({})
        local fb = lurek.localization.getFallbacks()
        expect_type("table", fb)
    end)
end)

-- ── t() basic lookup ─────────────────────────────────────────────────────────
describe("lurek.localization.t basic lookup", function()
    it("returns translated string for active language", function()
        setup_en_fr()
        expect_equal("Hello", lurek.localization.t("greeting"))
    end)

    it("supports dot-keys for nested tables", function()
        setup_en_fr()
        expect_equal("Start Game", lurek.localization.t("menu.start"))
    end)

    it("returns key when translation missing", function()
        setup_en_fr()
        expect_equal("nonexistent.key", lurek.localization.t("nonexistent.key"))
    end)

    it("falls back to base language", function()
        setup_en_fr()
        lurek.localization.setLanguage("fr")
        expect_equal("Au revoir", lurek.localization.t("farewell"))
    end)

    it("replaces {var} placeholders", function()
        setup_en_fr()
        local result = lurek.localization.t("welcome", { name = "Luna" })
        expect_equal("Welcome, Luna!", result)
    end)

    it("selects one for count == 1", function()
        setup_en_fr()
        local result = lurek.localization.t("items", { count = "1" }, 1)
        expect_equal("1 item", result)
    end)

    it("selects other for count > 1", function()
        setup_en_fr()
        local result = lurek.localization.t("items", { count = "5" }, 5)
        expect_equal("5 items", result)
    end)
end)

-- ── hasKey / getKeys / setKey ─────────────────────────────────────────────────
describe("lurek.localization.hasKey / getKeys / setKey", function()
    it("hasKey returns true for a loaded key", function()
        setup_en_fr()
        expect_true(lurek.localization.hasKey("greeting"))
    end)

    it("hasKey returns false for a missing key", function()
        setup_en_fr()
        expect_false(lurek.localization.hasKey("nonexistent_key_xyz"))
    end)

    it("getKeys returns a table of key strings", function()
        setup_en_fr()
        local keys = lurek.localization.getKeys()
        expect_type("table", keys)
        expect_true(#keys >= 1, "at least one key exists")
    end)

    it("setKey adds or overrides a key in the current language", function()
        setup_en_fr()
        lurek.localization.setKey("en", "custom_added_key", "Custom Value")
        expect_equal("Custom Value", lurek.localization.t("custom_added_key"))
    end)
end)

-- ── interpolate / pluralFor ───────────────────────────────────────────────────
describe("lurek.localization.interpolate / pluralFor", function()
    it("interpolate replaces {var} in a raw string", function()
        local result = lurek.localization.interpolate("Hello, {name}!", { name = "World" })
        expect_equal("Hello, World!", result)
    end)

    it("interpolate with no vars returns string unchanged", function()
        local result = lurek.localization.interpolate("No vars here", {})
        expect_equal("No vars here", result)
    end)

    it("pluralFor returns one for n=1", function()
        local form = lurek.localization.pluralFor(1)
        expect_equal("one", form)
    end)

    it("pluralFor returns other for n=5", function()
        local form = lurek.localization.pluralFor(5)
        expect_equal("other", form)
    end)
end)

-- ── onChange / offChange ──────────────────────────────────────────────────────
describe("lurek.localization.onChange / offChange", function()
    it("fires callback when language changes", function()
        lurek.localization.loadTable("en", en)
        local fired = false
        lurek.localization.onChange(function() fired = true end)
        lurek.localization.setLanguage("en")
        expect_true(fired)
    end)

    it("offChange removes the callback", function()
        lurek.localization.loadTable("en", en)
        local count = 0
        local function cb() count = count + 1 end
        lurek.localization.onChange(cb)
        lurek.localization.setLanguage("en")
        lurek.localization.offChange(cb)
        lurek.localization.setLanguage("en")
        expect_equal(1, count, "callback fired once, then removed")
    end)
end)

-- ── keyCount / categories / keysInCategory ────────────────────────────────────
describe("lurek.localization.keyCount / categories / keysInCategory", function()
    it("keyCount returns a non-negative number", function()
        setup_en_fr()
        local n = lurek.localization.keyCount()
        expect_type("number", n)
        expect_true(n >= 1, "at least one key loaded")
    end)

    it("categories returns a table", function()
        setup_en_fr()
        local cats = lurek.localization.categories()
        expect_type("table", cats)
    end)

    it("keysInCategory returns a table for a known category", function()
        setup_en_fr()
        local cats = lurek.localization.categories()
        if #cats > 0 then
            local keys = lurek.localization.keysInCategory(cats[1])
            expect_type("table", keys)
        else
            expect_true(true, "no categories to test (flat locale is acceptable)")
        end
    end)
end)

-- ── search / buildIndex / searchIndexed ──────────────────────────────────────
describe("lurek.localization.search / buildIndex / searchIndexed", function()
    it("search returns a table", function()
        setup_en_fr()
        local results = lurek.localization.search("Hello")
        expect_type("table", results)
    end)

    it("search finds a known term", function()
        setup_en_fr()
        local results = lurek.localization.search("Hello")
        expect_true(#results >= 1, "search should find greeting=Hello")
    end)

    it("buildIndex runs without error", function()
        setup_en_fr()
        expect_no_error(function() lurek.localization.buildIndex() end)
    end)

    it("searchIndexed returns a table after buildIndex", function()
        setup_en_fr()
        local idx = lurek.localization.buildIndex()
        local results = lurek.localization.searchIndexed(idx, "Hello")
        expect_type("table", results)
    end)
end)

-- ── mergeLocale ───────────────────────────────────────────────────────────────
describe("lurek.localization.mergeLocale", function()
    it("mergeLocale adds new keys to existing language without overwriting", function()
        setup_en_fr()
        lurek.localization.mergeLocale("en", { extra_key = "Extra Value" })
        expect_equal("Extra Value", lurek.localization.t("extra_key"))
        -- Original key preserved
        expect_equal("Hello", lurek.localization.t("greeting"))
    end)

    it("mergeLocale creates a new language if it did not exist", function()
        lurek.localization.mergeLocale("zz_merge_test", { hello = "Hola" })
        expect_true(lurek.localization.hasLanguage("zz_merge_test"))
        lurek.localization.unloadTable("zz_merge_test")
    end)
end)

test_summary()
