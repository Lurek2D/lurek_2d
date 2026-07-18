//! Internal regression tests for deterministic tile field-of-view state.

use lurek2d::awareness::TileFov;

#[test]
fn tile_fov_keeps_explored_cells_after_visibility_moves() {
    let mut fov = TileFov::new(9, 9, 3, true);
    fov.compute(2, 2, &|_, _| false);
    assert!(fov.is_visible(2, 2));
    assert!(fov.is_explored(2, 2));

    fov.compute(7, 7, &|_, _| false);
    assert!(!fov.is_visible(2, 2));
    assert!(fov.is_explored(2, 2));
}

#[test]
fn tile_fov_rejects_out_of_bounds_queries() {
    let fov = TileFov::new(4, 3, 2, false);
    assert!(!fov.is_visible(4, 0));
    assert!(!fov.is_explored(0, 3));
}

#[test]
fn tile_fov_restore_rejects_short_and_mismatched_blobs() {
    let mut fov = TileFov::new(4, 3, 2, false);
    assert!(fov.restore(&[0; 7]).is_err());

    let other = TileFov::new(5, 3, 2, false);
    assert!(fov.restore(&other.save()).is_err());
}
