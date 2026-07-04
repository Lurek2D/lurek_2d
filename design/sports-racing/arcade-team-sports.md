# Arcade Team Sports

**Category:** Sports and racing  
**Reference games:** Sensible Soccer, NBA Jam, Super Dodge Ball, Windjammers  
**Document type:** Technical game design and architecture

## Design target

A 2D arcade team sports game with readable players, quick matches, ball or puck possession, simple tactics, local multiplayer potential, and AI teammates. The design favors responsiveness over simulation realism.

## Lurek2D API map

| Need | Lurek2D surface |
|---|---|
| Field/court rendering | `lurek.render`, `lurek.camera`, `lurek.tilemap` if grid-like |
| Players and ball | `lurek.ecs`, `lurek.physics`, `lurek.animation` |
| Input/local control | `lurek.input`, gamepad callbacks, `lurek.ui` |
| Teammate AI | `lurek.ai`, `lurek.pathfind`, steering/influence maps |
| Match flow | `lurek.time`, `lurek.signal`, `lurek.audio`, `lurek.save` |

## Runtime architecture

Use a match state with period clock, score, possession, teams, controlled player, ball state, referee state, and replayable events. Input maps to player intents: move, pass, shoot, tackle, switch, sprint, special.

The ball should be a first-class entity with position, velocity, owner, loose state, target trajectory, and collision/hit rules. Player AI has roles: support, defend, mark, chase ball, receive pass, cover goal, or press.

Keep rules arcade-simple at first. It is better to ship a fun two-minute match than a half-implemented realistic ruleset.

## Suggested project structure

```text
my_arcade_sport/
  data/teams.toml
  data/players.toml
  data/match_rules.toml
  scripts/state/match.lua
  scripts/systems/player_control.lua
  scripts/systems/ball.lua
  scripts/systems/scoring.lua
  scripts/ai/team_ai.lua
  scripts/ui/scoreboard.lua
  assets/players/
```

## Vertical slice acceptance

The slice should include one field, two teams, passing, shooting/scoring, possession changes, goalie or defender AI, match timer, local two-player option, and results save.

## Risks

The risk is input ambiguity. Every control action should have clear priority rules. Ball possession, tackle windows, and target selection must be visible enough that failure feels fair.
