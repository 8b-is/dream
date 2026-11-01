/*
 * ESP32-S3 FLUG-OS Sovereign Guardian Contraction Kernel
 * with Active Parity Interlock (UltraDreamState v2.0)
 */
#ifndef FLUG_COMPLEX_TERNARY_H
#define FLUG_COMPLEX_TERNARY_H

#include <stdint.h>
#include <stdbool.h>

typedef struct __attribute__((aligned(32))) {
    uint64_t r_pos; // B^{R+}
    uint64_t r_neg; // B^{R-}
    uint64_t i_pos; // B^{I+}
    uint64_t i_neg; // B^{I-}
} flug_ternary_word64_t;

static inline bool flug_word64_is_valid(const flug_ternary_word64_t *w) {
    return (((w->r_pos & w->r_neg) | (w->i_pos & w->i_neg)) == 0ULL);
}

static inline bool flug_dot_word64(
    const flug_ternary_word64_t * restrict w,
    const flug_ternary_word64_t * restrict x,
    int32_t * restrict acc_re,
    int32_t * restrict acc_im
) {
    if (!flug_word64_is_valid(w) || !flug_word64_is_valid(x)) {
        return false; // Immediate O(1) Hardware Invariant 1 trap
    }
    uint64_t p_re_pos = (w->r_pos & x->r_pos) | (w->r_neg & x->r_neg);
    uint64_t q_re_pos = (w->i_pos & x->i_neg) | (w->i_neg & x->i_pos);
    uint64_t p_re_neg = (w->r_pos & x->r_neg) | (w->r_neg & x->r_pos);
    uint64_t q_re_neg = (w->i_pos & x->i_pos) | (w->i_neg & x->i_neg);

    int32_t re_pos = __builtin_popcountll(p_re_pos) + __builtin_popcountll(q_re_pos);
    int32_t re_neg = __builtin_popcountll(p_re_neg) + __builtin_popcountll(q_re_neg);
    *acc_re += (re_pos - re_neg);

    uint64_t p_im_pos = (w->r_pos & x->i_pos) | (w->r_neg & x->i_neg);
    uint64_t q_im_pos = (w->i_pos & x->r_pos) | (w->i_neg & x->r_neg);
    uint64_t p_im_neg = (w->r_pos & x->i_neg) | (w->r_neg & x->i_pos);
    uint64_t q_im_neg = (w->i_pos & x->r_neg) | (w->i_neg & x->r_pos);

    int32_t im_pos = __builtin_popcountll(p_im_pos) + __builtin_popcountll(q_im_pos);
    int32_t im_neg = __builtin_popcountll(p_im_neg) + __builtin_popcountll(q_im_neg);
    *acc_im += (im_pos - im_neg);
    return true;
}

#endif /* FLUG_COMPLEX_TERNARY_H */
