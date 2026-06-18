-- content/examples/i18n.lua
-- Auto-generated from content/examples2/i18n_*.lua by tools/fix/merge_examples2_into_examples.py
-- Run: cargo run -- content/examples/i18n.lua

--- i18n Module: localization, translation, number/date formatting

local function i18n_log(message)
    lurek.log.info("[i18n] " .. message)
end

local function has_value(list, needle)
    for _, value in ipairs(list or {}) do
        if value == needle then
            return true
        end
    end
    return false
end

local function seed_catalog()
    lurek.i18n.offChange()
    for _, locale in ipairs({ "en", "pl", "fr", "ar", "runtime_ui", "tmp_i18n", "cov_en", "cov_pl" }) do
        lurek.i18n.unloadTable(locale)
    end
    lurek.i18n.loadTable("en", {
        menu = { start = "Start game", quit = "Quit" },
        hud = {
            coins = { one = "{count} coin", other = "{count} coins" },
            quest = "Quest: {name}",
            score = "Score {score}",
        },
        dialog = {
            greeting = "Hello {name}",
            tip = "Press {key} to interact",
        },
        ui = { ok = "OK", cancel = "Cancel" },
        title = "Captain {name}",
    })
    lurek.i18n.loadTable("pl", {
        menu = { start = "Start game PL" },
        hud = { quest = "Quest PL: {name}" },
        ui = { ok = "OK PL" },
    })
    lurek.i18n.loadTable("fr", {
        menu = { start = "Demarrer" },
        ui = { ok = "Daccord" },
    })
    lurek.i18n.loadTable("ar", {
        menu = { start = "Start game AR" },
        dialog = { greeting = "Hello AR {name}" },
    })
    lurek.i18n.setBase("en")
    lurek.i18n.setFallbacks({ "en" })
    lurek.i18n.setLanguage("en")
end

--@api: lurek.i18n.loadTable
do
    seed_catalog()
    local had_en = lurek.i18n.hasLanguage("en")
    lurek.i18n.loadTable("runtime_ui", { menu = { resume = "Resume run" }, ui = { apply = "Apply" } })
    lurek.i18n.setLanguage("runtime_ui")
    local resume = lurek.i18n.t("menu.resume")
    i18n_log("loadTable had_en=" .. tostring(had_en) .. " runtime_ui=" .. tostring(lurek.i18n.hasLanguage("runtime_ui")) .. " resume=" .. resume)
end

--@api: lurek.i18n.unloadTable
do
    seed_catalog()
    lurek.i18n.loadTable("tmp_i18n", { debug = { label = "Debug overlay" } })
    local loaded = lurek.i18n.hasLanguage("tmp_i18n")
    local removed = lurek.i18n.unloadTable("tmp_i18n")
    local still_loaded = lurek.i18n.hasLanguage("tmp_i18n")
    i18n_log("unloadTable loaded=" .. tostring(loaded) .. " removed=" .. tostring(removed) .. " still_loaded=" .. tostring(still_loaded))
end

--@api: lurek.i18n.loadString
do
    seed_catalog()
    local json = '{"menu":{"credits":"Credits"},"hud":{"banner":"Mission {name}"}}'
    lurek.i18n.loadString("runtime_ui", json, "json")
    lurek.i18n.setLanguage("runtime_ui")
    local credits = lurek.i18n.t("menu.credits")
    local banner = lurek.i18n.t("hud.banner", { name = "Relay" })
    i18n_log("loadString credits=" .. credits .. " banner=" .. banner)
end

--@api: lurek.i18n.setLanguage
do
    seed_catalog()
    local before = lurek.i18n.t("menu.start")
    lurek.i18n.setLanguage("pl")
    local after = lurek.i18n.t("menu.start")
    local active = lurek.i18n.getLanguage()
    i18n_log("setLanguage before=" .. before .. " after=" .. after .. " active=" .. tostring(active))
end

--@api: lurek.i18n.getLanguage
do
    seed_catalog()
    lurek.i18n.setLanguage("pl")
    local current = lurek.i18n.getLanguage()
    lurek.i18n.setLanguage("en")
    local restored = lurek.i18n.getLanguage()
    i18n_log("getLanguage current=" .. tostring(current) .. " restored=" .. tostring(restored))
end

--@api: lurek.i18n.getLanguages
do
    seed_catalog()
    lurek.i18n.loadTable("runtime_ui", { menu = { credits = "Credits" } })
    local languages = lurek.i18n.getLanguages()
    local has_en = has_value(languages, "en")
    local has_runtime = has_value(languages, "runtime_ui")
    i18n_log("getLanguages count=" .. tostring(#languages) .. " has_en=" .. tostring(has_en) .. " has_runtime=" .. tostring(has_runtime))
end

--@api: lurek.i18n.hasLanguage
do
    seed_catalog()
    local has_en = lurek.i18n.hasLanguage("en")
    local has_es = lurek.i18n.hasLanguage("es")
    lurek.i18n.loadTable("runtime_ui", { menu = { resume = "Resume" } })
    local has_runtime = lurek.i18n.hasLanguage("runtime_ui")
    i18n_log("hasLanguage en=" .. tostring(has_en) .. " es=" .. tostring(has_es) .. " runtime_ui=" .. tostring(has_runtime))
end

--@api: lurek.i18n.getAvailableLanguages
do
    seed_catalog()
    lurek.i18n.loadTable("runtime_ui", { menu = { credits = "Credits" } })
    local languages = lurek.i18n.getAvailableLanguages()
    local has_fr = has_value(languages, "fr")
    local has_runtime = has_value(languages, "runtime_ui")
    i18n_log("getAvailableLanguages count=" .. tostring(#languages) .. " first=" .. tostring(languages[1]) .. " has_fr=" .. tostring(has_fr) .. " has_runtime=" .. tostring(has_runtime))
end

--@api: lurek.i18n.setBase
do
    seed_catalog()
    local before = lurek.i18n.getBase()
    lurek.i18n.setBase("pl")
    lurek.i18n.setLanguage("pl")
    local after = lurek.i18n.getBase()
    i18n_log("setBase before=" .. before .. " after=" .. after .. " menu=" .. lurek.i18n.t("menu.start"))
end

--@api: lurek.i18n.getBase
do
    seed_catalog()
    lurek.i18n.setBase("en")
    lurek.i18n.setLanguage("pl")
    local base = lurek.i18n.getBase()
    local fallback_text = lurek.i18n.t("ui.cancel")
    local localized = lurek.i18n.t("ui.ok")
    i18n_log("getBase base=" .. base .. " ok=" .. localized .. " cancel=" .. fallback_text)
end

--@api: lurek.i18n.setFallbacks
do
    seed_catalog()
    lurek.i18n.setLanguage("pl")
    lurek.i18n.setFallbacks({ "en", "fr" })
    local fallback_text = lurek.i18n.t("ui.cancel")
    local chain = lurek.i18n.getFallbacks()
    i18n_log("setFallbacks first=" .. tostring(chain[1]) .. " second=" .. tostring(chain[2]) .. " cancel=" .. fallback_text)
end

--@api: lurek.i18n.getFallbacks
do
    seed_catalog()
    lurek.i18n.setFallbacks({ "pl", "en" })
    local chain = lurek.i18n.getFallbacks()
    local primary = chain[1] or "none"
    local backup = chain[2] or "none"
    i18n_log("getFallbacks primary=" .. primary .. " backup=" .. backup .. " count=" .. tostring(#chain))
end

--@api: lurek.i18n.t
do
    seed_catalog()
    lurek.i18n.setLanguage("en")
    local quest = lurek.i18n.t("hud.quest", { name = "Find the relay" })
    local coins = lurek.i18n.t("hud.coins", { count = "3" }, 3)
    local prompt = lurek.i18n.t("dialog.greeting", { name = "Mira" })
    i18n_log("t quest=" .. quest .. " coins=" .. coins .. " prompt=" .. prompt)
end

--@api: lurek.i18n.hasKey
do
    seed_catalog()
    lurek.i18n.setLanguage("pl")
    local has_local = lurek.i18n.hasKey("menu.start")
    local has_fallback = lurek.i18n.hasKey("ui.cancel")
    local missing = lurek.i18n.hasKey("ui.apply")
    i18n_log("hasKey local=" .. tostring(has_local) .. " fallback=" .. tostring(has_fallback) .. " missing=" .. tostring(missing))
end

--@api: lurek.i18n.getKeys
do
    seed_catalog()
    local keys = lurek.i18n.getKeys()
    local first = keys[1] or "none"
    local has_quest = has_value(keys, "hud.quest")
    local has_tip = has_value(keys, "dialog.tip")
    i18n_log("getKeys count=" .. tostring(#keys) .. " first=" .. first .. " has_quest=" .. tostring(has_quest) .. " has_tip=" .. tostring(has_tip))
end

--@api: lurek.i18n.setKey
do
    seed_catalog()
    lurek.i18n.setLanguage("en")
    lurek.i18n.setKey("en", "ui.apply", "Apply changes")
    local apply = lurek.i18n.t("ui.apply")
    local exists = lurek.i18n.hasKey("ui.apply")
    i18n_log("setKey exists=" .. tostring(exists) .. " apply=" .. apply)
end

--@api: lurek.i18n.keyCount
do
    seed_catalog()
    local before = lurek.i18n.keyCount()
    lurek.i18n.setKey("en", "debug.overlay", "Debug overlay")
    local after = lurek.i18n.keyCount()
    local delta = after - before
    i18n_log("keyCount before=" .. tostring(before) .. " after=" .. tostring(after) .. " delta=" .. tostring(delta))
end

--@api: lurek.i18n.interpolate
do
    local template = "Quest {name}: {count}/{goal}"
    local vars = { name = "Signal Relay", count = "2", goal = "5" }
    local line = lurek.i18n.interpolate(template, vars)
    local escaped = lurek.i18n.interpolate("Use {{brace}} then {key}", { key = "E" })
    i18n_log("interpolate line=" .. line .. " escaped=" .. escaped)
end

--@api: lurek.i18n.pluralFor
do
    seed_catalog()
    local category_one = lurek.i18n.pluralFor(1)
    local category_many = lurek.i18n.pluralFor(4)
    local single = lurek.i18n.t("hud.coins", { count = "1" }, 1)
    local stack = lurek.i18n.t("hud.coins", { count = "4" }, 4)
    i18n_log("pluralFor one=" .. category_one .. " many=" .. category_many .. " single=" .. single .. " stack=" .. stack)
end

--@api: lurek.i18n.tGender
do
    seed_catalog()
    lurek.i18n.setKey("en", "title", "Captain {name}")
    lurek.i18n.setKey("en", "title.masculine", "Sir {name}")
    local masculine = lurek.i18n.tGender("title", "masculine", { name = "Alex" })
    local fallback = lurek.i18n.tGender("title", "neutral", { name = "Alex" })
    i18n_log("tGender masculine=" .. masculine .. " fallback=" .. fallback)
end

--@api: lurek.i18n.categories
do
    seed_catalog()
    local cats = lurek.i18n.categories()
    local has_dialog = has_value(cats, "dialog")
    local has_hud = has_value(cats, "hud")
    local has_menu = has_value(cats, "menu")
    i18n_log("categories count=" .. tostring(#cats) .. " dialog=" .. tostring(has_dialog) .. " hud=" .. tostring(has_hud) .. " menu=" .. tostring(has_menu))
end

--@api: lurek.i18n.keysInCategory
do
    seed_catalog()
    local hud_keys = lurek.i18n.keysInCategory("hud")
    local has_coins = has_value(hud_keys, "hud.coins.one")
    local has_quest = has_value(hud_keys, "hud.quest")
    local first = hud_keys[1] or "none"
    i18n_log("keysInCategory first=" .. first .. " count=" .. tostring(#hud_keys) .. " coins=" .. tostring(has_coins) .. " quest=" .. tostring(has_quest))
end

--@api: lurek.i18n.search
do
    seed_catalog()
    local results = lurek.i18n.search("Hello", 5)
    local first = results[1]
    local key = first and first.key or "none"
    local value = first and first.value or "none"
    i18n_log("search count=" .. tostring(#results) .. " first_key=" .. key .. " first_value=" .. value)
end

--@api: lurek.i18n.buildIndex
do
    seed_catalog()
    local index = lurek.i18n.buildIndex()
    local hello_keys = index.hello or {}
    local start_keys = index.start or {}
    local first = hello_keys[1] or "none"
    i18n_log("buildIndex hello_count=" .. tostring(#hello_keys) .. " start_count=" .. tostring(#start_keys) .. " first=" .. first)
end

--@api: lurek.i18n.searchIndexed
do
    seed_catalog()
    local index = lurek.i18n.buildIndex()
    local matches = lurek.i18n.searchIndexed(index, "hello", 5)
    local first = matches[1] or "none"
    local has_greeting = has_value(matches, "dialog.greeting")
    i18n_log("searchIndexed count=" .. tostring(#matches) .. " first=" .. first .. " has_greeting=" .. tostring(has_greeting))
end

--@api: lurek.i18n.mergeLocale
do
    seed_catalog()
    lurek.i18n.mergeLocale("pl", { ["ui.cancel"] = "Cancel PL", ["ui.apply"] = "Apply PL" })
    lurek.i18n.setLanguage("pl")
    local cancel = lurek.i18n.t("ui.cancel")
    local apply = lurek.i18n.t("ui.apply")
    i18n_log("mergeLocale cancel=" .. cancel .. " apply=" .. apply)
end

--@api: lurek.i18n.formatNumber
do
    seed_catalog()
    lurek.i18n.setLanguage("fr")
    local price = lurek.i18n.formatNumber(12345.678, { decimals = 2 })
    local balance = lurek.i18n.formatNumber(512, { decimals = 0 })
    local label = "shop:" .. price .. "/" .. balance
    i18n_log("formatNumber " .. label)
end

--@api: lurek.i18n.formatDate
do
    seed_catalog()
    lurek.i18n.setLanguage("en")
    local iso = lurek.i18n.formatDate(0, "iso")
    local short = lurek.i18n.formatDate(0, "short")
    local card = "patch:" .. iso .. " short:" .. short
    i18n_log("formatDate " .. card)
end

--@api: lurek.i18n.onLanguageChange
do
    seed_catalog()
    local seen_new = "none"
    local seen_old = "none"
    lurek.i18n.onLanguageChange(function(new_locale, old_locale) seen_new = new_locale; seen_old = old_locale end)
    lurek.i18n.setLanguage("pl")
    i18n_log("onLanguageChange new=" .. seen_new .. " old=" .. seen_old .. " menu=" .. lurek.i18n.t("menu.start"))
end

--@api: lurek.i18n.onChange
do
    seed_catalog()
    local transitions = 0
    local last = "none"
    lurek.i18n.onChange(function(new_locale) transitions = transitions + 1; last = new_locale end)
    lurek.i18n.setLanguage("pl")
    i18n_log("onChange transitions=" .. tostring(transitions) .. " last=" .. last .. " quest=" .. lurek.i18n.t("hud.quest", { name = "Beacon" }))
end

--@api: lurek.i18n.offChange
do
    seed_catalog()
    local fired = 0
    lurek.i18n.onChange(function() fired = fired + 1 end)
    lurek.i18n.setLanguage("pl")
    lurek.i18n.offChange()
    lurek.i18n.setLanguage("en")
    i18n_log("offChange fired=" .. tostring(fired) .. " active=" .. tostring(lurek.i18n.getLanguage()))
end

--@api: lurek.i18n.isRTL
do
    seed_catalog()
    local arabic = lurek.i18n.isRTL("ar")
    lurek.i18n.setLanguage("ar")
    local active = lurek.i18n.isRTL()
    lurek.i18n.setLanguage("en")
    local latin = lurek.i18n.isRTL()
    i18n_log("isRTL ar=" .. tostring(arabic) .. " active=" .. tostring(active) .. " en=" .. tostring(latin))
end

--@api: lurek.i18n.detectLocale
do
    local detected = lurek.i18n.detectLocale()
    local chosen = detected or "en"
    local valid = lurek.i18n.validateLocale(chosen)
    local rtl = lurek.i18n.isRTL(chosen)
    i18n_log("detectLocale detected=" .. tostring(detected) .. " chosen=" .. chosen .. " valid=" .. tostring(valid) .. " rtl=" .. tostring(rtl))
end

--@api: lurek.i18n.validateLocale
do
    local en_ok = lurek.i18n.validateLocale("en-US")
    local pl_ok = lurek.i18n.validateLocale("pl_PL")
    local bad_short = lurek.i18n.validateLocale("x")
    local bad_long = lurek.i18n.validateLocale("abcdefghijklmnopqrstuvwxyzabcdefghijk")
    i18n_log("validateLocale en_US=" .. tostring(en_ok) .. " pl_PL=" .. tostring(pl_ok) .. " short=" .. tostring(bad_short) .. " long=" .. tostring(bad_long))
end

--@api: lurek.i18n.localeCoverage
do
    seed_catalog()
    lurek.i18n.loadTable("cov_en", { ui = { ok = "OK", cancel = "Cancel" }, hud = { ready = "Ready" } })
    lurek.i18n.loadTable("cov_pl", { ui = { ok = "OK" } })
    local gaps = lurek.i18n.localeCoverage("cov_en")
    local first = gaps[1]
    local missing = first and #first.missing_in or 0
    i18n_log("localeCoverage gaps=" .. tostring(#gaps) .. " first_key=" .. tostring(first and first.key or "none") .. " missing_count=" .. tostring(missing))
end

--@api: lurek.i18n.getLoadedLocales
do
    seed_catalog()
    lurek.i18n.loadTable("runtime_ui", { menu = { credits = "Credits" } })
    local locales = lurek.i18n.getLoadedLocales()
    local has_ar = has_value(locales, "ar")
    local has_runtime = has_value(locales, "runtime_ui")
    i18n_log("getLoadedLocales count=" .. tostring(#locales) .. " has_ar=" .. tostring(has_ar) .. " has_runtime=" .. tostring(has_runtime))
end
