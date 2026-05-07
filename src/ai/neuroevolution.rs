//! Neuroevolution — evolve neural network weights using a genetic algorithm.
//!
//! Wraps [`crate::ai::genetic::GeneticAlgorithm`] and [`crate::ai::neural_net::NeuralNet`]
//! into a single type that manages population fitness evaluation, generation
//! stepping, and extraction of the best evolved network.
//!
//! ## Typical Usage Sequence
//!
//! 1. Create a `NeuralNet` template with the desired layer topology.
//! 2. Create `Neuroevolution::new(template, pop_size, seed)`.
//! 3. Access `population()` to iterate chromosomes.
//! 4. For each chromosome: call `chromosome_to_net(i)`, run simulation, set fitness.
//! 5. Call `evolve()` to advance one generation.
//! 6. After training: call `best_network()` to extract the winner.

use crate::ai::{genetic::GeneticAlgorithm, neural_net::NeuralNet};

// ────────────────────────────────────────────────────────────────────────────
// Neuroevolution
// ────────────────────────────────────────────────────────────────────────────

/// Neuroevolution trainer: evolves a population of neural network weight vectors.
///
/// # Fields
/// - `ga` — `GeneticAlgorithm`.
/// - `template_layer_spec` — `Vec<(usize, usize, String)>`.
/// - `generation` — `usize`.
pub struct Neuroevolution {
    /// Underlying genetic algorithm.
    pub ga: GeneticAlgorithm,
    /// Layer specifications: `(inputs, outputs, activation_name)`.
    template_layer_spec: Vec<(usize, usize, String)>,
    /// Number of completed generation evolutions.
    pub generation: usize,
}

impl Neuroevolution {
    /// Creates a new neuroevolution trainer for the given network topology.
    ///
    /// `layer_spec` is a list of `(inputs, outputs, activation)` tuples matching
    /// the layers that would be built via `NeuralNet::add_layer`.
    ///
    /// # Parameters
    /// - `layer_spec` — `Vec<(usize, usize, &str)>`.
    /// - `pop_size` — `usize`.
    /// - `seed` — `u64`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(layer_spec: Vec<(usize, usize, &str)>, pop_size: usize, seed: u64) -> Self {
        let gene_count = Self::total_params(&layer_spec);
        let ga = GeneticAlgorithm::new(pop_size, gene_count, seed);
        Self {
            ga,
            template_layer_spec: layer_spec
                .into_iter()
                .map(|(i, o, a)| (i, o, a.to_string()))
                .collect(),
            generation: 0,
        }
    }

    /// Returns the total parameter count implied by the given layer spec.
    fn total_params(spec: &[(usize, usize, &str)]) -> usize {
        spec.iter().map(|(i, o, _)| i * o + o).sum()
    }

    /// Returns the population size.
    ///
    /// # Returns
    /// `usize`.
    pub fn pop_size(&self) -> usize {
        self.ga.pop_size()
    }

    /// Builds a `NeuralNet` from the weight chromosome at index `i`.
    ///
    /// Returns `None` when `i` is out of bounds.
    ///
    /// # Parameters
    /// - `i` — `usize`.
    ///
    /// # Returns
    /// `Option<NeuralNet>`.
    pub fn chromosome_to_net(&self, i: usize) -> Option<NeuralNet> {
        let c = self.ga.population.get(i)?;
        let mut net = self.build_empty_net();
        net.set_weights(&c.genes);
        Some(net)
    }

    /// Sets the fitness for chromosome at index `i`.
    ///
    /// # Parameters
    /// - `i` — `usize`.
    /// - `fitness` — `f32`.
    pub fn set_fitness(&mut self, i: usize, fitness: f32) {
        if let Some(c) = self.ga.population.get_mut(i) {
            c.fitness = fitness;
        }
    }

    /// Advances one generation using the GA.
    pub fn evolve(&mut self) {
        self.ga.evolve();
        self.generation += 1;
    }

    /// Returns a `NeuralNet` loaded with the weights of the best chromosome.
    /// Returns `None` when the population is empty.
    ///
    /// # Returns
    /// `Option<NeuralNet>`.
    pub fn best_network(&self) -> Option<NeuralNet> {
        let best = self.ga.best()?;
        let mut net = self.build_empty_net();
        net.set_weights(&best.genes);
        Some(net)
    }

    /// Returns the fitness of the best chromosome.
    ///
    /// # Returns
    /// `f32`.
    pub fn best_fitness(&self) -> f32 {
        self.ga.best().map(|c| c.fitness).unwrap_or(0.0)
    }

    /// Returns a reference to the raw population chromosomes.
    ///
    /// # Returns
    /// `&[crate::ai::genetic::Chromosome]`.
    pub fn population(&self) -> &[crate::ai::genetic::Chromosome] {
        &self.ga.population
    }

    // ── Internal ─────────────────────────────────────────────────────────

    /// Builds an empty (zeroed weights) net matching the stored topology.
    fn build_empty_net(&self) -> NeuralNet {
        let mut net = NeuralNet::new();
        for (inputs, outputs, act_str) in &self.template_layer_spec {
            let act = crate::ai::neural_net::Activation::from_str(act_str);
            net.add_layer(*inputs, *outputs, act);
        }
        net
    }
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn new_pool_creates_population() {
        let ne = Neuroevolution::new(vec![(2, 3, "relu"), (3, 1, "sigmoid")], 10, 42);
        assert_eq!(ne.pop_size(), 10);
    }

    #[test]
    fn evaluate_and_evolve_preserves_size() {
        let mut ne = Neuroevolution::new(vec![(2, 1, "sigmoid")], 6, 42);
        for i in 0..6 {
            ne.set_fitness(i, i as f32);
        }
        ne.evolve();
        assert_eq!(ne.pop_size(), 6);
    }
}
