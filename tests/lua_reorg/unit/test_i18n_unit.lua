-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_i18n_core_unit.lua
do
-- Lurek2D localization (i18n) API unit tests
-- Headless-safe canonical unit coverage for lurek.i18n.

local en = {
    greeting = "Hello",
    farewell = "Goodbye",
    menu = {
        start = "Start Game",
        quit = "Quit",
    },
    welcome = "Welcome, {name}!",
    items = {
        one = "{count} item",
        other = "{count} items",
    },
}

local fr = {
    greeting = "Bonjour",
    farewell = "Au revoir",
    menu = {
        start = "Demarrer",
        quit = "Quitter",
    },
    welcome = "Bienvenue, {name} !",
    items = {
        one = "{count} article",
        other = "{count} articles",
    },
}

local function setup_en_fr()
    lurek.i18n.loadTable("en", en)
    lurek.i18n.loadTable("fr", fr)
    lurek.i18n.setLanguage("en")
    lurek.i18n.setBase("en")
end

local function clear_loaded_locales()
    local langs = lurek.i18n.getAvailableLanguages()
    for _, locale in ipairs(langs) do
        lurek.i18n.unloadTable(locale)
    end
end

-- @describe lurek.i18n.loadTable / unloadTable
describe("lurek.i18n.loadTable / unloadTable", function()
    -- @covers lurek.i18n.loadTable
    it("loadTable adds a language detectable by hasLanguage", function()
        lurek.i18n.loadTable("en", en)
        expect_true(lurek.i18n.hasLanguage("en"))
    end)

    -- @covers lurek.i18n.hasLanguage
    it("hasLanguage reports whether a locale table is currently loaded", function()
        lurek.i18n.loadTable("en", en)
        expect_true(lurek.i18n.hasLanguage("en"))
        expect_false(lurek.i18n.hasLanguage("zz_missing"))
    end)

    -- @covers lurek.i18n.getAvailableLanguages
    it("getAvailableLanguages lists loaded languages", function()
        lurek.i18n.loadTable("en", en)
        lurek.i18n.loadTable("fr", fr)
        local langs = lurek.i18n.getAvailableLanguages()
        expect_true(#langs >= 2)
    end)

    -- @covers lurek.i18n.getLanguages
    it("getLanguages is an alias for getAvailableLanguages", function()
        lurek.i18n.loadTable("en", en)
        local lhs = lurek.i18n.getLanguages()
        local rhs = lurek.i18n.getAvailableLanguages()
        expect_type("table", lhs)
        expect_equal(#rhs, #lhs)
    end)

    -- @covers lurek.i18n.unloadTable
    it("unloadTable removes the language", function()
        lurek.i18n.loadTable("zz_test", { hello = "Hi" })
        expect_true(lurek.i18n.hasLanguage("zz_test"))
        lurek.i18n.unloadTable("zz_test")
        expect_false(lurek.i18n.hasLanguage("zz_test"))
    end)
end)

-- @describe lurek.i18n.setLanguage / getLanguage / setBase / getBase
describe("lurek.i18n.setLanguage / getLanguage / setBase / getBase", function()
    -- @covers lurek.i18n.getLanguage
    it("getLanguage returns the active language set during setup", function()
        setup_en_fr()
        expect_equal("en", lurek.i18n.getLanguage())
    end)

    -- @covers lurek.i18n.setBase
    it("setBase updates the base locale used by getBase", function()
        lurek.i18n.setBase("en")
        expect_equal("en", lurek.i18n.getBase())
    end)

    -- @covers lurek.i18n.getBase
    it("getBase returns the currently configured base locale", function()
        lurek.i18n.setBase("en")
        expect_equal("en", lurek.i18n.getBase())
    end)
end)

-- @describe lurek.i18n.setFallbacks / getFallbacks
describe("lurek.i18n.setFallbacks / getFallbacks", function()
    -- @covers lurek.i18n.setFallbacks
    it("setFallbacks stores an ordered fallback chain", function()
        setup_en_fr()
        lurek.i18n.setFallbacks({ "fr", "en" })
        local fb = lurek.i18n.getFallbacks()
        expect_type("table", fb)
        expect_equal("fr", fb[1])
        expect_equal("en", fb[2])
    end)

    -- @covers lurek.i18n.getFallbacks
    it("getFallbacks returns a table when fallbacks are empty", function()
        lurek.i18n.setFallbacks({})
        local fb = lurek.i18n.getFallbacks()
        expect_type("table", fb)
    end)
end)

-- @describe lurek.i18n.t basic lookup
describe("lurek.i18n.t basic lookup", function()
    -- @covers lurek.i18n.t
    it("t resolves direct, nested, fallback, interpolated, plural, and missing-key lookups", function()
        setup_en_fr()
        expect_equal("Hello", lurek.i18n.t("greeting"))
        expect_equal("Start Game", lurek.i18n.t("menu.start"))
        expect_equal("nonexistent.key", lurek.i18n.t("nonexistent.key"))

        lurek.i18n.setLanguage("fr")
        expect_equal("Au revoir", lurek.i18n.t("farewell"))

        lurek.i18n.setLanguage("en")
        expect_equal("Welcome, Luna!", lurek.i18n.t("welcome", { name = "Luna" }))
        expect_equal("1 item", lurek.i18n.t("items", { count = "1" }, 1))
        expect_equal("5 items", lurek.i18n.t("items", { count = "5" }, 5))
    end)

    -- @covers lurek.i18n.setLanguage
    it("setLanguage switches the active locale used by t", function()
        setup_en_fr()
        lurek.i18n.setLanguage("en")
        expect_equal("Hello", lurek.i18n.t("greeting"))
        lurek.i18n.setLanguage("fr")
        expect_equal("Bonjour", lurek.i18n.t("greeting"))
    end)
end)

-- @describe lurek.i18n.hasKey / getKeys / setKey
describe("lurek.i18n.hasKey / getKeys / setKey", function()
    -- @covers lurek.i18n.hasKey
    it("hasKey reports present and missing keys", function()
        setup_en_fr()
        expect_true(lurek.i18n.hasKey("greeting"))
        expect_false(lurek.i18n.hasKey("nonexistent_key_xyz"))
    end)

    -- @covers lurek.i18n.getKeys
    it("getKeys returns a table of key strings", function()
        setup_en_fr()
        local keys = lurek.i18n.getKeys()
        expect_type("table", keys)
        expect_true(#keys >= 1, "at least one key exists")
    end)

    -- @covers lurek.i18n.setKey
    it("setKey adds or overrides a key in the selected language", function()
        setup_en_fr()
        lurek.i18n.setKey("en", "custom_added_key", "Custom Value")
        expect_equal("Custom Value", lurek.i18n.t("custom_added_key"))
    end)
end)

-- @describe lurek.i18n.interpolate / pluralFor
describe("lurek.i18n.interpolate / pluralFor", function()
    -- @covers lurek.i18n.interpolate
    it("interpolate replaces tokens, preserves missing values, and supports escaped braces", function()
        expect_equal("Hello, World!", lurek.i18n.interpolate("Hello, {name}!", { name = "World" }))
        expect_equal("1 + 2 = 3", lurek.i18n.interpolate("{a} + {b} = {c}", { a = "1", b = "2", c = "3" }))
        expect_equal("No vars here", lurek.i18n.interpolate("No vars here", {}))
        expect_contains(lurek.i18n.interpolate("Hi {unknown}", {}), "{unknown}")
        expect_contains(lurek.i18n.interpolate("{{literal}}", {}), "literal")
        expect_contains(lurek.i18n.interpolate("Value: {n}", { n = "42" }), "42")
    end)

    -- @covers lurek.i18n.pluralFor
    it("pluralFor returns supported plural categories", function()
        expect_equal("one", lurek.i18n.pluralFor(1))
        expect_equal("other", lurek.i18n.pluralFor(5))
    end)
end)

-- @describe lurek.i18n.onChange / offChange
describe("lurek.i18n.onChange / offChange", function()
    -- @covers lurek.i18n.onChange
    it("onChange fires the callback when the language changes", function()
        lurek.i18n.loadTable("en", en)
        local fired = false
        lurek.i18n.onChange(function()
            fired = true
        end)
        lurek.i18n.setLanguage("en")
        expect_true(fired)
    end)

    -- @covers lurek.i18n.offChange
    it("offChange removes the callback", function()
        lurek.i18n.loadTable("en", en)
        local count = 0
        local function cb()
            count = count + 1
        end

        lurek.i18n.onChange(cb)
        lurek.i18n.setLanguage("en")
        lurek.i18n.offChange()
        lurek.i18n.setLanguage("en")
        expect_equal(1, count, "callback fired once, then was removed")
    end)
end)

-- @describe lurek.i18n.keyCount / categories / keysInCategory
describe("lurek.i18n.keyCount / categories / keysInCategory", function()
    -- @covers lurek.i18n.keyCount
    it("keyCount returns a non-negative number", function()
        setup_en_fr()
        local count = lurek.i18n.keyCount()
        expect_type("number", count)
        expect_true(count >= 1, "at least one key should be loaded")
    end)

    -- @covers lurek.i18n.categories
    it("categories returns a table", function()
        setup_en_fr()
        expect_type("table", lurek.i18n.categories())
    end)

    -- @covers lurek.i18n.keysInCategory
    it("keysInCategory returns a table for a known category", function()
        setup_en_fr()
        local categories = lurek.i18n.categories()
        if #categories > 0 then
            expect_type("table", lurek.i18n.keysInCategory(categories[1]))
        else
            expect_true(true, "flat locales may not expose categories")
        end
    end)
end)

-- @describe lurek.i18n.search / buildIndex / searchIndexed
describe("lurek.i18n.search / buildIndex / searchIndexed", function()
    -- @covers lurek.i18n.search
    it("search returns matching results for known terms", function()
        setup_en_fr()
        local results = lurek.i18n.search("Hello")
        expect_type("table", results)
        expect_true(#results >= 1, "search should find greeting=Hello")
    end)

    -- @covers lurek.i18n.buildIndex
    it("buildIndex runs without error", function()
        setup_en_fr()
        expect_no_error(function()
            lurek.i18n.buildIndex()
        end)
    end)

    -- @covers lurek.i18n.searchIndexed
    it("searchIndexed returns a table after buildIndex", function()
        setup_en_fr()
        local idx = lurek.i18n.buildIndex()
        local results = lurek.i18n.searchIndexed(idx, "Hello")
        expect_type("table", results)
    end)
end)

-- @describe lurek.i18n.mergeLocale
describe("lurek.i18n.mergeLocale", function()
    -- @covers lurek.i18n.mergeLocale
    it("mergeLocale extends existing locales and can create new ones", function()
        setup_en_fr()
        lurek.i18n.mergeLocale("en", { extra_key = "Extra Value" })
        expect_equal("Extra Value", lurek.i18n.t("extra_key"))
        expect_equal("Hello", lurek.i18n.t("greeting"))

        lurek.i18n.mergeLocale("zz_merge_test", { hello = "Hola" })
        expect_true(lurek.i18n.hasLanguage("zz_merge_test"))
        lurek.i18n.unloadTable("zz_merge_test")
    end)
end)

-- @describe lurek.i18n helper coverage
describe("lurek.i18n helper coverage", function()
    -- @covers lurek.i18n.onLanguageChange
    it("onLanguageChange receives new and old locale codes", function()
        setup_en_fr()
        lurek.i18n.offChange()

        local new_locale = nil
        local old_locale = nil
        lurek.i18n.onLanguageChange(function(next_locale, previous_locale)
            new_locale = next_locale
            old_locale = previous_locale
        end)

        lurek.i18n.setLanguage("fr")
        expect_equal("fr", new_locale)
        expect_equal("en", old_locale)
        lurek.i18n.offChange()
    end)

    -- @covers lurek.i18n.formatNumber
    it("formatNumber applies locale separators and decimals", function()
        setup_en_fr()
        lurek.i18n.setLanguage("fr")
        local formatted = lurek.i18n.formatNumber(12345.678, { decimals = 2 })
        expect_equal("12.345,68", formatted)
    end)

    -- @covers lurek.i18n.formatDate
    it("formatDate supports iso and short formats", function()
        setup_en_fr()
        lurek.i18n.setLanguage("en")
        expect_equal("1970-01-01", lurek.i18n.formatDate(0, "iso"))
        expect_equal("Jan 1, 1970", lurek.i18n.formatDate(0, "short"))
    end)

    -- @covers lurek.i18n.tGender
    it("tGender resolves gendered keys and falls back to the base key", function()
        setup_en_fr()
        lurek.i18n.setKey("en", "title", "Captain {name}")
        lurek.i18n.setKey("en", "title.masculine", "Sir {name}")

        local masculine = lurek.i18n.tGender("title", "masculine", { name = "Alex" })
        local fallback = lurek.i18n.tGender("title", "neutral", { name = "Alex" })

        expect_equal("Sir Alex", masculine)
        expect_equal("Captain Alex", fallback)
    end)

    -- @covers lurek.i18n.getLoadedLocales
    it("getLoadedLocales returns every loaded locale", function()
        setup_en_fr()
        lurek.i18n.loadTable("zz_loaded", { hello = "Ciao" })

        local locales = lurek.i18n.getLoadedLocales()
        local seen = {}
        expect_type("table", locales)
        for _, locale in ipairs(locales) do
            seen[locale] = true
        end

        expect_true(seen["en"] ~= nil, "expected en to be listed")
        expect_true(seen["fr"] ~= nil, "expected fr to be listed")
        expect_true(seen["zz_loaded"] ~= nil, "expected zz_loaded to be listed")
        lurek.i18n.unloadTable("zz_loaded")
    end)
end)

-- @describe lurek.i18n.isRTL
describe("lurek.i18n.isRTL", function()
    -- @covers lurek.i18n.isRTL
    it("isRTL recognizes rtl locales, ltr locales, and the active locale fallback", function()
        expect_true(lurek.i18n.isRTL("ar"))
        expect_true(lurek.i18n.isRTL("ar-SA"))
        expect_true(lurek.i18n.isRTL("he"))
        expect_true(lurek.i18n.isRTL("he-IL"))
        expect_false(lurek.i18n.isRTL("en"))
        expect_false(lurek.i18n.isRTL("pl"))
        expect_false(lurek.i18n.isRTL("ja"))
        expect_false(lurek.i18n.isRTL("fr-FR"))

        lurek.i18n.loadTable("ar", { hello = "marhaba" })
        lurek.i18n.setLanguage("ar")
        expect_true(lurek.i18n.isRTL())
        lurek.i18n.loadTable("en", en)
        lurek.i18n.setLanguage("en")
        expect_false(lurek.i18n.isRTL())
    end)
end)

-- @describe lurek.i18n.validateLocale
describe("lurek.i18n.validateLocale", function()
    -- @covers lurek.i18n.validateLocale
    it("validateLocale accepts supported formats and rejects malformed codes", function()
        expect_true(lurek.i18n.validateLocale("en"))
        expect_true(lurek.i18n.validateLocale("en-US"))
        expect_true(lurek.i18n.validateLocale("zh-CN"))
        expect_true(lurek.i18n.validateLocale("pt-BR"))
        expect_true(lurek.i18n.validateLocale("en_GB"))
        expect_true(lurek.i18n.validateLocale("fr_FR"))
        expect_false(lurek.i18n.validateLocale(""))
        expect_false(lurek.i18n.validateLocale("x"))
        expect_false(lurek.i18n.validateLocale("1en"))
        expect_false(lurek.i18n.validateLocale("abcdefghijklmnopqrstuvwxyzabcdefghijk"))
    end)
end)

-- @describe lurek.i18n.detectLocale
describe("lurek.i18n.detectLocale", function()
    -- @covers lurek.i18n.detectLocale
    it("detectLocale returns nil or a non-empty locale string without encoding suffixes", function()
        local result = lurek.i18n.detectLocale()
        if result ~= nil then
            expect_type("string", result)
            expect_true(#result > 0, "detected locale must not be empty")
            expect_false(result:find("%.") ~= nil, "locale should not contain an encoding suffix")
        else
            expect_true(true, "nil is acceptable when no LANG env var is set")
        end
    end)
end)

-- @describe lurek.i18n.loadString
describe("lurek.i18n.loadString", function()
    -- @covers lurek.i18n.loadString
    it("loadString handles TOML and JSON inputs and rejects invalid formats", function()
        local toml_str = [[
[ui]
ok     = "OK"
cancel = "Cancel"
]]
        expect_no_error(function()
            lurek.i18n.loadString("toml_test", toml_str, "toml")
        end)
        lurek.i18n.setLanguage("toml_test")
        expect_equal("OK", lurek.i18n.t("ui.ok"))
        expect_equal("Cancel", lurek.i18n.t("ui.cancel"))
        lurek.i18n.unloadTable("toml_test")

        local json_str = '{"menu":{"start":"Start","quit":"Quit"}}'
        expect_no_error(function()
            lurek.i18n.loadString("json_test", json_str, "json")
        end)
        lurek.i18n.setLanguage("json_test")
        expect_equal("Start", lurek.i18n.t("menu.start"))
        expect_equal("Quit", lurek.i18n.t("menu.quit"))
        lurek.i18n.unloadTable("json_test")

        local ok = pcall(function()
            lurek.i18n.loadString("bad", "not valid toml !!!", "toml")
        end)
        expect_false(ok, "invalid TOML should raise an error")

        ok = pcall(function()
            lurek.i18n.loadString("bad", "{bad json", "json")
        end)
        expect_false(ok, "invalid JSON should raise an error")

        ok = pcall(function()
            lurek.i18n.loadString("bad", "data", "xml")
        end)
        expect_false(ok, "unknown format should raise an error")
    end)
end)

-- @describe lurek.i18n.localeCoverage
describe("lurek.i18n.localeCoverage", function()
    -- @covers lurek.i18n.localeCoverage
    it("localeCoverage reports missing keys and handles complete or unknown reference locales", function()
        clear_loaded_locales()
        lurek.i18n.loadTable("cov_en", { hello = "Hello", bye = "Goodbye" })
        lurek.i18n.loadTable("cov_fr", { hello = "Bonjour" })

        local gaps = lurek.i18n.localeCoverage("cov_en")
        expect_type("table", gaps)

        local found_bye = false
        for _, gap in ipairs(gaps) do
            if gap.key == "bye" then
                found_bye = true
                expect_type("table", gap.missing_in)
                local in_fr = false
                for _, loc in ipairs(gap.missing_in) do
                    if loc == "cov_fr" then
                        in_fr = true
                    end
                end
                expect_true(in_fr, "cov_fr should be listed as missing bye")
            end
        end
        expect_true(found_bye, "bye should appear as a coverage gap")
        lurek.i18n.unloadTable("cov_en")
        lurek.i18n.unloadTable("cov_fr")

        clear_loaded_locales()
        lurek.i18n.loadTable("full_en", { ok = "OK" })
        lurek.i18n.loadTable("full_fr", { ok = "OK" })
        gaps = lurek.i18n.localeCoverage("full_en")
        expect_type("table", gaps)
        expect_equal(0, #gaps, "no gaps expected when all keys are present")
        lurek.i18n.unloadTable("full_en")
        lurek.i18n.unloadTable("full_fr")

        clear_loaded_locales()
        gaps = lurek.i18n.localeCoverage("nonexistent_locale_xyz")
        expect_type("table", gaps)
        expect_equal(0, #gaps)
    end)
end)
end
-- END test_i18n_core_unit.lua

test_summary()
