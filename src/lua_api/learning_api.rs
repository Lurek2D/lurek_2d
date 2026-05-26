//! `lurek.learning` - Lua bindings for machine learning and evolutionary computation algorithms.

use super::SharedState;
use crate::learning::{
    Activation, Bandit, BanditStrategy, GeneticAlgorithm, NeuralNet, Neuroevolution, QLearner,
};
use mlua::prelude::*;
use std::cell::RefCell;
use std::rc::Rc;

/// Lua handle for a Q-learning table with configurable exploration and learning parameters.
#[derive(Clone)]
pub(crate) struct LuaQLearner {
    /// Shared Q-learning model containing Q-values, episode counters, and tuning parameters.
    pub(crate) inner: Rc<RefCell<QLearner>>,
}
impl LuaUserData for LuaQLearner {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- chooseAction --
        /// Chooses an action for a one-based state index using the learner's exploration policy.
        /// @param | state | integer | One-based state index.
        /// @return | integer | One-based chosen action index.
        methods.add_method("chooseAction", |_, this, state: usize| {
            Ok(this.inner.borrow().choose_action(state.saturating_sub(1)) + 1)
        });
        // -- bestAction --
        /// Returns the highest-valued action for a one-based state index without exploration.
        /// @param | state | integer | One-based state index.
        /// @return | integer | One-based best action index.
        methods.add_method("bestAction", |_, this, state: usize| {
            Ok(this.inner.borrow().best_action(state.saturating_sub(1)) + 1)
        });
        // -- learn --
        /// Applies one Q-learning update from a transition and reward.
        /// @param | state | integer | One-based previous state index.
        /// @param | action | integer | One-based action index taken in the previous state.
        /// @param | reward | number | Reward received for the transition.
        /// @param | next_state | integer | One-based next state index.
        methods.add_method(
            "learn",
            |_, this, (state, action, reward, next_state): (usize, usize, f64, usize)| {
                this.inner.borrow_mut().learn(
                    state.saturating_sub(1),
                    action.saturating_sub(1),
                    reward,
                    next_state.saturating_sub(1),
                );
                Ok(())
            },
        );
        // -- getQValue --
        /// Returns the stored Q-value for a one-based state and action pair.
        /// @param | state | integer | One-based state index.
        /// @param | action | integer | One-based action index.
        /// @return | number | Current Q-value.
        methods.add_method("getQValue", |_, this, (state, action): (usize, usize)| {
            Ok(this
                .inner
                .borrow()
                .get_q(state.saturating_sub(1), action.saturating_sub(1)))
        });
        // -- setQValue --
        /// Sets the stored Q-value for a one-based state and action pair.
        /// @param | state | integer | One-based state index.
        /// @param | action | integer | One-based action index.
        /// @param | value | number | Q-value to store.
        methods.add_method(
            "setQValue",
            |_, this, (state, action, value): (usize, usize, f64)| {
                this.inner.borrow_mut().set_q(
                    state.saturating_sub(1),
                    action.saturating_sub(1),
                    value,
                );
                Ok(())
            },
        );
        // -- endEpisode --
        /// Decays epsilon and increments the episode count.
        methods.add_method("endEpisode", |_, this, ()| {
            this.inner.borrow_mut().end_episode();
            Ok(())
        });
        // -- getStateCount --
        /// Returns the number of states represented by this learner.
        /// @return | integer | State count.
        methods.add_method("getStateCount", |_, this, ()| {
            Ok(this.inner.borrow().state_count)
        });
        // -- getActionCount --
        /// Returns the number of actions represented by this learner.
        /// @return | integer | Action count.
        methods.add_method("getActionCount", |_, this, ()| {
            Ok(this.inner.borrow().action_count)
        });
        // -- setLearningRate --
        /// Sets the Q-learning alpha learning rate.
        /// @param | v | number | Learning rate used by future updates.
        methods.add_method("setLearningRate", |_, this, v: f64| {
            this.inner.borrow_mut().alpha = v;
            Ok(())
        });
        // -- getLearningRate --
        /// Returns the Q-learning alpha learning rate.
        /// @return | number | Current learning rate.
        methods.add_method("getLearningRate", |_, this, ()| {
            Ok(this.inner.borrow().alpha)
        });
        // -- setDiscountFactor --
        /// Sets the Q-learning gamma discount factor.
        /// @param | v | number | Discount factor used by future updates.
        methods.add_method("setDiscountFactor", |_, this, v: f64| {
            this.inner.borrow_mut().gamma = v;
            Ok(())
        });
        // -- getDiscountFactor --
        /// Returns the Q-learning gamma discount factor.
        /// @return | number | Current discount factor.
        methods.add_method("getDiscountFactor", |_, this, ()| {
            Ok(this.inner.borrow().gamma)
        });
        // -- setExplorationRate --
        /// Sets the exploration rate used by action selection.
        /// @param | v | number | Exploration probability for future `chooseAction` calls.
        methods.add_method("setExplorationRate", |_, this, v: f64| {
            this.inner.borrow_mut().epsilon = v;
            Ok(())
        });
        // -- getExplorationRate --
        /// Returns the exploration rate used by action selection.
        /// @return | number | Current exploration rate.
        methods.add_method("getExplorationRate", |_, this, ()| {
            Ok(this.inner.borrow().epsilon)
        });
        // -- setExplorationDecay --
        /// Sets the exploration decay multiplier applied across episodes.
        /// @param | v | number | Exploration decay multiplier.
        methods.add_method("setExplorationDecay", |_, this, v: f64| {
            this.inner.borrow_mut().epsilon_decay = v;
            Ok(())
        });
        // -- getExplorationDecay --
        /// Returns the exploration decay multiplier.
        /// @return | number | Current exploration decay multiplier.
        methods.add_method("getExplorationDecay", |_, this, ()| {
            Ok(this.inner.borrow().epsilon_decay)
        });
        // -- serialize --
        /// Serializes the Q-learner state to a JSON string.
        /// @return | string | JSON representation of this learner.
        methods.add_method("serialize", |_, this, ()| {
            Ok(this.inner.borrow().serialize())
        });
        // -- deserialize --
        /// Replaces the Q-learner state from a JSON string.
        /// @param | json | string | JSON data previously produced by `serialize`.
        methods.add_method("deserialize", |_, this, json: String| {
            this.inner
                .borrow_mut()
                .deserialize(&json)
                .map_err(LuaError::RuntimeError)?;
            Ok(())
        });
        // -- type --
        /// Returns the Lua-visible type name for this Q-learner handle.
        /// @return | string | The string `LQLearner`.
        methods.add_method("type", |_, _, ()| Ok("LQLearner"));
        // -- typeOf --
        /// Returns whether this Q-learner handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LQLearner` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LQLearner" || name == "LObject")
        });
    }
}

/// Lua handle for a feed-forward neural network.
#[derive(Clone)]
pub(crate) struct LuaNeuralNet {
    /// Shared neural network containing layers and flattened weights.
    pub(crate) inner: Rc<RefCell<NeuralNet>>,
}
impl LuaUserData for LuaNeuralNet {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- addLayer --
        /// Adds a neural network layer with an activation function.
        /// @param | inputs | integer | Input count for the layer.
        /// @param | outputs | integer | Output count for the layer.
        /// @param | activation | string | Activation name such as `relu`, `sigmoid`, `tanh`, `linear`, or `softmax`.
        methods.add_method_mut(
            "addLayer",
            |_, this, (inputs, outputs, activation): (usize, usize, String)| {
                let act = Activation::from_str(&activation);
                this.inner.borrow_mut().add_layer(inputs, outputs, act);
                Ok(())
            },
        );
        // -- forward --
        /// Runs a forward pass and returns output values.
        /// @param | input | table | Array of numeric input values.
        /// @return | number[] | Numeric output values.
        methods.add_method("forward", |lua, this, input: Vec<f32>| {
            let out = this.inner.borrow().forward(&input);
            let t = lua.create_table()?;
            for (i, v) in out.into_iter().enumerate() {
                t.raw_set(i + 1, v)?;
            }
            Ok(t)
        });
        // -- setWeights --
        /// Replaces the network weights from a flat numeric array.
        /// @param | weights | table | Flat array of numeric weights in engine layer order.
        /// @return | boolean | True when the supplied weight slice matches the network shape.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.inner.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Returns the network weights as a flat numeric array.
        /// @return | number[] | Numeric weights in engine layer order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.inner.borrow().get_weights();
            let t = lua.create_table()?;
            for (i, v) in w.into_iter().enumerate() {
                t.raw_set(i + 1, v)?;
            }
            Ok(t)
        });
        // -- paramCount --
        /// Returns the total number of trainable parameters.
        /// @return | integer | Parameter count.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.inner.borrow().param_count() as i64)
        });
        // -- layerCount --
        /// Returns the number of layers in the network.
        /// @return | integer | Layer count.
        methods.add_method("layerCount", |_, this, ()| {
            Ok(this.inner.borrow().layer_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this neural network handle.
        /// @return | string | The string `LNeuralNet`.
        methods.add_method("type", |_, _, ()| Ok("LNeuralNet"));
        // -- typeOf --
        /// Returns whether this neural network handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LNeuralNet` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNeuralNet" || name == "LObject")
        });
    }
}

/// Lua handle for a floating-point genetic algorithm population.
#[derive(Clone)]
pub(crate) struct LuaGeneticAlgorithm {
    /// Shared genetic algorithm population and generation state.
    pub(crate) inner: Rc<RefCell<GeneticAlgorithm>>,
}
impl LuaUserData for LuaGeneticAlgorithm {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- evolve --
        /// Advances the genetic algorithm by one generation.
        methods.add_method_mut("evolve", |_, this, ()| {
            this.inner.borrow_mut().evolve();
            Ok(())
        });
        // -- generation --
        /// Returns the current generation index.
        /// @return | integer | Current generation count.
        methods.add_method("generation", |_, this, ()| {
            Ok(this.inner.borrow().generation as i64)
        });
        // -- popSize --
        /// Returns the population size. This method is available to Lua scripts.
        /// @return | integer | Current population size.
        methods.add_method("popSize", |_, this, ()| {
            Ok(this.inner.borrow().pop_size() as i64)
        });
        // -- setFitness --
        /// Sets the fitness value for a chromosome by zero-based index.
        /// @param | idx | integer | Zero-based chromosome index.
        /// @param | fitness | number | Fitness value used by the next evolution step.
        methods.add_method_mut("setFitness", |_, this, (idx, fitness): (usize, f32)| {
            if let Some(c) = this.inner.borrow_mut().population.get_mut(idx) {
                c.fitness = fitness;
            }
            Ok(())
        });
        // -- getGenes --
        /// Returns the genes for a chromosome by zero-based index.
        /// @param | idx | integer | Zero-based chromosome index.
        /// @return | number[] | Gene values, or an empty table for an invalid index.
        methods.add_method("getGenes", |lua, this, idx: usize| {
            let ga = this.inner.borrow();
            let t = lua.create_table()?;
            if let Some(c) = ga.population.get(idx) {
                for (i, &g) in c.genes.iter().enumerate() {
                    t.raw_set(i + 1, g)?;
                }
            }
            Ok(t)
        });
        // -- bestGenes --
        /// Returns the genes for the best chromosome in the population.
        /// @return | number[] | Array of best gene values, or an empty array when the population has no best chromosome.
        methods.add_method("bestGenes", |lua, this, ()| {
            let ga = this.inner.borrow();
            let t = lua.create_table()?;
            if let Some(best) = ga.best() {
                for (i, &g) in best.genes.iter().enumerate() {
                    t.raw_set(i + 1, g)?;
                }
            }
            Ok(t)
        });
        // -- type --
        /// Returns the Lua-visible type name for this genetic algorithm handle.
        /// @return | string | The string `LGeneticAlgorithm`.
        methods.add_method("type", |_, _, ()| Ok("LGeneticAlgorithm"));
        // -- typeOf --
        /// Returns whether this genetic algorithm handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LGeneticAlgorithm` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGeneticAlgorithm" || name == "LObject")
        });
    }
}

/// Lua handle for multi-armed bandit action selection.
#[derive(Clone)]
pub(crate) struct LuaBandit {
    /// Shared bandit model containing arm statistics and strategy state.
    pub(crate) inner: Rc<RefCell<Bandit>>,
}
impl LuaUserData for LuaBandit {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- select --
        /// Selects an arm using the configured bandit strategy.
        /// @return | integer | Zero-based selected arm index.
        methods.add_method_mut("select", |_, this, ()| {
            Ok(this.inner.borrow_mut().select() as i64)
        });
        // -- update --
        /// Updates one arm with a received reward.
        /// @param | idx | integer | Zero-based arm index.
        /// @param | reward | number | Reward value assigned to the arm pull.
        methods.add_method_mut("update", |_, this, (idx, reward): (usize, f64)| {
            this.inner.borrow_mut().update(idx, reward);
            Ok(())
        });
        // -- bestArm --
        /// Returns the arm with the best current estimate.
        /// @return | integer | Zero-based best arm index.
        methods.add_method("bestArm", |_, this, ()| {
            Ok(this.inner.borrow().best_arm() as i64)
        });
        // -- reset --
        /// Resets all bandit arm statistics. This method is available to Lua scripts.
        methods.add_method_mut("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- armCount --
        /// Returns the number of arms in this bandit.
        /// @return | integer | Arm count.
        methods.add_method("armCount", |_, this, ()| {
            Ok(this.inner.borrow().arm_count() as i64)
        });
        // -- totalPulls --
        /// Returns the total number of arm selections recorded by this bandit.
        /// @return | integer | Total pull count.
        methods.add_method("totalPulls", |_, this, ()| {
            Ok(this.inner.borrow().total_pulls as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this bandit handle.
        /// @return | string | The string `LBandit`.
        methods.add_method("type", |_, _, ()| Ok("LBandit"));
        // -- typeOf --
        /// Returns whether this bandit handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LBandit` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LBandit" || name == "LObject")
        });
    }
}

/// Lua handle for evolving neural network chromosomes.
#[derive(Clone)]
pub(crate) struct LuaNeuroevolution {
    /// Shared neuroevolution population and generation state.
    pub(crate) inner: Rc<RefCell<Neuroevolution>>,
}
impl LuaUserData for LuaNeuroevolution {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- evolve --
        /// Advances the neuroevolution population by one generation.
        methods.add_method_mut("evolve", |_, this, ()| {
            this.inner.borrow_mut().evolve();
            Ok(())
        });
        // -- setFitness --
        /// Sets the fitness value for a chromosome by zero-based index.
        /// @param | idx | integer | Zero-based chromosome index.
        /// @param | fitness | number | Fitness value used by the next evolution step.
        methods.add_method_mut("setFitness", |_, this, (idx, fitness): (usize, f32)| {
            this.inner.borrow_mut().set_fitness(idx, fitness);
            Ok(())
        });
        // -- chromosomeToNet --
        /// Converts one chromosome into a neural network handle when the index is valid.
        /// @param | idx | integer | Zero-based chromosome index.
        /// @return | LuaValue | Neural network handle, or nil when the chromosome index is invalid.
        methods.add_method("chromosomeToNet", |_, this, idx: usize| {
            let net = this.inner.borrow().chromosome_to_net(idx);
            Ok(net.map(|n| LuaNeuralNet {
                inner: Rc::new(RefCell::new(n)),
            }))
        });
        // -- bestNetwork --
        /// Converts the best chromosome into a neural network handle when one exists.
        /// @return | LuaValue | Neural network handle, or nil when no best chromosome is available.
        methods.add_method("bestNetwork", |_, this, ()| {
            let net = this.inner.borrow().best_network();
            Ok(net.map(|n| LuaNeuralNet {
                inner: Rc::new(RefCell::new(n)),
            }))
        });
        // -- bestFitness --
        /// Returns the best fitness value in the population.
        /// @return | number | Best fitness value.
        methods.add_method("bestFitness", |_, this, ()| {
            Ok(this.inner.borrow().best_fitness())
        });
        // -- popSize --
        /// Returns the population size. This method is available to Lua scripts.
        /// @return | integer | Current population size.
        methods.add_method("popSize", |_, this, ()| {
            Ok(this.inner.borrow().pop_size() as i64)
        });
        // -- generation --
        /// Returns the current generation index.
        /// @return | integer | Current generation count.
        methods.add_method("generation", |_, this, ()| {
            Ok(this.inner.borrow().generation as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this neuroevolution handle.
        /// @return | string | The string `LNeuroevolution`.
        methods.add_method("type", |_, _, ()| Ok("LNeuroevolution"));
        // -- typeOf --
        /// Returns whether this neuroevolution handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LNeuroevolution` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LNeuroevolution" || name == "LObject")
        });
    }
}

/// Registers the `lurek.learning` API table with the Lua VM.
pub fn register(lua: &Lua, lurek: &LuaTable, _state: Rc<RefCell<SharedState>>) -> LuaResult<()> {
    let tbl = lua.create_table()?;
    // -- newQLearner --
    /// Creates a Q-learner with fixed state and action counts.
    /// @param | sc | integer | Number of discrete states.
    /// @param | ac | integer | Number of discrete actions.
    /// @return | LQLearner | New Q-learner handle.
    tbl.set(
        "newQLearner",
        lua.create_function(|_, (sc, ac): (usize, usize)| {
            Ok(LuaQLearner {
                inner: Rc::new(RefCell::new(QLearner::new(sc, ac))),
            })
        })?,
    )?;
    // -- newNeuralNet --
    /// Creates an empty feed-forward neural network.
    /// @return | LNeuralNet | New neural network handle.
    tbl.set(
        "newNeuralNet",
        lua.create_function(|_, ()| {
            Ok(LuaNeuralNet {
                inner: Rc::new(RefCell::new(NeuralNet::new())),
            })
        })?,
    )?;
    // -- newGeneticAlgorithm --
    /// Creates a genetic algorithm population with fixed chromosome length.
    /// @param | pop_size | integer | Number of chromosomes in the population.
    /// @param | gene_count | integer | Number of floating-point genes per chromosome.
    /// @param | seed | integer | Random seed used for population initialization and evolution.
    /// @return | LGeneticAlgorithm | New genetic algorithm handle.
    tbl.set(
        "newGeneticAlgorithm",
        lua.create_function(|_, (pop_size, gene_count, seed): (usize, usize, u64)| {
            Ok(LuaGeneticAlgorithm {
                inner: Rc::new(RefCell::new(GeneticAlgorithm::new(
                    pop_size, gene_count, seed,
                ))),
            })
        })?,
    )?;
    // -- newBandit --
    /// Creates a multi-armed bandit with a named selection strategy.
    /// @param | arm_count | integer | Number of selectable arms.
    /// @param | strategy | string | Strategy name such as `ucb1`, `thompson`, or an epsilon-greedy fallback.
    /// @param | epsilon | number | Exploration probability used by epsilon-greedy strategy and clamped to `[0, 1]`.
    /// @param | seed | integer | Random seed used by the bandit.
    /// @return | LBandit | New bandit handle.
    tbl.set(
        "newBandit",
        lua.create_function(
            |_, (arm_count, strategy, epsilon, seed): (usize, String, f32, u64)| {
                let strat = match strategy.as_str() {
                    "ucb1" => BanditStrategy::UCB1,
                    "thompson" | "thompson_sampling" => BanditStrategy::ThompsonSampling,
                    _ => BanditStrategy::EpsilonGreedy {
                        epsilon: epsilon.clamp(0.0, 1.0),
                    },
                };
                Ok(LuaBandit {
                    inner: Rc::new(RefCell::new(Bandit::new(arm_count, strat, seed))),
                })
            },
        )?,
    )?;
    // -- newNeuroevolution --
    /// Creates a neuroevolution population from a layer specification table.
    /// @param | layer_spec | table | Array of layer tables with `inputs`, `outputs`, and optional `activation` fields.
    /// @param | pop_size | integer | Number of chromosomes in the population.
    /// @param | seed | integer | Random seed used for population initialization and evolution.
    /// @return | LNeuroevolution | New neuroevolution handle.
    tbl.set(
        "newNeuroevolution",
        lua.create_function(|_, (layer_spec, pop_size, seed): (LuaTable, usize, u64)| {
            let mut spec: Vec<(usize, usize, &'static str)> = Vec::new();
            for i in 1..=layer_spec.raw_len() {
                let entry: LuaTable = layer_spec.raw_get(i)?;
                let in_size: usize = entry.raw_get("inputs").unwrap_or(1);
                let out_size: usize = entry.raw_get("outputs").unwrap_or(1);
                let act_str: String = entry
                    .raw_get("activation")
                    .unwrap_or_else(|_| "relu".into());
                let act: &'static str = match act_str.as_str() {
                    "sigmoid" => "sigmoid",
                    "tanh" => "tanh",
                    "linear" => "linear",
                    "softmax" => "softmax",
                    _ => "relu",
                };
                spec.push((in_size, out_size, act));
            }
            Ok(LuaNeuroevolution {
                inner: Rc::new(RefCell::new(Neuroevolution::new(spec, pop_size, seed))),
            })
        })?,
    )?;

    lurek.set("learning", tbl)?;
    Ok(())
}
