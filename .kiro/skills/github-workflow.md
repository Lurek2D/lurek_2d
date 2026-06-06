---
inclusion: manual
---

# github-workflow

## Mission
Own GitHub issue, PR, label, and milestone workflow guidance.

## When To Use
- Triage issues.
- Prepare or review PR workflow details.
- Map roadmap work to milestones.

## When To Skip
- CI workflow setup, code review work.

## Rules

### Commit Format
`type(scope): description`. Types: `feat`, `fix`, `refactor`, `test`, `docs`, `chore`. Scope is the primary module or layer. Description is present tense, no period. Every commit that changes behavior must include a `docs/CHANGELOG.md` update in the same commit.

### Staging a Commit
`git status` to see dirty files → `git diff --stat HEAD` to confirm what changed → `git add <each file explicitly>`. Never `git add .`. Confirm the branch with `git rev-parse --abbrev-ref HEAD` before staging. If the branch is `main`, ask the user before proceeding.

### PR Scoping
One PR, one logical change. Mixed PRs are hard to review and revert. If a PR touches more than 3 unrelated files or more than 2 module groups, split it.

### Milestones
A milestone represents a deliverable slice with an explicit acceptance gate. The gate must be a runnable check. When creating a milestone, write the gate in its description field. Milestones without a gate become backlogs.

### Issue Triage
- Add a `module:` label to identify the affected subsystem.
- Add a `type:` label (bug, enhancement, task, question).
- Add a `persona:` label (EngDev, GameDev, Modder).
- For bugs, add a `repro:` section with the exact command and failing output.

### PR Labels
- `needs-review` — ready for human review.
- `blocked` — waiting on another PR or external decision.
- `auto-merge` — only when all quality gates pass.

### CONTRIBUTING.md
Is the canonical process document. When a process question arises, check there first. If the answer is not there, add it after resolving — the answer belongs in `CONTRIBUTING.md`, not in a chat message.

## References
- `CONTRIBUTING.md`
- `docs/CHANGELOG.md`
- `.github/`
- `tools/github/`
