//! INTERNAL ONLY: Rust-only tests for province economy and logistics internals.

use std::collections::HashMap;

use lurek2d::province::economy::{
    advance_shipments_one_day, assign_logistics_parents, base_tax_gold, dispatchable_gold,
    effective_tax_gold, food_deficit, launch_daily_shipments, monthly_food_need, natural_growth,
    population_food_need, resolve_monthly_tick, to_active_shipments, LogisticsConfig,
    LogisticsRole, MonthlyEconomyConfig, ProvinceEconomyState, ShipmentResource,
};

fn make_state(id: u32, role: LogisticsRole) -> ProvinceEconomyState {
    ProvinceEconomyState::new(id, role)
}

#[test]
fn test_economy_helper_formulas() {
    let mut s = make_state(1, LogisticsRole::Province);
    s.population = 100;
    s.population_cap = 120;
    s.farm_count = 2;
    s.housing_count = 1;
    s.happiness = 16;
    s.tax_level_multiplier = 1.0;
    s.tax_building_multiplier = 1.0;
    s.province_multiplier = 1.0;

    assert_eq!(population_food_need(s.population), 100);
    assert_eq!(monthly_food_need(&s), 100);
    assert_eq!(base_tax_gold(s.population), 10);
    assert_eq!(effective_tax_gold(&s), 12);
    assert_eq!(natural_growth(&s, &MonthlyEconomyConfig::default()), 3);
}

#[test]
fn test_monthly_tick_uses_local_stockpile_only() {
    let mut poor = make_state(1, LogisticsRole::Province);
    poor.population = 40;
    poor.food_stockpile = 0;
    poor.gold_stockpile = 0;
    poor.army_food_need = 5;
    poor.army_gold_need = 8;

    let mut rich_neighbor = make_state(2, LogisticsRole::Province);
    rich_neighbor.population = 40;
    rich_neighbor.food_stockpile = 500;
    rich_neighbor.gold_stockpile = 500;

    let report = resolve_monthly_tick(&mut poor, &MonthlyEconomyConfig::default());

    assert!(report.starvation_deaths > 0);
    assert!(report.upkeep_gold_missing > 0);
    assert!(poor.population < 40);
    assert_eq!(rich_neighbor.food_stockpile, 500);
    assert_eq!(rich_neighbor.gold_stockpile, 500);
}

#[test]
fn test_logistics_parent_prefers_nearest_hub_or_capital() {
    // 1(capital)-2(hub)-3(province)-4(province), and 4 also linked to 1.
    // Distances for 4: to 1 is 1, to 2 is 2, so parent should be 1.
    // Distances for 3: to 2 is 1, to 1 is 2, so parent should be 2.
    let mut states: HashMap<u32, ProvinceEconomyState> = HashMap::new();
    states.insert(1, make_state(1, LogisticsRole::Capital));
    states.insert(2, make_state(2, LogisticsRole::Hub));
    states.insert(3, make_state(3, LogisticsRole::Province));
    states.insert(4, make_state(4, LogisticsRole::Province));

    let adjacency = vec![(1, 2), (2, 3), (3, 4), (1, 4)];
    assign_logistics_parents(&mut states, &adjacency);

    assert_eq!(states.get(&3).and_then(|s| s.logistics_parent), Some(2));
    assert_eq!(states.get(&4).and_then(|s| s.logistics_parent), Some(1));
}

#[test]
fn test_shipment_launch_requires_real_origin_cargo() {
    let mut states: HashMap<u32, ProvinceEconomyState> = HashMap::new();

    let mut capital = make_state(1, LogisticsRole::Capital);
    capital.food_stockpile = 0;

    let mut province = make_state(2, LogisticsRole::Province);
    province.logistics_parent = Some(1);
    province.population = 30;
    province.gold_stockpile = 0;

    states.insert(1, capital);
    states.insert(2, province);

    let cfg = LogisticsConfig::default();
    let adjacency = vec![(1, 2)];
    let orders = launch_daily_shipments(&mut states, &adjacency, &cfg);
    assert!(orders.is_empty(), "no cargo means no shipment launch");

    // Now add real cargo and verify launch + origin deduction.
    states.get_mut(&1).expect("capital exists").food_stockpile = 200;
    states.get_mut(&2).expect("province exists").gold_stockpile = 120;

    let orders = launch_daily_shipments(&mut states, &adjacency, &cfg);
    assert!(!orders.is_empty());
    assert!(orders.iter().any(|o| o.resource == ShipmentResource::Gold));
    assert!(orders.iter().any(|o| o.resource == ShipmentResource::Food));

    let after_capital_food = states.get(&1).expect("capital exists").food_stockpile;
    let after_province_gold = states.get(&2).expect("province exists").gold_stockpile;
    assert!(after_capital_food < 200);
    assert!(after_province_gold < 120);
}

#[test]
fn test_daily_transport_and_monthly_economy_are_separate_steps() {
    let mut states: HashMap<u32, ProvinceEconomyState> = HashMap::new();

    let mut capital = make_state(1, LogisticsRole::Capital);
    capital.food_stockpile = 0;
    capital.gold_stockpile = 0;

    let mut province = make_state(2, LogisticsRole::Province);
    province.population = 20;
    province.food_stockpile = 100;
    province.gold_stockpile = 120;
    province.logistics_parent = Some(1);

    states.insert(1, capital);
    states.insert(2, province);

    let cfg = LogisticsConfig {
        max_daily_gold_shipment: 30,
        ..LogisticsConfig::default()
    };
    let adjacency = vec![(1, 2)];
    let orders = launch_daily_shipments(&mut states, &adjacency, &cfg);
    let mut active = to_active_shipments(&orders);

    // Shipment is in transit and not yet delivered before daily advance.
    let capital_gold_before = states.get(&1).expect("capital exists").gold_stockpile;
    assert_eq!(capital_gold_before, 0);

    // Monthly resolution does not teleport in-transit cargo.
    let _ = resolve_monthly_tick(
        states.get_mut(&1).expect("capital exists"),
        &MonthlyEconomyConfig::default(),
    );
    let capital_gold_after_monthly = states.get(&1).expect("capital exists").gold_stockpile;
    assert_eq!(capital_gold_after_monthly, 0);

    // Daily transport delivers once travel time is elapsed.
    advance_shipments_one_day(&mut states, &mut active);
    let capital_gold_after_delivery = states.get(&1).expect("capital exists").gold_stockpile;
    assert!(capital_gold_after_delivery > 0);
}

#[test]
fn test_dispatchable_and_deficit_are_local() {
    let mut state = make_state(10, LogisticsRole::Province);
    state.population = 50;
    state.food_stockpile = 20;
    state.gold_stockpile = 80;
    state.army_gold_need = 10;
    state.planned_build_gold_need = 5;

    let disp = dispatchable_gold(&state, 10);
    assert_eq!(disp, 55);

    let def = food_deficit(&state, 2);
    assert_eq!(def, 80);
}
