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
- Lua API surface: `92` functions, `21` types, `225` methods
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
- isolated `newStatusTracker()` handles with validated status definitions, copied per-instance tags, replace/refresh/add stacking, finite or infinite duration, pause/resume controls, deterministic filtered queries and bulk removal, backward-compatible snapshots, and neutral lifecycle events;
- attributes, resources, modifiers, and XP/level tracks;
- achievements with manual and counter-triggered unlocks;
- reward records with pending, claimed, applied, and rejected states;
- quest definitions with reveal and availability lifecycle, manual progress, canonical journal entries, visible/hidden objectives, explicit objective status overrides, counter-driven objectives, and quest rewards;
- transaction batching, debug snapshots, bounded changeset envelopes with schema/hash validation, ack/compaction helpers, and compatibility `exportChangesSince` / `applyChangeset` support built from retained revision snapshots;
- initial changeset merge policies with conflict reports for local profile divergence and quest-branch mismatches;
- malformed or oversized changesets are rejected before snapshot application;
- legacy import helpers for snapshots produced by the former `library.stats` and `library.quest` flows.

The module is intentionally headless. It owns data and mutation rules only.
Status ticks and expiry are emitted as neutral records; Lua gameplay code explicitly decides whether
to apply damage, healing, animation, audio, ECS changes, or other effects.
Pausing a status freezes both duration and periodic tick timers. Setting zero remaining duration
expires it on the next explicit tracker update, including `update(0)`.

## Ownership

- Canonical source: `src/progression`
- Owning tier: `Feature Systems`
- Plugin tier: `not_evaluated`
- Lua binding owner: `src/lua_api/progression_api.rs`
- Referenced engine modules: None detected from Rust imports.

## Imports

- No top-level `crate::<module>` imports were detected in this module's Rust source files.

## Source Files

### achievement.rs

- Owns authored achievement definitions plus per-profile unlock state and queued reward records.
- Exposes the store entrypoints that define achievements, unlock them, and query earned snapshots.
- Tracks repeatable completions, hidden presentation flags, and counter-trigger reverse indexes.
- Re-evaluates authored conditions before mutating profile records or emitting unlock-side events.
- Keeps achievement lifecycle rules out of `store.rs` so shared mutation plumbing stays narrower.
- Open this file when changing achievement authoring, unlock semantics, or reward-producing trophies.

### attribute.rs

- Owns attribute, resource, and modifier definitions plus per-profile state for stat-like progression data.
- Exposes canonical helpers that define, mutate, explain, spend, refill, and snapshot these profile values.
- Applies bounds, effective-value math, modifier storage, and resource normalization before state persists.
- Emits attribute, modifier, and resource events so other progression slices observe deterministic changes.
- Provides crate-local resource accessors reused by formulas and sibling owners without state duplication.
- Keeps stat and spendable-value behavior out of store-wide plumbing so growth rules stay cohesive.
- Open this file when changing attribute math, modifier handling, or resource spending semantics.

### challenge.rs

- Owns reusable challenge templates, per-profile challenge runs, expiry logic, and counter-driven progress updates.
- Stores authored challenge contracts alongside runtime state transitions for activation, completion, and timeout.
- Exposes the public store entrypoints that create runs, mutate progress, query snapshots, and list active work.
- Validates challenge definitions against existing counters, reward payloads, and authored time-window invariants.
- Re-evaluates counter-bound challenges after mutations so offline progression remains deterministic and evented.
- Expires active runs against the logical store clock instead of any wall-clock or platform-driven scheduler.
- Integrates with rewards, events, and retained profile state without depending on rendering, UI, or networking.
- Open this file when changing challenge authoring, lifecycle rules, or reward-bearing engagement mechanics.

### collection.rs

- Owns authored collections, per-profile collection state, hidden item discovery, and completion snapshots.
- Stores the rules that bind collection items to achievements and optional meta-achievement unlock behavior.
- Exposes public store helpers for definition, manual collection, querying, and deterministic list serialization.
- Validates collection definitions so item ids stay unique and referenced achievements exist before persistence.
- Synchronizes collection completion whenever achievements change, including hidden unlock and meta-owner checks.
- Integrates with rewards and achievements without adding renderer, inventory, or narrative-specific concerns.
- Open this file when changing collection authoring, discovery rules, or achievement-linked completion logic.

### condition.rs

- Owns authored condition trees, validation rules, evaluation helpers, and explanation payload generation.
- Exposes canonical helpers that compile, validate, evaluate, and explain progression predicates.
- Applies depth, fan-out, identifier, and reference checks before conditions run against store state.
- Resolves counter, level, achievement, quest, and tag predicates against canonical profile-owned data.
- Provides crate-local recursive helpers reused by quests, achievements, and prestige definitions.
- Keeps reusable predicate semantics out of store-wide plumbing so conditional logic stays cohesive.
- Open this file when changing predicate validation, evaluation semantics, or explanation structure.

### counter.rs

- Owns counter definitions, per-profile counter state, and threshold-aware mutation semantics.
- Exposes canonical helpers that define, add, set, list, and snapshot counters across the engine.
- Applies finite checks, monotonic rules, bounds, and value normalization before state persists.
- Refreshes quests, leaderboards, challenges, and achievements after writes so flow stays in sync.
- Keeps shared counter behavior out of store-wide plumbing so progression inputs stay cohesive.

### event.rs

- Owns filtered activity-feed projections over the store's retained progression event history.
- Shapes canonical event records into transport-neutral JSON snapshots without mutating or reordering store history.
- Exposes headless helpers that validate requested profile filters, apply type filters, and bound feed size.
- Open this file when activity-feed selection, event payload shape, or retained-event presentation needs adjustment.

### formula.rs

- Owns derived-value validation, parsing, AST evaluation, and bounded result normalization rules.
- Exposes the store entrypoints that read or explain derived values through one safe formula pipeline.
- Resolves counter, attribute, resource, level, and XP inputs into deterministic numeric maps.
- Stores the expression token and AST shapes used by validation, explanation, and runtime evaluation.
- Rejects malformed expressions, unsupported helpers, and non-finite results before they reach APIs.
- Keeps parser and evaluator internals out of `store.rs` so numeric derivation has a focused owner.
- Avoids Lua eval, runtime code execution, and rendering concerns so formulas stay headless and safe.
- Open this file when changing derived expressions, parser limits, supported math helpers, or payloads.

### leaderboard.rs

- Owns leaderboard definitions, score mutation, rank queries, and threshold-style leaderboard event emission.
- Stores deterministic ordering rules, tie handling, partitions, and query shaping for offline ranked state.
- Exposes public store helpers for authoring leaderboards, submitting scores, and reading ranked projections.
- Recomputes counter-bound leaderboards after source mutations while avoiding duplicate synchronization events.
- Integrates with rivals, seasons, and virtual populations without depending on UI tables or online services.
- Keeps ranking semantics local to progression so tests can prove ordering, ranges, and around-profile queries.
- Open this file when changing score ownership, ranking behavior, or leaderboard-derived progression events.

### level.rs

- Owns level-track progression, stored experience totals, and normalized level snapshots for profiles.
- Exposes the store entrypoints that add XP, set absolute XP, set explicit levels, and query state.
- Applies authored track bounds, carry-over policy, and capped level advancement in canonical data.
- Emits level and experience events so downstream systems observe one deterministic growth sequence.
- Open this file when changing XP accumulation, level caps, carry-over semantics, or level snapshots.

### mod.rs

- Declares the headless progression domain that backs the public `lurek.progression` Lua module.
- Exports the store, data contracts, and focused subsystem files that own deterministic progression behavior.
- Separates profiles, leaderboards, populations, seasons, persistence, and event helpers into navigable owners.
- Reexports the symbols that Rust tests and Lua bindings need without requiring callers to know file layout.
- Marks the progression domain as CPU-only and independent from rendering, audio, networking, or live Lua state.
- Open this index when routing a change to the correct progression owner or tracing reexports into sibling files.

### persistence.rs

- Owns progression snapshot transport, retained change records, and bounded changeset envelope validation.
- Stores the rules for exporting retained revisions, applying envelopes, acknowledging history, and compaction.
- Exposes public persistence helpers that keep sync payloads deterministic, versioned, and transport-neutral.
- Validates record counts and serialized sizes before export or import so malformed payloads fail early.
- Encodes merge-policy outcomes, conflict reports, and source-target revision metadata for caller inspection.
- Integrates with the main store snapshot model without adding backend concerns, auth state, or network code.
- Keeps offline sync semantics local to progression so tests can prove replay, ack, and compaction behavior.
- Open this file when changing save transport, incremental replication, or retained-history validation rules.

### population.rs

- Owns offline population templates, generated virtual profiles, simulation ticks, and materialization helpers.
- Stores deterministic identity generation, archetype weighting, leaderboard seeding, and activity simulation.
- Exposes public store helpers for defining templates, generating runs, advancing time, and querying statistics.
- Validates population templates so seeded generation remains bounded, deterministic, and leaderboard-aware.
- Simulates virtual profile progress without requiring remote services, hidden threads, or nondeterministic timers.
- Materializes virtual profiles into canonical store state only when callers explicitly need concrete profile data.
- Maintains reverse indexes between virtual handles and real profiles so dematerialization stays lossless and safe.
- Integrates with leaderboards, rivals, and events while keeping population-specific bookkeeping out of `store.rs`.
- Keeps simulation-side state local to progression so tests can prove seeded replay and budgeted catch-up behavior.
- Open this file when changing bot generation, offline simulation, or virtual profile persistence boundaries.

### prestige.rs

- Owns prestige definitions, reset application, preserved-history rules, and prestige snapshot serialization.
- Stores the contracts that decide when a profile may prestige and which counters or tracks survive the reset.
- Exposes public store helpers for authoring prestiges, checking eligibility, applying resets, and querying state.
- Validates prestige definitions against authored counters, level tracks, and preserved-history configuration.
- Integrates with achievements, counters, and experience without coupling prestige rules to UI or narrative flow.
- Open this file when changing rebirth semantics, retained history, or level-gated reset progression behavior.

### profile.rs

- Owns profile lifecycle, templates, traits, perks, skills, and the profile-facing identity mutation surface.
- Stores canonical profile identity, tags, metadata, trait handles, skill levels, and acquired perk ownership.
- Exposes public store helpers for creating profiles, applying templates, mutating identity, and querying shape.
- Validates template and trait definitions against authored counters, attributes, resources, and level tracks.
- Applies template payloads into canonical profile state while preserving caller-selected identity overrides.
- Owns trait, perk, and skill rules so profile progression stays separate from counters, quests, and snapshots.
- Spends attribute-backed skill costs and cooldown state here because learned-skill behavior is profile-local.
- Integrates with quests, achievements, and rewards through store events without pulling those systems inside.
- Keeps profile-shaped rules out of `store.rs` so identity and advancement changes have a focused maintenance home.
- Open this file when changing profile creation, template application, traits, perks, or learned-skill behavior.

### quest.rs

- Owns authored quest definitions, materialized quest state, retained journals, and stage progress for profiles.
- Exposes store-facing helpers for definition, reveal, accept, fail, complete, journal writes, and snapshot queries.
- Stores reverse bindings from counters to objectives so writes refresh only the affected active quest state.
- Applies hidden, revealed, available, active, completed, and failed transitions inside canonical engine state.
- Advances mandatory stage objectives, trims retained journals by authored limits, and preserves completion counts.
- Emits quest lifecycle, objective, journal, and reward-availability events in deterministic store order.
- Keeps authored availability and reveal conditions near quest-state transitions so discovery rules stay aligned.
- Reuses shared condition evaluation and reward records without duplicating attribute, counter, or payout logic.
- Keeps branching objective behavior out of store-wide plumbing so quest rules stay cohesive and testable.
- Open this file when changing quest validation, objective sync, journal retention, or lifecycle semantics.

### reward.rs

- Owns profile-scoped reward records and the canonical pending-claimed-applied-rejected state machine.
- Defines the store helpers that list outstanding reward work and transition records without applying game payloads.
- Persists optional external receipts, emits reward lifecycle events, and bumps revisions for every accepted change.
- Keeps payout-state rules separate from achievements, quests, and downstream economy code so producers stay decoupled.
- Open this file when changing reward transitions, external receipt storage, or queue-facing reward semantics.

### rival.rs

- Owns pinned rival relationships, rivalry deltas, and overtake event emission derived from leaderboard changes.
- Stores the profile-local rival contracts that connect chosen rivals to one or more authored leaderboards.
- Exposes public store helpers for pinning rivals, reading rival snapshots, and querying score or rank deltas.
- Captures pre-refresh rival relations so score updates can emit stable overtake events after ordering changes.
- Integrates with leaderboards and the activity feed without introducing matchmaking, social, or network features.
- Open this file when changing rivalry tracking, delta semantics, or overtake event generation rules.

### season.rs

- Owns authored seasons, archive snapshots, reset application, and season lifecycle serialization helpers.
- Stores season definitions, active windows, archive outputs, and reset targets for counters and leaderboards.
- Exposes public store helpers for defining seasons, starting runs, ending runs, and querying archives or status.
- Validates season definitions against existing counters and leaderboards before any runtime lifecycle changes.
- Applies configured resets and archive snapshots against logical time so offline tests can prove exact behavior.
- Integrates with leaderboards and counters without coupling season rules to rewards, UI, or external services.
- Open this file when changing season boundaries, archive contents, or reset semantics for cyclical progression.

### store.rs

- Owns deterministic progression store state, shared indexes, retained events, and retained change history.
- Stores profiles, authored definitions, revision counters, snapshots, and transaction bookkeeping at the root.
- Exposes creation, snapshot, update, and cross-slice seams reused by focused progression owners in sibling files.
- Applies shared validation, event buffering, change retention, and revision bumps before domain-specific slices fan out.
- Defines the private runtime structs that back counters, attributes, quests, rewards, populations, rivals, and peers.
- Keeps serialization, migration snapshots, and debug export close to the data they persist, replay, and compare.
- Integrates focused owners for profile, counter, attribute, quest, level, formula, reward, population, and sync logic.
- Leaves domain rules in sibling files and keeps only the shared seams those owners depend on together.
- Avoids renderer, network, audio, and Lua conversion concerns so progression state stays fully headless.
- Provides mutation plumbing that Rust tests, Lua bindings, changesets, and evidence artifacts rely on.
- Retains store-wide helpers for ids, bounds, formulas, deterministic sampling, and population setup.
- Status helpers keep copied tags, pause state, filtering, timers, and ordered removals inside tracker ownership.
- Open this file when a change touches shared tables, snapshots, transactions, or multi-slice coordination.

### types.rs

- Owns the serializable data contracts, enums, and durable state shapes used by the progression store.
- Stores authored definitions, retained runtime snapshots, and helper structs shared across progression subsystems.
- Exposes the canonical types that Rust tests, persistence code, and Lua bindings serialize or inspect directly.
- Keeps durable field layout separate from mutation logic so snapshots can evolve without hiding in store methods.
- Defines profile, quest, leaderboard, population, challenge, season, and reward state in one reusable contract set.
- Anchors deterministic serde behavior for snapshots, changesets, and debug payloads that cross module boundaries.
- Integrates with `store.rs` as the state schema owner while sibling files focus on behavior and mutation rules.
- Avoids renderer, filesystem, and Lua-specific adapters so these types stay transport-neutral and domain-focused.
- Status snapshots retain copied tags and pause state while serde defaults accept snapshots authored before them.
- Open this file when adding stored fields, authored definition shapes, or snapshot-visible progression contracts.
- Reach here before changing persistence, docs generation, or Lua serialization that depends on stable type layout.



## Lua API Ref

### Functions

- `lurek.progression.acquirePerk(this, name) -> nil`: Acquire perk.
- `lurek.progression.activeCount(this) -> nil`: Active count.
- `lurek.progression.activeIds(this) -> nil`: Active ids.
- `lurek.progression.addBuff() -> nil`: Adds buff.
- `lurek.progression.addJournalEntry(this, quest_id, text, tag?) -> nil`: Adds journal entry.
- `lurek.progression.addQuest(this, quest) -> nil`: Adds quest.
- `lurek.progression.addXP(this, amount) -> nil`: Adds xp.
- `lurek.progression.adjustMorale(this, delta) -> nil`: Adjust morale.
- `lurek.progression.advanceObjective() -> nil`: Advance objective.
- `lurek.progression.applyDamage(this, stat, amount, dtype?) -> nil`: Apply damage.
- `lurek.progression.applyTraitBuffs(this, trait_name) -> nil`: Apply trait buffs.
- `lurek.progression.beginTurn(this) -> nil`: Begin turn.
- `lurek.progression.checkMorale(this) -> nil`: Check morale.
- `lurek.progression.clearBuffs(this, stat?) -> nil`: Clears buffs.
- `lurek.progression.clearFlag(this, name) -> nil`: Clears flag.
- `lurek.progression.completeQuest(this, id) -> nil`: Complete quest.
- `lurek.progression.completedCount(this) -> nil`: Completed count.
- `lurek.progression.completedIds(this) -> nil`: Completed ids.
- `lurek.progression.createLegacyQuestAdapter(store, profile, options?) -> nil`: Create legacy quest adapter.
- `lurek.progression.createLegacyStatsAdapter(store, profile, options?) -> nil`: Create legacy stats adapter.
- `lurek.progression.define(this, name, base, opts?) -> nil`: Define.
- `lurek.progression.definePerk(this, name, opts?) -> nil`: Define perk.
- `lurek.progression.defineSkill(this, name, opts?) -> nil`: Define skill.
- `lurek.progression.failQuest(this, id) -> nil`: Fail quest.
- `lurek.progression.failedIds(this) -> nil`: Failed ids.
- `lurek.progression.get(this, name) -> nil`: Returns a value.
- `lurek.progression.getActionPoints(this) -> number, number`: Returns the action points.
- `lurek.progression.getActiveTraits(this) -> nil`: Returns the active traits.
- `lurek.progression.getBase(this, name) -> nil`: Returns the base.
- `lurek.progression.getBuffCount(this, stat?) -> nil`: Returns the buff count.
- `lurek.progression.getBuffs(this, stat?) -> nil`: Returns the buffs.
- `lurek.progression.getCooldownRemaining(this, name) -> nil`: Returns the cooldown remaining.
- `lurek.progression.getEncumbrance(this) -> nil`: Returns the encumbrance.
- `lurek.progression.getFlags(this) -> nil`: Returns the flags.
- `lurek.progression.getInitiative(this) -> nil`: Returns the initiative.
- `lurek.progression.getLevel(this) -> nil`: Returns the level.
- `lurek.progression.getMax(this, name) -> nil`: Returns the max.
- `lurek.progression.getMin(this, name) -> nil`: Returns the min.
- `lurek.progression.getMorale(this) -> number, number`: Returns the morale.
- `lurek.progression.getQuest(this, id) -> nil`: Returns the quest.
- `lurek.progression.getQuestReward(this, id) -> nil`: Returns the quest reward.
- `lurek.progression.getRegen(this, name) -> nil`: Returns the regen.
- `lurek.progression.getResistance(this, dtype) -> nil`: Returns the resistance.
- `lurek.progression.getSkillLevel(this, name) -> nil`: Returns the skill level.
- `lurek.progression.getStatNames(this) -> nil`: Returns the stat names.
- `lurek.progression.getUseCount(this, name) -> nil`: Returns the use count.
- `lurek.progression.getXP(this) -> nil`: Returns the xp.
- `lurek.progression.hasFlag(this, name) -> nil`: Returns true if flag.
- `lurek.progression.hasPerk(this, name) -> nil`: Returns true if perk.
- `lurek.progression.hasTrait(this, trait_name) -> nil`: Returns true if trait.
- `lurek.progression.importLegacyQuestSnapshot(snapshot) -> nil`: Import legacy quest snapshot.
- `lurek.progression.importLegacyStatsSnapshot(snapshot) -> nil`: Import legacy stats snapshot.
- `lurek.progression.isEncumbered(this) -> nil`: Returns true if encumbered.
- `lurek.progression.learnSkill(this, name) -> nil`: Learn skill.
- `lurek.progression.loadStore(snapshot) -> nil`: Load store.
- `lurek.progression.newStatusTracker() -> LStatusTracker`: Creates an isolated deterministic status lifecycle tracker.
- `lurek.progression.newStore(options?) -> nil`: New store.
- `lurek.progression.questCount(this) -> nil`: Quest count.
- `lurek.progression.questIds(this) -> nil`: Quest ids.
- `lurek.progression.questsWithStatus(this, wanted) -> nil`: Quests with status.
- `lurek.progression.recordUse(this, name) -> nil`: Record use.
- `lurek.progression.recoverActionPoints(this, amount) -> nil`: Recover action points.
- `lurek.progression.removeBuff(this, handle) -> nil`: Removes buff.
- `lurek.progression.removeQuest(this, id) -> nil`: Removes quest.
- `lurek.progression.removeTraitBuffs(this, trait_name) -> nil`: Removes trait buffs.
- `lurek.progression.resetQuest(this, id) -> nil`: Clears quest.
- `lurek.progression.restore(this, snap) -> nil`: Restore.
- `lurek.progression.setActionPoints(this, max_val) -> nil`: Sets the action points.
- `lurek.progression.setBase(this, name, value) -> nil`: Sets the base.
- `lurek.progression.setBerserkThreshold(this, value) -> nil`: Sets the berserk threshold.
- `lurek.progression.setEncumbrance(this, cur, max_val) -> nil`: Sets the encumbrance.
- `lurek.progression.setFlag(this, name) -> nil`: Sets the flag.
- `lurek.progression.setInitiative(this, value) -> nil`: Sets the initiative.
- `lurek.progression.setLevel(this, value) -> nil`: Sets the level.
- `lurek.progression.setLevelThresholds(this, thresholds) -> nil`: Sets the level thresholds.
- `lurek.progression.setMax(this, name, value) -> nil`: Sets the max.
- `lurek.progression.setMin(this, name, value) -> nil`: Sets the min.
- `lurek.progression.setMorale(this, max_val) -> nil`: Sets the morale.
- `lurek.progression.setPanicThreshold(this, value) -> nil`: Sets the panic threshold.
- `lurek.progression.setQuestReward(this, id, reward) -> nil`: Sets the quest reward.
- `lurek.progression.setRegen(this, name, value) -> nil`: Sets the regen.
- `lurek.progression.setResistance(this, dtype, value) -> nil`: Sets the resistance.
- `lurek.progression.setXP(this, value) -> nil`: Sets the xp.
- `lurek.progression.snapshot(this) -> nil`: Snapshot.
- `lurek.progression.spendActionPoints(this, amount) -> nil`: Spend action points.
- `lurek.progression.startQuest(this, id) -> nil`: Start quest.
- `lurek.progression.type() -> nil`: Type.
- `lurek.progression.type() -> nil`: Type.
- `lurek.progression.typeOf(name) -> nil`: Type of.
- `lurek.progression.typeOf(name) -> nil`: Type of.
- `lurek.progression.update(this, dt) -> nil`: Update.
- `lurek.progression.useSkill(this, name) -> boolean, string?`: Use skill.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAchievement Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LAchievement:getId() -> string`: Returns the authored achievement id.
- `LAchievement:getTitle() -> string`: Returns the authored achievement title.
- `LAchievement:isUnlocked() -> boolean`: Returns whether the achievement is currently unlocked for the owning profile.

#### LActivityFeed Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LActivityFeed:count() -> integer`: Returns the number of retained activity-feed entries in this selection.
- `LActivityFeed:listEntries() -> table`: Returns every retained activity-feed entry as typed userdata.

#### LActivityFeedEntry Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LActivityFeedEntry:getEventType() -> string`: Returns the canonical activity event type name.
- `LActivityFeedEntry:getSequence() -> integer`: Returns the retained event sequence number.

#### LChallenge Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LChallenge:getId() -> string`: Returns the authored challenge id.
- `LChallenge:getStatus() -> string`: Returns the current challenge lifecycle status.

#### LCollection Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LCollection:getId() -> string`: Returns the authored collection id.
- `LCollection:isComplete() -> boolean`: Returns whether every collection item is currently collected.

#### LLeaderboardEntry Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LLeaderboardEntry:getLeaderboardId() -> string`: Returns the leaderboard that produced this row.
- `LLeaderboardEntry:getProfileId() -> string`: Returns the profile that owns this row.
- `LLeaderboardEntry:getRank() -> integer`: Returns the one-based rank currently assigned to this row.

#### LPopulation Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LPopulation:getId() -> string`: Returns the population id.
- `LPopulation:isPaused() -> boolean`: Returns whether logical simulation for this population is paused.

#### LPopulationProfile Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LPopulationProfile:getProfileId() -> string`: Returns the virtual profile id.
- `LPopulationProfile:isMaterialized() -> boolean`: Returns whether this virtual profile is materialized as a normal store profile.

#### LPrestige Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LPrestige:getId() -> string`: Returns the authored prestige id.
- `LPrestige:isAvailable() -> boolean`: Returns whether the owning profile currently satisfies the prestige condition.

#### LProgressionProfile Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LProgressionProfile:getId() -> nil`: Returns the id.
- `LProgressionProfile:getPendingRewards() -> table`: Returns this profile's pending reward records as typed reward handles.
- `LProgressionProfile:type() -> nil`: Type.
- `LProgressionProfile:typeOf(name) -> nil`: Type of.

#### LProgressionStore Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LProgressionStore:acceptQuest(profile, quest_id) -> nil`: Returns the pending rewards.
- `LProgressionStore:ackChangesThrough(revision) -> nil`: Ack changes through.
- `LProgressionStore:acquirePerk(profile, perk_id) -> nil`: Lua-visible method.
- `LProgressionStore:activateChallenge(profile, challenge_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:addAttributeBase(profile, attribute_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:addCounter(profile, counter_id, amount?) -> nil`: Lua-visible method.
- `LProgressionStore:addExperience(profile, track_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:addModifier(profile, target_id, opts) -> nil`: Lua-visible method.
- `LProgressionStore:addProfileTag(id, tag) -> nil`: Adds profile tag.
- `LProgressionStore:addResource(profile, resource_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:advanceTime(seconds) -> nil`: Advance time.
- `LProgressionStore:applyChangeset(changeset) -> nil`: Apply changeset.
- `LProgressionStore:applyChangesetEnvelope(changeset, options?) -> nil`: Lua-visible method.
- `LProgressionStore:applyPrestige(profile, prestige_id) -> nil`: Lua-visible method.
- `LProgressionStore:applyProfileTemplate(profile, template_id) -> nil`: Lua-visible method.
- `LProgressionStore:applyTrait(profile, trait_id) -> nil`: Lua-visible method.
- `LProgressionStore:beginTransaction(options?) -> nil`: Lua-visible method.
- `LProgressionStore:canPrestige(profile, prestige_id) -> nil`: Lua-visible method.
- `LProgressionStore:canSpendResource(profile, resource_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:clear() -> nil`: Clears the state.
- `LProgressionStore:clearEvents() -> nil`: Clears events.
- `LProgressionStore:collectCollectionItem(profile, collection_id, item_id) -> nil`: Lua-visible method.
- `LProgressionStore:compactChanges(max_records) -> nil`: Compact changes.
- `LProgressionStore:compileCondition(condition) -> nil`: Compile condition.
- `LProgressionStore:completeQuest(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:countProfiles(arg?) -> nil`: Returns the number of items.
- `LProgressionStore:createProfile(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:debugSnapshot() -> nil`: Debug snapshot.
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
- `LProgressionStore:drainEvents() -> nil`: Drain events.
- `LProgressionStore:endSeason(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:ensureProfile(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:evaluateCondition(profile, condition) -> nil`: Lua-visible method.
- `LProgressionStore:explainAttribute(profile, attribute_id) -> nil`: Lua-visible method.
- `LProgressionStore:explainCondition(profile, condition) -> nil`: Lua-visible method.
- `LProgressionStore:explainDerivedValue(profile, id) -> nil`: Lua-visible method.
- `LProgressionStore:exportChangesSince(revision) -> nil`: Export changes since.
- `LProgressionStore:exportChangeset(revision, options?) -> nil`: Lua-visible method.
- `LProgressionStore:exportSnapshot() -> nil`: Export snapshot.
- `LProgressionStore:failQuest(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:generatePopulation(template_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:getAchievement(profile, achievement_id) -> nil`: Lua-visible method.
- `LProgressionStore:getActivityFeed(query?) -> nil`: Returns one typed activity-feed selection object.
- `LProgressionStore:getAttribute(profile, attribute_id, mode?) -> nil`: Lua-visible method.
- `LProgressionStore:getAttributeState(profile, attribute_id) -> nil`: Lua-visible method.
- `LProgressionStore:getChallenge(profile, challenge_id) -> nil`: Lua-visible method.
- `LProgressionStore:getCollection(profile, collection_id) -> nil`: Lua-visible method.
- `LProgressionStore:getCounter(profile, counter_id) -> nil`: Lua-visible method.
- `LProgressionStore:getCounterState(profile, counter_id) -> nil`: Lua-visible method.
- `LProgressionStore:getDefinitionHash() -> nil`: Returns the definition hash.
- `LProgressionStore:getDerivedValue(profile, id) -> nil`: Lua-visible method.
- `LProgressionStore:getExperience(profile, track_id) -> nil`: Lua-visible method.
- `LProgressionStore:getExperienceToNextLevel(profile, track_id) -> nil`: Lua-visible method.
- `LProgressionStore:getId() -> nil`: Returns the id.
- `LProgressionStore:getLeaderboardEntry(profile, leaderboard_id) -> nil`: Lua-visible method.
- `LProgressionStore:getLevel(profile, track_id) -> nil`: Lua-visible method.
- `LProgressionStore:getPopulation(handle_or_id) -> nil`: Returns the population.
- `LProgressionStore:getPopulationStatistics(handle_or_id, query?) -> nil`: Lua-visible method.
- `LProgressionStore:getPrestige(profile, prestige_id) -> nil`: Lua-visible method.
- `LProgressionStore:getProfile(id) -> nil`: Returns the profile.
- `LProgressionStore:getQuestState(profile, quest_id) -> nil`: Lua-visible method.
- `LProgressionStore:getResource(profile, resource_id) -> nil`: Lua-visible method.
- `LProgressionStore:getRevision() -> nil`: Returns the revision.
- `LProgressionStore:getRival(profile, rival_profile) -> nil`: Lua-visible method.
- `LProgressionStore:getRivalDelta(profile, rival_profile) -> nil`: Lua-visible method.
- `LProgressionStore:getSchemaVersion() -> nil`: Returns the schema version.
- `LProgressionStore:getSeason(id) -> nil`: Returns the season.
- `LProgressionStore:getSeasonArchive(id, query?) -> nil`: Lua-visible method.
- `LProgressionStore:getSkillCooldown(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:getSkillLevel(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:getTime() -> nil`: Returns the time.
- `LProgressionStore:hasPerk(profile, perk_id) -> nil`: Lua-visible method.
- `LProgressionStore:hasProfile(id) -> nil`: Returns true if profile.
- `LProgressionStore:hasTrait(profile, trait_id) -> nil`: Lua-visible method.
- `LProgressionStore:learnSkill(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:listAchievements(profile) -> nil`: List achievements.
- `LProgressionStore:listChallenges(profile, options?) -> nil`: Lua-visible method.
- `LProgressionStore:listCollections(profile) -> nil`: List collections.
- `LProgressionStore:listCounters(profile) -> nil`: List counters.
- `LProgressionStore:listLeaderboardAroundProfile() -> nil`: Lua-visible method.
- `LProgressionStore:listLeaderboardRange(leaderboard_id, start_rank, limit?) -> nil`: Lua-visible method.
- `LProgressionStore:listLeaderboardTop(leaderboard_id, limit?) -> nil`: Lua-visible method.
- `LProgressionStore:listModifiers(profile) -> nil`: List modifiers.
- `LProgressionStore:listPopulationProfiles(handle_or_id, query?) -> nil`: Lua-visible method.
- `LProgressionStore:listPrestiges(profile) -> nil`: List prestiges.
- `LProgressionStore:listProfiles(arg?) -> nil`: List profiles.
- `LProgressionStore:listRivals(profile) -> nil`: List rivals.
- `LProgressionStore:listSeasons(query?) -> nil`: List seasons.
- `LProgressionStore:listTraits(profile) -> nil`: List traits.
- `LProgressionStore:loadSnapshot(snapshot) -> nil`: Load snapshot.
- `LProgressionStore:materializePopulationProfile(profile_id) -> nil`: Lua-visible method.
- `LProgressionStore:pausePopulation(handle_or_id) -> nil`: Pause population.
- `LProgressionStore:pinRival(profile, rival_profile, options?) -> nil`: Lua-visible method.
- `LProgressionStore:refillResource(profile, resource_id, amount?) -> nil`: Lua-visible method.
- `LProgressionStore:refreshQuestLifecycle(profile) -> nil`: Refresh quest lifecycle.
- `LProgressionStore:regeneratePopulation(handle_or_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:removeDerivedValue(id) -> nil`: Removes derived value.
- `LProgressionStore:removeModifier(profile, handle) -> nil`: Lua-visible method.
- `LProgressionStore:removePopulation(handle_or_id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:removeProfile(id, opts?) -> nil`: Lua-visible method.
- `LProgressionStore:removeProfileMetadata(id, key) -> nil`: Lua-visible method.
- `LProgressionStore:removeProfileTag(id, tag) -> nil`: Lua-visible method.
- `LProgressionStore:removeTrait(profile, trait_id) -> nil`: Lua-visible method.
- `LProgressionStore:resumePopulation(handle_or_id) -> nil`: Resume population.
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
- `LProgressionStore:setTime(seconds) -> nil`: Sets the time.
- `LProgressionStore:simulatePopulationUntil(handle_or_id, logical_time, options?) -> nil`: Lua-visible method.
- `LProgressionStore:spendResource(profile, resource_id, amount) -> nil`: Lua-visible method.
- `LProgressionStore:startSeason(id, options?) -> nil`: Lua-visible method.
- `LProgressionStore:stats() -> nil`: Stats.
- `LProgressionStore:submitScore(profile, leaderboard_id, score) -> nil`: Lua-visible method.
- `LProgressionStore:type() -> nil`: Type.
- `LProgressionStore:typeOf(name) -> nil`: Type of.
- `LProgressionStore:unlockAchievement(profile, achievement_id) -> nil`: Lua-visible method.
- `LProgressionStore:update(dt, opts?) -> nil`: Lua-visible method.
- `LProgressionStore:updatePopulation(handle_or_id, dt, options?) -> nil`: Lua-visible method.
- `LProgressionStore:updateProfile(id, patch?) -> nil`: Lua-visible method.
- `LProgressionStore:useSkill(profile, skill_id) -> nil`: Lua-visible method.
- `LProgressionStore:validate() -> nil`: Validate.
- `LProgressionStore:validateCondition(condition) -> nil`: Validate condition.
- `LProgressionStore:validateDerivedValues() -> nil`: Validate derived values.
- `LProgressionStore:validatePopulationTemplate(id) -> nil`: Validate population template.

#### LProgressionTransaction Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LProgressionTransaction:addCounter(profile, counter_id, amount) -> nil`: Lua-visible method.
- `LProgressionTransaction:addExperience(profile, track_id, amount) -> nil`: Lua-visible method.
- `LProgressionTransaction:addModifier(profile, target_id, opts) -> nil`: Lua-visible method.
- `LProgressionTransaction:commit() -> nil`: Commit.
- `LProgressionTransaction:rollback() -> nil`: Rollback.
- `LProgressionTransaction:setAttributeBase(profile, attribute_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:setCounter(profile, counter_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:setQuestObjective(profile, quest_id, objective_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:setResource(profile, resource_id, value) -> nil`: Lua-visible method.
- `LProgressionTransaction:type() -> nil`: Type.
- `LProgressionTransaction:typeOf(name) -> nil`: Type of.

#### LQuestJournal Type

- Lua-side quest journal wrapper that owns retained entries and optional live mutation context.

##### Fields

- No documented fields.

##### Methods

- `LQuestJournal:addEntry(text, tag?) -> LQuestJournalEntry`: Appends one entry to the live quest journal and returns the stored entry object.
- `LQuestJournal:count() -> integer`: Returns the number of retained entries currently stored in this journal.
- `LQuestJournal:getQuestId() -> string`: Returns the quest id that owns this journal.
- `LQuestJournal:listEntries() -> table`: Returns every retained journal entry as typed entry userdata.

#### LQuestJournalEntry Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LQuestJournalEntry:getIndex() -> integer`: Returns the stable monotonically increasing journal index.
- `LQuestJournalEntry:getTag() -> string`: Returns the optional journal entry tag.
- `LQuestJournalEntry:getText() -> string`: Returns the authored journal entry text.

#### LQuestState Type

- Lua-side immutable progression quest state wrapper with optional live store context.

##### Fields

- No documented fields.

##### Methods

- `LQuestState:getJournal() -> LQuestJournal`: Returns the retained quest journal as a typed journal object.
- `LQuestState:getQuestId() -> string`: Returns the authored quest id.
- `LQuestState:getStatus() -> string`: Returns the current quest lifecycle status.
- `LQuestState:isRevealed() -> boolean`: Returns whether the quest is currently revealed to the owning profile.

#### LReward Type

- Lua-side immutable reward wrapper with optional live store context for state transitions.

##### Fields

- No documented fields.

##### Methods

- `LReward:claim() -> LReward`: Claims this pending reward and returns the updated reward object.
- `LReward:getId() -> string`: Returns the reward record id.
- `LReward:getState() -> string`: Returns the current reward state.
- `LReward:markApplied(external_receipt?) -> LReward`: Marks this claimed reward as applied and returns the updated reward object.
- `LReward:reject(reason?) -> LReward`: Rejects this reward and returns the updated reward object.

#### LRival Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LRival:getProfileId() -> string`: Returns the owner profile id for this rivalry.
- `LRival:getRivalProfileId() -> string`: Returns the pinned rival profile id.

#### LRivalDelta Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LRivalDelta:getLeaderboardId() -> string`: Returns the leaderboard used to compute this rivalry delta.
- `LRivalDelta:getRankDelta() -> integer`: Returns the signed rank gap between the owner and rival profiles.

#### LSeason Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LSeason:getId() -> string`: Returns the authored season id.
- `LSeason:isActive() -> boolean`: Returns whether this season is currently active.

#### LSeasonArchive Type

- Lua-visible object type.

##### Fields

- No documented fields.

##### Methods

- `LSeasonArchive:getArchiveIndex() -> integer`: Returns the monotonically increasing archive index for this season.
- `LSeasonArchive:getId() -> string`: Returns the season id that owns this archive record.

#### LStatusTracker Type

- Creates an isolated deterministic status lifecycle tracker.

##### Fields

- No documented fields.

##### Methods

- `LStatusTracker:apply(subjectId, definitionId, sourceId?, stacks?) -> integer`: Applies a status to a subject and returns its stable runtime instance id.
- `LStatusTracker:clear() -> nil`: Removes all definitions, instances, and queued events.
- `LStatusTracker:define(definition) -> nil`: Registers or replaces one status definition.
- `LStatusTracker:drainEvents() -> table`: Takes and clears neutral apply/refresh/stack/tick/expired events.
- `LStatusTracker:get(instanceId) -> table?`: Returns one active status instance by runtime id.
- `LStatusTracker:has(subjectId, definitionOrTag) -> boolean`: Checks whether a subject has a status with the requested definition id or tag.
- `LStatusTracker:list(subjectId, filter?) -> table`: Lists active status instances attached to one subject and matching all optional filters.
- `LStatusTracker:remove(instanceId) -> boolean`: Removes one active status instance.
- `LStatusTracker:removeByDefinition(subjectId, definitionId) -> integer`: Removes every matching definition instance from one subject.
- `LStatusTracker:removeByTag(subjectId, tag) -> integer`: Removes every instance carrying a copied tag from one subject.
- `LStatusTracker:restore(snapshot) -> nil`: Restores definitions, active instances, and ID allocation from a snapshot.
- `LStatusTracker:setPaused(instanceId, paused) -> boolean`: Pauses or resumes one status instance's lifecycle timers.
- `LStatusTracker:setRemaining(instanceId, seconds?) -> boolean`: Sets one status instance's remaining duration; nil makes it infinite.
- `LStatusTracker:snapshot() -> table`: Captures definitions, instances, and ID allocation state.
- `LStatusTracker:type() -> string`: Returns the Lua-visible type name.
- `LStatusTracker:typeOf(name) -> boolean`: Checks whether this handle matches `LStatusTracker` or `LObject`.
- `LStatusTracker:update(dt) -> integer`: Advances finite durations and periodic tick timers by dt seconds.

## Examples

- `content/examples/progression.lua` (present)

## Architecture Links

- No module-specific architecture links registered.

## Notes

- Use `clock = "manual"` for deterministic tests and offline simulation.
- Store and transaction APIs are designed so later roadmap phases can extend the module without changing the top-level ownership model.
- New gameplay code should use `lurek.progression` directly; the legacy adapter surface is now provided by that engine module instead of separate Lua libraries.
