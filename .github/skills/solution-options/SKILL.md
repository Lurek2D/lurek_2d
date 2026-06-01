---
name: solution-options
description: "Load this skill when solving a high-level problem needs 2 to 4 real options, trade-off checks, and one chosen path. Skip it for direct implementation, routine planning, or narrow bug fixing."
---
# solution-options

## Mission
- Own option-building, trade-off comparison, elimination, and final path selection for hard design problems.

## When To Load
- A high-level problem has more than one plausible solution.
- An architect must compare options before handing off implementation.
- Constraints, migration cost, or risk make a single-path answer unsafe.
- A human decision point is needed because the trade-off is real.

## When To Skip
- Direct implementation work.
- Routine planning where the target shape is already accepted.
- Narrow debugging where the next step is a local fix, not an option set.
- Review work that only checks an already chosen path.

## Domain Knowledge
- How to build a valid option set: start by writing the problem statement in one sentence naming the constraint being violated or the outcome not achievable with the current approach. Then list all non-negotiable constraints.
- Option count rule: 2 to 4 options only. Two options: forces a real binary trade-off.
- Required fields per option: name, approach summary in 2–3 sentences, fit with repo architecture, migration cost, validation path, long-term maintenance burden. Every option needs all six fields; missing fields signal the option is under-researched.
- How to compare options: use a comparison table with rows = options, columns = the six fields above. Place the conservative option first and the highest-upside option last.
- When to introduce a "status quo" option: always include one if the problem is not yet severe enough to mandate change. A status quo option named explicitly forces the decision-maker to articulate why change is needed now, which sometimes reveals the problem was over-stated.
- Decision output format: option name chosen, one sentence per rejected option naming the decisive reason it lost, the main residual risk of the chosen option, and the next owner. The handoff must be actionable — "implement in `src/<module>/`" is better than "proceed with engineering".
- When a human call is needed: surface the exact trade-off and leave the decision point explicit in the output rather than choosing on behalf of the user.
## Companion File Index
- None.

## References
- .github/agents/architect.agent.md
- .github/skills/module-architecture/SKILL.md
- .github/skills/enterprise-architecture/SKILL.md