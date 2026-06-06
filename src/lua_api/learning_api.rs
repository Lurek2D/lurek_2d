//! File: src/lua_api/learning_api.rs

use super::SharedState;
use crate::learning::{
    Activation, Bandit, BanditStrategy, Conv2D, EvolutionaryLayer, FrameStack, GeneticAlgorithm,
    GruLayer, LstmLayer, LurekTensor, MaxPool2D, MultiHeadAttention, NeuralNet, Neuroevolution,
    OnnxModel, PositionalEncoding, QLearner, SpaceSpec, TransformerDecoderBlock,
    TransformerEncoderBlock,
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
        // -- getEpisodeCount --
        /// Returns the total number of episodes completed so far.
        /// @return | integer | Episode count.
        methods.add_method("getEpisodeCount", |_, this, ()| {
            Ok(this.inner.borrow().episode_count)
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
        // -- predict --
        /// Alias for `chooseAction`. Selects an action for the given one-based state using the learner's policy.
        /// @param | state | integer | One-based state index.
        /// @return | integer | One-based chosen action index.
        methods.add_method("predict", |_, this, state: usize| {
            Ok(this.inner.borrow().choose_action(state.saturating_sub(1)) + 1)
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
        // -- predict --
        /// Alias for `forward`. Runs a forward pass and returns output values.
        /// @param | input | table | Array of numeric input values.
        /// @return | number[] | Numeric output values.
        methods.add_method("predict", |lua, this, input: Vec<f32>| {
            let out = this.inner.borrow().forward(&input);
            let t = lua.create_table()?;
            for (i, v) in out.into_iter().enumerate() {
                t.raw_set(i + 1, v)?;
            }
            Ok(t)
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
        // -- predict --
        /// Alias for `select`. Selects an arm using the configured bandit strategy.
        /// @return | integer | Zero-based selected arm index.
        methods.add_method_mut("predict", |_, this, ()| {
            Ok(this.inner.borrow_mut().select() as i64)
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
        /// @return | LNeuralNet | Neural network handle.
        methods.add_method("chromosomeToNet", |_, this, idx: usize| {
            let net = this.inner.borrow().chromosome_to_net(idx);
            Ok(net.map(|n| LuaNeuralNet {
                inner: Rc::new(RefCell::new(n)),
            }))
        });
        // -- bestNetwork --
        /// Converts the best chromosome into a neural network handle when one exists.
        /// @return | LNeuralNet | Neural network handle.
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

/// A uniform model wrapper that delegates `predict` to any supported learning model type.
///
/// Wraps one of `LuaQLearner`, `LuaNeuralNet`, or `LuaBandit` so callers can use a
/// single `predict(...)` call without knowing the concrete model type at call sites.
#[derive(Clone)]
pub(crate) enum LuaModel {
    QLearner(LuaQLearner),
    NeuralNet(LuaNeuralNet),
    Bandit(LuaBandit),
}
impl LuaUserData for LuaModel {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- predict --
        /// Runs the wrapped model's prediction. Delegates to `chooseAction`, `forward`, or `select`
        /// depending on the wrapped type. Input is interpreted as `integer` for QLearner/Bandit
        /// and as a `table` of numbers for NeuralNet.
        /// @param | input | any | State index (integer) for QLearner/Bandit, or number array table for NeuralNet.
        /// @return | integer, table | Action index for QLearner/Bandit, or number-array table for NeuralNet.
        methods.add_method_mut("predict", |lua, this, input: LuaValue| match this {
            LuaModel::QLearner(q) => {
                let state: usize = lua.unpack(input)?;
                Ok(lua.pack(q.inner.borrow().choose_action(state.saturating_sub(1)) + 1)?)
            }
            LuaModel::NeuralNet(n) => {
                let v: Vec<f32> = lua.unpack(input)?;
                let out = n.inner.borrow().forward(&v);
                let t = lua.create_table()?;
                for (i, val) in out.into_iter().enumerate() {
                    t.raw_set(i + 1, val)?;
                }
                Ok(lua.pack(t)?)
            }
            LuaModel::Bandit(b) => Ok(lua.pack(b.inner.borrow_mut().select() as i64)?),
        });
        // -- type --
        /// Returns this wrapper's stable type name `"LModel"`.
        /// @return | string | The string `LModel`.
        methods.add_method("type", |_, _, ()| Ok("LModel"));
        // -- typeOf --
        /// Returns whether this model wrapper matches a supported type name.
        /// @param | name | string | Type name to compare against `LModel` and `Object`.
        /// @return | boolean | True when the supplied type name matches this wrapper.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LModel" || name == "LObject")
        });
    }
}

// ---------------------------------------------------------------------------
// LuaEnv â€” gym-compatible RL environment wrapper
// ---------------------------------------------------------------------------

/// Flat RL environment handle. Stores Lua callbacks and optional wrapping layers.
pub(crate) struct LuaEnv {
    reset_fn: Option<LuaRegistryKey>,
    step_fn: Option<LuaRegistryKey>,
    obs_space: SpaceSpec,
    action_space: SpaceSpec,
    normalize_mean: Option<Vec<f32>>,
    normalize_std: Option<Vec<f32>>,
    time_limit: Option<u32>,
    step_count: u32,
    inner_env: Option<Rc<RefCell<LuaEnv>>>,
}

impl LuaEnv {
    fn call_reset(&mut self, lua: &Lua) -> LuaResult<Vec<f32>> {
        if let Some(ref inner) = self.inner_env.clone() {
            return inner.borrow_mut().call_reset(lua);
        }
        let key = self
            .reset_fn
            .as_ref()
            .ok_or_else(|| LuaError::RuntimeError("LEnv: no reset function defined".into()))?;
        let f: LuaFunction = lua.registry_value(key)?;
        let result: LuaTable = f.call(())?;
        let mut obs = Vec::with_capacity(result.raw_len());
        for i in 1..=result.raw_len() {
            let v: f64 = result.raw_get(i).unwrap_or(0.0);
            obs.push(v as f32);
        }
        Ok(obs)
    }

    fn call_step<'lua>(
        &mut self,
        lua: &'lua Lua,
        action: LuaValue<'lua>,
    ) -> LuaResult<(Vec<f32>, f32, bool, LuaTable<'lua>)> {
        if let Some(ref inner) = self.inner_env.clone() {
            return inner.borrow_mut().call_step(lua, action);
        }
        let key = self
            .step_fn
            .as_ref()
            .ok_or_else(|| LuaError::RuntimeError("LEnv: no step function defined".into()))?;
        let f: LuaFunction = lua.registry_value(key)?;
        let result: LuaTable = f.call(action)?;
        let obs_tbl: LuaTable = result.raw_get(1)?;
        let reward: f64 = result.raw_get(2).unwrap_or(0.0);
        let done: bool = result.raw_get(3).unwrap_or(false);
        let info: LuaTable = result
            .raw_get(4)
            .unwrap_or_else(|_| lua.create_table().expect("table"));
        let mut obs = Vec::with_capacity(obs_tbl.raw_len());
        for i in 1..=obs_tbl.raw_len() {
            let v: f64 = obs_tbl.raw_get(i).unwrap_or(0.0);
            obs.push(v as f32);
        }
        Ok((obs, reward as f32, done, info))
    }

    fn apply_normalize(&self, obs: &mut [f32]) {
        if let (Some(mean), Some(std)) = (&self.normalize_mean, &self.normalize_std) {
            for (i, v) in obs.iter_mut().enumerate() {
                let m = mean.get(i).copied().unwrap_or(0.0);
                let s = std.get(i).copied().unwrap_or(1.0);
                let s = if s == 0.0 { 1.0 } else { s };
                *v = (*v - m) / s;
            }
        }
    }

    fn obs_to_table<'lua>(lua: &'lua Lua, obs: Vec<f32>) -> LuaResult<LuaTable<'lua>> {
        let t = lua.create_table()?;
        for (i, v) in obs.into_iter().enumerate() {
            t.raw_set(i + 1, v as f64)?;
        }
        Ok(t)
    }

    fn space_to_table<'lua>(lua: &'lua Lua, space: &SpaceSpec) -> LuaResult<LuaTable<'lua>> {
        let t = lua.create_table()?;
        let shape_tbl = lua.create_table()?;
        for (i, &v) in space.shape.iter().enumerate() {
            shape_tbl.raw_set(i + 1, v)?;
        }
        t.raw_set("shape", shape_tbl)?;
        let low_tbl = lua.create_table()?;
        for (i, &v) in space.low.iter().enumerate() {
            low_tbl.raw_set(i + 1, v as f64)?;
        }
        t.raw_set("low", low_tbl)?;
        let high_tbl = lua.create_table()?;
        for (i, &v) in space.high.iter().enumerate() {
            high_tbl.raw_set(i + 1, v as f64)?;
        }
        t.raw_set("high", high_tbl)?;
        if space.n > 0 {
            t.raw_set("n", space.n)?;
        }
        Ok(t)
    }
}

impl LuaUserData for LuaEnv {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- reset --
        /// Resets the environment and returns the initial observation.
        /// @return | number[] | Initial observation vector.
        methods.add_method_mut("reset", |lua, this, ()| {
            this.step_count = 0;
            let mut obs = this.call_reset(lua)?;
            this.apply_normalize(&mut obs);
            Self::obs_to_table(lua, obs)
        });
        // -- step --
        /// Advances the environment one step.
        /// @param | action | any | Action to apply (integer or table depending on action space).
        /// @return | number[] | Next observation vector.
        /// @return | number | Reward for this step.
        /// @return | boolean | Whether the episode has ended.
        /// @return | table | Extra info table.
        methods.add_method_mut("step", |lua, this, action: LuaValue| {
            let (mut obs, reward, mut done, info) = this.call_step(lua, action)?;
            this.apply_normalize(&mut obs);
            this.step_count += 1;
            if let Some(limit) = this.time_limit {
                if this.step_count >= limit {
                    done = true;
                }
            }
            let obs_tbl = Self::obs_to_table(lua, obs)?;
            Ok((obs_tbl, reward as f64, done, info))
        });
        // -- obsSpace --
        /// Returns the observation space descriptor.
        /// @return | table | Observation space with shape, low, high fields.
        methods.add_method("obsSpace", |lua, this, ()| {
            Self::space_to_table(lua, &this.obs_space)
        });
        // -- actionSpace --
        /// Returns the action space descriptor.
        /// @return | table | Action space with shape/low/high or n fields.
        methods.add_method("actionSpace", |lua, this, ()| {
            Self::space_to_table(lua, &this.action_space)
        });
        // -- type --
        /// Returns this environment wrapper's type name `"LEnv"`.
        /// @return | string | The string `LEnv`.
        methods.add_method("type", |_, _, ()| Ok("LEnv"));
        // -- typeOf --
        /// Returns whether this env handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LEnv` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LEnv" || name == "LObject")
        });
    }
}

// ---------------------------------------------------------------------------
// LuaFrameStack â€” ring-buffer for stacking observations
// ---------------------------------------------------------------------------

/// Lua handle wrapping a frame-stacking ring buffer.
#[derive(Clone)]
pub(crate) struct LuaFrameStack {
    inner: Rc<RefCell<FrameStack>>,
}

impl LuaUserData for LuaFrameStack {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- push --
        /// Pushes one observation into the stack.
        /// @param | obs | number[] | Observation vector to push.
        methods.add_method("push", |_, this, obs: Vec<f64>| {
            let obs_f32: Vec<f32> = obs.iter().map(|&v| v as f32).collect();
            this.inner.borrow_mut().push(obs_f32);
            Ok(())
        });
        // -- get --
        /// Returns the flattened observation stack, zero-padded when not yet full.
        /// @return | number[] | Flattened frame-stack vector of length capacity Ă— obs_dim.
        methods.add_method("get", |lua, this, ()| {
            let flat = this.inner.borrow().get();
            let t = lua.create_table()?;
            for (i, v) in flat.into_iter().enumerate() {
                t.raw_set(i + 1, v as f64)?;
            }
            Ok(t)
        });
        // -- reset --
        /// Clears all stored observation frames from the stack.
        methods.add_method("reset", |_, this, ()| {
            this.inner.borrow_mut().reset();
            Ok(())
        });
        // -- capacity --
        /// Returns the maximum number of frames retained.
        /// @return | integer | Frame capacity n.
        methods.add_method("capacity", |_, this, ()| Ok(this.inner.borrow().capacity()));
        // -- type --
        /// Returns the type name `"LFrameStack"`.
        /// @return | string | The string `LFrameStack`.
        methods.add_method("type", |_, _, ()| Ok("LFrameStack"));
        // -- typeOf --
        /// Returns whether this frame stack handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LFrameStack` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LFrameStack" || name == "LObject")
        });
    }
}

/// Parses a `SpaceSpec` from a Lua table.
fn parse_space_spec(tbl: &LuaTable) -> LuaResult<SpaceSpec> {
    let shape_tbl: Option<LuaTable> = tbl.raw_get("shape").ok();
    let mut shape = Vec::new();
    if let Some(st) = shape_tbl {
        for i in 1..=st.raw_len() {
            let v: u32 = st.raw_get(i).unwrap_or(1);
            shape.push(v);
        }
    }
    let low_tbl: Option<LuaTable> = tbl.raw_get("low").ok();
    let mut low = Vec::new();
    if let Some(lt) = low_tbl {
        for i in 1..=lt.raw_len() {
            let v: f64 = lt.raw_get(i).unwrap_or(0.0);
            low.push(v as f32);
        }
    }
    let high_tbl: Option<LuaTable> = tbl.raw_get("high").ok();
    let mut high = Vec::new();
    if let Some(ht) = high_tbl {
        for i in 1..=ht.raw_len() {
            let v: f64 = ht.raw_get(i).unwrap_or(1.0);
            high.push(v as f32);
        }
    }
    let n: u32 = tbl.raw_get("n").unwrap_or(0);
    Ok(SpaceSpec {
        shape,
        low,
        high,
        n,
    })
}

fn vec_to_lua_f32<'lua>(lua: &'lua Lua, values: &[f32]) -> LuaResult<LuaTable<'lua>> {
    let tbl = lua.create_table()?;
    for (i, &v) in values.iter().enumerate() {
        tbl.raw_set(i + 1, v as f64)?;
    }
    Ok(tbl)
}

fn tensor_ud_to_owned(ud: &LuaAnyUserData) -> LuaResult<LurekTensor> {
    let t = ud.borrow::<LuaTensor>()?;
    let tensor = t.0.borrow().clone();
    Ok(tensor)
}

/// Stateful Lua wrapper over `LstmLayer` with recurrent hidden and cell state buffers.
#[derive(Clone)]
pub(crate) struct LuaLstm {
    pub(crate) inner: Rc<RefCell<LstmLayer>>,
    pub(crate) hidden_state: Rc<RefCell<Vec<f32>>>,
    pub(crate) cell_state: Rc<RefCell<Vec<f32>>>,
}

impl LuaUserData for LuaLstm {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs one LSTM recurrent step on input data and returns next hidden state values.
        /// @param | input | table | Input vector with length equal to layer input_size.
        /// @return | table | Hidden-state vector with length equal to hidden_size.
        methods.add_method_mut("forward", |lua, this, input: Vec<f32>| {
            let layer = this.inner.borrow();
            let prev_h = this.hidden_state.borrow();
            let prev_c = this.cell_state.borrow();
            let (next_h, next_c) = layer.step(&input, &prev_h, &prev_c).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.lstm.forward: {}", e))
            })?;
            drop(layer);
            drop(prev_h);
            drop(prev_c);
            *this.hidden_state.borrow_mut() = next_h.clone();
            *this.cell_state.borrow_mut() = next_c;
            vec_to_lua_f32(lua, &next_h)
        });
        // -- reset --
        /// Resets both hidden and cell recurrent state buffers to zeros.
        /// @return | nil | No return value.
        methods.add_method_mut("reset", |_, this, ()| {
            let hidden = this.inner.borrow().hidden_size;
            *this.hidden_state.borrow_mut() = vec![0.0; hidden];
            *this.cell_state.borrow_mut() = vec![0.0; hidden];
            Ok(())
        });
        // -- setWeights --
        /// Loads flattened layer weights and biases into the wrapped LSTM layer.
        /// @param | weights | table | Flat float genome in LSTM parameter order.
        /// @return | boolean | True when weight count matches this layer geometry.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.inner.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Exports flattened layer weights and biases from the wrapped LSTM layer.
        /// @return | table | Flat float genome in deterministic LSTM parameter order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.inner.borrow().get_weights();
            vec_to_lua_f32(lua, &w)
        });
        // -- paramCount --
        /// Returns trainable parameter count for this LSTM layer.
        /// @return | integer | Total number of trainable scalar parameters.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.inner.borrow().param_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LLSTM`.
        methods.add_method("type", |_, _, ()| Ok("LLSTM"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LLSTM` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLSTM" || name == "LObject")
        });
    }
}

/// Stateful Lua wrapper over `GruLayer` with a mutable recurrent hidden-state buffer.
#[derive(Clone)]
pub(crate) struct LuaGru {
    pub(crate) inner: Rc<RefCell<GruLayer>>,
    pub(crate) hidden_state: Rc<RefCell<Vec<f32>>>,
}

impl LuaUserData for LuaGru {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs one GRU recurrent step on input data and returns next hidden state values.
        /// @param | input | table | Input vector with length equal to layer input_size.
        /// @return | table | Hidden-state vector with length equal to hidden_size.
        methods.add_method_mut("forward", |lua, this, input: Vec<f32>| {
            let layer = this.inner.borrow();
            let prev_h = this.hidden_state.borrow();
            let next_h = layer.step(&input, &prev_h).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.gru.forward: {}", e))
            })?;
            drop(layer);
            drop(prev_h);
            *this.hidden_state.borrow_mut() = next_h.clone();
            vec_to_lua_f32(lua, &next_h)
        });
        // -- reset --
        /// Resets the recurrent hidden state buffer to zeros.
        /// @return | nil | No return value.
        methods.add_method_mut("reset", |_, this, ()| {
            let hidden = this.inner.borrow().hidden_size;
            *this.hidden_state.borrow_mut() = vec![0.0; hidden];
            Ok(())
        });
        // -- setWeights --
        /// Loads flattened layer weights and biases into the wrapped GRU layer.
        /// @param | weights | table | Flat float genome in GRU parameter order.
        /// @return | boolean | True when weight count matches this layer geometry.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.inner.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Exports flattened layer weights and biases from the wrapped GRU layer.
        /// @return | table | Flat float genome in deterministic GRU parameter order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.inner.borrow().get_weights();
            vec_to_lua_f32(lua, &w)
        });
        // -- paramCount --
        /// Returns trainable parameter count for this GRU layer.
        /// @return | integer | Total number of trainable scalar parameters.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.inner.borrow().param_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LGRU`.
        methods.add_method("type", |_, _, ()| Ok("LGRU"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LGRU` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LGRU" || name == "LObject")
        });
    }
}

/// Lua wrapper over `Conv2D` for deterministic spatial inference and weight roundtrips.
#[derive(Clone)]
pub(crate) struct LuaConv2D(pub(crate) Rc<RefCell<Conv2D>>);

impl LuaUserData for LuaConv2D {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs convolution over an input tensor shaped as `[channels,height,width]`.
        /// @param | input | LTensor | Input tensor for spatial convolution.
        /// @return | LTensor | Output tensor produced by this convolution layer.
        methods.add_method("forward", |_, this, input: LuaAnyUserData| {
            let t = tensor_ud_to_owned(&input)?;
            let out = this.0.borrow().forward(&t).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.conv2d.forward: {}", e))
            })?;
            Ok(LuaTensor(Rc::new(RefCell::new(out))))
        });
        // -- setWeights --
        /// Loads flattened convolution weights and biases into this layer.
        /// @param | weights | table | Flat float genome in Conv2D parameter order.
        /// @return | boolean | True when weight count matches this layer geometry.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.0.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Exports flattened convolution weights and biases from this layer.
        /// @return | table | Flat float genome in deterministic Conv2D parameter order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.0.borrow().get_weights();
            vec_to_lua_f32(lua, &w)
        });
        // -- paramCount --
        /// Returns trainable parameter count for this Conv2D layer.
        /// @return | integer | Total number of trainable scalar parameters.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.0.borrow().param_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LConv2D`.
        methods.add_method("type", |_, _, ()| Ok("LConv2D"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LConv2D` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LConv2D" || name == "LObject")
        });
    }
}

/// Lua wrapper over `MaxPool2D` for deterministic non-trainable spatial downsampling.
#[derive(Clone)]
pub(crate) struct LuaMaxPool2D(pub(crate) Rc<RefCell<MaxPool2D>>);

impl LuaUserData for LuaMaxPool2D {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs max-pooling over an input tensor shaped as `[channels,height,width]`.
        /// @param | input | LTensor | Input tensor for max-pooling.
        /// @return | LTensor | Output tensor after max-pooling reduction.
        methods.add_method("forward", |_, this, input: LuaAnyUserData| {
            let t = tensor_ud_to_owned(&input)?;
            let out = this.0.borrow().forward(&t).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.maxpool2d.forward: {}", e))
            })?;
            Ok(LuaTensor(Rc::new(RefCell::new(out))))
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LMaxPool2D`.
        methods.add_method("type", |_, _, ()| Ok("LMaxPool2D"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LMaxPool2D` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMaxPool2D" || name == "LObject")
        });
    }
}

/// Lua wrapper over `MultiHeadAttention`.
#[derive(Clone)]
pub(crate) struct LuaMha(pub(crate) Rc<RefCell<MultiHeadAttention>>);

impl LuaUserData for LuaMha {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs multi-head self-attention over an input tensor shaped as `[seq_len,d_model]`.
        /// @param | input | LTensor | Input sequence tensor for attention.
        /// @return | LTensor | Output sequence tensor after attention projection.
        methods.add_method("forward", |_, this, input: LuaAnyUserData| {
            let t = tensor_ud_to_owned(&input)?;
            let out = this.0.borrow().forward(&t).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.mha.forward: {}", e))
            })?;
            Ok(LuaTensor(Rc::new(RefCell::new(out))))
        });
        // -- setWeights --
        /// Loads flattened projection weights and biases into this MHA block.
        /// @param | weights | table | Flat float genome in MHA parameter order.
        /// @return | boolean | True when weight count matches this block geometry.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.0.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Exports flattened projection weights and biases from this MHA block.
        /// @return | table | Flat float genome in deterministic MHA parameter order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.0.borrow().get_weights();
            vec_to_lua_f32(lua, &w)
        });
        // -- paramCount --
        /// Returns trainable parameter count for this MHA block.
        /// @return | integer | Total number of trainable scalar parameters.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.0.borrow().param_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LMultiHeadAttention`.
        methods.add_method("type", |_, _, ()| Ok("LMultiHeadAttention"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LMultiHeadAttention` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LMultiHeadAttention" || name == "LObject")
        });
    }
}

/// Lua wrapper over `PositionalEncoding`.
#[derive(Clone)]
pub(crate) struct LuaPositionalEncoding(pub(crate) Rc<RefCell<PositionalEncoding>>);

impl LuaUserData for LuaPositionalEncoding {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- apply --
        /// Applies sinusoidal positional encoding values to a `[seq_len,d_model]` tensor.
        /// @param | input | LTensor | Input sequence tensor to encode.
        /// @return | LTensor | Encoded sequence tensor with added positional values.
        methods.add_method("apply", |_, this, input: LuaAnyUserData| {
            let mut t = tensor_ud_to_owned(&input)?;
            this.0.borrow().apply(&mut t).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.positional.apply: {}", e))
            })?;
            Ok(LuaTensor(Rc::new(RefCell::new(t))))
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LPositionalEncoding`.
        methods.add_method("type", |_, _, ()| Ok("LPositionalEncoding"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LPositionalEncoding` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LPositionalEncoding" || name == "LObject")
        });
    }
}

/// Lua wrapper over `TransformerEncoderBlock`.
#[derive(Clone)]
pub(crate) struct LuaTransformerEncoder(pub(crate) Rc<RefCell<TransformerEncoderBlock>>);

impl LuaUserData for LuaTransformerEncoder {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs one transformer encoder block over an input `[seq_len,d_model]` tensor.
        /// @param | input | LTensor | Input sequence tensor for encoder processing.
        /// @return | LTensor | Output sequence tensor after encoder block operations.
        methods.add_method("forward", |_, this, input: LuaAnyUserData| {
            let t = tensor_ud_to_owned(&input)?;
            let out = this.0.borrow().forward(&t).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.transformer.encoder.forward: {}", e))
            })?;
            Ok(LuaTensor(Rc::new(RefCell::new(out))))
        });
        // -- setWeights --
        /// Loads flattened trainable parameters for this encoder block.
        /// @param | weights | table | Flat float genome in encoder parameter order.
        /// @return | boolean | True when weight count matches this block geometry.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.0.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Exports flattened trainable parameters for this encoder block.
        /// @return | table | Flat float genome in deterministic encoder parameter order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.0.borrow().get_weights();
            vec_to_lua_f32(lua, &w)
        });
        // -- paramCount --
        /// Returns trainable parameter count for this encoder block.
        /// @return | integer | Total number of trainable scalar parameters.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.0.borrow().param_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LTransformerEncoder`.
        methods.add_method("type", |_, _, ()| Ok("LTransformerEncoder"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LTransformerEncoder` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTransformerEncoder" || name == "LObject")
        });
    }
}

/// Lua wrapper over `TransformerDecoderBlock`.
#[derive(Clone)]
pub(crate) struct LuaTransformerDecoder(pub(crate) Rc<RefCell<TransformerDecoderBlock>>);

impl LuaUserData for LuaTransformerDecoder {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- forward --
        /// Runs one transformer decoder block over input and encoder-output tensors.
        /// @param | input | LTensor | Decoder input sequence tensor.
        /// @param | encoder_out | LTensor | Encoder output sequence tensor.
        /// @return | LTensor | Output sequence tensor after decoder block operations.
        methods.add_method(
            "forward",
            |_, this, (input, encoder_out): (LuaAnyUserData, LuaAnyUserData)| {
                let t = tensor_ud_to_owned(&input)?;
                let e = tensor_ud_to_owned(&encoder_out)?;
                let out = this.0.borrow().forward(&t, &e).map_err(|err| {
                    LuaError::RuntimeError(format!(
                        "lurek.learning.transformer.decoder.forward: {}",
                        err
                    ))
                })?;
                Ok(LuaTensor(Rc::new(RefCell::new(out))))
            },
        );
        // -- setWeights --
        /// Loads flattened trainable parameters for this decoder block.
        /// @param | weights | table | Flat float genome in decoder parameter order.
        /// @return | boolean | True when weight count matches this block geometry.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.0.borrow_mut().set_weights(&weights))
        });
        // -- getWeights --
        /// Exports flattened trainable parameters for this decoder block.
        /// @return | table | Flat float genome in deterministic decoder parameter order.
        methods.add_method("getWeights", |lua, this, ()| {
            let w = this.0.borrow().get_weights();
            vec_to_lua_f32(lua, &w)
        });
        // -- paramCount --
        /// Returns trainable parameter count for this decoder block.
        /// @return | integer | Total number of trainable scalar parameters.
        methods.add_method("paramCount", |_, this, ()| {
            Ok(this.0.borrow().param_count() as i64)
        });
        // -- type --
        /// Returns the Lua-visible type name for this wrapper.
        /// @return | string | The string `LTransformerDecoder`.
        methods.add_method("type", |_, _, ()| Ok("LTransformerDecoder"));
        // -- typeOf --
        /// Returns whether this userdata matches the requested type string.
        /// @param | name | string | Type string to compare against this userdata.
        /// @return | boolean | True when name is `LTransformerDecoder` or `LObject`.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTransformerDecoder" || name == "LObject")
        });
    }
}

// ---------------------------------------------------------------------------
// LuaTensor â€” flat f32 tensor with shape metadata
// ---------------------------------------------------------------------------

/// Flat tensor handle exposing shape, element access, and tract conversion to Lua.
#[derive(Clone)]
pub(crate) struct LuaTensor(pub(crate) Rc<RefCell<LurekTensor>>);

impl LuaUserData for LuaTensor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- shape --
        /// Returns the tensor's dimension sizes as an integer array (one entry per axis).
        /// @return | integer[] | Dimension sizes in row-major order.
        methods.add_method("shape", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &s) in this.0.borrow().shape.iter().enumerate() {
                tbl.raw_set(i + 1, s as i64)?;
            }
            Ok(tbl)
        });
        // -- data --
        /// Returns all elements as a flat number array in row-major order.
        /// @return | number[] | Flat element data.
        methods.add_method("data", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &v) in this.0.borrow().data.iter().enumerate() {
                tbl.raw_set(i + 1, v as f64)?;
            }
            Ok(tbl)
        });
        // -- get --
        /// Gets a single element by one-based multi-dimensional indices.
        /// @param | indices | any | Variadic one-based index per dimension.
        /// @return | number | Element value at the given position.
        methods.add_method("get", |_, this, indices: LuaMultiValue| {
            let idx_vec: Vec<usize> = indices
                .iter()
                .map(|v| match v {
                    LuaValue::Integer(n) => Ok((*n as usize).saturating_sub(1)),
                    LuaValue::Number(n) => Ok((*n as usize).saturating_sub(1)),
                    _ => Err(LuaError::RuntimeError(
                        "LTensor:get: expected integer indices".into(),
                    )),
                })
                .collect::<LuaResult<Vec<usize>>>()?;
            let val =
                this.0.borrow().get_element(&idx_vec).ok_or_else(|| {
                    LuaError::RuntimeError("LTensor:get: index out of bounds".into())
                })?;
            Ok(val as f64)
        });
        // -- len --
        /// Returns the total number of elements in the tensor.
        /// @return | integer | Total element count.
        methods.add_method("len", |_, this, ()| Ok(this.0.borrow().len() as i64));
        // -- type --
        /// Returns the type name `"LTensor"`.
        /// @return | string | The string `LTensor`.
        methods.add_method("type", |_, _, ()| Ok("LTensor"));
        // -- typeOf --
        /// Returns whether this tensor handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LTensor` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTensor" || name == "LObject")
        });
    }
}

// ---------------------------------------------------------------------------
// LuaOnnxModel â€” loaded and optimised ONNX inference model
// ---------------------------------------------------------------------------

/// ONNX model handle that wraps a tract runnable plan for Lua-driven inference.
#[derive(Clone)]
pub(crate) struct LuaOnnxModel(pub(crate) Rc<RefCell<OnnxModel>>);

impl LuaUserData for LuaOnnxModel {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- run --
        /// Runs inference on a table of LTensor inputs and returns a table of LTensor outputs.
        /// @param | inputs | table | Array-indexed table of LTensor input values.
        /// @return | table | Array-indexed table of LTensor output values.
        methods.add_method("run", |lua, this, inputs_tbl: LuaTable| {
            let mut tract_inputs: Vec<LurekTensor> = Vec::new();
            for i in 1..=inputs_tbl.raw_len() {
                let ud: LuaAnyUserData = inputs_tbl.raw_get(i)?;
                let lt = ud.borrow::<LuaTensor>()?;
                tract_inputs.push(lt.0.borrow().clone());
            }
            let outputs = this
                .0
                .borrow()
                .run(tract_inputs)
                .map_err(LuaError::RuntimeError)?;
            let out_tbl = lua.create_table()?;
            for (i, tensor) in outputs.into_iter().enumerate() {
                out_tbl.raw_set(i + 1, LuaTensor(Rc::new(RefCell::new(tensor))))?;
            }
            Ok(out_tbl)
        });
        // -- inputCount --
        /// Returns the number of input tensors expected by the model.
        /// @return | integer | Input tensor count.
        methods.add_method("inputCount", |_, this, ()| {
            Ok(this.0.borrow().input_count() as i64)
        });
        // -- outputCount --
        /// Returns the number of output tensors produced by the model.
        /// @return | integer | Output tensor count.
        methods.add_method("outputCount", |_, this, ()| {
            Ok(this.0.borrow().output_count() as i64)
        });
        // -- type --
        /// Returns the type name `"LOnnxModel"`.
        /// @return | string | The string `LOnnxModel`.
        methods.add_method("type", |_, _, ()| Ok("LOnnxModel"));
        // -- typeOf --
        /// Returns whether this model handle matches a supported type name.
        /// @param | name | string | Type name to compare against `LOnnxModel` and `Object`.
        /// @return | boolean | True when the supplied type name matches this handle.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LOnnxModel" || name == "LObject")
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
    // -- wrap --
    /// Wraps a supported model (LQLearner, LNeuralNet, or LBandit) in a uniform LModel interface.
    /// The returned LModel exposes a single `predict(input)` method that delegates to the wrapped type.
    /// @param | model | any | An LQLearner, LNeuralNet, or LBandit instance.
    /// @return | LModel | A uniform model wrapper exposing predict().
    tbl.set(
        "wrap",
        lua.create_function(|_, model: LuaValue| {
            if let LuaValue::UserData(ud) = &model {
                if let Ok(q) = ud.borrow::<LuaQLearner>() {
                    return Ok(LuaModel::QLearner(q.clone()));
                }
                if let Ok(n) = ud.borrow::<LuaNeuralNet>() {
                    return Ok(LuaModel::NeuralNet(n.clone()));
                }
                if let Ok(b) = ud.borrow::<LuaBandit>() {
                    return Ok(LuaModel::Bandit(b.clone()));
                }
            }
            Err(LuaError::RuntimeError(
                "wrap: expected LQLearner, LNeuralNet, or LBandit".into(),
            ))
        })?,
    )?;
    // -- defineEnv --
    /// Defines a Lua-described RL environment from a config table.
    /// @param | config | table | Config with `reset` (function), `step` (function), `obs_space` (table), `action_space` (table).
    /// @return | LEnv | New environment handle.
    tbl.set(
        "defineEnv",
        lua.create_function(|lua, config: LuaTable| {
            let reset_fn: LuaFunction = config.raw_get("reset").map_err(|_| {
                LuaError::RuntimeError("defineEnv: config.reset must be a function".into())
            })?;
            let step_fn: LuaFunction = config.raw_get("step").map_err(|_| {
                LuaError::RuntimeError("defineEnv: config.step must be a function".into())
            })?;
            let obs_tbl: LuaTable = config.raw_get("obs_space").map_err(|_| {
                LuaError::RuntimeError("defineEnv: config.obs_space must be a table".into())
            })?;
            let act_tbl: LuaTable = config.raw_get("action_space").map_err(|_| {
                LuaError::RuntimeError("defineEnv: config.action_space must be a table".into())
            })?;
            let obs_space = parse_space_spec(&obs_tbl)?;
            let action_space = parse_space_spec(&act_tbl)?;
            Ok(LuaEnv {
                reset_fn: Some(lua.create_registry_value(reset_fn)?),
                step_fn: Some(lua.create_registry_value(step_fn)?),
                obs_space,
                action_space,
                normalize_mean: None,
                normalize_std: None,
                time_limit: None,
                step_count: 0,
                inner_env: None,
            })
        })?,
    )?;
    // -- frameStack --
    /// Creates a frame-stacking ring buffer of the last n observations.
    /// @param | n | integer | Number of frames to retain.
    /// @return | LFrameStack | New frame stack handle.
    tbl.set(
        "frameStack",
        lua.create_function(|_, n: usize| {
            Ok(LuaFrameStack {
                inner: Rc::new(RefCell::new(FrameStack::new(n))),
            })
        })?,
    )?;
    // -- normalizeEnv --
    /// Wraps an LEnv so observations are normalised by subtracting mean and dividing by std.
    /// @param | env | LEnv | The environment to wrap.
    /// @param | mean | number[] | Per-dimension mean values matching the obs_space shape.
    /// @param | std | number[] | Per-dimension standard deviation values matching the obs_space shape.
    /// @return | LEnv | New wrapped environment handle.
    tbl.set(
        "normalizeEnv",
        lua.create_function(
            |_, (env_ud, mean, std): (LuaAnyUserData, Vec<f64>, Vec<f64>)| {
                let source = env_ud
                    .borrow::<LuaEnv>()
                    .map_err(|_| LuaError::RuntimeError("normalizeEnv: expected LEnv".into()))?;
                let obs_space = source.obs_space.clone();
                let action_space = source.action_space.clone();
                drop(source);
                let mean_f32: Vec<f32> = mean.iter().map(|&v| v as f32).collect();
                let std_f32: Vec<f32> = std.iter().map(|&v| v as f32).collect();
                Ok(LuaEnv {
                    reset_fn: None,
                    step_fn: None,
                    obs_space,
                    action_space,
                    normalize_mean: Some(mean_f32),
                    normalize_std: Some(std_f32),
                    time_limit: None,
                    step_count: 0,
                    inner_env: Some(Rc::new(RefCell::new(env_ud.take::<LuaEnv>()?))),
                })
            },
        )?,
    )?;
    // -- timeLimit --
    /// Wraps an LEnv so episodes end automatically after max_steps steps.
    /// @param | env | LEnv | The environment to wrap.
    /// @param | max_steps | integer | Maximum number of steps before done is forced true.
    /// @return | LEnv | New wrapped environment handle.
    tbl.set(
        "timeLimit",
        lua.create_function(|_, (env_ud, max_steps): (LuaAnyUserData, u32)| {
            let source = env_ud
                .borrow::<LuaEnv>()
                .map_err(|_| LuaError::RuntimeError("timeLimit: expected LEnv".into()))?;
            let obs_space = source.obs_space.clone();
            let action_space = source.action_space.clone();
            drop(source);
            Ok(LuaEnv {
                reset_fn: None,
                step_fn: None,
                obs_space,
                action_space,
                normalize_mean: None,
                normalize_std: None,
                time_limit: Some(max_steps),
                step_count: 0,
                inner_env: Some(Rc::new(RefCell::new(env_ud.take::<LuaEnv>()?))),
            })
        })?,
    )?;

    // -- loadOnnx --
    /// Loads and optimises an ONNX model from a file path.
    /// @param | path | string | Filesystem path to the `.onnx` model file.
    /// @return | LOnnxModel | Loaded model handle ready for inference.
    tbl.set(
        "loadOnnx",
        lua.create_function(|_, path: String| {
            OnnxModel::load(&path)
                .map(|m| LuaOnnxModel(Rc::new(RefCell::new(m))))
                .map_err(LuaError::RuntimeError)
        })?,
    )?;
    // -- newTensor --
    /// Creates a tensor from a shape (integer array) and flat float data (number array).
    /// @param | shape | integer[] | Dimension sizes in row-major order.
    /// @param | data | number[] | Flat element values matching the product of `shape`.
    /// @return | LTensor | New tensor handle.
    tbl.set(
        "newTensor",
        lua.create_function(|_, (shape_tbl, data_tbl): (LuaTable, LuaTable)| {
            let shape: Vec<usize> = (1..=shape_tbl.raw_len())
                .map(|i| {
                    let v: i64 = shape_tbl.raw_get(i)?;
                    Ok(v as usize)
                })
                .collect::<LuaResult<Vec<usize>>>()?;
            let data: Vec<f32> = (1..=data_tbl.raw_len())
                .map(|i| {
                    let v: f64 = data_tbl.raw_get(i)?;
                    Ok(v as f32)
                })
                .collect::<LuaResult<Vec<f32>>>()?;
            Ok(LuaTensor(Rc::new(RefCell::new(LurekTensor::new(
                shape, data,
            )))))
        })?,
    )?;

    // -- newLstm --
    /// Creates a stateful LSTM layer wrapper.
    /// @param | input_size | integer | Input vector size for each step.
    /// @param | hidden_size | integer | Hidden state size.
    /// @return | LLSTM | New LSTM layer handle with internal recurrent state.
    tbl.set(
        "newLstm",
        lua.create_function(|_, (input_size, hidden_size): (usize, usize)| {
            Ok(LuaLstm {
                inner: Rc::new(RefCell::new(LstmLayer::new(input_size, hidden_size))),
                hidden_state: Rc::new(RefCell::new(vec![0.0; hidden_size])),
                cell_state: Rc::new(RefCell::new(vec![0.0; hidden_size])),
            })
        })?,
    )?;

    // -- newGru --
    /// Creates a stateful GRU layer wrapper.
    /// @param | input_size | integer | Input vector size for each step.
    /// @param | hidden_size | integer | Hidden state size.
    /// @return | LGRU | New GRU layer handle with internal recurrent state.
    tbl.set(
        "newGru",
        lua.create_function(|_, (input_size, hidden_size): (usize, usize)| {
            Ok(LuaGru {
                inner: Rc::new(RefCell::new(GruLayer::new(input_size, hidden_size))),
                hidden_state: Rc::new(RefCell::new(vec![0.0; hidden_size])),
            })
        })?,
    )?;

    // -- newConv2D --
    /// Creates a Conv2D layer wrapper for deterministic CPU spatial inference.
    /// @param | in_channels | integer | Input channel count.
    /// @param | out_channels | integer | Output channel count.
    /// @param | kernel_h | integer | Kernel height.
    /// @param | kernel_w | integer | Kernel width.
    /// @param | stride_h | integer | Vertical stride.
    /// @param | stride_w | integer | Horizontal stride.
    /// @param | pad_h | integer | Vertical zero-padding.
    /// @param | pad_w | integer | Horizontal zero-padding.
    /// @return | LConv2D | New Conv2D layer handle.
    tbl.set(
        "newConv2D",
        lua.create_function(
            |_, (in_channels, out_channels, kernel_h, kernel_w, stride_h, stride_w, pad_h, pad_w): (
                usize,
                usize,
                usize,
                usize,
                usize,
                usize,
                usize,
                usize,
            )| {
                Ok(LuaConv2D(Rc::new(RefCell::new(Conv2D::new(
                    in_channels,
                    out_channels,
                    (kernel_h, kernel_w),
                    (stride_h, stride_w),
                    (pad_h, pad_w),
                )))))
            },
        )?,
    )?;

    // -- newMaxPool2D --
    /// Creates a MaxPool2D layer wrapper.
    /// @param | kernel_h | integer | Kernel height.
    /// @param | kernel_w | integer | Kernel width.
    /// @param | stride_h | integer | Vertical stride.
    /// @param | stride_w | integer | Horizontal stride.
    /// @return | LMaxPool2D | New MaxPool2D layer handle.
    tbl.set(
        "newMaxPool2D",
        lua.create_function(
            |_, (kernel_h, kernel_w, stride_h, stride_w): (usize, usize, usize, usize)| {
                Ok(LuaMaxPool2D(Rc::new(RefCell::new(MaxPool2D::new(
                    (kernel_h, kernel_w),
                    (stride_h, stride_w),
                )))))
            },
        )?,
    )?;

    // -- newPositionalEncoding --
    /// Creates a sinusoidal positional encoding helper.
    /// @param | d_model | integer | Embedding width.
    /// @param | max_len | integer | Maximum supported sequence length.
    /// @return | LPositionalEncoding | New positional encoding handle.
    tbl.set(
        "newPositionalEncoding",
        lua.create_function(|_, (d_model, max_len): (usize, usize)| {
            Ok(LuaPositionalEncoding(Rc::new(RefCell::new(
                PositionalEncoding::new(d_model, max_len),
            ))))
        })?,
    )?;

    // -- newMultiHeadAttention --
    /// Creates a multi-head attention block.
    /// @param | d_model | integer | Model width.
    /// @param | num_heads | integer | Number of attention heads.
    /// @return | LMultiHeadAttention | New MHA handle.
    tbl.set(
        "newMultiHeadAttention",
        lua.create_function(|_, (d_model, num_heads): (usize, usize)| {
            let mha = MultiHeadAttention::new(d_model, num_heads).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.newMultiHeadAttention: {}", e))
            })?;
            Ok(LuaMha(Rc::new(RefCell::new(mha))))
        })?,
    )?;

    // -- newTransformerEncoder --
    /// Creates a transformer encoder block.
    /// @param | d_model | integer | Model width.
    /// @param | num_heads | integer | Number of attention heads.
    /// @param | d_ff | integer | Feed-forward hidden width.
    /// @return | LTransformerEncoder | New encoder block handle.
    tbl.set(
        "newTransformerEncoder",
        lua.create_function(|_, (d_model, num_heads, d_ff): (usize, usize, usize)| {
            let block = TransformerEncoderBlock::new(d_model, num_heads, d_ff).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.newTransformerEncoder: {}", e))
            })?;
            Ok(LuaTransformerEncoder(Rc::new(RefCell::new(block))))
        })?,
    )?;

    // -- newTransformerDecoder --
    /// Creates a transformer decoder block.
    /// @param | d_model | integer | Model width.
    /// @param | num_heads | integer | Number of attention heads.
    /// @param | d_ff | integer | Feed-forward hidden width.
    /// @return | LTransformerDecoder | New decoder block handle.
    tbl.set(
        "newTransformerDecoder",
        lua.create_function(|_, (d_model, num_heads, d_ff): (usize, usize, usize)| {
            let block = TransformerDecoderBlock::new(d_model, num_heads, d_ff).map_err(|e| {
                LuaError::RuntimeError(format!("lurek.learning.newTransformerDecoder: {}", e))
            })?;
            Ok(LuaTransformerDecoder(Rc::new(RefCell::new(block))))
        })?,
    )?;

    lurek.set("learning", tbl)?;
    Ok(())
}
