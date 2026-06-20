# Network Duel

**Category:** arcade / multiplayer  
**Status:** skeleton

Offline-first loopback duel for demonstrating packet state, snapshots, replay, and reconciliation.

**Modules:** `network`, `serial`, `scene`, `automation`

Next steps:
- Add two local players with deterministic input packets.
- Show predicted state versus corrected state.
- Keep default smoke mode local without external network dependencies.

Run:

```bash
cargo run -- content/games/arcade/network_duel
```
