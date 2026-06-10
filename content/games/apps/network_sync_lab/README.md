# Network Sync Lab

**Category:** apps / network diagnostics  
**Status:** skeleton

Offline-first diagnostics app for snapshot packing, worker/channel flow, latency charts, and packet inspection.

**Modules:** `network`, `thread`, `serial`, `charts`

Next steps:
- Add loopback packet timeline and charted latency.
- Compare predicted state against reconciled state.
- Keep tests deterministic without external servers.

Run:

```bash
cargo run -- content/games/apps/network_sync_lab
```
