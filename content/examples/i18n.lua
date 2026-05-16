-- content/examples/i18n.lua
-- Demonstrates the lurek.i18n localization API: loading translations, switching locales, formatting, and search.
-- Run: cargo run -- content/examples/i18n.lua

--@api-stub: lurek.i18n.loadTable
-- Loads translations for a locale from a nested Lua table flattened with dot-separated keys
do
  -- Tables nest naturally; the engine flattens them into dot-separated keys
  -- e.g. { ui = { start = "Start" } } becomes "ui.start" = "Start"
  lurek.i18n.loadTable("en", {
    ui = { start = "Start Game", quit = "Quit", settings = "Settings" },
    hud = {
      score = "Score: {n}",
      lives = { one = "1 life left", other = "{count} lives left" },
    },
    dialog = { npc_greet = "Hello, adventurer!" },
  })
  lurek.i18n.loadTable("pl", {
    ui = { start = "Nowa Gra", quit = "Wyjdź", settings = "Ustawienia" },
    hud = {
      score = "Wynik: {n}",
      lives = { one = "1 życie", other = "{count} żyć" },
    },
    dialog = { npc_greet = "Witaj, poszukiwaczu przygód!" },
  })
end

--@api-stub: lurek.i18n.loadString
-- Loads translations for a locale from TOML or JSON source text
do
  -- Use TOML when shipping translation files alongside the game
  local toml_src = [[
[ui]
ok     = "OK"
cancel = "Cancel"
apply  = "Apply Changes"

[item]
sword  = "Iron Sword"
shield = "Oak Shield"
potion = "Health Potion"
]]
  lurek.i18n.loadString("en_items", toml_src, "toml")
  lurek.i18n.setLanguage("en_items")
  -- Verify the keys are accessible after TOML parse
  lurek.log.info("item.sword = " .. lurek.i18n.t("item.sword"), "i18n")
  lurek.log.info("ui.apply = " .. lurek.i18n.t("ui.apply"), "i18n")
end

--@api-stub: lurek.i18n.unloadTable
-- Removes all translations for a locale from the catalog
do
  -- Load a temporary locale for testing, then clean up
  lurek.i18n.loadTable("tmp", { test = { msg = "Temporary" } })
  local removed = lurek.i18n.unloadTable("tmp")
  -- Returns true if the locale existed and was removed
  lurek.log.info("tmp locale removed = " .. tostring(removed), "i18n")
  -- Attempting to unload a non-existent locale returns false
  local noop = lurek.i18n.unloadTable("nonexistent")
  lurek.log.info("nonexistent removed = " .. tostring(noop), "i18n")
end

--@api-stub: lurek.i18n.mergeLocale
-- Merges flat translation entries into an existing locale
do
  -- Use mergeLocale to add DLC or mod translations without replacing the base table
  lurek.i18n.loadTable("en", { ui = { start = "Start" } })
  lurek.i18n.mergeLocale("en", {
    ["dialog.intro"] = "Welcome, traveller.",
    ["dialog.outro"] = "Farewell, until next time.",
    ["quest.fetch"] = "Bring me {count} {item}.",
  })
  lurek.i18n.setLanguage("en")
  -- Original keys still work after merge
  lurek.log.info("ui.start = " .. lurek.i18n.t("ui.start"), "i18n")
  -- New keys from merge are accessible
  lurek.log.info("dialog.intro = " .. lurek.i18n.t("dialog.intro"), "i18n")
end

--@api-stub: lurek.i18n.setLanguage
-- Sets the active locale and invokes registered change callbacks with new and old locale values
do
  -- Switching locale immediately changes what t() returns
  lurek.i18n.loadTable("en", { menu = { play = "Play" } })
  lurek.i18n.loadTable("fr", { menu = { play = "Jouer" } })
  lurek.i18n.setLanguage("en")
  lurek.log.info("before switch: " .. lurek.i18n.t("menu.play"), "i18n")
  lurek.i18n.setLanguage("fr")
  lurek.log.info("after switch: " .. lurek.i18n.t("menu.play"), "i18n")
end

--@api-stub: lurek.i18n.getLanguage
-- Returns the active locale code
do
  lurek.i18n.loadTable("en", { ui = { ok = "OK" } })
  lurek.i18n.setLanguage("en")
  -- Use getLanguage to display the active locale in a settings menu
  local active = lurek.i18n.getLanguage()
  if active then
    lurek.log.info("Settings menu showing locale: " .. active, "i18n")
  end
end

--@api-stub: lurek.i18n.getLanguages
-- Returns sorted locale codes currently loaded in the catalog
do
  lurek.i18n.loadTable("en", { a = "a" })
  lurek.i18n.loadTable("de", { a = "a" })
  lurek.i18n.loadTable("fr", { a = "a" })
  -- Use to populate a language picker dropdown
  local langs = lurek.i18n.getLanguages()
  for i, code in ipairs(langs) do
    lurek.log.info("picker slot " .. i .. " = " .. code, "i18n")
  end
end

--@api-stub: lurek.i18n.getAvailableLanguages
-- Returns sorted locale codes currently loaded in the catalog
do
  -- Alias for getLanguages — both return the same sorted list
  local langs = lurek.i18n.getAvailableLanguages()
  lurek.log.info("total available locales: " .. #langs, "i18n")
end

--@api-stub: lurek.i18n.getLoadedLocales
-- Returns locale codes currently loaded in the catalog
do
  lurek.i18n.loadTable("en", { ui = { ok = "OK" } })
  lurek.i18n.loadTable("ja", { ui = { ok = "はい" } })
  -- Use when building a language options screen
  local locales = lurek.i18n.getLoadedLocales()
  lurek.log.info("loaded locale count = " .. #locales, "i18n")
end

--@api-stub: lurek.i18n.hasLanguage
-- Returns whether a locale has translations loaded
do
  lurek.i18n.loadTable("en", { ui = { ok = "OK" } })
  -- Guard before switching to avoid runtime errors
  if lurek.i18n.hasLanguage("en") then
    lurek.i18n.setLanguage("en")
    lurek.log.info("switched to en", "i18n")
  end
  if not lurek.i18n.hasLanguage("ko") then
    lurek.log.info("Korean not loaded — skipping", "i18n")
  end
end

--@api-stub: lurek.i18n.validateLocale
-- Returns whether a locale code has a valid syntax
do
  -- Validate user input from a locale-code text field before using it
  local user_input_good = "en-US"
  local user_input_bad = "123invalid"
  lurek.log.info(user_input_good .. " valid = " .. tostring(lurek.i18n.validateLocale(user_input_good)), "i18n")
  lurek.log.info(user_input_bad .. " valid = " .. tostring(lurek.i18n.validateLocale(user_input_bad)), "i18n")
  -- Empty string is also invalid
  lurek.log.info("empty valid = " .. tostring(lurek.i18n.validateLocale("")), "i18n")
end

--@api-stub: lurek.i18n.detectLocale
-- Detects the system locale when available
do
  -- Use at startup to auto-select the player's preferred locale
  local detected = lurek.i18n.detectLocale()
  if detected then
    lurek.log.info("system locale detected: " .. detected, "i18n")
    -- In a real game: if lurek.i18n.hasLanguage(detected) then lurek.i18n.setLanguage(detected) end
  else
    lurek.log.info("no system locale detected — using default", "i18n")
  end
end

--@api-stub: lurek.i18n.setBase
-- Sets the base locale string stored by the localization module
do
  -- setBase marks the "source of truth" locale for coverage checks
  lurek.i18n.setBase("en")
  lurek.log.info("base locale set to 'en'", "i18n")
end

--@api-stub: lurek.i18n.getBase
-- Returns the base locale string stored by the localization module
do
  lurek.i18n.setBase("en")
  local base = lurek.i18n.getBase()
  if base ~= "" then
    lurek.log.info("base locale for coverage analysis: " .. base, "i18n")
  end
end

--@api-stub: lurek.i18n.setFallbacks
-- Replaces the fallback locale list used for missing translations
do
  -- Fallback chain: if a key is missing in "en-GB", try "en-US", then "en"
  lurek.i18n.loadTable("en", { ui = { quit = "Quit" } })
  lurek.i18n.loadTable("en-US", { ui = { color = "Color" } })
  lurek.i18n.setFallbacks({ "en-US", "en" })
  -- Now any missing key in the active locale will try en-US first, then en
  lurek.log.info("fallback chain set: en-US -> en", "i18n")
end

--@api-stub: lurek.i18n.getFallbacks
-- Returns fallback locale codes in lookup order
do
  lurek.i18n.setFallbacks({ "en-US", "en" })
  local chain = lurek.i18n.getFallbacks()
  -- Display the fallback chain in a debug overlay
  lurek.log.info("fallback chain: " .. table.concat(chain, " -> "), "i18n")
end

--@api-stub: lurek.i18n.t
-- Translates a key using the active locale, optional variables, and optional English plural selection
do
  lurek.i18n.loadTable("en", {
    hud = {
      score = "Score: {n}",
      lives = { one = "1 life left", other = "{count} lives left" },
      player = "{name} — Level {level}",
    },
  })
  lurek.i18n.setLanguage("en")
  -- Simple variable interpolation
  local score_text = lurek.i18n.t("hud.score", { n = "2500" })
  lurek.log.info(score_text, "i18n")
  -- Plural selection: pass count as third argument
  -- count=1 picks "one", count>1 picks "other", {count} is auto-inserted
  local lives_one = lurek.i18n.t("hud.lives", nil, 1)
  local lives_many = lurek.i18n.t("hud.lives", nil, 5)
  lurek.log.info(lives_one .. " / " .. lives_many, "i18n")
  -- Multiple variables in one translation
  local player_hud = lurek.i18n.t("hud.player", { name = "Kira", level = "12" })
  lurek.log.info(player_hud, "i18n")
end

--@api-stub: lurek.i18n.tGender
-- Translates a gender-specific key variant when present, then falls back to the base key
do
  lurek.i18n.loadTable("en", {
    npc = {
      greet = {
        masculine = "He extends a hand.",
        feminine = "She extends a hand.",
        neutral = "They extend a hand.",
      },
    },
  })
  lurek.i18n.setLanguage("en")
  -- Select gender variant based on NPC data
  local npc_gender = "feminine"
  local greeting = lurek.i18n.tGender("npc.greet", npc_gender)
  lurek.log.info("NPC says: " .. greeting, "i18n")
  -- If gender key is missing, falls back to the base key value
end

--@api-stub: lurek.i18n.interpolate
-- Replaces `{name}` placeholders in a template using string variables
do
  -- Use interpolate for dynamic strings that are not in the catalog
  -- (e.g., debug messages, runtime-generated text)
  local template = "Player {name} found {item} in {area}"
  local msg = lurek.i18n.interpolate(template, {
    name = "Aria",
    item = "Golden Key",
    area = "Dark Cavern",
  })
  lurek.log.info(msg, "i18n")
end

--@api-stub: lurek.i18n.pluralFor
-- Returns the English plural category key for a number
do
  -- Use pluralFor to manually select plural forms in custom logic
  local test_counts = { 0, 1, 2, 12, 100 }
  for _, n in ipairs(test_counts) do
    local category = lurek.i18n.pluralFor(n)
    -- Returns "one" for 1, "other" for everything else (English rules)
    lurek.log.info("count=" .. n .. " -> category='" .. category .. "'", "i18n")
  end
end

--@api-stub: lurek.i18n.hasKey
-- Returns whether the catalog contains a translation key in active or fallback locales
do
  lurek.i18n.loadTable("en", { ui = { start = "Start", quit = "Quit" } })
  lurek.i18n.setLanguage("en")
  -- Use hasKey to conditionally show UI elements that have translations
  local keys_to_check = { "ui.start", "ui.credits", "ui.quit", "ui.multiplayer" }
  for _, key in ipairs(keys_to_check) do
    if lurek.i18n.hasKey(key) then
      lurek.log.info("show button: " .. lurek.i18n.t(key), "i18n")
    else
      lurek.log.warn("missing translation for: " .. key, "i18n")
    end
  end
end

--@api-stub: lurek.i18n.getKeys
-- Returns sorted translation keys known to the catalog
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start", quit = "Quit" },
    hud = { health = "HP", mana = "MP" },
  })
  lurek.i18n.setLanguage("en")
  -- Use getKeys to build a translation editor or debug listing
  local all_keys = lurek.i18n.getKeys()
  lurek.log.info("total keys in catalog: " .. #all_keys, "i18n")
  for _, key in ipairs(all_keys) do
    lurek.log.info("  " .. key .. " = " .. lurek.i18n.t(key), "i18n")
  end
end

--@api-stub: lurek.i18n.setKey
-- Sets one translation value for one locale and key
do
  -- Use setKey for runtime patches, mod support, or player-defined labels
  lurek.i18n.loadTable("en", { ui = { start = "Start" } })
  lurek.i18n.setLanguage("en")
  -- A mod adds a new menu entry at runtime
  lurek.i18n.setKey("en", "ui.mod_menu", "Mod Settings")
  lurek.i18n.setKey("en", "ui.mod_reload", "Reload Mods")
  lurek.log.info(lurek.i18n.t("ui.mod_menu"), "i18n")
  lurek.log.info(lurek.i18n.t("ui.mod_reload"), "i18n")
end

--@api-stub: lurek.i18n.keyCount
-- Returns the number of translation keys known to the catalog
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start", quit = "Quit", settings = "Settings" },
    hud = { score = "Score" },
  })
  lurek.i18n.setLanguage("en")
  -- Display key count in a localization progress bar
  local total = lurek.i18n.keyCount()
  lurek.log.info("translation strings to maintain: " .. total, "i18n")
end

--@api-stub: lurek.i18n.categories
-- Returns top-level translation key categories
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start" },
    hud = { score = "Score" },
    dialog = { npc1 = "Hello" },
    item = { sword = "Sword" },
  })
  lurek.i18n.setLanguage("en")
  -- Use categories to group translations in a dev tools panel
  local cats = lurek.i18n.categories()
  for _, cat in ipairs(cats) do
    lurek.log.info("category: " .. cat, "i18n")
  end
end

--@api-stub: lurek.i18n.keysInCategory
-- Returns translation keys belonging to one category prefix
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start", quit = "Quit", settings = "Settings" },
    hud = { score = "Score" },
  })
  lurek.i18n.setLanguage("en")
  -- List all keys under "ui" for the translation editor sidebar
  local ui_keys = lurek.i18n.keysInCategory("ui")
  lurek.log.info("ui section has " .. #ui_keys .. " entries:", "i18n")
  for _, key in ipairs(ui_keys) do
    lurek.log.info("  " .. key .. " = " .. lurek.i18n.t(key), "i18n")
  end
end

--@api-stub: lurek.i18n.search
-- Searches translation keys and values for a query string
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start Game", restart = "Restart Level", quit = "Quit Game" },
    dialog = { start_quest = "Start the quest?" },
  })
  lurek.i18n.setLanguage("en")
  -- Search for all entries containing "start" — useful for translation tools
  local hits = lurek.i18n.search("start", 10)
  lurek.log.info("search 'start' found " .. #hits .. " results:", "i18n")
  for _, row in ipairs(hits) do
    lurek.log.info("  " .. row.key .. " = " .. row.value, "i18n")
  end
end

--@api-stub: lurek.i18n.buildIndex
-- Builds a word-to-keys search index from the catalog
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start the game", quit = "Quit the game" },
    dialog = { intro = "Welcome to the game world" },
  })
  lurek.i18n.setLanguage("en")
  -- Build an index once, then reuse it for multiple fast searches
  local index = lurek.i18n.buildIndex()
  lurek.log.info("search index built, has entries: " .. tostring(next(index) ~= nil), "i18n")
end

--@api-stub: lurek.i18n.searchIndexed
-- Searches a prebuilt word index and returns matching keys
do
  lurek.i18n.loadTable("en", {
    ui = { start = "Start the game", quit = "Quit the game", options = "Game options" },
    help = { controls = "Game controls guide" },
  })
  lurek.i18n.setLanguage("en")
  -- Pre-build index for repeated searches (e.g., in-game search bar)
  local index = lurek.i18n.buildIndex()
  local matches = lurek.i18n.searchIndexed(index, "game", 5)
  lurek.log.info("indexed search 'game' found " .. #matches .. " keys:", "i18n")
  for _, key in ipairs(matches) do
    lurek.log.info("  " .. key, "i18n")
  end
end

--@api-stub: lurek.i18n.formatNumber
-- Formats a number with locale-aware separators and optional decimal precision
do
  -- Format game currency with locale-appropriate separators
  lurek.i18n.loadTable("de", { a = "a" })
  lurek.i18n.setLanguage("de")
  local price = lurek.i18n.formatNumber(12345.6, { decimals = 2 })
  lurek.log.info("shop price (DE format): " .. price, "i18n")
  -- No decimals for integer displays like score
  lurek.i18n.loadTable("en", { a = "a" })
  lurek.i18n.setLanguage("en")
  local score = lurek.i18n.formatNumber(1000000, { decimals = 0 })
  lurek.log.info("high score (EN format): " .. score, "i18n")
end

--@api-stub: lurek.i18n.formatDate
-- Formats a timestamp with the active locale and a named format
do
  lurek.i18n.loadTable("en", { a = "a" })
  lurek.i18n.setLanguage("en")
  -- Format a save-file timestamp for display in the load menu
  local save_time = 1700000000
  local short_date = lurek.i18n.formatDate(save_time, "short")
  local long_date = lurek.i18n.formatDate(save_time, "long")
  lurek.log.info("save slot 1: " .. short_date, "i18n")
  lurek.log.info("detailed: " .. long_date, "i18n")
end

--@api-stub: lurek.i18n.isRTL
-- Returns whether a locale is written right-to-left
do
  -- Use isRTL to flip UI layout direction for Arabic, Hebrew, etc.
  local rtl_arabic = lurek.i18n.isRTL("ar-SA")
  local ltr_english = lurek.i18n.isRTL("en-US")
  lurek.log.info("ar-SA isRTL = " .. tostring(rtl_arabic), "i18n")
  lurek.log.info("en-US isRTL = " .. tostring(ltr_english), "i18n")
  -- No argument tests the currently active locale
  local active_rtl = lurek.i18n.isRTL()
  lurek.log.info("active locale isRTL = " .. tostring(active_rtl), "i18n")
end

--@api-stub: lurek.i18n.onLanguageChange
-- Registers a callback invoked when the active locale changes
do
  -- Use to rebuild UI text, flush cached strings, or reload font atlases
  lurek.i18n.onLanguageChange(function(new_locale, old_locale)
    lurek.log.info("locale changed: " .. tostring(old_locale) .. " -> " .. new_locale, "i18n")
    -- In a real game: rebuild_all_ui_labels()
  end)
  lurek.i18n.loadTable("es", { ui = { start = "Iniciar" } })
  lurek.i18n.setLanguage("es")
end

--@api-stub: lurek.i18n.onChange
-- Registers a locale-change callback using the shorter alias name
do
  -- onChange is a shorter alias for onLanguageChange
  lurek.i18n.onChange(function(new_locale, _old)
    lurek.log.info("UI rebuild triggered for: " .. new_locale, "i18n")
  end)
  lurek.i18n.loadTable("it", { ui = { start = "Inizia" } })
  lurek.i18n.setLanguage("it")
end

--@api-stub: lurek.i18n.offChange
-- Removes every registered locale-change callback
do
  -- Register a temporary handler, then clean up
  lurek.i18n.onChange(function() end)
  -- Call offChange when tearing down a screen that no longer needs updates
  lurek.i18n.offChange()
  lurek.log.info("all locale-change handlers cleared", "i18n")
end

--@api-stub: lurek.i18n.localeCoverage
-- Returns missing translation keys for all locales compared to a reference locale
do
  -- Use during development to find untranslated strings
  lurek.i18n.loadTable("cov_en", { hello = "Hello", bye = "Goodbye", ok = "OK" })
  lurek.i18n.loadTable("cov_fr", { hello = "Bonjour", ok = "OK" })  -- 'bye' missing
  lurek.i18n.loadTable("cov_de", { hello = "Hallo", bye = "Tschüss" }) -- 'ok' missing
  local gaps = lurek.i18n.localeCoverage("cov_en")
  -- Each gap has .key (the missing key) and .missing_in (array of locales)
  for _, gap in ipairs(gaps) do
    lurek.log.warn(("MISSING '%s' in: %s"):format(
      gap.key, table.concat(gap.missing_in, ", ")), "i18n")
  end
end

print("content/examples/i18n.lua")
