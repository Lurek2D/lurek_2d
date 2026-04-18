# `library.loot`

Lurek2D loot library — designer-friendly weighted RNG, drop DSL, and pity timers.

A pure-Lua loot table system built on `lurek.math.RandomGenerator`. Provides:

* `LootTable` — Walker–Vose alias-method weighted RNG with O(1) sampling.
* `DropSet`   — composable, conditional, multi-roll drop DSL.
* `Pity`      — guaranteed-after-N-misses helper for streak protection.
* `Modifier`  — luck/level/zone weight multipliers applied as a temporary view.

Usage:
local loot = require("library.loot")
local tbl  = loot.fromList({
{id="gold", weight=60},
{id="ring", weight=10, meta={tier="rare"}},
})
local id, meta = tbl:sample()

*32 functions, 0 module fields documented.*

See: [`lurek.math.newRandomGenerator`](../lua-api.md#lurekmathnewrandomgenerator) — default RNG source for sampling, [`lurek.codec.fromToml`](../lua-api.md#lurekcodecfromtoml) — designer-authored loot tables (`fromToml`), [`lurek.fs.read`](../lua-api.md#lurekfsread) — sandboxed file load for `fromToml`, [`lurek.savegame`](../lua-api.md#lureksavegame) — `Pity:save`/`restore` collector wiring

## Functions

### `setDefaultRng(rng)`

Install a custom default RNG used by `LootTable:sample` when no rng arg is passed.

**Parameters**

- `rng` *userdata|table* — A `RandomGenerator` or any object implementing `:random()` → [0,1).

### `getDefaultRng()`

Get the module's current default RNG (resolves on first use).

**Returns**

- *userdata|table* — The RNG instance.

### `newTable()`

Create an empty weighted loot table.

**Returns**

- *LootTable*

### `fromList(entries)`

Bulk-build a loot table from a list of `{id, weight, meta?}` entries.

**Parameters**

- `entries` *table* — Array of `{id=string, weight=number, meta=table?}`.

**Returns**

- *LootTable*

### `fromToml(path)`

Load a loot table from a TOML file via `lurek.fs.read` + `lurek.codec.fromToml`. The file must contain an `entries = [...]` array.

**Parameters**

- `path` *string* — Sandboxed game-path to a TOML file.

**Returns**

- *LootTable*

**Raises**

- descriptive error on missing engine bindings or malformed file.

### `merge(...)`

Combine multiple LootTables into a single new one. Identical IDs sum weights.

**Parameters**

- `...` *LootTable* — Two or more tables.

**Returns**

- *LootTable*

### `add(id, weight, meta)`

Add or accumulate an entry. Triggers alias rebuild on next sample.

**Parameters**

- `id` *string* — Unique entry identifier.
- `weight` *number* — Positive weight.
- `meta` *table?* — Opaque user data returned alongside `id` from `:sample`.

**Returns**

- *LootTable* — self for chaining.

### `remove(id)`

Remove an entry by id.

**Parameters**

- `id` *string* — Entry identifier.

**Returns**

- *boolean* — true if removed.

### `setWeight(id, w)`

Adjust an entry's weight (rebuilds alias on next sample).

**Parameters**

- `id` *string*
- `w` *number* — new positive weight.

**Returns**

- *LootTable* — self

### `sample(rng)`

O(1) sample one entry from the alias table.

**Parameters**

- `rng` *userdata|table?* — Optional `RandomGenerator` (defaults to module RNG).

**Returns**

- *string* — id
- *table?* — meta (may be nil)

### `sampleN(n, rng, opts)`

Bulk draw N samples.

**Parameters**

- `n` *integer* — Number of draws (must be >= 0).
- `rng` *userdata|table?*
- `opts` *table?* — `{unique=true}` for sampling without replacement.

**Returns**

- *table* — Array of ids (length n).

**Raises**

- on `unique=true` when n exceeds the entry count.

### `weightOf(id)`

Current weight of an entry.

**Parameters**

- `id` *string*

**Returns**

- *number* — Weight, or 0 if unknown.

### `totalWeight()`

Total weight of all entries.

**Returns**

- *number*

### `probability(id)`

Normalised probability of an entry (0..1).

**Parameters**

- `id` *string*

**Returns**

- *number*

### `ids()`

Snapshot of all entry ids.

**Returns**

- *table* — Array of ids.

### `clone()`

Deep-copy this table.

**Returns**

- *LootTable*

### `newDrop()`

Create a composable drop description.

**Returns**

- *DropSet*

### `roll(tbl, opts)`

Roll a loot table N times.

**Parameters**

- `tbl` *LootTable*
- `opts` *table?* — `{count=1, chance=1.0, tag=nil}`.

**Returns**

- *DropSet* — self

### `guarantee(id, count)`

Always emit `id × count`.

**Parameters**

- `id` *string*
- `count` *integer?* — defaults 1.

**Returns**

- *DropSet* — self

### `when(fn)`

Gate the next clauses on a predicate `fn(context) -> bool`. The gate persists for all subsequent `:roll`/`:guarantee` calls in the chain.

**Parameters**

- `fn` *function(context)* — -> bool

**Returns**

- *DropSet* — self

### `resolve(context, rng)`

Execute all clauses against `context` and return the resolved drop list.

**Parameters**

- `context` *table* — Arbitrary context passed to gate predicates.
- `rng` *userdata|table?*

**Returns**

- *table* — List of `{id=string, count=integer, meta=table?}`.

### `explain(context)`

Human-readable explanation of which clauses would fire.

**Parameters**

- `context` *table*

**Returns**

- *string*

### `newPity(target_id, threshold)`

Guarantee `target_id` is forced after `threshold` consecutive misses.

**Parameters**

- `target_id` *string* — Id whose appearance resets the counter.
- `threshold` *integer* — Misses before pity fires (must be >= 1).

**Returns**

- *Pity*

### `notice(result_id)`

Notice a draw result. Returns true when pity is now primed and should force `target_id` on the next draw.

**Parameters**

- `result_id` *string* — The id that just dropped.

**Returns**

- *boolean* — primed

### `reset()`

Reset the pity counter to 0.

### `getCounter()`

Current miss counter.

**Returns**

- *integer*

### `isPrimed()`

True when pity will fire on the next draw.

**Returns**

- *boolean*

### `save()`

Serialise to a save blob.

**Returns**

- *table*

### `restore(blob)`

Restore from a save blob.

**Parameters**

- `blob` *table* — Output of `Pity:save`.

**Returns**

- *Pity* — self

### `newModifier()`

Stack of named weight multipliers applied to a LootTable view.

**Returns**

- *Modifier*

### `add(name, fn)`

Add a multiplier function.

**Parameters**

- `name` *string* — label.
- `fn` *function* — `(entry, context) -> multiplier`.

**Returns**

- *Modifier* — self

### `apply(tbl, context)`

Produce a temporary LootTable with adjusted weights. Original is untouched.

**Parameters**

- `tbl` *LootTable*
- `context` *table* — Passed to each multiplier.

**Returns**

- *LootTable*
