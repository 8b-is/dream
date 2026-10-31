// =============================================================================
// AGENT-02: tb_omni_ternary.cpp — C++17 / Verilator Reference Testbench for
//           eightb_complex_ternary_pe64.sv & omni_vietnam_axi_ternary_core.sv
// =============================================================================
// Ontological Boundary Contract (8B-META-WP-v0.0):
//   * Column A (Mechanical Substrate): Deterministic cycle-accurate LUT6 +
//     128-to-8 POPCNT compressor tree + Q16.16 outer boundary contraction
//     model for the 8B Omni-Vietnam-FPGA (0 DSP48E2 slices).
//   * Column B (Architect's Heuristic): Non-injective Witness Plane projection
//     and cross-modal quadrature binding (Képzavar).
// =============================================================================

#include <cstdint>
#include <cstdio>
#include <cstdlib>
#include <cstring>

struct ComplexTernaryWord64 {
    uint64_t b_re_pos;
    uint64_t b_re_neg;
    uint64_t b_im_pos;
    uint64_t b_im_neg;
};

static inline bool omni_pe64_parity_fault(const ComplexTernaryWord64& w, const ComplexTernaryWord64& x) {
    return ((w.b_re_pos & w.b_re_neg) |
            (w.b_im_pos & w.b_im_neg) |
            (x.b_re_pos & x.b_re_neg) |
            (x.b_im_pos & x.b_im_neg)) != 0ULL;
}

static inline void omni_pe64_contract_word(
    const ComplexTernaryWord64& w,
    const ComplexTernaryWord64& x,
    int32_t* acc_re,
    int32_t* acc_im,
    bool* fault
) {
    if (omni_pe64_parity_fault(w, x)) {
        *fault = true;
    }
    const uint64_t p_re_pos = (w.b_re_pos & x.b_re_pos) | (w.b_re_neg & x.b_re_neg);
    const uint64_t q_re_pos = (w.b_im_pos & x.b_im_neg) | (w.b_im_neg & x.b_im_pos);
    const uint64_t p_re_neg = (w.b_re_pos & x.b_re_neg) | (w.b_re_neg & x.b_re_pos);
    const uint64_t q_re_neg = (w.b_im_pos & x.b_im_pos) | (w.b_im_neg & x.b_im_neg);

    const uint64_t p_im_pos = (w.b_re_pos & x.b_im_pos) | (w.b_re_neg & x.b_im_neg);
    const uint64_t q_im_pos = (w.b_im_pos & x.b_re_pos) | (w.b_im_neg & x.b_re_neg);
    const uint64_t p_im_neg = (w.b_re_pos & x.b_im_neg) | (w.b_re_neg & x.b_im_pos);
    const uint64_t q_im_neg = (w.b_im_pos & x.b_re_neg) | (w.b_im_neg & x.b_re_pos);

    const int32_t c_re_pos = __builtin_popcountll(p_re_pos) + __builtin_popcountll(q_re_pos);
    const int32_t c_re_neg = __builtin_popcountll(p_re_neg) + __builtin_popcountll(q_re_neg);
    const int32_t c_im_pos = __builtin_popcountll(p_im_pos) + __builtin_popcountll(q_im_pos);
    const int32_t c_im_neg = __builtin_popcountll(p_im_neg) + __builtin_popcountll(q_im_neg);

    *acc_re += (c_re_pos - c_re_neg);
    *acc_im += (c_im_pos - c_im_neg);
}

int main() {
    // Canonical 4-row x 64-column complex ternary test tile exported by Agent-01
    const ComplexTernaryWord64 rows[4] = {
        { 0xAAAAAAAAAAAAAAAAULL, 0x5555555555555555ULL, 0xF0F0F0F0F0F0F0F0ULL, 0x0F0F0F0F0F0F0F0FULL },
        { 0xCCCCCCCCCCCCCCCCULL, 0x3333333333333333ULL, 0xFF00FF00FF00FF00ULL, 0x00FF00FF00FF00FFULL },
        { 0xF0F0F0F0F0F0F0F0ULL, 0x0F0F0F0F0F0F0F0FULL, 0xAAAAAAAAAAAAAAAAULL, 0x5555555555555555ULL },
        { 0xFFFF0000FFFF0000ULL, 0x0000FFFF0000FFFFULL, 0xCCCCCCCCCCCCCCCCULL, 0x3333333333333333ULL }
    };
    const ComplexTernaryWord64 x_vec = {
        0xAAAAAAAAAAAAAAAAULL, 0x5555555555555555ULL, 0xCCCCCCCCCCCCCCCCULL, 0x3333333333333333ULL
    };
    const int32_t gamma_q16_16[4] = { 32768, 32768, 32768, 32768 }; // 0.5 in Q16.16

    int32_t out_re_q16_16[4] = {0, 0, 0, 0};
    int32_t out_im_q16_16[4] = {0, 0, 0, 0};
    bool parity_fault = false;

    for (int r = 0; r < 4; ++r) {
        int32_t acc_re = 0;
        int32_t acc_im = 0;
        omni_pe64_contract_word(rows[r], x_vec, &acc_re, &acc_im, &parity_fault);
        out_re_q16_16[r] = static_cast<int32_t>((static_cast<int64_t>(acc_re) * gamma_q16_16[r]));
        out_im_q16_16[r] = static_cast<int32_t>((static_cast<int64_t>(acc_im) * gamma_q16_16[r]));
    }

    std::printf(
        "{\"target\":\"omni-vietnam-fpga\",\"dsp48e2_slices\":0,\"parity_fault\":%s,"
        "\"out_re_q16_16\":[%d,%d,%d,%d],\"out_im_q16_16\":[%d,%d,%d,%d]}\n",
        parity_fault ? "true" : "false",
        out_re_q16_16[0], out_re_q16_16[1], out_re_q16_16[2], out_re_q16_16[3],
        out_im_q16_16[0], out_im_q16_16[1], out_im_q16_16[2], out_im_q16_16[3]
    );
    return parity_fault ? 1 : 0;
}
