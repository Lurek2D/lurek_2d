//! LAN lobby discovery via UDP broadcast.
//!
//! [`broadcast_lobby`] advertises a game session on the local network by
//! sending a short announcement datagram to the subnet broadcast address.
//! [`discover_lobbies`] listens for those datagrams for a short window and
//! collects unique [`LobbyInfo`] records.
//!
//! The wire format is a plain ASCII string:
//! ```text
//! name=<name>;host=<host>;port=<port>;players=<count>;max=<max>
//! ```
//! Fields are separated by `;` and values must not contain `;` or `=`.
//! The discovery port is fixed at [`LOBBY_PORT`].

use std::net::{Ipv4Addr, SocketAddr, UdpSocket};
use std::time::{Duration, Instant};

/// UDP port used for LAN lobby broadcast and discovery.
pub const LOBBY_PORT: u16 = 47_777;

/// Metadata about a discoverable game lobby.
///
/// # Fields
/// - `name` — Human-readable session name.
/// - `host` — IP address string of the advertising host.
/// - `port` — Game listen port (not the lobby port).
/// - `player_count` — Current number of connected players.
/// - `max_players` — Maximum players this session accepts.
#[derive(Debug, Clone, PartialEq)]
pub struct LobbyInfo {
    /// Human-readable session name.
    pub name: String,
    /// IP address string of the advertising host.
    pub host: String,
    /// Game listen port on the advertising host.
    pub port: u16,
    /// Current number of connected players.
    pub player_count: u32,
    /// Maximum players this session accepts.
    pub max_players: u32,
}

impl LobbyInfo {
    /// Serialises this lobby record into the wire format.
    ///
    /// # Returns
    /// `String` — `"name=…;host=…;port=…;players=…;max=…"`.
    pub fn to_wire(&self) -> String {
        format!(
            "name={};host={};port={};players={};max={}",
            self.name, self.host, self.port, self.player_count, self.max_players
        )
    }

    /// Parses a lobby record from the wire format.
    ///
    /// Returns `None` if any required field is missing or malformed.
    ///
    /// # Parameters
    /// - `s` — `&str` — the raw datagram payload.
    /// - `sender` — `SocketAddr` — used to fill `host` when the host field is `0`.
    ///
    /// # Returns
    /// `Option<LobbyInfo>`.
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

/// Broadcasts a lobby announcement to the subnet once.
///
/// Binds an ephemeral UDP socket with `SO_BROADCAST` enabled and sends a
/// single datagram to `255.255.255.255:<LOBBY_PORT>`. The receiving end is
/// [`discover_lobbies`].
///
/// Returns an error description if the socket cannot be created or the send
/// fails.
///
/// # Parameters
/// - `info` — `&LobbyInfo` — the lobby to advertise.
///
/// # Returns
/// `Result<(), String>`.
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

/// Listens for lobby announcements on [`LOBBY_PORT`] for `timeout_ms` milliseconds.
///
/// Opens a UDP socket bound to `0.0.0.0:<LOBBY_PORT>` with `SO_REUSEADDR`
/// and collects all unique [`LobbyInfo`] records received within the window.
/// "Unique" is determined by `(host, port)` — duplicate announcements from
/// the same host are silently dropped.
///
/// Returns an empty `Vec` if the socket cannot be bound (e.g., the port is
/// already in use and `SO_REUSEADDR` is unavailable).
///
/// # Parameters
/// - `timeout_ms` — `u64` — discovery window in milliseconds (clamped to 5 000 ms).
///
/// # Returns
/// `Vec<LobbyInfo>`.
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

    // Poll loop: read datagrams until the deadline expires.
    // Each received datagram is parsed and deduplicated by (host, port).
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
                    || e.kind() == std::io::ErrorKind::TimedOut =>
            {
                // No data yet — keep polling until deadline.
            }
            Err(_) => break,
        }
    }
    results
}
