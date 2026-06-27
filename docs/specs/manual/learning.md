# learning manual spec overlay

## TL;DR

- Manages dynamic neural nets, attention blocks, transformers, and flat tensor buffers.
- Supports genetic algorithms, neuroevolution, bandits, tabular Q-learning, and simple engine-side tensor/model workflows.

## Summary

- The `learning` module is the engine's lightweight adaptive-policy surface for users who want experimentation, inference-like forward passes, and basic training loops to live inside the same runtime as gameplay and tooling code.
- Its defining feature is breadth across learning styles. Tensor math, feedforward models, convolutional structures, recurrent logic, attention, transformer-style components, Q-learning, bandits, genetic algorithms, and neuroevolution all coexist because game-related learning problems vary widely.
- That breadth matters because one project may want inference from a pretrained model, another may want online adaptation, and another may want population-based search or discrete action learning rather than gradient-heavy end-to-end training.
- The module therefore acts less like a single ML framework and more like an engine-owned research and experimentation toolkit with several entry points.
- Environment wrappers are an important part of the feature because learning is not only about models. It is also about observations, rewards, resets, episodes, action loops, and the staged interaction between a policy and a simulated task.
- This makes the module useful for reinforcement-style experimentation where the engine itself is part of the training or evaluation environment rather than merely a host for precomputed predictions.
- External model runtimes are intentionally out of scope for the small runtime build. The module keeps basic tensors, neural layers, reinforcement helpers, and population search so scripts can prototype game-facing behavior without turning the engine into a full data-science platform.
- Bandits, Q-learning, and evolutionary support are particularly relevant for game-like adaptation where discrete choices, heuristic search, or population exploration may be more useful than large-scale supervised training.
- Deterministic tensor and model operations are also valuable because experimentation inside a game engine still needs inspectability. Teams often need results to be partially reproducible so they can debug or compare behavior meaningfully.
- The module is therefore useful for adaptive NPC behavior, tuning agents, recommendation-like systems, simulation control, encounter balancing, and tool-side analysis of what a model would choose under engine constraints.
- It is also useful for benchmarking several policy ideas against the same engine-side tasks.
- That shared experimentation surface keeps inference, adaptation, and evaluation workflows closer to the game systems they are meant to influence.
- It keeps those experiments closer to game-side consequences and iteration loops.
- From a boundary perspective, domain modules define the world, rewards, and consequences, while `learning` owns the tensors, models, adaptation strategies, and training-oriented utilities that make machine learning usable inside that world.
- Read `learning` as the place where research-oriented AI and practical engine workflows meet.

This module is mostly self-contained inside the `Feature Systems` group. Cross-module behavior should stay in the referenced Rust source files and Lua bindings rather than being duplicated here.

## Notes

- No additional module-specific notes.

## Architecture Links

- Intentionally empty.
