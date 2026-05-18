# Province Economy Loop

## Summary

This document defines a world-scale province economy for a graph map in the style of Galcon growth plus grand-strategy logistics.

The map is made of connected provinces. Each province belongs to one of three logistics roles:

- capital,
- hub,
- province.

The system is built around three primary province resources:

- population,
- food stockpile,
- gold stockpile.

The most important rule is strict:

- no food teleports,
- no gold teleports,
- no empire-wide shared balance,
- no hidden background transfer.

Every unit of food and gold must exist at a real node and must be moved by a real shipment.

---

## Non-Negotiable Rules

1. Food and gold move only through physical shipments.
2. A shipment can launch only if the origin node physically holds the cargo.
3. A province can build only with the food and gold physically stored in that province.
4. A province pays army upkeep only from its local stockpiles.
5. Gold moves upstream from province to nearest hub or capital.
6. Food moves downstream from hub or capital to the nearest province that needs it.
7. Route priority can be automated, but movement itself is never virtual.

---

## Time Model

- 1 second of real time = 1 day of game time.
- 30 game days = 1 month.
- Shipments move every day.
- Economy, growth, taxes, happiness, starvation, and migration resolve once per month.

This means the game has two layers:

- a daily logistics layer,
- a monthly economy layer.

---

## Node Hierarchy

| Node | Role |
|------|------|
| Capital | Main political center and main market node. Buys food, stores large reserves, sends bulk convoys, and receives large tax remittances. |
| Hub | Special building inside a province. Stores large reserves, receives bulk shipments, and redistributes food and gold to nearby provinces. |
| Province | Normal local node. Stores local resources, consumes food, generates tax gold, supports army and construction, and sends gold upstream. |

The intended empire flow is:

- capital -> hub -> province for food and strategic support,
- province -> hub -> capital for gold and extracted value.

---

## Province Model

Each province tracks the following core state.

| Field | Default | Notes |
|-------|---------|-------|
| Population | scenario-defined | Current residents of the province. |
| Population Cap | 30 | Base maximum population. Increased by housing. |
| Monthly Growth | 1 | Base natural growth per month. Increased by farms and modifiers. |
| Happiness | 10 | Base local stability and satisfaction. |
| Building Slots | 1 to 6 | Province size and development limit. |
| Food Stockpile | scenario-defined | Local food reserve. Used by population, army, and local building work. |
| Gold Stockpile | scenario-defined | Local gold reserve. Used by army and local building work. |
| Logistics Parent | nearest hub or capital | Upstream node chosen by shortest route time. |

These are the three primary province resources:

- population,
- food stockpile,
- gold stockpile.

Everything else is state, modifier, or routing metadata.

---

## Province Structures and Slots

Each province has a limited number of building slots.

- minimum: 1 slot,
- maximum: 6 slots.

Slot count is part of province quality and long-term strategic value.

### Confirmed Buildings

| Building | Slot Cost | Effect |
|----------|-----------|--------|
| Hub | 1 | Turns the province into a logistics center with bigger storage and stronger convoy handling. |
| Farm | 1 | +1 monthly population growth. |
| Housing | 1 | +30 population cap. |
| Tax Building | 1 | Improves tax efficiency or tax multiplier. Exact subtype can be defined later. |

Only these building rules are fixed in this document. Other building types can be added later.

### Hub as a Special Structure

A hub is expensive and uses one slot.

It is the key building for long-distance empires because it:

- stores more food and gold than a normal province,
- receives larger shipments,
- dispatches larger shipments,
- reduces logistics friction,
- collects gold from child provinces,
- redistributes food to child provinces.

Without hubs, a large empire becomes too slow and too fragile.

---

## Resource Rules

### Population

Population is both workforce and demand.

- it increases through monthly growth,
- it decreases through hunger, war, revolt, and emigration,
- it cannot go above population cap,
- it directly drives food demand,
- it directly drives base tax output.

### Food

Food is a local stockpiled resource.

- 1 population consumes 1 food per monthly tick,
- army also consumes food locally,
- local construction can consume food locally,
- food bought on the market appears at the capital only,
- food must then be shipped physically to hubs or provinces.

Suggested base rule:

```text
population_food_need = population
```

### Gold

Gold is also a local stockpiled resource.

- gold is generated locally by taxes,
- gold remains local until shipped away,
- gold is used locally for army upkeep and building,
- only surplus gold should move upstream.

Default tax rule:

- 10 population gives 1 gold,
- this is the default 10% tax baseline,
- tax level and buildings can improve it.

Suggested base rule:

```text
base_tax_gold = floor(population / 10)
effective_tax_gold = floor(base_tax_gold * tax_level_multiplier * tax_building_multiplier * province_multiplier * happiness_productivity_multiplier)
```

This preserves the clear rule that 10 population is worth 1 gold at the default level.

---

## Happiness, Growth, and Migration

### Happiness

Happiness is the main local social stability value.

- default happiness is 10,
- war lowers happiness,
- high taxes lower happiness,
- revolt lowers happiness,
- no food lowers happiness,
- buildings and local safety can improve happiness.

Suggested happiness bands:

| Happiness | Meaning |
|-----------|---------|
| 0 to 4 | Crisis. Province may lose population, suffer revolt, and stop normal growth. |
| 5 to 14 | Normal. Province behaves in the standard way. |
| 15+ | Prosperous. Province becomes more productive and attracts immigration. |

### Monthly Growth

Population growth is resolved once per month, similar to Galcon-style discrete growth.

Default growth:

- base monthly growth = +1,
- each farm adds +1 more.

Suggested base rule:

```text
monthly_growth_value = 1 + farm_count + growth_modifiers
natural_growth = min(monthly_growth_value, population_cap - population)
```

Natural growth should apply only when the province is fed and not in severe unrest.

### Population Cap

Default cap:

- base cap = 30,
- each housing building adds +30 cap.

Suggested base rule:

```text
population_cap = 30 + (housing_count * 30) + cap_modifiers
```

### Migration

Population can also move between provinces.

Main migration drivers:

- low happiness pushes people out,
- high happiness pulls people in,
- food shortage pushes people out,
- war pushes people out,
- safe and rich provinces pull people in.

Suggested directional rules:

- below happiness 5: province may lose population by emigration and may roll revolt,
- above happiness 15: province gains productivity and can attract immigration from weaker neighbors.

Migration should prefer nearby friendly provinces connected by safe routes.

---

## Logistics and Shipment Rules

### Physical Shipment Rule

Each shipment should have at least:

- origin,
- destination,
- cargo type,
- cargo amount,
- route,
- ETA,
- risk state.

Suggested launch rule:

```text
can_launch_shipment = origin_stockpile >= cargo_amount
```

If the cargo is not present, the shipment cannot launch.

### Routing Rule

Each normal province should have one logistics parent:

- nearest reachable hub by route time,
- if no hub exists, nearest reachable capital.

Hubs can also chain upward to another hub or directly to the capital.

Route choice should use route travel days, not raw map pixels.

Suggested rule:

```text
route_days = sum(edge_travel_days / convoy_speed_class) + loading_days + unloading_days + security_delay_days
```

Visual movement can still be animated freely, but the gameplay truth is route ETA.

### Upstream Gold Flow

Gold moves upstream from province to hub or capital.

Default upstream behavior:

1. Province keeps enough gold for local army and planned building.
2. Remaining gold becomes dispatchable surplus.
3. Surplus gold is sent to the logistics parent.

Suggested rule:

```text
dispatchable_gold = max(0, gold_stockpile - local_gold_reserve - army_gold_need - planned_build_gold_need)
```

### Downstream Food Flow

Food moves downstream from hub or capital to provinces.

Default downstream behavior:

1. Province computes its target reserve.
2. If current food is below target, the province is marked as needing supply.
3. The parent hub or capital sends food to the nearest connected province that needs it.

Suggested rule:

```text
target_food_reserve = monthly_food_need * reserve_months
food_deficit = max(0, target_food_reserve - food_stockpile)
```

This keeps the user request intact:

- gold goes to the closest hub or capital,
- food goes from hub or capital to the closest province that needs it.

### No Automatic Chain Teleport

Arrival at a hub does not continue automatically to the next node.

If food arrives in Bombay, it stays in Bombay until a new shipment carries it to Delhi.

If gold arrives in Delhi, it stays in Delhi until it is spent locally or loaded onto a new shipment.

Automation may create shipment orders, but the cargo itself always moves physically.

---

## Simulation Loop

### Daily Layer

Every game day:

1. Move all active shipments.
2. Resolve arrivals and unload cargo.
3. Update route risk, blockade, interception, and escort results.
4. Move armies and resolve war losses if needed.

### Monthly Layer

Every 30 days:

1. Resolve local food consumption for population and army.
2. Resolve local gold spending for army upkeep and active construction.
3. Update happiness from food, tax pressure, war, revolt, and local conditions.
4. Apply starvation deaths and war deaths.
5. Apply natural growth if the province is eligible.
6. Apply emigration and immigration.
7. Generate local tax gold.
8. Create upstream gold shipment orders from provinces with dispatchable surplus.
9. Create downstream food shipment orders for provinces below target reserve.

This keeps transport continuous and economy discrete.

---

## Local Spending Rules

### Food Spending

Food is used for:

- population,
- army,
- local building work.

If local food is missing:

- growth should stop,
- happiness should fall,
- starvation can begin,
- migration pressure should rise.

### Gold Spending

Gold is used for:

- army,
- local building work.

If local gold is missing:

- army upkeep fails,
- construction slows or stops,
- local stability may worsen.

### Local Construction Rule

If the player wants to build in India, then India must physically hold the required food and gold.

Suggested rule:

```text
can_build = local_food_stock >= build_food_cost and local_gold_stock >= build_gold_cost
```

London being rich does not help until the shipment arrives.

---

## Base Formulas

These formulas are enough for the first playable version.

```text
population_food_need = population
monthly_food_need = population_food_need + army_food_need

population_cap = 30 + (housing_count * 30) + cap_modifiers
monthly_growth_value = 1 + farm_count + growth_modifiers
natural_growth = min(monthly_growth_value, population_cap - population)

base_tax_gold = floor(population / 10)
effective_tax_gold = floor(base_tax_gold * tax_level_multiplier * tax_building_multiplier * province_multiplier * happiness_productivity_multiplier)

target_food_reserve = monthly_food_need * reserve_months
food_deficit = max(0, target_food_reserve - food_stockpile)
dispatchable_gold = max(0, gold_stockpile - local_gold_reserve - army_gold_need - planned_build_gold_need)

can_launch_shipment = origin_stockpile >= cargo_amount
can_build = local_food_stock >= build_food_cost and local_gold_stock >= build_gold_cost

population_next = clamp(0, population_cap, population + natural_growth + immigration - starvation_deaths - war_deaths - emigration)
```

Exact army formulas, revolt formulas, and convoy loss formulas can be tuned later.

---

## World-Empire Behavior

This model works for a Britain-style empire because distance matters without using fake transfer.

Example:

1. London buys food.
2. London ships food to Bombay hub.
3. Bombay hub stores it.
4. Bombay hub ships food to Delhi.
5. Delhi population and army consume local food.
6. Delhi generates local tax gold.
7. Delhi sends surplus gold back to Bombay.
8. Bombay aggregates gold and later sends a larger convoy back to London.

If Delhi wants to build a housing structure, then Delhi must first receive the required gold and food. Nothing is paid from a hidden imperial pool.

This keeps colonies valuable but slow, and makes hub placement one of the main strategy decisions.

---

## Default MVP Values

The first playable version should use these defaults.

- 1 second real time = 1 day game time,
- 30 days = 1 month,
- province slots = 1 to 6,
- base monthly growth = +1,
- base population cap = 30,
- one farm = +1 growth,
- one housing = +30 population cap,
- one population consumes 1 food per monthly tick,
- 10 population produces 1 gold before modifiers,
- default happiness = 10,
- below happiness 5 province may lose population or revolt,
- above happiness 15 province becomes more productive and attracts immigration,
- gold is used for army and building,
- food is used for army and population,
- gold moves upstream to the closest hub or capital,
- food moves downstream from hub or capital to the closest province that needs it,
- all movement is physical shipment only.

---

## One-Sentence Design Rule

Population grows monthly inside a local cap, food and gold exist only where they are physically stored, and the whole empire lives or dies by the capital -> hub -> province / province -> hub -> capital logistics chain.
