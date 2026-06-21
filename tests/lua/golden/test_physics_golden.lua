-- Golden test: physics compare evidence output against golden samples

-- @describe golden: physics evidence comparison
describe("golden: physics evidence comparison", function()
    it("matches physics image baselines", function()
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_gravity_drop.png",
            "tests/artifacts/baselines/physics/physics_gravity_drop.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_velocity_tracks.png",
            "tests/artifacts/baselines/physics/physics_velocity_tracks.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_collision_bands.png",
            "tests/artifacts/baselines/physics/physics_collision_bands.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_query_map.png",
            "tests/artifacts/baselines/physics/physics_query_map.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_sleep_flags.png",
            "tests/artifacts/baselines/physics/physics_sleep_flags.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_terrain_crater_raster.png",
            "tests/artifacts/baselines/physics/physics_terrain_crater_raster.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_gravity_drop_timeline_5s.gif",
            "tests/artifacts/baselines/physics/physics_gravity_drop_timeline_5s.gif"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_joint_revolute_debug.png",
            "tests/artifacts/baselines/physics/physics_joint_revolute_debug.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_joint_distance_debug.png",
            "tests/artifacts/baselines/physics/physics_joint_distance_debug.png"
        )
        expect_golden_file_match(
            evidence_output_dir("physics") .. "physics_joint_wheel_debug.png",
            "tests/artifacts/baselines/physics/physics_joint_wheel_debug.png"
        )
    end)
end)
test_summary()
