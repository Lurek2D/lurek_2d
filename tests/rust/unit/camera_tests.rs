use lurek2d::camera::Camera2D;
use lurek2d::math::Vec2;

fn assert_near(expected: f32, actual: f32) {
    assert!(
        (expected - actual).abs() < 0.001,
        "expected {expected}, got {actual}"
    );
}

#[test]
fn screen_world_round_trip_honors_viewport_offset_rotation_and_zoom() {
    let mut camera = Camera2D::new(320.0, 240.0);
    camera.set_viewport(40.0, 20.0, 320.0, 240.0);
    camera.set_position(48.0, -12.0);
    camera.set_zoom(2.5);
    camera.set_rotation(0.6);

    let (world_x, world_y) = camera.to_world_coords(180.0, 130.0);
    let (screen_x, screen_y) = camera.to_screen_coords(world_x, world_y);

    assert_near(180.0, screen_x);
    assert_near(130.0, screen_y);
}

#[test]
fn viewport_center_maps_back_to_camera_position() {
    let mut camera = Camera2D::new(200.0, 100.0);
    camera.set_viewport(100.0, 40.0, 200.0, 100.0);
    camera.set_position(10.0, 20.0);
    camera.set_rotation(0.75);

    let (world_x, world_y) = camera.to_world_coords(200.0, 90.0);
    assert_near(10.0, world_x);
    assert_near(20.0, world_y);
}

#[test]
fn visible_area_expands_for_rotation() {
    let mut camera = Camera2D::new(200.0, 100.0);
    camera.set_zoom(2.0);

    let (_, _, base_w, base_h) = camera.get_visible_area();
    camera.set_rotation(std::f32::consts::FRAC_PI_4);
    let (_, _, rotated_w, rotated_h) = camera.get_visible_area();

    assert!(rotated_w > base_w);
    assert!(rotated_h > base_h);
}

#[test]
fn bounds_clamp_uses_scaled_visible_extents() {
    let mut camera = Camera2D::new(200.0, 100.0);
    camera.set_zoom(2.0);
    camera.set_bounds(0.0, 0.0, 100.0, 100.0);
    camera.set_position(90.0, 90.0);

    camera.update(0.0);

    let (x, y) = camera.get_position();
    assert_near(50.0, x);
    assert_near(75.0, y);
}

#[test]
fn view_matrix_matches_centered_screen_coordinates() {
    let mut camera = Camera2D::new(320.0, 180.0);
    camera.set_viewport(15.0, 25.0, 320.0, 180.0);
    camera.set_position(24.0, -8.0);
    camera.set_zoom(1.75);
    camera.set_rotation(0.35);

    let world = Vec2::new(40.0, 10.0);
    let (screen_x, screen_y) = camera.to_screen_coords(world.x, world.y);
    let centered = Vec2::new(
        screen_x - (15.0 + 320.0 * 0.5),
        screen_y - (25.0 + 180.0 * 0.5),
    );
    let transformed = camera.view_matrix().transform_point(world);

    assert_near(centered.x, transformed.x);
    assert_near(centered.y, transformed.y);
}
