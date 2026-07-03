//! Owns the agent local HTTP implementation for the agent subsystem and keeps related runtime rules local here.
//! Keeps agent requests, HTTP boundaries, and service state so helpers stay close to invariants this file updates.
//! Defines how agent local HTTP data is validated, transformed, or stored before neighboring systems consume it.
//! Separates agent local HTTP behavior from Lua bindings, tests, and sibling owners so integration stays readable.
//! Documents the boundary where agent code accepts inputs, reports errors, allocates state, or emits outputs.
//! Use this file when changing agent local HTTP defaults, lifecycle handling, validation, or data ownership rules.

use std::io::{Read, Write};
use std::net::{TcpStream, ToSocketAddrs};
use std::time::Duration;

/// Error returned when a caller tries to use TLS in the runtime agent client.
pub const LOCAL_HTTP_ONLY_MESSAGE: &str = "Ollama agent runtime supports local plain HTTP only";

/// Small response type matching the fields the agent transport needs.
#[derive(Debug, Clone, Default, PartialEq, Eq)]
pub struct HttpResponse {
    /// HTTP status code, or 0 when no response was received.
    pub status: u16,
    /// Raw response body bytes.
    pub body: Vec<u8>,
    /// Parsed response headers.
    pub headers: Vec<(String, String)>,
    /// Transport or parse error when the request failed before a usable body.
    pub error: Option<String>,
}

/// Parsed HTTP URL accepted by the local agent client.
#[derive(Debug, Clone, PartialEq, Eq)]
pub struct ParsedHttpUrl {
    /// URL scheme. Only `http` is accepted.
    pub scheme: String,
    /// Host name or address.
    pub host: String,
    /// TCP port.
    pub port: u16,
    /// Request target path including query string.
    pub path: String,
}

/// Returns the host portion of an accepted HTTP URL.
pub fn endpoint_host(url: &str) -> Option<String> {
    parse_http_url(url).ok().map(|parsed| parsed.host)
}

/// Parses a narrow `http://host[:port]/path` URL.
pub fn parse_http_url(url: &str) -> Result<ParsedHttpUrl, String> {
    let (scheme, rest) = url
        .split_once("://")
        .ok_or_else(|| format!("agent URL '{}' is missing a scheme", url))?;
    let scheme = scheme.to_ascii_lowercase();
    if scheme == "https" {
        return Err(LOCAL_HTTP_ONLY_MESSAGE.to_string());
    }
    if scheme != "http" {
        return Err(format!(
            "{}: unsupported scheme '{}'",
            LOCAL_HTTP_ONLY_MESSAGE, scheme
        ));
    }

    let (authority, path) = match rest.find('/') {
        Some(index) => (&rest[..index], &rest[index..]),
        None => (rest, "/"),
    };
    if authority.is_empty() {
        return Err(format!("agent URL '{}' is missing a host", url));
    }
    if authority.contains('@') {
        return Err("agent URL userinfo is not supported".to_string());
    }

    let (host, port) = parse_authority(authority)?;
    Ok(ParsedHttpUrl {
        scheme,
        host,
        port,
        path: path.to_string(),
    })
}

/// Executes a blocking HTTP/1.1 request over plain TCP.
pub fn execute_request(
    method: &str,
    url: &str,
    headers: &[(String, String)],
    body: Option<&[u8]>,
    timeout_secs: u64,
) -> HttpResponse {
    match execute_request_inner(method, url, headers, body, timeout_secs) {
        Ok(response) => response,
        Err(error) => HttpResponse {
            status: 0,
            body: Vec::new(),
            headers: Vec::new(),
            error: Some(error),
        },
    }
}

fn execute_request_inner(
    method: &str,
    url: &str,
    headers: &[(String, String)],
    body: Option<&[u8]>,
    timeout_secs: u64,
) -> Result<HttpResponse, String> {
    let parsed = parse_http_url(url)?;
    let timeout = Duration::from_secs(timeout_secs.max(1));
    let mut stream = connect(&parsed.host, parsed.port, timeout)?;
    stream
        .set_read_timeout(Some(timeout))
        .map_err(|error| error.to_string())?;
    stream
        .set_write_timeout(Some(timeout))
        .map_err(|error| error.to_string())?;

    let body = body.unwrap_or(&[]);
    let request = build_request(method, &parsed, headers, body);
    stream
        .write_all(&request)
        .map_err(|error| error.to_string())?;
    stream.flush().map_err(|error| error.to_string())?;

    let mut bytes = Vec::new();
    stream
        .read_to_end(&mut bytes)
        .map_err(|error| error.to_string())?;
    parse_response(bytes)
}

fn parse_authority(authority: &str) -> Result<(String, u16), String> {
    if let Some(rest) = authority.strip_prefix('[') {
        let Some(end) = rest.find(']') else {
            return Err("invalid IPv6 host in agent URL".to_string());
        };
        let host = rest[..end].to_string();
        let tail = &rest[end + 1..];
        let port = if let Some(port) = tail.strip_prefix(':') {
            parse_port(port)?
        } else if tail.is_empty() {
            80
        } else {
            return Err("invalid IPv6 authority in agent URL".to_string());
        };
        return Ok((host, port));
    }

    match authority.rsplit_once(':') {
        Some((host, port)) if !host.is_empty() && port.chars().all(|ch| ch.is_ascii_digit()) => {
            Ok((host.to_string(), parse_port(port)?))
        }
        _ => Ok((authority.to_string(), 80)),
    }
}

fn parse_port(port: &str) -> Result<u16, String> {
    port.parse::<u16>()
        .map_err(|_| format!("invalid agent URL port '{}'", port))
}

fn connect(host: &str, port: u16, timeout: Duration) -> Result<TcpStream, String> {
    let addrs = (host, port)
        .to_socket_addrs()
        .map_err(|error| error.to_string())?;
    let mut last_error = None;
    for addr in addrs {
        match TcpStream::connect_timeout(&addr, timeout) {
            Ok(stream) => return Ok(stream),
            Err(error) => last_error = Some(error.to_string()),
        }
    }
    Err(last_error.unwrap_or_else(|| format!("could not resolve {}:{}", host, port)))
}

fn build_request(
    method: &str,
    parsed: &ParsedHttpUrl,
    headers: &[(String, String)],
    body: &[u8],
) -> Vec<u8> {
    let mut request = Vec::new();
    let host_header = if parsed.port == 80 {
        parsed.host.clone()
    } else if parsed.host.contains(':') {
        format!("[{}]:{}", parsed.host, parsed.port)
    } else {
        format!("{}:{}", parsed.host, parsed.port)
    };

    request.extend_from_slice(
        format!(
            "{} {} HTTP/1.1\r\nHost: {}\r\nConnection: close\r\n",
            method, parsed.path, host_header
        )
        .as_bytes(),
    );
    if !body.is_empty() {
        request.extend_from_slice(format!("Content-Length: {}\r\n", body.len()).as_bytes());
    }
    for (name, value) in headers {
        if is_builtin_header(name) {
            continue;
        }
        request.extend_from_slice(name.as_bytes());
        request.extend_from_slice(b": ");
        request.extend_from_slice(value.as_bytes());
        request.extend_from_slice(b"\r\n");
    }
    request.extend_from_slice(b"\r\n");
    request.extend_from_slice(body);
    request
}

fn is_builtin_header(name: &str) -> bool {
    name.eq_ignore_ascii_case("host")
        || name.eq_ignore_ascii_case("connection")
        || name.eq_ignore_ascii_case("content-length")
}

fn parse_response(bytes: Vec<u8>) -> Result<HttpResponse, String> {
    let Some(split) = find_header_end(&bytes) else {
        return Err("invalid HTTP response: missing header terminator".to_string());
    };
    let header_text = std::str::from_utf8(&bytes[..split]).map_err(|error| error.to_string())?;
    let mut lines = header_text.split("\r\n");
    let status_line = lines
        .next()
        .ok_or_else(|| "invalid HTTP response: missing status line".to_string())?;
    let status = status_line
        .split_whitespace()
        .nth(1)
        .ok_or_else(|| "invalid HTTP response: missing status code".to_string())?
        .parse::<u16>()
        .map_err(|error| error.to_string())?;

    let mut headers = Vec::new();
    for line in lines {
        if let Some((name, value)) = line.split_once(':') {
            headers.push((name.trim().to_string(), value.trim().to_string()));
        }
    }
    if has_chunked_encoding(&headers) {
        return Err(
            "chunked responses are not supported by the local Ollama HTTP client".to_string(),
        );
    }

    Ok(HttpResponse {
        status,
        body: bytes[split + 4..].to_vec(),
        headers,
        error: None,
    })
}

fn find_header_end(bytes: &[u8]) -> Option<usize> {
    bytes.windows(4).position(|window| window == b"\r\n\r\n")
}

fn has_chunked_encoding(headers: &[(String, String)]) -> bool {
    headers.iter().any(|(name, value)| {
        name.eq_ignore_ascii_case("transfer-encoding")
            && value
                .split(',')
                .any(|part| part.trim().eq_ignore_ascii_case("chunked"))
    })
}
