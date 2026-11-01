use mem8_ternary_rs::{
    compute_waking_seal_blake3, contract_row_q16_16, decode_balanced_ternary_lsb, hex_decode32,
    hex_encode, measure_carrier_phase_error_deg, pack_row_sigma_delta_f32, ComplexTernaryWord64,
    CANONICAL_FIB_HEAD_F0_TO_F3, CANONICAL_FIB_STRIP_F1_TO_F12,
};

fn main() {
    let rows = [
        ComplexTernaryWord64 {
            r_pos: 0xAAAAAAAAAAAAAAAA,
            r_neg: 0x5555555555555555,
            i_pos: 0xF0F0F0F0F0F0F0F0,
            i_neg: 0x0F0F0F0F0F0F0F0F,
        },
        ComplexTernaryWord64 {
            r_pos: 0xCCCCCCCCCCCCCCCC,
            r_neg: 0x3333333333333333,
            i_pos: 0xFF00FF00FF00FF00,
            i_neg: 0x00FF00FF00FF00FF,
        },
        ComplexTernaryWord64 {
            r_pos: 0xF0F0F0F0F0F0F0F0,
            r_neg: 0x0F0F0F0F0F0F0F0F,
            i_pos: 0xAAAAAAAAAAAAAAAA,
            i_neg: 0x5555555555555555,
        },
        ComplexTernaryWord64 {
            r_pos: 0xFFFF0000FFFF0000,
            r_neg: 0x0000FFFF0000FFFF,
            i_pos: 0xCCCCCCCCCCCCCCCC,
            i_neg: 0x3333333333333333,
        },
    ];
    let x_vec = [ComplexTernaryWord64 {
        r_pos: 0xAAAAAAAAAAAAAAAA,
        r_neg: 0x5555555555555555,
        i_pos: 0xCCCCCCCCCCCCCCCC,
        i_neg: 0x3333333333333333,
    }];
    let gamma_q16_16 = [32768i32, 32768, 32768, 32768];

    let mut out_re = [0i32; 4];
    let mut out_im = [0i32; 4];
    for r in 0..4 {
        let (re, im) = contract_row_q16_16(&rows[r..r + 1], &x_vec, gamma_q16_16[r])
            .expect("canonical test tile satisfies sign-plane mutual exclusion");
        out_re[r] = re;
        out_im[r] = im;
    }

    let genesis_seed =
        hex_decode32("25b3cfadda15081e99f8595b205c1611bbb14eac9bbfdc8f489fb361c7a63f4e")
            .unwrap();
    let tombstone_root = [0u8; 32];
    let (mu, seal) = compute_waking_seal_blake3(
        &genesis_seed,
        1,
        &gamma_q16_16,
        &rows,
        &tombstone_root,
        63865, // 0.9745 in Q16.16
    );

    // Measure actual carrier phase error of the implemented nonlinear Sigma-Delta packer
    // across 32 phase offsets at OSR = 8 (k0 = pi / 8).
    let k0_rad: f32 = std::f32::consts::PI / 8.0;
    let gamma: f32 = 0.5;
    let mut sq_err_sum = 0.0f64;
    let trials = 32;
    for t in 0..trials {
        let phi0 = (t as f32) * (2.0 * std::f32::consts::PI / (trials as f32));
        let mut u_row = [0.0f32; 64];
        let mut v_row = [0.0f32; 64];
        for n in 0..64 {
            let theta = k0_rad * (n as f32) + phi0;
            u_row[n] = 0.85 * theta.cos();
            v_row[n] = 0.85 * theta.sin();
        }
        let mut packed = [ComplexTernaryWord64::default(); 1];
        pack_row_sigma_delta_f32(&u_row, &v_row, &mut packed, gamma, k0_rad);
        let deg = measure_carrier_phase_error_deg(&u_row, &v_row, &packed, gamma, k0_rad);
        sq_err_sum += deg * deg;
    }
    let measured_carrier_rms_deg = (sq_err_sum / (trials as f64)).sqrt();

    let decoded_f1_12: Vec<i64> = CANONICAL_FIB_STRIP_F1_TO_F12
        .split_whitespace()
        .map(|s| decode_balanced_ternary_lsb(s).unwrap())
        .collect();
    let decoded_f0_3: Vec<i64> = CANONICAL_FIB_HEAD_F0_TO_F3
        .split_whitespace()
        .map(|s| decode_balanced_ternary_lsb(s).unwrap())
        .collect();

    println!(
        "{{\"target\":\"rust-reference-oracle\",\"crate\":\"mem8-ternary-rs\",\"parity_fault\":false,\
         \"out_re_q16_16\":[{},{},{},{}],\"out_im_q16_16\":[{},{},{},{}],\
         \"mu_blake3\":\"{}\",\"waking_seal_blake3\":\"{}\",\
         \"measured_sigma_delta_carrier_phase_rms_deg\":{:.4},\
         \"fib_strip_f1_to_f12\":\"{}\",\
         \"fib_decoded_f1_to_f12\":{:?},\
         \"fib_head_f0_to_f3\":\"{}\",\
         \"fib_decoded_f0_to_f3\":{:?}}}",
        out_re[0],
        out_re[1],
        out_re[2],
        out_re[3],
        out_im[0],
        out_im[1],
        out_im[2],
        out_im[3],
        hex_encode(&mu),
        hex_encode(&seal),
        measured_carrier_rms_deg,
        CANONICAL_FIB_STRIP_F1_TO_F12,
        decoded_f1_12,
        CANONICAL_FIB_HEAD_F0_TO_F3,
        decoded_f0_3,
    );
}
