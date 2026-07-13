<!-- GENERATED FILE. Do not edit directly. Edit docs/specs/manual/progression.md or source docstrings instead. -->

# progression

## TL;DR

- `lurek.progression` is the canonical offline-first progression store for counters, stats-like data, resources, XP, achievements, quests, rewards, event history, seasons, rivals, deterministic virtual populations, and initial transport-neutral changesets.
- The initial implementation is headless and deterministic.
- Legacy-style stats and quest adapters now live directly inside `lurek.progression`, so old gameplay patterns can migrate without keeping separate `library.stats` or `library.quest` modules.

## General Info

- Module group: `Feature Systems`
- Source path: `src/progression`
- Binding: `src/lua_api/progression_api.rs`
- Namespace: `lurek.progression`
- Lua API surface: `91` functions, `3` types, `169` methods
- User-facing: `true`
- Plugin tier: `not_evaluated`

## Summary

`lurek.progression` introduces a store-based progression model under `src/progression/` and exposes it to Lua as `lurek.progression`.

The current slice includes:

- isolated stores with logical time and bounded events;
- profiles with tags and metadata;
- counter definitions and threshold events;
- shared condition compile/validate/evaluate/explain helpers for counter, achievement, quest, tag, all/any/not checks;
- initial derived-value definitions with named progression inputs, arithmetic expressions, validation, and explanations;
- initial profile template definitions with authored counter, attribute, resource, XP, tag, and metadata seeding;
- initial trait and perk definitions with canonical per-profile trait activation and perk-granted trait unlocks;
- initial skill definitions with learned levels, attribute-backed costs, manual use, and cooldown ticking through store updates;
- initial leaderboard definitions with deterministic ranking, manual score submission, counter-backed score sources, top/range/around-profile queries, and top-threshold movement events;
- initial season definitions with manual logical start/end control, optional archive snapshots, and reset hooks for selected counters and leaderboards;
- initial prestige definitions with level-gated rebirth checks, selected counter/level resets, preserved achievement state, and lifetime counter carry-forward;
- initial collections with achievement-set items, hidden codex-style discoveries, completion percentage, and optional meta-achievement unlocks;
- initial challenge templates with manual or counter-driven progress, activation windows, status filters, expiry, and reward records;
- initial rivals with leaderboard-aware delta queries, overtake events, and a bounded local activity feed derived from retained progression events;
- initial virtual population templates with deterministic identity generation, leaderboard-backed lightweight profiles, logical-time simulation, materialization/dematerialization, and leaderboard participation without a network service;
- attributes, resources, modifiers, and XP/level tracks;
- achievements with manual and counter-triggered unlocks;
- reward records with pending, claimed, applied, and rejected states;
- quest definitions with reveal and availability lifecycle, manual progress, canonical journal entries, visible/hidden objectives, explicit objective status overrides, counter-driven objectives, and quest rewards;
- transaction batching, debug snapshots, bounded changeset envelopes with schema/hash validation, ack/compaction helpers, and compatibility `exportChangesSince` / `applyChangeset` support built from retained revision snapshots;
- initial changeset merge policies with conflict reports for local profile divergence and quest-branch mismatches;
- malformed or oversized changesets are rejected before snapshot application;
- legacy import helpers for snapshots produced by the former `library.stats` and `library.quest` flows.

The module is intentionally headless. It owns data and mutation rules only.

## Ownership

- Canonical source: `src/progression`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/progression_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### attribute.rs

- `src/progression/attribute.rs` reserves the attribute-focused extraction surface planned for base values, modifiers, and explanations.
- This file exists to align the progression module layout with the implementation roadmap.

### challenge.rs

- `src/progression/challenge.rs` owns reusable challenge templates, per-profile challenge runs, and challenge progression helpers.
- It keeps engagement-style timed challenge logic out of `store.rs` while preserving deterministic offline behavior.

### collection.rs

- `src/progression/collection.rs` owns collections, achievement-linked discovery, completion checks, and collection snapshots.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### condition.rs

- `src/progression/condition.rs` reserves the condition-focused extraction surface planned for authored conditions and explanations.
- This file exists to align the progression module layout with the implementation roadmap.

### counter.rs

- `src/progression/counter.rs` reserves the counter-focused extraction surface planned for mutation, thresholds, and history helpers.
- This file exists to align the progression module layout with the implementation roadmap.

### event.rs

- `src/progression/event.rs` owns bounded activity-feed projections over retained progression events.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### leaderboard.rs

- `src/progression/leaderboard.rs` owns leaderboard definitions, score mutation, rank queries, and leaderboard-side event helpers.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### mod.rs

- `src/progression/mod.rs` declares the headless progression domain used by `lurek.progression`.
- This module owns offline progression state, deterministic mutations, and snapshot-shaped data.
- Lua bindings live in `src/lua_api/progression_api.rs` and should stay thin over these types.
- The store is CPU-only and does not depend on rendering, audio, networking, or a live Lua VM.

### persistence.rs

- `src/progression/persistence.rs` owns snapshot and incremental-sync helpers for progression state.
- It adds bounded changeset envelopes, validation, acknowledgements, and compaction without changing the headless store model.

### population.rs

- `src/progression/population.rs` owns offline population templates, simulation, materialization, and population validation helpers.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### prestige.rs

- `src/progression/prestige.rs` owns prestige definitions, reset application, lifetime tracking, and prestige serialization.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### profile.rs

- `src/progression/profile.rs` owns profile-template application helpers and trait-definition validation shared by progression profiles.
- It keeps profile-shaping helper logic out of `store.rs` while preserving the same store API surface.

### rival.rs

- `src/progression/rival.rs` owns pinned rival relationships, rival deltas, and rivalry overtake event helpers.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### season.rs

- `src/progression/season.rs` owns authored seasons, archive snapshots, resets, and season serialization helpers.
- It keeps virtual-profile simulation and related store helpers out of `store.rs` while preserving the same API surface.

### store.rs

- `src/progression/store.rs` owns the deterministic in-memory progression store.
- It implements store mutation rules, profile state, transactions, event emission, and snapshots.
- Rendering, networking, UI text, and Lua conversion are intentionally out of scope here.

### types.rs

- `src/progression/types.rs` owns the data contracts for the progression store.
- These types are serializable, deterministic, and reusable by Rust tests and Lua bindings.
- Runtime mutation logic stays in `store.rs`; this file only defines durable shapes and enums.



## Lua API Ref

### Functions

- `lurek.progression.acquirePerk(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.activeCount(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.activeIds(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.addBuff() -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.addJournalEntry(this, quest_id, text, tag?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.addQuest(this, quest) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.addXP(this, amount) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.adjustMorale(this, delta) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.advanceObjective() -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.applyDamage(this, stat, amount, dtype?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.applyTraitBuffs(this, trait_name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.beginTurn(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.checkMorale(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.clearBuffs(this, stat?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.clearFlag(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.completeQuest(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.completedCount(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.completedIds(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.createLegacyQuestAdapter(store, profile, options?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.createLegacyStatsAdapter(store, profile, options?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.define(this, name, base, opts?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.definePerk(this, name, opts?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.defineSkill(this, name, opts?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.failQuest(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.failedIds(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.get(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getActionPoints(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getActiveTraits(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getBase(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getBuffCount(this, stat?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getBuffs(this, stat?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getCooldownRemaining(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getEncumbrance(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getFlags(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getInitiative(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getLevel(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getMax(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getMin(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getMorale(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getQuest(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getQuestReward(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getRegen(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getResistance(this, dtype) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getSkillLevel(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getStatNames(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getUseCount(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.getXP(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.hasFlag(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.hasPerk(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.hasTrait(this, trait_name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.importLegacyQuestSnapshot(snapshot) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.importLegacyStatsSnapshot(snapshot) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.isEncumbered(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.learnSkill(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.loadStore(snapshot) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.newStore(options?) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.questCount(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.questIds(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.questsWithStatus(this, wanted) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.recordUse(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.recoverActionPoints(this, amount) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.removeBuff(this, handle) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.removeQuest(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.removeTraitBuffs(this, trait_name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.resetQuest(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.restore(this, snap) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setActionPoints(this, max_val) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setBase(this, name, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setBerserkThreshold(this, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setEncumbrance(this, cur, max_val) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setFlag(this, name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setInitiative(this, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setLevel(this, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setLevelThresholds(this, thresholds) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setMax(this, name, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setMin(this, name, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setMorale(this, max_val) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setPanicThreshold(this, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setQuestReward(this, id, reward) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setRegen(this, name, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setResistance(this, dtype, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.setXP(this, value) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.snapshot(this) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.spendActionPoints(this, amount) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.startQuest(this, id) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.type() -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.type() -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.typeOf(name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.typeOf(name) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.update(this, dt) -> nil`: Lua-facing function documented in the binding source.
- `lurek.progression.useSkill(this, name) -> nil`: Lua-facing function documented in the binding source.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LProgressionProfile Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LProgressionProfile:getId() -> nil`: Lua-visible method.
- `LProgressionProfile:type() -> nil`: Lua-visible method.
- `LProgressionProfile:typeOf(name) -> nil`: Lua-visible method.

#### LProgressionStore Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LProgressionStore:acceptQuest(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:ackChangesThrough(revision) -> nil`: Lua-visible method.
- `LProgressionStore:acquirePerk(profile, perk_id) -> nil`: Lua-visible method.
- `LProgressionStore:activateChallenge(profile, challenge_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:addAttributeBase(profile, attribute_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:addCounter(profile, counter_id, amount?) -> nil`: Lua-visible method.
- `LProgressionStore:addExperience(profile, track_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:addModifier(profile, target_id, opts) -> nil`: Lua-visible method.
- `LProgressionStore:addProfileTag(id, tag) -> nil`: Lua-visible method.
- `LProgressionStore:addQuestJournalEntry(profile, quest_id, text, tag?) -> nil`: Lua-visible method.
- `LProgressionStore:addResource(profile, resource_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:advanceTime(seconds) -> nil`: Lua-visible method.
- `LProgressionStore:applyChangeset(changeset) -> nil`: Lua-visible method.
- `LProgressionStore:applyChangesetEnvelope(changeset, options?) -> nil`: Lua-visible method.
- `LProgressionStore:applyPrestige(profile, prestige_id) -> nil`: Lua-visible method.
- `LProgressionStore:applyProfileTemplate(profile, template_id) -> nil`: Lua-visible method.
- `LProgressionStore:applyTrait(profile, trait_id) -> nil`: Lua-visible method.
- `LProgressionStore:beginTransaction(options?) -> nil`: Lua-visible method.
- `LProgressionStore:canPrestige(profile, prestige_id) -> nil`: Lua-visible method.
- `LProgressionStore:canSpendResource(profile, resource_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:claimReward(profile, reward_id) -> nil`: Lua-visible method.
- `LProgressionStore:clear() -> nil`: Lua-visible method.
- `LProgressionStore:clearEvents() -> nil`: Lua-visible method.
- `LProgressionStore:collectCollectionItem(profile, collection_id, item_id) -> nil`: Lua-visible method.
- `LProgressionStore:compactChanges(max_records) -> nil`: Lua-visible method.
- `LProgressionStore:compileCondition(condition) -> nil`: Lua-visible method.
- `LProgressionStore:completeQuest(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:countProfiles(arg?) -> nil`: Lua-visible method.
- `LProgressionStore:createProfile(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:debugSnapshot() -> nil`: Lua-visible method.
- `LProgressionStore:defineAchievement(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineAttribute(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineChallengeTemplate(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineCollection(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineCounter(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineDerivedValue(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineLeaderboard(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineLevelTrack(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:definePerk(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:definePopulationTemplate(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:definePrestige(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineProfileTemplate(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineQuest(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineResource(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineSeason(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineSkill(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:defineTrait(id, definition) -> nil`: Lua-visible method.
- `LProgressionStore:dematerializePopulationProfile(profile_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:drainEvents() -> nil`: Lua-visible method.
- `LProgressionStore:endSeason(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:ensureProfile(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:evaluateCondition(profile, condition) -> nil`: Lua-visible method.
- `LProgressionStore:explainAttribute(profile, attribute_id) -> nil`: Lua-visible method.
- `LProgressionStore:explainCondition(profile, condition) -> nil`: Lua-visible method.
- `LProgressionStore:explainDerivedValue(profile, id) -> nil`: Lua-visible method.
- `LProgressionStore:exportChangesSince(revision) -> nil`: Lua-visible method.
- `LProgressionStore:exportChangeset(revision, options?) -> nil`: Lua-visible method.
- `LProgressionStore:exportSnapshot() -> nil`: Lua-visible method.
- `LProgressionStore:failQuest(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:generatePopulation(template_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:getAchievement(profile, achievement_id) -> nil`: Lua-visible method.
- `LProgressionStore:getActivityFeed(query?) -> nil`: Lua-visible method.
- `LProgressionStore:getAttribute(profile, attribute_id, mode?) -> nil`: Lua-visible method.
- `LProgressionStore:getAttributeState(profile, attribute_id) -> nil`: Lua-visible method.
- `LProgressionStore:getChallenge(profile, challenge_id) -> nil`: Lua-visible method.
- `LProgressionStore:getCollection(profile, collection_id) -> nil`: Lua-visible method.
- `LProgressionStore:getCounter(profile, counter_id) -> nil`: Lua-visible method.
- `LProgressionStore:getCounterState(profile, counter_id) -> nil`: Lua-visible method.
- `LProgressionStore:getDefinitionHash() -> nil`: Lua-visible method.
- `LProgressionStore:getDerivedValue(profile, id) -> nil`: Lua-visible method.
- `LProgressionStore:getExperience(profile, track_id) -> nil`: Lua-visible method.
- `LProgressionStore:getExperienceToNextLevel(profile, track_id) -> nil`: Lua-visible method.
- `LProgressionStore:getId() -> nil`: Lua-visible method.
- `LProgressionStore:getLeaderboardEntry(profile, leaderboard_id) -> nil`: Lua-visible method.
- `LProgressionStore:getLevel(profile, track_id) -> nil`: Lua-visible method.
- `LProgressionStore:getPendingRewards(profile) -> nil`: Lua-visible method.
- `LProgressionStore:getPopulation(handle_or_id) -> nil`: Lua-visible method.
- `LProgressionStore:getPopulationStatistics(handle_or_id, query?) -> nil`: Lua-visible method.
- `LProgressionStore:getPrestige(profile, prestige_id) -> nil`: Lua-visible method.
- `LProgressionStore:getProfile(id) -> nil`: Lua-visible method.
- `LProgressionStore:getQuestState(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:getResource(profile, resource_id) -> nil`: Lua-visible method.
- `LProgressionStore:getRevision() -> nil`: Lua-visible method.
- `LProgressionStore:getRival(profile, rival_profile) -> nil`: Lua-visible method.
- `LProgressionStore:getRivalDelta(profile, rival_profile) -> nil`: Lua-visible method.
- `LProgressionStore:getSchemaVersion() -> nil`: Lua-visible method.
- `LProgressionStore:getSeason(id) -> nil`: Lua-visible method.
- `LProgressionStore:getSeasonArchive(id, query?) -> nil`: Lua-visible method.
- `LProgressionStore:getSkillCooldown(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:getSkillLevel(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:getTime() -> nil`: Lua-visible method.
- `LProgressionStore:hasPerk(profile, perk_id) -> nil`: Lua-visible method.
- `LProgressionStore:hasProfile(id) -> nil`: Lua-visible method.
- `LProgressionStore:hasTrait(profile, trait_id) -> nil`: Lua-visible method.
- `LProgressionStore:learnSkill(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:listAchievements(profile) -> nil`: Lua-visible method.
- `LProgressionStore:listChallenges(profile, options?) -> nil`: Lua-visible method.
- `LProgressionStore:listCollections(profile) -> nil`: Lua-visible method.
- `LProgressionStore:listCounters(profile) -> nil`: Lua-visible method.
- `LProgressionStore:listLeaderboardAroundProfile() -> nil`: Lua-visible method.
- `LProgressionStore:listLeaderboardRange(leaderboard_id, start_rank, limit?) -> nil`: Lua-visible method.
- `LProgressionStore:listLeaderboardTop(leaderboard_id, limit?) -> nil`: Lua-visible method.
- `LProgressionStore:listModifiers(profile) -> nil`: Lua-visible method.
- `LProgressionStore:listPopulationProfiles(handle_or_id, query?) -> nil`: Lua-visible method.
- `LProgressionStore:listPrestiges(profile) -> nil`: Lua-visible method.
- `LProgressionStore:listProfiles(arg?) -> nil`: Lua-visible method.
- `LProgressionStore:listQuestJournalEntries(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:listRivals(profile) -> nil`: Lua-visible method.
- `LProgressionStore:listSeasons(query?) -> nil`: Lua-visible method.
- `LProgressionStore:listTraits(profile) -> nil`: Lua-visible method.
- `LProgressionStore:loadSnapshot(snapshot) -> nil`: Lua-visible method.
- `LProgressionStore:markRewardApplied(profile, reward_id, external_receipt?) -> nil`: Lua-visible method.
- `LProgressionStore:materializePopulationProfile(profile_id) -> nil`: Lua-visible method.
- `LProgressionStore:pausePopulation(handle_or_id) -> nil`: Lua-visible method.
- `LProgressionStore:pinRival(profile, rival_profile, options?) -> nil`: Lua-visible method.
- `LProgressionStore:refillResource(profile, resource_id, amount?) -> nil`: Lua-visible method.
- `LProgressionStore:refreshQuestLifecycle(profile) -> nil`: Lua-visible method.
- `LProgressionStore:regeneratePopulation(handle_or_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:rejectReward(profile, reward_id, reason?) -> nil`: Lua-visible method.
- `LProgressionStore:removeDerivedValue(id) -> nil`: Lua-visible method.
- `LProgressionStore:removeModifier(profile, handle) -> nil`: Lua-visible method.
- `LProgressionStore:removePopulation(handle_or_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:removeProfile(id, opts?) -> nil`: Lua-visible method.
- `LProgressionStore:removeProfileMetadata(id, key) -> nil`: Lua-visible method.
- `LProgressionStore:removeProfileTag(id, tag) -> nil`: Lua-visible method.
- `LProgressionStore:removeTrait(profile, trait_id) -> nil`: Lua-visible method.
- `LProgressionStore:resumePopulation(handle_or_id) -> nil`: Lua-visible method.
- `LProgressionStore:revealQuest(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:setAttributeBase(profile, attribute_id, value) -> nil`: Lua-visible method.
- `LProgressionStore:setChallengeProgress(profile, challenge_id, value) -> nil`: Lua-visible method.
- `LProgressionStore:setCounter(profile, counter_id, value) -> nil`: Lua-visible method.
- `LProgressionStore:setExperience(profile, track_id, value) -> nil`: Lua-visible method.
- `LProgressionStore:setLevel(profile, track_id, level) -> nil`: Lua-visible method.
- `LProgressionStore:setProfileMetadata(id, key, value) -> nil`: Lua-visible method.
- `LProgressionStore:setQuestObjective(profile, quest_id, objective_id, value) -> nil`: Lua-visible method.
- `LProgressionStore:setQuestObjectiveStatus(profile, quest_id, objective_id, status) -> nil`: Lua-visible method.
- `LProgressionStore:setQuestObjectiveVisibility(profile, quest_id, objective_id, visible) -> nil`: Lua-visible method.
- `LProgressionStore:setResource(profile, resource_id, value) -> nil`: Lua-visible method.
- `LProgressionStore:setTime(seconds) -> nil`: Lua-visible method.
- `LProgressionStore:simulatePopulationUntil(handle_or_id, logical_time, options?) -> nil`: Lua-visible method.
- `LProgressionStore:spendResource(profile, resource_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:startSeason(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:stats() -> nil`: Lua-visible method.
- `LProgressionStore:submitScore(profile, leaderboard_id, score) -> nil`: Lua-visible method.
- `LProgressionStore:type() -> nil`: Lua-visible method.
- `LProgressionStore:typeOf(name) -> nil`: Lua-visible method.
- `LProgressionStore:unlockAchievement(profile, achievement_id) -> nil`: Lua-visible method.
- `LProgressionStore:update(dt, opts?) -> nil`: Lua-visible method.
- `LProgressionStore:updatePopulation(handle_or_id, dt, options?) -> nil`: Lua-visible method.
- `LProgressionStore:updateProfile(id, patch?) -> nil`: Lua-visible method.
- `LProgressionStore:useSkill(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:validate() -> nil`: Lua-visible method.
- `LProgressionStore:validateCondition(condition) -> nil`: Lua-visible method.
- `LProgressionStore:validateDerivedValues() -> nil`: Lua-visible method.
- `LProgressionStore:validatePopulationTemplate(id) -> nil`: Lua-visible method.

#### LProgressionTransaction Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LProgressionTransaction:addCounter(profile, counter_id, amount) -> nil`: Lua-visible method.
- `LProgressionTransaction:addExperience(profile, track_id, amount) -> nil`: Lua-visible method.
- `LProgressionTransaction:addModifier(profile, target_id, opts) -> nil`: Lua-visible method.
- `LProgressionTransaction:commit() -> nil`: Lua-visible method.
- `LProgressionTransaction:rollback() -> nil`: Lua-visible method.
- `LProgressionTransaction:setAttributeBase(profile, attribute_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:setCounter(profile, counter_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:setQuestObjective(profile, quest_id, objective_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:setResource(profile, resource_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:type() -> nil`: Lua-visible method.
- `LProgressionTransaction:typeOf(name) -> nil`: Lua-visible method.

## Examples

- `content/examples/progression.lua` (present)

## Architecture Links

- No module-specific architecture links registered.

## Notes

- Use `clock = "manual"` for deterministic tests and offline simulation.
- Store and transaction APIs are designed so later roadmap phases can extend the module without changing the top-level ownership model.
- New gameplay code should use `lurek.progression` directly; the legacy adapter surface is now provided by that engine module instead of separate Lua libraries.
