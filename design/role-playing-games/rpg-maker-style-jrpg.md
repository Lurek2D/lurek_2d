# RPG Maker Style JRPG

> Category: `role-playing-games`
> Scope: top-down tile-based JRPG, RPG Maker-inspired town/dungeon adventure, party RPG, cozy quest RPG, or story-heavy 2D RPG built with Lurek2D.
> Implementation tracker: #47

## Market positioning

A RPG Maker-style JRPG in Lurek2D should offer familiar comfort: tile maps, towns, dungeons, NPCs, treasure chests, shops, turn-based battles, party growth, quests, save points, and a database-driven content model. Lurek's advantage is not a visual editor. The advantage is a Lua-first, AI-assisted, testable runtime where RPG content can be generated, validated, imported, and executed with deterministic scripts.

Best fit:

- short Steam or itch.io JRPG with 3-8 hours of content
- jam-sized RPG Maker-style adventure
- narrative RPG with town exploration and turn-based encounters
- systems prototype for battle formulas, items, quests, shops, and progression
- AI-assisted content pipeline where generated database rows remain reviewable content

Not the goal:

- perfect compatibility with arbitrary RPG Maker projects and plugins
- editor-first map/event authoring in phase 1
- MMO-scale online RPG
- 3D action RPG
- mobile-first RPG Maker replacement

## Player promise

The player explores a readable tile world, talks to NPCs, solves event-driven problems, collects items, grows a party, fights tactical turn-based battles, and returns to saved progress without losing context.

## Core loop

1. Load the current map, player position, party, inventory, switches, variables, and self switches.
2. Player moves on a tile grid with camera follow and collision/passability rules.
3. Action button or collision trigger runs an event: NPC dialogue, chest, transfer, shop, inn, cutscene, puzzle, or battle.
4. Battles award gold, items, experience, quest progress, and state changes.
5. Switches, variables, and self switches select new event pages and unlock new content.
6. Save points or menu saves persist map state, party state, and database-driven progress.
7. Chapter milestones unlock new maps, quests, shops, and enemy tables.

## Suggested project structure

```text
content/games/<jrpg_name>/
  conf.toml
  main.lua
  assets/
    tilesets/
    characters/
    faces/
    battlers/
    animations/
    ui/
    audio/
      bgm/
      bgs/
      me/
      se/
  data/
    database/
      actors.toml
      classes.toml
      skills.toml
      items.toml
      weapons.toml
      armors.toml
      enemies.toml
      troops.toml
      states.toml
      animations.toml
      common_events.toml
    maps/
      map_001_town.toml
      map_002_forest.toml
    imports/
      rpgmaker_mz/
        Actors.json
        Classes.json
        Skills.json
        Items.json
        Weapons.json
        Armors.json
        Enemies.json
        Troops.json
        States.json
        Tilesets.json
        CommonEvents.json
        MapInfos.json
        Map001.json
  scripts/
    systems/
      rpg_runtime.lua
      player_controller.lua
      event_runtime.lua
      battle_adapter.lua
      shop_runtime.lua
      party_menu.lua
      map_loader.lua
      save_adapter.lua
```

## State model

The state should mirror the mental model RPG Maker users already understand, while keeping Lua data explicit.

```lua
GameState = {
  map = {
    id = 1,
    x = 12,
    y = 8,
    facing = "down",
    region_id = 0,
    encounter_steps = 24,
  },
  party = {
    gold = 120,
    actors = { "hero", "healer" },
    inventory = {},
    equipment = {},
    levels = {},
    exp = {},
  },
  world = {
    switches = {},
    variables = {},
    self_switches = {}, -- key: map_id:event_id:letter
    common_event_queue = {},
  },
  quests = {},
  battle = {
    last_troop_id = nil,
    rewards_pending = nil,
  },
}
```

## Data and content model

### Database tables

Store RPG data as TOML/Lua tables for native projects. Import RPG Maker MZ JSON into the same normalized shape.

```lua
Skill = {
  id = 7,
  name = "Spark",
  scope = "enemy_single",
  cost = { mp = 4 },
  formula = "a.mat * 2 - b.mdf",
  element = "thunder",
  success_rate = 1.0,
  effects = {
    { kind = "damage", type = "magical" },
    { kind = "state", id = "shock", chance = 0.15 },
  },
}
```

### Map model

The visual map belongs to `lurek.tilemap`. Gameplay facts belong to `lurek.tilefield` and Lua metadata.

```lua
Map = {
  id = 1,
  name = "Harbor Town",
  tilemap = tilemap_handle,
  tilefield = tilefield_handle,
  tileset_id = 3,
  events = {},
  encounters = {},
  regions = {},
  transfers = {},
}
```

### Event model

Events use pages, conditions, triggers, and command lists. Highest valid page wins.

```lua
Event = {
  id = 4,
  name = "Treasure Chest",
  x = 15,
  y = 9,
  pages = {
    {
      conditions = { self_switch = "A" },
      sprite = "chest_open",
      trigger = "action_button",
      commands = {
        { code = "Show Text", speaker = nil, text = "The chest is empty." },
      },
    },
    {
      conditions = {},
      sprite = "chest_closed",
      trigger = "action_button",
      commands = {
        { code = "Show Text", text = "Found a Potion!" },
        { code = "Change Items", item = "potion", amount = 1 },
        { code = "Control Self Switch", letter = "A", value = true },
      },
    },
  },
}
```

## Lurek API strategy

| Need | Existing surface | Strategy |
|---|---|---|
| Tile world | `lurek.tilemap`, `lurek.tilefield`, `lurek.tileset`, `lurek.tilelight`, `lurek.pathfind` | Store visual layers in tilemap; passability/regions/costs in tilefield; routes through pathfind. |
| RPG Maker assets | `lurek.sprite.newRPGMakerSheet`, `lurek.sprite.newAutoTileSheet(..., "rpgmaker48", ...)` | Support character sheets and RPG Maker-like autotile sheets. |
| Player/NPC rendering | `lurek.sprite`, `lurek.animation`, `lurek.tween`, `lurek.camera` | Walk cycles, facing, camera follow, damage popups, transfer fades. |
| Events/dialogue | `lurek.dialog`, `lurek.event` | Event commands call dialogue, choices, variables, and common events. |
| Battle | `library.battle`, `library.stats`, `lurek.ui`, `lurek.audio` | Turn-based battle adapter with party/enemy combatants and UI panels. |
| Party/items | `library.item`, `library.inventory`, `library.quest` | Inventory, equipment, rewards, quest objectives, journal. |
| Database | `lurek.dataframe`, `lurek.serialize`, `lurek.filesystem` | Load JSON/TOML/CSV tables, validate schema, support balancing tools. |
| Save | `lurek.save` | Persist map, party, switches, variables, self switches, quests, and migration version. |
| Menus | `lurek.ui` | Party menu, item menu, equipment, skills, save screen, shop, inn, quest journal. |
| AI workflow | `lurek.agent`, docs/stubs | Generate database drafts, event command tests, NPC dialogue, and balance reports. |

## Runtime architecture

Use a `RpgRuntime` coordinator with explicit subsystem ownership.

```lua
local rpg = require("library.rpg_runtime")

local runtime = rpg.newRuntime({
  database = database,
  map_loader = map_loader,
  save_manager = save_mgr,
})

runtime:bindParty(party)
runtime:bindInventory(inventory)
runtime:bindQuestLog(quest_log)
runtime:bindDialog(dialog_seq)
runtime:bindBattle(battle_adapter)
runtime:loadMap(1, { x = 12, y = 8, facing = "down" })
```

## Need implementation notes

The current Lurek API can build a native JRPG, but RPG Maker-style support needs a dedicated compatibility/data/event layer. Track this under issue #47.

Required new library/API layer:

- `library.rpgmaker.loadDatabase(path)` to load RPG Maker MZ-style `data/*.json` files into normalized Lua tables.
- `library.rpgmaker.loadMap(path, database)` to build tilemap, tilefield, events, encounters, regions, transfer metadata, and tileset references.
- `library.rpgmaker.newEventRuntime(opts)` to execute event pages and command lists deterministically.
- Switch, variable, and self-switch APIs.
- Event page resolver with conditions: switch, variable, self switch, item, actor, party member.
- Trigger APIs: action button, player touch, event touch, autorun, parallel.
- Blocking command interpreter: dialogue waits, choice waits, move route waits, battle waits, transfer waits, shop waits.
- Passability adapter from RPG Maker tileset flags to `lurek.tilefield` blockers and path costs.
- Region and terrain tag metadata bridge for random encounters, hazards, quest zones, and cutscene triggers.
- Event trace output for tests and debugging.

## Event command subset for phase 1

Implement a practical subset before chasing full compatibility.

- Show Text
- Show Choices
- Control Switches
- Control Variables
- Control Self Switch
- Conditional Branch
- Transfer Player
- Set Event Location
- Set Move Route
- Wait
- Play BGM / BGS / ME / SE
- Stop or fade audio
- Change Gold
- Change Items
- Change Weapons
- Change Armors
- Change Party Member
- Battle Processing
- Shop Processing
- Common Event
- Label / Jump to Label
- Loop / Break Loop
- Exit Event Processing
- Show Picture / Move Picture / Erase Picture

## Vertical slice

Build one town-to-dungeon loop.

Minimum slice:

- title screen and load screen
- one town map, one forest/dungeon map
- player character with four-direction walk cycle
- two NPC events with dialogue and choices
- one treasure chest with self switch
- one transfer event between maps
- one shop event
- one save point
- one random or scripted battle
- three actors, four skills, five items, two enemies, one troop
- one quest with two objectives
- one boss gate controlled by a switch or variable

## Test strategy

- Import test: load database and map files, assert table counts and normalized keys.
- Passability test: blocked tile prevents movement and pathfinding avoids it.
- Event page test: switch/self-switch changes selected page.
- Command interpreter test: execute chest event and assert item + self switch.
- Transfer test: execute transfer and assert map id, x, y, facing.
- Battle adapter test: event starts troop, battle result writes rewards, quest progress updates.
- Save/load test: switches, variables, self switches, party, map id, and inventory round-trip.
- Headless event trace test: run an autorun cutscene and compare trace artifact.

## Production risks

- RPG Maker compatibility scope can explode; define an MZ subset and reject unsupported plugin commands clearly.
- Event command blocking semantics must be deterministic or bugs will be hard to reproduce.
- Tileset passability rules are more important than visual import for gameplay feel.
- Battle formulas and states can become a scripting language inside the scripting language; keep formula evaluation sandboxed.
- Editor-first expectations should be redirected to importers, validators, and VS Code tooling rather than a full built-in editor.

## Acceptance checklist

- [ ] A native Lurek JRPG can be built without RPG Maker imports.
- [ ] A MZ-style database subset can be imported into normalized Lua tables.
- [ ] A MZ-style map subset can create tilemap, tilefield, events, and region metadata.
- [ ] Event pages resolve by switch/variable/self-switch conditions.
- [ ] Event runtime can block on dialogue, choices, move routes, transfers, shops, and battles.
- [ ] Tile passability feeds movement and pathfinding.
- [ ] Party, inventory, quests, battle rewards, switches, variables, and self switches persist through `lurek.save`.
