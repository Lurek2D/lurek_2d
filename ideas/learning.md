Lurek2D — Plan Rozszerzenia Modułu Learning (LSTM, ConvNet, Transformers)

Ten dokument stanowi szczegółową specyfikację techniczną, matematyczną i architektoniczną rozbudowy modułu learning/ w silniku Lurek2D. Plik służy jako kompletny plan wdrożeniowy dla Agenta AI realizującego zadanie w środowisku Antigravity.

1. Założenia Matematyczne i Architektoniczne

Wszystkie nowe bloki sieci neuronowych muszą współpracować z algorytmem genetycznym (genetic.rs). W tym celu każda struktura warstwy musi jednoznacznie definiować schemat serializacji swoich wag (filtrów, macierzy projekcji, biasów) do i z płaskiej tablicy Vec<f32> (bufor genomu).

1.1 Kontrakt Genetyczny: EvolutionaryLayer

W pliku src/learning/neural_net.rs (lub nowym dedykowanym module) wprowadzamy cechę EvolutionaryLayer:

/// Kontrakt dla warstw sieci neuronowych umożliwiający ich bezpośrednie użycie w procesach neuroewolucji.
pub trait EvolutionaryLayer {
    /// Zwraca całkowitą liczbę uczalnych parametrów (wagi + biasy) w danej warstwie.
    fn param_count(&self) -> usize;

    /// Nadpisuje wagi i biasy warstwy wartościami z płaskiego bufora f32.
    /// Zwraca false, jeżeli rozmiar bufora nie jest zgodny z geometrią warstwy.
    fn set_weights(&mut self, weights: &[f32]) -> bool;

    /// Zwraca płaski bufor f32 reprezentujący aktualny stan wszystkich uczalnych wag i biasów warstwy.
    fn get_weights(&self) -> Vec<f32>;
}


1.2 Format Layoutu Płaskiego Genomu

Dla zachowania pełnej deterministyczności, każda warstwa musi zapisywać swoje parametry w ściśle określonej kolejności:

Macierze wag (zawsze w układzie wierszowym — Row-Major / C-Contiguous).

Wektory biasów (jeżeli występują).

W przypadku warstw złożonych (np. LSTM, MHA), wagi poszczególnych bram lub projekcji są łączone w jeden blok w kolejności opisanej w rozdziałach szczegółowych.

2. Podstawa Matematyczna: Silnik Tensorowy (tensor.rs)

Zamiast polegać na ciężkich bibliotekach zewnętrznych, tworzymy lekki, zoptymalizowany pod kątem CPU silnik tensorowy obsługujący dowolną liczbę wymiarów.

//! - Podstawowy moduł algebry liniowej dla struktur wielowymiarowych na CPU.
//! - Wspiera układy wierszowe (Row-Major), zmianę kształtów (reshape) oraz operacje elementowe.

/// Flat f32 tensor z jawną metadaną kształtu (row-major).
#[derive(Debug, Clone)]
pub struct LurekTensor {
    /// Rozmiary wymiarów tensora.
    pub shape: Vec<usize>,
    /// Płaski bufor danych typu f32.
    pub data: Vec<f32>,
}

impl LurekTensor {
    /// Tworzy nowy tensor z określonym kształtem i danymi. Podlega walidacji rozmiaru.
    pub fn new(shape: Vec<usize>, data: Vec<f32>) -> Self {
        let expected_len: usize = shape.iter().product();
        assert_eq!(
            expected_len,
            data.len(),
            "Rozmiar danych {} nie pasuje do wymiarów kształtu {:?}",
            data.len(),
            shape
        );
        Self { shape, data }
    }

    /// Tworzy tensor wypełniony zerami o podanym kształcie.
    pub fn zeros(shape: Vec<usize>) -> Self {
        let size = shape.iter().product();
        Self {
            shape,
            data: vec![0.0; size],
        }
    }

    /// Oblicza płaski indeks w buforze jednowymiarowym na podstawie współrzędnych wielowymiarowych.
    pub fn flat_index(&self, indices: &[usize]) -> Option<usize> {
        if indices.len() != self.shape.len() {
            return None;
        }
        let mut idx = 0usize;
        let mut stride = 1usize;
        for (&i, &s) in indices.iter().zip(self.shape.iter()).rev() {
            if i >= s {
                return None;
            }
            idx += i * stride;
            stride *= s;
        }
        Some(idx)
    }

    /// Spłaszcza tensor do jednowymiarowego kształtu [length].
    pub fn flatten(&self) -> Self {
        Self {
            shape: vec![self.data.len()],
            data: self.data.clone(),
        }
    }
}


2.1 Mnożenie Macierzy (General Matrix Multiply — GEMM)

Do obsługi warstw liniowych, LSTM, GRU oraz Attention potrzebujemy natywnego mnożenia macierzy dwuwymiarowych:


$$\mathbf{C} = \mathbf{A} \mathbf{B} + \mathbf{\beta}$$

Mnożenie $\mathbf{A} \in \mathbb{R}^{M \times K}$ przez $\mathbf{B} \in \mathbb{R}^{K \times N}$ z biasem $\mathbf{b} \in \mathbb{R}^{N}$:

/// Mnoży macierz A [M x K] przez B [K x N] i dodaje opcjonalny wektor biasu o długości N.
pub fn gemm(
    m: usize,
    k: usize,
    n: usize,
    a: &[f32],
    b: &[f32],
    bias: Option<&[f32]>,
) -> Vec<f32> {
    let mut out = vec![0.0; m * n];
    for i in 0..m {
        for j in 0..n {
            let mut sum = if let Some(b_val) = bias { b_val[j] } else { 0.0 };
            for p in 0..k {
                sum += a[i * k + p] * b[p * n + j];
            }
            out[i * n + j] = sum;
        }
    }
    out
}


3. Blok: Sploty i Pooling (ConvNet)

3.1 Warstwa Conv2D

Warstwa splotu 2D przetwarza trójwymiarowe tensory wejściowe o wymiarach $[C, H, W]$, gdzie $C$ to liczba kanałów (np. kanały tekstur, mapy wysokości), a $H, W$ to wysokość i szerokość przestrzenna.

Matematyka Splotu

Dla wyjściowego kanału $f \in [0, F)$, wejściowego kanału $c \in [0, C)$, oraz pozycji przestrzennej $(y, x)$ na wyjściu:


$$\mathbf{Y}_{f, y, x} = b_f + \sum_{c=0}^{C-1} \sum_{i=0}^{K_h-1} \sum_{j=0}^{K_w-1} \mathbf{X}_{c, y \cdot S_h + i - P_h, x \cdot S_w + j - P_w} \cdot \mathbf{W}_{f, c, i, j}$$

Gdzie:

$F$ — liczba filtrów wyjściowych (out_channels),

$C$ — liczba kanałów wejściowych (in_channels),

$K_h, K_w$ — wymiary jądra splotu (kernel size),

$S_h, S_w$ — krok przesunięcia (stride),

$P_h, P_w$ — dopełnienie (padding).

Struktura Rust i Układ Wag

Wszystkie wagi splotu są przechowywane w płaskim buforze o rozmiarze:


$$\text{Liczba Parametrów} = F \cdot C \cdot K_h \cdot K_w + F$$

Kolejność w genomie: [F, C, Kh, Kw] dla wag, a następnie [F] dla biasów.

/// Warstwa splotowa Conv2D dla CPU.
pub struct Conv2D {
    pub in_channels: usize,
    pub out_channels: usize,
    pub kernel_size: (usize, usize),
    pub stride: (usize, usize),
    pub padding: (usize, usize),
    pub weights: Vec<f32>, // Rozmiar: out_channels * in_channels * kh * kw
    pub biases: Vec<f32>,  // Rozmiar: out_channels
}

impl EvolutionaryLayer for Conv2D {
    fn param_count(&self) -> usize {
        self.out_channels * self.in_channels * self.kernel_size.0 * self.kernel_size.1 + self.out_channels
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }
        let w_size = self.out_channels * self.in_channels * self.kernel_size.0 * self.kernel_size.1;
        self.weights.copy_from_slice(&weights[0..w_size]);
        self.biases.copy_from_slice(&weights[w_size..expected]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.weights);
        out.extend_from_slice(&self.biases);
        out
    }
}


3.2 Warstwa MaxPool2D

Służy do redukcji wymiarów przestrzennych bez wprowadzania dodatkowych uczalnych wag (nie implementuje EvolutionaryLayer, zwraca 0 parametrów).

Matematyka Max Pool

Dla każdego kanału $c$ oraz lokalnego okna o wymiarach $K_h \times K_w$ wyjściem jest wartość maksymalna:


$$\mathbf{Y}_{c, y, x} = \max_{i \in [0, K_h), j \in [0, K_w)} \mathbf{X}_{c, y \cdot S_h + i, x \cdot S_w + j}$$

/// Warstwa redukcji przestrzennej MaxPool2D.
pub struct MaxPool2D {
    pub kernel_size: (usize, usize),
    pub stride: (usize, usize),
}

impl MaxPool2D {
    /// Przeprowadza forward pass redukcji wymiarów na tensorze wejściowym.
    pub fn forward(&self, input: &LurekTensor) -> LurekTensor {
        let channels = input.shape[0];
        let in_h = input.shape[1];
        let in_w = input.shape[2];

        let out_h = (in_h - self.kernel_size.0) / self.stride.0 + 1;
        let out_w = (in_w - self.kernel_size.1) / self.stride.1 + 1;

        let mut out_data = vec![0.0; channels * out_h * out_w];

        for c in 0..channels {
            for oh in 0..out_h {
                for ow in 0..out_w {
                    let mut max_val = f32::NEG_INFINITY;
                    for kh in 0..self.kernel_size.0 {
                        for kw in 0..self.kernel_size.1 {
                            let ih = oh * self.stride.0 + kh;
                            let iw = ow * self.stride.1 + kw;
                            let idx = c * (in_h * in_w) + ih * in_w + iw;
                            let val = input.data[idx];
                            if val > max_val {
                                max_val = val;
                            }
                        }
                    }
                    let out_idx = c * (out_h * out_w) + oh * out_w + ow;
                    out_data[out_idx] = max_val;
                }
            }
        }
        LurekTensor::new(vec![channels, out_h, out_w], out_data)
    }
}


4. Warstwy Rekurencyjne (LSTM i GRU)

Służą do budowania ciągłej pamięci sekwencyjnej u agentów AI.

4.1 LSTM (Long Short-Term Memory)

Warstwa LSTM operuje na wejściu $\mathbf{x}_t \in \mathbb{R}^{D}$, poprzednim stanie ukrytym $\mathbf{h}_{t-1} \in \mathbb{R}^{H}$ i poprzednim stanie komórki $\mathbf{c}_{t-1} \in \mathbb{R}^{H}$.

Bramy LSTM

$$\mathbf{f}_t = \sigma(\mathbf{W}_f \mathbf{x}_t + \mathbf{U}_f \mathbf{h}_{t-1} + \mathbf{b}_f) \quad \text{(brama zapominania)}$$

$$\mathbf{i}_t = \sigma(\mathbf{W}_i \mathbf{x}_t + \mathbf{U}_i \mathbf{h}_{t-1} + \mathbf{b}_i) \quad \text{(brama wejściowa)}$$

$$\tilde{\mathbf{c}}_t = \tanh(\mathbf{W}_c \mathbf{x}_t + \mathbf{U}_c \mathbf{h}_{t-1} + \mathbf{b}_c) \quad \text{(kandydat na stan komórki)}$$

$$\mathbf{c}_t = \mathbf{f}_t \odot \mathbf{c}_{t-1} + \mathbf{i}_t \odot \tilde{\mathbf{c}}_t \quad \text{(nowy stan komórki)}$$

$$\mathbf{o}_t = \sigma(\mathbf{W}_o \mathbf{x}_t + \mathbf{U}_o \mathbf{h}_{t-1} + \mathbf{b}_o) \quad \text{(brama wyjściowa)}$$

$$\mathbf{h}_t = \mathbf{o}_t \odot \tanh(\mathbf{c}_t) \quad \text{(nowy stan ukryty)}$$

Układ Wag w Genomie (Combined Weight Matrix)

Aby zminimalizować liczbę operacji mnożenia macierzy, wagi wszystkich czterech bram są łączone w jedną dużą macierz rzutowania wejścia $\mathbf{W}_{gate} \in \mathbb{R}^{4H \times D}$ oraz macierz rzutowania stanu ukrytego $\mathbf{U}_{gate} \in \mathbb{R}^{4H \times H}$:


$$\mathbf{W}_{gate} = \begin{bmatrix} \mathbf{W}_i \\ \mathbf{W}_f \\ \mathbf{W}_c \\ \mathbf{W}_o \end{bmatrix}, \quad \mathbf{U}_{gate} = \begin{bmatrix} \mathbf{U}_i \\ \mathbf{U}_f \\ \mathbf{U}_c \\ \mathbf{U}_o \end{bmatrix}, \quad \mathbf{b}_{gate} = \begin{bmatrix} \mathbf{b}_i \\ \mathbf{b}_f \\ \mathbf{b}_c \\ \mathbf{b}_o \end{bmatrix}$$

$$\text{Całkowita Liczba Parametrów} = 4 \cdot H \cdot D + 4 \cdot H \cdot H + 4 \cdot H = 4 \cdot H \cdot (D + H + 1)$$

Kolejność w płaskim genomie:

W_gate (rozmiar $4 \cdot H \cdot D$)

U_gate (rozmiar $4 \cdot H \cdot H$)

b_gate (rozmiar $4 \cdot H$)

/// Zunifikowana warstwa LSTM na CPU.
pub struct LstmLayer {
    pub input_size: usize,
    pub hidden_size: usize,
    /// Połączone wagi bram wejściowych: [4 * hidden_size, input_size]
    pub w_gate: Vec<f32>,
    /// Połączone wagi bram stanów ukrytych: [4 * hidden_size, hidden_size]
    pub u_gate: Vec<f32>,
    /// Połączone biasy bram: [4 * hidden_size]
    pub b_gate: Vec<f32>,
}

impl LstmLayer {
    /// Wykonuje pojedynczy krok rekurencyjny. Zwraca nowy stan ukryty i stan komórki.
    pub fn step(&self, x: &[f32], prev_h: &[f32], prev_c: &[f32]) -> (Vec<f32>, Vec<f32>) {
        let h = self.hidden_size;

        // Obliczenie rzutowań: gates = W_gate * x + U_gate * prev_h + b_gate
        let mut gates = vec![0.0; 4 * h];
        for g in 0..(4 * h) {
            let mut sum = self.b_gate[g];
            for i in 0..self.input_size {
                sum += self.w_gate[g * self.input_size + i] * x[i];
            }
            for j in 0..h {
                sum += self.u_gate[g * h + j] * prev_h[j];
            }
            gates[g] = sum;
        }

        let mut next_h = vec![0.0; h];
        let mut next_c = vec![0.0; h];

        // Wyodrębnienie bram i aktywacja (sigmoidy i tanh)
        for i in 0..h {
            let in_gate = 1.0 / (1.0 + (-gates[i]).exp());
            let forget_gate = 1.0 / (1.0 + (-gates[h + i]).exp());
            let cell_candidate = gates[2 * h + i].tanh();
            let out_gate = 1.0 / (1.0 + (-gates[3 * h + i]).exp());

            next_c[i] = forget_gate * prev_c[i] + in_gate * cell_candidate;
            next_h[i] = out_gate * next_c[i].tanh();
        }

        (next_h, next_c)
    }
}

impl EvolutionaryLayer for LstmLayer {
    fn param_count(&self) -> usize {
        4 * self.hidden_size * (self.input_size + self.hidden_size + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }
        let h = self.hidden_size;
        let d = self.input_size;

        let w_offset = 4 * h * d;
        let u_offset = w_offset + 4 * h * h;

        self.w_gate.copy_from_slice(&weights[0..w_offset]);
        self.u_gate.copy_from_slice(&weights[w_offset..u_offset]);
        self.b_gate.copy_from_slice(&weights[u_offset..expected]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_gate);
        out.extend_from_slice(&self.u_gate);
        out.extend_from_slice(&self.b_gate);
        out
    }
}


4.2 GRU (Gated Recurrent Unit)

GRU łączy bramę zapominania i wejściową w jedną bramę aktualizacji, co redukuje liczbę wymaganych wag.

Matematyka GRU

$$\mathbf{z}_t = \sigma(\mathbf{W}_z \mathbf{x}_t + \mathbf{U}_z \mathbf{h}_{t-1} + \mathbf{b}_z) \quad \text{(brama aktualizacji)}$$

$$\mathbf{r}_t = \sigma(\mathbf{W}_r \mathbf{x}_t + \mathbf{U}_r \mathbf{h}_{t-1} + \mathbf{b}_r) \quad \text{(brama resetowania)}$$

$$\tilde{\mathbf{h}}_t = \tanh(\mathbf{W}_h \mathbf{x}_t + \mathbf{U}_h (\mathbf{r}_t \odot \mathbf{h}_{t-1}) + \mathbf{b}_h) \quad \text{(kandydat do stanu ukrytego)}$$

$$\mathbf{h}_t = (1 - \mathbf{z}_t) \odot \mathbf{h}_{t-1} + \mathbf{z}_t \odot \tilde{\mathbf{h}}_t \quad \text{(nowy stan ukryty)}$$

Układ Wag w Genomie (GRU)

$$\mathbf{W}_{gru} = \begin{bmatrix} \mathbf{W}_z \\ \mathbf{W}_r \\ \mathbf{W}_h \end{bmatrix}, \quad \mathbf{U}_{gru} = \begin{bmatrix} \mathbf{U}_z \\ \mathbf{U}_r \\ \mathbf{U}_h \end{bmatrix}, \quad \mathbf{b}_{gru} = \begin{bmatrix} \mathbf{b}_z \\ \mathbf{b}_r \\ \mathbf{b}_h \end{bmatrix}$$

$$\text{Całkowita Liczba Parametrów} = 3 \cdot H \cdot (D + H + 1)$$

5. Blok: Transformers i Attention

5.1 Kodowanie Pozycyjne (Positional Encoding)

Zapewnia geometryczną informację o kolejności tokenów w sekwencji. Dla długości sekwencji $S$ oraz wymiaru modelu $D$:


$$\mathbf{PE}_{pos, 2i} = \sin\left(\frac{pos}{10000^{2i/D}}\right)$$

$$\mathbf{PE}_{pos, 2i+1} = \cos\left(\frac{pos}{10000^{2i/D}}\right)$$

Wspornik ten nie zawiera parametrów podlegających ewolucji.

/// Zapewnia dodawanie wektorów pozycyjnych do osadzenia sekwencji.
pub struct PositionalEncoding {
    pub d_model: usize,
    pub max_len: usize,
    pub encoding: Vec<f32>,
}

impl PositionalEncoding {
    /// Inicjalizuje statyczną tablicę wartości sinusoidalnych i kosinusoidalnych.
    pub fn new(d_model: usize, max_len: usize) -> Self {
        let mut encoding = vec![0.0; max_len * d_model];
        for pos in 0..max_len {
            for i in (0..d_model).step_by(2) {
                let div_term = 10000.0f32.powf((i as f32) / (d_model as f32));
                encoding[pos * d_model + i] = ((pos as f32) / div_term).sin();
                if i + 1 < d_model {
                    encoding[pos * d_model + i + 1] = ((pos as f32) / div_term).cos();
                }
            }
        }
        Self { d_model, max_len, encoding }
    }

    /// Dodaje wektory PE bezpośrednio do przesłanego tensora [SeqLen, d_model] in-place.
    pub fn apply(&self, x: &mut LurekTensor) {
        let seq_len = x.shape[0];
        let d = x.shape[1];
        assert_eq!(d, self.d_model, "Niezgodność d_model");
        for pos in 0..seq_len {
            for i in 0..d {
                x.data[pos * d + i] += self.encoding[pos * d + i];
            }
        }
    }
}


5.2 Multi-Head Attention (MHA)

Warstwa Multi-Head Attention dzieli wymiar wejściowy $D$ na $H$ odrębnych głowic o rozmiarze $d_k = D / H$.

Matematyka MHA

Dla wejścia $\mathbf{X} \in \mathbb{R}^{S \times D}$:


$$\mathbf{Q} = \mathbf{X} \mathbf{W}_q, \quad \mathbf{K} = \mathbf{X} \mathbf{W}_k, \quad \mathbf{V} = \mathbf{X} \mathbf{W}_v$$


Każda głowica $h \in [0, H)$ wycina swoje sub-macierze $\mathbf{Q}_h, \mathbf{K}_h, \mathbf{V}_h \in \mathbb{R}^{S \times d_k}$ i liczy wagę uwagi:


$$\mathbf{Head}_h = \text{Softmax}\left(\frac{\mathbf{Q}_h \mathbf{K}_h^T}{\sqrt{d_k}}\right) \mathbf{V}_h$$


Wyjście to konkatenacja głowic rzutowana wstecz na przestrzeń wejściową:


$$\text{MHA}(\mathbf{X}) = \left[\mathbf{Head}_0 \,\|\, \mathbf{Head}_1 \,\|\, \dots \,\|\, \mathbf{Head}_{H-1}\right] \mathbf{W}_o$$

Układ Wag w Genomie (MHA)

Macierze projekcji: $\mathbf{W}_q, \mathbf{W}_k, \mathbf{W}_v, \mathbf{W}_o$ (każda o rozmiarze $D \times D$). Dodajemy do każdej opcjonalny bias o długości $D$.


$$\text{Całkowita Liczba Parametrów} = 4 \cdot D^2 + 4 \cdot D = 4 \cdot D \cdot (D + 1)$$

Kolejność w genomie: W_q, W_k, W_v, W_o, b_q, b_k, b_v, b_o.

/// Implementacja warstwy Multi-Head Attention na CPU.
pub struct MultiHeadAttention {
    pub d_model: usize,
    pub num_heads: usize,
    pub d_k: usize,
    pub w_q: Vec<f32>, // [d_model, d_model]
    pub w_k: Vec<f32>, // [d_model, d_model]
    pub w_v: Vec<f32>, // [d_model, d_model]
    pub w_o: Vec<f32>, // [d_model, d_model]
    pub b_q: Vec<f32>, // [d_model]
    pub b_k: Vec<f32>, // [d_model]
    pub b_v: Vec<f32>, // [d_model]
    pub b_o: Vec<f32>, // [d_model]
}

impl EvolutionaryLayer for MultiHeadAttention {
    fn param_count(&self) -> usize {
        4 * self.d_model * (self.d_model + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }
        let d = self.d_model;
        let d2 = d * d;

        self.w_q.copy_from_slice(&weights[0..d2]);
        self.w_k.copy_from_slice(&weights[d2..2*d2]);
        self.w_v.copy_from_slice(&weights[2*d2..3*d2]);
        self.w_o.copy_from_slice(&weights[3*d2..4*d2]);

        let b_offset = 4 * d2;
        self.b_q.copy_from_slice(&weights[b_offset..b_offset + d]);
        self.b_k.copy_from_slice(&weights[b_offset + d..b_offset + 2*d]);
        self.b_v.copy_from_slice(&weights[b_offset + 2*d..b_offset + 3*d]);
        self.b_o.copy_from_slice(&weights[b_offset + 3*d..expected]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_q);
        out.extend_from_slice(&self.w_k);
        out.extend_from_slice(&self.w_v);
        out.extend_from_slice(&self.w_o);
        out.extend_from_slice(&self.b_q);
        out.extend_from_slice(&self.b_k);
        out.extend_from_slice(&self.b_v);
        out.extend_from_slice(&self.b_o);
        out
    }
}


6. Superbloki: Transformer Encoder i Decoder

Superbloki grupują warstwy MHA, Normalizację Warstwową (LayerNorm) oraz dwuwarstwowy blok Feed-Forward (FFN).

6.1 Normalizacja Warstwowa (LayerNorm)

Dla wektora wejściowego $\mathbf{x} \in \mathbb{R}^{D}$:


$$\mu = \frac{1}{D} \sum_{i=1}^{D} x_i, \quad \sigma^2 = \frac{1}{D} \sum_{i=1}^{D} (x_i - \mu)^2$$

$$\text{LayerNorm}(\mathbf{x})_i = \gamma_i \cdot \frac{x_i - \mu}{\sqrt{\sigma^2 + \epsilon}} + \beta_i$$

Gdzie $\boldsymbol{\gamma}$ (skala) oraz $\boldsymbol{\beta}$ (przesunięcie) są uczalnymi wektorami o rozmiarze $D$.

/// Moduł LayerNorm stabilizujący aktywacje w transformerach.
pub struct LayerNorm {
    pub d_model: usize,
    pub gamma: Vec<f32>,
    pub beta: Vec<f32>,
    pub epsilon: f32,
}

impl LayerNorm {
    /// Przeprowadza normalizację warstwy.
    pub fn forward(&self, x: &[f32]) -> Vec<f32> {
        let n = x.len();
        let mean: f32 = x.iter().sum::<f32>() / n as f32;
        let variance: f32 = x.iter().map(|&val| (val - mean).powi(2)).sum::<f32>() / n as f32;
        let std_dev = (variance + self.epsilon).sqrt();

        x.iter()
            .enumerate()
            .map(|(i, &val)| self.gamma[i] * (val - mean) / std_dev + self.beta[i])
            .collect()
    }
}


6.2 Transformer Encoder Block

Łączy wszystkie pod-warstwy w jeden niezależny blok głęboki.

Wejście (X) ──> Multi-Head Attention ──> (+) ──> LayerNorm ──> Feed-Forward ──> (+) ──> LayerNorm ──> Wyjście
                 │                        ^                    │               ^
                 └────────────────────────┘                    └───────────────┘


Układ Parametrów w Genomie Encoder Block

Parametry MHA ($4 D^2 + 4D$)

Parametry LayerNorm 1 ($2 D$)

Parametry LayerNorm 2 ($2 D$)

Parametry FFN 1: Waga rzutowania w górę ($D \times D_{ff}$) + bias ($D_{ff}$)

Parametry FFN 2: Waga rzutowania w dół ($D_{ff} \times D$) + bias ($D$)

/// Kompletny superblock Encodera Transformera.
pub struct TransformerEncoderBlock {
    pub attention: MultiHeadAttention,
    pub norm1: LayerNorm,
    pub norm2: LayerNorm,
    pub ffn_w1: Vec<f32>, // [d_model, d_ff]
    pub ffn_b1: Vec<f32>, // [d_ff]
    pub ffn_w2: Vec<f32>, // [d_ff, d_model]
    pub ffn_b2: Vec<f32>, // [d_model]
    pub d_model: usize,
    pub d_ff: usize,
}


7. Dynamiczny Graf Obliczeniowy (engine.rs)

Zamiast monolitycznej struktury, implementujemy elastyczny mechanizm LurekNeuralEngine, który potrafi zbudować sieć o dowolnym kształcie warstwowym.

/// Rodzaje bloków funkcjonalnych obsługiwanych przez silnik LurekNeuralEngine.
pub enum NeuralBlock {
    /// Warstwa w pełni połączona (Dense).
    Dense(crate::learning::neural_net::NeuralLayer),
    /// Warstwa splotowa.
    Conv2D(Conv2D),
    /// Redukcja przestrzenna.
    MaxPool2D(MaxPool2D),
    /// Długa pamięć krótkotrwała.
    LSTM(LstmLayer),
    /// Blok transformera.
    TransformerEncoder(TransformerEncoderBlock),
}


Dzięki zaimplementowaniu EvolutionaryLayer dla każdego wariantu z osobna, cały silnik potrafi bez wysiłku dokonać spłaszczenia struktur do jednego genomu.

8. Projekt Lua API (Cienkie Bindingi)

Zgodnie ze standardem Thin Wrapper Rule, bindingi w src/lua_api/learning_api.rs zajmują się wyłącznie walidacją danych na granicy, parsowaniem do typów Rust oraz obsługą błędów o jednolitym formacie lurek.learning.<function>:.

8.1 Implementacja Wrapperów w Rust

//! `lurek.learning` — Zaawansowane komponenty sieci neuronowych i tensorów.

use super::SharedState;
use crate::learning::tensor::LurekTensor;
use crate::learning::recurrent::LstmLayer;
use mlua::prelude::*;

// ── LuaTensor ────────────────────────────────────────────────────────────────

/// Lua-widoczny uchwyt do wielwymiarowego tensora f32 na CPU.
pub struct LuaTensor {
    pub inner: LurekTensor,
}

impl LuaUserData for LuaTensor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Zwraca nazwę typu w formacie Lurek2D.
        /// @return | string | Zwraca ciąg `"LTensor"`.
        methods.add_method("type", |_, _, ()| Ok("LTensor"));

        // -- typeOf --
        /// Sprawdza dziedziczenie typu.
        /// @param | name | string | Nazwa typu do sprawdzenia.
        /// @return | boolean | True, jeżeli typ pasuje.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTensor" || name == "LObject")
        });

        // -- shape --
        /// Zwraca tablicę określającą wymiary tensora.
        /// @return | table | Array liczb całkowitych reprezentujący wymiary.
        methods.add_method("shape", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &dim) in this.inner.shape.iter().enumerate() {
                tbl.set(i + 1, dim)?;
            }
            Ok(tbl)
        });

        // -- data --
        /// Zwraca płaską tablicę wszystkich danych w tensorze.
        /// @return | table | Array liczb zmiennoprzecinkowych.
        methods.add_method("data", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &val) in this.inner.data.iter().enumerate() {
                tbl.set(i + 1, val)?;
            }
            Ok(tbl)
        });

        // -- flatten --
        /// Spłaszcza tensor in-place lub zwraca nowy spłaszczony tensor.
        /// @return | LTensor | Spłaszczona instancja tensora.
        methods.add_method("flatten", |lua, this, ()| {
            lua.create_userdata(LuaTensor {
                inner: this.inner.flatten()
            })
        });
    }
}

// ── LuaLSTM ──────────────────────────────────────────────────────────────────

/// Lua-widoczny uchwyt dla warstwy LSTM utrzymujący swój stan ukryty na przestrzeni klatek.
pub struct LuaLSTM {
    pub inner: LstmLayer,
    pub hidden_state: Vec<f32>,
    pub cell_state: Vec<f32>,
}

impl LuaUserData for LuaLSTM {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Zwraca nazwę typu w formacie Lurek2D.
        /// @return | string | Zwraca ciąg `"LLSTM"`.
        methods.add_method("type", |_, _, ()| Ok("LLSTM"));

        // -- typeOf --
        /// Sprawdza dziedziczenie typu.
        /// @param | name | string | Nazwa typu do sprawdzenia.
        /// @return | boolean | True, jeżeli typ pasuje.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLSTM" || name == "LObject")
        });

        // -- forward --
        /// Wykonuje jeden krok czasowy sieci neuronowej LSTM.
        /// @param | input | table | Płaska tablica wejściowa o rozmiarze równym input_size.
        /// @return | table | Tablica wyjściowa (nowy stan ukryty) o rozmiarze hidden_size.
        methods.add_method_mut("forward", |lua, this, input: Vec<f32>| {
            if input.len() != this.inner.input_size {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.learning.lstm.forward: rozmiar wejścia ({}) nie pasuje do zadeklarowanego wejścia ({})",
                    input.len(),
                    this.inner.input_size
                )));
            }
            let (next_h, next_c) = this.inner.step(&input, &this.hidden_state, &this.cell_state);
            this.hidden_state = next_h.clone();
            this.cell_state = next_c;

            let tbl = lua.create_table()?;
            for (i, &val) in next_h.iter().enumerate() {
                tbl.set(i + 1, val)?;
            }
            Ok(tbl)
        });

        // -- reset --
        /// Resetuje wewnętrzne bufory stanu ukrytego i komórki do wartości zerowych.
        /// @return | nil | Brak zwracanej wartości.
        methods.add_method_mut("reset", |_, this, ()| {
            this.hidden_state = vec![0.0; this.inner.hidden_size];
            this.cell_state = vec![0.0; this.inner.hidden_size];
            Ok(())
        });

        // -- setWeights --
        /// Ustala wagi i biasy warstwy pobierając płaski genom.
        /// @param | genome | table | Tablica f32 reprezentująca spłaszczone wagi.
        /// @return | boolean | True, jeżeli proces przebiegł pomyślnie.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.inner.set_weights(&weights))
        });

        // -- getWeights --
        /// Pobiera płaski bufor parametrów warstwy.
        /// @return | table | Płaska tablica f32 parametrów.
        methods.add_method("getWeights", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &val) in this.inner.get_weights().iter().enumerate() {
                tbl.set(i + 1, val)?;
            }
            Ok(tbl)
        });
    }
}


9. Szczegółowy Plan Działań (Master Plan dla Agenta AI)

Prace nad wdrożeniem nowych bloków w silniku Antigravity zostają podzielone na pięć zdefiniowanych faz. Każda faza kończy się bramką jakości.

┌────────────────────────────────────────────────────────┐
│ FAZA 1: Kręgosłup Matematyczny (Tensory na CPU)       │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 2: Implementacja Warstw (Sploty, LSTM, GRU)       │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 3: Superbloki i Uwaga (Transformers, Encoder)     │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 4: Graf Obliczeniowy i Integracja z Ewolucją     │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 5: Warstwa Lua API, Testy i Dokumentacja API      │
└────────────────────────────────────────────────────────┘


Faza 1: Kręgosłup Matematyczny (Tensors & CPU GEMM)

[ ] Krok 1.1: Utwórz plik src/learning/tensor.rs. Zaimplementuj strukturę LurekTensor oraz algorytm obliczania płaskich indeksów (row-major).

[ ] Krok 1.2: Zaimplementuj funkcję gemm w tensor.rs do mnożenia macierzy wraz z opcją transpozycji i nakładania biasu.

[ ] Krok 1.3: Napisz kompletne testy jednostkowe Rust dla algebry liniowej w tests/rust/unit/tensor_tests.rs. Zweryfikuj poprawność mnożenia macierzy dla różnych wymiarów.

[ ] Krok 1.4: Zarejestruj testy w pliku Cargo.toml.

Faza 2: Warstwy Podstawowe (Sploty i Rekurencje)

[ ] Krok 2.1: Utwórz definicję cechy EvolutionaryLayer w pliku src/learning/neural_net.rs.

[ ] Krok 2.2: Utwórz plik src/learning/conv.rs. Zaimplementuj strukturę Conv2D oraz MaxPool2D w oparciu o silnik tensorowy na CPU. Zapewnij pełną obsługę dopełnień (padding) i kroków przesunięcia (stride).

[ ] Krok 2.3: Zaimplementuj metody EvolutionaryLayer dla warstwy splotowej (dokładne mapowanie parametrów).

[ ] Krok 2.4: Utwórz plik src/learning/recurrent.rs. Zaimplementuj warstwę LstmLayer oraz GruLayer z mechanizmem połączonych macierzy bram (Combined Weights). Zaimplementuj cechę EvolutionaryLayer.

[ ] Krok 2.5: Napisz testy jednostkowe w tests/rust/unit/learning_layers_tests.rs, sprawdzające, czy załadowanie losowych wag, a następnie ich pobranie zwraca identyczny wektor f32 (Roundtrip Test).

Faza 3: Transformery i Mechanizm Uwagi

[ ] Krok 3.1: Utwórz plik src/learning/attention.rs. Zaimplementuj strukturę PositionalEncoding generującą statyczną bazę sinusoidalną o zmiennych częstotliwościach.

[ ] Krok 3.2: Zaimplementuj warstwę MultiHeadAttention w src/learning/attention.rs z podziałem na pod-głowice, mechanizmem Scaled Dot-Product, funkcją Softmax oraz projekcją wyjściową.

[ ] Krok 3.3: Utwórz plik src/learning/transformer.rs. Zaimplementuj pomocniczą strukturę LayerNorm (normalizacja warstwy).

[ ] Krok 3.4: Zaimplementuj superblock TransformerEncoderBlock oraz TransformerDecoderBlock, łącząc MHA, LayerNorm oraz warstwy FFN. Zaimplementuj integrację z płaskim genomem.

Faza 4: Integracja z Systemem Neuroewolucji

[ ] Krok 4.1: Utwórz plik src/learning/engine.rs. Zaimplementuj enum NeuralBlock oraz strukturę LurekNeuralEngine.

[ ] Krok 4.2: Zaimplementuj mechanizm łączenia parametrów dla całego silnika. Silnik musi podsumować param_count() wszystkich swoich pod-bloków i precyzyjnie dzielić płaski wycinek genomu na poszczególne warstwy przy wywołaniu set_weights().

[ ] Krok 4.3: Zmodyfikuj plik src/learning/mod.rs w celu wyeksportowania wszystkich nowych komponentów dla silnika Lurek2D.

Faza 5: Cienkie API Lua, Suita Testowa i Dokumentacja

[ ] Krok 5.1: Zaimplementuj bindings w pliku src/lua_api/learning_api.rs. Utwórz wrappery LuaTensor, LuaLSTM, LuaConv2D, LuaTransformerEncoder itp.

[ ] Krok 5.2: Dodaj pełne, rygorystyczne docstringi do metod w learning_api.rs (separatory // -- method -- oraz tagi @param/@return ze spacjami wokół |).

[ ] Krok 5.3: Zarejestruj moduł learning w rejestratorze bindingów src/lua_api/register.rs.

[ ] Krok 5.4: Napisz rygorystyczne, deterministyczne testy jednostkowe Lua w pliku tests/lua/unit/test_learning_core_unit.lua. Pokryj asercjami:

Konstruktor tensora i poprawność obliczania wymiarów (shape/flatten).

Konstruktor LSTM, krok forward() i reset stanu.

Pomyślne ładowanie spłaszczonych wag genomu i ich poprawny podział.

[ ] Krok 5.5: Zarejestruj plik testowy Lua w tests/lua/harness.rs.

[ ] Krok 5.6: Uruchom proces generowania i walidacji API:

python tools/docs/gen_lua_api_data.py
python tools/docs/gen_luadoc.py
python tools/docs/gen_extension_api.py
python tools/validate/validate_lua_api.py


[ ] Krok 5.7: Uruchom komplet testów silnika (cargo test) i clippy, upewniając się, że nie występują żadne ostrzeżenia ani błędy kompilacji. Zmiany udokumentuj w docs/CHANGELOG.md.

Koniec Specyfikacji Technicznej. Dokument gotowy do wdrożenia przez Agenta AI.



Lurek2D — Plan Rozszerzenia Modułu Learning (LSTM, ConvNet, Transformers)Ten dokument stanowi szczegółową specyfikację techniczną, matematyczną i architektoniczną rozbudowy modułu learning/ w silniku Lurek2D. Plik służy jako kompletny plan wdrożeniowy dla Agenta AI realizującego zadanie w środowisku Antigravity.1. Założenia Matematyczne i ArchitektoniczneWszystkie nowe bloki sieci neuronowych muszą współpracować z algorytmem genetycznym (genetic.rs). W tym celu każda struktura warstwy musi jednoznacznie definiować schemat serializacji swoich wag (filtrów, macierzy projekcji, biasów) do i z płaskiej tablicy Vec<f32> (bufor genomu).1.1 Kontrakt Genetyczny: EvolutionaryLayerW pliku src/learning/neural_net.rs (lub nowym dedykowanym module) wprowadzamy cechę EvolutionaryLayer:/// Kontrakt dla warstw sieci neuronowych umożliwiający ich bezpośrednie użycie w procesach neuroewolucji.
pub trait EvolutionaryLayer {
    /// Zwraca całkowitą liczbę uczalnych parametrów (wagi + biasy) w danej warstwie.
    fn param_count(&self) -> usize;

    /// Nadpisuje wagi i biasy warstwy wartościami z płaskiego bufora f32.
    /// Zwraca false, jeżeli rozmiar bufora nie jest zgodny z geometrią warstwy.
    fn set_weights(&mut self, weights: &[f32]) -> bool;

    /// Zwraca płaski bufor f32 reprezentujący aktualny stan wszystkich uczalnych wag i biasów warstwy.
    fn get_weights(&self) -> Vec<f32>;
}
1.2 Format Layoutu Płaskiego GenomuDla zachowania pełnej deterministyczności, każda warstwa musi zapisywać swoje parametry w ściśle określonej kolejności:Macierze wag (zawsze w układzie wierszowym — Row-Major / C-Contiguous).Wektory biasów (jeżeli występują).W przypadku warstw złożonych (np. LSTM, MHA), wagi poszczególnych bram lub projekcji są łączone w jeden blok w kolejności opisanej w rozdziałach szczegółowych.2. Podstawa Matematyczna: Silnik Tensorowy (tensor.rs)Zamiast polegać na ciężkich bibliotekach zewnętrznych, tworzymy lekki, zoptymalizowany pod kątem CPU silnik tensorowy obsługujący dowolną liczbę wymiarów.//! - Podstawowy moduł algebry liniowej dla struktur wielowymiarowych na CPU.
//! - Wspiera układy wierszowe (Row-Major), zmianę kształtów (reshape) oraz operacje elementowe.

/// Flat f32 tensor z jawną metadaną kształtu (row-major).
#[derive(Debug, Clone)]
pub struct LurekTensor {
    /// Rozmiary wymiarów tensora.
    pub shape: Vec<usize>,
    /// Płaski bufor danych typu f32.
    pub data: Vec<f32>,
}

impl LurekTensor {
    /// Tworzy nowy tensor z określonym kształtem i danymi. Podlega walidacji rozmiaru.
    pub fn new(shape: Vec<usize>, data: Vec<f32>) -> Self {
        let expected_len: usize = shape.iter().product();
        assert_eq!(
            expected_len,
            data.len(),
            "Rozmiar danych {} nie pasuje do wymiarów kształtu {:?}",
            data.len(),
            shape
        );
        Self { shape, data }
    }

    /// Tworzy tensor wypełniony zerami o podanym kształcie.
    pub fn zeros(shape: Vec<usize>) -> Self {
        let size = shape.iter().product();
        Self {
            shape,
            data: vec![0.0; size],
        }
    }

    /// Oblicza płaski indeks w buforze jednowymiarowym na podstawie współrzędnych wielowymiarowych.
    pub fn flat_index(&self, indices: &[usize]) -> Option<usize> {
        if indices.len() != self.shape.len() {
            return None;
        }
        let mut idx = 0usize;
        let mut stride = 1usize;
        for (&i, &s) in indices.iter().zip(self.shape.iter()).rev() {
            if i >= s {
                return None;
            }
            idx += i * stride;
            stride *= s;
        }
        Some(idx)
    }

    /// Spłaszcza tensor do jednowymiarowego kształtu [length].
    pub fn flatten(&self) -> Self {
        Self {
            shape: vec![self.data.len()],
            data: self.data.clone(),
        }
    }
}
2.1 Mnożenie Macierzy (General Matrix Multiply — GEMM)Do obsługi warstw liniowych, LSTM, GRU oraz Attention potrzebujemy natywnego mnożenia macierzy dwuwymiarowych:$$\mathbf{C} = \mathbf{A} \mathbf{B} + \mathbf{\beta}$$Mnożenie $\mathbf{A} \in \mathbb{R}^{M \times K}$ przez $\mathbf{B} \in \mathbb{R}^{K \times N}$ z biasem $\mathbf{b} \in \mathbb{R}^{N}$:/// Mnoży macierz A [M x K] przez B [K x N] i dodaje opcjonalny wektor biasu o długości N.
pub fn gemm(
    m: usize,
    k: usize,
    n: usize,
    a: &[f32],
    b: &[f32],
    bias: Option<&[f32]>,
) -> Vec<f32> {
    let mut out = vec![0.0; m * n];
    for i in 0..m {
        for j in 0..n {
            let mut sum = if let Some(b_val) = bias { b_val[j] } else { 0.0 };
            for p in 0..k {
                sum += a[i * k + p] * b[p * n + j];
            }
            out[i * n + j] = sum;
        }
    }
    out
}
3. Blok: Sploty i Pooling (ConvNet)3.1 Warstwa Conv2DWarstwa splotu 2D przetwarza trójwymiarowe tensory wejściowe o wymiarach $[C, H, W]$, gdzie $C$ to liczba kanałów (np. kanały tekstur, mapy wysokości), a $H, W$ to wysokość i szerokość przestrzenna.Matematyka SplotuDla wyjściowego kanału $f \in [0, F)$, wejściowego kanału $c \in [0, C)$, oraz pozycji przestrzennej $(y, x)$ na wyjściu:$$\mathbf{Y}_{f, y, x} = b_f + \sum_{c=0}^{C-1} \sum_{i=0}^{K_h-1} \sum_{j=0}^{K_w-1} \mathbf{X}_{c, y \cdot S_h + i - P_h, x \cdot S_w + j - P_w} \cdot \mathbf{W}_{f, c, i, j}$$Gdzie:$F$ — liczba filtrów wyjściowych (out_channels),$C$ — liczba kanałów wejściowych (in_channels),$K_h, K_w$ — wymiary jądra splotu (kernel size),$S_h, S_w$ — krok przesunięcia (stride),$P_h, P_w$ — dopełnienie (padding).Struktura Rust i Układ WagWszystkie wagi splotu są przechowywane w płaskim buforze o rozmiarze:$$\text{Liczba Parametrów} = F \cdot C \cdot K_h \cdot K_w + F$$Kolejność w genomie: [F, C, Kh, Kw] dla wag, a następnie [F] dla biasów./// Warstwa splotowa Conv2D dla CPU.
pub struct Conv2D {
    pub in_channels: usize,
    pub out_channels: usize,
    pub kernel_size: (usize, usize),
    pub stride: (usize, usize),
    pub padding: (usize, usize),
    pub weights: Vec<f32>, // Rozmiar: out_channels * in_channels * kh * kw
    pub biases: Vec<f32>,  // Rozmiar: out_channels
}

impl EvolutionaryLayer for Conv2D {
    fn param_count(&self) -> usize {
        self.out_channels * self.in_channels * self.kernel_size.0 * self.kernel_size.1 + self.out_channels
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }
        let w_size = self.out_channels * self.in_channels * self.kernel_size.0 * self.kernel_size.1;
        self.weights.copy_from_slice(&weights[0..w_size]);
        self.biases.copy_from_slice(&weights[w_size..expected]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.weights);
        out.extend_from_slice(&self.biases);
        out
    }
}
3.2 Warstwa MaxPool2DSłuży do redukcji wymiarów przestrzennych bez wprowadzania dodatkowych uczalnych wag (nie implementuje EvolutionaryLayer, zwraca 0 parametrów).Matematyka Max PoolDla każdego kanału $c$ oraz lokalnego okna o wymiarach $K_h \times K_w$ wyjściem jest wartość maksymalna:$$\mathbf{Y}_{c, y, x} = \max_{i \in [0, K_h), j \in [0, K_w)} \mathbf{X}_{c, y \cdot S_h + i, x \cdot S_w + j}$$/// Warstwa redukcji przestrzennej MaxPool2D.
pub struct MaxPool2D {
    pub kernel_size: (usize, usize),
    pub stride: (usize, usize),
}

impl MaxPool2D {
    /// Przeprowadza forward pass redukcji wymiarów na tensorze wejściowym.
    pub fn forward(&self, input: &LurekTensor) -> LurekTensor {
        let channels = input.shape[0];
        let in_h = input.shape[1];
        let in_w = input.shape[2];

        let out_h = (in_h - self.kernel_size.0) / self.stride.0 + 1;
        let out_w = (in_w - self.kernel_size.1) / self.stride.1 + 1;

        let mut out_data = vec![0.0; channels * out_h * out_w];

        for c in 0..channels {
            for oh in 0..out_h {
                for ow in 0..out_w {
                    let mut max_val = f32::NEG_INFINITY;
                    for kh in 0..self.kernel_size.0 {
                        for kw in 0..self.kernel_size.1 {
                            let ih = oh * self.stride.0 + kh;
                            let iw = ow * self.stride.1 + kw;
                            let idx = c * (in_h * in_w) + ih * in_w + iw;
                            let val = input.data[idx];
                            if val > max_val {
                                max_val = val;
                            }
                        }
                    }
                    let out_idx = c * (out_h * out_w) + oh * out_w + ow;
                    out_data[out_idx] = max_val;
                }
            }
        }
        LurekTensor::new(vec![channels, out_h, out_w], out_data)
    }
}
4. Warstwy Rekurencyjne (LSTM i GRU)Służą do budowania ciągłej pamięci sekwencyjnej u agentów AI.4.1 LSTM (Long Short-Term Memory)Warstwa LSTM operuje na wejściu $\mathbf{x}_t \in \mathbb{R}^{D}$, poprzednim stanie ukrytym $\mathbf{h}_{t-1} \in \mathbb{R}^{H}$ i poprzednim stanie komórki $\mathbf{c}_{t-1} \in \mathbb{R}^{H}$.Bramy LSTM$$\mathbf{f}_t = \sigma(\mathbf{W}_f \mathbf{x}_t + \mathbf{U}_f \mathbf{h}_{t-1} + \mathbf{b}_f) \quad \text{(brama zapominania)}$$$$\mathbf{i}_t = \sigma(\mathbf{W}_i \mathbf{x}_t + \mathbf{U}_i \mathbf{h}_{t-1} + \mathbf{b}_i) \quad \text{(brama wejściowa)}$$$$\tilde{\mathbf{c}}_t = \tanh(\mathbf{W}_c \mathbf{x}_t + \mathbf{U}_c \mathbf{h}_{t-1} + \mathbf{b}_c) \quad \text{(kandydat na stan komórki)}$$$$\mathbf{c}_t = \mathbf{f}_t \odot \mathbf{c}_{t-1} + \mathbf{i}_t \odot \tilde{\mathbf{c}}_t \quad \text{(nowy stan komórki)}$$$$\mathbf{o}_t = \sigma(\mathbf{W}_o \mathbf{x}_t + \mathbf{U}_o \mathbf{h}_{t-1} + \mathbf{b}_o) \quad \text{(brama wyjściowa)}$$$$\mathbf{h}_t = \mathbf{o}_t \odot \tanh(\mathbf{c}_t) \quad \text{(nowy stan ukryty)}$$Układ Wag w Genomie (Combined Weight Matrix)Aby zminimalizować liczbę operacji mnożenia macierzy, wagi wszystkich czterech bram są łączone w jedną dużą macierz rzutowania wejścia $\mathbf{W}_{gate} \in \mathbb{R}^{4H \times D}$ oraz macierz rzutowania stanu ukrytego $\mathbf{U}_{gate} \in \mathbb{R}^{4H \times H}$:$$\mathbf{W}_{gate} = \begin{bmatrix} \mathbf{W}_i \\ \mathbf{W}_f \\ \mathbf{W}_c \\ \mathbf{W}_o \end{bmatrix}, \quad \mathbf{U}_{gate} = \begin{bmatrix} \mathbf{U}_i \\ \mathbf{U}_f \\ \mathbf{U}_c \\ \mathbf{U}_o \end{bmatrix}, \quad \mathbf{b}_{gate} = \begin{bmatrix} \mathbf{b}_i \\ \mathbf{b}_f \\ \mathbf{b}_c \\ \mathbf{b}_o \end{bmatrix}$$$$\text{Całkowita Liczba Parametrów} = 4 \cdot H \cdot D + 4 \cdot H \cdot H + 4 \cdot H = 4 \cdot H \cdot (D + H + 1)$$Kolejność w płaskim genomie:W_gate (rozmiar $4 \cdot H \cdot D$)U_gate (rozmiar $4 \cdot H \cdot H$)b_gate (rozmiar $4 \cdot H$)/// Zunifikowana warstwa LSTM na CPU.
pub struct LstmLayer {
    pub input_size: usize,
    pub hidden_size: usize,
    /// Połączone wagi bram wejściowych: [4 * hidden_size, input_size]
    pub w_gate: Vec<f32>,
    /// Połączone wagi bram stanów ukrytych: [4 * hidden_size, hidden_size]
    pub u_gate: Vec<f32>,
    /// Połączone biasy bram: [4 * hidden_size]
    pub b_gate: Vec<f32>,
}

impl LstmLayer {
    /// Wykonuje pojedynczy krok rekurencyjny. Zwraca nowy stan ukryty i stan komórki.
    pub fn step(&self, x: &[f32], prev_h: &[f32], prev_c: &[f32]) -> (Vec<f32>, Vec<f32>) {
        let h = self.hidden_size;

        // Obliczenie rzutowań: gates = W_gate * x + U_gate * prev_h + b_gate
        let mut gates = vec![0.0; 4 * h];
        for g in 0..(4 * h) {
            let mut sum = self.b_gate[g];
            for i in 0..self.input_size {
                sum += self.w_gate[g * self.input_size + i] * x[i];
            }
            for j in 0..h {
                sum += self.u_gate[g * h + j] * prev_h[j];
            }
            gates[g] = sum;
        }

        let mut next_h = vec![0.0; h];
        let mut next_c = vec![0.0; h];

        // Wyodrębnienie bram i aktywacja (sigmoidy i tanh)
        for i in 0..h {
            let in_gate = 1.0 / (1.0 + (-gates[i]).exp());
            let forget_gate = 1.0 / (1.0 + (-gates[h + i]).exp());
            let cell_candidate = gates[2 * h + i].tanh();
            let out_gate = 1.0 / (1.0 + (-gates[3 * h + i]).exp());

            next_c[i] = forget_gate * prev_c[i] + in_gate * cell_candidate;
            next_h[i] = out_gate * next_c[i].tanh();
        }

        (next_h, next_c)
    }
}

impl EvolutionaryLayer for LstmLayer {
    fn param_count(&self) -> usize {
        4 * self.hidden_size * (self.input_size + self.hidden_size + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }
        let h = self.hidden_size;
        let d = self.input_size;

        let w_offset = 4 * h * d;
        let u_offset = w_offset + 4 * h * h;

        self.w_gate.copy_from_slice(&weights[0..w_offset]);
        self.u_gate.copy_from_slice(&weights[w_offset..u_offset]);
        self.b_gate.copy_from_slice(&weights[u_offset..expected]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_gate);
        out.extend_from_slice(&self.u_gate);
        out.extend_from_slice(&self.b_gate);
        out
    }
}
4.2 GRU (Gated Recurrent Unit)GRU łączy bramę zapominania i wejściową w jedną bramę aktualizacji, co redukuje liczbę wymaganych wag.Matematyka GRU$$\mathbf{z}_t = \sigma(\mathbf{W}_z \mathbf{x}_t + \mathbf{U}_z \mathbf{h}_{t-1} + \mathbf{b}_z) \quad \text{(brama aktualizacji)}$$$$\mathbf{r}_t = \sigma(\mathbf{W}_r \mathbf{x}_t + \mathbf{U}_r \mathbf{h}_{t-1} + \mathbf{b}_r) \quad \text{(brama resetowania)}$$$$\tilde{\mathbf{h}}_t = \tanh(\mathbf{W}_h \mathbf{x}_t + \mathbf{U}_h (\mathbf{r}_t \odot \mathbf{h}_{t-1}) + \mathbf{b}_h) \quad \text{(kandydat do stanu ukrytego)}$$$$\mathbf{h}_t = (1 - \mathbf{z}_t) \odot \mathbf{h}_{t-1} + \mathbf{z}_t \odot \tilde{\mathbf{h}}_t \quad \text{(nowy stan ukryty)}$$Układ Wag w Genomie (GRU)$$\mathbf{W}_{gru} = \begin{bmatrix} \mathbf{W}_z \\ \mathbf{W}_r \\ \mathbf{W}_h \end{bmatrix}, \quad \mathbf{U}_{gru} = \begin{bmatrix} \mathbf{U}_z \\ \mathbf{U}_r \\ \mathbf{U}_h \end{bmatrix}, \quad \mathbf{b}_{gru} = \begin{bmatrix} \mathbf{b}_z \\ \mathbf{b}_r \\ \mathbf{b}_h \end{bmatrix}$$$$\text{Całkowita Liczba Parametrów} = 3 \cdot H \cdot (D + H + 1)$$5. Blok: Transformers i Attention5.1 Kodowanie Pozycyjne (Positional Encoding)Zapewnia geometryczną informację o kolejności tokenów w sekwencji. Dla długości sekwencji $S$ oraz wymiaru modelu $D$:$$\mathbf{PE}_{pos, 2i} = \sin\left(\frac{pos}{10000^{2i/D}}\right)$$$$\mathbf{PE}_{pos, 2i+1} = \cos\left(\frac{pos}{10000^{2i/D}}\right)$$Wspornik ten nie zawiera parametrów podlegających ewolucji./// Zapewnia dodawanie wektorów pozycyjnych do osadzenia sekwencji.
pub struct PositionalEncoding {
    pub d_model: usize,
    pub max_len: usize,
    pub encoding: Vec<f32>,
}

impl PositionalEncoding {
    /// Inicjalizuje statyczną tablicę wartości sinusoidalnych i kosinusoidalnych.
    pub fn new(d_model: usize, max_len: usize) -> Self {
        let mut encoding = vec![0.0; max_len * d_model];
        for pos in 0..max_len {
            for i in (0..d_model).step_by(2) {
                let div_term = 10000.0f32.powf((i as f32) / (d_model as f32));
                encoding[pos * d_model + i] = ((pos as f32) / div_term).sin();
                if i + 1 < d_model {
                    encoding[pos * d_model + i + 1] = ((pos as f32) / div_term).cos();
                }
            }
        }
        Self { d_model, max_len, encoding }
    }

    /// Dodaje wektory PE bezpośrednio do przesłanego tensora [SeqLen, d_model] in-place.
    pub fn apply(&self, x: &mut LurekTensor) {
        let seq_len = x.shape[0];
        let d = x.shape[1];
        assert_eq!(d, self.d_model, "Niezgodność d_model");
        for pos in 0..seq_len {
            for i in 0..d {
                x.data[pos * d + i] += self.encoding[pos * d + i];
            }
        }
    }
}
5.2 Multi-Head Attention (MHA)Warstwa Multi-Head Attention dzieli wymiar wejściowy $D$ na $H$ odrębnych głowic o rozmiarze $d_k = D / H$.Matematyka MHADla wejścia $\mathbf{X} \in \mathbb{R}^{S \times D}$:$$\mathbf{Q} = \mathbf{X} \mathbf{W}_q, \quad \mathbf{K} = \mathbf{X} \mathbf{W}_k, \quad \mathbf{V} = \mathbf{X} \mathbf{W}_v$$Każda głowica $h \in [0, H)$ wycina swoje sub-macierze $\mathbf{Q}_h, \mathbf{K}_h, \mathbf{V}_h \in \mathbb{R}^{S \times d_k}$ i liczy wagę uwagi:$$\mathbf{Head}_h = \text{Softmax}\left(\frac{\mathbf{Q}_h \mathbf{K}_h^T}{\sqrt{d_k}}\right) \mathbf{V}_h$$Wyjście to konkatenacja głowic rzutowana wstecz na przestrzeń wejściową:$$\text{MHA}(\mathbf{X}) = \left[\mathbf{Head}_0 \,\|\, \mathbf{Head}_1 \,\|\, \dots \,\|\, \mathbf{Head}_{H-1}\right] \mathbf{W}_o$$Układ Wag w Genomie (MHA)Macierze projekcji: $\mathbf{W}_q, \mathbf{W}_k, \mathbf{W}_v, \mathbf{W}_o$ (każda o rozmiarze $D \times D$). Dodajemy do każdej opcjonalny bias o długości $D$.$$\text{Całkowita Liczba Parametrów} = 4 \cdot D^2 + 4 \cdot D = 4 \cdot D \cdot (D + 1)$$Kolejność w genomie: W_q, W_k, W_v, W_o, b_q, b_k, b_v, b_o./// Implementacja warstwy Multi-Head Attention na CPU.
pub struct MultiHeadAttention {
    pub d_model: usize,
    pub num_heads: usize,
    pub d_k: usize,
    pub w_q: Vec<f32>, // [d_model, d_model]
    pub w_k: Vec<f32>, // [d_model, d_model]
    pub w_v: Vec<f32>, // [d_model, d_model]
    pub w_o: Vec<f32>, // [d_model, d_model]
    pub b_q: Vec<f32>, // [d_model]
    pub b_k: Vec<f32>, // [d_model]
    pub b_v: Vec<f32>, // [d_model]
    pub b_o: Vec<f32>, // [d_model]
}

impl EvolutionaryLayer for MultiHeadAttention {
    fn param_count(&self) -> usize {
        4 * self.d_model * (self.d_model + 1)
    }

    fn set_weights(&mut self, weights: &[f32]) -> bool {
        let expected = self.param_count();
        if weights.len() != expected {
            return false;
        }
        let d = self.d_model;
        let d2 = d * d;

        self.w_q.copy_from_slice(&weights[0..d2]);
        self.w_k.copy_from_slice(&weights[d2..2*d2]);
        self.w_v.copy_from_slice(&weights[2*d2..3*d2]);
        self.w_o.copy_from_slice(&weights[3*d2..4*d2]);

        let b_offset = 4 * d2;
        self.b_q.copy_from_slice(&weights[b_offset..b_offset + d]);
        self.b_k.copy_from_slice(&weights[b_offset + d..b_offset + 2*d]);
        self.b_v.copy_from_slice(&weights[b_offset + 2*d..b_offset + 3*d]);
        self.b_o.copy_from_slice(&weights[b_offset + 3*d..expected]);
        true
    }

    fn get_weights(&self) -> Vec<f32> {
        let mut out = Vec::with_capacity(self.param_count());
        out.extend_from_slice(&self.w_q);
        out.extend_from_slice(&self.w_k);
        out.extend_from_slice(&self.w_v);
        out.extend_from_slice(&self.w_o);
        out.extend_from_slice(&self.b_q);
        out.extend_from_slice(&self.b_k);
        out.extend_from_slice(&self.b_v);
        out.extend_from_slice(&self.b_o);
        out
    }
}
6. Superbloki: Transformer Encoder i DecoderSuperbloki grupują warstwy MHA, Normalizację Warstwową (LayerNorm) oraz dwuwarstwowy blok Feed-Forward (FFN).6.1 Normalizacja Warstwowa (LayerNorm)Dla wektora wejściowego $\mathbf{x} \in \mathbb{R}^{D}$:$$\mu = \frac{1}{D} \sum_{i=1}^{D} x_i, \quad \sigma^2 = \frac{1}{D} \sum_{i=1}^{D} (x_i - \mu)^2$$$$\text{LayerNorm}(\mathbf{x})_i = \gamma_i \cdot \frac{x_i - \mu}{\sqrt{\sigma^2 + \epsilon}} + \beta_i$$Gdzie $\boldsymbol{\gamma}$ (skala) oraz $\boldsymbol{\beta}$ (przesunięcie) są uczalnymi wektorami o rozmiarze $D$./// Moduł LayerNorm stabilizujący aktywacje w transformerach.
pub struct LayerNorm {
    pub d_model: usize,
    pub gamma: Vec<f32>,
    pub beta: Vec<f32>,
    pub epsilon: f32,
}

impl LayerNorm {
    /// Przeprowadza normalizację warstwy.
    pub fn forward(&self, x: &[f32]) -> Vec<f32> {
        let n = x.len();
        let mean: f32 = x.iter().sum::<f32>() / n as f32;
        let variance: f32 = x.iter().map(|&val| (val - mean).powi(2)).sum::<f32>() / n as f32;
        let std_dev = (variance + self.epsilon).sqrt();

        x.iter()
            .enumerate()
            .map(|(i, &val)| self.gamma[i] * (val - mean) / std_dev + self.beta[i])
            .collect()
    }
}
6.2 Transformer Encoder BlockŁączy wszystkie pod-warstwy w jeden niezależny blok głęboki.Wejście (X) ──> Multi-Head Attention ──> (+) ──> LayerNorm ──> Feed-Forward ──> (+) ──> LayerNorm ──> Wyjście
                 │                        ^                    │               ^
                 └────────────────────────┘                    └───────────────┘
Układ Parametrów w Genomie Encoder BlockParametry MHA ($4 D^2 + 4D$)Parametry LayerNorm 1 ($2 D$)Parametry LayerNorm 2 ($2 D$)Parametry FFN 1: Waga rzutowania w górę ($D \times D_{ff}$) + bias ($D_{ff}$)Parametry FFN 2: Waga rzutowania w dół ($D_{ff} \times D$) + bias ($D$)/// Kompletny superblock Encodera Transformera.
pub struct TransformerEncoderBlock {
    pub attention: MultiHeadAttention,
    pub norm1: LayerNorm,
    pub norm2: LayerNorm,
    pub ffn_w1: Vec<f32>, // [d_model, d_ff]
    pub ffn_b1: Vec<f32>, // [d_ff]
    pub ffn_w2: Vec<f32>, // [d_ff, d_model]
    pub ffn_b2: Vec<f32>, // [d_model]
    pub d_model: usize,
    pub d_ff: usize,
}
7. Dynamiczny Graf Obliczeniowy (engine.rs)Zamiast monolitycznej struktury, implementujemy elastyczny mechanizm LurekNeuralEngine, który potrafi zbudować sieć o dowolnym kształcie warstwowym./// Rodzaje bloków funkcjonalnych obsługiwanych przez silnik LurekNeuralEngine.
pub enum NeuralBlock {
    /// Warstwa w pełni połączona (Dense).
    Dense(crate::learning::neural_net::NeuralLayer),
    /// Warstwa splotowa.
    Conv2D(Conv2D),
    /// Redukcja przestrzenna.
    MaxPool2D(MaxPool2D),
    /// Długa pamięć krótkotrwała.
    LSTM(LstmLayer),
    /// Blok transformera.
    TransformerEncoder(TransformerEncoderBlock),
}
Dzięki zaimplementowaniu EvolutionaryLayer dla każdego wariantu z osobna, cały silnik potrafi bez wysiłku dokonać spłaszczenia struktur do jednego genomu.8. Projekt Lua API (Cienkie Bindingi)Zgodnie ze standardem Thin Wrapper Rule, bindingi w src/lua_api/learning_api.rs zajmują się wyłącznie walidacją danych na granicy, parsowaniem do typów Rust oraz obsługą błędów o jednolitym formacie lurek.learning.<function>:.8.1 Implementacja Wrapperów w Rust//! `lurek.learning` — Zaawansowane komponenty sieci neuronowych i tensorów.

use super::SharedState;
use crate::learning::tensor::LurekTensor;
use crate::learning::recurrent::LstmLayer;
use mlua::prelude::*;

// ── LuaTensor ────────────────────────────────────────────────────────────────

/// Lua-widoczny uchwyt do wielwymiarowego tensora f32 na CPU.
pub struct LuaTensor {
    pub inner: LurekTensor,
}

impl LuaUserData for LuaTensor {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Zwraca nazwę typu w formacie Lurek2D.
        /// @return | string | Zwraca ciąg `"LTensor"`.
        methods.add_method("type", |_, _, ()| Ok("LTensor"));

        // -- typeOf --
        /// Sprawdza dziedziczenie typu.
        /// @param | name | string | Nazwa typu do sprawdzenia.
        /// @return | boolean | True, jeżeli typ pasuje.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LTensor" || name == "LObject")
        });

        // -- shape --
        /// Zwraca tablicę określającą wymiary tensora.
        /// @return | table | Array liczb całkowitych reprezentujący wymiary.
        methods.add_method("shape", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &dim) in this.inner.shape.iter().enumerate() {
                tbl.set(i + 1, dim)?;
            }
            Ok(tbl)
        });

        // -- data --
        /// Zwraca płaską tablicę wszystkich danych w tensorze.
        /// @return | table | Array liczb zmiennoprzecinkowych.
        methods.add_method("data", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &val) in this.inner.data.iter().enumerate() {
                tbl.set(i + 1, val)?;
            }
            Ok(tbl)
        });

        // -- flatten --
        /// Spłaszcza tensor in-place lub zwraca nowy spłaszczony tensor.
        /// @return | LTensor | Spłaszczona instancja tensora.
        methods.add_method("flatten", |lua, this, ()| {
            lua.create_userdata(LuaTensor {
                inner: this.inner.flatten()
            })
        });
    }
}

// ── LuaLSTM ──────────────────────────────────────────────────────────────────

/// Lua-widoczny uchwyt dla warstwy LSTM utrzymujący swój stan ukryty na przestrzeni klatek.
pub struct LuaLSTM {
    pub inner: LstmLayer,
    pub hidden_state: Vec<f32>,
    pub cell_state: Vec<f32>,
}

impl LuaUserData for LuaLSTM {
    fn add_methods<'lua, M: LuaUserDataMethods<'lua, Self>>(methods: &mut M) {
        // -- type --
        /// Zwraca nazwę typu w formacie Lurek2D.
        /// @return | string | Zwraca ciąg `"LLSTM"`.
        methods.add_method("type", |_, _, ()| Ok("LLSTM"));

        // -- typeOf --
        /// Sprawdza dziedziczenie typu.
        /// @param | name | string | Nazwa typu do sprawdzenia.
        /// @return | boolean | True, jeżeli typ pasuje.
        methods.add_method("typeOf", |_, _, name: String| {
            Ok(name == "LLSTM" || name == "LObject")
        });

        // -- forward --
        /// Wykonuje jeden krok czasowy sieci neuronowej LSTM.
        /// @param | input | table | Płaska tablica wejściowa o rozmiarze równym input_size.
        /// @return | table | Tablica wyjściowa (nowy stan ukryty) o rozmiarze hidden_size.
        methods.add_method_mut("forward", |lua, this, input: Vec<f32>| {
            if input.len() != this.inner.input_size {
                return Err(LuaError::RuntimeError(format!(
                    "lurek.learning.lstm.forward: rozmiar wejścia ({}) nie pasuje do zadeklarowanego wejścia ({})",
                    input.len(),
                    this.inner.input_size
                )));
            }
            let (next_h, next_c) = this.inner.step(&input, &this.hidden_state, &this.cell_state);
            this.hidden_state = next_h.clone();
            this.cell_state = next_c;

            let tbl = lua.create_table()?;
            for (i, &val) in next_h.iter().enumerate() {
                tbl.set(i + 1, val)?;
            }
            Ok(tbl)
        });

        // -- reset --
        /// Resetuje wewnętrzne bufory stanu ukrytego i komórki do wartości zerowych.
        /// @return | nil | Brak zwracanej wartości.
        methods.add_method_mut("reset", |_, this, ()| {
            this.hidden_state = vec![0.0; this.inner.hidden_size];
            this.cell_state = vec![0.0; this.inner.hidden_size];
            Ok(())
        });

        // -- setWeights --
        /// Ustala wagi i biasy warstwy pobierając płaski genom.
        /// @param | genome | table | Tablica f32 reprezentująca spłaszczone wagi.
        /// @return | boolean | True, jeżeli proces przebiegł pomyślnie.
        methods.add_method_mut("setWeights", |_, this, weights: Vec<f32>| {
            Ok(this.inner.set_weights(&weights))
        });

        // -- getWeights --
        /// Pobiera płaski bufor parametrów warstwy.
        /// @return | table | Płaska tablica f32 parametrów.
        methods.add_method("getWeights", |lua, this, ()| {
            let tbl = lua.create_table()?;
            for (i, &val) in this.inner.get_weights().iter().enumerate() {
                tbl.set(i + 1, val)?;
            }
            Ok(tbl)
        });
    }
}
9. Szczegółowy Plan Działań (Master Plan dla Agenta AI)Prace nad wdrożeniem nowych bloków w silniku Antigravity zostają podzielone na pięć zdefiniowanych faz. Każda faza kończy się bramką jakości.┌────────────────────────────────────────────────────────┐
│ FAZA 1: Kręgosłup Matematyczny (Tensory na CPU)       │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 2: Implementacja Warstw (Sploty, LSTM, GRU)       │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 3: Superbloki i Uwaga (Transformers, Encoder)     │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 4: Graf Obliczeniowy i Integracja z Ewolucją     │
└───────────────────────────┬────────────────────────────┘
                            ▼
┌────────────────────────────────────────────────────────┐
│ FAZA 5: Warstwa Lua API, Testy i Dokumentacja API      │
└────────────────────────────────────────────────────────┘
Faza 1: Kręgosłup Matematyczny (Tensors & CPU GEMM)[ ] Krok 1.1: Utwórz plik src/learning/tensor.rs. Zaimplementuj strukturę LurekTensor oraz algorytm obliczania płaskich indeksów (row-major).[ ] Krok 1.2: Zaimplementuj funkcję gemm w tensor.rs do mnożenia macierzy wraz z opcją transpozycji i nakładania biasu.[ ] Krok 1.3: Napisz kompletne testy jednostkowe Rust dla algebry liniowej w tests/rust/unit/tensor_tests.rs. Zweryfikuj poprawność mnożenia macierzy dla różnych wymiarów.[ ] Krok 1.4: Zarejestruj testy w pliku Cargo.toml.Faza 2: Warstwy Podstawowe (Sploty i Rekurencje)[ ] Krok 2.1: Utwórz definicję cechy EvolutionaryLayer w pliku src/learning/neural_net.rs.[ ] Krok 2.2: Utwórz plik src/learning/conv.rs. Zaimplementuj strukturę Conv2D oraz MaxPool2D w oparciu o silnik tensorowy na CPU. Zapewnij pełną obsługę dopełnień (padding) i kroków przesunięcia (stride).[ ] Krok 2.3: Zaimplementuj metody EvolutionaryLayer dla warstwy splotowej (dokładne mapowanie parametrów).[ ] Krok 2.4: Utwórz plik src/learning/recurrent.rs. Zaimplementuj warstwę LstmLayer oraz GruLayer z mechanizmem połączonych macierzy bram (Combined Weights). Zaimplementuj cechę EvolutionaryLayer.[ ] Krok 2.5: Napisz testy jednostkowe w tests/rust/unit/learning_layers_tests.rs, sprawdzające, czy załadowanie losowych wag, a następnie ich pobranie zwraca identyczny wektor f32 (Roundtrip Test).Faza 3: Transformery i Mechanizm Uwagi[ ] Krok 3.1: Utwórz plik src/learning/attention.rs. Zaimplementuj strukturę PositionalEncoding generującą statyczną bazę sinusoidalną o zmiennych częstotliwościach.[ ] Krok 3.2: Zaimplementuj warstwę MultiHeadAttention w src/learning/attention.rs z podziałem na pod-głowice, mechanizmem Scaled Dot-Product, funkcją Softmax oraz projekcją wyjściową.[ ] Krok 3.3: Utwórz plik src/learning/transformer.rs. Zaimplementuj pomocniczą strukturę LayerNorm (normalizacja warstwy).[ ] Krok 3.4: Zaimplementuj superblock TransformerEncoderBlock oraz TransformerDecoderBlock, łącząc MHA, LayerNorm oraz warstwy FFN. Zaimplementuj integrację z płaskim genomem.Faza 4: Integracja z Systemem Neuroewolucji[ ] Krok 4.1: Utwórz plik src/learning/engine.rs. Zaimplementuj enum NeuralBlock oraz strukturę LurekNeuralEngine.[ ] Krok 4.2: Zaimplementuj mechanizm łączenia parametrów dla całego silnika. Silnik musi podsumować param_count() wszystkich swoich pod-bloków i precyzyjnie dzielić płaski wycinek genomu na poszczególne warstwy przy wywołaniu set_weights().[ ] Krok 4.3: Zmodyfikuj plik src/learning/mod.rs w celu wyeksportowania wszystkich nowych komponentów dla silnika Lurek2D.Faza 5: Cienkie API Lua, Suita Testowa i Dokumentacja[ ] Krok 5.1: Zaimplementuj bindings w pliku src/lua_api/learning_api.rs. Utwórz wrappery LuaTensor, LuaLSTM, LuaConv2D, LuaTransformerEncoder itp.[ ] Krok 5.2: Dodaj pełne, rygorystyczne docstringi do metod w learning_api.rs (separatory // -- method -- oraz tagi @param/@return ze spacjami wokół |).[ ] Krok 5.3: Zarejestruj moduł learning w rejestratorze bindingów src/lua_api/register.rs.[ ] Krok 5.4: Napisz rygorystyczne, deterministyczne testy jednostkowe Lua w pliku tests/lua/unit/test_learning_core_unit.lua. Pokryj asercjami:Konstruktor tensora i poprawność obliczania wymiarów (shape/flatten).Konstruktor LSTM, krok forward() i reset stanu.Pomyślne ładowanie spłaszczonych wag genomu i ich poprawny podział.[ ] Krok 5.5: Zarejestruj plik testowy Lua w tests/lua/harness.rs.[ ] Krok 5.6: Uruchom proces generowania i walidacji API:python tools/docs/gen_lua_api_data.py
python tools/docs/gen_luadoc.py
python tools/docs/gen_extension_api.py
python tools/validate/validate_lua_api.py
[ ] Krok 5.7: Uruchom komplet testów silnika (cargo test) i clippy, upewniając się, że nie występują żadne ostrzeżenia ani błędy kompilacji. Zmiany udokumentuj w docs/CHANGELOG.md.Koniec Specyfikacji Technicznej. Dokument gotowy do wdrożenia przez Agenta AI.
