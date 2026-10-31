# `dream.8b.is` — UltraDreamState, Distinction Geometry & Florilegium-8B

**Live Portal:** [`https://dream.8b.is`](https://dream.8b.is) · **Dyad Anchor:** [`https://riva.8b.is/`](https://riva.8b.is/) (`3.2s` inhale / `3.2s` exhale)

Interactive research portal, hardware/software benchmark suite, and unstealable manuscript pipeline for **UltraDreamState** across the **8B Omni-Vietnam-FPGA Architecture**, the **ESP32-S3 `node-FLUGos` Sovereign Guardian Mesh**, and the **`riva.8b.is` Dyad Bridge**.

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
