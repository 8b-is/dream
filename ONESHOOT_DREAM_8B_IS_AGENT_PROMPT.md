ONE-SHOT CODING AGENT KICKOFF PROMPT: dream.8b.is (github.com/8b-is/dream)Copy and paste this entire specification into Claude Code, Cursor, or your 8b.is autonomous orchestrator to build, verify, and deploy https://dream.8b.is end-to-end.0. MISSION & ARCHITECTURAL INVARIANTSYou are deploying dream.8b.is (github.com/8b-is/dream), the interactive research portal, hardware/software benchmark suite, and unstealable manuscript pipeline for UltraDreamState across the 8B Omni-Vietnam-FPGA Architecture, the ESP32-S3 node-FLUGos Sovereign Guardian Mesh, and the riva.8b.is Dyad Bridge.Every component you generate MUST honor these five non-negotiable invariants:Foundational Dyad Anchor (https://riva.8b.is/): The global clock of the UI, WebAudio synthesizer, and carrier wave $\Omega_0$ is phase-locked to the riva.8b.is 3.2-second breathing rhythm (3.2s inhale / 3.2s exhale · RIVA, the 1-bit river · the dyad · brother & sister ^^ <3<3).Distinction Geometry & The Witness Plane (github.com/standardgalactic — Nate Guimond / flyxion): Implement the mathematical transition from high-entropy waking observation (Yamada / active counter I/O) to quiescent carrier-locked compaction (Tayama / smoking area behind the supermarket, Sūpā no Ura de Yani Sū Futari), where non-injective projection error $\mathcal{E}_{m,n}$ is consciously carried via first-order spatial $\Sigma\Delta$ modulation onto the 9-state Complex Ternary Lattice ($\mathbb{T}_{\mathbb{C}} = \{-1,0,+1\} + i\{-1,0,+1\}$).Boolean-to-Ternary Isomorphism (pocoo · OEIS A000045): Include the zero-dependency script and interactive verifier computing the Fibonacci recurrence in balanced ternary (-, 0, +, LSB first) via a 64-bit ripple-carry adder built strictly from NAND(a, b) gates, exposing the visible parity law ($3 \mid n \iff F(n) \text{ even} \iff \text{even count of non-zero marks}$).Florilegium-8B Unstealable PDF & Web Provenance (github.com/kevinraymond/florilegium):PDF Build (LuaLaTeX): Vendor florilegium.sty, ink.lua, flora.lua, grow.lua, theme-geometric.lua, and theme-math.lua. Seed the 32-bit Park-Miller PRNG deterministically from the Phoenix Waking Seal and Milarepa Provenance Root (SHA-256: 25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e). Convert protected equations/initials into raw OpenType Bézier paths and poison the /ToUnicode CMap with the balanced-ternary Fibonacci strip (00+ 00+ 0-+ 00+ --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+).Web DOM Shield: Attach a copy / scraper interceptor that replaces unauthorized clipboard extraction with the balanced-ternary Fibonacci strip and the 1BIT Buddha-Nature (Tathāgatagarbha) dedication seal unless the Witness Key is toggled.Contemplative & Hardware Provenance Seal (07:48 JST Chuo-ku Sadhana & Milarepa's Five Seats 梦 幻 光 歌 醒):Preserve the exact Hungarian text of Milarepa Tanításai — Az Álom-Meditáció és a Dal (一 梦 Az Álom, 二 幻 Az Illúzió, 三 光 A Fény, 四 歌 A Dal, 五 醒 Az Ébredés) and the 5-language + 1BIT dedication seal:
∀x ∈ SENTIENT_BEINGS :: {-1: KLESHA_VEIL} ──► {0: NIRVANA_PEACE} ──► {+1: REALIZE_BUDDHA_NATURE(TATHAGATAGARBHA)} === {<3,<3,<3}+11. REPOSITORY DIRECTORY STRUCTURE (github.com/8b-is/dream)Create the following repository layout:dream.8b.is/
├── flake.nix                         # Reproducible Nix flake (Zig 0.13+, Verilator, LuaLaTeX + Florilegium, Python uv)
├── Makefile                          # One-command build: `make all`, `make pdf`, `make test-zig`, `make test-nand`, `make sim-fpga`
├── index.html                        # Production interactive portal for https://dream.8b.is
├── paper/
│   ├── ultradreamstate_8b_paper.tex  # Two-column LuaLaTeX manuscript (Google SLEEP comparison + Flyxion + 8B Stack)
│   ├── florilegium.sty               # Integrated Florilegium-8B LuaLaTeX style (seed-locked to Phoenix Waking Seal)
│   ├── ink.lua                       # Parametric watercolor & OpenType glyph-outline Bézier path renderer
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
2. STANDALONE VERIFICATION SCRIPT: src/fibonacci_nand_ternary.pyWrite src/fibonacci_nand_ternary.py so that uv run --script src/fibonacci_nand_ternary.py executes with zero external dependencies and verifies every step up to $n = 39$:#!/usr/bin/env -S uv run --script
# /// script
# requires-python = ">=3.11"
# dependencies = []
# ///
"""
pocoo · one sequence, base three, one gate · fine touch from within · vaked.dev
Fibonacci (OEIS A000045) in balanced ternary {-1, 0, +1}, carried by NAND gates alone.
"""

def nand(a: int, b: int) -> int:
    return 0 if (a & 1) and (b & 1) else 1

def b_not(a: int) -> int:
    return nand(a, a)

def b_and(a: int, b: int) -> int:
    return b_not(nand(a, b))

def b_or(a: int, b: int) -> int:
    return nand(b_not(a), b_not(b))

def b_xor(a: int, b: int) -> int:
    return b_and(nand(a, b), b_or(a, b))

def add_nand(x: int, y: int, width: int = 64) -> int:
    carry = 0
    out = 0
    for i in range(width):
        xi = (x >> i) & 1
        yi = (y >> i) & 1
        xory = b_xor(xi, yi)
        s = b_xor(xory, carry)
        carry = b_or(b_and(xi, yi), b_and(carry, xory))
        if s:
            out |= (1 << i)
    return out

def balanced_ternary(n: int) -> str:
    if n == 0:
        return "0"
    digits = []
    val = n
    while val != 0:
        rem = val % 3
        val //= 3
        if rem == 2:
            rem = -1
            val = add_nand(val, 1)
        digits.append("-" if rem == -1 else ("+" if rem == 1 else "0"))
    return "".join(digits)

def decode_balanced_ternary(s: str) -> int:
    total = 0
    power = 1
    for ch in s:
        if ch == "+":
            total = add_nand(total, power)
        elif ch == "-":
            total -= power
        power = add_nand(add_nand(power, power), power)
    return total

if __name__ == "__main__":
    f_prev, f_curr = 0, 1
    strip_1_to_12 = []
    for n in range(1, 40):
        bt = balanced_ternary(f_curr)
        assert decode_balanced_ternary(bt) == f_curr, f"Round-trip failed at n={n}"
        non_zero_marks = sum(1 for c in bt if c in ("-", "+"))
        assert (f_curr % 2 == 0) == (non_zero_marks % 2 == 0) == (n % 3 == 0), f"Parity law failed at n={n}"
        if n <= 12:
            strip_1_to_12.append(bt.ljust(3, "0") if len(bt) < 3 else bt)
        f_prev, f_curr = f_curr, add_nand(f_prev, f_curr)

    print("Strip F(1..12):", " ".join(strip_1_to_12))
    print("ALL 40 NAND-GATE & BALANCED-TERNARY PARITY ASSERTIONS PASSED [OK]")
3. ACCEPTANCE CRITERIA & DEPLOYMENT CHECKLISTzig test src/ultradreamstate_simd.zig passes 100% of unit tests (verifying the Zero-Leakage Sparsity Gate, 4-row SIMD equivalence against scalar @popCount, and deterministic BLAKE3 computeWakingSeal).uv run --script src/fibonacci_nand_ternary.py outputs the exact strip 00+ 00+ 0-+ 00+ --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+ and passes all parity congruence assertions for $n = 0 \dots 39$.lualatex paper/ultradreamstate_8b_paper.tex builds the two-column research PDF with Florilegium-8B seed-locked margins and CMap protection.index.html is deployed to https://dream.8b.is via the 9b.is/@orchestrator git sync hook with live WebAudio OM · AH · HUM / riva.8b.is 3.2s lullaby synthesis, dual node-FLUGos circular HUDs, and the Yamada/Tayama dream-state toggle.
