---
name: create-tool
description: Create or update python or powershell tool in tools, review if all are properly documented and registered as CLI for agent to use.
---

# GOAL
- Develop utility scripts for validation, auditing, or build processes, ensuring they are documented and registered.

# INPUTS REQUIRED
- Tool purpose and target operation
- Language choice (Python or PowerShell)
= User must provide the utility requirement
- Agent must collect the CLI registry format

# STEPS TO DO
1. Load skills: build-system, scripting.
2. Write the script in `tools/` with correct `--help` support and argument parsing.
3. Register the tool in `tools/agent_cli_reference.md`.
4. Execute `python tools/audit/tool_registry_audit.py`. If it reports the tool is unregistered (exit code >0), fix the registry file and repeat this step.
5. Execute the newly created tool directly with standard inputs. If it exits with code >0, fix the tool's internal logic.

# OUTPUTS PROVIDED
- New or updated script in `tools/`
- Updated CLI reference docs-general

# SUCCESS CRITERIA
- `python tools/audit/tool_registry_audit.py` exits with code 0 (exactly 0 unregistered tools).
- The new tool exits with code 0 on standard execution.

# ANIT PATTERNS
- Writing scripts without `--help` docs-general.
- Hardcoding paths instead of using relative repository roots.

# REFERENCES
- skills: build-system, scripting
- tools: python tools/audit/tool_registry_audit.py
- agent: Build-Engineer
