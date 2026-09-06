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

- `lurek.progression.acquirePerk(this, name) -> boolean`: Performs the `acquirePerk` progression operation for Lua callers.
- `lurek.progression.activeCount(this) -> integer`: Performs the `activeCount` progression operation for Lua callers.
- `lurek.progression.activeIds(this) -> nil`: Performs the `activeIds` progression operation for Lua callers.
- `lurek.progression.addBuff() -> string`: Adds buff to the progression store for Lua callers.
- `lurek.progression.addJournalEntry(this, quest_id, text, tag?) -> integer`: Adds journal entry to the progression store for Lua callers.
- `lurek.progression.addQuest(this, quest) -> nil`: Adds quest to the progression store for Lua callers.
- `lurek.progression.addXP(this, amount) -> nil`: Adds x p to the progression store for Lua callers.
- `lurek.progression.adjustMorale(this, delta) -> nil`: Performs the `adjustMorale` progression operation for Lua callers.
- `lurek.progression.advanceObjective() -> boolean`: Performs the `advanceObjective` progression operation for Lua callers.
- `lurek.progression.applyDamage(this, stat, amount, dtype?) -> number`: Applies damage in the progression store for Lua callers.
- `lurek.progression.applyTraitBuffs(this, trait_name) -> nil`: Applies trait buffs in the progression store for Lua callers.
- `lurek.progression.beginTurn(this) -> nil`: Begins turn in the progression store for Lua callers.
- `lurek.progression.checkMorale(this) -> string`: Performs the `checkMorale` progression operation for Lua callers.
- `lurek.progression.clearBuffs(this, stat?) -> nil`: Clears buffs in the progression store for Lua callers.
- `lurek.progression.clearFlag(this, name) -> nil`: Clears flag in the progression store for Lua callers.
- `lurek.progression.completeQuest(this, id) -> boolean`: Performs the `completeQuest` progression operation for Lua callers.
- `lurek.progression.completedCount(this) -> integer`: Performs the `completedCount` progression operation for Lua callers.
- `lurek.progression.completedIds(this) -> nil`: Performs the `completedIds` progression operation for Lua callers.
- `lurek.progression.createLegacyQuestAdapter(store, profile, options?) -> nil`: Creates legacy quest adapter in the progression store for Lua callers.
- `lurek.progression.createLegacyStatsAdapter(store, profile, options?) -> nil`: Creates legacy stats adapter in the progression store for Lua callers.
- `lurek.progression.define(this, name, base, opts?) -> nil`: Defines this operation in the progression store for Lua callers.
- `lurek.progression.definePerk(this, name, opts?) -> nil`: Defines perk in the progression store for Lua callers.
- `lurek.progression.defineSkill(this, name, opts?) -> nil`: Defines skill in the progression store for Lua callers.
- `lurek.progression.failQuest(this, id) -> boolean`: Performs the `failQuest` progression operation for Lua callers.
- `lurek.progression.failedIds(this) -> nil`: Performs the `failedIds` progression operation for Lua callers.
- `lurek.progression.get(this, name) -> number`: Returns this operation from the progression store for Lua callers.
- `lurek.progression.getActionPoints(this) -> table | number, number | Current action points followed by the configured maximum`: Returns action points from the progression store for Lua callers.
- `lurek.progression.getActiveTraits(this) -> table`: Returns active traits from the progression store for Lua callers.
- `lurek.progression.getBase(this, name) -> number`: Returns base from the progression store for Lua callers.
- `lurek.progression.getBuffCount(this, stat?) -> integer`: Returns buff count from the progression store for Lua callers.
- `lurek.progression.getBuffs(this, stat?) -> table`: Returns buffs from the progression store for Lua callers.
- `lurek.progression.getCooldownRemaining(this, name) -> number`: Returns cooldown remaining from the progression store for Lua callers.
- `lurek.progression.getEncumbrance(this) -> table`: Returns encumbrance from the progression store for Lua callers.
- `lurek.progression.getFlags(this) -> table`: Returns flags from the progression store for Lua callers.
- `lurek.progression.getInitiative(this) -> table`: Returns initiative from the progression store for Lua callers.
- `lurek.progression.getLevel(this) -> integer`: Returns level from the progression store for Lua callers.
- `lurek.progression.getMax(this, name) -> table`: Returns max from the progression store for Lua callers.
- `lurek.progression.getMin(this, name) -> table`: Returns min from the progression store for Lua callers.
- `lurek.progression.getMorale(this) -> table | number, number | Current morale followed by the configured maximum`: Returns morale from the progression store for Lua callers.
- `lurek.progression.getQuest(this, id) -> table`: Returns quest from the progression store for Lua callers.
- `lurek.progression.getQuestReward(this, id) -> table`: Returns quest reward from the progression store for Lua callers.
- `lurek.progression.getRegen(this, name) -> table`: Returns regen from the progression store for Lua callers.
- `lurek.progression.getResistance(this, dtype) -> number`: Returns resistance from the progression store for Lua callers.
- `lurek.progression.getSkillLevel(this, name) -> integer`: Returns skill level from the progression store for Lua callers.
- `lurek.progression.getStatNames(this) -> table`: Returns stat names from the progression store for Lua callers.
- `lurek.progression.getUseCount(this, name) -> integer`: Returns use count from the progression store for Lua callers.
- `lurek.progression.getXP(this) -> number`: Returns x p from the progression store for Lua callers.
- `lurek.progression.hasFlag(this, name) -> boolean`: Checks whether flag exists in the progression store for Lua callers.
- `lurek.progression.hasPerk(this, name) -> boolean`: Checks whether perk exists in the progression store for Lua callers.
- `lurek.progression.hasTrait(this, trait_name) -> boolean`: Checks whether trait exists in the progression store for Lua callers.
- `lurek.progression.importLegacyQuestSnapshot(snapshot) -> nil`: Imports legacy quest snapshot into the progression store for Lua callers.
- `lurek.progression.importLegacyStatsSnapshot(snapshot) -> nil`: Imports legacy stats snapshot into the progression store for Lua callers.
- `lurek.progression.isEncumbered(this) -> boolean`: Checks whether encumbered is true for this progression object.
- `lurek.progression.learnSkill(this, name) -> boolean`: Performs the `learnSkill` progression operation for Lua callers.
- `lurek.progression.loadStore(snapshot) -> nil`: Performs the `loadStore` progression operation for Lua callers.
- `lurek.progression.newStatusTracker() -> | LStatusTracker | New status tracker handle`: Creates an isolated deterministic status lifecycle tracker.
- `lurek.progression.newStore(options?) -> nil`: Performs the `newStore` progression operation for Lua callers.
- `lurek.progression.questCount(this) -> integer`: Performs the `questCount` progression operation for Lua callers.
- `lurek.progression.questIds(this) -> table`: Performs the `questIds` progression operation for Lua callers.
- `lurek.progression.questsWithStatus(this, wanted) -> table`: Performs the `questsWithStatus` progression operation for Lua callers.
- `lurek.progression.recordUse(this, name) -> nil`: Performs the `recordUse` progression operation for Lua callers.
- `lurek.progression.recoverActionPoints(this, amount) -> nil`: Performs the `recoverActionPoints` progression operation for Lua callers.
- `lurek.progression.removeBuff(this, handle) -> boolean`: Removes buff from the progression store for Lua callers.
- `lurek.progression.removeQuest(this, id) -> boolean`: Removes quest from the progression store for Lua callers.
- `lurek.progression.removeTraitBuffs(this, trait_name) -> boolean`: Removes trait buffs from the progression store for Lua callers.
- `lurek.progression.resetQuest(this, id) -> boolean`: Performs the `resetQuest` progression operation for Lua callers.
- `lurek.progression.restore(this, snap) -> nil`: Performs the `restore` progression operation for Lua callers.
- `lurek.progression.setActionPoints(this, max_val) -> nil`: Sets action points in the progression store for Lua callers.
- `lurek.progression.setBase(this, name, value) -> boolean`: Sets base in the progression store for Lua callers.
- `lurek.progression.setBerserkThreshold(this, value) -> nil`: Sets berserk threshold in the progression store for Lua callers.
- `lurek.progression.setEncumbrance(this, cur, max_val) -> nil`: Sets encumbrance in the progression store for Lua callers.
- `lurek.progression.setFlag(this, name) -> nil`: Sets flag in the progression store for Lua callers.
- `lurek.progression.setInitiative(this, value) -> nil`: Sets initiative in the progression store for Lua callers.
- `lurek.progression.setLevel(this, value) -> nil`: Sets level in the progression store for Lua callers.
- `lurek.progression.setLevelThresholds(this, thresholds) -> nil`: Sets level thresholds in the progression store for Lua callers.
- `lurek.progression.setMax(this, name, value) -> nil`: Sets max in the progression store for Lua callers.
- `lurek.progression.setMin(this, name, value) -> nil`: Sets min in the progression store for Lua callers.
- `lurek.progression.setMorale(this, max_val) -> nil`: Sets morale in the progression store for Lua callers.
- `lurek.progression.setPanicThreshold(this, value) -> nil`: Sets panic threshold in the progression store for Lua callers.
- `lurek.progression.setQuestReward(this, id, reward) -> nil`: Sets quest reward in the progression store for Lua callers.
- `lurek.progression.setRegen(this, name, value) -> nil`: Sets regen in the progression store for Lua callers.
- `lurek.progression.setResistance(this, dtype, value) -> nil`: Sets resistance in the progression store for Lua callers.
- `lurek.progression.setXP(this, value) -> nil`: Sets x p in the progression store for Lua callers.
- `lurek.progression.snapshot(this) -> table`: Performs the `snapshot` progression operation for Lua callers.
- `lurek.progression.spendActionPoints(this, amount) -> boolean`: Performs the `spendActionPoints` progression operation for Lua callers.
- `lurek.progression.startQuest(this, id) -> boolean`: Performs the `startQuest` progression operation for Lua callers.
- `lurek.progression.type() -> string`: Returns the runtime type name exposed by this progression object to Lua callers.
- `lurek.progression.type() -> string`: Returns the runtime type name exposed by this progression object to Lua callers.
- `lurek.progression.typeOf(name) -> boolean`: Returns the runtime type name exposed by this progression object to Lua callers.
- `lurek.progression.typeOf(name) -> boolean`: Returns the runtime type name exposed by this progression object to Lua callers.
- `lurek.progression.update(this, dt) -> nil`: Updates this operation in the progression store for Lua callers.
- `lurek.progression.useSkill(this, name) -> nil | boolean, string? | Success flag followed by an optional failure reason`: Performs the `useSkill` progression operation for Lua callers.

### Callbacks

- No documented callback parameters in this module.

### Enums

- No documented module-level enums/constants.

### Types

#### LAchievement Type

- Lua-visible `Achievement` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LAchievement:getId() -> | string | Stable achievement identifier`: Returns the authored achievement id.
- `LAchievement:getTitle() -> | string | Local presentation title`: Returns the authored achievement title.
- `LAchievement:isUnlocked() -> | boolean | `true` when the achievement was unlocked`: Returns whether the achievement is currently unlocked for the owning profile.

#### LActivityFeed Type

- Lua-visible `ActivityFeed` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LActivityFeed:count() -> | integer | Number of feed entries currently stored in this feed snapshot`: Returns the number of retained activity-feed entries in this selection.
- `LActivityFeed:listEntries() -> | table | Array of `LActivityFeedEntry` userdata values`: Returns every retained activity-feed entry as typed userdata.

#### LActivityFeedEntry Type

- Lua-visible `ActivityFeedEntry` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LActivityFeedEntry:getEventType() -> | string | Event type such as `"achievement_unlocked"``: Returns the canonical activity event type name.
- `LActivityFeedEntry:getSequence() -> | integer | Event sequence in feed order`: Returns the retained event sequence number.

#### LChallenge Type

- Lua-visible `Challenge` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LChallenge:getId() -> | string | Stable challenge identifier`: Returns the authored challenge id.
- `LChallenge:getStatus() -> | string | One of `"inactive"`, `"active"`, `"completed"`, or `"expired"``: Returns the current challenge lifecycle status.

#### LCollection Type

- Lua-visible `Collection` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LCollection:getId() -> | string | Stable collection identifier`: Returns the authored collection id.
- `LCollection:isComplete() -> | boolean | `true` when the collection is complete`: Returns whether every collection item is currently collected.

#### LLeaderboardEntry Type

- Lua-visible `LeaderboardEntry` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LLeaderboardEntry:getLeaderboardId() -> | string | Leaderboard identifier`: Returns the leaderboard that produced this row.
- `LLeaderboardEntry:getProfileId() -> | string | Profile identifier`: Returns the profile that owns this row.
- `LLeaderboardEntry:getRank() -> | integer | Deterministic rank for the current ordering`: Returns the one-based rank currently assigned to this row.

#### LPopulation Type

- Lua-visible `Population` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LPopulation:getId() -> string | string | Population identifier`: Returns id from the progression store for Lua callers.
- `LPopulation:isPaused() -> | boolean | `true` when updates are paused`: Returns whether logical simulation for this population is paused.

#### LPopulationProfile Type

- Lua-visible `PopulationProfile` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LPopulationProfile:getProfileId() -> string | string | Virtual profile identifier`: Returns profile id from the progression store for Lua callers.
- `LPopulationProfile:isMaterialized() -> | boolean | `true` when the virtual profile was materialized`: Returns whether this virtual profile is materialized as a normal store profile.

#### LPrestige Type

- Lua-visible `Prestige` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LPrestige:getId() -> string | string | Prestige identifier`: Returns id from the progression store for Lua callers.
- `LPrestige:isAvailable() -> | boolean | `true` when the prestige is currently available`: Returns whether the owning profile currently satisfies the prestige condition.

#### LProgressionProfile Type

- Lua-visible `ProfileHandle` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LProgressionProfile:getId() -> string`: Returns id from the progression store for Lua callers.
- `LProgressionProfile:getPendingRewards() -> | table | Array of `LReward` values still waiting for claim`: Returns this profile's pending reward records as typed reward handles.
- `LProgressionProfile:type() -> string`: Returns the runtime type name exposed by this progression object to Lua callers.
- `LProgressionProfile:typeOf(name) -> boolean`: Returns the runtime type name exposed by this progression object to Lua callers.

#### LProgressionStore Type

- Lua-visible `ProgressionStore` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LProgressionStore:acceptQuest(profile, quest_id) -> boolean`: Performs the `acceptQuest` progression operation for Lua callers.
- `LProgressionStore:ackChangesThrough(revision) -> nil`: Performs the `ackChangesThrough` progression operation for Lua callers.
- `LProgressionStore:acquirePerk(profile, perk_id) -> nil`: Performs the `acquirePerk` progression operation for Lua callers.
- `LProgressionStore:activateChallenge(profile, challenge_id, options?) -> nil`: Performs the `activateChallenge` progression operation for Lua callers.
- `LProgressionStore:addAttributeBase(profile, attribute_id, amount) -> nil`: Adds attribute base to the progression store for Lua callers.
- `LProgressionStore:addCounter(profile, counter_id, amount?) -> nil`: Adds counter to the progression store for Lua callers.
- `LProgressionStore:addExperience(profile, track_id, amount) -> nil`: Adds experience to the progression store for Lua callers.
- `LProgressionStore:addModifier(profile, target_id, opts) -> nil`: Adds modifier to the progression store for Lua callers.
- `LProgressionStore:addProfileTag(id, tag) -> nil`: Adds profile tag to the progression store for Lua callers.
- `LProgressionStore:addResource(profile, resource_id, amount) -> nil`: Adds resource to the progression store for Lua callers.
- `LProgressionStore:advanceTime(seconds) -> nil`: Performs the `advanceTime` progression operation for Lua callers.
- `LProgressionStore:applyChangeset(changeset) -> nil`: Applies changeset in the progression store for Lua callers.
- `LProgressionStore:applyChangesetEnvelope(changeset, options?) -> nil`: Applies changeset envelope in the progression store for Lua callers.
- `LProgressionStore:applyPrestige(profile, prestige_id) -> nil`: Applies prestige in the progression store for Lua callers.
- `LProgressionStore:applyProfileTemplate(profile, template_id) -> nil`: Applies profile template in the progression store for Lua callers.
- `LProgressionStore:applyTrait(profile, trait_id) -> boolean`: Applies trait in the progression store for Lua callers.
- `LProgressionStore:beginTransaction(options?) -> nil`: Begins transaction in the progression store for Lua callers.
- `LProgressionStore:canPrestige(profile, prestige_id) -> boolean`: Checks whether Lua callers can prestige in the progression store.
- `LProgressionStore:canSpendResource(profile, resource_id, amount) -> boolean`: Checks whether Lua callers can spend resource in the progression store.
- `LProgressionStore:clear() -> nil`: Clears this operation in the progression store for Lua callers.
- `LProgressionStore:clearEvents() -> nil`: Clears events in the progression store for Lua callers.
- `LProgressionStore:collectCollectionItem(profile, collection_id, item_id) -> nil`: Performs the `collectCollectionItem` progression operation for Lua callers.
- `LProgressionStore:compactChanges(max_records) -> nil`: Performs the `compactChanges` progression operation for Lua callers.
- `LProgressionStore:compileCondition(condition) -> table`: Performs the `compileCondition` progression operation for Lua callers.
- `LProgressionStore:completeQuest(profile, quest_id) -> boolean`: Performs the `completeQuest` progression operation for Lua callers.
- `LProgressionStore:countProfiles(arg1?) -> number`: Performs the `countProfiles` progression operation for Lua callers.
- `LProgressionStore:createProfile(id, options?) -> nil`: Creates profile in the progression store for Lua callers.
- `LProgressionStore:debugSnapshot() -> table`: Performs the `debugSnapshot` progression operation for Lua callers.
- `LProgressionStore:defineAchievement(id, definition) -> nil`: Defines achievement in the progression store for Lua callers.
- `LProgressionStore:defineAttribute(id, definition) -> nil`: Defines attribute in the progression store for Lua callers.
- `LProgressionStore:defineChallengeTemplate(id, definition) -> nil`: Defines challenge template in the progression store for Lua callers.
- `LProgressionStore:defineCollection(id, definition) -> nil`: Defines collection in the progression store for Lua callers.
- `LProgressionStore:defineCounter(id, definition) -> nil`: Defines counter in the progression store for Lua callers.
- `LProgressionStore:defineDerivedValue(id, definition) -> nil`: Defines derived value in the progression store for Lua callers.
- `LProgressionStore:defineLeaderboard(id, definition) -> nil`: Defines leaderboard in the progression store for Lua callers.
- `LProgressionStore:defineLevelTrack(id, definition) -> nil`: Defines level track in the progression store for Lua callers.
- `LProgressionStore:definePerk(id, definition) -> nil`: Defines perk in the progression store for Lua callers.
- `LProgressionStore:definePopulationTemplate(id, definition) -> nil`: Defines population template in the progression store for Lua callers.
- `LProgressionStore:definePrestige(id, definition) -> nil`: Defines prestige in the progression store for Lua callers.
- `LProgressionStore:defineProfileTemplate(id, definition) -> nil`: Defines profile template in the progression store for Lua callers.
- `LProgressionStore:defineQuest(id, definition) -> nil`: Defines quest in the progression store for Lua callers.
- `LProgressionStore:defineResource(id, definition) -> nil`: Defines resource in the progression store for Lua callers.
- `LProgressionStore:defineSeason(id, definition) -> nil`: Defines season in the progression store for Lua callers.
- `LProgressionStore:defineSkill(id, definition) -> nil`: Defines skill in the progression store for Lua callers.
- `LProgressionStore:defineTrait(id, definition) -> nil`: Defines trait in the progression store for Lua callers.
- `LProgressionStore:dematerializePopulationProfile(profile_id, options?) -> nil`: Performs the `dematerializePopulationProfile` progression operation for Lua callers.
- `LProgressionStore:drainEvents() -> table`: Performs the `drainEvents` progression operation for Lua callers.
- `LProgressionStore:endSeason(id, options?) -> nil`: Performs the `endSeason` progression operation for Lua callers.
- `LProgressionStore:ensureProfile(id, options?) -> nil`: Performs the `ensureProfile` progression operation for Lua callers.
- `LProgressionStore:evaluateCondition(profile, condition) -> table`: Performs the `evaluateCondition` progression operation for Lua callers.
- `LProgressionStore:explainAttribute(profile, attribute_id) -> table`: Performs the `explainAttribute` progression operation for Lua callers.
- `LProgressionStore:explainCondition(profile, condition) -> table`: Performs the `explainCondition` progression operation for Lua callers.
- `LProgressionStore:explainDerivedValue(profile, id) -> table`: Performs the `explainDerivedValue` progression operation for Lua callers.
- `LProgressionStore:exportChangesSince(revision) -> table`: Exports changes since from the progression store for Lua callers.
- `LProgressionStore:exportChangeset(revision, options?) -> table`: Exports changeset from the progression store for Lua callers.
- `LProgressionStore:exportSnapshot() -> table`: Exports snapshot from the progression store for Lua callers.
- `LProgressionStore:failQuest(profile, quest_id) -> boolean`: Performs the `failQuest` progression operation for Lua callers.
- `LProgressionStore:generatePopulation(template_id, options?) -> nil`: Performs the `generatePopulation` progression operation for Lua callers.
- `LProgressionStore:getAchievement(profile, achievement_id) -> table`: Returns achievement from the progression store for Lua callers.
- `LProgressionStore:getActivityFeed(query?) -> table`: Returns one typed activity-feed selection object.
- `LProgressionStore:getAttribute(profile, attribute_id, mode?) -> table`: Returns attribute from the progression store for Lua callers.
- `LProgressionStore:getAttributeState(profile, attribute_id) -> table`: Returns attribute state from the progression store for Lua callers.
- `LProgressionStore:getChallenge(profile, challenge_id) -> table`: Returns challenge from the progression store for Lua callers.
- `LProgressionStore:getCollection(profile, collection_id) -> table`: Returns collection from the progression store for Lua callers.
- `LProgressionStore:getCounter(profile, counter_id) -> table`: Returns counter from the progression store for Lua callers.
- `LProgressionStore:getCounterState(profile, counter_id) -> table`: Returns counter state from the progression store for Lua callers.
- `LProgressionStore:getDefinitionHash() -> string`: Returns definition hash from the progression store for Lua callers.
- `LProgressionStore:getDerivedValue(profile, id) -> table`: Returns derived value from the progression store for Lua callers.
- `LProgressionStore:getExperience(profile, track_id) -> number`: Returns experience from the progression store for Lua callers.
- `LProgressionStore:getExperienceToNextLevel(profile, track_id) -> number`: Returns experience to next level from the progression store for Lua callers.
- `LProgressionStore:getId() -> string`: Returns id from the progression store for Lua callers.
- `LProgressionStore:getLeaderboardEntry(profile, leaderboard_id) -> table`: Returns leaderboard entry from the progression store for Lua callers.
- `LProgressionStore:getLevel(profile, track_id) -> number`: Returns level from the progression store for Lua callers.
- `LProgressionStore:getPopulation(handle_or_id) -> table`: Returns population from the progression store for Lua callers.
- `LProgressionStore:getPopulationStatistics(handle_or_id, query?) -> table`: Returns population statistics from the progression store for Lua callers.
- `LProgressionStore:getPrestige(profile, prestige_id) -> table`: Returns prestige from the progression store for Lua callers.
- `LProgressionStore:getProfile(id) -> table`: Returns profile from the progression store for Lua callers.
- `LProgressionStore:getQuestState(profile, quest_id) -> table`: Returns quest state from the progression store for Lua callers.
- `LProgressionStore:getResource(profile, resource_id) -> table`: Returns resource from the progression store for Lua callers.
- `LProgressionStore:getRevision() -> integer`: Returns revision from the progression store for Lua callers.
- `LProgressionStore:getRival(profile, rival_profile) -> table`: Returns rival from the progression store for Lua callers.
- `LProgressionStore:getRivalDelta(profile, rival_profile) -> table`: Returns rival delta from the progression store for Lua callers.
- `LProgressionStore:getSchemaVersion() -> integer`: Returns schema version from the progression store for Lua callers.
- `LProgressionStore:getSeason(id) -> table`: Returns season from the progression store for Lua callers.
- `LProgressionStore:getSeasonArchive(id, query?) -> table`: Returns season archive from the progression store for Lua callers.
- `LProgressionStore:getSkillCooldown(profile, skill_id) -> table`: Returns skill cooldown from the progression store for Lua callers.
- `LProgressionStore:getSkillLevel(profile, skill_id) -> table`: Returns skill level from the progression store for Lua callers.
- `LProgressionStore:getTime() -> number`: Returns time from the progression store for Lua callers.
- `LProgressionStore:hasPerk(profile, perk_id) -> boolean`: Checks whether perk exists in the progression store for Lua callers.
- `LProgressionStore:hasProfile(id) -> boolean`: Checks whether profile exists in the progression store for Lua callers.
- `LProgressionStore:hasTrait(profile, trait_id) -> boolean`: Checks whether trait exists in the progression store for Lua callers.
- `LProgressionStore:learnSkill(profile, skill_id) -> nil`: Performs the `learnSkill` progression operation for Lua callers.
- `LProgressionStore:listAchievements(profile) -> table`: Lists achievements from the progression store for Lua callers.
- `LProgressionStore:listChallenges(profile, options?) -> table`: Lists challenges from the progression store for Lua callers.
- `LProgressionStore:listCollections(profile) -> table`: Lists collections from the progression store for Lua callers.
- `LProgressionStore:listCounters(profile) -> table`: Lists counters from the progression store for Lua callers.
- `LProgressionStore:listLeaderboardAroundProfile() -> table`: Lists leaderboard around profile from the progression store for Lua callers.
- `LProgressionStore:listLeaderboardRange(leaderboard_id, start_rank, limit?) -> table`: Lists leaderboard range from the progression store for Lua callers.
- `LProgressionStore:listLeaderboardTop(leaderboard_id, limit?) -> table`: Lists leaderboard top from the progression store for Lua callers.
- `LProgressionStore:listModifiers(profile) -> table`: Lists modifiers from the progression store for Lua callers.
- `LProgressionStore:listPopulationProfiles(handle_or_id, query?) -> table`: Lists population profiles from the progression store for Lua callers.
- `LProgressionStore:listPrestiges(profile) -> table`: Lists prestiges from the progression store for Lua callers.
- `LProgressionStore:listProfiles(arg1?) -> table`: Lists profiles from the progression store for Lua callers.
- `LProgressionStore:listRivals(profile) -> table`: Lists rivals from the progression store for Lua callers.
- `LProgressionStore:listSeasons(query?) -> table`: Lists seasons from the progression store for Lua callers.
- `LProgressionStore:listTraits(profile) -> table`: Lists traits from the progression store for Lua callers.
- `LProgressionStore:loadSnapshot(snapshot) -> nil`: Performs the `loadSnapshot` progression operation for Lua callers.
- `LProgressionStore:materializePopulationProfile(profile_id) -> nil`: Performs the `materializePopulationProfile` progression operation for Lua callers.
- `LProgressionStore:pausePopulation(handle_or_id) -> nil`: Performs the `pausePopulation` progression operation for Lua callers.
- `LProgressionStore:pinRival(profile, rival_profile, options?) -> nil`: Performs the `pinRival` progression operation for Lua callers.
- `LProgressionStore:refillResource(profile, resource_id, amount?) -> nil`: Performs the `refillResource` progression operation for Lua callers.
- `LProgressionStore:refreshQuestLifecycle(profile) -> nil`: Performs the `refreshQuestLifecycle` progression operation for Lua callers.
- `LProgressionStore:regeneratePopulation(handle_or_id, options?) -> nil`: Performs the `regeneratePopulation` progression operation for Lua callers.
- `LProgressionStore:removeDerivedValue(id) -> boolean`: Removes derived value from the progression store for Lua callers.
- `LProgressionStore:removeModifier(profile, handle) -> nil`: Removes modifier from the progression store for Lua callers.
- `LProgressionStore:removePopulation(handle_or_id, options?) -> nil`: Removes population from the progression store for Lua callers.
- `LProgressionStore:removeProfile(id, opts?) -> nil`: Removes profile from the progression store for Lua callers.
- `LProgressionStore:removeProfileMetadata(id, key) -> nil`: Removes profile metadata from the progression store for Lua callers.
- `LProgressionStore:removeProfileTag(id, tag) -> nil`: Removes profile tag from the progression store for Lua callers.
- `LProgressionStore:removeTrait(profile, trait_id) -> boolean`: Removes trait from the progression store for Lua callers.
- `LProgressionStore:resumePopulation(handle_or_id) -> nil`: Performs the `resumePopulation` progression operation for Lua callers.
- `LProgressionStore:revealQuest(profile, quest_id) -> nil`: Performs the `revealQuest` progression operation for Lua callers.
- `LProgressionStore:setAttributeBase(profile, attribute_id, value) -> nil`: Sets attribute base in the progression store for Lua callers.
- `LProgressionStore:setChallengeProgress(profile, challenge_id, value) -> nil`: Sets challenge progress in the progression store for Lua callers.
- `LProgressionStore:setCounter(profile, counter_id, value) -> nil`: Sets counter in the progression store for Lua callers.
- `LProgressionStore:setExperience(profile, track_id, value) -> nil`: Sets experience in the progression store for Lua callers.
- `LProgressionStore:setLevel(profile, track_id, level) -> nil`: Sets level in the progression store for Lua callers.
- `LProgressionStore:setProfileMetadata(id, key, value) -> nil`: Sets profile metadata in the progression store for Lua callers.
- `LProgressionStore:setQuestObjective(profile, quest_id, objective_id, value) -> nil`: Sets quest objective in the progression store for Lua callers.
- `LProgressionStore:setQuestObjectiveStatus(profile, quest_id, objective_id, status) -> nil`: Sets quest objective status in the progression store for Lua callers.
- `LProgressionStore:setQuestObjectiveVisibility(profile, quest_id, objective_id, visible) -> nil`: Sets quest objective visibility in the progression store for Lua callers.
- `LProgressionStore:setResource(profile, resource_id, value) -> nil`: Sets resource in the progression store for Lua callers.
- `LProgressionStore:setTime(seconds) -> nil`: Sets time in the progression store for Lua callers.
- `LProgressionStore:simulatePopulationUntil(handle_or_id, logical_time, options?) -> nil`: Performs the `simulatePopulationUntil` progression operation for Lua callers.
- `LProgressionStore:spendResource(profile, resource_id, amount) -> nil`: Performs the `spendResource` progression operation for Lua callers.
- `LProgressionStore:startSeason(id, options?) -> nil`: Performs the `startSeason` progression operation for Lua callers.
- `LProgressionStore:stats() -> table`: Performs the `stats` progression operation for Lua callers.
- `LProgressionStore:submitScore(profile, leaderboard_id, score) -> nil`: Performs the `submitScore` progression operation for Lua callers.
- `LProgressionStore:type() -> string`: Returns the runtime type name exposed by this progression object to Lua callers.
- `LProgressionStore:typeOf(name) -> boolean`: Returns the runtime type name exposed by this progression object to Lua callers.
- `LProgressionStore:unlockAchievement(profile, achievement_id) -> nil`: Performs the `unlockAchievement` progression operation for Lua callers.
- `LProgressionStore:update(dt, opts?) -> nil`: Updates this operation in the progression store for Lua callers.
- `LProgressionStore:updatePopulation(handle_or_id, dt, options?) -> nil`: Updates population in the progression store for Lua callers.
- `LProgressionStore:updateProfile(id, patch?) -> nil`: Updates profile in the progression store for Lua callers.
- `LProgressionStore:useSkill(profile, skill_id) -> nil`: Performs the `useSkill` progression operation for Lua callers.
- `LProgressionStore:validate() -> boolean`: Validates this operation using the progression store rules for Lua callers.
- `LProgressionStore:validateCondition(condition) -> boolean`: Validates condition using the progression store rules for Lua callers.
- `LProgressionStore:validateDerivedValues() -> boolean`: Validates derived values using the progression store rules for Lua callers.
- `LProgressionStore:validatePopulationTemplate(id) -> boolean`: Validates population template using the progression store rules for Lua callers.

#### LProgressionTransaction Type

- Lua-visible `ProgressionTransaction` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LProgressionTransaction:addCounter(profile, counter_id, amount) -> nil`: Adds counter to the progression store for Lua callers.
- `LProgressionTransaction:addExperience(profile, track_id, amount) -> nil`: Adds experience to the progression store for Lua callers.
- `LProgressionTransaction:addModifier(profile, target_id, opts) -> nil`: Adds modifier to the progression store for Lua callers.
- `LProgressionTransaction:commit() -> table`: Commits the pending progression transaction and returns its result to Lua callers.
- `LProgressionTransaction:rollback() -> nil`: Rolls back the pending progression transaction for Lua callers.
- `LProgressionTransaction:setAttributeBase(profile, attribute_id, value) -> nil`: Sets attribute base in the progression store for Lua callers.
- `LProgressionTransaction:setCounter(profile, counter_id, value) -> nil`: Sets counter in the progression store for Lua callers.
- `LProgressionTransaction:setQuestObjective(profile, quest_id, objective_id, value) -> nil`: Sets quest objective in the progression store for Lua callers.
- `LProgressionTransaction:setResource(profile, resource_id, value) -> nil`: Sets resource in the progression store for Lua callers.
- `LProgressionTransaction:type() -> string`: Returns the runtime type name exposed by this progression object to Lua callers.
- `LProgressionTransaction:typeOf(name) -> boolean`: Returns the runtime type name exposed by this progression object to Lua callers.

#### LQuestJournal Type

- Lua-side quest journal wrapper that owns retained entries and optional live mutation context.

##### Fields

- No documented fields.

##### Methods

- `LQuestJournal:addEntry(text, tag?) -> | LQuestJournalEntry | Retained journal entry after store-side indexing and trimming`: Appends one entry to the live quest journal and returns the stored entry object.
- `LQuestJournal:count() -> | integer | Journal entry count after retention trimming`: Returns the number of retained entries currently stored in this journal.
- `LQuestJournal:getQuestId() -> | string | Authored quest identifier`: Returns the quest id that owns this journal.
- `LQuestJournal:listEntries() -> | table | Array of `LQuestJournalEntry` userdata values`: Returns every retained journal entry as typed entry userdata.

#### LQuestJournalEntry Type

- Lua-visible `QuestJournalEntry` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LQuestJournalEntry:getIndex() -> | integer | Zero-based journal entry index`: Returns the stable monotonically increasing journal index.
- `LQuestJournalEntry:getTag() -> | string | Journal entry tag, or an empty string when no tag was stored`: Returns the optional journal entry tag.
- `LQuestJournalEntry:getText() -> | string | Retained journal body text`: Returns the authored journal entry text.

#### LQuestState Type

- Lua-side immutable progression quest state wrapper with optional live store context.

##### Fields

- No documented fields.

##### Methods

- `LQuestState:getJournal() -> | LQuestJournal | Journal handle for the current quest state`: Returns the retained quest journal as a typed journal object.
- `LQuestState:getQuestId() -> string | string | Quest identifier`: Returns quest id from the progression store for Lua callers.
- `LQuestState:getStatus() -> | string | Current quest state such as `"hidden"`, `"available"`, or `"active"``: Returns the current quest lifecycle status.
- `LQuestState:isRevealed() -> | boolean | `true` when the quest is visible`: Returns whether the quest is currently revealed to the owning profile.

#### LReward Type

- Lua-side immutable reward wrapper with optional live store context for state transitions.

##### Fields

- No documented fields.

##### Methods

- `LReward:claim() -> | LReward | Updated reward handle after the claim transition`: Claims this pending reward and returns the updated reward object.
- `LReward:getId() -> string | string | Stable reward identifier`: Returns id from the progression store for Lua callers.
- `LReward:getState() -> table | string | One of `"pending"`, `"claimed"`, `"applied"`, or `"rejected"``: Returns state from the progression store for Lua callers.
- `LReward:markApplied(external_receipt?) -> | LReward | Updated reward handle after the apply transition`: Marks this claimed reward as applied and returns the updated reward object.
- `LReward:reject(reason?) -> | LReward | Updated reward handle after the rejection transition`: Rejects this reward and returns the updated reward object.

#### LRival Type

- Lua-visible `Rival` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LRival:getProfileId() -> | string | Profile identifier that pinned the rival`: Returns the owner profile id for this rivalry.
- `LRival:getRivalProfileId() -> | string | Rival profile identifier`: Returns the pinned rival profile id.

#### LRivalDelta Type

- Lua-visible `RivalDelta` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LRivalDelta:getLeaderboardId() -> | string | Leaderboard identifier`: Returns the leaderboard used to compute this rivalry delta.
- `LRivalDelta:getRankDelta() -> | integer | Positive when the rival is behind, negative when ahead`: Returns the signed rank gap between the owner and rival profiles.

#### LSeason Type

- Lua-visible `Season` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LSeason:getId() -> string | string | Season identifier`: Returns id from the progression store for Lua callers.
- `LSeason:isActive() -> | boolean | `true` when the season is active`: Returns whether this season is currently active.

#### LSeasonArchive Type

- Lua-visible `SeasonArchive` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LSeasonArchive:getArchiveIndex() -> | integer | Archive sequence number`: Returns the monotonically increasing archive index for this season.
- `LSeasonArchive:getId() -> | string | Season identifier`: Returns the season id that owns this archive record.

#### LStatusTracker Type

- Lua-visible `StatusTracker` object carrying progression state and operations.

##### Fields

- No documented fields.

##### Methods

- `LStatusTracker:apply(subjectId, definitionId, sourceId?, stacks?) -> | integer | Status instance id`: Applies a status to a subject and returns its stable runtime instance id.
- `LStatusTracker:clear() -> nil`: Removes all definitions, instances, and queued events.
- `LStatusTracker:define(definition) -> nil`: Registers or replaces one status definition.
- `LStatusTracker:drainEvents() -> | table | Event records in deterministic emission order`: Takes and clears neutral apply/refresh/stack/tick/expired events.
- `LStatusTracker:get(instanceId) -> | table? | Status instance record, or nil when missing`: Returns one active status instance by runtime id.
- `LStatusTracker:has(subjectId, definitionOrTag) -> | boolean | Whether a matching instance exists`: Checks whether a subject has a status with the requested definition id or tag.
- `LStatusTracker:list(subjectId, filter?) -> | table | Status instance records`: Lists active status instances attached to one subject and matching all optional filters.
- `LStatusTracker:remove(instanceId) -> | boolean | True when an instance was removed`: Removes one active status instance.
- `LStatusTracker:removeByDefinition(subjectId, definitionId) -> | integer | Number of removed instances`: Removes every matching definition instance from one subject.
- `LStatusTracker:removeByTag(subjectId, tag) -> | integer | Number of removed instances`: Removes every instance carrying a copied tag from one subject.
- `LStatusTracker:restore(snapshot) -> nil`: Restores definitions, active instances, and ID allocation from a snapshot.
- `LStatusTracker:setPaused(instanceId, paused) -> | boolean | True when the instance exists`: Pauses or resumes one status instance's lifecycle timers.
- `LStatusTracker:setRemaining(instanceId, seconds?) -> | boolean | True when the instance exists`: Sets one status instance's remaining duration; nil makes it infinite.
- `LStatusTracker:snapshot() -> | table | Serializable status tracker snapshot`: Captures definitions, instances, and ID allocation state.
- `LStatusTracker:type() -> | string | Always `LStatusTracker``: Returns the Lua-visible type name.
- `LStatusTracker:typeOf(name) -> | boolean | Whether the name matches`: Checks whether this handle matches `LStatusTracker` or `LObject`.
- `LStatusTracker:update(dt) -> | integer | Number of events currently queued after the update`: Advances finite durations and periodic tick timers by dt seconds.

## Examples

- `content/examples/progression.lua` (present)

## Architecture Links

- No module-specific architecture links registered.

## Notes

- Use `clock = "manual"` for deterministic tests and offline simulation.
- Store and transaction APIs are designed so later roadmap phases can extend the module without changing the top-level ownership model.
- New gameplay code should use `lurek.progression` directly; the legacy adapter surface is now provided by that engine module instead of separate Lua libraries.
