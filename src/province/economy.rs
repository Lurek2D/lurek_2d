//! - Province economy domain model with local-only stockpiles (population, food, gold).
//! - Monthly economy tick: food consumption, local upkeep, growth, happiness pressure, and tax.
//! - Daily logistics planning: upstream gold, downstream food, and physical shipment movement.
//! - No hidden empire-wide pool; all launches require cargo present at the origin node.

use crate::province::types::ProvinceId;
use std::collections::{HashMap, VecDeque};

/// Resource kind moved by logistics shipments.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum ShipmentResource {
    /// Food cargo used by population and army monthly consumption.
    Food,
    /// Gold cargo used for upkeep and local spending.
    Gold,
}

/// Logistics role of a province node.
#[derive(Debug, Clone, Copy, PartialEq, Eq)]
pub enum LogisticsRole {
    /// Main strategic center and terminal market node.
    Capital,
    /// Regional redistribution center.
    Hub,
    /// Standard local province node.
    Province,
}

/// Local economy state for one province.
#[derive(Debug, Clone)]
pub struct ProvinceEconomyState {
    /// Province id.
    pub id: ProvinceId,
    /// Logistics role.
    pub role: LogisticsRole,
    /// Selected upstream logistics parent.
    pub logistics_parent: Option<ProvinceId>,
    /// Current population.
    pub population: u32,
    /// Population cap.
    pub population_cap: u32,
    /// Local happiness score in range 0..20.
    pub happiness: i32,
    /// Number of farm buildings (+1 monthly growth each).
    pub farm_count: u32,
    /// Number of housing buildings (+30 cap each).
    pub housing_count: u32,
    /// Local food reserve.
    pub food_stockpile: u32,
    /// Local gold reserve.
    pub gold_stockpile: u32,
    /// Local army monthly food demand.
    pub army_food_need: u32,
    /// Local army monthly gold upkeep demand.
    pub army_gold_need: u32,
    /// Planned construction monthly food demand.
    pub planned_build_food_need: u32,
    /// Planned construction monthly gold demand.
    pub planned_build_gold_need: u32,
    /// Tax policy multiplier.
    pub tax_level_multiplier: f32,
    /// Building-derived tax multiplier.
    pub tax_building_multiplier: f32,
    /// Province-specific productivity multiplier.
    pub province_multiplier: f32,
}

impl ProvinceEconomyState {
    /// Create a basic province economy state with conservative defaults.
    pub fn new(id: ProvinceId, role: LogisticsRole) -> Self {
        Self {
            id,
            role,
            logistics_parent: None,
            population: 10,
            population_cap: 30,
            happiness: 10,
            farm_count: 0,
            housing_count: 0,
            food_stockpile: 0,
            gold_stockpile: 0,
            army_food_need: 0,
            army_gold_need: 0,
            planned_build_food_need: 0,
            planned_build_gold_need: 0,
            tax_level_multiplier: 1.0,
            tax_building_multiplier: 1.0,
            province_multiplier: 1.0,
        }
    }
}

/// Tunable constants for monthly economy resolution.
#[derive(Debug, Clone)]
pub struct MonthlyEconomyConfig {
    /// Baseline growth added before farm modifiers.
    pub base_monthly_growth: u32,
}

impl Default for MonthlyEconomyConfig {
    fn default() -> Self {
        Self {
            base_monthly_growth: 1,
        }
    }
}

/// Tunable constants for daily logistics planning.
#[derive(Debug, Clone)]
pub struct LogisticsConfig {
    /// Desired reserve horizon in months for food safety.
    pub reserve_months: u32,
    /// Gold reserve kept local before dispatch upstream.
    pub local_gold_reserve: u32,
    /// Maximum per-order food shipment size.
    pub max_daily_food_shipment: u32,
    /// Maximum per-order gold shipment size.
    pub max_daily_gold_shipment: u32,
}

impl Default for LogisticsConfig {
    fn default() -> Self {
        Self {
            reserve_months: 2,
            local_gold_reserve: 5,
            max_daily_food_shipment: 50,
            max_daily_gold_shipment: 50,
        }
    }
}

/// Output of one monthly province resolution.
#[derive(Debug, Clone)]
pub struct MonthlyEconomyReport {
    /// Province id.
    pub province_id: ProvinceId,
    /// Population before this tick.
    pub population_before: u32,
    /// Population after this tick.
    pub population_after: u32,
    /// Food consumed this month.
    pub consumed_food: u32,
    /// Population deaths from food shortage.
    pub starvation_deaths: u32,
    /// Emigration pressure losses from prolonged instability.
    pub emigration: u32,
    /// Gold paid locally for upkeep/build obligations.
    pub upkeep_gold_paid: u32,
    /// Unpaid local upkeep/build obligations.
    pub upkeep_gold_missing: u32,
    /// Population growth applied this month.
    pub natural_growth: u32,
    /// Gold generated from local taxes.
    pub tax_generated: u32,
    /// Happiness delta applied this tick.
    pub happiness_delta: i32,
}

/// Shipment launch order created by daily planner.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ShipmentOrder {
    /// Cargo kind.
    pub resource: ShipmentResource,
    /// Origin province id.
    pub from: ProvinceId,
    /// Destination province id.
    pub to: ProvinceId,
    /// Cargo amount.
    pub amount: u32,
    /// Travel duration in days.
    pub eta_days: u32,
}

/// In-transit shipment that carries real cargo until delivery.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ActiveShipment {
    /// Cargo kind.
    pub resource: ShipmentResource,
    /// Origin province id.
    pub from: ProvinceId,
    /// Destination province id.
    pub to: ProvinceId,
    /// Cargo amount.
    pub amount: u32,
    /// Remaining travel time in days.
    pub days_remaining: u32,
}

/// Returns monthly food need generated by population only.
pub fn population_food_need(population: u32) -> u32 {
    population
}

/// Returns full monthly food need including army demand.
pub fn monthly_food_need(state: &ProvinceEconomyState) -> u32 {
    population_food_need(state.population).saturating_add(state.army_food_need)
}

/// Returns base tax output using 10 population => 1 gold.
pub fn base_tax_gold(population: u32) -> u32 {
    population / 10
}

/// Returns happiness-driven productivity multiplier.
pub fn happiness_productivity_multiplier(happiness: i32) -> f32 {
    if happiness < 5 {
        0.75
    } else if happiness >= 15 {
        1.25
    } else {
        1.0
    }
}

/// Returns monthly effective tax gold from local multipliers.
pub fn effective_tax_gold(state: &ProvinceEconomyState) -> u32 {
    let raw = base_tax_gold(state.population) as f32
        * state.tax_level_multiplier.max(0.0)
        * state.tax_building_multiplier.max(0.0)
        * state.province_multiplier.max(0.0)
        * happiness_productivity_multiplier(state.happiness);
    raw.floor().max(0.0) as u32
}

/// Returns cap from base + housing.
pub fn computed_population_cap(state: &ProvinceEconomyState) -> u32 {
    30_u32.saturating_add(state.housing_count.saturating_mul(30))
}

/// Returns natural monthly growth without starvation/emigration penalties.
pub fn natural_growth(state: &ProvinceEconomyState, cfg: &MonthlyEconomyConfig) -> u32 {
    let growth_value = cfg.base_monthly_growth.saturating_add(state.farm_count);
    let cap = computed_population_cap(state).max(state.population_cap);
    let free_space = cap.saturating_sub(state.population);
    growth_value.min(free_space)
}

/// Returns migration pressure score from local instability.
pub fn migration_pressure(state: &ProvinceEconomyState, starvation_deaths: u32) -> u32 {
    let mut pressure = 0_u32;
    if state.happiness < 5 {
        pressure = pressure.saturating_add((5 - state.happiness) as u32);
    }
    pressure.saturating_add(starvation_deaths)
}

/// Returns dispatchable upstream gold after keeping mandatory local reserve.
pub fn dispatchable_gold(state: &ProvinceEconomyState, local_gold_reserve: u32) -> u32 {
    state
        .gold_stockpile
        .saturating_sub(local_gold_reserve)
        .saturating_sub(state.army_gold_need)
        .saturating_sub(state.planned_build_gold_need)
}

/// Returns local food deficit to hit target reserve months.
pub fn food_deficit(state: &ProvinceEconomyState, reserve_months: u32) -> u32 {
    let target = monthly_food_need(state).saturating_mul(reserve_months);
    target.saturating_sub(state.food_stockpile)
}

/// Resolve one monthly local-economy tick for a single province.
pub fn resolve_monthly_tick(
    state: &mut ProvinceEconomyState,
    cfg: &MonthlyEconomyConfig,
) -> MonthlyEconomyReport {
    let population_before = state.population;

    let pop_food_need = population_food_need(population_before);
    let full_food_need = pop_food_need
        .saturating_add(state.army_food_need)
        .saturating_add(state.planned_build_food_need);
    let consumed_food = state.food_stockpile.min(full_food_need);
    state.food_stockpile = state.food_stockpile.saturating_sub(consumed_food);

    let pop_food_consumed = consumed_food.min(pop_food_need);
    let starvation_deaths = pop_food_need.saturating_sub(pop_food_consumed).min(state.population);

    let upkeep_need = state
        .army_gold_need
        .saturating_add(state.planned_build_gold_need);
    let upkeep_gold_paid = state.gold_stockpile.min(upkeep_need);
    state.gold_stockpile = state.gold_stockpile.saturating_sub(upkeep_gold_paid);
    let upkeep_gold_missing = upkeep_need.saturating_sub(upkeep_gold_paid);

    let mut happiness_delta = 0_i32;
    if starvation_deaths > 0 {
        happiness_delta -= 3;
    } else {
        happiness_delta += 1;
    }
    if upkeep_gold_missing > 0 {
        happiness_delta -= 2;
    }
    if state.tax_level_multiplier > 1.2 {
        happiness_delta -= 1;
    }

    state.happiness = (state.happiness + happiness_delta).clamp(0, 20);

    let base_growth = if starvation_deaths == 0 && state.happiness >= 5 {
        natural_growth(state, cfg)
    } else {
        0
    };

    let pressure = migration_pressure(state, starvation_deaths);
    let emigration = if pressure == 0 {
        0
    } else {
        (pressure / 5).max(1).min(state.population)
    };

    state.population = state
        .population
        .saturating_add(base_growth)
        .saturating_sub(starvation_deaths)
        .saturating_sub(emigration)
        .min(computed_population_cap(state).max(state.population_cap));

    let tax_generated = effective_tax_gold(state);
    state.gold_stockpile = state.gold_stockpile.saturating_add(tax_generated);

    MonthlyEconomyReport {
        province_id: state.id,
        population_before,
        population_after: state.population,
        consumed_food,
        starvation_deaths,
        emigration,
        upkeep_gold_paid,
        upkeep_gold_missing,
        natural_growth: base_growth,
        tax_generated,
        happiness_delta,
    }
}

/// Resolve one monthly tick for all provinces, sorted by province id.
pub fn resolve_monthly_for_all(
    states: &mut HashMap<ProvinceId, ProvinceEconomyState>,
    cfg: &MonthlyEconomyConfig,
) -> Vec<MonthlyEconomyReport> {
    let mut ids: Vec<ProvinceId> = states.keys().copied().collect();
    ids.sort_unstable();
    ids.into_iter()
        .filter_map(|id| states.get_mut(&id).map(|s| resolve_monthly_tick(s, cfg)))
        .collect()
}

fn build_adjacency(adjacency_pairs: &[(ProvinceId, ProvinceId)]) -> HashMap<ProvinceId, Vec<ProvinceId>> {
    let mut adjacency: HashMap<ProvinceId, Vec<ProvinceId>> = HashMap::new();
    for &(a, b) in adjacency_pairs {
        if a == b {
            continue;
        }
        adjacency.entry(a).or_default().push(b);
        adjacency.entry(b).or_default().push(a);
    }
    for neighbors in adjacency.values_mut() {
        neighbors.sort_unstable();
        neighbors.dedup();
    }
    adjacency
}

fn shortest_path_len(
    adjacency: &HashMap<ProvinceId, Vec<ProvinceId>>,
    start: ProvinceId,
    target: ProvinceId,
) -> Option<u32> {
    if start == target {
        return Some(0);
    }
    let mut q: VecDeque<(ProvinceId, u32)> = VecDeque::new();
    let mut seen: HashMap<ProvinceId, bool> = HashMap::new();
    q.push_back((start, 0));
    seen.insert(start, true);
    while let Some((cur, d)) = q.pop_front() {
        if let Some(neighbors) = adjacency.get(&cur) {
            for &n in neighbors {
                if seen.contains_key(&n) {
                    continue;
                }
                if n == target {
                    return Some(d + 1);
                }
                seen.insert(n, true);
                q.push_back((n, d + 1));
            }
        }
    }
    None
}

/// Assign nearest logistics parent for province/hub nodes using adjacency shortest-path distance.
pub fn assign_logistics_parents(
    states: &mut HashMap<ProvinceId, ProvinceEconomyState>,
    adjacency_pairs: &[(ProvinceId, ProvinceId)],
) {
    let adjacency = build_adjacency(adjacency_pairs);
    let hubs_or_capitals: Vec<ProvinceId> = states
        .values()
        .filter(|s| matches!(s.role, LogisticsRole::Hub | LogisticsRole::Capital))
        .map(|s| s.id)
        .collect();
    let capitals: Vec<ProvinceId> = states
        .values()
        .filter(|s| s.role == LogisticsRole::Capital)
        .map(|s| s.id)
        .collect();

    let mut ids: Vec<ProvinceId> = states.keys().copied().collect();
    ids.sort_unstable();

    for id in ids {
        let Some(state) = states.get_mut(&id) else {
            continue;
        };
        let candidates: &[ProvinceId] = match state.role {
            LogisticsRole::Capital => &[],
            LogisticsRole::Hub => &capitals,
            LogisticsRole::Province => &hubs_or_capitals,
        };
        let mut best: Option<(u32, ProvinceId)> = None;
        for &target in candidates {
            if target == id {
                continue;
            }
            if let Some(dist) = shortest_path_len(&adjacency, id, target) {
                match best {
                    None => best = Some((dist, target)),
                    Some((best_dist, best_id)) => {
                        if dist < best_dist || (dist == best_dist && target < best_id) {
                            best = Some((dist, target));
                        }
                    }
                }
            }
        }
        state.logistics_parent = best.map(|(_, parent)| parent);
    }
}

fn route_eta_days(
    adjacency: &HashMap<ProvinceId, Vec<ProvinceId>>,
    from: ProvinceId,
    to: ProvinceId,
) -> u32 {
    shortest_path_len(adjacency, from, to).unwrap_or(1).max(1)
}

/// Plan and launch daily shipments; deduct origin cargo immediately and return launched orders.
pub fn launch_daily_shipments(
    states: &mut HashMap<ProvinceId, ProvinceEconomyState>,
    adjacency_pairs: &[(ProvinceId, ProvinceId)],
    cfg: &LogisticsConfig,
) -> Vec<ShipmentOrder> {
    let adjacency = build_adjacency(adjacency_pairs);
    let mut orders: Vec<ShipmentOrder> = Vec::new();

    let mut ids: Vec<ProvinceId> = states.keys().copied().collect();
    ids.sort_unstable();

    // Upstream gold: province/hub -> parent.
    for id in &ids {
        let Some(state_snapshot) = states.get(id).cloned() else {
            continue;
        };
        let Some(parent) = state_snapshot.logistics_parent else {
            continue;
        };
        let candidate = dispatchable_gold(&state_snapshot, cfg.local_gold_reserve)
            .min(cfg.max_daily_gold_shipment);
        if candidate == 0 {
            continue;
        }
        let Some(origin) = states.get_mut(id) else {
            continue;
        };
        if origin.gold_stockpile < candidate {
            continue;
        }
        origin.gold_stockpile -= candidate;
        orders.push(ShipmentOrder {
            resource: ShipmentResource::Gold,
            from: *id,
            to: parent,
            amount: candidate,
            eta_days: route_eta_days(&adjacency, *id, parent),
        });
    }

    // Downstream food: parent -> province when below reserve target.
    let mut food_candidates: Vec<(ProvinceId, ProvinceId, u32)> = Vec::new();
    for id in &ids {
        let Some(state_snapshot) = states.get(id).cloned() else {
            continue;
        };
        if state_snapshot.role != LogisticsRole::Province {
            continue;
        }
        let Some(parent) = state_snapshot.logistics_parent else {
            continue;
        };
        let deficit = food_deficit(&state_snapshot, cfg.reserve_months)
            .min(cfg.max_daily_food_shipment);
        if deficit == 0 {
            continue;
        }
        food_candidates.push((parent, *id, deficit));
    }

    for (parent, child, deficit) in food_candidates {
        let Some(parent_snapshot) = states.get(&parent).cloned() else {
            continue;
        };
        let parent_need = monthly_food_need(&parent_snapshot).saturating_mul(cfg.reserve_months);
        let parent_surplus = parent_snapshot.food_stockpile.saturating_sub(parent_need);
        let amount = deficit.min(parent_surplus);
        if amount == 0 {
            continue;
        }

        let Some(parent_state) = states.get_mut(&parent) else {
            continue;
        };
        if parent_state.food_stockpile < amount {
            continue;
        }
        parent_state.food_stockpile -= amount;

        orders.push(ShipmentOrder {
            resource: ShipmentResource::Food,
            from: parent,
            to: child,
            amount,
            eta_days: route_eta_days(&adjacency, parent, child),
        });
    }

    orders
}

/// Convert launch orders into in-transit shipments.
pub fn to_active_shipments(orders: &[ShipmentOrder]) -> Vec<ActiveShipment> {
    orders
        .iter()
        .map(|o| ActiveShipment {
            resource: o.resource,
            from: o.from,
            to: o.to,
            amount: o.amount,
            days_remaining: o.eta_days.max(1),
        })
        .collect()
}

/// Advance all active shipments by one day and deliver arrived cargo to destination stockpiles.
pub fn advance_shipments_one_day(
    states: &mut HashMap<ProvinceId, ProvinceEconomyState>,
    active: &mut Vec<ActiveShipment>,
) {
    for shipment in active.iter_mut() {
        shipment.days_remaining = shipment.days_remaining.saturating_sub(1);
    }

    let mut delivered: Vec<ActiveShipment> = Vec::new();
    let mut pending: Vec<ActiveShipment> = Vec::with_capacity(active.len());
    for shipment in active.drain(..) {
        if shipment.days_remaining == 0 {
            delivered.push(shipment);
        } else {
            pending.push(shipment);
        }
    }

    for shipment in delivered {
        if let Some(dst) = states.get_mut(&shipment.to) {
            match shipment.resource {
                ShipmentResource::Food => {
                    dst.food_stockpile = dst.food_stockpile.saturating_add(shipment.amount)
                }
                ShipmentResource::Gold => {
                    dst.gold_stockpile = dst.gold_stockpile.saturating_add(shipment.amount)
                }
            }
        }
    }

    *active = pending;
}
