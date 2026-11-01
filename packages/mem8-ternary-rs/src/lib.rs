//! `mem8-ternary-rs` — Bit-Exact Rust Reference Oracle for UltraDreamState
//!
//! Ontological Boundary Contract (8B-META-WP-v0.0):
//! - Column A (Mechanical Substrate):
//!   1. `ComplexTernaryWord64` (`#[repr(C, align(32))]`) with sign-plane mutual exclusion
//!      invariant `(r_pos & r_neg) | (i_pos & i_neg) == 0`.
//!   2. Multiplier-free 8-mask `count_ones()` (`@popcount`) contraction verified exhaustively
//!      across all 81 pairs `(w, x) in T_C^2`.
//!   3. First-order spatial Sigma-Delta row packer (both `f32` and deterministic `Q16.16`
//!      fixed-point with gap-aware carrier rotation) and direct DFT in-band RMS phase measurement.
//!   4. Official spec-compliant BLAKE3 (`mu^{(n+1)}` and `S^{(n+1)}` Waking Seal) verified
//!      against the official BLAKE3 test vectors.
//!   5. Pure-NAND 64-bit ripple-carry Fibonacci cascade (`OEIS A000045`, 576 2-input NAND gates
//!      per addition) with strict LSB-first balanced-ternary codec and parity-law assertions.

/// Orthogonal 4-bit-per-node complex ternary word covering 64 lattice sites (32 bytes).
#[repr(C, align(32))]
#[derive(Clone, Copy, Debug, Default, PartialEq, Eq)]
pub struct ComplexTernaryWord64 {
    pub r_pos: u64,
    pub r_neg: u64,
    pub i_pos: u64,
    pub i_neg: u64,
}

impl ComplexTernaryWord64 {
    /// Hardware Invariant 1 (Sign-plane mutual exclusion):
    /// `(B^{R+} & B^{R-}) | (B^{I+} & B^{I-}) == 0`.
    #[inline]
    pub const fn is_valid(&self) -> bool {
        ((self.r_pos & self.r_neg) | (self.i_pos & self.i_neg)) == 0
    }

    /// Serializes the 4 bit-planes in canonical little-endian byte order (32 bytes).
    #[inline]
    pub const fn to_le_bytes(&self) -> [u8; 32] {
        let rp = self.r_pos.to_le_bytes();
        let rn = self.r_neg.to_le_bytes();
        let ip = self.i_pos.to_le_bytes();
        let ineg = self.i_neg.to_le_bytes();
        let mut out = [0u8; 32];
        let mut i = 0;
        while i < 8 {
            out[i] = rp[i];
            out[8 + i] = rn[i];
            out[16 + i] = ip[i];
            out[24 + i] = ineg[i];
            i += 1;
        }
        out
    }

    /// Multiplier-free complex ternary dot product of two 64-node words using 8 Boolean
    /// quadrature masks and population counts. Returns `None` if either word violates
    /// the sign-plane mutual exclusion invariant.
    #[inline]
    pub const fn dot_checked(&self, x: &Self) -> Option<(i32, i32)> {
        if !self.is_valid() || !x.is_valid() {
            return None;
        }
        let p_re_pos = (self.r_pos & x.r_pos) | (self.r_neg & x.r_neg);
        let q_re_pos = (self.i_pos & x.i_neg) | (self.i_neg & x.i_pos);
        let p_re_neg = (self.r_pos & x.r_neg) | (self.r_neg & x.r_pos);
        let q_re_neg = (self.i_pos & x.i_pos) | (self.i_neg & x.i_neg);

        let p_im_pos = (self.r_pos & x.i_pos) | (self.r_neg & x.i_neg);
        let q_im_pos = (self.i_pos & x.r_pos) | (self.i_neg & x.r_neg);
        let p_im_neg = (self.r_pos & x.i_neg) | (self.r_neg & x.i_pos);
        let q_im_neg = (self.i_pos & x.r_neg) | (self.i_neg & x.r_pos);

        let re_pos = (p_re_pos.count_ones() + q_re_pos.count_ones()) as i32;
        let re_neg = (p_re_neg.count_ones() + q_re_neg.count_ones()) as i32;
        let im_pos = (p_im_pos.count_ones() + q_im_pos.count_ones()) as i32;
        let im_neg = (p_im_neg.count_ones() + q_im_neg.count_ones()) as i32;

        Some((re_pos - re_neg, im_pos - im_neg))
    }
}

/// Contracts a multi-word row `w_row` against `x_vec` and scales by `gamma_q16_16` outside
/// the contraction loop. Returns `None` if any word fails `is_valid()`.
pub fn contract_row_q16_16(
    w_row: &[ComplexTernaryWord64],
    x_vec: &[ComplexTernaryWord64],
    gamma_q16_16: i32,
) -> Option<(i32, i32)> {
    if w_row.len() != x_vec.len() {
        return None;
    }
    let mut acc_re: i32 = 0;
    let mut acc_im: i32 = 0;
    for (w, x) in w_row.iter().zip(x_vec.iter()) {
        let (dr, di) = w.dot_checked(x)?;
        acc_re = acc_re.checked_add(dr)?;
        acc_im = acc_im.checked_add(di)?;
    }
    let out_re = ((acc_re as i64) * (gamma_q16_16 as i64)) as i32;
    let out_im = ((acc_im as i64) * (gamma_q16_16 as i64)) as i32;
    Some((out_re, out_im))
}

/// Causal first-order spatial Sigma-Delta row packer (`f32` reference matching Listing 3).
pub fn pack_row_sigma_delta_f32(
    u_row: &[f32],
    v_row: &[f32],
    out_words: &mut [ComplexTernaryWord64],
    gamma: f32,
    k0_rad: f32,
) {
    assert_eq!(u_row.len(), out_words.len() * 64);
    assert_eq!(v_row.len(), out_words.len() * 64);
    let delta: f32 = 0.5 * gamma;
    let h_r: f32 = k0_rad.cos();
    let h_i: f32 = k0_rad.sin();
    let mut err_r: f32 = 0.0;
    let mut err_i: f32 = 0.0;

    for (w_idx, word) in out_words.iter_mut().enumerate() {
        let mut r_pos: u64 = 0;
        let mut r_neg: u64 = 0;
        let mut i_pos: u64 = 0;
        let mut i_neg: u64 = 0;
        let base = w_idx * 64;

        for b in 0..64 {
            let u = u_row[base + b];
            let v = v_row[base + b];
            if (u != 0.0) || (v != 0.0) {
                let u_tilde = u + (h_r * err_r - h_i * err_i);
                let v_tilde = v + (h_r * err_i + h_i * err_r);
                let mask: u64 = 1u64 << b;

                let mut q_r: f32 = 0.0;
                if u_tilde > delta {
                    r_pos |= mask;
                    q_r = 1.0;
                } else if u_tilde < -delta {
                    r_neg |= mask;
                    q_r = -1.0;
                }

                let mut q_i: f32 = 0.0;
                if v_tilde > delta {
                    i_pos |= mask;
                    q_i = 1.0;
                } else if v_tilde < -delta {
                    i_neg |= mask;
                    q_i = -1.0;
                }

                err_r = (u_tilde - gamma * q_r).clamp(-delta, delta);
                err_i = (v_tilde - gamma * q_i).clamp(-delta, delta);
            }
        }
        *word = ComplexTernaryWord64 {
            r_pos,
            r_neg,
            i_pos,
            i_neg,
        };
        debug_assert!(word.is_valid());
    }
}

/// Deterministic `Q16.16` fixed-point first-order Sigma-Delta row packer.
/// Avoids platform libm/FMA drift so independent nodes generate bit-identical bit-planes.
pub fn pack_row_sigma_delta_q16_16(
    u_q16: &[i32],
    v_q16: &[i32],
    out_words: &mut [ComplexTernaryWord64],
    gamma_q16: i32,
    cos_k0_q16: i32,
    sin_k0_q16: i32,
) {
    assert_eq!(u_q16.len(), out_words.len() * 64);
    assert_eq!(v_q16.len(), out_words.len() * 64);
    let delta_q16: i32 = gamma_q16 >> 1;
    let mut err_r_q16: i32 = 0;
    let mut err_i_q16: i32 = 0;

    for (w_idx, word) in out_words.iter_mut().enumerate() {
        let mut r_pos: u64 = 0;
        let mut r_neg: u64 = 0;
        let mut i_pos: u64 = 0;
        let mut i_neg: u64 = 0;
        let base = w_idx * 64;

        for b in 0..64 {
            let u = u_q16[base + b];
            let v = v_q16[base + b];
            if (u != 0) || (v != 0) {
                let rot_r = (((cos_k0_q16 as i64) * (err_r_q16 as i64)
                    - (sin_k0_q16 as i64) * (err_i_q16 as i64))
                    >> 16) as i32;
                let rot_i = (((cos_k0_q16 as i64) * (err_i_q16 as i64)
                    + (sin_k0_q16 as i64) * (err_r_q16 as i64))
                    >> 16) as i32;
                let u_tilde = u.saturating_add(rot_r);
                let v_tilde = v.saturating_add(rot_i);
                let mask: u64 = 1u64 << b;

                let mut q_r: i32 = 0;
                if u_tilde > delta_q16 {
                    r_pos |= mask;
                    q_r = gamma_q16;
                } else if u_tilde < -delta_q16 {
                    r_neg |= mask;
                    q_r = -gamma_q16;
                }

                let mut q_i: i32 = 0;
                if v_tilde > delta_q16 {
                    i_pos |= mask;
                    q_i = gamma_q16;
                } else if v_tilde < -delta_q16 {
                    i_neg |= mask;
                    q_i = -gamma_q16;
                }

                err_r_q16 = (u_tilde - q_r).clamp(-delta_q16, delta_q16);
                err_i_q16 = (v_tilde - q_i).clamp(-delta_q16, delta_q16);
            }
        }
        *word = ComplexTernaryWord64 {
            r_pos,
            r_neg,
            i_pos,
            i_neg,
        };
        debug_assert!(word.is_valid());
    }
}

/// Measures the actual carrier-demodulated phase error (in degrees) of a packed row
/// against the reference complex wave `(u_row, v_row)` at wavenumber `k0_rad`.
pub fn measure_carrier_phase_error_deg(
    u_row: &[f32],
    v_row: &[f32],
    words: &[ComplexTernaryWord64],
    gamma: f32,
    k0_rad: f32,
) -> f64 {
    let mut ref_re = 0.0f64;
    let mut ref_im = 0.0f64;
    let mut q_re = 0.0f64;
    let mut q_im = 0.0f64;

    for (w_idx, w) in words.iter().enumerate() {
        for b in 0..64 {
            let n = w_idx * 64 + b;
            let angle = -(k0_rad as f64) * (n as f64);
            let (s, c) = angle.sin_cos();

            let u = u_row[n] as f64;
            let v = v_row[n] as f64;
            ref_re += u * c - v * s;
            ref_im += u * s + v * c;

            let wr = (((w.r_pos >> b) & 1) as i32 - ((w.r_neg >> b) & 1) as i32) as f64 * (gamma as f64);
            let wi = (((w.i_pos >> b) & 1) as i32 - ((w.i_neg >> b) & 1) as i32) as f64 * (gamma as f64);
            q_re += wr * c - wi * s;
            q_im += wr * s + wi * c;
        }
    }
    let theta_ref = ref_im.atan2(ref_re);
    let theta_q = q_im.atan2(q_re);
    let mut diff = (theta_q - theta_ref).abs();
    if diff > std::f64::consts::PI {
        diff = 2.0 * std::f64::consts::PI - diff;
    }
    diff.to_degrees()
}

// =============================================================================
// Official Spec-Compliant BLAKE3 Implementation (Single-Chunk <= 1024 B)
// =============================================================================

const BLAKE3_IV: [u32; 8] = [
    0x6A09E667, 0xBB67AE85, 0x3C6EF372, 0xA54FF53A,
    0x510E527F, 0x9B05688C, 0x1F83D9AB, 0x5BE0CD19,
];

const BLAKE3_MSG_PERM: [usize; 16] = [2, 6, 3, 10, 7, 0, 4, 13, 1, 11, 12, 5, 9, 14, 15, 8];

const CHUNK_START: u32 = 1 << 0;
const CHUNK_END: u32 = 1 << 1;
const ROOT: u32 = 1 << 3;

#[inline]
fn blake3_g(state: &mut [u32; 16], a: usize, b: usize, c: usize, d: usize, mx: u32, my: u32) {
    state[a] = state[a].wrapping_add(state[b]).wrapping_add(mx);
    state[d] = (state[d] ^ state[a]).rotate_right(16);
    state[c] = state[c].wrapping_add(state[d]);
    state[b] = (state[b] ^ state[c]).rotate_right(12);
    state[a] = state[a].wrapping_add(state[b]).wrapping_add(my);
    state[d] = (state[d] ^ state[a]).rotate_right(8);
    state[c] = state[c].wrapping_add(state[d]);
    state[b] = (state[b] ^ state[c]).rotate_right(7);
}

fn blake3_round(state: &mut [u32; 16], m: &[u32; 16]) {
    blake3_g(state, 0, 4, 8, 12, m[0], m[1]);
    blake3_g(state, 1, 5, 9, 13, m[2], m[3]);
    blake3_g(state, 2, 6, 10, 14, m[4], m[5]);
    blake3_g(state, 3, 7, 11, 15, m[6], m[7]);
    blake3_g(state, 0, 5, 10, 15, m[8], m[9]);
    blake3_g(state, 1, 6, 11, 12, m[10], m[11]);
    blake3_g(state, 2, 7, 8, 13, m[12], m[13]);
    blake3_g(state, 3, 4, 9, 14, m[14], m[15]);
}

fn blake3_compress(
    chaining_value: &[u32; 8],
    block_words: &[u32; 16],
    counter: u64,
    block_len: u32,
    flags: u32,
) -> [u32; 16] {
    let mut state = [
        chaining_value[0],
        chaining_value[1],
        chaining_value[2],
        chaining_value[3],
        chaining_value[4],
        chaining_value[5],
        chaining_value[6],
        chaining_value[7],
        BLAKE3_IV[0],
        BLAKE3_IV[1],
        BLAKE3_IV[2],
        BLAKE3_IV[3],
        counter as u32,
        (counter >> 32) as u32,
        block_len,
        flags,
    ];
    let mut block = *block_words;
    for r in 0..7 {
        blake3_round(&mut state, &block);
        if r < 6 {
            let mut permuted = [0u32; 16];
            for i in 0..16 {
                permuted[i] = block[BLAKE3_MSG_PERM[i]];
            }
            block = permuted;
        }
    }
    for i in 0..8 {
        state[i] ^= state[i + 8];
        state[i + 8] ^= chaining_value[i];
    }
    state
}

/// Computes the official 32-byte BLAKE3 hash of `input` (supports inputs up to 1024 bytes,
/// covering all bit-plane tiles and Waking Seal manifests).
pub fn blake3_hash(input: &[u8]) -> [u8; 32] {
    assert!(input.len() <= 1024, "single-chunk BLAKE3 requires input <= 1024 bytes");
    let mut cv = BLAKE3_IV;
    let num_blocks = if input.is_empty() {
        1
    } else {
        (input.len() + 63) / 64
    };

    for b_idx in 0..num_blocks {
        let start = b_idx * 64;
        let end = (start + 64).min(input.len());
        let slice = &input[start..end];
        let mut block_bytes = [0u8; 64];
        block_bytes[..slice.len()].copy_from_slice(slice);

        let mut block_words = [0u32; 16];
        for (i, chunk) in block_bytes.chunks_exact(4).enumerate() {
            block_words[i] = u32::from_le_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]);
        }

        let mut flags = 0u32;
        if b_idx == 0 {
            flags |= CHUNK_START;
        }
        if b_idx + 1 == num_blocks {
            flags |= CHUNK_END | ROOT;
        }

        let out = blake3_compress(&cv, &block_words, 0, slice.len() as u32, flags);
        cv.copy_from_slice(&out[..8]);
    }

    let mut digest = [0u8; 32];
    for (i, word) in cv.iter().enumerate() {
        digest[i * 4..(i + 1) * 4].copy_from_slice(&word.to_le_bytes());
    }
    digest
}

/// Computes the present-state commitment `\mu^{(n+1)} = BLAKE3(tag || LE32(gamma_q16_16) || B)`
/// and history-chained Waking Seal `S^{(n+1)}` (Section 7 Eqs. 16-17).
pub fn compute_waking_seal_blake3(
    prev_seal: &[u8; 32],
    epoch: u64,
    gamma_q16_16: &[i32],
    words: &[ComplexTernaryWord64],
    tombstone_root: &[u8; 32],
    r_quant_q16_16: i32,
) -> ([u8; 32], [u8; 32]) {
    let mut mu_buf = Vec::with_capacity(16 + gamma_q16_16.len() * 4 + words.len() * 32);
    mu_buf.extend_from_slice(b"8B-ULTRADREAM-v1");
    for &g in gamma_q16_16 {
        mu_buf.extend_from_slice(&g.to_le_bytes());
    }
    for w in words {
        mu_buf.extend_from_slice(&w.to_le_bytes());
    }
    let mu = blake3_hash(&mu_buf);

    let mut seal_buf = Vec::with_capacity(32 + 32 + 32 + 4 + 8);
    seal_buf.extend_from_slice(prev_seal);
    seal_buf.extend_from_slice(&mu);
    seal_buf.extend_from_slice(tombstone_root);
    seal_buf.extend_from_slice(&r_quant_q16_16.to_le_bytes());
    seal_buf.extend_from_slice(&epoch.to_le_bytes());
    let seal = blake3_hash(&seal_buf);
    (mu, seal)
}

// =============================================================================
// Pure-NAND 64-Bit Ripple-Carry Adder & LSB-First Balanced-Ternary Fibonacci
// =============================================================================

/// Primitive 2-input NAND gate — sole boolean primitive for the Fibonacci cascade.
#[inline]
pub const fn nand(a: u8, b: u8) -> u8 {
    ((a & 1) & (b & 1)) ^ 1
}

/// 1-bit full adder constructed from 9 primitive 2-input `nand(a, b)` gates.
#[inline]
pub const fn nand_full_adder(a: u8, b: u8, cin: u8) -> (u8, u8) {
    let g1 = nand(a, b);
    let g2 = nand(a, g1);
    let g3 = nand(b, g1);
    let axb = nand(g2, g3);
    let g5 = nand(axb, cin);
    let g6 = nand(axb, g5);
    let g7 = nand(cin, g5);
    let sum = nand(g6, g7);
    let cout = nand(g1, g5);
    (sum, cout)
}

/// 64-bit ripple-carry adder built strictly from 576 primitive 2-input NAND gates (`64 * 9`).
#[inline]
pub const fn nand_add64(x: u64, y: u64) -> u64 {
    let mut carry: u8 = 0;
    let mut result: u64 = 0;
    let mut bit: u32 = 0;
    while bit < 64 {
        let a = ((x >> bit) & 1) as u8;
        let b = ((y >> bit) & 1) as u8;
        let (sum, cout) = nand_full_adder(a, b, carry);
        result |= (sum as u64) << bit;
        carry = cout;
        bit += 1;
    }
    result
}

/// Encodes an unsigned integer into strict LSB-first balanced ternary (`-`, `0`, `+`),
/// where character `k` has weight `3^k`.
pub fn encode_balanced_ternary_lsb(n: u64) -> String {
    if n == 0 {
        return "0".to_string();
    }
    let mut digits = Vec::new();
    let mut val = n;
    while val != 0 {
        let rem = val % 3;
        val /= 3;
        match rem {
            0 => digits.push('0'),
            1 => digits.push('+'),
            2 => {
                digits.push('-');
                val = nand_add64(val, 1);
            }
            _ => unreachable!(),
        }
    }
    digits.into_iter().collect()
}

/// Encodes an unsigned integer into strict LSB-first balanced ternary right-padded with `'0'`
/// to at least `min_width` trits (preserving LSB-first value under trailing zeros).
pub fn encode_balanced_ternary_lsb_padded(n: u64, min_width: usize) -> String {
    let mut s = encode_balanced_ternary_lsb(n);
    while s.len() < min_width {
        s.push('0');
    }
    s
}

/// Decodes an LSB-first balanced-ternary token (`s[k]` carries weight `3^k`).
pub fn decode_balanced_ternary_lsb(token: &str) -> Result<i64, String> {
    if token.is_empty() {
        return Err("empty balanced-ternary token".to_string());
    }
    let mut total: i64 = 0;
    let mut power: i64 = 1;
    for ch in token.chars() {
        match ch {
            '+' => total += power,
            '-' => total -= power,
            '0' => {}
            _ => return Err(format!("invalid balanced-ternary mark: {:?}", ch)),
        }
        power *= 3;
    }
    Ok(total)
}

/// Canonical 12-token LSB-first unpadded Fibonacci strip `F(1)..F(12) = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]` (UltraDreamState v2.0).
pub const CANONICAL_FIB_STRIP_F1_TO_F12_UNPADDED: &str =
    "+ + -+ 0+ --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+";

/// Canonical 12-token LSB-first padded Fibonacci strip `F(1)..F(12) = [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]`.
pub const CANONICAL_FIB_STRIP_F1_TO_F12: &str =
    "+00 +00 -+0 0+0 --+ -0+ +++ 0+-+ +-++ +00-+ -0+0+ 00+--+";

/// Canonical 12-token LSB-first padded Fibonacci strip starting from `F(0)..F(3) = [0, 1, 1, 2]` followed by `F(5)..F(12)`.
pub const CANONICAL_FIB_HEAD_F0_TO_F3: &str = "000 +00 +00 -+0";

pub mod complex_ternary;

/// Zero-dependency SHA-256 reference implementation used by `complex_ternary::waking_seal`.
pub fn sha256(data: &[u8]) -> [u8; 32] {
    const K: [u32; 64] = [
        0x428a2f98, 0x71374491, 0xb5c0fbcf, 0xe9b5dba5, 0x3956c25b, 0x59f111f1, 0x923f82a4,
        0xab1c5ed5, 0xd807aa98, 0x12835b01, 0x243185be, 0x550c7dc3, 0x72be5d74, 0x80deb1fe,
        0x9bdc06a7, 0xc19bf174, 0xe49b69c1, 0xefbe4786, 0x0fc19dc6, 0x240ca1cc, 0x2de92c6f,
        0x4a7484aa, 0x5cb0a9dc, 0x76f988da, 0x983e5152, 0xa831c66d, 0xb00327c8, 0xbf597fc7,
        0xc6e00bf3, 0xd5a79147, 0x06ca6351, 0x14292967, 0x27b70a85, 0x2e1b2138, 0x4d2c6dfc,
        0x53380d13, 0x650a7354, 0x766a0abb, 0x81c2c92e, 0x92722c85, 0xa2bfe8a1, 0xa81a664b,
        0xc24b8b70, 0xc76c51a3, 0xd192e819, 0xd6990624, 0xf40e3585, 0x106aa070, 0x19a4c116,
        0x1e376c08, 0x2748774c, 0x34b0bcb5, 0x391c0cb3, 0x4ed8aa4a, 0x5b9cca4f, 0x682e6ff3,
        0x748f82ee, 0x78a5636f, 0x84c87814, 0x8cc70208, 0x90befffa, 0xa4506ceb, 0xbef9a3f7,
        0xc67178f2,
    ];
    let mut h: [u32; 8] = [
        0x6a09e667, 0xbb67ae85, 0x3c6ef372, 0xa54ff53a, 0x510e527f, 0x9b05688c, 0x1f83d9ab,
        0x5be0cd19,
    ];

    let bit_len = (data.len() as u64) * 8;
    let mut padded = Vec::with_capacity(data.len() + 72);
    padded.extend_from_slice(data);
    padded.push(0x80);
    while (padded.len() % 64) != 56 {
        padded.push(0x00);
    }
    padded.extend_from_slice(&bit_len.to_be_bytes());

    for chunk in padded.chunks_exact(64) {
        let mut w = [0u32; 64];
        for i in 0..16 {
            w[i] = u32::from_be_bytes([
                chunk[i * 4],
                chunk[i * 4 + 1],
                chunk[i * 4 + 2],
                chunk[i * 4 + 3],
            ]);
        }
        for i in 16..64 {
            let s0 = w[i - 15].rotate_right(7) ^ w[i - 15].rotate_right(18) ^ (w[i - 15] >> 3);
            let s1 = w[i - 2].rotate_right(17) ^ w[i - 2].rotate_right(19) ^ (w[i - 2] >> 10);
            w[i] = w[i - 16]
                .wrapping_add(s0)
                .wrapping_add(w[i - 7])
                .wrapping_add(s1);
        }

        let mut a = h[0];
        let mut b = h[1];
        let mut c = h[2];
        let mut d = h[3];
        let mut e = h[4];
        let mut f = h[5];
        let mut g = h[6];
        let mut hh = h[7];

        for i in 0..64 {
            let s1 = e.rotate_right(6) ^ e.rotate_right(11) ^ e.rotate_right(25);
            let ch = (e & f) ^ ((!e) & g);
            let temp1 = hh
                .wrapping_add(s1)
                .wrapping_add(ch)
                .wrapping_add(K[i])
                .wrapping_add(w[i]);
            let s0 = a.rotate_right(2) ^ a.rotate_right(13) ^ a.rotate_right(22);
            let maj = (a & b) ^ (a & c) ^ (b & c);
            let temp2 = s0.wrapping_add(maj);

            hh = g;
            g = f;
            f = e;
            e = d.wrapping_add(temp1);
            d = c;
            c = b;
            b = a;
            a = temp1.wrapping_add(temp2);
        }

        h[0] = h[0].wrapping_add(a);
        h[1] = h[1].wrapping_add(b);
        h[2] = h[2].wrapping_add(c);
        h[3] = h[3].wrapping_add(d);
        h[4] = h[4].wrapping_add(e);
        h[5] = h[5].wrapping_add(f);
        h[6] = h[6].wrapping_add(g);
        h[7] = h[7].wrapping_add(hh);
    }

    let mut out = [0u8; 32];
    for (i, word) in h.iter().enumerate() {
        out[i * 4..i * 4 + 4].copy_from_slice(&word.to_be_bytes());
    }
    out
}

pub fn hex_encode(bytes: &[u8]) -> String {
    const HEX: &[u8; 16] = b"0123456789abcdef";
    let mut out = String::with_capacity(bytes.len() * 2);
    for &b in bytes {
        out.push(HEX[(b >> 4) as usize] as char);
        out.push(HEX[(b & 0x0F) as usize] as char);
    }
    out
}

pub fn hex_decode32(s: &str) -> Option<[u8; 32]> {
    if s.len() < 64 {
        return None;
    }
    let mut out = [0u8; 32];
    let bytes = s.as_bytes();
    for i in 0..32 {
        let hi = (bytes[i * 2] as char).to_digit(16)? as u8;
        let lo = (bytes[i * 2 + 1] as char).to_digit(16)? as u8;
        out[i] = (hi << 4) | lo;
    }
    Some(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn proposition_3_exhaustive_81_pair_complex_ternary_contraction() {
        let trits: [i32; 3] = [-1, 0, 1];
        for &wr in &trits {
            for &wi in &trits {
                for &xr in &trits {
                    for &xi in &trits {
                        let w = ComplexTernaryWord64 {
                            r_pos: if wr == 1 { 1 } else { 0 },
                            r_neg: if wr == -1 { 1 } else { 0 },
                            i_pos: if wi == 1 { 1 } else { 0 },
                            i_neg: if wi == -1 { 1 } else { 0 },
                        };
                        let x = ComplexTernaryWord64 {
                            r_pos: if xr == 1 { 1 } else { 0 },
                            r_neg: if xr == -1 { 1 } else { 0 },
                            i_pos: if xi == 1 { 1 } else { 0 },
                            i_neg: if xi == -1 { 1 } else { 0 },
                        };
                        assert!(w.is_valid());
                        assert!(x.is_valid());
                        let (got_re, got_im) = w.dot_checked(&x).unwrap();
                        let exp_re = wr * xr - wi * xi;
                        let exp_im = wr * xi + wi * xr;
                        assert_eq!((got_re, got_im), (exp_re, exp_im));
                    }
                }
            }
        }
    }

    #[test]
    fn invariant_1_traps_corrupt_simultaneous_sign_planes() {
        let bad_real = ComplexTernaryWord64 {
            r_pos: 1 << 7,
            r_neg: 1 << 7,
            i_pos: 0,
            i_neg: 0,
        };
        let good = ComplexTernaryWord64::default();
        assert!(!bad_real.is_valid());
        assert_eq!(bad_real.dot_checked(&good), None);
    }

    #[test]
    fn blake3_matches_official_test_vectors() {
        // Official BLAKE3("") test vector:
        let empty_hash = hex_encode(&blake3_hash(b""));
        assert_eq!(
            empty_hash,
            "af1349b9f5f9a1a6a0404dea36dcc9499bcb25c9adc112b7cc9a93cae41f3262"
        );
        // Official BLAKE3([0, 1, 2]) test vector:
        let three_hash = hex_encode(&blake3_hash(&[0u8, 1u8, 2u8]));
        assert_eq!(
            three_hash,
            "e1be4d7a8ab5560aa4199eea339849ba8e293d55ca0a81006726d184519e647f"
        );
    }

    #[test]
    fn nand_fibonacci_cascade_and_provenance_strip_head_verification() {
        // 1. Verify F(0)..F(39) via pure 2-input NAND ripple-carry adder + parity congruence law
        let mut f_prev = 0u64;
        let mut f_curr = 1u64;
        let mut strip_f1_to_f12 = Vec::new();
        for n in 0..=39usize {
            let val = if n == 0 {
                0
            } else if n == 1 {
                1
            } else {
                let next = nand_add64(f_prev, f_curr);
                f_prev = f_curr;
                f_curr = next;
                f_curr
            };
            let bt = encode_balanced_ternary_lsb(val);
            assert_eq!(decode_balanced_ternary_lsb(&bt).unwrap() as u64, val);
            let non_zero_marks = bt.chars().filter(|&c| c == '+' || c == '-').count();
            assert_eq!(n % 3 == 0, val % 2 == 0);
            assert_eq!(val % 2 == 0, non_zero_marks % 2 == 0);
            if (1..=12).contains(&n) {
                strip_f1_to_f12.push(encode_balanced_ternary_lsb_padded(val, 3));
            }
        }
        assert_eq!(f_curr, 63_245_986);
        assert_eq!(strip_f1_to_f12.join(" "), CANONICAL_FIB_STRIP_F1_TO_F12);

        // 2. Verify canonical F(1)..F(12) strip decodes LSB-first to [1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
        let decoded_f1_12: Vec<i64> = CANONICAL_FIB_STRIP_F1_TO_F12
            .split_whitespace()
            .map(|t| decode_balanced_ternary_lsb(t).unwrap())
            .collect();
        assert_eq!(
            decoded_f1_12,
            vec![1, 1, 2, 3, 5, 8, 13, 21, 34, 55, 89, 144]
        );

        // 3. Verify F(0)..F(3) head decodes LSB-first to [0, 1, 1, 2]
        let decoded_f0_3: Vec<i64> = CANONICAL_FIB_HEAD_F0_TO_F3
            .split_whitespace()
            .map(|t| decode_balanced_ternary_lsb(t).unwrap())
            .collect();
        assert_eq!(decoded_f0_3, vec![0, 1, 1, 2]);

        // 4. Regression test for Peter's provenance strip catch:
        // Left-padded MSB-style `00+ 00+ 0-+ 00+` silently decodes to [9, 9, 6, 9] under LSB-first!
        let corrupt_head: Vec<i64> = "00+ 00+ 0-+ 00+"
            .split_whitespace()
            .map(|t| decode_balanced_ternary_lsb(t).unwrap())
            .collect();
        assert_eq!(corrupt_head, vec![9, 9, 6, 9]);
        assert_ne!(corrupt_head, vec![1, 1, 2, 3]);
        assert_ne!(corrupt_head, vec![0, 1, 1, 2]);
    }
}
