---
trigger: manual
description: "Analyze one roadmap phase for readiness, gaps, and evidence strength."
expected_agent: "Manager"
---

# Analyze Roadmap Phase

## Goal
- Return a short phase audit that separates ready work from weakly supported work.

## Inputs
- Phase file or note path.
- Target persona or audience.
- Decision horizon.
- Known blockers or open questions.

## Steps
1. Load [skill: opportunity-discovery](../rules/skill_opportunity-discovery.md), [skill: roadmap-planning](../rules/skill_roadmap-planning.md), and [skill: documentation](../rules/skill_documentation.md) before acting.
2. Gather only the relevant source material from the named roadmap or ideas artifact, linked docs, related gaps, and any supporting notes in ideas/ or docs/.
3. Check whether the phase has a clear problem, why-now, dependencies, acceptance gate, and evidence strong enough to justify planning.
4. State what is ready, what is speculative, and the smallest next action to improve the phase.

## Success Criteria
- [ ] The data or source scope is explicit.
- [ ] Findings are evidence-backed and quantified where possible.
- [ ] Assumptions and open questions are separated from facts.
- [ ] A next owner or next validation step is clear.

## Anti-patterns
- Give generic advice with no repo evidence or measured signal.
- Mix facts, guesses, and recommendations into one vague paragraph.
- Jump to implementation before identifying the owner and the evidence strength.

## Example Invocation
- /analyze-roadmap-phase path=ideas/render-phase.md

## CAG Metadata
Mode: agent
Loads skills: opportunity-discovery, roadmap-planning, documentation
Inputs required: Phase file or note path., Target persona or audience., Decision horizon., Known blockers or open questions.
