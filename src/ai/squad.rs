//! Owns squad-level coordination state that groups members around a leader, formation choice, and shared blackboard.
//! Defines formation semantics for line, wedge, circle, and column layouts, yielding member offsets from the leader.
//! Provides the group-coordination boundary between individual agents and higher-level formation-aware movement logic.
//! Also carries squad-local context so cooperative decisions can read shared tactical state instead of isolated tags.
//! Open this owner when formation geometry or leader-centric placement rules need to change across the whole squad.

use crate::patterns::Blackboard;
use std::cell::{Cell, RefCell};
use std::collections::hash_map::DefaultHasher;
use std::collections::HashMap;
use std::hash::{Hash, Hasher};
/// Supported squad formation shapes.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FormationType {
    /// No formation offset.
    None,
    /// Members spread horizontally around the leader.
    Line,
    /// Members stack vertically behind the leader.
    Wedge,
    /// Members orbit the leader in a circle.
    Circle,
    /// Members stack vertically behind the leader.
    Column,
}
impl FormationType {
    /// Parse a lowercase formation name; unknown strings map to `None`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "line" => Self::Line,
            "wedge" => Self::Wedge,
            "circle" => Self::Circle,
            "column" => Self::Column,
            _ => Self::None,
        }
    }
    /// Return the canonical lowercase formation name.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::None => "none",
            Self::Line => "line",
            Self::Wedge => "wedge",
            Self::Circle => "circle",
            Self::Column => "column",
        }
    }
}
/// Member ordering strategy used when assigning members to formation slots.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FormationSortMode {
    /// Keep the roster order exactly as stored on the squad.
    Roster,
    /// Reorder members by spatial heuristics to reduce crossing during assignment.
    Distance,
}
impl FormationSortMode {
    /// Parse a lowercase sort mode; unknown strings map to `Roster`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "distance" => Self::Distance,
            _ => Self::Roster,
        }
    }
    /// Return the canonical lowercase sort mode name.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Roster => "roster",
            Self::Distance => "distance",
        }
    }
}
/// Fallback strategy used when a formation is wider than an available lane.
#[derive(Debug, Clone, PartialEq, Eq)]
pub enum FormationFallbackMode {
    /// Keep the requested formation even when the lane is too narrow.
    Keep,
    /// Switch to a column when the requested formation exceeds lane width.
    Column,
}
impl FormationFallbackMode {
    /// Parse a lowercase fallback mode; unknown strings map to `Keep`.
    pub fn parse_str(s: &str) -> Self {
        match s {
            "column" => Self::Column,
            _ => Self::Keep,
        }
    }
    /// Return the canonical lowercase fallback mode name.
    pub fn as_str(&self) -> &'static str {
        match self {
            Self::Keep => "keep",
            Self::Column => "column",
        }
    }
}
/// Footprint and subgroup metadata stored for one squad member name.
#[derive(Debug, Clone, PartialEq)]
pub struct SquadMemberProfile {
    /// Footprint width in grid-style cells or logical slot units.
    pub footprint_w: u32,
    /// Footprint height in grid-style cells or logical slot units.
    pub footprint_h: u32,
    /// Optional subgroup label used to keep nearby members clustered together.
    pub subgroup: Option<String>,
    /// Optional tactical role label such as `assault`, `support`, or `builder`.
    pub role: Option<String>,
    /// Weapon range hint in world units used by RTS order planners.
    pub weapon_range: f32,
    /// Optional speed-class label used by higher-level movement grouping.
    pub speed_class: Option<String>,
}
impl Default for SquadMemberProfile {
    fn default() -> Self {
        Self {
            footprint_w: 1,
            footprint_h: 1,
            subgroup: None,
            role: None,
            weapon_range: 0.0,
            speed_class: None,
        }
    }
}
/// One resolved formation slot assignment for a squad member.
#[derive(Debug, Clone, PartialEq)]
pub struct FormationSlotAssignment {
    /// Member name occupying this slot.
    pub member: String,
    /// Zero-based slot index in the resolved assignment order.
    pub slot_index: usize,
    /// World-space X position of the slot center.
    pub x: f32,
    /// World-space Y position of the slot center.
    pub y: f32,
    /// Formation row index used for debugging and slot grouping.
    pub row: i32,
    /// Formation column index used for debugging and slot grouping.
    pub col: i32,
    /// Footprint width associated with the assigned member.
    pub footprint_w: u32,
    /// Footprint height associated with the assigned member.
    pub footprint_h: u32,
    /// Optional subgroup label copied from the assigned member profile.
    pub subgroup: Option<String>,
}
/// Summary of one resolved formation layout request.
#[derive(Debug, Clone, PartialEq)]
pub struct FormationLayout {
    /// Requested formation before fallback policy is applied.
    pub requested_formation: FormationType,
    /// Active formation after fallback policy is applied.
    pub active_formation: FormationType,
    /// Whether a fallback policy changed the requested formation.
    pub fallback_applied: bool,
    /// Approximate layout width in world units.
    pub width: f32,
    /// Approximate layout height in world units.
    pub height: f32,
    /// Ordered slot assignments for every squad member.
    pub slots: Vec<FormationSlotAssignment>,
}

#[derive(Debug, Clone, PartialEq)]
struct LayoutCacheKey {
    leader_x_bits: u32,
    leader_y_bits: u32,
    lane_width_bits: Option<u32>,
    formation: FormationType,
    spacing_bits: u32,
    sort_mode: FormationSortMode,
    fallback_mode: FormationFallbackMode,
    preserve_subgroups: bool,
    members: Vec<String>,
    profiles: Vec<SquadMemberProfile>,
    positions: Option<Vec<Option<(u32, u32)>>>,
}

#[derive(Debug, Clone, PartialEq)]
struct CachedFormationLayout {
    key: LayoutCacheKey,
    layout: FormationLayout,
}
/// Squad membership, formation state, and local blackboard.
pub struct Squad {
    /// Squad name.
    pub name: String,
    /// Member names in formation order.
    pub members: Vec<String>,
    /// Optional leader name.
    pub leader: Option<String>,
    /// Selected formation type.
    pub formation: FormationType,
    /// Distance between adjacent members in pixels.
    pub formation_spacing: f32,
    /// Member ordering strategy used during slot assignment.
    pub sort_mode: FormationSortMode,
    /// Fallback strategy used when a formation exceeds an available lane width.
    pub fallback_mode: FormationFallbackMode,
    /// Whether subgroup labels should remain clustered during assignment.
    pub preserve_subgroups: bool,
    /// Optional footprint and subgroup metadata per member name.
    pub member_profiles: HashMap<String, SquadMemberProfile>,
    /// Squad-local blackboard.
    pub blackboard: Blackboard,
    layout_cache: RefCell<Option<CachedFormationLayout>>,
    layout_cache_hits: Cell<u64>,
    layout_cache_misses: Cell<u64>,
    path_request_version: Cell<u64>,
}
impl Squad {
    /// Create an empty squad with default spacing.
    pub fn new(name: &str) -> Self {
        Self {
            name: name.to_string(),
            members: Vec::new(),
            leader: None,
            formation: FormationType::None,
            formation_spacing: 30.0,
            sort_mode: FormationSortMode::Roster,
            fallback_mode: FormationFallbackMode::Keep,
            preserve_subgroups: false,
            member_profiles: HashMap::new(),
            blackboard: Blackboard::default(),
            layout_cache: RefCell::new(None),
            layout_cache_hits: Cell::new(0),
            layout_cache_misses: Cell::new(0),
            path_request_version: Cell::new(0),
        }
    }
    /// Append a member name to the squad member list.
    pub fn add_member(&mut self, name: &str) {
        self.members.push(name.to_string());
    }
    /// Remove every occurrence of one member name and return the number of removed entries.
    pub fn remove_member(&mut self, name: &str) -> usize {
        let before = self.members.len();
        self.members.retain(|member| member != name);
        before.saturating_sub(self.members.len())
    }
    /// Set the squad leader name, or clear it when `None`.
    pub fn set_leader(&mut self, name: Option<String>) {
        self.leader = name;
    }
    /// Set the squad formation type and optionally update spacing.
    pub fn set_formation(&mut self, formation: FormationType, spacing: Option<f32>) {
        self.formation = formation;
        if let Some(spacing) = spacing {
            self.formation_spacing = spacing.max(0.0);
        }
    }
    /// Set slot-assignment behavior knobs used during layout planning.
    pub fn set_formation_behavior(
        &mut self,
        sort_mode: FormationSortMode,
        fallback_mode: FormationFallbackMode,
        preserve_subgroups: bool,
    ) {
        self.sort_mode = sort_mode;
        self.fallback_mode = fallback_mode;
        self.preserve_subgroups = preserve_subgroups;
    }
    /// Store footprint and subgroup metadata for one member name.
    pub fn set_member_profile(&mut self, name: &str, profile: SquadMemberProfile) {
        self.member_profiles.insert(name.to_string(), profile);
    }
    /// Return the stored profile for one member name, or the default profile when unset.
    pub fn member_profile(&self, name: &str) -> SquadMemberProfile {
        self.member_profiles.get(name).cloned().unwrap_or_default()
    }
    /// Return the target position for one member relative to a leader position.
    pub fn get_formation_position(&self, member_idx: usize, leader_pos: (f32, f32)) -> (f32, f32) {
        let spacing = self.formation_spacing;
        match self.formation {
            FormationType::None => leader_pos,
            FormationType::Line => {
                let offset =
                    (member_idx as f32 - (self.members.len() as f32 - 1.0) / 2.0) * spacing;
                (leader_pos.0 + offset, leader_pos.1)
            }
            FormationType::Column => {
                let offset = member_idx as f32 * spacing;
                (leader_pos.0, leader_pos.1 + offset)
            }
            FormationType::Wedge => {
                if member_idx == 0 {
                    return leader_pos;
                }
                let row = member_idx.div_ceil(2);
                let side = if member_idx % 2 == 1 { -1.0f32 } else { 1.0 };
                (
                    leader_pos.0 + side * row as f32 * spacing,
                    leader_pos.1 + row as f32 * spacing,
                )
            }
            FormationType::Circle => {
                if self.members.is_empty() {
                    return leader_pos;
                }
                let angle =
                    2.0 * std::f32::consts::PI * member_idx as f32 / self.members.len() as f32;
                let radius = spacing;
                (
                    leader_pos.0 + angle.cos() * radius,
                    leader_pos.1 + angle.sin() * radius,
                )
            }
        }
    }
    /// Build an ordered slot layout, optionally falling back for narrow lanes and reordering members by current positions.
    pub fn get_formation_layout(
        &self,
        leader_pos: (f32, f32),
        lane_width: Option<f32>,
        member_positions: Option<&HashMap<String, (f32, f32)>>,
    ) -> FormationLayout {
        let key = self.layout_cache_key(leader_pos, lane_width, member_positions);
        if let Some(cached) = self.layout_cache.borrow().as_ref() {
            if cached.key == key {
                self.layout_cache_hits
                    .set(self.layout_cache_hits.get().saturating_add(1));
                return cached.layout.clone();
            }
        }
        let requested_formation = self.formation.clone();
        let active_formation = self.resolve_active_formation(lane_width);
        let slots = self.build_slots(&active_formation, leader_pos);
        let assignments =
            self.assign_members_to_slots(&active_formation, slots, leader_pos, member_positions);
        let (width, height) = formation_bounds(&assignments, self.formation_spacing);
        let layout = FormationLayout {
            requested_formation: requested_formation.clone(),
            active_formation: active_formation.clone(),
            fallback_applied: requested_formation != active_formation,
            width,
            height,
            slots: assignments,
        };
        self.layout_cache_misses
            .set(self.layout_cache_misses.get().saturating_add(1));
        self.layout_cache
            .borrow_mut()
            .replace(CachedFormationLayout {
                key,
                layout: layout.clone(),
            });
        layout
    }

    /// Clear the cached formation layout and reset cache counters.
    pub fn clear_layout_cache(&self) {
        self.layout_cache.borrow_mut().take();
        self.layout_cache_hits.set(0);
        self.layout_cache_misses.set(0);
    }

    /// Return the number of cached layout hits observed on this squad.
    pub fn layout_cache_hits(&self) -> u64 {
        self.layout_cache_hits.get()
    }

    /// Return the number of cached layout misses observed on this squad.
    pub fn layout_cache_misses(&self) -> u64 {
        self.layout_cache_misses.get()
    }

    /// Increment and return the squad-local async path request version.
    pub(crate) fn next_path_request_version(&self) -> u64 {
        let next = self.path_request_version.get().saturating_add(1);
        self.path_request_version.set(next);
        next
    }

    /// Return a stable owner id derived from the squad name for path events.
    pub(crate) fn default_path_request_owner_id(&self) -> u64 {
        let mut hasher = DefaultHasher::new();
        self.name.hash(&mut hasher);
        hasher.finish()
    }

    fn layout_cache_key(
        &self,
        leader_pos: (f32, f32),
        lane_width: Option<f32>,
        member_positions: Option<&HashMap<String, (f32, f32)>>,
    ) -> LayoutCacheKey {
        LayoutCacheKey {
            leader_x_bits: leader_pos.0.to_bits(),
            leader_y_bits: leader_pos.1.to_bits(),
            lane_width_bits: lane_width.map(f32::to_bits),
            formation: self.formation.clone(),
            spacing_bits: self.formation_spacing.to_bits(),
            sort_mode: self.sort_mode.clone(),
            fallback_mode: self.fallback_mode.clone(),
            preserve_subgroups: self.preserve_subgroups,
            members: self.members.clone(),
            profiles: self
                .members
                .iter()
                .map(|member| self.member_profile(member))
                .collect(),
            positions: member_positions.map(|positions| {
                self.members
                    .iter()
                    .map(|member| {
                        positions
                            .get(member)
                            .map(|(x, y)| (x.to_bits(), y.to_bits()))
                    })
                    .collect()
            }),
        }
    }

    fn resolve_active_formation(&self, lane_width: Option<f32>) -> FormationType {
        if self.members.is_empty() || self.formation == FormationType::None {
            return self.formation.clone();
        }
        let Some(lane_width) = lane_width else {
            return self.formation.clone();
        };
        if lane_width <= 0.0 {
            return match self.fallback_mode {
                FormationFallbackMode::Column => FormationType::Column,
                FormationFallbackMode::Keep => self.formation.clone(),
            };
        }
        let horizontal_span = self.estimated_horizontal_span(&self.formation);
        if matches!(self.fallback_mode, FormationFallbackMode::Column)
            && !matches!(self.formation, FormationType::Column | FormationType::None)
            && horizontal_span > lane_width
        {
            FormationType::Column
        } else {
            self.formation.clone()
        }
    }

    fn estimated_horizontal_span(&self, formation: &FormationType) -> f32 {
        let stride_x = self.horizontal_stride();
        let count = self.members.len() as f32;
        match formation {
            FormationType::None => 0.0,
            FormationType::Line => (count.max(1.0) - 1.0) * stride_x,
            FormationType::Column => {
                self.max_footprint_w() as f32 * self.formation_spacing.max(0.0)
            }
            FormationType::Wedge => {
                let rows = if self.members.len() <= 1 {
                    0.0
                } else {
                    self.members.len().div_ceil(2) as f32
                };
                rows * stride_x * 2.0
            }
            FormationType::Circle => {
                self.formation_spacing.max(0.0) * self.max_footprint_dim() * 2.0
            }
        }
    }

    fn build_slots(
        &self,
        formation: &FormationType,
        leader_pos: (f32, f32),
    ) -> Vec<UnassignedSlot> {
        let stride_x = self.horizontal_stride();
        let stride_y = self.vertical_stride();
        let radius = self.formation_spacing.max(0.0) * self.max_footprint_dim();
        let count = self.members.len();
        (0..count)
            .map(|slot_index| match formation {
                FormationType::None => UnassignedSlot {
                    slot_index,
                    x: leader_pos.0,
                    y: leader_pos.1,
                    row: 0,
                    col: 0,
                },
                FormationType::Line => {
                    let offset = (slot_index as f32 - (count as f32 - 1.0) / 2.0) * stride_x;
                    UnassignedSlot {
                        slot_index,
                        x: leader_pos.0 + offset,
                        y: leader_pos.1,
                        row: 0,
                        col: slot_index as i32,
                    }
                }
                FormationType::Column => UnassignedSlot {
                    slot_index,
                    x: leader_pos.0,
                    y: leader_pos.1 + slot_index as f32 * stride_y,
                    row: slot_index as i32,
                    col: 0,
                },
                FormationType::Wedge => {
                    if slot_index == 0 {
                        UnassignedSlot {
                            slot_index,
                            x: leader_pos.0,
                            y: leader_pos.1,
                            row: 0,
                            col: 0,
                        }
                    } else {
                        let row = slot_index.div_ceil(2) as i32;
                        let side = if slot_index % 2 == 1 { -1.0f32 } else { 1.0 };
                        UnassignedSlot {
                            slot_index,
                            x: leader_pos.0 + side * row as f32 * stride_x,
                            y: leader_pos.1 + row as f32 * stride_y,
                            row,
                            col: if side < 0.0 { -row } else { row },
                        }
                    }
                }
                FormationType::Circle => {
                    let angle = if count == 0 {
                        0.0
                    } else {
                        2.0 * std::f32::consts::PI * slot_index as f32 / count as f32
                    };
                    UnassignedSlot {
                        slot_index,
                        x: leader_pos.0 + angle.cos() * radius,
                        y: leader_pos.1 + angle.sin() * radius,
                        row: 0,
                        col: slot_index as i32,
                    }
                }
            })
            .collect()
    }

    fn assign_members_to_slots(
        &self,
        formation: &FormationType,
        mut slots: Vec<UnassignedSlot>,
        leader_pos: (f32, f32),
        member_positions: Option<&HashMap<String, (f32, f32)>>,
    ) -> Vec<FormationSlotAssignment> {
        if self.sort_mode == FormationSortMode::Distance && member_positions.is_some() {
            slots.sort_by(|a, b| {
                slot_sort_key(formation, leader_pos, a)
                    .total_cmp(&slot_sort_key(formation, leader_pos, b))
            });
        }

        let grouped_members = self.assignment_groups(formation, leader_pos, member_positions);
        let mut assignments = Vec::with_capacity(self.members.len());
        let mut cursor = 0usize;
        for group in grouped_members {
            let end = cursor.saturating_add(group.len()).min(slots.len());
            let slot_slice = &slots[cursor..end];
            for (member_item, slot) in group.into_iter().zip(slot_slice.iter()) {
                assignments.push(FormationSlotAssignment {
                    member: member_item.name,
                    slot_index: slot.slot_index,
                    x: slot.x,
                    y: slot.y,
                    row: slot.row,
                    col: slot.col,
                    footprint_w: member_item.profile.footprint_w,
                    footprint_h: member_item.profile.footprint_h,
                    subgroup: member_item.profile.subgroup,
                });
            }
            cursor = end;
        }
        assignments.sort_by_key(|assignment| assignment.slot_index);
        assignments
    }

    fn assignment_groups(
        &self,
        formation: &FormationType,
        leader_pos: (f32, f32),
        member_positions: Option<&HashMap<String, (f32, f32)>>,
    ) -> Vec<Vec<MemberAssignmentItem>> {
        let members: Vec<MemberAssignmentItem> = self
            .members
            .iter()
            .map(|member| MemberAssignmentItem {
                name: member.clone(),
                profile: self.member_profile(member),
            })
            .collect();
        if members.is_empty() {
            return Vec::new();
        }
        if !(self.sort_mode == FormationSortMode::Distance && member_positions.is_some()) {
            if self.preserve_subgroups {
                return subgroup_blocks(members);
            }
            return vec![members];
        }

        let positions = member_positions.expect("checked above");
        if self.preserve_subgroups {
            let mut blocks = subgroup_blocks(members);
            for block in &mut blocks {
                block.sort_by(|a, b| {
                    member_sort_key(formation, leader_pos, positions.get(&a.name), a).total_cmp(
                        &member_sort_key(formation, leader_pos, positions.get(&b.name), b),
                    )
                });
            }
            blocks
        } else {
            let mut members = members;
            members.sort_by(|a, b| {
                member_sort_key(formation, leader_pos, positions.get(&a.name), a).total_cmp(
                    &member_sort_key(formation, leader_pos, positions.get(&b.name), b),
                )
            });
            vec![members]
        }
    }

    fn max_footprint_w(&self) -> u32 {
        self.member_profiles
            .values()
            .map(|profile| profile.footprint_w.max(1))
            .max()
            .unwrap_or(1)
    }

    fn max_footprint_h(&self) -> u32 {
        self.member_profiles
            .values()
            .map(|profile| profile.footprint_h.max(1))
            .max()
            .unwrap_or(1)
    }

    fn max_footprint_dim(&self) -> f32 {
        self.max_footprint_w().max(self.max_footprint_h()) as f32
    }

    fn horizontal_stride(&self) -> f32 {
        self.formation_spacing.max(0.0) * self.max_footprint_w() as f32
    }

    fn vertical_stride(&self) -> f32 {
        self.formation_spacing.max(0.0) * self.max_footprint_h() as f32
    }
}

#[derive(Debug, Clone)]
struct MemberAssignmentItem {
    name: String,
    profile: SquadMemberProfile,
}

#[derive(Debug, Clone)]
struct UnassignedSlot {
    slot_index: usize,
    x: f32,
    y: f32,
    row: i32,
    col: i32,
}

fn subgroup_blocks(members: Vec<MemberAssignmentItem>) -> Vec<Vec<MemberAssignmentItem>> {
    let mut subgroup_order: Vec<String> = Vec::new();
    let mut grouped: HashMap<String, Vec<MemberAssignmentItem>> = HashMap::new();
    let mut ungrouped: Vec<Vec<MemberAssignmentItem>> = Vec::new();
    for member in members {
        if let Some(subgroup) = member.profile.subgroup.clone() {
            if !grouped.contains_key(&subgroup) {
                subgroup_order.push(subgroup.clone());
            }
            grouped.entry(subgroup).or_default().push(member);
        } else {
            ungrouped.push(vec![member]);
        }
    }

    let mut out = Vec::new();
    for subgroup in subgroup_order {
        if let Some(block) = grouped.remove(&subgroup) {
            out.push(block);
        }
    }
    out.extend(ungrouped);
    out
}

fn member_sort_key(
    formation: &FormationType,
    leader_pos: (f32, f32),
    position: Option<&(f32, f32)>,
    member: &MemberAssignmentItem,
) -> f32 {
    let position = position.copied().unwrap_or(leader_pos);
    match formation {
        FormationType::Line => position.0,
        FormationType::Column => position.1,
        FormationType::Wedge => position.1 * 1000.0 + position.0,
        FormationType::Circle => (position.1 - leader_pos.1).atan2(position.0 - leader_pos.0),
        FormationType::None => {
            let dx = position.0 - leader_pos.0;
            let dy = position.1 - leader_pos.1;
            dx * dx + dy * dy + member.profile.footprint_w as f32 * 0.001
        }
    }
}

fn slot_sort_key(formation: &FormationType, leader_pos: (f32, f32), slot: &UnassignedSlot) -> f32 {
    match formation {
        FormationType::Line => slot.x,
        FormationType::Column => slot.y,
        FormationType::Wedge => slot.y * 1000.0 + slot.x,
        FormationType::Circle => (slot.y - leader_pos.1).atan2(slot.x - leader_pos.0),
        FormationType::None => {
            let dx = slot.x - leader_pos.0;
            let dy = slot.y - leader_pos.1;
            dx * dx + dy * dy
        }
    }
}

fn formation_bounds(assignments: &[FormationSlotAssignment], spacing: f32) -> (f32, f32) {
    if assignments.is_empty() {
        return (0.0, 0.0);
    }
    let mut min_x = f32::INFINITY;
    let mut max_x = f32::NEG_INFINITY;
    let mut min_y = f32::INFINITY;
    let mut max_y = f32::NEG_INFINITY;
    for assignment in assignments {
        let half_w = assignment.footprint_w.max(1) as f32 * spacing.max(0.0) * 0.5;
        let half_h = assignment.footprint_h.max(1) as f32 * spacing.max(0.0) * 0.5;
        min_x = min_x.min(assignment.x - half_w);
        max_x = max_x.max(assignment.x + half_w);
        min_y = min_y.min(assignment.y - half_h);
        max_y = max_y.max(assignment.y + half_h);
    }
    (max_x - min_x, max_y - min_y)
}
