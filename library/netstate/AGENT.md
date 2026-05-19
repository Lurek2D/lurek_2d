# `netstate` â€” Agent Reference (Lureksome)

| Property       | Value                                                                                                    |
| -------------- | -------------------------------------------------------------------------------------------------------- |
| **Tier**       | Tier 3 â€” Lureksome (pure Lua, no Rust dependencies)                                                       |
| **Source**     | `library/netstate/init.lua`                                                                              |
| **Lua Tests**  | `tests/lua/library/test_library_netstate.lua`                                                            |
| **Depends on** | `lurek.network` (mandatory for online mode), `lurek.serial` (optional, `:toJson`), `lurek.log` (optional) |
| **Status**     | Full                                                                                                     |

## Summary

Pure-Lua **network state replication** with per-key versioning, authority
control, delta updates, and an optional turn-based protocol. Sits on top of
`lurek.network` and matches the on-the-wire format used by `library.lobby`
(MessagePack via `lurek.network.pack` / `:unpack`).

Designed to make turn-based and lockstep multiplayer games trivial:

- **Authority model** â€” exactly one peer (typically the server) owns writes;
  others apply deltas read-only. Per-key version numbers prevent stale
  replays under concurrent updates.
- **Delta sync** â€” call `:sync()` once per frame on the authority; only dirty
  keys go on the wire.
- **Full snapshots** â€” joining clients call `:requestFullState()` to receive
  the authority's current state (no built-in timeout â€” caller responsible).
- **Turn-based** â€” opt-in via `opts.turnBased = true`; rotating peer order,
  monotonic turn counter, broadcast on `:beginTurn()`.
- **Desync detection** â€” `:hashState()` returns a deterministic FNV-1a 32-bit
  digest of all replicated state for cheap divergence checks.

## Wire Format

State deltas (`action="delta"`), full snapshots (`action="full"`), full-state
requests (`action="full_request"`), and turn changes (`action="turn"`) are
encoded with `lurek.network.pack` (MessagePack â€” the canonical ENet payload
format). For human-readable persistence (snapshots written to disk) call
`:toJson()`, which delegates to `lurek.serial.toJson`.

## Architecture

```
M.new(host?, opts?) â†’ NetState
  â”śâ”€â”€ _host           (lurek.network host or nil)
  â”śâ”€â”€ _channel        (ENet channel, default 0)
  â”śâ”€â”€ _authority      (boolean â€” only authority can :set)
  â”śâ”€â”€ _state          ({ key = {value, version, owner} })
  â”śâ”€â”€ _callbacks      ({ key = {fn, ...} })
  â”śâ”€â”€ _on_change      (global callback)
  â”śâ”€â”€ _dirty          (set of keys pending sync)
  â”śâ”€â”€ _dirty_order    (insertion-order list for maxDirtyKeys eviction)
  â”śâ”€â”€ _max_dirty      (cap on dirty set; nil = unlimited)
  â”śâ”€â”€ turn-based      (current_turn, turn_peer, turn_order, turn_index, on_turn)
  â””â”€â”€ on_full_state_timeout (caller-implemented)

NetState methods:
  setAuthority(b) / isAuthority() â†’ boolean
  set(key, value)             â†’ ok, err? (authority only)
  get(key) / getKeyVersion(key) / hasKey(key) / remove(key)
  getAll() / getKeyCount() / getDirtyCount() / getVersion()
  onChange(fn) / onChanged(key, fn) / clearCallbacks(key)
  sync()                      (authority broadcast)
  poll() â†’ array of {key, value, old_value, peer_id}
  requestFullState() â†’ ok    (no built-in timeout)
  onFullStateTimeout(fn)     (caller-driven)
  hashState() â†’ number       (FNV-1a 32-bit, desync detection)
  toJson() â†’ string|nil      (uses lurek.serial.toJson when available)

Turn-based:
  setTurnOrder({peer_id, ...}) / beginTurn() / endTurn() / getCurrentTurn()
  getTurnPeer() / onTurn(fn) / isTurn(peer_id)

Logging:
  M.setLogging(enabled, custom_log?)   (delegates to lurek.log.debug)
```

## Source Files

| File                        | Purpose                                                                      |
| --------------------------- | ---------------------------------------------------------------------------- |
| `library/netstate/init.lua` | Full implementation â€” NetState manager, delta protocol, turn-based, hashing. |

## Key Types

| Type     | Constructor           | Purpose                    |
| -------- | --------------------- | -------------------------- |
| NetState | `M.new(host?, opts?)` | State replication manager. |

## Notes

- **Authority is required** to call `:set()`. Non-authority writes return
  `false, "not authority"` and are not silently dropped.
- **Per-key versioning** is monotonic per key (not global). Two peers
  modifying *different* keys at the same logical tick do not race.
- **Dirty key cap** (`opts.maxDirtyKeys`) evicts the oldest dirty key when
  exceeded â€” useful in scripted stress where the dirty set could grow
  unbounded between syncs.
- **`requestFullState` has no built-in timeout** â€” use `onFullStateTimeout` or
  `lurek.timer.Scheduler:after(...)` to drive a retry.
- **`:hashState()` is not a cryptographic hash** â€” it is a deterministic
  FNV-1a digest sufficient for desync detection. Will delegate to
  `lurek.data.hash` once that P4 lift candidate lands.
- **Wire format is MessagePack**, not JSON. Do not mix `:toJson()` payloads
  on the same channel.

## Lua API Reference

See LDoc-generated page: `docs/api/lureksome.lua` (regenerated by
`python tools/docs/gen_lib_docs.py`).

