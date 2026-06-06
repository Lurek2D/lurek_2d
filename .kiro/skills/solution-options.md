---
inclusion: manual
---

# solution-options

## Mission
Own option-building, trade-off comparison, elimination, and final path selection for hard design problems.

## When To Use
- A high-level problem has more than one plausible solution.
- Constraints, migration cost, or risk make a single-path answer unsafe.
- A human decision point is needed because the trade-off is real.

## When To Skip
- Direct implementation work.
- Routine planning where the target shape is already accepted.
- Narrow debugging where the next step is a local fix.

## Rules

### Building a Valid Option Set
Start by writing the problem statement in one sentence naming the constraint being violated. List all non-negotiable constraints (binding constraints from the system rules, known validation requirements, existing module boundaries). Any option breaking a constraint is eliminated before scoring.

### Option Count Rule
2 to 4 options only.
- 2 options: forces a real binary trade-off.
- 3 options: sweet spot for most design decisions.
- 4 options: only when a third axis of variation genuinely matters.
More than 4 usually means options are wording variants of the same solution. Cluster them.

### Required Fields Per Option
1. Name (a noun phrase, not a verdict).
2. Approach summary in 2-3 sentences.
3. Fit with repo architecture (binding constraints).
4. Migration cost (what existing code, tests, or docs must change).
5. Validation path (name the specific test or audit command).
6. Long-term maintenance burden.

Every option needs all six fields. Missing fields signal the option is under-researched.

### Comparison Table
Rows = options, columns = the six fields above. Place the conservative option first (least change, lowest risk) and the highest-upside option last.

### Status Quo Option
Always include one if the problem is not yet severe enough to mandate change. Forces the decision-maker to articulate why change is needed now.

### Decision Output Format
Option name chosen, one sentence per rejected option naming the decisive reason it lost, the main residual risk of the chosen option, and the next owner. The handoff must be actionable.

### Human Decision Point
When a human call is needed, surface the exact trade-off explicitly and leave the decision point in the output rather than choosing on behalf of the user.

## References
- `.kiro/steering/agent-architect.md`
- `.kiro/skills/module-architecture.md`
- `.kiro/skills/enterprise-architecture.md`
