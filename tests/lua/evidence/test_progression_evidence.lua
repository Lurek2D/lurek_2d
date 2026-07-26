-- Canonical evidence file for lurek.progression artifacts.
-- @covers lurek.filesystem.write
-- @covers lurek.progression.createLegacyQuestAdapter
-- @covers lurek.progression.createLegacyStatsAdapter
-- @covers lurek.progression.newStore
-- @covers lurek.serialize.fromJson
-- @covers lurek.serialize.toJson


local OUT = evidence_output_dir("progression")

local function write_text(path, text)
    if write_file then
        write_file(path, text)
    else
        lurek.filesystem.write(path, text)
    end
    expect_evidence_created(path)
end

local function measured(fn)
    local start = os.clock()
    local results = { fn() }
    local elapsed = os.clock() - start
    return elapsed, unpack(results)
end

local function new_store(id)
    return lurek.progression.newStore({
        id = id,
        seed = 7,
        clock = "manual",
        event_limit = 2048,
        max_change_records = 512,
    })
end

local function define_population_surface(store, bot_count)
    store:defineLeaderboard("arena", {
        title = "Arena",
        sort = "descending",
        rank_mode = "ordinal",
        max_entries = bot_count + 64,
    })
    store:definePopulationTemplate("bots", {
        id_prefix = "bot_",
        count = bot_count,
        identity = {
            name_generator = {
                mode = "parts",
                prefixes = { "Iron", "Silver", "Amber", "North" },
                suffixes = { "Fox", "Wing", "Star", "Pike" },
            },
            tags = { "bot", "arena" },
        },
        archetypes = {
            {
                id = "steady",
                weight = 2,
                activity = { min = 1, max = 2 },
                skill = { mean = 1000, deviation = 35 },
            },
            {
                id = "sharp",
                weight = 1,
                activity = { min = 2, max = 3 },
                skill = { mean = 1080, deviation = 25 },
            },
        },
        leaderboards = {
            arena = {
                category = "ranked",
                initial_score = { distribution = "normal" },
                progression = {
                    mode = "bounded_random_walk",
                    volatility = 8,
                    mean_reversion = 0.15,
                },
            },
        },
    })
end

local function add_human_scores(store, count)
    for i = 1, count do
        local profile_id = "human_" .. i
        local profile = store:createProfile(profile_id, {
            display_name = "Human " .. i,
            tags = { "human" },
        })
        store:submitScore(profile, "arena", 850 + i * 7)
    end
end

local function define_changeset_surface(store)
    store:defineCounter("wins", { kind = "integer", initial = 0 })
    store:defineResource("focus", {
        initial = 5,
        min = 0,
        max = 5,
        regeneration = 0,
        refill = "manual",
    })
    store:defineQuest("cleanup", {
        title = "Cleanup",
        stages = {
            {
                id = "stage_1",
                name = "Stage 1",
                objectives = {
                    {
                        id = "step",
                        description = "One step",
                        required = 1,
                        mandatory = true,
                    },
                },
            },
        },
    })
end

local function populate_changeset_source(store, profile_count)
    define_changeset_surface(store)
    for i = 1, profile_count do
        local profile_id = "player_" .. i
        local profile = store:createProfile(profile_id, {
            display_name = "Player " .. i,
            tags = { "batch" },
            metadata = { wave = i % 4 },
        })
        store:addCounter(profile, "wins", i)
        store:setResource(profile, "focus", i % 5)
        if i % 2 == 0 then
            store:acceptQuest(profile_id, "cleanup")
            store:setQuestObjective(profile_id, "cleanup", "step", 1)
        end
    end
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

local function new_legacy_quest(id, title, max_journal_entries)
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
        _max_journal = max_journal_entries,
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

local function top_rows_summary(rows, limit)
    local out = {}
    local last = math.min(limit, #rows)
    for i = 1, last do
        local row = rows[i]
        out[#out + 1] = {
            rank = row.rank,
            profile_id = row.profile_id,
            score = row.score,
        }
    end
    return out
end

-- @describe Evidence: lurek.progression headless performance traces
describe("Evidence: lurek.progression headless performance traces", function()
    before_each(function()
        ensure_evidence_dir("progression")
    end)

    -- Does: Builds one mixed human and virtual leaderboard population, advances simulation headlessly, and records timing plus representative leaderboard slices.
    -- Shows: The report should make population generation, simulation, and leaderboard query costs legible alongside deterministic top-row output.
    -- Artifact: tests/artifacts/current/progression/progression_population_leaderboard_perf.json, tests/artifacts/current/progression/progression_population_leaderboard_perf.txt
    -- Why: This is meaningful because every reported metric comes from public lurek.progression APIs exercised without rendering or network access.
    it("JSON+TXT: population, leaderboard, and simulation throughput", function()
        local store = new_store("progression_evidence_population")
        define_population_surface(store, 128)
        add_human_scores(store, 24)

        local generate_elapsed, population = measured(function()
            return store:generatePopulation("bots", { id = "bots_run" })
        end)
        local update_elapsed, update_report = measured(function()
            return store:updatePopulation("bots_run", 30)
        end)
        local top_elapsed, top = measured(function()
            return store:listLeaderboardTop("arena", 10)
        end)
        local range_elapsed, range_rows = measured(function()
            return store:listLeaderboardRange("arena", 10, 10)
        end)
        local stats = store:getPopulationStatistics("bots_run", { leaderboard_id = "arena" })

        expect_equal(128, population.generated_count)
        expect_equal(30, update_report.logical_time)
        expect_equal(10, #top)
        expect_equal(10, #range_rows)
        expect_true(stats.leaderboards.arena.count >= 128)

        local report = {
            scenario = "population_leaderboard",
            humans = 24,
            bots = population.generated_count,
            logical_time = update_report.logical_time,
            timings = {
                generate_population = generate_elapsed,
                update_population = update_elapsed,
                list_leaderboard_top = top_elapsed,
                list_leaderboard_range = range_elapsed,
            },
            aggregate = {
                leaderboard_count = stats.leaderboards.arena.count,
                leaderboard_average = stats.leaderboards.arena.average,
                leaderboard_min = stats.leaderboards.arena.min,
                leaderboard_max = stats.leaderboards.arena.max,
            },
            top_rows = top_rows_summary(top, 5),
            range_rows = top_rows_summary(range_rows, 3),
        }
        local lines = {
            "scenario=population_leaderboard",
            "humans=24",
            "bots=" .. tostring(population.generated_count),
            "logical_time=" .. tostring(update_report.logical_time),
            string.format("generate_population=%.6f", generate_elapsed),
            string.format("update_population=%.6f", update_elapsed),
            string.format("list_leaderboard_top=%.6f", top_elapsed),
            string.format("list_leaderboard_range=%.6f", range_elapsed),
            "top_1=" .. tostring(top[1].profile_id) .. ":" .. tostring(top[1].score),
            "top_2=" .. tostring(top[2].profile_id) .. ":" .. tostring(top[2].score),
        }
        write_text(OUT .. "progression_population_leaderboard_perf.json", lurek.serialize.toJson(report))
        write_text(OUT .. "progression_population_leaderboard_perf.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Populates many profiles, exports both legacy and envelope changesets, applies them to fresh stores, and records retention-management timings.
    -- Shows: The report should prove that transport-neutral sync paths stay headless, deterministic, and bounded while moving real progression state.
    -- Artifact: tests/artifacts/current/progression/progression_changeset_roundtrip_perf.json, tests/artifacts/current/progression/progression_changeset_roundtrip_perf.txt
    -- Why: This is meaningful because the artifacts are generated from public changeset export, import, acknowledgement, and compaction APIs instead of mocked sync data.
    it("JSON+TXT: changeset export, apply, ack, and compaction throughput", function()
        local legacy_source = new_store("progression_evidence_changes_legacy_source")
        populate_changeset_source(legacy_source, 12)
        local source = new_store("progression_evidence_changes_source")
        populate_changeset_source(source, 32)

        local legacy_export_elapsed, legacy_payload = measured(function()
            return legacy_source:exportChangesSince(0)
        end)
        local envelope_export_elapsed, envelope_payload = measured(function()
            return source:exportChangeset(0, { max_records = 4 })
        end)

        local legacy_target = new_store("progression_evidence_changes_legacy_target")
        local legacy_apply_elapsed, legacy_report = measured(function()
            return legacy_target:applyChangeset(legacy_payload)
        end)

        local envelope_target = new_store("progression_evidence_changes_envelope_target")
        define_changeset_surface(envelope_target)
        local envelope_apply_elapsed, envelope_report = measured(function()
            return envelope_target:applyChangesetEnvelope(envelope_payload, {
                require_definition_hash_match = true,
                require_schema_match = true,
            })
        end)

        local envelope = lurek.serialize.fromJson(envelope_payload)
        local ack_elapsed, ack_report = measured(function()
            return source:ackChangesThrough(envelope.records[1].revision)
        end)
        local compact_elapsed, compact_report = measured(function()
            return source:compactChanges(4)
        end)

        expect_true(legacy_report.applied)
        expect_true(envelope_report.applied)
        expect_equal(legacy_source:getCounter("player_12", "wins"), legacy_target:getCounter("player_12", "wins"))
        expect_equal(source:getCounter("player_16", "wins"), envelope_target:getCounter("player_16", "wins"))

        local report = {
            scenario = "changeset_roundtrip",
            profiles = {
                legacy = 12,
                envelope = 32,
            },
            revisions = {
                latest = source:getRevision(),
                envelope_from = envelope.from_revision,
                envelope_to = envelope.to_revision,
                retained_after_ack = ack_report.remainingCount,
                retained_after_compact = compact_report.afterCount,
            },
            sizes = {
                legacy_payload_bytes = #legacy_payload,
                envelope_payload_bytes = #envelope_payload,
                envelope_record_count = #envelope.records,
            },
            timings = {
                legacy_export = legacy_export_elapsed,
                legacy_apply = legacy_apply_elapsed,
                envelope_export = envelope_export_elapsed,
                envelope_apply = envelope_apply_elapsed,
                ack_changes = ack_elapsed,
                compact_changes = compact_elapsed,
            },
            spot_checks = {
                player_16_wins = envelope_target:getCounter("player_16", "wins"),
                player_20_focus = envelope_target:getResource("player_20", "focus").value,
                player_24_cleanup = envelope_target:getQuestState("player_24", "cleanup").status,
            },
        }
        local lines = {
            "scenario=changeset_roundtrip",
            "legacy_profiles=12",
            "envelope_profiles=32",
            "latest_revision=" .. tostring(source:getRevision()),
            "envelope_records=" .. tostring(#envelope.records),
            "legacy_payload_bytes=" .. tostring(#legacy_payload),
            "envelope_payload_bytes=" .. tostring(#envelope_payload),
            string.format("legacy_export=%.6f", legacy_export_elapsed),
            string.format("legacy_apply=%.6f", legacy_apply_elapsed),
            string.format("envelope_export=%.6f", envelope_export_elapsed),
            string.format("envelope_apply=%.6f", envelope_apply_elapsed),
            string.format("ack_changes=%.6f", ack_elapsed),
            string.format("compact_changes=%.6f", compact_elapsed),
            "player_16_wins=" .. tostring(envelope_target:getCounter("player_16", "wins")),
            "player_24_cleanup=" .. tostring(envelope_target:getQuestState("player_24", "cleanup").status),
        }
        write_text(OUT .. "progression_changeset_roundtrip_perf.json", lurek.serialize.toJson(report))
        write_text(OUT .. "progression_changeset_roundtrip_perf.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Builds former library-style stats and quest data through `lurek.progression` adapters only, then records the resulting canonical engine state and confirms the old library modules are absent.
    -- Shows: The artifact should prove that migration no longer depends on `library.stats` or `library.quest` while still covering thresholds, damage, traits, journals, and quest completion.
    -- Artifact: tests/artifacts/current/progression/progression_legacy_adapter_migration.json, tests/artifacts/current/progression/progression_legacy_adapter_migration.txt
    -- Why: This is meaningful because the report is generated from public `lurek.progression` APIs plus real `require(...)` checks after the legacy Lua libraries have been removed.
    it("JSON+TXT: legacy adapter migration without external library modules", function()
        local stats_ok = pcall(require, "library.stats")
        local quest_ok = pcall(require, "library.quest")
        expect_false(stats_ok)
        expect_false(quest_ok)

        local store = new_store("progression_evidence_legacy_adapter")
        store:createProfile("player", { display_name = "Player" })

        local stats = lurek.progression.createLegacyStatsAdapter(store, "player")
        stats:define("hp", 100, { min = 0, max = 150 })
        stats:setResistance("fire", 0.25)
        define_legacy_trait(store, "veteran", "hp", 10)
        stats:applyTraitBuffs("veteran")
        stats:setLevelThresholds({ kind = "table", values = { 50, 100, 200 } })
        stats:addXP(160)
        local actual_damage = stats:applyDamage("hp", 40, "fire")

        local quests = lurek.progression.createLegacyQuestAdapter(store, "player")
        local quest = new_legacy_quest("cleanup", "Cleanup", 2)
        quest:setMeta("origin", "engine")
        quest:addJournalEntry("Cleanup assigned", "system")
        quests:addQuest(quest)
        quests:startQuest("cleanup")
        quests:addJournalEntry("cleanup", "First sweep complete")
        quests:advanceObjective("cleanup", "step", 1)
        quests:setQuestReward("cleanup", "gold")
        quests:completeQuest("cleanup")

        local quest_state = quests:getQuest("cleanup")
        local report = {
            scenario = "legacy_adapter_migration",
            library_modules_present = {
                stats = stats_ok,
                quest = quest_ok,
            },
            stats = {
                hp_base = stats:getBase("hp"),
                hp_effective = stats:get("hp"),
                resistance_fire = stats:getResistance("fire"),
                actual_damage = actual_damage,
                xp = stats:getXP(),
                level = stats:getLevel(),
                active_traits = stats:getActiveTraits(),
            },
            quest = {
                id = quest_state.id,
                status = quest_state.status,
                reward = quests:getQuestReward("cleanup"),
                journal_entries = #quest_state.journal,
                first_journal = quest_state.journal[1] and quest_state.journal[1].text or "",
                metadata_origin = quest_state.metadata.origin,
            },
            snapshot = stats:snapshot(),
        }
        local lines = {
            "scenario=legacy_adapter_migration",
            "library_stats_present=" .. tostring(stats_ok),
            "library_quest_present=" .. tostring(quest_ok),
            "hp_base=" .. tostring(stats:getBase("hp")),
            "hp_effective=" .. tostring(stats:get("hp")),
            "actual_damage=" .. tostring(actual_damage),
            "xp=" .. tostring(stats:getXP()),
            "level=" .. tostring(stats:getLevel()),
            "quest_status=" .. tostring(quest_state.status),
            "quest_reward=" .. tostring(quests:getQuestReward("cleanup")),
            "journal_entries=" .. tostring(#quest_state.journal),
            "metadata_origin=" .. tostring(quest_state.metadata.origin),
        }

        expect_equal(70, stats:getBase("hp"))
        expect_equal(80, stats:get("hp"))
        expect_equal(3, stats:getLevel())
        expect_equal("completed", quest_state.status)
        expect_equal("gold", quests:getQuestReward("cleanup"))

        write_text(OUT .. "progression_legacy_adapter_migration.json", lurek.serialize.toJson(report))
        write_text(OUT .. "progression_legacy_adapter_migration.txt", table.concat(lines, "\n") .. "\n")
    end)

    -- Does: Applies, pauses, filters, snapshots, and restores one neutral status instance through the existing progression tracker.
    -- Shows: The trace records copied tags, paused state, remaining time, filter count, and restored compatibility state.
    -- Artifact: tests/artifacts/current/progression/progression_status_tracker_trace.txt
    -- Why: This proves the tracker owns deterministic lifecycle data only; no damage, healing, ECS, audio, or presentation action occurs automatically.
    it("TXT: neutral status lifecycle and snapshot trace", function()
        local tracker = lurek.progression.newStatusTracker()
        tracker:define({
            id = "evidence_status",
            duration = 5,
            tickInterval = 1,
            tags = { "harmful", "evidence" },
        })
        local instance_id = tracker:apply(17, "evidence_status", 44)
        tracker:setPaused(instance_id, true)
        tracker:update(2)
        local filtered = tracker:list(17, {
            tag = "evidence",
            sourceId = 44,
            paused = true,
        })
        local restored = lurek.progression.newStatusTracker()
        restored:restore(tracker:snapshot())
        local instance = restored:get(instance_id)
        local lines = {
            "instance_id=" .. tostring(instance.id),
            "definition_id=" .. tostring(instance.definitionId),
            "tags=" .. table.concat(instance.tags, ","),
            "paused=" .. tostring(instance.paused),
            "remaining=" .. tostring(instance.remaining),
            "filtered_count=" .. tostring(#filtered),
            "events_after_paused_update=" .. tostring(#tracker:drainEvents()),
        }
        write_text(OUT .. "progression_status_tracker_trace.txt", table.concat(lines, "\n") .. "\n")
    end)
end)

test_summary()
