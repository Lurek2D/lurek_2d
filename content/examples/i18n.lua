-- content/examples/i18n.lua
-- Auto-generated from content/examples2/i18n_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/i18n.lua

--- i18n Module: localization, translation, number/date formatting




--@api: lurek.i18n.loadTable
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.unloadTable
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.loadString
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.setLanguage
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getLanguage
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getLanguages
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.hasLanguage
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getAvailableLanguages
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.setBase
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getBase
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.setFallbacks
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getFallbacks
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.t
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.hasKey
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getKeys
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.setKey
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.keyCount
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.interpolate
do

    local template = "Quest {name}: {count}/{goal}"
    local vars = { name = "Signal Relay", count = "2", goal = "5" }
    local line = lurek.i18n.interpolate(template, vars)
    local escaped = lurek.i18n.interpolate("Use {{brace}} then {key}", { key = "E" })
    lurek.log.info("interpolate line=" .. line .. " escaped=" .. escaped)
end

--@api: lurek.i18n.pluralFor
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.tGender
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.categories
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.keysInCategory
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.search
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.buildIndex
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.searchIndexed
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.mergeLocale
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.formatNumber
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.formatDate
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.onLanguageChange
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.onChange
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.offChange
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.isRTL
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.detectLocale
do

    local detected = lurek.i18n.detectLocale()
    local chosen = detected or "en"
    local valid = lurek.i18n.validateLocale(chosen)
    local rtl = lurek.i18n.isRTL(chosen)
    lurek.log.info("detectLocale detected=" .. tostring(detected) .. " chosen=" .. chosen .. " valid=" .. tostring(valid) .. " rtl=" .. tostring(rtl))
end

--@api: lurek.i18n.validateLocale
do

    local en_ok = lurek.i18n.validateLocale("en-US")
    local pl_ok = lurek.i18n.validateLocale("pl_PL")
    local bad_short = lurek.i18n.validateLocale("x")
    local bad_long = lurek.i18n.validateLocale("abcdefghijklmnopqrstuvwxyzabcdefghijk")
    lurek.log.info("validateLocale en_US=" .. tostring(en_ok) .. " pl_PL=" .. tostring(pl_ok) .. " short=" .. tostring(bad_short) .. " long=" .. tostring(bad_long))
end

--@api: lurek.i18n.localeCoverage
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end

--@api: lurek.i18n.getLoadedLocales
do

lurek.i18n.offChange()
for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
lurek.i18n.unloadTable(locale)
end
    local example_ok = true
end
