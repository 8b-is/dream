// ============================================================================
// FLUG-OS Sovereign Guardian Kernel: ESP32-S3 Complex Ternary Contraction
// Target: Dual-Core Xtensa LX7 @ 240 MHz (Zero-FPU / Exact Integer Q16.16)
// ============================================================================
#ifndef FLUG_OS_ESP32S3_TERNARY_H
#define FLUG_OS_ESP32S3_TERNARY_H

#include <stdint.h>
#include <stdbool.h>
#include <stddef.h>

typedef struct __attribute__((packed, aligned(32))) {
    uint64_t r_pos; // B^{R+}
    uint64_t r_neg; // B^{R-}
    uint64_t i_pos; // B^{I+}
    uint64_t i_neg; // B^{I-}
} flug_ternary_word64_t;

// Hardware Orthogonality Interlock Check on ESP32-S3
static inline bool flug_word64_is_valid(const flug_ternary_word64_t *w) {
    return (((w->r_pos & w->r_neg) | (w->i_pos & w->i_neg)) == 0ULL);
}

// 64-Node Complex Ternary Inner Product for ESP32-S3 Xtensa LX7
static inline void flug_dot_word64(
    const flug_ternary_word64_t * __restrict w,
    const flug_ternary_word64_t * __restrict x,
    int32_t * __restrict acc_re,
    int32_t * __restrict acc_im
) {
    // Real excitations & inhibitions: T^{(R)}x^{(R)} - T^{(I)}x^{(I)}
    uint64_t p_re_pos = (w->r_pos & x->r_pos) | (w->r_neg & x->r_neg);
    uint64_t q_re_pos = (w->i_pos & x->i_neg) | (w->i_neg & x->i_pos);
    uint64_t p_re_neg = (w->r_pos & x->r_neg) | (w->r_neg & x->r_pos);
    uint64_t q_re_neg = (w->i_pos & x->i_pos) | (w->i_neg & x->i_neg);

    int32_t re_pos = __builtin_popcountll(p_re_pos) + __builtin_popcountll(q_re_pos);
    int32_t re_neg = __builtin_popcountll(p_re_neg) + __builtin_popcountll(q_re_neg);
    *acc_re += (re_pos - re_neg);

    // Imaginary excitations & inhibitions: T^{(R)}x^{(I)} + T^{(I)}x^{(R)}
    uint64_t p_im_pos = (w->r_pos & x->i_pos) | (w->r_neg & x->i_neg);
    uint64_t q_im_pos = (w->i_pos & x->r_pos) | (w->i_neg & x->r_neg);
    uint64_t p_im_neg = (w->r_pos & x->i_neg) | (w->r_neg & x->i_pos);
    uint64_t q_im_neg = (w->i_pos & x->r_neg) | (w->i_neg & x->r_pos);

    int32_t im_pos = __builtin_popcountll(p_im_pos) + __builtin_popcountll(q_im_pos);
    int32_t im_neg = __builtin_popcountll(p_im_neg) + __builtin_popcountll(q_im_neg);
    *acc_im += (im_pos - im_neg);
}

// Row contraction with Q16.16 scaling and parity interlock validation
static inline bool flug_contract_row_q16_16(
    const flug_ternary_word64_t * __restrict row_w,
    const flug_ternary_word64_t * __restrict vec_x,
    size_t words_per_row,
    int32_t gamma_q16_16,
    int32_t * __restrict out_re_q16_16,
    int32_t * __restrict out_im_q16_16
) {
    int32_t acc_re = 0;
    int32_t acc_im = 0;
    for (size_t k = 0; k < words_per_row; ++k) {
        if (!flug_word64_is_valid(&row_w[k]) || !flug_word64_is_valid(&vec_x[k])) {
            return false;
        }
        flug_dot_word64(&row_w[k], &vec_x[k], &acc_re, &acc_im);
    }
    *out_re_q16_16 = (int32_t)((int64_t)acc_re * (int64_t)gamma_q16_16);
    *out_im_q16_16 = (int32_t)((int64_t)acc_im * (int64_t)gamma_q16_16);
    return true;
}

#endif // FLUG_OS_ESP32S3_TERNARY_H
