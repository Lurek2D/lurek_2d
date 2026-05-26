-- content/examples/i18n.lua
-- Auto-generated from content/examples2/i18n_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/i18n.lua

--- i18n Module: localization, translation, number/date formatting

--@api-stub: lurek.i18n.loadTable
do
    lurek.i18n.loadTable("en", {["greetings.hello"] = "Hello"})
    print("locale table loaded")
end

--@api-stub: lurek.i18n.unloadTable
do
    lurek.i18n.loadTable("en", {["test.key"] = "value"})
    lurek.i18n.unloadTable("en")
    print("unloaded")
end

--@api-stub: lurek.i18n.loadString
do
    lurek.i18n.loadString("en", '[greetings]\nhello = "Hello"', "toml")
    print("loaded from string")
end

--@api-stub: lurek.i18n.setLanguage
do
    lurek.i18n.setLanguage("en")
    print("language set to en")
end

--@api-stub: lurek.i18n.getLanguage
do
    lurek.i18n.setLanguage("pl")
    local lang = lurek.i18n.getLanguage()
    print("current = " .. lang)
end

--@api-stub: lurek.i18n.getLanguages
do
    local langs = lurek.i18n.getLanguages()
    print("languages: " .. #langs)
end

--@api-stub: lurek.i18n.hasLanguage
do
    local ok = lurek.i18n.hasLanguage("en")
    print("has en = " .. tostring(ok))
end

--@api-stub: lurek.i18n.getAvailableLanguages
do
    local avail = lurek.i18n.getAvailableLanguages()
    print("available = " .. #avail)
end

--@api-stub: lurek.i18n.setBase
do
    lurek.i18n.setBase("en")
    print("base set to en")
end

--@api-stub: lurek.i18n.getBase
do
    lurek.i18n.setBase("en")
    local base = lurek.i18n.getBase()
    print("base = " .. base)
end

--@api-stub: lurek.i18n.setFallbacks
do
    lurek.i18n.setFallbacks({"en", "de"})
    print("fallbacks set")
end

--@api-stub: lurek.i18n.getFallbacks
do
    lurek.i18n.setFallbacks({"en"})
    local fb = lurek.i18n.getFallbacks()
    print("fallbacks = " .. #fb)
end

--@api-stub: lurek.i18n.t
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello" } })
    lurek.i18n.setLanguage("en")
    local text = lurek.i18n.t("greetings.hello")
    print("translated = " .. text)
end

--@api-stub: lurek.i18n.hasKey
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello" } })
    lurek.i18n.setLanguage("en")
    local ok = lurek.i18n.hasKey("greetings.hello")
    print("has key = " .. tostring(ok))
end

--@api-stub: lurek.i18n.getKeys
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello" }, ui = { ok = "OK" } })
    lurek.i18n.setLanguage("en")
    local keys = lurek.i18n.getKeys()
    print("key count = " .. #keys)
end

--@api-stub: lurek.i18n.setKey
do
    lurek.i18n.setKey("en", "custom.msg", "Hello!")
    print("key set")
end

--@api-stub: lurek.i18n.keyCount
do
    lurek.i18n.loadTable("en", { ui = { ok = "OK", cancel = "Cancel" } })
    lurek.i18n.setLanguage("en")
    local n = lurek.i18n.keyCount()
    print("total keys = " .. n)
end

--@api-stub: lurek.i18n.interpolate
do
    local result = lurek.i18n.interpolate("Hello {name}!", {name = "Player"})
    print("interpolated = " .. result)
end

--@api-stub: lurek.i18n.pluralFor
do
    local text = lurek.i18n.pluralFor(5)
    print("plural = " .. text)
end

--@api-stub: lurek.i18n.tGender
do
    local text = lurek.i18n.tGender("greeting.formal", "female")
    print("gendered = " .. text)
end

--@api-stub: lurek.i18n.categories
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello" }, ui = { ok = "OK" } })
    lurek.i18n.setLanguage("en")
    local cats = lurek.i18n.categories()
    print("categories = " .. #cats)
end

--@api-stub: lurek.i18n.keysInCategory
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello", bye = "Bye" } })
    lurek.i18n.setLanguage("en")
    local keys = lurek.i18n.keysInCategory("greetings")
    print("greeting keys = " .. #keys)
end

--@api-stub: lurek.i18n.search
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello there" } })
    lurek.i18n.setLanguage("en")
    local results = lurek.i18n.search("hello")
    print("search results = " .. #results)
end

--@api-stub: lurek.i18n.buildIndex
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello traveler" } })
    lurek.i18n.setLanguage("en")
    local indexed = lurek.i18n.buildIndex()
    print("index built = " .. tostring(type(indexed) == "table"))
    print("has greeting bucket = " .. tostring(indexed.greeting ~= nil or indexed.hello ~= nil))
end

--@api-stub: lurek.i18n.searchIndexed
do
    lurek.i18n.loadTable("en", { greetings = { hello = "Hello traveler" } })
    lurek.i18n.setLanguage("en")
    local idx = lurek.i18n.buildIndex()
    local results = lurek.i18n.searchIndexed(idx, "greet")
    print("indexed results = " .. #results)
end

--@api-stub: lurek.i18n.mergeLocale
do
    lurek.i18n.mergeLocale("en", {["ui.ok"] = "OK", ["ui.cancel"] = "Cancel"})
    print("locale merged")
end

--@api-stub: lurek.i18n.formatNumber
do
    local str = lurek.i18n.formatNumber(1234567.89)
    print("formatted = " .. str)
end

--@api-stub: lurek.i18n.formatDate
do
    local str = lurek.i18n.formatDate(1700000000)
    print("date = " .. str)
end

--@api-stub: lurek.i18n.onLanguageChange
do
    lurek.i18n.onLanguageChange(function(new_locale, old_locale)
        print("language changed!")
    end)
    print("language change callback registered")
end

--@api-stub: lurek.i18n.onChange
do
    lurek.i18n.onChange(function(new_locale, old_locale)
        print("something changed")
    end)
    print("change callback registered")
end

--@api-stub: lurek.i18n.offChange
do
    lurek.i18n.onChange(function() end)
    lurek.i18n.offChange()
    print("callbacks removed")
end

--@api-stub: lurek.i18n.isRTL
do
    local rtl = lurek.i18n.isRTL("ar")
    print("arabic RTL = " .. tostring(rtl))
end

--@api-stub: lurek.i18n.detectLocale
do
    local detected = lurek.i18n.detectLocale()
    print("detected = " .. tostring(detected))
end

--@api-stub: lurek.i18n.validateLocale
do
    local ok = lurek.i18n.validateLocale("en")
    print("valid = " .. tostring(ok))
end

--@api-stub: lurek.i18n.localeCoverage
do
    lurek.i18n.loadTable("en", { ui = { ok = "OK", cancel = "Cancel" } })
    lurek.i18n.loadTable("pl", { ui = { ok = "OK" } })
    local cov = lurek.i18n.localeCoverage("en")
    print("coverage gaps = " .. #cov)
end

--@api-stub: lurek.i18n.getLoadedLocales
do
    lurek.i18n.loadTable("en", { ui = { ok = "OK" } })
    lurek.i18n.loadTable("pl", { ui = { ok = "OK" } })
    local loaded = lurek.i18n.getLoadedLocales()
    print("loaded = " .. #loaded)
end
