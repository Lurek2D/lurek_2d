---
name: create-tool
description: "Create or update python or powershell tool in tools, review if all are properly documented and registered as CLI for agent to use."
---
# create-tool

## Goal
- Develop utility scripts for validation, auditing, or build processes, ensuring they are documented and registered.

## Required inputs
- Tool purpose and target operation
- Language choice (Python or PowerShell)
- User must provide the utility requirement
- Agent must collect the CLI registry format

## Profile hint
- `builder`

## Read these contracts
- `tools/AGENTS.md`
- `tools/audit/AGENTS.md`

## Steps
- Read the listed contracts before creating a new script, audit helper, or CLI registration update.
- Write the script in `tools/` with correct `--help` support and argument parsing.
- Register the tool in `tools/agent_cli_reference.md`.
- Execute `python tools/audit/tool_registry_audit.py`. If it reports the tool is unregistered (exit code >0), fix the registry file and repeat this step.
- Execute the newly created tool directly with standard inputs. If it exits with code >0, fix the tool's internal logic.

## Outputs
- New or updated script in `tools/`
- Updated CLI reference documentation

## Success criteria
- [ ] `python tools/audit/tool_registry_audit.py` exits with code 0 (exactly 0 unregistered tools).
- [ ] The new tool exits with code 0 on standard execution.

## Stop conditions
- Writing scripts without `--help` documentation.
- Hardcoding paths instead of using relative repository roots.

## References
- `contracts: tools/AGENTS.md, tools/audit/AGENTS.md`
- `tools: python tools/audit/tool_registry_audit.py`
- `agent: Build-Engineer`


