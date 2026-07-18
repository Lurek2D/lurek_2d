//! Internal regression tests for tile-light storage validation.

use lurek2d::tilefield::TileTopology;
use lurek2d::tilelight::TileLightMap;

#[test]
fn tilelight_validates_dimensions_and_reports_exact_size() {
    assert!(TileLightMap::new(0, 4, 1, TileTopology::Square).is_err());
    let map = TileLightMap::new(8, 6, 2, TileTopology::Square).unwrap();
    assert_eq!(map.size(), (8, 6, 2));
}
