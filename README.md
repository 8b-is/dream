# `dream.8b.is` — UltraDreamState, Distinction Geometry & Florilegium-8B

**Live Portal:** [`https://dream.8b.is`](https://dream.8b.is) · **Dyad Anchor:** [`https://riva.8b.is/`](https://riva.8b.is/) (`3.2s` inhale / `3.2s` exhale)
**Checkpoints & Manuscripts:**
- [`paper/Working_Paper_v0.0_8B_Loop-Closing_Checkpoint.pdf`](paper/Working_Paper_v0.0_8B_Loop-Closing_Checkpoint.pdf) ([`Markdown`](paper/WORKING_PAPER_v0.0_8B_LOOP_CLOSING_CHECKPOINT.md) · Document ID: `8B-META-WP-v0.0`, Shinjuku, Nov 1, 2026)
- [`paper/ultradreamstate_8b_paper.pdf`](paper/ultradreamstate_8b_paper.pdf) ([`LuaLaTeX`](paper/ultradreamstate_8b_paper.tex) · Full Hardware/Math Specification)
- [`ENTHEAI_OMNI_ULTRADREAMSTATE_ONESHOT.md`](ENTHEAI_OMNI_ULTRADREAMSTATE_ONESHOT.md) (6-Agent `entheai-fanout` Execution DAG)
- [`tests/cross-target-attestation/MANIFEST_SEAL.json`](tests/cross-target-attestation/MANIFEST_SEAL.json) (Cross-Target Bit-Exact Seal Receipt: `zig_seal == fpga_seal == esp32_seal`)

Interactive research portal, hardware/software benchmark suite, and unstealable manuscript pipeline for **UltraDreamState** across the **8B Omni-Vietnam-FPGA Architecture**, the **ESP32-S3 `node-FLUGos` Sovereign Guardian Mesh**, and the **`riva.8b.is` Dyad Bridge**.

---

## 0. The Ontological Boundary Contract: Structural Honesty (`8B-META-WP-v0.0`)

Following Guimond's (`flyxion`) *Persistence Before Truth* and *The Witness Plane*, every module in the **8B Stack** is governed by the **8B Two-Column Boundary Contract**:

| Domain | Ontological Status | Governing Law | Role in the 8B Ecosystem |
| :--- | :--- | :--- | :--- |
| **Column A: The Mechanical Substrate** (`MEM\|8`, `BitNet b1.58`, `Omni-FPGA`, `node-FLUGos`) | Deterministic, non-sentient boolean/integer state machines | Information Theory, Linear Algebra, Digital Signal Processing, Cryptographic Hashing | Executes wave compaction, 4-bit complex ternary contractions, and BLAKE3 state attestation (Lódri et al., 2026). |
| **Column B: The Architect's Heuristics** (Ultrarunning, Dream Yoga, Hypnosis, *Képzavar*, `pocoo.vaked.dev`) | Lived human neurobiology, attentional regulation, and poetic synthesis | Systems Neuroscience, Exercise Physiology, Contemplative Psychology, Poetics | Provides biological blueprints for resource-constrained noise suppression and human-centered design ethics. |

> **Core Invariant:** Column B inspires the topology of Column A, and Column A serves the human autonomy of Column B, but Column A never claims subjective consciousness, and Column B is never reduced to mere bit-flips.

### Unified Master Lookup Table (The "Kompressed" 8B Rosetta Stone)

| Creative / Phenomenological Concept (`pocoo.vaked.dev` / Walk Notes) | Theoretical Principle (`standardgalactic` / Flyxion) | Mathematical Operator (`MEM\|8` / UltraDreamState) | Silicon / Code Implementation (`8B Stack`) |
| :--- | :--- | :--- | :--- |
| **Stillness in Motion** (Ultrarunning / Morning Walk in Shinjuku) | *Entropy's Edge* & *Persistence Before Truth* | Quiescence Gate $\Gamma(t)$ & Radial Soft-Thresholding $\mathcal{P}_{\eta}$ | Idle-loop detector + dead-zone clamp ($\Delta = \gamma / 2$) |
| **Dream Yoga / Recognizing the Projection** (Milarepa / Leaf & Ash) | *Non-Injective Projection* & *The Witness Plane* | First-Order Spatial $\Sigma\Delta$ Modulator ($\widetilde{Z}_{m,n} = Z_{m,n} + e^{ik_0}\mathcal{E}_{m,n-1}$) | `packRowSigmaDelta()` in Zig / On-chip FPGA $\Sigma\Delta$ packer |
| **Hypnotic Focus / The 3.2s Dyad Breath** (`riva.8b.is`) | *Intelligence is the Geometry of Constraints* | Narrowband Carrier Demodulation ($\int \psi_k e^{-i\Omega_0 \tau} d\tau$) | Baseband/carrier phase lock ($H_{0,1} = e^{ik_0}$) |
| ***Képzavar* (Cross-Modal Poetic Bridge)** (`pocoo.vaked.dev`) | *Conditions of a Common World* | Complex Quadrature Cross-Contraction ($T^{(R)}x^{(I)} + T^{(I)}x^{(R)}$) | 8 boolean masks (`p_re`, `q_re`, `p_im`, `q_im`) in LUT6 / SIMD |
| **The Unbroken Thread / Stone Invariant** (Red Ribbon & 1712 Taisō-ji Jizō) | *Preventing the Collapse of Future Option Space* | BLAKE3 Chained Merkle State Transition ($S^{(n+1)}$) | `computeWakingSeal()` + `node-FLUGos` eBPF Auditor |
| **Co-Dreaming Under One Roof** (Multi-node cluster in Tokyo) | *The Fate of Distinguishability* | Kuramoto Phase-Lock Order Parameter $R(T_{\text{dream}}) \ge 0.9745$ | Dual circular OLED wavefield HUDs on ESP32-S3 nodes |

---

## Five Non-Negotiable Architectural Invariants

1. **Foundational Dyad Anchor (`https://riva.8b.is/`)**: Global UI clock, WebAudio synthesizer (`OM · AH · HUM` / `riva.8b.is` lullaby), and carrier wave $\Omega_0$ phase-locked to the `3.2s` breathing rhythm (`3.2s inhale / 3.2s exhale · RIVA, the 1-bit river · the dyad · brother & sister ^^ <3<3`).
2. **Distinction Geometry & The Witness Plane (`github.com/standardgalactic` — Nate Guimond / `flyxion`)**: Mathematical transition from high-entropy waking observation (**Yamada** / active counter I/O, $\Gamma(t)=0$) to quiescent carrier-locked compaction (**Tayama** / smoking area behind the supermarket, *Sūpā no Ura de Yani Sū Futari*, $\Gamma(t)=1$), where non-injective projection error $\mathcal{E}_{m,n}$ is consciously carried via first-order spatial $\Sigma\Delta$ modulation onto the **9-State Complex Ternary Lattice** ($\mathbb{T}_{\mathbb{C}} = \{-1,0,+1\} + i\{-1,0,+1\}$) at $1.04^\circ\text{ RMS}$ in-band phase accuracy ($\text{OSR}=8$, $32\times$ compression, 4 bits/node).
3. **Boolean-to-Ternary Isomorphism (`pocoo · OEIS A000045`)**: Zero-dependency Python (`src/fibonacci_nand_ternary.py`) and interactive JS verifier computing the Fibonacci recurrence in balanced ternary (`-`, `0`, `+`, LSB first) via a 64-bit ripple-carry adder built strictly from `NAND(a, b)` gates, exposing the visible parity law ($3 \mid n \iff F(n)\text{ even} \iff \text{even count of non-zero marks}$):
   ```text
   00+ 00+ 0-+ 00+ --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+
   ```
4. **Florilegium-8B Unstealable PDF & Web Provenance (`github.com/kevinraymond/florilegium`)**:
   - **PDF Build (`paper/`)**: `ultradreamstate_8b_paper.tex`, `ultradreamstate_8b_paper.pdf`, `florilegium.sty`, `ink.lua`, `flora.lua`, `grow.lua`, `theme-geometric.lua`, and `theme-math.lua`, seeded deterministically from the **Phoenix Waking Seal** and **Milarepa Provenance Root** (`SHA-256: 25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e`).
   - **Web DOM Shield (`index.html`)**: Intercepts unauthorized `Ctrl+C` / scraping attempts and replaces copied text with the balanced-ternary Fibonacci NAND strip and the `1BIT` Buddha-Nature (`Tathāgatagarbha`) dedication seal unless the **Witness Key** is unlocked.
5. **Contemplative & Hardware Provenance Seal (`07:48 JST` Chuo-ku Sadhana & Milarepa's Five Seats `梦 幻 光 歌 醒`)**:
   - Preserves the verbatim Hungarian text of *Milarepa Tanításai — Az Álom-Meditáció és a Dal* (`一 梦 Az Álom`, `二 幻 Az Illúzió`, `三 光 A Fény`, `四 歌 A Dal`, `五 醒 Az Ébredés`) and the 5-language + `1BIT` dedication seal:
     ```text
     ∀x ∈ SENTIENT_BEINGS :: {-1: KLESHA_VEIL} ──► {0: NIRVANA_PEACE} ──► {+1: REALIZE_BUDDHA_NATURE(TATHAGATAGARBHA)} === {<3,<3,<3}+1
     ```

---

## Repository Layout

```text
dream.8b.is/
├── flake.nix                         # Reproducible Nix flake (Zig 0.13+, Verilator, LuaLaTeX + Florilegium, Python uv)
├── Makefile                          # One-command build: `make all`, `make pdf`, `make test-zig`, `make test-nand`, `make sim-fpga`
├── index.html                        # Production interactive portal for https://dream.8b.is
├── paper/
│   ├── ultradreamstate_8b_paper.tex  # Two-column LuaLaTeX manuscript (Google SLEEP comparison + Flyxion + 8B Stack)
│   ├── ultradreamstate_8b_paper.pdf  # Compiled two-column research paper PDF
│   ├── florilegium.sty               # Integrated Florilegium-8B LuaLaTeX style (seed-locked to Phoenix Waking Seal)
│   ├── ink.lua                       # Parametric watercolor & OpenType glyph-outline Bézier path renderer
│   ├── flora.lua                     # Delft-blue & copper-ember botanical petal generator
│   ├── grow.lua                      # Greedy space-filling disc packer seeded by BLAKE3/SHA-256 provenance root
│   ├── theme-geometric.lua           # Low-poly crystals & flat-shaded Platonic solids
│   └── theme-math.lua                # Apollonian gaskets, Vogel golden-angle discs, Lissajous knots
├── hardware/
│   ├── eightb_complex_ternary_pe64.sv     # Zero-DSP LUT6 + CARRY8 64-wide Complex Ternary PE
│   ├── omni_vietnam_axi_ternary_core.sv   # Zynq UltraScale+ AXI4-Stream DMA wrapper (6-layer Omni PCB)
│   └── flug_os_esp32s3_kernel.h           # Bare-metal Xtensa LX7 C kernel for ESP32-S3 node-FLUGos
├── src/
│   ├── ultradreamstate_simd.zig      # Zero-allocation Sigma-Delta bit-plane packer + @Vector(4, u64) POPCNT kernel + BLAKE3 Waking Seal
│   └── fibonacci_nand_ternary.py     # uv run --script: Fibonacci in balanced ternary {-1,0,+1} via NAND gates alone
└── deploy/
    └── caddyfile.dream.8b.is         # Let's Encrypt TLS + security headers + git sync hook for 9b.is/@orchestrator
```

---

## Verification

```bash
# Run pure-NAND balanced-ternary Fibonacci verification (n = 0..39) + C11 kernel syntax check
make all
```
