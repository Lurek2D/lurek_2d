use lurek2d::spine::{Bone, BoneParams, Skeleton};
use std::hint::black_box;

fn build_benchmark_skeleton() -> Skeleton {
    let mut skeleton = Skeleton::new("bench");
    let root = skeleton.add_bone(Bone::new("root"));
    let torso = skeleton.add_bone_full(BoneParams {
        name: "torso".to_string(),
        parent_index: Some(root),
        x: 4.0,
        y: 8.0,
        rotation: 0.15,
        scale_x: 1.0,
        scale_y: 1.0,
    });
    let arm = skeleton.add_bone_full(BoneParams {
        name: "arm".to_string(),
        parent_index: Some(torso),
        x: 6.0,
        y: 2.0,
        rotation: -0.2,
        scale_x: 1.0,
        scale_y: 1.0,
    });
    let _hand = skeleton.add_bone_full(BoneParams {
        name: "hand".to_string(),
        parent_index: Some(arm),
        x: 5.0,
        y: 0.0,
        rotation: 0.1,
        scale_x: 1.0,
        scale_y: 1.0,
    });
    // Seed the world pose once so the hot loop measures steady-state hierarchy updates.
    skeleton.update_world_transforms();
    skeleton
}

fn main() {
    let mut skeleton = build_benchmark_skeleton();
    for _ in 0..10_000 {
        skeleton.update_world_transforms();
        black_box(&skeleton);
    }
}