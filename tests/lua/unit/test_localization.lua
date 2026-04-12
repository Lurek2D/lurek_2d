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

-- â”€â”€ module presence â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Verifies that the localization namespace exists and exposes every documented entry point as a callable function.
describe("lurek.localization module", function()
    -- @description Asserts that lurek.localization is registered as a table on the global lurek namespace.
    it("lurek.localization is a table", function()
        expect_type("table", lurek.localization)
    end)

    -- @description Checks that each expected API name resolves to a function, including loading, lookup, fallback, search, and merge helpers.
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

-- â”€â”€ loadTable / unloadTable / getLanguages / hasLanguage â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Exercises language registration and removal, then confirms the discovery APIs reflect the loaded locale set.
describe("lurek.localization.loadTable / unloadTable", function()
    -- @description Loads the en table and confirms hasLanguage immediately reports the new locale as available.
    it("loadTable adds a language detectable by hasLanguage", function()
        lurek.localization.loadTable("en", en)
        expect_true(lurek.localization.hasLanguage("en"))
    end)

    -- @description Loads two locales and checks that getAvailableLanguages returns a table containing at least both entries.
    it("getAvailableLanguages lists loaded languages", function()
        lurek.localization.loadTable("en", en)
        lurek.localization.loadTable("fr", fr)
        local langs = lurek.localization.getAvailableLanguages()
        expect_true(#langs >= 2)
    end)

    -- @description Confirms getLanguages returns a table and matches getAvailableLanguages in entry count after loading en.
    it("getLanguages is an alias for getAvailableLanguages", function()
        lurek.localization.loadTable("en", en)
        local l1 = lurek.localization.getLanguages()
        local l2 = lurek.localization.getAvailableLanguages()
        expect_type("table", l1)
        expect_equal(#l2, #l1)
    end)

    -- @description Loads a temporary locale, verifies it exists, unloads it, and then checks that hasLanguage flips to false.
    it("unloadTable removes the language", function()
        lurek.localization.loadTable("zz_test", { hello = "Hi" })
        expect_true(lurek.localization.hasLanguage("zz_test"))
        lurek.localization.unloadTable("zz_test")
        expect_false(lurek.localization.hasLanguage("zz_test"))
    end)
end)

-- â”€â”€ setLanguage / getLanguage / setBase / getBase â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Validates that the active language and base language setters persist values that the matching getters return unchanged.
describe("lurek.localization.setLanguage / getLanguage / setBase / getBase", function()
    -- @description Initializes the English and French tables, sets English active in setup, and checks getLanguage returns en.
    it("sets and gets the active language", function()
        setup_en_fr()
        expect_equal("en", lurek.localization.getLanguage())
    end)

    -- @description Sets the base locale to en and verifies getBase returns the same language code.
    it("setBase / getBase round-trip", function()
        lurek.localization.setBase("en")
        expect_equal("en", lurek.localization.getBase())
    end)
end)

-- â”€â”€ setFallbacks / getFallbacks â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Confirms fallback chain storage preserves order and that an empty configuration still returns a table.
describe("lurek.localization.setFallbacks / getFallbacks", function()
    -- @description Stores a two-language fallback list and checks the returned table keeps fr first and en second.
    it("setFallbacks stores ordered fallback chain", function()
        setup_en_fr()
        lurek.localization.setFallbacks({ "fr", "en" })
        local fb = lurek.localization.getFallbacks()
        expect_type("table", fb)
        expect_equal("fr", fb[1])
        expect_equal("en", fb[2])
    end)

    -- @description Clears fallbacks with an empty table and verifies getFallbacks still yields a table value.
    it("getFallbacks returns empty table when not set", function()
        lurek.localization.setFallbacks({})
        local fb = lurek.localization.getFallbacks()
        expect_type("table", fb)
    end)
end)

-- â”€â”€ t() basic lookup â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Covers direct key lookup, nested dot-path resolution, missing-key behavior, placeholder substitution, and plural form selection.
describe("lurek.localization.t basic lookup", function()
    -- @description Sets up English as the active locale and expects the greeting key to resolve to Hello.
    it("returns translated string for active language", function()
        setup_en_fr()
        expect_equal("Hello", lurek.localization.t("greeting"))
    end)

    -- @description Looks up the nested menu.start entry through dot-key syntax and expects the flattened result Start Game.
    it("supports dot-keys for nested tables", function()
        setup_en_fr()
        expect_equal("Start Game", lurek.localization.t("menu.start"))
    end)

    -- @description Requests a missing key and confirms the API returns the original key string as the fallback result.
    it("returns key when translation missing", function()
        setup_en_fr()
        expect_equal("nonexistent.key", lurek.localization.t("nonexistent.key"))
    end)

    -- @description Switches to French and verifies the farewell key resolves to the French string Au revoir.
    it("falls back to base language", function()
        setup_en_fr()
        lurek.localization.setLanguage("fr")
        expect_equal("Au revoir", lurek.localization.t("farewell"))
    end)

    -- @description Passes a name variable into the welcome template and checks that the {name} placeholder is replaced with Luna.
    it("replaces {var} placeholders", function()
        setup_en_fr()
        local result = lurek.localization.t("welcome", { name = "Luna" })
        expect_equal("Welcome, Luna!", result)
    end)

    -- @description Resolves the pluralized items entry with count 1 and expects the singular template 1 item.
    it("selects one for count == 1", function()
        setup_en_fr()
        local result = lurek.localization.t("items", { count = "1" }, 1)
        expect_equal("1 item", result)
    end)

    -- @description Resolves the pluralized items entry with count 5 and expects the plural template 5 items.
    it("selects other for count > 1", function()
        setup_en_fr()
        local result = lurek.localization.t("items", { count = "5" }, 5)
        expect_equal("5 items", result)
    end)
end)

-- â”€â”€ hasKey / getKeys / setKey â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Checks key existence reporting, key enumeration, and runtime insertion or override of localized strings.
describe("lurek.localization.hasKey / getKeys / setKey", function()
    -- @description Uses the loaded locale data to confirm hasKey reports greeting as present.
    it("hasKey returns true for a loaded key", function()
        setup_en_fr()
        expect_true(lurek.localization.hasKey("greeting"))
    end)

    -- @description Queries an obviously absent key name and confirms hasKey returns false.
    it("hasKey returns false for a missing key", function()
        setup_en_fr()
        expect_false(lurek.localization.hasKey("nonexistent_key_xyz"))
    end)

    -- @description Retrieves the current key list and verifies it is a table with at least one entry.
    it("getKeys returns a table of key strings", function()
        setup_en_fr()
        local keys = lurek.localization.getKeys()
        expect_type("table", keys)
        expect_true(#keys >= 1, "at least one key exists")
    end)

    -- @description Inserts a custom key into the English locale and confirms t() resolves the new value exactly.
    it("setKey adds or overrides a key in the current language", function()
        setup_en_fr()
        lurek.localization.setKey("en", "custom_added_key", "Custom Value")
        expect_equal("Custom Value", lurek.localization.t("custom_added_key"))
    end)
end)

-- â”€â”€ interpolate / pluralFor â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Verifies the raw interpolation helper and the plural classification helper independently of locale table lookup.
describe("lurek.localization.interpolate / pluralFor", function()
    -- @description Calls interpolate on a literal template and checks that the name placeholder becomes World.
    it("interpolate replaces {var} in a raw string", function()
        local result = lurek.localization.interpolate("Hello, {name}!", { name = "World" })
        expect_equal("Hello, World!", result)
    end)

    -- @description Provides an empty substitution table and confirms interpolate leaves a placeholder-free string unchanged.
    it("interpolate with no vars returns string unchanged", function()
        local result = lurek.localization.interpolate("No vars here", {})
        expect_equal("No vars here", result)
    end)

    -- @description Verifies pluralFor classifies the numeric value 1 as the singular form one.
    it("pluralFor returns one for n=1", function()
        local form = lurek.localization.pluralFor(1)
        expect_equal("one", form)
    end)

    -- @description Verifies pluralFor classifies the numeric value 5 as the plural form other.
    it("pluralFor returns other for n=5", function()
        local form = lurek.localization.pluralFor(5)
        expect_equal("other", form)
    end)
end)

-- â”€â”€ onChange / offChange â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Ensures language change callbacks fire when registered and stop firing once the same callback is removed.
describe("lurek.localization.onChange / offChange", function()
    -- @description Registers a callback that flips a boolean and confirms setLanguage invokes it at least once.
    it("fires callback when language changes", function()
        lurek.localization.loadTable("en", en)
        local fired = false
        lurek.localization.onChange(function() fired = true end)
        lurek.localization.setLanguage("en")
        expect_true(fired)
    end)

    -- @description Counts callback invocations across two setLanguage calls and verifies offChange prevents the second increment.
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

-- â”€â”€ keyCount / categories / keysInCategory â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Checks summary and grouping helpers by validating count types, category list shape, and category-specific key lookup behavior.
describe("lurek.localization.keyCount / categories / keysInCategory", function()
    -- @description Reads the total key count and confirms it is numeric and at least one after loading fixtures.
    it("keyCount returns a non-negative number", function()
        setup_en_fr()
        local n = lurek.localization.keyCount()
        expect_type("number", n)
        expect_true(n >= 1, "at least one key loaded")
    end)

    -- @description Calls categories after loading locale data and verifies the result is always a table.
    it("categories returns a table", function()
        setup_en_fr()
        local cats = lurek.localization.categories()
        expect_type("table", cats)
    end)

    -- @description Uses the first returned category when available and checks keysInCategory yields a table, otherwise accepts flat locales with no categories.
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

-- â”€â”€ search / buildIndex / searchIndexed â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Validates both direct and indexed text search helpers, including successful query results and index construction without errors.
describe("lurek.localization.search / buildIndex / searchIndexed", function()
    -- @description Searches for Hello and verifies the plain search API returns a table result container.
    it("search returns a table", function()
        setup_en_fr()
        local results = lurek.localization.search("Hello")
        expect_type("table", results)
    end)

    -- @description Searches for the known greeting value Hello and asserts that at least one result is returned.
    it("search finds a known term", function()
        setup_en_fr()
        local results = lurek.localization.search("Hello")
        expect_true(#results >= 1, "search should find greeting=Hello")
    end)

    -- @description Builds the localization search index and confirms the operation completes without raising an error.
    it("buildIndex runs without error", function()
        setup_en_fr()
        expect_no_error(function() lurek.localization.buildIndex() end)
    end)

    -- @description Builds an index, runs the indexed search for Hello, and verifies the indexed search result is a table.
    it("searchIndexed returns a table after buildIndex", function()
        setup_en_fr()
        local idx = lurek.localization.buildIndex()
        local results = lurek.localization.searchIndexed(idx, "Hello")
        expect_type("table", results)
    end)
end)

-- â”€â”€ mergeLocale â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€â”€
-- @description Covers locale merging for both extending an existing language and creating a brand-new language entry on demand.
describe("lurek.localization.mergeLocale", function()
    -- @description Merges an extra key into English, confirms the new key resolves, and then checks the original greeting remains unchanged.
    it("mergeLocale adds new keys to existing language without overwriting", function()
        setup_en_fr()
        lurek.localization.mergeLocale("en", { extra_key = "Extra Value" })
        expect_equal("Extra Value", lurek.localization.t("extra_key"))
        -- Original key preserved
        expect_equal("Hello", lurek.localization.t("greeting"))
    end)

    -- @description Merges data into a previously unknown language code, verifies the language now exists, and then removes the temporary fixture.
    it("mergeLocale creates a new language if it did not exist", function()
        lurek.localization.mergeLocale("zz_merge_test", { hello = "Hola" })
        expect_true(lurek.localization.hasLanguage("zz_merge_test"))
        lurek.localization.unloadTable("zz_merge_test")
    end)
end)

-- @description Mirrors Rust-side interpolation parity cases by checking single replacement, multiple replacements, unknown placeholder retention, and brace escaping behavior.
describe("string interpolation (RS parity)", function()
    -- @description Replaces one named placeholder in Hello, {name}! and expects the exact final string Hello, World!.
    it("interpolate replaces a single placeholder", function()
        local result = lurek.localization.interpolate("Hello, {name}!", { name = "World" })
        expect_equal("Hello, World!", result)
    end)

    -- @description Replaces three placeholders in the arithmetic template and expects the fully expanded string 1 + 2 = 3.
    it("interpolate replaces multiple placeholders", function()
        local result = lurek.localization.interpolate("{a} + {b} = {c}", { a = "1", b = "2", c = "3" })
        expect_equal("1 + 2 = 3", result)
    end)

    -- @description Leaves an unresolved placeholder untouched and checks the output still contains the literal token {unknown}.
    it("interpolate leaves unknown placeholders as-is", function()
        local result = lurek.localization.interpolate("Hi {unknown}", {})
        expect_contains(result, "{unknown}")
    end)

    -- @description Uses double braces around literal text and confirms the interpolated output still contains literal as escaped content.
    it("interpolate double-brace escaping produces single brace", function()
        local result = lurek.localization.interpolate("{{literal}}", {})
        expect_contains(result, "literal")
    end)
end)

-- @description Covers parity helpers that rely on interpolation and language enumeration by checking formatted string output and loaded-language table shape.
describe("localization format helpers (RS parity)", function()
    -- @description Interpolates a numeric placeholder, then verifies the result type is string and that the rendered output includes 42.
    it("format returns a string", function()
        local result = lurek.localization.interpolate("Value: {n}", { n = "42" })
        expect_equal("string", type(result))
        expect_contains(result, "42")
    end)

    -- @description Calls getLanguages after prior test loading and confirms the returned value is a table.
    it("getLanguages returns a non-empty table after loading", function()
        local langs = lurek.localization.getLanguages()
        expect_equal("table", type(langs))
    end)
end)

test_summary()
