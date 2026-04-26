---
name: github-workflow
description: "Load this skill when working with Lurek2D's GitHub project: creating or triaging issues, opening PRs, managing labels and milestones, using mcp_github_* tools for automation, or mapping roadmap phases to GitHub milestones. Skip it for CI/CD pipeline configuration (use ci-cd-pipeline skill) or code review (use Reviewer agent)."
---
# github-workflow

## Mission

Own GitHub project conventions: label taxonomy, branch naming, PR process, commit format, milestone mapping, and mcp_github_* tool usage patterns.

## When To Load

- Creating, triaging, or closing GitHub issues
- Opening or merging pull requests
- Using mcp_github_* tools for automation
- Mapping roadmap phases to GitHub milestones
- Preparing a release tag and changelog

## When To Skip

- CI/CD pipeline configuration → use ci-cd-pipeline skill
- Code review → use Reviewer agent

## Domain Knowledge

**Label taxonomy:**

| Prefix | Meaning | Examples |
|--------|---------|---------|
| type: | Issue category | type:bug, type:feature, type:docs, type:task |
| module: | Affected source module | module:graphics, module:physics, module:lua_api |
| tier: | Architecture tier | tier:1, tier:2, tier:3 |
| priority: | Urgency | priority:critical, priority:high, priority:low |
| status: | Work state | status:blocked, status:ready, status:in-review |
| phase: | Roadmap phase | phase:4, phase:5 |

**Branch naming:** type/short-description. Types: feat/ (new feature), fix/ (bug fix), refactor/ (no behavior change), docs/ (docs only), test/ (tests only), chore/ (build/deps/tooling).

**Commit format:** type(scope): description. Scope = affected module or area (graphics, physics, lua_api, cag, docs). One logical change per commit. Never git add . — stage only changed files. Confirm branch with git rev-parse --abbrev-ref HEAD before staging.

**PR process:** (1) branch from main, never commit directly; (2) one logical change per PR; (3) PR title = commit format; (4) must pass quality gates (cargo test, cargo clippy -- -D warnings, cargo fmt --check); (5) squash-merge to keep main history clean.

**Roadmap ↔ milestones:** Phase 1-3 = v0.1-v0.3 (historical), Phase 4 = v0.4 (current), Phase 5+ = v0.5+ (future). Map acceptance gates to issue completion for tracking.

**mcp_github_* tools:** always search before creating to avoid duplicates. Use mcp_github_search_issues for lookup, mcp_github_create_issue for new issues, mcp_github_pull_request_review_write for review requests.

## Companion File Index

None — all guidance is inline.

## References

- CONTRIBUTING.md — contributor guidelines
- docs/CHANGELOG.md — release changelog
- tools/github/ideas_to_github_issues.py — bulk issue importer
