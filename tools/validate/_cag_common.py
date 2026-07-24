"""Shared discovery and parsing helpers for the active Codex CAG layer."""

from __future__ import annotations

import re
import tomllib
from pathlib import Path

WORKSPACE_ROOT = Path(__file__).resolve().parents[2]
CODEX_DIR = WORKSPACE_ROOT / ".codex"
SKILLS_DIR = CODEX_DIR / "skills"
ROLE_CONFIG_DIR = CODEX_DIR / "agents"
CODEX_CONFIG = CODEX_DIR / "config.toml"
COVERAGE_CONFIG = CODEX_DIR / "coverage.toml"
REPO_AGENT_SECTIONS = ("Mission & Scope", "Files", "Rules", "Workflow")
SKILL_SECTIONS = ("Mission", "Domain Knowledge", "Workflow", "References")
IGNORED_PARTS = {".git", "build", "dist", "target", "node_modules", "__pycache__", ".cache", ".vscode-test"}


def normalize_text(text: str) -> str:
    return text.replace("\r\n", "\n").replace("\r", "\n")


def safe_read(path: Path) -> str:
    return normalize_text(path.read_text(encoding="utf-8", errors="replace"))


def relpath(path: Path) -> str:
    try:
        return path.resolve().relative_to(WORKSPACE_ROOT.resolve()).as_posix()
    except ValueError:
        return str(path)


def discover_skills() -> list[Path]:
    if not SKILLS_DIR.exists():
        return []
    return sorted(path for path in SKILLS_DIR.glob("*/SKILL.md") if path.is_file())


def discover_repo_agents() -> list[Path]:
    return sorted(
        path for path in WORKSPACE_ROOT.rglob("AGENTS.md")
        if not any(part in IGNORED_PARTS for part in path.parts)
    )


def read_config() -> dict[str, object]:
    try:
        return tomllib.loads(safe_read(CODEX_CONFIG))
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def registered_roles() -> dict[str, dict[str, object]]:
    agents = read_config().get("agents", {})
    if not isinstance(agents, dict):
        return {}
    return {name: value for name, value in agents.items() if isinstance(value, dict)}


def discover_role_configs() -> list[Path]:
    return sorted(ROLE_CONFIG_DIR.glob("*.toml")) if ROLE_CONFIG_DIR.exists() else []


def parse_frontmatter(text: str) -> dict[str, str] | None:
    match = re.match(r"^---\n(.*?)\n---\n", text, re.DOTALL)
    if not match:
        return None
    result: dict[str, str] = {}
    for raw in match.group(1).splitlines():
        if ":" not in raw:
            continue
        key, value = raw.split(":", 1)
        result[key.strip()] = value.strip().strip('"')
    return result


def body_after_frontmatter(text: str) -> str:
    match = re.match(r"^---\n.*?\n---\n", text, re.DOTALL)
    return text[match.end():] if match else text


def headings(text: str) -> list[tuple[int, int, str]]:
    out: list[tuple[int, int, str]] = []
    for line_no, line in enumerate(text.splitlines(), 1):
        match = re.match(r"^(#{1,6})\s+(.+?)\s*$", line)
        if match:
            out.append((line_no, len(match.group(1)), match.group(2).strip()))
    return out


def exact_heading_count(text: str, title: str, level: int = 2) -> int:
    return sum(1 for _, found_level, found in headings(text) if found_level == level and found.casefold() == title.casefold())


def parse_references(text: str) -> dict[str, list[str] | str]:
    result: dict[str, list[str] | str] = {}
    body = body_after_frontmatter(text)
    for line in body.splitlines():
        match = re.match(r"^- `([a-z_]+):\s*(.*?)`\s*$", line.strip())
        if not match:
            continue
        key, value = match.groups()
        if key in {"contracts", "tools"}:
            result[key] = [item.strip() for item in value.split(",") if item.strip()]
        else:
            result[key] = value.strip()
    for line in body.splitlines():
        if line.strip().startswith("- RAG:"):
            result["rag"] = line.strip()[6:].strip()
    return result


def load_coverage() -> dict[str, object]:
    try:
        return tomllib.loads(safe_read(COVERAGE_CONFIG))
    except (OSError, tomllib.TOMLDecodeError):
        return {}


def optional_roots() -> tuple[str, ...]:
    domains = load_coverage().get("domains", {})
    if not isinstance(domains, dict):
        return ()
    values: list[str] = []
    for domain in domains.values():
        if isinstance(domain, dict) and domain.get("optional_checkout") is True:
            roots = domain.get("roots", [])
            if isinstance(roots, list):
                values.extend(str(root).rstrip("/") for root in roots)
    return tuple(values)


def optional_missing(path_text: str) -> bool:
    return any(path_text.replace("\\", "/").startswith(root + "/") or path_text == root for root in optional_roots())


def script_paths(command: str) -> list[str]:
    return re.findall(r"(?:^|\s)(tools/[A-Za-z0-9_./-]+\.(?:py|cmd|ps1))", command)
