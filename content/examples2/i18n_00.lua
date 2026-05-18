--- i18n Module: localization, translation, number/date formatting

--@api-stub: lurek.i18n.loadTable
-- Loads a translation table for a locale.
do
    lurek.i18n.loadTable("en", {["greetings.hello"] = "Hello"})
    print("locale table loaded")
end

--@api-stub: lurek.i18n.unloadTable
-- Unloads a previously loaded translation file.
do
    lurek.i18n.loadTable("en", {["test.key"] = "value"})
    lurek.i18n.unloadTable("content/examples/locale_en.toml")
    print("unloaded")
end

--@api-stub: lurek.i18n.loadString
-- Loads translations from an inline string with format.
do
    lurek.i18n.loadString("en", '[greetings]\nhello = "Hello"', "toml")
    print("loaded from string")
end

--@api-stub: lurek.i18n.setLanguage
-- Sets the active language.
do
    lurek.i18n.setLanguage("en")
    print("language set to en")
end

--@api-stub: lurek.i18n.getLanguage
-- Returns the currently active language.
do
    lurek.i18n.setLanguage("pl")
    local lang = lurek.i18n.getLanguage()
    print("current = " .. lang)
end

--@api-stub: lurek.i18n.getLanguages
-- Returns all loaded language codes.
do
    local langs = lurek.i18n.getLanguages()
    print("languages: " .. #langs)
end

--@api-stub: lurek.i18n.hasLanguage
-- Checks if a language is loaded.
do
    local ok = lurek.i18n.hasLanguage("en")
    print("has en = " .. tostring(ok))
end

--@api-stub: lurek.i18n.getAvailableLanguages
-- Returns all available language codes.
do
    local avail = lurek.i18n.getAvailableLanguages()
    print("available = " .. #avail)
end

--@api-stub: lurek.i18n.setBase
-- Sets the base (default) language.
do
    lurek.i18n.setBase("en")
    print("base set to en")
end

--@api-stub: lurek.i18n.getBase
-- Returns the base language.
do
    lurek.i18n.setBase("en")
    local base = lurek.i18n.getBase()
    print("base = " .. base)
end

--@api-stub: lurek.i18n.setFallbacks
-- Sets fallback language chain.
do
    lurek.i18n.setFallbacks({"en", "de"})
    print("fallbacks set")
end

--@api-stub: lurek.i18n.getFallbacks
-- Returns the fallback chain.
do
    lurek.i18n.setFallbacks({"en"})
    local fb = lurek.i18n.getFallbacks()
    print("fallbacks = " .. #fb)
end

--@api-stub: lurek.i18n.t
-- Translates a key with optional variable interpolation.
do
    lurek.i18n.setLanguage("en")
    local text = lurek.i18n.t("greetings.hello")
    print("translated = " .. text)
end

--@api-stub: lurek.i18n.t (with vars)
-- Translates a key with variable substitution.
do
    local text = lurek.i18n.t("greeting.personal", {name = "World"})
    print("with vars = " .. text)
end

--@api-stub: lurek.i18n.hasKey
-- Checks if a translation key exists.
do
    local ok = lurek.i18n.hasKey("greetings.hello")
    print("has key = " .. tostring(ok))
end

--@api-stub: lurek.i18n.getKeys
-- Returns all translation keys.
do
    local keys = lurek.i18n.getKeys()
    print("key count = " .. #keys)
end

--@api-stub: lurek.i18n.setKey
-- Sets a key value for a language at runtime.
do
    lurek.i18n.setKey("en", "custom.msg", "Hello!")
    print("key set")
end

--@api-stub: lurek.i18n.keyCount
-- Returns the total number of translation keys.
do
    local n = lurek.i18n.keyCount()
    print("total keys = " .. n)
end

--@api-stub: lurek.i18n.interpolate
-- Interpolates variables into a template string.
do
    local result = lurek.i18n.interpolate("Hello {name}!", {name = "Player"})
    print("interpolated = " .. result)
end

--@api-stub: lurek.i18n.pluralFor
-- Returns a plural-aware translation.
do
    local text = lurek.i18n.pluralFor(5)
    print("plural = " .. text)
end

--@api-stub: lurek.i18n.tGender
-- Returns a gender-aware translation.
do
    local text = lurek.i18n.tGender("greeting.formal", "female")
    print("gendered = " .. text)
end

--@api-stub: lurek.i18n.categories
-- Returns translation categories.
do
    local cats = lurek.i18n.categories()
    print("categories = " .. #cats)
end

--@api-stub: lurek.i18n.keysInCategory
-- Returns keys in a specific category.
do
    local keys = lurek.i18n.keysInCategory("greetings")
    print("greeting keys = " .. #keys)
end

--@api-stub: lurek.i18n.search
-- Searches keys by query string.
do
    local results = lurek.i18n.search("hello")
    print("search results = " .. #results)
end

--@api-stub: lurek.i18n.buildIndex
-- Builds a search index for fast lookups.
do
    local indexed = lurek.i18n.buildIndex()
    print("index built, entries = " .. #indexed)
end

--@api-stub: lurek.i18n.searchIndexed
-- Searches the pre-built index.
do
    local idx = lurek.i18n.buildIndex()
    local results = lurek.i18n.searchIndexed(idx, "greet")
    print("indexed results = " .. #results)
end

--@api-stub: lurek.i18n.mergeLocale
-- Merges a table of key-value pairs into a locale.
do
    lurek.i18n.mergeLocale("en", {["ui.ok"] = "OK", ["ui.cancel"] = "Cancel"})
    print("locale merged")
end

--@api-stub: lurek.i18n.formatNumber
-- Formats a number with locale rules.
do
    local str = lurek.i18n.formatNumber(1234567.89)
    print("formatted = " .. str)
end

--@api-stub: lurek.i18n.formatDate
-- Formats a timestamp with optional format string.
do
    local str = lurek.i18n.formatDate(1700000000)
    print("date = " .. str)
end

--@api-stub: lurek.i18n.onLanguageChange
-- Registers a callback for language changes.
do
    local handle = lurek.i18n.onLanguageChange(function()
        print("language changed!")
    end)
    print("onChange handle = " .. handle)
end

--@api-stub: lurek.i18n.onChange
-- Registers a change callback (alias).
do
    local handle = lurek.i18n.onChange(function()
        print("something changed")
    end)
    print("handle = " .. handle)
end

--@api-stub: lurek.i18n.offChange
-- Removes all change callbacks.
do
    lurek.i18n.onChange(function() end)
    lurek.i18n.offChange()
    print("callbacks removed")
end

--@api-stub: lurek.i18n.isRTL
-- Checks if a language uses right-to-left layout.
do
    local rtl = lurek.i18n.isRTL("ar")
    print("arabic RTL = " .. tostring(rtl))
end

--@api-stub: lurek.i18n.detectLocale
-- Detects the system locale.
do
    local detected = lurek.i18n.detectLocale()
    print("detected = " .. detected)
end

--@api-stub: lurek.i18n.validateLocale
-- Validates a locale's data integrity.
do
    local ok, err = lurek.i18n.validateLocale("en")
    print("valid = " .. tostring(ok))
    if err then
        print("error = " .. err)
    end
end

--@api-stub: lurek.i18n.localeCoverage
-- Returns translation completeness as a fraction.
do
    local cov = lurek.i18n.localeCoverage("en")
    print("coverage = " .. cov)
end

--@api-stub: lurek.i18n.getLoadedLocales
-- Returns loaded locale identifiers.
do
    local loaded = lurek.i18n.getLoadedLocales()
    print("loaded = " .. #loaded)
end

print("i18n_00.lua")
