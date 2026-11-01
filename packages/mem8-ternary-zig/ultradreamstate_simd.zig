const std = @import("std");
const math = std.math;
const Blake3 = std.crypto.hash.Blake3;

pub const Vec4u64 = @Vector(4, u64);
pub const Vec4u16 = @Vector(4, u16);
pub const Vec4i32 = @Vector(4, i32);
pub const Vec4f32 = @Vector(4, f32);

/// 64 Complex Ternary Nodes packed into four orthogonal 64-bit bit-planes.
/// Footprint: 32 bytes per 64 complex nodes (4 bits/node -> 32x compression vs Complex<f64>).
/// Invariant: (r_pos & r_neg) == 0 and (i_pos & i_neg) == 0.
pub const ComplexTernaryWord64 = extern struct {
    r_pos: u64 align(32) = 0, // B^{R+}
    r_neg: u64 = 0,           // B^{R-}
    i_pos: u64 = 0,           // B^{I+}
    i_neg: u64 = 0,           // B^{I-}

    /// Hardware parity / corruption trap check in O(1) bitwise ops.
    pub inline fn isValid(self: ComplexTernaryWord64) bool {
        return ((self.r_pos & self.r_neg) | (self.i_pos & self.i_neg)) == 0;
    }
};

/// 4-Row x 64-Column Interleaved SIMD Tile (128 bytes = 2 cache lines).
/// Lane k \in {0, 1, 2, 3} holds the bit-plane for row (m + k) at column word w.
pub const ComplexTernaryTile4x64 = extern struct {
    r_pos: Vec4u64 align(64) = @splat(0), // B^{R+} for 4 rows
    r_neg: Vec4u64 = @splat(0),           // B^{R-} for 4 rows
    i_pos: Vec4u64 = @splat(0),           // B^{I+} for 4 rows
    i_neg: Vec4u64 = @splat(0),           // B^{I-} for 4 rows

    /// Branchless 4-lane hardware parity check: verifies (B^+ & B^-) == 0 across all 4 rows at once.
    pub inline fn isValid(self: ComplexTernaryTile4x64) bool {
        const corrupted = (self.r_pos & self.r_neg) | (self.i_pos & self.i_neg);
        return @reduce(.Or, corrupted) == 0;
    }

    /// Packs 4 row-major ComplexTernaryWord64 entries at column `w` into a single contiguous SIMD tile.
    pub inline fn fromRowWords(
        row0: ComplexTernaryWord64,
        row1: ComplexTernaryWord64,
        row2: ComplexTernaryWord64,
        row3: ComplexTernaryWord64,
    ) ComplexTernaryTile4x64 {
        return .{
            .r_pos = .{ row0.r_pos, row1.r_pos, row2.r_pos, row3.r_pos },
            .r_neg = .{ row0.r_neg, row1.r_neg, row2.r_neg, row3.r_neg },
            .i_pos = .{ row0.i_pos, row1.i_pos, row2.i_pos, row3.i_pos },
            .i_neg = .{ row0.i_neg, row1.i_neg, row2.i_neg, row3.i_neg },
        };
    }
};

/// Canonical Q16.16 fixed-point representation for cross-architecture hash determinism.
pub inline fn toQ16_16(val: f32) i32 {
    const scaled = @round(val * 65536.0);
    return @intFromFloat(math.clamp(scaled, @as(f32, @floatFromInt(math.minInt(i32))), @as(f32, @floatFromInt(math.maxInt(i32)))));
}

pub inline fn fromQ16_16(q: i32) f32 {
    return @as(f32, @floatFromInt(q)) * (1.0 / 65536.0);
}

/// First-Order Spatial Sigma-Delta (ΣΔ) Bit-Plane Packer.
/// Sweeps a row of continuous post-dream nodes (u + iv), pushing quantization noise
/// out of the carrier wavenumber `k0_rad` while strictly preserving pruned zeros (|z| == 0).
pub fn packRowSigmaDelta(
    u_row: []const f32,
    v_row: []const f32,
    out_words: []ComplexTernaryWord64,
    gamma: f32,
    k0_rad: f32,
) void {
    std.debug.assert(u_row.len == v_row.len);
    std.debug.assert(u_row.len == out_words.len * 64);

    const delta: f32 = 0.5 * gamma;
    const h_r: f32 = @cos(k0_rad);
    const h_i: f32 = @sin(k0_rad);

    var err_r: f32 = 0.0;
    var err_i: f32 = 0.0;

    for (out_words, 0..) |*word, w_idx| {
        var r_pos: u64 = 0;
        var r_neg: u64 = 0;
        var i_pos: u64 = 0;
        var i_neg: u64 = 0;

        const base = w_idx * 64;

        for (0..64) |b| {
            const u = u_row[base + b];
            const v = v_row[base + b];

            // Zero-Leakage Sparsity Gate: M_{m,n} = I(|z| > 0)
            const is_active = (u != 0.0) or (v != 0.0);
            const fb_r = h_r * err_r - h_i * err_i;
            const fb_i = h_r * err_i + h_i * err_r;

            if (is_active) {
                const u_tilde = u + fb_r;
                const v_tilde = v + fb_i;

                const bit_mask: u64 = @as(u64, 1) << @intCast(b);

                var q_r: f32 = 0.0;
                if (u_tilde > delta) {
                    r_pos |= bit_mask;
                    q_r = 1.0;
                } else if (u_tilde < -delta) {
                    r_neg |= bit_mask;
                    q_r = -1.0;
                }

                var q_i: f32 = 0.0;
                if (v_tilde > delta) {
                    i_pos |= bit_mask;
                    q_i = 1.0;
                } else if (v_tilde < -delta) {
                    i_neg |= bit_mask;
                    q_i = -1.0;
                }

                err_r = math.clamp(u_tilde - gamma * q_r, -delta, delta);
                err_i = math.clamp(v_tilde - gamma * q_i, -delta, delta);
            } else {
                // Advance carrier phase across sparse gaps (Eq. 15)
                err_r = fb_r;
                err_i = fb_i;
            }
        }

        word.* = .{
            .r_pos = r_pos,
            .r_neg = r_neg,
            .i_pos = i_pos,
            .i_neg = i_neg,
        };
    }
}

/// 64-Wide Complex Ternary Dot Product (Single Word Pair).
pub inline fn dotWord64(w: ComplexTernaryWord64, x: ComplexTernaryWord64) struct { re: i32, im: i32 } {
    const rr_pos = @popCount((w.r_pos & x.r_pos) | (w.r_neg & x.r_neg));
    const rr_neg = @popCount((w.r_pos & x.r_neg) | (w.r_neg & x.r_pos));
    const rr: i32 = @as(i32, rr_pos) - @as(i32, rr_neg);

    const ii_pos = @popCount((w.i_pos & x.i_pos) | (w.i_neg & x.i_neg));
    const ii_neg = @popCount((w.i_pos & x.i_neg) | (w.i_neg & x.i_pos));
    const ii: i32 = @as(i32, ii_pos) - @as(i32, ii_neg);

    const ri_pos = @popCount((w.r_pos & x.i_pos) | (w.r_neg & x.i_neg));
    const ri_neg = @popCount((w.r_pos & x.i_neg) | (w.r_neg & x.i_pos));
    const ri: i32 = @as(i32, ri_pos) - @as(i32, ri_neg);

    const ir_pos = @popCount((w.i_pos & x.r_pos) | (w.i_neg & x.r_neg));
    const ir_neg = @popCount((w.i_pos & x.r_neg) | (w.i_neg & x.r_pos));
    const ir: i32 = @as(i32, ir_pos) - @as(i32, ir_neg);

    return .{
        .re = rr - ii,
        .im = ri + ir,
    };
}

/// Full Matrix-Vector Waking Contraction: y = \gamma * W * x (Scalar Reference)
pub fn contractMatrixVector(
    matrix_words: []const ComplexTernaryWord64,
    x_words: []const ComplexTernaryWord64,
    out_re: []f32,
    out_im: []f32,
    rows: usize,
    words_per_row: usize,
    gamma: f32,
) void {
    std.debug.assert(matrix_words.len == rows * words_per_row);
    std.debug.assert(x_words.len == words_per_row);
    std.debug.assert(out_re.len == rows and out_im.len == rows);

    for (0..rows) |m| {
        const row_slice = matrix_words[m * words_per_row .. (m + 1) * words_per_row];
        var acc_re: i32 = 0;
        var acc_im: i32 = 0;

        for (row_slice, x_words) |w_word, x_word| {
            const prod = dotWord64(w_word, x_word);
            acc_re += prod.re;
            acc_im += prod.im;
        }

        out_re[m] = gamma * @as(f32, @floatFromInt(acc_re));
        out_im[m] = gamma * @as(f32, @floatFromInt(acc_im));
    }
}

/// Transposes a row-major ComplexTernaryWord64 matrix (rows x words_per_row)
/// into a contiguous array of 4-row SIMD tiles ((rows / 4) x words_per_row).
pub fn packMatrixIntoTiles4x64(
    row_major_words: []const ComplexTernaryWord64,
    out_tiles: []ComplexTernaryTile4x64,
    rows: usize,
    words_per_row: usize,
) void {
    std.debug.assert(rows % 4 == 0);
    std.debug.assert(row_major_words.len == rows * words_per_row);
    std.debug.assert(out_tiles.len == (rows / 4) * words_per_row);

    const num_row_blocks = rows / 4;
    for (0..num_row_blocks) |rb| {
        const r0 = (rb * 4 + 0) * words_per_row;
        const r1 = (rb * 4 + 1) * words_per_row;
        const r2 = (rb * 4 + 2) * words_per_row;
        const r3 = (rb * 4 + 3) * words_per_row;
        const tile_base = rb * words_per_row;

        for (0..words_per_row) |w| {
            out_tiles[tile_base + w] = ComplexTernaryTile4x64.fromRowWords(
                row_major_words[r0 + w],
                row_major_words[r1 + w],
                row_major_words[r2 + w],
                row_major_words[r3 + w],
            );
        }
    }
}

/// Evaluates 4 rows x 64 columns (256 complex ternary nodes) in a single 32-bit safe SIMD pass
/// with active Hardware Invariant 1 parity interlock (UltraDreamState v2.0).
pub inline fn stepTile4x64(
    tile: ComplexTernaryTile4x64,
    x_r_pos: Vec4u64,
    x_r_neg: Vec4u64,
    x_i_pos: Vec4u64,
    x_i_neg: Vec4u64,
    re_acc: *Vec4i32,
    im_acc: *Vec4i32,
) bool {
    if (!tile.isValid()) return false;
    const rr_pos: Vec4i32 = @as(Vec4i32, @popCount((tile.r_pos & x_r_pos) | (tile.r_neg & x_r_neg)));
    const ii_neg: Vec4i32 = @as(Vec4i32, @popCount((tile.i_pos & x_i_neg) | (tile.i_neg & x_i_pos)));
    const rr_neg: Vec4i32 = @as(Vec4i32, @popCount((tile.r_pos & x_r_neg) | (tile.r_neg & x_r_pos)));
    const ii_pos: Vec4i32 = @as(Vec4i32, @popCount((tile.i_pos & x_i_pos) | (tile.i_neg & x_i_neg)));
    re_acc.* += (rr_pos + ii_neg) - (rr_neg + ii_pos);

    const ri_pos: Vec4i32 = @as(Vec4i32, @popCount((tile.r_pos & x_i_pos) | (tile.r_neg & x_i_neg)));
    const ir_pos: Vec4i32 = @as(Vec4i32, @popCount((tile.i_pos & x_r_pos) | (tile.i_neg & x_r_neg)));
    const ri_neg: Vec4i32 = @as(Vec4i32, @popCount((tile.r_pos & x_i_neg) | (tile.r_neg & x_i_pos)));
    const ir_neg: Vec4i32 = @as(Vec4i32, @popCount((tile.i_pos & x_r_neg) | (tile.i_neg & x_r_pos)));
    im_acc.* += (ri_pos + ir_pos) - (ri_neg + ir_neg);
    return true;
}

/// Vectorized 4-Row Batch Matrix-Vector Contraction: y = \gamma * W * x
pub fn contractMatrixVectorSIMD4(
    tiles: []const ComplexTernaryTile4x64,
    x_words: []const ComplexTernaryWord64,
    out_re: []f32,
    out_im: []f32,
    rows: usize,
    words_per_row: usize,
    gamma: f32,
) void {
    std.debug.assert(rows % 4 == 0);
    std.debug.assert(tiles.len == (rows / 4) * words_per_row);
    std.debug.assert(x_words.len == words_per_row);
    std.debug.assert(out_re.len == rows and out_im.len == rows);

    const gamma_vec: Vec4f32 = @splat(gamma);
    const num_row_blocks = rows / 4;

    for (0..num_row_blocks) |rb| {
        const tile_row = tiles[rb * words_per_row .. (rb + 1) * words_per_row];

        var net_re: Vec4i32 = @splat(0);
        var net_im: Vec4i32 = @splat(0);

        for (tile_row, x_words) |tile, x_w| {
            const x_r_pos: Vec4u64 = @splat(x_w.r_pos);
            const x_r_neg: Vec4u64 = @splat(x_w.r_neg);
            const x_i_pos: Vec4u64 = @splat(x_w.i_pos);
            const x_i_neg: Vec4u64 = @splat(x_w.i_neg);

            const ok = stepTile4x64(
                tile,
                x_r_pos,
                x_r_neg,
                x_i_pos,
                x_i_neg,
                &net_re,
                &net_im,
            );
            std.debug.assert(ok);
        }

        const scaled_re: Vec4f32 = @as(Vec4f32, @floatFromInt(net_re)) * gamma_vec;
        const scaled_im: Vec4f32 = @as(Vec4f32, @floatFromInt(net_im)) * gamma_vec;

        const out_offset = rb * 4;
        out_re[out_offset..][0..4].* = scaled_re;
        out_im[out_offset..][0..4].* = scaled_im;
    }
}

/// Cryptographic State-Continuity Waking Seal (S^{(n+1)}).
pub fn computeWakingSeal(
    prev_seal: [32]u8,
    pruned_tombstone_root: [32]u8,
    matrix_words: []const ComplexTernaryWord64,
    gamma: f32,
    kuramoto_r: f32,
    epoch_tick: u64,
) ![32]u8 {
    var mu_hasher = Blake3.init(.{});
    var gamma_buf: [4]u8 = undefined;
    std.mem.writeInt(i32, &gamma_buf, toQ16_16(gamma), .little);
    mu_hasher.update(&gamma_buf);

    for (matrix_words) |w| {
        if (!w.isValid()) return error.CorruptedBitPlaneParity;
        var word_buf: [32]u8 = undefined;
        std.mem.writeInt(u64, word_buf[0..8], w.r_pos, .little);
        std.mem.writeInt(u64, word_buf[8..16], w.r_neg, .little);
        std.mem.writeInt(u64, word_buf[16..24], w.i_pos, .little);
        std.mem.writeInt(u64, word_buf[24..32], w.i_neg, .little);
        mu_hasher.update(&word_buf);
    }

    var mu_compacted: [32]u8 = undefined;
    mu_hasher.finalize(&mu_compacted);

    var seal_hasher = Blake3.init(.{});
    seal_hasher.update(&prev_seal);
    seal_hasher.update(&mu_compacted);
    seal_hasher.update(&pruned_tombstone_root);

    var r_buf: [4]u8 = undefined;
    std.mem.writeInt(i32, &r_buf, toQ16_16(kuramoto_r), .little);
    seal_hasher.update(&r_buf);

    var tick_buf: [8]u8 = undefined;
    std.mem.writeInt(u64, &tick_buf, epoch_tick, .little);
    seal_hasher.update(&tick_buf);

    var next_seal: [32]u8 = undefined;
    seal_hasher.finalize(&next_seal);
    return next_seal;
}

test "UltraDreamState Sigma-Delta packing preserves low-frequency carrier coherence" {
    const N = 64;
    var u_row: [N]f32 = undefined;
    var v_row: [N]f32 = undefined;

    const k0: f32 = 2.0 * math.pi / 16.0;
    const gamma: f32 = 0.85;

    for (0..N) |n| {
        const phase = k0 * @as(f32, @floatFromInt(n));
        u_row[n] = 0.6 * gamma * @cos(phase);
        v_row[n] = 0.6 * gamma * @sin(phase);
    }

    for (28..36) |n| {
        u_row[n] = 0.0;
        v_row[n] = 0.0;
    }

    var packed_row: [1]ComplexTernaryWord64 = undefined;
    packRowSigmaDelta(&u_row, &v_row, &packed_row, gamma, k0);

    try std.testing.expect(packed_row[0].isValid());

    const pruned_mask: u64 = (@as(u64, 0xFF) << 28);
    const active_bits = packed_row[0].r_pos | packed_row[0].r_neg | packed_row[0].i_pos | packed_row[0].i_neg;
    try std.testing.expectEqual(@as(u64, 0), active_bits & pruned_mask);

    var out_re: [1]f32 = undefined;
    var out_im: [1]f32 = undefined;
    contractMatrixVector(&packed_row, &packed_row, &out_re, &out_im, 1, 1, gamma);
    try std.testing.expect(out_re[0] > 20.0);
    try std.testing.expectApproxEqAbs(@as(f32, 0.0), out_im[0], 1e-5);

    const genesis_seal = [_]u8{0x7c} ** 32;
    const tombstone_root = [_]u8{0x00} ** 32;
    const seal = try computeWakingSeal(genesis_seal, tombstone_root, &packed_row, gamma, 0.985, 1);
    try std.testing.expect(!std.mem.eql(u8, &genesis_seal, &seal));
}

test "SIMD 4-row contraction matches scalar contraction bit-for-bit" {
    const rows = 8;
    const words_per_row = 4;
    const total_words = rows * words_per_row;

    var prng = std.Random.DefaultPrng.init(0x7c242080f5f821e5);
    const rand = prng.random();

    var matrix_words: [total_words]ComplexTernaryWord64 = undefined;
    for (&matrix_words) |*w| {
        const r_raw = rand.int(u64);
        const r_mask = rand.int(u64);
        const i_raw = rand.int(u64);
        const i_mask = rand.int(u64);
        w.* = .{
            .r_pos = r_raw & r_mask,
            .r_neg = (~r_raw) & r_mask,
            .i_pos = i_raw & i_mask,
            .i_neg = (~i_raw) & i_mask,
        };
    }

    var x_words: [words_per_row]ComplexTernaryWord64 = undefined;
    for (&x_words) |*xw| {
        const r_raw = rand.int(u64);
        const i_raw = rand.int(u64);
        xw.* = .{
            .r_pos = r_raw,
            .r_neg = ~r_raw,
            .i_pos = i_raw,
            .i_neg = ~i_raw,
        };
    }

    var tiles: [(rows / 4) * words_per_row]ComplexTernaryTile4x64 = undefined;
    packMatrixIntoTiles4x64(&matrix_words, &tiles, rows, words_per_row);

    for (tiles) |t| {
        try std.testing.expect(t.isValid());
    }

    const gamma: f32 = 0.8660254;
    var simd_re: [rows]f32 = undefined;
    var simd_im: [rows]f32 = undefined;
    var scalar_re: [rows]f32 = undefined;
    var scalar_im: [rows]f32 = undefined;

    contractMatrixVectorSIMD4(&tiles, &x_words, &simd_re, &simd_im, rows, words_per_row, gamma);
    contractMatrixVector(&matrix_words, &x_words, &scalar_re, &scalar_im, rows, words_per_row, gamma);

    for (0..rows) |m| {
        try std.testing.expectEqual(scalar_re[m], simd_re[m]);
        try std.testing.expectEqual(scalar_im[m], simd_im[m]);
    }
}
