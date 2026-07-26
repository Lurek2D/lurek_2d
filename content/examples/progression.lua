-- content/examples/progression.lua
-- Run: cargo run -- content/examples/progression.lua

--- Progression Module: store-based offline progression state

--@api: lurek.progression.newStore
do
    local store = lurek.progression.newStore({
        id = "example_store",
        clock = "manual",
        event_capacity = 32,
        max_profiles = 16,
        strict = true,
    })
    local stats = store:stats()
    local snapshot = store:debugSnapshot()
    lurek.log.info("newStore id=" .. tostring(store:getId()) .. " revision=" .. tostring(store:getRevision()) .. " profiles=" .. tostring(stats.profiles) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api: lurek.progression.importLegacyStatsSnapshot
do
    local converted = lurek.progression.importLegacyStatsSnapshot({
        xp = 120,
        level = 2,
        attributes = {
            strength = { base = 10 },
            agility = { base = 8 },
        },
    })
    lurek.log.info("importLegacyStatsSnapshot attrs=" .. tostring(#converted.attributes) .. " xp=" .. tostring(converted.experience.experience) .. " level=" .. tostring(converted.experience.level))
end

--@api: lurek.progression.importLegacyQuestSnapshot
do
    local converted = lurek.progression.importLegacyQuestSnapshot({
        quests = {
            { id = "rat_hunt", title = "Rat Hunt", status = "active" },
            { id = "cleanup", title = "Cleanup", status = "completed" },
        },
    })
    lurek.log.info("importLegacyQuestSnapshot quests=" .. tostring(#converted.quests) .. " first=" .. tostring(converted.quests[1] and converted.quests[1].id))
end

--@api: LProgressionStore:createProfile
do
    local store = lurek.progression.newStore({ id = "profile_example" })
    local profile = store:createProfile("player", {
        kind = "human",
        display_name = "Mira",
        tags = { "local", "campaign_a" },
        metadata = { country = "PL", runs = 3 },
    })
    local snapshot = store:getProfile("player")
    lurek.log.info("createProfile id=" .. tostring(profile:getId()) .. " name=" .. tostring(snapshot.display_name) .. " tags=" .. tostring(#snapshot.tags))
end

--@api: LProgressionStore:defineCounter
do
    local store = lurek.progression.newStore({ id = "counter_example" })
    local player = store:createProfile("player")
    store:defineCounter("rats_killed", {
        kind = "cumulative_integer",
        initial = 0,
        min = 0,
        monotonic = true,
        thresholds = { 3, 5 },
    })
    local after_add = store:addCounter(player, "rats_killed", 4)
    local counter = store:getCounterState("player", "rats_killed")
    lurek.log.info("defineCounter value=" .. tostring(after_add) .. " snapshot=" .. tostring(counter.value))
end

--@api: LProgressionStore:compileCondition
do
    local store = lurek.progression.newStore({ id = "condition_example" })
    local player = store:createProfile("player", { tags = { "hero" } })
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    local condition = {
        all = {
            { tag = "hero" },
            { counter = "wins", op = ">=", value = 2 },
        },
    }
    local compiled = store:compileCondition(condition)
    store:addCounter(player, "wins", 2)
    local ok = store:evaluateCondition("player", condition)
    local explanation = store:explainCondition(player, condition)
    lurek.log.info("compileCondition kind=" .. tostring(compiled.kind) .. " ok=" .. tostring(ok) .. " children=" .. tostring(#explanation.children))
end

--@api: LProgressionStore:defineDerivedValue
do
    local store = lurek.progression.newStore({ id = "derived_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    store:addCounter(player, "wins", 3)
    store:setAttributeBase("player", "strength", 12)
    store:addResource("player", "stamina", -2)
    store:addExperience("player", "character_xp", 180)
    store:defineDerivedValue("combat_rating", {
        expression = "round((wins * 5 + strength + stamina + level) / 2)",
        inputs = {
            wins = { kind = "counter", counter_id = "wins" },
            strength = { kind = "attribute", attribute_id = "strength", mode = "effective" },
            stamina = { kind = "resource", resource_id = "stamina" },
            level = { kind = "level", track_id = "character_xp" },
        },
        min = 0,
    })
    local value = store:getDerivedValue(player, "combat_rating")
    local explanation = store:explainDerivedValue("player", "combat_rating")
    lurek.log.info("defineDerivedValue value=" .. tostring(value) .. " wins=" .. tostring(explanation.inputs.wins))
end

--@api: LProgressionStore:defineProfileTemplate
do
    local store = lurek.progression.newStore({ id = "template_example" })
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:defineResource("stamina", { initial = 2, min = 0, max = 10, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    store:defineProfileTemplate("veteran_scout", {
        kind = "scout",
        counters = { wins = 4 },
        attributes = { strength = 14 },
        resources = { stamina = 7 },
        experience = { character_xp = 180 },
        tags = { "veteran" },
        metadata = { origin = "frontier" },
    })
    store:createProfile("player", { display_name = "Mira", template = "veteran_scout" })
    local snapshot = store:getProfile("player")
    lurek.log.info("defineProfileTemplate kind=" .. tostring(snapshot.kind) .. " origin=" .. tostring(snapshot.metadata.origin) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end

--@api: LProgressionStore:defineTrait
do
    local store = lurek.progression.newStore({ id = "trait_perk_example" })
    store:createProfile("player")
    store:defineAttribute("hp", { base = 100, min = 0, max = 999 })
    store:defineLevelTrack("__legacy_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 100 },
        carry_over = true,
    })
    store:defineTrait("tough", {
        modifiers = {
            { target_id = "hp", value = 20, layer = "final_add" },
        },
    })
    store:definePerk("iron_skin", {
        require_level = 3,
        track_id = "__legacy_xp",
        trait_ids = { "tough" },
    })
    store:applyTrait("player", "tough")
    store:removeTrait("player", "tough")
    store:setLevel("player", "__legacy_xp", 3)
    store:acquirePerk("player", "iron_skin")
    lurek.log.info("defineTrait hp=" .. tostring(store:getAttribute("player", "hp", "effective")) .. " has_perk=" .. tostring(store:hasPerk("player", "iron_skin")))
end

--@api: LProgressionStore:defineSkill
do
    local store = lurek.progression.newStore({ id = "skill_example" })
    store:createProfile("player")
    store:defineAttribute("mana", { base = 100, min = 0, max = 100 })
    store:setAttributeBase("player", "mana", 100)
    store:defineSkill("heal", {
        max_level = 5,
        resource = "mana",
        cost = 30,
        cooldown = 5,
    })
    store:learnSkill("player", "heal")
    local used = store:useSkill("player", "heal")
    store:update(3)
    lurek.log.info("defineSkill ok=" .. tostring(used.ok) .. " mana=" .. tostring(store:getAttribute("player", "mana", "base")) .. " cooldown=" .. tostring(store:getSkillCooldown("player", "heal")))
end

--@api: LProgressionStore:defineLeaderboard
do
    local store = lurek.progression.newStore({ id = "leaderboard_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:createProfile("gamma")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", {
        title = "Arena",
        sort = "descending",
        rank_mode = "competition",
        max_entries = 10,
        counter_id = "wins",
    })
    store:addCounter("alpha", "wins", 5)
    store:addCounter("beta", "wins", 5)
    store:addCounter("gamma", "wins", 3)
    local top = store:listLeaderboardTop("arena", 3)
    local around = store:listLeaderboardAroundProfile("arena", "beta", 1, 1)
    local promoted = store:submitScore("gamma", "arena", 8)
    lurek.log.info("defineLeaderboard first=" .. tostring(top[1] and top[1].profile_id) .. " center=" .. tostring(around[2] and around[2].profile_id) .. " promoted_rank=" .. tostring(promoted.rank))
end

--@api: LProgressionStore:defineSeason
do
    local store = lurek.progression.newStore({ id = "season_define_example" })
    store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal", counter_id = "season_wins" })
    store:defineSeason("arena_s1", {
        starts_at = 0,
        ends_at = 100,
        reset = { leaderboards = { "arena" }, counters = { "season_wins" } },
        archive = true,
    })
    local season = store:getSeason("arena_s1")
    lurek.log.info("defineSeason id=" .. tostring(season.id) .. " archives=" .. tostring(season.archive_count) .. " resets=" .. tostring(#season.reset.counters))
end

--@api: LProgressionStore:startSeason
do
    local store = lurek.progression.newStore({ id = "season_start_example" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100 })
    local started = store:startSeason("arena_s1", { time = 5 })
    local fetched = store:getSeason("arena_s1")
    local active = store:listSeasons({ active = true })
    lurek.log.info("startSeason active=" .. tostring(started.active) .. " started_at=" .. tostring(fetched.started_at) .. " listed=" .. tostring(#active))
end

--@api: LProgressionStore:endSeason
do
    local store = lurek.progression.newStore({ id = "season_end_example" })
    store:createProfile("alpha")
    store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal", counter_id = "season_wins" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, reset = { leaderboards = { "arena" }, counters = { "season_wins" } }, archive = true })
    store:startSeason("arena_s1", { time = 0 })
    store:addCounter("alpha", "season_wins", 4)
    local ended = store:endSeason("arena_s1", { time = 100 })
    lurek.log.info("endSeason active=" .. tostring(ended.active) .. " wins=" .. tostring(store:getCounter("alpha", "season_wins")) .. " top=" .. tostring(#store:listLeaderboardTop("arena", 3)))
end

--@api: LProgressionStore:getSeason
do
    local store = lurek.progression.newStore({ id = "season_get_example" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, archive = true })
    store:startSeason("arena_s1", { time = 12 })
    local season = store:getSeason("arena_s1")
    local stats = store:stats()
    lurek.log.info("getSeason active=" .. tostring(season.active) .. " started_at=" .. tostring(season.started_at) .. " season_defs=" .. tostring(stats.seasonDefinitions))
end

--@api: LProgressionStore:listSeasons
do
    local store = lurek.progression.newStore({ id = "season_list_example" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100 })
    store:defineSeason("arena_s2", { starts_at = 100, ends_at = 200 })
    store:startSeason("arena_s1", { time = 0 })
    local active = store:listSeasons({ active = true })
    local all = store:listSeasons()
    lurek.log.info("listSeasons active=" .. tostring(#active) .. " total=" .. tostring(#all) .. " first=" .. tostring(all[1] and all[1].id))
end

--@api: LProgressionStore:getSeasonArchive
do
    local store = lurek.progression.newStore({ id = "season_archive_example" })
    store:createProfile("alpha")
    store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal", counter_id = "season_wins" })
    store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, reset = { leaderboards = { "arena" }, counters = { "season_wins" } }, archive = true })
    store:startSeason("arena_s1", { time = 0 })
    store:addCounter("alpha", "season_wins", 4)
    store:endSeason("arena_s1", { time = 100 })
    local archive = store:getSeasonArchive("arena_s1", { latest = true })
    lurek.log.info("getSeasonArchive archive=" .. tostring(archive.archive_index) .. " wins=" .. tostring(archive.snapshot.profiles.alpha.counters.season_wins.value))
end

--@api: LProgressionStore:definePrestige
do
    local store = lurek.progression.newStore({ id = "prestige_define_example" })
    local profile = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:defineCounter("campaign_kills", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:definePrestige("career", {
        condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        reset = { level_tracks = { "character_xp" }, counters = { "campaign_kills" } },
        preserve = { achievements = true, lifetime_counters = true },
    })
    local prestige = store:getPrestige(profile, "career")
    lurek.log.info("definePrestige id=" .. tostring(prestige.id) .. " resets=" .. tostring(#prestige.reset.counters) .. " keep_achievements=" .. tostring(prestige.preserve.achievements))
end

--@api: LProgressionStore:canPrestige
do
    local store = lurek.progression.newStore({ id = "prestige_can_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", { condition = { level = { track = "character_xp", op = ">=", value = 100 } } })
    local before = store:canPrestige(player, "career")
    store:setLevel("player", "character_xp", 100)
    local after = store:canPrestige("player", "career")
    lurek.log.info("canPrestige before=" .. tostring(before) .. " after=" .. tostring(after) .. " level=" .. tostring(store:getLevel("player", "character_xp")))
end

--@api: LProgressionStore:applyPrestige
do
    local store = lurek.progression.newStore({ id = "prestige_apply_example" })
    local player = store:createProfile("player")
    store:defineCounter("campaign_kills", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", {
        condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        reset = { level_tracks = { "character_xp" }, counters = { "campaign_kills" } },
        preserve = { lifetime_counters = true },
    })
    store:setLevel(player, "character_xp", 100)
    store:addCounter("player", "campaign_kills", 42)
    local prestige = store:applyPrestige(player, "career")
    lurek.log.info("applyPrestige count=" .. tostring(prestige.count) .. " kills=" .. tostring(store:getCounter("player", "campaign_kills")) .. " lifetime=" .. tostring(prestige.lifetime_counters.campaign_kills))
end

--@api: LProgressionStore:getPrestige
do
    local store = lurek.progression.newStore({ id = "prestige_get_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", { condition = { level = { track = "character_xp", op = ">=", value = 100 } } })
    local prestige = store:getPrestige(player, "career")
    local stats = store:stats()
    lurek.log.info("getPrestige count=" .. tostring(prestige.count) .. " available=" .. tostring(prestige.available) .. " definitions=" .. tostring(stats.prestigeDefinitions))
end

--@api: LProgressionStore:listPrestiges
do
    local store = lurek.progression.newStore({ id = "prestige_list_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", { initial_level = 1, max_level = 200, curve = { base = 100, increment = 100 }, carry_over = true })
    store:definePrestige("career", { condition = { level = { track = "character_xp", op = ">=", value = 100 } } })
    store:definePrestige("rebirth", { condition = { level = { track = "character_xp", op = ">=", value = 50 } } })
    local prestiges = store:listPrestiges(player)
    lurek.log.info("listPrestiges total=" .. tostring(#prestiges) .. " first=" .. tostring(prestiges[1] and prestiges[1].id) .. " second=" .. tostring(prestiges[2] and prestiges[2].id))
end

--@api: LProgressionStore:defineCollection
do
    local store = lurek.progression.newStore({ id = "collection_define_example" })
    local player = store:createProfile("player")
    store:defineAchievement("boss_slayer", { title = "Boss Slayer" })
    store:defineAchievement("museum_complete", { title = "Museum Complete" })
    store:defineCollection("museum", {
        title = "Museum",
        description = "Collect lore and trophies",
        meta_achievement_id = "museum_complete",
        items = {
            { id = "boss_trophy", title = "Boss Trophy", achievement_id = "boss_slayer" },
            { id = "secret_codex", title = "Secret Codex", hidden = true },
        },
    })
    local collection = store:getCollection(player, "museum")
    lurek.log.info("defineCollection items=" .. tostring(collection.total_count) .. " title=" .. tostring(collection.title) .. " complete=" .. tostring(collection.complete))
end

--@api: LProgressionStore:collectCollectionItem
do
    local store = lurek.progression.newStore({ id = "collection_collect_example" })
    local player = store:createProfile("player")
    store:defineAchievement("boss_slayer", { title = "Boss Slayer" })
    store:defineAchievement("museum_complete", { title = "Museum Complete" })
    store:defineCollection("museum", {
        title = "Museum",
        meta_achievement_id = "museum_complete",
        items = {
            { id = "boss_trophy", title = "Boss Trophy", achievement_id = "boss_slayer" },
            { id = "secret_codex", title = "Secret Codex", hidden = true },
        },
    })
    store:unlockAchievement(player, "boss_slayer")
    local collection = store:collectCollectionItem(player, "museum", "secret_codex")
    lurek.log.info("collectCollectionItem completion=" .. tostring(collection.completion) .. " meta=" .. tostring(store:getAchievement("player", "museum_complete").unlocked))
end

--@api: LProgressionStore:getCollection
do
    local store = lurek.progression.newStore({ id = "collection_get_example" })
    local player = store:createProfile("player")
    store:defineCollection("museum", {
        title = "Museum",
        items = {
            { id = "entry_a", title = "Entry A" },
            { id = "entry_b", title = "Entry B", hidden = true },
        },
    })
    local collection = store:getCollection(player, "museum")
    lurek.log.info("getCollection visible=" .. tostring(collection.items[1].title) .. " hidden=" .. tostring(collection.items[2].title) .. " completion=" .. tostring(collection.completion))
end

--@api: LProgressionStore:listCollections
do
    local store = lurek.progression.newStore({ id = "collection_list_example" })
    local player = store:createProfile("player")
    store:defineCollection("museum", { title = "Museum", items = { { id = "entry_a", title = "Entry A" } } })
    store:defineCollection("bestiary", { title = "Bestiary", items = { { id = "slime", title = "Slime" } } })
    local collections = store:listCollections(player)
    lurek.log.info("listCollections total=" .. tostring(#collections) .. " first=" .. tostring(collections[1] and collections[1].id))
end

--@api: LProgressionStore:pinRival
do
    local store = lurek.progression.newStore({ id = "rival_pin_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    local pinned = store:pinRival(player, rival, { leaderboard_id = "arena" })
    lurek.log.info("pinRival rival=" .. tostring(pinned.rival_profile_id) .. " board=" .. tostring(pinned.leaderboard_id))
end

--@api: LProgressionStore:getRival
do
    local store = lurek.progression.newStore({ id = "rival_get_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:submitScore(player, "arena", 5)
    store:submitScore(rival, "arena", 6)
    store:pinRival(player, rival, { leaderboard_id = "arena" })
    local snapshot = store:getRival(player, rival)
    lurek.log.info("getRival rival_rank=" .. tostring(snapshot.delta.rival_rank) .. " player_rank=" .. tostring(snapshot.delta.profile_rank))
end

--@api: LProgressionStore:listRivals
do
    local store = lurek.progression.newStore({ id = "rival_list_example" })
    local player = store:createProfile("player")
    local alpha = store:createProfile("alpha")
    local beta = store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:pinRival(player, beta, { leaderboard_id = "arena" })
    store:pinRival(player, alpha, { leaderboard_id = "arena" })
    local rivals = store:listRivals(player)
    lurek.log.info("listRivals total=" .. tostring(#rivals) .. " first=" .. tostring(rivals[1] and rivals[1].rival_profile_id))
end

--@api: LProgressionStore:getRivalDelta
do
    local store = lurek.progression.newStore({ id = "rival_delta_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:submitScore(player, "arena", 5)
    store:submitScore(rival, "arena", 6)
    store:pinRival(player, rival, { leaderboard_id = "arena" })
    local delta = store:getRivalDelta(player, rival)
    lurek.log.info("getRivalDelta rank_delta=" .. tostring(delta.rank_delta) .. " score_delta=" .. tostring(delta.score_delta))
end

--@api: LProgressionStore:getActivityFeed
do
    local store = lurek.progression.newStore({ id = "activity_feed_example" })
    local player = store:createProfile("player")
    local rival = store:createProfile("rival")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:submitScore(player, "arena", 5)
    store:submitScore(rival, "arena", 6)
    store:pinRival(player, rival, { leaderboard_id = "arena" })
    store:submitScore("player", "arena", 8)
    local feed = store:getActivityFeed({
        profiles = { player, rival },
        types = { "profile_overtook_rival", "rival_overtook_profile" },
        limit = 10,
    })
    local entries = feed:listEntries()
    lurek.log.info("getActivityFeed total=" .. tostring(feed:count()) .. " last=" .. tostring(entries[#entries] and entries[#entries]:getEventType()))
end

--@api: LProgressionStore:definePopulationTemplate
do
    local store = lurek.progression.newStore({ id = "population_define_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 3,
        identity = {
            name_generator = { mode = "parts", prefixes = { "Iron", "Silver" }, suffixes = { "Fox", "Wing" } },
            avatars = { "bots/a.png", "bots/b.png" },
            tags = { "bot", "ranked" },
        },
        archetypes = {
            { id = "steady", weight = 2, activity = { min = 1, max = 2 }, skill = { mean = 1200, deviation = 20 } },
            { id = "volatile", weight = 1, activity = { min = 2, max = 4 }, skill = { mean = 1180, deviation = 35 } },
        },
        leaderboards = {
            arena = {
                category = "ranked",
                initial_score = { distribution = "normal" },
                progression = { mode = "bounded_random_walk", volatility = 4, mean_reversion = 0.2 },
            },
        },
    })
    local report = store:validatePopulationTemplate("bots")
    lurek.log.info("definePopulationTemplate ok=" .. tostring(report.ok) .. " errors=" .. tostring(#report.errors) .. " definitions=" .. tostring(store:stats().populationTemplates))
end

--@api: LProgressionStore:validatePopulationTemplate
do
    local store = lurek.progression.newStore({ id = "population_validate_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = {
            { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } },
        },
        leaderboards = {
            arena = {
                initial_score = { distribution = "normal" },
                progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 },
            },
        },
    })
    local report = store:validatePopulationTemplate("bots")
    lurek.log.info("validatePopulationTemplate template=" .. tostring(report.template_id) .. " ok=" .. tostring(report.ok) .. " errors=" .. tostring(#report.errors))
end

--@api: LProgressionStore:generatePopulation
do
    local store = lurek.progression.newStore({ id = "population_generate_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox", "Wing" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 2 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    local population = store:generatePopulation("bots", { id = "bots_run" })
    lurek.log.info("generatePopulation id=" .. tostring(population.id) .. " active=" .. tostring(population.active_count) .. " materialized=" .. tostring(population.materialized_count))
end

--@api: LProgressionStore:getPopulation
do
    local store = lurek.progression.newStore({ id = "population_get_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local population = store:getPopulation("bots_run")
    lurek.log.info("getPopulation profiles=" .. tostring(#population.profiles) .. " paused=" .. tostring(population.paused) .. " time=" .. tostring(population.logical_time))
end

--@api: LProgressionStore:updatePopulation
do
    local store = lurek.progression.newStore({ id = "population_update_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local before = store:listPopulationProfiles("bots_run")[1]
    local report = store:updatePopulation("bots_run", 5)
    local after = store:listPopulationProfiles("bots_run")[1]
    lurek.log.info("updatePopulation dt=" .. tostring(report.dt) .. " before=" .. tostring(before.leaderboard_scores.arena) .. " after=" .. tostring(after.leaderboard_scores.arena))
end

--@api: LProgressionStore:simulatePopulationUntil
do
    local store = lurek.progression.newStore({ id = "population_until_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local report = store:simulatePopulationUntil("bots_run", 8)
    local population = store:getPopulation("bots_run")
    lurek.log.info("simulatePopulationUntil time=" .. tostring(report.logical_time) .. " paused=" .. tostring(population.paused) .. " updates=" .. tostring(report.score_updates))
end

--@api: LProgressionStore:pausePopulation
do
    local store = lurek.progression.newStore({ id = "population_pause_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local paused = store:pausePopulation("bots_run")
    local report = store:updatePopulation("bots_run", 4)
    lurek.log.info("pausePopulation paused=" .. tostring(paused.paused) .. " updated=" .. tostring(report.updated_profiles) .. " time=" .. tostring(report.logical_time))
end

--@api: LProgressionStore:resumePopulation
do
    local store = lurek.progression.newStore({ id = "population_resume_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    store:pausePopulation("bots_run")
    local resumed = store:resumePopulation("bots_run")
    local report = store:updatePopulation("bots_run", 2)
    lurek.log.info("resumePopulation paused=" .. tostring(resumed.paused) .. " updated=" .. tostring(report.updated_profiles) .. " time=" .. tostring(report.logical_time))
end

--@api: LProgressionStore:removePopulation
do
    local store = lurek.progression.newStore({ id = "population_remove_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local removed = store:removePopulation("bots_run")
    local stats = store:stats()
    lurek.log.info("removePopulation removed=" .. tostring(removed) .. " populations=" .. tostring(stats.populations) .. " templates=" .. tostring(stats.populationTemplates))
end

--@api: LProgressionStore:regeneratePopulation
do
    local store = lurek.progression.newStore({ id = "population_regenerate_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    store:updatePopulation("bots_run", 4)
    local regenerated = store:regeneratePopulation("bots_run")
    lurek.log.info("regeneratePopulation time=" .. tostring(regenerated.logical_time) .. " generated=" .. tostring(regenerated.generated_count) .. " paused=" .. tostring(regenerated.paused))
end

--@api: LProgressionStore:getPopulationStatistics
do
    local store = lurek.progression.newStore({ id = "population_stats_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local stats = store:getPopulationStatistics("bots_run", { leaderboard_id = "arena" })
    lurek.log.info("getPopulationStatistics count=" .. tostring(stats.leaderboards.arena.count) .. " min=" .. tostring(stats.leaderboards.arena.min) .. " max=" .. tostring(stats.leaderboards.arena.max))
end

--@api: LProgressionStore:listPopulationProfiles
do
    local store = lurek.progression.newStore({ id = "population_list_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local profiles = store:listPopulationProfiles("bots_run", { limit = 1 })
    lurek.log.info("listPopulationProfiles count=" .. tostring(#profiles) .. " first=" .. tostring(profiles[1] and profiles[1].profile_id) .. " population=" .. tostring(profiles[1] and profiles[1].population_id))
end

--@api: LProgressionStore:materializePopulationProfile
do
    local store = lurek.progression.newStore({ id = "population_materialize_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local virtual_profile = store:listPopulationProfiles("bots_run")[1]
    local materialized = store:materializePopulationProfile(virtual_profile.profile_id)
    lurek.log.info("materializePopulationProfile id=" .. tostring(materialized.id) .. " exists=" .. tostring(store:hasProfile(virtual_profile.profile_id)) .. " kind=" .. tostring(materialized.kind))
end

--@api: LProgressionStore:dematerializePopulationProfile
do
    local store = lurek.progression.newStore({ id = "population_dematerialize_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
        archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bots_run" })
    local virtual_profile = store:listPopulationProfiles("bots_run")[1]
    store:materializePopulationProfile(virtual_profile.profile_id)
    local changed = store:dematerializePopulationProfile(virtual_profile.profile_id, { remove_profile = true })
    local remaining = store:listPopulationProfiles("bots_run", { materialized = false })
    lurek.log.info("dematerializePopulationProfile changed=" .. tostring(changed) .. " has_profile=" .. tostring(store:hasProfile(virtual_profile.profile_id)) .. " visible=" .. tostring(#remaining))
end

--@api: LProgressionStore:defineAttribute
do
    local store = lurek.progression.newStore({ id = "attribute_example" })
    local player = store:createProfile("player")
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:setAttributeBase(player, "strength", 12)
    local modifier = store:addModifier(player, "strength", { value = 3, layer = "final_add", duration = 30 })
    local effective = store:getAttribute(player, "strength", "effective")
    local explanation = store:explainAttribute("player", "strength")
    lurek.log.info("defineAttribute mod=" .. tostring(modifier) .. " effective=" .. tostring(effective) .. " delta=" .. tostring(explanation.modifier_total))
end

--@api: LProgressionStore:defineResource
do
    local store = lurek.progression.newStore({ id = "resource_example" })
    local player = store:createProfile("player")
    store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
    local spent = store:spendResource(player, "stamina", 2)
    local resource = store:getResource("player", "stamina")
    local refilled = store:refillResource(player, "stamina")
    lurek.log.info("defineResource spent=" .. tostring(spent) .. " value=" .. tostring(resource.value) .. " refilled=" .. tostring(refilled))
end

--@api: LProgressionStore:defineLevelTrack
do
    local store = lurek.progression.newStore({ id = "level_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
        allow_level_down = false,
    })
    local xp = store:addExperience(player, "character_xp", 180)
    local to_next = store:getExperienceToNextLevel("player", "character_xp")
    lurek.log.info("defineLevelTrack level=" .. tostring(xp.level) .. " xp=" .. tostring(xp.experience) .. " to_next=" .. tostring(to_next))
end

--@api: LProgressionStore:defineQuest
do
    local store = lurek.progression.newStore({ id = "quest_example" })
    local player = store:createProfile("player", { tags = { "hero" } })
    store:defineCounter("rats_killed", {
        kind = "cumulative_integer",
        initial = 0,
        min = 0,
        monotonic = true,
    })
    store:defineQuest("rat_hunt", {
        title = "Rat Hunt",
        reveal_condition = {
            tag = "hero",
        },
        availability_condition = {
            tag = "hero",
        },
        reward_payload = {
            currency = 50,
        },
        stages = {
            {
                id = "stage_1",
                name = "Cull",
                objectives = {
                    { id = "kills", description = "Defeat three rats", required = 3, mandatory = true, counter_id = "rats_killed" },
                },
            },
        },
    })
    store:acceptQuest(player, "rat_hunt")
    store:addCounter(player, "rats_killed", 3)
    local quest = store:getQuestState("player", "rat_hunt")
    local rewards = player:getPendingRewards()
    lurek.log.info("defineQuest status=" .. tostring(quest.status) .. " stage=" .. tostring(quest.current_stage_index) .. " rewards=" .. tostring(#rewards))
end

--@api: LProgressionStore:revealQuest
do
    local store = lurek.progression.newStore({ id = "quest_lifecycle_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineQuest("arena", {
        title = "Arena",
        reveal_condition = {
            counter = "wins",
            op = ">=",
            value = 1,
        },
        availability_condition = {
            counter = "wins",
            op = ">=",
            value = 2,
        },
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    local hidden = store:getQuestState("player", "arena")
    store:addCounter(player, "wins", 1)
    local revealed = store:getQuestState(player, "arena")
    store:addCounter("player", "wins", 1)
    local available = store:getQuestState("player", "arena")
    lurek.log.info("revealQuest hidden=" .. tostring(hidden.status) .. " revealed=" .. tostring(revealed.status) .. " available=" .. tostring(available.status))
end

--@api: LQuestState:getJournal
do
    local store = lurek.progression.newStore({ id = "quest_journal_example" })
    local player = store:createProfile("player")
    store:defineQuest("journaled", {
        title = "Journaled",
        max_journal_entries = 2,
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    store:acceptQuest(player, "journaled")
    local state = store:getQuestState("player", "journaled")
    local journal = state:getJournal()
    journal:addEntry("Found clue", "discover")
    journal:addEntry("Opened door", "progress")
    local entry = journal:addEntry("Reached boss")
    lurek.log.info("LQuestState:getJournal quest=" .. tostring(journal:getQuestId()) .. " kept=" .. tostring(journal:count()) .. " last=" .. tostring(entry:getText()))
end

--@api: LProgressionStore:setQuestObjectiveStatus
do
    local store = lurek.progression.newStore({ id = "quest_objective_controls_example" })
    local player = store:createProfile("player")
    store:defineQuest("stealth", {
        title = "Stealth",
        stages = {
            {
                id = "stage_1",
                name = "Stage",
                objectives = {
                    { id = "required", description = "Required", required = 1, mandatory = true, visible = false },
                    { id = "optional", description = "Optional", required = 1, mandatory = false, visible = true },
                },
            },
        },
    })
    store:acceptQuest(player, "stealth")
    local before = store:getQuestState("player", "stealth")
    store:setQuestObjectiveVisibility(player, "stealth", "required", true)
    local after = store:setQuestObjectiveStatus("player", "stealth", "required", "skipped")
    lurek.log.info("setQuestObjectiveStatus before_visible=" .. tostring(before.objectives[1].visible) .. " final=" .. tostring(after.status))
end

--@api: LProgressionStore:defineChallengeTemplate
do
    local store = lurek.progression.newStore({ id = "challenge_define_example" })
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        description = "Win three matches",
        required = 3,
        counter_id = "wins",
        tags = { "daily" },
        reward_payload = { currency = 25 },
    })
    store:createProfile("player")
    local challenge = store:getChallenge("player", "win_streak")
    lurek.log.info("defineChallengeTemplate id=" .. tostring(challenge.id) .. " status=" .. tostring(challenge.status) .. " tag=" .. tostring(challenge.tags[1]))
end

--@api: LProgressionStore:activateChallenge
do
    local store = lurek.progression.newStore({ id = "challenge_activate_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        required = 3,
        counter_id = "wins",
        reward_payload = { currency = 25 },
    })
    local started = store:activateChallenge(player, "win_streak")
    lurek.log.info("activateChallenge status=" .. tostring(started.status) .. " current=" .. tostring(started.current))
end

--@api: LProgressionStore:setChallengeProgress
do
    local store = lurek.progression.newStore({ id = "challenge_progress_example" })
    local player = store:createProfile("player")
    store:defineChallengeTemplate("timed_route", {
        title = "Timed Route",
        required = 2,
        duration = 10,
        repeatable = true,
    })
    store:activateChallenge(player, "timed_route", { time = 0 })
    local progress = store:setChallengeProgress("player", "timed_route", 1)
    lurek.log.info("setChallengeProgress status=" .. tostring(progress.status) .. " completion=" .. tostring(progress.completion))
end

--@api: LProgressionStore:getChallenge
do
    local store = lurek.progression.newStore({ id = "challenge_get_example" })
    local player = store:createProfile("player")
    store:defineChallengeTemplate("timed_route", {
        title = "Timed Route",
        required = 1,
        duration = 5,
        repeatable = true,
    })
    store:activateChallenge(player, "timed_route", { time = 0 })
    store:advanceTime(6)
    local challenge = store:getChallenge("player", "timed_route")
    lurek.log.info("getChallenge status=" .. tostring(challenge.status) .. " expires_in=" .. tostring(challenge.expires_in))
end

--@api: LProgressionStore:listChallenges
do
    local store = lurek.progression.newStore({ id = "challenge_list_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        required = 1,
        counter_id = "wins",
    })
    store:defineChallengeTemplate("timed_route", {
        title = "Timed Route",
        required = 1,
        duration = 2,
        repeatable = true,
    })
    store:activateChallenge(player, "win_streak")
    store:activateChallenge(player, "timed_route", { time = 0 })
    store:addCounter("player", "wins", 1)
    store:advanceTime(3)
    local completed = store:listChallenges(player, { status = "completed" })
    local expired = store:listChallenges("player", { status = "expired" })
    lurek.log.info("listChallenges completed=" .. tostring(#completed) .. " expired=" .. tostring(#expired))
end

--@api: LProgressionStore:defineAchievement
do
    local store = lurek.progression.newStore({ id = "achievement_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", {
        kind = "cumulative_integer",
        initial = 0,
        min = 0,
        monotonic = true,
    })
    store:defineAchievement("first_win", {
        title = "First Win",
        description = "Win one match",
        counter_trigger = {
            counter_id = "wins",
            op = ">=",
            value = 1,
        },
        reward_payload = {
            currency = 100,
        },
    })
    store:addCounter(player, "wins", 1)
    local achievement = store:getAchievement("player", "first_win")
    local rewards = player:getPendingRewards()
    lurek.log.info("defineAchievement unlocked=" .. tostring(achievement.unlocked) .. " rewards=" .. tostring(#rewards))
end

--@api: LProgressionStore:unlockAchievement
do
    local store = lurek.progression.newStore({ id = "reward_flow_example" })
    local player = store:createProfile("player", { tags = { "hero" } })
    store:defineAchievement("manual_reward", {
        title = "Manual Reward",
        condition = {
            tag = "hero",
        },
        repeatable = true,
        reward_payload = {
            items = { "token" },
        },
    })
    local achievement = store:unlockAchievement(player, "manual_reward")
    local reward_id = "achievement:manual_reward:" .. tostring(achievement.unlock_count)
    local claimed = player:getPendingRewards()[1]:claim()
    local applied = claimed:markApplied("receipt-1")
    lurek.log.info("unlockAchievement reward=" .. tostring(reward_id) .. " state=" .. tostring(applied:getState()))
end

--@api: LProgressionStore:beginTransaction
do
    local store = lurek.progression.newStore({ id = "transaction_example" })
    local player = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    local tx = store:beginTransaction({ id = "match_1" })
    tx:addCounter(player, "wins", 1)
    tx:setResource("player", "focus", 2)
    local summary = tx:commit()
    lurek.log.info("beginTransaction revision=" .. tostring(summary.revision) .. " changes=" .. tostring(summary.changes) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end

--@api: lurek.progression.loadStore
do
    local original = lurek.progression.newStore({ id = "snapshot_source" })
    original:createProfile("player", { display_name = "Snapshot Hero" })
    local snapshot = original:exportSnapshot()
    local restored = lurek.progression.loadStore(snapshot)
    lurek.log.info("loadStore id=" .. tostring(restored:getId()) .. " hash=" .. tostring(restored:getDefinitionHash()) .. " profiles=" .. tostring(restored:countProfiles()))
end

--@api: LProgressionStore:exportChangesSince
do
    local source = lurek.progression.newStore({ id = "changes_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 3)
    local changes = source:exportChangesSince(0)
    local target = lurek.progression.newStore({ id = "changes_target" })
    local applied = target:applyChangeset(changes)
    lurek.log.info("exportChangesSince applied=" .. tostring(applied.applied) .. " wins=" .. tostring(target:getCounter("player", "wins")))
end

--@api: LProgressionStore:exportChangeset
do
    local source = lurek.progression.newStore({ id = "changeset_export_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 2)
    source:addCounter(profile, "wins", 3)
    local envelope = lurek.serialize.fromJson(source:exportChangeset(0, { max_records = 2 }))
    lurek.log.info("exportChangeset truncated=" .. tostring(envelope.truncated) .. " count=" .. tostring(#envelope.records) .. " to=" .. tostring(envelope.to_revision))
end

--@api: LProgressionStore:setQuestObjective
do
    local source = lurek.progression.newStore({ id = "changeset_apply_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 4)
    local envelope = source:exportChangeset(0)

    local target = lurek.progression.newStore({ id = "changeset_apply_target" })
    target:defineCounter("wins", { kind = "integer", initial = 0 })
    local applied = target:applyChangesetEnvelope(envelope, {
        require_definition_hash_match = true,
        require_schema_match = true,
        merge_policy = "replace",
    })
    lurek.log.info("applyChangesetEnvelope applied=" .. tostring(applied.applied) .. " policy=" .. tostring(applied.mergePolicy) .. " wins=" .. tostring(target:getCounter("player", "wins")))
end

--@api: LProgressionStore:getSchemaVersion
do
    local source = lurek.progression.newStore({ id = "changeset_conflict_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    source:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    local source_profile = source:createProfile("player")
    source:addCounter(source_profile, "wins", 1)
    source:acceptQuest(source_profile, "cleanup")
    local envelope = source:exportChangeset(0)

    local target = lurek.progression.newStore({ id = "changeset_conflict_target" })
    target:defineCounter("wins", { kind = "integer", initial = 0 })
    target:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    local target_profile = target:createProfile("player")
    target:createProfile("local_only")
    target:addCounter(target_profile, "wins", 5)
    target:acceptQuest(target_profile, "cleanup")
    target:setQuestObjective(target_profile, "cleanup", "step", 1)
    local report = target:applyChangesetEnvelope(envelope, {
        require_definition_hash_match = true,
        require_schema_match = true,
        merge_policy = "keep_local",
    })
    lurek.log.info("applyChangesetEnvelope conflict_count=" .. tostring(report.conflictCount) .. " reason=" .. tostring(report.reason) .. " kept_wins=" .. tostring(target:getCounter("player", "wins")))
end

--@api: LProgressionStore:ackChangesThrough
do
    local source = lurek.progression.newStore({ id = "changeset_ack_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 1)
    local first = lurek.serialize.fromJson(source:exportChangesSince(0))[1]
    local ack = source:ackChangesThrough(first.revision)
    lurek.log.info("ackChangesThrough removed=" .. tostring(ack.removedCount) .. " remaining=" .. tostring(ack.remainingCount))
end

--@api: LProgressionStore:compactChanges
do
    local source = lurek.progression.newStore({ id = "changeset_compact_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 1)
    source:addCounter(profile, "wins", 1)
    local compact = source:compactChanges(1)
    lurek.log.info("compactChanges after=" .. tostring(compact.afterCount) .. " removed=" .. tostring(compact.removedCount))
end

--@api: LProgressionStore:applyChangesetEnvelope
do
    local source = lurek.progression.newStore({ id = "changeset_reject_source" })
    local oversized = lurek.serialize.toJson({
        schema_version = source:getSchemaVersion(),
        definition_hash = source:getDefinitionHash(),
        from_revision = 0,
        to_revision = 1,
        truncated = false,
        records = {
            {
                revision = 1,
                snapshot = {
                    blob = string.rep("x", 300000),
                },
            },
        },
    })
    local ok, err = pcall(function()
        source:applyChangesetEnvelope(oversized, {
            require_definition_hash_match = true,
            require_schema_match = true,
        })
    end)
    lurek.log.info("applyChangesetEnvelope oversized_ok=" .. tostring(ok) .. " err=" .. tostring(err))
end

--@api: LProgressionStore:updateProfile
do
    local store = lurek.progression.newStore({ id = "profile_patch_example" })
    store:createProfile("player", { display_name = "Mira" })
    store:updateProfile("player", {
        kind = "human",
        display_name = "Captain Mira",
        tags = { "story" },
        metadata = { chapter = 2 },
    })
    store:addProfileTag("player", "veteran")
    store:setProfileMetadata("player", "region", "old_tunnels")
    local profile = store:getProfile("player")
    lurek.log.info("updateProfile name=" .. tostring(profile.display_name) .. " tags=" .. tostring(#profile.tags) .. " chapter=" .. tostring(profile.metadata.chapter))
end

--@api: LProgressionStore:setExperience
do
    local store = lurek.progression.newStore({ id = "xp_set_example" })
    local player = store:createProfile("player")
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    local xp = store:setExperience(player, "character_xp", 275)
    local forced = store:setLevel("player", "character_xp", 4)
    lurek.log.info("setExperience level=" .. tostring(xp.level) .. " xp=" .. tostring(xp.experience) .. " forced_level=" .. tostring(forced.level))
end

--@api: LProgressionStore:completeQuest
do
    local store = lurek.progression.newStore({ id = "quest_manual_example" })
    local player = store:createProfile("player")
    store:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Clear", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    store:acceptQuest(player, "cleanup")
    store:completeQuest("player", "cleanup")
    local quest = store:getQuestState(player, "cleanup")
    lurek.log.info("completeQuest status=" .. tostring(quest.status))
end

--@api-stub: LProgressionProfile:getId
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_getid" })
    local profile = store:createProfile("player")
    local pid = profile:getId()
    local kind = profile:type()
    lurek.log.info("LProgressionProfile:getId id=" .. tostring(pid) .. " kind=" .. tostring(kind) .. " ok=" .. tostring(profile:typeOf("LProgressionProfile")))
end

--@api-stub: LProgressionProfile:type
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_type" })
    local profile = store:createProfile("player")
    local pid = profile:getId()
    local kind = profile:type()
    lurek.log.info("LProgressionProfile:type id=" .. tostring(pid) .. " kind=" .. tostring(kind) .. " ok=" .. tostring(profile:typeOf("LProgressionProfile")))
end

--@api-stub: LProgressionProfile:typeOf
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_typeof" })
    local profile = store:createProfile("player")
    local pid = profile:getId()
    local kind = profile:type()
    lurek.log.info("LProgressionProfile:typeOf id=" .. tostring(pid) .. " kind=" .. tostring(kind) .. " ok=" .. tostring(profile:typeOf("LProgressionProfile")))
end

--@api-stub: LProgressionStore:acceptQuest
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_acceptquest" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:acceptQuest profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:acquirePerk
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_acquireperk" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:acquirePerk profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:addAttributeBase
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addattributebase" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addAttributeBase profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:addCounter
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addcounter" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addCounter profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:addExperience
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addexperience" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addExperience profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:addModifier
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addmodifier" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addModifier profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:addProfileTag
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addprofiletag" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addProfileTag profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:addResource
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_addresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:addResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:advanceTime
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_advancetime" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:advanceTime profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:applyProfileTemplate
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_applyprofiletemplate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:applyProfileTemplate profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:applyTrait
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_applytrait" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:applyTrait profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:canSpendResource
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_canspendresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:canSpendResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:clear
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_clear" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:clear profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:clearEvents
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_clearevents" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:clearEvents profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:countProfiles
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_countprofiles" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:countProfiles profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:debugSnapshot
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_debugsnapshot" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:debugSnapshot profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:definePerk
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_defineperk" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:definePerk profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:drainEvents
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_drainevents" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:drainEvents profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:ensureProfile
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_ensureprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:ensureProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:evaluateCondition
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_evaluatecondition" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:evaluateCondition profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:explainAttribute
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_explainattribute" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:explainAttribute profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:explainCondition
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_explaincondition" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:explainCondition profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:explainDerivedValue
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_explainderivedvalue" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:explainDerivedValue profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:exportSnapshot
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_exportsnapshot" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:exportSnapshot profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:failQuest
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_failquest" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:failQuest profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getAchievement
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getachievement" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getAchievement profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getAttribute
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getattribute" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getAttribute profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getAttributeState
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getattributestate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getAttributeState profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getCounter
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getcounter" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getCounter profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getCounterState
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getcounterstate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getCounterState profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getDefinitionHash
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getdefinitionhash" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getDefinitionHash profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getDerivedValue
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getderivedvalue" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getDerivedValue profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getExperience
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getexperience" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getExperience profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getExperienceToNextLevel
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getexperiencetonextlevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getExperienceToNextLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getId
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getid" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getId profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getLeaderboardEntry
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getleaderboardentry" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getLeaderboardEntry profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getLevel
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getlevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api: LProgressionProfile:getPendingRewards
do
    local store = lurek.progression.newStore({ id = "lprogressionprofile_getpendingrewards" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local rewards = profile:getPendingRewards()
    local reward = rewards[1]
    lurek.log.info("LProgressionProfile:getPendingRewards total=" .. tostring(#rewards) .. " reward=" .. tostring(reward:getId()) .. " state=" .. tostring(reward:getState()))
end

--@api-stub: LProgressionStore:getProfile
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getQuestState
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getqueststate" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getQuestState profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getResource
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getRevision
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getrevision" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getRevision profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getSkillCooldown
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getskillcooldown" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getSkillCooldown profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getSkillLevel
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_getskilllevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getSkillLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:getTime
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_gettime" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:getTime profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:hasPerk
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_hasperk" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:hasPerk profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:hasProfile
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_hasprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:hasProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:hasTrait
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_hastrait" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:hasTrait profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:learnSkill
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_learnskill" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:learnSkill profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listAchievements
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listachievements" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listAchievements profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listCounters
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listcounters" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listCounters profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listLeaderboardAroundProfile
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listleaderboardaroundprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listLeaderboardAroundProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listLeaderboardRange
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listleaderboardrange" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listLeaderboardRange profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listLeaderboardTop
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listleaderboardtop" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listLeaderboardTop profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listModifiers
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listmodifiers" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listModifiers profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:listProfiles
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listprofiles" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listProfiles profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api: LQuestJournal:listEntries
do
    local store = lurek.progression.newStore({ id = "lquestjournal_listentries" })
    local profile = store:createProfile("player")
    store:defineQuest("journaled", {
        title = "Journaled",
        max_journal_entries = 3,
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
    store:acceptQuest(profile, "journaled")
    local journal = store:getQuestState("player", "journaled"):getJournal()
    journal:addEntry("Found clue", "discover")
    journal:addEntry("Opened door", "progress")
    local entries = journal:listEntries()
    lurek.log.info("LQuestJournal:listEntries total=" .. tostring(#entries) .. " first=" .. tostring(entries[1] and entries[1]:getText()) .. " quest=" .. tostring(journal:getQuestId()))
end

--@api-stub: LProgressionStore:listTraits
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_listtraits" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:listTraits profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:loadSnapshot
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_loadsnapshot" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:loadSnapshot profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:refillResource
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_refillresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:refillResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:refreshQuestLifecycle
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_refreshquestlifecycle" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:refreshQuestLifecycle profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:removeDerivedValue
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removederivedvalue" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeDerivedValue profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:removeModifier
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removemodifier" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeModifier profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:removeProfile
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removeprofile" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeProfile profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:removeProfileMetadata
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removeprofilemetadata" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeProfileMetadata profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:removeProfileTag
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removeprofiletag" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeProfileTag profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:removeTrait
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_removetrait" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:removeTrait profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setAttributeBase
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setattributebase" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setAttributeBase profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setCounter
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setcounter" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setCounter profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setLevel
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setlevel" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setLevel profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setProfileMetadata
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setprofilemetadata" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setProfileMetadata profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setQuestObjectiveVisibility
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setquestobjectivevisibility" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setQuestObjectiveVisibility profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setResource
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_setresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:setTime
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_settime" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:setTime profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:spendResource
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_spendresource" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:spendResource profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:stats
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_stats" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:stats profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:submitScore
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_submitscore" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:submitScore profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:type
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_type" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:type profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:typeOf
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_typeof" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:typeOf profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:useSkill
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_useskill" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:useSkill profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:validateCondition
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_validatecondition" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:validateCondition profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionStore:validateDerivedValues
do
    local store = lurek.progression.newStore({ id = "lprogressionstore_validatederivedvalues" })
    local profile = store:createProfile("player")
    local snapshot = store:debugSnapshot()
    local stats = store:stats()
    lurek.log.info("LProgressionStore:validateDerivedValues profiles=" .. tostring(stats.profiles) .. " profile=" .. tostring(profile:getId()) .. " schema=" .. tostring(snapshot.schema_version))
end

--@api-stub: LProgressionTransaction:addCounter
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_addcounter" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_addcounter_tx" })
    tx:addCounter(profile, "wins", 2)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:addCounter changes=" .. tostring(summary.changes) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end

--@api-stub: LProgressionTransaction:addExperience
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_addexperience" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_addexperience_tx" })
    tx:addExperience(profile, "xp", 150)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:addExperience changes=" .. tostring(summary.changes) .. " level=" .. tostring(store:getLevel("player", "xp")))
end

--@api-stub: LProgressionTransaction:addModifier
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_addmodifier" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_addmodifier_tx" })
    tx:addModifier(profile, "hp", { value = 10, layer = "final_add" })
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:addModifier changes=" .. tostring(summary.changes) .. " hp=" .. tostring(store:getAttribute("player", "hp", "effective")))
end

--@api-stub: LProgressionTransaction:commit
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_commit" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_commit_tx" })
    local summary = tx:commit()
    local stats = store:stats()
    lurek.log.info("LProgressionTransaction:commit revision=" .. tostring(summary.revision) .. " changes=" .. tostring(summary.changes) .. " profiles=" .. tostring(stats.profiles))
end

--@api-stub: LProgressionTransaction:rollback
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_rollback" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_rollback_tx" })
    tx:addCounter(profile, "wins", 2)
    tx:rollback()
    lurek.log.info("LProgressionTransaction:rollback wins=" .. tostring(store:getCounter("player", "wins")) .. " revision=" .. tostring(store:getRevision()))
end

--@api-stub: LProgressionTransaction:setAttributeBase
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setattributebase" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setattributebase_tx" })
    tx:setAttributeBase(profile, "hp", 120)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setAttributeBase changes=" .. tostring(summary.changes) .. " hp=" .. tostring(store:getAttribute("player", "hp", "base")))
end

--@api-stub: LProgressionTransaction:setCounter
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setcounter" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setcounter_tx" })
    tx:setCounter(profile, "wins", 4)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setCounter changes=" .. tostring(summary.changes) .. " wins=" .. tostring(store:getCounter("player", "wins")))
end

--@api-stub: LProgressionTransaction:setQuestObjective
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setquestobjective" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setquestobjective_tx" })
    tx:setQuestObjective(profile, "cleanup", "step", 1)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setQuestObjective changes=" .. tostring(summary.changes) .. " status=" .. tostring(store:getQuestState("player", "cleanup").status))
end

--@api-stub: LProgressionTransaction:setResource
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_setresource" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_setresource_tx" })
    tx:setResource(profile, "focus", 2)
    local summary = tx:commit()
    lurek.log.info("LProgressionTransaction:setResource changes=" .. tostring(summary.changes) .. " focus=" .. tostring(store:getResource("player", "focus").value))
end

--@api-stub: LProgressionTransaction:type
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_type" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_type_tx" })
    local kind = tx:type()
    local is_tx = tx:typeOf("LProgressionTransaction")
    lurek.log.info("LProgressionTransaction:type type=" .. tostring(kind) .. " ok=" .. tostring(is_tx))
end

--@api-stub: LProgressionTransaction:typeOf
do
    local store = lurek.progression.newStore({ id = "lprogressiontransaction_typeof" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
    store:defineLevelTrack("xp", { initial_level = 1, max_level = 10, curve = { base = 100, increment = 50 }, carry_over = true })
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest("player", "cleanup")
    local tx = store:beginTransaction({ id = "lprogressiontransaction_typeof_tx" })
    local kind = tx:type()
    local is_tx = tx:typeOf("LProgressionTransaction")
    lurek.log.info("LProgressionTransaction:typeOf type=" .. tostring(kind) .. " ok=" .. tostring(is_tx))
end

--@api-stub: lurek.progression.acquirePerk
do
    local store = lurek.progression.newStore({ id = "lurek_progression_acquireperk" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = "example_trait" })
    local acquired = adapter:acquirePerk("iron_skin")
    lurek.log.info("{api} acquired=" .. tostring(acquired) .. " has=" .. tostring(adapter:hasPerk("iron_skin")))
end

--@api-stub: lurek.progression.activeCount
do
    local store = lurek.progression.newStore({ id = "lurek_progression_activecount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local count = adapter:activeCount()
    lurek.log.info("lurek.progression.activeCount count=" .. tostring(count))
end

--@api-stub: lurek.progression.activeIds
do
    local store = lurek.progression.newStore({ id = "lurek_progression_activeids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local ids = adapter:activeIds()
    lurek.log.info("lurek.progression.activeIds first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.addBuff
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addbuff" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local handle = adapter:addBuff("hp", 5, 1, 2, "potion")
    local count = adapter:getBuffCount("hp")
    lurek.log.info("{api} handle=" .. tostring(handle) .. " count=" .. tostring(count))
end

--@api-stub: lurek.progression.addJournalEntry
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addjournalentry" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:addJournalEntry("cleanup", "Entered the cellar", "story")
    local quest_state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.addJournalEntry journal=" .. tostring(#quest_state.journal))
end

--@api-stub: lurek.progression.addQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.addQuest first=" .. tostring(ids[1]) .. " count=" .. tostring(count))
end

--@api-stub: lurek.progression.addXP
do
    local store = lurek.progression.newStore({ id = "lurek_progression_addxp" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:addXP(120)
    local xp = adapter:getXP()
    local level = adapter:getLevel()
    lurek.log.info("{api} xp=" .. tostring(xp) .. " level=" .. tostring(level))
end

--@api-stub: lurek.progression.adjustMorale
do
    local store = lurek.progression.newStore({ id = "lurek_progression_adjustmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:adjustMorale(-3)
    local current = select(1, adapter:getMorale())
    lurek.log.info("{api} morale=" .. tostring(current))
end

--@api-stub: lurek.progression.advanceObjective
do
    local store = lurek.progression.newStore({ id = "lurek_progression_advanceobjective" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.advanceObjective status=" .. tostring(state.status))
end

--@api-stub: lurek.progression.applyTraitBuffs
do
    local store = lurek.progression.newStore({ id = "lurek_progression_applytraitbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    local traits = adapter:getActiveTraits()
    lurek.log.info("{api} trait=" .. tostring(traits[1]))
end

--@api-stub: lurek.progression.beginTurn
do
    local store = lurek.progression.newStore({ id = "lurek_progression_beginturn" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    adapter:spendActionPoints(3)
    adapter:beginTurn()
    local current = select(1, adapter:getActionPoints())
    lurek.log.info("{api} current=" .. tostring(current))
end

--@api-stub: lurek.progression.checkMorale
do
    local store = lurek.progression.newStore({ id = "lurek_progression_checkmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:setPanicThreshold(6)
    adapter:setBerserkThreshold(3)
    adapter:adjustMorale(-5)
    lurek.log.info("{api} state=" .. tostring(adapter:checkMorale()))
end

--@api-stub: lurek.progression.clearBuffs
do
    local store = lurek.progression.newStore({ id = "lurek_progression_clearbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:addBuff("hp", 5, 1, 1, "a")
    adapter:clearBuffs("hp")
    lurek.log.info("{api} count=" .. tostring(adapter:getBuffCount("hp")))
end

--@api-stub: lurek.progression.clearFlag
do
    local store = lurek.progression.newStore({ id = "lurek_progression_clearflag" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    adapter:clearFlag("panic")
    local flags = adapter:getFlags()
    lurek.log.info("{api} count=" .. tostring(#flags))
end

--@api-stub: lurek.progression.completeQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_completequest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:completeQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.completeQuest status=" .. tostring(state.status))
end

--@api-stub: lurek.progression.completedCount
do
    local store = lurek.progression.newStore({ id = "lurek_progression_completedcount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    lurek.log.info("lurek.progression.completedCount count=" .. tostring(adapter:completedCount()))
end

--@api-stub: lurek.progression.completedIds
do
    local store = lurek.progression.newStore({ id = "lurek_progression_completedids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local ids = adapter:completedIds()
    lurek.log.info("lurek.progression.completedIds first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.createLegacyQuestAdapter
do
    local store = lurek.progression.newStore({ id = "lurek_progression_createlegacyquestadapter" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local kind = adapter.type()
    lurek.log.info("lurek.progression.createLegacyQuestAdapter type=" .. tostring(kind) .. " first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.createLegacyStatsAdapter
do
    local store = lurek.progression.newStore({ id = "lurek_progression_createlegacystatsadapter" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    local stats = adapter:getStatNames()
    local kind = adapter.type()
    lurek.log.info("{api} type=" .. tostring(kind) .. " stats=" .. tostring(#stats))
end

--@api-stub: lurek.progression.define
do
    local store = lurek.progression.newStore({ id = "lurek_progression_define" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local names = adapter:getStatNames()
    local value = adapter:get("hp")
    lurek.log.info("{api} stat=" .. tostring(names[1]) .. " value=" .. tostring(value))
end

--@api-stub: lurek.progression.definePerk
do
    local store = lurek.progression.newStore({ id = "lurek_progression_defineperk" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:definePerk("iron_skin", { require_level = 1, trait_name = "example_trait" })
    adapter:setXP(150)
    lurek.log.info("{api} ready=" .. tostring(adapter:hasPerk("iron_skin")))
end

--@api-stub: lurek.progression.defineSkill
do
    local store = lurek.progression.newStore({ id = "lurek_progression_defineskill" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    lurek.log.info("{api} level=" .. tostring(adapter:getSkillLevel("heal")))
end

--@api-stub: lurek.progression.failQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_failquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:failQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.failQuest status=" .. tostring(state.status))
end

--@api-stub: lurek.progression.failedIds
do
    local store = lurek.progression.newStore({ id = "lurek_progression_failedids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:failQuest("cleanup")
    local ids = adapter:failedIds()
    lurek.log.info("lurek.progression.failedIds first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.get
do
    local store = lurek.progression.newStore({ id = "lurek_progression_get" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local value = adapter:get("hp")
    local base = adapter:getBase("hp")
    lurek.log.info("{api} value=" .. tostring(value) .. " base=" .. tostring(base))
end

--@api-stub: lurek.progression.getActionPoints
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getactionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    local current, maxv = adapter:getActionPoints()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.getActiveTraits
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getactivetraits" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    local traits = adapter:getActiveTraits()
    lurek.log.info("{api} trait=" .. tostring(traits[1]))
end

--@api-stub: lurek.progression.getBase
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getbase" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local base = adapter:getBase("hp")
    local value = adapter:get("hp")
    lurek.log.info("{api} base=" .. tostring(base) .. " value=" .. tostring(value))
end

--@api-stub: lurek.progression.getBuffCount
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getbuffcount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:addBuff("hp", 5, 1, 1, "a")
    local count = adapter:getBuffCount("hp")
    lurek.log.info("{api} count=" .. tostring(count))
end

--@api-stub: lurek.progression.getBuffs
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:addBuff("hp", 5, 1, 1, "a")
    local buffs = adapter:getBuffs("hp")
    lurek.log.info("{api} count=" .. tostring(#buffs))
end

--@api-stub: lurek.progression.getCooldownRemaining
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getcooldownremaining" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    adapter:useSkill("heal")
    lurek.log.info("{api} cooldown=" .. tostring(adapter:getCooldownRemaining("heal")))
end

--@api-stub: lurek.progression.getEncumbrance
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getencumbrance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setEncumbrance(12, 20)
    local enc = adapter:getEncumbrance()
    local over = adapter:isEncumbered()
    lurek.log.info("{api} current=" .. tostring(enc.current) .. " over=" .. tostring(over))
end

--@api-stub: lurek.progression.getFlags
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getflags" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    adapter:setFlag("wounded")
    local flags = adapter:getFlags()
    lurek.log.info("{api} count=" .. tostring(#flags) .. " first=" .. tostring(flags[1]))
end

--@api-stub: lurek.progression.getInitiative
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getinitiative" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setInitiative(17)
    local initiative = adapter:getInitiative()
    local kind = adapter.type()
    lurek.log.info("{api} initiative=" .. tostring(initiative) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.getLevel
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getlevel" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:addXP(150)
    local level = adapter:getLevel()
    local xp = adapter:getXP()
    lurek.log.info("{api} level=" .. tostring(level) .. " xp=" .. tostring(xp))
end

--@api-stub: lurek.progression.getMax
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getmax" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local maxv = adapter:getMax("hp")
    local minv = adapter:getMin("hp")
    lurek.log.info("{api} min=" .. tostring(minv) .. " max=" .. tostring(maxv))
end

--@api-stub: lurek.progression.getMin
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getmin" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local minv = adapter:getMin("hp")
    local maxv = adapter:getMax("hp")
    lurek.log.info("{api} min=" .. tostring(minv) .. " max=" .. tostring(maxv))
end

--@api-stub: lurek.progression.getMorale
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    local current, maxv = adapter:getMorale()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.getQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local fetched = adapter:getQuest("cleanup")
    local ids = adapter:questIds()
    lurek.log.info("lurek.progression.getQuest id=" .. tostring(fetched.id) .. " first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.getQuestReward
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getquestreward" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:setQuestReward("cleanup", "gold")
    local reward = adapter:getQuestReward("cleanup")
    lurek.log.info("lurek.progression.getQuestReward reward=" .. tostring(reward))
end

--@api-stub: lurek.progression.getRegen
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getregen" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setRegen("hp", 1.5)
    local regen = adapter:getRegen("hp")
    lurek.log.info("{api} regen=" .. tostring(regen))
end

--@api-stub: lurek.progression.getResistance
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getresistance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setResistance("fire", 0.25)
    local value = adapter:getResistance("fire")
    local kind = adapter.type()
    lurek.log.info("{api} value=" .. tostring(value) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.getSkillLevel
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getskilllevel" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    lurek.log.info("{api} level=" .. tostring(adapter:getSkillLevel("heal")))
end

--@api-stub: lurek.progression.getStatNames
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getstatnames" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("agi", 8, { min = 0, max = 20 })
    adapter:define("hp", 100, { min = 0, max = 150 })
    local names = adapter:getStatNames()
    lurek.log.info("{api} first=" .. tostring(names[1]) .. " total=" .. tostring(#names))
end

--@api-stub: lurek.progression.getUseCount
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getusecount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:recordUse("heal")
    local count = adapter:getUseCount("heal")
    local kind = adapter.type()
    lurek.log.info("{api} count=" .. tostring(count) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.getXP
do
    local store = lurek.progression.newStore({ id = "lurek_progression_getxp" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:addXP(120)
    local xp = adapter:getXP()
    local level = adapter:getLevel()
    lurek.log.info("{api} xp=" .. tostring(xp) .. " level=" .. tostring(level))
end

--@api-stub: lurek.progression.hasFlag
do
    local store = lurek.progression.newStore({ id = "lurek_progression_hasflag" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    local has = adapter:hasFlag("panic")
    local flags = adapter:getFlags()
    lurek.log.info("{api} has=" .. tostring(has) .. " count=" .. tostring(#flags))
end

--@api-stub: lurek.progression.hasPerk
do
    local store = lurek.progression.newStore({ id = "lurek_progression_hasperk" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = "example_trait" })
    lurek.log.info("{api} has=" .. tostring(adapter:hasPerk("iron_skin")))
end

--@api-stub: lurek.progression.hasTrait
do
    local store = lurek.progression.newStore({ id = "lurek_progression_hastrait" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    lurek.log.info("{api} has=" .. tostring(adapter:hasTrait("example_trait")))
end

--@api-stub: lurek.progression.isEncumbered
do
    local store = lurek.progression.newStore({ id = "lurek_progression_isencumbered" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setEncumbrance(21, 20)
    local enc = adapter:getEncumbrance()
    local over = adapter:isEncumbered()
    lurek.log.info("{api} current=" .. tostring(enc.current) .. " over=" .. tostring(over))
end

--@api-stub: lurek.progression.learnSkill
do
    local store = lurek.progression.newStore({ id = "lurek_progression_learnskill" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    lurek.log.info("{api} level=" .. tostring(adapter:getSkillLevel("heal")))
end

--@api-stub: lurek.progression.questCount
do
    local store = lurek.progression.newStore({ id = "lurek_progression_questcount" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local count = adapter:questCount()
    local ids = adapter:questIds()
    lurek.log.info("lurek.progression.questCount count=" .. tostring(count) .. " first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.questIds
do
    local store = lurek.progression.newStore({ id = "lurek_progression_questids" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local ids = adapter:questIds()
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.questIds first=" .. tostring(ids[1]) .. " count=" .. tostring(count))
end

--@api-stub: lurek.progression.questsWithStatus
do
    local store = lurek.progression.newStore({ id = "lurek_progression_questswithstatus" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local ids = adapter:questsWithStatus("active")
    lurek.log.info("lurek.progression.questsWithStatus first=" .. tostring(ids[1]))
end

--@api-stub: lurek.progression.recordUse
do
    local store = lurek.progression.newStore({ id = "lurek_progression_recorduse" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:recordUse("heal")
    local count = adapter:getUseCount("heal")
    local kind = adapter.type()
    lurek.log.info("{api} count=" .. tostring(count) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.recoverActionPoints
do
    local store = lurek.progression.newStore({ id = "lurek_progression_recoveractionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    adapter:spendActionPoints(3)
    adapter:recoverActionPoints(2)
    local current = select(1, adapter:getActionPoints())
    lurek.log.info("{api} current=" .. tostring(current))
end

--@api-stub: lurek.progression.removeBuff
do
    local store = lurek.progression.newStore({ id = "lurek_progression_removebuff" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local handle = adapter:addBuff("hp", 5, 1, 1, "a")
    local removed = adapter:removeBuff(handle)
    lurek.log.info("{api} removed=" .. tostring(removed))
end

--@api-stub: lurek.progression.removeQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_removequest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    local removed = adapter:removeQuest("cleanup")
    local count = adapter:questCount()
    lurek.log.info("lurek.progression.removeQuest removed=" .. tostring(removed) .. " count=" .. tostring(count))
end

--@api-stub: lurek.progression.removeTraitBuffs
do
    local store = lurek.progression.newStore({ id = "lurek_progression_removetraitbuffs" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    store:defineTrait("example_trait", {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    adapter:applyTraitBuffs("example_trait")
    local removed = adapter:removeTraitBuffs("example_trait")
    lurek.log.info("{api} removed=" .. tostring(removed))
end

--@api-stub: lurek.progression.resetQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_resetquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    adapter:advanceObjective("cleanup", "step", 1)
    local reset = adapter:resetQuest("cleanup")
    lurek.log.info("lurek.progression.resetQuest reset=" .. tostring(reset))
end

--@api-stub: lurek.progression.restore
do
    local store = lurek.progression.newStore({ id = "lurek_progression_restore" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setXP(0)
    local snap = adapter:snapshot()
    adapter:restore(snap)
    local value = adapter:get("hp")
    lurek.log.info("{api} value=" .. tostring(value))
end

--@api-stub: lurek.progression.setActionPoints
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setactionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    local current, maxv = adapter:getActionPoints()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.setBase
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setbase" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setBase("hp", 120)
    local base = adapter:getBase("hp")
    lurek.log.info("{api} base=" .. tostring(base))
end

--@api-stub: lurek.progression.setBerserkThreshold
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setberserkthreshold" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:setPanicThreshold(7)
    adapter:setBerserkThreshold(4)
    adapter:adjustMorale(-7)
    lurek.log.info("{api} state=" .. tostring(adapter:checkMorale()))
end

--@api-stub: lurek.progression.setEncumbrance
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setencumbrance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setEncumbrance(12, 20)
    local enc = adapter:getEncumbrance()
    local over = adapter:isEncumbered()
    lurek.log.info("{api} current=" .. tostring(enc.current) .. " over=" .. tostring(over))
end

--@api-stub: lurek.progression.setFlag
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setflag" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setFlag("panic")
    local has = adapter:hasFlag("panic")
    local flags = adapter:getFlags()
    lurek.log.info("{api} has=" .. tostring(has) .. " count=" .. tostring(#flags))
end

--@api-stub: lurek.progression.setInitiative
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setinitiative" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setInitiative(17)
    local initiative = adapter:getInitiative()
    local kind = adapter.type()
    lurek.log.info("{api} initiative=" .. tostring(initiative) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.setLevel
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setlevel" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setXP(0)
    adapter:setLevel(3)
    local level = adapter:getLevel()
    local xp = adapter:getXP()
    lurek.log.info("{api} level=" .. tostring(level) .. " xp=" .. tostring(xp))
end

--@api-stub: lurek.progression.setMax
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setmax" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setMax("hp", 160)
    local maxv = adapter:getMax("hp")
    lurek.log.info("{api} max=" .. tostring(maxv))
end

--@api-stub: lurek.progression.setMin
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setmin" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setMin("hp", 10)
    local minv = adapter:getMin("hp")
    lurek.log.info("{api} min=" .. tostring(minv))
end

--@api-stub: lurek.progression.setMorale
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setmorale" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    local current, maxv = adapter:getMorale()
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " max=" .. tostring(maxv) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.setPanicThreshold
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setpanicthreshold" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setMorale(10)
    adapter:setPanicThreshold(8)
    adapter:setBerserkThreshold(4)
    adapter:adjustMorale(-3)
    lurek.log.info("{api} state=" .. tostring(adapter:checkMorale()))
end

--@api-stub: lurek.progression.setQuestReward
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setquestreward" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:setQuestReward("cleanup", "gold")
    local reward = adapter:getQuestReward("cleanup")
    lurek.log.info("lurek.progression.setQuestReward reward=" .. tostring(reward))
end

--@api-stub: lurek.progression.setRegen
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setregen" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    local value = adapter:get("hp")
    local names = adapter:getStatNames()
    lurek.log.info("lurek.progression.setRegen value=" .. tostring(value) .. " stats=" .. tostring(#names))
end

--@api-stub: lurek.progression.setResistance
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setresistance" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setResistance("fire", 0.25)
    local value = adapter:getResistance("fire")
    local kind = adapter.type()
    lurek.log.info("{api} value=" .. tostring(value) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.applyDamage
do
    local store = lurek.progression.newStore({ id = "lurek_progression_applydamage" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setResistance("fire", 0.25)
    local actual = adapter:applyDamage("hp", 40, "fire")
    local hp = adapter:getBase("hp")
    lurek.log.info("{api} actual=" .. tostring(actual) .. " hp=" .. tostring(hp))
end

--@api-stub: lurek.progression.setLevelThresholds
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setlevelthresholds" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setLevelThresholds({ kind = "table", values = { 50, 100, 200 } })
    adapter:addXP(160)
    local level = adapter:getLevel()
    local xp = adapter:getXP()
    lurek.log.info("{api} level=" .. tostring(level) .. " xp=" .. tostring(xp))
end

--@api-stub: lurek.progression.setXP
do
    local store = lurek.progression.newStore({ id = "lurek_progression_setxp" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setXP(180)
    local xp = adapter:getXP()
    local level = adapter:getLevel()
    lurek.log.info("{api} xp=" .. tostring(xp) .. " level=" .. tostring(level))
end

--@api-stub: lurek.progression.snapshot
do
    local store = lurek.progression.newStore({ id = "lurek_progression_snapshot" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("hp", 100, { min = 0, max = 150 })
    adapter:setXP(0)
    local snap = adapter:snapshot()
    local value = snap.attributes.hp.base
    lurek.log.info("{api} base=" .. tostring(value) .. " level=" .. tostring(snap.level))
end

--@api-stub: lurek.progression.spendActionPoints
do
    local store = lurek.progression.newStore({ id = "lurek_progression_spendactionpoints" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    local ok = adapter:spendActionPoints(2)
    local current = select(1, adapter:getActionPoints())
    lurek.log.info("{api} ok=" .. tostring(ok) .. " current=" .. tostring(current))
end

--@api-stub: lurek.progression.startQuest
do
    local store = lurek.progression.newStore({ id = "lurek_progression_startquest" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
    local quest = {
        id = "cleanup",
        title = "Cleanup",
        description = "",
        status = "available",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        current = 0,
                        required = 1,
                        mandatory = true,
                        status = "pending",
                        visible = true,
                        tags = {},
                    },
                },
            },
        },
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
    }
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    adapter:addQuest(quest)
    adapter:startQuest("cleanup")
    local state = adapter:getQuest("cleanup")
    lurek.log.info("lurek.progression.startQuest status=" .. tostring(state.status))
end

--@api-stub: lurek.progression.type
do
    local store = lurek.progression.newStore({ id = "lurek_progression_type" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    local kind = adapter.type()
    local ok = adapter.typeOf("LLegacyStatsAdapter")
    local names = adapter:getStatNames()
    lurek.log.info("{api} type=" .. tostring(kind) .. " ok=" .. tostring(ok) .. " names=" .. tostring(#names))
end

--@api-stub: lurek.progression.typeOf
do
    local store = lurek.progression.newStore({ id = "lurek_progression_typeof" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    local kind = adapter.type()
    local ok = adapter.typeOf("LLegacyStatsAdapter")
    local names = adapter:getStatNames()
    lurek.log.info("{api} type=" .. tostring(kind) .. " ok=" .. tostring(ok) .. " names=" .. tostring(#names))
end

--@api-stub: lurek.progression.update
do
    local store = lurek.progression.newStore({ id = "lurek_progression_update" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:setActionPoints(5)
    adapter:update(0.5)
    local current = select(1, adapter:getActionPoints())
    local kind = adapter.type()
    lurek.log.info("{api} current=" .. tostring(current) .. " type=" .. tostring(kind))
end

--@api-stub: lurek.progression.useSkill
do
    local store = lurek.progression.newStore({ id = "lurek_progression_useskill" })
    store:createProfile("player")
    local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    adapter:learnSkill("heal")
    local ok = adapter:useSkill("heal")
    lurek.log.info("{api} ok=" .. tostring(ok))
end

--@api-stub: LProgressionStore:applyChangeset
do
    local source = lurek.progression.newStore({ id = "apply_changeset_source" })
    source:defineCounter("wins", { kind = "integer", initial = 0 })
    local profile = source:createProfile("player")
    source:addCounter(profile, "wins", 3)
    local changes = source:exportChangesSince(0)
    local target = lurek.progression.newStore({ id = "apply_changeset_target" })
    local report = target:applyChangeset(changes)
    lurek.log.info("LProgressionStore:applyChangeset applied=" .. tostring(report.applied) .. " wins=" .. tostring(target:getCounter("player", "wins")))
end

--@api-stub: LProgressionStore:update
do
    local store = lurek.progression.newStore({ id = "update_owner_store" })
    local profile = store:createProfile("player")
    store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 1, refill = "rate" })
    store:setResource(profile, "focus", 1)
    store:update(2.0)
    lurek.log.info("LProgressionStore:update focus=" .. tostring(store:getResource("player", "focus").value) .. " revision=" .. tostring(store:getRevision()))
end

--@api-stub: LProgressionStore:validate
do
    local store = lurek.progression.newStore({ id = "validate_owner_store" })
    store:createProfile("player")
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    local report = store:validate()
    lurek.log.info("LProgressionStore:validate ok=" .. tostring(report.ok) .. " errors=" .. tostring(#report.errors))
end

--@api: LAchievement:getId
do
    local store = lurek.progression.newStore({ id = "achievement_get_id_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("first_win", { title = "First Win" })
    store:unlockAchievement(profile, "first_win")
    local achievement = store:getAchievement("player", "first_win")
    lurek.log.info("LAchievement:getId id=" .. tostring(achievement:getId()) .. " title=" .. tostring(achievement:getTitle()) .. " unlocked=" .. tostring(achievement:isUnlocked()))
end

--@api: LAchievement:getTitle
do
    local store = lurek.progression.newStore({ id = "achievement_get_title_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("cartographer", { title = "Cartographer" })
    store:unlockAchievement(profile, "cartographer")
    local achievement = store:getAchievement(profile, "cartographer")
    lurek.log.info("LAchievement:getTitle title=" .. tostring(achievement:getTitle()) .. " id=" .. tostring(achievement:getId()) .. " unlocked=" .. tostring(achievement:isUnlocked()))
end

--@api: LAchievement:isUnlocked
do
    local store = lurek.progression.newStore({ id = "achievement_is_unlocked_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("finisher", { title = "Finisher" })
    local before = store:getAchievement(profile, "finisher")
    store:unlockAchievement(profile, "finisher")
    local after = store:getAchievement("player", "finisher")
    lurek.log.info("LAchievement:isUnlocked before=" .. tostring(before:isUnlocked()) .. " after=" .. tostring(after:isUnlocked()) .. " id=" .. tostring(after:getId()))
end

--@api: LActivityFeed:count
do
    local store = lurek.progression.newStore({ id = "activity_feed_count_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("manual_reward", { title = "Manual Reward" })
    store:unlockAchievement(profile, "manual_reward")
    local feed = store:getActivityFeed({
        profiles = { profile },
        types = { "achievement_unlocked" },
        limit = 4,
    })
    lurek.log.info("LActivityFeed:count total=" .. tostring(feed:count()) .. " requested_limit=" .. tostring(feed.limit))
end

--@api: LActivityFeed:listEntries
do
    local store = lurek.progression.newStore({ id = "activity_feed_entries_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("manual_reward", { title = "Manual Reward" })
    store:unlockAchievement(profile, "manual_reward")
    local feed = store:getActivityFeed({
        profiles = { "player" },
        types = { "achievement_unlocked" },
        limit = 2,
    })
    local entries = feed:listEntries()
    lurek.log.info("LActivityFeed:listEntries total=" .. tostring(#entries) .. " first=" .. tostring(entries[1] and entries[1]:getEventType()))
end

--@api: LActivityFeedEntry:getEventType
do
    local store = lurek.progression.newStore({ id = "activity_feed_type_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("headline", { title = "Headline" })
    store:unlockAchievement(profile, "headline")
    local entry = store:getActivityFeed({ profiles = { profile }, limit = 1 }):listEntries()[1]
    lurek.log.info("LActivityFeedEntry:getEventType type=" .. tostring(entry:getEventType()) .. " seq=" .. tostring(entry:getSequence()))
end

--@api: LActivityFeedEntry:getSequence
do
    local store = lurek.progression.newStore({ id = "activity_feed_sequence_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("beat", { title = "Beat" })
    store:unlockAchievement(profile, "beat")
    local entry = store:getActivityFeed({ profiles = { "player" }, limit = 1 }):listEntries()[1]
    lurek.log.info("LActivityFeedEntry:getSequence seq=" .. tostring(entry:getSequence()) .. " type=" .. tostring(entry:getEventType()))
end

--@api: LChallenge:getId
do
    local store = lurek.progression.newStore({ id = "challenge_get_id_example" })
    local profile = store:createProfile("player")
    store:defineChallengeTemplate("daily_wins", { title = "Daily Wins", required = 3, tags = { "daily" } })
    local challenge = store:activateChallenge(profile, "daily_wins")
    lurek.log.info("LChallenge:getId id=" .. tostring(challenge:getId()) .. " status=" .. tostring(challenge:getStatus()))
end

--@api: LChallenge:getStatus
do
    local store = lurek.progression.newStore({ id = "challenge_get_status_example" })
    local profile = store:createProfile("player")
    store:defineChallengeTemplate("night_ops", { title = "Night Ops", required = 2, tags = { "weekly" } })
    store:activateChallenge(profile, "night_ops")
    local challenge = store:setChallengeProgress("player", "night_ops", 1)
    lurek.log.info("LChallenge:getStatus id=" .. tostring(challenge:getId()) .. " status=" .. tostring(challenge:getStatus()))
end

--@api: LCollection:getId
do
    local store = lurek.progression.newStore({ id = "collection_get_id_example" })
    local profile = store:createProfile("player")
    store:defineCollection("field_notes", { title = "Field Notes", items = { { id = "entry_a", title = "Entry A" } } })
    local collection = store:collectCollectionItem(profile, "field_notes", "entry_a")
    lurek.log.info("LCollection:getId id=" .. tostring(collection:getId()) .. " complete=" .. tostring(collection:isComplete()))
end

--@api: LCollection:isComplete
do
    local store = lurek.progression.newStore({ id = "collection_is_complete_example" })
    local profile = store:createProfile("player")
    store:defineCollection("museum", { title = "Museum", items = { { id = "artifact", title = "Artifact" } } })
    local before = store:getCollection(profile, "museum")
    local after = store:collectCollectionItem("player", "museum", "artifact")
    lurek.log.info("LCollection:isComplete before=" .. tostring(before:isComplete()) .. " after=" .. tostring(after:isComplete()) .. " id=" .. tostring(after:getId()))
end

--@api: LLeaderboardEntry:getLeaderboardId
do
    local store = lurek.progression.newStore({ id = "leaderboard_get_lb_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 7)
    local entry = store:getLeaderboardEntry("alpha", "arena")
    lurek.log.info("LLeaderboardEntry:getLeaderboardId leaderboard=" .. tostring(entry:getLeaderboardId()) .. " profile=" .. tostring(entry:getProfileId()))
end

--@api: LLeaderboardEntry:getProfileId
do
    local store = lurek.progression.newStore({ id = "leaderboard_get_profile_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("beta", "arena", 5)
    local entry = store:getLeaderboardEntry("beta", "arena")
    lurek.log.info("LLeaderboardEntry:getProfileId profile=" .. tostring(entry:getProfileId()) .. " leaderboard=" .. tostring(entry:getLeaderboardId()))
end

--@api: LLeaderboardEntry:getRank
do
    local store = lurek.progression.newStore({ id = "leaderboard_get_rank_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    local entry = store:submitScore("beta", "arena", 3)
    lurek.log.info("LLeaderboardEntry:getRank rank=" .. tostring(entry:getRank()) .. " profile=" .. tostring(entry:getProfileId()))
end

--@api: LPopulation:getId
do
    local store = lurek.progression.newStore({ id = "population_get_id_example", seed = 42 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("citizens", {
        id_prefix = "citizen_",
        count = 3,
        identity = { name_generator = { mode = "parts", prefixes = { "North" }, suffixes = { "Vale", "Gate" } }, tags = { "npc" } },
        archetypes = { { id = "worker", weight = 1, activity = { min = 1, max = 2 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    local pop = store:generatePopulation("citizens", { id = "city_pop" })
    local stats = store:getPopulationStatistics("city_pop")
    lurek.log.info("LPopulation:getId id=" .. tostring(pop:getId()) .. " paused=" .. tostring(pop:isPaused()) .. " active=" .. tostring(stats.active_count))
end

--@api: LPopulation:isPaused
do
    local store = lurek.progression.newStore({ id = "population_is_paused_example", seed = 7 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("visitors", {
        id_prefix = "visitor_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "East" }, suffixes = { "Pier", "Row" } }, tags = { "guest" } },
        archetypes = { { id = "guest", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 980, deviation = 5 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 1, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("visitors", { id = "camp" })
    store:pausePopulation("camp")
    local pop = store:getPopulation("camp")
    lurek.log.info("LPopulation:isPaused paused=" .. tostring(pop:isPaused()) .. " id=" .. tostring(pop:getId()))
end

--@api: LPopulationProfile:getProfileId
do
    local store = lurek.progression.newStore({ id = "population_profile_get_id_example", seed = 11 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = 2,
        identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox", "Wing" } }, tags = { "bot" } },
        archetypes = { { id = "runner", weight = 1, activity = { min = 1, max = 2 }, skill = { mean = 1000, deviation = 10 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("bots", { id = "bot_pack" })
    local profile = store:listPopulationProfiles("bot_pack", { limit = 1 })[1]
    lurek.log.info("LPopulationProfile:getProfileId profile=" .. tostring(profile:getProfileId()) .. " materialized=" .. tostring(profile:isMaterialized()))
end

--@api: LPopulationProfile:isMaterialized
do
    local store = lurek.progression.newStore({ id = "population_profile_materialized_example", seed = 12 })
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
    store:definePopulationTemplate("pilots", {
        id_prefix = "pilot_",
        count = 1,
        identity = { name_generator = { mode = "parts", prefixes = { "Sky" }, suffixes = { "Ace" } }, tags = { "pilot" } },
        archetypes = { { id = "ace", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1025, deviation = 0 } } },
        leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 1, mean_reversion = 0.1 } } },
    })
    store:generatePopulation("pilots", { id = "pilot_pack" })
    local before = store:listPopulationProfiles("pilot_pack", { limit = 1 })[1]
    store:materializePopulationProfile(before:getProfileId())
    local after = store:listPopulationProfiles("pilot_pack", { limit = 1 })[1]
    lurek.log.info("LPopulationProfile:isMaterialized before=" .. tostring(before:isMaterialized()) .. " after=" .. tostring(after:isMaterialized()) .. " profile=" .. tostring(after:getProfileId()))
end

--@api: LPrestige:getId
do
    local store = lurek.progression.newStore({ id = "prestige_get_id_example" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:addCounter(profile, "wins", 3)
    store:definePrestige("rebirth", { condition = { counter = "wins", op = ">=", value = 1 }, reset = { counters = { "wins" }, level_tracks = {} }, preserve = { achievements = true, lifetime_counters = true } })
    local prestige = store:getPrestige("player", "rebirth")
    lurek.log.info("LPrestige:getId id=" .. tostring(prestige:getId()) .. " available=" .. tostring(prestige:isAvailable()))
end

--@api: LPrestige:isAvailable
do
    local store = lurek.progression.newStore({ id = "prestige_is_available_example" })
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:definePrestige("rebirth", { condition = { counter = "wins", op = ">=", value = 2 }, reset = { counters = { "wins" }, level_tracks = {} }, preserve = { achievements = true, lifetime_counters = true } })
    local before = store:getPrestige(profile, "rebirth")
    store:addCounter("player", "wins", 2)
    local after = store:getPrestige("player", "rebirth")
    lurek.log.info("LPrestige:isAvailable before=" .. tostring(before:isAvailable()) .. " after=" .. tostring(after:isAvailable()) .. " id=" .. tostring(after:getId()))
end

--@api: LQuestState:getQuestId
do
    local store = lurek.progression.newStore({ id = "quest_state_get_id_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    local state = store:getQuestState(profile, "cleanup")
    lurek.log.info("LQuestState:getQuestId quest=" .. tostring(state:getQuestId()) .. " status=" .. tostring(state:getStatus()))
end

--@api: LQuestState:getStatus
do
    local store = lurek.progression.newStore({ id = "quest_state_get_status_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local state = store:getQuestState("player", "cleanup")
    lurek.log.info("LQuestState:getStatus quest=" .. tostring(state:getQuestId()) .. " status=" .. tostring(state:getStatus()))
end

--@api: LQuestState:isRevealed
do
    local store = lurek.progression.newStore({ id = "quest_state_is_revealed_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    local before = store:getQuestState(profile, "cleanup")
    local after = store:revealQuest("player", "cleanup")
    lurek.log.info("LQuestState:isRevealed before=" .. tostring(before:isRevealed()) .. " after=" .. tostring(after:isRevealed()) .. " quest=" .. tostring(after:getQuestId()))
end

--@api: LQuestJournal:getQuestId
do
    local store = lurek.progression.newStore({ id = "quest_journal_get_id_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local journal = store:getQuestState("player", "cleanup"):getJournal()
    journal:addEntry("Found clue", "discover")
    lurek.log.info("LQuestJournal:getQuestId quest=" .. tostring(journal:getQuestId()) .. " entries=" .. tostring(journal:count()))
end

--@api: LQuestJournal:count
do
    local store = lurek.progression.newStore({ id = "quest_journal_count_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local journal = store:getQuestState(profile, "cleanup"):getJournal()
    journal:addEntry("Found clue", "discover")
    journal:addEntry("Opened door", "progress")
    lurek.log.info("LQuestJournal:count total=" .. tostring(journal:count()) .. " quest=" .. tostring(journal:getQuestId()))
end

--@api: LQuestJournal:addEntry
do
    local store = lurek.progression.newStore({ id = "quest_journal_add_entry_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local journal = store:getQuestState("player", "cleanup"):getJournal()
    local entry = journal:addEntry("Opened vault", "discover")
    lurek.log.info("LQuestJournal:addEntry index=" .. tostring(entry:getIndex()) .. " text=" .. tostring(entry:getText()) .. " total=" .. tostring(journal:count()))
end

--@api: LQuestJournalEntry:getIndex
do
    local store = lurek.progression.newStore({ id = "quest_journal_entry_index_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local entry = store:getQuestState("player", "cleanup"):getJournal():addEntry("Found clue", "discover")
    lurek.log.info("LQuestJournalEntry:getIndex index=" .. tostring(entry:getIndex()) .. " tag=" .. tostring(entry:getTag()))
end

--@api: LQuestJournalEntry:getText
do
    local store = lurek.progression.newStore({ id = "quest_journal_entry_text_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local entry = store:getQuestState(profile, "cleanup"):getJournal():addEntry("Mapped tunnel", "discover")
    lurek.log.info("LQuestJournalEntry:getText text=" .. tostring(entry:getText()) .. " index=" .. tostring(entry:getIndex()))
end

--@api: LQuestJournalEntry:getTag
do
    local store = lurek.progression.newStore({ id = "quest_journal_entry_tag_example" })
    local profile = store:createProfile("player")
    store:defineQuest("cleanup", { title = "Cleanup", stages = { { id = "stage_1", name = "Stage 1", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } } } })
    store:acceptQuest(profile, "cleanup")
    local entry = store:getQuestState("player", "cleanup"):getJournal():addEntry("Opened door", "progress")
    lurek.log.info("LQuestJournalEntry:getTag tag=" .. tostring(entry:getTag()) .. " text=" .. tostring(entry:getText()))
end

--@api: LReward:getId
do
    local store = lurek.progression.newStore({ id = "reward_get_id_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    lurek.log.info("LReward:getId id=" .. tostring(reward_record:getId()) .. " state=" .. tostring(reward_record:getState()))
end

--@api: LReward:getState
do
    local store = lurek.progression.newStore({ id = "reward_get_state_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    local claimed = reward_record:claim()
    lurek.log.info("LReward:getState pending=" .. tostring(reward_record:getState()) .. " claimed=" .. tostring(claimed:getState()))
end

--@api: LReward:claim
do
    local store = lurek.progression.newStore({ id = "reward_claim_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    local claimed = reward_record:claim()
    lurek.log.info("LReward:claim before=" .. tostring(reward_record:getState()) .. " after=" .. tostring(claimed:getState()) .. " id=" .. tostring(claimed:getId()))
end

--@api: LReward:markApplied
do
    local store = lurek.progression.newStore({ id = "reward_mark_applied_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local claimed = profile:getPendingRewards()[1]:claim()
    local applied = claimed:markApplied("receipt-42")
    lurek.log.info("LReward:markApplied state=" .. tostring(applied:getState()) .. " receipt=" .. tostring(applied.external_receipt))
end

--@api: LReward:reject
do
    local store = lurek.progression.newStore({ id = "reward_reject_example" })
    local profile = store:createProfile("player")
    store:defineAchievement("paid", { title = "Paid", reward_payload = { coins = 5 } })
    store:unlockAchievement(profile, "paid")
    local reward_record = profile:getPendingRewards()[1]
    local rejected = reward_record:reject("inventory_full")
    lurek.log.info("LReward:reject state=" .. tostring(rejected:getState()) .. " id=" .. tostring(rejected:getId()))
end

--@api: LRival:getProfileId
do
    local store = lurek.progression.newStore({ id = "rival_get_profile_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    local rival_state = store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
    lurek.log.info("LRival:getProfileId profile=" .. tostring(rival_state:getProfileId()) .. " rival=" .. tostring(rival_state:getRivalProfileId()))
end

--@api: LRival:getRivalProfileId
do
    local store = lurek.progression.newStore({ id = "rival_get_rival_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    local rival_state = store:getRival(store:pinRival("alpha", "beta", { leaderboard_id = "arena" }):getProfileId(), "beta")
    lurek.log.info("LRival:getRivalProfileId profile=" .. tostring(rival_state:getProfileId()) .. " rival=" .. tostring(rival_state:getRivalProfileId()))
end

--@api: LRivalDelta:getLeaderboardId
do
    local store = lurek.progression.newStore({ id = "rival_delta_get_lb_id_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
    local delta = store:getRivalDelta("alpha", "beta")
    lurek.log.info("LRivalDelta:getLeaderboardId leaderboard=" .. tostring(delta:getLeaderboardId()) .. " rank_delta=" .. tostring(delta:getRankDelta()))
end

--@api: LRivalDelta:getRankDelta
do
    local store = lurek.progression.newStore({ id = "rival_delta_get_rank_delta_example" })
    store:createProfile("alpha")
    store:createProfile("beta")
    store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "competition", max_entries = 10 })
    store:submitScore("alpha", "arena", 10)
    store:submitScore("beta", "arena", 8)
    store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
    local delta = store:getRivalDelta("alpha", "beta")
    lurek.log.info("LRivalDelta:getRankDelta leaderboard=" .. tostring(delta:getLeaderboardId()) .. " rank_delta=" .. tostring(delta:getRankDelta()))
end

--@api: LSeason:getId
do
    local store = lurek.progression.newStore({ id = "season_get_id_example" })
    store:defineSeason("spring", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = false })
    store:startSeason("spring")
    local season_state = store:getSeason("spring")
    lurek.log.info("LSeason:getId id=" .. tostring(season_state:getId()) .. " active=" .. tostring(season_state:isActive()))
end

--@api: LSeason:isActive
do
    local store = lurek.progression.newStore({ id = "season_is_active_example" })
    store:defineSeason("summer", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = false })
    local before = store:getSeason("summer")
    store:startSeason("summer")
    local after = store:getSeason("summer")
    lurek.log.info("LSeason:isActive before=" .. tostring(before:isActive()) .. " after=" .. tostring(after:isActive()) .. " id=" .. tostring(after:getId()))
end

--@api: LSeasonArchive:getArchiveIndex
do
    local store = lurek.progression.newStore({ id = "season_archive_index_example" })
    store:createProfile("player")
    store:defineSeason("league", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = true })
    store:startSeason("league")
    store:endSeason("league", { archive = true })
    local archive = store:getSeasonArchive("league", { latest = true })
    lurek.log.info("LSeasonArchive:getArchiveIndex id=" .. tostring(archive:getId()) .. " index=" .. tostring(archive:getArchiveIndex()))
end

--@api: LSeasonArchive:getId
do
    local store = lurek.progression.newStore({ id = "season_archive_id_example" })
    store:createProfile("player")
    store:defineSeason("league", { starts_at = 0, ends_at = 10, reset = { leaderboards = {}, counters = {} }, archive = true })
    store:startSeason("league")
    store:endSeason("league", { archive = true })
    local archive = store:getSeasonArchive("league", { latest = true })
    lurek.log.info("LSeasonArchive:getId id=" .. tostring(archive:getId()) .. " index=" .. tostring(archive:getArchiveIndex()))
end

--@api: lurek.progression.newStatusTracker
do
    local tracker = lurek.progression.newStatusTracker()
    local type_name = tracker:type()
    local empty = tracker:list(1)
    local snapshot = tracker:snapshot()
    lurek.log.info("status tracker type=" .. type_name .. " empty=" .. #empty .. " isolated=" .. tostring(tracker ~= nil))
    lurek.log.info("next status id=" .. tostring(snapshot.nextId))
end

--@api: LStatusTracker:define
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "poison", duration = 5, tickInterval = 1, maxStacks = 3, stacking = "add", tags = { "damage_over_time" } })
    local empty = tracker:list(1)
    local snapshot = tracker:snapshot()
    lurek.log.info("defined poison statuses=" .. #tracker:list(1) .. " type=" .. tracker:type())
    lurek.log.info("defined id=" .. snapshot.definitions.poison.id .. " active=" .. tostring(#empty))
end

--@api: LStatusTracker:apply
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "slow", duration = 4, maxStacks = 2, stacking = "refresh" })
    local instance = tracker:apply(7, "slow", 99, 1)
    local status = tracker:get(instance)
    lurek.log.info("applied instance=" .. instance .. " subject=" .. tracker:list(7)[1].subjectId .. " source=" .. tracker:list(7)[1].sourceId)
    lurek.log.info("applied definition=" .. status.definitionId)
end

--@api: LStatusTracker:clear
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "shield", duration = 10 })
    tracker:apply(1, "shield")
    tracker:clear()
    lurek.log.info("cleared status count=" .. #tracker:list(1) .. " events=" .. #tracker:drainEvents())
end

--@api: LStatusTracker:drainEvents
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "regen", duration = 3, tickInterval = 1 })
    tracker:apply(2, "regen")
    local events = tracker:drainEvents()
    lurek.log.info("status events=" .. #events .. " first=" .. events[1].kind .. " instance=" .. events[1].instanceId)
end

--@api: LStatusTracker:list
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "marked", duration = 8 })
    tracker:apply(3, "marked", nil, 2)
    local statuses = tracker:list(3)
    lurek.log.info("status count=" .. #statuses .. " definition=" .. statuses[1].definitionId .. " stacks=" .. statuses[1].stacks)
end

--@api: LStatusTracker:remove
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", duration = 8 })
    local instance = tracker:apply(4, "ward")
    local removed = tracker:remove(instance)
    lurek.log.info("removed=" .. tostring(removed) .. " remaining=" .. #tracker:list(4) .. " second=" .. tostring(tracker:remove(instance)))
end

--@api: LStatusTracker:restore
do
    local source = lurek.progression.newStatusTracker()
    source:define({ id = "burn", duration = 2, tickInterval = 1 })
    source:apply(5, "burn")
    local target = lurek.progression.newStatusTracker()
    target:restore(source:snapshot())
    lurek.log.info("restored statuses=" .. #target:list(5) .. " definition=" .. target:list(5)[1].definitionId)
end

--@api: LStatusTracker:snapshot
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "haste", duration = 6 })
    tracker:apply(6, "haste")
    local snapshot = tracker:snapshot()
    lurek.log.info("snapshot definitions=" .. tostring(snapshot.definitions.haste.id) .. " instances=" .. #snapshot.instances .. " next=" .. snapshot.nextId)
end

--@api: LStatusTracker:type
do
    local tracker = lurek.progression.newStatusTracker()
    local kind = tracker:type()
    local exact = tracker:typeOf("LStatusTracker")
    local empty = #tracker:list(1)
    lurek.log.info("status tracker type=" .. tracker:type() .. " empty=" .. tostring(#tracker:list(1) == 0) .. " snapshot=" .. tostring(tracker:snapshot() ~= nil))
    lurek.log.info(kind .. " exact=" .. tostring(exact) .. " count=" .. tostring(empty))
end

--@api: LStatusTracker:typeOf
do
    local tracker = lurek.progression.newStatusTracker()
    local exact = tracker:typeOf("LStatusTracker")
    local base = tracker:typeOf("LObject")
    local store = tracker:typeOf("LProgressionStore")
    lurek.log.info("tracker=" .. tostring(tracker:typeOf("LStatusTracker")) .. " object=" .. tostring(tracker:typeOf("LObject")) .. " store=" .. tostring(tracker:typeOf("LProgressionStore")))
    lurek.log.info("type flags=" .. tostring(exact) .. "," .. tostring(base) .. "," .. tostring(store))
end

--@api: LStatusTracker:update
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "poison", duration = 2.5, tickInterval = 1 })
    tracker:apply(8, "poison")
    local queued = tracker:update(1.1)
    local events = tracker:drainEvents()
    lurek.log.info("update queued=" .. queued .. " tick=" .. tostring(events[#events].kind == "tick") .. " remaining=" .. tracker:list(8)[1].remaining)
end

--@api: LStatusTracker:get
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", duration = 5, tags = { "helpful" } })
    local instance_id = tracker:apply(1, "ward")
    local instance = tracker:get(instance_id)
    lurek.log.info("status instance=" .. tostring(instance.id))
end

--@api: LStatusTracker:has
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", tags = { "helpful" } })
    tracker:apply(1, "ward")
    local helpful = tracker:has(1, "helpful")
    lurek.log.info("has helpful=" .. tostring(helpful))
end

--@api: LStatusTracker:removeByDefinition
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", tags = { "helpful" } })
    tracker:apply(1, "ward")
    local removed = tracker:removeByDefinition(1, "ward")
    lurek.log.info("removed definitions=" .. tostring(removed))
end

--@api: LStatusTracker:removeByTag
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", tags = { "helpful" } })
    tracker:apply(1, "ward")
    local removed = tracker:removeByTag(1, "helpful")
    lurek.log.info("removed tags=" .. tostring(removed))
end

--@api: LStatusTracker:setPaused
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", duration = 5 })
    local instance_id = tracker:apply(1, "ward")
    tracker:setPaused(instance_id, true)
    lurek.log.info("paused=" .. tostring(tracker:get(instance_id).paused))
end

--@api: LStatusTracker:setRemaining
do
    local tracker = lurek.progression.newStatusTracker()
    tracker:define({ id = "ward", duration = 5 })
    local instance_id = tracker:apply(1, "ward")
    tracker:setRemaining(instance_id, 2)
    lurek.log.info("remaining=" .. tostring(tracker:get(instance_id).remaining))
end






