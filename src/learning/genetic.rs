//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Centers the implementation around Chromosome, new, GeneticAlgorithm, with helpers kept close to their invariants.
//! Defines how genetic data is validated, transformed, or stored before neighboring systems use it.
//! Owns learning behavior with explicit state, validation, and crate-local integration boundaries.
//! Keeps public crate helpers focused on genetic behavior while Lua registration stays elsewhere.
//! Documents the boundary where learning code accepts inputs, reports errors, or updates state.

use crate::learning::{
    error::LearningError,
    limits::{
        enforce_limit, validate_finite, validate_non_zero_count, validate_range, LearningLimits,
    },
    rng::{LearningRng, LearningRngSnapshot},
};

/// Evolving genome with fitness and stable id.
#[derive(Clone)]
pub struct Chromosome {
    /// Gene vector used by the genome.
    pub genes: Vec<f32>,
    /// Fitness assigned by the caller.
    pub fitness: f32,
    /// Stable identifier across generations.
    pub id: u64,
}

impl Chromosome {
    /// Create a zeroed chromosome with `gene_count` genes.
    pub fn new(gene_count: usize, id: u64) -> Self {
        Self {
            genes: vec![0.0; gene_count],
            fitness: 0.0,
            id,
        }
    }
}

/// Population-based genetic optimizer.
pub struct GeneticAlgorithm {
    /// Current population.
    pub population: Vec<Chromosome>,
    /// Gene count per chromosome.
    pub gene_count: usize,
    /// Per-gene mutation probability.
    pub mutation_rate: f32,
    /// Standard deviation used by Gaussian mutation.
    pub mutation_std: f32,
    /// Tournament size used for parent selection.
    pub tournament_size: usize,
    /// Number of elite chromosomes preserved each generation.
    pub elitism: usize,
    /// Current generation number.
    pub generation: usize,
    /// Next chromosome id.
    next_id: u64,
    /// Internal deterministic RNG state.
    rng: LearningRng,
}

impl GeneticAlgorithm {
    /// Create a population with random initial genes.
    pub fn new(pop_size: usize, gene_count: usize, seed: u64) -> Self {
        Self::try_new(pop_size, gene_count, seed)
            .expect("GeneticAlgorithm::new received invalid population settings")
    }

    /// Create a population with random initial genes after validating dimensions and budgets.
    pub fn try_new(pop_size: usize, gene_count: usize, seed: u64) -> Result<Self, LearningError> {
        validate_non_zero_count("genetic population size", pop_size)?;
        validate_non_zero_count("genetic gene_count", gene_count)?;
        let limits = LearningLimits::default();
        enforce_limit("genetic population", pop_size, limits.max_population)?;
        enforce_limit(
            "genetic genome length",
            gene_count,
            limits.max_genome_length,
        )?;

        let mut ga = Self {
            population: Vec::with_capacity(pop_size),
            gene_count,
            mutation_rate: 0.05,
            mutation_std: 0.1,
            tournament_size: 3,
            elitism: 1,
            generation: 0,
            next_id: 0,
            rng: LearningRng::new(seed),
        };
        for _ in 0..pop_size {
            let id = ga.next_id;
            ga.next_id += 1;
            let mut c = Chromosome::new(gene_count, id);
            for g in &mut c.genes {
                *g = ga.rng.normal_f32();
            }
            ga.population.push(c);
        }
        ga.validate_hyperparams()?;
        Ok(ga)
    }

    /// Return the current population size.
    pub fn pop_size(&self) -> usize {
        self.population.len()
    }

    /// Return the chromosome with the highest fitness, or `None` if empty.
    pub fn best(&self) -> Option<&Chromosome> {
        self.population
            .iter()
            .max_by(|a, b| a.fitness.total_cmp(&b.fitness))
    }

    /// Build the next generation using elitism, tournament selection, crossover, and mutation.
    pub fn evolve(&mut self) {
        let _ = self.try_evolve();
    }

    /// Build the next generation using elitism, tournament selection, crossover, and mutation.
    pub fn try_evolve(&mut self) -> Result<(), LearningError> {
        self.validate_hyperparams()?;
        let pop_size = self.population.len();
        if pop_size == 0 {
            return Err(LearningError::ZeroCount {
                field: "genetic population size",
            });
        }

        for chromosome in &self.population {
            validate_finite("genetic fitness", chromosome.fitness as f64)?;
        }

        let elitism = self.elitism.min(pop_size);
        let tournament_size = self.tournament_size.clamp(1, pop_size);
        let mut next_gen: Vec<Chromosome> = Vec::with_capacity(pop_size);
        let mut sorted: Vec<usize> = (0..pop_size).collect();
        sorted.sort_by(|&a, &b| {
            self.population[b]
                .fitness
                .total_cmp(&self.population[a].fitness)
        });
        for &i in sorted.iter().take(elitism) {
            next_gen.push(self.population[i].clone());
        }
        while next_gen.len() < pop_size {
            let p1 = self.tournament_select(pop_size, tournament_size)?;
            let p2 = self.tournament_select(pop_size, tournament_size)?;
            let mut child =
                self.crossover(&self.population[p1].clone(), &self.population[p2].clone())?;
            self.mutate(&mut child)?;
            child.id = self.next_id;
            self.next_id += 1;
            child.fitness = 0.0;
            next_gen.push(child);
        }
        self.population = next_gen;
        self.generation += 1;
        Ok(())
    }

    /// Return the current exact RNG snapshot for reproducible replay.
    pub fn rng_snapshot(&self) -> LearningRngSnapshot {
        self.rng.snapshot()
    }

    /// Restore the internal evolution RNG from an exact saved snapshot.
    pub fn restore_rng_snapshot(
        &mut self,
        snapshot: LearningRngSnapshot,
    ) -> Result<(), LearningError> {
        self.rng.restore(snapshot)
    }

    /// Validate hyperparameter ranges and mutation policy.
    pub fn validate_hyperparams(&self) -> Result<(), LearningError> {
        validate_range("genetic mutation_rate", self.mutation_rate as f64, 0.0, 1.0)?;
        validate_range(
            "genetic mutation_std",
            self.mutation_std as f64,
            0.0,
            f64::INFINITY,
        )?;
        Ok(())
    }

    /// Return one selected parent index using tournament selection.
    fn tournament_select(
        &mut self,
        pop_size: usize,
        tournament_size: usize,
    ) -> Result<usize, LearningError> {
        let mut best_idx = self.rng.next_index(pop_size)?;
        for _ in 1..tournament_size {
            let idx = self.rng.next_index(pop_size)?;
            if self.population[idx].fitness > self.population[best_idx].fitness {
                best_idx = idx;
            }
        }
        Ok(best_idx)
    }

    /// Create a child chromosome by choosing each gene from one parent.
    fn crossover(&mut self, p1: &Chromosome, p2: &Chromosome) -> Result<Chromosome, LearningError> {
        let mut child = Chromosome::new(self.gene_count, 0);
        for i in 0..self.gene_count {
            child.genes[i] = if self.rng.next_index(2)? == 0 {
                p1.genes[i]
            } else {
                p2.genes[i]
            };
        }
        Ok(child)
    }

    /// Mutate a chromosome in place.
    fn mutate(&mut self, c: &mut Chromosome) -> Result<(), LearningError> {
        for g in &mut c.genes {
            if self.rng.next_f32() < self.mutation_rate {
                *g += self.rng.normal_f32() * self.mutation_std;
                validate_finite("genetic gene", *g as f64)?;
            }
        }
        Ok(())
    }
}
