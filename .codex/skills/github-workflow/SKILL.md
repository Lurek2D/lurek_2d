---
name: github-workflow
description: "Load this skill when working with GitHub issues, PRs, labels, milestones, or roadmap mapping. Skip it for CI/CD setup or code review."
---
# github-workflow

## Use when
- Triage issues.
- Prepare or review PR workflow details.
- Map roadmap work to milestones.
- Use repo GitHub automation tools.

## Avoid when
- CI workflow setup.
- Code review work.

## Repo rules
- Commit format is `type(scope): description`. Allowed types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`.
- How to stage a commit correctly: `git status` to see dirty files, `git diff --stat HEAD` to confirm what changed, then `git add <each file explicitly>`. Never `git add .`.
- PR scoping rule: one PR, one logical change. Mixed PRs are hard to review and hard to revert.
- How to use milestones: a milestone represents a deliverable slice with an explicit acceptance gate. The gate must be a runnable check.
- How to triage an issue: add a `module:` label to identify the affected subsystem. Add a `type:` label.
- How to label a PR for routing: `needs-review` when ready for human review; `blocked` when waiting on another PR or external decision; `auto-merge` only when all quality gates pass. The `cag` label routes to the CAG-Architect agent; the `engine` label routes to the Developer agent.
- `CONTRIBUTING.md` is the canonical process document. When a process question arises, check there first.

## Checks
- `Run the narrowest relevant validation for the touched files or workflow.`

## References
- `CONTRIBUTING.md`
- `.github/`
- `tools/github/`

