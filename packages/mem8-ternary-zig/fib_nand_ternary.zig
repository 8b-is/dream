// =============================================================================
// AGENT-01: fib_nand_ternary.zig — Fibonacci in Balanced Ternary via Pure NAND
// =============================================================================
// Ontological Boundary Contract (8B-META-WP-v0.0):
//   * Column A (Mechanical Substrate): Deterministic boolean/integer state
//     machine computing OEIS A000045 (n = 0..39) using a 64-bit ripple-carry
//     adder constructed strictly from primitive 2-input NAND(a, b) gates.
//   * Column B (Architect's Heuristic): pocoo.vaked.dev Boolean-to-Ternary
//     Isomorphism & Visible Parity Law (3 | n <=> F(n) even <=> even non-zero
//     balanced-ternary marks).
// =============================================================================

const std = @import("std");
const testing = std.testing;

/// Primitive 2-input NAND gate — the sole boolean primitive for the adder.
pub inline fn nand(a: u1, b: u1) u1 {
    return ~(a & b);
}

pub inline fn nandNot(a: u1) u1 {
    return nand(a, a);
}

pub inline fn nandAnd(a: u1, b: u1) u1 {
    return nandNot(nand(a, b));
}

pub inline fn nandOr(a: u1, b: u1) u1 {
    return nand(nandNot(a), nandNot(b));
}

pub inline fn nandXor(a: u1, b: u1) u1 {
    const n_ab = nand(a, b);
    return nand(nand(a, n_ab), nand(b, n_ab));
}

pub const FullAdderOut = struct {
    sum: u1,
    cout: u1,
};

/// 1-bit full adder built from 9 primitive 2-input NAND gates.
pub inline fn nandFullAdder(a: u1, b: u1, cin: u1) FullAdderOut {
    const g1 = nand(a, b);
    const g2 = nand(a, g1);
    const g3 = nand(b, g1);
    const axb = nand(g2, g3);
    const g5 = nand(axb, cin);
    const g6 = nand(axb, g5);
    const g7 = nand(cin, g5);
    const s = nand(g6, g7);
    const cout = nand(g1, g5);
    return .{ .sum = s, .cout = cout };
}

/// 64-bit ripple-carry adder built strictly from 576 NAND gates (64 * 9).
pub fn nandAdd64(x: u64, y: u64) u64 {
    var carry: u1 = 0;
    var result: u64 = 0;
    var bit: u6 = 0;
    while (true) : (bit += 1) {
        const a: u1 = @truncate((x >> bit) & 1);
        const b: u1 = @truncate((y >> bit) & 1);
        const fa = nandFullAdder(a, b, carry);
        result |= (@as(u64, fa.sum) << bit);
        carry = fa.cout;
        if (bit == 63) break;
    }
    return result;
}

/// Encode an unsigned integer into LSB-first balanced ternary {-1:'-', 0:'0', +1:'+'},
/// returning the number of non-zero trits (popcnt(B^+ | B^-)).
pub fn countNonZeroBalancedTernaryMarks(n_in: u64) u32 {
    if (n_in == 0) return 0;
    var n = n_in;
    var non_zero: u32 = 0;
    while (n > 0) {
        const rem = n % 3;
        n /= 3;
        if (rem == 1) {
            non_zero += 1;
        } else if (rem == 2) {
            non_zero += 1;
            n += 1;
        }
    }
    return non_zero;
}

test "Fibonacci NAND-gate ripple-carry adder & balanced-ternary parity law (n = 0..39)" {
    var f_prev: u64 = 0;
    var f_curr: u64 = 1;
    var n: usize = 0;
    while (n <= 39) : (n += 1) {
        const val = if (n == 0) 0 else if (n == 1) 1 else blk: {
            const next_val = nandAdd64(f_prev, f_curr);
            f_prev = f_curr;
            f_curr = next_val;
            break :blk f_curr;
        };
        const nz = countNonZeroBalancedTernaryMarks(val);
        const is_even_val = (val % 2) == 0;
        const is_even_marks = (nz % 2) == 0;
        const is_div3 = (n % 3) == 0;
        try testing.expectEqual(is_div3, is_even_val);
        try testing.expectEqual(is_even_val, is_even_marks);
    }
    try testing.expectEqual(@as(u64, 63245986), f_curr);
}
