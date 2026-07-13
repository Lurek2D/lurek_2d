-- Lurek2D stress test for lurek.progression population, leaderboard, and sync throughput.

local function new_store(id)
    return lurek.progression.newStore({
        id = id,
        seed = 11,
        clock = "manual",
        event_limit = 2048,
        max_change_records = 512,
    })
end

local function define_population_surface(store, bot_count, human_count)
    store:defineLeaderboard("arena", {
        title = "Arena",
        sort = "descending",
        rank_mode = "ordinal",
        max_entries = bot_count + human_count,
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
                skill = { mean = 1000, deviation = 40 },
            },
            {
                id = "sharp",
                weight = 1,
                activity = { min = 2, max = 3 },
                skill = { mean = 1090, deviation = 30 },
            },
        },
        leaderboards = {
            arena = {
                initial_score = { distribution = "normal" },
                progression = {
                    mode = "bounded_random_walk",
                    volatility = 8,
                    mean_reversion = 0.15,
                },
            },
        },
    })
    for i = 1, human_count do
        local profile = store:createProfile("human_" .. i)
        store:submitScore(profile, "arena", 900 + i * 5)
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
        local profile = store:createProfile(profile_id)
        store:addCounter(profile, "wins", i)
        store:setResource(profile, "focus", i % 5)
        if i % 2 == 0 then
            store:acceptQuest(profile_id, "cleanup")
            store:setQuestObjective(profile_id, "cleanup", "step", 1)
        end
    end
end

-- @describe stress: progression population generation throughput
describe("stress: progression population generation throughput", function()
    -- @stress LProgressionStore:generatePopulation
    it("256 virtual profiles generate repeatedly in <10s", function()
        local elapsed = measure("progression generatePopulation", 4, function()
            local store = new_store("progression_generate_stress")
            define_population_surface(store, 256, 32)
            local population = store:generatePopulation("bots", { id = "bots_run" })
            expect_equal(256, population.generated_count)
        end)
        expect_true(elapsed < 10.0, "generatePopulation budget: " .. elapsed .. "s")
    end)
end)

-- @describe stress: progression simulation and leaderboard query throughput
describe("stress: progression simulation and leaderboard query throughput", function()
    -- @stress LProgressionStore:updatePopulation
    it("population simulation updates stay under budget", function()
        local store = new_store("progression_update_stress")
        define_population_surface(store, 256, 32)
        store:generatePopulation("bots", { id = "bots_run" })
        local elapsed = measure("progression updatePopulation", 24, function()
            local report = store:updatePopulation("bots_run", 1)
            expect_equal(256, report.updated_profiles)
        end)
        expect_true(elapsed < 10.0, "updatePopulation budget: " .. elapsed .. "s")
    end)

    -- @stress LProgressionStore:listLeaderboardTop
    it("top leaderboard queries over mixed rosters stay under budget", function()
        local store = new_store("progression_top_query_stress")
        define_population_surface(store, 256, 32)
        store:generatePopulation("bots", { id = "bots_run" })
        store:updatePopulation("bots_run", 8)
        local elapsed = measure("progression listLeaderboardTop", 80, function()
            local rows = store:listLeaderboardTop("arena", 25)
            expect_equal(25, #rows)
        end)
        expect_true(elapsed < 10.0, "listLeaderboardTop budget: " .. elapsed .. "s")
    end)
end)

-- @describe stress: progression changeset sync throughput
describe("stress: progression changeset sync throughput", function()
    -- @stress LProgressionStore:applyChangesetEnvelope
    it("envelope sync for 32 profiles stays under budget", function()
        local elapsed = measure("progression applyChangesetEnvelope", 4, function()
            local source = new_store("progression_changes_source")
            populate_changeset_source(source, 32)
            local encoded = source:exportChangeset(0, { max_records = 4 })

            local target = new_store("progression_changes_target")
            define_changeset_surface(target)
            local report = target:applyChangesetEnvelope(encoded, {
                require_definition_hash_match = true,
                require_schema_match = true,
            })

            expect_true(report.applied)
            expect_equal(32, target:getCounter("player_32", "wins"))
        end)
        expect_true(elapsed < 10.0, "applyChangesetEnvelope budget: " .. elapsed .. "s")
    end)
end)

test_summary()
