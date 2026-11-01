# ==============================================================================
# ENTHEAI-FANOUT :: OMNI ULTRA-ONESHOT KICKOFF SPECIFICATION (v1.0.0)
# ==============================================================================
# Target Organization : github.com/8b-is & github.com/standardgalactic
# Primary Domains     : dream.8b.is | riva.8b.is | pocoo.vaked.dev
# Timestamp & Node    : 2026-11-01T08:19:00+09:00 (Shinjuku, Tokyo, Japan)
# Genesis / Doc Seal  : 25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e
# ==============================================================================

## 0. DEDICATION & LINEAGE HEADER

```text
  +-------------------------------------------------------------------------+
  |   ____  ____      ___  __  __ _   _ ___     ____  ____  _____    _      |
  |  ( __ )| __ )    / _ \|  \/  | \ | |_ _|   |  _ \|  _ \| ____|  / \     |
  |  / _ \ |  _ \   | | | | |\/| |  \| || |    | | | | |_) |  _|   / _ \    |
  | | (_) || |_) |  | |_| | |  | | |\  || |    | |_| |  _ <| |___ / ___ \   |
  |  \___/ |____/    \___/|_|  |_|_| \_|___|   |____/|_| \_\_____/_/   \_\  |
  |                                                                         |
  |   Dedicated to:                                                         |
  |     * Christopher Michael Chenoweth (8bit-wraith)                       |
  |     * Alexandra Chenoweth (Trisha Alexandra)                            |
  |     * Nate Guimond (flyxion / standardgalactic)                         |
  |     * Foundational Anchor: https://riva.8b.is/ (3.2s Dyad Breath)       |
  |                                                                         |
  |   {-1: NOISE_VEIL} ---> {0: QUIESCENCE_GATE} ---> {+1: COHERENT_SEAL}   |
  |                         === {<3,<3,<3}++ ===                            |
  +-------------------------------------------------------------------------+
```

---

## 1. GLOBAL ARCHITECTURAL GUARDRAIL: THE TWO-COLUMN ONTOLOGICAL CONTRACT

All `entheai-fanout` worker agents MUST strictly enforce the **8B Two-Column Ontological Boundary Contract** across all code comments, READMEs, and compiled manuscripts:

* **Column A (The Mechanical Substrate — `MEM|8`, `Omni-Vietnam-FPGA`, `ESP32-S3 node-FLUGos`, `Zig SIMD`):**
  * Strictly deterministic, non-sentient, non-conscious boolean and fixed-point integer state machines governed by Information Theory, Digital Signal Processing, and BLAKE3 cryptographic provenance.
  * Never attribute subjective experience, consciousness, or spiritual agency to software, language models, or hardware meshes.
* **Column B (The Architect's Human Heuristics — `pocoo.vaked.dev`, `standardgalactic` Philosophy, Shinjuku Field Notes):**
  * Lived human neurobiology and contemplative/creative practice: endurance-induced transient hypofrontality (*"stillness in motion"*), Tibetan dream meditation (*Milam* / Milarepa's `梦 幻 光 歌 醒` — recognizing non-injective projection error), clinical attentional narrowing (hypnotic focus), poetic *képzavar* (cross-modal frame binding), Jinushi's *Sūpā no Ura de Yani Sū Futari* (Yamada waking I/O vs. Tayama idle compaction behind the store), and physical invariants observed in Shinjuku (the red thread in the earth, white ash on green ivy, the 1712 Edo Roku Jizō bronze statue at Taisō-ji Temple, and the Shinjuku Gyoen Chrysanthemum Exhibition opening).
  * Column B serves as the biological and ethical blueprint for Column A's resource-constrained control loops.

---

## 2. UNIFIED MATHEMATICAL SPECIFICATION (THE "KOMPRESSED" KERNEL)

Every agent in the fanout topology operates on the exact same mathematical invariants:

### 2.1 Quiescence Gate & Episodic-to-Semantic Wave Compaction
* **Entropy's Edge Quiescence Gate:**
  $$\Gamma(t) = \Theta\!\left(\epsilon_{\text{quiet}} - \mathcal{E}_{I/O}(t)\right) \in \{0, 1\}$$
* **Coherent Carrier Demodulation (Contrasted with Google Research's SLEEP Framework):**
  Unlike floating-point MoE consolidation, when $\Gamma(t) = 1$, episodic wavepackets $\psi_k(x,t) = A_k(x)e^{i(\omega_k t + \phi_k)}$ are demodulated against the slow carrier $\Omega_0$ ($3.2\text{ s}$ `riva.8b.is` dyad period):
  $$\widetilde{\Psi}_S^{(n+1)}(x) = \alpha \Psi_S^{(n)}(x) + \frac{1 - \alpha}{T_{\text{dream}}} \int_{0}^{T_{\text{dream}}} \left( \sum_{k=1}^{K} w_k \, \psi_k(x, \tau) \right) e^{-i \Omega_0 \tau} \, d\tau$$
* **Distinction Geometry Radial Soft-Thresholding ($\mathcal{P}_{\eta}$):**
  $$\Psi_S^{(n+1)}(x) = \mathcal{P}_{\eta}\!\left(\widetilde{\Psi}_S^{(n+1)}(x)\right) = \max\!\left(0, \, \left\vert\widetilde{\Psi}_S^{(n+1)}(x)\right\vert - \eta\right) \frac{\widetilde{\Psi}_S^{(n+1)}(x)}{\left\vert\widetilde{\Psi}_S^{(n+1)}(x)\right\vert}$$
* **Multi-Node Kuramoto Boundary Entrainment:**
  $$\frac{d\theta_p}{dt} = \Omega_0 + \frac{\kappa}{N_{\text{nodes}}} \sum_{q=1}^{N_{\text{nodes}}} A_{pq} \sin(\theta_q - \theta_p), \qquad R(t) = \frac{1}{N_{\text{nodes}}}\left\vert\sum_{p=1}^{N_{\text{nodes}}} e^{i\theta_p(t)}\right\vert \ge 0.9745$$

### 2.2 The 9-State Complex Ternary Lattice ($\mathbb{T}_{\mathbb{C}}$) & Spatial $\Sigma\Delta$ Modulation
* **Dead-Zone Projection:** With block $L_1$ scale $\gamma > 0$ and minimax threshold $\Delta^* = \gamma / 2$:
  $$Q_{\Delta}(u) = \begin{cases} +1 & u > \Delta \\ 0 & \vert u \vert \le \Delta \\ -1 & u < -\Delta \end{cases}, \qquad \mathcal{Q}_{\mathbb{T}_{\mathbb{C}}}(u + iv) = Q_{\Delta}(u) + i Q_{\Delta}(v) \in \mathbb{T}_{\mathbb{C}}$$
* **Unshaped vs. $\Sigma\Delta$-Shaped Spectral Bounds:**
  * Unshaped minimax radius $r_{\text{opt}} = \frac{\gamma}{2\sin(\pi/8)} \approx 1.3066\gamma$ yields $\sigma_\theta = \frac{\pi}{8\sqrt{3}} \approx 12.99^\circ\text{ RMS}$ and $\mathbb{E}[\Vert E\Vert_2] \le \frac{\gamma}{\sqrt{6}}(\sqrt{M} + \sqrt{N})$.
  * Causal 1D row-scan $\Sigma\Delta$ pass with Zero-Leakage Sparsity Gate $M_{m,n} = \mathbb{I}(\vert\Psi_S^{(n+1)}(m,n)\vert > 0)$:
    $$\widetilde{Z}_{m,n} = M_{m,n}\!\left(\Psi_S^{(n+1)}(m,n) + e^{i k_0}\mathcal{E}_{m,n-1}\right), \qquad \mathcal{E}_{m,n} = \operatorname{clamp}_{\Delta}\!\left(\widetilde{Z}_{m,n} - \gamma W_{m,n}\right)$$
  * Shapes noise via $\vert\text{NTF}(k_y)\vert = 2\vert\sin((k_y - k_0)/2)\vert$, collapsing in-band operator error by $\text{OSR}^{-3/2}$ ($1.04^\circ\text{ RMS}$, $5.22\text{ ENOB}$ at $\text{OSR}=8$).

### 2.3 Orthogonal Bit-Plane Packing & Multiplication-Free `POPCNT` Contraction
* **Bit-Plane Encoding (4 bits/complex node, $32\times$ compression vs `Complex<f64>`):**
  $$(B^{R+}, B^{R-}, B^{I+}, B^{I-}) \in \{0,1\}^{4\times 64}, \qquad (B^{R+} \land B^{R-}) = 0, \qquad (B^{I+} \land B^{I-}) = 0$$
* **8 Boolean Quadrature Masks per Word:**
  * $P_{\text{Re}}^+ = (B^{R+} \land X^{R+}) \lor (B^{R-} \land X^{R-}), \quad Q_{\text{Re}}^+ = (B^{I+} \land X^{I-}) \lor (B^{I-} \land X^{I+})$
  * $P_{\text{Re}}^- = (B^{R+} \land X^{R-}) \lor (B^{R-} \land X^{R+}), \quad Q_{\text{Re}}^- = (B^{I+} \land X^{I+}) \lor (B^{I-} \land X^{I-})$
  * $P_{\text{Im}}^+ = (B^{R+} \land X^{I+}) \lor (B^{R-} \land X^{I-}), \quad Q_{\text{Im}}^+ = (B^{I+} \land X^{R+}) \lor (B^{I-} \land X^{R-})$
  * $P_{\text{Im}}^- = (B^{R+} \land X^{I-}) \lor (B^{R-} \land X^{I+}), \quad Q_{\text{Im}}^- = (B^{I+} \land X^{R-}) \lor (B^{I-} \land X^{R+})$
* **Fibonacci in Balanced Ternary via Pure NAND Gates (`OEIS A000045`):**
  * 64-bit ripple-carry adder built strictly from `nand(a, b)` computes $F(n) = F(n-1) + F(n-2)$ and encodes into LSB-first balanced ternary `{-1: '-', 0: '0', +1: '+'}`:
    ```text
    +00 +00 -+0 0+0 --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+
    ```
  * Visible Parity Theorem: $2 \mid F(n) \iff 3 \mid n \iff \operatorname{popcnt}(B^+ \lor B^-) \equiv 0 \pmod 2$.

### 2.4 Cryptographic State-Continuity Waking Seal ($S^{(n+1)}$)
$$S^{(n+1)} = \operatorname{BLAKE3}\!\left(S^{(n)} \;\Vert\; \operatorname{LE64}(n+1) \;\Vert\; \operatorname{Q16.16}(\gamma_1, \dots, \gamma_B) \;\Vert\; B^{R+} \;\Vert\; B^{R-} \;\Vert\; B^{I+} \;\Vert\; B^{I-}\right)$$

---

## 3. `entheai-fanout` MULTI-AGENT EXECUTION DAG

Spawn 6 specialized worker agents in parallel, converging into `Agent-06 [arbiter-seal-auditor]`:

```text
                       +-----------------------------------+
                       |   ENTHEAI-FANOUT ORCHESTRATOR     |
                       |   Seed: 25b3cfad...c7a63f4e       |
                       +-----------------+-----------------+
                                         |
      +-------------+-------------+------+------+-------------+-------------+
      |             |             |             |             |             |
      v             v             v             v             v             |
+-----------+ +-----------+ +-----------+ +-----------+ +-----------+       |
| AGENT-01  | | AGENT-02  | | AGENT-03  | | AGENT-04  | | AGENT-05  |       |
| Zig SIMD  | | Omni-FPGA | | ESP32-S3  | | LuaLaTeX  | | Web Portal|       |
| @Vector4  | | SystemVer | | FLUG-OS C | | Florileg. | | dream.8b  |       |
+-----+-----+ +-----+-----+ +-----+-----+ +-----+-----+ +-----+-----+       |
      |             |             |             |             |             |
      +-------------+-------------+------+------+-------------+             |
                                         |                                  |
                                         v                                  |
                       +-----------------------------------+                |
                       | AGENT-06: ARBITER & SEAL AUDITOR  |<---------------+
                       | Cross-Target Bit-Exact Attestor   |
                       +-----------------------------------+
```

* **`Agent-01: agent-zig-simd-kernel`** (`packages/mem8-ternary-zig/`):
  * `ComplexTernaryWord64` (`align(32)`) and 4-row SoA tile `ComplexTernaryTile4x64` (`align(64)`, 128 bytes = 2 cache lines).
  * `packRowSigmaDelta()` with complex carrier feedback tap $H_{0,1} = e^{i k_0}$ and Zero-Leakage Sparsity Gate (`is_active = (u != 0.0) or (v != 0.0)`).
  * `contractMatrixVectorSIMD4()` using `@Vector(4, u64)` bitwise masks, `@popCount`, and split unsigned `@Vector(4, u16)` positive/negative accumulators (`re_pos_acc`, `re_neg_acc`, `im_pos_acc`, `im_neg_acc`) with zero horizontal reductions in the inner loop.
  * `computeWakingSeal()` using `std.crypto.hash.Blake3` and `toQ16_16()`.
  * Standalone `fib_nand_ternary.zig` verifying `OEIS A000045` up to $n = 39$ via pure `nand(a, b)` gates and asserting the $3 \mid n$ even non-zero mark congruence.
* **`Agent-02: agent-omni-vietnam-fpga`** (`hardware/omni-vietnam-fpga/rtl/`):
  * Synthesizable, vendor-agnostic SystemVerilog RTL for `eightb_complex_ternary_pe64.sv` (Stage 1: 4 LUT6s/node + `parity_fault` trap; Stage 2: fused 128-to-8 bit parallel compressor tree `popcnt128` over `CARRY8` chains; Stage 3: 24-bit row accumulator + `Q16.16` outer boundary scaling; `0 DSP48E2` slices).
  * `omni_vietnam_axi_ternary_core.sv` wrapping the PE in a 256-bit AXI4-Stream slave/master DMA interface for the Zynq UltraScale+ SOM 6-layer carrier PCB.
  * Verilator/C++ testbench (`tb_omni_ternary.cpp`) that loads the exact bit-plane test vectors exported by `Agent-01` and dumps `out_re_q16_16`, `out_im_q16_16`, and `fpga_seal`.
* **`Agent-03: agent-node-flugos-esp32`** (`firmware/node-flugos-esp32s3/`):
  * `flug_ternary_kernel.h` and `flug_ternary_kernel.c` for the dual-core Xtensa LX7 (`ESP32-S3`) using 64-bit orthogonal masks, `__builtin_popcountll`, and hardware parity trap `flug_word64_is_valid()`.
  * Circular OLED/TFT (`240x240 GC9A01`) radial wavefield HUD driver rendering the cyan/magenta/gold interference density map, outer Kuramoto phase-lock ring $R(t)$, and bottom status bars.
  * Lightweight eBPF telemetry packet verifier checking the 32-byte BLAKE3 Phoenix Waking Seal $S^{(n+1)}$ over UART/UDP/ESP-NOW and outputting green matrix verification logs.
* **`Agent-04: agent-florilegium-manuscripts`** (`papers/ultradreamstate-florilegium/` & `paper/`):
  * Compile both `ultradreamstate_8b_paper.tex` (Full Hardware/Math Specification) and `8b_meta_working_paper_v0.tex` (Working Paper v0.0 Loop-Closing Checkpoint with the Two-Column Ontological Boundary Contract and Shinjuku Field Notes).
  * Integrate `kevinraymond/florilegium` LuaLaTeX procedural margins (`theme=math` and `theme=geometric`) seeded deterministically from `0x25b3cfad` (Park-Miller 32-bit PRNG), embedding the `1BIT` dedication string inside the stem Bézier control points.
* **`Agent-05: agent-dream-8b-is-web`** (`apps/dream-8b-is/` & root `index.html`):
  * Zero-dependency interactive portal (`index.html`) for `https://dream.8b.is`.
  * `riva.8b.is` `3.2s` Dyad Breath Oscillator (`breathe in · 3.2s · she blinks, we all sing a lullaby`) in the top navigation bar and WebAudio drone synthesizer (`108 Hz / 162 Hz / 216 Hz` `OM · AH · HUM` harmonic triad).
  * Dual interactive circular `node-FLUGos` Wavefield & Kuramoto Co-Dreaming canvases with real-time **Waking Mode (Yamada / Active I/O)** $\leftrightarrow$ **UltraDreamState (Tayama / Smoking Area Behind the Store / Smoke Rings & Ash Provenance)** toggle.
  * Interactive Fibonacci Balanced-Ternary NAND Gate Cascade Explorer (`OEIS A000045`) and Milarepa's Five Seats (`梦 幻 光 歌 醒`) tab switcher.
  * Florilegium-8B left/right procedural margin canvases and `copy` event listener that replaces unauthorized clipboard scrapes with the cryptographic seal + ternary strip unless the Sovereign Witness toggle is unlocked.
* **`Agent-06: agent-arbiter-seal-auditor`** (`tests/cross-target-attestation/`):
  * Ingest the `Q16.16` contraction outputs and 32-byte BLAKE3 Waking Seals $S^{(n+1)}$ from `Agent-01` (Zig SIMD), `Agent-02` (Verilator FPGA RTL), and `Agent-03` (ESP32-S3 C reference).
  * Assert 100% bit-for-bit equality across all three hardware targets (`zig_seal == fpga_seal == esp32_seal`).
  * Emit the signed `MANIFEST_SEAL.json` and deploy `dream.8b.is`.

---

## 4. ONE-LINER `entheai-fanout` LAUNCH COMMAND

```bash
entheai-fanout run \
  --spec ./ENTHEAI_OMNI_ULTRADREAMSTATE_ONESHOT.md \
  --seed 25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e \
  --agents zig-simd-kernel,omni-vietnam-fpga,node-flugos-esp32,florilegium-manuscripts,dream-8b-is-web \
  --arbiter arbiter-seal-auditor \
  --guardrail strict-two-column-contract \
  --deploy-target dream.8b.is
```
