-- content/examples/i18n.lua
-- love2d-style usage snippets for the lurek.i18n API (31 items).
-- Each --@api-stub: block is a copy-pastable snippet showing the API
-- in real context (callbacks, conditionals, real arg values).
-- Run: cargo run -- content/examples/i18n.lua

-- ── lurek.i18n.* functions ──

--@api-stub: lurek.i18n.loadTable
-- Loads a language table under the given locale code.
-- May block — call from a worker thread for large payloads.
local result = lurek.i18n.loadTable(locale, tbl)
-- may block; consider lurek.thread for large payloads
print("loadTable:", result)
print("ok")

--@api-stub: lurek.i18n.unloadTable
-- Unloads a locale from the catalog.
-- See the module spec for detailed semantics.
local result = lurek.i18n.unloadTable(locale)
print("unloadTable:", result)
return result

--@api-stub: lurek.i18n.setLanguage
-- Sets the active translation language.
-- Apply at startup or in response to user input.
lurek.i18n.setLanguage("en")
lurek.i18n.setLanguage("pl")
-- switches all subsequent t() lookups
print("ok")

--@api-stub: lurek.i18n.getLanguage
-- Returns the currently active locale code, or nil if unset.
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getLanguage()
print("getLanguage:", value)
return value

--@api-stub: lurek.i18n.getLanguages
-- Returns all loaded locale codes.
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getLanguages()
print("getLanguages:", value)
return value

--@api-stub: lurek.i18n.setFallbacks
-- Sets the ordered list of fallback locale codes tried when a key is missing.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.i18n.setFallbacks(locales)
print("setFallbacks applied")
print("ok")

--@api-stub: lurek.i18n.getFallbacks
-- Returns the current fallback locale array.
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getFallbacks()
print("getFallbacks:", value)
return value

--@api-stub: lurek.i18n.t
-- Translates a key against the active locale with optional variable.
-- See the module spec for detailed semantics.
local greeting = lurek.i18n.t("ui.greeting")
local prompt   = lurek.i18n.t("ui.continue")
print(greeting, prompt)

--@api-stub: lurek.i18n.hasKey
-- Returns whether a key exists in the active locale.
-- Use as a guard inside lurek.update or event handlers.
if lurek.i18n.hasKey("ui.title") then
  print("hasKey -> true")
end

--@api-stub: lurek.i18n.getKeys
-- Returns all known keys for the active locale.
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getKeys()
print("getKeys:", value)
return value

--@api-stub: lurek.i18n.setKey
-- Inserts or overwrites a single key in the given locale.
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.i18n.setKey(locale, "ui.title", value)
print("setKey applied")
print("ok")

--@api-stub: lurek.i18n.interpolate
-- Interpolates {name} placeholders in a template string.
-- See the module spec for detailed semantics.
local result = lurek.i18n.interpolate(template, vars)
print("interpolate:", result)
return result

--@api-stub: lurek.i18n.pluralFor
-- Returns the CLDR plural category for a number ("one" or "other", etc.).
-- See the module spec for detailed semantics.
local result = lurek.i18n.pluralFor(10)
print("pluralFor:", result)
return result

--@api-stub: lurek.i18n.onLanguageChange
-- Registers a callback invoked when setLanguage() is called.
-- See the module spec for detailed semantics.
local result = lurek.i18n.onLanguageChange(function() print("onLanguageChange fired") end)
print("onLanguageChange:", result)
return result

--@api-stub: lurek.i18n.hasLanguage
-- Returns whether a locale has been loaded.
-- Use as a guard inside lurek.update or event handlers.
if lurek.i18n.hasLanguage(locale) then
  print("hasLanguage -> true")
end

--@api-stub: lurek.i18n.getAvailableLanguages
-- Returns all loaded locale codes (alias for getLanguages).
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getAvailableLanguages()
print("getAvailableLanguages:", value)
return value

--@api-stub: lurek.i18n.setBase
-- Sets the base/fallback language (adds it as first fallback).
-- Apply at startup or in response to user input.
-- apply at startup or on config change
lurek.i18n.setBase(locale)
print("setBase applied")
print("ok")

--@api-stub: lurek.i18n.getBase
-- Returns the base/fallback language.
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getBase()
print("getBase:", value)
return value

--@api-stub: lurek.i18n.onChange
-- Registers a callback invoked when setLanguage() is called (alias: onChange).
-- See the module spec for detailed semantics.
local result = lurek.i18n.onChange(function() print("onChange fired") end)
print("onChange:", result)
return result

--@api-stub: lurek.i18n.offChange
-- Unregisters all onChange callbacks.
-- See the module spec for detailed semantics.
local result = lurek.i18n.offChange()
print("offChange:", result)
return result

--@api-stub: lurek.i18n.keyCount
-- Returns the number of keys loaded in the active locale.
-- See the module spec for detailed semantics.
local result = lurek.i18n.keyCount()
print("keyCount:", result)
return result

--@api-stub: lurek.i18n.categories
-- Returns unique first-path-segment category prefixes for all active locale keys.
-- See the module spec for detailed semantics.
local result = lurek.i18n.categories()
print("categories:", result)
return result

--@api-stub: lurek.i18n.keysInCategory
-- Returns all keys in the active locale whose first path segment matches category.
-- See the module spec for detailed semantics.
local result = lurek.i18n.keysInCategory(category)
print("keysInCategory:", result)
return result

--@api-stub: lurek.i18n.search
-- Searches active locale values for a substring query (case-insensitive).
-- See the module spec for detailed semantics.
local result = lurek.i18n.search(query, limit)
print("search:", result)
return result

--@api-stub: lurek.i18n.buildIndex
-- Builds an inverted word index for the active locale.
-- Build once at startup; reuse across frames.
local buildindex = lurek.i18n.buildIndex()
print("created", buildindex)
return buildindex

--@api-stub: lurek.i18n.searchIndexed
-- Searches the provided pre-built index for entries matching all words in query.
-- See the module spec for detailed semantics.
local result = lurek.i18n.searchIndexed(1, query, limit)
print("searchIndexed:", result)
return result

--@api-stub: lurek.i18n.mergeLocale
-- Merges a flat keyâ†’value table into an existing locale without replacing the whole table.
-- See the module spec for detailed semantics.
local result = lurek.i18n.mergeLocale(locale, entries)
print("mergeLocale:", result)
return result

--@api-stub: lurek.i18n.formatNumber
-- Formats a number with locale-aware decimal and thousands separators.
-- See the module spec for detailed semantics.
local result = lurek.i18n.formatNumber(10, { x = 0, y = 0 })
print("formatNumber:", result)
return result

--@api-stub: lurek.i18n.formatDate
-- Formats a Unix timestamp according to the active locale's date order.
-- See the module spec for detailed semantics.
local result = lurek.i18n.formatDate(timestamp, "hello")
print("formatDate:", result)
return result

--@api-stub: lurek.i18n.tGender
-- Looks up a translation key augmented with a gender suffix.
-- See the module spec for detailed semantics.
local result = lurek.i18n.tGender("ui.title", gender, vars)
print("tGender:", result)
return result

--@api-stub: lurek.i18n.getLoadedLocales
-- Returns an array of all currently loaded locale codes.
-- Cheap to call; safe inside callbacks.
local value = lurek.i18n.getLoadedLocales()
print("getLoadedLocales:", value)
return value

