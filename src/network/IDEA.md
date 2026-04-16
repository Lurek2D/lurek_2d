# IDEA.md — `network` module

> Migrated from `ideas/features/network.md` and `ideas/performance/23-network-pipeline-future.md`.
> Status checked against `src/network/` and `src/lua_api/network_api.rs`.
> Lua namespaces: `lurek.network` (ENet UDP) and `lurek.network.net` (async HTTP/WS).

---

## Features

### ❌ DEFERRED — NAT Punchthrough
**Source**: features/network.md — Feature Gaps #4

Requires relay server infrastructure. Deferred.

---

### ❌ DEFERRED — Input Prediction / Rollback (Action Games)
**Source**: features/network.md — Feature Gaps #8

Complex to implement correctly. Deferred until multiplayer action game demos prove demand.

---

### ❌ TODO — Background Network Polling via Thread
**Source**: features/network.md — Structural Issues / Suggestions #8

`poll()` runs on the main thread. For high-frequency networking, this budgets main-thread
time. Add documented guidance or native support for running network polling on a
`lurek.thread` worker and returning events to the main thread via Channel.
