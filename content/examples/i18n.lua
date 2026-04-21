-- content/examples/i18n.lua
-- Lurek2D lurek.i18n API Reference
-- Run with: cargo run -- content/examples/i18n
--
-- Scenario: A multilingual RPG with English/Spanish/Polish translations,
-- gender-aware dialogue, plural-aware item counts, number/date formatting,
-- and a searchable translation editor for modders.

print("=== lurek.i18n — Internationalization ===\n")

-- =============================================================================
-- Loading Translation Tables
-- =============================================================================

--@api-stub: lurek.i18n.loadTable
-- Demonstrates the proper usage of lurek.i18n.loadTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_loadTable()
    lurek.i18n.loadTable("en", "assets/locales/en.toml")
    lurek.i18n.loadTable("es", "assets/locales/es.toml")
    lurek.i18n.loadTable("pl", "assets/locales/pl.toml")
    print("loaded 3 locales")
end
local _ok, _err = pcall(demo_lurek_i18n_loadTable)

--@api-stub: lurek.i18n.getLoadedLocales
-- Demonstrates the proper usage of lurek.i18n.getLoadedLocales.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getLoadedLocales()
    local loaded = lurek.i18n.getLoadedLocales()
    print("loaded locales: " .. table.concat(loaded, ", "))
end
local _ok, _err = pcall(demo_lurek_i18n_getLoadedLocales)

--@api-stub: lurek.i18n.unloadTable
-- Demonstrates the proper usage of lurek.i18n.unloadTable.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_unloadTable()
    lurek.i18n.unloadTable("es")
    print("Spanish unloaded (to free memory)")
    lurek.i18n.loadTable("es", "assets/locales/es.toml")
end
local _ok, _err = pcall(demo_lurek_i18n_unloadTable)

-- =============================================================================
-- Language Selection
-- =============================================================================

--@api-stub: lurek.i18n.setLanguage
-- Demonstrates the proper usage of lurek.i18n.setLanguage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_setLanguage()
    lurek.i18n.setLanguage("en")
end
local _ok, _err = pcall(demo_lurek_i18n_setLanguage)

--@api-stub: lurek.i18n.getLanguage
-- Demonstrates the proper usage of lurek.i18n.getLanguage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getLanguage()
    print("current: " .. lurek.i18n.getLanguage())
end
local _ok, _err = pcall(demo_lurek_i18n_getLanguage)

--@api-stub: lurek.i18n.getLanguages
-- Demonstrates the proper usage of lurek.i18n.getLanguages.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getLanguages()
    local langs = lurek.i18n.getLanguages()
    print("languages: " .. table.concat(langs, ", "))
end
local _ok, _err = pcall(demo_lurek_i18n_getLanguages)

--@api-stub: lurek.i18n.hasLanguage
-- Demonstrates the proper usage of lurek.i18n.hasLanguage.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_hasLanguage()
    print("has Polish: " .. tostring(lurek.i18n.hasLanguage("pl")))
end
local _ok, _err = pcall(demo_lurek_i18n_hasLanguage)

--@api-stub: lurek.i18n.getAvailableLanguages
-- Demonstrates the proper usage of lurek.i18n.getAvailableLanguages.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getAvailableLanguages()
    local avail = lurek.i18n.getAvailableLanguages()
    print("available: " .. table.concat(avail, ", "))
end
local _ok, _err = pcall(demo_lurek_i18n_getAvailableLanguages)

-- =============================================================================
-- Base Language & Fallbacks
-- =============================================================================

--@api-stub: lurek.i18n.setBase
-- Demonstrates the proper usage of lurek.i18n.setBase.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_setBase()
    lurek.i18n.setBase("en")
end
local _ok, _err = pcall(demo_lurek_i18n_setBase)

--@api-stub: lurek.i18n.getBase
-- Demonstrates the proper usage of lurek.i18n.getBase.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getBase()
    print("base language: " .. lurek.i18n.getBase())
end
local _ok, _err = pcall(demo_lurek_i18n_getBase)

--@api-stub: lurek.i18n.setFallbacks
-- Demonstrates the proper usage of lurek.i18n.setFallbacks.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_setFallbacks()
    lurek.i18n.setFallbacks({"en"})
end
local _ok, _err = pcall(demo_lurek_i18n_setFallbacks)

--@api-stub: lurek.i18n.getFallbacks
-- Demonstrates the proper usage of lurek.i18n.getFallbacks.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getFallbacks()
    local fb = lurek.i18n.getFallbacks()
    print("fallbacks: " .. table.concat(fb, ", "))
end
local _ok, _err = pcall(demo_lurek_i18n_getFallbacks)

-- =============================================================================
-- Translation Lookup
-- =============================================================================

--@api-stub: lurek.i18n.t
-- Demonstrates the proper usage of lurek.i18n.t.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_t()
    print(lurek.i18n.t("menu.play"))
    print(lurek.i18n.t("menu.settings"))
end
local _ok, _err = pcall(demo_lurek_i18n_t)

--@api-stub: lurek.i18n.hasKey
-- Demonstrates the proper usage of lurek.i18n.hasKey.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_hasKey()
    print("has 'menu.play': " .. tostring(lurek.i18n.hasKey("menu.play")))
end
local _ok, _err = pcall(demo_lurek_i18n_hasKey)

--@api-stub: lurek.i18n.setKey
-- Demonstrates the proper usage of lurek.i18n.setKey.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_setKey()
    lurek.i18n.setKey("mod.greeting", "Hello from the mod!")
end
local _ok, _err = pcall(demo_lurek_i18n_setKey)

--@api-stub: lurek.i18n.interpolate
-- Demonstrates the proper usage of lurek.i18n.interpolate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_interpolate()
    local msg = lurek.i18n.interpolate("item.acquired", {item = "Iron Sword", count = 1})
    print("interpolated: " .. msg)
end
local _ok, _err = pcall(demo_lurek_i18n_interpolate)

--@api-stub: lurek.i18n.pluralFor
-- Demonstrates the proper usage of lurek.i18n.pluralFor.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_pluralFor()
    local form = lurek.i18n.pluralFor(5)
    print("plural form for 5: " .. form)
end
local _ok, _err = pcall(demo_lurek_i18n_pluralFor)

--@api-stub: lurek.i18n.tGender
-- Demonstrates the proper usage of lurek.i18n.tGender.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_tGender()
    local gendered = lurek.i18n.tGender("npc.greeting", "female")
    print("gendered: " .. gendered)
end
local _ok, _err = pcall(demo_lurek_i18n_tGender)

-- =============================================================================
-- Key Management & Categories
-- =============================================================================

--@api-stub: lurek.i18n.getKeys
-- Demonstrates the proper usage of lurek.i18n.getKeys.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_getKeys()
    local keys = lurek.i18n.getKeys()
    print("total keys: " .. #keys)
end
local _ok, _err = pcall(demo_lurek_i18n_getKeys)

--@api-stub: lurek.i18n.keyCount
-- Demonstrates the proper usage of lurek.i18n.keyCount.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_keyCount()
    print("key count: " .. lurek.i18n.keyCount())
end
local _ok, _err = pcall(demo_lurek_i18n_keyCount)

--@api-stub: lurek.i18n.categories
-- Demonstrates the proper usage of lurek.i18n.categories.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_categories()
    local cats = lurek.i18n.categories()
    print("categories: " .. table.concat(cats, ", "))
end
local _ok, _err = pcall(demo_lurek_i18n_categories)

--@api-stub: lurek.i18n.keysInCategory
-- Demonstrates the proper usage of lurek.i18n.keysInCategory.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_keysInCategory()
    local menu_keys = lurek.i18n.keysInCategory("menu")
    print("menu keys: " .. #menu_keys)
end
local _ok, _err = pcall(demo_lurek_i18n_keysInCategory)

-- =============================================================================
-- Search & Indexing (for mod translation editors)
-- =============================================================================

--@api-stub: lurek.i18n.search
-- Demonstrates the proper usage of lurek.i18n.search.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_search()
    local results = lurek.i18n.search("sword")
    print("search 'sword': " .. #results .. " hits")
end
local _ok, _err = pcall(demo_lurek_i18n_search)

--@api-stub: lurek.i18n.buildIndex
-- Demonstrates the proper usage of lurek.i18n.buildIndex.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_buildIndex()
    lurek.i18n.buildIndex()
    print("search index built")
end
local _ok, _err = pcall(demo_lurek_i18n_buildIndex)

--@api-stub: lurek.i18n.searchIndexed
-- Demonstrates the proper usage of lurek.i18n.searchIndexed.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_searchIndexed()
    local indexed = lurek.i18n.searchIndexed("potion")
    print("indexed search 'potion': " .. #indexed .. " hits")
end
local _ok, _err = pcall(demo_lurek_i18n_searchIndexed)

-- =============================================================================
-- Merging Locales (for mod support)
-- =============================================================================

--@api-stub: lurek.i18n.mergeLocale
-- Demonstrates the proper usage of lurek.i18n.mergeLocale.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_mergeLocale()
    lurek.i18n.mergeLocale("en", {["mod.item.name"] = "Enchanted Ring"})
    print("mod locale merged")
end
local _ok, _err = pcall(demo_lurek_i18n_mergeLocale)

-- =============================================================================
-- Formatting
-- =============================================================================

--@api-stub: lurek.i18n.formatNumber
-- Demonstrates the proper usage of lurek.i18n.formatNumber.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_formatNumber()
    print("number: " .. lurek.i18n.formatNumber(1234567.89))
end
local _ok, _err = pcall(demo_lurek_i18n_formatNumber)

--@api-stub: lurek.i18n.formatDate
-- Demonstrates the proper usage of lurek.i18n.formatDate.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_formatDate()
    print("date: " .. lurek.i18n.formatDate(os.time()))
end
local _ok, _err = pcall(demo_lurek_i18n_formatDate)

-- =============================================================================
-- Change Callbacks
-- =============================================================================

--@api-stub: lurek.i18n.onLanguageChange
-- Demonstrates the proper usage of lurek.i18n.onLanguageChange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_onLanguageChange()
    lurek.i18n.onLanguageChange(function(old_lang, new_lang)
    print("language changed: " .. old_lang .. " -> " .. new_lang)
end
local _ok, _err = pcall(demo_lurek_i18n_onLanguageChange)

--@api-stub: lurek.i18n.onChange
-- Demonstrates the proper usage of lurek.i18n.onChange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_onChange()
    local cb_id = lurek.i18n.onChange(function(key, value)
    print("translation updated: " .. key)
end
local _ok, _err = pcall(demo_lurek_i18n_onChange)

--@api-stub: lurek.i18n.offChange
-- Demonstrates the proper usage of lurek.i18n.offChange.
-- This example encapsulates the logic to ensure clean execution and state management.
local function demo_lurek_i18n_offChange()
    lurek.i18n.offChange(cb_id)
    print("\n-- i18n.lua example complete --")
end
local _ok, _err = pcall(demo_lurek_i18n_offChange)
