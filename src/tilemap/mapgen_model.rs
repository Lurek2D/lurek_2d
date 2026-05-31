//! Shared model types for map generation.

/// Cardinal edge of a map block, used as a side-matching key.
#[derive(Debug, Clone, Copy, Hash, PartialEq, Eq)]
pub enum Edge {
	/// Top edge of the block.
	North,
	/// Right edge of the block.
	East,
	/// Bottom edge of the block.
	South,
	/// Left edge of the block.
	West,
}

impl Edge {
	/// Parse `s` ("north", "east", "south", "west") into an `Edge`; returns `None` for unknown strings.
	#[allow(clippy::should_implement_trait)]
	pub fn from_str(s: &str) -> Option<Edge> {
		match s {
			"north" => Some(Edge::North),
			"east" => Some(Edge::East),
			"south" => Some(Edge::South),
			"west" => Some(Edge::West),
			_ => None,
		}
	}

	/// Return the lowercase string representation of this edge.
	pub fn as_str(&self) -> &'static str {
		match self {
			Edge::North => "north",
			Edge::East => "east",
			Edge::South => "south",
			Edge::West => "west",
		}
	}
}


