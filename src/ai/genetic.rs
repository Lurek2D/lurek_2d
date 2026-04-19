//! Genetic Algorithm (GA) for offline AI parameter optimisation.
//!
//! Provides a simple generational GA with tournament selection, uniform
//! crossover, and Gaussian mutation. Intended for offline training of neural
//! network weights, behaviour tree thresholds, or steering behaviour parameters.
//!
//! ## Architecture
//!
//! - [`Chromosome`] is a named candidate solution: a flat `Vec<f32>` of genes
//!   plus a fitness score.
//! - [`GeneticAlgorithm`] manages a fixed-size population: `evolve()` runs one
//!   full generation (selection → crossover → mutation → replacement).
//!
//! ## Typical Usage Sequence
//!
//! 1. Create `GeneticAlgorithm::new(pop_size, gene_count, seed)`.
//! 2. Evaluate each chromosome in the population with your fitness function.
//! 3. Call `evolve()` to produce the next generation.
//! 4. Repeat for N generations or until `best()` fitness crosses a threshold.
//! 5. Load `best().genes` into a `NeuralNet` via `set_weights`.

// ────────────────────────────────────────────────────────────────────────────
// Chromosome
// ────────────────────────────────────────────────────────────────────────────

/// A candidate solution in a genetic algorithm population.
///
/// # Fields
/// - `genes` — `Vec<f32>`.
/// - `fitness` — `f32`.
/// - `id` — `u64`.
#[derive(Clone)]
pub struct Chromosome {
    /// The flat gene vector (e.g. neural network weights).
    pub genes: Vec<f32>,
    /// Fitness score computed by the caller's evaluation function.
    /// Must be set before calling `GeneticAlgorithm::evolve()`.
    pub fitness: f32,
    /// Per-population unique ID assigned at construction.
    pub id: u64,
}

impl Chromosome {
    /// Creates a zeroed chromosome.
    ///
    /// # Parameters
    /// - `gene_count` — `usize`.
    /// - `id` — `u64`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(gene_count: usize, id: u64) -> Self {
        Self { genes: vec![0.0; gene_count], fitness: 0.0, id }
    }
}

// ────────────────────────────────────────────────────────────────────────────
// GeneticAlgorithm
// ────────────────────────────────────────────────────────────────────────────

/// Simple generational genetic algorithm.
///
/// Uses tournament selection, uniform crossover, and Gaussian mutation.
/// The population is replaced each generation; the best chromosome is
/// always carried over (elitism).
///
/// # Fields
/// - `population` — `Vec<Chromosome>`.
/// - `gene_count` — `usize`.
/// - `mutation_rate` — `f32`.
/// - `mutation_std` — `f32`.
/// - `tournament_size` — `usize`.
/// - `elitism` — `usize`.
/// - `generation` — `usize`.
pub struct GeneticAlgorithm {
    /// Current population ordered by arbitrary index.
    pub population: Vec<Chromosome>,
    /// Number of genes per chromosome.
    pub gene_count: usize,
    /// Probability of mutating any single gene.
    pub mutation_rate: f32,
    /// Standard deviation of Gaussian mutation noise.
    pub mutation_std: f32,
    /// Number of candidates in each tournament selection round.
    pub tournament_size: usize,
    /// Number of best chromosomes copied unchanged to the next generation.
    pub elitism: usize,
    /// Count of completed generations.
    pub generation: usize,
    next_id: u64,
    rng: u64,
}

impl GeneticAlgorithm {
    /// Creates a new GA with a random initial population.
    ///
    /// Genes are initialised with Gaussian noise (mean=0, std=1).
    ///
    /// # Parameters
    /// - `pop_size` — `usize`.
    /// - `gene_count` — `usize`.
    /// - `seed` — `u64`.
    ///
    /// # Returns
    /// `Self`.
    pub fn new(pop_size: usize, gene_count: usize, seed: u64) -> Self {
        let mut ga = Self {
            population: Vec::with_capacity(pop_size),
            gene_count,
            mutation_rate: 0.05,
            mutation_std: 0.1,
            tournament_size: 3,
            elitism: 1,
            generation: 0,
            next_id: 0,
            rng: seed,
        };
        for _ in 0..pop_size {
            let id = ga.next_id;
            ga.next_id += 1;
            let mut c = Chromosome::new(gene_count, id);
            for g in &mut c.genes {
                *g = ga.randn();
            }
            ga.population.push(c);
        }
        ga
    }

    /// Returns the population size.
    ///
    /// # Returns
    /// `usize`.
    pub fn pop_size(&self) -> usize {
        self.population.len()
    }

    /// Returns a reference to the chromosome with highest fitness.
    ///
    /// # Returns
    /// `Option<&Chromosome>`.
    pub fn best(&self) -> Option<&Chromosome> {
        self.population.iter().max_by(|a, b| a.fitness.partial_cmp(&b.fitness).unwrap())
    }

    /// Runs one generation: tournament selection, crossover, mutation, elitism.
    ///
    /// Fitness values must be set on all chromosomes before calling this.
    pub fn evolve(&mut self) {
        let pop_size = self.population.len();
        let mut next_gen: Vec<Chromosome> = Vec::with_capacity(pop_size);

        // Elitism: carry over best unchanged
        let mut sorted: Vec<usize> = (0..pop_size).collect();
        sorted.sort_by(|&a, &b| {
            self.population[b].fitness.partial_cmp(&self.population[a].fitness).unwrap()
        });
        for &i in sorted.iter().take(self.elitism) {
            next_gen.push(self.population[i].clone());
        }

        // Fill rest with crossover + mutation offspring
        while next_gen.len() < pop_size {
            let p1 = self.tournament_select(pop_size);
            let p2 = self.tournament_select(pop_size);
            let mut child = self.crossover(&self.population[p1].clone(), &self.population[p2].clone());
            self.mutate(&mut child);
            child.id = self.next_id;
            self.next_id += 1;
            child.fitness = 0.0;
            next_gen.push(child);
        }

        self.population = next_gen;
        self.generation += 1;
    }

    // ── Internal helpers ────────────────────────────────────────────────────

    /// Returns index of winning chromosome in a tournament of `tournament_size`.
    fn tournament_select(&mut self, pop_size: usize) -> usize {
        let mut best_idx = self.rand_usize(pop_size);
        for _ in 1..self.tournament_size {
            let idx = self.rand_usize(pop_size);
            if self.population[idx].fitness > self.population[best_idx].fitness {
                best_idx = idx;
            }
        }
        best_idx
    }

    /// Uniform crossover: each gene drawn randomly from one of the two parents.
    fn crossover(&mut self, p1: &Chromosome, p2: &Chromosome) -> Chromosome {
        let mut child = Chromosome::new(self.gene_count, 0);
        for i in 0..self.gene_count {
            child.genes[i] = if self.rand_bool() { p1.genes[i] } else { p2.genes[i] };
        }
        child
    }

    /// Gaussian mutation: each gene mutated independently with `mutation_rate` probability.
    fn mutate(&mut self, c: &mut Chromosome) {
        for g in &mut c.genes {
            if self.rand_f01() < self.mutation_rate {
                *g += self.randn() * self.mutation_std;
            }
        }
    }

    /// Xorshift64 → `[0, n)`
    fn rand_usize(&mut self, n: usize) -> usize {
        self.rng = xorshift64(self.rng);
        (self.rng as usize) % n
    }

    /// Xorshift64 → `[0, 1)`
    fn rand_f01(&mut self) -> f32 {
        self.rng = xorshift64(self.rng);
        (self.rng >> 11) as f32 * (1.0 / (1u64 << 53) as f32)
    }

    /// Box-Muller transform for Gaussian noise (mean=0, std=1).
    fn randn(&mut self) -> f32 {
        let u1 = self.rand_f01().max(1e-7);
        let u2 = self.rand_f01();
        (-2.0 * u1.ln()).sqrt() * (2.0 * std::f32::consts::PI * u2).cos()
    }

    /// Returns `true` ~50% of the time.
    fn rand_bool(&mut self) -> bool {
        self.rng = xorshift64(self.rng);
        self.rng & 1 == 0
    }
}

/// Xorshift64 PRNG step.
fn xorshift64(mut x: u64) -> u64 {
    x ^= x << 13;
    x ^= x >> 7;
    x ^= x << 17;
    x
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn population_initialised() {
        let ga = GeneticAlgorithm::new(10, 5, 42);
        assert_eq!(ga.population().len(), 10);
        assert!(ga.population().iter().all(|g| g.genes.len() == 5));
    }

    #[test]
    fn evolve_step_preserves_size() {
        let mut ga = GeneticAlgorithm::new(8, 4, 42);
        let fitnesses: Vec<f64> = (0..8).map(|i| i as f64).collect();
        ga.evolve(&fitnesses, 0.1);
        assert_eq!(ga.population().len(), 8);
    }

    #[test]
    fn best_index_picks_highest() {
        let mut ga = GeneticAlgorithm::new(4, 3, 42);
        let fitnesses = vec![1.0, 5.0, 3.0, 2.0];
        ga.evolve(&fitnesses, 0.0);
        assert_eq!(ga.best_index(&fitnesses), 1);
    }

    #[test]
    fn generation_counter_increments() {
        let mut ga = GeneticAlgorithm::new(4, 2, 42);
        assert_eq!(ga.generation(), 0);
        ga.evolve(&[1.0, 2.0, 3.0, 4.0], 0.1);
        assert_eq!(ga.generation(), 1);
    }
}
