#!/usr/bin/env python3
"""Validate the active Codex CAG contracts, role registry, skills, and domains."""

from __future__ import annotations

import argparse
import json
import sys
import tomllib
from dataclasses import dataclass
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parent))
from _cag_common import (  # noqa: E402
    CODEX_CONFIG, COVERAGE_CONFIG, ROLE_CONFIG_DIR, SKILLS_DIR, WORKSPACE_ROOT,
    REPO_AGENT_SECTIONS, SKILL_SECTIONS, body_after_frontmatter, discover_repo_agents,
    discover_role_configs, discover_skills, exact_heading_count, load_coverage,
    optional_missing, parse_frontmatter, parse_references, read_config, registered_roles,
    relpath, safe_read, script_paths,
)

BASELINE_PATH = Path(__file__).with_suffix(".baseline.json")
ROLE_REQUIRED = {"name", "description", "model", "model_reasoning_effort", "approval_policy", "sandbox_mode"}
VALID_APPROVAL = {"never", "on-request", "on-failure"}
VALID_SANDBOX = {"read-only", "workspace-write", "danger-full-access"}


@dataclass(frozen=True)
class Violation:
    file: str
    rule: str
    message: str
    line: int = 0

    def key(self) -> str:
        return f"{self.file}:{self.rule}:{self.message}"


def error(path: Path, rule: str, message: str, line: int = 0) -> Violation:
    return Violation(relpath(path), rule, message, line)


def check_contract(path: Path) -> list[Violation]:
    text = safe_read(path)
    cap = 5000 if path.resolve() == (WORKSPACE_ROOT / "AGENTS.md").resolve() else 3000
    out: list[Violation] = []
    if len(text) > cap:
        out.append(error(path, "E401", f"Contract has {len(text)} normalized characters (cap {cap})"))
    h1 = sum(1 for line in text.splitlines() if line.startswith("# "))
    if h1 != 1:
        out.append(error(path, "E402", f"Contract must have exactly one H1 (found {h1})"))
    for section in REPO_AGENT_SECTIONS:
        count = exact_heading_count(text, section)
        if count != 1:
            out.append(error(path, "E403", f"Required H2 '{section}' must appear exactly once (found {count})"))
    return out


def check_skill(path: Path, roles: set[str]) -> list[Violation]:
    text = safe_read(path)
    out: list[Violation] = []
    if len(text) > 5000:
        out.append(error(path, "E201", f"Skill has {len(text)} normalized characters (cap 5000)"))
    frontmatter = parse_frontmatter(text)
    if frontmatter is None:
        return out + [error(path, "E202", "Missing or malformed YAML frontmatter")]
    name = frontmatter.get("name", "")
    if name != path.parent.name:
        out.append(error(path, "E203", "Frontmatter name must match the skill directory"))
    description = frontmatter.get("description", "").casefold()
    if "load this skill when" not in description or "skip it for" not in description:
        out.append(error(path, "E204", "Description must contain load and skip routing clauses"))
    body = body_after_frontmatter(text)
    h1 = sum(1 for line in body.splitlines() if line.startswith("# "))
    if h1 != 1:
        out.append(error(path, "E205", f"Skill must have exactly one H1 (found {h1})"))
    for section in SKILL_SECTIONS:
        count = exact_heading_count(body, section)
        if count != 1:
            out.append(error(path, "E206", f"Required H2 '{section}' must appear exactly once (found {count})"))
    if "```" in body:
        out.append(error(path, "E207", "Fenced code blocks are forbidden in skills"))
    refs = parse_references(text)
    contracts = refs.get("contracts")
    if not isinstance(contracts, list) or not contracts:
        out.append(error(path, "E208", "References must include contracts"))
    else:
        for contract in contracts:
            candidate = WORKSPACE_ROOT / contract
            if not candidate.exists() and not optional_missing(contract):
                out.append(error(path, "E209", f"Contract reference does not exist: {contract}"))
    agent = refs.get("agent")
    if not isinstance(agent, str) or agent not in roles:
        out.append(error(path, "E210", f"Unknown registered agent: {agent or '<missing>'}"))
    tools = refs.get("tools")
    if not isinstance(tools, list) or not tools:
        out.append(error(path, "E211", "References must include tools"))
    else:
        for command in tools:
            for script in script_paths(command):
                if not (WORKSPACE_ROOT / script).exists():
                    out.append(error(path, "E212", f"Tool reference does not exist: {script}"))
    if not isinstance(refs.get("rag"), str):
        out.append(error(path, "E213", "References must include a RAG line"))
    return out


def check_roles() -> list[Violation]:
    out: list[Violation] = []
    config = read_config()
    roles = registered_roles()
    if not config or not roles:
        return [Violation(".codex/config.toml", "E101", "No registered roles")]
    known_files = {path.stem: path for path in discover_role_configs()}
    for name, entry in roles.items():
        config_file = entry.get("config_file")
        description = entry.get("description")
        if not isinstance(config_file, str):
            out.append(Violation(".codex/config.toml", "E102", f"Role '{name}' has no config_file"))
            continue
        path = (ROLE_CONFIG_DIR.parent / config_file).resolve()
        if not path.exists():
            out.append(Violation(".codex/config.toml", "E103", f"Role '{name}' points to missing {config_file}"))
            continue
        try:
            data = tomllib.loads(safe_read(path))
        except tomllib.TOMLDecodeError:
            out.append(error(path, "E104", "Invalid TOML role configuration"))
            continue
        missing = sorted(key for key in ROLE_REQUIRED if not data.get(key))
        if missing:
            out.append(error(path, "E105", "Missing required keys: " + ", ".join(missing)))
            continue
        if data.get("name") != name or path.stem != name:
            out.append(error(path, "E106", "Role registry name, file name, and TOML name must match"))
        if data.get("description") != description:
            out.append(error(path, "E107", "Role description must match .codex/config.toml"))
        if data.get("approval_policy") not in VALID_APPROVAL or data.get("sandbox_mode") not in VALID_SANDBOX:
            out.append(error(path, "E108", "Unsupported approval policy or sandbox mode"))
    for name, path in known_files.items():
        if name not in roles:
            out.append(error(path, "E109", "Unregistered role configuration"))
    return out


def check_domains(skills: set[str]) -> list[Violation]:
    out: list[Violation] = []
    coverage = load_coverage()
    domains = coverage.get("domains") if isinstance(coverage, dict) else None
    if coverage.get("version") != 1 or not isinstance(domains, dict) or not domains:
        return [Violation(".codex/coverage.toml", "E301", "Invalid or empty domain coverage matrix")]
    declared: set[str] = set()
    for name, domain in domains.items():
        if not isinstance(domain, dict):
            out.append(Violation(".codex/coverage.toml", "E302", f"Domain '{name}' is not a table"))
            continue
        optional = domain.get("optional_checkout") is True
        for key in ("roots", "contracts", "skills"):
            values = domain.get(key)
            if not isinstance(values, list) or not values:
                out.append(Violation(".codex/coverage.toml", "E303", f"Domain '{name}' has no {key}"))
                continue
            for value in values:
                value = str(value)
                if key == "skills":
                    declared.add(value)
                    if value not in skills:
                        out.append(Violation(".codex/coverage.toml", "E304", f"Domain '{name}' references unknown skill '{value}'"))
                elif not (WORKSPACE_ROOT / value).exists() and not optional:
                    out.append(Violation(".codex/coverage.toml", "E305", f"Domain '{name}' missing {key[:-1]} '{value}'"))
    for skill in sorted(skills - declared):
        out.append(Violation(".codex/coverage.toml", "E306", f"Active skill is not assigned to a domain: {skill}"))
    return out


def run_validation(kind: str = "all", single_file: Path | None = None) -> tuple[list[Violation], dict[str, int]]:
    aliases = {"agent": "role", "repo_agent": "contract"}
    kind = aliases.get(kind, kind)
    roles = set(registered_roles())
    skills = discover_skills()
    counts = {"role": 0, "skill": 0, "contract": 0, "domain": 0}
    violations: list[Violation] = []
    if single_file is not None:
        if single_file.name == "SKILL.md":
            return check_skill(single_file, roles), {**counts, "skill": 1}
        if single_file.name == "AGENTS.md":
            return check_contract(single_file), {**counts, "contract": 1}
        if single_file.suffix == ".toml":
            return check_roles(), {**counts, "role": len(roles)}
    if kind in {"all", "role"}:
        violations.extend(check_roles()); counts["role"] = len(roles)
    if kind in {"all", "skill"}:
        for path in skills:
            violations.extend(check_skill(path, roles))
        counts["skill"] = len(skills)
    if kind in {"all", "contract"}:
        contracts = discover_repo_agents()
        for path in contracts:
            violations.extend(check_contract(path))
        counts["contract"] = len(contracts)
    if kind in {"all", "domain"}:
        violations.extend(check_domains({path.parent.name for path in skills}))
        coverage = load_coverage().get("domains", {})
        counts["domain"] = len(coverage) if isinstance(coverage, dict) else 0
    return violations, counts


def load_baseline() -> set[str]:
    try:
        return set(json.loads(BASELINE_PATH.read_text(encoding="utf-8")).get("keys", []))
    except (OSError, json.JSONDecodeError):
        return set()


def write_baseline(violations: list[Violation], counts: dict[str, int]) -> None:
    BASELINE_PATH.write_text(json.dumps({"keys": sorted(v.key() for v in violations), "scanned": counts}, indent=2) + "\n", encoding="utf-8")


def format_report(violations: list[Violation], counts: dict[str, int]) -> str:
    lines = [f"  ERROR {v.rule} {v.file}:{v.line} {v.message}" for v in violations]
    lines.append("Scanned: " + " ".join(f"{key}s={value}" for key, value in counts.items()))
    lines.append(f"Summary: {len(violations)} errors, 0 warnings")
    return "\n".join(lines)


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--type", choices=["all", "role", "skill", "contract", "domain", "agent", "repo_agent"], default="all")
    parser.add_argument("--file", type=Path)
    parser.add_argument("--baseline", action="store_true")
    parser.add_argument("--write-baseline", action="store_true")
    args = parser.parse_args()
    violations, counts = run_validation(args.type, args.file)
    if args.write_baseline:
        write_baseline(violations, counts)
    if args.baseline:
        baseline = load_baseline()
        violations = [violation for violation in violations if violation.key() not in baseline]
    print(format_report(violations, counts))
    return 1 if violations else 0


if __name__ == "__main__":
    raise SystemExit(main())
