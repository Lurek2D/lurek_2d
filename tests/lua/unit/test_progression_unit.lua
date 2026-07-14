-- Reorganized unit test file.
-- Source files are isolated in do-end blocks to preserve local helper scope.

-- BEGIN test_progression_core_unit.lua
-- tests/lua/unit/test_progression_core_unit.lua
-- Canonical Lua unit tests for the initial lurek.progression store slice.

local function new_store(id)
    return lurek.progression.newStore({
        id = id or "unit_store",
        clock = "manual",
        event_capacity = 64,
        max_profiles = 32,
        strict = true,
    })
end

local function new_stats_adapter(id, profile_id)
    local pid = profile_id or "player"
    local store = new_store(id)
    store:createProfile(pid)
    return store, lurek.progression.createLegacyStatsAdapter(store, pid)
end

local function new_quest_adapter(id, profile_id)
    local pid = profile_id or "player"
    local store = new_store(id)
    store:createProfile(pid)
    return store, lurek.progression.createLegacyQuestAdapter(store, pid)
end

local function define_legacy_trait(store, trait_name, stat, add)
    store:defineTrait(trait_name, {
        modifiers = {
            { target_id = stat or "hp", value = add or 10, layer = "final_add" },
        },
    })
end

local function new_legacy_objective(id, description, required)
    return {
        id = id,
        description = description,
        current = 0,
        required = required or 0,
        mandatory = true,
        status = "pending",
        visible = true,
        tags = {},
    }
end

local function new_legacy_stage(id, name)
    local stage = {
        id = id,
        name = name,
        objectives = {},
    }
    function stage:addObjective(objective)
        self.objectives[#self.objectives + 1] = objective
    end
    return stage
end

local function new_legacy_quest(id, title)
    local quest = {
        id = id,
        title = title or id,
        description = "",
        status = "available",
        stages = {},
        current_stage = 1,
        journal = {},
        metadata = {},
        visible = true,
        reward = "",
        _journal_counter = 0,
        _max_journal = nil,
    }
    function quest:addStage(stage)
        self.stages[#self.stages + 1] = stage
    end
    function quest:addJournalEntry(text, tag)
        local entry = {
            index = self._journal_counter,
            text = text,
            tag = tag,
        }
        self._journal_counter = self._journal_counter + 1
        self.journal[#self.journal + 1] = entry
        if self._max_journal ~= nil then
            while #self.journal > self._max_journal do
                table.remove(self.journal, 1)
            end
        end
        return entry
    end
    function quest:setMeta(key, value)
        self.metadata[key] = value
    end
    local stage = new_legacy_stage("stage_1", "Stage 1")
    stage:addObjective(new_legacy_objective("step", "One step", 1))
    quest:addStage(stage)
    return quest
end

local function new_hp_stats_adapter(id)
    local _, adapter = new_stats_adapter(id)
    adapter:define("hp", 100, { min = 0, max = 150 })
    return adapter
end

local function new_skill_stats_adapter(id)
    local _, adapter = new_stats_adapter(id)
    adapter:define("mana", 100, { min = 0, max = 100 })
    adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
    return adapter
end

local function new_perk_stats_adapter(id, trait_name)
    local store, adapter = new_stats_adapter(id)
    adapter:define("hp", 100, { min = 0, max = 150 })
    define_legacy_trait(store, trait_name, "hp", 10)
    adapter:setXP(180)
    adapter:definePerk("iron_skin", { require_level = 2, trait_name = trait_name })
    return adapter
end

local function new_seeded_quest_adapter(id)
    local _, adapter = new_quest_adapter(id)
    adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
    return adapter
end

local function new_resource_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineResource("stamina", { initial = 5, min = 0, max = 10, regeneration = 0, refill = "manual" })
    return store, profile
end

local function new_attribute_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineAttribute("hp", { base = 100, min = 0, max = 150 })
    return store, profile
end

local function new_level_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    return store, profile
end

local function new_skill_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineAttribute("mana", { base = 100, min = 0, max = 100 })
    store:setAttributeBase(profile, "mana", 100)
    store:defineSkill("heal", { max_level = 5, resource = "mana", cost = 20, cooldown = 3 })
    return store, profile
end

local function new_perk_store(id, trait_name)
    local store, profile = new_attribute_store(id)
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    store:defineTrait(trait_name, {
        modifiers = {
            { target_id = "hp", value = 10, layer = "final_add" },
        },
    })
    store:definePerk("iron_skin", {
        require_level = 2,
        track_id = "character_xp",
        trait_ids = { trait_name },
    })
    store:setLevel(profile, "character_xp", 2)
    return store, profile
end

local function define_store_quest(store, id)
    store:defineQuest(id or "cleanup", {
        title = "Cleanup",
        stages = {
            { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
        },
    })
end

local function new_store_quest(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    define_store_quest(store, "cleanup")
    return store, profile
end

local function new_challenge_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineChallengeTemplate("win_streak", {
        title = "Win Streak",
        description = "Win three matches",
        required = 3,
        counter_id = "wins",
        tags = { "daily" },
        reward_payload = { currency = 25 },
    })
    return store, profile
end

local function new_reward_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineAchievement("manual_reward", {
        title = "Manual Reward",
        repeatable = true,
        reward_payload = {
            items = { "token" },
        },
    })
    local first = store:unlockAchievement(profile, "manual_reward")
    local reward_id = "achievement:manual_reward:" .. tostring(first.unlock_count)
    return store, profile, reward_id
end

local function new_leaderboard_store(id)
    local store = new_store(id)
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
    return store
end

local function new_derived_store(id)
    local store = new_store(id)
    local profile = store:createProfile("player")
    store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
    store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
    store:defineLevelTrack("character_xp", {
        initial_level = 1,
        max_level = 10,
        curve = { base = 100, increment = 50 },
        carry_over = true,
    })
    store:addCounter(profile, "wins", 3)
    store:setAttributeBase(profile, "strength", 12)
    store:addExperience(profile, "character_xp", 150)
    store:defineDerivedValue("combat_rating", {
        expression = "wins + strength + level",
        inputs = {
            wins = { kind = "counter", counter_id = "wins" },
            strength = { kind = "attribute", attribute_id = "strength", mode = "effective" },
            level = { kind = "level", track_id = "character_xp" },
        },
        min = 0,
    })
    return store, profile
end

-- @describe lurek.progression namespace
describe("lurek.progression namespace", function()
    -- @covers lurek.progression.newStore
    it("newStore creates a deterministic empty store", function()
        local store = new_store("new_store_case")
        expect_equal("new_store_case", store:getId())
        expect_equal(0, store:getRevision())
        expect_equal(0, store:getTime())
        expect_type("table", store:stats())
    end)

    -- @covers lurek.progression.importLegacyStatsSnapshot
    it("importLegacyStatsSnapshot converts legacy stats fields into a structured summary", function()
        local converted = lurek.progression.importLegacyStatsSnapshot({
            xp = 50,
            level = 3,
            attributes = { strength = { base = 9 } },
        })
        expect_type("table", converted)
        expect_equal(1, #converted.attributes)
        expect_equal(50, converted.experience.experience)
        expect_equal(3, converted.experience.level)
    end)

    -- @covers lurek.progression.importLegacyQuestSnapshot
    it("importLegacyQuestSnapshot reports basic quest identities and status", function()
        local converted = lurek.progression.importLegacyQuestSnapshot({
            quests = {
                { id = "rat_hunt", title = "Rat Hunt", status = "active" },
            },
        })
        expect_type("table", converted)
        expect_equal(1, #converted.quests)
        expect_equal("rat_hunt", converted.quests[1].id)
        expect_equal("active", converted.quests[1].status)
    end)

    -- @covers lurek.progression.loadStore
    it("loadStore recreates a store from an exported snapshot", function()
        local source = new_store("snapshot_source")
        source:createProfile("player", { display_name = "Snapshot Hero" })
        local snapshot = source:exportSnapshot()
        local restored = lurek.progression.loadStore(snapshot)
        expect_equal("snapshot_source", restored:getId())
        expect_equal(1, restored:countProfiles())
    end)

    -- @covers lurek.progression.createLegacyStatsAdapter
    it("createLegacyStatsAdapter exposes a sheet-like compatibility wrapper", function()
        local store = new_store("legacy_stats_case")
        store:createProfile("player")
        local adapter = lurek.progression.createLegacyStatsAdapter(store, "player")
        adapter:define("hp", 100, { min = 0, max = 150 })
        adapter:setBase("hp", 120)
        adapter:addXP(180)
        expect_equal(120, adapter:get("hp"))
        expect_true(adapter:getLevel() >= 2)
    end)

    -- @covers lurek.progression.createLegacyQuestAdapter
    it("createLegacyQuestAdapter exposes a quest-log compatibility wrapper", function()
        local store = new_store("legacy_quest_case")
        store:createProfile("player")
        local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
        local quest = new_legacy_quest("cleanup", "Cleanup")
        adapter:addQuest(quest)
        adapter:startQuest("cleanup")
        adapter:advanceObjective("cleanup", "step", 1)
        expect_equal(1, adapter:questCount())
        expect_equal("completed", adapter:getQuest("cleanup").status)
    end)
end)

-- @describe LProgressionStore profiles and counters
describe("LProgressionStore profiles and counters", function()
    -- @covers LProgressionStore:createProfile
    it("createProfile returns a handle and stores profile metadata", function()
        local store = new_store("profiles_case")
        local profile = store:createProfile("player", {
            kind = "human",
            display_name = "Mira",
            tags = { "local", "campaign_a" },
            metadata = { country = "PL" },
        })
        local snapshot = store:getProfile("player")
        expect_equal("player", profile:getId())
        expect_equal("Mira", snapshot.display_name)
        expect_equal(2, #snapshot.tags)
    end)

    -- @covers LProgressionStore:updateProfile
    it("updateProfile and profile tag metadata helpers patch identity fields", function()
        local store = new_store("profile_patch_case")
        store:createProfile("player", { display_name = "Mira" })
        store:updateProfile("player", { display_name = "Captain Mira", tags = { "story" }, metadata = { chapter = 2 } })
        store:addProfileTag("player", "veteran")
        store:setProfileMetadata("player", "region", "old_tunnels")
        local snapshot = store:getProfile("player")
        expect_equal("Captain Mira", snapshot.display_name)
        expect_equal(2, #snapshot.tags)
        expect_equal(2, snapshot.metadata.chapter)
        expect_equal("old_tunnels", snapshot.metadata.region)
    end)

    -- @covers LProgressionStore:defineCounter
    it("defineCounter enables addCounter and threshold events", function()
        local store = new_store("counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("rats_killed", {
            kind = "cumulative_integer",
            initial = 0,
            min = 0,
            monotonic = true,
            thresholds = { 3 },
        })
        local value = store:addCounter(profile, "rats_killed", 3)
        local snapshot = store:getCounterState("player", "rats_killed")
        local events = store:drainEvents()
        expect_equal(3, value)
        expect_equal(3, snapshot.value)
        expect_true(#events >= 2)
    end)

    -- @covers LProgressionStore:getCounter
    it("getCounter returns the current counter value", function()
        local store = new_store("get_counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:addCounter(profile, "wins", 2)
        expect_equal(2, store:getCounter("player", "wins"))
    end)

    -- @covers LProgressionStore:ensureProfile
    it("ensureProfile only creates a profile once", function()
        local store = new_store("ensure_profile_case")
        local _, created = store:ensureProfile("player", { display_name = "Mira" })
        local _, created_again = store:ensureProfile("player", { display_name = "Other" })
        expect_true(created)
        expect_false(created_again)
        expect_equal(1, store:countProfiles())
    end)

    -- @covers LProgressionStore:hasProfile
    it("hasProfile reflects whether a profile exists", function()
        local store = new_store("has_profile_case")
        expect_false(store:hasProfile("player"))
        store:createProfile("player")
        expect_true(store:hasProfile("player"))
    end)

    -- @covers LProgressionStore:listProfiles
    it("listProfiles returns deterministic profile snapshots", function()
        local store = new_store("list_profiles_case")
        store:createProfile("beta")
        store:createProfile("alpha")
        local profiles = store:listProfiles()
        expect_equal(2, #profiles)
        expect_equal("alpha", profiles[1].id)
        expect_equal("beta", profiles[2].id)
    end)

    -- @covers LProgressionStore:removeProfileTag
    it("removeProfileTag deletes a tag without touching others", function()
        local store = new_store("remove_profile_tag_case")
        store:createProfile("player", { tags = { "hero", "veteran" } })
        store:removeProfileTag("player", "hero")
        local profile = store:getProfile("player")
        expect_equal(1, #profile.tags)
        expect_equal("veteran", profile.tags[1])
    end)

    -- @covers LProgressionStore:removeProfileMetadata
    it("removeProfileMetadata deletes a keyed metadata field", function()
        local store = new_store("remove_profile_metadata_case")
        store:createProfile("player", { metadata = { chapter = 2, region = "old_tunnels" } })
        store:removeProfileMetadata("player", "chapter")
        local profile = store:getProfile("player")
        expect_nil(profile.metadata.chapter)
        expect_equal("old_tunnels", profile.metadata.region)
    end)

    -- @covers LProgressionStore:removeProfile
    it("removeProfile drops the profile and returns whether it existed", function()
        local store = new_store("remove_profile_case")
        store:createProfile("player")
        expect_true(store:removeProfile("player"))
        expect_false(store:hasProfile("player"))
        expect_false(store:removeProfile("player"))
    end)

    -- @covers LProgressionStore:countProfiles
    it("countProfiles reports the current profile total", function()
        local store = new_store("count_profiles_case")
        store:createProfile("alpha")
        store:createProfile("beta")
        expect_equal(2, store:countProfiles())
    end)

    -- @covers LProgressionStore:listCounters
    it("listCounters returns touched counters for a profile", function()
        local store = new_store("list_counters_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:defineCounter("losses", { kind = "integer", initial = 0 })
        store:addCounter(profile, "wins", 2)
        store:addCounter("player", "losses", 1)
        local counters = store:listCounters("player")
        expect_equal(2, #counters)
        expect_equal("losses", counters[1].id)
        expect_equal("wins", counters[2].id)
    end)
end)

-- @describe LProgressionStore store utilities
describe("LProgressionStore store utilities", function()
    -- @covers LProgressionStore:advanceTime
    it("advanceTime moves the logical clock forward", function()
        local store = new_store("advance_time_case")
        store:advanceTime(4)
        expect_equal(4, store:getTime())
    end)

    -- @covers LProgressionStore:clear
    it("clear resets mutable state while keeping authored definitions", function()
        local store = new_store("clear_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:addCounter(profile, "wins", 3)
        store:clear()
        expect_equal(0, store:countProfiles())
        expect_equal(1, store:stats().counterDefinitions)
    end)

    -- @covers LProgressionStore:clearEvents
    it("clearEvents removes retained events without changing revision", function()
        local store = new_store("clear_events_case")
        store:createProfile("player")
        expect_true(#store:drainEvents() >= 1)
        store:createProfile("beta")
        store:clearEvents()
        expect_equal(0, #store:drainEvents())
    end)

    -- @covers LProgressionStore:drainEvents
    it("drainEvents returns and clears retained events", function()
        local store = new_store("drain_events_case")
        store:createProfile("player")
        local events = store:drainEvents()
        expect_true(#events >= 1)
        expect_equal(0, #store:drainEvents())
    end)

    -- @covers LProgressionStore:debugSnapshot
    it("debugSnapshot returns a structured view of current store state", function()
        local store = new_store("debug_snapshot_case")
        store:createProfile("player")
        local snapshot = store:debugSnapshot()
        expect_equal("debug_snapshot_case", snapshot.options.id)
        expect_type("table", snapshot.profiles.player)
    end)

    -- @covers LProgressionStore:stats
    it("stats reports current counts for the store", function()
        local store = new_store("stats_case")
        store:createProfile("player")
        local stats = store:stats()
        expect_equal(1, stats.profiles)
        expect_equal(1, stats.revision)
    end)

    -- @covers LProgressionStore:validate
    it("validate reports a healthy store snapshot", function()
        local store = new_store("validate_case")
        local report = store:validate()
        expect_true(report.ok)
        expect_equal(0, #report.errors)
    end)
end)

-- @describe LProgressionStore conditions
describe("LProgressionStore conditions", function()
    -- @covers LProgressionStore:validateCondition
    it("compileCondition evaluateCondition and explainCondition share a canonical shape", function()
        local store = new_store("condition_case")
        local profile = store:createProfile("player", { tags = { "hero" } })
        store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 100,
            curve = { base = 100, increment = 100 },
            carry_over = true,
        })
        local condition = {
            all = {
                { tag = "hero" },
                { counter = "wins", op = ">=", value = 2 },
                { level = { track = "character_xp", op = ">=", value = 3 } },
            },
        }

        local compiled = store:compileCondition(condition)
        local validation = store:validateCondition(condition)
        expect_equal("all", compiled.kind)
        expect_true(validation.ok)
        expect_false(store:evaluateCondition(profile, condition))

        store:addCounter("player", "wins", 2)
        store:setLevel("player", "character_xp", 3)

        local explanation = store:explainCondition("player", condition)
        expect_true(store:evaluateCondition("player", condition))
        expect_true(explanation.ok)
        expect_equal(3, #explanation.children)
        expect_equal("level", explanation.children[3].kind)
    end)
end)

-- @describe LProgressionStore derived values
describe("LProgressionStore derived values", function()
    -- @covers LProgressionStore:defineDerivedValue
    it("defineDerivedValue evaluates expressions against named progression inputs", function()
        local store = new_store("derived_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
        store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 10,
            curve = { base = 100, increment = 50 },
            carry_over = true,
        })
        store:addCounter(profile, "wins", 3)
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

        local validation = store:validateDerivedValues()
        local value = store:getDerivedValue("player", "combat_rating")
        local explanation = store:explainDerivedValue(profile, "combat_rating")
        expect_true(validation.ok)
        expect_equal(17, value)
        expect_equal(3, explanation.inputs.wins)
        expect_equal(17, explanation.value)
    end)

    -- @covers LProgressionStore:removeDerivedValue
    it("removeDerivedValue deletes an authored derived value", function()
        local store = new_store("remove_derived_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineDerivedValue("combat_rating", {
            expression = "wins",
            inputs = {
                wins = { kind = "counter", counter_id = "wins" },
            },
        })
        expect_equal(0, store:getDerivedValue(profile, "combat_rating"))
        expect_true(store:removeDerivedValue("combat_rating"))
    end)
end)

-- @describe LProgressionStore profile templates
describe("LProgressionStore profile templates", function()
    -- @covers LProgressionStore:defineProfileTemplate
    it("profile templates seed counters stats resources xp tags and metadata", function()
        local store = new_store("template_case")
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
            display_name = "Veteran Scout",
            counters = { wins = 4 },
            attributes = { strength = 14 },
            resources = { stamina = 7 },
            experience = { character_xp = 180 },
            tags = { "veteran" },
            metadata = { origin = "frontier" },
        })

        store:createProfile("player", {
            display_name = "Mira",
            template = "veteran_scout",
        })

        local snapshot = store:getProfile("player")
        local strength = store:getAttribute("player", "strength", "base")
        local stamina = store:getResource("player", "stamina")
        expect_equal("Mira", snapshot.display_name)
        expect_equal("scout", snapshot.kind)
        expect_equal("frontier", snapshot.metadata.origin)
        expect_equal(4, store:getCounter("player", "wins"))
        expect_equal(14, strength)
        expect_equal(7, stamina.value)
        expect_equal(2, store:getLevel("player", "character_xp"))

        store:setAttributeBase("player", "strength", 20)
        local reapplied = store:applyProfileTemplate("player", "veteran_scout")
        expect_equal("veteran_scout", reapplied.metadata.__template_id)
        expect_equal(14, store:getAttribute("player", "strength", "base"))
    end)
end)

-- @describe LProgressionStore traits and perks
describe("LProgressionStore traits and perks", function()
    -- @covers LProgressionStore:defineTrait
    it("traits and perks apply canonical stat modifiers", function()
        local store = new_store("traits_perks_case")
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

        expect_true(store:applyTrait("player", "tough"))
        expect_equal(120, store:getAttribute("player", "hp", "effective"))
        expect_true(store:removeTrait("player", "tough"))
        expect_false(store:hasTrait("player", "tough"))
        expect_equal(100, store:getAttribute("player", "hp", "effective"))

        store:setLevel("player", "__legacy_xp", 3)
        expect_true(store:acquirePerk("player", "iron_skin"))
        expect_true(store:hasPerk("player", "iron_skin"))
        expect_true(store:hasTrait("player", "tough"))
    end)

    -- @covers LProgressionStore:listTraits
    it("listTraits returns active canonical trait ids", function()
        local store = new_store("list_traits_case")
        store:createProfile("player")
        store:defineAttribute("hp", { base = 100, min = 0, max = 999 })
        store:defineTrait("tough", {
            modifiers = {
                { target_id = "hp", value = 20, layer = "final_add" },
            },
        })
        store:applyTrait("player", "tough")
        local traits = store:listTraits("player")
        expect_equal(1, #traits)
        expect_equal("tough", traits[1])
    end)
end)

-- @describe LProgressionStore skills
describe("LProgressionStore skills", function()
    -- @covers LProgressionStore:defineSkill
    it("skills track levels costs and cooldowns", function()
        local store = new_store("skills_case")
        store:createProfile("player")
        store:defineAttribute("mana", { base = 100, min = 0, max = 100 })
        store:setAttributeBase("player", "mana", 100)
        store:defineSkill("heal", {
            max_level = 5,
            resource = "mana",
            cost = 30,
            cooldown = 5,
        })

        expect_true(store:learnSkill("player", "heal"))
        local used = store:useSkill("player", "heal")
        expect_true(used.ok)
        expect_equal(70, store:getAttribute("player", "mana", "base"))
        local blocked = store:useSkill("player", "heal")
        expect_false(blocked.ok)
        expect_equal("on cooldown", blocked.reason)
        store:update(3)
        expect_equal(2, store:getSkillCooldown("player", "heal"))
        store:update(3)
        expect_equal(0, store:getSkillCooldown("player", "heal"))
    end)
end)

-- @describe LProgressionStore leaderboards
describe("LProgressionStore leaderboards", function()
    -- @covers LProgressionStore:defineLeaderboard
    it("leaderboards accept manual and counter-driven score submissions", function()
        local store = new_store("leaderboard_case")
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
        local range = store:listLeaderboardRange("arena", 2, 2)
        local around_beta = store:listLeaderboardAroundProfile("arena", "beta", 1, 1)
        local alpha = store:getLeaderboardEntry("alpha", "arena")
        local gamma = store:getLeaderboardEntry("gamma", "arena")
        local promoted = store:submitScore("gamma", "arena", 8)
        local events = store:drainEvents()
        local saw_top_entered = false
        local saw_rank_changed = false
        for _, event in ipairs(events) do
            if event.event_type == "leaderboard_top_entered" then
                saw_top_entered = true
            elseif event.event_type == "leaderboard_rank_changed" then
                saw_rank_changed = true
            end
        end

        expect_equal(3, #top)
        expect_equal("alpha", top[1].profile_id)
        expect_equal("beta", top[2].profile_id)
        expect_equal("gamma", top[3].profile_id)
        expect_equal(1, #range)
        expect_equal("gamma", range[1].profile_id)
        expect_equal(3, #around_beta)
        expect_equal("beta", around_beta[2].profile_id)
        expect_equal(1, alpha.rank)
        expect_equal(3, gamma.rank)
        expect_equal(1, promoted.rank)
        expect_true(saw_top_entered)
        expect_true(saw_rank_changed)
    end)
end)

-- @describe LProgressionStore seasons
describe("LProgressionStore seasons", function()
    -- @covers LProgressionStore:defineSeason
    it("defineSeason stores reset targets for later lifecycle use", function()
        local store = new_store("season_define_case")
        store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
            counter_id = "season_wins",
        })

        store:defineSeason("arena_s1", {
            starts_at = 0,
            ends_at = 100,
            reset = {
                leaderboards = { "arena" },
                counters = { "season_wins" },
            },
            archive = true,
        })

        local season = store:getSeason("arena_s1")
        expect_equal("arena_s1", season.id)
        expect_equal(1, #season.reset.leaderboards)
        expect_true(season.archive)
    end)

    -- @covers LProgressionStore:startSeason
    it("startSeason marks a season active at logical time", function()
        local store = new_store("season_start_case")
        store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100 })
        local season = store:startSeason("arena_s1", { time = 5 })
        expect_true(season.active)
        expect_equal(5, season.started_at)
    end)

    -- @covers LProgressionStore:getSeason
    it("getSeason returns current runtime state and archive counts", function()
        local store = new_store("season_get_case")
        store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100, archive = true })
        store:startSeason("arena_s1", { time = 10 })
        local season = store:getSeason("arena_s1")
        expect_true(season.active)
        expect_equal(0, season.archive_count)
        expect_equal(10, season.started_at)
    end)

    -- @covers LProgressionStore:listSeasons
    it("listSeasons can filter by active state", function()
        local store = new_store("season_list_case")
        store:defineSeason("arena_s1", { starts_at = 0, ends_at = 100 })
        store:defineSeason("arena_s2", { starts_at = 100, ends_at = 200 })
        store:startSeason("arena_s1", { time = 0 })
        local active = store:listSeasons({ active = true })
        expect_equal(1, #active)
        expect_equal("arena_s1", active[1].id)
    end)

    -- @covers LProgressionStore:endSeason
    it("endSeason archives pre-reset state and clears selected counters and leaderboards", function()
        local store = new_store("season_end_case")
        store:createProfile("alpha")
        store:createProfile("beta")
        store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
            counter_id = "season_wins",
        })
        store:defineSeason("arena_s1", {
            starts_at = 0,
            ends_at = 100,
            reset = {
                leaderboards = { "arena" },
                counters = { "season_wins" },
            },
            archive = true,
        })
        store:startSeason("arena_s1", { time = 0 })
        store:addCounter("alpha", "season_wins", 5)
        store:addCounter("beta", "season_wins", 3)

        local season = store:endSeason("arena_s1", { time = 100 })

        expect_false(season.active)
        expect_equal(1, season.archive_count)
        expect_equal(0, store:getCounter("alpha", "season_wins"))
        expect_equal(0, #store:listLeaderboardTop("arena", 3))
    end)

    -- @covers LProgressionStore:getSeasonArchive
    it("getSeasonArchive returns the archived pre-reset snapshot", function()
        local store = new_store("season_archive_case")
        store:createProfile("alpha")
        store:defineCounter("season_wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
            counter_id = "season_wins",
        })
        store:defineSeason("arena_s1", {
            starts_at = 0,
            ends_at = 100,
            reset = {
                leaderboards = { "arena" },
                counters = { "season_wins" },
            },
            archive = true,
        })
        store:startSeason("arena_s1", { time = 0 })
        store:addCounter("alpha", "season_wins", 4)
        store:endSeason("arena_s1", { time = 100 })

        local archive = store:getSeasonArchive("arena_s1", { latest = true })
        expect_equal(1, archive.archive_index)
        expect_equal(4, archive.snapshot.profiles.alpha.counters.season_wins.value)
        expect_equal(4, archive.snapshot.profiles.alpha.leaderboard_scores.arena)
    end)

    -- @covers LProgressionStore:refreshQuestLifecycle
    it("refreshQuestLifecycle recomputes revealed and available quest state", function()
        local store = new_store("refresh_quest_lifecycle_case")
        local profile = store:createProfile("player")
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
        store:addCounter(profile, "wins", 2)
        local state = store:refreshQuestLifecycle("player")
        local quest = store:getQuestState("player", "arena")
        expect_equal(nil, state)
        expect_equal("available", quest.status)
    end)
end)

-- @describe LProgressionStore prestiges
describe("LProgressionStore prestiges", function()
    -- @covers LProgressionStore:definePrestige
    it("definePrestige stores reset and preserve configuration", function()
        local store = new_store("prestige_define_case")
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 200,
            curve = { base = 100, increment = 100 },
            carry_over = true,
        })
        store:defineCounter("campaign_kills", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:definePrestige("career", {
            condition = { level = { track = "character_xp", op = ">=", value = 100 } },
            reset = {
                level_tracks = { "character_xp" },
                counters = { "campaign_kills" },
            },
            preserve = {
                achievements = true,
                lifetime_counters = true,
            },
        })

        local profile = store:createProfile("player")
        local prestige = store:getPrestige(profile, "career")
        expect_equal("career", prestige.id)
        expect_true(prestige.preserve.achievements)
        expect_equal(1, #prestige.reset.level_tracks)
    end)

    -- @covers LProgressionStore:canPrestige
    it("canPrestige evaluates shared level conditions", function()
        local store = new_store("prestige_can_case")
        local profile = store:createProfile("player")
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 200,
            curve = { base = 100, increment = 100 },
            carry_over = true,
        })
        store:definePrestige("career", {
            condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        })

        expect_false(store:canPrestige(profile, "career"))
        store:setLevel("player", "character_xp", 100)
        expect_true(store:canPrestige("player", "career"))
    end)

    -- @covers LProgressionStore:applyPrestige
    it("applyPrestige resets selected progress and preserves configured history", function()
        local store = new_store("prestige_apply_case")
        local profile = store:createProfile("player")
        store:defineCounter("campaign_kills", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 200,
            curve = { base = 100, increment = 100 },
            carry_over = true,
        })
        store:defineAchievement("first_steps", { title = "First Steps" })
        store:definePrestige("career", {
            condition = { level = { track = "character_xp", op = ">=", value = 100 } },
            reset = {
                level_tracks = { "character_xp" },
                counters = { "campaign_kills" },
            },
            preserve = {
                achievements = true,
                lifetime_counters = true,
            },
        })
        store:setLevel(profile, "character_xp", 100)
        store:addCounter("player", "campaign_kills", 42)
        store:unlockAchievement("player", "first_steps")

        local prestige = store:applyPrestige(profile, "career")

        expect_equal(1, prestige.count)
        expect_equal(42, prestige.lifetime_counters.campaign_kills)
        expect_equal(1, store:getLevel("player", "character_xp"))
        expect_equal(0, store:getCounter("player", "campaign_kills"))
        expect_true(store:getAchievement("player", "first_steps").unlocked)
    end)

    -- @covers LProgressionStore:getPrestige
    it("getPrestige returns the current per-profile prestige state", function()
        local store = new_store("prestige_get_case")
        local profile = store:createProfile("player")
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 200,
            curve = { base = 100, increment = 100 },
            carry_over = true,
        })
        store:definePrestige("career", {
            condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        })
        local prestige = store:getPrestige(profile, "career")
        expect_equal(0, prestige.count)
        expect_false(prestige.available)
    end)

    -- @covers LProgressionStore:listPrestiges
    it("listPrestiges returns authored prestige paths for one profile", function()
        local store = new_store("prestige_list_case")
        local profile = store:createProfile("player")
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 200,
            curve = { base = 100, increment = 100 },
            carry_over = true,
        })
        store:definePrestige("career", {
            condition = { level = { track = "character_xp", op = ">=", value = 100 } },
        })
        store:definePrestige("rebirth", {
            condition = { level = { track = "character_xp", op = ">=", value = 50 } },
        })
        local prestiges = store:listPrestiges(profile)
        expect_equal(2, #prestiges)
        expect_equal("career", prestiges[1].id)
        expect_equal("rebirth", prestiges[2].id)
    end)
end)

-- @describe LProgressionStore collections
describe("LProgressionStore collections", function()
    -- @covers LProgressionStore:defineCollection
    it("defineCollection stores achievement-set and codex item definitions", function()
        local store = new_store("collection_define_case")
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
        local profile = store:createProfile("player")
        local collection = store:getCollection(profile, "museum")
        expect_equal("museum", collection.id)
        expect_equal(2, collection.total_count)
        expect_equal("museum_complete", collection.meta_achievement_id)
    end)

    -- @covers LProgressionStore:collectCollectionItem
    it("collectCollectionItem reveals hidden codex entries and completes the set", function()
        local store = new_store("collection_collect_case")
        local profile = store:createProfile("player")
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
        store:unlockAchievement(profile, "boss_slayer")
        local partial = store:getCollection("player", "museum")
        expect_equal(0.5, partial.completion)
        expect_nil(partial.items[2].title)
        local collection = store:collectCollectionItem(profile, "museum", "secret_codex")
        expect_true(collection.complete)
        expect_equal("Secret Codex", collection.items[2].title)
        expect_true(store:getAchievement("player", "museum_complete").unlocked)
    end)

    -- @covers LProgressionStore:getCollection
    it("getCollection reports completion percentage and visible item state", function()
        local store = new_store("collection_get_case")
        local profile = store:createProfile("player")
        store:defineCollection("museum", {
            title = "Museum",
            items = {
                { id = "entry_a", title = "Entry A" },
                { id = "entry_b", title = "Entry B", hidden = true },
            },
        })
        local collection = store:getCollection(profile, "museum")
        expect_equal(0, collection.completion)
        expect_equal("Entry A", collection.items[1].title)
        expect_nil(collection.items[2].title)
    end)

    -- @covers LProgressionStore:listCollections
    it("listCollections returns authored collections for a profile", function()
        local store = new_store("collection_list_case")
        local profile = store:createProfile("player")
        store:defineCollection("museum", { title = "Museum", items = { { id = "entry_a", title = "Entry A" } } })
        store:defineCollection("bestiary", { title = "Bestiary", items = { { id = "slime", title = "Slime" } } })
        local collections = store:listCollections(profile)
        expect_equal(2, #collections)
        expect_equal("bestiary", collections[1].id)
        expect_equal("museum", collections[2].id)
    end)
end)

-- @describe LProgressionStore rivals and activity
describe("LProgressionStore rivals and activity", function()
    -- @covers LProgressionStore:pinRival
    it("pinRival stores a leaderboard-aware rival relationship", function()
        local store = new_store("rival_pin_case")
        local player = store:createProfile("player")
        local rival = store:createProfile("rival")
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
        })
        local pinned = store:pinRival(player, rival, { leaderboard_id = "arena" })
        expect_equal("player", pinned.profile_id)
        expect_equal("rival", pinned.rival_profile_id)
        expect_equal("arena", pinned.leaderboard_id)
    end)

    -- @covers LProgressionStore:getRival
    it("getRival returns the pinned rival snapshot", function()
        local store = new_store("rival_get_case")
        local player = store:createProfile("player")
        local rival = store:createProfile("rival")
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
        })
        store:submitScore(player, "arena", 5)
        store:submitScore(rival, "arena", 6)
        store:pinRival(player, rival, { leaderboard_id = "arena" })
        local snapshot = store:getRival("player", "rival")
        expect_equal("rival", snapshot.rival_profile_id)
        expect_equal(2, snapshot.delta.profile_rank)
        expect_equal(1, snapshot.delta.rival_rank)
    end)

    -- @covers LProgressionStore:listRivals
    it("listRivals returns pinned rivals in deterministic order", function()
        local store = new_store("rival_list_case")
        local player = store:createProfile("player")
        local alpha = store:createProfile("alpha")
        local beta = store:createProfile("beta")
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
        })
        store:pinRival(player, beta, { leaderboard_id = "arena" })
        store:pinRival(player, alpha, { leaderboard_id = "arena" })
        local rivals = store:listRivals("player")
        expect_equal(2, #rivals)
        expect_equal("alpha", rivals[1].rival_profile_id)
        expect_equal("beta", rivals[2].rival_profile_id)
    end)

    -- @covers LProgressionStore:getRivalDelta
    it("getRivalDelta reports rank and score deltas", function()
        local store = new_store("rival_delta_case")
        local player = store:createProfile("player")
        local rival = store:createProfile("rival")
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
        })
        store:submitScore(player, "arena", 5)
        store:submitScore(rival, "arena", 6)
        store:pinRival(player, rival, { leaderboard_id = "arena" })
        local delta = store:getRivalDelta(player, rival)
        expect_equal(2, delta.profile_rank)
        expect_equal(1, delta.rival_rank)
        expect_equal(-1, delta.score_delta)
    end)

    -- @covers LProgressionStore:getActivityFeed
    it("getActivityFeed filters retained events and includes rival overtakes", function()
        local store = new_store("activity_feed_case")
        local player = store:createProfile("player")
        local rival = store:createProfile("rival")
        store:defineLeaderboard("arena", {
            title = "Arena",
            sort = "descending",
            rank_mode = "ordinal",
        })
        store:submitScore(player, "arena", 5)
        store:submitScore(rival, "arena", 6)
        store:pinRival(player, rival, { leaderboard_id = "arena" })
        store:submitScore("player", "arena", 8)
        local feed = store:getActivityFeed({
            profiles = { player },
            types = { "profile_overtook_rival" },
            limit = 10,
        })
        local entries = feed:listEntries()
        expect_equal(1, feed:count())
        expect_equal(1, #entries)
        expect_equal("profile_overtook_rival", entries[1].event_type)
        expect_equal("rival", entries[1].payload.rivalProfileId)
    end)
end)

-- @describe LProgressionStore populations
describe("LProgressionStore populations", function()
    -- @covers LProgressionStore:definePopulationTemplate
    it("definePopulationTemplate registers a deterministic virtual population template", function()
        local store = new_store("population_define_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        expect_no_error(function()
            store:definePopulationTemplate("bots", {
                id_prefix = "bot_",
                count = 3,
                identity = {
                    name_generator = {
                        mode = "parts",
                        prefixes = { "Iron", "Silver" },
                        suffixes = { "Fox", "Wing" },
                    },
                    avatars = { "a.png", "b.png" },
                    tags = { "bot", "arena" },
                },
                archetypes = {
                    {
                        id = "steady",
                        weight = 2,
                        activity = { min = 1, max = 2 },
                        skill = { mean = 1200, deviation = 20 },
                    },
                },
                leaderboards = {
                    arena = {
                        category = "ranked",
                        initial_score = { distribution = "normal" },
                        progression = { mode = "bounded_random_walk", volatility = 4, mean_reversion = 0.2 },
                    },
                },
            })
        end)
        local report = store:validatePopulationTemplate("bots")
        expect_true(report.ok)
    end)

    -- @covers LProgressionStore:validatePopulationTemplate
    it("validatePopulationTemplate returns a report for the authored template", function()
        local store = new_store("population_validate_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 2,
            identity = {
                name_generator = {
                    mode = "parts",
                    prefixes = { "Iron" },
                    suffixes = { "Fox" },
                },
                tags = { "bot" },
            },
            archetypes = {
                {
                    id = "steady",
                    weight = 1,
                    activity = { min = 1, max = 1 },
                    skill = { mean = 1000, deviation = 10 },
                },
            },
            leaderboards = {
                arena = {
                    initial_score = { distribution = "normal" },
                    progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 },
                },
            },
        })
        local report = store:validatePopulationTemplate("bots")
        expect_equal("bots", report.template_id)
        expect_true(report.ok)
        expect_equal(0, #report.errors)
    end)

    -- @covers LProgressionStore:generatePopulation
    it("generatePopulation creates a stable population snapshot", function()
        local store = new_store("population_generate_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 2,
            identity = {
                name_generator = {
                    mode = "parts",
                    prefixes = { "Iron" },
                    suffixes = { "Fox", "Wing" },
                },
                tags = { "bot" },
            },
            archetypes = {
                {
                    id = "steady",
                    weight = 1,
                    activity = { min = 1, max = 2 },
                    skill = { mean = 1000, deviation = 10 },
                },
            },
            leaderboards = {
                arena = {
                    initial_score = { distribution = "normal" },
                    progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 },
                },
            },
        })
        local population = store:generatePopulation("bots", { id = "bots_run" })
        expect_equal("bots_run", population.id)
        expect_equal("bots", population.template_id)
        expect_equal(2, population.generated_count)
        expect_equal(2, population.active_count)
    end)

    -- @covers LProgressionStore:getPopulation
    it("getPopulation resolves a generated population by id", function()
        local store = new_store("population_get_case")
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
        expect_equal("bots_run", population.id)
        expect_equal(1, #population.profiles)
    end)

    -- @covers LProgressionStore:updatePopulation
    it("updatePopulation advances logical time and mutates simulated scores", function()
        local store = new_store("population_update_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        store:generatePopulation("bots", { id = "bots_run" })
        local before = store:listPopulationProfiles("bots_run")[1].leaderboard_scores.arena
        local report = store:updatePopulation("bots_run", 5)
        local after = store:listPopulationProfiles("bots_run")[1].leaderboard_scores.arena
        expect_equal(5, report.logical_time)
        expect_equal(1, report.updated_profiles)
        expect_true(before ~= after)
    end)

    -- @covers LProgressionStore:simulatePopulationUntil
    it("simulatePopulationUntil advances to an absolute logical time", function()
        local store = new_store("population_until_case")
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
        expect_equal(8, report.logical_time)
    end)

    -- @covers LProgressionStore:pausePopulation
    it("pausePopulation marks the simulation as paused", function()
        local store = new_store("population_pause_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        store:generatePopulation("bots", { id = "bots_run" })
        local snapshot = store:pausePopulation("bots_run")
        expect_true(snapshot.paused)
    end)

    -- @covers LProgressionStore:resumePopulation
    it("resumePopulation clears the paused flag", function()
        local store = new_store("population_resume_case")
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
        local snapshot = store:resumePopulation("bots_run")
        expect_equal(false, snapshot.paused)
    end)

    -- @covers LProgressionStore:getPopulationStatistics
    it("getPopulationStatistics reports aggregate leaderboard score metrics", function()
        local store = new_store("population_stats_case")
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
        expect_equal(2, stats.leaderboards.arena.count)
        expect_true(stats.leaderboards.arena.average ~= nil)
    end)

    -- @covers LProgressionStore:listPopulationProfiles
    it("listPopulationProfiles returns generated profile summaries", function()
        local store = new_store("population_list_case")
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
        expect_equal(1, #profiles)
        expect_equal("bots_run", profiles[1].population_id)
    end)

    -- @covers LProgressionStore:materializePopulationProfile
    it("materializePopulationProfile creates a real profile from a virtual row", function()
        local store = new_store("population_materialize_case")
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
        local profile = store:materializePopulationProfile(virtual_profile.profile_id)
        expect_equal(virtual_profile.profile_id, profile.id)
        expect_true(store:hasProfile(virtual_profile.profile_id))
    end)

    -- @covers LProgressionStore:dematerializePopulationProfile
    it("dematerializePopulationProfile can drop the real profile copy", function()
        local store = new_store("population_dematerialize_case")
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
        expect_true(store:dematerializePopulationProfile(virtual_profile.profile_id, { remove_profile = true }))
        expect_equal(false, store:hasProfile(virtual_profile.profile_id))
    end)

    -- @covers LProgressionStore:removePopulation
    it("removePopulation removes the generated instance", function()
        local store = new_store("population_remove_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        store:generatePopulation("bots", { id = "bots_run" })
        expect_true(store:removePopulation("bots_run"))
    end)

    -- @covers LProgressionStore:regeneratePopulation
    it("regeneratePopulation rebuilds the virtual roster from the template", function()
        local store = new_store("population_regenerate_case")
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
        expect_equal(0, regenerated.logical_time)
        expect_equal(1, regenerated.generated_count)
    end)

    -- @covers LProgressionStore:listLeaderboardTop
    it("listLeaderboardTop includes non-materialized virtual population profiles", function()
        local store = new_store("population_leaderboard_case")
        local player = store:createProfile("player")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:submitScore(player, "arena", 1)
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 2,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "steady", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        store:generatePopulation("bots", { id = "bots_run" })
        local rows = store:listLeaderboardTop("arena", 3)
        expect_equal(3, #rows)
        expect_true(rows[1].profile_id ~= "player")
    end)
end)

-- @describe LProgressionStore stats and resources
describe("LProgressionStore stats and resources", function()
    -- @covers LProgressionStore:defineAttribute
    it("defineAttribute and addModifier affect effective values", function()
        local store = new_store("attribute_case")
        local profile = store:createProfile("player")
        store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
        store:setAttributeBase(profile, "strength", 12)
        store:addModifier("player", "strength", { value = 5, layer = "final_add", duration = 10 })
        expect_equal(17, store:getAttribute(profile, "strength", "effective"))
    end)

    -- @covers LProgressionStore:getAttributeState
    it("getAttributeState returns base and effective values", function()
        local store = new_store("attribute_state_case")
        local profile = store:createProfile("player")
        store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
        store:setAttributeBase(profile, "strength", 12)
        local state = store:getAttributeState("player", "strength")
        expect_equal(12, state.base)
        expect_equal(12, state.effective)
    end)

    -- @covers LProgressionStore:addAttributeBase
    it("addAttributeBase increments an existing attribute base", function()
        local store = new_store("add_attribute_base_case")
        local profile = store:createProfile("player")
        store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
        store:setAttributeBase(profile, "strength", 12)
        expect_equal(15, store:addAttributeBase("player", "strength", 3))
    end)

    -- @covers LProgressionStore:explainAttribute
    it("explainAttribute reports modifier totals", function()
        local store = new_store("explain_attribute_case")
        local profile = store:createProfile("player")
        store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
        store:setAttributeBase(profile, "strength", 12)
        store:addModifier("player", "strength", { value = 4, layer = "final_add" })
        local explanation = store:explainAttribute("player", "strength")
        expect_equal(12, explanation.base)
        expect_equal(4, explanation.modifier_total)
        expect_equal(16, explanation.effective)
    end)

    -- @covers LProgressionStore:listModifiers
    it("listModifiers returns active modifier snapshots", function()
        local store = new_store("list_modifiers_case")
        local profile = store:createProfile("player")
        store:defineAttribute("strength", { base = 10, min = 0, max = 99 })
        local handle = store:addModifier(profile, "strength", { value = 4, layer = "final_add", source = "potion" })
        local modifiers = store:listModifiers("player")
        expect_equal(1, #modifiers)
        expect_equal(handle, modifiers[1].handle)
        expect_equal("potion", modifiers[1].source)
    end)

    -- @covers LProgressionStore:defineResource
    it("defineResource supports spend and refill operations", function()
        local store = new_store("resource_case")
        local profile = store:createProfile("player")
        store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
        expect_true(store:spendResource(profile, "stamina", 2))
        expect_equal(4, store:getResource("player", "stamina").value)
        store:refillResource("player", "stamina")
        expect_equal(10, store:getResource(profile, "stamina").value)
    end)

    -- @covers LProgressionStore:canSpendResource
    it("canSpendResource checks whether enough value exists", function()
        local store = new_store("can_spend_resource_case")
        local profile = store:createProfile("player")
        store:defineResource("stamina", { initial = 6, min = 0, max = 10, regeneration = 0, refill = "manual" })
        expect_true(store:canSpendResource(profile, "stamina", 6))
        expect_false(store:canSpendResource("player", "stamina", 7))
    end)

    -- @covers LProgressionStore:defineLevelTrack
    it("defineLevelTrack and addExperience advance levels with carry-over", function()
        local store = new_store("level_case")
        local profile = store:createProfile("player")
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 10,
            curve = { base = 100, increment = 50 },
            carry_over = true,
            allow_level_down = false,
        })
        local snapshot = store:addExperience(profile, "character_xp", 180)
        expect_equal(2, snapshot.level)
        expect_equal(80, snapshot.experience)
        expect_equal(70, store:getExperienceToNextLevel("player", "character_xp"))
    end)

    -- @covers LProgressionStore:setExperience
    it("setExperience and setLevel directly override track state", function()
        local store = new_store("set_level_case")
        local profile = store:createProfile("player")
        store:defineLevelTrack("character_xp", {
            initial_level = 1,
            max_level = 10,
            curve = { base = 100, increment = 50 },
            carry_over = true,
            allow_level_down = false,
        })
        local xp = store:setExperience(profile, "character_xp", 275)
        local forced = store:setLevel("player", "character_xp", 4)
        expect_true(xp.level >= 2)
        expect_equal(4, forced.level)
        expect_equal(0, forced.experience)
    end)
end)

-- @describe LProgressionStore quests and transactions
describe("LProgressionStore quests and transactions", function()
    -- @covers LProgressionStore:defineQuest
    it("defineQuest allows acceptQuest and objective completion", function()
        local store = new_store("quest_case")
        local profile = store:createProfile("player", { tags = { "hero" } })
        store:defineCounter("rats_killed", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineQuest("rat_hunt", {
            title = "Rat Hunt",
            reveal_condition = {
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
        store:acceptQuest(profile, "rat_hunt")
        store:addCounter("player", "rats_killed", 3)
        local quest = store:getQuestState("player", "rat_hunt")
        local rewards = profile:getPendingRewards()
        expect_equal("completed", quest.status)
        expect_equal(1, quest.completion_count)
        expect_equal(1, #rewards)
        expect_equal("quest", rewards[1].source_kind)
    end)

    -- @covers LProgressionStore:revealQuest
    it("quest lifecycle supports hidden revealed available and active states", function()
        local store = new_store("quest_lifecycle_case")
        local profile = store:createProfile("player")
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

        expect_equal("hidden", store:getQuestState("player", "arena").status)
        store:addCounter(profile, "wins", 1)
        expect_equal("revealed", store:getQuestState("player", "arena").status)
        store:addCounter(profile, "wins", 1)
        local available = store:getQuestState("player", "arena")
        expect_equal("available", available.status)
        expect_true(available.revealed)
        expect_true(available.available)
        store:acceptQuest(profile, "arena")
        expect_equal("active", store:getQuestState("player", "arena").status)
    end)

    -- @covers LQuestJournal:addEntry
    it("quest journal entries keep stable indexes and surface through the legacy adapter", function()
        local store = new_store("quest_journal_case")
        local profile = store:createProfile("player")
        store:defineQuest("journaled", {
            title = "Journaled",
            max_journal_entries = 2,
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        store:acceptQuest(profile, "journaled")
        local journal = store:getQuestState("player", "journaled"):getJournal()
        local first = journal:addEntry("Found clue", "discover")
        journal:addEntry("Opened door", "progress")
        local third = journal:addEntry("Reached boss")
        local entries = journal:listEntries()
        local adapter = lurek.progression.createLegacyQuestAdapter(store, "player")
        local quest = new_legacy_quest("journaled", "Journaled")
        quest._max_journal = 2
        quest.stages[1].name = "Stage"
        adapter:addQuest(quest)
        adapter:addJournalEntry("journaled", "Bonus note", "note")
        local copy = adapter:getQuest("journaled")

        expect_equal(0, first.index)
        expect_equal(2, third.index)
        expect_equal(2, #entries)
        expect_equal("Opened door", entries[1].text)
        expect_equal("Reached boss", entries[2].text)
        expect_equal(3, copy.journal[#copy.journal].index)
        expect_equal("Bonus note", copy.journal[#copy.journal].text)
    end)

    -- @covers LProgressionStore:setQuestObjectiveStatus
    it("objective visibility and skipped status are reflected in canonical quest state", function()
        local store = new_store("quest_objective_controls_case")
        local profile = store:createProfile("player")
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
        store:acceptQuest(profile, "stealth")
        local before = store:getQuestState("player", "stealth")
        local required_before
        for _, objective in ipairs(before.objectives) do
            if objective.id == "required" then
                required_before = objective
            end
        end
        expect_false(required_before.visible)

        store:setQuestObjectiveVisibility("player", "stealth", "required", true)
        local after = store:setQuestObjectiveStatus(profile, "stealth", "required", "skipped")
        local quest = store:getQuestState("player", "stealth")
        local required_after
        for _, objective in ipairs(quest.objectives) do
            if objective.id == "required" then
                required_after = objective
            end
        end
        expect_equal("completed", after.status)
        expect_equal("completed", quest.status)
        expect_equal("skipped", required_after.status)
        expect_true(required_after.visible)
    end)

    -- @covers LProgressionStore:completeQuest
    it("completeQuest and failQuest manually override lifecycle state", function()
        local store = new_store("quest_manual_case")
        local profile = store:createProfile("player")
        store:defineQuest("cleanup", {
            title = "Cleanup",
            stages = {
                { id = "stage_1", name = "Clear", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        store:acceptQuest(profile, "cleanup")
        store:failQuest("player", "cleanup")
        expect_equal("failed", store:getQuestState("player", "cleanup").status)
        store:acceptQuest("player", "cleanup")
        store:completeQuest(profile, "cleanup")
        expect_equal("completed", store:getQuestState("player", "cleanup").status)
    end)

    -- @covers LProgressionStore:evaluateCondition
    it("quest availability and achievement conditions use the shared evaluator", function()
        local store = new_store("condition_gate_case")
        local profile = store:createProfile("player", { tags = { "hero" } })
        store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:addCounter(profile, "wins", 2)
        store:defineQuest("gated_quest", {
            title = "Gated Quest",
            reveal_condition = {
                tag = "hero",
            },
            availability_condition = {
                all = {
                    { tag = "hero" },
                    { counter = "wins", op = ">=", value = 2 },
                },
            },
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        store:acceptQuest(profile, "gated_quest")
        expect_equal("active", store:getQuestState("player", "gated_quest").status)

        store:defineAchievement("gated_badge", {
            title = "Gated Badge",
            condition = { tag = "hero" },
        })
        local achievement = store:unlockAchievement("player", "gated_badge")
        expect_true(achievement.unlocked)
    end)

    -- @covers LProgressionStore:beginTransaction
    it("beginTransaction batches operations and commits them", function()
        local store = new_store("tx_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:defineResource("focus", { initial = 4, min = 0, max = 4, regeneration = 0, refill = "manual" })
        local tx = store:beginTransaction({ id = "battle_1" })
        tx:addCounter(profile, "wins", 1)
        tx:setResource("player", "focus", 2)
        local summary = tx:commit()
        expect_true(summary.revision >= 1)
        expect_equal(2, summary.changes)
        expect_equal(1, store:getCounter("player", "wins"))
        expect_equal(2, store:getResource("player", "focus").value)
    end)

    -- @covers LProgressionStore:exportSnapshot
    it("exportSnapshot and loadSnapshot preserve canonical state", function()
        local store = new_store("snapshot_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:addCounter(profile, "wins", 3)
        local snapshot = store:exportSnapshot()

        local restored = new_store("placeholder")
        restored:loadSnapshot(snapshot)

        expect_equal("snapshot_case", restored:getId())
        expect_equal(3, restored:getCounter("player", "wins"))
        expect_type("string", restored:getDefinitionHash())
    end)

    -- @covers LProgressionStore:exportChangesSince
    it("exportChangesSince and applyChangeset replicate the latest store snapshot", function()
        local source = new_store("changes_source_case")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        local profile = source:createProfile("player")
        source:addCounter(profile, "wins", 3)

        local changes = source:exportChangesSince(0)
        local target = new_store("changes_target_case")
        local applied = target:applyChangeset(changes)

        expect_true(applied.applied)
        expect_equal(3, target:getCounter("player", "wins"))
        expect_equal("player", target:getProfile("player").id)
    end)

    -- @covers LProgressionStore:exportChangeset
    it("exportChangeset returns bounded metadata-rich envelopes", function()
        local source = new_store("changes_envelope_case")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        local profile = source:createProfile("player")
        source:addCounter(profile, "wins", 1)
        source:addCounter(profile, "wins", 2)
        source:addCounter(profile, "wins", 3)

        local envelope = lurek.serialize.fromJson(source:exportChangeset(0, { max_records = 2 }))
        expect_true(envelope.truncated)
        expect_equal(2, #envelope.records)
        expect_equal(source:getSchemaVersion(), envelope.schema_version)
        expect_equal(source:getDefinitionHash(), envelope.definition_hash)
    end)

    -- @covers LProgressionStore:applyChangesetEnvelope
    it("applyChangesetEnvelope enforces hash checks and restores the newest snapshot", function()
        local source = new_store("changes_envelope_apply_case")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        local profile = source:createProfile("player")
        source:addCounter(profile, "wins", 1)
        source:addCounter(profile, "wins", 2)
        source:addCounter(profile, "wins", 3)
        local encoded = source:exportChangeset(0)
        local envelope = lurek.serialize.fromJson(encoded)

        local target = new_store("changes_envelope_target_case")
        target:defineCounter("wins", { kind = "integer", initial = 0 })
        local applied = target:applyChangesetEnvelope(encoded, {
            require_definition_hash_match = true,
            require_schema_match = true,
        })
        expect_true(applied.applied)
        expect_equal(6, target:getCounter("player", "wins"))

        local mismatch = new_store("changes_envelope_mismatch_case")
        local ok = pcall(function()
            mismatch:applyChangesetEnvelope(encoded, {
                require_definition_hash_match = true,
                require_schema_match = true,
            })
        end)
        expect_equal(false, ok)
    end)

    -- @covers LProgressionStore:setQuestObjective
    it("applyChangesetEnvelope reports conflicts and honors merge_policy", function()
        local source = new_store("changes_envelope_merge_source")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        source:defineQuest("cleanup", {
            title = "Cleanup",
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        local source_profile = source:createProfile("player")
        source:addCounter(source_profile, "wins", 1)
        source:acceptQuest("player", "cleanup")
        local encoded = source:exportChangeset(0)

        local keep_local = new_store("changes_envelope_keep_local")
        keep_local:defineCounter("wins", { kind = "integer", initial = 0 })
        keep_local:defineQuest("cleanup", {
            title = "Cleanup",
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        local local_profile = keep_local:createProfile("player")
        keep_local:createProfile("local_only")
        keep_local:addCounter(local_profile, "wins", 5)
        keep_local:acceptQuest("player", "cleanup")
        keep_local:setQuestObjective("player", "cleanup", "step", 1)
        local kept = keep_local:applyChangesetEnvelope(encoded, {
            require_definition_hash_match = true,
            require_schema_match = true,
            merge_policy = "keep_local",
        })
        expect_false(kept.applied)
        expect_equal("kept_local_due_to_conflicts", kept.reason)
        expect_true(kept.conflictCount >= 2)
        expect_equal(5, keep_local:getCounter("player", "wins"))
        expect_true(keep_local:hasProfile("local_only"))

        local replace = new_store("changes_envelope_replace")
        replace:defineCounter("wins", { kind = "integer", initial = 0 })
        replace:defineQuest("cleanup", {
            title = "Cleanup",
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        local replace_profile = replace:createProfile("player")
        replace:createProfile("local_only")
        replace:addCounter(replace_profile, "wins", 5)
        replace:acceptQuest("player", "cleanup")
        replace:setQuestObjective("player", "cleanup", "step", 1)
        local replaced = replace:applyChangesetEnvelope(encoded, {
            require_definition_hash_match = true,
            require_schema_match = true,
            merge_policy = "replace",
        })
        expect_true(replaced.applied)
        expect_equal("replaced_with_conflicts", replaced.reason)
        expect_equal(1, replace:getCounter("player", "wins"))
        expect_false(replace:hasProfile("local_only"))

        local rejected = new_store("changes_envelope_rejected")
        rejected:defineCounter("wins", { kind = "integer", initial = 0 })
        rejected:defineQuest("cleanup", {
            title = "Cleanup",
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        local rejected_profile = rejected:createProfile("player")
        rejected:createProfile("local_only")
        rejected:addCounter(rejected_profile, "wins", 5)
        rejected:acceptQuest("player", "cleanup")
        rejected:setQuestObjective("player", "cleanup", "step", 1)
        local rejected_report = rejected:applyChangesetEnvelope(encoded, {
            require_definition_hash_match = true,
            require_schema_match = true,
            merge_policy = "reject_conflicts",
        })
        expect_false(rejected_report.applied)
        expect_equal("conflict", rejected_report.reason)
        expect_equal(5, rejected:getCounter("player", "wins"))
        expect_true(rejected:hasProfile("local_only"))
    end)

    -- @covers LProgressionStore:getSchemaVersion
    it("changeset APIs reject malformed and oversized payloads", function()
        local source = new_store("changes_envelope_guard_source")
        local malformed = lurek.serialize.toJson({
            schema_version = source:getSchemaVersion(),
            definition_hash = source:getDefinitionHash(),
            from_revision = 1,
            to_revision = 2,
            truncated = false,
            records = {
                { revision = 1, snapshot = {} },
            },
        })
        local malformed_ok = pcall(function()
            source:applyChangesetEnvelope(malformed, {
                require_definition_hash_match = true,
                require_schema_match = true,
            })
        end)
        expect_false(malformed_ok)

        local oversized_snapshot = {
            blob = string.rep("x", 300000),
        }
        local oversized = lurek.serialize.toJson({
            schema_version = source:getSchemaVersion(),
            definition_hash = source:getDefinitionHash(),
            from_revision = 0,
            to_revision = 1,
            truncated = false,
            records = {
                { revision = 1, snapshot = oversized_snapshot },
            },
        })
        local oversized_ok = pcall(function()
            source:applyChangesetEnvelope(oversized, {
                require_definition_hash_match = true,
                require_schema_match = true,
            })
        end)
        expect_false(oversized_ok)

        local old_style_ok = pcall(function()
            source:applyChangeset(lurek.serialize.toJson({
                { revision = 1, snapshot = oversized_snapshot },
            }))
        end)
        expect_false(old_style_ok)
    end)

    -- @covers LProgressionStore:ackChangesThrough
    it("ackChangesThrough removes retained records up to the acknowledged revision", function()
        local source = new_store("changes_envelope_ack_case")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        local profile = source:createProfile("player")
        source:addCounter(profile, "wins", 1)
        source:addCounter(profile, "wins", 2)
        local first = lurek.serialize.fromJson(source:exportChangesSince(0))[1]
        local ack = source:ackChangesThrough(first.revision)
        expect_equal(1, ack.removedCount)
        expect_equal(2, ack.remainingCount)
    end)

    -- @covers LProgressionStore:compactChanges
    it("compactChanges keeps only the newest retained change records", function()
        local source = new_store("changes_envelope_compact_case")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        local profile = source:createProfile("player")
        source:addCounter(profile, "wins", 1)
        source:addCounter(profile, "wins", 2)
        source:addCounter(profile, "wins", 3)
        local compact = source:compactChanges(1)
        expect_equal(1, compact.afterCount)
    end)
end)

-- @describe LProgressionStore achievements and rewards
describe("LProgressionStore achievements and rewards", function()
    -- @covers LProgressionStore:defineChallengeTemplate
    it("challenge templates support activation progress filters rewards and expiry", function()
        local store = new_store("challenge_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
        store:defineChallengeTemplate("win_streak", {
            title = "Win Streak",
            description = "Win three matches",
            required = 3,
            counter_id = "wins",
            tags = { "daily" },
            reward_payload = {
                currency = 25,
            },
        })
        store:defineChallengeTemplate("timed_route", {
            title = "Timed Route",
            required = 2,
            duration = 5,
            repeatable = true,
        })

        local started = store:activateChallenge(profile, "win_streak")
        expect_equal("active", started.status)
        expect_equal("daily", started.tags[1])
        store:addCounter("player", "wins", 2)
        expect_equal(2, store:getChallenge("player", "win_streak").current)
        store:addCounter(profile, "wins", 1)

        local completed = store:getChallenge("player", "win_streak")
        local completed_list = store:listChallenges("player", { status = "completed" })
        local rewards = profile:getPendingRewards()
        expect_equal("completed", completed.status)
        expect_equal(1, completed.completion_count)
        expect_equal(1, #completed_list)
        expect_equal("challenge", rewards[1].source_kind)

        store:activateChallenge("player", "timed_route", { time = 0 })
        local manual = store:setChallengeProgress("player", "timed_route", 1)
        expect_equal("active", manual.status)
        expect_equal(1, manual.current)
        store:advanceTime(6)
        local expired = store:getChallenge(profile, "timed_route")
        local expired_list = store:listChallenges("player", { status = "expired" })
        expect_equal("expired", expired.status)
        expect_equal(1, #expired_list)
    end)

    -- @covers LProgressionStore:defineAchievement
    it("defineAchievement unlocks automatically from counter triggers", function()
        local store = new_store("achievement_counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "cumulative_integer", initial = 0, min = 0, monotonic = true })
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

        store:addCounter(profile, "wins", 1)

        local achievement = store:getAchievement("player", "first_win")
        local rewards = profile:getPendingRewards()
        expect_true(achievement.unlocked)
        expect_equal(1, achievement.unlock_count)
        expect_equal(1, #rewards)
        expect_equal("pending", rewards[1].state)
    end)

    -- @covers LProgressionStore:unlockAchievement
    it("unlockAchievement supports repeatable reward records and lifecycle transitions", function()
        local store = new_store("achievement_manual_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", {
            title = "Manual Reward",
            repeatable = true,
            reward_payload = {
                items = { "token" },
            },
        })

        local first = store:unlockAchievement(profile, "manual_reward")
        local reward_id = "achievement:manual_reward:" .. tostring(first.unlock_count)
        local claimed = profile:getPendingRewards()[1]:claim()
        local applied = claimed:markApplied("receipt-1")

        expect_equal(1, first.unlock_count)
        expect_equal("claimed", claimed.state)
        expect_equal("applied", applied.state)
        expect_equal("receipt-1", applied.external_receipt)

        store:unlockAchievement("player", "manual_reward")
        local rejected = profile:getPendingRewards()[1]:reject("inventory_full")
        expect_equal("rejected", rejected.state)
    end)

    -- @covers LProgressionStore:listAchievements
    it("listAchievements returns canonical achievement snapshots", function()
        local store = new_store("list_achievements_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        store:unlockAchievement(profile, "manual_reward")
        local achievements = store:listAchievements("player")
        expect_equal(1, #achievements)
        expect_equal("manual_reward", achievements[1].id)
        expect_true(achievements[1].unlocked)
    end)
end)

-- @describe lurek.progression legacy stats wrappers
describe("lurek.progression legacy stats wrappers", function()
    -- @covers lurek.progression.get
    it("get reads effective attribute values through the legacy stats wrapper", function()
        local _, adapter = new_stats_adapter("legacy_get_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        expect_equal(100, adapter:get("hp"))
    end)

    -- @covers lurek.progression.setRegen
    it("setRegen stores regeneration metadata on a legacy stat definition", function()
        local _, adapter = new_stats_adapter("legacy_set_regen_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        adapter:setRegen("hp", 2.5)
        expect_equal(2.5, adapter:getRegen("hp"))
    end)

    -- @covers lurek.progression.getRegen
    it("getRegen returns stored regeneration metadata", function()
        local _, adapter = new_stats_adapter("legacy_get_regen_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        adapter:setRegen("hp", 1.25)
        expect_equal(1.25, adapter:getRegen("hp"))
    end)

    -- @covers lurek.progression.getStatNames
    it("getStatNames lists authored legacy stat ids in sorted order", function()
        local _, adapter = new_stats_adapter("legacy_stat_names_case")
        adapter:define("agi", 8, { min = 0, max = 20 })
        adapter:define("hp", 100, { min = 0, max = 150 })
        local names = adapter:getStatNames()
        expect_equal("agi", names[1])
        expect_equal("hp", names[2])
    end)

    -- @covers lurek.progression.addBuff
    it("addBuff returns a removable modifier handle", function()
        local _, adapter = new_stats_adapter("legacy_add_buff_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        local handle = adapter:addBuff("hp", 12, 1, 3, "potion")
        expect_type("string", handle)
        expect_equal(1, adapter:getBuffCount("hp"))
    end)

    -- @covers lurek.progression.removeBuff
    it("removeBuff clears one modifier by handle", function()
        local _, adapter = new_stats_adapter("legacy_remove_buff_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        local handle = adapter:addBuff("hp", 12, 1, 3, "potion")
        expect_true(adapter:removeBuff(handle))
        expect_equal(0, adapter:getBuffCount("hp"))
    end)

    -- @covers lurek.progression.clearBuffs
    it("clearBuffs removes all matching legacy modifiers", function()
        local _, adapter = new_stats_adapter("legacy_clear_buffs_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        adapter:addBuff("hp", 5, 1, 1, "a")
        adapter:addBuff("hp", 7, 1, 1, "b")
        adapter:clearBuffs("hp")
        expect_equal(0, adapter:getBuffCount("hp"))
    end)

    -- @covers lurek.progression.getBuffCount
    it("getBuffCount reports active modifier totals", function()
        local _, adapter = new_stats_adapter("legacy_get_buff_count_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        adapter:addBuff("hp", 5, 1, 1, "a")
        adapter:addBuff("hp", 7, 1, 1, "b")
        expect_equal(2, adapter:getBuffCount("hp"))
    end)

    -- @covers lurek.progression.applyTraitBuffs
    it("applyTraitBuffs activates a registered legacy trait", function()
        local store, adapter = new_stats_adapter("legacy_apply_trait_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        define_legacy_trait(store, "progression_tough", "hp", 20)
        adapter:applyTraitBuffs("progression_tough")
        expect_true(adapter:hasTrait("progression_tough"))
    end)

    -- @covers lurek.progression.removeTraitBuffs
    it("removeTraitBuffs deactivates a registered legacy trait", function()
        local store, adapter = new_stats_adapter("legacy_remove_trait_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        define_legacy_trait(store, "progression_nimble", "hp", 10)
        adapter:applyTraitBuffs("progression_nimble")
        expect_true(adapter:removeTraitBuffs("progression_nimble"))
        expect_false(adapter:hasTrait("progression_nimble"))
    end)

    -- @covers lurek.progression.getActiveTraits
    it("getActiveTraits returns active legacy trait ids", function()
        local store, adapter = new_stats_adapter("legacy_active_traits_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        define_legacy_trait(store, "progression_brave", "hp", 10)
        adapter:applyTraitBuffs("progression_brave")
        local traits = adapter:getActiveTraits()
        expect_equal("progression_brave", traits[1])
    end)

    -- @covers lurek.progression.getBuffs
    it("getBuffs returns structured modifier snapshots", function()
        local _, adapter = new_stats_adapter("legacy_get_buffs_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        local handle = adapter:addBuff("hp", 5, 1, 2, "potion")
        local buffs = adapter:getBuffs("hp")
        expect_equal(handle, buffs[1].handle)
        expect_equal("potion", buffs[1].source)
    end)

    -- @covers lurek.progression.getXP
    it("getXP reads the legacy experience track value", function()
        local _, adapter = new_stats_adapter("legacy_get_xp_case")
        adapter:addXP(75)
        expect_equal(75, adapter:getXP())
    end)

    -- @covers lurek.progression.setXP
    it("setXP overwrites the legacy experience track value", function()
        local _, adapter = new_stats_adapter("legacy_set_xp_case")
        adapter:setXP(180)
        expect_equal(80, adapter:getXP())
        expect_equal(2, adapter:getLevel())
    end)

    -- @covers lurek.progression.getSkillLevel
    it("getSkillLevel reports the learned legacy skill level", function()
        local _, adapter = new_stats_adapter("legacy_get_skill_level_case")
        adapter:define("mana", 100, { min = 0, max = 100 })
        adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 3 })
        adapter:learnSkill("heal")
        expect_equal(1, adapter:getSkillLevel("heal"))
    end)

    -- @covers lurek.progression.getCooldownRemaining
    it("getCooldownRemaining reports legacy skill cooldown state", function()
        local _, adapter = new_stats_adapter("legacy_get_cooldown_case")
        adapter:define("mana", 100, { min = 0, max = 100 })
        adapter:defineSkill("heal", { resource = "mana", cost = 20, cooldown = 5 })
        adapter:learnSkill("heal")
        adapter:useSkill("heal")
        expect_equal(5, adapter:getCooldownRemaining("heal"))
    end)

    -- @covers lurek.progression.setActionPoints
    it("setActionPoints seeds current and max action points", function()
        local _, adapter = new_stats_adapter("legacy_set_ap_case")
        adapter:setActionPoints(6)
        local current, max_value = adapter:getActionPoints()
        expect_equal(6, current)
        expect_equal(6, max_value)
    end)

    -- @covers lurek.progression.getActionPoints
    it("getActionPoints returns the current and max action point tuple", function()
        local _, adapter = new_stats_adapter("legacy_get_ap_case")
        adapter:setActionPoints(5)
        local current, max_value = adapter:getActionPoints()
        expect_equal(5, current)
        expect_equal(5, max_value)
    end)

    -- @covers lurek.progression.spendActionPoints
    it("spendActionPoints consumes from the legacy action point resource", function()
        local _, adapter = new_stats_adapter("legacy_spend_ap_case")
        adapter:setActionPoints(5)
        expect_true(adapter:spendActionPoints(2))
        local current = select(1, adapter:getActionPoints())
        expect_equal(3, current)
    end)

    -- @covers lurek.progression.recoverActionPoints
    it("recoverActionPoints restores spent action points", function()
        local _, adapter = new_stats_adapter("legacy_recover_ap_case")
        adapter:setActionPoints(5)
        adapter:spendActionPoints(3)
        adapter:recoverActionPoints(2)
        local current = select(1, adapter:getActionPoints())
        expect_equal(4, current)
    end)

    -- @covers lurek.progression.beginTurn
    it("beginTurn refills the legacy action point pool to max", function()
        local _, adapter = new_stats_adapter("legacy_begin_turn_case")
        adapter:setActionPoints(6)
        adapter:spendActionPoints(4)
        adapter:beginTurn()
        local current = select(1, adapter:getActionPoints())
        expect_equal(6, current)
    end)

    -- @covers lurek.progression.setMorale
    it("setMorale seeds current and max morale", function()
        local _, adapter = new_stats_adapter("legacy_set_morale_case")
        adapter:setMorale(10)
        local current, max_value = adapter:getMorale()
        expect_equal(10, current)
        expect_equal(10, max_value)
    end)

    -- @covers lurek.progression.getMorale
    it("getMorale returns the current and max morale tuple", function()
        local _, adapter = new_stats_adapter("legacy_get_morale_case")
        adapter:setMorale(12)
        local current, max_value = adapter:getMorale()
        expect_equal(12, current)
        expect_equal(12, max_value)
    end)

    -- @covers lurek.progression.adjustMorale
    it("adjustMorale applies a signed delta to morale", function()
        local _, adapter = new_stats_adapter("legacy_adjust_morale_case")
        adapter:setMorale(10)
        adapter:adjustMorale(-3)
        local current = select(1, adapter:getMorale())
        expect_equal(7, current)
    end)

    -- @covers lurek.progression.setPanicThreshold
    it("setPanicThreshold changes the threshold used by checkMorale", function()
        local _, adapter = new_stats_adapter("legacy_panic_threshold_case")
        adapter:setMorale(10)
        adapter:setPanicThreshold(8)
        adapter:setBerserkThreshold(4)
        adapter:adjustMorale(-3)
        expect_equal("panic", adapter:checkMorale())
    end)

    -- @covers lurek.progression.setBerserkThreshold
    it("setBerserkThreshold changes the lower morale threshold", function()
        local _, adapter = new_stats_adapter("legacy_berserk_threshold_case")
        adapter:setMorale(10)
        adapter:setPanicThreshold(7)
        adapter:setBerserkThreshold(4)
        adapter:adjustMorale(-7)
        expect_equal("berserk", adapter:checkMorale())
    end)

    -- @covers lurek.progression.checkMorale
    it("checkMorale reports panic or berserk states from current morale", function()
        local _, adapter = new_stats_adapter("legacy_check_morale_case")
        adapter:setMorale(10)
        adapter:setPanicThreshold(6)
        adapter:setBerserkThreshold(3)
        adapter:adjustMorale(-5)
        expect_equal("panic", adapter:checkMorale())
    end)

    -- @covers lurek.progression.clearFlag
    it("clearFlag removes a previously set legacy flag", function()
        local _, adapter = new_stats_adapter("legacy_clear_flag_case")
        adapter:setFlag("panic")
        adapter:clearFlag("panic")
        expect_false(adapter:hasFlag("panic"))
    end)

    -- @covers lurek.progression.getFlags
    it("getFlags returns sorted enabled legacy flags", function()
        local _, adapter = new_stats_adapter("legacy_get_flags_case")
        adapter:setFlag("panic")
        adapter:setFlag("wounded")
        local flags = adapter:getFlags()
        expect_equal("panic", flags[1])
        expect_equal("wounded", flags[2])
    end)

    -- @covers lurek.progression.setResistance
    it("setResistance writes legacy typed resistance values", function()
        local _, adapter = new_stats_adapter("legacy_set_resistance_case")
        adapter:setResistance("fire", 0.25)
        expect_equal(0.25, adapter:getResistance("fire"))
    end)

    -- @covers lurek.progression.getResistance
    it("getResistance returns legacy typed resistance values", function()
        local _, adapter = new_stats_adapter("legacy_get_resistance_case")
        adapter:setResistance("ice", 0.5)
        expect_equal(0.5, adapter:getResistance("ice"))
    end)

    -- @covers lurek.progression.applyDamage
    it("applyDamage reduces a legacy stat after resistance mitigation", function()
        local _, adapter = new_stats_adapter("legacy_apply_damage_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        adapter:setResistance("fire", 0.25)
        local actual = adapter:applyDamage("hp", 40, "fire")
        expect_equal(30, actual)
        expect_equal(70, adapter:getBase("hp"))
    end)

    -- @covers lurek.progression.recordUse
    it("recordUse increments a legacy usage counter", function()
        local _, adapter = new_stats_adapter("legacy_record_use_case")
        adapter:recordUse("heal")
        adapter:recordUse("heal")
        expect_equal(2, adapter:getUseCount("heal"))
    end)

    -- @covers lurek.progression.getUseCount
    it("getUseCount returns the recorded legacy usage total", function()
        local _, adapter = new_stats_adapter("legacy_get_use_count_case")
        adapter:recordUse("dash")
        expect_equal(1, adapter:getUseCount("dash"))
    end)

    -- @covers lurek.progression.setEncumbrance
    it("setEncumbrance stores current and max carrying load", function()
        local _, adapter = new_stats_adapter("legacy_set_enc_case")
        adapter:setEncumbrance(12, 20)
        local encumbrance = adapter:getEncumbrance()
        expect_equal(12, encumbrance.current)
        expect_equal(20, encumbrance.max)
    end)

    -- @covers lurek.progression.getEncumbrance
    it("getEncumbrance returns the stored carrying load snapshot", function()
        local _, adapter = new_stats_adapter("legacy_get_enc_case")
        adapter:setEncumbrance(14, 20)
        local encumbrance = adapter:getEncumbrance()
        expect_equal(14, encumbrance.current)
        expect_equal(20, encumbrance.max)
    end)

    -- @covers lurek.progression.isEncumbered
    it("isEncumbered reports when current load exceeds max", function()
        local _, adapter = new_stats_adapter("legacy_is_enc_case")
        adapter:setEncumbrance(21, 20)
        expect_true(adapter:isEncumbered())
    end)

    -- @covers lurek.progression.setInitiative
    it("setInitiative overwrites the stored legacy initiative value", function()
        local _, adapter = new_stats_adapter("legacy_set_initiative_case")
        adapter:setInitiative(17)
        expect_equal(17, adapter:getInitiative())
    end)

    -- @covers lurek.progression.getInitiative
    it("getInitiative returns the stored legacy initiative value", function()
        local _, adapter = new_stats_adapter("legacy_get_initiative_case")
        adapter:setInitiative(19)
        expect_equal(19, adapter:getInitiative())
    end)
end)

-- @describe lurek.progression legacy quest wrappers
describe("lurek.progression legacy quest wrappers", function()
    -- @covers lurek.progression.questIds
    it("questIds returns the authored quest order", function()
        local _, adapter = new_quest_adapter("legacy_quest_ids_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:addQuest(new_legacy_quest("boss", "Boss"))
        local ids = adapter:questIds()
        expect_equal("cleanup", ids[1])
        expect_equal("boss", ids[2])
    end)

    -- @covers lurek.progression.removeQuest
    it("removeQuest removes one authored legacy quest", function()
        local _, adapter = new_quest_adapter("legacy_remove_quest_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        expect_true(adapter:removeQuest("cleanup"))
        expect_equal(0, adapter:questCount())
    end)

    -- @covers lurek.progression.questsWithStatus
    it("questsWithStatus filters authored quest ids by live status", function()
        local _, adapter = new_quest_adapter("legacy_quests_with_status_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:startQuest("cleanup")
        local ids = adapter:questsWithStatus("active")
        expect_equal("cleanup", ids[1])
    end)

    -- @covers lurek.progression.activeIds
    it("activeIds lists active legacy quests", function()
        local _, adapter = new_quest_adapter("legacy_active_ids_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:startQuest("cleanup")
        local ids = adapter:activeIds()
        expect_equal("cleanup", ids[1])
    end)

    -- @covers lurek.progression.completedIds
    it("completedIds lists completed legacy quests", function()
        local _, adapter = new_quest_adapter("legacy_completed_ids_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:startQuest("cleanup")
        adapter:advanceObjective("cleanup", "step", 1)
        local ids = adapter:completedIds()
        expect_equal("cleanup", ids[1])
    end)

    -- @covers lurek.progression.failedIds
    it("failedIds lists failed legacy quests", function()
        local _, adapter = new_quest_adapter("legacy_failed_ids_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:startQuest("cleanup")
        adapter:failQuest("cleanup")
        local ids = adapter:failedIds()
        expect_equal("cleanup", ids[1])
    end)

    -- @covers lurek.progression.completedCount
    it("completedCount reports how many legacy quests are completed", function()
        local _, adapter = new_quest_adapter("legacy_completed_count_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:startQuest("cleanup")
        adapter:advanceObjective("cleanup", "step", 1)
        expect_equal(1, adapter:completedCount())
    end)

    -- @covers lurek.progression.setQuestReward
    it("setQuestReward stores reward text on a legacy quest definition", function()
        local _, adapter = new_quest_adapter("legacy_set_quest_reward_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:setQuestReward("cleanup", "gold")
        expect_equal("gold", adapter:getQuestReward("cleanup"))
    end)

    -- @covers lurek.progression.getQuestReward
    it("getQuestReward returns stored reward text for a legacy quest", function()
        local _, adapter = new_quest_adapter("legacy_get_quest_reward_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:setQuestReward("cleanup", "gold")
        expect_equal("gold", adapter:getQuestReward("cleanup"))
    end)

    -- @covers lurek.progression.resetQuest
    it("resetQuest moves a completed quest back to available", function()
        local _, adapter = new_quest_adapter("legacy_reset_quest_case")
        adapter:addQuest(new_legacy_quest("cleanup", "Cleanup"))
        adapter:startQuest("cleanup")
        adapter:advanceObjective("cleanup", "step", 1)
        expect_true(adapter:resetQuest("cleanup"))
        expect_equal(1, adapter:questCount())
    end)
end)

-- @describe LProgressionStore explicit progression wrappers
describe("LProgressionStore explicit progression wrappers", function()
    -- @covers LProgressionStore:setCounter
    it("setCounter writes an exact counter value without delta semantics", function()
        local store = new_store("store_set_counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:setCounter(profile, "wins", 7)
        expect_equal(7, store:getCounter("player", "wins"))
    end)

    -- @covers LProgressionStore:getSkillLevel
    it("getSkillLevel returns the learned store skill rank", function()
        local store = new_store("store_get_skill_level_case")
        local profile = store:createProfile("player")
        store:defineAttribute("mana", { base = 100, min = 0, max = 100 })
        store:setAttributeBase(profile, "mana", 100)
        store:defineSkill("heal", { max_level = 5, resource = "mana", cost = 20, cooldown = 3 })
        store:learnSkill(profile, "heal")
        expect_equal(1, store:getSkillLevel("player", "heal"))
    end)
end)

-- @describe LProgressionTransaction explicit progression wrappers
describe("LProgressionTransaction explicit progression wrappers", function()
    -- @covers LProgressionTransaction:setCounter
    it("setCounter queues an absolute counter write inside a transaction", function()
        local store = new_store("tx_set_counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        local tx = store:beginTransaction({ id = "set_counter_tx" })
        tx:setCounter(profile, "wins", 9)
        tx:commit()
        expect_equal(9, store:getCounter("player", "wins"))
    end)

    -- @covers LProgressionTransaction:rollback
    it("rollback clears queued changes before they are committed", function()
        local store = new_store("tx_rollback_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        local tx = store:beginTransaction({ id = "rollback_tx" })
        tx:addCounter(profile, "wins", 4)
        tx:rollback()
        expect_equal(0, store:getCounter("player", "wins"))
    end)
end)

-- @describe lurek.progression missing explicit wrapper owners
describe("lurek.progression missing explicit wrapper owners", function()
    -- @covers lurek.progression.define
    it("define authors a legacy stat definition through the adapter wrapper", function()
        local adapter = new_hp_stats_adapter("legacy_define_case")
        expect_equal(100, adapter:get("hp"))
    end)

    -- @covers lurek.progression.getBase
    it("getBase returns the authored legacy stat base value", function()
        local adapter = new_hp_stats_adapter("legacy_get_base_case")
        expect_equal(100, adapter:getBase("hp"))
    end)

    -- @covers lurek.progression.setBase
    it("setBase overwrites the authored legacy stat base value", function()
        local adapter = new_hp_stats_adapter("legacy_set_base_case")
        adapter:setBase("hp", 120)
        expect_equal(120, adapter:getBase("hp"))
    end)

    -- @covers lurek.progression.setMin
    it("setMin updates the lower legacy stat bound", function()
        local adapter = new_hp_stats_adapter("legacy_set_min_case")
        adapter:setMin("hp", 10)
        expect_equal(10, adapter:getMin("hp"))
    end)

    -- @covers lurek.progression.setMax
    it("setMax updates the upper legacy stat bound", function()
        local adapter = new_hp_stats_adapter("legacy_set_max_case")
        adapter:setMax("hp", 175)
        expect_equal(175, adapter:getMax("hp"))
    end)

    -- @covers lurek.progression.getMin
    it("getMin returns the lower legacy stat bound", function()
        local adapter = new_hp_stats_adapter("legacy_get_min_case")
        expect_equal(0, adapter:getMin("hp"))
    end)

    -- @covers lurek.progression.getMax
    it("getMax returns the upper legacy stat bound", function()
        local adapter = new_hp_stats_adapter("legacy_get_max_case")
        expect_equal(150, adapter:getMax("hp"))
    end)

    -- @covers lurek.progression.hasTrait
    it("hasTrait reports whether a legacy trait is active", function()
        local store, adapter = new_stats_adapter("legacy_has_trait_case")
        adapter:define("hp", 100, { min = 0, max = 150 })
        define_legacy_trait(store, "progression_has_trait", "hp", 10)
        adapter:applyTraitBuffs("progression_has_trait")
        expect_true(adapter:hasTrait("progression_has_trait"))
    end)

    -- @covers lurek.progression.setLevelThresholds
    it("setLevelThresholds reconfigures the legacy XP thresholds", function()
        local _, adapter = new_stats_adapter("legacy_set_level_thresholds_case")
        adapter:setLevelThresholds({ kind = "table", values = { 50, 100, 200 } })
        adapter:addXP(160)
        expect_equal(3, adapter:getLevel())
        expect_equal(10, adapter:getXP())
    end)

    -- @covers lurek.progression.addXP
    it("addXP increases legacy experience and can advance the legacy level", function()
        local _, adapter = new_stats_adapter("legacy_add_xp_case")
        adapter:addXP(150)
        expect_true(adapter:getLevel() >= 2)
    end)

    -- @covers lurek.progression.getLevel
    it("getLevel returns the current legacy level track level", function()
        local _, adapter = new_stats_adapter("legacy_get_level_case")
        adapter:addXP(150)
        expect_equal(2, adapter:getLevel())
    end)

    -- @covers lurek.progression.setLevel
    it("setLevel overwrites the current legacy level track level", function()
        local _, adapter = new_stats_adapter("legacy_set_level_case")
        adapter:setLevel(3)
        expect_equal(3, adapter:getLevel())
    end)

    -- @covers lurek.progression.defineSkill
    it("defineSkill authors a legacy skill that can be learned", function()
        local adapter = new_skill_stats_adapter("legacy_define_skill_case")
        adapter:learnSkill("heal")
        expect_equal(1, adapter:getSkillLevel("heal"))
    end)

    -- @covers lurek.progression.learnSkill
    it("learnSkill unlocks a legacy skill for the profile", function()
        local adapter = new_skill_stats_adapter("legacy_learn_skill_case")
        adapter:learnSkill("heal")
        expect_equal(1, adapter:getSkillLevel("heal"))
    end)

    -- @covers lurek.progression.useSkill
    it("useSkill spends resources and starts a legacy cooldown", function()
        local adapter = new_skill_stats_adapter("legacy_use_skill_case")
        adapter:learnSkill("heal")
        adapter:useSkill("heal")
        expect_equal(3, adapter:getCooldownRemaining("heal"))
    end)

    -- @covers lurek.progression.definePerk
    it("definePerk authors a legacy perk definition with level requirements", function()
        local adapter = new_perk_stats_adapter("legacy_define_perk_case", "progression_define_perk")
        expect_false(adapter:hasPerk("iron_skin"))
    end)

    -- @covers lurek.progression.acquirePerk
    it("acquirePerk grants the authored legacy perk", function()
        local adapter = new_perk_stats_adapter("legacy_acquire_perk_case", "progression_acquire_perk")
        expect_true(adapter:acquirePerk("iron_skin"))
        expect_true(adapter:hasPerk("iron_skin"))
    end)

    -- @covers lurek.progression.hasPerk
    it("hasPerk reports whether the legacy perk is already owned", function()
        local adapter = new_perk_stats_adapter("legacy_has_perk_case", "progression_has_perk")
        adapter:acquirePerk("iron_skin")
        expect_true(adapter:hasPerk("iron_skin"))
    end)

    -- @covers lurek.progression.setFlag
    it("setFlag enables a legacy boolean flag", function()
        local _, adapter = new_stats_adapter("legacy_set_flag_case")
        adapter:setFlag("panic")
        expect_true(adapter:hasFlag("panic"))
    end)

    -- @covers lurek.progression.hasFlag
    it("hasFlag reads an enabled legacy boolean flag", function()
        local _, adapter = new_stats_adapter("legacy_has_flag_case")
        adapter:setFlag("panic")
        expect_true(adapter:hasFlag("panic"))
    end)

    -- @covers lurek.progression.update
    it("update advances the underlying store clock for legacy adapter state", function()
        local adapter = new_hp_stats_adapter("legacy_update_case")
        adapter:addBuff("hp", 5, 1, 1, "short")
        adapter:update(2)
        expect_equal(0, adapter:getBuffCount("hp"))
    end)

    -- @covers lurek.progression.snapshot
    it("snapshot exports legacy adapter stats and level state", function()
        local adapter = new_hp_stats_adapter("legacy_snapshot_case")
        adapter:addXP(150)
        local snap = adapter:snapshot()
        expect_equal(100, snap.attributes.hp.base)
        expect_equal(2, snap.level)
    end)

    -- @covers lurek.progression.restore
    it("restore reapplies a previously exported legacy adapter snapshot", function()
        local adapter = new_hp_stats_adapter("legacy_restore_case")
        adapter:addXP(0)
        adapter:setBase("hp", 120)
        local snap = adapter:snapshot()
        adapter:setBase("hp", 90)
        adapter:restore(snap)
        expect_equal(120, adapter:getBase("hp"))
    end)

    -- @covers lurek.progression.type
    it("type exposes the legacy stats adapter userdata name", function()
        local _, adapter = new_stats_adapter("legacy_type_case")
        expect_equal("LLegacyStatsAdapter", adapter:type())
    end)

    -- @covers lurek.progression.typeOf
    it("typeOf accepts the legacy stats adapter userdata name", function()
        local _, adapter = new_stats_adapter("legacy_typeof_case")
        expect_true(adapter.typeOf("LLegacyStatsAdapter"))
    end)

    -- @covers lurek.progression.addQuest
    it("addQuest registers a legacy quest definition", function()
        local adapter = new_seeded_quest_adapter("legacy_add_quest_case")
        expect_equal(1, adapter:questCount())
    end)

    -- @covers lurek.progression.questCount
    it("questCount reports authored legacy quests", function()
        local adapter = new_seeded_quest_adapter("legacy_quest_count_case")
        expect_equal(1, adapter:questCount())
    end)

    -- @covers lurek.progression.startQuest
    it("startQuest moves a legacy quest to active state", function()
        local adapter = new_seeded_quest_adapter("legacy_start_quest_case")
        adapter:startQuest("cleanup")
        expect_equal("active", adapter:getQuest("cleanup").status)
    end)

    -- @covers lurek.progression.completeQuest
    it("completeQuest moves a legacy quest to completed state", function()
        local adapter = new_seeded_quest_adapter("legacy_complete_quest_case")
        adapter:startQuest("cleanup")
        adapter:completeQuest("cleanup")
        expect_equal("completed", adapter:getQuest("cleanup").status)
    end)

    -- @covers lurek.progression.failQuest
    it("failQuest moves a legacy quest to failed state", function()
        local adapter = new_seeded_quest_adapter("legacy_fail_quest_case")
        adapter:startQuest("cleanup")
        adapter:failQuest("cleanup")
        expect_equal("failed", adapter:getQuest("cleanup").status)
    end)

    -- @covers lurek.progression.advanceObjective
    it("advanceObjective completes a legacy quest objective", function()
        local adapter = new_seeded_quest_adapter("legacy_advance_objective_case")
        adapter:startQuest("cleanup")
        adapter:advanceObjective("cleanup", "step", 1)
        expect_equal("completed", adapter:getQuest("cleanup").status)
    end)

    -- @covers lurek.progression.addJournalEntry
    it("addJournalEntry appends a legacy quest journal record", function()
        local adapter = new_seeded_quest_adapter("legacy_add_journal_case")
        adapter:startQuest("cleanup")
        adapter:addJournalEntry("cleanup", "Entered the cellar", "story")
        expect_equal(1, #adapter:getQuest("cleanup").journal)
    end)

    -- @covers lurek.progression.getQuest
    it("getQuest returns the legacy quest definition plus live state", function()
        local adapter = new_seeded_quest_adapter("legacy_get_quest_case")
        expect_equal("cleanup", adapter:getQuest("cleanup").id)
    end)

    -- @covers lurek.progression.activeCount
    it("activeCount reports how many legacy quests are active", function()
        local adapter = new_seeded_quest_adapter("legacy_active_count_case")
        adapter:startQuest("cleanup")
        expect_equal(1, adapter:activeCount())
    end)
end)

-- @describe progression uncovered method owners
describe("progression uncovered method owners", function()
    -- @covers LProgressionProfile:getId
    it("profile getId returns the authored profile id", function()
        local store = new_store("profile_get_id_case")
        local profile = store:createProfile("player")
        expect_equal("player", profile:getId())
    end)

    -- @covers LProgressionProfile:type
    it("profile type returns the progression profile userdata name", function()
        local store = new_store("profile_type_case")
        local profile = store:createProfile("player")
        expect_equal("LProgressionProfile", profile:type())
    end)

    -- @covers LProgressionProfile:typeOf
    it("profile typeOf accepts the progression profile userdata name", function()
        local store = new_store("profile_typeof_case")
        local profile = store:createProfile("player")
        expect_true(profile:typeOf("LProgressionProfile"))
    end)

    -- @covers LProgressionStore:spendResource
    it("spendResource subtracts from a bounded store resource", function()
        local store, profile = new_resource_store("store_spend_resource_case")
        expect_true(store:spendResource(profile, "stamina", 2))
        expect_equal(3, store:getResource("player", "stamina").value)
    end)

    -- @covers LProgressionStore:refillResource
    it("refillResource restores a bounded store resource", function()
        local store, profile = new_resource_store("store_refill_resource_case")
        store:spendResource(profile, "stamina", 4)
        store:refillResource("player", "stamina")
        expect_equal(10, store:getResource("player", "stamina").value)
    end)

    -- @covers LProgressionStore:getExperience
    it("getExperience returns the canonical experience snapshot for a level track", function()
        local store, profile = new_level_store("store_get_experience_case")
        store:addExperience(profile, "character_xp", 150)
        local snapshot = store:getExperience("player", "character_xp")
        expect_equal(50, snapshot.experience)
        expect_equal(2, snapshot.level)
    end)

    -- @covers LProgressionStore:activateChallenge
    it("activateChallenge starts an authored challenge for a profile", function()
        local store, profile = new_challenge_store("store_activate_challenge_case")
        local started = store:activateChallenge(profile, "win_streak")
        expect_equal("active", started.status)
    end)

    -- @covers LProgressionStore:setChallengeProgress
    it("setChallengeProgress manually advances a running challenge", function()
        local store, profile = new_challenge_store("store_set_challenge_progress_case")
        store:activateChallenge(profile, "win_streak")
        local updated = store:setChallengeProgress("player", "win_streak", 2)
        expect_equal(2, updated.current)
    end)

    -- @covers LProgressionStore:getChallenge
    it("getChallenge returns the canonical challenge state snapshot", function()
        local store, profile = new_challenge_store("store_get_challenge_case")
        store:activateChallenge(profile, "win_streak")
        store:addCounter("player", "wins", 1)
        expect_equal(1, store:getChallenge("player", "win_streak").current)
    end)

    -- @covers LProgressionStore:listChallenges
    it("listChallenges filters challenge snapshots by lifecycle status", function()
        local store, profile = new_challenge_store("store_list_challenges_case")
        store:activateChallenge(profile, "win_streak")
        store:addCounter("player", "wins", 3)
        local completed = store:listChallenges("player", { status = "completed" })
        expect_equal("win_streak", completed[1].id)
    end)

    -- @covers LProgressionProfile:getPendingRewards
    it("profile getPendingRewards returns challenge reward records awaiting claim", function()
        local store, profile = new_challenge_store("store_pending_rewards_case")
        store:activateChallenge(profile, "win_streak")
        store:addCounter("player", "wins", 3)
        local rewards = profile:getPendingRewards()
        expect_equal(1, #rewards)
        expect_equal("pending", rewards[1].state)
    end)

    -- @covers LProgressionStore:setQuestObjectiveVisibility
    it("setQuestObjectiveVisibility toggles whether one objective is shown", function()
        local store = new_store("store_objective_visibility_case")
        local profile = store:createProfile("player")
        store:defineQuest("stealth", {
            title = "Stealth",
            stages = {
                {
                    id = "stage_1",
                    name = "Stage",
                    objectives = {
                        { id = "required", description = "Stay hidden", required = 1, mandatory = true, hidden = true },
                    },
                },
            },
        })
        store:acceptQuest(profile, "stealth")
        store:setQuestObjectiveVisibility("player", "stealth", "required", true)
        local quest = store:getQuestState("player", "stealth")
        local required
        for _, objective in ipairs(quest.objectives) do
            if objective.id == "required" then
                required = objective
            end
        end
        expect_true(required.visible)
    end)
end)

-- @describe progression heuristic owner closures
describe("progression heuristic owner closures", function()
    -- @covers LProgressionTransaction:addCounter
    it("transaction addCounter queues a counter delta", function()
        local store = new_store("tx_add_counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        local tx = store:beginTransaction({ id = "tx_add_counter" })
        tx:addCounter(profile, "wins", 3)
        tx:commit()
        expect_equal(3, store:getCounter("player", "wins"))
    end)

    -- @covers LProgressionTransaction:setAttributeBase
    it("transaction setAttributeBase queues an attribute overwrite", function()
        local store, profile = new_attribute_store("tx_set_attribute_base_case")
        local tx = store:beginTransaction({ id = "tx_set_attribute_base" })
        tx:setAttributeBase(profile, "hp", 120)
        tx:commit()
        expect_equal(120, store:getAttribute("player", "hp", "base"))
    end)

    -- @covers LProgressionTransaction:setResource
    it("transaction setResource queues a resource overwrite", function()
        local store, profile = new_resource_store("tx_set_resource_case")
        local tx = store:beginTransaction({ id = "tx_set_resource" })
        tx:setResource(profile, "stamina", 2)
        tx:commit()
        expect_equal(2, store:getResource("player", "stamina").value)
    end)

    -- @covers LProgressionTransaction:addModifier
    it("transaction addModifier queues a modifier application", function()
        local store, profile = new_attribute_store("tx_add_modifier_case")
        local tx = store:beginTransaction({ id = "tx_add_modifier" })
        tx:addModifier(profile, "hp", { value = 10, layer = "final_add" })
        tx:commit()
        expect_equal(110, store:getAttribute("player", "hp", "effective"))
    end)

    -- @covers LProgressionTransaction:setQuestObjective
    it("transaction setQuestObjective queues quest objective progress", function()
        local store, profile = new_store_quest("tx_set_quest_objective_case")
        store:acceptQuest(profile, "cleanup")
        local tx = store:beginTransaction({ id = "tx_set_quest_objective" })
        tx:setQuestObjective(profile, "cleanup", "step", 1)
        tx:commit()
        expect_equal("completed", store:getQuestState("player", "cleanup").status)
    end)

    -- @covers LProgressionTransaction:addExperience
    it("transaction addExperience queues level-track progress", function()
        local store, profile = new_level_store("tx_add_experience_case")
        local tx = store:beginTransaction({ id = "tx_add_experience" })
        tx:addExperience(profile, "character_xp", 150)
        tx:commit()
        expect_equal(2, store:getLevel("player", "character_xp"))
    end)

    -- @covers LProgressionTransaction:commit
    it("transaction commit returns a revision summary", function()
        local store = new_store("tx_commit_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        local tx = store:beginTransaction({ id = "tx_commit" })
        tx:addCounter(profile, "wins", 1)
        local summary = tx:commit()
        expect_true(summary.revision >= 1)
        expect_equal(1, summary.changes)
    end)

    -- @covers LProgressionTransaction:type
    it("transaction type returns the userdata name", function()
        local store = new_store("tx_type_case")
        local tx = store:beginTransaction({ id = "tx_type" })
        expect_equal("LProgressionTransaction", tx:type())
    end)

    -- @covers LProgressionTransaction:typeOf
    it("transaction typeOf accepts the transaction userdata name", function()
        local store = new_store("tx_typeof_case")
        local tx = store:beginTransaction({ id = "tx_typeof" })
        expect_true(tx:typeOf("LProgressionTransaction"))
    end)

    -- @covers LProgressionStore:getId
    it("store getId returns the configured store id", function()
        local store = new_store("store_get_id_case")
        expect_equal("store_get_id_case", store:getId())
    end)

    -- @covers LProgressionStore:getRevision
    it("store getRevision returns the current logical revision", function()
        local store = new_store("store_get_revision_case")
        store:createProfile("player")
        expect_true(store:getRevision() >= 1)
    end)

    -- @covers LProgressionStore:getDefinitionHash
    it("store getDefinitionHash returns a stable schema hash string", function()
        local store = new_store("store_get_hash_case")
        expect_type("string", store:getDefinitionHash())
    end)

    -- @covers LProgressionStore:getTime
    it("store getTime reads the logical clock seconds", function()
        local store = new_store("store_get_time_case")
        store:advanceTime(3)
        expect_equal(3, store:getTime())
    end)

    -- @covers LProgressionStore:setTime
    it("store setTime overwrites the logical clock seconds", function()
        local store = new_store("store_set_time_case")
        store:setTime(7)
        expect_equal(7, store:getTime())
    end)

    -- @covers LProgressionStore:update
    it("store update advances time-bound modifier state", function()
        local store, profile = new_attribute_store("store_update_case")
        store:addModifier(profile, "hp", { value = 10, layer = "final_add", duration = 1 })
        store:update(2)
        expect_equal(100, store:getAttribute("player", "hp", "effective"))
    end)

    -- @covers LProgressionStore:compileCondition
    it("store compileCondition returns a canonical compiled condition tree", function()
        local store = new_store("store_compile_condition_case")
        local compiled = store:compileCondition({ all = { { tag = "hero" } } })
        expect_equal("all", compiled.kind)
    end)

    -- @covers LProgressionStore:explainCondition
    it("store explainCondition returns a structured evaluation explanation", function()
        local store = new_store("store_explain_condition_case")
        local profile = store:createProfile("player", { tags = { "hero" } })
        local explanation = store:explainCondition(profile, { tag = "hero" })
        expect_true(explanation.ok)
    end)

    -- @covers LProgressionStore:loadSnapshot
    it("store loadSnapshot replaces state from an exported snapshot", function()
        local source = new_store("store_load_snapshot_source")
        source:createProfile("player")
        local snapshot = source:exportSnapshot()
        local target = new_store("store_load_snapshot_target")
        target:loadSnapshot(snapshot)
        expect_true(target:hasProfile("player"))
    end)

    -- @covers LProgressionStore:applyChangeset
    it("store applyChangeset imports old-style revision snapshots", function()
        local source = new_store("store_apply_changeset_source")
        source:defineCounter("wins", { kind = "integer", initial = 0 })
        local profile = source:createProfile("player")
        source:addCounter(profile, "wins", 3)
        local target = new_store("store_apply_changeset_target")
        local report = target:applyChangeset(source:exportChangesSince(0))
        expect_true(report.applied)
        expect_equal(3, target:getCounter("player", "wins"))
    end)

    -- @covers LProgressionStore:getProfile
    it("store getProfile returns a canonical profile snapshot", function()
        local store = new_store("store_get_profile_case")
        store:createProfile("player", { display_name = "Mira" })
        expect_equal("Mira", store:getProfile("player").display_name)
    end)

    -- @covers LProgressionStore:addProfileTag
    it("store addProfileTag appends one tag to an existing profile", function()
        local store = new_store("store_add_profile_tag_case")
        store:createProfile("player")
        store:addProfileTag("player", "hero")
        expect_equal("hero", store:getProfile("player").tags[1])
    end)

    -- @covers LProgressionStore:setProfileMetadata
    it("store setProfileMetadata writes one keyed metadata value", function()
        local store = new_store("store_set_profile_metadata_case")
        store:createProfile("player")
        store:setProfileMetadata("player", "region", "old_tunnels")
        expect_equal("old_tunnels", store:getProfile("player").metadata.region)
    end)

    -- @covers LProgressionStore:addCounter
    it("store addCounter applies a delta to one counter", function()
        local store = new_store("store_add_counter_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        expect_equal(4, store:addCounter(profile, "wins", 4))
    end)

    -- @covers LProgressionStore:getCounterState
    it("store getCounterState returns a structured counter snapshot", function()
        local store = new_store("store_get_counter_state_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:addCounter(profile, "wins", 2)
        expect_equal(2, store:getCounterState("player", "wins").value)
    end)

    -- @covers LProgressionStore:getAttribute
    it("store getAttribute reads one attribute by mode", function()
        local store, profile = new_attribute_store("store_get_attribute_case")
        store:setAttributeBase(profile, "hp", 120)
        expect_equal(120, store:getAttribute("player", "hp", "base"))
    end)

    -- @covers LProgressionStore:setAttributeBase
    it("store setAttributeBase overwrites one attribute base value", function()
        local store, profile = new_attribute_store("store_set_attribute_base_case")
        store:setAttributeBase(profile, "hp", 130)
        expect_equal(130, store:getAttribute("player", "hp", "base"))
    end)

    -- @covers LProgressionStore:addModifier
    it("store addModifier returns a handle and affects effective values", function()
        local store, profile = new_attribute_store("store_add_modifier_case")
        local handle = store:addModifier(profile, "hp", { value = 10, layer = "final_add" })
        expect_type("string", handle)
        expect_equal(110, store:getAttribute("player", "hp", "effective"))
    end)

    -- @covers LProgressionStore:removeModifier
    it("store removeModifier clears one authored modifier by handle", function()
        local store, profile = new_attribute_store("store_remove_modifier_case")
        local handle = store:addModifier(profile, "hp", { value = 10, layer = "final_add" })
        expect_true(store:removeModifier("player", handle))
        expect_equal(100, store:getAttribute("player", "hp", "effective"))
    end)

    -- @covers LProgressionStore:getResource
    it("store getResource returns a structured resource snapshot", function()
        local store = new_store("store_get_resource_case")
        local profile = store:createProfile("player")
        store:defineResource("stamina", { initial = 5, min = 0, max = 10, regeneration = 0, refill = "manual" })
        store:setResource(profile, "stamina", 3)
        expect_equal(3, store:getResource("player", "stamina").value)
    end)

    -- @covers LProgressionStore:setResource
    it("store setResource overwrites the current resource value", function()
        local store, profile = new_resource_store("store_set_resource_case")
        store:setResource(profile, "stamina", 2)
        expect_equal(2, store:getResource("player", "stamina").value)
    end)

    -- @covers LProgressionStore:addResource
    it("store addResource applies a signed delta to the current resource value", function()
        local store, profile = new_resource_store("store_add_resource_case")
        store:addResource(profile, "stamina", 2)
        expect_equal(7, store:getResource("player", "stamina").value)
    end)

    -- @covers LProgressionStore:applyTrait
    it("store applyTrait activates one authored trait", function()
        local store, profile = new_attribute_store("store_apply_trait_case")
        store:defineTrait("tough", { modifiers = { { target_id = "hp", value = 10, layer = "final_add" } } })
        store:applyTrait(profile, "tough")
        expect_true(store:hasTrait("player", "tough"))
    end)

    -- @covers LProgressionStore:removeTrait
    it("store removeTrait deactivates one authored trait", function()
        local store, profile = new_attribute_store("store_remove_trait_case")
        store:defineTrait("tough", { modifiers = { { target_id = "hp", value = 10, layer = "final_add" } } })
        store:applyTrait(profile, "tough")
        expect_true(store:removeTrait("player", "tough"))
    end)

    -- @covers LProgressionStore:hasTrait
    it("store hasTrait reports whether a trait is active", function()
        local store, profile = new_attribute_store("store_has_trait_case")
        store:defineTrait("tough", { modifiers = { { target_id = "hp", value = 10, layer = "final_add" } } })
        store:applyTrait(profile, "tough")
        expect_true(store:hasTrait("player", "tough"))
    end)

    -- @covers LProgressionStore:definePerk
    it("store definePerk authors a perk definition that can later be granted", function()
        local store, _ = new_perk_store("store_define_perk_case", "store_define_perk_trait")
        expect_type("table", store:debugSnapshot())
    end)

    -- @covers LProgressionStore:learnSkill
    it("store learnSkill grants one skill level to the profile", function()
        local store, profile = new_skill_store("store_learn_skill_case")
        store:learnSkill(profile, "heal")
        expect_equal(1, store:getSkillLevel("player", "heal"))
    end)

    -- @covers LProgressionStore:useSkill
    it("store useSkill spends the configured resource and starts cooldown", function()
        local store, profile = new_skill_store("store_use_skill_case")
        store:learnSkill(profile, "heal")
        store:useSkill(profile, "heal")
        expect_equal(3, store:getSkillCooldown("player", "heal"))
    end)

    -- @covers LProgressionStore:getSkillCooldown
    it("store getSkillCooldown reads the remaining cooldown seconds", function()
        local store, profile = new_skill_store("store_get_skill_cooldown_case")
        store:learnSkill(profile, "heal")
        store:useSkill(profile, "heal")
        expect_equal(3, store:getSkillCooldown("player", "heal"))
    end)

    -- @covers LProgressionStore:acquirePerk
    it("store acquirePerk grants one authored perk", function()
        local store, profile = new_perk_store("store_acquire_perk_case", "store_acquire_perk_trait")
        expect_true(store:acquirePerk(profile, "iron_skin"))
    end)

    -- @covers LProgressionStore:hasPerk
    it("store hasPerk reports whether a perk is owned", function()
        local store, profile = new_perk_store("store_has_perk_case", "store_has_perk_trait")
        store:acquirePerk(profile, "iron_skin")
        expect_true(store:hasPerk("player", "iron_skin"))
    end)

    -- @covers LProgressionStore:applyProfileTemplate
    it("store applyProfileTemplate reapplies authored template state to a profile", function()
        local store = new_store("store_apply_profile_template_case")
        local profile = store:createProfile("player")
        store:defineCounter("wins", { kind = "integer", initial = 0 })
        store:defineProfileTemplate("veteran", { counters = { wins = 4 }, tags = { "veteran" } })
        store:applyProfileTemplate(profile, "veteran")
        expect_equal(4, store:getCounter("player", "wins"))
    end)

    -- @covers LProgressionStore:getDerivedValue
    it("store getDerivedValue reads one authored derived stat", function()
        local store, _ = new_derived_store("store_get_derived_case")
        expect_equal(17, store:getDerivedValue("player", "combat_rating"))
    end)

    -- @covers LProgressionStore:explainDerivedValue
    it("store explainDerivedValue returns the bound input explanation", function()
        local store, profile = new_derived_store("store_explain_derived_case")
        expect_equal(17, store:explainDerivedValue(profile, "combat_rating").value)
    end)

    -- @covers LProgressionStore:validateDerivedValues
    it("store validateDerivedValues reports authored formulas as healthy", function()
        local store, _ = new_derived_store("store_validate_derived_case")
        expect_true(store:validateDerivedValues().ok)
    end)

    -- @covers LProgressionStore:submitScore
    it("store submitScore inserts or updates one leaderboard entry", function()
        local store = new_leaderboard_store("store_submit_score_case")
        local entry = store:submitScore("alpha", "arena", 5)
        expect_equal(1, entry.rank)
    end)

    -- @covers LProgressionStore:getLeaderboardEntry
    it("store getLeaderboardEntry returns one ranked leaderboard snapshot", function()
        local store = new_leaderboard_store("store_get_leaderboard_entry_case")
        store:submitScore("alpha", "arena", 5)
        expect_equal(1, store:getLeaderboardEntry("alpha", "arena").rank)
    end)

    -- @covers LProgressionStore:listLeaderboardRange
    it("store listLeaderboardRange returns a bounded rank window", function()
        local store = new_leaderboard_store("store_list_leaderboard_range_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 4)
        expect_equal(2, #store:listLeaderboardRange("arena", 1, 2))
    end)

    -- @covers LProgressionStore:listLeaderboardAroundProfile
    it("store listLeaderboardAroundProfile centers a rank window on one profile", function()
        local store = new_leaderboard_store("store_list_leaderboard_around_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 4)
        store:submitScore("gamma", "arena", 3)
        expect_equal("beta", store:listLeaderboardAroundProfile("arena", "beta", 1, 1)[2].profile_id)
    end)

    -- @covers LProgressionStore:addExperience
    it("store addExperience advances a level track with carry-over", function()
        local store, profile = new_level_store("store_add_experience_case")
        local snapshot = store:addExperience(profile, "character_xp", 150)
        expect_equal(2, snapshot.level)
    end)

    -- @covers LProgressionStore:getLevel
    it("store getLevel reads the current level-track level", function()
        local store, profile = new_level_store("store_get_level_case")
        store:addExperience(profile, "character_xp", 150)
        expect_equal(2, store:getLevel("player", "character_xp"))
    end)

    -- @covers LProgressionStore:setLevel
    it("store setLevel forces the current level-track level", function()
        local store, profile = new_level_store("store_set_level_case")
        local snapshot = store:setLevel(profile, "character_xp", 4)
        expect_equal(4, snapshot.level)
    end)

    -- @covers LProgressionStore:getExperienceToNextLevel
    it("store getExperienceToNextLevel reports remaining experience", function()
        local store, _ = new_level_store("store_get_exp_to_next_case")
        expect_equal(100, store:getExperienceToNextLevel("player", "character_xp"))
    end)

    -- @covers LProgressionStore:getAchievement
    it("store getAchievement returns the canonical achievement state snapshot", function()
        local store = new_store("store_get_achievement_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        store:unlockAchievement(profile, "manual_reward")
        expect_true(store:getAchievement("player", "manual_reward").unlocked)
    end)

    -- @covers LReward:claim
    it("reward claim moves one reward record to claimed state", function()
        local store, profile, _ = new_reward_store("store_claim_reward_case")
        local pending = profile:getPendingRewards()[1]
        expect_equal("claimed", pending:claim().state)
    end)

    -- @covers LReward:markApplied
    it("reward markApplied records an external receipt on the reward", function()
        local store, profile, _ = new_reward_store("store_mark_reward_applied_case")
        local claimed = profile:getPendingRewards()[1]:claim()
        expect_equal("applied", claimed:markApplied("receipt-1").state)
    end)

    -- @covers LReward:reject
    it("reward reject records a rejection state and reason", function()
        local store, profile, _ = new_reward_store("store_reject_reward_case")
        store:unlockAchievement("player", "manual_reward")
        local rejected = profile:getPendingRewards()[1]:reject("inventory_full")
        expect_equal("rejected", rejected.state)
    end)

    -- @covers LProgressionStore:acceptQuest
    it("store acceptQuest activates one authored quest for a profile", function()
        local store, profile = new_store_quest("store_accept_quest_case")
        store:acceptQuest(profile, "cleanup")
        expect_equal("active", store:getQuestState("player", "cleanup").status)
    end)

    -- @covers LQuestJournal:listEntries
    it("quest journal listEntries returns authored journal records in order", function()
        local store, profile = new_store_quest("store_list_journal_case")
        store:acceptQuest(profile, "cleanup")
        local journal = store:getQuestState("player", "cleanup"):getJournal()
        journal:addEntry("First note")
        expect_equal("First note", journal:listEntries()[1].text)
    end)

    -- @covers LProgressionStore:failQuest
    it("store failQuest moves one active quest to failed state", function()
        local store, profile = new_store_quest("store_fail_quest_case")
        store:acceptQuest(profile, "cleanup")
        store:failQuest(profile, "cleanup")
        expect_equal("failed", store:getQuestState("player", "cleanup").status)
    end)

    -- @covers LProgressionStore:getQuestState
    it("store getQuestState returns the current quest lifecycle snapshot", function()
        local store, _ = new_store_quest("store_get_quest_state_case")
        expect_equal("available", store:getQuestState("player", "cleanup").status)
    end)

    -- @covers LProgressionStore:type
    it("store type returns the progression store userdata name", function()
        local store = new_store("store_type_case")
        expect_equal("LProgressionStore", store:type())
    end)

    -- @covers LProgressionStore:typeOf
    it("store typeOf accepts the progression store userdata name", function()
        local store = new_store("store_typeof_case")
        expect_true(store:typeOf("LProgressionStore"))
    end)

    -- @covers LAchievement:isUnlocked
    it("achievement userdata reports whether one profile unlocked it", function()
        local store = new_store("achievement_userdata_is_unlocked_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        local before = store:getAchievement("player", "manual_reward")
        store:unlockAchievement(profile, "manual_reward")
        local after = store:getAchievement("player", "manual_reward")
        expect_false(before:isUnlocked())
        expect_true(after:isUnlocked())
    end)

    -- @covers LAchievement:getId
    it("achievement userdata returns the authored achievement id", function()
        local store = new_store("achievement_userdata_get_id_case")
        store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        local achievement = store:getAchievement("player", "manual_reward")
        expect_equal("manual_reward", achievement:getId())
    end)

    -- @covers LAchievement:getTitle
    it("achievement userdata returns the authored achievement title", function()
        local store = new_store("achievement_userdata_get_title_case")
        store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        local achievement = store:getAchievement("player", "manual_reward")
        expect_equal("Manual Reward", achievement:getTitle())
    end)

    -- @covers LChallenge:getId
    it("challenge userdata returns the authored challenge id", function()
        local store, profile = new_challenge_store("challenge_userdata_get_id_case")
        store:activateChallenge(profile, "win_streak")
        local challenge = store:getChallenge("player", "win_streak")
        expect_equal("win_streak", challenge:getId())
    end)

    -- @covers LChallenge:getStatus
    it("challenge userdata returns the current lifecycle status", function()
        local store, profile = new_challenge_store("challenge_userdata_get_status_case")
        store:activateChallenge(profile, "win_streak")
        local challenge = store:getChallenge("player", "win_streak")
        expect_equal("active", challenge:getStatus())
    end)

    -- @covers LCollection:getId
    it("collection userdata returns the authored collection id", function()
        local store = new_store("collection_userdata_get_id_case")
        local profile = store:createProfile("player")
        store:defineCollection("museum", {
            title = "Museum",
            items = {
                { id = "entry_a", title = "Entry A" },
            },
        })
        local collection = store:getCollection("player", "museum")
        expect_equal("museum", collection:getId())
    end)

    -- @covers LCollection:isComplete
    it("collection userdata reports whether every item was collected", function()
        local store = new_store("collection_userdata_complete_case")
        local profile = store:createProfile("player")
        store:defineCollection("museum", {
            title = "Museum",
            items = {
                { id = "entry_a", title = "Entry A" },
                { id = "entry_b", title = "Entry B" },
            },
        })
        local before = store:getCollection("player", "museum")
        store:collectCollectionItem(profile, "museum", "entry_a")
        store:collectCollectionItem(profile, "museum", "entry_b")
        local after = store:getCollection("player", "museum")
        expect_false(before:isComplete())
        expect_true(after:isComplete())
    end)

    -- @covers LActivityFeedEntry:getEventType
    it("activity feed entry userdata returns the canonical event type", function()
        local store = new_store("activity_feed_entry_type_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        store:unlockAchievement(profile, "manual_reward")
        local entry = store:getActivityFeed({ profiles = { "player" }, limit = 1 }):listEntries()[1]
        expect_equal("achievement_unlocked", entry:getEventType())
    end)

    -- @covers LActivityFeedEntry:getSequence
    it("activity feed entry userdata returns the retained event sequence", function()
        local store = new_store("activity_feed_entry_sequence_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        store:unlockAchievement(profile, "manual_reward")
        local entry = store:getActivityFeed({ profiles = { "player" }, limit = 1 }):listEntries()[1]
        expect_true(entry:getSequence() >= 1)
    end)

    -- @covers LActivityFeed:count
    it("activity feed userdata reports the retained entry count", function()
        local store = new_store("activity_feed_count_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        store:unlockAchievement(profile, "manual_reward")
        local feed = store:getActivityFeed({
            profiles = { profile },
            types = { "achievement_unlocked" },
            limit = 3,
        })
        expect_equal(1, feed:count())
    end)

    -- @covers LActivityFeed:listEntries
    it("activity feed userdata returns typed retained entries", function()
        local store = new_store("activity_feed_entries_case")
        local profile = store:createProfile("player")
        store:defineAchievement("manual_reward", { title = "Manual Reward" })
        store:unlockAchievement(profile, "manual_reward")
        local entries = store:getActivityFeed({
            profiles = { profile },
            types = { "achievement_unlocked" },
            limit = 3,
        }):listEntries()
        expect_equal(1, #entries)
        expect_equal("achievement_unlocked", entries[1]:getEventType())
    end)

    -- @covers LLeaderboardEntry:getLeaderboardId
    it("leaderboard entry userdata returns the leaderboard id", function()
        local store = new_leaderboard_store("leaderboard_entry_get_lb_case")
        store:submitScore("alpha", "arena", 5)
        local entry = store:getLeaderboardEntry("alpha", "arena")
        expect_equal("arena", entry:getLeaderboardId())
    end)

    -- @covers LLeaderboardEntry:getProfileId
    it("leaderboard entry userdata returns the owning profile id", function()
        local store = new_leaderboard_store("leaderboard_entry_get_profile_case")
        store:submitScore("beta", "arena", 4)
        local entry = store:getLeaderboardEntry("beta", "arena")
        expect_equal("beta", entry:getProfileId())
    end)

    -- @covers LLeaderboardEntry:getRank
    it("leaderboard entry userdata returns the current one-based rank", function()
        local store = new_leaderboard_store("leaderboard_entry_get_rank_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 3)
        local entry = store:getLeaderboardEntry("beta", "arena")
        expect_equal(2, entry:getRank())
    end)

    -- @covers LPopulation:getId
    it("population userdata returns the generated population id", function()
        local store = new_store("population_userdata_get_id_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "runner", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        local run = store:generatePopulation("bots", { id = "bot_pack" })
        expect_equal("bot_pack", run:getId())
    end)

    -- @covers LPopulation:isPaused
    it("population userdata reports whether logical updates are paused", function()
        local store = new_store("population_userdata_is_paused_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "runner", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        local before = store:generatePopulation("bots", { id = "bot_pack" })
        store:pausePopulation("bot_pack")
        local after = store:getPopulation("bot_pack")
        expect_false(before:isPaused())
        expect_true(after:isPaused())
    end)

    -- @covers LPopulationProfile:getProfileId
    it("population profile userdata returns the virtual profile id", function()
        local store = new_store("population_profile_get_id_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "runner", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        store:generatePopulation("bots", { id = "bot_pack" })
        local profile = store:listPopulationProfiles("bot_pack", { limit = 1 })[1]
        expect_true(profile:getProfileId() ~= nil)
    end)

    -- @covers LPopulationProfile:isMaterialized
    it("population profile userdata reports materialization state", function()
        local store = new_store("population_profile_materialized_case")
        store:defineLeaderboard("arena", { title = "Arena", sort = "descending", rank_mode = "ordinal" })
        store:definePopulationTemplate("bots", {
            id_prefix = "bot_",
            count = 1,
            identity = { name_generator = { mode = "parts", prefixes = { "Iron" }, suffixes = { "Fox" } }, tags = { "bot" } },
            archetypes = { { id = "runner", weight = 1, activity = { min = 1, max = 1 }, skill = { mean = 1000, deviation = 10 } } },
            leaderboards = { arena = { initial_score = { distribution = "normal" }, progression = { mode = "bounded_random_walk", volatility = 2, mean_reversion = 0.1 } } },
        })
        store:generatePopulation("bots", { id = "bot_pack" })
        local before = store:listPopulationProfiles("bot_pack", { limit = 1 })[1]
        store:materializePopulationProfile(before:getProfileId())
        local after = store:listPopulationProfiles("bot_pack", { limit = 1 })[1]
        expect_false(before:isMaterialized())
        expect_true(after:isMaterialized())
    end)

    -- @covers LQuestState:getQuestId
    it("quest state userdata returns the authored quest id", function()
        local store, _ = new_store_quest("quest_state_get_id_case")
        local state = store:getQuestState("player", "cleanup")
        expect_equal("cleanup", state:getQuestId())
    end)

    -- @covers LQuestState:getStatus
    it("quest state userdata returns the current quest lifecycle status", function()
        local store, _ = new_store_quest("quest_state_get_status_case")
        local state = store:getQuestState("player", "cleanup")
        expect_equal("available", state:getStatus())
    end)

    -- @covers LQuestState:isRevealed
    it("quest state userdata reports whether the quest is revealed", function()
        local store, _ = new_store_quest("quest_state_is_revealed_case")
        local state = store:getQuestState("player", "cleanup")
        expect_true(state:isRevealed())
    end)

    -- @covers LQuestState:getJournal
    it("quest state userdata returns a typed journal handle", function()
        local store, profile = new_store_quest("quest_state_get_journal_case")
        store:acceptQuest(profile, "cleanup")
        local journal = store:getQuestState("player", "cleanup"):getJournal()
        expect_equal("cleanup", journal:getQuestId())
    end)

    -- @covers LQuestJournal:getQuestId
    it("quest journal userdata returns the owning quest id", function()
        local store, profile = new_store_quest("quest_journal_get_id_case")
        store:acceptQuest(profile, "cleanup")
        local journal = store:getQuestState(profile, "cleanup"):getJournal()
        expect_equal("cleanup", journal:getQuestId())
    end)

    -- @covers LQuestJournal:count
    it("quest journal userdata reports the retained entry count", function()
        local store = new_store("quest_journal_count_case")
        local profile = store:createProfile("player")
        store:defineQuest("journaled", {
            title = "Journaled",
            max_journal_entries = 2,
            stages = {
                { id = "stage_1", name = "Stage", objectives = { { id = "step", description = "One step", required = 1, mandatory = true } } },
            },
        })
        store:acceptQuest(profile, "journaled")
        local journal = store:getQuestState("player", "journaled"):getJournal()
        journal:addEntry("Found clue", "discover")
        journal:addEntry("Opened door", "progress")
        expect_equal(2, journal:count())
    end)

    -- @covers LReward:getId
    it("reward userdata returns the stable reward identifier", function()
        local _, profile, reward_id = new_reward_store("reward_userdata_get_id_case")
        local reward_record = profile:getPendingRewards()[1]
        expect_equal(reward_id, reward_record:getId())
    end)

    -- @covers LReward:getState
    it("reward userdata returns the current reward state", function()
        local _, profile, _ = new_reward_store("reward_userdata_get_state_case")
        local reward_record = profile:getPendingRewards()[1]
        local claimed = reward_record:claim()
        expect_equal("claimed", claimed:getState())
    end)

    -- @covers LQuestJournalEntry:getIndex
    it("quest journal entry userdata returns the stable retained index", function()
        local store, profile = new_store_quest("quest_journal_entry_index_case")
        store:acceptQuest(profile, "cleanup")
        local entry = store:getQuestState("player", "cleanup"):getJournal():addEntry("Found clue", "discover")
        expect_equal(0, entry:getIndex())
    end)

    -- @covers LQuestJournalEntry:getText
    it("quest journal entry userdata returns the authored text", function()
        local store, profile = new_store_quest("quest_journal_entry_text_case")
        store:acceptQuest(profile, "cleanup")
        local entry = store:getQuestState(profile, "cleanup"):getJournal():addEntry("Opened door", "progress")
        expect_equal("Opened door", entry:getText())
    end)

    -- @covers LQuestJournalEntry:getTag
    it("quest journal entry userdata returns the stored tag", function()
        local store, profile = new_store_quest("quest_journal_entry_tag_case")
        store:acceptQuest(profile, "cleanup")
        local entry = store:getQuestState("player", "cleanup"):getJournal():addEntry("Opened vault", "discover")
        expect_equal("discover", entry:getTag())
    end)

    -- @covers LRival:getProfileId
    it("rival userdata returns the owner profile id", function()
        local store = new_leaderboard_store("rival_get_profile_id_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 4)
        local pinned = store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
        expect_equal("alpha", pinned:getProfileId())
    end)

    -- @covers LRival:getRivalProfileId
    it("rival userdata returns the pinned rival profile id", function()
        local store = new_leaderboard_store("rival_get_rival_id_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 4)
        local pinned = store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
        expect_equal("beta", pinned:getRivalProfileId())
    end)

    -- @covers LRivalDelta:getLeaderboardId
    it("rival delta userdata returns the bound leaderboard id", function()
        local store = new_leaderboard_store("rival_delta_get_lb_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 4)
        store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
        local delta = store:getRivalDelta("alpha", "beta")
        expect_equal("arena", delta:getLeaderboardId())
    end)

    -- @covers LRivalDelta:getRankDelta
    it("rival delta userdata returns the signed rank difference", function()
        local store = new_leaderboard_store("rival_delta_get_rank_case")
        store:submitScore("alpha", "arena", 5)
        store:submitScore("beta", "arena", 4)
        store:pinRival("alpha", "beta", { leaderboard_id = "arena" })
        local delta = store:getRivalDelta("alpha", "beta")
        expect_equal(1, delta:getRankDelta())
    end)

    -- @covers LPrestige:getId
    it("prestige userdata returns the authored prestige id", function()
        local store = new_store("prestige_userdata_get_id_case")
        local profile = store:createProfile("player")
        store:defineCounter("campaign_kills", { kind = "integer", initial = 0 })
        store:definePrestige("career", {
            condition = { counter = "campaign_kills", op = ">=", value = 5 },
            reset = { counters = { "campaign_kills" } },
            preserve = { achievements = true },
        })
        local prestige = store:getPrestige(profile, "career")
        expect_equal("career", prestige:getId())
    end)

    -- @covers LPrestige:isAvailable
    it("prestige userdata reports whether the condition is currently satisfied", function()
        local store = new_store("prestige_userdata_is_available_case")
        local profile = store:createProfile("player")
        store:defineCounter("campaign_kills", { kind = "integer", initial = 0 })
        store:definePrestige("career", {
            condition = { counter = "campaign_kills", op = ">=", value = 5 },
            reset = { counters = { "campaign_kills" } },
            preserve = { achievements = true },
        })
        local before = store:getPrestige(profile, "career")
        store:setCounter("player", "campaign_kills", 5)
        local after = store:getPrestige(profile, "career")
        expect_false(before:isAvailable())
        expect_true(after:isAvailable())
    end)

    -- @covers LSeason:getId
    it("season userdata returns the authored season id", function()
        local store = new_store("season_userdata_get_id_case")
        store:defineSeason("league", {
            starts_at = 0,
            ends_at = 10,
            reset = { leaderboards = {}, counters = {} },
            archive = true,
        })
        local season = store:getSeason("league")
        expect_equal("league", season:getId())
    end)

    -- @covers LSeason:isActive
    it("season userdata reports whether the season is active", function()
        local store = new_store("season_userdata_is_active_case")
        store:defineSeason("league", {
            starts_at = 0,
            ends_at = 10,
            reset = { leaderboards = {}, counters = {} },
            archive = true,
        })
        local before = store:getSeason("league")
        store:startSeason("league")
        local after = store:getSeason("league")
        expect_false(before:isActive())
        expect_true(after:isActive())
    end)

    -- @covers LSeasonArchive:getId
    it("season archive userdata returns the owning season id", function()
        local store = new_store("season_archive_get_id_case")
        store:createProfile("player")
        store:defineSeason("league", {
            starts_at = 0,
            ends_at = 10,
            reset = { leaderboards = {}, counters = {} },
            archive = true,
        })
        store:startSeason("league")
        store:endSeason("league", { archive = true })
        local archive = store:getSeasonArchive("league", { latest = true })
        expect_equal("league", archive:getId())
    end)

    -- @covers LSeasonArchive:getArchiveIndex
    it("season archive userdata returns the stored archive sequence", function()
        local store = new_store("season_archive_get_index_case")
        store:createProfile("player")
        store:defineSeason("league", {
            starts_at = 0,
            ends_at = 10,
            reset = { leaderboards = {}, counters = {} },
            archive = true,
        })
        store:startSeason("league")
        store:endSeason("league", { archive = true })
        local archive = store:getSeasonArchive("league", { latest = true })
        expect_equal(1, archive:getArchiveIndex())
    end)
end)

test_summary()

