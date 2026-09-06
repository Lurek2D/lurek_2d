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
    local had_en = lurek.i18n.hasLanguage("en")
    lurek.i18n.loadTable("runtime_ui", { menu = { resume = "Resume run" }, ui = { apply = "Apply" } })
    lurek.i18n.setLanguage("runtime_ui")
    local resume = lurek.i18n.t("menu.resume")
    lurek.log.info("loadTable had_en=" .. tostring(had_en) .. " runtime_ui=" .. tostring(lurek.i18n.hasLanguage("runtime_ui")) .. " resume=" .. resume)
end

--@api: lurek.i18n.unloadTable
do

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
    lurek.i18n.loadTable("tmp_i18n", { debug = { label = "Debug overlay" } })
    local loaded = lurek.i18n.hasLanguage("tmp_i18n")
    local removed = lurek.i18n.unloadTable("tmp_i18n")
    local still_loaded = lurek.i18n.hasLanguage("tmp_i18n")
    lurek.log.info("unloadTable loaded=" .. tostring(loaded) .. " removed=" .. tostring(removed) .. " still_loaded=" .. tostring(still_loaded))
end

--@api: lurek.i18n.loadString
do

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
    local json = '{"menu":{"credits":"Credits"},"hud":{"banner":"Mission {name}"}}'
    lurek.i18n.loadString("runtime_ui", json, "json")
    lurek.i18n.setLanguage("runtime_ui")
    local credits = lurek.i18n.t("menu.credits")
    local banner = lurek.i18n.t("hud.banner", { name = "Relay" })
    lurek.log.info("loadString credits=" .. credits .. " banner=" .. banner)
end

--@api: lurek.i18n.setLanguage
do

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
    local before = lurek.i18n.t("menu.start")
    lurek.i18n.setLanguage("pl")
    local after = lurek.i18n.t("menu.start")
    local active = lurek.i18n.getLanguage()
    lurek.log.info("setLanguage before=" .. before .. " after=" .. after .. " active=" .. tostring(active))
end

--@api: lurek.i18n.getLanguage
do

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
    lurek.i18n.setLanguage("pl")
    local current = lurek.i18n.getLanguage()
    lurek.i18n.setLanguage("en")
    local restored = lurek.i18n.getLanguage()
    lurek.log.info("getLanguage current=" .. tostring(current) .. " restored=" .. tostring(restored))
end

--@api: lurek.i18n.getLanguages
do

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
    lurek.i18n.loadTable("runtime_ui", { menu = { credits = "Credits" } })
    local languages = lurek.i18n.getLanguages()
    local has_en = false
    for _, value in ipairs(languages or {}) do
        if value == "en" then
            has_en = true
        end
    end
    local has_runtime = false
    for _, value in ipairs(languages or {}) do
        if value == "runtime_ui" then
            has_runtime = true
        end
    end
    lurek.log.info("getLanguages count=" .. tostring(#languages) .. " has_en=" .. tostring(has_en) .. " has_runtime=" .. tostring(has_runtime))
end

--@api: lurek.i18n.hasLanguage
do

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
    local has_en = lurek.i18n.hasLanguage("en")
    local has_es = lurek.i18n.hasLanguage("es")
    lurek.i18n.loadTable("runtime_ui", { menu = { resume = "Resume" } })
    local has_runtime = lurek.i18n.hasLanguage("runtime_ui")
    lurek.log.info("hasLanguage en=" .. tostring(has_en) .. " es=" .. tostring(has_es) .. " runtime_ui=" .. tostring(has_runtime))
end

--@api: lurek.i18n.getAvailableLanguages
do

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
    lurek.i18n.loadTable("runtime_ui", { menu = { credits = "Credits" } })
    local languages = lurek.i18n.getAvailableLanguages()
    local has_fr = false
    for _, value in ipairs(languages or {}) do
        if value == "fr" then
            has_fr = true
        end
    end
    local has_runtime = false
    for _, value in ipairs(languages or {}) do
        if value == "runtime_ui" then
            has_runtime = true
        end
    end
    lurek.log.info("getAvailableLanguages count=" .. tostring(#languages) .. " first=" .. tostring(languages[1]) .. " has_fr=" .. tostring(has_fr) .. " has_runtime=" .. tostring(has_runtime))
end

--@api: lurek.i18n.setBase
do

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
    local before = lurek.i18n.getBase()
    lurek.i18n.setBase("pl")
    lurek.i18n.setLanguage("pl")
    local after = lurek.i18n.getBase()
    lurek.log.info("setBase before=" .. before .. " after=" .. after .. " menu=" .. lurek.i18n.t("menu.start"))
end

--@api: lurek.i18n.getBase
do

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
    lurek.i18n.setBase("en")
    lurek.i18n.setLanguage("pl")
    local base = lurek.i18n.getBase()
    local fallback_text = lurek.i18n.t("ui.cancel")
    local localized = lurek.i18n.t("ui.ok")
    lurek.log.info("getBase base=" .. base .. " ok=" .. localized .. " cancel=" .. fallback_text)
end

--@api: lurek.i18n.setFallbacks
do

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
    lurek.i18n.setLanguage("pl")
    lurek.i18n.setFallbacks({ "en", "fr" })
    local fallback_text = lurek.i18n.t("ui.cancel")
    local chain = lurek.i18n.getFallbacks()
    lurek.log.info("setFallbacks first=" .. tostring(chain[1]) .. " second=" .. tostring(chain[2]) .. " cancel=" .. fallback_text)
end

--@api: lurek.i18n.getFallbacks
do

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
    lurek.i18n.setFallbacks({ "pl", "en" })
    local chain = lurek.i18n.getFallbacks()
    local primary = chain[1] or "none"
    local backup = chain[2] or "none"
    lurek.log.info("getFallbacks primary=" .. primary .. " backup=" .. backup .. " count=" .. tostring(#chain))
end

--@api: lurek.i18n.t
do

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
    lurek.i18n.setLanguage("en")
    local quest = lurek.i18n.t("hud.quest", { name = "Find the relay" })
    local coins = lurek.i18n.t("hud.coins", { count = "3" }, 3)
    local prompt = lurek.i18n.t("dialog.greeting", { name = "Mira" })
    lurek.log.info("t quest=" .. quest .. " coins=" .. coins .. " prompt=" .. prompt)
end

--@api: lurek.i18n.hasKey
do

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
    lurek.i18n.setLanguage("pl")
    local has_local = lurek.i18n.hasKey("menu.start")
    local has_fallback = lurek.i18n.hasKey("ui.cancel")
    local missing = lurek.i18n.hasKey("ui.apply")
    lurek.log.info("hasKey local=" .. tostring(has_local) .. " fallback=" .. tostring(has_fallback) .. " missing=" .. tostring(missing))
end

--@api: lurek.i18n.getKeys
do

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
    local keys = lurek.i18n.getKeys()
    local first = keys[1] or "none"
    local has_quest = false
    for _, value in ipairs(keys or {}) do
        if value == "hud.quest" then
            has_quest = true
        end
    end
    local has_tip = false
    for _, value in ipairs(keys or {}) do
        if value == "dialog.tip" then
            has_tip = true
        end
    end
    lurek.log.info("getKeys count=" .. tostring(#keys) .. " first=" .. first .. " has_quest=" .. tostring(has_quest) .. " has_tip=" .. tostring(has_tip))
end

--@api: lurek.i18n.setKey
do

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
    lurek.i18n.setLanguage("en")
    lurek.i18n.setKey("en", "ui.apply", "Apply changes")
    local apply = lurek.i18n.t("ui.apply")
    local exists = lurek.i18n.hasKey("ui.apply")
    lurek.log.info("setKey exists=" .. tostring(exists) .. " apply=" .. apply)
end

--@api: lurek.i18n.keyCount
do

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
    local before = lurek.i18n.keyCount()
    lurek.i18n.setKey("en", "debug.overlay", "Debug overlay")
    local after = lurek.i18n.keyCount()
    local delta = after - before
    lurek.log.info("keyCount before=" .. tostring(before) .. " after=" .. tostring(after) .. " delta=" .. tostring(delta))
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
    local category_one = lurek.i18n.pluralFor(1)
    local category_many = lurek.i18n.pluralFor(4)
    local single = lurek.i18n.t("hud.coins", { count = "1" }, 1)
    local stack = lurek.i18n.t("hud.coins", { count = "4" }, 4)
    lurek.log.info("pluralFor one=" .. category_one .. " many=" .. category_many .. " single=" .. single .. " stack=" .. stack)
end

--@api: lurek.i18n.tGender
do

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
    lurek.i18n.setKey("en", "title", "Captain {name}")
    lurek.i18n.setKey("en", "title.masculine", "Sir {name}")
    local masculine = lurek.i18n.tGender("title", "masculine", { name = "Alex" })
    local fallback = lurek.i18n.tGender("title", "neutral", { name = "Alex" })
    lurek.log.info("tGender masculine=" .. masculine .. " fallback=" .. fallback)
end

--@api: lurek.i18n.categories
do

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
    local cats = lurek.i18n.categories()
    local has_dialog = false
    for _, value in ipairs(cats or {}) do
        if value == "dialog" then
            has_dialog = true
        end
    end
    local has_hud = false
    for _, value in ipairs(cats or {}) do
        if value == "hud" then
            has_hud = true
        end
    end
    local has_menu = false
    for _, value in ipairs(cats or {}) do
        if value == "menu" then
            has_menu = true
        end
    end
    lurek.log.info("categories count=" .. tostring(#cats) .. " dialog=" .. tostring(has_dialog) .. " hud=" .. tostring(has_hud) .. " menu=" .. tostring(has_menu))
end

--@api: lurek.i18n.keysInCategory
do

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
    local hud_keys = lurek.i18n.keysInCategory("hud")
    local has_coins = false
    for _, value in ipairs(hud_keys or {}) do
        if value == "hud.coins.one" then
            has_coins = true
        end
    end
    local has_quest = false
    for _, value in ipairs(hud_keys or {}) do
        if value == "hud.quest" then
            has_quest = true
        end
    end
    local first = hud_keys[1] or "none"
    lurek.log.info("keysInCategory first=" .. first .. " count=" .. tostring(#hud_keys) .. " coins=" .. tostring(has_coins) .. " quest=" .. tostring(has_quest))
end

--@api: lurek.i18n.search
do

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
    local results = lurek.i18n.search("Hello", 5)
    local first = results[1]
    local key = first and first.key or "none"
    local value = first and first.value or "none"
    lurek.log.info("search count=" .. tostring(#results) .. " first_key=" .. key .. " first_value=" .. value)
end

--@api: lurek.i18n.buildIndex
do

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
    local index = lurek.i18n.buildIndex()
    local hello_keys = index.hello or {}
    local start_keys = index.start or {}
    local first = hello_keys[1] or "none"
    lurek.log.info("buildIndex hello_count=" .. tostring(#hello_keys) .. " start_count=" .. tostring(#start_keys) .. " first=" .. first)
end

--@api: lurek.i18n.searchIndexed
do

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
    local index = lurek.i18n.buildIndex()
    local matches = lurek.i18n.searchIndexed(index, "hello", 5)
    local first = matches[1] or "none"
    local has_greeting = false
    for _, value in ipairs(matches or {}) do
        if value == "dialog.greeting" then
            has_greeting = true
        end
    end
    lurek.log.info("searchIndexed count=" .. tostring(#matches) .. " first=" .. first .. " has_greeting=" .. tostring(has_greeting))
end

--@api: lurek.i18n.mergeLocale
do

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
    lurek.i18n.mergeLocale("pl", { ["ui.cancel"] = "Cancel PL", ["ui.apply"] = "Apply PL" })
    lurek.i18n.setLanguage("pl")
    local cancel = lurek.i18n.t("ui.cancel")
    local apply = lurek.i18n.t("ui.apply")
    lurek.log.info("mergeLocale cancel=" .. cancel .. " apply=" .. apply)
end

--@api: lurek.i18n.formatNumber
do

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
    lurek.i18n.setLanguage("fr")
    local price = lurek.i18n.formatNumber(12345.678, { decimals = 2 })
    local balance = lurek.i18n.formatNumber(512, { decimals = 0 })
    local label = "shop:" .. price .. "/" .. balance
    lurek.log.info("formatNumber " .. label)
end

--@api: lurek.i18n.formatDate
do

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
    lurek.i18n.setLanguage("en")
    local iso = lurek.i18n.formatDate(0, "iso")
    local short = lurek.i18n.formatDate(0, "short")
    local card = "patch:" .. iso .. " short:" .. short
    lurek.log.info("formatDate " .. card)
end

--@api: lurek.i18n.onLanguageChange
do

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
    local seen_new = "none"
    local seen_old = "none"
    lurek.i18n.onLanguageChange(function(new_locale, old_locale) seen_new = new_locale; seen_old = old_locale end)
    lurek.i18n.setLanguage("pl")
    lurek.log.info("onLanguageChange new=" .. seen_new .. " old=" .. seen_old .. " menu=" .. lurek.i18n.t("menu.start"))
end

--@api: lurek.i18n.onChange
do

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
    local transitions = 0
    local last = "none"
    lurek.i18n.onChange(function(new_locale) transitions = transitions + 1; last = new_locale end)
    lurek.i18n.setLanguage("pl")
    lurek.log.info("onChange transitions=" .. tostring(transitions) .. " last=" .. last .. " quest=" .. lurek.i18n.t("hud.quest", { name = "Beacon" }))
end

--@api: lurek.i18n.offChange
do

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
    local fired = 0
    lurek.i18n.onChange(function() fired = fired + 1 end)
    lurek.i18n.setLanguage("pl")
    lurek.i18n.offChange()
    lurek.i18n.setLanguage("en")
    lurek.log.info("offChange fired=" .. tostring(fired) .. " active=" .. tostring(lurek.i18n.getLanguage()))
end

--@api: lurek.i18n.isRTL
do

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
    local arabic = lurek.i18n.isRTL("ar")
    lurek.i18n.setLanguage("ar")
    local active = lurek.i18n.isRTL()
    lurek.i18n.setLanguage("en")
    local latin = lurek.i18n.isRTL()
    lurek.log.info("isRTL ar=" .. tostring(arabic) .. " active=" .. tostring(active) .. " en=" .. tostring(latin))
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
    lurek.i18n.loadTable("cov_en", { ui = { ok = "OK", cancel = "Cancel" }, hud = { ready = "Ready" } })
    lurek.i18n.loadTable("cov_pl", { ui = { ok = "OK" } })
    local gaps = lurek.i18n.localeCoverage("cov_en")
    local first = gaps[1]
    local missing = first and #first.missing_in or 0
    lurek.log.info("localeCoverage gaps=" .. tostring(#gaps) .. " first_key=" .. tostring(first and first.key or "none") .. " missing_count=" .. tostring(missing))
end

--@api: lurek.i18n.getLoadedLocales
do

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
    lurek.i18n.loadTable("runtime_ui", { menu = { credits = "Credits" } })
    local locales = lurek.i18n.getLoadedLocales()
    local has_ar = false
    for _, value in ipairs(locales or {}) do
        if value == "ar" then
            has_ar = true
        end
    end
    local has_runtime = false
    for _, value in ipairs(locales or {}) do
        if value == "runtime_ui" then
            has_runtime = true
        end
    end
    lurek.log.info("getLoadedLocales count=" .. tostring(#locales) .. " has_ar=" .. tostring(has_ar) .. " has_runtime=" .. tostring(has_runtime))
end
