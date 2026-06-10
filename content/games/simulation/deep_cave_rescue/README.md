# Deep Cave Rescue

**Category:** simulation / exploration  
**Status:** skeleton

Async cave exploration demo where chunks are generated in the background while the player searches for a rescue beacon.

**Modules:** `thread`, `procgen`, `tilemap`, `pathfind`, `save`

Next steps:
- Move chunk generation to a worker/channel flow.
- Add cave map reveal and beacon route updates.
- Save discovered chunks and rescue progress.

Run:

```bash
cargo run -- content/games/simulation/deep_cave_rescue
```
