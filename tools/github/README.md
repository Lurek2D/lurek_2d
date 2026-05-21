# tools/github — GitHub Integration

Scripts for automating GitHub project management: generating issues from
idea files.

## Scripts

| Script | Purpose |
|---|---|
| `ideas_to_github_issues.py` | Create GitHub issues from each Markdown file in `ideas/` |
| `sync_agent_rules.py` | Synchronize workspace agent rules file (.antigravityrules) with `.github/copilot-instructions.md` |

## Common usage

```powershell
# Create GitHub issues from ideas (requires GITHUB_TOKEN env var)
python tools/github/ideas_to_github_issues.py

# Synchronize agent rules file (.antigravityrules)
python tools/github/sync_agent_rules.py

# Verify synchronization (exits 1 if out of sync)
python tools/github/sync_agent_rules.py --check
```

## Requirements

Set the `GITHUB_TOKEN` environment variable to a Personal Access Token with
the `repo` scope before running `ideas_to_github_issues.py`.
