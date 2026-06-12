//! LAN lobby discovery via timed UDP broadcast on a fixed port.
//! Encodes and parses lobby advertisements in a compact key-value wire format.
//! Maintains an in-process room registry for create, join, leave, and list flows.
//! Sends one broadcast datagram across all interfaces when scanning starts.
//! Deduplicates discovered lobbies by host and port during the scan window.

use std::net::{Ipv4Addr, SocketAddr, UdpSocket};
use std::sync::{Mutex, OnceLock};
use std::time::{Duration, Instant};
/// UDP port used for LAN lobby broadcast and discovery.
pub const LOBBY_PORT: u16 = 47_777;
/// Lobby advertisement received via LAN UDP broadcast.
#[derive(Debug, Clone, PartialEq)]
pub struct LobbyInfo {
    /// Human-readable lobby name set by the host.
    pub name: String,
    /// IP address or hostname string of the hosting machine.
    pub host: String,
    /// ENet port the host is listening on.
    pub port: u16,
    /// Current number of connected players.
    pub player_count: u32,
    /// Maximum players allowed before the lobby is full.
    pub max_players: u32,
}
impl LobbyInfo {
    /// Encode this `LobbyInfo` as a `key=value;...` wire string for UDP broadcast.
    pub fn to_wire(&self) -> String {
        format!(
            "name={};host={};port={};players={};max={}",
            self.name, self.host, self.port, self.player_count, self.max_players
        )
    }
    /// Parse a wire string back into a `LobbyInfo`; uses `sender` IP when `host` field is absent; returns `None` on malformed input.
    pub fn from_wire(s: &str, sender: SocketAddr) -> Option<Self> {
        let mut name = None;
        let mut host = None;
        let mut port = None;
        let mut player_count = None;
        let mut max_players = None;
        for kv in s.split(';') {
            let mut parts = kv.splitn(2, '=');
            let key = parts.next()?.trim();
            let val = parts.next()?.trim();
            match key {
                "name" => name = Some(val.to_string()),
                "host" => host = Some(val.to_string()),
                "port" => port = val.parse::<u16>().ok(),
                "players" => player_count = val.parse::<u32>().ok(),
                "max" => max_players = val.parse::<u32>().ok(),
                _ => {}
            }
        }
        Some(Self {
            name: name?,
            host: host.unwrap_or_else(|| sender.ip().to_string()),
            port: port?,
            player_count: player_count.unwrap_or(0),
            max_players: max_players.unwrap_or(0),
        })
    }
}
/// Send a single UDP broadcast on the LAN announcing `info`; returns an error string on socket failure.
pub fn broadcast_lobby(info: &LobbyInfo) -> Result<(), String> {
    let socket = UdpSocket::bind("0.0.0.0:0").map_err(|e| format!("lobby broadcast bind: {e}"))?;
    socket
        .set_broadcast(true)
        .map_err(|e| format!("lobby broadcast SO_BROADCAST: {e}"))?;
    let payload = info.to_wire();
    let addr = SocketAddr::new(Ipv4Addr::BROADCAST.into(), LOBBY_PORT);
    socket
        .send_to(payload.as_bytes(), addr)
        .map_err(|e| format!("lobby broadcast send: {e}"))?;
    Ok(())
}
/// Listen on `LOBBY_PORT` for up to `timeout_ms` (capped at 5000) ms and return all unique lobbies found.
pub fn discover_lobbies(timeout_ms: u64) -> Vec<LobbyInfo> {
    let deadline = Duration::from_millis(timeout_ms.min(5_000));
    let Ok(socket) = UdpSocket::bind(SocketAddr::new(Ipv4Addr::UNSPECIFIED.into(), LOBBY_PORT))
    else {
        return Vec::new();
    };
    if socket
        .set_read_timeout(Some(Duration::from_millis(50)))
        .is_err()
    {
        return Vec::new();
    }
    let mut results: Vec<LobbyInfo> = Vec::new();
    let start = Instant::now();
    let mut buf = [0u8; 512];
    loop {
        if start.elapsed() >= deadline {
            break;
        }
        match socket.recv_from(&mut buf) {
            Ok((len, sender)) => {
                if let Ok(s) = std::str::from_utf8(&buf[..len]) {
                    if let Some(info) = LobbyInfo::from_wire(s, sender) {
                        let key = (info.host.clone(), info.port);
                        if !results.iter().any(|r| (r.host.clone(), r.port) == key) {
                            results.push(info);
                        }
                    }
                }
            }
            Err(ref e)
                if e.kind() == std::io::ErrorKind::WouldBlock
                    || e.kind() == std::io::ErrorKind::TimedOut => {}
            Err(_) => break,
        }
    }
    results
}
/// Room advertisement stored in the in-process registry; used when a relay server is not available.
#[derive(Debug, Clone, PartialEq)]
pub struct RoomInfo {
    /// Unique room identifier assigned at creation (e.g. `"room-1"`).
    pub id: String,
    /// Human-readable room name.
    pub name: String,
    /// IP or hostname of the room host.
    pub host: String,
    /// Current number of players in the room.
    pub player_count: u32,
    /// Maximum allowed players; at least 1.
    pub max_players: u32,
}
/// Process-global in-memory store for all announced rooms.
#[derive(Debug, Default)]
struct RoomRegistry {
    /// Ordered list of all rooms created in this process.
    rooms: Vec<RoomInfo>,
}
/// Return the process-global `RoomRegistry` mutex, initialising it on first call.
fn rooms() -> &'static Mutex<RoomRegistry> {
    static REGISTRY: OnceLock<Mutex<RoomRegistry>> = OnceLock::new();
    REGISTRY.get_or_init(|| Mutex::new(RoomRegistry::default()))
}
/// Create a room entry in the global registry and return a clone of the new `RoomInfo`.
pub fn create_room(name: &str, host: &str, max_players: u32) -> RoomInfo {
    let mut reg = rooms().lock().expect("room registry poisoned");
    let id = format!("room-{}", reg.rooms.len() + 1);
    let room = RoomInfo {
        id,
        name: name.to_string(),
        host: host.to_string(),
        player_count: 1,
        max_players: max_players.max(1),
    };
    reg.rooms.push(room.clone());
    room
}
/// Return a snapshot of all rooms currently in the global registry.
pub fn list_rooms() -> Vec<RoomInfo> {
    rooms()
        .lock()
        .expect("room registry poisoned")
        .rooms
        .clone()
}
/// Increment the player count for the given room and return the updated `RoomInfo`; returns `None` when full or not found.
pub fn join_room(id: &str) -> Option<RoomInfo> {
    let mut reg = rooms().lock().expect("room registry poisoned");
    let room = reg.rooms.iter_mut().find(|r| r.id == id)?;
    if room.player_count >= room.max_players {
        return None;
    }
    room.player_count += 1;
    Some(room.clone())
}
/// Decrement the player count for the given room and return the updated `RoomInfo`; returns `None` when not found.
pub fn leave_room(id: &str) -> Option<RoomInfo> {
    let mut reg = rooms().lock().expect("room registry poisoned");
    let room = reg.rooms.iter_mut().find(|r| r.id == id)?;
    if room.player_count > 0 {
        room.player_count -= 1;
    }
    Some(room.clone())
}

/// Per-player state tracked in a room: peer_id → (name, ready).
use std::collections::HashMap;
#[derive(Debug, Clone)]
pub struct PlayerState {
    /// Display name of the player.
    pub name: String,
    /// Whether this player has marked themselves as ready.
    pub ready: bool,
}

/// Extended room tracking with per-player data and host election.
#[derive(Debug, Clone)]
pub struct RoomState {
    /// Room name.
    pub name: String,
    /// Host peer_id (0-based index of earliest joiner).
    pub host_peer: u32,
    /// Map of peer_id → (name, ready).
    pub players: HashMap<u32, PlayerState>,
    /// Maximum allowed players in this room.
    pub max_players: u32,
}

/// Process-global extended room registry with player state tracking.
#[derive(Debug, Default)]
struct ExtendedRoomRegistry {
    /// Map of room_name → RoomState.
    rooms: HashMap<String, RoomState>,
}

/// Return the process-global extended room registry, initializing on first call.
fn extended_rooms() -> &'static Mutex<ExtendedRoomRegistry> {
    static EXT_REGISTRY: OnceLock<Mutex<ExtendedRoomRegistry>> = OnceLock::new();
    EXT_REGISTRY.get_or_init(|| Mutex::new(ExtendedRoomRegistry::default()))
}

/// Mark a player as ready or not ready in a room. Creates room if it doesn't exist.
pub fn set_player_ready(room_name: &str, peer_id: u32, ready: bool) {
    let mut reg = extended_rooms()
        .lock()
        .expect("extended room registry poisoned");
    let room = reg
        .rooms
        .entry(room_name.to_string())
        .or_insert_with(|| RoomState {
            name: room_name.to_string(),
            host_peer: peer_id,
            players: HashMap::new(),
            max_players: 8,
        });

    if let Some(player) = room.players.get_mut(&peer_id) {
        player.ready = ready;
    } else {
        room.players.insert(
            peer_id,
            PlayerState {
                name: format!("Player{}", peer_id),
                ready,
            },
        );
        // Re-elect host: earliest peer_id becomes host if current host is gone
        if !room.players.contains_key(&room.host_peer) {
            if let Some(&min_peer) = room.players.keys().min() {
                room.host_peer = min_peer;
            }
        }
    }
}

/// Check if all players in a room are ready. Requires at least 2 players.
pub fn is_all_ready(room_name: &str) -> bool {
    let reg = extended_rooms()
        .lock()
        .expect("extended room registry poisoned");
    if let Some(room) = reg.rooms.get(room_name) {
        if room.players.len() < 2 {
            return false;
        }
        room.players.values().all(|p| p.ready)
    } else {
        false
    }
}

/// Get room state as a cloned RoomState; returns None if room doesn't exist.
pub fn get_room_state(room_name: &str) -> Option<RoomState> {
    let reg = extended_rooms()
        .lock()
        .expect("extended room registry poisoned");
    reg.rooms.get(room_name).cloned()
}

/// Get list of player peer_ids in a room.
pub fn get_player_list(room_name: &str) -> Vec<u32> {
    let reg = extended_rooms()
        .lock()
        .expect("extended room registry poisoned");
    if let Some(room) = reg.rooms.get(room_name) {
        let mut peers: Vec<u32> = room.players.keys().copied().collect();
        peers.sort();
        peers
    } else {
        Vec::new()
    }
}
